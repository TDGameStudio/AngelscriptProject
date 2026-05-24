[CmdletBinding(DefaultParameterSetName = 'Prefix')]
param(
    [Parameter(Mandatory = $true, ParameterSetName = 'Prefix')]
    [Alias('Prefix', 'TestFilter', 'TestTarget')]
    [string]$TestPrefix,

    [Parameter(Mandatory = $true, ParameterSetName = 'Group')]
    [string]$Group,

    [string]$Label = '',

    [string]$OutputRoot = '',

    [int]$TimeoutMs = 0,

    [int]$ExecutionSlot = 0,

    [switch]$Fast,

    [switch]$Render,

    [switch]$NoReport,

    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$ExtraArgs = @()
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot 'Shared\UnrealCommandUtils.ps1')
. (Join-Path $PSScriptRoot 'Shared\TestLaunchProfile.ps1')

$exitCodes = @{
    Success      = 0
    TestFailed   = 1
    TimedOut     = 2
    ConfigError  = 3
    WorktreeBusy = 4
}

$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$worktreeMutex = $null
$metadataPath = $null
$scriptExitCode = $exitCodes.ConfigError

try {
    $agentConfig = Resolve-AgentConfiguration -ProjectRoot $projectRoot

    $defaultTimeoutMs = $agentConfig.TestDefaultTimeoutMs
    $resolvedTimeoutMs = Resolve-TimeoutMs -RequestedTimeoutMs $TimeoutMs -DefaultTimeoutMs $defaultTimeoutMs -ParameterName 'TimeoutMs'
    $deadlineUtc = New-ExecutionDeadline -TimeoutMs $resolvedTimeoutMs
    $editorCmd = Join-Path $agentConfig.EngineRoot 'Engine\Binaries\Win64\UnrealEditor-Cmd.exe'
    if (-not (Test-Path -LiteralPath $editorCmd -PathType Leaf)) {
        throw "UnrealEditor-Cmd.exe was not found: $editorCmd"
    }

    $target = if ($PSCmdlet.ParameterSetName -eq 'Group') {
        $definedGroups = @(Get-DefinedAutomationGroups -ProjectRoot $projectRoot)
        if ($definedGroups -notcontains $Group) {
            throw "Unknown automation group '$Group'. Defined groups: $($definedGroups -join ', ')"
        }

        "Group:$Group"
    }
    else {
        $TestPrefix
    }

    if ([string]::IsNullOrWhiteSpace($Label)) {
        $Label = $target
    }

    $outputLayout = New-CommandOutputLayout -ProjectRoot $projectRoot -Category 'Tests' -Label $Label -RequestedOutputRoot $OutputRoot -LogFileName 'Automation.log'
    $metadataPath = Join-Path $outputLayout.OutputRoot 'RunMetadata.json'
    $summaryPath = Join-Path $outputLayout.OutputRoot 'Summary.json'
    $targetInfoPath = Join-Path $projectRoot 'Intermediate\TargetInfo.json'
    $timedOutPhase = $null

    if ($ExecutionSlot -lt 0) {
        throw 'ExecutionSlot must be zero or a positive integer.'
    }

    $executionScopeKeyPath = Get-ExecutionScopeKeyPath -ProjectRoot $projectRoot -ExecutionSlot $ExecutionSlot
    $worktreeMutexName = Get-NamedMutexName -Scope 'ue-command-worktree' -KeyPath $executionScopeKeyPath
    $worktreeMutex = Acquire-NamedMutex -Name $worktreeMutexName -TimeoutMs 0
    if ($null -eq $worktreeMutex) {
        if ($ExecutionSlot -gt 0) {
            Write-Host ("[error] Execution slot {0} is already running a test command." -f $ExecutionSlot) -ForegroundColor Red
        }
        else {
            Write-Host '[error] Another build or test command is already running for this worktree.' -ForegroundColor Red
        }
        $scriptExitCode = $exitCodes.WorktreeBusy
        return
    }

    $argumentList = @(
        $agentConfig.ProjectFile
        "-ExecCmds=Automation RunTests $target; Quit"
        '-TestExit=Automation Test Queue Empty'
        '-BUILDMACHINE'
        '-Unattended'
        '-NoPause'
        '-NoSplash'
        '-stdout'
        '-FullStdOutLogOutput'
        '-UTF8Output'
        "-ABSLOG=$($outputLayout.LogPath)"
        "-ReportExportPath=$($outputLayout.ReportPath)"
        '-NOSOUND'
    )

    if (-not $Render) {
        $argumentList += '-NullRHI'
    }

    if ($Fast) {
        $argumentList += @(Get-AngelscriptTestFastLaunchArgs)
    }

    if ($ExtraArgs.Count -gt 0) {
        $argumentList += $ExtraArgs
    }

    $prewarmResult = Ensure-TargetInfoJson `
        -EngineRoot $agentConfig.EngineRoot `
        -ProjectFile $agentConfig.ProjectFile `
        -ProjectRoot $projectRoot `
        -TimeoutMs (Get-RemainingTimeoutMs -DeadlineUtc $deadlineUtc -PhaseName 'TargetInfo prewarm')

    if ($prewarmResult.Status -eq 'TimedOut') {
        Write-Host ("[warn] TargetInfo.json prewarm timed out after {0}ms. Editor startup may be slow." -f $prewarmResult.DurationMs) -ForegroundColor Yellow
    }
    elseif ($prewarmResult.Status -eq 'Failed') {
        Write-Host ("[warn] TargetInfo.json prewarm failed: {0}" -f $prewarmResult.Message) -ForegroundColor Yellow
    }

    $remainingAfterPrewarmMs = Get-RemainingTimeoutMs -DeadlineUtc $deadlineUtc -PhaseName 'Build.bat lock wait'
    $buildLockWaitBudgetMs = [Math]::Min([Math]::Min([int]($resolvedTimeoutMs / 3), [int]$remainingAfterPrewarmMs), 300000)
    $buildLockResult = Wait-BuildBatLockRelease -EngineRoot $agentConfig.EngineRoot -TimeoutMs $buildLockWaitBudgetMs
    if ($buildLockResult.Status -eq 'TimedOut') {
        Write-Host ("[error] Build.bat global lock did not release within {0}ms: {1}" -f $buildLockResult.DurationMs, $buildLockResult.LockPath) -ForegroundColor Red
        $timedOutPhase = 'BuildBatLockWait'
        $scriptExitCode = $exitCodes.TimedOut
        return
    }
    elseif ($buildLockResult.Status -eq 'Waited') {
        Write-Host ("[info] Build.bat global lock released after {0}ms." -f $buildLockResult.DurationMs) -ForegroundColor DarkCyan
    }

    Write-Utf8JsonFile -Path $metadataPath -Value ([PSCustomObject]@{
            Label             = $Label
            Target            = $target
            ProjectRoot       = $projectRoot
            ProjectFile       = $agentConfig.ProjectFile
            EngineRoot        = $agentConfig.EngineRoot
            EditorCmd         = $editorCmd
            TimeoutMs         = $resolvedTimeoutMs
            OutputRoot        = $outputLayout.OutputRoot
            LogPath           = $outputLayout.LogPath
            ReportPath        = $outputLayout.ReportPath
            SummaryPath       = $summaryPath
            TargetInfoPath    = $targetInfoPath
            TimedOutPhase     = $timedOutPhase
            Arguments         = $argumentList
            Prewarm           = [PSCustomObject]@{
                Status     = $prewarmResult.Status
                DurationMs = $prewarmResult.DurationMs
                Message    = $prewarmResult.Message
            }
            BuildBatLockWait  = [PSCustomObject]@{
                Status     = $buildLockResult.Status
                DurationMs = $buildLockResult.DurationMs
                LockPath    = $buildLockResult.LockPath
            }
            TimedOut          = $false
            ProcessExitCode   = $null
            ExitCode          = $null
        })

    Write-Host '================================================================'
    Write-Host 'Angelscript Automation Test Runner'
    Write-Host '================================================================'
    Write-Host ('Target          : {0}' -f $target)
    Write-Host ('ProjectFile     : {0}' -f $agentConfig.ProjectFile)
    Write-Host ('EditorCmd       : {0}' -f $editorCmd)
    Write-Host ('ExecutionSlot   : {0}' -f $ExecutionSlot)
    Write-Host ('FastLaunch      : {0}' -f ([bool]$Fast))
    Write-Host ('NullRHI         : {0}' -f (-not [bool]$Render))
    Write-Host ('TimeoutMs       : {0}' -f $resolvedTimeoutMs)
    Write-Host ('LogPath         : {0}' -f $outputLayout.LogPath)
    Write-Host ('TargetInfoPath  : {0}' -f $targetInfoPath)
    Write-Host ('ReportPath      : {0}' -f $outputLayout.ReportPath)
    Write-Host ('Render          : {0}' -f ([bool]$Render))
    Write-Host ('Prewarm         : {0} ({1}ms)' -f $prewarmResult.Status, $prewarmResult.DurationMs)
    Write-Host ('BuildBatLock    : {0} ({1}ms)' -f $buildLockResult.Status, $buildLockResult.DurationMs)
    Write-Host '----------------------------------------------------------------'

    $shutdownState = @{ TestCompleteAt = $null }
    $onOutputLine = {
        param([string]$stream, [string]$text)
        if ($null -eq $shutdownState.TestCompleteAt -and $text -match 'TEST COMPLETE\. EXIT CODE:') {
            $shutdownState.TestCompleteAt = [DateTime]::UtcNow
            Write-Host '[info] Tests finished. Waiting for editor process to shut down...' -ForegroundColor DarkCyan
        }
    }
    $remainingTimeoutMs = Get-RemainingTimeoutMs -DeadlineUtc $deadlineUtc -PhaseName 'Automation execution'
    $result = Invoke-StreamingProcess `
        -FilePath $editorCmd `
        -ArgumentList $argumentList `
        -WorkingDirectory $projectRoot `
        -TimeoutMs $remainingTimeoutMs `
        -LogPath $outputLayout.LogPath `
        -Label 'automation-tests' `
        -OnLine $onOutputLine

    if ($null -ne $shutdownState.TestCompleteAt) {
        $shutdownMs = [int]([DateTime]::UtcNow - $shutdownState.TestCompleteAt).TotalMilliseconds
        Write-Host ("[info] Editor exited {0}ms after test completion." -f $shutdownMs) -ForegroundColor DarkCyan
    }

    $processExitCode = [int]$result.ExitCode
    $scriptExitCode = if ($result.TimedOut) {
        $timedOutPhase = 'AutomationExecution'
        $exitCodes.TimedOut
    }
    elseif ($processExitCode -eq 0) {
        $exitCodes.Success
    }
    else {
        $exitCodes.TestFailed
    }

    if (-not $NoReport) {
        $summaryObject = & (Join-Path $PSScriptRoot 'GetAutomationReportSummary.ps1') `
            -ReportPath $outputLayout.ReportPath `
            -LogPath $outputLayout.LogPath `
            -ExitCode $processExitCode `
            -BucketName $target `
            -SummaryPath $summaryPath

        $summaryRecord = @($summaryObject | Select-Object -Last 1)[0]
        if ($processExitCode -eq 0 -and $null -ne $summaryRecord) {
            $summarySource = if ($null -ne $summaryRecord.SummarySource) { [string]$summaryRecord.SummarySource } else { 'None' }
            $failedCount = if ($null -ne $summaryRecord.Failed) { [int]$summaryRecord.Failed } else { 0 }
            $failedTests = @($summaryRecord.FailedTests)
            $logHints = @($summaryRecord.LogFailureHints)
            $missingStructuredSummary = $summarySource -eq 'None'
            if ($failedCount -gt 0 -or $failedTests.Count -gt 0 -or $logHints.Count -gt 0 -or $missingStructuredSummary) {
                if ($missingStructuredSummary) {
                    Write-Host '[warn] Automation run exited with code 0 but did not produce a structured summary. Promoting final exit code to 1.' -ForegroundColor Yellow
                }
                else {
                    Write-Host '[warn] Structured report indicates failures despite a zero process exit code. Promoting final exit code to 1.' -ForegroundColor Yellow
                }
                $scriptExitCode = $exitCodes.TestFailed
            }
        }
    }

    Write-Utf8JsonFile -Path $metadataPath -Value ([PSCustomObject]@{
            Label             = $Label
            Target            = $target
            ExecutionSlot     = $ExecutionSlot
            FastLaunch        = [bool]$Fast
            NullRHI           = -not [bool]$Render
            ProjectRoot       = $projectRoot
            ProjectFile       = $agentConfig.ProjectFile
            EngineRoot        = $agentConfig.EngineRoot
            EditorCmd         = $editorCmd
            TimeoutMs         = $resolvedTimeoutMs
            OutputRoot        = $outputLayout.OutputRoot
            LogPath           = $outputLayout.LogPath
            ReportPath        = $outputLayout.ReportPath
            SummaryPath       = if ($NoReport) { $null } else { $summaryPath }
            TargetInfoPath    = $targetInfoPath
            Prewarm           = [PSCustomObject]@{
                Status     = $prewarmResult.Status
                DurationMs = $prewarmResult.DurationMs
                Message    = $prewarmResult.Message
            }
            TimedOutPhase     = $timedOutPhase
            BuildBatLockWait  = [PSCustomObject]@{
                Status     = $buildLockResult.Status
                DurationMs = $buildLockResult.DurationMs
                LockPath    = $buildLockResult.LockPath
            }
            Arguments         = $argumentList
            TimedOut          = [bool]$result.TimedOut
            ProcessExitCode   = $processExitCode
            ExitCode          = $scriptExitCode
            DurationMs        = [int]$result.DurationMs
        })

    Write-Host '----------------------------------------------------------------'
    Write-Host ('ProcessExitCode : {0}' -f $processExitCode)
    Write-Host ('FinalExitCode   : {0}' -f $scriptExitCode)
    Write-Host ('DurationMs      : {0}' -f $result.DurationMs)
    Write-Host ('MetadataPath    : {0}' -f $metadataPath)
}
catch {
    Write-Host ("[error] {0}" -f $_.Exception.Message) -ForegroundColor Red
    $isTimeoutBudgetError = $_.Exception.Message -like '*allocated timeout budget*'

    if (-not [string]::IsNullOrWhiteSpace($metadataPath)) {
        Write-Utf8JsonFile -Path $metadataPath -Value ([PSCustomObject]@{
                Label       = $Label
                ProjectRoot = $projectRoot
                Message     = $_.Exception.Message
                ExitCode    = if ($isTimeoutBudgetError) { $exitCodes.TimedOut } else { $exitCodes.ConfigError }
            })
    }

    $scriptExitCode = if ($isTimeoutBudgetError) { $exitCodes.TimedOut } else { $exitCodes.ConfigError }
}
finally {
    if ($null -ne $worktreeMutex) {
        Release-NamedMutex -Mutex $worktreeMutex
    }
}

exit $scriptExitCode
