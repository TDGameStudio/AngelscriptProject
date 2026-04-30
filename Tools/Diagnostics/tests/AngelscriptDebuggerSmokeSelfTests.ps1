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
    $stdout = $process.StandardOutput.ReadToEnd()
    $stderr = $process.StandardError.ReadToEnd()
    $process.WaitForExit()

    return [PSCustomObject]@{
        ExitCode = $process.ExitCode
        StdOut   = $stdout
        StdErr   = $stderr
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

function Remove-TestDirectory {
    param(
        [Parameter(Mandatory = $true)]
        [string]$BasePath,

        [Parameter(Mandatory = $true)]
        [string]$TargetPath
    )

    $normalizedBase = [System.IO.Path]::GetFullPath($BasePath).TrimEnd(
        [System.IO.Path]::DirectorySeparatorChar,
        [System.IO.Path]::AltDirectorySeparatorChar)
    $normalizedTarget = [System.IO.Path]::GetFullPath($TargetPath).TrimEnd(
        [System.IO.Path]::DirectorySeparatorChar,
        [System.IO.Path]::AltDirectorySeparatorChar)
    $isWithinBase = $normalizedTarget.StartsWith(
        $normalizedBase + [System.IO.Path]::DirectorySeparatorChar,
        [System.StringComparison]::OrdinalIgnoreCase
    ) -or $normalizedTarget.Equals($normalizedBase, [System.StringComparison]::OrdinalIgnoreCase)

    if (-not $isWithinBase) {
        throw "Refusing to remove path outside test root: $normalizedTarget"
    }

    if (Test-Path -LiteralPath $normalizedTarget) {
        Remove-Item -LiteralPath $normalizedTarget -Recurse -Force
    }
}

function New-DebuggerSmokeFixture {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ProjectRoot
    )

    New-Item -ItemType Directory -Path $ProjectRoot -Force | Out-Null
    New-Item -ItemType Directory -Path (Join-Path $ProjectRoot 'Script') -Force | Out-Null
    New-Item -ItemType Directory -Path (Join-Path $ProjectRoot 'Saved\Crashes') -Force | Out-Null
    Set-Content -LiteralPath (Join-Path $ProjectRoot 'AngelscriptProject.uproject') -Encoding UTF8 -Value '{}'
}

function New-MockDebuggerCommand {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,

        [Parameter(Mandatory = $true)]
        [string[]]$Lines
    )

    Set-Content -LiteralPath $Path -Encoding ASCII -Value $Lines
}

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..\..')).Path
$diagnosticScript = Join-Path $repoRoot 'Tools\Diagnostics\powershell\Test-AngelscriptDebuggerSmoke.ps1'
$diagnosticBatch = Join-Path $repoRoot 'Tools\Diagnostics\Test-AngelscriptDebuggerSmoke.bat'
$testRoot = Join-Path ([System.IO.Path]::GetTempPath()) ('angelscript-debugger-smoke-test-' + [System.Guid]::NewGuid().ToString('N'))

try {
    Invoke-TestCase -Name 'RequiredFilesExist' -Body {
        Assert-True -Condition (Test-Path -LiteralPath $diagnosticScript -PathType Leaf) `
            -Message 'Test-AngelscriptDebuggerSmoke.ps1 should exist.'
        Assert-True -Condition (Test-Path -LiteralPath $diagnosticBatch -PathType Leaf) `
            -Message 'Test-AngelscriptDebuggerSmoke.bat should exist.'
    }

    Invoke-TestCase -Name 'FailsWhenDebuggerExeMissing' -Body {
        $fixtureRoot = Join-Path $testRoot 'missing-exe'
        New-DebuggerSmokeFixture -ProjectRoot $fixtureRoot

        $run = Invoke-CapturedProcess -FilePath 'powershell.exe' -ArgumentList @(
            '-NoProfile',
            '-ExecutionPolicy', 'Bypass',
            '-File', $diagnosticScript,
            '-ProjectRoot', $fixtureRoot,
            '-DebuggerExe', (Join-Path $fixtureRoot 'MissingDebugger.cmd')
        ) -WorkingDirectory $repoRoot

        $combined = $run.StdOut + $run.StdErr
        Assert-Equal -Expected 1 -Actual $run.ExitCode `
            -Message ('Missing debugger executable should fail. Output: {0}' -f $combined)
        Assert-True -Condition ($combined -match 'Debugger executable was not found') `
            -Message ('Failure output should identify the missing executable. Output: {0}' -f $combined)
    }

    Invoke-TestCase -Name 'AcceptsZeroExitSmoke' -Body {
        $fixtureRoot = Join-Path $testRoot 'zero-exit'
        New-DebuggerSmokeFixture -ProjectRoot $fixtureRoot
        $mockDebugger = Join-Path $fixtureRoot 'MockDebugger.cmd'
        New-MockDebuggerCommand -Path $mockDebugger -Lines @(
            '@echo off',
            'exit /b 0'
        )

        $run = Invoke-CapturedProcess -FilePath 'powershell.exe' -ArgumentList @(
            '-NoProfile',
            '-ExecutionPolicy', 'Bypass',
            '-File', $diagnosticScript,
            '-ProjectRoot', $fixtureRoot,
            '-DebuggerExe', $mockDebugger,
            '-TimeoutSeconds', '5'
        ) -WorkingDirectory $repoRoot

        $combined = $run.StdOut + $run.StdErr
        Assert-Equal -Expected 0 -Actual $run.ExitCode `
            -Message ('Zero-exit smoke should pass. Output: {0}' -f $combined)
        Assert-True -Condition ($combined -match 'Angelscript debugger smoke passed') `
            -Message ('Passing output should confirm smoke success. Output: {0}' -f $combined)
    }

    Invoke-TestCase -Name 'FailsOnNonzeroExit' -Body {
        $fixtureRoot = Join-Path $testRoot 'nonzero-exit'
        New-DebuggerSmokeFixture -ProjectRoot $fixtureRoot
        $mockDebugger = Join-Path $fixtureRoot 'MockDebugger.cmd'
        New-MockDebuggerCommand -Path $mockDebugger -Lines @(
            '@echo off',
            'exit /b 7'
        )

        $run = Invoke-CapturedProcess -FilePath 'powershell.exe' -ArgumentList @(
            '-NoProfile',
            '-ExecutionPolicy', 'Bypass',
            '-File', $diagnosticScript,
            '-ProjectRoot', $fixtureRoot,
            '-DebuggerExe', $mockDebugger,
            '-TimeoutSeconds', '5'
        ) -WorkingDirectory $repoRoot

        $combined = $run.StdOut + $run.StdErr
        Assert-Equal -Expected 1 -Actual $run.ExitCode `
            -Message ('Nonzero debugger exit should fail. Output: {0}' -f $combined)
        Assert-True -Condition ($combined -match 'exited with code 7') `
            -Message ('Failure output should include the debugger exit code. Output: {0}' -f $combined)
    }

    Invoke-TestCase -Name 'AllowsBriefCrashReporterProcessToExit' -Body {
        $fixtureRoot = Join-Path $testRoot 'brief-crash-reporter'
        New-DebuggerSmokeFixture -ProjectRoot $fixtureRoot
        $mockDebugger = Join-Path $fixtureRoot 'MockDebugger.cmd'
        New-MockDebuggerCommand -Path $mockDebugger -Lines @(
            '@echo off',
            'start "" "%SystemRoot%\System32\ping.exe" -n 3 127.0.0.1',
            'exit /b 0'
        )

        $run = Invoke-CapturedProcess -FilePath 'powershell.exe' -ArgumentList @(
            '-NoProfile',
            '-ExecutionPolicy', 'Bypass',
            '-File', $diagnosticScript,
            '-ProjectRoot', $fixtureRoot,
            '-DebuggerExe', $mockDebugger,
            '-TimeoutSeconds', '5',
            '-CrashReportProcessNames', 'ping',
            '-ProcessGraceSeconds', '5'
        ) -WorkingDirectory $repoRoot

        $combined = $run.StdOut + $run.StdErr
        Assert-Equal -Expected 0 -Actual $run.ExitCode `
            -Message ('Short-lived crash reporter process should be allowed to drain. Output: {0}' -f $combined)
    }

    Invoke-TestCase -Name 'DetectsNewCrashDirectory' -Body {
        $fixtureRoot = Join-Path $testRoot 'new-crash'
        New-DebuggerSmokeFixture -ProjectRoot $fixtureRoot
        New-Item -ItemType Directory -Path (Join-Path $fixtureRoot 'Saved\Crashes\ExistingCrash') -Force | Out-Null
        $mockDebugger = Join-Path $fixtureRoot 'MockDebugger.cmd'
        $newCrashPath = Join-Path $fixtureRoot 'Saved\Crashes\CrashAfterSmoke'
        New-MockDebuggerCommand -Path $mockDebugger -Lines @(
            '@echo off',
            ('mkdir "{0}"' -f $newCrashPath),
            'exit /b 0'
        )

        $run = Invoke-CapturedProcess -FilePath 'powershell.exe' -ArgumentList @(
            '-NoProfile',
            '-ExecutionPolicy', 'Bypass',
            '-File', $diagnosticScript,
            '-ProjectRoot', $fixtureRoot,
            '-DebuggerExe', $mockDebugger,
            '-TimeoutSeconds', '5'
        ) -WorkingDirectory $repoRoot

        $combined = $run.StdOut + $run.StdErr
        Assert-Equal -Expected 1 -Actual $run.ExitCode `
            -Message ('New crash directory should fail smoke validation. Output: {0}' -f $combined)
        Assert-True -Condition ($combined -match 'New crash output was created') `
            -Message ('Failure output should identify crash output. Output: {0}' -f $combined)
    }
}
finally {
    Remove-TestDirectory -BasePath ([System.IO.Path]::GetTempPath()) -TargetPath $testRoot
}

Write-Host 'Angelscript debugger smoke self-tests passed.'
