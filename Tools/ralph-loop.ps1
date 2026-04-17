param(
    [Parameter(Mandatory = $true)]
    [Alias('Task')]
    [string]$Prompt,

    [int]$MaxIterations = 5,

    [Alias('CodeHome')]
    [string]$AgentHome,

    [string]$CodexHome,

    [string]$PromptFile,

    [Alias('CodexCommand')]
    [string]$AgentCommand,

    [string]$Agent,

    [string]$VerifyCommand,

    [string]$RunsRoot,

    [int]$CommandTimeoutSeconds = 0,

    [switch]$StreamAgentOutput
)

$ErrorActionPreference = 'Stop'
$Task = $Prompt

function Resolve-FullPath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,

        [Parameter(Mandatory = $true)]
        [string]$BaseDirectory
    )

    if ([System.IO.Path]::IsPathRooted($Path)) {
        return [System.IO.Path]::GetFullPath($Path)
    }

    return [System.IO.Path]::GetFullPath((Join-Path $BaseDirectory $Path))
}

function Expand-TemplateString {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Template,

        [Parameter(Mandatory = $true)]
        [hashtable]$Values
    )

    $expanded = $Template

    foreach ($key in $Values.Keys) {
        $expanded = $expanded.Replace("{$key}", [string]$Values[$key])
    }

    return $expanded
}

function Get-AgentProfiles {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ScriptRoot
    )

    $profilesPath = Join-Path $ScriptRoot 'agents\profiles.psd1'
    if (-not (Test-Path $profilesPath)) {
        throw "Agent profiles not found: $profilesPath"
    }

    return Import-PowerShellDataFile -Path $profilesPath
}

function Get-AgentProfile {
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$Profiles,

        [string]$ExplicitAgent
    )

    $selectedAgent = if (-not [string]::IsNullOrWhiteSpace($ExplicitAgent)) {
        $ExplicitAgent
    } elseif (-not [string]::IsNullOrWhiteSpace($env:RALPH_AGENT)) {
        $env:RALPH_AGENT
    } else {
        $Profiles.DefaultAgent
    }

    if (-not $Profiles.Agents.ContainsKey($selectedAgent)) {
        throw "Unknown agent profile '$selectedAgent'. Available profiles: $($Profiles.Agents.Keys -join ', ')"
    }

    return [pscustomobject]$Profiles.Agents[$selectedAgent]
}

function Resolve-AgentHomePath {
    param(
        [Parameter(Mandatory = $true)]
        [pscustomobject]$Profile,

        [Parameter(Mandatory = $true)]
        [string]$Workspace,

        [string]$ExplicitAgentHome,

        [string]$ExplicitCodexHome
    )

    if (-not [string]::IsNullOrWhiteSpace($ExplicitAgentHome)) {
        return Resolve-FullPath -Path $ExplicitAgentHome -BaseDirectory $Workspace
    }

    if (($Profile.Id -eq 'codex') -and (-not [string]::IsNullOrWhiteSpace($ExplicitCodexHome))) {
        return Resolve-FullPath -Path $ExplicitCodexHome -BaseDirectory $Workspace
    }

    if (-not [string]::IsNullOrWhiteSpace($env:RALPH_AGENT_HOME)) {
        return Resolve-FullPath -Path $env:RALPH_AGENT_HOME -BaseDirectory $Workspace
    }

    if (-not [string]::IsNullOrWhiteSpace($env:AGENT_HOME)) {
        return Resolve-FullPath -Path $env:AGENT_HOME -BaseDirectory $Workspace
    }

    if (-not [string]::IsNullOrWhiteSpace($Profile.HomeEnvVar)) {
        $providerHome = [Environment]::GetEnvironmentVariable($Profile.HomeEnvVar)
        if (-not [string]::IsNullOrWhiteSpace($providerHome)) {
            return Resolve-FullPath -Path $providerHome -BaseDirectory $Workspace
        }
    }

    return Join-Path $HOME $Profile.DefaultHomePath
}

function Get-PreferredPowerShellExe {
    $pwshCommand = Get-Command pwsh -ErrorAction SilentlyContinue
    if ($null -ne $pwshCommand) {
        return $pwshCommand.Source
    }

    $powershellCommand = Get-Command powershell -ErrorAction SilentlyContinue
    if ($null -ne $powershellCommand) {
        return $powershellCommand.Source
    }

    throw 'Neither pwsh nor powershell is available for stop-hook execution.'
}

function Format-ElapsedTime {
    param(
        [Parameter(Mandatory = $true)]
        [TimeSpan]$Elapsed
    )

    return [string]::Format('{0:00}:{1:00}:{2:00}', [int]$Elapsed.TotalHours, $Elapsed.Minutes, $Elapsed.Seconds)
}

function Write-SectionDivider {
    Write-Output '================================================================'
}

function Write-RunHeader {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Agent,

        [Parameter(Mandatory = $true)]
        [string]$RunDirectory,

        [Parameter(Mandatory = $true)]
        [string]$Workspace,

        [Parameter(Mandatory = $true)]
        [string]$PromptTemplatePath,

        [Parameter(Mandatory = $true)]
        [string]$AgentHome,

        [Parameter(Mandatory = $true)]
        [bool]$HasVerifyCommand,

        [Parameter(Mandatory = $true)]
        [int]$MaxIterations,

        [Parameter(Mandatory = $true)]
        [bool]$StreamAgentOutput,

        [int]$TimeoutSeconds
    )

    Write-SectionDivider
    Write-Output "  RalphLoop ($Agent) - starting"
    Write-Output "  Output dir : $RunDirectory"
    Write-Output "  Work dir   : $Workspace"
    Write-Output "  Prompt tpl : $PromptTemplatePath"
    Write-Output "  Agent home : $AgentHome"
    Write-Output "  Verify     : $(if ($HasVerifyCommand) { 'configured' } else { 'disabled' })"
    Write-Output "  Max rounds : $MaxIterations"
    Write-Output "  Stream raw : $(if ($StreamAgentOutput) { 'on' } else { 'off' })"
    Write-Output "  Timeout    : $(if ($TimeoutSeconds -gt 0) { "$TimeoutSeconds second(s)" } else { 'off' })"
    Write-SectionDivider
}

function Write-IterationArtifacts {
    param(
        [Parameter(Mandatory = $true)]
        [int]$Iteration,

        [Parameter(Mandatory = $true)]
        [int]$MaxIterations,

        [Parameter(Mandatory = $true)]
        [string]$Agent,

        [Parameter(Mandatory = $true)]
        [string]$PromptFilePath,

        [Parameter(Mandatory = $true)]
        [string]$StdoutLogFile,

        [Parameter(Mandatory = $true)]
        [string]$StderrLogFile,

        [Parameter(Mandatory = $true)]
        [string]$LastMessageFile
    )

    Write-Output "  [$Iteration/$MaxIterations] $Agent prompt  : $PromptFilePath"
    Write-Output "  [$Iteration/$MaxIterations] $Agent stdout  : $StdoutLogFile"
    Write-Output "  [$Iteration/$MaxIterations] $Agent stderr  : $StderrLogFile"
    Write-Output "  [$Iteration/$MaxIterations] $Agent lastmsg : $LastMessageFile"
}

function Write-AgentStatusLine {
    param(
        [Parameter(Mandatory = $true)]
        [int]$Iteration,

        [Parameter(Mandatory = $true)]
        [int]$MaxIterations,

        [Parameter(Mandatory = $true)]
        [string]$Agent,

        [Parameter(Mandatory = $true)]
        [string]$Status,

        [TimeSpan]$Elapsed
    )

    if ($PSBoundParameters.ContainsKey('Elapsed')) {
        Write-Output "  [$Iteration/$MaxIterations] $Agent $Status $(Format-ElapsedTime -Elapsed $Elapsed)"
    } else {
        Write-Output "  [$Iteration/$MaxIterations] $Agent $Status"
    }
}

function Write-AgentStatusLineInteractive {
    param(
        [Parameter(Mandatory = $true)]
        [int]$Iteration,

        [Parameter(Mandatory = $true)]
        [int]$MaxIterations,

        [Parameter(Mandatory = $true)]
        [string]$Agent,

        [Parameter(Mandatory = $true)]
        [string]$Status,

        [TimeSpan]$Elapsed,

        [switch]$Finalize,

        [bool]$ForceLineOutput = $false
    )

    $line = if ($PSBoundParameters.ContainsKey('Elapsed')) {
        "  [$Iteration/$MaxIterations] $Agent $Status $(Format-ElapsedTime -Elapsed $Elapsed)"
    } else {
        "  [$Iteration/$MaxIterations] $Agent $Status"
    }

    $supportsInteractiveRefresh = (-not $ForceLineOutput) -and (-not [Console]::IsOutputRedirected)

    if (-not $supportsInteractiveRefresh) {
        [Console]::Out.WriteLine($line)
        return
    }

    if (-not (Get-Variable -Name RalphLastStatusLength -Scope Script -ErrorAction SilentlyContinue)) {
        $script:RalphLastStatusLength = 0
    }

    $paddingLength = [Math]::Max(0, $script:RalphLastStatusLength - $line.Length)
    $padding = if ($paddingLength -gt 0) { ' ' * $paddingLength } else { '' }
    [Console]::Out.Write("`r$line$padding")
    $script:RalphLastStatusLength = $line.Length

    if ($Finalize) {
        [Console]::Out.WriteLine()
        $script:RalphLastStatusLength = 0
    }
}

function Invoke-LoggedCommand {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Command,

        [Parameter(Mandatory = $true)]
        [string]$WorkingDirectory,

        [Parameter(Mandatory = $true)]
        [string]$StdOutFile,

        [Parameter(Mandatory = $true)]
        [string]$StdErrFile,

        [string]$StdinText,

        [hashtable]$EnvironmentMap = @{},

        [int]$TimeoutSeconds = 0,

        [string]$ConsolePrefix = '',

        [bool]$EmitConsoleOutput = $true,

        [scriptblock]$OnRunningTick
    )

    $startInfo = New-Object System.Diagnostics.ProcessStartInfo
    $startInfo.FileName = 'cmd.exe'
    $startInfo.Arguments = "/d /s /c `"$Command`""
    $startInfo.WorkingDirectory = $WorkingDirectory
    $startInfo.UseShellExecute = $false
    $startInfo.RedirectStandardInput = $true
    $startInfo.RedirectStandardOutput = $true
    $startInfo.RedirectStandardError = $true
    $startInfo.CreateNoWindow = $true

    foreach ($entry in $EnvironmentMap.GetEnumerator()) {
        $startInfo.EnvironmentVariables[$entry.Key] = [string]$entry.Value
    }

    $stdoutWriter = New-Object System.IO.StreamWriter($StdOutFile, $false, (New-Object System.Text.UTF8Encoding($false)))
    $stderrWriter = New-Object System.IO.StreamWriter($StdErrFile, $false, (New-Object System.Text.UTF8Encoding($false)))
    $stdoutWriter.AutoFlush = $true
    $stderrWriter.AutoFlush = $true
    $stdoutBuffer = New-Object System.Text.StringBuilder
    $stderrBuffer = New-Object System.Text.StringBuilder

    $process = New-Object System.Diagnostics.Process
    $process.StartInfo = $startInfo
    [void]$process.Start()

    $stdoutSubscription = Register-ObjectEvent -InputObject $process -EventName OutputDataReceived -MessageData @{
        Writer  = $stdoutWriter
        Buffer  = $stdoutBuffer
        Prefix  = $ConsolePrefix
        Emit    = $EmitConsoleOutput
    } -Action {
        if ($EventArgs.Data -ne $null) {
            $state = $Event.MessageData
            $state.Writer.WriteLine($EventArgs.Data)
            [void]$state.Buffer.AppendLine($EventArgs.Data)
            if ($state.Emit) {
                [Console]::Out.WriteLine("$($state.Prefix)$($EventArgs.Data)")
            }
        }
    }

    $stderrSubscription = Register-ObjectEvent -InputObject $process -EventName ErrorDataReceived -MessageData @{
        Writer  = $stderrWriter
        Buffer  = $stderrBuffer
        Prefix  = $ConsolePrefix
        Emit    = $EmitConsoleOutput
    } -Action {
        if ($EventArgs.Data -ne $null) {
            $state = $Event.MessageData
            $state.Writer.WriteLine($EventArgs.Data)
            [void]$state.Buffer.AppendLine($EventArgs.Data)
            if ($state.Emit) {
                [Console]::Error.WriteLine("$($state.Prefix)$($EventArgs.Data)")
            }
        }
    }

    $process.BeginOutputReadLine()
    $process.BeginErrorReadLine()

    if ($null -ne $StdinText) {
        $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
        $stdinBytes = $utf8NoBom.GetBytes($StdinText)
        $process.StandardInput.BaseStream.Write($stdinBytes, 0, $stdinBytes.Length)
    }

    $process.StandardInput.Close()

    $timedOut = $false
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    $lastTickSecond = -1

    while (-not $process.HasExited) {
        if ($process.WaitForExit(250)) {
            break
        }

        if ($null -ne $OnRunningTick) {
            $elapsedSecond = [int]$stopwatch.Elapsed.TotalSeconds
            if ($elapsedSecond -ne $lastTickSecond) {
                & $OnRunningTick $stopwatch.Elapsed
                $lastTickSecond = $elapsedSecond
            }
        }

        if (($TimeoutSeconds -gt 0) -and ($stopwatch.Elapsed.TotalSeconds -ge $TimeoutSeconds)) {
            $timedOut = $true
            Stop-ProcessTree -Process $process
            $process.WaitForExit()
            $timeoutMessage = "Process timed out after $TimeoutSeconds second(s)."
            $stderrWriter.WriteLine($timeoutMessage)
            [void]$stderrBuffer.AppendLine($timeoutMessage)
            if ($EmitConsoleOutput) {
                [Console]::Error.WriteLine("$ConsolePrefix$timeoutMessage")
            }
            break
        }
    }

    $stopwatch.Stop()

    $process.WaitForExit()
    $process.CancelOutputRead()
    $process.CancelErrorRead()
    Wait-Event -SourceIdentifier $stdoutSubscription.Name -Timeout 1 -ErrorAction SilentlyContinue | Out-Null
    Wait-Event -SourceIdentifier $stderrSubscription.Name -Timeout 1 -ErrorAction SilentlyContinue | Out-Null
    Unregister-Event -SourceIdentifier $stdoutSubscription.Name -ErrorAction SilentlyContinue
    Unregister-Event -SourceIdentifier $stderrSubscription.Name -ErrorAction SilentlyContinue
    Remove-Job -Id $stdoutSubscription.Id -Force -ErrorAction SilentlyContinue
    Remove-Job -Id $stderrSubscription.Id -Force -ErrorAction SilentlyContinue
    $stdoutWriter.Dispose()
    $stderrWriter.Dispose()

    $stdout = $stdoutBuffer.ToString()
    $stderr = $stderrBuffer.ToString()
    $exitCode = if ($timedOut) { 124 } else { $process.ExitCode }

    return [pscustomobject]@{
        ExitCode = $exitCode
        StdOut   = $stdout
        StdErr   = $stderr
        TimedOut = $timedOut
        Elapsed  = $stopwatch.Elapsed
    }
}

function Stop-ProcessTree {
    param(
        [Parameter(Mandatory = $true)]
        [System.Diagnostics.Process]$Process
    )

    try {
        $killTreeMethod = $Process.GetType().GetMethod('Kill', [type[]]@([bool]))
        if ($null -ne $killTreeMethod) {
            $Process.Kill($true)
            return
        }
    } catch {
    }

    try {
        & taskkill.exe /F /T /PID $Process.Id *> $null
        return
    } catch {
    }

    try {
        $Process.Kill()
    } catch {
    }
}

function Get-PreviousSummary {
    param(
        [Parameter(Mandatory = $true)]
        [string]$IterationDirectory
    )

    $lastMessageFile = Join-Path $IterationDirectory 'last-message.txt'
    if (Test-Path $lastMessageFile) {
        return (Get-Content -Raw -Path $lastMessageFile).Trim()
    }

    $stdoutFile = Join-Path $IterationDirectory 'stdout.log'
    if (Test-Path $stdoutFile) {
        $tailLines = Get-Content -Path $stdoutFile | Select-Object -Last 20
        return ($tailLines -join [Environment]::NewLine).Trim()
    }

    return 'No previous iteration summary is available.'
}

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$workspace = (Get-Location).Path
$profiles = Get-AgentProfiles -ScriptRoot $scriptRoot
$selectedProfile = Get-AgentProfile -Profiles $profiles -ExplicitAgent $Agent
$preferredPowerShellExe = Get-PreferredPowerShellExe
$forceLineStatusOutput = $env:RALPH_FORCE_LINE_STATUS -in @('1', 'true', 'TRUE', 'yes', 'YES')

if ([string]::IsNullOrWhiteSpace($Agent)) {
    $Agent = $selectedProfile.Id
}

if ([string]::IsNullOrWhiteSpace($PromptFile)) {
    $PromptFile = if ($env:RALPH_PROMPT_FILE) { $env:RALPH_PROMPT_FILE } else { Join-Path $scriptRoot 'prompts\loop.txt' }
}

if ([string]::IsNullOrWhiteSpace($AgentCommand)) {
    $AgentCommand = if ($env:RALPH_AGENT_COMMAND) {
        $env:RALPH_AGENT_COMMAND
    } elseif ($env:RALPH_CODEX_COMMAND) {
        $env:RALPH_CODEX_COMMAND
    } else {
        $selectedProfile.CommandTemplate
    }
}

$usesCustomAgentCommand = $PSBoundParameters.ContainsKey('AgentCommand') -or
    (-not [string]::IsNullOrWhiteSpace($env:RALPH_AGENT_COMMAND)) -or
    (-not [string]::IsNullOrWhiteSpace($env:RALPH_CODEX_COMMAND))

$effectivePromptTransport = if ($usesCustomAgentCommand) {
    'stdin'
} else {
    $selectedProfile.PromptTransport
}

if ([string]::IsNullOrWhiteSpace($VerifyCommand) -and $env:RALPH_VERIFY_COMMAND) {
    $VerifyCommand = $env:RALPH_VERIFY_COMMAND
}

if ([string]::IsNullOrWhiteSpace($RunsRoot)) {
    $RunsRoot = if ($env:RALPH_RUNS_ROOT) { $env:RALPH_RUNS_ROOT } else { Join-Path $scriptRoot '.codexloop\runs' }
}

if (($CommandTimeoutSeconds -le 0) -and $env:RALPH_COMMAND_TIMEOUT_SECONDS) {
    $CommandTimeoutSeconds = [int]$env:RALPH_COMMAND_TIMEOUT_SECONDS
}

$resolvedPromptFile = Resolve-FullPath -Path $PromptFile -BaseDirectory $workspace
$resolvedRunsRoot = Resolve-FullPath -Path $RunsRoot -BaseDirectory $workspace
$resolvedAgentHome = Resolve-AgentHomePath -Profile $selectedProfile -Workspace $workspace -ExplicitAgentHome $AgentHome -ExplicitCodexHome $CodexHome

if (-not (Test-Path $resolvedPromptFile)) {
    throw "Prompt template not found: $resolvedPromptFile"
}

New-Item -ItemType Directory -Path $resolvedRunsRoot -Force | Out-Null
New-Item -ItemType Directory -Path $resolvedAgentHome -Force | Out-Null

$runStamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$runDirectory = Join-Path $resolvedRunsRoot "$runStamp-$PID"
New-Item -ItemType Directory -Path $runDirectory -Force | Out-Null

$templateText = Get-Content -Raw -Path $resolvedPromptFile
$previousSummary = 'No previous iteration summary is available.'

$runMetadata = [ordered]@{
    prompt        = $Prompt
    task          = $Prompt
    agent         = $Agent
    maxIterations = $MaxIterations
    agentHome     = $resolvedAgentHome
    codeHome      = $resolvedAgentHome
    promptFile    = $resolvedPromptFile
    runsRoot      = $resolvedRunsRoot
    agentCommand  = $AgentCommand
    codexCommand  = $AgentCommand
    verifyCommand = $VerifyCommand
    workspace     = $workspace
} | ConvertTo-Json -Depth 4

Set-Content -Path (Join-Path $runDirectory 'run.json') -Value $runMetadata -Encoding UTF8

Write-RunHeader -Agent $Agent -RunDirectory $runDirectory -Workspace $workspace -PromptTemplatePath $resolvedPromptFile -AgentHome $resolvedAgentHome -HasVerifyCommand (-not [string]::IsNullOrWhiteSpace($VerifyCommand)) -MaxIterations $MaxIterations -StreamAgentOutput $StreamAgentOutput.IsPresent -TimeoutSeconds $CommandTimeoutSeconds

for ($iteration = 1; $iteration -le $MaxIterations; $iteration++) {
    $iterationName = 'iter-{0:d3}' -f $iteration
    $iterationDirectory = Join-Path $runDirectory $iterationName
    New-Item -ItemType Directory -Path $iterationDirectory -Force | Out-Null
    $lastMessageFile = Join-Path $iterationDirectory 'last-message.txt'
    $stdoutLogFile = Join-Path $iterationDirectory 'stdout.log'
    $stderrLogFile = Join-Path $iterationDirectory 'stderr.log'
    $values = @{
        PROMPT            = $Prompt
        TASK              = $Prompt
        AGENT             = $Agent
        MAX_ITERATIONS    = $MaxIterations
        ITERATION         = $iteration
        WORKSPACE         = $workspace
        RUN_DIR           = $runDirectory
        ITERATION_DIR     = $iterationDirectory
        AGENT_HOME        = $resolvedAgentHome
        CODEX_HOME        = $resolvedAgentHome
        PREVIOUS_SUMMARY  = $previousSummary
    }

    $renderedPrompt = Expand-TemplateString -Template $templateText -Values $values
    $promptFilePath = Join-Path $iterationDirectory 'prompt.txt'
    Set-Content -Path $promptFilePath -Value $renderedPrompt -Encoding UTF8
    Write-IterationArtifacts -Iteration $iteration -MaxIterations $MaxIterations -Agent $Agent -PromptFilePath $promptFilePath -StdoutLogFile $stdoutLogFile -StderrLogFile $stderrLogFile -LastMessageFile $lastMessageFile

    $commandValues = @{
        WORKSPACE         = $workspace
        RUN_DIR           = $runDirectory
        ITERATION_DIR     = $iterationDirectory
        ITERATION         = $iteration
        PROMPT_FILE       = $promptFilePath
        LAST_MESSAGE_FILE = $lastMessageFile
    }

    $expandedCommand = Expand-TemplateString -Template $AgentCommand -Values $commandValues
    $environmentMap = @{
        AGENT_HOME               = $resolvedAgentHome
        RALPH_AGENT_HOME         = $resolvedAgentHome
        RALPH_LOOP_PROMPT        = $Prompt
        RALPH_LOOP_TASK          = $Task
        RALPH_LOOP_AGENT         = $Agent
        RALPH_LOOP_RUN_DIR       = $runDirectory
        RALPH_LOOP_ITERATION_DIR = $iterationDirectory
        RALPH_LOOP_ITERATION     = $iteration
        RALPH_LOOP_PROMPT_FILE   = $promptFilePath
    }

    if (-not [string]::IsNullOrWhiteSpace($selectedProfile.HomeEnvVar)) {
        $environmentMap[$selectedProfile.HomeEnvVar] = $resolvedAgentHome
    }

    foreach ($entry in $environmentMap.GetEnumerator()) {
        Set-Item -Path "Env:$($entry.Key)" -Value ([string]$entry.Value)
    }

    Write-AgentStatusLineInteractive -Iteration $iteration -MaxIterations $MaxIterations -Agent $Agent -Status 'running...' -Elapsed ([TimeSpan]::Zero) -ForceLineOutput $StreamAgentOutput.IsPresent
    $commandResult = Invoke-LoggedCommand `
        -Command $expandedCommand `
        -WorkingDirectory $workspace `
        -StdOutFile $stdoutLogFile `
        -StdErrFile $stderrLogFile `
        -StdinText $(if ($effectivePromptTransport -eq 'stdin') { $renderedPrompt } else { $null }) `
        -EnvironmentMap $environmentMap `
        -TimeoutSeconds $CommandTimeoutSeconds `
        -ConsolePrefix $selectedProfile.ConsolePrefix `
        -EmitConsoleOutput $StreamAgentOutput.IsPresent `
        -OnRunningTick $(if ($StreamAgentOutput.IsPresent) { $null } else { { param($elapsed) if ($elapsed.TotalSeconds -ge 1) { Write-AgentStatusLineInteractive -Iteration $iteration -MaxIterations $MaxIterations -Agent $Agent -Status 'running...' -Elapsed $elapsed -ForceLineOutput $forceLineStatusOutput } } })

    $elapsedText = Format-ElapsedTime -Elapsed $commandResult.Elapsed

    if ($commandResult.TimedOut) {
        Write-AgentStatusLineInteractive -Iteration $iteration -MaxIterations $MaxIterations -Agent $Agent -Status 'timed-out' -Elapsed $commandResult.Elapsed -Finalize -ForceLineOutput ($StreamAgentOutput.IsPresent -or $forceLineStatusOutput)
    } elseif ($commandResult.ExitCode -eq 0) {
        Write-AgentStatusLineInteractive -Iteration $iteration -MaxIterations $MaxIterations -Agent $Agent -Status 'completed ' -Elapsed $commandResult.Elapsed -Finalize -ForceLineOutput ($StreamAgentOutput.IsPresent -or $forceLineStatusOutput)
    } else {
        Write-AgentStatusLineInteractive -Iteration $iteration -MaxIterations $MaxIterations -Agent $Agent -Status 'failed    ' -Elapsed $commandResult.Elapsed -Finalize -ForceLineOutput ($StreamAgentOutput.IsPresent -or $forceLineStatusOutput)
    }

    if (-not (Test-Path $lastMessageFile)) {
        $summaryText = if (-not [string]::IsNullOrWhiteSpace($commandResult.StdOut)) {
            $commandResult.StdOut.Trim()
        } elseif (-not [string]::IsNullOrWhiteSpace($commandResult.StdErr)) {
            $commandResult.StdErr.Trim()
        } else {
            ''
        }

        if (-not [string]::IsNullOrWhiteSpace($summaryText)) {
            Set-Content -Path $lastMessageFile -Value $summaryText -Encoding UTF8
        }
    }

    if ($commandResult.ExitCode -ne 0) {
        [Console]::Error.WriteLine("Loop command failed on iteration $iteration with exit code $($commandResult.ExitCode). See $iterationDirectory.")
        exit $commandResult.ExitCode
    }

    $stopHookPath = Join-Path $scriptRoot 'stop-hook.ps1'
    $stopHookArgs = @(
        '-NoProfile'
        '-ExecutionPolicy'
        'Bypass'
        '-File'
        $stopHookPath
        '-VerifyCommand'
        $VerifyCommand
        '-WorkingDirectory'
        $workspace
        '-RunDir'
        $runDirectory
        '-IterationDir'
        $iterationDirectory
        '-Iteration'
        "$iteration"
    )

    Write-AgentStatusLine -Iteration $iteration -MaxIterations $MaxIterations -Agent $Agent -Status 'verifying...'
    & $preferredPowerShellExe @stopHookArgs
    $stopHookExitCode = $LASTEXITCODE

    if ($stopHookExitCode -eq 0) {
        $state = [ordered]@{
            stopped       = $true
            agent         = $Agent
            iteration     = $iteration
            reason        = 'verification-passed'
            runDirectory  = $runDirectory
            agentHome     = $resolvedAgentHome
            codeHome      = $resolvedAgentHome
        } | ConvertTo-Json -Depth 4

        Set-Content -Path (Join-Path $runDirectory 'state.json') -Value $state -Encoding UTF8
        Write-Output "Loop finished after $iteration iteration(s). Run directory: $runDirectory"
        exit 0
    }

    if ($stopHookExitCode -gt 1) {
        [Console]::Error.WriteLine("Stop hook failed on iteration $iteration with exit code $stopHookExitCode. See $iterationDirectory.")
        exit $stopHookExitCode
    }

    Write-AgentStatusLine -Iteration $iteration -MaxIterations $MaxIterations -Agent $Agent -Status 'continuing'
    $previousSummary = Get-PreviousSummary -IterationDirectory $iterationDirectory
}

$finalState = [ordered]@{
    stopped       = $false
    agent         = $Agent
    iteration     = $MaxIterations
    reason        = 'max-iterations-reached'
    runDirectory  = $runDirectory
    agentHome     = $resolvedAgentHome
    codeHome      = $resolvedAgentHome
} | ConvertTo-Json -Depth 4

Set-Content -Path (Join-Path $runDirectory 'state.json') -Value $finalState -Encoding UTF8
Write-AgentStatusLine -Iteration $MaxIterations -MaxIterations $MaxIterations -Agent $Agent -Status 'max-rounds-reached'
Write-Output "Loop reached MaxIterations=$MaxIterations. Run directory: $runDirectory"
exit 0
