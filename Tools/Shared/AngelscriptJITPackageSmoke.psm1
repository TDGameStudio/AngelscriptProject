Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Resolve-AngelscriptJITGameLinkResponsePath {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ProjectRoot,

        [Parameter(Mandatory = $true)]
        [string]$ProjectName,

        [Parameter(Mandatory = $true)]
        [ValidateSet('Development', 'Shipping')]
        [string]$Configuration
    )

    $responseName = if ($Configuration -eq 'Shipping') {
        "$ProjectName-Win64-Shipping.exe.rsp"
    }
    else {
        "$ProjectName.exe.rsp"
    }
    $responsePath = [System.IO.Path]::GetFullPath((Join-Path $ProjectRoot (
                'Intermediate\Build\Win64\x64\{0}\{1}\{2}' -f
                    $ProjectName, $Configuration, $responseName)))
    if (-not (Test-Path -LiteralPath $responsePath -PathType Leaf)) {
        throw "Game link response was not found: $responsePath"
    }
    return $responsePath
}

function Read-AngelscriptJITStructuredRoutingRecord {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ReportPath,

        [Parameter(Mandatory = $true)]
        [PSObject]$Manifest,

        [Parameter(Mandatory = $true)]
        [string]$ExpectedProfile
    )

    if (-not (Test-Path -LiteralPath $ReportPath -PathType Leaf)) {
        throw "Packaged process structure report was not produced: $ReportPath"
    }
    $report = Get-Content -LiteralPath $ReportPath -Raw | ConvertFrom-Json
    if ($null -eq $report -or [int]$report.schemaVersion -lt 4) {
        throw 'Packaged process structure report must use schema version 4 or newer.'
    }
    if (-not [bool]$report.current.present) {
        throw 'Packaged process structure report has no current Cache V2 publication.'
    }
    if (-not [bool]$report.functionRoutes.present) {
        throw 'Packaged process structure report has no function-route publication.'
    }

    $artifactProfile = [string]$Manifest.artifactProfile
    if ([string]$report.current.profile -ne $artifactProfile) {
        throw ("Packaged process profile '{0}' does not match manifest profile '{1}'." -f
            $report.current.profile, $artifactProfile)
    }

    $expectedFunctions = @($Manifest.functions)
    $expectedByIdentity = @{}
    foreach ($function in $expectedFunctions) {
        $identity = '{0}|{1}' -f $function.moduleKey, $function.functionKey
        if ($expectedByIdentity.ContainsKey($identity)) {
            throw "Provider manifest contains duplicate function identity '$identity'."
        }
        $expectedByIdentity[$identity] = $function
    }

    $verifiedRoutes = @($report.functionRoutes.routes |
        Where-Object { [bool]$_.verifiedArtifactIdentity })
    if ($verifiedRoutes.Count -ne $expectedFunctions.Count) {
        throw ("Packaged process published {0} verified routes; expected exactly {1}." -f
            $verifiedRoutes.Count, $expectedFunctions.Count)
    }

    $observedByIdentity = @{}
    foreach ($route in $verifiedRoutes) {
        $identity = '{0}|{1}' -f $route.moduleKey, $route.functionKey
        if ($observedByIdentity.ContainsKey($identity)) {
            throw "Packaged process contains duplicate verified route '$identity'."
        }
        $observedByIdentity[$identity] = $route
    }

    foreach ($identity in $expectedByIdentity.Keys) {
        if (-not $observedByIdentity.ContainsKey($identity)) {
            throw "Packaged process is missing verified manifest route '$identity'."
        }
        $expected = $expectedByIdentity[$identity]
        $observed = $observedByIdentity[$identity]
        if ([string]$observed.executionHash -ne [string]$expected.executionHash -or
            [string]$observed.debugHash -ne [string]$expected.debugHash -or
            [string]$observed.profile -ne $artifactProfile) {
            throw "Packaged process route '$identity' does not match the manifest artifact identity."
        }
        if ([int]$observed.artifactMatchResult -ne 0 -or
            [string]$observed.selectedRouteName -ne 'Native') {
            throw ("Packaged process route '{0}' selected {1} with match result {2}; " +
                'an exact Native route was required.' -f
                $identity, $observed.selectedRouteName, $observed.artifactMatchResult)
        }
    }

    if ([int]$report.functionRoutes.nativeRouteCount -ne $expectedFunctions.Count) {
        throw ("Packaged process published {0} native routes; expected exactly {1}." -f
            $report.functionRoutes.nativeRouteCount, $expectedFunctions.Count)
    }

    $stableReferences = @($expectedFunctions |
        ForEach-Object { @($_.references) } |
        ForEach-Object {
            '{0}|{1}|{2}' -f $_.kind, $_.stableKey, $_.expectedAbi
        } |
        Sort-Object -Unique)
    $stableRouteSet = @($expectedByIdentity.Keys | Sort-Object) -join ','
    $publicationOrdinal = [uint64]$report.functionRoutes.publicationOrdinal
    return [PSCustomObject][ordered]@{
        EvidenceSource = 'StructuredProcessReport'
        Code = 0
        Profile = $ExpectedProfile
        PublicationOrdinal = $publicationOrdinal
        ProviderCount = 1
        VerifiedRouteCount = $expectedFunctions.Count
        ExactMatchCount = $expectedFunctions.Count
        PublishedNativeCount = $expectedFunctions.Count
        VmFallbackCount = 0
        ResolvedReferenceCount = $stableReferences.Count
        RequestedReferenceCount = $stableReferences.Count
        SourceRouteGeneration = $publicationOrdinal
        PublishedRouteGeneration = $publicationOrdinal
        MatchResults = ('0:{0}' -f $expectedFunctions.Count)
        StableRouteSet = $stableRouteSet
        StructureSchemaVersion = [int]$report.schemaVersion
    }
}

Export-ModuleMember -Function @(
    'Resolve-AngelscriptJITGameLinkResponsePath',
    'Read-AngelscriptJITStructuredRoutingRecord'
)
