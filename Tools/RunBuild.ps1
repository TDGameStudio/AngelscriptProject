[CmdletBinding()]
param(
    [int]$TimeoutMs = 0,

    [string]$Label = 'build',

    [string]$Target = '',

    [string]$LogRoot = '',

    [switch]$SerializeByEngine,

    [switch]$NoXGE,

    [switch]$UniqueBuildEnvironment,

    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$ExtraArgs = @()
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot 'Shared\UnrealCommandUtils.ps1')

$exitCodes = @{
    Success      = 0
    BuildFailed  = 1
    TimedOut     = 2
    ConfigError  = 3
    WorktreeBusy = 4
    EngineBusy   = 5
}

$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$worktreeMutex = $null
$engineMutex = $null
$metadataPath = $null
$scriptExitCode = $exitCodes.ConfigError

try {
    $agentConfig = Resolve-AgentConfiguration -ProjectRoot $projectRoot

    if ($UniqueBuildEnvironment) {
        throw 'Using -UniqueBuildEnvironment is prohibited in this repository. It triggers a worktree-private engine rebuild. Use -SerializeByEngine or a dedicated EngineRoot instead.'
    }

    if ($ExtraArgs -contains '-UniqueBuildEnvironment') {
        throw 'Using -UniqueBuildEnvironment via ExtraArgs is prohibited in this repository. It triggers a worktree-private engine rebuild. Use -SerializeByEngine or a dedicated EngineRoot instead.'
    }

    $defaultTimeoutMs = $agentConfig.BuildDefaultTimeoutMs
    $resolvedTarget = if ([string]::IsNullOrWhiteSpace($Target)) { $agentConfig.EditorTarget } else { $Target }
    $resolvedTimeoutMs = Resolve-TimeoutMs -RequestedTimeoutMs $TimeoutMs -DefaultTimeoutMs $defaultTimeoutMs -ParameterName 'TimeoutMs'
    $deadlineUtc = New-ExecutionDeadline -TimeoutMs $resolvedTimeoutMs
    $ubtPaths = Resolve-UbtPaths -EngineRoot $agentConfig.EngineRoot
    $outputLayout = New-CommandOutputLayout -ProjectRoot $projectRoot -Category 'Build' -Label $Label -RequestedOutputRoot $LogRoot -LogFileName 'Build.log'
    $metadataPath = Join-Path $outputLayout.OutputRoot 'RunMetadata.json'
    $engineWaitDurationMs = 0
    $timedOutPhase = $null
    $sharedEngineTimestampConflict = [PSCustomObject]@{
        Detected             = $false
        SharedEngineDetected = $false
        Paths                = @()
        SharedEnginePaths    = @()
    }

    $worktreeMutexName = Get-NamedMutexName -Scope 'ue-command-worktree' -KeyPath $projectRoot
    $worktreeMutex = Acquire-NamedMutex -Name $worktreeMutexName -TimeoutMs 0
    if ($null -eq $worktreeMutex) {
        Write-Host '[error] Another build or test command is already running for this worktree.' -ForegroundColor Red
        $scriptExitCode = $exitCodes.WorktreeBusy
        return
    }

    if ($SerializeByEngine) {
        $engineMutexName = Get-NamedMutexName -Scope 'ue-build-engine' -KeyPath $agentConfig.EngineRoot
        Write-Host ('Serialized engine mode enabled for: {0}' -f $agentConfig.EngineRoot)
        $engineWaitStartedAt = [DateTime]::UtcNow
        $engineWaitTimeoutMs = Get-RemainingTimeoutMs -DeadlineUtc $deadlineUtc -PhaseName 'Build engine slot wait'
        $engineMutex = Acquire-NamedMutex -Name $engineMutexName -TimeoutMs $engineWaitTimeoutMs -PollIntervalMs 5000 -OnWait {
            param($ElapsedMs, $RemainingMs)
            Write-Host ("[wait] Engine build slot busy. elapsed={0}ms remaining={1}ms" -f $ElapsedMs, $RemainingMs)
        }
        $engineWaitDurationMs = [int]([DateTime]::UtcNow - $engineWaitStartedAt).TotalMilliseconds

        if ($null -eq $engineMutex) {
            Write-Host '[error] Failed to acquire the engine build slot within the requested timeout.' -ForegroundColor Red
            $timedOutPhase = 'EngineWait'
            $scriptExitCode = $exitCodes.EngineBusy
            return
        }
    }

    $buildModeParts = New-Object System.Collections.Generic.List[string]
    $baseBuildMode = if ($SerializeByEngine) { 'SerializedEngine' } else { 'ConcurrentNoEngineChanges' }
    $buildModeParts.Add($baseBuildMode) | Out-Null
    if ($NoXGE) {
        $buildModeParts.Add('NoXGE') | Out-Null
    }
    $buildMode = [string]::Join('+', $buildModeParts)
    $ubtLogPath = Join-Path $outputLayout.OutputRoot 'UBT.log'
    $argumentList = @(
        $ubtPaths.UbtDllPath
        $resolvedTarget
        $agentConfig.Platform
        $agentConfig.Configuration
        "-Project=$($agentConfig.ProjectFile)"
        "-architecture=$($agentConfig.Architecture)"
        "-Log=$ubtLogPath"
        '-NoMutex'
    )

    if (-not $SerializeByEngine) {
        $argumentList += '-NoEngineChanges'
    }

    if ($NoXGE) {
        $argumentList += '-NoXGE'
    }

    if ($ExtraArgs.Count -gt 0) {
        $argumentList += $ExtraArgs
    }

    Write-Utf8JsonFile -Path $metadataPath -Value ([PSCustomObject]@{
            Label             = $Label
            Mode              = $buildMode
            ProjectRoot       = $projectRoot
            ProjectFile       = $agentConfig.ProjectFile
            EngineRoot        = $agentConfig.EngineRoot
            DotNetExecutable  = $ubtPaths.DotNetExecutablePath
            UbtDllPath        = $ubtPaths.UbtDllPath
            Target            = $resolvedTarget
            WorkingDirectory  = $ubtPaths.WorkingDirectory
            TimeoutMs         = $resolvedTimeoutMs
            OutputRoot        = $outputLayout.OutputRoot
            LogPath           = $outputLayout.LogPath
            EngineWaitDurationMs = $engineWaitDurationMs
            NoXGE             = [bool]$NoXGE
            SharedEngineUhtTimestampConflict = $sharedEngineTimestampConflict
            TimedOutPhase     = $timedOutPhase
            Arguments         = $argumentList
            TimedOut          = $false
            ProcessExitCode   = $null
            ExitCode          = $null
        })

    Write-Host '================================================================'
    Write-Host 'Angelscript UBT Build Runner'
    Write-Host '================================================================'
    Write-Host ('Mode            : {0}' -f $buildMode)
    Write-Host ('Target          : {0}' -f $resolvedTarget)
    Write-Host ('Platform        : {0}' -f $agentConfig.Platform)
    Write-Host ('Configuration   : {0}' -f $agentConfig.Configuration)
    Write-Host ('ProjectFile     : {0}' -f $agentConfig.ProjectFile)
    Write-Host ('EngineRoot      : {0}' -f $agentConfig.EngineRoot)
    Write-Host ('DotNet          : {0} ({1})' -f $ubtPaths.DotNetExecutablePath, $ubtPaths.DotNetSource)
    Write-Host ('TimeoutMs       : {0}' -f $resolvedTimeoutMs)
    Write-Host ('LogPath         : {0}' -f $outputLayout.LogPath)
    Write-Host ('UBT LogPath     : {0}' -f $ubtLogPath)
    Write-Host ('NoXGE          : {0}' -f ([bool]$NoXGE))
    if (-not $SerializeByEngine) {
        Write-Host 'Guard           : -NoMutex -NoEngineChanges'
        Write-Host 'Hint            : rerun with -SerializeByEngine if engine outputs must change.'
    }
    Write-Host '----------------------------------------------------------------'

    $processTimeoutMs = Get-RemainingTimeoutMs -DeadlineUtc $deadlineUtc -PhaseName 'Build execution'
    $result = Invoke-StreamingProcess `
        -FilePath $ubtPaths.DotNetExecutablePath `
        -ArgumentList $argumentList `
        -WorkingDirectory $ubtPaths.WorkingDirectory `
        -TimeoutMs $processTimeoutMs `
        -LogPath $outputLayout.LogPath `
        -Label 'ubt-build' `
        -Environment $ubtPaths.Environment

    $scriptExitCode = if ($result.TimedOut) {
        $timedOutPhase = 'BuildExecution'
        $exitCodes.TimedOut
    }
    elseif ([int]$result.ExitCode -eq 0) {
        $exitCodes.Success
    }
    else {
        $exitCodes.BuildFailed
    }

    if ($scriptExitCode -eq $exitCodes.Success -and (Test-Path -LiteralPath $outputLayout.LogPath -PathType Leaf)) {
        $buildLog = Get-Content -LiteralPath $outputLayout.LogPath -Raw -Encoding UTF8
        if ($buildLog -match '(?m)^Result:\s+Failed\b') {
            Write-Host '[warn] Build log reports failure despite a zero process exit code. Promoting final exit code to 1.' -ForegroundColor Yellow
            $scriptExitCode = $exitCodes.BuildFailed
        }
    }

    if ($scriptExitCode -eq $exitCodes.Success -and $resolvedTarget -eq 'AngelscriptDebugger') {
        if (-not $SerializeByEngine) {
            Write-Host '[warn] AngelscriptDebugger writes shared engine outputs. Rerun with -SerializeByEngine to copy runtime DLLs next to the executable.' -ForegroundColor Yellow
        }
        else {
            $debuggerRuntimeDependencies = @(
                [PSCustomObject]@{
                    Source      = Join-Path $projectRoot 'Plugins\Angelscript\Binaries\Win64\UnrealEditor-AngelscriptDebugProtocol.dll'
                    Destination = Join-Path $agentConfig.EngineRoot 'Engine\Binaries\Win64\UnrealEditor-AngelscriptDebugProtocol.dll'
                    Required    = $true
                },
                [PSCustomObject]@{
                    Source      = Join-Path $projectRoot 'Plugins\Angelscript\Binaries\Win64\UnrealEditor-AngelscriptSyntax.dll'
                    Destination = Join-Path $agentConfig.EngineRoot 'Engine\Binaries\Win64\UnrealEditor-AngelscriptSyntax.dll'
                    Required    = $true
                },
                [PSCustomObject]@{
                    Source      = Join-Path $projectRoot 'Binaries\Win64\AngelscriptDebugger.target'
                    Destination = Join-Path $agentConfig.EngineRoot 'Engine\Binaries\Win64\AngelscriptDebugger.target'
                    Required    = $false
                }
            )

            foreach ($dependency in $debuggerRuntimeDependencies) {
                if (Test-Path -LiteralPath $dependency.Source -PathType Leaf) {
                    Copy-Item -LiteralPath $dependency.Source -Destination $dependency.Destination -Force
                    Write-Host ('Copied debugger runtime dependency: {0}' -f $dependency.Destination)
                }
                elseif ($dependency.Required) {
                    Write-Host ('[warn] Missing required debugger runtime dependency: {0}' -f $dependency.Source) -ForegroundColor Yellow
                    $scriptExitCode = $exitCodes.BuildFailed
                }
                else {
                    Write-Host ('[warn] Optional debugger runtime dependency not found: {0}' -f $dependency.Source) -ForegroundColor Yellow
                }
            }
        }
    }

    $sharedEngineTimestampConflict = Get-UhtTimestampConflictSummary -LogPaths @($outputLayout.LogPath, $ubtLogPath) -EngineRoot $agentConfig.EngineRoot
    if ($sharedEngineTimestampConflict.SharedEngineDetected) {
        $previewConflictPaths = @($sharedEngineTimestampConflict.SharedEnginePaths | Select-Object -First 3)
        Write-Host ("[warn] Detected shared-engine UHT Timestamp contention across {0} path(s)." -f $sharedEngineTimestampConflict.SharedEnginePaths.Count) -ForegroundColor Yellow
        foreach ($conflictPath in $previewConflictPaths) {
            Write-Host ("       {0}" -f $conflictPath) -ForegroundColor Yellow
        }
        if ($sharedEngineTimestampConflict.SharedEnginePaths.Count -gt $previewConflictPaths.Count) {
            Write-Host ("       ... ({0} more)" -f ($sharedEngineTimestampConflict.SharedEnginePaths.Count - $previewConflictPaths.Count)) -ForegroundColor Yellow
        }

        if ($scriptExitCode -eq $exitCodes.Success) {
            Write-Host '[warn] Shared-engine UHT timestamp contention occurred despite a zero process exit code. Promoting final exit code to 1.' -ForegroundColor Yellow
            $scriptExitCode = $exitCodes.BuildFailed
        }

        if (-not $SerializeByEngine) {
            Write-Host '[warn] Rerun with -SerializeByEngine to serialize shared engine writes, or switch to a dedicated EngineRoot for this worktree.' -ForegroundColor Yellow
        }
    }

    Write-Utf8JsonFile -Path $metadataPath -Value ([PSCustomObject]@{
            Label             = $Label
            Mode              = $buildMode
            ProjectRoot       = $projectRoot
            ProjectFile       = $agentConfig.ProjectFile
            EngineRoot        = $agentConfig.EngineRoot
            DotNetExecutable  = $ubtPaths.DotNetExecutablePath
            UbtDllPath        = $ubtPaths.UbtDllPath
            Target            = $resolvedTarget
            WorkingDirectory  = $ubtPaths.WorkingDirectory
            TimeoutMs         = $resolvedTimeoutMs
            OutputRoot        = $outputLayout.OutputRoot
            LogPath           = $outputLayout.LogPath
            EngineWaitDurationMs = $engineWaitDurationMs
            NoXGE             = [bool]$NoXGE
            SharedEngineUhtTimestampConflict = $sharedEngineTimestampConflict
            TimedOutPhase     = $timedOutPhase
            Arguments         = $argumentList
            TimedOut          = [bool]$result.TimedOut
            ProcessExitCode   = [int]$result.ExitCode
            ExitCode          = $scriptExitCode
            DurationMs        = [int]$result.DurationMs
        })

    Write-Host '----------------------------------------------------------------'
    Write-Host ('ProcessExitCode : {0}' -f $result.ExitCode)
    Write-Host ('FinalExitCode   : {0}' -f $scriptExitCode)
    Write-Host ('DurationMs      : {0}' -f $result.DurationMs)
    Write-Host ('MetadataPath    : {0}' -f $metadataPath)
    if ($scriptExitCode -eq $exitCodes.BuildFailed -and -not $SerializeByEngine) {
        Write-Host 'If the failure is due to shared engine outputs, rerun with -SerializeByEngine or switch to a dedicated EngineRoot.'
    }
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
    if ($null -ne $engineMutex) {
        Release-NamedMutex -Mutex $engineMutex
    }

    if ($null -ne $worktreeMutex) {
        Release-NamedMutex -Mutex $worktreeMutex
    }
}

exit $scriptExitCode
