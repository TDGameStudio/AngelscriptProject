[CmdletBinding()]
param(
	[string] $ProjectRoot
)

$ErrorActionPreference = 'Stop'

function Find-ProjectRoot
{
	param([string] $StartPath)

	$Cursor = [System.IO.DirectoryInfo]::new(
		[System.IO.Path]::GetFullPath($StartPath))
	while ($null -ne $Cursor)
	{
		if ((Test-Path -LiteralPath (Join-Path $Cursor.FullName 'AGENTS.md') -PathType Leaf) -and
			(Test-Path -LiteralPath (Join-Path $Cursor.FullName 'Plugins/Angelscript') -PathType Container))
		{
			return $Cursor.FullName
		}

		$Cursor = $Cursor.Parent
	}

	throw "Could not locate the AngelscriptProject root above '$StartPath'."
}

if ([string]::IsNullOrWhiteSpace($ProjectRoot))
{
	$ProjectRoot = Find-ProjectRoot -StartPath $PSScriptRoot
}
else
{
	$ProjectRoot = [System.IO.Path]::GetFullPath($ProjectRoot)
}

$RuntimeRoot = Join-Path $ProjectRoot 'Plugins/Angelscript/Source/AngelscriptRuntime'
$ThirdPartySource = Join-Path $RuntimeRoot 'ThirdParty/angelscript/source'
$Files = @{
	ScriptFunction = Join-Path $ThirdPartySource 'as_scriptfunction.h'
	Builder = Join-Path $ThirdPartySource 'as_builder.cpp'
	Compiler = Join-Path $ThirdPartySource 'as_compiler.cpp'
	Preprocessor = Join-Path $RuntimeRoot 'Preprocessor/AngelscriptPreprocessor.cpp'
	AssetTest = Join-Path $ProjectRoot 'Plugins/Angelscript/Source/AngelscriptTest/Generator/Core/AngelscriptLiteralAssetPostInitTests.cpp'
	TraitResearch = Join-Path $ProjectRoot 'openspec/changes/feature-as-typed-semantic-aot/research/function-traits-and-effective-receiver.md'
}

$Texts = @{}
foreach ($Entry in $Files.GetEnumerator())
{
	if (-not (Test-Path -LiteralPath $Entry.Value -PathType Leaf))
	{
		throw "Required evidence file is missing: $($Entry.Value)"
	}

	$Texts[$Entry.Key] = [System.IO.File]::ReadAllText($Entry.Value)
}

$Failures = [System.Collections.Generic.List[string]]::new()
$Passed = 0

function Assert-SourcePattern
{
	param(
		[Parameter(Mandatory = $true)]
		[string] $Name,

		[Parameter(Mandatory = $true)]
		[string] $Text,

		[Parameter(Mandatory = $true)]
		[string] $Pattern,

		[int] $MinimumMatches = 1
	)

	$MatchCount = [System.Text.RegularExpressions.Regex]::Matches(
		$Text,
		$Pattern,
		[System.Text.RegularExpressions.RegexOptions]::Singleline).Count
	if ($MatchCount -lt $MinimumMatches)
	{
		$script:Failures.Add(
			"${Name}: expected at least $MinimumMatches match(es), found $MatchCount.")
		return
	}

	$script:Passed += 1
}

Assert-SourcePattern -Name 'stable trait bit' -Text $Texts.ScriptFunction `
	-Pattern 'asTRAIT_EXTERNAL_IMPLICIT_THIS\s*=\s*0x200000'
Assert-SourcePattern -Name 'global-only builder classification' -Text $Texts.Builder `
	-Pattern '!objType[^\r\n]*EXTERNAL_IMPLICIT_THIS_TOKEN'
Assert-SourcePattern -Name 'parameter-zero receiver capture' -Text $Texts.Compiler `
	-Pattern 'GetTrait\(asTRAIT_EXTERNAL_IMPLICIT_THIS\)\s*&&\s*n\s*==\s*0\s*&&\s*type\.GetTypeInfo\(\)\s*!=\s*nullptr'
Assert-SourcePattern -Name 'receiver type comes from parameter zero' -Text $Texts.Compiler `
	-Pattern 'ExternalThisType\s*=\s*CastToObjectType\(type\.GetTypeInfo\(\)\)'
Assert-SourcePattern -Name 'receiver ABI offset comes from parameter zero' -Text $Texts.Compiler `
	-Pattern 'ExternalThisOffset\s*=\s*stackPos'
Assert-SourcePattern -Name 'unqualified property and method lookup use external receiver type' `
	-Text $Texts.Compiler -Pattern 'ThisObjectType\s*=\s*ExternalThisType' -MinimumMatches 2
Assert-SourcePattern -Name 'unqualified property and method lookup use external receiver offset' `
	-Text $Texts.Compiler -Pattern 'ThisObjectStackOffset\s*=\s*ExternalThisOffset' -MinimumMatches 2
Assert-SourcePattern -Name 'asset lowering keeps declared receiver parameter' -Text $Texts.Preprocessor `
	-Pattern 'void __Init_\{Name\}\(\{Type\} \{Name\}\) external_implicit_this'
Assert-SourcePattern -Name 'asset lowering passes receiver as a normal argument' -Text $Texts.Preprocessor `
	-Pattern '__Init_\{Name\}\(__Asset_\{Name\}\);'
Assert-SourcePattern -Name 'asset body uses unqualified receiver properties' -Text $Texts.AssetTest `
	-Pattern 'asset ExampleAsset of ULiteralPostInitAsset\s*\{\s*bWasPostInit\s*=\s*true;\s*PostInitCalls\s*\+=\s*1;\s*InitMarker\s*=\s*1337;'

$SourceTraits = @(
	[System.Text.RegularExpressions.Regex]::Matches(
		$Texts.ScriptFunction,
		'asTRAIT_([A-Z0-9_]+)\s*=') |
		ForEach-Object { $_.Groups[1].Value } |
		Sort-Object -Unique)
$TraitSectionMatch = [System.Text.RegularExpressions.Regex]::Match(
	$Texts.TraitResearch,
	'## 5\. Maintained fork trait policy matrix(?<body>.*?)## 6\.',
	[System.Text.RegularExpressions.RegexOptions]::Singleline)
if (-not $TraitSectionMatch.Success)
{
	$Failures.Add('trait policy coverage: policy-matrix section could not be located.')
}
else
{
	$DocumentedTraits = @(
		[System.Text.RegularExpressions.Regex]::Matches(
			$TraitSectionMatch.Groups['body'].Value,
			'\| `([A-Z][A-Z0-9_]+)` \|') |
			ForEach-Object { $_.Groups[1].Value } |
			Sort-Object -Unique)
	$MissingTraits = @($SourceTraits | Where-Object { $_ -notin $DocumentedTraits })
	$ExtraTraits = @($DocumentedTraits | Where-Object { $_ -notin $SourceTraits })
	if ($MissingTraits.Count -gt 0 -or $ExtraTraits.Count -gt 0)
	{
		$Failures.Add(
			"trait policy coverage: missing=[$($MissingTraits -join ',')] extra=[$($ExtraTraits -join ',')].")
	}
	else
	{
		$Passed += 1
	}
}

if ($Failures.Count -gt 0)
{
	foreach ($Failure in $Failures)
	{
		Write-Error $Failure -ErrorAction Continue
	}

	throw "Function-trait source evidence probe failed: $($Failures.Count) assertion(s)."
}

Write-Output "PASS function-trait source evidence: $Passed assertions"
Write-Output 'Contract: parameter 0 remains a declared ABI argument and also supplies the callee-body effective receiver.'
