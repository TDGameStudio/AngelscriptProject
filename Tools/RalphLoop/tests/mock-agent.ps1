param()

$ErrorActionPreference = 'Stop'

$promptText = [Console]::In.ReadToEnd()
$iterationDir = $env:RALPH_LOOP_ITERATION_DIR

if (-not $iterationDir) {
    throw "RALPH_LOOP_ITERATION_DIR is required."
}

$snapshot = [ordered]@{
    iteration     = [int]$env:RALPH_LOOP_ITERATION
    agent         = $env:RALPH_LOOP_AGENT
    agentHome     = $env:RALPH_AGENT_HOME
    codexHome     = $env:CODEX_HOME
    opencodeConfigDir = $env:OPENCODE_CONFIG_DIR
    promptText    = $promptText
    prompt        = $env:RALPH_LOOP_PROMPT
    task          = $env:RALPH_LOOP_TASK
}

$json = $snapshot | ConvertTo-Json -Depth 4
$json | Set-Content -Path (Join-Path $iterationDir 'agent-snapshot.json') -Encoding UTF8

Write-Output "mock-agent iteration $($env:RALPH_LOOP_ITERATION)"
