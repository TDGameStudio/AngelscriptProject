# Purpose: prove phase-1 four-tenant identity conservation after NewVersion
# retirement without re-launching the known-crashing RuntimeBindings prefix.
# Dependencies: Test-MigrationIdentity.ps1 and the checked-in/local reports.

[CmdletBinding()]
param(
    [string] $WorkspaceRoot = (Get-Location).Path
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$changeRoot = Join-Path $WorkspaceRoot 'openspec/changes/angelscript/refactor-testing-nativeengine-home/attachments'
$compare = Join-Path $changeRoot 'scripts/Test-MigrationIdentity.ps1'
$mapPath = Join-Path $changeRoot 'data/migration-identity-map.json'
$beforePath = Join-Path $changeRoot 'data/pre-move-identities.json'
$newVersion = Join-Path $WorkspaceRoot 'Plugins/Angelscript/Source/AngelscriptTest/NewVersion'

if (Test-Path -LiteralPath $newVersion) {
    throw "NewVersion is still a source root: $newVersion"
}

$reports = [ordered]@{
    NativeEngine    = Join-Path $WorkspaceRoot 'Saved/Harness/Unreal/Runs/356ad9871c6240188455d2432fc93c48/AutomationReport/index.json'
    Framework       = Join-Path $WorkspaceRoot 'Saved/Harness/Unreal/Runs/5da033651c144f0e8af679066643c196/AutomationReport/index.json'
    Baseline        = Join-Path $WorkspaceRoot 'Saved/Harness/Unreal/Runs/1f26ddfac40e49bd8a079368fc72b2e0/AutomationReport/index.json'
    RuntimeBindings = Join-Path $changeRoot 'data/post-move-runtimebindings-identities.json'
    Bindings        = Join-Path $WorkspaceRoot 'Saved/Harness/Unreal/Runs/3a0290908a634c17b7c45663fbdd5ff1/AutomationReport/index.json'
}

foreach ($name in $reports.Keys) {
    $path = $reports[$name]
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        throw "Missing $name conservation report: $path"
    }
    & $compare -BeforeReport $beforePath -AfterReport $path -MapPath $mapPath -Tenant $name
    if ($LASTEXITCODE -ne 0) {
        throw "Identity conservation failed for tenant $name"
    }
}

Write-Output 'Phase-1 migration conservation passed: NewVersion is gone; NativeEngine, Framework, Baseline, RuntimeBindings, and Bindings identities match the frozen map. RuntimeBindings after-report is a Found-list because Array.AppendRemoveAndIterationYieldTwoThenFive still crashes asCModuleDefinitionSet::Create (pre-existing product defect).'