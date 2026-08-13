[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$Assertions = 0

function Assert-Equal
{
	param(
		[Parameter(Mandatory = $true)] $Expected,
		[Parameter(Mandatory = $true)] $Actual,
		[Parameter(Mandatory = $true)] [string] $Message
	)

	if ($Expected -ne $Actual)
	{
		throw "ASSERT FAILED: $Message Expected '$Expected', actual '$Actual'."
	}
	$script:Assertions++
}

function New-Use
{
	param(
		[string] $Kind,
		[string] $ReferenceKind,
		[string] $StableKey,
		[bool] $HasCurrentRoute = $true,
		[bool] $OwnsBody = $true
	)

	return [pscustomobject]@{
		Kind = $Kind
		ReferenceKind = $ReferenceKind
		StableKey = $StableKey
		HasCurrentRoute = $HasCurrentRoute
		OwnsBody = $OwnsBody
	}
}

function New-Dependency
{
	param(
		[string] $Kind,
		[string] $ReferenceKind,
		[string] $StableKey
	)

	return [pscustomobject]@{
		Kind = $Kind
		ReferenceKind = $ReferenceKind
		StableKey = $StableKey
	}
}

function Get-CompatibleDependencyKinds
{
	param([string] $UseKind)

	switch ($UseKind)
	{
		'Function' { return @('Signature') }
		'ImportedSlot' { return @('Signature') }
		'TypeDeclaration' { return @('Declaration') }
		'TypeValueLayout' { return @('ValueLayout') }
		'Property' { return @('PropertyLayout') }
		'FoldedGlobalConstant' { return @('HardValue') }
		'GlobalStorage' { return @('GlobalStorage') }
		default { return @() }
	}
}

function Test-SemanticUses
{
	param(
		[object[]] $Uses,
		[object[]] $Dependencies
	)

	$CoveredDependencyIndexes = @{}
	foreach ($Use in @($Uses))
	{
		$CompatibleKinds = @(Get-CompatibleDependencyKinds -UseKind $Use.Kind)
		$Matches = [System.Collections.Generic.List[int]]::new()
		for ($Index = 0; $Index -lt @($Dependencies).Count; ++$Index)
		{
			$Dependency = $Dependencies[$Index]
			if ($Dependency.ReferenceKind -eq $Use.ReferenceKind `
				-and $Dependency.StableKey -eq $Use.StableKey `
				-and $CompatibleKinds -contains $Dependency.Kind)
			{
				$Matches.Add($Index)
			}
		}

		if ($Matches.Count -ne 1)
		{
			return [pscustomobject]@{
				Result = 'SemanticDependencyMismatch'
				ExtraDependencyCount = @($Dependencies).Count
			}
		}
		$CoveredDependencyIndexes[$Matches[0]] = $true
	}

	return [pscustomobject]@{
		Result = 'Covered'
		ExtraDependencyCount = @($Dependencies).Count - $CoveredDependencyIndexes.Count
	}
}

function Get-InitialEligibility
{
	param([object[]] $Uses)

	foreach ($Use in @($Uses))
	{
		switch ($Use.Kind)
		{
			'GlobalStorage' { return 'UnsupportedGlobalStorage' }
			'GlobalInitializer' { return 'UnsupportedGlobalInitializer' }
			'ImportedSlot' {
				if (-not $Use.HasCurrentRoute) { return 'UnsupportedImportedRoute' }
			}
			'SharedExternalBody' {
				if (-not $Use.OwnsBody) { return 'UnsupportedCall' }
			}
		}
	}
	return 'Semantic'
}

$FoldedUses = @(
	(New-Use -Kind FoldedGlobalConstant -ReferenceKind Global -StableKey GlobalMax)
	(New-Use -Kind Function -ReferenceKind Function -StableKey ClampSignature)
)
$FoldedDependencies = @(
	(New-Dependency -Kind HardValue -ReferenceKind Global -StableKey GlobalMax)
	(New-Dependency -Kind Signature -ReferenceKind Function -StableKey ClampSignature)
	(New-Dependency -Kind EnvironmentAbi -ReferenceKind Type -StableKey ToolchainProfile)
)
$FoldedResult = Test-SemanticUses -Uses $FoldedUses -Dependencies $FoldedDependencies
Assert-Equal 'Covered' $FoldedResult.Result `
	'Folded global and function uses should be covered by hard-value/signature dependencies.'
Assert-Equal 1 $FoldedResult.ExtraDependencyCount `
	'Extra authoritative compiler dependencies must remain preserved rather than causing mismatch.'
Assert-Equal 'Semantic' (Get-InitialEligibility -Uses $FoldedUses) `
	'Covered folded primitive global may enter the initial Semantic slice.'

$WrongKindDependencies = @(
	(New-Dependency -Kind GlobalStorage -ReferenceKind Global -StableKey GlobalMax)
	(New-Dependency -Kind Signature -ReferenceKind Function -StableKey ClampSignature)
)
Assert-Equal 'SemanticDependencyMismatch' `
	(Test-SemanticUses -Uses $FoldedUses -Dependencies $WrongKindDependencies).Result `
	'Folded constant must not accept mutable-storage authority.'

$MissingFunctionDependencies = @(
	(New-Dependency -Kind HardValue -ReferenceKind Global -StableKey GlobalMax)
)
Assert-Equal 'SemanticDependencyMismatch' `
	(Test-SemanticUses -Uses $FoldedUses -Dependencies $MissingFunctionDependencies).Result `
	'Missing function signature authority must fail closed.'

$MutableUses = @(
	(New-Use -Kind GlobalStorage -ReferenceKind Global -StableKey MutableCounter)
)
$MutableDependencies = @(
	(New-Dependency -Kind GlobalStorage -ReferenceKind Global -StableKey MutableCounter)
)
Assert-Equal 'Covered' `
	(Test-SemanticUses -Uses $MutableUses -Dependencies $MutableDependencies).Result `
	'Mutable storage can reconcile even though v1 eligibility still rejects it.'
Assert-Equal 'UnsupportedGlobalStorage' (Get-InitialEligibility -Uses $MutableUses) `
	'Initial backend must reject mutable global relocation/lifecycle.'

$InitializerUses = @(
	(New-Use -Kind GlobalInitializer -ReferenceKind Function -StableKey InitCounter)
)
Assert-Equal 'UnsupportedGlobalInitializer' (Get-InitialEligibility -Uses $InitializerUses) `
	'Anonymous global initializer body must not publish as ordinary function.'

$ImportedWithoutRoute = @(
	(New-Use -Kind ImportedSlot -ReferenceKind Function -StableKey ModuleA_DoWork `
		-HasCurrentRoute $false)
)
$ImportedDependency = @(
	(New-Dependency -Kind Signature -ReferenceKind Function -StableKey ModuleA_DoWork)
)
Assert-Equal 'Covered' `
	(Test-SemanticUses -Uses $ImportedWithoutRoute -Dependencies $ImportedDependency).Result `
	'Imported signature dependency and runtime route eligibility are separate checks.'
Assert-Equal 'UnsupportedImportedRoute' `
	(Get-InitialEligibility -Uses $ImportedWithoutRoute) `
	'Imported slot without a current-binding route must not freeze boundFunctionId.'

$ImportedWithRoute = @(
	(New-Use -Kind ImportedSlot -ReferenceKind Function -StableKey ModuleA_DoWork `
		-HasCurrentRoute $true)
)
Assert-Equal 'Semantic' (Get-InitialEligibility -Uses $ImportedWithRoute) `
	'Imported slot may be eligible only after a current-binding route is proven.'

$ExternalBodyWithoutOwner = @(
	(New-Use -Kind SharedExternalBody -ReferenceKind Function -StableKey Shared_DoWork `
		-OwnsBody $false)
)
Assert-Equal 'UnsupportedCall' (Get-InitialEligibility -Uses $ExternalBodyWithoutOwner) `
	'Shared/external declaration visibility must not imply body ownership.'

Write-Output "PASS semantic dependency contract: $Assertions assertions"
