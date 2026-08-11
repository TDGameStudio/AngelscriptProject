[CmdletBinding()]
param(
    [int]$TimeoutMs = 0,

    [string]$Label = 'package',

    [string]$Configuration = 'Development',

    [string]$Platform = 'Win64',

    [string]$Map = '/Game/Test/ActorTestMap',

    [string]$ArchiveDir = '',

    [string]$LogRoot = '',

    [switch]$NoXGE,

    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$ExtraArgs = @()
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot 'Shared\UnrealCommandUtils.ps1')
Import-Module (Join-Path $PSScriptRoot 'Shared\AngelscriptCachePackageSmoke.psm1') -Force

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
$layoutValidation = $null
$layoutValidationError = ''

try {
    $agentConfig = Resolve-AgentConfiguration -ProjectRoot $projectRoot

    # Packaging can take a long time. Default to the maximum allowed budget when
    # the caller does not request a specific timeout.
    $defaultTimeoutMs = 3600000
    $resolvedTimeoutMs = Resolve-TimeoutMs -RequestedTimeoutMs $TimeoutMs -DefaultTimeoutMs $defaultTimeoutMs -ParameterName 'TimeoutMs'
    $deadlineUtc = New-ExecutionDeadline -TimeoutMs $resolvedTimeoutMs

    $resolvedEngineRoot = Normalize-PathValue -Path $agentConfig.EngineRoot
    $projectName = [System.IO.Path]::GetFileNameWithoutExtension(
        $agentConfig.ProjectFile)
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

    $finalArguments = @(
        New-AngelscriptPackageRunnerArguments `
            -ProjectFile $agentConfig.ProjectFile `
            -Platform $Platform `
            -Configuration $Configuration `
            -ArchiveDir $resolvedArchiveDir `
            -Map $Map `
            -NoXGE:$NoXGE `
            -ExtraArgs $ExtraArgs)

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
            NoXGE           = [bool]$NoXGE
            OutputRoot      = $outputLayout.OutputRoot
            LogPath         = $outputLayout.LogPath
            Arguments       = $finalArguments
            TimedOut        = $false
            ProcessExitCode = $null
            ExitCode        = $null
            LayoutValidation = 'Pending'
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
    Write-Host ('NoXGE           : {0}' -f ([bool]$NoXGE))
    Write-Host ('LogPath         : {0}' -f $outputLayout.LogPath)
    Write-Host '----------------------------------------------------------------'

    $processTimeoutMs = Get-RemainingTimeoutMs -DeadlineUtc $deadlineUtc -PhaseName 'Package execution'
    $result = Invoke-StreamingProcess `
        -FilePath $runUatPath `
        -ArgumentList $finalArguments `
        -WorkingDirectory $resolvedEngineRoot `
        -TimeoutMs $processTimeoutMs `
        -LogPath $outputLayout.LogPath `
        -Label 'runuat-package'

    if (-not $result.TimedOut -and [int]$result.ExitCode -eq 0) {
        try {
            $layoutValidation = Assert-AngelscriptLoosePackageLayout `
                -ArchiveRoot $resolvedArchiveDir `
                -ProjectName $projectName `
                -Configuration $Configuration
        }
        catch {
            $layoutValidationError = $_.Exception.Message
            Write-Host ("[error] Packaged Cache V2 layout validation failed: {0}" -f $layoutValidationError) -ForegroundColor Red
        }
    }

    $scriptExitCode = if ($result.TimedOut) {
        $exitCodes.TimedOut
    }
    elseif ([int]$result.ExitCode -eq 0 -and $null -ne $layoutValidation) {
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
            NoXGE           = [bool]$NoXGE
            OutputRoot      = $outputLayout.OutputRoot
            LogPath         = $outputLayout.LogPath
            Arguments       = $finalArguments
            TimedOut        = [bool]$result.TimedOut
            ProcessExitCode = [int]$result.ExitCode
            ExitCode        = $scriptExitCode
            DurationMs      = [int]$result.DurationMs
            LayoutValidation = if ($null -ne $layoutValidation) { 'Passed' } elseif (-not [string]::IsNullOrWhiteSpace($layoutValidationError)) { 'Failed' } else { 'Skipped' }
            LayoutValidationError = $layoutValidationError
            PackagedExecutable = if ($null -ne $layoutValidation) { $layoutValidation.Executable } else { $null }
            LooseScriptRoot = if ($null -ne $layoutValidation) { $layoutValidation.ScriptRoot } else { $null }
            BindsCache = if ($null -ne $layoutValidation) { $layoutValidation.BindsCache } else { $null }
            LooseSourceCount = if ($null -ne $layoutValidation) { $layoutValidation.SourceCount } else { 0 }
        })

    Write-Host '----------------------------------------------------------------'
    Write-Host ('ProcessExitCode : {0}' -f $result.ExitCode)
    Write-Host ('FinalExitCode   : {0}' -f $scriptExitCode)
    Write-Host ('DurationMs      : {0}' -f $result.DurationMs)
    Write-Host ('ArchiveDir      : {0}' -f $resolvedArchiveDir)
    Write-Host ('MetadataPath    : {0}' -f $metadataPath)
    Write-Host ('LayoutValidation: {0}' -f $(if ($null -ne $layoutValidation) { 'Passed' } elseif (-not [string]::IsNullOrWhiteSpace($layoutValidationError)) { 'Failed' } else { 'Skipped' }))
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
                NoXGE       = [bool]$NoXGE
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
