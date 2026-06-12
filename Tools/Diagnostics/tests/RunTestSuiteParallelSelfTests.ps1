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

function New-ParallelRunnerFixture {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ProjectRoot
    )

    $toolsRoot = Join-Path $ProjectRoot 'Tools'
    $sharedRoot = Join-Path $toolsRoot 'Shared'
    $intermediateRoot = Join-Path $ProjectRoot 'Intermediate'
    $savedRoot = Join-Path $ProjectRoot 'Saved'

    New-Item -ItemType Directory -Path $sharedRoot -Force | Out-Null
    New-Item -ItemType Directory -Path $intermediateRoot -Force | Out-Null
    New-Item -ItemType Directory -Path $savedRoot -Force | Out-Null

    Copy-Item -LiteralPath (Join-Path $repoRoot 'Tools\RunTestSuiteParallel.ps1') -Destination $toolsRoot
    Copy-Item -LiteralPath (Join-Path $repoRoot 'Tools\Shared\UnrealCommandUtils.ps1') -Destination $sharedRoot
    Copy-Item -LiteralPath (Join-Path $repoRoot 'Tools\Shared\TestShardPlanner.ps1') -Destination $sharedRoot
    Copy-Item -LiteralPath (Join-Path $repoRoot 'Tools\Shared\TestSuiteDefinitions.ps1') -Destination $sharedRoot
    Copy-Item -LiteralPath (Join-Path $repoRoot 'Tools\Shared\TestLaunchProfile.ps1') -Destination $sharedRoot

    Set-Content -LiteralPath (Join-Path $ProjectRoot 'DummyProject.uproject') -Encoding UTF8 -Value @'
{"FileVersion":3,"EngineAssociation":"5.7","Category":"","Description":""}
'@

    Set-Content -LiteralPath (Join-Path $ProjectRoot 'AgentConfig.ini') -Encoding UTF8 -Value @"
[Paths]
EngineRoot=C:\DummyEngine
ProjectFile=$($ProjectRoot.Replace('\', '\\'))\DummyProject.uproject

[Test]
DefaultTimeoutMs=600000
"@

    Set-Content -LiteralPath (Join-Path $intermediateRoot 'TargetInfo.json') -Encoding UTF8 -Value @'
{"Targets":[{"Path":"DummyTarget"}]}
'@

    Set-Content -LiteralPath (Join-Path $toolsRoot 'RunTests.ps1') -Encoding UTF8 -Value @'
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$TestPrefix,

    [string]$Label = '',

    [string]$OutputRoot = '',

    [int]$TimeoutMs = 0,

    [int]$ExecutionSlot = 0,

    [switch]$Fast,

    [switch]$Render,

    [switch]$NoReport,

    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$ExtraArgs = @()
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$runId = '{0}_{1:yyyyMMdd_HHmmss_fff}_{2}' -f $Label, (Get-Date), ([guid]::NewGuid().ToString('N').Substring(0,8))
$outputRoot = Join-Path $projectRoot ('Saved\Tests\{0}\{1}' -f $Label, $runId)
New-Item -ItemType Directory -Path $outputRoot -Force | Out-Null

[PSCustomObject]@{
    BucketName    = $TestPrefix
    ExitCode      = 0
    Passed        = 1
    Failed        = 0
    Total         = 1
    SummarySource = 'ReportJson'
} | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath (Join-Path $outputRoot 'Summary.json') -Encoding UTF8

[PSCustomObject]@{
    Label         = $Label
    Target        = $TestPrefix
    ExecutionSlot = $ExecutionSlot
    DurationMs    = 10
} | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath (Join-Path $outputRoot 'RunMetadata.json') -Encoding UTF8

exit 0
'@
}

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..\..')).Path
$testRoot = Join-Path ([System.IO.Path]::GetTempPath()) ('run-testsuiteparallel-selftests-' + [System.Guid]::NewGuid().ToString('N'))
$fixtureRoot = Join-Path $testRoot 'fixture'
$runnerScript = Join-Path $fixtureRoot 'Tools\RunTestSuiteParallel.ps1'

Invoke-TestCase -Name 'ParallelSummarySerializesShardArray' -Body {
    New-ParallelRunnerFixture -ProjectRoot $fixtureRoot

    $run = Invoke-CapturedProcess -FilePath 'powershell.exe' -ArgumentList @(
        '-NoProfile',
        '-ExecutionPolicy', 'Bypass',
        '-File', $runnerScript,
        '-Suite', 'Smoke',
        '-LabelPrefix', 'repro',
        '-TimeoutMs', '600000',
        '-ContinueOnFail'
    ) -WorkingDirectory $fixtureRoot

    $combined = $run.StdOut + $run.StdErr
    Assert-Equal -Expected 0 -Actual $run.ExitCode `
        -Message ('Parallel suite runner should exit successfully. Output: {0}' -f $combined)

    $summaryPath = Get-ChildItem -Path (Join-Path $fixtureRoot 'Saved\Tests') -Recurse -Filter 'ParallelSuiteSummary.json' |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 1
    Assert-True -Condition ($null -ne $summaryPath -and (Test-Path -LiteralPath $summaryPath.FullName -PathType Leaf)) `
        -Message ('Parallel suite runner should write ParallelSuiteSummary.json. Output: {0}' -f $combined)

    $summary = Get-Content -LiteralPath $summaryPath.FullName -Raw | ConvertFrom-Json
    $suiteDefinitionsPath = Join-Path $fixtureRoot 'Tools\Shared\TestSuiteDefinitions.ps1'
    $testShardPlannerPath = Join-Path $fixtureRoot 'Tools\Shared\TestShardPlanner.ps1'
    . $suiteDefinitionsPath
    . $testShardPlannerPath
    $expectedShardCount = @(Get-AngelscriptCoarseDynamicPlan -ProjectRoot $fixtureRoot -WorkerCount 4).Entries.Count
    Assert-Equal -Expected $expectedShardCount -Actual ([int]$summary.ShardCount) `
        -Message ('Parallel suite runner should record all shard results. Output: {0}' -f $combined)
    Assert-Equal -Expected 0 -Actual ([int]$summary.FailedShardCount) `
        -Message ('Parallel suite runner should record no failed shards. Output: {0}' -f $combined)
    Assert-Equal -Expected $expectedShardCount -Actual ([int]$summary.AggregatedPassed) `
        -Message ('Parallel suite runner should aggregate passed tests. Output: {0}' -f $combined)
    Assert-True -Condition ($combined -match 'Parallel Suite Summary') `
        -Message ('Parallel suite runner should print its summary block. Output: {0}' -f $combined)
}

Remove-TestDirectory -BasePath ([System.IO.Path]::GetTempPath()) -TargetPath $testRoot
Write-Host 'RunTestSuiteParallel self-tests passed.'
