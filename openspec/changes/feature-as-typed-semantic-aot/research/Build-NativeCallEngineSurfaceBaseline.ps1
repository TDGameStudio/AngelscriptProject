[CmdletBinding()]
param(
	[Parameter(Mandatory = $true)]
	[string] $BundleDirectory,

	[Parameter(Mandatory = $true)]
	[string] $OutputCsv,

	[Parameter(Mandatory = $true)]
	[string] $SummaryJson
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$resolvedBundle = (Resolve-Path -LiteralPath $BundleDirectory).Path
$symbolsPath = Join-Path $resolvedBundle 'symbols.jsonl'
$manifestPath = Join-Path $resolvedBundle 'manifest.json'

if (-not (Test-Path -LiteralPath $symbolsPath -PathType Leaf))
{
	throw "Missing symbols.jsonl beneath bundle directory: $resolvedBundle"
}
if (-not (Test-Path -LiteralPath $manifestPath -PathType Leaf))
{
	throw "Missing manifest.json beneath bundle directory: $resolvedBundle"
}

$manifest = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json
$symbolsManifest = @($manifest.files | Where-Object { $_.name -eq 'symbols.jsonl' })
if ($symbolsManifest.Count -ne 1)
{
	throw "Expected exactly one symbols.jsonl manifest entry, found $($symbolsManifest.Count)"
}

$actualHash = (Get-FileHash -LiteralPath $symbolsPath -Algorithm SHA256).Hash.ToLowerInvariant()
if ($actualHash -ne [string] $symbolsManifest[0].sha256)
{
	throw "symbols.jsonl hash mismatch: manifest=$($symbolsManifest[0].sha256) actual=$actualHash"
}

$callableCount = 0
$manualRows = [System.Collections.Generic.List[object]]::new()
$kindCounts = [System.Collections.Generic.Dictionary[string, int]]::new()
$originCounts = [System.Collections.Generic.Dictionary[string, int]]::new()

foreach ($line in [System.IO.File]::ReadLines($symbolsPath))
{
	if (-not $line.Contains('"kind":"callable"'))
	{
		continue
	}

	++$callableCount
	$record = $line | ConvertFrom-Json
	$callable = $record.callable
	$origin = $callable.origin
	$kind = [string] $callable.kind
	$originKind = [string] $origin.kind

	if (-not $kindCounts.ContainsKey($kind))
	{
		$kindCounts.Add($kind, 0)
	}
	++$kindCounts[$kind]

	if (-not $originCounts.ContainsKey($originKind))
	{
		$originCounts.Add($originKind, 0)
	}
	++$originCounts[$originKind]

	if ($originKind -ne 'manual')
	{
		continue
	}

	$parameters = @($callable.parameters)
	$parameterTypes = @($parameters | ForEach-Object { [string] $_.type })
	$hasDefaults = @($parameters | Where-Object { [bool] $_.hasDefault }).Count -ne 0
	$hasReferences = @($parameters | Where-Object { [bool] $_.reference }).Count -ne 0
	$hasHandles = @($parameters | Where-Object { [bool] $_.handle }).Count -ne 0

	$manualRows.Add([pscustomobject] [ordered] @{
		StableId = [string] $callable.stableId
		OwnerStableId = [string] $callable.ownerStableId
		Namespace = [string] $callable.namespace
		CallableKind = $kind
		CanonicalDeclaration = [string] $callable.declaration
		RegisteredName = [string] $callable.name
		Behavior = [string] $callable.behavior
		ReturnType = [string] $callable.returnType
		ParameterCount = $parameters.Count
		ParameterTypes = $parameterTypes -join ';'
		HasDefaultArguments = $hasDefaults
		HasReferenceArguments = $hasReferences
		HasHandleArguments = $hasHandles
		Availability = [string] $callable.availability
		UEFunctionPath = [string] $callable.ueFunctionPath
		Origin = $originKind
		OriginModule = [string] $origin.module
		OriginPlugin = [string] $origin.plugin
		CppCallableDisplay = ''
		NativeFormKind = ''
		ExternalLinkage = ''
		ExpectedAbi = ''
		Disposition = 'unclassified'
		ReviewStatus = 'pending-native-form-source-join'
	})
}

if ($callableCount -gt [int] $symbolsManifest[0].recordCount)
{
	throw "Callable count $callableCount exceeds total symbol count $($symbolsManifest[0].recordCount)"
}

$outputDirectory = Split-Path -Parent $OutputCsv
$summaryDirectory = Split-Path -Parent $SummaryJson
New-Item -ItemType Directory -Force -Path $outputDirectory | Out-Null
New-Item -ItemType Directory -Force -Path $summaryDirectory | Out-Null

$manualRows |
	Sort-Object StableId |
	Export-Csv -LiteralPath $OutputCsv -NoTypeInformation -Encoding utf8NoBOM

$kindSummary = [ordered] @{}
foreach ($entry in $kindCounts.GetEnumerator() | Sort-Object Key)
{
	$kindSummary[$entry.Key] = $entry.Value
}
$originSummary = [ordered] @{}
foreach ($entry in $originCounts.GetEnumerator() | Sort-Object Key)
{
	$originSummary[$entry.Key] = $entry.Value
}

$summary = [ordered] @{
	Schema = 'typed-aot-native-call-engine-surface-baseline-v1'
	BundleIdentity = [string] $manifest.bundleIdentity
	BundleKind = [string] $manifest.bundleKind
	Platform = [string] $manifest.platform
	Configuration = [string] $manifest.configuration
	SymbolsSha256 = $actualHash
	SymbolCount = [int] $symbolsManifest[0].recordCount
	CallableCount = $callableCount
	ManualCallableCount = $manualRows.Count
	CallableKinds = $kindSummary
	CallableOrigins = $originSummary
	Completeness = 'partial-manual-provenance-only'
	KnownGap = 'Unknown-origin behavior/constructor/destructor/template-expanded callables still require registration provenance and native-form/source join before task 5.3 can complete.'
}

$summary |
	ConvertTo-Json -Depth 8 |
	Set-Content -LiteralPath $SummaryJson -Encoding utf8NoBOM

Write-Output "CALLABLE_TOTAL=$callableCount"
Write-Output "MANUAL_CALLABLE_TOTAL=$($manualRows.Count)"
Write-Output "CSV=$OutputCsv"
Write-Output "SUMMARY=$SummaryJson"
