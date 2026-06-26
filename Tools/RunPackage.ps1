[CmdletBinding()]
param(
    [int]$TimeoutMs = 0,

    [string]$Label = 'package',

    [string]$Configuration = 'Development',

    [string]$Platform = 'Win64',

    [string]$Map = '/Game/Test/ActorTestMap',

    [string]$ArchiveDir = '',

    [string]$LogRoot = '',

    # Generate an AngelScript precompiled-script cache (PrecompiledScript.Cache) before
    # packaging. The cache holds bytecode for all non-editor script roots (e.g. Script/Game,
    # Script/Tests) and is staged via DirectoriesToAlwaysStageAsUFS so the packaged runtime
    # can load script classes without rescanning. Defaults to $true.
    [bool]$GeneratePrecompiledData = $true,

    # Force the cook/precompile to also compile editor-only script directories (Examples/,
    # Dev/, Editor/) via -as-force-preprocess-editor-code. This is intentionally OFF: those
    # scripts reference editor-only (WITH_EDITORONLY_DATA) symbols that are not registered in
    # a non-editor packaged runtime, which crashes script loading. Game content that needs a
    # script class must place it outside the editor-only directories (see Script/Game/).
    [bool]$ForcePreprocessEditorCode = $false,

    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$ExtraArgs = @()
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot 'Shared\UnrealCommandUtils.ps1')

$exitCodes = @{
    Success       = 0
    PackageFailed = 1
    TimedOut      = 2
    ConfigError   = 3
    WorktreeBusy  = 4
}

$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$worktreeMutex = $null
$metadataPath = $null
$scriptExitCode = $exitCodes.ConfigError

try {
    $agentConfig = Resolve-AgentConfiguration -ProjectRoot $projectRoot

    # Packaging can take a long time. Default to the maximum allowed budget when
    # the caller does not request a specific timeout.
    $defaultTimeoutMs = 3600000
    $resolvedTimeoutMs = Resolve-TimeoutMs -RequestedTimeoutMs $TimeoutMs -DefaultTimeoutMs $defaultTimeoutMs -ParameterName 'TimeoutMs'
    $deadlineUtc = New-ExecutionDeadline -TimeoutMs $resolvedTimeoutMs

    $resolvedEngineRoot = Normalize-PathValue -Path $agentConfig.EngineRoot
    $runUatPath = Join-Path $resolvedEngineRoot 'Engine\Build\BatchFiles\RunUAT.bat'
    if (-not (Test-Path -LiteralPath $runUatPath -PathType Leaf)) {
        throw "RunUAT.bat was not found: $runUatPath"
    }

    $outputLayout = New-CommandOutputLayout -ProjectRoot $projectRoot -Category 'Package' -Label $Label -RequestedOutputRoot $LogRoot -LogFileName 'Package.log'
    $metadataPath = Join-Path $outputLayout.OutputRoot 'RunMetadata.json'

    $resolvedArchiveDir = if ([string]::IsNullOrWhiteSpace($ArchiveDir)) {
        Join-Path $outputLayout.OutputRoot 'Archive'
    }
    else {
        Normalize-PathValue -Path $ArchiveDir
    }
    New-Item -ItemType Directory -Path $resolvedArchiveDir -Force | Out-Null

    # Guard against concurrent build/test/package commands in the same worktree.
    $worktreeMutexName = Get-NamedMutexName -Scope 'ue-command-worktree' -KeyPath $projectRoot
    $worktreeMutex = Acquire-NamedMutex -Name $worktreeMutexName -TimeoutMs 0
    if ($null -eq $worktreeMutex) {
        Write-Host '[error] Another build, test, or package command is already running for this worktree.' -ForegroundColor Red
        $scriptExitCode = $exitCodes.WorktreeBusy
        return
    }

    $argumentList = New-Object System.Collections.Generic.List[string]
    $argumentList.Add('BuildCookRun') | Out-Null
    $argumentList.Add("-project=$($agentConfig.ProjectFile)") | Out-Null
    $argumentList.Add('-noP4') | Out-Null
    $argumentList.Add('-utf8output') | Out-Null
    $argumentList.Add("-platform=$Platform") | Out-Null
    $argumentList.Add("-clientconfig=$Configuration") | Out-Null
    $argumentList.Add('-build') | Out-Null
    $argumentList.Add('-cook') | Out-Null
    $argumentList.Add('-stage') | Out-Null
    $argumentList.Add('-pak') | Out-Null
    $argumentList.Add('-archive') | Out-Null
    $argumentList.Add("-archivedirectory=$resolvedArchiveDir") | Out-Null
    $argumentList.Add('-nocompileeditor') | Out-Null
    if (-not [string]::IsNullOrWhiteSpace($Map)) {
        $argumentList.Add("-map=$Map") | Out-Null
    }
    if ($ForcePreprocessEditorCode) {
        # Forward to the cook commandlet so Examples/Dev scripts are compiled during cook.
        $argumentList.Add('-AdditionalCookerOptions=-as-force-preprocess-editor-code') | Out-Null
    }
    if ($ExtraArgs.Count -gt 0) {
        foreach ($extra in $ExtraArgs) {
            $argumentList.Add($extra) | Out-Null
        }
    }

    $finalArguments = @($argumentList.ToArray())

    Write-Utf8JsonFile -Path $metadataPath -Value ([PSCustomObject]@{
            Label           = $Label
            ProjectRoot     = $projectRoot
            ProjectFile     = $agentConfig.ProjectFile
            EngineRoot      = $resolvedEngineRoot
            RunUAT          = $runUatPath
            Platform        = $Platform
            Configuration   = $Configuration
            Map             = $Map
            ArchiveDir      = $resolvedArchiveDir
            TimeoutMs       = $resolvedTimeoutMs
            OutputRoot      = $outputLayout.OutputRoot
            LogPath         = $outputLayout.LogPath
            Arguments       = $finalArguments
            TimedOut        = $false
            ProcessExitCode = $null
            ExitCode        = $null
        })

    Write-Host '================================================================'
    Write-Host 'Angelscript Package Runner (RunUAT BuildCookRun)'
    Write-Host '================================================================'
    Write-Host ('Platform        : {0}' -f $Platform)
    Write-Host ('Configuration   : {0}' -f $Configuration)
    Write-Host ('Map             : {0}' -f $Map)
    Write-Host ('ProjectFile     : {0}' -f $agentConfig.ProjectFile)
    Write-Host ('EngineRoot      : {0}' -f $resolvedEngineRoot)
    Write-Host ('RunUAT          : {0}' -f $runUatPath)
    Write-Host ('ArchiveDir      : {0}' -f $resolvedArchiveDir)
    Write-Host ('TimeoutMs       : {0}' -f $resolvedTimeoutMs)
    Write-Host ('LogPath         : {0}' -f $outputLayout.LogPath)
    Write-Host '----------------------------------------------------------------'

    # Pre-step: generate the PrecompiledScript.Cache for all non-editor script roots so the
    # packaged non-editor runtime can load script classes (e.g. Script/Game, Script/Tests).
    if ($GeneratePrecompiledData) {
        $editorCmdPath = Join-Path $resolvedEngineRoot 'Engine\Binaries\Win64\UnrealEditor-Cmd.exe'
        if (-not (Test-Path -LiteralPath $editorCmdPath -PathType Leaf)) {
            throw "UnrealEditor-Cmd.exe was not found (build the editor first): $editorCmdPath"
        }

        $genLogPath = Join-Path $outputLayout.OutputRoot 'GeneratePrecompiled.log'
        $genArguments = @(
            $agentConfig.ProjectFile,
            '-run=AngelscriptAllScriptRoots',
            '-as-generate-precompiled-data',
            '-as-skip-static-jit-codegen',
            '-unattended',
            '-nullrhi',
            '-nosplash',
            '-stdout',
            '-NoLogTimes'
        )
        if ($ForcePreprocessEditorCode) {
            $genArguments += '-as-force-preprocess-editor-code'
        }

        Write-Host '----------------------------------------------------------------'
        Write-Host 'Pre-step: generating AngelScript PrecompiledScript.Cache (non-editor script roots)'
        Write-Host ('EditorCmd       : {0}' -f $editorCmdPath)
        Write-Host ('GenLogPath      : {0}' -f $genLogPath)
        Write-Host '----------------------------------------------------------------'

        $genTimeoutMs = Get-RemainingTimeoutMs -DeadlineUtc $deadlineUtc -PhaseName 'Precompiled cache generation'
        $genResult = Invoke-StreamingProcess `
            -FilePath $editorCmdPath `
            -ArgumentList $genArguments `
            -WorkingDirectory $resolvedEngineRoot `
            -TimeoutMs $genTimeoutMs `
            -LogPath $genLogPath `
            -Label 'generate-precompiled'

        $cachePath = Join-Path $projectRoot 'Script\PrecompiledScript.Cache'
        if ($genResult.TimedOut) {
            throw 'Precompiled cache generation timed out.'
        }
        if (-not (Test-Path -LiteralPath $cachePath -PathType Leaf)) {
            throw "Precompiled cache generation finished (exit=$($genResult.ExitCode)) but $cachePath was not produced. See $genLogPath."
        }
        Write-Host ('Generated cache : {0}' -f $cachePath) -ForegroundColor Green
    }

    $processTimeoutMs = Get-RemainingTimeoutMs -DeadlineUtc $deadlineUtc -PhaseName 'Package execution'
    $result = Invoke-StreamingProcess `
        -FilePath $runUatPath `
        -ArgumentList $finalArguments `
        -WorkingDirectory $resolvedEngineRoot `
        -TimeoutMs $processTimeoutMs `
        -LogPath $outputLayout.LogPath `
        -Label 'runuat-package'

    $scriptExitCode = if ($result.TimedOut) {
        $exitCodes.TimedOut
    }
    elseif ([int]$result.ExitCode -eq 0) {
        $exitCodes.Success
    }
    else {
        $exitCodes.PackageFailed
    }

    Write-Utf8JsonFile -Path $metadataPath -Value ([PSCustomObject]@{
            Label           = $Label
            ProjectRoot     = $projectRoot
            ProjectFile     = $agentConfig.ProjectFile
            EngineRoot      = $resolvedEngineRoot
            RunUAT          = $runUatPath
            Platform        = $Platform
            Configuration   = $Configuration
            Map             = $Map
            ArchiveDir      = $resolvedArchiveDir
            TimeoutMs       = $resolvedTimeoutMs
            OutputRoot      = $outputLayout.OutputRoot
            LogPath         = $outputLayout.LogPath
            Arguments       = $finalArguments
            TimedOut        = [bool]$result.TimedOut
            ProcessExitCode = [int]$result.ExitCode
            ExitCode        = $scriptExitCode
            DurationMs      = [int]$result.DurationMs
        })

    Write-Host '----------------------------------------------------------------'
    Write-Host ('ProcessExitCode : {0}' -f $result.ExitCode)
    Write-Host ('FinalExitCode   : {0}' -f $scriptExitCode)
    Write-Host ('DurationMs      : {0}' -f $result.DurationMs)
    Write-Host ('ArchiveDir      : {0}' -f $resolvedArchiveDir)
    Write-Host ('MetadataPath    : {0}' -f $metadataPath)
    if ($scriptExitCode -eq $exitCodes.Success) {
        Write-Host ('Packaged build  : {0}\Windows' -f $resolvedArchiveDir) -ForegroundColor Green
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
    if ($null -ne $worktreeMutex) {
        Release-NamedMutex -Mutex $worktreeMutex
    }
}

exit $scriptExitCode
