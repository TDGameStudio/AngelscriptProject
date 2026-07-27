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
$ExpectedPath = Join-Path $ChangeRoot 'audits\expected-coverage.csv'
$CardinalityPath = Join-Path $ChangeRoot 'audits\product-cardinalities.csv'
$GeneratedSourceRegistryPath = Join-Path $ChangeRoot 'catalogs\generated-source-registry.csv'
$CoverageRoot = Join-Path $ChangeRoot 'coverage'
. (Join-Path $PSScriptRoot 'ImportCoverageCatalog.ps1')
$Catalog = Import-CoverageCatalog -CatalogPath $CatalogPath
$ProjectRoot = Resolve-Path (Join-Path $ChangeRoot '..\..\..')
$TypeCaseHeader = Join-Path $ProjectRoot 'Plugins\Angelscript\Source\AngelscriptTest\AngelScriptSDK\Support\AngelscriptNativeCaseTestSupport.h'
$NativeSdkRoot = Join-Path $ProjectRoot 'Plugins\Angelscript\Source\AngelscriptTest\AngelScriptSDK'

if ($Catalog.SchemaVersion -ne 1)
{
	throw "Unsupported catalog schema version: $($Catalog.SchemaVersion)"
}

$AllowedClassifications = @('CurrentFork', 'Compatible238', 'RejectByFork', 'Future238Disabled', 'ApiDeferred')
$AllowedEvidence = @('Compile', 'Diagnostic', 'Runtime', 'Metadata', 'Bytecode', 'Lifecycle', 'Debug', 'SaveLoad', 'Recovery', 'Cleanup', 'Isolation')
$RequiredLanguageThemes = @('Declarations', 'Functions', 'Variables', 'Properties', 'Constructors', 'Destructors', 'Inheritance', 'References', 'Conversions', 'Operators', 'Expressions', 'ControlFlow', 'Exceptions', 'Foreach')
$ProductIds = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
$ProductsById = [System.Collections.Generic.Dictionary[string, object]]::new([System.StringComparer]::Ordinal)

foreach ($Product in $Catalog.Products)
{
	foreach ($Field in @('Id', 'SourceCatalog', 'Theme', 'Element', 'Axes', 'Classification', 'Evidence', 'Expected', 'Owner'))
	{
		if (-not $Product.ContainsKey($Field) -or $null -eq $Product[$Field] -or [string]::IsNullOrWhiteSpace([string]$Product[$Field]))
		{
			throw "Product '$($Product.Id)' is missing required field '$Field'."
		}
	}

	if (-not $ProductIds.Add([string]$Product.Id))
	{
		throw "Duplicate product ID: $($Product.Id)"
	}
	$ProductsById.Add([string]$Product.Id, $Product)
	if ($Product.Id -cnotmatch '^[A-Z0-9]+(?:-[A-Z0-9]+)*$')
	{
		throw "Product ID is not a stable uppercase token: $($Product.Id)"
	}
	if ($Product.Classification -notin $AllowedClassifications)
	{
		throw "Product $($Product.Id) has invalid classification '$($Product.Classification)'."
	}
	foreach ($Layer in @($Product.Evidence))
	{
		if ($Layer -notin $AllowedEvidence)
		{
			throw "Product $($Product.Id) has invalid evidence layer '$Layer'."
		}
	}
	if (@($Product.Owner -split '\|').Count -ne 3 -or $Product.Owner -notmatch '\.cpp\|[A-Za-z_][A-Za-z0-9_]*\|[A-Za-z_][A-Za-z0-9_]*$')
	{
		throw "Product $($Product.Id) owner must be file|class|method: $($Product.Owner)"
	}
	if (-not (Test-Path -LiteralPath (Join-Path $CoverageRoot $Product.SourceCatalog)))
	{
		throw "Product $($Product.Id) references missing coverage source '$($Product.SourceCatalog)'."
	}
	$AxisNames = @($Product.Axes.Keys)
	if ($AxisNames.Count -eq 0)
	{
		throw "Product $($Product.Id) has no axes."
	}
	foreach ($AxisName in $AxisNames)
	{
		$AxisValue = $Product.Axes[$AxisName]
		$Values = if ($AxisValue -is [string]) { @($Catalog.AxisSets[$AxisValue]) } else { @($AxisValue) }
		if (@($Values).Count -eq 0)
		{
			throw "Product $($Product.Id) axis $AxisName has no values or references an unknown set."
		}
		if (@($Values | Sort-Object -Unique).Count -ne @($Values).Count)
		{
			throw "Product $($Product.Id) axis $AxisName contains duplicate values."
		}
	}
}

foreach ($Theme in $RequiredLanguageThemes)
{
	if (@($Catalog.Products | Where-Object Theme -eq $Theme).Count -eq 0)
	{
		throw "Required language theme has no products: $Theme"
	}
}

$GeneratedSourceRows = @(Import-Csv -LiteralPath $GeneratedSourceRegistryPath)
$GeneratedSourceFiles = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
$GeneratedSourceOwners = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
$GeneratedSourceTextByPath = [System.Collections.Generic.Dictionary[string, string]]::new([System.StringComparer]::OrdinalIgnoreCase)
foreach ($Row in $GeneratedSourceRows)
{
	foreach ($Field in @('File', 'Class', 'Method', 'ProductId', 'Generator', 'PrintSites', 'FormattingContract', 'Reason'))
	{
		if ($Row.PSObject.Properties.Name -notcontains $Field -or [string]::IsNullOrWhiteSpace([string]$Row.$Field))
		{
			throw "Generated-source registry row '$($Row.ProductId)' is missing '$Field'."
		}
	}

	$GeneratedSourceFiles.Add([string]$Row.File) | Out-Null
	$OwnerKey = "$($Row.File)|$($Row.Class)|$($Row.Method)|$($Row.ProductId)"
	if (-not $GeneratedSourceOwners.Add($OwnerKey))
	{
		throw "Generated-source registry contains duplicate owner '$OwnerKey'."
	}
	$Product = $null
	if (-not $ProductsById.TryGetValue([string]$Row.ProductId, [ref]$Product))
	{
		throw "Generated-source registry product '$($Row.ProductId)' does not identify exactly one catalog product."
	}
	$ExpectedOwner = "$($Row.File)|$($Row.Class)|$($Row.Method)"
	if ($Product.Owner -cne $ExpectedOwner)
	{
		throw "Generated-source registry owner mismatch for $($Row.ProductId). Expected='$($Product.Owner)' Actual='$ExpectedOwner'."
	}

	$SourcePath = Join-Path $NativeSdkRoot $Row.File
	if (-not (Test-Path -LiteralPath $SourcePath))
	{
		throw "Generated-source owner is missing: $($Row.File)"
	}
	$SourceText = $null
	if (-not $GeneratedSourceTextByPath.TryGetValue($SourcePath, [ref]$SourceText))
	{
		$SourceText = Get-Content -LiteralPath $SourcePath -Raw
		$GeneratedSourceTextByPath.Add($SourcePath, $SourceText)
	}
	foreach ($RequiredText in @($Row.Class, $Row.Method, $Row.ProductId, 'PrintGeneratedAsSource'))
	{
		if ($SourceText.IndexOf($RequiredText, [System.StringComparison]::Ordinal) -lt 0)
		{
			throw "Generated-source owner '$($Row.File)' does not contain required text '$RequiredText'."
		}
	}
	foreach ($GeneratorName in @($Row.Generator -split ';' | ForEach-Object { $_.Trim() } | Where-Object { $_ }))
	{
		if ($SourceText.IndexOf($GeneratorName, [System.StringComparison]::Ordinal) -lt 0)
		{
			throw "Generated-source owner '$($Row.File)' does not contain registered builder '$GeneratorName'."
		}
	}

	$PrintSiteCount = [regex]::Matches($SourceText, '\bPrintGeneratedAsSource\s*\(').Count
	$RequiredPrintSiteCount = 0
	if (-not [int]::TryParse([string]$Row.PrintSites, [ref]$RequiredPrintSiteCount) -or $RequiredPrintSiteCount -le 0)
	{
		throw "Generated-source owner '$($Row.File)' has invalid PrintSites '$($Row.PrintSites)'."
	}
	if ($PrintSiteCount -ne $RequiredPrintSiteCount)
	{
		throw "Generated-source owner '$($Row.File)' declares $RequiredPrintSiteCount source-reporting sites but contains $PrintSiteCount."
	}
}

$NativeSdkRootPath = (Resolve-Path $NativeSdkRoot).Path.TrimEnd('\')
$GeneratedCandidates = @(Get-ChildItem -LiteralPath $NativeSdkRoot -Recurse -Filter '*.cpp' -File | Where-Object {
	$Text = Get-Content -LiteralPath $_.FullName -Raw
	$Text -match '\bAppendGeneratedAsLine\s*\(' -or $Text -match '\bAppendGeneratedLine\s*\('
})
foreach ($Candidate in $GeneratedCandidates)
{
	$RelativePath = $Candidate.FullName.Substring($NativeSdkRootPath.Length).TrimStart('\').Replace('\', '/')
	if (-not $GeneratedSourceFiles.Contains($RelativePath))
	{
		throw "Generated AngelScript owner is not registered: $RelativePath"
	}
}

$TypeCaseText = Get-Content -LiteralPath $TypeCaseHeader -Raw
$ImplementedTypeNames = @([regex]::Matches($TypeCaseText, 'AS_NATIVE_TYPE_CASE\("(?<Name>[a-z0-9_]+)"') | ForEach-Object { $_.Groups['Name'].Value })
$ExpectedTypeNames = @($Catalog.AxisSets.CoreValueTypes) + @($Catalog.AxisSets.CoreReferenceTypes) + @('null')
if (@($ImplementedTypeNames | Sort-Object -Unique).Count -ne @($ImplementedTypeNames).Count)
{
	throw 'Native core type case definitions contain duplicate catalog names.'
}
$MissingTypeNames = @($ExpectedTypeNames | Where-Object { $_ -notin $ImplementedTypeNames })
$UnknownTypeNames = @($ImplementedTypeNames | Where-Object { $_ -notin $ExpectedTypeNames })
if (@($MissingTypeNames).Count -gt 0 -or @($UnknownTypeNames).Count -gt 0)
{
	throw "Native core type cases do not match catalog names. Missing={$($MissingTypeNames -join ',')} Unknown={$($UnknownTypeNames -join ',')}"
}

& (Join-Path $ChangeRoot 'scripts\ExpandCoverageProducts.ps1') -ChangeRoot $ChangeRoot | Out-Host
$Rows = @(Import-Csv -LiteralPath $ExpectedPath)
$Cardinalities = @(Import-Csv -LiteralPath $CardinalityPath)
$RowsByProduct = $Rows | Group-Object ProductId -AsHashTable -AsString

if (@($Rows.Id | Sort-Object -Unique).Count -ne @($Rows).Count)
{
	$Duplicates = $Rows | Group-Object Id | Where-Object Count -gt 1 | Select-Object -ExpandProperty Name
	throw "Expanded case IDs are not unique: $($Duplicates -join ', ')"
}

foreach ($Cardinality in $Cardinalities)
{
	if ([int]$Cardinality.ExpectedCells -ne [int]$Cardinality.ExpandedCells)
	{
		throw "Product $($Cardinality.ProductId) expanded $($Cardinality.ExpandedCells) cells, expected $($Cardinality.ExpectedCells)."
	}
	$ProductRows = $RowsByProduct[[string]$Cardinality.ProductId]
	$Actual = if ($null -eq $ProductRows)
	{
		0
	}
	else
	{
		@($ProductRows).Count
	}
	if ($Actual -ne [int]$Cardinality.ExpectedCells)
	{
		throw "Product $($Cardinality.ProductId) output contains $Actual rows, expected $($Cardinality.ExpectedCells)."
	}
}

$ForbiddenTerm = 'mat' + 'rix'
$Forbidden = @(Get-ChildItem -LiteralPath $ChangeRoot -Recurse -File | Select-String -Pattern $ForbiddenTerm -CaseSensitive:$false)
if (@($Forbidden).Count -gt 0)
{
	throw "Forbidden generic coverage term found in new change files: $($Forbidden[0].Path):$($Forbidden[0].LineNumber)"
}

[pscustomobject]@{
	Products = @($Catalog.Products).Count
	Cases = @($Rows).Count
	LanguageThemes = $RequiredLanguageThemes.Count
	UniqueIds = @($Rows).Count
	Result = 'PASS'
}
