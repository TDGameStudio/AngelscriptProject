param(
    [int]$PassAfter = 1
)

$ErrorActionPreference = 'Stop'

$runDir = $env:RALPH_LOOP_RUN_DIR

if (-not $runDir) {
    throw "RALPH_LOOP_RUN_DIR is required."
}

$iterationCount = @(Get-ChildItem -Path $runDir -Directory -Filter 'iter-*' -ErrorAction SilentlyContinue).Count

Write-Output "verify-shell=$PSEdition"
Write-Output "stop-hook-shell=$env:RALPH_STOP_HOOK_SHELL"

if ($iterationCount -ge $PassAfter) {
    Write-Output "verification passed after $iterationCount iteration(s)"
    exit 0
}

Write-Error "verification pending after $iterationCount iteration(s)"
exit 1
