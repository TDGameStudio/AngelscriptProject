<#
.SYNOPSIS
    Run Angelscript test suites with tier-aware parallel dispatch.

.DESCRIPTION
    Executes suite prefixes through multiple concurrent RunTests.ps1 workers.
    Light tiers run with higher concurrency; Heavy tiers (full engine / large
  binding surface) run with low concurrency, each in its own ExecutionSlot process.

.PARAMETER Suite
    Built-in suite name (same catalog as RunTestSuite.ps1).

.PARAMETER MaxParallelLight
    Maximum concurrent workers for Light-tier prefixes. Default: 4.

.PARAMETER MaxParallelHeavy
    Maximum concurrent workers for Heavy-tier prefixes. Default: 1.

.PARAMETER ContinueOnFail
    Keep running remaining prefixes after a failure instead of stopping early.

.PARAMETER LabelPrefix
    Output label prefix for each shard run.

.PARAMETER OutputRoot
    Optional output root forwarded to RunTests.ps1.

.PARAMETER TimeoutMs
    Per-prefix timeout forwarded to RunTests.ps1.

.PARAMETER Strategy
    CoarseDynamic = split TestModule across N workers using timing hints (recommended).
    Coarse = 4 top-level shards (legacy; TestModule stays monolithic).
    Monolithic = single editor session with prefix Angelscript.
    Fine = legacy per-prefix suite shards from TestSuiteDefinitions (slow).

.PARAMETER TestModuleWorkers
    Worker count for CoarseDynamic TestModule subdivision. Default: 4.

.PARAMETER ExcludeSlow
    Skip slow TestModule prefixes (Debugger / Performance / HotReload) in CoarseDynamic.

.PARAMETER Fast
    Forward -Fast to each RunTests worker (NullRHI + NoLoadStartupPackages + ...).

.PARAMETER DryRun
    Print planned worker commands without launching editors.
#>
param(
    [string]$Suite = 'All',
    [ValidateSet('CoarseDynamic', 'Coarse', 'Monolithic', 'Fine')]
    [string]$Strategy = 'CoarseDynamic',
    [int]$TestModuleWorkers = 4,
    [int]$MaxParallelLight = 4,
    [int]$MaxParallelHeavy = 4,
    [string]$LabelPrefix = '',
    [string]$OutputRoot = '',
    [int]$TimeoutMs = 0,
    [switch]$Fast,
    [switch]$ExcludeSlow,
    [switch]$ContinueOnFail,
    [switch]$ListSuites,
    [switch]$DryRun
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot 'Shared\TestSuiteDefinitions.ps1')
. (Join-Path $PSScriptRoot 'Shared\TestLaunchProfile.ps1')
. (Join-Path $PSScriptRoot 'Shared\TestShardPlanner.ps1')
. (Join-Path $PSScriptRoot 'Shared\UnrealCommandUtils.ps1')

$runTestsPath = Join-Path $PSScriptRoot 'RunTests.ps1'
$runSuiteEntryPath = Join-Path $PSScriptRoot 'RunTestSuiteEntry.ps1'
if (-not (Test-Path -LiteralPath $runTestsPath -PathType Leaf)) {
    throw "RunTests.ps1 was not found at '$runTestsPath'."
}
if (-not (Test-Path -LiteralPath $runSuiteEntryPath -PathType Leaf)) {
    throw "RunTestSuiteEntry.ps1 was not found at '$runSuiteEntryPath'."
}

if ($ListSuites) {
    Write-AngelscriptTestSuiteCatalog
    exit 0
}

if ($MaxParallelLight -lt 1) {
    throw 'MaxParallelLight must be at least 1.'
}

if ($MaxParallelHeavy -lt 1) {
    throw 'MaxParallelHeavy must be at least 1.'
}

if ($TestModuleWorkers -lt 1) {
    throw 'TestModuleWorkers must be at least 1.'
}

if ($TimeoutMs -lt 0) {
    throw 'TimeoutMs must be zero or a positive integer.'
}

if ($TimeoutMs -gt 3600000) {
    throw 'TimeoutMs cannot exceed 3600000ms.'
}

$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..\..\..')).Path

$workerPlan = $null
$entries = @(switch ($Strategy) {
    'CoarseDynamic' {
        $workerPlan = Get-AngelscriptCoarseDynamicPlan `
            -ProjectRoot $projectRoot `
            -WorkerCount $TestModuleWorkers `
            -ExcludeSlow:$ExcludeSlow
        @($workerPlan.Entries)
    }
    'Coarse' {
        @(Get-AngelscriptTestCoarseShards)
    }
    'Monolithic' {
        @{
            Prefix = (Get-AngelscriptTestMonolithicPrefix)
            Label  = 'Monolithic'
            Tier   = 'Heavy'
        }
    }
    'Fine' {
        @(Get-AngelscriptTestSuiteEntries -SuiteName $Suite)
    }
})
$normalizedEntries = New-Object 'System.Collections.Generic.List[hashtable]'
foreach ($entry in $entries) {
    $normalizedEntry = @{}
    foreach ($key in $entry.Keys) {
        $normalizedEntry[$key] = $entry[$key]
    }
    if (-not $normalizedEntry.ContainsKey('Kind')) {
        $normalizedEntry.Kind = 'UnrealAutomation'
    }
    $normalizedEntries.Add($normalizedEntry)
}
$entries = @($normalizedEntries)
$effectiveLabelPrefix = if ([string]::IsNullOrWhiteSpace($LabelPrefix)) {
    switch ($Strategy) {
        'CoarseDynamic' { 'All-Dynamic' }
        'Coarse' { 'All-Coarse' }
        'Monolithic' { 'All-Monolithic' }
        default { "$Suite-Parallel" }
    }
}
else { $LabelPrefix }
$suiteStartedAt = Get-Date
$summaryRoot = Join-Path $projectRoot ('Saved\Tests/{0}_{1:yyyyMMdd_HHmmss}' -f $effectiveLabelPrefix, $suiteStartedAt)

$requiresUnreal = @($entries | Where-Object { $_.Kind -eq 'UnrealAutomation' }).Count -gt 0
if (-not $DryRun -and $requiresUnreal) {
    $agentConfig = Resolve-AgentConfiguration -ProjectRoot $projectRoot
    $prewarmTimeoutMs = if ($TimeoutMs -gt 0) { [Math]::Min($TimeoutMs, 120000) } else { 120000 }
    $prewarmResult = Ensure-TargetInfoJson `
        -EngineRoot $agentConfig.EngineRoot `
        -ProjectFile $agentConfig.ProjectFile `
        -ProjectRoot $projectRoot `
        -TimeoutMs $prewarmTimeoutMs
    Write-Host ("TargetInfo prewarm : {0} ({1}ms)" -f $prewarmResult.Status, $prewarmResult.DurationMs)
}

Write-Host '================================================================'
Write-Host '  Angelscript Parallel Test Suite Runner'
Write-Host '================================================================'
Write-Host ("Strategy           : {0}" -f $Strategy)
Write-Host ("Suite              : {0}" -f $(if ($Strategy -eq 'Fine') { $Suite } else { '<n/a>' }))
Write-Host ("TestModuleWorkers  : {0}" -f $(if ($Strategy -eq 'CoarseDynamic') { $TestModuleWorkers } else { '<n/a>' }))
Write-Host ("Run count          : {0}" -f $entries.Count)
Write-Host ("MaxParallelLight   : {0}" -f $MaxParallelLight)
Write-Host ("MaxParallelHeavy   : {0}" -f $MaxParallelHeavy)
Write-Host ("FastLaunch         : {0}" -f ([bool]$Fast))
Write-Host ("ExcludeSlow        : {0}" -f ([bool]$ExcludeSlow))
Write-Host ("ContinueOnFail     : {0}" -f ([bool]$ContinueOnFail))
Write-Host ("DryRun             : {0}" -f ([bool]$DryRun))
Write-Host ("SummaryRoot        : {0}" -f $summaryRoot)
Write-Host ("RequiresUnreal     : {0}" -f $requiresUnreal)
Write-Host ("Runners            : UnrealAutomation={0}; typed non-Unreal={1}" -f $runTestsPath, $runSuiteEntryPath)
Write-Host '================================================================'

if ($null -ne $workerPlan) {
    Write-AngelscriptWorkerPlan -Plan $workerPlan
    if (-not $DryRun) {
        New-Item -ItemType Directory -Path $summaryRoot -Force | Out-Null
        $planPath = Join-Path $summaryRoot 'WorkerPlan.json'
        Write-Utf8JsonFile -Path $planPath -Value (ConvertTo-AngelscriptWorkerPlanJson -Plan $workerPlan)
        Write-Host ("WorkerPlanPath     : {0}" -f $planPath)
        Write-Host ''
    }
}

function New-PlannedRun {
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$Entry,

        [Parameter(Mandatory = $true)]
        [int]$Index,

        [Parameter(Mandatory = $true)]
        [int]$ExecutionSlot
    )

    $runLabel = '{0}_{1:D2}_{2}' -f $effectiveLabelPrefix, ($Index + 1), $Entry.Label
    $identity = if ($Entry.Kind -eq 'UnrealAutomation') { $Entry.Prefix } else { "$($Entry.Kind):$($Entry.Label)" }
    return [PSCustomObject]@{
        Index         = $Index
        Entry         = $Entry
        Kind          = $Entry.Kind
        Label         = $Entry.Label
        Identity      = $identity
        Prefix        = if ($Entry.ContainsKey('Prefix')) { $Entry.Prefix } else { '' }
        Tier          = Resolve-AngelscriptTestSuiteEntryTier -Entry $Entry
        RunLabel      = $runLabel
        ExecutionSlot = $ExecutionSlot
        ResultPath    = Join-Path $summaryRoot ('EntryResult_{0:D2}_{1}.json' -f ($Index + 1), $Entry.Label)
    }
}

function Start-PlannedRunProcess {
    param(
        [Parameter(Mandatory = $true)]
        [psobject]$PlannedRun
    )

    if ($PlannedRun.Kind -eq 'UnrealAutomation') {
        $filePath = $runTestsPath
        $argList = @(
            '-NoProfile',
            '-ExecutionPolicy', 'Bypass',
            '-File', $filePath,
            '-TestPrefix', $PlannedRun.Prefix,
            '-Label', $PlannedRun.RunLabel,
            '-ExecutionSlot', $PlannedRun.ExecutionSlot
        )
    }
    elseif ($PlannedRun.Kind -ne 'UnrealAutomation') {
        $entrySuite = $Suite
        $entryIndex = $PlannedRun.Index
        if ($Strategy -ne 'Fine') {
            $entrySuite = 'All'
            $allEntries = @(Get-AngelscriptTestSuiteEntries -SuiteName $entrySuite)
            $entryIndex = -1
            for ($candidateIndex = 0; $candidateIndex -lt $allEntries.Count; ++$candidateIndex) {
                $candidate = $allEntries[$candidateIndex]
                if ($candidate.Kind -eq $PlannedRun.Kind -and
                    $candidate.Label -eq $PlannedRun.Label) {
                    $entryIndex = $candidateIndex
                    break
                }
            }
            if ($entryIndex -lt 0) {
                throw "Typed entry '$($PlannedRun.Identity)' is not present in suite '$entrySuite'."
            }
        }
        $filePath = $runSuiteEntryPath
        $argList = @(
            '-NoProfile',
            '-ExecutionPolicy', 'Bypass',
            '-File', $filePath,
            '-Suite', $entrySuite,
            '-EntryIndex', $entryIndex,
            '-RunLabel', $PlannedRun.RunLabel,
            '-ResultPath', $PlannedRun.ResultPath,
            '-ExecutionSlot', $PlannedRun.ExecutionSlot
        )
    }
    else {
        throw "Unsupported suite entry kind '$($PlannedRun.Kind)'."
    }

    if (-not [string]::IsNullOrWhiteSpace($OutputRoot)) {
        $argList += @('-OutputRoot', $OutputRoot)
    }

    if ($TimeoutMs -gt 0) {
        $argList += @('-TimeoutMs', $TimeoutMs)
    }

    if ($Fast) {
        $argList += '-Fast'
    }

    if ($PlannedRun.Kind -eq 'UnrealAutomation') {
        # Parallel editor processes share Project/Intermediate by default. UE's
        # AssetRegistry writer uses fixed temp/ref names there, so concurrent
        # publication can surface an unrelated LogFileManager error in whichever
        # automation test happens to be active. Keep cache reads, but make every
        # parallel worker read-only for this process-global optimization cache.
        $argList += @('-ExtraArgs', '-NoAssetRegistryCacheWrite')
    }

    if ($DryRun) {
        Write-Host ("[DryRun][slot {0}] powershell.exe {1}" -f $PlannedRun.ExecutionSlot, ($argList -join ' '))
        return $null
    }

    Write-Host ("[start][slot {0}] [{1}] {2} ({3})" -f $PlannedRun.ExecutionSlot, $PlannedRun.Kind, $PlannedRun.Identity, $PlannedRun.Tier)
    $process = Start-Process -FilePath 'powershell.exe' `
        -ArgumentList $argList `
        -WorkingDirectory $projectRoot `
        -PassThru `
        -WindowStyle Hidden

    return [PSCustomObject]@{
        PlannedRun = $PlannedRun
        Process    = $process
        StartedAt  = Get-Date
    }
}

function Get-RunResultFromMetadata {
    param(
        [Parameter(Mandatory = $true)]
        [psobject]$ActiveRun,

        [Parameter(Mandatory = $true)]
        [int]$ProcessExitCode
    )

    $entryResult = $null
    if ($ActiveRun.PlannedRun.Kind -ne 'UnrealAutomation' -and
        (Test-Path -LiteralPath $ActiveRun.PlannedRun.ResultPath -PathType Leaf)) {
        $entryResult = Get-Content -LiteralPath $ActiveRun.PlannedRun.ResultPath -Raw | ConvertFrom-Json
    }

    $metadataPath = if ($null -ne $entryResult -and
        -not [string]::IsNullOrWhiteSpace([string]$entryResult.MetadataPath) -and
        (Test-Path -LiteralPath ([string]$entryResult.MetadataPath) -PathType Leaf)) {
        Get-Item -LiteralPath ([string]$entryResult.MetadataPath)
    }
    elseif ($ActiveRun.PlannedRun.Kind -eq 'UnrealAutomation') {
        Get-ChildItem -Path (Join-Path $projectRoot 'Saved\Tests') -Recurse -Filter 'RunMetadata.json' -ErrorAction SilentlyContinue |
            Where-Object { $_.FullName -like "*$($ActiveRun.PlannedRun.RunLabel)*" } |
            Sort-Object LastWriteTime -Descending |
            Select-Object -First 1
    }
    else {
        $null
    }

    $summaryRecord = $null
    if ($null -ne $entryResult -and
        -not [string]::IsNullOrWhiteSpace([string]$entryResult.SummaryPath) -and
        (Test-Path -LiteralPath ([string]$entryResult.SummaryPath) -PathType Leaf)) {
        $summaryRecord = Get-Content -LiteralPath ([string]$entryResult.SummaryPath) -Raw | ConvertFrom-Json
    }
    elseif ($null -ne $metadataPath) {
        $summaryPath = Join-Path $metadataPath.Directory.FullName 'Summary.json'
        if (Test-Path -LiteralPath $summaryPath -PathType Leaf) {
            $summaryRecord = Get-Content -LiteralPath $summaryPath -Raw | ConvertFrom-Json
        }
    }

    return [PSCustomObject]@{
        Index         = $ActiveRun.PlannedRun.Index
        Kind          = $ActiveRun.PlannedRun.Kind
        Label         = $ActiveRun.PlannedRun.Label
        Identity      = $ActiveRun.PlannedRun.Identity
        Prefix        = $ActiveRun.PlannedRun.Prefix
        Tier          = $ActiveRun.PlannedRun.Tier
        RunLabel      = $ActiveRun.PlannedRun.RunLabel
        ExecutionSlot = $ActiveRun.PlannedRun.ExecutionSlot
        ExitCode      = $ProcessExitCode
        RawExitCode   = if ($null -ne $entryResult) { [int]$entryResult.RawExitCode } else { $ProcessExitCode }
        DurationMs    = [int]((Get-Date) - $ActiveRun.StartedAt).TotalMilliseconds
        MetadataPath  = if ($null -ne $metadataPath) { $metadataPath.FullName } else { $null }
        Passed        = if ($null -ne $summaryRecord -and $null -ne $summaryRecord.Passed) { [int]$summaryRecord.Passed } else { $null }
        Failed        = if ($null -ne $summaryRecord -and $null -ne $summaryRecord.Failed) { [int]$summaryRecord.Failed } else { $null }
        Total         = if ($null -ne $summaryRecord -and $null -ne $summaryRecord.Total) { [int]$summaryRecord.Total } else { $null }
    }
}

$useFixedWorkerSlots = ($Strategy -eq 'CoarseDynamic')
$pending = $null
$pendingBySlot = $null

if ($useFixedWorkerSlots) {
    $pendingBySlot = @{}
    for ($slotIndex = 1; $slotIndex -le $TestModuleWorkers; ++$slotIndex) {
        $pendingBySlot[$slotIndex] = New-Object 'System.Collections.Generic.Queue[object]'
    }

    for ($index = 0; $index -lt $entries.Count; ++$index) {
        $entry = $entries[$index]
        if (-not $entry.ContainsKey('PreferredSlot') -or $null -eq $entry.PreferredSlot) {
            $entryIdentity = if ($entry.Kind -eq 'UnrealAutomation') {
                [string]$entry.Prefix
            }
            else {
                "$($entry.Kind):$($entry.Label)"
            }
            throw "CoarseDynamic entry '$entryIdentity' is missing PreferredSlot."
        }

        $slotIndex = [int]$entry.PreferredSlot
        $pendingBySlot[$slotIndex].Enqueue([PSCustomObject]@{
                Index = $index
                Entry = $entry
            })
    }
}
else {
    $pending = New-Object 'System.Collections.Generic.Queue[object]'
    for ($index = 0; $index -lt $entries.Count; ++$index) {
        $pending.Enqueue([PSCustomObject]@{
                Index = $index
                Entry = $entries[$index]
            })
    }
}

$activeBySlot = @{}
$results = New-Object 'System.Collections.Generic.List[object]'
$slotPoolLight = 1..$MaxParallelLight
$slotPoolHeavy = ($MaxParallelLight + 1)..($MaxParallelLight + $MaxParallelHeavy)
$activeHeavyCount = 0
$stopScheduling = $false

function Test-HasPendingParallelWork {
    if ($useFixedWorkerSlots) {
        foreach ($slotKey in $pendingBySlot.Keys) {
            if ($pendingBySlot[$slotKey].Count -gt 0) {
                return $true
            }
        }

        return $false
    }

    return $pending.Count -gt 0
}

function Clear-AllPendingParallelWork {
    if ($useFixedWorkerSlots) {
        foreach ($slotKey in $pendingBySlot.Keys) {
            while ($pendingBySlot[$slotKey].Count -gt 0) {
                $pendingBySlot[$slotKey].Dequeue() | Out-Null
            }
        }
    }
    else {
        $pending.Clear()
    }
}

function Test-CanScheduleTier {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Tier
    )

    if ($Tier -eq 'Heavy') {
        return $activeHeavyCount -lt $MaxParallelHeavy
    }

    return $true
}

function Get-AvailableSlotForEntry {
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$Entry,

        [Parameter(Mandatory = $true)]
        [string]$Tier
    )

    if ($Entry.ContainsKey('PreferredSlot') -and $null -ne $Entry.PreferredSlot) {
        $preferredSlot = [int]$Entry.PreferredSlot
        if (-not $activeBySlot.ContainsKey($preferredSlot)) {
            return $preferredSlot
        }

        return $null
    }

    return Get-AvailableSlot -Tier $Tier
}

function Get-AvailableSlot {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Tier
    )

    if ($Tier -eq 'Heavy') {
        foreach ($slot in $slotPoolHeavy) {
            if (-not $activeBySlot.ContainsKey($slot)) {
                return $slot
            }
        }
        return $null
    }

    foreach ($slot in $slotPoolLight) {
        if (-not $activeBySlot.ContainsKey($slot)) {
            return $slot
        }
    }

    return $null
}

while ((Test-HasPendingParallelWork) -or $activeBySlot.Count -gt 0) {
    foreach ($slot in @($activeBySlot.Keys)) {
        $activeRun = $activeBySlot[$slot]
        if (-not $activeRun.Process.HasExited) {
            continue
        }

        $exitCode = $activeRun.Process.ExitCode
        $result = Get-RunResultFromMetadata -ActiveRun $activeRun -ProcessExitCode $exitCode
        $results.Add($result) | Out-Null

        if ($result.Tier -eq 'Heavy') {
            $activeHeavyCount = [Math]::Max(0, $activeHeavyCount - 1)
        }

        Write-Host ("[done][slot {0}] [{1}] {2} exit={3} raw={4} duration={5}ms tests={6}/{7}" -f $slot, $result.Kind, $result.Identity, $exitCode, $result.RawExitCode, $result.DurationMs, $(if ($null -ne $result.Passed) { $result.Passed } else { '?' }), $(if ($null -ne $result.Total) { $result.Total } else { '?' }))
        $activeBySlot.Remove($slot) | Out-Null

        if ($exitCode -ne 0 -and -not $ContinueOnFail) {
            Write-Host '[error] Stopping remaining prefixes because a shard failed. Re-run with -ContinueOnFail to collect all results.' -ForegroundColor Red
            $stopScheduling = $true
            Clear-AllPendingParallelWork
        }
    }

    if ($stopScheduling -and $activeBySlot.Count -eq 0) {
        break
    }

    if (-not (Test-HasPendingParallelWork)) {
        if ($activeBySlot.Count -gt 0) {
            Start-Sleep -Seconds 2
        }
        continue
    }

    $scheduledAny = $false
    if ($useFixedWorkerSlots) {
        foreach ($slot in ($pendingBySlot.Keys | Sort-Object)) {
            if ($pendingBySlot[$slot].Count -eq 0) {
                continue
            }

            if ($activeBySlot.ContainsKey($slot)) {
                continue
            }

            $queued = $pendingBySlot[$slot].Dequeue()
            $tier = Resolve-AngelscriptTestSuiteEntryTier -Entry $queued.Entry
            $plannedRun = New-PlannedRun -Entry $queued.Entry -Index $queued.Index -ExecutionSlot $slot
            $process = Start-PlannedRunProcess -PlannedRun $plannedRun
            if ($null -ne $process) {
                $activeBySlot[$slot] = $process
                if ($tier -eq 'Heavy') {
                    $activeHeavyCount++
                }
                $scheduledAny = $true
            }
        }
    }
    else {
        $deferred = New-Object 'System.Collections.Generic.Queue[object]'
        while ($pending.Count -gt 0) {
            $queued = $pending.Dequeue()
            $tier = Resolve-AngelscriptTestSuiteEntryTier -Entry $queued.Entry
            $slot = Get-AvailableSlotForEntry -Entry $queued.Entry -Tier $tier

            if ($null -eq $slot -or -not (Test-CanScheduleTier -Tier $tier)) {
                $deferred.Enqueue($queued)
                continue
            }

            $plannedRun = New-PlannedRun -Entry $queued.Entry -Index $queued.Index -ExecutionSlot $slot
            $process = Start-PlannedRunProcess -PlannedRun $plannedRun
            if ($null -ne $process) {
                $activeBySlot[$slot] = $process
                if ($tier -eq 'Heavy') {
                    $activeHeavyCount++
                }
                $scheduledAny = $true
            }
        }

        while ($deferred.Count -gt 0) {
            $pending.Enqueue($deferred.Dequeue())
        }
    }

    if (-not $scheduledAny) {
        Start-Sleep -Seconds 2
    }
}

if ($DryRun) {
    Write-Host ''
    Write-Host "Dry run completed for suite '$Suite'."
    exit 0
}

$failedShards = @($results | Where-Object { $_.ExitCode -ne 0 })
$passedValues = @($results | Where-Object { $null -ne $_.Passed } | ForEach-Object { [int]$_.Passed })
$failedValues = @($results | Where-Object { $null -ne $_.Failed } | ForEach-Object { [int]$_.Failed })
$totalValues = @($results | Where-Object { $null -ne $_.Total } | ForEach-Object { [int]$_.Total })
$passedTests = if ($passedValues.Count -gt 0) { ($passedValues | Measure-Object -Sum).Sum } else { $null }
$failedTests = if ($failedValues.Count -gt 0) { ($failedValues | Measure-Object -Sum).Sum } else { $null }
$totalTests = if ($totalValues.Count -gt 0) { ($totalValues | Measure-Object -Sum).Sum } else { $null }
$suiteDurationMs = [int]((Get-Date) - $suiteStartedAt).TotalMilliseconds

New-Item -ItemType Directory -Path $summaryRoot -Force | Out-Null
$summaryPath = Join-Path $summaryRoot 'ParallelSuiteSummary.json'
$shardResults = @($results.ToArray())

$summaryObject = [PSCustomObject]@{
    Strategy          = $Strategy
    Suite             = $Suite
    LabelPrefix       = $effectiveLabelPrefix
    StartedAtUtc      = $suiteStartedAt.ToUniversalTime().ToString('o')
    DurationMs        = $suiteDurationMs
    TestModuleWorkers = if ($Strategy -eq 'CoarseDynamic') { $TestModuleWorkers } else { $null }
    MaxParallelLight  = $MaxParallelLight
    MaxParallelHeavy  = $MaxParallelHeavy
    ShardCount        = $results.Count
    FailedShardCount  = $failedShards.Count
    AggregatedPassed  = $passedTests
    AggregatedFailed  = $failedTests
    AggregatedTotal   = $totalTests
    WorkerPlan        = if ($null -ne $workerPlan) { ConvertTo-AngelscriptWorkerPlanJson -Plan $workerPlan } else { $null }
    Shards            = $shardResults
}

Write-Utf8JsonFile -Path $summaryPath -Value $summaryObject

Write-Host ''
Write-Host '================================================================'
Write-Host '  Parallel Suite Summary'
Write-Host '================================================================'
Write-Host ("DurationMs       : {0}" -f $suiteDurationMs)
Write-Host ("Shards           : {0}" -f $results.Count)
Write-Host ("Failed shards    : {0}" -f $failedShards.Count)
if ($null -ne $totalTests) {
    Write-Host ("Aggregated tests : {0} pass / {1} fail / {2} total" -f $passedTests, $failedTests, $totalTests)
}
Write-Host ("SummaryPath      : {0}" -f $summaryPath)
Write-Host '================================================================'

if ($failedShards.Count -gt 0) {
    Write-Host 'Failed shards:'
    foreach ($shard in $failedShards) {
        Write-Host ("  - [{0}][{1}] {2} (exit {3}, raw {4})" -f $shard.Tier, $shard.Kind, $shard.Identity, $shard.ExitCode, $shard.RawExitCode)
    }
    exit 1
}

Write-Host "Suite '$Suite' completed successfully."
exit 0
