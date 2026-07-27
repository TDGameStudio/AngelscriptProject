[CmdletBinding()]
param(
	[string]$ChangeRoot,
	[string]$OutputPath
)

$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrWhiteSpace($ChangeRoot))
{
	$ChangeRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
}
else
{
	$ChangeRoot = (Resolve-Path -LiteralPath $ChangeRoot).Path
}

if ([string]::IsNullOrWhiteSpace($OutputPath))
{
	$OutputPath = Join-Path $ChangeRoot 'audits\internal-method-dispositions.csv'
}

$InventoryPath = Join-Path $ChangeRoot 'audits\internal-methods.csv'
$EngineCompilerReviewPath = Join-Path $ChangeRoot 'handoffs\internal-method-engine-frontend-compiler-review-v2.csv'
$RuntimeLanguageReviewPath = Join-Path $ChangeRoot 'handoffs\internal-method-runtime-language-review.csv'
$RuntimeLanguageAddendumPath = Join-Path $ChangeRoot 'handoffs\internal-method-runtime-language-review-addendum.csv'
$CompilerImplementationPath = Join-Path $ChangeRoot 'handoffs\compiler-internal-deferred-implementation.csv'

function Get-ExactMethodKey
{
	param($Row)

	return '{0}|{1}|{2}|{3}' -f $Row.ImplementationUnit, $Row.Class, $Row.Method, $Row.Line
}

function Get-MethodKeyWithoutLine
{
	param($Row)

	return '{0}|{1}|{2}' -f $Row.ImplementationUnit, $Row.Class, $Row.Method
}

function Add-UniqueRow
{
	param(
		[hashtable]$Map,
		[string]$Key,
		$Row,
		[string]$Source
	)

	if ($Map.ContainsKey($Key))
	{
		throw "Duplicate internal-method key '$Key' in $Source."
	}
	$Map[$Key] = $Row
}

$Inventory = @(Import-Csv -LiteralPath $InventoryPath)
$ReviewedRows = @(
	@(Import-Csv -LiteralPath $EngineCompilerReviewPath)
	@(Import-Csv -LiteralPath $RuntimeLanguageReviewPath)
)
$AddendumRows = @(Import-Csv -LiteralPath $RuntimeLanguageAddendumPath)
$CompilerRows = @(Import-Csv -LiteralPath $CompilerImplementationPath)

if ($Inventory.Count -ne 1002)
{
	throw "Expected the frozen 1,002-row internal-method inventory, found $($Inventory.Count). Rebaseline the inventory and reviews deliberately before finalizing."
}
if ($ReviewedRows.Count -ne 1001)
{
	throw "Expected 1,001 reviewed inventory rows before the CreatePrimitive addendum, found $($ReviewedRows.Count)."
}

$ReviewByExactKey = @{}
foreach ($Row in $ReviewedRows)
{
	Add-UniqueRow -Map $ReviewByExactKey -Key (Get-ExactMethodKey $Row) -Row $Row -Source 'primary reviews'
}

$AddendumByExactKey = @{}
foreach ($Row in $AddendumRows)
{
	Add-UniqueRow -Map $AddendumByExactKey -Key (Get-ExactMethodKey $Row) -Row $Row -Source 'runtime/language addendum'
}

$CompilerByMethodKey = @{}
foreach ($Row in $CompilerRows)
{
	Add-UniqueRow -Map $CompilerByMethodKey -Key (Get-MethodKeyWithoutLine $Row) -Row $Row -Source 'compiler implementation handoff'
}

$MissingPrimaryReviewKeys = [System.Collections.Generic.List[string]]::new()
$Results = foreach ($Method in $Inventory)
{
	$ExactKey = Get-ExactMethodKey $Method
	$MethodKey = Get-MethodKeyWithoutLine $Method
	$Review = $ReviewByExactKey[$ExactKey]
	$Addendum = $AddendumByExactKey[$ExactKey]
	$CompilerImplementation = $CompilerByMethodKey[$MethodKey]

	if ($null -eq $Review)
	{
		if ($null -eq $Addendum -or $Addendum.PriorDisposition -ne 'Missing')
		{
			$MissingPrimaryReviewKeys.Add($ExactKey)
			continue
		}

		$Disposition = 'DirectCovered'
		$CoverageIds = $Addendum.ProductId
		$Rationale = 'Direct focused owner added after the primary review. Oracle: {0} Source evidence: {1}' -f `
			$Addendum.ExactOracle, $Addendum.SourceEvidence
	}
	else
	{
		$Disposition = $Review.Disposition
		$CoverageIds = $Review.FinalCoverageIds
		$Rationale = $Review.Rationale
	}

	if ($null -ne $Addendum -and $Addendum.PriorDisposition -ne 'Missing')
	{
		if ($Addendum.FeasibilityClass -eq 'ImmediateDirectTestGap')
		{
			$Disposition = 'DirectCovered'
			$CoverageIds = $Addendum.ProductId
			$Rationale = 'Direct focused owner now exercises the exact internal method. Oracle: {0} Source evidence: {1}' -f `
				$Addendum.ExactOracle, $Addendum.SourceEvidence
		}
		else
		{
			$Disposition = 'ApiDeferred'
			$CoverageIds = $Addendum.ProductId
			$Rationale = '{0}. Concrete prerequisite: {1} Exact future oracle: {2} Source evidence: {3}' -f `
				$Addendum.FeasibilityClass, $Addendum.Prerequisite, $Addendum.ExactOracle, $Addendum.SourceEvidence
		}
	}

	if ($null -ne $CompilerImplementation)
	{
		$Disposition = $CompilerImplementation.RevisedDisposition
		if ($Disposition -eq 'DirectCovered')
		{
			$CoverageIds = $CompilerImplementation.ProductId
			$Rationale = '{0} Reachability: {1} Evidence: {2}' -f `
				$CompilerImplementation.MethodOracle,
				$CompilerImplementation.CurrentForkReachability,
				$CompilerImplementation.PrerequisiteOrEvidence
		}
		else
		{
			# Preserve the stable internal deferred ID from the primary review. The
			# selected-2.38 product is intentionally not an enabled current-fork owner.
			$Rationale = '{0} Current reachability: {1} Concrete prerequisite: {2}' -f `
				$CompilerImplementation.MethodOracle,
				$CompilerImplementation.CurrentForkReachability,
				$CompilerImplementation.PrerequisiteOrEvidence
		}
	}

	[pscustomobject]@{
		ImplementationUnit = $Method.ImplementationUnit
		Class = $Method.Class
		Method = $Method.Method
		Line = $Method.Line
		CurrentStatus = $Disposition
		FinalCoverageIds = $CoverageIds
		Rationale = $Rationale
	}
}

if ($MissingPrimaryReviewKeys.Count -gt 0)
{
	throw "Primary reviews and addendum do not cover $($MissingPrimaryReviewKeys.Count) inventory rows. First: $($MissingPrimaryReviewKeys[0])"
}
if (@($Results).Count -ne $Inventory.Count)
{
	throw "Final disposition row count $(@($Results).Count) does not match inventory count $($Inventory.Count)."
}

$InvalidRows = @($Results | Where-Object {
	$_.CurrentStatus -notin @('DirectCovered', 'PublicContractCovered', 'NotApplicable', 'ApiDeferred') -or
	[string]::IsNullOrWhiteSpace($_.FinalCoverageIds) -or
	($_.CurrentStatus -in @('NotApplicable', 'ApiDeferred') -and [string]::IsNullOrWhiteSpace($_.Rationale))
})
if ($InvalidRows.Count -gt 0)
{
	$First = $InvalidRows[0]
	throw "Final disposition validation failed for $($First.ImplementationUnit) $($First.Class).$($First.Method)."
}

$OutputDirectory = Split-Path -Parent $OutputPath
if (-not (Test-Path -LiteralPath $OutputDirectory))
{
	New-Item -ItemType Directory -Path $OutputDirectory | Out-Null
}
$Results | Export-Csv -LiteralPath $OutputPath -NoTypeInformation -Encoding utf8

[pscustomobject]@{
	Rows = @($Results).Count
	DirectCovered = @($Results | Where-Object CurrentStatus -eq 'DirectCovered').Count
	PublicContractCovered = @($Results | Where-Object CurrentStatus -eq 'PublicContractCovered').Count
	NotApplicable = @($Results | Where-Object CurrentStatus -eq 'NotApplicable').Count
	ApiDeferred = @($Results | Where-Object CurrentStatus -eq 'ApiDeferred').Count
	Output = $OutputPath
}
