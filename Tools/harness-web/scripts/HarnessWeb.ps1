[CmdletBinding()]
param(
    [ValidateSet('Start', 'Open', 'Stop', 'Status')]
    [string]$Action,

    [int]$Port = 4310,

    [int]$WaitSeconds = 60
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)
$OutputEncoding = [Console]::OutputEncoding

function Get-HarnessWebPackageRoot {
    return (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
}

function Get-HarnessWebProjectRoot {
    return (Resolve-Path -LiteralPath (Join-Path (Get-HarnessWebPackageRoot) '..\..')).Path
}

function Get-HarnessWebCacheDirectory {
    return Join-Path (Get-HarnessWebPackageRoot) '.cache'
}

function Get-HarnessWebPidFile {
    return Join-Path (Get-HarnessWebCacheDirectory) 'server.pid'
}

function Get-HarnessWebLogFile {
    return Join-Path (Get-HarnessWebCacheDirectory) 'server.log'
}

function Write-HarnessWebError {
    param([Parameter(Mandatory = $true)][string]$Message)
    [Console]::Error.WriteLine($Message)
}

function Test-HarnessWebCommandLine {
    param(
        [string]$CommandLine,
        [Parameter(Mandatory = $true)]
        [string]$PackageRoot
    )

    if ([string]::IsNullOrWhiteSpace($CommandLine)) {
        return $false
    }

    $command = $CommandLine.Replace('/', '\').ToLowerInvariant()
    $package = $PackageRoot.Replace('/', '\').ToLowerInvariant().TrimEnd('\')
    if (-not $command.Contains($package)) {
        return $false
    }

    return $command.Contains('src\server\index.ts') `
        -or $command.Contains('dist\server\index.js') `
        -or $command -match '(^|[\s"])run\s+dev([\s"]|$)' `
        -or $command -match '(^|[\s"])run\s+start([\s"]|$)'
}

function Resolve-HarnessWebState {
    param(
        [bool]$HttpReady,
        $ListenerPid,
        [bool]$ListenerIsHarnessWeb,
        $TrackedPid,
        [bool]$TrackedAlive
    )

    if ($ListenerPid -and -not $ListenerIsHarnessWeb) {
        return 'conflict'
    }
    if ($HttpReady) {
        return 'running'
    }
    if (($ListenerPid -and $ListenerIsHarnessWeb) -or $TrackedAlive) {
        return 'starting'
    }
    return 'stopped'
}

function Get-HarnessWebHealth {
    param([Parameter(Mandatory = $true)][int]$Port)

    try {
        $response = Invoke-WebRequest -Uri "http://127.0.0.1:$Port/api/workspace" -UseBasicParsing -TimeoutSec 2
        if ($response.StatusCode -ne 200) {
            return [PSCustomObject]@{ Ready = $false; Root = $null }
        }
        $json = $response.Content | ConvertFrom-Json
        $root = $null
        if ($json.PSObject.Properties.Name -contains 'root') {
            $root = [string]$json.root
        }
        return [PSCustomObject]@{ Ready = $true; Root = $root }
    }
    catch {
        return [PSCustomObject]@{ Ready = $false; Root = $null }
    }
}

function Test-SamePath {
    param([string]$Left, [string]$Right)
    if ([string]::IsNullOrWhiteSpace($Left) -or [string]::IsNullOrWhiteSpace($Right)) {
        return $false
    }
    $leftPath = [System.IO.Path]::GetFullPath($Left).TrimEnd('\')
    $rightPath = [System.IO.Path]::GetFullPath($Right).TrimEnd('\')
    return $leftPath.Equals($rightPath, [System.StringComparison]::OrdinalIgnoreCase)
}

function Get-HarnessWebListener {
    param([Parameter(Mandatory = $true)][int]$Port)

    $connections = @(Get-NetTCPConnection -LocalPort $Port -State Listen -ErrorAction SilentlyContinue |
            Where-Object { $_.LocalAddress -in @('127.0.0.1', '::1', '0.0.0.0') })
    if ($connections.Count -eq 0) {
        return $null
    }

    $processId = [int]$connections[0].OwningProcess
    $process = Get-CimInstance -ClassName Win32_Process -Filter "ProcessId=$processId" -ErrorAction SilentlyContinue
    $commandLine = $null
    if ($process) {
        $commandLine = $process.CommandLine
    }

    return [PSCustomObject]@{
        Pid           = $processId
        CommandLine   = $commandLine
        IsHarnessWeb  = Test-HarnessWebCommandLine -CommandLine $commandLine -PackageRoot (Get-HarnessWebPackageRoot)
    }
}

function Read-HarnessWebPidFile {
    $pidFile = Get-HarnessWebPidFile
    if (-not (Test-Path -LiteralPath $pidFile)) {
        return $null
    }

    $raw = Get-Content -LiteralPath $pidFile -Raw -ErrorAction SilentlyContinue
    if ([string]::IsNullOrWhiteSpace($raw)) {
        return $null
    }

    $trackedPid = 0
    $trackedPort = 0
    foreach ($line in ($raw -split '\r?\n')) {
        $trim = $line.Trim()
        if ($trim -match '^(?i)pid=(\d+)$') {
            $trackedPid = [int]$Matches[1]
        }
        elseif ($trim -match '^(?i)port=(\d+)$') {
            $trackedPort = [int]$Matches[1]
        }
        elseif ($trim -match '^\d+$' -and $trackedPid -le 0) {
            $trackedPid = [int]$trim
        }
    }

    if ($trackedPid -le 0) {
        return $null
    }
    if ($trackedPort -le 0) {
        $trackedPort = 4310
    }

    return [PSCustomObject]@{
        Pid  = $trackedPid
        Port = $trackedPort
    }
}

function Write-HarnessWebPidFile {
    param(
        [Parameter(Mandatory = $true)][int]$ProcessId,
        [Parameter(Mandatory = $true)][int]$Port
    )

    $cache = Get-HarnessWebCacheDirectory
    New-Item -ItemType Directory -Force -Path $cache | Out-Null
    $content = @(
        "pid=$ProcessId"
        "port=$Port"
    )
    Set-Content -LiteralPath (Get-HarnessWebPidFile) -Value $content -Encoding ascii
}

function Get-HarnessWebTrackedProcess {
    param([Parameter(Mandatory = $true)][int]$Port)

    $record = Read-HarnessWebPidFile
    if (-not $record -or $record.Port -ne $Port) {
        return [PSCustomObject]@{ Pid = $null; Alive = $false }
    }

    try {
        $null = Get-Process -Id $record.Pid -ErrorAction Stop
        return [PSCustomObject]@{ Pid = $record.Pid; Alive = $true }
    }
    catch {
        return [PSCustomObject]@{ Pid = $record.Pid; Alive = $false }
    }
}

function Get-HarnessWebRuntimeStatus {
    param([Parameter(Mandatory = $true)][int]$Port)

    $projectRoot = Get-HarnessWebProjectRoot
    $health = Get-HarnessWebHealth -Port $Port
    $listener = Get-HarnessWebListener -Port $Port
    $tracked = Get-HarnessWebTrackedProcess -Port $Port
    $listenerPid = $null
    $isOurs = $false
    if ($listener) {
        $listenerPid = $listener.Pid
        $isOurs = [bool]$listener.IsHarnessWeb -or (Test-SamePath -Left $health.Root -Right $projectRoot)
    }

    $state = Resolve-HarnessWebState `
        -HttpReady ([bool]$health.Ready) `
        -ListenerPid $listenerPid `
        -ListenerIsHarnessWeb $isOurs `
        -TrackedPid $tracked.Pid `
        -TrackedAlive ([bool]$tracked.Alive)

    $displayPid = $listenerPid
    if (-not $displayPid -and $tracked.Alive) {
        $displayPid = $tracked.Pid
    }

    $workspace = $projectRoot
    if ($state -eq 'running' -and $health.Root) {
        $workspace = $health.Root
    }

    $message = switch ($state) {
        'running' { 'Harness Web 正在运行。' }
        'starting' { 'Harness Web 正在启动。' }
        'stopped' { 'Harness Web 未运行。' }
        'conflict' { "端口 $Port 已被其他程序占用。" }
        default { $state }
    }

    return [PSCustomObject]@{
        State     = $state
        Url       = "http://127.0.0.1:$Port"
        Pid       = $displayPid
        Workspace = $workspace
        Message   = $message
        LogPath   = Get-HarnessWebLogFile
    }
}

function Write-HarnessWebLine {
    param([Parameter(Mandatory = $true)][string]$Message)
    [Console]::Out.WriteLine($Message)
}

function Write-HarnessWebStatus {
    param([Parameter(Mandatory = $true)]$Status)
    Write-HarnessWebLine -Message ("State={0}" -f $Status.State)
    Write-HarnessWebLine -Message ("Url={0}" -f $Status.Url)
    $pidText = ''
    if ($Status.Pid) {
        $pidText = [string]$Status.Pid
    }
    Write-HarnessWebLine -Message ("Pid={0}" -f $pidText)
    Write-HarnessWebLine -Message ("Workspace={0}" -f $Status.Workspace)
    Write-HarnessWebLine -Message ("Message={0}" -f $Status.Message)
}

function Clear-HarnessWebPidFile {
    $pidFile = Get-HarnessWebPidFile
    if (Test-Path -LiteralPath $pidFile) {
        Remove-Item -LiteralPath $pidFile -Force
    }
}

function Stop-HarnessWebProcessTree {
    param([Parameter(Mandatory = $true)][int]$ProcessId)

    $children = @(Get-CimInstance -ClassName Win32_Process -Filter "ParentProcessId=$ProcessId" -ErrorAction SilentlyContinue)
    foreach ($child in $children) {
        Stop-HarnessWebProcessTree -ProcessId ([int]$child.ProcessId)
    }
    Stop-Process -Id $ProcessId -Force -ErrorAction SilentlyContinue
}

function Get-HarnessWebStopRoots {
    param([Parameter(Mandatory = $true)][int]$Port)

    $packageRoot = Get-HarnessWebPackageRoot
    $roots = New-Object System.Collections.Generic.List[int]
    $listener = Get-HarnessWebListener -Port $Port
    $health = Get-HarnessWebHealth -Port $Port
    $projectRoot = Get-HarnessWebProjectRoot
    $listenerIsOurs = $false
    if ($listener) {
        $listenerIsOurs = [bool]$listener.IsHarnessWeb -or (Test-SamePath -Left $health.Root -Right $projectRoot)
    }

    if ($listener -and $listenerIsOurs) {
        $current = [int]$listener.Pid
        $roots.Add($current)
        for ($depth = 0; $depth -lt 8; $depth++) {
            $process = Get-CimInstance -ClassName Win32_Process -Filter "ProcessId=$current" -ErrorAction SilentlyContinue
            if (-not $process -or -not $process.ParentProcessId) {
                break
            }
            $parentId = [int]$process.ParentProcessId
            if ($parentId -le 4) {
                break
            }
            $parent = Get-CimInstance -ClassName Win32_Process -Filter "ProcessId=$parentId" -ErrorAction SilentlyContinue
            if (-not $parent) {
                break
            }
            $parentCommand = [string]$parent.CommandLine
            $parentName = [string]$parent.Name
            $matchesPackage = $parentCommand -and $parentCommand.Replace('/', '\').ToLowerInvariant().Contains(
                $packageRoot.Replace('/', '\').ToLowerInvariant().TrimEnd('\')
            )
            $isCmdOrNpm = $parentName -match '(?i)^(cmd|npm|node)\.exe$'
            if (-not ($matchesPackage -or (Test-HarnessWebCommandLine -CommandLine $parentCommand -PackageRoot $packageRoot))) {
                if (-not ($isCmdOrNpm -and $matchesPackage)) {
                    break
                }
            }
            $roots.Add($parentId)
            $current = $parentId
        }
    }

    $tracked = Get-HarnessWebTrackedProcess -Port $Port
    if ($tracked.Alive) {
        $roots.Add([int]$tracked.Pid)
    }

    return @($roots | Select-Object -Unique)
}

function Start-HarnessWebProcess {
    param([Parameter(Mandatory = $true)][int]$Port)

    $packageRoot = Get-HarnessWebPackageRoot
    $projectRoot = Get-HarnessWebProjectRoot
    $cache = Get-HarnessWebCacheDirectory
    New-Item -ItemType Directory -Force -Path $cache | Out-Null

    if (-not (Test-Path -LiteralPath (Join-Path $packageRoot 'node_modules'))) {
        Write-HarnessWebError "缺少依赖。请先运行: npm.cmd --prefix `"$packageRoot`" ci"
        return 1
    }

    $npm = Get-Command npm.cmd -ErrorAction SilentlyContinue
    if (-not $npm) {
        Write-HarnessWebError '未找到 npm.cmd。请安装 Node.js 24 或更新版本。'
        return 1
    }

    $log = Get-HarnessWebLogFile
    $launchCmd = Join-Path $cache 'launch.cmd'
    $npmPath = $npm.Source
    $lines = @(
        '@echo off'
        "call `"$npmPath`" --prefix `"$packageRoot`" run dev -- --workspace `"$projectRoot`" --port $Port >> `"$log`" 2>&1"
    )
    Set-Content -LiteralPath $launchCmd -Value $lines -Encoding ascii

    $process = Start-Process -FilePath $env:ComSpec -ArgumentList @('/d', '/c', "`"$launchCmd`"") -WorkingDirectory $projectRoot -WindowStyle Hidden -PassThru
    Write-HarnessWebPidFile -ProcessId $process.Id -Port $Port
    Write-HarnessWebLine -Message ("StartedPid={0}" -f $process.Id)
    Write-HarnessWebLine -Message ("Log={0}" -f $log)
    return 0
}

function Wait-HarnessWebReady {
    param(
        [Parameter(Mandatory = $true)][int]$Port,
        [Parameter(Mandatory = $true)][int]$WaitSeconds
    )

    $deadline = (Get-Date).AddSeconds($WaitSeconds)
    $log = Get-HarnessWebLogFile
    while ((Get-Date) -lt $deadline) {
        $status = Get-HarnessWebRuntimeStatus -Port $Port
        if ($status.State -eq 'running') {
            Write-HarnessWebStatus -Status $status
            return 0
        }
        if ($status.State -eq 'conflict') {
            Write-HarnessWebStatus -Status $status
            return 1
        }
        if ($status.State -eq 'stopped') {
            $tail = ''
            if (Test-Path -LiteralPath $log) {
                $tail = (Get-Content -LiteralPath $log -Tail 20 -ErrorAction SilentlyContinue) -join [Environment]::NewLine
            }
            Write-HarnessWebError "Harness Web 启动失败。日志: $log"
            if ($tail) {
                Write-HarnessWebError $tail
            }
            return 1
        }
        Start-Sleep -Milliseconds 400
    }

    Write-HarnessWebError "等待 Harness Web 就绪超时（${WaitSeconds}s）。日志: $log"
    return 1
}

function Start-HarnessWebServer {
    param(
        [Parameter(Mandatory = $true)][int]$Port,
        [Parameter(Mandatory = $true)][int]$WaitSeconds
    )

    $status = Get-HarnessWebRuntimeStatus -Port $Port
    if ($status.State -eq 'running') {
        Write-HarnessWebStatus -Status $status
        return 0
    }
    if ($status.State -eq 'conflict') {
        Write-HarnessWebStatus -Status $status
        return 1
    }
    if ($status.State -eq 'stopped') {
        $started = Start-HarnessWebProcess -Port $Port
        if ($started -ne 0) {
            return $started
        }
    }
    return Wait-HarnessWebReady -Port $Port -WaitSeconds $WaitSeconds
}

function Open-HarnessWeb {
    param(
        [Parameter(Mandatory = $true)][int]$Port,
        [Parameter(Mandatory = $true)][int]$WaitSeconds
    )

    $code = Start-HarnessWebServer -Port $Port -WaitSeconds $WaitSeconds
    if ($code -ne 0) {
        return $code
    }
    $status = Get-HarnessWebRuntimeStatus -Port $Port
    Start-Process $status.Url | Out-Null
    Write-HarnessWebLine -Message ("Opened={0}" -f $status.Url)
    return 0
}

function Stop-HarnessWebServer {
    param([Parameter(Mandatory = $true)][int]$Port)

    $status = Get-HarnessWebRuntimeStatus -Port $Port
    if ($status.State -eq 'stopped') {
        Clear-HarnessWebPidFile
        Write-HarnessWebStatus -Status $status
        return 0
    }
    if ($status.State -eq 'conflict') {
        Write-HarnessWebStatus -Status $status
        return 1
    }

    $roots = @(Get-HarnessWebStopRoots -Port $Port)
    foreach ($root in $roots) {
        Stop-HarnessWebProcessTree -ProcessId $root
    }

    $deadline = (Get-Date).AddSeconds(10)
    while ((Get-Date) -lt $deadline) {
        $status = Get-HarnessWebRuntimeStatus -Port $Port
        if ($status.State -eq 'stopped') {
            break
        }
        Start-Sleep -Milliseconds 200
    }

    Clear-HarnessWebPidFile
    $status = Get-HarnessWebRuntimeStatus -Port $Port
    if ($status.State -ne 'stopped') {
        Write-HarnessWebError '未能停止 Harness Web。'
        Write-HarnessWebStatus -Status $status
        return 1
    }
    $status.Message = 'Harness Web 已停止。'
    Write-HarnessWebStatus -Status $status
    return 0
}

function Invoke-HarnessWebAction {
    param(
        [Parameter(Mandatory = $true)][string]$Action,
        [Parameter(Mandatory = $true)][int]$Port,
        [Parameter(Mandatory = $true)][int]$WaitSeconds
    )

    switch ($Action) {
        'Status' {
            $status = Get-HarnessWebRuntimeStatus -Port $Port
            Write-HarnessWebStatus -Status $status
            if ($status.State -eq 'conflict') {
                return 1
            }
            return 0
        }
        'Start' { return Start-HarnessWebServer -Port $Port -WaitSeconds $WaitSeconds }
        'Open' { return Open-HarnessWeb -Port $Port -WaitSeconds $WaitSeconds }
        'Stop' { return Stop-HarnessWebServer -Port $Port }
        default {
            Write-HarnessWebError "Unknown action: $Action"
            return 2
        }
    }
}

if ($MyInvocation.InvocationName -ne '.') {
    if ([string]::IsNullOrWhiteSpace($Action)) {
        Write-HarnessWebError 'Specify -Action Start|Open|Stop|Status'
        exit 2
    }
    $code = Invoke-HarnessWebAction -Action $Action -Port $Port -WaitSeconds $WaitSeconds
    exit $code
}
