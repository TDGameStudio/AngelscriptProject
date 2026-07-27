[CmdletBinding()]
param(
	[string]$ProjectRoot,
	[string]$InputPath,
	[string]$OutputPath,
	[switch]$RequireComplete
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
if ([string]::IsNullOrWhiteSpace($InputPath))
{
	$InputPath = Join-Path $ChangeRoot 'audits\internal-methods.csv'
}
if ([string]::IsNullOrWhiteSpace($OutputPath))
{
	$OutputPath = Join-Path $ChangeRoot 'audits\internal-method-reconciliation.csv'
}

$AllowedStates = @(
	'DirectCovered',
	'PublicContractCovered',
	'NotApplicable',
	'ApiDeferred'
)
$Rows = foreach ($Method in Import-Csv -LiteralPath $InputPath)
{
	$Issue = ''
	if ($Method.CurrentStatus -notin $AllowedStates)
	{
		$Issue = "Unresolved status '$($Method.CurrentStatus)'"
	}
	elseif ([string]::IsNullOrWhiteSpace($Method.FinalCoverageIds))
	{
		$Issue = 'Terminal disposition requires a stable coverage ID'
	}
	elseif ($Method.CurrentStatus -in @('NotApplicable', 'ApiDeferred') -and
		-not ($Method.PSObject.Properties.Name -contains 'Rationale' -and -not [string]::IsNullOrWhiteSpace($Method.Rationale)))
	{
		$Issue = "$($Method.CurrentStatus) requires a concrete rationale or prerequisite"
	}

	[pscustomobject]@{
		ImplementationUnit = $Method.ImplementationUnit
		Class = $Method.Class
		Method = $Method.Method
		Line = $Method.Line
		Disposition = $Method.CurrentStatus
		FinalCoverageIds = $Method.FinalCoverageIds
		Rationale = $(if ($Method.PSObject.Properties.Name -contains 'Rationale') { $Method.Rationale } else { '' })
		State = $(if ([string]::IsNullOrWhiteSpace($Issue)) { 'Final' } else { 'Pending' })
		Issue = $Issue
	}
}

$Rows | Export-Csv -LiteralPath $OutputPath -NoTypeInformation -Encoding utf8
$Failures = @($Rows | Where-Object State -eq 'Pending')
if ($RequireComplete -and $Failures.Count -gt 0)
{
	throw "Internal-method reconciliation has $($Failures.Count) unresolved rows. First: $($Failures[0].ImplementationUnit) $($Failures[0].Class).$($Failures[0].Method): $($Failures[0].Issue)"
}

[pscustomobject]@{
	Rows = @($Rows).Count
	Final = @($Rows | Where-Object State -eq 'Final').Count
	Pending = $Failures.Count
	Output = $OutputPath
}
