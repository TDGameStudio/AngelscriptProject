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

    $stderrTask = $process.StandardError.ReadToEndAsync()
    $stdout = $process.StandardOutput.ReadToEnd()
    $stderr = $stderrTask.GetAwaiter().GetResult()
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

    $normalizedBase = [System.IO.Path]::GetFullPath($BasePath)
    $normalizedTarget = [System.IO.Path]::GetFullPath($TargetPath)
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

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..\..')).Path
$launcherBatch = Join-Path $repoRoot 'Tools\PullReference\PullReference.bat'

Invoke-TestCase -Name 'RequiredFilesExist' -Body {
    Assert-True -Condition (Test-Path -LiteralPath $launcherBatch -PathType Leaf) `
        -Message 'PullReference.bat should exist.'
}

Invoke-TestCase -Name 'ListIncludesHazelightDocs' -Body {
    $run = Invoke-CapturedProcess -FilePath 'cmd.exe' -ArgumentList @(
        '/c',
        $launcherBatch,
        'list'
    ) -WorkingDirectory $repoRoot

    $combined = $run.StdOut + $run.StdErr
    Assert-Equal -Expected 0 -Actual $run.ExitCode `
        -Message ('PullReference list should exit successfully. Output: {0}' -f $combined)
    Assert-True -Condition ($combined -match 'hazelightdocs\s+- Pull Hazelight public docs into Reference\\Docs-UnrealEngine-Angelscript') `
        -Message ('PullReference list should mention hazelightdocs. Output: {0}' -f $combined)
    Assert-True -Condition ($combined -match 'hazelightvscode\s+- Pull Hazelight VS Code extension into Reference\\vscode-unreal-angelscript') `
        -Message ('PullReference list should mention hazelightvscode. Output: {0}' -f $combined)
}

Invoke-TestCase -Name 'UsageIncludesHazelightDocs' -Body {
    $run = Invoke-CapturedProcess -FilePath 'cmd.exe' -ArgumentList @(
        '/c',
        $launcherBatch
    ) -WorkingDirectory $repoRoot

    $combined = $run.StdOut + $run.StdErr
    Assert-Equal -Expected 1 -Actual $run.ExitCode `
        -Message ('PullReference without arguments should show usage. Output: {0}' -f $combined)
    Assert-True -Condition ($combined -match 'Tools\\PullReference\\PullReference\.bat hazelightdocs') `
        -Message ('Usage output should include hazelightdocs example. Output: {0}' -f $combined)
    Assert-True -Condition ($combined -match 'Tools\\PullReference\\PullReference\.bat hazelightvscode') `
        -Message ('Usage output should include hazelightvscode example. Output: {0}' -f $combined)
}

Invoke-TestCase -Name 'RemoteCloneHazelightDocs' -Body {
    if ($env:PULLREFERENCE_TEST_REMOTE -ne '1') {
        Write-Host '  [skip] Set PULLREFERENCE_TEST_REMOTE=1 to run the live clone test' -ForegroundColor Yellow
        return
    }

    $testRoot = Join-Path $env:TEMP 'AngelscriptProject-PullReferenceSelfTests'
    $targetDir = Join-Path $testRoot 'Docs-UnrealEngine-Angelscript'
    New-Item -ItemType Directory -Path $testRoot -Force | Out-Null
    Remove-TestDirectory -BasePath $testRoot -TargetPath $targetDir

    $run = Invoke-CapturedProcess -FilePath 'cmd.exe' -ArgumentList @(
        '/c',
        $launcherBatch,
        'hazelightdocs',
        $targetDir
    ) -WorkingDirectory $repoRoot

    $combined = $run.StdOut + $run.StdErr
    Assert-Equal -Expected 0 -Actual $run.ExitCode `
        -Message ('Live hazelightdocs clone should succeed. Output: {0}' -f $combined)
    Assert-True -Condition (Test-Path -LiteralPath (Join-Path $targetDir '.git') -PathType Container) `
        -Message 'Live hazelightdocs clone should create a git repository.'
    Assert-True -Condition (Test-Path -LiteralPath (Join-Path $targetDir 'README.md') -PathType Leaf) `
        -Message 'Live hazelightdocs clone should contain README.md.'

    $remoteRun = Invoke-CapturedProcess -FilePath 'git' -ArgumentList @(
        '-C',
        $targetDir,
        'remote',
        'get-url',
        'origin'
    ) -WorkingDirectory $repoRoot

    Assert-Equal -Expected 0 -Actual $remoteRun.ExitCode `
        -Message ('git remote get-url origin should succeed. Output: {0}' -f ($remoteRun.StdOut + $remoteRun.StdErr))
    Assert-Equal -Expected 'git@github.com:Hazelight/Docs-UnrealEngine-Angelscript.git' -Actual $remoteRun.StdOut.Trim() `
        -Message ('Origin remote should point to Hazelight docs repo. Actual: {0}' -f $remoteRun.StdOut.Trim())

    Remove-TestDirectory -BasePath $testRoot -TargetPath $targetDir
}
