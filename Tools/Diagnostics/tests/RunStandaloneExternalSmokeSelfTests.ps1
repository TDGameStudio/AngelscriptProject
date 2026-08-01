[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Assert-True {
    param([bool]$Condition, [string]$Message)
    if (-not $Condition) {
        throw $Message
    }
}

function Assert-Equal {
    param($Expected, $Actual, [string]$Message)
    if ($Expected -ne $Actual) {
        throw "$Message Expected=[$Expected] Actual=[$Actual]"
    }
}

function Assert-Throws {
    param([scriptblock]$Body, [string]$Message)
    try {
        & $Body
    }
    catch {
        return
    }
    throw $Message
}

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..\..')).Path
$helperPath = Join-Path $repoRoot 'Tools\Shared\StandaloneExternalSmokeUtils.ps1'
if (Test-Path -LiteralPath $helperPath -PathType Leaf) {
    . $helperPath
}

$testRoot = Join-Path ([System.IO.Path]::GetTempPath()) ('standalone-external-smoke-selftest-' + [guid]::NewGuid().ToString('N'))
try {
    $repository = Join-Path $testRoot 'Repository'
    $plugins = Join-Path $repository 'Plugins'
    $allowedRoot = Join-Path $repository 'Saved\StandaloneExternalSmoke'
    $runRoot = Join-Path $allowedRoot 'fixture-run'
    New-Item -ItemType Directory -Path $plugins -Force | Out-Null

    $emptyHashFixture = Join-Path $testRoot 'empty.bin'
    [System.IO.File]::WriteAllBytes($emptyHashFixture, [byte[]]@())
    Assert-Equal `
        'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855' `
        (Get-AngelscriptExternalSmokeSha256 -Path $emptyHashFixture) `
        'External-smoke SHA-256 should not depend on Get-FileHash availability.'

    $project = New-AngelscriptExternalConsumerProject `
        -RepositoryRoot $repository `
        -RunRoot $runRoot `
        -ProjectName 'ExternalConsumer'
    Assert-True (Test-Path -LiteralPath $project.ProjectFile -PathType Leaf) `
        'External project descriptor should be created.'
    Assert-True (Test-Path -LiteralPath $project.ScriptFile -PathType Leaf) `
        'External AngelScript fixture should be created.'
    $descriptor = Get-Content -LiteralPath $project.ProjectFile -Raw | ConvertFrom-Json
    Assert-True ($descriptor.PSObject.Properties.Name -notcontains 'Modules') `
        'External smoke project must remain content-only.'
    Assert-True ($descriptor.PSObject.Properties.Name -notcontains 'DisableEnginePluginsByDefault') `
        'External smoke project should retain the normal engine-plugin baseline.'
    Assert-Equal 1 @($descriptor.AdditionalPluginDirectories).Count `
        'External smoke project should declare one plugin directory.'
    $resolvedPluginDirectory = [System.IO.Path]::GetFullPath(
        (Join-Path $project.ProjectRoot ([string]$descriptor.AdditionalPluginDirectories[0])))
    Assert-Equal $plugins $resolvedPluginDirectory `
        'AdditionalPluginDirectories should resolve to the repository Plugins directory.'
    Assert-True (@($descriptor.Plugins.Name) -contains 'Angelscript') `
        'External project should enable the Angelscript plugin.'

    Assert-Throws -Body {
        Assert-AngelscriptExternalSmokePath `
            -AllowedRoot $allowedRoot `
            -CandidatePath (Join-Path $repository 'Outside')
    } -Message 'Paths outside the external-smoke root should be rejected.'

    $bundleA = Join-Path $runRoot 'bundle-a'
    $bundleB = Join-Path $runRoot 'bundle-b'
    New-Item -ItemType Directory -Path $bundleA, $bundleB -Force | Out-Null
    $manifest = [ordered]@{
        bundleIdentity = 'fixture-bundle-identity'
        bundleKind = 'project'
        engineProperties = [ordered]@{ 'unreal.project-name' = 'ExternalConsumer' }
        loadedModules = @('AngelscriptRuntime', 'AngelscriptEditor')
        symbolScope = [ordered]@{ complete = $true; state = 'complete' }
        assetScope = [ordered]@{ complete = $true; state = 'complete' }
    } | ConvertTo-Json -Depth 6 -Compress
    foreach ($bundle in @($bundleA, $bundleB)) {
        [System.IO.File]::WriteAllText((Join-Path $bundle 'manifest.json'), $manifest)
        [System.IO.File]::WriteAllText((Join-Path $bundle 'symbols.jsonl'), "{`"stableId`":`"fixture`"}`n")
        [System.IO.File]::WriteAllText((Join-Path $bundle 'assets.jsonl'), '')
    }
    $comparison = Compare-AngelscriptExternalProjectBundles `
        -FirstBundle $bundleA `
        -SecondBundle $bundleB `
        -ExpectedProjectName 'ExternalConsumer' `
        -ForbiddenModuleName 'AngelscriptProject' `
        -ForbiddenMachinePaths @($repository, $runRoot)
    Assert-Equal 'fixture-bundle-identity' $comparison.BundleIdentity `
        'Bundle comparison should retain the verified identity.'

    [System.IO.File]::WriteAllText((Join-Path $bundleB 'assets.jsonl'), "{}`n")
    Assert-Throws -Body {
        Compare-AngelscriptExternalProjectBundles `
            -FirstBundle $bundleA `
            -SecondBundle $bundleB `
            -ExpectedProjectName 'ExternalConsumer'
    } -Message 'Byte-different bundles should be rejected.'
    [System.IO.File]::WriteAllText((Join-Path $bundleB 'assets.jsonl'), '')

    $resultPath = Join-Path $runRoot 'result.json'
    [System.IO.File]::WriteAllText(
        $resultPath,
        ([ordered]@{
                status = 'complete'
                profile = 'ue-validation'
                ueValidationOnly = $true
                bundle = [ordered]@{
                    identity = 'fixture-bundle-identity'
                    kind = 'project'
                    path = $bundleA
                }
            } | ConvertTo-Json -Depth 5))
    $validatedResult = Test-AngelscriptExternalCompileResult `
        -ResultPath $resultPath `
        -ExpectedBundleIdentity 'fixture-bundle-identity' `
        -ExpectedBundlePath $bundleA
    Assert-Equal 'complete' $validatedResult.status `
        'Verified compile result should be returned.'
}
finally {
    if (Test-Path -LiteralPath $testRoot) {
        Remove-Item -LiteralPath $testRoot -Recurse -Force
    }
}

Write-Host 'RunStandaloneExternalSmoke self-tests passed.'
