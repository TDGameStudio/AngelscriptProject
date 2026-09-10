[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Assert-True {
    param(
        [Parameter(Mandatory = $true)]
        [bool]$Condition,

        [Parameter(Mandatory = $true)]
        [string]$Message
    )

    if (-not $Condition) {
        throw $Message
    }
}

function Assert-Equal {
    param(
        [Parameter(Mandatory = $true)]
        $Expected,

        [Parameter(Mandatory = $true)]
        $Actual,

        [Parameter(Mandatory = $true)]
        [string]$Message
    )

    if ($Expected -ne $Actual) {
        throw "$Message Expected=[$Expected] Actual=[$Actual]"
    }
}

function Invoke-CapturedProcess {
    param(
        [Parameter(Mandatory = $true)]
        [string]$FilePath,

        [Parameter(Mandatory = $true)]
        [string[]]$ArgumentList,

        [Parameter(Mandatory = $true)]
        [string]$WorkingDirectory
    )

    $startInfo = New-Object System.Diagnostics.ProcessStartInfo
    $startInfo.FileName = $FilePath
    $startInfo.WorkingDirectory = $WorkingDirectory
    $startInfo.UseShellExecute = $false
    $startInfo.RedirectStandardOutput = $true
    $startInfo.RedirectStandardError = $true
    $startInfo.StandardOutputEncoding = [System.Text.UTF8Encoding]::new($false)
    $startInfo.StandardErrorEncoding = [System.Text.UTF8Encoding]::new($false)
    $startInfo.CreateNoWindow = $true

    $quotedArguments = foreach ($argument in $ArgumentList) {
        if ($argument -match '[\s"]') {
            '"{0}"' -f ($argument -replace '"', '\"')
        }
        else {
            $argument
        }
    }

    $startInfo.Arguments = ($quotedArguments -join ' ')

    $process = New-Object System.Diagnostics.Process
    $process.StartInfo = $startInfo
    [void]$process.Start()

    $stderrTask = $process.StandardError.ReadToEndAsync()
    $stdout = $process.StandardOutput.ReadToEnd()
    $stderr = $stderrTask.GetAwaiter().GetResult()
    $process.WaitForExit()

    return [PSCustomObject]@{
        ExitCode = $process.ExitCode
        StdOut   = $stdout.Replace("`r", '')
        StdErr   = $stderr.Replace("`r", '')
    }
}

function Invoke-TestCase {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name,

        [Parameter(Mandatory = $true)]
        [scriptblock]$Body
    )

    Write-Host ("[test] {0}" -f $Name)
    & $Body
    Write-Host ("[pass] {0}" -f $Name) -ForegroundColor Green
}

$packageRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$scriptPath = Join-Path $packageRoot 'scripts\HarnessWeb.ps1'
$startBat = Join-Path $packageRoot 'Start.bat'
$openBat = Join-Path $packageRoot 'Open.bat'
$stopBat = Join-Path $packageRoot 'Stop.bat'
$statusBat = Join-Path $packageRoot 'Status.bat'

Invoke-TestCase -Name 'Launcher files exist' -Body {
    foreach ($path in @($startBat, $openBat, $stopBat, $statusBat, $scriptPath)) {
        Assert-True -Condition (Test-Path -LiteralPath $path -PathType Leaf) `
            -Message ("Launcher file should exist: {0}" -f $path)
    }
}

Invoke-TestCase -Name 'Batch files dispatch matching actions' -Body {
    $pairs = @(
        @{ Path = $startBat; Action = 'Start' }
        @{ Path = $openBat; Action = 'Open' }
        @{ Path = $stopBat; Action = 'Stop' }
        @{ Path = $statusBat; Action = 'Status' }
    )

    foreach ($pair in $pairs) {
        $text = Get-Content -LiteralPath $pair.Path -Raw
        Assert-True -Condition ($text -match 'pwsh\.exe') `
            -Message ("{0} should invoke pwsh.exe" -f $pair.Path)
        Assert-True -Condition ($text -match 'scripts\\HarnessWeb\.ps1') `
            -Message ("{0} should call scripts\HarnessWeb.ps1" -f $pair.Path)
        Assert-True -Condition ($text -match ("-Action {0}" -f $pair.Action)) `
            -Message ("{0} should pass -Action {1}" -f $pair.Path, $pair.Action)
        Assert-True -Condition ($text -notmatch '(?i)npm(?!\.cmd)') `
            -Message ("{0} should not invoke npm without .cmd" -f $pair.Path)
    }
}

Invoke-TestCase -Name 'Start Stop Status pause; Open pauses only on error' -Body {
    $startText = Get-Content -LiteralPath $startBat -Raw
    $stopText = Get-Content -LiteralPath $stopBat -Raw
    $statusText = Get-Content -LiteralPath $statusBat -Raw
    $openText = Get-Content -LiteralPath $openBat -Raw

    Assert-True -Condition ($startText -match '(?im)^\s*pause\s*$') `
        -Message 'Start.bat should pause after the controller runs.'
    Assert-True -Condition ($stopText -match '(?im)^\s*pause\s*$') `
        -Message 'Stop.bat should pause after the controller runs.'
    Assert-True -Condition ($statusText -match '(?im)^\s*pause\s*$') `
        -Message 'Status.bat should pause after the controller runs.'
    Assert-True -Condition ($openText -notmatch '(?im)^\s*pause\s*$') `
        -Message 'Open.bat should not pause on success.'
    Assert-True -Condition ($openText -match '(?i)if not %EXITCODE%==0 pause') `
        -Message 'Open.bat should pause when the controller fails.'
}

. $scriptPath

Invoke-TestCase -Name 'Command line matcher accepts harness-web servers and launchers' -Body {
    $pkg = 'D:\Workspace\AngelscriptProject\Tools\harness-web'
    Assert-Equal -Expected $false -Actual (Test-HarnessWebCommandLine -CommandLine '"C:\nodejs\node.exe" dist/server/index.js' -PackageRoot $pkg) `
        -Message 'Relative dist server without the package path should not match.'
    Assert-True -Condition (Test-HarnessWebCommandLine -CommandLine ('node.exe "{0}\dist\server\index.js"' -f $pkg) -PackageRoot $pkg) `
        -Message 'Absolute dist server path should match.'
    Assert-True -Condition (Test-HarnessWebCommandLine -CommandLine ('node.exe {0}\node_modules\tsx\dist\cli.mjs src/server/index.ts --dev' -f $pkg) -PackageRoot $pkg) `
        -Message 'tsx dev server under the package should match.'
    Assert-True -Condition (Test-HarnessWebCommandLine -CommandLine ('npm.cmd --prefix {0} run dev' -f $pkg) -PackageRoot $pkg) `
        -Message 'npm run dev with this prefix should match.'
    Assert-True -Condition (Test-HarnessWebCommandLine -CommandLine ('npm.cmd --prefix {0} run start' -f $pkg) -PackageRoot $pkg) `
        -Message 'npm run start with this prefix should match.'
}

Invoke-TestCase -Name 'Command line matcher rejects unrelated node and test runners' -Body {
    $pkg = 'D:\Workspace\AngelscriptProject\Tools\harness-web'
    Assert-Equal -Expected $false -Actual (Test-HarnessWebCommandLine -CommandLine 'node.exe server.js' -PackageRoot $pkg) `
        -Message 'Unrelated node process should not match.'
    Assert-Equal -Expected $false -Actual (Test-HarnessWebCommandLine -CommandLine ("npx playwright test {0}\tests\e2e" -f $pkg) -PackageRoot $pkg) `
        -Message 'Playwright using the package path should not match.'
    Assert-Equal -Expected $false -Actual (Test-HarnessWebCommandLine -CommandLine ("vitest run {0}" -f $pkg) -PackageRoot $pkg) `
        -Message 'Vitest using the package path should not match.'
    Assert-Equal -Expected $false -Actual (Test-HarnessWebCommandLine -CommandLine $null -PackageRoot $pkg) `
        -Message 'Empty command line should not match.'
}

Invoke-TestCase -Name 'State machine classifies running starting stopped and conflict' -Body {
    Assert-Equal -Expected 'conflict' -Actual (Resolve-HarnessWebState -HttpReady $false -ListenerPid 10 -ListenerIsHarnessWeb:$false -TrackedPid $null -TrackedAlive:$false) `
        -Message 'Foreign listener should be conflict.'
    Assert-Equal -Expected 'conflict' -Actual (Resolve-HarnessWebState -HttpReady $true -ListenerPid 10 -ListenerIsHarnessWeb:$false -TrackedPid $null -TrackedAlive:$false) `
        -Message 'Foreign listener should remain conflict even if HTTP answers.'
    Assert-Equal -Expected 'running' -Actual (Resolve-HarnessWebState -HttpReady $true -ListenerPid 20 -ListenerIsHarnessWeb:$true -TrackedPid 20 -TrackedAlive:$true) `
        -Message 'Ready harness-web listener should be running.'
    Assert-Equal -Expected 'starting' -Actual (Resolve-HarnessWebState -HttpReady $false -ListenerPid 20 -ListenerIsHarnessWeb:$true -TrackedPid 20 -TrackedAlive:$true) `
        -Message 'Harness-web listener that is not HTTP-ready should be starting.'
    Assert-Equal -Expected 'starting' -Actual (Resolve-HarnessWebState -HttpReady $false -ListenerPid $null -ListenerIsHarnessWeb:$false -TrackedPid 30 -TrackedAlive:$true) `
        -Message 'Tracked live process without a listener should be starting.'
    Assert-Equal -Expected 'stopped' -Actual (Resolve-HarnessWebState -HttpReady $false -ListenerPid $null -ListenerIsHarnessWeb:$false -TrackedPid 30 -TrackedAlive:$false) `
        -Message 'Stale tracked pid should be stopped.'
    Assert-Equal -Expected 'stopped' -Actual (Resolve-HarnessWebState -HttpReady $false -ListenerPid $null -ListenerIsHarnessWeb:$false -TrackedPid $null -TrackedAlive:$false) `
        -Message 'No process should be stopped.'
}

$unusedPort = 43991
$existing = @(Get-NetTCPConnection -LocalPort $unusedPort -State Listen -ErrorAction SilentlyContinue)
if ($existing.Count -gt 0) {
    $unusedPort = 43993
}

function Invoke-StatusOnPort {
    param([Parameter(Mandatory = $true)][int]$Port)

    return Invoke-CapturedProcess -FilePath 'pwsh.exe' -ArgumentList @(
        '-NoProfile',
        '-ExecutionPolicy', 'Bypass',
        '-File', $scriptPath,
        '-Action', 'Status',
        '-Port', "$Port"
    ) -WorkingDirectory $packageRoot
}

Invoke-TestCase -Name 'Status on an unused port reports stopped' -Body {
    $run = Invoke-StatusOnPort -Port $unusedPort
    $combined = $run.StdOut + $run.StdErr
    Assert-Equal -Expected 0 -Actual $run.ExitCode `
        -Message ("Status should succeed when stopped. Output: {0}" -f $combined)
    Assert-True -Condition ($run.StdOut -match '(?m)^State=stopped$') `
        -Message ("Status should print State=stopped. Output: {0}" -f $combined)
    Assert-True -Condition ($run.StdOut -match ('(?m)^Url=http://127\.0\.0\.1:{0}$' -f $unusedPort)) `
        -Message ("Status should print the queried URL. Output: {0}" -f $combined)
    Assert-True -Condition ($run.StdOut -match '未运行') `
        -Message ("Status should say the service is not running. Output: {0}" -f $combined)
}

Invoke-TestCase -Name 'Tracked pid for another port does not mark this port starting' -Body {
    $cache = Join-Path $packageRoot '.cache'
    $pidFile = Join-Path $cache 'server.pid'
    New-Item -ItemType Directory -Force -Path $cache | Out-Null
    $original = $null
    if (Test-Path -LiteralPath $pidFile) {
        $original = Get-Content -LiteralPath $pidFile -Raw
    }
    try {
        Set-Content -LiteralPath $pidFile -Value @("pid=$PID", 'port=4310') -Encoding ascii
        $run = Invoke-StatusOnPort -Port $unusedPort
        $combined = $run.StdOut + $run.StdErr
        Assert-Equal -Expected 0 -Actual $run.ExitCode `
            -Message ("Status should succeed when this port is free. Output: {0}" -f $combined)
        Assert-True -Condition ($run.StdOut -match '(?m)^State=stopped$') `
            -Message ("A pid file for 4310 should not make port {0} starting. Output: {1}" -f $unusedPort, $combined)
    }
    finally {
        if ($null -eq $original) {
            if (Test-Path -LiteralPath $pidFile) {
                Remove-Item -LiteralPath $pidFile -Force
            }
        }
        else {
            Set-Content -LiteralPath $pidFile -Value $original -Encoding ascii -NoNewline
        }
    }
}

Write-Host 'All launcher tests passed.' -ForegroundColor Green
