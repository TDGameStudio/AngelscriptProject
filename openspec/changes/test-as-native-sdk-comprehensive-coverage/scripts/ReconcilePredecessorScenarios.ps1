[CmdletBinding()]
param(
	[string]$ProjectRoot,
	[string]$OutputPath,
	[string]$DispositionPath,
	[switch]$RequireFinalDisposition
)

$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrWhiteSpace($ProjectRoot))
{
	$ProjectRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..\..\..')).Path
}
else
{
	$ProjectRoot = (Resolve-Path -LiteralPath $ProjectRoot).Path
}
if ([string]::IsNullOrWhiteSpace($OutputPath))
{
	$OutputPath = Join-Path (Resolve-Path (Join-Path $PSScriptRoot '..\audits')).Path 'predecessor-baseline.csv'
}

$PredecessorPath = Join-Path $ProjectRoot 'openspec\changes\refactor-as-native-sdk-regression-suite\audits\test-scenarios.md'
$SdkRoot = Join-Path $ProjectRoot 'Plugins\Angelscript\Source\AngelscriptTest\AngelScriptSDK'
if ([string]::IsNullOrWhiteSpace($DispositionPath))
{
	$DispositionPath = Join-Path (Split-Path -Parent $OutputPath) 'predecessor-dispositions.csv'
}

if (-not (Test-Path -LiteralPath $PredecessorPath))
{
	throw "Predecessor scenario record was not found: $PredecessorPath"
}

$SourceFiles = @(Get-ChildItem -LiteralPath $SdkRoot -Recurse -Filter '*.cpp' -File)
$SourceRecords = foreach ($File in $SourceFiles)
{
	[pscustomobject]@{
		File = $File.FullName.Substring($SdkRoot.Length).TrimStart([char[]]@('\', '/')).Replace('\', '/')
		Text = Get-Content -LiteralPath $File.FullName -Raw
	}
}

$Rows = [System.Collections.Generic.List[object]]::new()
$Domain = ''
$LanguageTheme = ''
$LastOwner = ''
$InLanguage = $false

foreach ($Line in Get-Content -LiteralPath $PredecessorPath)
{
	if ($Line -match '^## Language domain$')
	{
		$Domain = 'Language'
		$InLanguage = $true
		continue
	}

	if ($Line -match '^## Cross-theme interaction gate$')
	{
		$InLanguage = $false
		continue
	}

	if (-not $InLanguage -and $Line -match '^## (?<Domain>.+) domain$')
	{
		$Domain = $Matches['Domain']
		continue
	}

	if ($InLanguage -and $Line -match '^### (?<Theme>.+)$')
	{
		$LanguageTheme = $Matches['Theme']
		continue
	}

	$Owner = ''
	$Method = ''
	if (-not $InLanguage -and $Line -match '^\|\s*(?<Owner>`[^`]+`|same)\s*\|\s*`(?<Method>[^`]+)`\s*\|')
	{
		$OwnerToken = $Matches['Owner']
		if ($OwnerToken -ne 'same')
		{
			$LastOwner = $OwnerToken.Trim('`')
		}
		$Owner = $LastOwner
		$Method = $Matches['Method']
	}
	elseif ($InLanguage -and $Line -match '^- `(?<Method>[^`]+)`$')
	{
		$Owner = "Language/$LanguageTheme"
		$Method = $Matches['Method']
	}

	if ([string]::IsNullOrWhiteSpace($Method))
	{
		continue
	}

	$Pattern = 'TEST_METHOD\s*\(\s*' + [regex]::Escape($Method) + '\s*\)'
	$ActualFiles = @($SourceRecords | Where-Object { $_.Text -match $Pattern } | ForEach-Object File)
	$Rows.Add([pscustomobject]@{
		Domain = $Domain
		Theme = $(if ($Domain -eq 'Language') { $LanguageTheme } else { '' })
		PlannedOwner = $Owner
		RequiredMethod = $Method
		Present = $ActualFiles.Count -gt 0
		ActualFiles = ($ActualFiles -join ';')
		FinalDisposition = 'Pending'
		FinalCoverageIds = ''
		Rationale = ''
	})
}

$UniqueRows = @($Rows | Sort-Object Domain, Theme, RequiredMethod -Unique)
$UniqueRows | Export-Csv -LiteralPath $OutputPath -NoTypeInformation -Encoding utf8

if ($RequireFinalDisposition)
{
	if (-not (Test-Path -LiteralPath $DispositionPath))
	{
		throw "Final predecessor disposition file is missing: $DispositionPath"
	}

	$Dispositions = @(Import-Csv -LiteralPath $DispositionPath)
	$ByMethod = @{}
	foreach ($Disposition in $Dispositions)
	{
		$Key = "$($Disposition.Domain)|$($Disposition.Theme)|$($Disposition.RequiredMethod)"
		if ($ByMethod.ContainsKey($Key))
		{
			throw "Duplicate predecessor disposition: $Key"
		}
		$ByMethod[$Key] = $Disposition
	}

	foreach ($Row in $UniqueRows)
	{
		$Key = "$($Row.Domain)|$($Row.Theme)|$($Row.RequiredMethod)"
		if (-not $ByMethod.ContainsKey($Key))
		{
			throw "Missing predecessor disposition: $Key"
		}
		$Disposition = $ByMethod[$Key]
		if ($Disposition.FinalDisposition -notin @('Implemented', 'Superseded', 'Obsolete', 'RejectedRequirement', 'ApiDeferred'))
		{
			throw "Invalid final predecessor disposition '$($Disposition.FinalDisposition)' for $Key"
		}
		if ($Disposition.FinalDisposition -in @('Implemented', 'Superseded') -and [string]::IsNullOrWhiteSpace($Disposition.FinalCoverageIds))
		{
			throw "Final coverage IDs are required for $Key"
		}
		if ($Disposition.FinalDisposition -in @('Obsolete', 'RejectedRequirement') -and [string]::IsNullOrWhiteSpace($Disposition.Rationale))
		{
			throw "A rationale is required for $Key"
		}
		if ($Disposition.FinalDisposition -eq 'ApiDeferred' -and
			([string]::IsNullOrWhiteSpace($Disposition.FinalCoverageIds) -or [string]::IsNullOrWhiteSpace($Disposition.Rationale)))
		{
			throw "ApiDeferred requires a stable coverage ID and concrete prerequisite for $Key"
		}
	}
}

$PresentCount = @($UniqueRows | Where-Object Present).Count
$MissingCount = @($UniqueRows | Where-Object { -not $_.Present }).Count
[pscustomobject]@{
	Required = $UniqueRows.Count
	Present = $PresentCount
	Missing = $MissingCount
	FinalDispositionChecked = [bool]$RequireFinalDisposition
	Output = $OutputPath
}
