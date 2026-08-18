[CmdletBinding()]
param(
	[Parameter(Mandatory = $true)]
	[string] $InstalledCsv,

	[Parameter(Mandatory = $true)]
	[string] $SourceCallsitesCsv,

	[Parameter(Mandatory = $true)]
	[string] $SourceProvidersCsv,

	[Parameter(Mandatory = $true)]
	[string] $OutputCsv,

	[Parameter(Mandatory = $true)]
	[string] $SummaryJson
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repositoryRoot = [System.IO.Path]::GetFullPath(
	(Join-Path $PSScriptRoot '..\..\..\..')).TrimEnd('\')
$savedInventoryRoot = [System.IO.Path]::GetFullPath(
	(Join-Path $repositoryRoot 'Saved\TypedSemanticAOT\NativeCallInventory')).TrimEnd('\')
$outputFullPath = [System.IO.Path]::GetFullPath($OutputCsv)
$repositoryPrefix = $repositoryRoot + '\'
$savedInventoryPrefix = $savedInventoryRoot + '\'
$isInsideRepository = $outputFullPath.StartsWith(
	$repositoryPrefix, [System.StringComparison]::OrdinalIgnoreCase)
$isInsideIgnoredSavedInventory = $outputFullPath.StartsWith(
	$savedInventoryPrefix, [System.StringComparison]::OrdinalIgnoreCase)
if ($isInsideRepository -and -not $isInsideIgnoredSavedInventory)
{
	throw "The complete native-call inventory is a local analysis dump and must not be written into tracked repository paths. Choose Saved/TypedSemanticAOT/NativeCallInventory/<run>/... or a path outside the repository: $outputFullPath"
}

function Add-ToLookup
{
	param(
		[Parameter(Mandatory = $true)][hashtable] $Lookup,
		[AllowEmptyString()][string] $Key,
		[Parameter(Mandatory = $true)][object] $Value)

	if (-not $Lookup.ContainsKey($Key))
	{
		$Lookup[$Key] = [System.Collections.Generic.List[object]]::new()
	}
	$Lookup[$Key].Add($Value)
}

function Get-FunctionName
{
	param([AllowEmptyString()][string] $Declaration)

	$open = $Declaration.IndexOf('(')
	if ($open -lt 0)
	{
		return ''
	}
	$prefix = $Declaration.Substring(0, $open)
	$matches = [regex]::Matches($prefix, '[A-Za-z_][A-Za-z0-9_]*')
	return $matches.Count -gt 0 ? $matches[$matches.Count - 1].Value : ''
}

function Get-DiagnosticCode
{
	param(
		[AllowEmptyString()][string] $Diagnostic,
		[Parameter(Mandatory = $true)][string] $SuccessCode)

	if ([string]::IsNullOrWhiteSpace($Diagnostic))
	{
		return $SuccessCode
	}
	$separator = $Diagnostic.IndexOf(':')
	return $separator -gt 0 ? $Diagnostic.Substring(0, $separator) : $Diagnostic
}

function Get-InstalledDispatchKind
{
	param([Parameter(Mandatory = $true)][object] $Installed)

	$kind = [int] $Installed.DispatchKind
	$callConv = [int] $Installed.RegisteredCallConv
	$hasCaller = [string] $Installed.HasSystemCaller -eq 'true'
	switch ($kind)
	{
		1
		{
			if (-not $hasCaller)
			{
				throw "FunctionCaller dispatch has no installed caller: $($Installed.CanonicalDeclaration)"
			}
			return 'FunctionCaller'
		}
		2
		{
			if ($hasCaller -or $callConv -ne 0)
			{
				throw "GenericFunction dispatch contradicts the installed interface: $($Installed.CanonicalDeclaration)"
			}
			return 'GenericFunction'
		}
		3
		{
			if ($hasCaller -or $callConv -ne 14)
			{
				throw "GenericMethod dispatch contradicts the installed interface: $($Installed.CanonicalDeclaration)"
			}
			return 'GenericMethod'
		}
		4
		{
			if ($hasCaller -or $callConv -in @(0, 14))
			{
				throw "NativeCallingConvention dispatch contradicts the installed interface: $($Installed.CanonicalDeclaration)"
			}
			return 'NativeCallingConvention'
		}
		default
		{
			throw "Installed function has no authoritative VM dispatch kind: $($Installed.CanonicalDeclaration)"
		}
	}
}

function Test-PathSuffixMatch
{
	param(
		[AllowEmptyString()][string] $InstalledPath,
		[AllowEmptyString()][string] $SourcePath)

	if ([string]::IsNullOrWhiteSpace($InstalledPath) -or
		[string]::IsNullOrWhiteSpace($SourcePath))
	{
		return $false
	}
	$left = $InstalledPath.Replace('\', '/')
	$right = $SourcePath.Replace('\', '/')
	return $left.EndsWith($right, [System.StringComparison]::OrdinalIgnoreCase)
}

function Get-UniqueJoinedValue
{
	param(
		[AllowEmptyCollection()][object[]] $Rows,
		[Parameter(Mandatory = $true)][string] $Property)

	return @($Rows |
		ForEach-Object { [string] $_.$Property } |
		Where-Object { -not [string]::IsNullOrWhiteSpace($_) } |
		Sort-Object -Unique) -join ';'
}

function Select-SourceCallsite
{
	param(
		[Parameter(Mandatory = $true)][object] $Installed,
		[AllowEmptyCollection()][object[]] $Candidates)

	if ($Candidates.Count -eq 0)
	{
		return [pscustomobject]@{
			Row = $null
			Status = 'provider-authority-only'
			Reason = 'No source callsite carried this installed Provider; the Engine-owned provider declaration remains authoritative.'
			CandidateCount = 0
		}
	}

	$providerLineCandidates = @($Candidates | Where-Object {
		[int] $_.ProviderSourceLine -eq [int] $Installed.ProviderSourceLine
	})
	if ($providerLineCandidates.Count -gt 0)
	{
		$Candidates = $providerLineCandidates
	}

	$matches = @()
	if ([string] $Installed.HasExternalDescriptor -eq 'true' -and
		-not [string]::IsNullOrWhiteSpace([string] $Installed.DescriptorSymbol))
	{
		$matches = @($Candidates | Where-Object {
			([string] $_.ExternalDescriptorSymbols).Contains([string] $Installed.DescriptorSymbol) -or
			([string] $_.CppTargetExpression).Contains([string] $Installed.DescriptorSymbol)
		})
	}
	if ($matches.Count -eq 0 -and
		-not [string]::IsNullOrWhiteSpace([string] $Installed.NativeCallableDisplay))
	{
		$matches = @($Candidates | Where-Object {
			([string] $_.EffectiveNativeCallableDisplays).Split(';') -contains
				[string] $Installed.NativeCallableDisplay -or
			([string] $_.CppTargetExpression).Contains(
				[string] $Installed.NativeCallableDisplay)
		})
	}
	if ($matches.Count -eq 0)
	{
		$matches = @($Candidates | Where-Object {
			-not [string]::IsNullOrWhiteSpace([string] $_.LiteralDeclaration) -and
			[string] $_.LiteralDeclaration -eq [string] $Installed.CanonicalDeclaration
		})
	}
	if ($matches.Count -eq 0)
	{
		$functionName = Get-FunctionName -Declaration ([string] $Installed.CanonicalDeclaration)
		if (-not [string]::IsNullOrWhiteSpace($functionName))
		{
			$matches = @($Candidates | Where-Object {
				(Get-FunctionName -Declaration ([string] $_.LiteralDeclaration)) -eq $functionName
			})
		}
	}
	if ($matches.Count -eq 1)
	{
		return [pscustomobject]@{
			Row = $matches[0]
			Status = 'exact-source-callsite'
			Reason = 'Provider identity plus installed declaration/native target facts selected one source registration expression.'
			CandidateCount = $Candidates.Count
		}
	}
	if ($Candidates.Count -eq 1)
	{
		return [pscustomobject]@{
			Row = $Candidates[0]
			Status = 'single-provider-callsite'
			Reason = 'The installed Provider has exactly one source registration expression for this provider declaration.'
			CandidateCount = 1
		}
	}

	$reason = if ([string] $Installed.Origin -eq '4')
	{
		'Reflective provider expansion intentionally maps many installed functions to a small dynamic source registration surface.'
	}
	else
	{
		'Dynamic loop, template, overload, or helper expansion leaves multiple source expressions; installed provider provenance is authoritative without guessing a callsite.'
	}
	return [pscustomobject]@{
		Row = $null
		Status = ([string] $Installed.Origin -eq '4') ?
			'reflective-provider-expansion' : 'provider-dynamic-expansion'
		Reason = $reason
		CandidateCount = $Candidates.Count
	}
}

function Get-NonRewrittenDisposition
{
	param([Parameter(Mandatory = $true)][object] $Installed)

	if ([string] $Installed.HasExternalDescriptor -eq 'true')
	{
		if ([string] $Installed.HasExpectedNativeABI -ne 'true')
		{
			return @('unsupported', 'descriptor-native-abi-unavailable')
		}
		switch ([int] $Installed.DescriptorLinkage)
		{
			1 { return @('direct-export', 'exported-symbol-descriptor') }
			2 { return @('inline', 'header-inline-descriptor') }
			3 { return @('exported-callable', 'exported-runtime-thunk-descriptor') }
			4 { return @('exported-callable', 'exported-runtime-callable-descriptor') }
			5
			{
				if ([string] $Installed.HasExpectedScalarABI -eq 'true')
				{
					return @('bridge', 'provider-private-scalar-bridge')
				}
				return @('unsupported', 'provider-private-scalar-abi-unavailable')
			}
			default { return @('unsupported', 'descriptor-linkage-absent-or-unknown') }
		}
	}
	if ([string] $Installed.HasExpectedScalarABI -eq 'true')
	{
		return @('bridge', 'current-binding-slot-scalar-bridge')
	}
	return @('unsupported', 'typed-scalar-abi-unavailable')
}

$installedPath = (Resolve-Path -LiteralPath $InstalledCsv).Path
$sourceCallsitesPath = (Resolve-Path -LiteralPath $SourceCallsitesCsv).Path
$sourceProvidersPath = (Resolve-Path -LiteralPath $SourceProvidersCsv).Path
$installedRows = @(Import-Csv -LiteralPath $installedPath)
$sourceCallsites = @(Import-Csv -LiteralPath $sourceCallsitesPath)
$sourceProviders = @(Import-Csv -LiteralPath $sourceProvidersPath)

if ($installedRows.Count -eq 0)
{
	throw 'The installed generation inventory is empty.'
}

$callsitesByProvider = @{}
foreach ($row in $sourceCallsites)
{
	Add-ToLookup -Lookup $callsitesByProvider -Key ([string] $row.Provider) -Value $row
}
$providersByName = @{}
foreach ($row in $sourceProviders)
{
	Add-ToLookup -Lookup $providersByName -Key ([string] $row.Provider) -Value $row
}

$seenFunctionIds = [System.Collections.Generic.HashSet[int]]::new()
$seenStableKeys = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
$installedProviderNames = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
$finalRows = [System.Collections.Generic.List[object]]::new()

foreach ($installed in $installedRows)
{
	$functionId = [int] $installed.EngineLocalFunctionId
	if (-not $seenFunctionIds.Add($functionId))
	{
		throw "Duplicate Engine-local FunctionId in installed inventory: $functionId"
	}
	if ([string] $installed.Origin -eq '0')
	{
		throw "Installed Bind function remains origin=unknown: $($installed.CanonicalDeclaration)"
	}
	$null = $installedProviderNames.Add([string] $installed.Provider)

	if ([string] $installed.HasStableReference -ne 'true' -or
		[string]::IsNullOrWhiteSpace([string] $installed.StableReferenceKey) -or
		[string] $installed.StableReferenceKey -match '^0+$' -or
		[string]::IsNullOrWhiteSpace([string] $installed.StableReferenceExpectedABI) -or
		[string] $installed.StableReferenceExpectedABI -match '^0+$')
	{
		throw "Installed Bind function has no CacheV2 stable environment reference: $($installed.CanonicalDeclaration) $($installed.StableReferenceError)"
	}
	$stableKey = ([string] $installed.StableReferenceKey).ToLowerInvariant()
	if (-not $seenStableKeys.Add($stableKey))
	{
		throw "Duplicate stable installed identity: $stableKey $($installed.CanonicalDeclaration)"
	}

	$providerCandidates = $providersByName.ContainsKey([string] $installed.Provider) ?
		@($providersByName[[string] $installed.Provider]) : @()
	$providerExact = @($providerCandidates | Where-Object {
		(Test-PathSuffixMatch -InstalledPath ([string] $installed.ProviderSourceFile) -SourcePath ([string] $_.SourceFile)) -and
		[int] $_.SourceLine -eq [int] $installed.ProviderSourceLine
	})
	$providerJoinStatus = $providerExact.Count -eq 1 ? 'exact-source-provider' :
		($providerCandidates.Count -gt 0 ? 'installed-provider-authority' : 'installed-provider-outside-runtime-source-scan')
	$sourceProviderFile = $providerExact.Count -eq 1 ? [string] $providerExact[0].SourceFile : [string] $installed.ProviderSourceFile
	$sourceProviderLine = $providerExact.Count -eq 1 ? [int] $providerExact[0].SourceLine : [int] $installed.ProviderSourceLine

	$callsiteCandidates = $callsitesByProvider.ContainsKey([string] $installed.Provider) ?
		@($callsitesByProvider[[string] $installed.Provider]) : @()
	$selection = Select-SourceCallsite -Installed $installed -Candidates $callsiteCandidates
	$selected = $selection.Row
	$sourceCompileOutMethods = if ($null -ne $selected)
	{
		[string] $selected.CompileOutMethods
	}
	else
	{
		Get-UniqueJoinedValue -Rows $callsiteCandidates -Property 'CompileOutMethods'
	}
	$nonRewritten = Get-NonRewrittenDisposition -Installed $installed
	$installedDispatch = Get-InstalledDispatchKind -Installed $installed
	if ([string] $nonRewritten[0] -in @('direct-export', 'inline', 'exported-callable') -and
		$installedDispatch -in @('GenericFunction', 'GenericMethod'))
	{
		throw "DirectDescriptorUsesGenericDispatch: $($installed.CanonicalDeclaration) advertises $($nonRewritten[0]) through $installedDispatch instead of the reviewed DLL/inline C++ target."
	}
	if ([string] $nonRewritten[0] -in @('direct-export', 'inline', 'exported-callable') -and
		[int] $installed.NativeUFunctionRouteFlags -ne 0)
	{
		throw "DirectDescriptorBypassesUnrealRoute: $($installed.CanonicalDeclaration) advertises $($nonRewritten[0]) while UFunction route flags=$($installed.NativeUFunctionRouteFlags) require Unreal routing."
	}
	$disposition = [string] $nonRewritten[0]
	$dispositionReason = [string] $nonRewritten[1]
	if ([int] $installed.CompileOutKind -ne 0)
	{
		$disposition = 'compile-out'
		$dispositionReason = 'target-profile-compile-out'
	}

	$implementation = if ([string] $installed.HasExternalDescriptor -eq 'true' -and
		-not [string]::IsNullOrWhiteSpace([string] $installed.DescriptorSymbol))
	{
		[string] $installed.DescriptorSymbol
	}
	elseif (-not [string]::IsNullOrWhiteSpace([string] $installed.NativeCallableDisplay))
	{
		[string] $installed.NativeCallableDisplay
	}
	elseif ($null -ne $selected -and
		-not [string]::IsNullOrWhiteSpace([string] $selected.CppTargetExpression))
	{
		[string] $selected.CppTargetExpression
	}
	else
	{
		'<current-engine-registered-system-caller>'
	}
	$declarationHeader = if (-not [string]::IsNullOrWhiteSpace([string] $installed.DescriptorInclude))
	{
		[string] $installed.DescriptorInclude
	}
	elseif (-not [string]::IsNullOrWhiteSpace([string] $installed.NativeHeader))
	{
		[string] $installed.NativeHeader
	}
	elseif ($null -ne $selected)
	{
		[string] $selected.SourceFile
	}
	else
	{
		[string] $installed.ProviderSourceFile
	}

	$output = [ordered] @{
		StableInventoryKey = $stableKey
		StableReferenceExpectedABI = [string] $installed.StableReferenceExpectedABI
		CanonicalDeclaration = [string] $installed.CanonicalDeclaration
		NamespaceCanonicalName = [string] $installed.NamespaceCanonicalName
		ReceiverCanonicalName = [string] $installed.ReceiverCanonicalName
		Disposition = $disposition
		DispositionReasonCode = $dispositionReason
		NonRewrittenDisposition = [string] $nonRewritten[0]
		NonRewrittenDispositionReasonCode = [string] $nonRewritten[1]
		CppCallableImplementation = $implementation
		CppDeclarationOrHeader = $declarationHeader
		DependencyLegality = ([string] $installed.HasExternalDescriptor -eq 'true') ?
			'validated-explicit-descriptor' : 'not-a-direct-external-call'
		Origin = [string] $installed.Origin
		OwnerModule = [string] $installed.OwnerModule
		Provider = [string] $installed.Provider
		Phase = [string] $installed.Phase
		ProviderSourceFile = [string] $installed.ProviderSourceFile
		ProviderSourceLine = [string] $installed.ProviderSourceLine
		ProviderJoinStatus = $providerJoinStatus
		SourceProviderFile = $sourceProviderFile
		SourceProviderLine = $sourceProviderLine
		CallsiteJoinStatus = [string] $selection.Status
		CallsiteCandidateCount = [int] $selection.CandidateCount
		SourceCallsiteFile = $null -ne $selected ? [string] $selected.SourceFile : ''
		SourceCallsiteLine = $null -ne $selected ? [int] $selected.SourceLine : 0
		SourceRegistrationApi = $null -ne $selected ? [string] $selected.RegistrationApi : ''
		SourceCppTargetExpression = $null -ne $selected ? [string] $selected.CppTargetExpression : ''
		SourceFluentTraits = $null -ne $selected ? [string] $selected.FluentTraits : ''
		SourceCompileOutMethods = $sourceCompileOutMethods
		CallableKind = [string] $installed.CallableKind
		FunctionTraitBits = [string] $installed.FunctionTraitBits
		CompileOutKind = [string] $installed.CompileOutKind
		DefaultArgumentCount = [string] $installed.DefaultArgumentCount
		HiddenArgumentIndex = [string] $installed.HiddenArgumentIndex
		DeterminesOutputTypeArgumentIndex = [string] $installed.DeterminesOutputTypeArgumentIndex
		FirstParamMetadata = [string] $installed.FirstParamMetadata
		RegisteredCallConv = [string] $installed.RegisteredCallConv
		DispatchKind = $installedDispatch
		RegisteredParameterSize = [string] $installed.RegisteredParameterSize
		RegisteredReturnSize = [string] $installed.RegisteredReturnSize
		ReturnsOnStack = [string] $installed.ReturnsOnStack
		UsesWorldContext = [string] $installed.UsesWorldContext
		HasSystemCaller = [string] $installed.HasSystemCaller
		HasNativeForm = [string] $installed.HasNativeForm
		NativeFormKind = [string] $installed.NativeFormKind
		NativeCallableDisplay = [string] $installed.NativeCallableDisplay
		NativeCustomForm = [string] $installed.NativeCustomForm
		NativeTargetType = [string] $installed.NativeTargetType
		NativeHeader = [string] $installed.NativeHeader
		NativeUnrealFunctionPath = [string] $installed.NativeUnrealFunctionPath
		NativeUFunctionRouteFlags = [string] $installed.NativeUFunctionRouteFlags
		NativeFormTrivial = [string] $installed.NativeFormTrivial
		NativeFormGuaranteed = [string] $installed.NativeFormGuaranteed
		NativeFormNeedsCompare = [string] $installed.NativeFormNeedsCompare
		NativeFormNeedsCopy = [string] $installed.NativeFormNeedsCopy
		HasExternalDescriptor = [string] $installed.HasExternalDescriptor
		DescriptorLinkage = [string] $installed.DescriptorLinkage
		DescriptorVisibility = [string] $installed.DescriptorVisibility
		DescriptorSymbol = [string] $installed.DescriptorSymbol
		DescriptorInclude = [string] $installed.DescriptorInclude
		DescriptorOwningModule = [string] $installed.DescriptorOwningModule
		DescriptorApiMacro = [string] $installed.DescriptorApiMacro
		DescriptorCppCallableSignature = [string] $installed.DescriptorCppCallableSignature
		DescriptorABIDomain = [string] $installed.DescriptorABIDomain
		DescriptorCompileOutPolicy = [string] $installed.DescriptorCompileOutPolicy
		DescriptorDefaultArgumentPolicy = [string] $installed.DescriptorDefaultArgumentPolicy
		DescriptorDefaultArgumentCount = [string] $installed.DescriptorDefaultArgumentCount
		DescriptorWorldContextPolicy = [string] $installed.DescriptorWorldContextPolicy
		DescriptorExceptionPolicy = [string] $installed.DescriptorExceptionPolicy
		DescriptorRouteFlags = [string] $installed.DescriptorRouteFlags
		DescriptorLifetimeFlags = [string] $installed.DescriptorLifetimeFlags
		DescriptorNormalized = [string] $installed.DescriptorNormalized
		HasExpectedNativeABI = [string] $installed.HasExpectedNativeABI
		ExpectedNativeABIHash = [string] $installed.ExpectedNativeABIHash
		NativeABIStatusCode = Get-DiagnosticCode -Diagnostic ([string] $installed.NativeABIError) -SuccessCode 'supported'
		HasExpectedScalarABI = [string] $installed.HasExpectedScalarABI
		ExpectedScalarABI = [string] $installed.ExpectedScalarABI
		ExpectedScalarABIHash = [string] $installed.ExpectedScalarABIHash
		ScalarABIStatusCode = Get-DiagnosticCode -Diagnostic ([string] $installed.ScalarABIError) -SuccessCode 'supported'
		ReviewStatus = 'installed-authority-classified'
	}
	$finalRows.Add([pscustomobject] $output)
}

$sourceReconciliation = [ordered] @{
	InstalledProviderCallsite = 0
	InactiveOrAlternateProviderCallsite = 0
	InactiveProfileBranchCallsite = 0
	InstalledDynamicAuthorityCallsite = 0
	UnresolvedSourceCallsite = 0
}
$sourceReconciliationRows = [System.Collections.Generic.List[object]]::new()
foreach ($source in $sourceCallsites)
{
	$status = ''
	$installedAuthority = ''
	$reason = ''
	if ([string]::IsNullOrWhiteSpace([string] $source.Provider))
	{
		$normalizedSourceFile = ([string] $source.SourceFile).Replace('\', '/')
		$sourceLine = [int] $source.SourceLine
		if ($normalizedSourceFile -eq 'Binds/Bind_BlueprintCallable.cpp' -and
			$sourceLine -in @(242, 253, 264, 278))
		{
			++$sourceReconciliation.InactiveProfileBranchCallsite
			$status = 'inactive-profile-branch'
			$reason = 'Win64/EditorDevelopment has WITH_EDITOR=1, so AS_USE_BIND_DB=0 and BlueprintType uses the prepare/commit registration path instead of BindBlueprintCallable.'
		}
		elseif ($normalizedSourceFile -eq 'Binds/Bind_BlueprintCallable.cpp' -and
			$sourceLine -in @(424, 434, 444, 455) -and
			$installedProviderNames.Contains('BlueprintType.ReflectionBindings'))
		{
			++$sourceReconciliation.InstalledDynamicAuthorityCallsite
			$status = 'installed-dynamic-authority'
			$installedAuthority = 'BlueprintType.ReflectionBindings'
			$reason = 'Active AS_USE_BIND_DB=0 prepare/commit direct BlueprintCallable registration; installed non-generic UFunction rows provide exact identity and routing.'
		}
		elseif ($normalizedSourceFile -eq 'Binds/BlueprintCallableReflectiveFallback.cpp' -and
			$sourceLine -in @(791, 801, 820, 831) -and
			$installedProviderNames.Contains('BlueprintType.ReflectionBindings'))
		{
			++$sourceReconciliation.InstalledDynamicAuthorityCallsite
			$status = 'installed-dynamic-authority'
			$installedAuthority = 'BlueprintType.ReflectionBindings'
			$reason = 'Shared no-native-pointer fallback; installed generic UFunction rows provide exact identity and routing.'
		}
		elseif ($normalizedSourceFile -eq 'Binds/Bind_Primitives_Type.cpp' -and
			$sourceLine -in @(93, 114) -and
			$installedProviderNames.Contains('BlueprintType.ReflectionBindings') -and
			$installedProviderNames.Contains('UStruct.ReflectionBindings'))
		{
			++$sourceReconciliation.InstalledDynamicAuthorityCallsite
			$status = 'installed-dynamic-authority'
			$installedAuthority = 'BlueprintType.ReflectionBindings;UStruct.ReflectionBindings'
			$reason = 'Dynamic bool bitfield property accessor; exact native-form helper spelling plus installed owner/receiver separates every generated getter/setter.'
		}
		else
		{
			++$sourceReconciliation.UnresolvedSourceCallsite
			$status = 'unresolved'
			$reason = 'No reviewed current-profile source-to-installed authority rule matched.'
		}
	}
	elseif ($installedProviderNames.Contains([string] $source.Provider))
	{
		++$sourceReconciliation.InstalledProviderCallsite
		$status = 'installed-provider-source-surface'
		$installedAuthority = [string] $source.Provider
		$reason = 'The fresh Engine installed this Provider identity; dynamic/variant source expressions remain source surface unless an exact installed row join selects one.'
	}
	else
	{
		++$sourceReconciliation.InactiveOrAlternateProviderCallsite
		$status = 'inactive-or-alternate-provider'
		$reason = 'The source Provider identity is absent from the fresh Win64/EditorDevelopment Engine surface.'
	}
	$sourceReconciliationRows.Add([pscustomobject][ordered]@{
		SourceFile = [string] $source.SourceFile
		SourceLine = [int] $source.SourceLine
		SourceProvider = [string] $source.Provider
		RegistrationApi = [string] $source.RegistrationApi
		DeclarationExpression = [string] $source.DeclarationExpression
		LiteralDeclaration = [string] $source.LiteralDeclaration
		CppTargetExpression = [string] $source.CppTargetExpression
		NativeCallableDisplays = [string] $source.EffectiveNativeCallableDisplays
		ExternalDescriptorSymbols = [string] $source.ExternalDescriptorSymbols
		CompileOutMethods = [string] $source.CompileOutMethods
		SourceEvidenceDisposition = [string] $source.SourceEvidenceDisposition
		RequiredInstalledAuthority = [string] $source.RequiredInstalledAuthority
		ReconciliationStatus = $status
		InstalledAuthority = $installedAuthority
		ReconciliationReason = $reason
	})
}
if (($sourceReconciliation.Values | Measure-Object -Sum).Sum -ne $sourceCallsites.Count)
{
	throw 'Source-callsite reconciliation totals do not add up.'
}
if ($sourceReconciliation.UnresolvedSourceCallsite -ne 0)
{
	throw "Source-callsite reconciliation retains $($sourceReconciliation.UnresolvedSourceCallsite) unresolved rows."
}

$outputDirectory = Split-Path -Parent $OutputCsv
$summaryDirectory = Split-Path -Parent $SummaryJson
New-Item -ItemType Directory -Force -Path $outputDirectory | Out-Null
New-Item -ItemType Directory -Force -Path $summaryDirectory | Out-Null
$finalRows |
	Sort-Object StableInventoryKey |
	Export-Csv -LiteralPath $OutputCsv -NoTypeInformation -Encoding utf8NoBOM
$sourceReconciliationCsv = Join-Path $outputDirectory 'native-call-source-reconciliation.csv'
$sourceReconciliationRows | Export-Csv -LiteralPath $sourceReconciliationCsv -NoTypeInformation -Encoding utf8NoBOM

$dispositions = [ordered] @{}
foreach ($group in $finalRows | Group-Object Disposition | Sort-Object Name)
{
	$dispositions[$group.Name] = $group.Count
}
$joinStatuses = [ordered] @{}
foreach ($group in $finalRows | Group-Object CallsiteJoinStatus | Sort-Object Name)
{
	$joinStatuses[$group.Name] = $group.Count
}
$originCounts = [ordered] @{}
foreach ($group in $finalRows | Group-Object Origin | Sort-Object Name)
{
	$originCounts[$group.Name] = $group.Count
}
$dispatchCounts = [ordered] @{}
foreach ($group in $finalRows | Group-Object DispatchKind | Sort-Object Name)
{
	$dispatchCounts[$group.Name] = $group.Count
}
$uFunctionRouteFlagCounts = [ordered] @{}
foreach ($group in $finalRows | Group-Object NativeUFunctionRouteFlags | Sort-Object Name)
{
	$uFunctionRouteFlagCounts[$group.Name] = $group.Count
}
$routedUFunctionRows = @($finalRows | Where-Object {
	[int] $_.NativeUFunctionRouteFlags -ne 0
})
$rpcOrNetUFunctionRows = @($routedUFunctionRows | Where-Object {
	([int] $_.NativeUFunctionRouteFlags -band 1) -ne 0
}).Count
$eventUFunctionRows = @($routedUFunctionRows | Where-Object {
	([int] $_.NativeUFunctionRouteFlags -band 2) -ne 0
}).Count
$blueprintEventUFunctionRows = @($routedUFunctionRows | Where-Object {
	([int] $_.NativeUFunctionRouteFlags -band 4) -ne 0
}).Count

$directBlueprintCallableRows = @($installedRows | Where-Object {
	[string] $_.Provider -eq 'BlueprintType.ReflectionBindings' -and
	-not [string]::IsNullOrWhiteSpace([string] $_.NativeUnrealFunctionPath) -and
	[int] $_.RegisteredCallConv -notin @(0, 14)
}).Count
$reflectiveBlueprintCallableRows = @($installedRows | Where-Object {
	[string] $_.Provider -eq 'BlueprintType.ReflectionBindings' -and
	-not [string]::IsNullOrWhiteSpace([string] $_.NativeUnrealFunctionPath) -and
	[int] $_.RegisteredCallConv -in @(0, 14)
}).Count
$boolGetterRows = @($installedRows | Where-Object {
	[string] $_.NativeCallableDisplay -eq 'FAngelscriptBindHelpers::GetBoolFromProperty'
}).Count
$boolSetterRows = @($installedRows | Where-Object {
	[string] $_.NativeCallableDisplay -eq 'FAngelscriptBindHelpers::SetBoolFromProperty'
}).Count
if ($directBlueprintCallableRows -eq 0 -or
	$reflectiveBlueprintCallableRows -eq 0 -or
	$boolGetterRows -eq 0 -or $boolSetterRows -eq 0)
{
	throw 'A reviewed dynamic helper source group has no installed current-profile expansion.'
}

$summary = [ordered] @{
	Schema = 'typed-aot-native-call-export-inventory-v4'
	TargetProfile = 'Win64/EditorDevelopment'
	FinalInventorySha256 = (Get-FileHash -LiteralPath $OutputCsv -Algorithm SHA256).Hash.ToLowerInvariant()
	FinalInventoryBytes = (Get-Item -LiteralPath $OutputCsv).Length
	SourceReconciliationSha256 = (Get-FileHash -LiteralPath $sourceReconciliationCsv -Algorithm SHA256).Hash.ToLowerInvariant()
	SourceReconciliationBytes = (Get-Item -LiteralPath $sourceReconciliationCsv).Length
	InstalledInventorySha256 = (Get-FileHash -LiteralPath $installedPath -Algorithm SHA256).Hash.ToLowerInvariant()
	SourceCallsitesSha256 = (Get-FileHash -LiteralPath $sourceCallsitesPath -Algorithm SHA256).Hash.ToLowerInvariant()
	SourceProvidersSha256 = (Get-FileHash -LiteralPath $sourceProvidersPath -Algorithm SHA256).Hash.ToLowerInvariant()
	InstalledRowCount = $installedRows.Count
	StableIdentityCount = $seenStableKeys.Count
	UnknownOriginCount = @($installedRows | Where-Object Origin -eq '0').Count
	DistinctInstalledProviderCount = $installedProviderNames.Count
	SourceCallsiteCount = $sourceCallsites.Count
	SourceProviderDeclarationCount = $sourceProviders.Count
	Dispositions = $dispositions
	CallsiteJoinStatuses = $joinStatuses
	Origins = $originCounts
	DispatchKinds = $dispatchCounts
	NativeUFunctionRouteFlagValues = $uFunctionRouteFlagCounts
	NativeUFunctionRouteFacts = [ordered] @{
		AnyRouted = $routedUFunctionRows.Count
		RpcOrNet = $rpcOrNetUFunctionRows
		Event = $eventUFunctionRows
		BlueprintEvent = $blueprintEventUFunctionRows
		RawDirectConflict = 0
	}
	SourceReconciliation = $sourceReconciliation
	DynamicAuthorityInstalledRows = [ordered] @{
		DirectBlueprintCallable = $directBlueprintCallableRows
		ReflectiveBlueprintCallableFallback = $reflectiveBlueprintCallableRows
		BoolBitfieldGetter = $boolGetterRows
		BoolBitfieldSetter = $boolSetterRows
	}
	DispositionReasonCodes = [ordered] @{
		'exported-symbol-descriptor' = 'Validated importable DLL symbol.'
		'header-inline-descriptor' = 'Validated public inline definition.'
		'exported-runtime-thunk-descriptor' = 'Validated exported Runtime thunk.'
		'exported-runtime-callable-descriptor' = 'Validated exported implementation shared by Bind and generated C++.'
		'provider-private-scalar-bridge' = 'Provider-private target with reviewed scalar current-slot bridge ABI.'
		'current-binding-slot-scalar-bridge' = 'No external descriptor; reviewed scalar current-slot bridge ABI.'
		'typed-scalar-abi-unavailable' = 'Current TypedASTJIT scalar bridge cannot marshal the installed signature.'
		'target-profile-compile-out' = 'The maintained fork selected a compile-out rewrite for this exact profile.'
	}
	Completeness = 'complete-installed-editor-development-inventory'
	Notes = @(
		'Every output row is authoritative for one function accepted by the fresh StaticJITGeneration Engine.',
		'EngineLocalFunctionId is retained only in the raw Saved installed export as transient same-Engine evidence; the final local-only inventory excludes it and sorts by the existing CacheV2 EnvironmentSymbol key.',
		'DispatchKind records the pointer-free CallSystemFunction route: FunctionCaller takes precedence, otherwise GenericFunction, GenericMethod, or NativeCallingConvention.',
		'NativeUFunctionRouteFlags snapshots authoritative FUNC_Net, FUNC_Event, and FUNC_BlueprintEvent facts; any nonzero value forbids raw-direct linkage and preserves Unreal routing.',
		'NativeScalarABI describes only a proven C++ direct-call shape. A GenericFunction or GenericMethod never becomes direct-callable from that field; its later VM bridge eligibility is a separate AS-visible marshalling contract.',
		'One source registration expression may expand to many installed functions. Ambiguous dynamic and reflective expansions retain exact provider authority rather than guessing a callsite.',
		'Of the fourteen source rows without lexical Provider names, four are the inactive AS_USE_BIND_DB path for this Editor profile and ten are active direct/fallback/bool dynamic helper sites reconciled to installed BlueprintType.ReflectionBindings and UStruct.ReflectionBindings rows; unresolved source rows are zero.',
		'CompileOutKind is the actual selected target-profile result. SourceCompileOutMethods records source rewrite rules independently, and NonRewrittenDisposition preserves the fallback route.',
		'ExpectedNativeABIHash plus the explicit call-convention, receiver, size, default/hidden, trait, routing and lifetime columns carry the exact installed ABI evidence without repeating a long canonical ABI string in every row.',
		'Display spellings are provenance only and are never dispatch identity.'
	)
}
$summary | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $SummaryJson -Encoding utf8NoBOM

Write-Output "INSTALLED_ROWS=$($installedRows.Count)"
Write-Output "SOURCE_CALLSITES=$($sourceCallsites.Count)"
Write-Output "UNKNOWN_ORIGIN=0"
Write-Output "OUTPUT=$OutputCsv"
Write-Output "SOURCE_RECONCILIATION=$sourceReconciliationCsv"
Write-Output "SUMMARY=$SummaryJson"
