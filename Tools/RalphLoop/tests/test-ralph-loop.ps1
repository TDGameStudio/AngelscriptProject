param()

$ErrorActionPreference = 'Stop'

. "$PSScriptRoot\test-helpers.ps1"

$repoRoot = Split-Path -Parent $PSScriptRoot
$tmpRoot = Join-Path $PSScriptRoot '.tmp\ralph-loop-smoke'

if (Test-Path $tmpRoot) {
    Remove-Item -Path $tmpRoot -Recurse -Force -ErrorAction SilentlyContinue
}

New-Item -ItemType Directory -Path $tmpRoot | Out-Null

$runsRootPs = Join-Path $tmpRoot 'runs-ps'
$runsRootBat = Join-Path $tmpRoot 'runs-bat'
$runsRootAgentPs = Join-Path $tmpRoot 'runs-agent-ps'
$runsRootAgentBat = Join-Path $tmpRoot 'runs-agent-bat'
$customCodeHome = Join-Path $tmpRoot 'custom-codex-home'
$batchCodeHome = Join-Path $tmpRoot 'batch-codex-home'
$explicitCodexHome = Join-Path $tmpRoot 'explicit-codex-home'
$customAgentHome = Join-Path $tmpRoot 'custom-agent-home'
$batchAgentHome = Join-Path $tmpRoot 'batch-agent-home'

$mockAgentCommand = "powershell -NoProfile -ExecutionPolicy Bypass -File $repoRoot\tests\mock-agent.ps1"
$mockProgressAgentCommand = "powershell -NoProfile -ExecutionPolicy Bypass -File $repoRoot\tests\mock-progress-agent.ps1"
$mockSlowAgentCommand = "powershell -NoProfile -ExecutionPolicy Bypass -File $repoRoot\tests\mock-slow-agent.ps1"
$verifyTwoPassesCommand = "powershell -NoProfile -ExecutionPolicy Bypass -File `"$repoRoot\tests\mock-verify.ps1`" -PassAfter 2"
$verifyOnePassCommand = "powershell -NoProfile -ExecutionPolicy Bypass -File `"$repoRoot\tests\mock-verify.ps1`" -PassAfter 1"

$psArgs = @(
    '-NoProfile'
    '-ExecutionPolicy'
    'Bypass'
    '-File'
    "$repoRoot\ralph-loop.ps1"
    '-Prompt'
    'ps smoke :: PS EXTRA'
    '-MaxIterations'
    '3'
    '-CodexCommand'
    $mockAgentCommand
    '-VerifyCommand'
    $verifyTwoPassesCommand
    '-RunsRoot'
    $runsRootPs
)

$psOutput = & powershell @psArgs *>&1 | Out-String
$psExitCode = $LASTEXITCODE

Assert-Equal '0' "$psExitCode" 'PowerShell loop command should succeed.'
Assert-True ($psOutput -match '================================================================') 'PowerShell loop should print a summary header block.'
Assert-True ($psOutput -match 'RalphLoop \(codex\) - starting') 'PowerShell loop should print the selected provider in the header.'
Assert-True ($psOutput -match 'Output dir\s+:\s+.*') 'PowerShell loop should print the output directory in the header.'
Assert-True ($psOutput -match 'Work dir\s+:\s+.*D:\\Workspace\\codexloop') 'PowerShell loop should print the working directory in the header.'
Assert-True ($psOutput -match 'Prompt tpl\s+:\s+.*prompts\\loop\.txt') 'PowerShell loop should print the prompt template path in the header.'
Assert-True ($psOutput -match 'Agent home\s+:\s+.*') 'PowerShell loop should print the agent home in the header.'
Assert-True ($psOutput -match 'Verify\s+:\s+configured') 'PowerShell loop should print whether verification is configured.'
Assert-True ($psOutput -match 'Max rounds\s+:\s+3') 'PowerShell loop should print max rounds in the header.'
Assert-True ($psOutput -match 'Stream raw\s+:\s+off') 'PowerShell loop should print the default output mode.'
Assert-True ($psOutput -match 'Timeout\s+:\s+off') 'PowerShell loop should print timeout status in the header.'
Assert-True ($psOutput -match '\[1/3\] codex prompt\s+:\s+.*prompt\.txt') 'PowerShell loop should print the prompt file path in compact form.'
Assert-True ($psOutput -match '\[1/3\] codex stdout\s+:\s+.*stdout\.log') 'PowerShell loop should print the stdout log path in compact form.'
Assert-True ($psOutput -match '\[1/3\] codex stderr\s+:\s+.*stderr\.log') 'PowerShell loop should print the stderr log path in compact form.'
Assert-True ($psOutput -match '\[1/3\] codex lastmsg\s+:\s+.*last-message\.txt') 'PowerShell loop should print the last-message file path in compact form.'
Assert-True ($psOutput -match '\[1/3\] codex running\.\.\. 00:00:00') 'PowerShell loop should print the compact running status with elapsed time.'
Assert-True ($psOutput -match '\[1/3\] codex verifying\.\.\.') 'PowerShell loop should print the compact verifying status.'
Assert-True ($psOutput -match '\[1/3\] codex completed\s+00:00:0[0-9]') 'PowerShell loop should print the compact completed status with elapsed time.'
Assert-True ($psOutput -notmatch '\[codex\] mock-agent iteration 1') 'PowerShell loop should hide raw agent output by default.'

$psRunDir = Get-ChildItem -Path $runsRootPs -Directory | Select-Object -First 1
Assert-True ($null -ne $psRunDir) 'Expected a PowerShell run directory.'

$psIterations = Get-ChildItem -Path $psRunDir.FullName -Directory -Filter 'iter-*' | Sort-Object Name
Assert-Equal '2' "$($psIterations.Count)" 'PowerShell loop should stop after verification succeeds.'

$psVerifyStdout = Get-Content -Raw -Path (Join-Path $psIterations[-1].FullName 'verify.stdout.log')
Assert-True ($psVerifyStdout -match 'verify-shell=') 'Verify stdout should record which PowerShell edition executed the stop hook.'
Assert-True ($psVerifyStdout -match 'stop-hook-shell=') 'Verify stdout should record which PowerShell edition executed the stop hook wrapper.'

if ($null -ne (Get-Command pwsh -ErrorAction SilentlyContinue)) {
    Assert-True ($psVerifyStdout -match 'stop-hook-shell=Core') 'When pwsh is available, the stop hook should run under PowerShell Core.'
}

$defaultCodeHome = Join-Path $HOME '.codex'
$psSnapshot = Get-Content -Raw -Path (Join-Path $psIterations[0].FullName 'agent-snapshot.json') | ConvertFrom-Json
Assert-Equal $defaultCodeHome $psSnapshot.codexHome 'Default CODEX_HOME should fall back to .codex-home.'
Assert-Equal 'ps smoke :: PS EXTRA' $psSnapshot.prompt 'Prompt environment should preserve the unified prompt.'
Assert-True ($psSnapshot.promptText -match 'ps smoke :: PS EXTRA') 'Rendered prompt should include the unified prompt.'

$runsRootCodexHomePs = Join-Path $tmpRoot 'runs-codex-home-ps'
$codexHomePsArgs = @(
    '-NoProfile'
    '-ExecutionPolicy'
    'Bypass'
    '-File'
    "$repoRoot\ralph-loop.ps1"
    '-Prompt'
    'codex home smoke'
    '-MaxIterations'
    '1'
    '-CodexCommand'
    $mockAgentCommand
    '-CodexHome'
    $explicitCodexHome
    '-VerifyCommand'
    $verifyOnePassCommand
    '-RunsRoot'
    $runsRootCodexHomePs
)

$codexHomePsOutput = & powershell @codexHomePsArgs *>&1 | Out-String
$codexHomePsExitCode = $LASTEXITCODE

Assert-Equal '0' "$codexHomePsExitCode" 'PowerShell loop should accept -CodexHome for codex runs.'

$codexHomePsRunDir = Get-ChildItem -Path $runsRootCodexHomePs -Directory | Select-Object -First 1
Assert-True ($null -ne $codexHomePsRunDir) 'Expected a codex-home PowerShell run directory.'

$codexHomePsSnapshot = Get-Content -Raw -Path (Join-Path $codexHomePsRunDir.FullName 'iter-001\agent-snapshot.json') | ConvertFrom-Json
Assert-Equal $explicitCodexHome $codexHomePsSnapshot.codexHome 'PowerShell loop should honor -CodexHome when provided.'

$providerPsArgs = @(
    '-NoProfile'
    '-ExecutionPolicy'
    'Bypass'
    '-File'
    "$repoRoot\ralph-loop.ps1"
    '-Prompt'
    'provider smoke :: AGENT EXTRA'
    '-MaxIterations'
    '2'
    '-Agent'
    'opencode'
    '-AgentCommand'
    $mockAgentCommand
    '-AgentHome'
    $customAgentHome
    '-VerifyCommand'
    $verifyOnePassCommand
    '-RunsRoot'
    $runsRootAgentPs
)

$providerPsOutput = & powershell @providerPsArgs *>&1 | Out-String
$providerPsExitCode = $LASTEXITCODE

Assert-Equal '0' "$providerPsExitCode" 'Provider-based PowerShell loop command should succeed.'
Assert-True ($providerPsOutput -match 'RalphLoop \(opencode\) - starting') 'Provider-based PowerShell loop should print the selected provider in the header.'
Assert-True ($providerPsOutput -match 'Verify\s+:\s+configured') 'Provider-based PowerShell loop should print verification mode in the header.'
Assert-True ($providerPsOutput -notmatch '\[opencode\] mock-agent iteration 1') 'Provider-based PowerShell loop should hide raw provider output by default.'

$providerPsRunDir = Get-ChildItem -Path $runsRootAgentPs -Directory | Select-Object -First 1
Assert-True ($null -ne $providerPsRunDir) 'Expected a provider PowerShell run directory.'

$providerPsIterations = Get-ChildItem -Path $providerPsRunDir.FullName -Directory -Filter 'iter-*' | Sort-Object Name
Assert-Equal '1' "$($providerPsIterations.Count)" 'Provider-based PowerShell loop should stop after verification succeeds.'

$providerPsSnapshot = Get-Content -Raw -Path (Join-Path $providerPsIterations[0].FullName 'agent-snapshot.json') | ConvertFrom-Json
Assert-Equal 'opencode' $providerPsSnapshot.agent 'Provider-based PowerShell loop should export the selected agent.'
Assert-Equal $customAgentHome $providerPsSnapshot.agentHome 'Provider-based PowerShell loop should export the generic agent home.'
Assert-True ($providerPsSnapshot.promptText -match 'AGENT_HOME:') 'Prompt should expose provider-neutral agent-home metadata.'
Assert-Equal 'provider smoke :: AGENT EXTRA' $providerPsSnapshot.prompt 'Provider-based PowerShell loop should export the unified prompt.'
Assert-True ($providerPsSnapshot.promptText -match 'provider smoke :: AGENT EXTRA') 'Provider-based PowerShell prompt should include the unified prompt.'

$env:RALPH_CODEX_COMMAND = $mockAgentCommand
$env:RALPH_VERIFY_COMMAND = $verifyOnePassCommand
$env:RALPH_RUNS_ROOT = $runsRootBat

$batArgs = @(
    '/c'
    "$repoRoot\run-ralph-loop.bat"
    '-Prompt'
    'bat smoke :: BAT EXTRA'
    '-MaxIterations'
    '4'
    '-AgentHome'
    $batchCodeHome
)

$batOutput = & cmd @batArgs *>&1 | Out-String
$batExitCode = $LASTEXITCODE

Remove-Item Env:RALPH_CODEX_COMMAND -ErrorAction SilentlyContinue
Remove-Item Env:RALPH_VERIFY_COMMAND -ErrorAction SilentlyContinue
Remove-Item Env:RALPH_RUNS_ROOT -ErrorAction SilentlyContinue

Assert-Equal '0' "$batExitCode" 'Batch loop command should succeed.'
Assert-True ($batOutput -match 'RalphLoop \(codex\) - starting') 'Batch wrapper should show the compact summary header.'
Assert-True ($batOutput -match 'Output dir\s+:\s+.*') 'Batch wrapper should show the output directory in the header.'
Assert-True ($batOutput -match '\[1/4\] codex running\.\.\. 00:00:00') 'Batch wrapper should show compact running progress.'
Assert-True ($batOutput -notmatch '\[codex\] mock-agent iteration 1') 'Batch wrapper should hide raw agent output by default.'

$batRunDir = Get-ChildItem -Path $runsRootBat -Directory | Select-Object -First 1
Assert-True ($null -ne $batRunDir) 'Expected a batch run directory.'

$batIterations = Get-ChildItem -Path $batRunDir.FullName -Directory -Filter 'iter-*' | Sort-Object Name
Assert-Equal '1' "$($batIterations.Count)" 'Batch wrapper should respect verify success.'

$batSnapshot = Get-Content -Raw -Path (Join-Path $batIterations[0].FullName 'agent-snapshot.json') | ConvertFrom-Json
Assert-Equal $batchCodeHome $batSnapshot.codexHome 'Batch wrapper should forward CODEX_HOME.'
Assert-Equal 'bat smoke :: BAT EXTRA' $batSnapshot.prompt 'Batch wrapper should forward the unified prompt.'
Assert-True ($batSnapshot.promptText -match 'bat smoke :: BAT EXTRA') 'Batch wrapper should render the unified prompt.'

$env:RALPH_VERIFY_COMMAND = $verifyOnePassCommand
$env:RALPH_RUNS_ROOT = $runsRootAgentBat

$providerBatArgs = @(
    '/c'
    "$repoRoot\run-ralph-loop.bat"
    '-Prompt'
    'provider bat smoke :: BATCH AGENT EXTRA'
    '-MaxIterations'
    '2'
    '-AgentHome'
    $batchAgentHome
    '-TimeoutSeconds'
    '0'
    '-Agent'
    'opencode'
    '-AgentCommand'
    $mockAgentCommand
)

$providerBatOutput = & cmd @providerBatArgs *>&1 | Out-String
$providerBatExitCode = $LASTEXITCODE

Remove-Item Env:RALPH_VERIFY_COMMAND -ErrorAction SilentlyContinue
Remove-Item Env:RALPH_RUNS_ROOT -ErrorAction SilentlyContinue

Assert-Equal '0' "$providerBatExitCode" 'Batch wrapper should support provider selection.'
Assert-True ($providerBatOutput -match 'RalphLoop \(opencode\) - starting') 'Batch wrapper should show the selected provider in the compact header.'
Assert-True ($providerBatOutput -match 'Agent home\s+:\s+.*') 'Batch wrapper should show the agent home in the header.'
Assert-True ($providerBatOutput -notmatch '\[opencode\] mock-agent iteration 1') 'Batch wrapper should hide raw provider output by default.'

$streamOutputRunsRoot = Join-Path $tmpRoot 'runs-stream-output'
$streamOutputArgs = @(
    '-NoProfile'
    '-ExecutionPolicy'
    'Bypass'
    '-File'
    "$repoRoot\ralph-loop.ps1"
    '-Prompt'
    'stream output smoke'
    '-MaxIterations'
    '1'
    '-CodexCommand'
    $mockAgentCommand
    '-VerifyCommand'
    $verifyOnePassCommand
    '-RunsRoot'
    $streamOutputRunsRoot
    '-StreamAgentOutput'
)

$streamOutputResult = & powershell @streamOutputArgs *>&1 | Out-String
$streamOutputExitCode = $LASTEXITCODE

Assert-Equal '0' "$streamOutputExitCode" 'Explicit stream-output mode should succeed.'
Assert-True ($streamOutputResult -match 'Stream raw\s+:\s+on') 'Explicit stream-output mode should show the enabled output mode in the header.'
Assert-True ($streamOutputResult -match '\[codex\] mock-agent iteration 1') 'Explicit stream-output mode should show raw agent output.'

$unicodeRunsRoot = Join-Path $tmpRoot 'runs-unicode'
$unicodePrompt = 'unicode smoke :: 中文输入'

if ($null -ne (Get-Command pwsh -ErrorAction SilentlyContinue)) {
    $unicodeAgentCommand = "pwsh -NoProfile -ExecutionPolicy Bypass -File $repoRoot\tests\mock-unicode-agent.ps1"
    $unicodeArgs = @(
        '-NoProfile'
        '-ExecutionPolicy'
        'Bypass'
        '-File'
        "$repoRoot\ralph-loop.ps1"
        '-Prompt'
        $unicodePrompt
        '-MaxIterations'
        '1'
        '-CodexCommand'
        $unicodeAgentCommand
        '-RunsRoot'
        $unicodeRunsRoot
    )
    $unicodeOutput = & pwsh @unicodeArgs *>&1 | Out-String
    $unicodeExitCode = $LASTEXITCODE

    Assert-Equal '0' "$unicodeExitCode" 'Unicode smoke run should succeed under pwsh.'

    $unicodeRunDir = Get-ChildItem -Path $unicodeRunsRoot -Directory | Select-Object -First 1
    Assert-True ($null -ne $unicodeRunDir) 'Expected a unicode run directory.'

    $unicodeSnapshot = Get-Content -Raw -Path (Join-Path $unicodeRunDir.FullName 'iter-001\agent-snapshot.json') | ConvertFrom-Json
    Assert-True ($unicodeSnapshot.promptFileContent -match [regex]::Escape($unicodePrompt)) 'Unicode prompt text should be preserved in prompt.txt.'

    $unicodeStderr = Get-Content -Raw -Path (Join-Path $unicodeRunDir.FullName 'iter-001\stderr.log')
    Assert-True ($unicodeStderr -match [regex]::Escape('unicode stderr :: 中文')) 'stderr.log should preserve UTF-8 unicode output.'
}

$tickerRunsRoot = Join-Path $tmpRoot 'runs-status-ticker'
$tickerArgs = @(
    '-NoProfile'
    '-ExecutionPolicy'
    'Bypass'
    '-File'
    "$repoRoot\ralph-loop.ps1"
    '-Prompt'
    'ticker smoke'
    '-MaxIterations'
    '1'
    '-CodexCommand'
    $mockProgressAgentCommand
    '-VerifyCommand'
    $verifyOnePassCommand
    '-RunsRoot'
    $tickerRunsRoot
)

$env:RALPH_FORCE_LINE_STATUS = '1'
$tickerOutput = & powershell @tickerArgs *>&1 | Out-String
$tickerExitCode = $LASTEXITCODE
Remove-Item Env:RALPH_FORCE_LINE_STATUS -ErrorAction SilentlyContinue

Assert-Equal '0' "$tickerExitCode" 'Status-only ticker mode should succeed.'
Assert-True ($tickerOutput -match '\[1/1\] codex running\.\.\. 00:00:00') 'Ticker mode should print the initial running status.'
Assert-True ($tickerOutput -match '\[1/1\] codex running\.\.\. 00:00:01') 'Ticker mode should refresh the running status while the agent is still running.'
Assert-True ($tickerOutput -match '\[1/1\] codex completed\s+00:00:0[2-9]') 'Ticker mode should print the completed status with the final elapsed time.'
Assert-True ($tickerOutput -notmatch 'progress-agent finished') 'Ticker mode should keep raw agent output hidden by default.'

$providerBatRunDir = Get-ChildItem -Path $runsRootAgentBat -Directory | Select-Object -First 1
Assert-True ($null -ne $providerBatRunDir) 'Expected a provider batch run directory.'

$providerBatIterations = Get-ChildItem -Path $providerBatRunDir.FullName -Directory -Filter 'iter-*' | Sort-Object Name
Assert-Equal '1' "$($providerBatIterations.Count)" 'Provider batch loop should stop after verification succeeds.'

$providerBatSnapshot = Get-Content -Raw -Path (Join-Path $providerBatIterations[0].FullName 'agent-snapshot.json') | ConvertFrom-Json
Assert-Equal 'opencode' $providerBatSnapshot.agent 'Batch wrapper should export the selected provider.'
Assert-Equal $batchAgentHome $providerBatSnapshot.agentHome 'Batch wrapper should forward the generic agent home.'
Assert-Equal 'provider bat smoke :: BATCH AGENT EXTRA' $providerBatSnapshot.prompt 'Provider batch wrapper should forward the unified prompt.'
Assert-True ($providerBatSnapshot.promptText -match 'provider bat smoke :: BATCH AGENT EXTRA') 'Provider batch prompt should include the unified prompt.'

$runsRootCodexWrapper = Join-Path $tmpRoot 'runs-codex-wrapper'
$env:RALPH_VERIFY_COMMAND = $verifyOnePassCommand
$env:RALPH_RUNS_ROOT = $runsRootCodexWrapper

$codexWrapperArgs = @(
    '/c'
    "$repoRoot\run-codex-loop.bat"
    '-Prompt'
    'codex wrapper smoke :: CODEX WRAPPER EXTRA'
    '-MaxIterations'
    '2'
    '-CodexHome'
    $batchCodeHome
    '-AgentCommand'
    $mockAgentCommand
)

$codexWrapperOutput = & cmd @codexWrapperArgs *>&1 | Out-String
$codexWrapperExitCode = $LASTEXITCODE

Remove-Item Env:RALPH_VERIFY_COMMAND -ErrorAction SilentlyContinue
Remove-Item Env:RALPH_RUNS_ROOT -ErrorAction SilentlyContinue

Assert-Equal '0' "$codexWrapperExitCode" 'run-codex-loop.bat should succeed.'
Assert-True ($codexWrapperOutput -match '\[run-codex-loop\.bat\] Provider: codex') 'run-codex-loop.bat should print its fixed provider.'
Assert-True ($codexWrapperOutput -notmatch '\[codex\] mock-agent iteration 1') 'run-codex-loop.bat should hide raw agent output by default.'

$codexWrapperRunDir = Get-ChildItem -Path $runsRootCodexWrapper -Directory | Select-Object -First 1
Assert-True ($null -ne $codexWrapperRunDir) 'Expected a codex wrapper run directory.'

$codexWrapperSnapshot = Get-Content -Raw -Path (Join-Path $codexWrapperRunDir.FullName 'iter-001\agent-snapshot.json') | ConvertFrom-Json
Assert-Equal 'codex' $codexWrapperSnapshot.agent 'run-codex-loop.bat should force the codex provider.'
Assert-Equal 'codex wrapper smoke :: CODEX WRAPPER EXTRA' $codexWrapperSnapshot.prompt 'run-codex-loop.bat should forward the unified prompt.'
Assert-True ($codexWrapperSnapshot.promptText -match 'codex wrapper smoke :: CODEX WRAPPER EXTRA') 'run-codex-loop.bat should render the unified prompt.'

$runsRootOpencodeWrapper = Join-Path $tmpRoot 'runs-opencode-wrapper'
$env:RALPH_VERIFY_COMMAND = $verifyOnePassCommand
$env:RALPH_RUNS_ROOT = $runsRootOpencodeWrapper

$opencodeWrapperArgs = @(
    '/c'
    "$repoRoot\run-opencode-loop.bat"
    '-Prompt'
    'opencode wrapper smoke :: OPENCODE WRAPPER EXTRA'
    '-MaxIterations'
    '2'
    '-AgentHome'
    $batchAgentHome
    '-AgentCommand'
    $mockAgentCommand
)

$opencodeWrapperOutput = & cmd @opencodeWrapperArgs *>&1 | Out-String
$opencodeWrapperExitCode = $LASTEXITCODE

Remove-Item Env:RALPH_VERIFY_COMMAND -ErrorAction SilentlyContinue
Remove-Item Env:RALPH_RUNS_ROOT -ErrorAction SilentlyContinue

Assert-Equal '0' "$opencodeWrapperExitCode" 'run-opencode-loop.bat should succeed.'
Assert-True ($opencodeWrapperOutput -match '\[run-opencode-loop\.bat\] Provider: opencode') 'run-opencode-loop.bat should print its fixed provider.'
Assert-True ($opencodeWrapperOutput -notmatch '\[opencode\] mock-agent iteration 1') 'run-opencode-loop.bat should hide raw provider output by default.'

$opencodeWrapperRunDir = Get-ChildItem -Path $runsRootOpencodeWrapper -Directory | Select-Object -First 1
Assert-True ($null -ne $opencodeWrapperRunDir) 'Expected an opencode wrapper run directory.'

$opencodeWrapperSnapshot = Get-Content -Raw -Path (Join-Path $opencodeWrapperRunDir.FullName 'iter-001\agent-snapshot.json') | ConvertFrom-Json
Assert-Equal 'opencode' $opencodeWrapperSnapshot.agent 'run-opencode-loop.bat should force the opencode provider.'
Assert-Equal 'opencode wrapper smoke :: OPENCODE WRAPPER EXTRA' $opencodeWrapperSnapshot.prompt 'run-opencode-loop.bat should forward the unified prompt.'
Assert-True ($opencodeWrapperSnapshot.promptText -match 'opencode wrapper smoke :: OPENCODE WRAPPER EXTRA') 'run-opencode-loop.bat should render the unified prompt.'

$timeoutRunsRoot = Join-Path $tmpRoot 'runs-timeout'
$env:RALPH_CODEX_COMMAND = $mockSlowAgentCommand
Remove-Item Env:RALPH_VERIFY_COMMAND -ErrorAction SilentlyContinue
$env:RALPH_RUNS_ROOT = $timeoutRunsRoot
$timeoutBatchCodeHome = Join-Path $tmpRoot 'timeout-codex-home'

$timeoutBatArgs = @(
    '/c'
    "$repoRoot\run-ralph-loop.bat"
    '-Prompt'
    'timeout smoke :: TIMEOUT EXTRA'
    '-MaxIterations'
    '2'
    '-AgentHome'
    $timeoutBatchCodeHome
    '-TimeoutSeconds'
    '1'
)

$timeoutOutput = & cmd @timeoutBatArgs *>&1 | Out-String
$timeoutExitCode = $LASTEXITCODE

Remove-Item Env:RALPH_CODEX_COMMAND -ErrorAction SilentlyContinue
Remove-Item Env:RALPH_VERIFY_COMMAND -ErrorAction SilentlyContinue
Remove-Item Env:RALPH_RUNS_ROOT -ErrorAction SilentlyContinue

Assert-Equal '124' "$timeoutExitCode" 'Batch wrapper should forward timeout seconds and stop a hanging command.'
Assert-True ($timeoutOutput -match 'Timeout\s+:\s+1 second\(s\)') 'Timeout run should print the timeout configuration.'

$timeoutRunDir = Get-ChildItem -Path $timeoutRunsRoot -Directory | Select-Object -First 1
Assert-True ($null -ne $timeoutRunDir) 'Expected a timeout run directory.'

$timeoutStdout = [string](Get-Content -Raw -Path (Join-Path $timeoutRunDir.FullName 'iter-001\stdout.log'))
Assert-True (-not ($timeoutStdout -match 'slow-agent finished')) 'Timed-out agent should be terminated before writing completion output.'

Write-Output 'ralph-loop smoke tests passed'
