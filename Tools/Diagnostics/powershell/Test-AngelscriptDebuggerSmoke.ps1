[CmdletBinding()]
param(
    [string]$ProjectRoot = '',

    [string]$ProjectFile = '',

    [string]$EngineRoot = '',

    [string]$DebuggerExe = '',

    [string]$ScriptRoot = '',

    [int]$TimeoutSeconds = 30,

    [int]$ProcessGraceSeconds = 5,

    [string[]]$ResidualProcessNames = @('AngelscriptDebugger'),

    [string[]]$CrashReportProcessNames = @('CrashReportClientEditor')
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot '..\..\Shared\UnrealCommandUtils.ps1')

function Resolve-ProjectRootForSmoke {
    param([string]$Path)

    if ([string]::IsNullOrWhiteSpace($Path)) {
        return (Resolve-Path (Join-Path $PSScriptRoot '..\..\..')).Path
    }

    return Normalize-PathValue -Path $Path
}

function Resolve-ProjectFileForSmoke {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ResolvedProjectRoot,

        [string]$RequestedProjectFile = '',

        [AllowNull()]
        $AgentConfig = $null
    )

    if (-not [string]::IsNullOrWhiteSpace($RequestedProjectFile)) {
        $resolvedProjectFile = Normalize-PathValue -Path $RequestedProjectFile
        if (-not (Test-Path -LiteralPath $resolvedProjectFile -PathType Leaf)) {
            throw "Project file was not found: $resolvedProjectFile"
        }
        return $resolvedProjectFile
    }

    if ($null -ne $AgentConfig -and -not [string]::IsNullOrWhiteSpace([string]$AgentConfig.ProjectFile)) {
        return [string]$AgentConfig.ProjectFile
    }

    $projectFiles = @(Get-ChildItem -LiteralPath $ResolvedProjectRoot -Filter *.uproject -File)
    if ($projectFiles.Count -eq 0) {
        throw "Could not resolve a .uproject file from '$ResolvedProjectRoot'."
    }

    return Normalize-PathValue -Path $projectFiles[0].FullName
}

function Resolve-DebuggerExeForSmoke {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ResolvedProjectRoot,

        [string]$RequestedDebuggerExe = '',

        [string]$RequestedEngineRoot = '',

        [AllowNull()]
        $AgentConfig = $null
    )

    if (-not [string]::IsNullOrWhiteSpace($RequestedDebuggerExe)) {
        $resolvedDebuggerExe = Normalize-PathValue -Path $RequestedDebuggerExe
        if (-not (Test-Path -LiteralPath $resolvedDebuggerExe -PathType Leaf)) {
            throw "Debugger executable was not found: $resolvedDebuggerExe"
        }
        return $resolvedDebuggerExe
    }

    $resolvedEngineRoot = ''
    if (-not [string]::IsNullOrWhiteSpace($RequestedEngineRoot)) {
        $resolvedEngineRoot = Normalize-PathValue -Path $RequestedEngineRoot
    }
    elseif ($null -ne $AgentConfig -and -not [string]::IsNullOrWhiteSpace([string]$AgentConfig.EngineRoot)) {
        $resolvedEngineRoot = [string]$AgentConfig.EngineRoot
    }

    $candidates = @()
    if (-not [string]::IsNullOrWhiteSpace($resolvedEngineRoot)) {
        $candidates += Join-Path $resolvedEngineRoot 'Engine\Binaries\Win64\AngelscriptDebugger.exe'
    }
    $candidates += Join-Path $ResolvedProjectRoot 'Binaries\Win64\AngelscriptDebugger.exe'

    foreach ($candidate in $candidates) {
        if (Test-Path -LiteralPath $candidate -PathType Leaf) {
            return Normalize-PathValue -Path $candidate
        }
    }

    throw ("Debugger executable was not found. Checked: {0}" -f ($candidates -join '; '))
}

function Get-CrashOutputDirectories {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ResolvedProjectRoot
    )

    $crashRoot = Join-Path $ResolvedProjectRoot 'Saved\Crashes'
    if (-not (Test-Path -LiteralPath $crashRoot -PathType Container)) {
        return @()
    }

    return @(
        Get-ChildItem -LiteralPath $crashRoot -Directory |
            ForEach-Object { Normalize-PathValue -Path $_.FullName }
    )
}

function Get-NewCrashOutputDirectories {
    param(
        [string[]]$Before,

        [string[]]$After
    )

    $beforeSet = New-Object 'System.Collections.Generic.HashSet[string]' ([System.StringComparer]::OrdinalIgnoreCase)
    foreach ($path in $Before) {
        [void]$beforeSet.Add($path)
    }

    $newDirectories = @()
    foreach ($path in $After) {
        if (-not $beforeSet.Contains($path)) {
            $newDirectories += $path
        }
    }
    return @($newDirectories)
}

function Get-LingeringProcesses {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Names
    )

    $processes = @()
    foreach ($name in $Names) {
        if ([string]::IsNullOrWhiteSpace($name)) {
            continue
        }

        $processes += @(Get-Process -Name $name -ErrorAction SilentlyContinue | Where-Object { $_.Id -ne $PID })
    }

    return @($processes)
}

function Wait-ForProcessesToDrain {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Names,

        [Parameter(Mandatory = $true)]
        [int]$GraceSeconds
    )

    $deadlineUtc = [DateTime]::UtcNow.AddSeconds([Math]::Max($GraceSeconds, 0))
    do {
        $processes = @(Get-LingeringProcesses -Names $Names)
        if ($processes.Count -eq 0) {
            return @()
        }

        if ([DateTime]::UtcNow -ge $deadlineUtc) {
            return @($processes)
        }

        Start-Sleep -Milliseconds 250
    } while ($true)
}

function ConvertTo-ProcessArgumentString {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Arguments
    )

    return (($Arguments | ForEach-Object { ConvertTo-QuotedProcessArgument -Argument $_ }) -join ' ')
}

function Start-DebuggerSmokeProcess {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ResolvedDebuggerExe,

        [Parameter(Mandatory = $true)]
        [string[]]$DebuggerArguments
    )

    $launchFile = $ResolvedDebuggerExe
    $launchArguments = $DebuggerArguments
    $extension = [System.IO.Path]::GetExtension($ResolvedDebuggerExe)
    if ($extension.Equals('.cmd', [System.StringComparison]::OrdinalIgnoreCase) -or
        $extension.Equals('.bat', [System.StringComparison]::OrdinalIgnoreCase)) {
        $launchFile = if ([string]::IsNullOrWhiteSpace($env:ComSpec)) { 'cmd.exe' } else { $env:ComSpec }
        $launchArguments = @('/d', '/c', $ResolvedDebuggerExe) + $DebuggerArguments
    }

    $startInfo = New-Object System.Diagnostics.ProcessStartInfo
    $startInfo.FileName = $launchFile
    $startInfo.WorkingDirectory = Split-Path -Parent $ResolvedDebuggerExe
    $startInfo.UseShellExecute = $false
    $startInfo.CreateNoWindow = $true
    $startInfo.Arguments = ConvertTo-ProcessArgumentString -Arguments $launchArguments

    $process = New-Object System.Diagnostics.Process
    $process.StartInfo = $startInfo
    [void]$process.Start()
    return $process
}

try {
    if ($TimeoutSeconds -le 0) {
        throw 'TimeoutSeconds must be greater than zero.'
    }
    if ($ProcessGraceSeconds -lt 0) {
        throw 'ProcessGraceSeconds cannot be negative.'
    }

    $resolvedProjectRoot = Resolve-ProjectRootForSmoke -Path $ProjectRoot
    $agentConfig = $null
    $configPath = Join-Path $resolvedProjectRoot 'AgentConfig.ini'
    if (Test-Path -LiteralPath $configPath -PathType Leaf) {
        $agentConfig = Resolve-AgentConfiguration -ProjectRoot $resolvedProjectRoot -ConfigPath $configPath
    }

    $resolvedProjectFile = Resolve-ProjectFileForSmoke `
        -ResolvedProjectRoot $resolvedProjectRoot `
        -RequestedProjectFile $ProjectFile `
        -AgentConfig $agentConfig
    $resolvedDebuggerExe = Resolve-DebuggerExeForSmoke `
        -ResolvedProjectRoot $resolvedProjectRoot `
        -RequestedDebuggerExe $DebuggerExe `
        -RequestedEngineRoot $EngineRoot `
        -AgentConfig $agentConfig
    $resolvedScriptRoot = if ([string]::IsNullOrWhiteSpace($ScriptRoot)) {
        Normalize-PathValue -Path (Join-Path $resolvedProjectRoot 'Script')
    }
    else {
        Normalize-PathValue -Path $ScriptRoot
    }

    $crashesBefore = @(Get-CrashOutputDirectories -ResolvedProjectRoot $resolvedProjectRoot)
    $debuggerArguments = @(
        ('-project={0}' -f $resolvedProjectFile),
        ('-scriptroot={0}' -f $resolvedScriptRoot),
        '-smoketest'
    )

    Write-Host ('Launching Angelscript debugger smoke: {0}' -f $resolvedDebuggerExe)
    $process = Start-DebuggerSmokeProcess -ResolvedDebuggerExe $resolvedDebuggerExe -DebuggerArguments $debuggerArguments
    $timeoutMilliseconds = [Math]::Min([int64]$TimeoutSeconds * 1000, [int64][int]::MaxValue)
    if (-not $process.WaitForExit([int]$timeoutMilliseconds)) {
        try {
            $process.Kill()
            $process.WaitForExit()
        }
        catch {
        }
        Write-Host ('Angelscript debugger smoke timed out after {0}s.' -f $TimeoutSeconds) -ForegroundColor Red
        exit 1
    }

    $failures = @()
    if ($process.ExitCode -ne 0) {
        $failures += ('Angelscript debugger exited with code {0}.' -f $process.ExitCode)
    }

    $lingeringDebuggers = @(Wait-ForProcessesToDrain -Names $ResidualProcessNames -GraceSeconds $ProcessGraceSeconds)
    foreach ($lingeringProcess in $lingeringDebuggers) {
        $failures += ('Lingering debugger process: {0} (PID {1}).' -f $lingeringProcess.ProcessName, $lingeringProcess.Id)
    }

    $lingeringCrashReporters = @(Wait-ForProcessesToDrain -Names $CrashReportProcessNames -GraceSeconds $ProcessGraceSeconds)
    foreach ($lingeringProcess in $lingeringCrashReporters) {
        $failures += ('Lingering crash reporter process: {0} (PID {1}).' -f $lingeringProcess.ProcessName, $lingeringProcess.Id)
    }

    $crashesAfter = @(Get-CrashOutputDirectories -ResolvedProjectRoot $resolvedProjectRoot)
    $newCrashDirectories = @(Get-NewCrashOutputDirectories -Before $crashesBefore -After $crashesAfter)
    foreach ($crashDirectory in $newCrashDirectories) {
        $failures += ('New crash output was created: {0}' -f $crashDirectory)
    }

    if ($failures.Count -gt 0) {
        Write-Host 'Angelscript debugger smoke failed:' -ForegroundColor Red
        foreach ($failure in $failures) {
            Write-Host ("- {0}" -f $failure)
        }
        exit 1
    }

    Write-Host ('Angelscript debugger smoke passed. ExitCode={0}' -f $process.ExitCode)
    exit 0
}
catch {
    Write-Host ('Angelscript debugger smoke failed: {0}' -f $_.Exception.Message) -ForegroundColor Red
    exit 1
}
