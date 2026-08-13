[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('Scaffold', 'Generate', 'Verify')]
    [string]$Mode,

    [ValidateSet('EditorDevelopment', 'GameDevelopment', 'GameShipping', 'All')]
    [string]$Profile = 'EditorDevelopment',

    [string]$Label = '',

    [int]$TimeoutMs = 300000
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot 'Shared\UnrealCommandUtils.ps1')

$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$worktreeMutex = $null
$metadataPath = $null
$scriptExitCode = 2

try {
    $agentConfig = Resolve-AgentConfiguration -ProjectRoot $projectRoot
    $resolvedTimeoutMs = Resolve-TimeoutMs `
        -RequestedTimeoutMs $TimeoutMs `
        -DefaultTimeoutMs 300000 `
        -ParameterName 'TimeoutMs'
    $editorCmd = Join-Path $agentConfig.EngineRoot 'Engine\Binaries\Win64\UnrealEditor-Cmd.exe'
    if (-not (Test-Path -LiteralPath $editorCmd -PathType Leaf)) {
        throw "UnrealEditor-Cmd.exe was not found: $editorCmd"
    }

    $projectFile = Normalize-PathValue -Path $agentConfig.ProjectFile
    if (-not (Test-Path -LiteralPath $projectFile -PathType Leaf)) {
        throw "Configured project descriptor was not found: $projectFile"
    }
    if (-not [System.IO.Path]::GetExtension($projectFile).Equals(
            '.uproject', [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Configured project path is not a .uproject descriptor: $projectFile"
    }

    if ([string]::IsNullOrWhiteSpace($Label)) {
        $Label = if ($Mode -eq 'Scaffold') {
            'scaffold'
        }
        else {
            ('{0}-{1}' -f $Mode.ToLowerInvariant(), $Profile.ToLowerInvariant())
        }
    }
    $outputLayout = New-CommandOutputLayout `
        -ProjectRoot $projectRoot `
        -Category 'AngelscriptJITRuns' `
        -Label $Label `
        -LogFileName 'AngelscriptJIT.log'
    $metadataPath = Join-Path $outputLayout.OutputRoot 'RunMetadata.json'

    $mutexName = Get-NamedMutexName `
        -Scope 'ue-command-worktree' `
        -KeyPath $projectRoot
    $worktreeMutex = Acquire-NamedMutex -Name $mutexName -TimeoutMs 0
    if ($null -eq $worktreeMutex) {
        throw 'Another build, test, or AngelscriptJIT command is already running for this worktree.'
    }

    $commandletArguments = @(
        $projectFile
        '-run=AngelscriptJIT'
        "-Mode=$Mode"
        "-Project=$projectFile"
    )
    if ($Mode -ne 'Scaffold') {
        $commandletArguments += "-Profile=$Profile"
    }
    $commandletArguments += @(
        '-Unattended'
        '-NoPause'
        '-NoSplash'
        '-stdout'
        '-FullStdOutLogOutput'
        "-ABSLOG=$($outputLayout.LogPath)"
        '-NOSOUND'
        '-NullRHI'
    )

    Write-Utf8JsonFile -Path $metadataPath -Value ([PSCustomObject]@{
            Mode            = $Mode
            Profile         = if ($Mode -eq 'Scaffold') { $null } else { $Profile }
            Label           = $Label
            ProjectRoot     = $projectRoot
            ProjectFile     = $projectFile
            EngineRoot      = $agentConfig.EngineRoot
            EditorCmd       = $editorCmd
            TimeoutMs       = $resolvedTimeoutMs
            OutputRoot      = $outputLayout.OutputRoot
            LogPath         = $outputLayout.LogPath
            Arguments       = $commandletArguments
            TimedOut        = $false
            ProcessExitCode = $null
            ExitCode        = $null
        })

    Write-Host '================================================================'
    Write-Host 'Angelscript StaticJIT Command Runner'
    Write-Host '================================================================'
    Write-Host ('Mode        : {0}' -f $Mode)
    if ($Mode -ne 'Scaffold') {
        Write-Host ('Profile     : {0}' -f $Profile)
    }
    Write-Host ('ProjectFile : {0}' -f $projectFile)
    Write-Host ('TimeoutMs   : {0}' -f $resolvedTimeoutMs)
    Write-Host ('LogPath     : {0}' -f $outputLayout.LogPath)
    Write-Host '----------------------------------------------------------------'

    $result = Invoke-StreamingProcess `
        -FilePath $editorCmd `
        -ArgumentList $commandletArguments `
        -WorkingDirectory $projectRoot `
        -TimeoutMs $resolvedTimeoutMs `
        -LogPath $outputLayout.LogPath `
        -Label 'angelscript-jit'

    $scriptExitCode = if ($result.TimedOut) { 124 } else { [int]$result.ExitCode }
    Write-Utf8JsonFile -Path $metadataPath -Value ([PSCustomObject]@{
            Mode            = $Mode
            Profile         = if ($Mode -eq 'Scaffold') { $null } else { $Profile }
            Label           = $Label
            ProjectRoot     = $projectRoot
            ProjectFile     = $projectFile
            EngineRoot      = $agentConfig.EngineRoot
            EditorCmd       = $editorCmd
            TimeoutMs       = $resolvedTimeoutMs
            OutputRoot      = $outputLayout.OutputRoot
            LogPath         = $outputLayout.LogPath
            Arguments       = $commandletArguments
            TimedOut        = [bool]$result.TimedOut
            ProcessExitCode = [int]$result.ExitCode
            ExitCode        = $scriptExitCode
            DurationMs      = [int]$result.DurationMs
        })

    Write-Host '----------------------------------------------------------------'
    Write-Host ('ProcessExitCode : {0}' -f $result.ExitCode)
    Write-Host ('FinalExitCode   : {0}' -f $scriptExitCode)
    Write-Host ('DurationMs      : {0}' -f $result.DurationMs)
    Write-Host ('MetadataPath    : {0}' -f $metadataPath)
}
catch {
    Write-Host ('[error] {0}' -f $_.Exception.Message) -ForegroundColor Red
    if (-not [string]::IsNullOrWhiteSpace($metadataPath)) {
        Write-Utf8JsonFile -Path $metadataPath -Value ([PSCustomObject]@{
                Mode        = $Mode
                Profile     = if ($Mode -eq 'Scaffold') { $null } else { $Profile }
                Label       = $Label
                ProjectRoot = $projectRoot
                Message     = $_.Exception.Message
                ExitCode    = 2
            })
    }
    $scriptExitCode = 2
}
finally {
    if ($null -ne $worktreeMutex) {
        Release-NamedMutex -Mutex $worktreeMutex
    }
}

exit $scriptExitCode
