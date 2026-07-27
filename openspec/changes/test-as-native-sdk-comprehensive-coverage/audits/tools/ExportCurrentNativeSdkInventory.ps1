[CmdletBinding()]
param(
	[string]$ProjectRoot,
	[string]$OutputRoot
)

$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrWhiteSpace($ProjectRoot))
{
	$ProjectRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..\..\..\..')).Path
}
if ([string]::IsNullOrWhiteSpace($OutputRoot))
{
	$OutputRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
}

$SdkRoot = Join-Path $ProjectRoot 'Plugins\Angelscript\Source\AngelscriptTest\AngelScriptSDK'
if (-not (Test-Path -LiteralPath $SdkRoot))
{
	throw "Native SDK root was not found: $SdkRoot"
}

$Files = @(Get-ChildItem -LiteralPath $SdkRoot -Recurse -Filter '*.cpp' -File | Sort-Object FullName)
$FileRows = [System.Collections.Generic.List[object]]::new()
$MethodRows = [System.Collections.Generic.List[object]]::new()
$AssertionRows = [System.Collections.Generic.List[object]]::new()

foreach ($File in $Files)
{
	$Text = Get-Content -LiteralPath $File.FullName -Raw
	$RelativePath = $File.FullName.Substring($SdkRoot.Length).TrimStart([char[]]@('\', '/')).Replace('\', '/')
	$Domain = $RelativePath.Split('/')[0]
	$ClassMatches = [regex]::Matches(
		$Text,
		'TEST_CLASS_WITH_FLAGS(?:_AND_TAGS)?\s*\(\s*(?<Class>[A-Za-z_][A-Za-z0-9_]*)\s*,\s*"(?<Prefix>[^"]+)"',
		[System.Text.RegularExpressions.RegexOptions]::Singleline)
	$Classes = @($ClassMatches | ForEach-Object { $_.Groups['Class'].Value })
	$Prefixes = @($ClassMatches | ForEach-Object { $_.Groups['Prefix'].Value })
	$MethodMatches = [regex]::Matches($Text, 'TEST_METHOD\s*\(\s*(?<Method>[A-Za-z_][A-Za-z0-9_]*)\s*\)')
	$LineCount = (Get-Content -LiteralPath $File.FullName).Count
	$RawBlockCount = ([regex]::Matches($Text, 'R"AS\(')).Count
	$AnsiWrapperCount = ([regex]::Matches($Text, 'ASTEST_AS_ANSI\s*\(')).Count
	$DisabledClass = $Text -match 'TEST_CLASS_WITH_FLAGS_AND_TAGS' -and $Text -match 'EAutomationTestFlags::Disabled'

	$FileRows.Add([pscustomobject]@{
		Domain = $Domain
		File = $RelativePath
		Classes = ($Classes -join ';')
		Prefixes = ($Prefixes -join ';')
		MethodCount = $MethodMatches.Count
		LineCount = $LineCount
		RawBlockCount = $RawBlockCount
		AnsiWrapperCount = $AnsiWrapperCount
		DisabledClass = $DisabledClass
	})

	foreach ($MethodMatch in $MethodMatches)
	{
		$Line = ($Text.Substring(0, $MethodMatch.Index) -split "`n").Count
		$OwningClassMatch = @($ClassMatches | Where-Object Index -lt $MethodMatch.Index | Select-Object -Last 1)
		$OwningClass = $(if ($OwningClassMatch.Count -gt 0) { $OwningClassMatch[0].Groups['Class'].Value } else { '' })
		$MethodRows.Add([pscustomobject]@{
			Domain = $Domain
			File = $RelativePath
			Class = $OwningClass
			Prefixes = ($Prefixes -join ';')
			Method = $MethodMatch.Groups['Method'].Value
			Line = $Line
			DisabledClass = $DisabledClass
			Disposition = 'Retained'
			FinalCoverageIds = ''
		})
	}

	$AssertionMatches = [regex]::Matches(
		$Text,
		'ASSERT_THAT\s*\((?<Body>.*?)\)\s*;',
		[System.Text.RegularExpressions.RegexOptions]::Singleline)
	foreach ($AssertionMatch in $AssertionMatches)
	{
		$Line = ($Text.Substring(0, $AssertionMatch.Index) -split "`n").Count
		$OwningMethodMatch = @($MethodMatches | Where-Object Index -lt $AssertionMatch.Index | Select-Object -Last 1)
		$OwningClassMatch = @($ClassMatches | Where-Object Index -lt $AssertionMatch.Index | Select-Object -Last 1)
		$Body = ($AssertionMatch.Groups['Body'].Value -replace '\s+', ' ').Trim()
		$HashBytes = [Security.Cryptography.SHA256]::HashData([Text.Encoding]::UTF8.GetBytes($Body))
		$AssertionRows.Add([pscustomobject]@{
			Domain = $Domain
			File = $RelativePath
			Class = $(if ($OwningClassMatch.Count -gt 0) { $OwningClassMatch[0].Groups['Class'].Value } else { '' })
			Method = $(if ($OwningMethodMatch.Count -gt 0) { $OwningMethodMatch[0].Groups['Method'].Value } elseif ($OwningClassMatch.Count -gt 0) { '<ClassHelper>' } else { '<FileHelper>' })
			Line = $Line
			AssertionSha256 = [Convert]::ToHexString($HashBytes).ToLowerInvariant()
			Assertion = $Body
			Disposition = 'Retained'
			FinalCoverageIds = ''
		})
	}
}

$FilePath = Join-Path $OutputRoot 'current-files.csv'
$MethodPath = Join-Path $OutputRoot 'current-methods.csv'
$AssertionPath = Join-Path $OutputRoot 'current-assertions.csv'
$FileRows | Export-Csv -LiteralPath $FilePath -NoTypeInformation -Encoding utf8
$MethodRows | Export-Csv -LiteralPath $MethodPath -NoTypeInformation -Encoding utf8
$AssertionRows | Export-Csv -LiteralPath $AssertionPath -NoTypeInformation -Encoding utf8

$Summary = [pscustomobject]@{
	Files = $FileRows.Count
	Methods = $MethodRows.Count
	Assertions = $AssertionRows.Count
	Lines = ($FileRows | Measure-Object LineCount -Sum).Sum
	RawBlocks = ($FileRows | Measure-Object RawBlockCount -Sum).Sum
	AnsiWrappers = ($FileRows | Measure-Object AnsiWrapperCount -Sum).Sum
	DisabledMethods = @($MethodRows | Where-Object DisabledClass).Count
	ActiveMethods = @($MethodRows | Where-Object { -not $_.DisabledClass }).Count
}

$Summary | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $OutputRoot 'current-summary.json') -Encoding utf8
$Summary
