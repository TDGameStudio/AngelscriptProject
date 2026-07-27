[CmdletBinding()]
param(
	[string]$ChangeRoot
)

$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrWhiteSpace($ChangeRoot))
{
	$ChangeRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
}

$CatalogPath = Join-Path $ChangeRoot 'catalogs\coverage-products.psd1'
$AuditRoot = Join-Path $ChangeRoot 'audits'
. (Join-Path $PSScriptRoot 'ImportCoverageCatalog.ps1')
$Catalog = Import-CoverageCatalog -CatalogPath $CatalogPath

function ConvertTo-CaseToken
{
	param([string]$Value)

	$Token = $Value.ToUpperInvariant() -replace '[^A-Z0-9]+', '-'
	return $Token.Trim('-')
}

function Resolve-AxisValues
{
	param($AxisValue, [hashtable]$AxisSets, [string]$ProductId, [string]$AxisName)

	if ($AxisValue -is [string])
	{
		if (-not $AxisSets.ContainsKey($AxisValue))
		{
			throw "Product $ProductId axis $AxisName references unknown axis set '$AxisValue'."
		}
		return @($AxisSets[$AxisValue])
	}

	return @($AxisValue)
}

function Expand-Axes
{
	param(
		[object[]]$Axes,
		[int]$Index,
		[hashtable]$Current,
		[System.Collections.Generic.List[object]]$Output
	)

	if ($Index -ge $Axes.Count)
	{
		$Output.Add(@{} + $Current)
		return
	}

	$Axis = $Axes[$Index]
	foreach ($Value in $Axis.Values)
	{
		$Current[$Axis.Name] = [string]$Value
		Expand-Axes -Axes $Axes -Index ($Index + 1) -Current $Current -Output $Output
	}
	$Current.Remove($Axis.Name)
}

$Rows = [System.Collections.Generic.List[object]]::new()
$Cardinalities = [System.Collections.Generic.List[object]]::new()

foreach ($Product in $Catalog.Products)
{
	$Axes = [System.Collections.Generic.List[object]]::new()
	foreach ($AxisName in @($Product.Axes.Keys | Sort-Object))
	{
		$Values = @(Resolve-AxisValues -AxisValue $Product.Axes[$AxisName] -AxisSets $Catalog.AxisSets -ProductId $Product.Id -AxisName $AxisName)
		if ($Values.Count -eq 0)
		{
			throw "Product $($Product.Id) axis $AxisName has no values."
		}
		$Axes.Add([pscustomobject]@{ Name = $AxisName; Values = $Values })
	}

	$Cells = [System.Collections.Generic.List[object]]::new()
	Expand-Axes -Axes $Axes.ToArray() -Index 0 -Current @{} -Output $Cells
	$ExpectedCount = 1
	foreach ($Axis in $Axes)
	{
		$ExpectedCount *= $Axis.Values.Count
	}

	$Cardinalities.Add([pscustomobject]@{
		ProductId = $Product.Id
		SourceCatalog = $Product.SourceCatalog
		Theme = $Product.Theme
		AxisCount = $Axes.Count
		Axes = (($Axes | ForEach-Object { "$($_.Name)=$($_.Values.Count)" }) -join ';')
		ExpectedCells = $ExpectedCount
		ExpandedCells = $Cells.Count
		Classification = $Product.Classification
		Owner = $Product.Owner
	})

	foreach ($Cell in $Cells)
	{
		$DimensionPairs = @($Axes | ForEach-Object { "$($_.Name)=$($Cell[$_.Name])" })
		$CaseSuffix = @($Axes | ForEach-Object { ConvertTo-CaseToken $Cell[$_.Name] }) -join '-'
		$Rows.Add([pscustomobject]@{
			Id = "$($Product.Id)-$CaseSuffix"
			ProductId = $Product.Id
			SourceCatalog = $Product.SourceCatalog
			Theme = $Product.Theme
			Element = $Product.Element
			Dimensions = ($DimensionPairs -join ';')
			Classification = $Product.Classification
			ExpectedResult = $Product.Expected
			EvidenceLayers = (@($Product.Evidence) -join ';')
			PlannedOwner = $Product.Owner
			ImplementationState = $(if ($Product.Classification -eq 'Future238Disabled') { 'Disabled' } elseif ($Product.Classification -eq 'ApiDeferred') { 'Deferred' } else { 'Pending' })
			Rationale = $(if ($Product.Classification -eq 'Future238Disabled') { 'Selected 2.38 desired behavior remains compiled and Disabled until its enable condition is met.' } elseif ($Product.Classification -eq 'ApiDeferred') { 'The required public API is absent from the current fork.' } else { '' })
		})
	}
}

$ExpectedPath = Join-Path $AuditRoot 'expected-coverage.csv'
$CardinalityPath = Join-Path $AuditRoot 'product-cardinalities.csv'
$Rows | Export-Csv -LiteralPath $ExpectedPath -NoTypeInformation -Encoding utf8
$Cardinalities | Export-Csv -LiteralPath $CardinalityPath -NoTypeInformation -Encoding utf8

[pscustomobject]@{
	Products = $Cardinalities.Count
	ExpectedCases = $Rows.Count
	CurrentForkCases = @($Rows | Where-Object Classification -eq 'CurrentFork').Count
	FutureDisabledCases = @($Rows | Where-Object Classification -eq 'Future238Disabled').Count
	Output = $ExpectedPath
}
