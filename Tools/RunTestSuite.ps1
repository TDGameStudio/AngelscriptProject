<#
.SYNOPSIS
    Run named Angelscript test suites by dispatching one or more standard test prefixes through RunTests.ps1.

.PARAMETER Suite
    Name of the built-in suite to execute.

.PARAMETER LabelPrefix
    Optional label prefix used for each suite item output directory.

.PARAMETER OutputRoot
    Optional output root forwarded to RunTests.ps1.

.PARAMETER NoReport
    Forwarded to RunTests.ps1.

.PARAMETER ContinueOnFail
    Keep running remaining prefixes after a failure instead of stopping early.

.PARAMETER ListSuites
    Print available suites and included prefixes.

.PARAMETER DryRun
    Print the commands that would run without invoking UnrealEditor-Cmd.
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
Write-Host "Runner       : $runTestsPath"
Write-Host "================================================================"

for ($index = 0; $index -lt $selectedSuite.Count; ++$index) {
    $entry = $selectedSuite[$index]
    $runLabel = "{0}_{1:D2}_{2}" -f $effectiveLabelPrefix, ($index + 1), $entry.Label
    $argList = @(
        "-NoProfile",
        "-ExecutionPolicy", "Bypass",
        "-File", $runTestsPath,
        "-TestPrefix", $entry.Prefix,
        "-Label", $runLabel
    )

    if (-not [string]::IsNullOrWhiteSpace($OutputRoot)) {
        $argList += @("-OutputRoot", $OutputRoot)
    }
    if ($TimeoutMs -gt 0) {
        $argList += @("-TimeoutMs", $TimeoutMs)
    }
    if ($NoReport) {
        $argList += "-NoReport"
    }

    if ($DryRun) {
        Write-Host "[DryRun] powershell.exe $($argList -join ' ')"
        continue
    }

    Write-Host "----------------------------------------------------------------"
    Write-Host "Running $($entry.Prefix)"
    Write-Host "Label        : $runLabel"
    Write-Host "Tier         : $(Resolve-AngelscriptTestSuiteEntryTier -Entry $entry)"
    Write-Host "----------------------------------------------------------------"

    & powershell.exe @argList
    if ($LASTEXITCODE -ne 0) {
        $failedRuns.Add([PSCustomObject]@{
                Prefix   = $entry.Prefix
                Label    = $runLabel
                ExitCode = $LASTEXITCODE
            }) | Out-Null

        if (-not $ContinueOnFail) {
            throw "Suite '$Suite' failed while executing prefix '$($entry.Prefix)' (label '$runLabel')."
        }

        Write-Host "[warn] Prefix '$($entry.Prefix)' failed with exit code $LASTEXITCODE. Continuing because -ContinueOnFail is set." -ForegroundColor Yellow
    }
}

if ($failedRuns.Count -gt 0) {
    Write-Host ""
    Write-Host "Suite '$Suite' completed with $($failedRuns.Count) failed prefix(es)." -ForegroundColor Yellow
    foreach ($failedRun in $failedRuns) {
        Write-Host ("  - {0} (exit {1})" -f $failedRun.Prefix, $failedRun.ExitCode)
    }
    exit 1
}

Write-Host ""
Write-Host "Suite '$Suite' completed successfully."
