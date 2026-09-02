[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Commandlet,

    [string]$Label = '',

    [string]$OutputRoot = '',

    [int]$TimeoutMs = 0,

    [string]$ProjectFile = '',

    [switch]$Render,

    [string]$ExtraArgsFile = '',

    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$ExtraArgs = @()
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot 'Shared\UnrealCommandUtils.ps1')
. (Join-Path $PSScriptRoot 'Shared\CommandletProjectUtils.ps1')

$exitCodes = @{
    Success      = 0
    Failed       = 1
    TimedOut     = 2
    ConfigError  = 3
    WorktreeBusy = 4
}

$repositoryRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..\..\..')).Path
$worktreeMutex = $null
$metadataPath = $null
$scriptExitCode = $exitCodes.ConfigError

try {
    if ([string]::IsNullOrWhiteSpace($Commandlet)) {
        throw 'Commandlet is required.'
    }

    $agentConfig = Resolve-AgentConfiguration -ProjectRoot $repositoryRoot
    $projectContext = Resolve-AngelscriptCommandletProjectContext `
        -RepositoryRoot $repositoryRoot `
        -ConfiguredProjectFile $agentConfig.ProjectFile `
        -ProjectFileOverride $ProjectFile
    $resolvedExtraArgs = @(Resolve-AngelscriptCommandletExtraArguments `
            -InlineArguments $ExtraArgs `
            -ArgumentsFile $ExtraArgsFile)
    $defaultTimeoutMs = $agentConfig.TestDefaultTimeoutMs
    $resolvedTimeoutMs = Resolve-TimeoutMs -RequestedTimeoutMs $TimeoutMs -DefaultTimeoutMs $defaultTimeoutMs -ParameterName 'TimeoutMs'
    $deadlineUtc = New-ExecutionDeadline -TimeoutMs $resolvedTimeoutMs
    $editorCmd = Join-Path $agentConfig.EngineRoot 'Engine\Binaries\Win64\UnrealEditor-Cmd.exe'
    if (-not (Test-Path -LiteralPath $editorCmd -PathType Leaf)) {
        throw "UnrealEditor-Cmd.exe was not found: $editorCmd"
    }

    if ([string]::IsNullOrWhiteSpace($Label)) {
        $Label = $Commandlet
    }

    $outputLayout = New-CommandOutputLayout -ProjectRoot $repositoryRoot -Category 'Commandlet' -Label $Label -RequestedOutputRoot $OutputRoot -LogFileName 'Commandlet.log'
    $metadataPath = Join-Path $outputLayout.OutputRoot 'RunMetadata.json'
    $targetInfoPath = $projectContext.TargetInfoPath
    $timedOutPhase = $null

    $worktreeMutexName = Get-NamedMutexName -Scope 'ue-command-worktree' -KeyPath $repositoryRoot
    $worktreeMutex = Acquire-NamedMutex -Name $worktreeMutexName -TimeoutMs 0
    if ($null -eq $worktreeMutex) {
        Write-Host '[error] Another build, test, or commandlet is already running for this worktree.' -ForegroundColor Red
        $scriptExitCode = $exitCodes.WorktreeBusy
        return
    }

    $argumentList = New-AngelscriptCommandletArgumentList `
        -ProjectFile $projectContext.ProjectFile `
        -Commandlet $Commandlet `
        -LogPath $outputLayout.LogPath `
        -Render:$Render `
        -ExtraArgs $resolvedExtraArgs

    $prewarmResult = Ensure-TargetInfoJson `
        -EngineRoot $agentConfig.EngineRoot `
        -ProjectFile $projectContext.ProjectFile `
        -ProjectRoot $projectContext.ProjectRoot `
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
            Label            = $Label
            Commandlet       = $Commandlet
            RepositoryRoot   = $repositoryRoot
            ProjectRoot      = $projectContext.ProjectRoot
            ProjectFile      = $projectContext.ProjectFile
            EngineRoot       = $agentConfig.EngineRoot
            EditorCmd        = $editorCmd
            TimeoutMs        = $resolvedTimeoutMs
            OutputRoot       = $outputLayout.OutputRoot
            LogPath          = $outputLayout.LogPath
            TargetInfoPath   = $targetInfoPath
            TimedOutPhase    = $timedOutPhase
            Arguments        = $argumentList
            ExtraArgsFile    = $ExtraArgsFile
            Prewarm          = [PSCustomObject]@{
                Status     = $prewarmResult.Status
                DurationMs = $prewarmResult.DurationMs
                Message    = $prewarmResult.Message
            }
            BuildBatLockWait = [PSCustomObject]@{
                Status     = $buildLockResult.Status
                DurationMs = $buildLockResult.DurationMs
                LockPath    = $buildLockResult.LockPath
            }
            TimedOut         = $false
            ProcessExitCode  = $null
            ExitCode         = $null
        })

    Write-Host '================================================================'
    Write-Host 'Angelscript Commandlet Runner'
    Write-Host '================================================================'
    Write-Host ('Commandlet      : {0}' -f $Commandlet)
    Write-Host ('ProjectFile     : {0}' -f $projectContext.ProjectFile)
    Write-Host ('EditorCmd       : {0}' -f $editorCmd)
    Write-Host ('TimeoutMs       : {0}' -f $resolvedTimeoutMs)
    Write-Host ('LogPath         : {0}' -f $outputLayout.LogPath)
    Write-Host ('TargetInfoPath  : {0}' -f $targetInfoPath)
    Write-Host ('Render          : {0}' -f ([bool]$Render))
    Write-Host ('Prewarm         : {0} ({1}ms)' -f $prewarmResult.Status, $prewarmResult.DurationMs)
    Write-Host ('BuildBatLock    : {0} ({1}ms)' -f $buildLockResult.Status, $buildLockResult.DurationMs)
    Write-Host '----------------------------------------------------------------'

    $remainingTimeoutMs = Get-RemainingTimeoutMs -DeadlineUtc $deadlineUtc -PhaseName 'Commandlet execution'
    $result = Invoke-StreamingProcess `
        -FilePath $editorCmd `
        -ArgumentList $argumentList `
        -WorkingDirectory $projectContext.ProjectRoot `
        -TimeoutMs $remainingTimeoutMs `
        -LogPath $outputLayout.LogPath `
        -Label 'commandlet'

    $processExitCode = [int]$result.ExitCode
    if ($result.TimedOut) {
        $timedOutPhase = 'CommandletExecution'
    }
    $scriptExitCode = Resolve-AngelscriptCommandletExitCode `
        -ProcessExitCode $processExitCode `
        -TimedOut:$result.TimedOut

    Write-Utf8JsonFile -Path $metadataPath -Value ([PSCustomObject]@{
            Label            = $Label
            Commandlet       = $Commandlet
            RepositoryRoot   = $repositoryRoot
            ProjectRoot      = $projectContext.ProjectRoot
            ProjectFile      = $projectContext.ProjectFile
            EngineRoot       = $agentConfig.EngineRoot
            EditorCmd        = $editorCmd
            TimeoutMs        = $resolvedTimeoutMs
            OutputRoot       = $outputLayout.OutputRoot
            LogPath          = $outputLayout.LogPath
            TargetInfoPath   = $targetInfoPath
            TimedOutPhase    = $timedOutPhase
            Arguments        = $argumentList
            ExtraArgsFile    = $ExtraArgsFile
            Prewarm          = [PSCustomObject]@{
                Status     = $prewarmResult.Status
                DurationMs = $prewarmResult.DurationMs
                Message    = $prewarmResult.Message
            }
            BuildBatLockWait = [PSCustomObject]@{
                Status     = $buildLockResult.Status
                DurationMs = $buildLockResult.DurationMs
                LockPath    = $buildLockResult.LockPath
            }
            TimedOut         = [bool]$result.TimedOut
            ProcessExitCode  = $processExitCode
            ExitCode         = $scriptExitCode
        })

    if ($scriptExitCode -ne $exitCodes.Success) {
        Write-Host ("[error] Commandlet exited with process code {0}. See {1}" -f $processExitCode, $outputLayout.LogPath) -ForegroundColor Red
    }
    else {
        Write-Host ("[success] Commandlet completed. Log: {0}" -f $outputLayout.LogPath) -ForegroundColor Green
    }
}
catch {
    Write-Host ("[error] {0}" -f $_.Exception.Message) -ForegroundColor Red
    if (-not [string]::IsNullOrWhiteSpace($metadataPath)) {
        Write-Utf8JsonFile -Path $metadataPath -Value ([PSCustomObject]@{
                Label          = $Label
                Commandlet     = $Commandlet
                RepositoryRoot = $repositoryRoot
                TimeoutMs      = $TimeoutMs
                Error          = $_.Exception.Message
                ExitCode       = $scriptExitCode
            })
    }
    if ($scriptExitCode -eq $exitCodes.ConfigError) {
        exit $scriptExitCode
    }
    exit $exitCodes.Failed
}
finally {
    if ($null -ne $worktreeMutex) {
        $worktreeMutex.ReleaseMutex()
        $worktreeMutex.Dispose()
    }
}

exit $scriptExitCode
