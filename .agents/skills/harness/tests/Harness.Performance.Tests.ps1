#requires -Version 7.0

[CmdletBinding()]
param(
    [ValidateRange(0, 1000)]
    [int]$WarmupRuns = 3,

    [ValidateRange(1, 10000)]
    [int]$MeasurementRuns = 15,

    [ValidateRange(1, 100000)]
    [int]$BatchSize = 1000,

    [string]$ProjectRoot = '',

    [string]$OutputRoot = '',

    [ValidatePattern('^[A-Za-z0-9][A-Za-z0-9._-]{0,127}$')]
    [string]$RunId = '',

    [ValidateScript({ [string]::IsNullOrWhiteSpace($_) -or $_ -match '^[A-Za-z0-9][A-Za-z0-9._/-]{0,255}$' })]
    [string]$TaskChange = '',

    [ValidateRange(1, 600000)]
    [double]$FreshProcessP95BudgetMs = 5000,

    [ValidateRange(1, 600000)]
    [double]$PersistentApiP95BudgetUsPerOp = 5000,

    [ValidateRange(1, 600000)]
    [double]$TaskStatusP95BudgetMs = 2000,

    [ValidateRange(1, 600000)]
    [double]$FastWorkspaceStatusP95BudgetMs = 10000,

    [ValidateRange(1, 600000)]
    [double]$HarnessStatusP95BudgetMs = 10000,

    [ValidateRange(1, 600000)]
    [double]$DetailedWorkspaceStatusP95BudgetMs = 180000,

    [ValidateRange(1, 600000)]
    [double]$ObservationWriteP95BudgetMs = 10000,

    [ValidateRange(1, 600000)]
    [double]$EvolutionStatusP95BudgetMs = 10000,

    [ValidateRange(100, 600000)]
    [int]$FreshProcessTimeoutMs = 30000,

    [ValidateSet('Normal', 'HangTree', 'Flood')]
    [string]$FreshProcessProbeMode = 'Normal'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Assert-PerformanceCondition {
    param([bool]$Condition, [string]$Message)
    if (-not $Condition) {
        throw "Performance sample correctness check failed: $Message"
    }
}

function Get-PercentileNearestRank {
    param([double[]]$Values, [double]$Percentile)
    if ($Values.Count -eq 0) { throw 'A percentile requires at least one value.' }
    $ordered = @($Values | Sort-Object)
    $index = [Math]::Max(0, [Math]::Ceiling($Percentile * $ordered.Count) - 1)
    return [double]$ordered[$index]
}

function Get-Median {
    param([double[]]$Values)
    if ($Values.Count -eq 0) { throw 'A median requires at least one value.' }
    $ordered = @($Values | Sort-Object)
    $middle = [Math]::Floor($ordered.Count / 2)
    if (($ordered.Count % 2) -eq 1) {
        return [double]$ordered[$middle]
    }
    return ([double]$ordered[$middle - 1] + [double]$ordered[$middle]) / 2.0
}

function New-ScenarioSummary {
    param(
        [string]$Name,
        [string]$Metric,
        [string]$Unit,
        [int]$OperationsPerSample,
        [double[]]$Values,
        [double]$P95Budget
    )
    $minimum = [double]($Values | Measure-Object -Minimum).Minimum
    $maximum = [double]($Values | Measure-Object -Maximum).Maximum
    $median = Get-Median -Values $Values
    $p95 = Get-PercentileNearestRank -Values $Values -Percentile 0.95
    [pscustomobject][ordered]@{
        Name                = $Name
        Metric              = $Metric
        Unit                = $Unit
        WarmupRuns          = $WarmupRuns
        MeasurementRuns     = $MeasurementRuns
        OperationsPerSample = $OperationsPerSample
        Min                 = [Math]::Round($minimum, 6)
        Median              = [Math]::Round($median, 6)
        P95                 = [Math]::Round($p95, 6)
        Max                 = [Math]::Round($maximum, 6)
        P95Budget           = [Math]::Round($P95Budget, 6)
        BudgetStatus        = $(if ($p95 -le $P95Budget) { 'Passed' } else { 'Failed' })
    }
}

function Write-AtomicUtf8File {
    param([string]$Path, [string]$Content)
    if (Test-Path -LiteralPath $Path) {
        throw "Refusing to overwrite performance artifact: $Path"
    }
    $directory = Split-Path -Parent $Path
    $temporaryPath = Join-Path $directory ('.{0}.{1}.tmp' -f ([System.IO.Path]::GetFileName($Path)), [guid]::NewGuid().ToString('N'))
    try {
        [System.IO.File]::WriteAllText($temporaryPath, $Content, [System.Text.UTF8Encoding]::new($false))
        [System.IO.File]::Move($temporaryPath, $Path)
    }
    finally {
        if (Test-Path -LiteralPath $temporaryPath) {
            Remove-Item -LiteralPath $temporaryPath -Force
        }
    }
}

function Wait-RedirectedTasks {
    param(
        [object[]]$Tasks,
        [int]$TimeoutMs
    )
    if (@($Tasks).Count -eq 0) { return $true }
    try {
        return [System.Threading.Tasks.Task]::WaitAll(
            [System.Threading.Tasks.Task[]]@($Tasks),
            [Math]::Max(0, $TimeoutMs))
    }
    catch {
        return $false
    }
}

function Get-RedirectedTaskText {
    param([object]$Task)
    if ($null -eq $Task) { return '' }
    if ($Task.Status -ne [System.Threading.Tasks.TaskStatus]::RanToCompletion) { return '' }
    return [string]$Task.Result
}

function Stop-PerformanceOwnedProcessTree {
    param([System.Diagnostics.Process]$Process)

    $strategy = 'AlreadyExited'
    $processExited = $false
    try { $processExited = $Process.HasExited } catch { $processExited = $true }
    if ($processExited) {
        return [pscustomobject]@{ Strategy = $strategy; ProcessExited = $true }
    }

    try {
        $Process.Kill($true)
        $strategy = 'KillTree'
        [void]$Process.WaitForExit(5000)
    }
    catch {
        # taskkill /T remains the bounded Windows fallback if Kill(true) fails.
    }

    try { $processExited = $Process.HasExited } catch { $processExited = $true }
    if (-not $processExited -and $env:OS -eq 'Windows_NT') {
        $taskKillPath = Join-Path $env:SystemRoot 'System32\taskkill.exe'
        if (Test-Path -LiteralPath $taskKillPath -PathType Leaf) {
            $killer = New-Object System.Diagnostics.Process
            try {
                $killer.StartInfo = New-Object System.Diagnostics.ProcessStartInfo
                $killer.StartInfo.FileName = $taskKillPath
                $killer.StartInfo.Arguments = "/PID $($Process.Id) /T /F"
                $killer.StartInfo.UseShellExecute = $false
                $killer.StartInfo.CreateNoWindow = $true
                [void]$killer.Start()
                if (-not $killer.WaitForExit(5000)) {
                    try { $killer.Kill() } catch { }
                }
                $strategy = 'TaskKillTree'
            }
            finally {
                $killer.Dispose()
            }
            [void]$Process.WaitForExit(3000)
        }
    }

    try { $processExited = $Process.HasExited } catch { $processExited = $true }
    if (-not $processExited) {
        try {
            $Process.Kill()
            $strategy = 'KillProcessFallback'
            [void]$Process.WaitForExit(2000)
        }
        catch { }
    }
    try { $processExited = $Process.HasExited } catch { $processExited = $true }
    return [pscustomobject]@{ Strategy = $strategy; ProcessExited = $processExited }
}

function New-FreshHarnessSampleCommand {
    param(
        [string]$PowerShellExecutable,
        [string]$ManifestPath,
        [string]$RootPath,
        [string]$ProbeMode
    )

    $escapedExecutable = $PowerShellExecutable.Replace("'", "''")
    $escapedManifest = $ManifestPath.Replace("'", "''")
    $escapedRoot = $RootPath.Replace("'", "''")
    $probeCommand = ''
    if ($ProbeMode -eq 'Flood') {
        $probeCommand = @"
[Console]::Out.Write(('O' * 1048576))
[Console]::Out.WriteLine()
[Console]::Out.Flush()
[Console]::Error.Write(('E' * 1048576))
[Console]::Error.Flush()
"@
    }
    elseif ($ProbeMode -eq 'HangTree') {
        $descendantCommand = "while (`$true) { Start-Sleep -Milliseconds 200 }"
        $descendantEncodedCommand = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($descendantCommand))
        $descendantArguments = @('-NoLogo', '-NoProfile', '-NonInteractive')
        $descendantArguments += @('-EncodedCommand', $descendantEncodedCommand)
        $escapedDescendantArguments = ($descendantArguments -join ' ').Replace("'", "''")
        $probeCommand = @"
`$descendantStartInfo = New-Object System.Diagnostics.ProcessStartInfo
`$descendantStartInfo.FileName = '$escapedExecutable'
`$descendantStartInfo.Arguments = '$escapedDescendantArguments'
`$descendantStartInfo.WorkingDirectory = '$escapedRoot'
`$descendantStartInfo.UseShellExecute = `$false
`$descendantStartInfo.CreateNoWindow = `$true
`$descendant = New-Object System.Diagnostics.Process
`$descendant.StartInfo = `$descendantStartInfo
[void]`$descendant.Start()
[Console]::Out.WriteLine(('HARNESS_PERF_DESCENDANT_PID=' + `$descendant.Id))
[Console]::Out.Flush()
while (`$true) { Start-Sleep -Milliseconds 200 }
"@
    }

    return @"
`$ErrorActionPreference = 'Stop'
Import-Module '$escapedManifest' -Force -ErrorAction Stop
`$context = New-HarnessContext -WorkspaceRoot '$escapedRoot'
`$route = Get-HarnessCommand -Name 'task.status'
if (`$context.WorkspaceRoot -ne '$escapedRoot' -or `$context.Topology -notin @('Primary', 'Worktree') -or `$route.Name -ne 'task.status') { throw 'Fresh-process API validation failed.' }
[Console]::Out.WriteLine(('HARNESS_PERF_CHILD_PID=' + `$PID))
[Console]::Out.Flush()
$probeCommand
[Console]::Out.WriteLine('HARNESS_PERF_OK')
"@
}

function Invoke-FreshHarnessProcessSample {
    param(
        [string]$PowerShellExecutable,
        [string]$ManifestPath,
        [string]$RootPath,
        [int]$TimeoutMs,
        [string]$ProbeMode
    )
    $sampleCommand = New-FreshHarnessSampleCommand `
        -PowerShellExecutable $PowerShellExecutable `
        -ManifestPath $ManifestPath `
        -RootPath $RootPath `
        -ProbeMode $ProbeMode
    $encodedCommand = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($sampleCommand))
    $arguments = @('-NoLogo', '-NoProfile', '-NonInteractive')
    $arguments += @('-EncodedCommand', $encodedCommand)

    $startInfo = New-Object System.Diagnostics.ProcessStartInfo
    $startInfo.FileName = $PowerShellExecutable
    $startInfo.Arguments = ($arguments -join ' ')
    $startInfo.WorkingDirectory = $RootPath
    $startInfo.UseShellExecute = $false
    $startInfo.CreateNoWindow = $true
    $startInfo.RedirectStandardOutput = $true
    $startInfo.RedirectStandardError = $true

    $process = New-Object System.Diagnostics.Process
    $process.StartInfo = $startInfo
    $timer = [System.Diagnostics.Stopwatch]::StartNew()
    $standardOutputTask = $null
    $standardErrorTask = $null
    $processId = 0
    $timedOut = $false
    $termination = [pscustomobject]@{ Strategy = 'NotRequired'; ProcessExited = $false }
    $failureKind = ''
    $exitCode = $null
    try {
        [void]$process.Start()
        $processId = $process.Id
        # Start both readers before waiting. Sequential ReadToEnd calls can deadlock
        # when the child fills the pipe that is not currently being consumed.
        $standardOutputTask = $process.StandardOutput.ReadToEndAsync()
        $standardErrorTask = $process.StandardError.ReadToEndAsync()

        if (-not $process.WaitForExit($TimeoutMs)) {
            $timedOut = $true
            $failureKind = 'Timeout'
            $termination = Stop-PerformanceOwnedProcessTree -Process $process
        }

        $remainingMs = [Math]::Max(0, $TimeoutMs - [int]$timer.Elapsed.TotalMilliseconds)
        $drainCompleted = Wait-RedirectedTasks -Tasks @($standardOutputTask, $standardErrorTask) -TimeoutMs $remainingMs
        if (-not $drainCompleted) {
            if (-not $timedOut) {
                $failureKind = 'RedirectDrainTimeout'
                $termination = Stop-PerformanceOwnedProcessTree -Process $process
            }
            $drainCompleted = Wait-RedirectedTasks -Tasks @($standardOutputTask, $standardErrorTask) -TimeoutMs 5000
        }

        $timer.Stop()
        $standardOutput = Get-RedirectedTaskText -Task $standardOutputTask
        $standardError = Get-RedirectedTaskText -Task $standardErrorTask
        try {
            if ($process.HasExited) { $exitCode = $process.ExitCode }
        }
        catch { }

        if (-not $timedOut -and $failureKind -eq '') {
            if ($exitCode -ne 0) {
                $failureKind = 'ExitCode'
            }
            elseif ($standardOutput -notmatch '(?m)^HARNESS_PERF_OK\r?$') {
                $failureKind = 'CorrectnessMarker'
            }
        }

        $ownedProcessIds = New-Object System.Collections.Generic.List[int]
        if ($processId -gt 0) { $ownedProcessIds.Add($processId) | Out-Null }
        foreach ($match in [regex]::Matches($standardOutput, '(?m)^HARNESS_PERF_(?:CHILD|DESCENDANT)_PID=(\d+)\r?$')) {
            $ownedProcessIds.Add([int]$match.Groups[1].Value) | Out-Null
        }

        return [pscustomobject][ordered]@{
            ElapsedMs            = [double]$timer.Elapsed.TotalMilliseconds
            Correct              = $failureKind -eq ''
            FailureKind          = $failureKind
            TimeoutMs            = $TimeoutMs
            ProcessId            = $processId
            ExitCode             = $exitCode
            TerminationStrategy  = $termination.Strategy
            ProcessExited        = $(try { $process.HasExited } catch { $termination.ProcessExited })
            OutputDrainCompleted = $drainCompleted
            StandardOutputLength = $standardOutput.Length
            StandardErrorLength  = $standardError.Length
            OwnedProcessIds      = @($ownedProcessIds | Select-Object -Unique)
        }
    }
    catch {
        if ($processId -gt 0) {
            $termination = Stop-PerformanceOwnedProcessTree -Process $process
        }
        $timer.Stop()
        if ($null -ne $standardOutputTask -and $null -ne $standardErrorTask) {
            [void](Wait-RedirectedTasks -Tasks @($standardOutputTask, $standardErrorTask) -TimeoutMs 5000)
        }
        return [pscustomobject][ordered]@{
            ElapsedMs            = [double]$timer.Elapsed.TotalMilliseconds
            Correct              = $false
            FailureKind          = 'ProcessError'
            TimeoutMs            = $TimeoutMs
            ProcessId            = $processId
            ExitCode             = $null
            TerminationStrategy  = $termination.Strategy
            ProcessExited        = $termination.ProcessExited
            OutputDrainCompleted = $false
            StandardOutputLength = 0
            StandardErrorLength  = 0
            OwnedProcessIds      = @($processId | Where-Object { $_ -gt 0 })
        }
    }
    finally {
        if ($timer.IsRunning) { $timer.Stop() }
        $process.Dispose()
    }
}

function Add-PerformanceSample {
    param(
        [System.Collections.Generic.List[object]]$Samples,
        [string]$Scenario,
        [string]$Phase,
        [int]$Iteration,
        [string]$Unit,
        [double]$Value,
        [bool]$Correct = $true
    )
    $Samples.Add([pscustomobject][ordered]@{
        Scenario = $Scenario
        Phase    = $Phase
        Iteration = $Iteration
        Unit     = $Unit
        Value    = [Math]::Round($Value, 6)
        Correct  = $Correct
    }) | Out-Null
}

if ([string]::IsNullOrWhiteSpace($ProjectRoot)) {
    $ProjectRoot = Join-Path $PSScriptRoot '..\..\..\..'
}
$ProjectRoot = [System.IO.Path]::GetFullPath($ProjectRoot)
Assert-PerformanceCondition (Test-Path -LiteralPath $ProjectRoot -PathType Container) 'ProjectRoot must exist'

$manifest = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\scripts\Harness.psd1'))
Assert-PerformanceCondition (Test-Path -LiteralPath $manifest -PathType Leaf) 'Harness module manifest must exist'

if ([string]::IsNullOrWhiteSpace($OutputRoot)) {
    $OutputRoot = Join-Path $ProjectRoot 'Saved\Harness\Performance'
}
$OutputRoot = [System.IO.Path]::GetFullPath($OutputRoot)
if ([string]::IsNullOrWhiteSpace($RunId)) {
    $RunId = '{0}-{1}' -f ([DateTime]::UtcNow.ToString('yyyyMMddTHHmmssfffZ')), [guid]::NewGuid().ToString('N').Substring(0, 8)
}
if ($RunId -notmatch '^[A-Za-z0-9][A-Za-z0-9._-]{0,127}$') {
    throw 'RunId contains unsupported characters.'
}

if (-not (Test-Path -LiteralPath $OutputRoot -PathType Container)) {
    [void](New-Item -ItemType Directory -Path $OutputRoot -Force)
}
$runDirectory = Join-Path $OutputRoot $RunId
if (Test-Path -LiteralPath $runDirectory) {
    throw "Refusing to reuse performance RunId '$RunId'."
}
[void](New-Item -ItemType Directory -Path $runDirectory)

$samples = New-Object System.Collections.Generic.List[object]
$failures = New-Object System.Collections.Generic.List[object]
$scenarioValues = [ordered]@{
    FreshProcess = New-Object System.Collections.Generic.List[double]
    PersistentApi = New-Object System.Collections.Generic.List[double]
    TaskStatus = New-Object System.Collections.Generic.List[double]
    FastWorkspaceStatus = New-Object System.Collections.Generic.List[double]
    HarnessStatus = New-Object System.Collections.Generic.List[double]
    DetailedWorkspaceStatus = New-Object System.Collections.Generic.List[double]
    ObservationWrite = New-Object System.Collections.Generic.List[double]
    EvolutionStatus = New-Object System.Collections.Generic.List[double]
}

$hostExecutable = (Get-Process -Id $PID).Path
Assert-PerformanceCondition (Test-Path -LiteralPath $hostExecutable -PathType Leaf) 'current PowerShell executable must be resolvable'

$taskContext = $null
$effectiveTaskChange = $TaskChange
$taskFixtureRoot = ''
$evolutionContext = $null
$evolutionFixtureRoot = ''
$evolutionChange = 'fixture/evolution-status'
Import-Module $manifest -Force -ErrorAction Stop
try {
    $context = New-HarnessContext -WorkspaceRoot $ProjectRoot
    Assert-PerformanceCondition ($context.WorkspaceRoot -eq $ProjectRoot) 'persistent context must use WorkspaceRoot'
    Assert-PerformanceCondition ($context.Topology -in @('Primary', 'Worktree')) 'persistent context must derive Git topology'

    $temporaryRoot = [System.IO.Path]::GetFullPath([System.IO.Path]::GetTempPath()).TrimEnd('\', '/') + [System.IO.Path]::DirectorySeparatorChar
    $evolutionFixtureRoot = [System.IO.Path]::GetFullPath((Join-Path $temporaryRoot ('harness-performance-evolution-' + [guid]::NewGuid().ToString('N'))))
    Assert-PerformanceCondition ($evolutionFixtureRoot.StartsWith($temporaryRoot, [System.StringComparison]::OrdinalIgnoreCase)) 'EvolutionStatus fixture escaped the system temp directory'
    [void](New-Item -ItemType Directory -Path $evolutionFixtureRoot)
    $evolutionGitInit = @(& git -C $evolutionFixtureRoot init -b main 2>&1)
    Assert-PerformanceCondition ($LASTEXITCODE -eq 0) ("EvolutionStatus fixture git init failed: {0}" -f ($evolutionGitInit -join [Environment]::NewLine))
    [System.IO.File]::WriteAllText((Join-Path $evolutionFixtureRoot '.gitignore'), "Saved/`nAgentConfig.ini`n", [System.Text.UTF8Encoding]::new($false))
    [System.IO.File]::WriteAllText((Join-Path $evolutionFixtureRoot 'Fixture.uproject'), "{}`n", [System.Text.UTF8Encoding]::new($false))
    $evolutionGitAdd = @(& git -C $evolutionFixtureRoot add .gitignore Fixture.uproject 2>&1)
    Assert-PerformanceCondition ($LASTEXITCODE -eq 0) ("EvolutionStatus fixture git add failed: {0}" -f ($evolutionGitAdd -join [Environment]::NewLine))
    $evolutionGitCommit = @(& git -C $evolutionFixtureRoot -c user.name='Harness Performance Fixture' -c user.email=harness-performance@example.invalid commit -m 'fixture baseline' 2>&1)
    Assert-PerformanceCondition ($LASTEXITCODE -eq 0) ("EvolutionStatus fixture git commit failed: {0}" -f ($evolutionGitCommit -join [Environment]::NewLine))

    $sourceOpenSpec = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..\openspec\bin\openspec.exe'))
    Assert-PerformanceCondition (Test-Path -LiteralPath $sourceOpenSpec -PathType Leaf) 'packaged OpenSpec is required for the EvolutionStatus fixture'
    $evolutionInit = @(& $sourceOpenSpec init $evolutionFixtureRoot --project-id harness-performance-evolution --title 'Harness Performance Evolution' --workflow spec-driven --language en 2>&1)
    Assert-PerformanceCondition ($LASTEXITCODE -eq 0) ("EvolutionStatus fixture init failed: {0}" -f ($evolutionInit -join [Environment]::NewLine))
    Push-Location -LiteralPath $evolutionFixtureRoot
    try {
        $evolutionDomain = @(& $sourceOpenSpec domain create fixture --title Fixture --description 'Fixture domain.' --json 2>&1)
        Assert-PerformanceCondition ($LASTEXITCODE -eq 0) ("EvolutionStatus fixture domain creation failed: {0}" -f ($evolutionDomain -join [Environment]::NewLine))
        $evolutionChangeOutput = @(& $sourceOpenSpec change create fixture/evolution-status --title 'Evolution status performance fixture' --goal 'Measure exact evolution status.' --json 2>&1)
        Assert-PerformanceCondition ($LASTEXITCODE -eq 0) ("EvolutionStatus fixture change creation failed: {0}" -f ($evolutionChangeOutput -join [Environment]::NewLine))
    }
    finally {
        Pop-Location
    }

    $evolutionChangeRoot = Join-Path $evolutionFixtureRoot 'openspec\changes\fixture\evolution-status'
    $evolutionChange = 'fixture/evolution-status'
    $evolutionDataRoot = Join-Path $evolutionChangeRoot 'attachments\data'
    [void](New-Item -ItemType Directory -Path $evolutionDataRoot -Force)
    [System.IO.File]::WriteAllText((Join-Path $evolutionChangeRoot 'proposal.md'), "# Proposal`n`nThis stable performance fixture measures exact evolution status after all setup completes.`n", [System.Text.UTF8Encoding]::new($false))
    [System.IO.File]::WriteAllText((Join-Path $evolutionChangeRoot 'tasks.md'), @'
---
task_graph:
  version: 1
  depends_on:
    "1.1": []
---

## Tasks

## [x] 1.1 Measure terminal status

**Files**

```diff
 fixture
```

**Verification**

```sh
fixture
```
'@, [System.Text.UTF8Encoding]::new($false))
    $evolutionEvaluationPath = Join-Path $evolutionDataRoot 'workflow-evaluation.md'
    $evolutionEvaluationTemplate = @'
---
record: harness-workflow-evaluation-v1
result: passed
change: fixture/evolution-status
closure_kind: completed
input_sha256: __INPUT_SHA256__
captured_at: 2026-09-03T18:00:00+08:00
---

# Workflow Evaluation

Body sentinel: result: failed; captured_at: invalid. The measured route must stop at the frontmatter delimiter.
'@
    [System.IO.File]::WriteAllText($evolutionEvaluationPath, $evolutionEvaluationTemplate.Replace('__INPUT_SHA256__', ('0' * 64)), [System.Text.UTF8Encoding]::new($false))
    [System.IO.File]::WriteAllText((Join-Path $evolutionChangeRoot 'attachments\INDEX.md'), @'
# INDEX

## Attachment index

- `data/workflow-evaluation.md` - terminal workflow evaluation fixture.
'@, [System.Text.UTF8Encoding]::new($false))
    $evolutionContext = New-HarnessContext -WorkspaceRoot $evolutionFixtureRoot
    $evolutionOrientation = Invoke-Harness -Command 'harness.evolution.status' -Context $evolutionContext -Parameters @{ Change = 'fixture/evolution-status' }
    Assert-PerformanceCondition ($evolutionOrientation.status -eq 'Succeeded') 'EvolutionStatus fixture could not derive the current input digest'
    Assert-PerformanceCondition ([string]$evolutionOrientation.data.CurrentInputSha256 -match '^[a-f0-9]{64}$') 'EvolutionStatus fixture returned an invalid current input digest'
    [System.IO.File]::WriteAllText($evolutionEvaluationPath, $evolutionEvaluationTemplate.Replace('__INPUT_SHA256__', [string]$evolutionOrientation.data.CurrentInputSha256), [System.Text.UTF8Encoding]::new($false))

    if ([string]::IsNullOrWhiteSpace($effectiveTaskChange)) {
        $taskFixtureRoot = [System.IO.Path]::GetFullPath((Join-Path $temporaryRoot ('harness-performance-task-' + [guid]::NewGuid().ToString('N'))))
        Assert-PerformanceCondition ($taskFixtureRoot.StartsWith($temporaryRoot, [System.StringComparison]::OrdinalIgnoreCase)) 'TaskStatus fixture escaped the system temp directory'

        Assert-PerformanceCondition (Test-Path -LiteralPath $sourceOpenSpec -PathType Leaf) 'packaged OpenSpec is required for the TaskStatus fixture'
        $fixtureExeDirectory = Join-Path $taskFixtureRoot '.agents\skills\openspec\bin'
        [void](New-Item -ItemType Directory -Path $fixtureExeDirectory -Force)
        $fixtureExe = Join-Path $fixtureExeDirectory 'openspec.exe'
        Copy-Item -LiteralPath $sourceOpenSpec -Destination $fixtureExe
        $gitInitOutput = @(& git -C $taskFixtureRoot init -b main 2>&1)
        Assert-PerformanceCondition ($LASTEXITCODE -eq 0) ("TaskStatus fixture git init failed: {0}" -f ($gitInitOutput -join [Environment]::NewLine))
        [System.IO.File]::WriteAllText((Join-Path $taskFixtureRoot '.gitignore'), "Saved/`nAgentConfig.ini`n", [System.Text.UTF8Encoding]::new($false))
        [System.IO.File]::WriteAllText((Join-Path $taskFixtureRoot 'Fixture.uproject'), "{}`n", [System.Text.UTF8Encoding]::new($false))
        foreach ($identity in @(
            @('user.name', 'Harness Performance Fixture'),
            @('user.email', 'harness-performance@example.invalid')
        )) {
            $configOutput = @(& git -C $taskFixtureRoot config $identity[0] $identity[1] 2>&1)
            Assert-PerformanceCondition ($LASTEXITCODE -eq 0) ("TaskStatus fixture git config failed: {0}" -f ($configOutput -join [Environment]::NewLine))
        }
        $addOutput = @(& git -C $taskFixtureRoot add .gitignore Fixture.uproject 2>&1)
        Assert-PerformanceCondition ($LASTEXITCODE -eq 0) ("TaskStatus fixture git add failed: {0}" -f ($addOutput -join [Environment]::NewLine))
        $commitOutput = @(& git -C $taskFixtureRoot commit -m 'fixture baseline' 2>&1)
        Assert-PerformanceCondition ($LASTEXITCODE -eq 0) ("TaskStatus fixture git commit failed: {0}" -f ($commitOutput -join [Environment]::NewLine))

        $initOutput = @(& $fixtureExe init $taskFixtureRoot --project-id harness-performance-fixture --title 'Harness Performance Fixture' --workflow spec-driven --language en 2>&1)
        Assert-PerformanceCondition ($LASTEXITCODE -eq 0) ("TaskStatus fixture init failed: {0}" -f ($initOutput -join [Environment]::NewLine))
        Push-Location -LiteralPath $taskFixtureRoot
        try {
            $domainOutput = @(& $fixtureExe domain create fixture --title Fixture --description Fixture --json 2>&1)
            Assert-PerformanceCondition ($LASTEXITCODE -eq 0) ("TaskStatus fixture domain creation failed: {0}" -f ($domainOutput -join [Environment]::NewLine))
            $changeOutput = @(& $fixtureExe change create fixture/performance --title 'Performance Task Graph' --goal 'Measure the real task.status route' --json 2>&1)
            Assert-PerformanceCondition ($LASTEXITCODE -eq 0) ("TaskStatus fixture change creation failed: {0}" -f ($changeOutput -join [Environment]::NewLine))
        }
        finally {
            Pop-Location
        }
        $tasksPath = Join-Path $taskFixtureRoot 'openspec\changes\fixture\performance\tasks.md'
        $tasksDocument = @'
---
task_graph:
  version: 1
  depends_on:
    "1.1": []
---

## Tasks

## [ ] 1.1 Measure TaskStatus

**Files**

```diff
 fixture
```

**Verification**

```sh
fixture
```
'@
        [System.IO.File]::WriteAllText($tasksPath, $tasksDocument, [System.Text.UTF8Encoding]::new($false))
        $taskChangeRoot = Split-Path $tasksPath -Parent
        $taskMarkerRoot = Join-Path $taskChangeRoot 'attachments/data'
        [void](New-Item -ItemType Directory -Path $taskMarkerRoot -Force)
        [System.IO.File]::WriteAllText((Join-Path $taskMarkerRoot 'harness-origin.json'), '{"schema":1,"changeId":"fixture/performance","origin":"Direct","reason":"Isolated performance fixture"}', [System.Text.UTF8Encoding]::new($false))
        [System.IO.File]::WriteAllText((Join-Path $taskChangeRoot 'design.md'), "## Call chains`n`nnone — parser performance fixture with no code path.`n", [System.Text.UTF8Encoding]::new($false))

        $effectiveTaskChange = 'fixture/performance'
        $taskContext = New-HarnessContext -WorkspaceRoot $taskFixtureRoot
    }
    else {
        $taskContext = $context
    }

    $stopFreshScenario = $false
    foreach ($phase in @('Warmup', 'Measurement')) {
        $runCount = if ($phase -eq 'Warmup') { $WarmupRuns } else { $MeasurementRuns }
        for ($iteration = 1; $iteration -le $runCount; $iteration++) {
            $sampleResult = Invoke-FreshHarnessProcessSample `
                -PowerShellExecutable $hostExecutable `
                -ManifestPath $manifest `
                -RootPath $ProjectRoot `
                -TimeoutMs $FreshProcessTimeoutMs `
                -ProbeMode $FreshProcessProbeMode
            $value = [double]$sampleResult.ElapsedMs
            Add-PerformanceSample `
                -Samples $samples `
                -Scenario 'FreshProcess' `
                -Phase $phase `
                -Iteration $iteration `
                -Unit 'ms' `
                -Value $value `
                -Correct $sampleResult.Correct
            if ($phase -eq 'Measurement' -or -not $sampleResult.Correct) {
                $scenarioValues.FreshProcess.Add($value) | Out-Null
            }
            if (-not $sampleResult.Correct) {
                $failures.Add([pscustomobject][ordered]@{
                    Scenario              = 'FreshProcess'
                    Phase                 = $phase
                    Iteration             = $iteration
                    Kind                  = $sampleResult.FailureKind
                    TimeoutMs             = $sampleResult.TimeoutMs
                    ElapsedMs             = [Math]::Round($sampleResult.ElapsedMs, 6)
                    ProcessId             = $sampleResult.ProcessId
                    ExitCode              = $sampleResult.ExitCode
                    TerminationStrategy    = $sampleResult.TerminationStrategy
                    ProcessExited          = $sampleResult.ProcessExited
                    OutputDrainCompleted   = $sampleResult.OutputDrainCompleted
                    StandardOutputLength   = $sampleResult.StandardOutputLength
                    StandardErrorLength    = $sampleResult.StandardErrorLength
                    OwnedProcessIds        = @($sampleResult.OwnedProcessIds)
                }) | Out-Null
                $stopFreshScenario = $true
                break
            }
        }
        if ($stopFreshScenario) { break }
    }

    if ($FreshProcessProbeMode -eq 'Normal' -and -not $stopFreshScenario) {
        foreach ($phase in @('Warmup', 'Measurement')) {
            $runCount = if ($phase -eq 'Warmup') { $WarmupRuns } else { $MeasurementRuns }
            for ($iteration = 1; $iteration -le $runCount; $iteration++) {
                $timer = [System.Diagnostics.Stopwatch]::StartNew()
                for ($operation = 0; $operation -lt $BatchSize; $operation++) {
                    $route = Get-HarnessCommand -Name 'task.status'
                    Assert-PerformanceCondition ($context.WorkspaceRoot -eq $ProjectRoot) 'persistent context drifted during route lookup'
                    Assert-PerformanceCondition ($route.Name -eq 'task.status') 'persistent route lookup returned the wrong route'
                }
                $timer.Stop()
                $value = ($timer.Elapsed.TotalMilliseconds * 1000.0) / $BatchSize
                Add-PerformanceSample -Samples $samples -Scenario 'PersistentApi' -Phase $phase -Iteration $iteration -Unit 'us/op' -Value $value
                if ($phase -eq 'Measurement') { $scenarioValues.PersistentApi.Add($value) | Out-Null }
            }
        }

    foreach ($phase in @('Warmup', 'Measurement')) {
        $runCount = if ($phase -eq 'Warmup') { $WarmupRuns } else { $MeasurementRuns }
        for ($iteration = 1; $iteration -le $runCount; $iteration++) {
            $timer = [System.Diagnostics.Stopwatch]::StartNew()
            $result = Invoke-Harness -Command 'task.status' -Context $taskContext -Parameters @{ Change = $effectiveTaskChange }
            $timer.Stop()
            Assert-PerformanceCondition ($result.status -eq 'Succeeded' -and $result.exitCode -eq 0) "task.status failed for '$effectiveTaskChange'"
            Assert-PerformanceCondition ($result.data.changeId -eq $effectiveTaskChange) 'task.status returned a different change'
            Assert-PerformanceCondition ($null -ne $result.data.tasks -and @($result.data.tasks).Count -gt 0) 'task.status returned no parsed tasks'
            $value = [double]$timer.Elapsed.TotalMilliseconds
            Add-PerformanceSample -Samples $samples -Scenario 'TaskStatus' -Phase $phase -Iteration $iteration -Unit 'ms' -Value $value
            if ($phase -eq 'Measurement') { $scenarioValues.TaskStatus.Add($value) | Out-Null }
        }
    }

        $statusContext = $taskContext
        foreach ($phase in @('Warmup', 'Measurement')) {
            $runCount = if ($phase -eq 'Warmup') { $WarmupRuns } else { $MeasurementRuns }
            for ($iteration = 1; $iteration -le $runCount; $iteration++) {
                $timer = [System.Diagnostics.Stopwatch]::StartNew()
                $workspaceResult = Invoke-Harness -Command 'workspace.status' -Context $statusContext
                $timer.Stop()
                Assert-PerformanceCondition ($workspaceResult.status -eq 'Succeeded' -and $workspaceResult.exitCode -eq 0) 'fast workspace.status failed'
                Assert-PerformanceCondition ($workspaceResult.data.WorkspaceRoot -eq $statusContext.WorkspaceRoot) 'fast workspace.status targeted a different workspace root'
                Assert-PerformanceCondition ($workspaceResult.data.DetailLevel -eq 'Fast') 'default workspace.status did not remain fast'
                Assert-PerformanceCondition ('Changes' -notin @($workspaceResult.data.PSObject.Properties.Name)) 'fast workspace.status performed detailed change reporting'
                $value = [double]$timer.Elapsed.TotalMilliseconds
                Add-PerformanceSample -Samples $samples -Scenario 'FastWorkspaceStatus' -Phase $phase -Iteration $iteration -Unit 'ms' -Value $value
                if ($phase -eq 'Measurement') { $scenarioValues.FastWorkspaceStatus.Add($value) | Out-Null }
            }
        }

        foreach ($phase in @('Warmup', 'Measurement')) {
            $runCount = if ($phase -eq 'Warmup') { $WarmupRuns } else { $MeasurementRuns }
            for ($iteration = 1; $iteration -le $runCount; $iteration++) {
                $timer = [System.Diagnostics.Stopwatch]::StartNew()
                $statusResult = Invoke-Harness -Command 'harness.status' -Context $statusContext
                $timer.Stop()
                Assert-PerformanceCondition ($statusResult.status -eq 'Succeeded' -and $statusResult.exitCode -eq 0) 'harness.status failed'
                Assert-PerformanceCondition ($statusResult.data.Workspace.WorkspaceRoot -eq $statusContext.WorkspaceRoot) 'harness.status targeted a different workspace root'
                Assert-PerformanceCondition (-not [bool]$statusResult.data.DetailedScan) 'harness.status performed a detailed scan'
                $value = [double]$timer.Elapsed.TotalMilliseconds
                Add-PerformanceSample -Samples $samples -Scenario 'HarnessStatus' -Phase $phase -Iteration $iteration -Unit 'ms' -Value $value
                if ($phase -eq 'Measurement') { $scenarioValues.HarnessStatus.Add($value) | Out-Null }
            }
        }

        foreach ($phase in @('Warmup', 'Measurement')) {
            $runCount = if ($phase -eq 'Warmup') { $WarmupRuns } else { $MeasurementRuns }
            for ($iteration = 1; $iteration -le $runCount; $iteration++) {
                $timer = [System.Diagnostics.Stopwatch]::StartNew()
                $evolutionResult = Invoke-Harness -Command 'harness.evolution.status' -Context $evolutionContext -Parameters @{ Change = $evolutionChange; RequireTerminal = $true }
                $timer.Stop()
                Assert-PerformanceCondition ($evolutionResult.status -eq 'Succeeded' -and $evolutionResult.exitCode -eq 0) ("harness.evolution.status failed: {0}" -f ($evolutionResult | ConvertTo-Json -Depth 5 -Compress))
                Assert-PerformanceCondition ($evolutionResult.data.ChangeId -eq $evolutionChange) 'harness.evolution.status returned a different change'
                Assert-PerformanceCondition ($evolutionResult.data.LatestEvaluationResult -eq 'passed') 'harness.evolution.status did not use workflow-evaluation frontmatter'
                Assert-PerformanceCondition ([bool]$evolutionResult.data.ClosureReady) 'harness.evolution.status fixture was not terminal'
                Assert-PerformanceCondition (-not [bool]$evolutionResult.data.RawBodiesLoaded) 'harness.evolution.status loaded attachment bodies'
                $value = [double]$timer.Elapsed.TotalMilliseconds
                Add-PerformanceSample -Samples $samples -Scenario 'EvolutionStatus' -Phase $phase -Iteration $iteration -Unit 'ms' -Value $value
                if ($phase -eq 'Measurement') { $scenarioValues.EvolutionStatus.Add($value) | Out-Null }
            }
        }

        foreach ($phase in @('Warmup', 'Measurement')) {
            $runCount = if ($phase -eq 'Warmup') { $WarmupRuns } else { $MeasurementRuns }
            for ($iteration = 1; $iteration -le $runCount; $iteration++) {
                $timer = [System.Diagnostics.Stopwatch]::StartNew()
                $detailedResult = Invoke-Harness -Command 'workspace.status' -Context $statusContext -Parameters @{ Detailed = $true }
                $timer.Stop()
                Assert-PerformanceCondition ($detailedResult.status -eq 'Succeeded' -and $detailedResult.exitCode -eq 0) 'detailed workspace.status failed'
                Assert-PerformanceCondition ($detailedResult.data.WorkspaceRoot -eq $statusContext.WorkspaceRoot) 'detailed workspace.status targeted a different workspace root'
                Assert-PerformanceCondition ($detailedResult.data.DetailLevel -eq 'Detailed') 'explicit workspace.status did not perform a detailed scan'
                foreach ($field in @('Changes', 'IgnoredFiles', 'Submodules')) {
                    Assert-PerformanceCondition ($field -in @($detailedResult.data.PSObject.Properties.Name)) "detailed workspace.status omitted $field"
                }
                $value = [double]$timer.Elapsed.TotalMilliseconds
                Add-PerformanceSample -Samples $samples -Scenario 'DetailedWorkspaceStatus' -Phase $phase -Iteration $iteration -Unit 'ms' -Value $value
                if ($phase -eq 'Measurement') { $scenarioValues.DetailedWorkspaceStatus.Add($value) | Out-Null }
            }
        }

        foreach ($phase in @('Warmup', 'Measurement')) {
            $runCount = if ($phase -eq 'Warmup') { $WarmupRuns } else { $MeasurementRuns }
            for ($iteration = 1; $iteration -le $runCount; $iteration++) {
                $timer = [System.Diagnostics.Stopwatch]::StartNew()
                $observationResult = Invoke-Harness -Command 'harness.observe' -Context $statusContext -Parameters @{
                    Category      = 'performance-probe'
                    Summary       = 'Measure the bounded Harness observation write path.'
                    Change        = $effectiveTaskChange
                    Stage         = 'performance'
                    CorrelationId = "performance-$($phase.ToLowerInvariant())-$iteration"
                }
                $timer.Stop()
                Assert-PerformanceCondition ($observationResult.status -eq 'Succeeded' -and $observationResult.exitCode -eq 0) 'harness.observe failed'
                $rawArtifacts = @($observationResult.artifacts | Where-Object { [IO.Path]::GetExtension([string]$_) -eq '.json' })
                $inboxPath = Join-Path $statusContext.WorkspaceRoot 'Saved/Harness/Observations/INBOX.md'
                Assert-PerformanceCondition ($rawArtifacts.Count -eq 1) 'harness.observe did not return exactly one raw JSON artifact'
                Assert-PerformanceCondition (@($observationResult.artifacts).Count -eq 2 -and @($observationResult.artifacts | Where-Object { $_ -eq $inboxPath }).Count -eq 1) 'harness.observe did not return its current feedback inbox alongside the raw JSON'
                $observationPath = [string]$rawArtifacts[0]
                Assert-PerformanceCondition (Test-Path -LiteralPath $observationPath -PathType Leaf) 'harness.observe artifact does not exist'
                Assert-PerformanceCondition (Test-Path -LiteralPath $inboxPath -PathType Leaf) 'harness.observe feedback inbox does not exist'
                $observation = Get-Content -LiteralPath $observationPath -Raw | ConvertFrom-Json -ErrorAction Stop
                Assert-PerformanceCondition ($observation.schemaVersion -eq 'harness-observation-v1') 'harness.observe wrote the wrong schema'
                Assert-PerformanceCondition ($observation.workspaceRoot -eq $statusContext.WorkspaceRoot) 'harness.observe recorded a different workspace root'
                Assert-PerformanceCondition ($observation.category -eq 'performance-probe') 'harness.observe recorded the wrong category'
                Assert-PerformanceCondition ([IO.File]::ReadAllText($inboxPath).Contains($observation.runId)) 'harness.observe feedback inbox omits the new observation'
                $value = [double]$timer.Elapsed.TotalMilliseconds
                Add-PerformanceSample -Samples $samples -Scenario 'ObservationWrite' -Phase $phase -Iteration $iteration -Unit 'ms' -Value $value
                if ($phase -eq 'Measurement') { $scenarioValues.ObservationWrite.Add($value) | Out-Null }
            }
        }
    }
}
finally {
    Remove-Module Harness -Force -ErrorAction SilentlyContinue
    if (-not [string]::IsNullOrWhiteSpace($taskFixtureRoot) -and (Test-Path -LiteralPath $taskFixtureRoot)) {
        $temporaryRoot = [System.IO.Path]::GetFullPath([System.IO.Path]::GetTempPath()).TrimEnd('\', '/') + [System.IO.Path]::DirectorySeparatorChar
        $resolvedFixture = [System.IO.Path]::GetFullPath($taskFixtureRoot)
        if (-not $resolvedFixture.StartsWith($temporaryRoot, [System.StringComparison]::OrdinalIgnoreCase) -or
            -not ([System.IO.Path]::GetFileName($resolvedFixture)).StartsWith('harness-performance-task-', [System.StringComparison]::Ordinal)) {
            throw "Refusing to clean an unexpected TaskStatus fixture path: $resolvedFixture"
        }
        Remove-Item -LiteralPath $resolvedFixture -Recurse -Force
    }
    if (-not [string]::IsNullOrWhiteSpace($evolutionFixtureRoot) -and (Test-Path -LiteralPath $evolutionFixtureRoot)) {
        $temporaryRoot = [System.IO.Path]::GetFullPath([System.IO.Path]::GetTempPath()).TrimEnd('\', '/') + [System.IO.Path]::DirectorySeparatorChar
        $resolvedEvolutionFixture = [System.IO.Path]::GetFullPath($evolutionFixtureRoot)
        if (-not $resolvedEvolutionFixture.StartsWith($temporaryRoot, [System.StringComparison]::OrdinalIgnoreCase) -or
            -not ([System.IO.Path]::GetFileName($resolvedEvolutionFixture)).StartsWith('harness-performance-evolution-', [System.StringComparison]::Ordinal)) {
            throw "Refusing to clean an unexpected EvolutionStatus fixture path: $resolvedEvolutionFixture"
        }
        Remove-Item -LiteralPath $resolvedEvolutionFixture -Recurse -Force
    }
}

$scenarioSummaryList = New-Object System.Collections.Generic.List[object]
$scenarioSummaryList.Add((New-ScenarioSummary -Name 'FreshProcess' -Metric 'Harness import plus context and route lookup' -Unit 'ms' -OperationsPerSample 1 -Values @($scenarioValues.FreshProcess) -P95Budget $FreshProcessP95BudgetMs)) | Out-Null
if ($FreshProcessProbeMode -eq 'Normal' -and -not $stopFreshScenario) {
    $scenarioSummaryList.Add((New-ScenarioSummary -Name 'PersistentApi' -Metric 'Persistent route lookup with retained context' -Unit 'us/op' -OperationsPerSample $BatchSize -Values @($scenarioValues.PersistentApi) -P95Budget $PersistentApiP95BudgetUsPerOp)) | Out-Null
    $scenarioSummaryList.Add((New-ScenarioSummary -Name 'TaskStatus' -Metric 'Real task.status route' -Unit 'ms' -OperationsPerSample 1 -Values @($scenarioValues.TaskStatus) -P95Budget $TaskStatusP95BudgetMs)) | Out-Null
    $scenarioSummaryList.Add((New-ScenarioSummary -Name 'FastWorkspaceStatus' -Metric 'Default workspace.status route without detailed scan' -Unit 'ms' -OperationsPerSample 1 -Values @($scenarioValues.FastWorkspaceStatus) -P95Budget $FastWorkspaceStatusP95BudgetMs)) | Out-Null
    $scenarioSummaryList.Add((New-ScenarioSummary -Name 'HarnessStatus' -Metric 'Fast harness.status orientation route' -Unit 'ms' -OperationsPerSample 1 -Values @($scenarioValues.HarnessStatus) -P95Budget $HarnessStatusP95BudgetMs)) | Out-Null
    $scenarioSummaryList.Add((New-ScenarioSummary -Name 'DetailedWorkspaceStatus' -Metric 'Explicit detailed workspace.status scan' -Unit 'ms' -OperationsPerSample 1 -Values @($scenarioValues.DetailedWorkspaceStatus) -P95Budget $DetailedWorkspaceStatusP95BudgetMs)) | Out-Null
    $scenarioSummaryList.Add((New-ScenarioSummary -Name 'ObservationWrite' -Metric 'Bounded ignored harness.observe write' -Unit 'ms' -OperationsPerSample 1 -Values @($scenarioValues.ObservationWrite) -P95Budget $ObservationWriteP95BudgetMs)) | Out-Null
    $scenarioSummaryList.Add((New-ScenarioSummary -Name 'EvolutionStatus' -Metric 'Exact frontmatter-only harness.evolution.status closure gate' -Unit 'ms' -OperationsPerSample 1 -Values @($scenarioValues.EvolutionStatus) -P95Budget $EvolutionStatusP95BudgetMs)) | Out-Null
}
$scenarioSummaries = @($scenarioSummaryList | ForEach-Object { $_ })
$failedBudgets = @($scenarioSummaries | Where-Object BudgetStatus -eq 'Failed')
$failedCorrectness = @($failures.ToArray())

try {
    $architecture = [System.Runtime.InteropServices.RuntimeInformation]::ProcessArchitecture.ToString()
}
catch {
    $architecture = [string]$env:PROCESSOR_ARCHITECTURE
}
$summary = [pscustomobject][ordered]@{
    SchemaVersion = '1.0'
    RecordType    = 'HarnessPerformanceRaw'
    RunId         = $RunId
    CreatedUtc    = [DateTime]::UtcNow.ToString('o')
    PowerShell    = [pscustomobject][ordered]@{
        Edition      = [string]$PSVersionTable.PSEdition
        Version      = [string]$PSVersionTable.PSVersion
        Architecture = $architecture
    }
    Parameters    = [pscustomobject][ordered]@{
        WarmupRuns     = $WarmupRuns
        MeasurementRuns = $MeasurementRuns
        BatchSize      = $BatchSize
        TaskChange     = $effectiveTaskChange
        FreshProcessTimeoutMs = $FreshProcessTimeoutMs
        FreshProcessProbeMode = $FreshProcessProbeMode
        EvolutionStatusP95BudgetMs = $EvolutionStatusP95BudgetMs
    }
    Scenarios     = @($scenarioSummaries)
    OverallStatus = $(if ($failedBudgets.Count -eq 0 -and $failedCorrectness.Count -eq 0) { 'Passed' } else { 'Failed' })
    Artifacts     = $(if ($failedCorrectness.Count -eq 0) { @('Summary.json', 'Samples.csv') } else { @('Summary.json', 'Samples.csv', 'Failures.json') })
}

$summaryPath = Join-Path $runDirectory 'Summary.json'
$samplesPath = Join-Path $runDirectory 'Samples.csv'
$failuresPath = Join-Path $runDirectory 'Failures.json'
$summaryJson = $summary | ConvertTo-Json -Depth 10
$samplesCsv = ($samples.ToArray() | ConvertTo-Csv -NoTypeInformation) -join [Environment]::NewLine
Write-AtomicUtf8File -Path $samplesPath -Content ($samplesCsv + [Environment]::NewLine)
if ($failedCorrectness.Count -gt 0) {
    $failureRecord = [pscustomobject][ordered]@{
        SchemaVersion = '1.0'
        RecordType    = 'HarnessPerformanceFailures'
        RunId         = $RunId
        Failures      = @($failures.ToArray())
    }
    $failuresJson = $failureRecord | ConvertTo-Json -Depth 10
    Write-AtomicUtf8File -Path $failuresPath -Content ($failuresJson + [Environment]::NewLine)
}
Write-AtomicUtf8File -Path $summaryPath -Content ($summaryJson + [Environment]::NewLine)

Write-Output $summary
Write-Output "Harness performance artifacts: $runDirectory"

if ($failedCorrectness.Count -gt 0) {
    throw "Harness fresh-process correctness failed: $($failedCorrectness.Kind -join ', ')"
}
if ($failedBudgets.Count -gt 0) {
    throw "Harness performance disaster budget failed: $($failedBudgets.Name -join ', ')"
}
