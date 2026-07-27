[CmdletBinding()]
param(
	[string]$ProjectRoot,
	[string]$OutputPath,
	[switch]$RequireClean
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
$ChangeRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
if ([string]::IsNullOrWhiteSpace($OutputPath))
{
	$OutputPath = Join-Path $ChangeRoot 'audits\planning-record-violations.csv'
}

$Rows = [System.Collections.Generic.List[object]]::new()
$TaskPath = Join-Path $ChangeRoot 'tasks.md'
$TaskIds = [regex]::Matches(
	(Get-Content -LiteralPath $TaskPath -Raw),
	'(?m)^- \[[ xX]\]\s+(?<Id>[0-9]+(?:\.[0-9A-Za-z-]+)+)\s+')
foreach ($Group in $TaskIds | Group-Object { $_.Groups['Id'].Value } | Where-Object Count -gt 1)
{
	$Rows.Add([pscustomobject]@{
		Rule = 'UniqueActiveTaskId'
		File = 'tasks.md'
		Detail = "Duplicate active task ID '$($Group.Name)'"
	})
}

$ForbiddenThemeWord = ([char]77) + 'atrix'
$ActivePlanningFiles = @(
	'tasks.md',
	'proposal.md',
	'design.md',
	'impact-map.md',
	'progress.md',
	'runtime-change-map.md'
)
foreach ($RelativePath in $ActivePlanningFiles)
{
	$Path = Join-Path $ChangeRoot $RelativePath
	if ((Get-Content -LiteralPath $Path -Raw) -cmatch "\b$ForbiddenThemeWord\b")
	{
		$Rows.Add([pscustomobject]@{
			Rule = 'ForbiddenGenericThemeWord'
			File = $RelativePath
			Detail = 'Use a concrete test subject name instead of the generic forbidden term.'
		})
	}
}

$LinkedChanges = @(
	'fix-as-reference-bytecode-ownership-persistence',
	'fix-as-script-class-restore-lifecycle',
	'fix-as-object-last-native-calling-convention',
	'fix-as-engine-property-default-initialization',
	'fix-as-static-jit-debug-text-whitespace',
	'fix-as-switch-int-max-lowering',
	'fix-as-double-int64-bytecode-execution'
)
$RuntimeMapText = Get-Content -LiteralPath (Join-Path $ChangeRoot 'runtime-change-map.md') -Raw
foreach ($LinkedChange in $LinkedChanges)
{
	$LinkedRoot = Join-Path $ProjectRoot "openspec\changes\$LinkedChange"
	if (-not (Test-Path -LiteralPath $LinkedRoot) -or $RuntimeMapText -notmatch [regex]::Escape($LinkedChange))
	{
		$Rows.Add([pscustomobject]@{
			Rule = 'LinkedRuntimeChange'
			File = 'runtime-change-map.md'
			Detail = "Missing linked change or reference '$LinkedChange'"
		})
	}
}

$ProgressText = Get-Content -LiteralPath (Join-Path $ChangeRoot 'progress.md') -Raw
$HasTerminalActiveCount = $ProgressText -match '(?<ActiveCount>[1-9][0-9]*)/\k<ActiveCount> PASS'
$HasGeneratedSourceTotal =
	$ProgressText -match '\|\s*Unique printed generated-source IDs\s*\|\s*[1-9][0-9,]*\s*\|'
$HasAuthoritativeReport =
	$ProgressText -match 'Saved/Tests/[^`\r\n]+/Report/index\.json'
if (-not $HasTerminalActiveCount -or -not $HasGeneratedSourceTotal -or -not $HasAuthoritativeReport)
{
	$Rows.Add([pscustomobject]@{
		Rule = 'ReviewedExecutionBaseline'
		File = 'progress.md'
		Detail = 'Terminal active count, generated-source total, or authoritative report path is missing.'
	})
}
if ($ProgressText -notmatch 'no source-line target' -and $ProgressText -notmatch 'no replacement line')
{
	$Rows.Add([pscustomobject]@{
		Rule = 'NoPhysicalLineQuota'
		File = 'progress.md'
		Detail = 'The retired physical-line target must be stated explicitly.'
	})
}

$Rows | Export-Csv -LiteralPath $OutputPath -NoTypeInformation -Encoding utf8
if ($RequireClean -and $Rows.Count -gt 0)
{
	throw "Planning-record validation found $($Rows.Count) violations. First: $($Rows[0].File) $($Rows[0].Detail)"
}

[pscustomobject]@{
	Violations = $Rows.Count
	Output = $OutputPath
}
