[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Assert-True {
    param([bool]$Condition, [string]$Message)
    if (-not $Condition) { throw "Assertion failed: $Message" }
}

function Assert-Equal {
    param($Expected, $Actual, [string]$Message)
    if ($Expected -ne $Actual) { throw "Assertion failed: $Message (expected '$Expected', actual '$Actual')" }
}

$projectRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..\..\..'))
$harnessManifest = Join-Path $projectRoot '.agents\skills\harness\scripts\Harness.psd1'
$legacyManifest = Join-Path $projectRoot '.agents\skills\hardness\scripts\Hardness.psd1'

Assert-True (Test-Path -LiteralPath $harnessManifest -PathType Leaf) 'the canonical Harness module exists'
Assert-True (-not (Test-Path -LiteralPath $legacyManifest)) 'the old Hardness module path is absent'

$moduleManifests = @(
    $harnessManifest
    (Join-Path $projectRoot '.agents\skills\workspace-lifecycle\scripts\WorkspaceLifecycle.psd1')
    (Join-Path $projectRoot '.agents\skills\git-operations\scripts\GitOperations.psd1')
    (Join-Path $projectRoot '.agents\skills\unreal-engine-develop\scripts\UnrealEngineDevelop.psd1')
)
foreach ($manifest in $moduleManifests) {
    $data = Import-PowerShellDataFile -LiteralPath $manifest
    Assert-Equal '3.0.0' ([string]$data.ModuleVersion) "breaking module version is current: $manifest"
}

Import-Module $harnessManifest -Force
try {
    $routes = @(Get-HarnessCommand)
    foreach ($name in @('harness.status', 'harness.observe', 'harness.evolution.status')) {
        Assert-Equal 1 @($routes | Where-Object Name -eq $name).Count "Harness exposes $name exactly once"
    }
    Assert-Equal 0 @($routes | Where-Object Name -in @('hardness.status', 'hardness.observe', 'hardness.evolution.status')).Count 'old framework routes are absent'
    Assert-Equal 0 @(Get-Command -Module Harness | Where-Object Name -match 'Hardness').Count 'Harness exports no old public symbol'
    Assert-True ($null -eq (Get-Command New-HardnessContext -ErrorAction SilentlyContinue)) 'the old context constructor is unavailable'

    $context = New-HarnessContext -WorkspaceRoot $projectRoot
    $status = Invoke-Harness -Command harness.status -Context $context
    Assert-Equal 'Succeeded' $status.status 'the canonical Harness status route succeeds'
}
finally {
    Remove-Module Harness -Force -ErrorAction SilentlyContinue
}

Write-Output 'HarnessCutover.Tests.ps1: PASS'
