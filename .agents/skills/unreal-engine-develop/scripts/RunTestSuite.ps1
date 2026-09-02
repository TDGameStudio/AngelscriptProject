<#
.SYNOPSIS
    Run named Angelscript test suites through their declared Unreal Automation or CMake/CTest runner.

.PARAMETER Suite
    Name of the built-in suite to execute.

.PARAMETER LabelPrefix
    Optional label prefix used for each suite item output directory.

.PARAMETER OutputRoot
    Optional output root forwarded to RunTests.ps1.

.PARAMETER NoReport
    Forwarded to Unreal Automation entries. Standalone CMake/CTest metadata is always retained.

.PARAMETER ContinueOnFail
    Keep running remaining entries after a failure instead of stopping early.

.PARAMETER ListSuites
    Print available suites and included entries.

.PARAMETER DryRun
    Print the commands that would run without invoking child runners.
#>
param(
    [string]$Suite = "",
    [string]$LabelPrefix = "",
    [string]$OutputRoot = "",
    [int]$TimeoutMs = 0,
    [switch]$NoReport,
    [switch]$ContinueOnFail,
    [switch]$ListSuites,
    [switch]$DryRun
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

. (Join-Path $PSScriptRoot 'Shared\TestSuiteDefinitions.ps1')
. (Join-Path $PSScriptRoot 'Shared\TestSuiteEntryRunner.ps1')

$runTestsPath = Join-Path $PSScriptRoot "RunTests.ps1"
if (-not (Test-Path -LiteralPath $runTestsPath)) {
    throw "RunTests.ps1 not found at '$runTestsPath'."
}

if ($ListSuites) {
    Write-AngelscriptTestSuiteCatalog
    exit 0
}

if ([string]::IsNullOrWhiteSpace($Suite)) {
    throw "Suite is required. Use -ListSuites to inspect available values."
}

if ($TimeoutMs -lt 0) {
    throw "TimeoutMs must be zero or a positive integer."
}

if ($TimeoutMs -gt 3600000) {
    throw "TimeoutMs cannot exceed 3600000ms."
}

$selectedSuite = @(Get-AngelscriptTestSuiteEntries -SuiteName $Suite)
$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..\..\..')).Path
$effectiveLabelPrefix = if ([string]::IsNullOrWhiteSpace($LabelPrefix)) { $Suite } else { $LabelPrefix }
$failedRuns = New-Object 'System.Collections.Generic.List[object]'

Write-Host "================================================================"
Write-Host "  Angelscript Test Suite Runner"
Write-Host "================================================================"
Write-Host "Suite        : $Suite"
Write-Host "Dry run      : $DryRun"
Write-Host "ContinueOnFail : $ContinueOnFail"
Write-Host "TimeoutMs    : $(if ($TimeoutMs -gt 0) { $TimeoutMs } else { '<per-run default>' })"
Write-Host "Run count    : $($selectedSuite.Count)"
Write-Host "Runner       : typed suite-entry dispatcher"
Write-Host "================================================================"

for ($index = 0; $index -lt $selectedSuite.Count; ++$index) {
    $entry = $selectedSuite[$index]
    $runLabel = "{0}_{1:D2}_{2}" -f $effectiveLabelPrefix, ($index + 1), $entry.Label
    Write-Host "----------------------------------------------------------------"
    $entryIdentity = if ($entry.Kind -eq 'UnrealAutomation') { $entry.Prefix } else { "$($entry.Kind):$($entry.Label)" }
    Write-Host "Running $entryIdentity"
    Write-Host "Label        : $runLabel"
    Write-Host "Kind         : $($entry.Kind)"
    Write-Host "Tier         : $(Resolve-AngelscriptTestSuiteEntryTier -Entry $entry)"
    Write-Host "----------------------------------------------------------------"

    $entryResult = Invoke-AngelscriptTestSuiteEntry `
        -Entry $entry `
        -ProjectRoot $projectRoot `
        -RunTestsPath $runTestsPath `
        -RunLabel $runLabel `
        -OutputRoot $OutputRoot `
        -TimeoutMs $TimeoutMs `
        -NoReport:$NoReport `
        -DryRun:$DryRun

    if ($entryResult.ExitCode -ne 0) {
        $failedRuns.Add([PSCustomObject]@{
                Kind     = $entry.Kind
                Identity = $entryIdentity
                Label    = $runLabel
                ExitCode = $entryResult.ExitCode
                RawExitCode = $entryResult.RawExitCode
            }) | Out-Null

        if (-not $ContinueOnFail) {
            throw "Suite '$Suite' failed while executing '$entryIdentity' (label '$runLabel', raw exit $($entryResult.RawExitCode))."
        }

        Write-Host "[warn] Entry '$entryIdentity' failed with exit code $($entryResult.ExitCode) (raw $($entryResult.RawExitCode)). Continuing because -ContinueOnFail is set." -ForegroundColor Yellow
    }
}

if ($failedRuns.Count -gt 0) {
    Write-Host ""
    Write-Host "Suite '$Suite' completed with $($failedRuns.Count) failed entry/entries." -ForegroundColor Yellow
    foreach ($failedRun in $failedRuns) {
        Write-Host ("  - {0} (exit {1}, raw {2})" -f $failedRun.Identity, $failedRun.ExitCode, $failedRun.RawExitCode)
    }
    exit 1
}

Write-Host ""
Write-Host "Suite '$Suite' completed successfully."
