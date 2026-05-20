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
    [switch]$ListSuites,
    [switch]$DryRun
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$runTestsPath = Join-Path $PSScriptRoot "RunTests.ps1"
if (-not (Test-Path -LiteralPath $runTestsPath)) {
    throw "RunTests.ps1 not found at '$runTestsPath'."
}

$suiteDefinitions = [ordered]@{
    "Smoke" = @(
        @{ Prefix = "Angelscript.TestModule.CppTests.MultiEngine"; Label = "MultiEngine" }
        @{ Prefix = "Angelscript.TestModule.CppTests.Engine.DependencyInjection"; Label = "DependencyInjection" }
        @{ Prefix = "Angelscript.TestModule.CppTests.Subsystem"; Label = "Subsystem" }
        @{ Prefix = "Angelscript.TestModule.Engine.BindConfig"; Label = "BindConfig" }
        @{ Prefix = "Angelscript.TestModule.Shared.EngineHelper"; Label = "SharedEngineHelper" }
        @{ Prefix = "Angelscript.TestModule.Parity"; Label = "Parity" }
    )
    "NativeCore" = @(
        @{ Prefix = "Angelscript.TestModule.AngelScriptSDK"; Label = "AngelScriptSDK" }
    )
    "RuntimeCpp" = @(
        @{ Prefix = "Angelscript.TestModule.CppTests"; Label = "CppTests" }
    )
    "Bindings" = @(
        @{ Prefix = "Angelscript.TestModule.Bindings"; Label = "Bindings" }
    )
    "LearningNative" = @(
        @{ Prefix = "Angelscript.TestModule.Learning.Native"; Label = "LearningNative" }
    )
    "LearningRuntime" = @(
        @{ Prefix = "Angelscript.TestModule.Learning.Runtime"; Label = "LearningRuntime" }
    )
    "HotReload" = @(
        @{ Prefix = "Angelscript.TestModule.HotReload"; Label = "HotReload" }
    )
    "Debugger" = @(
        @{ Prefix = "Angelscript.TestModule.CppTests.Debug."; Label = "CppDebugger" }
        @{ Prefix = "Angelscript.TestModule.Debugger."; Label = "TestModuleDebugger" }
    )
    "FunctionalSamples" = @(
        @{ Prefix = "Angelscript.TestModule.Actor"; Label = "Actor" }
        @{ Prefix = "Angelscript.TestModule.Component"; Label = "Component" }
        @{ Prefix = "Angelscript.TestModule.Delegate"; Label = "Delegate" }
        @{ Prefix = "Angelscript.TestModule.Interface"; Label = "Interface" }
    )
    "All" = @(
        @{ Prefix = "Angelscript"; Label = "All" }
    )
}

if ($ListSuites) {
    Write-Host "Available suites:"
    foreach ($suiteName in $suiteDefinitions.Keys) {
        Write-Host "- $suiteName"
        foreach ($entry in $suiteDefinitions[$suiteName]) {
            Write-Host "    $($entry.Prefix)"
        }
    }
    exit 0
}

if ([string]::IsNullOrWhiteSpace($Suite)) {
    throw "Suite is required. Use -ListSuites to inspect available values."
}

if (-not $suiteDefinitions.Contains($Suite)) {
    throw "Unknown suite '$Suite'. Use -ListSuites to inspect available values."
}

if ($TimeoutMs -lt 0) {
    throw "TimeoutMs must be zero or a positive integer."
}

if ($TimeoutMs -gt 3600000) {
    throw "TimeoutMs cannot exceed 3600000ms."
}

$selectedSuite = $suiteDefinitions[$Suite]
$effectiveLabelPrefix = if ([string]::IsNullOrWhiteSpace($LabelPrefix)) { $Suite } else { $LabelPrefix }

Write-Host "================================================================"
Write-Host "  Angelscript Test Suite Runner"
Write-Host "================================================================"
Write-Host "Suite        : $Suite"
Write-Host "Dry run      : $DryRun"
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
    Write-Host "----------------------------------------------------------------"

    & powershell.exe @argList
    if ($LASTEXITCODE -ne 0) {
        throw "Suite '$Suite' failed while executing prefix '$($entry.Prefix)' (label '$runLabel')."
    }
}

Write-Host ""
Write-Host "Suite '$Suite' completed successfully."
