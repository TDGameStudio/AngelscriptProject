[CmdletBinding()]
param(
	[string]$ProjectRoot,
	[string]$OutputPath,
	[string]$MethodOutputPath,
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
if ([string]::IsNullOrWhiteSpace($OutputPath))
{
	$OutputPath = Join-Path (Resolve-Path (Join-Path $PSScriptRoot '..\audits')).Path 'implementation-reconciliation.csv'
}
if ([string]::IsNullOrWhiteSpace($MethodOutputPath))
{
	$MethodOutputPath = Join-Path (Split-Path -Parent $OutputPath) 'method-product-reconciliation.csv'
}

$ChangeRoot = Resolve-Path (Join-Path $PSScriptRoot '..')
$ExpectedRows = @(Import-Csv -LiteralPath (Join-Path $ChangeRoot 'audits\expected-coverage.csv'))
$SdkRoot = Join-Path $ProjectRoot 'Plugins\Angelscript\Source\AngelscriptTest\AngelScriptSDK'
$AllowedEvidence = @('Compile', 'Diagnostic', 'Runtime', 'Metadata', 'Bytecode', 'Lifecycle', 'Debug', 'SaveLoad', 'Recovery', 'Cleanup', 'Isolation')
$Markers = [System.Collections.Generic.List[object]]::new()
$ProductParts = [System.Collections.Generic.List[object]]::new()
$MethodRows = [System.Collections.Generic.List[object]]::new()

foreach ($File in Get-ChildItem -LiteralPath $SdkRoot -Recurse -Filter '*.cpp' -File | Sort-Object FullName)
{
	$Text = Get-Content -LiteralPath $File.FullName -Raw
	$RelativePath = $File.FullName.Substring($SdkRoot.Length).TrimStart([char[]]@('\', '/')).Replace('\', '/')
	$ClassMatches = [regex]::Matches($Text, 'TEST_CLASS_WITH_(?:BASE_AND_)?FLAGS(?:_AND_TAGS)?\s*\(\s*(?<Class>[A-Za-z_][A-Za-z0-9_]*)')
	$MethodMatches = [regex]::Matches($Text, 'TEST_METHOD\s*\(\s*(?<Method>[A-Za-z_][A-Za-z0-9_]*)\s*\)')
	$ProductMatches = [regex]::Matches(
		$Text,
		'AS_NATIVE_PRODUCT\s*\(\s*"(?<Product>[A-Z0-9-]+)"\s*,\s*(?<Evidence>.*?)\)\s*;',
		[System.Text.RegularExpressions.RegexOptions]::Singleline)
	$NonProductMatches = [regex]::Matches(
		$Text,
		'AS_NATIVE_NON_PRODUCT\s*\(\s*"(?<Disposition>[A-Za-z]+)"\s*,\s*"(?<Rationale>[^"]+)"\s*\)\s*;',
		[System.Text.RegularExpressions.RegexOptions]::Singleline)
	$ProductPartMatches = [regex]::Matches(
		$Text,
		'AS_NATIVE_PRODUCT_PART\s*\(\s*"(?<Product>[A-Z0-9-]+)"\s*,\s*"(?<Scenario>[^"]+)"\s*\)\s*;',
		[System.Text.RegularExpressions.RegexOptions]::Singleline)

	foreach ($ProductMatch in $ProductMatches)
	{
		$ClassMatch = @($ClassMatches | Where-Object Index -lt $ProductMatch.Index | Select-Object -Last 1)
		$MethodMatch = @($MethodMatches | Where-Object Index -lt $ProductMatch.Index | Select-Object -Last 1)
		$EvidenceTokens = @([regex]::Matches($ProductMatch.Groups['Evidence'].Value, 'ENativeEvidence::(?<Layer>[A-Za-z]+)') | ForEach-Object { $_.Groups['Layer'].Value } | Sort-Object -Unique)
		foreach ($Token in $EvidenceTokens)
		{
			if ($Token -notin $AllowedEvidence)
			{
				throw "Unknown evidence token '$Token' in ${RelativePath}."
			}
		}

		$Markers.Add([pscustomobject]@{
			ProductId = $ProductMatch.Groups['Product'].Value
			File = $RelativePath
			Class = $(if ($ClassMatch.Count -gt 0) { $ClassMatch[0].Groups['Class'].Value } else { '' })
			Method = $(if ($MethodMatch.Count -gt 0) { $MethodMatch[0].Groups['Method'].Value } else { '' })
			EvidenceLayers = ($EvidenceTokens -join ';')
			Line = ($Text.Substring(0, $ProductMatch.Index) -split "`n").Count
		})
	}

	foreach ($ProductPartMatch in $ProductPartMatches)
	{
		$ClassMatch = @($ClassMatches | Where-Object Index -lt $ProductPartMatch.Index | Select-Object -Last 1)
		$MethodMatch = @($MethodMatches | Where-Object Index -lt $ProductPartMatch.Index | Select-Object -Last 1)
		$ProductParts.Add([pscustomobject]@{
			ProductId = $ProductPartMatch.Groups['Product'].Value
			Scenario = $ProductPartMatch.Groups['Scenario'].Value
			File = $RelativePath
			Class = $(if ($ClassMatch.Count -gt 0) { $ClassMatch[0].Groups['Class'].Value } else { '' })
			Method = $(if ($MethodMatch.Count -gt 0) { $MethodMatch[0].Groups['Method'].Value } else { '' })
			Line = ($Text.Substring(0, $ProductPartMatch.Index) -split "`n").Count
		})
	}

	for ($MethodIndex = 0; $MethodIndex -lt $MethodMatches.Count; ++$MethodIndex)
	{
		$MethodMatch = $MethodMatches[$MethodIndex]
		$RegionEnd = $(if ($MethodIndex + 1 -lt $MethodMatches.Count) { $MethodMatches[$MethodIndex + 1].Index } else { $Text.Length })
		$ClassMatch = @($ClassMatches | Where-Object Index -lt $MethodMatch.Index | Select-Object -Last 1)
		$OwnedProducts = @(
			$ProductMatches |
				Where-Object { $_.Index -gt $MethodMatch.Index -and $_.Index -lt $RegionEnd } |
				ForEach-Object { $_.Groups['Product'].Value }
		)
		$Dispositions = @(
			$NonProductMatches |
				Where-Object { $_.Index -gt $MethodMatch.Index -and $_.Index -lt $RegionEnd }
		)
		$Parts = @(
			$ProductPartMatches |
				Where-Object { $_.Index -gt $MethodMatch.Index -and $_.Index -lt $RegionEnd }
		)
		$State = 'Unowned'
		$Disposition = ''
		$Rationale = ''
		if ($OwnedProducts.Count -gt 0)
		{
			$State = $(if ($Parts.Count -gt 0 -or $Dispositions.Count -gt 0) { 'ConflictingDisposition' } else { 'ProductOwned' })
		}
		elseif ($Parts.Count -eq 1 -and $Dispositions.Count -eq 0)
		{
			$State = 'ProductPart'
			$Disposition = 'ProductPart'
			$Rationale = $Parts[0].Groups['Scenario'].Value
		}
		elseif ($Dispositions.Count -eq 1)
		{
			$Disposition = $Dispositions[0].Groups['Disposition'].Value
			$Rationale = $Dispositions[0].Groups['Rationale'].Value
			if ($Disposition -notin @('AggregateSupport', 'NegativeAbsence', 'LegacyCompatibility', 'Infrastructure'))
			{
				throw "Unknown non-product disposition '$Disposition' in ${RelativePath}."
			}
			$State = 'ExplicitNonProduct'
		}
		elseif ($Dispositions.Count -gt 1)
		{
			$State = 'DuplicateNonProductDisposition'
		}

		$MethodRows.Add([pscustomobject]@{
			File = $RelativePath
			Class = $(if ($ClassMatch.Count -gt 0) { $ClassMatch[0].Groups['Class'].Value } else { '' })
			Method = $MethodMatch.Groups['Method'].Value
			Line = ($Text.Substring(0, $MethodMatch.Index) -split "`n").Count
			ProductIds = $(
				if ($OwnedProducts.Count -gt 0)
				{
					$OwnedProducts -join ';'
				}
				elseif ($Parts.Count -eq 1)
				{
					$Parts[0].Groups['Product'].Value
				}
				else
				{
					''
				})
			Disposition = $Disposition
			Rationale = $Rationale
			State = $State
		})
	}
}

$ExpectedProducts = @($ExpectedRows | Group-Object ProductId)
$ExpectedProductIds = @($ExpectedProducts.Name)
foreach ($Marker in $Markers)
{
	if ($Marker.ProductId -notin $ExpectedProductIds)
	{
		throw "Unknown implemented product '$($Marker.ProductId)' at $($Marker.File):$($Marker.Line)."
	}
}

$UnknownProductParts = @($ProductParts | Where-Object ProductId -notin $ExpectedProductIds)
if ($UnknownProductParts.Count -gt 0)
{
	throw "Unknown product part '$($UnknownProductParts[0].ProductId)' at $($UnknownProductParts[0].File):$($UnknownProductParts[0].Line)."
}

$DuplicateProductParts = @($ProductParts | Group-Object ProductId, Scenario | Where-Object Count -gt 1)
if ($DuplicateProductParts.Count -gt 0)
{
	throw "Product part scenarios must be unique; duplicates: $($DuplicateProductParts.Name -join ', ')"
}

$OwnerlessProductParts = @(
	$ProductParts |
		Where-Object ProductId -notin @($Markers.ProductId)
)
if ($OwnerlessProductParts.Count -gt 0)
{
	throw "Product part '$($OwnerlessProductParts[0].ProductId)' has no exact AS_NATIVE_PRODUCT owner."
}

$DuplicateMarkers = @($Markers | Group-Object ProductId | Where-Object Count -gt 1)
if ($DuplicateMarkers.Count -gt 0)
{
	throw "Products must have exactly one owning marker; duplicates: $($DuplicateMarkers.Name -join ', ')"
}

$Rows = [System.Collections.Generic.List[object]]::new()
foreach ($ExpectedProduct in $ExpectedProducts)
{
	$Representative = $ExpectedProduct.Group[0]
	$OwnerParts = @($Representative.PlannedOwner -split '\|')
	$ExpectedEvidence = @($Representative.EvidenceLayers -split ';')
	$Marker = @($Markers | Where-Object ProductId -eq $ExpectedProduct.Name)
	$State = 'Missing'
	$Issue = ''

	if ($Representative.Classification -eq 'ApiDeferred')
	{
		$State = 'Deferred'
	}
	elseif ($Marker.Count -eq 1)
	{
		$Actual = $Marker[0]
		if ($Actual.File -ne $OwnerParts[0] -or $Actual.Class -ne $OwnerParts[1] -or $Actual.Method -ne $OwnerParts[2])
		{
			$State = 'OwnerMismatch'
			$Issue = "Expected $($Representative.PlannedOwner); actual $($Actual.File)|$($Actual.Class)|$($Actual.Method)"
		}
		else
		{
			$MissingEvidence = @($ExpectedEvidence | Where-Object { $_ -notin @($Actual.EvidenceLayers -split ';') })
			if ($MissingEvidence.Count -gt 0)
			{
				$State = 'EvidenceIncomplete'
				$Issue = "Missing evidence: $($MissingEvidence -join ';')"
			}
			else
			{
				$State = $(if ($Representative.Classification -eq 'Future238Disabled') { 'DisabledImplemented' } else { 'Implemented' })
			}
		}
	}

	$Rows.Add([pscustomobject]@{
		ProductId = $ExpectedProduct.Name
		Theme = $Representative.Theme
		Classification = $Representative.Classification
		ExpectedCases = $ExpectedProduct.Count
		PlannedOwner = $Representative.PlannedOwner
		ExpectedEvidence = $Representative.EvidenceLayers
		ActualOwner = $(if ($Marker.Count -eq 1) { "$($Marker[0].File)|$($Marker[0].Class)|$($Marker[0].Method)" } else { '' })
		ActualEvidence = $(if ($Marker.Count -eq 1) { $Marker[0].EvidenceLayers } else { '' })
		State = $State
		Issue = $Issue
	})
}

$Rows | Export-Csv -LiteralPath $OutputPath -NoTypeInformation -Encoding utf8
$MethodRows | Export-Csv -LiteralPath $MethodOutputPath -NoTypeInformation -Encoding utf8
$ProductFailures = @($Rows | Where-Object State -in @('Missing', 'OwnerMismatch', 'EvidenceIncomplete'))
$MethodFailures = @($MethodRows | Where-Object State -notin @('ProductOwned', 'ProductPart', 'ExplicitNonProduct'))
if ($RequireComplete -and ($ProductFailures.Count -gt 0 -or $MethodFailures.Count -gt 0))
{
	if ($ProductFailures.Count -gt 0)
	{
		throw "Native SDK source reconciliation has $($ProductFailures.Count) incomplete products. First: $($ProductFailures[0].ProductId) $($ProductFailures[0].State) $($ProductFailures[0].Issue)"
	}
	throw "Native SDK method ownership has $($MethodFailures.Count) unresolved methods. First: $($MethodFailures[0].File):$($MethodFailures[0].Line) $($MethodFailures[0].Class).$($MethodFailures[0].Method)"
}

[pscustomobject]@{
	Products = $Rows.Count
	Implemented = @($Rows | Where-Object State -eq 'Implemented').Count
	DisabledImplemented = @($Rows | Where-Object State -eq 'DisabledImplemented').Count
	IncompleteProducts = $ProductFailures.Count
	Methods = $MethodRows.Count
	ProductOwnedMethods = @($MethodRows | Where-Object State -eq 'ProductOwned').Count
	ProductPartMethods = @($MethodRows | Where-Object State -eq 'ProductPart').Count
	ExplicitNonProductMethods = @($MethodRows | Where-Object State -eq 'ExplicitNonProduct').Count
	UnresolvedMethods = $MethodFailures.Count
	Output = $OutputPath
	MethodOutput = $MethodOutputPath
}
