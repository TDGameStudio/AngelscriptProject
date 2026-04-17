param()

$ErrorActionPreference = 'Stop'

. "$PSScriptRoot\test-helpers.ps1"

$repoRoot = Split-Path -Parent $PSScriptRoot
$tmpRoot = Join-Path $PSScriptRoot '.tmp\ralph-loop-no-verify'

if (Test-Path $tmpRoot) {
    Remove-Item -Path $tmpRoot -Recurse -Force -ErrorAction SilentlyContinue
}

New-Item -ItemType Directory -Path $tmpRoot | Out-Null

$runsRoot = Join-Path $tmpRoot 'runs'
$mockAgentCommand = "powershell -NoProfile -ExecutionPolicy Bypass -File $repoRoot\tests\mock-agent.ps1"

$args = @(
    '-NoProfile'
    '-ExecutionPolicy'
    'Bypass'
    '-File'
    "$repoRoot\ralph-loop.ps1"
    '-Prompt'
    'no verify smoke :: NO VERIFY EXTRA'
    '-MaxIterations'
    '1'
    '-CodexCommand'
    $mockAgentCommand
    '-RunsRoot'
    $runsRoot
)

$previousErrorActionPreference = $ErrorActionPreference
$ErrorActionPreference = 'Continue'
$output = & powershell @args *>&1 | Out-String
$exitCode = $LASTEXITCODE
$ErrorActionPreference = $previousErrorActionPreference

Assert-Equal '0' "$exitCode" 'Loop should succeed when verification is disabled.'
Assert-True ($output -match 'Verify\s+:\s+disabled') 'Loop should print disabled verification mode when VerifyCommand is omitted.'
Assert-True ($output -notmatch '\[1/1\] codex verifying\.\.\.') 'Loop should skip the verifying status when verification is disabled.'
Assert-True ($output -notmatch 'Missing an argument for parameter') 'Loop should not invoke stop-hook with a missing VerifyCommand argument.'
Assert-True ($output -match '\[1/1\] codex max-rounds-reached') 'Loop should reach the max-rounds state without verification.'

$runDir = Get-ChildItem -Path $runsRoot -Directory | Select-Object -First 1
Assert-True ($null -ne $runDir) 'Expected a run directory when verification is disabled.'
Assert-True (Test-Path (Join-Path $runDir.FullName 'iter-001\stdout.log')) 'Expected stdout.log for the no-verify run.'
Assert-True (Test-Path (Join-Path $runDir.FullName 'iter-001\stderr.log')) 'Expected stderr.log for the no-verify run.'
Assert-True (-not (Test-Path (Join-Path $runDir.FullName 'iter-001\verify.stdout.log'))) 'Disabled verification should not emit verify stdout logs.'
Assert-True (-not (Test-Path (Join-Path $runDir.FullName 'iter-001\verify.stderr.log'))) 'Disabled verification should not emit verify stderr logs.'

Write-Output 'ralph-loop no-verify regression passed'
