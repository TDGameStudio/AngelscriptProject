[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Assert-Equal {
    param($Expected, $Actual, [string]$Message)
    if ($Expected -ne $Actual) {
        throw "$Message Expected=[$Expected] Actual=[$Actual]"
    }
}

function Assert-Throws {
    param([scriptblock]$Action, [string]$Message)
    try {
        & $Action
    }
    catch {
        return
    }
    throw $Message
}

$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
Import-Module (Join-Path $projectRoot `
        'Tools\Shared\AngelscriptJITPackageSmoke.psm1') -Force

$testRoot = Join-Path ([System.IO.Path]::GetTempPath()) (
    'as-jit-package-smoke-selftest-' + [guid]::NewGuid().ToString('N'))
try {
    $responseRoot = Join-Path $testRoot `
        'Intermediate\Build\Win64\x64\FixtureProject'
    $developmentRoot = Join-Path $responseRoot 'Development'
    $shippingRoot = Join-Path $responseRoot 'Shipping'
    New-Item -ItemType Directory `
        -Path $developmentRoot, $shippingRoot -Force | Out-Null
    $developmentResponse = Join-Path $developmentRoot `
        'FixtureProject.exe.rsp'
    $shippingResponse = Join-Path $shippingRoot `
        'FixtureProject-Win64-Shipping.exe.rsp'
    [System.IO.File]::WriteAllText($developmentResponse, 'development')
    [System.IO.File]::WriteAllText($shippingResponse, 'shipping')

    Assert-Equal $developmentResponse `
        (Resolve-AngelscriptJITGameLinkResponsePath `
            -ProjectRoot $testRoot `
            -ProjectName 'FixtureProject' `
            -Configuration Development) `
        'Development must resolve the unsuffixed game target response.'
    Assert-Equal $shippingResponse `
        (Resolve-AngelscriptJITGameLinkResponsePath `
            -ProjectRoot $testRoot `
            -ProjectName 'FixtureProject' `
            -Configuration Shipping) `
        'Shipping must resolve the configuration-suffixed game target response.'

    $manifest = [PSCustomObject]@{
        artifactProfile = 'profile-hash'
        functions = @(
            [PSCustomObject]@{
                moduleKey = 'module-a'
                functionKey = 'function-a'
                executionHash = 'execution-a'
                debugHash = 'debug-a'
                references = @(
                    [PSCustomObject]@{
                        kind = 'ScriptType'
                        stableKey = 'type-a'
                        expectedAbi = 'abi-a'
                    }
                )
            },
            [PSCustomObject]@{
                moduleKey = 'module-b'
                functionKey = 'function-b'
                executionHash = 'execution-b'
                debugHash = 'debug-b'
                references = @(
                    [PSCustomObject]@{
                        kind = 'ScriptType'
                        stableKey = 'type-a'
                        expectedAbi = 'abi-a'
                    }
                )
            }
        )
    }
    $report = [ordered]@{
        schemaVersion = 4
        current = [ordered]@{
            present = $true
            profile = 'profile-hash'
        }
        functionRoutes = [ordered]@{
            present = $true
            publicationOrdinal = '7'
            vmRouteCount = 1
            nativeRouteCount = 2
            routes = @(
                [ordered]@{
                    moduleKey = 'module-a'
                    functionKey = 'function-a'
                    executionHash = 'execution-a'
                    debugHash = 'debug-a'
                    profile = 'profile-hash'
                    selectedRouteName = 'Native'
                    artifactMatchResult = 0
                    verifiedArtifactIdentity = $true
                },
                [ordered]@{
                    moduleKey = 'module-b'
                    functionKey = 'function-b'
                    executionHash = 'execution-b'
                    debugHash = 'debug-b'
                    profile = 'profile-hash'
                    selectedRouteName = 'Native'
                    artifactMatchResult = 0
                    verifiedArtifactIdentity = $true
                },
                [ordered]@{
                    moduleKey = 'module-vm-only'
                    functionKey = 'function-vm-only'
                    executionHash = 'zero'
                    debugHash = 'zero'
                    profile = 'zero'
                    selectedRouteName = 'Vm'
                    artifactMatchResult = 2
                    verifiedArtifactIdentity = $false
                }
            )
        }
    }
    $reportPath = Join-Path $testRoot 'Launch-01.json'
    $report | ConvertTo-Json -Depth 10 | Set-Content `
        -LiteralPath $reportPath -Encoding utf8

    $route = Read-AngelscriptJITStructuredRoutingRecord `
        -ReportPath $reportPath `
        -Manifest $manifest `
        -ExpectedProfile GameShipping
    Assert-Equal 'StructuredProcessReport' $route.EvidenceSource `
        'Shipping fallback must identify its evidence source.'
    Assert-Equal 2 $route.VerifiedRouteCount `
        'Every manifest function must have a verified route.'
    Assert-Equal 2 $route.PublishedNativeCount `
        'Every manifest function must select a native route.'
    Assert-Equal 0 $route.VmFallbackCount `
        'Unverified VM-only routes must not count as provider fallbacks.'
    Assert-Equal 1 $route.RequestedReferenceCount `
        'Stable references must be counted by unique identity.'
    Assert-Equal 'module-a|function-a,module-b|function-b' `
        $route.StableRouteSet `
        'The stable route set must be deterministic.'

    $report.functionRoutes.routes[1].selectedRouteName = 'Vm'
    $report | ConvertTo-Json -Depth 10 | Set-Content `
        -LiteralPath $reportPath -Encoding utf8
    Assert-Throws {
        Read-AngelscriptJITStructuredRoutingRecord `
            -ReportPath $reportPath `
            -Manifest $manifest `
            -ExpectedProfile GameShipping
    } 'A verified VM fallback must fail packaged native-route validation.'
}
finally {
    if (Test-Path -LiteralPath $testRoot) {
        Remove-Item -LiteralPath $testRoot -Recurse -Force
    }
}

Write-Host 'AngelScript StaticJIT package-smoke helper self-tests passed.'
