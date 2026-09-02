<#
.SYNOPSIS
    Fast full-suite automation entry (~5-8 min target on a warm dev machine).

.DESCRIPTION
    Uses dynamic TestModule subdivision (4 workers by default) + headless fast launch profile:
      -NullRHI (no GPU rendering — faster than real RHI)
      -NoLoadStartupPackages, -NoLiveCoding, -NoScreenMessages, ...

    This replaces the legacy 36-prefix serial/parallel flow which pays 36 cold starts.

    For slow/isolated suites (Debugger / Performance / HotReload), run separately:
      Tools\RunTests.ps1 -TestPrefix Angelscript.TestModule.Debugger -Fast -Label debugger-slow
#>
param(
    [string]$LabelPrefix = 'All-Fast',
    [int]$TimeoutMs = 900000,
    [switch]$ContinueOnFail,
    [switch]$DryRun
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$runner = Join-Path $PSScriptRoot 'RunTestSuiteParallel.ps1'
$argList = @(
    '-NoProfile',
    '-ExecutionPolicy', 'Bypass',
    '-File', $runner,
    '-Strategy', 'CoarseDynamic',
    '-TestModuleWorkers', '4',
    '-Fast',
    '-MaxParallelLight', '4',
    '-MaxParallelHeavy', '4',
    '-LabelPrefix', $LabelPrefix,
    '-TimeoutMs', $TimeoutMs
)

if ($ContinueOnFail) {
    $argList += '-ContinueOnFail'
}

if ($DryRun) {
    $argList += '-DryRun'
}

& powershell.exe @argList
exit $LASTEXITCODE
