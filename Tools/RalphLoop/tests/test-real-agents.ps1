param(
    [string[]]$Agents = @('codex', 'opencode')
)

$ErrorActionPreference = 'Stop'

. "$PSScriptRoot\test-helpers.ps1"

function Test-CommandAvailable {
    param(
        [Parameter(Mandatory = $true)]
        [string]$CommandName
    )

    return $null -ne (Get-Command $CommandName -ErrorAction SilentlyContinue)
}

if ($env:RALPH_TEST_REAL_AGENTS -notin @('1', 'true', 'TRUE', 'yes', 'YES')) {
    Write-Output 'SKIP: Set RALPH_TEST_REAL_AGENTS=1 to run real agent tests.'
    exit 0
}

$repoRoot = Split-Path -Parent $PSScriptRoot
$tmpRoot = Join-Path $PSScriptRoot '.tmp\real-agents'
$verifyScriptPath = Join-Path $tmpRoot 'verify-real-agent.ps1'

if (Test-Path $tmpRoot) {
    Remove-Item -Path $tmpRoot -Recurse -Force
}

New-Item -ItemType Directory -Path $tmpRoot -Force | Out-Null

$verifyScript = @'
param()

$ErrorActionPreference = 'Stop'
$iterationDir = $env:RALPH_LOOP_ITERATION_DIR
$lastMessageFile = Join-Path $iterationDir 'last-message.txt'

if ((Test-Path $lastMessageFile) -and -not [string]::IsNullOrWhiteSpace((Get-Content -Raw -Path $lastMessageFile))) {
    exit 0
}

exit 1
'@

Set-Content -Path $verifyScriptPath -Value $verifyScript -Encoding UTF8

foreach ($agent in $Agents) {
    if (-not (Test-CommandAvailable -CommandName $agent)) {
        Write-Output "SKIP: Agent '$agent' is not installed."
        continue
    }

    $runsRoot = Join-Path $tmpRoot $agent
    $verifyCommand = "pwsh -NoProfile -ExecutionPolicy Bypass -File `"$verifyScriptPath`""

    $output = & pwsh -NoProfile -ExecutionPolicy Bypass -File "$repoRoot\ralph-loop.ps1" -Prompt 'Reply with a short completion marker.' -MaxIterations 1 -Agent $agent -VerifyCommand $verifyCommand -RunsRoot $runsRoot -CommandTimeoutSeconds 120 *>&1 | Out-String
    $exitCode = $LASTEXITCODE

    Assert-Equal '0' "$exitCode" "Real agent run for '$agent' should succeed."

    $runDir = Get-ChildItem -Path $runsRoot -Directory | Select-Object -First 1
    Assert-True ($null -ne $runDir) "Expected a run directory for '$agent'."
    Assert-True (Test-Path (Join-Path $runDir.FullName 'state.json')) "Expected state.json for '$agent'."
    Assert-True (Test-Path (Join-Path $runDir.FullName 'iter-001\prompt.txt')) "Expected prompt.txt for '$agent'."
    Assert-True (Test-Path (Join-Path $runDir.FullName 'iter-001\stdout.log')) "Expected stdout.log for '$agent'."
    Assert-True (Test-Path (Join-Path $runDir.FullName 'iter-001\last-message.txt')) "Expected last-message.txt for '$agent'."
    Assert-True ($output -match 'Loop finished after 1 iteration') "Expected one-iteration completion output for '$agent'."
}

Write-Output 'real agent tests completed'
