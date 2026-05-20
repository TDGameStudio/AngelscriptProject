param()

$ErrorActionPreference = 'Stop'

$iterationDir = $env:RALPH_LOOP_ITERATION_DIR
$promptFile = $env:RALPH_LOOP_PROMPT_FILE

if (-not $iterationDir) {
    throw "RALPH_LOOP_ITERATION_DIR is required."
}

if (-not $promptFile) {
    throw "RALPH_LOOP_PROMPT_FILE is required."
}

$snapshot = [ordered]@{
    promptFileContent = Get-Content -Raw -Path $promptFile
}

$snapshot | ConvertTo-Json -Depth 2 | Set-Content -Path (Join-Path $iterationDir 'agent-snapshot.json') -Encoding UTF8

$stderrStream = [Console]::OpenStandardError()
$stderrWriter = New-Object System.IO.StreamWriter($stderrStream, (New-Object System.Text.UTF8Encoding($false)))
$stderrWriter.AutoFlush = $true
$stderrWriter.WriteLine("unicode stderr :: $([char]0x4E2D)$([char]0x6587)")
$stderrWriter.Dispose()
