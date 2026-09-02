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
        # Windows PowerShell 5.1 has no Process.Kill(bool) overload. taskkill /T
        # is the bounded process-tree fallback on the supported Windows hosts.
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

function New-FreshHardnessSampleCommand {
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
        if ($PSVersionTable.PSEdition -eq 'Desktop') {
            $descendantArguments += @('-ExecutionPolicy', 'Bypass')
        }
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
[Console]::Out.WriteLine(('HARDNESS_PERF_DESCENDANT_PID=' + `$descendant.Id))
[Console]::Out.Flush()
while (`$true) { Start-Sleep -Milliseconds 200 }
"@
    }

    return @"
`$ErrorActionPreference = 'Stop'
Import-Module '$escapedManifest' -Force -ErrorAction Stop
`$context = New-HardnessContext -Mode Current -ProjectRoot '$escapedRoot'
`$route = Get-HardnessCommand -Name 'task.status'
if (`$context.Mode -ne 'Current' -or `$context.ProjectRoot -ne '$escapedRoot' -or `$route.Name -ne 'task.status') { throw 'Fresh-process API validation failed.' }
[Console]::Out.WriteLine(('HARDNESS_PERF_CHILD_PID=' + `$PID))
[Console]::Out.Flush()
$probeCommand
[Console]::Out.WriteLine('HARDNESS_PERF_OK')
"@
}

function Invoke-FreshHardnessProcessSample {
    param(
        [string]$PowerShellExecutable,
        [string]$ManifestPath,
        [string]$RootPath,
        [int]$TimeoutMs,
        [string]$ProbeMode
    )
    $sampleCommand = New-FreshHardnessSampleCommand `
        -PowerShellExecutable $PowerShellExecutable `
        -ManifestPath $ManifestPath `
        -RootPath $RootPath `
        -ProbeMode $ProbeMode
    $encodedCommand = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($sampleCommand))
    $arguments = @('-NoLogo', '-NoProfile', '-NonInteractive')
    if ($PSVersionTable.PSEdition -eq 'Desktop') {
        $arguments += @('-ExecutionPolicy', 'Bypass')
    }
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
            elseif ($standardOutput -notmatch '(?m)^HARDNESS_PERF_OK\r?$') {
                $failureKind = 'CorrectnessMarker'
            }
        }

        $ownedProcessIds = New-Object System.Collections.Generic.List[int]
        if ($processId -gt 0) { $ownedProcessIds.Add($processId) | Out-Null }
        foreach ($match in [regex]::Matches($standardOutput, '(?m)^HARDNESS_PERF_(?:CHILD|DESCENDANT)_PID=(\d+)\r?$')) {
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

$manifest = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\scripts\Hardness.psd1'))
Assert-PerformanceCondition (Test-Path -LiteralPath $manifest -PathType Leaf) 'Hardness module manifest must exist'

if ([string]::IsNullOrWhiteSpace($OutputRoot)) {
    $OutputRoot = Join-Path $ProjectRoot 'Saved\Harness\Hardness\Performance'
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
}

$hostExecutable = (Get-Process -Id $PID).Path
Assert-PerformanceCondition (Test-Path -LiteralPath $hostExecutable -PathType Leaf) 'current PowerShell executable must be resolvable'

$taskContext = $null
$effectiveTaskChange = $TaskChange
$taskFixtureRoot = ''
Import-Module $manifest -Force -ErrorAction Stop
try {
    $context = New-HardnessContext -Mode Current -ProjectRoot $ProjectRoot
    Assert-PerformanceCondition ($context.Mode -eq 'Current') 'persistent context must use Current mode'
    Assert-PerformanceCondition ($context.ProjectRoot -eq $ProjectRoot) 'persistent context must use ProjectRoot'

    if ([string]::IsNullOrWhiteSpace($effectiveTaskChange)) {
        $temporaryRoot = [System.IO.Path]::GetFullPath([System.IO.Path]::GetTempPath()).TrimEnd('\', '/') + [System.IO.Path]::DirectorySeparatorChar
        $taskFixtureRoot = [System.IO.Path]::GetFullPath((Join-Path $temporaryRoot ('hardness-performance-task-' + [guid]::NewGuid().ToString('N'))))
        Assert-PerformanceCondition ($taskFixtureRoot.StartsWith($temporaryRoot, [System.StringComparison]::OrdinalIgnoreCase)) 'TaskStatus fixture escaped the system temp directory'

        $sourceOpenSpec = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..\openspec\bin\openspec.exe'))
        Assert-PerformanceCondition (Test-Path -LiteralPath $sourceOpenSpec -PathType Leaf) 'packaged OpenSpec is required for the TaskStatus fixture'
        $fixtureExeDirectory = Join-Path $taskFixtureRoot '.agents\skills\openspec\bin'
        [void](New-Item -ItemType Directory -Path $fixtureExeDirectory -Force)
        $fixtureExe = Join-Path $fixtureExeDirectory 'openspec.exe'
        Copy-Item -LiteralPath $sourceOpenSpec -Destination $fixtureExe

        $initOutput = @(& $fixtureExe init $taskFixtureRoot --project-id hardness-performance-fixture --title 'Hardness Performance Fixture' --workflow spec-driven --language en 2>&1)
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

        $taskSeparator = [string][char]0x2014
        $tasksPath = Join-Path $taskFixtureRoot 'openspec\changes\fixture\performance\tasks.md'
        $tasksDocument = @'
---
task_graph:
  version: 1
  depends_on:
    "1.1": []
---

## Tasks

- [ ] 1.1 Measure TaskStatus __TASK_SEPARATOR__ verify: `fixture`
  > Files: `fixture`
'@
        $tasksDocument = $tasksDocument.Replace('__TASK_SEPARATOR__', $taskSeparator)
        [System.IO.File]::WriteAllText($tasksPath, $tasksDocument, [System.Text.UTF8Encoding]::new($false))

        $effectiveTaskChange = 'fixture/performance'
        $taskContext = New-HardnessContext -Mode Current -ProjectRoot $taskFixtureRoot
    }
    else {
        $taskContext = $context
    }

    $stopFreshScenario = $false
    foreach ($phase in @('Warmup', 'Measurement')) {
        $runCount = if ($phase -eq 'Warmup') { $WarmupRuns } else { $MeasurementRuns }
        for ($iteration = 1; $iteration -le $runCount; $iteration++) {
            $sampleResult = Invoke-FreshHardnessProcessSample `
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

    foreach ($phase in @('Warmup', 'Measurement')) {
        $runCount = if ($phase -eq 'Warmup') { $WarmupRuns } else { $MeasurementRuns }
        for ($iteration = 1; $iteration -le $runCount; $iteration++) {
            $timer = [System.Diagnostics.Stopwatch]::StartNew()
            for ($operation = 0; $operation -lt $BatchSize; $operation++) {
                $apiContext = New-HardnessContext -Mode Current -ProjectRoot $ProjectRoot
                $route = Get-HardnessCommand -Name 'task.status'
                Assert-PerformanceCondition ($apiContext.Mode -eq 'Current' -and $apiContext.ProjectRoot -eq $ProjectRoot) 'persistent context lookup returned incorrect data'
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
            $result = Invoke-Hardness -Command 'task.status' -Context $taskContext -Parameters @{ Change = $effectiveTaskChange }
            $timer.Stop()
            Assert-PerformanceCondition ($result.status -eq 'Succeeded' -and $result.exitCode -eq 0) "task.status failed for '$effectiveTaskChange'"
            Assert-PerformanceCondition ($result.data.changeId -eq $effectiveTaskChange) 'task.status returned a different change'
            Assert-PerformanceCondition ($null -ne $result.data.tasks -and @($result.data.tasks).Count -gt 0) 'task.status returned no parsed tasks'
            $value = [double]$timer.Elapsed.TotalMilliseconds
            Add-PerformanceSample -Samples $samples -Scenario 'TaskStatus' -Phase $phase -Iteration $iteration -Unit 'ms' -Value $value
            if ($phase -eq 'Measurement') { $scenarioValues.TaskStatus.Add($value) | Out-Null }
        }
    }
}
finally {
    Remove-Module Hardness -Force -ErrorAction SilentlyContinue
    if (-not [string]::IsNullOrWhiteSpace($taskFixtureRoot) -and (Test-Path -LiteralPath $taskFixtureRoot)) {
        $temporaryRoot = [System.IO.Path]::GetFullPath([System.IO.Path]::GetTempPath()).TrimEnd('\', '/') + [System.IO.Path]::DirectorySeparatorChar
        $resolvedFixture = [System.IO.Path]::GetFullPath($taskFixtureRoot)
        if (-not $resolvedFixture.StartsWith($temporaryRoot, [System.StringComparison]::OrdinalIgnoreCase) -or
            -not ([System.IO.Path]::GetFileName($resolvedFixture)).StartsWith('hardness-performance-task-', [System.StringComparison]::Ordinal)) {
            throw "Refusing to clean an unexpected TaskStatus fixture path: $resolvedFixture"
        }
        Remove-Item -LiteralPath $resolvedFixture -Recurse -Force
    }
}

$scenarioSummaries = @(
    New-ScenarioSummary -Name 'FreshProcess' -Metric 'Hardness import plus context and route lookup' -Unit 'ms' -OperationsPerSample 1 -Values @($scenarioValues.FreshProcess) -P95Budget $FreshProcessP95BudgetMs
    New-ScenarioSummary -Name 'PersistentApi' -Metric 'Context plus route lookup batch' -Unit 'us/op' -OperationsPerSample $BatchSize -Values @($scenarioValues.PersistentApi) -P95Budget $PersistentApiP95BudgetUsPerOp
    New-ScenarioSummary -Name 'TaskStatus' -Metric 'Real task.status route' -Unit 'ms' -OperationsPerSample 1 -Values @($scenarioValues.TaskStatus) -P95Budget $TaskStatusP95BudgetMs
)
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
    RecordType    = 'HardnessPerformanceRaw'
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
        RecordType    = 'HardnessPerformanceFailures'
        RunId         = $RunId
        Failures      = @($failures.ToArray())
    }
    $failuresJson = $failureRecord | ConvertTo-Json -Depth 10
    Write-AtomicUtf8File -Path $failuresPath -Content ($failuresJson + [Environment]::NewLine)
}
Write-AtomicUtf8File -Path $summaryPath -Content ($summaryJson + [Environment]::NewLine)

Write-Output $summary
Write-Output "Hardness performance artifacts: $runDirectory"

if ($failedCorrectness.Count -gt 0) {
    throw "Hardness fresh-process correctness failed: $($failedCorrectness.Kind -join ', ')"
}
if ($failedBudgets.Count -gt 0) {
    throw "Hardness performance disaster budget failed: $($failedBudgets.Name -join ', ')"
}
