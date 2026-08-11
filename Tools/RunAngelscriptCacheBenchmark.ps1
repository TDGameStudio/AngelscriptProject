[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ArchiveRoot,

    [ValidateSet('Development', 'Shipping')]
    [string]$Configuration = 'Development',

    [string]$Label = 'cache-v2-benchmark',

    [string]$OutputRoot = '',

    [int]$WarmupRuns = 1,

    [int]$MeasuredRuns = 3,

    [int]$TimeoutMs = 3600000,

    [switch]$PlanOnly
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot 'Shared\UnrealCommandUtils.ps1')
Import-Module (Join-Path $PSScriptRoot 'Shared\AngelscriptCachePackageSmoke.psm1') -Force

function Get-BenchmarkMedian {
    param([double[]]$Values)
    $sorted = @($Values | Sort-Object)
    if ($sorted.Count -eq 0) {
        return $null
    }
    $middle = [int][Math]::Floor($sorted.Count / 2)
    if (($sorted.Count % 2) -eq 1) {
        return [double]$sorted[$middle]
    }
    return ([double]$sorted[$middle - 1] + [double]$sorted[$middle]) / 2.0
}

function Get-GitEvidenceState {
    param([Parameter(Mandatory = $true)][string]$RepositoryRoot)
    $commit = (& git -C $RepositoryRoot rev-parse HEAD 2>$null).Trim()
    if ($LASTEXITCODE -ne 0) {
        throw "Could not resolve Git commit for $RepositoryRoot"
    }
    $porcelain = @(& git -C $RepositoryRoot status --porcelain=v1 2>$null)
    if ($LASTEXITCODE -ne 0) {
        throw "Could not resolve Git dirty state for $RepositoryRoot"
    }
    return [ordered]@{
        commit = $commit
        dirty = $porcelain.Count -gt 0
        changedPathCount = $porcelain.Count
    }
}

if ($WarmupRuns -lt 1 -or $MeasuredRuns -lt 3) {
    throw 'Cache benchmark evidence requires at least one warmup and three measured runs.'
}
if ($TimeoutMs -le 0) {
    throw 'TimeoutMs must be positive.'
}

$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$resolvedArchive = (Resolve-Path $ArchiveRoot).Path
$layout = Assert-AngelscriptLoosePackageLayout `
    -ArchiveRoot $resolvedArchive `
    -ProjectName 'AngelscriptProject' `
    -Configuration $Configuration
$fixture = New-AngelscriptCacheSmokeFixture `
    -ArchiveRoot $resolvedArchive `
    -ScriptRoot $layout.ScriptRoot

$stamp = Get-Date -Format 'yyyyMMdd_HHmmss_fff'
if ([string]::IsNullOrWhiteSpace($OutputRoot)) {
    $OutputRoot = Join-Path $projectRoot "Saved\CacheBenchmark\$Label\$stamp"
}
$resolvedOutput = [System.IO.Path]::GetFullPath($OutputRoot)
New-Item -ItemType Directory -Path $resolvedOutput -Force | Out-Null

$packageRoot = Split-Path -Parent $layout.ScriptRoot
$benchmarkRoot = Join-Path $packageRoot "Saved\CacheBenchmark\$Label-$stamp"
$cacheRoots = Join-Path $benchmarkRoot 'CacheRoots'
$reportsRoot = Join-Path $benchmarkRoot 'Reports'
$logsRoot = Join-Path $benchmarkRoot 'Logs'
$dumpsRoot = Join-Path $benchmarkRoot 'Dumps'
foreach ($directory in @($cacheRoots, $reportsRoot, $logsRoot, $dumpsRoot)) {
    New-Item -ItemType Directory -Path $directory -Force | Out-Null
}

$dumpTool = Join-Path $projectRoot `
    'Plugins\Angelscript\Tools\CacheV2Dump\cache_v2_dump.py'
$engineVersionPath = Join-Path `
    'C:\Program Files\Epic Games\UE_5.8' 'Engine\Build\Build.version'
$engineVersion = if (Test-Path -LiteralPath $engineVersionPath) {
    $versionDocument = Get-Content $engineVersionPath -Raw | ConvertFrom-Json
    '{0}.{1}.{2}-{3}' -f $versionDocument.MajorVersion,
        $versionDocument.MinorVersion,
        $versionDocument.PatchVersion,
        $versionDocument.Changelist
}
else {
    'UE5.8'
}

$cpu = Get-CimInstance Win32_Processor | Select-Object -First 1
$computer = Get-CimInstance Win32_ComputerSystem
$os = Get-CimInstance Win32_OperatingSystem
$diskMedia = @()
try {
    $diskMedia = @(Get-PhysicalDisk | ForEach-Object {
        [ordered]@{ friendlyName = $_.FriendlyName; mediaType = [string]$_.MediaType }
    })
}
catch {
    $diskMedia = @([ordered]@{ friendlyName = 'unavailable'; mediaType = 'unavailable' })
}

$context = [ordered]@{
    schemaVersion = 1
    startedAtUtc = (Get-Date).ToUniversalTime().ToString('o')
    parent = Get-GitEvidenceState -RepositoryRoot $projectRoot
    plugin = Get-GitEvidenceState -RepositoryRoot (Join-Path $projectRoot 'Plugins\Angelscript')
    engineVersion = $engineVersion
    platform = 'Win64'
    configuration = $Configuration
    cacheDiagnosticSchema = 4
    archiveRoot = $resolvedArchive
    executable = $layout.Executable
    scriptRoot = $layout.ScriptRoot
    stagedSourceFileCount = @(Get-ChildItem $layout.ScriptRoot -Recurse -Filter '*.as' -File).Count
    warmupRuns = $WarmupRuns
    measuredRuns = $MeasuredRuns
    cpu = [string]$cpu.Name
    logicalProcessors = [int]$computer.NumberOfLogicalProcessors
    memoryBytes = [uint64]$computer.TotalPhysicalMemory
    os = [string]$os.Caption + ' ' + [string]$os.Version
    disks = $diskMedia
    command = $MyInvocation.Line
}
$context | ConvertTo-Json -Depth 8 |
    Set-Content -LiteralPath (Join-Path $resolvedOutput 'Context.json') -Encoding UTF8

$plan = New-Object System.Collections.Generic.List[object]
function Add-PlannedRows {
    param(
        [string]$Scenario,
        [string]$DiagnosticsMode,
        [string]$PreparationMode,
        [int]$PackTargetMiB,
        [int]$MaxWorkers
    )
    for ($index = 0; $index -lt ($WarmupRuns + $MeasuredRuns); ++$index) {
        $plan.Add([pscustomobject]@{
            scenario = $Scenario
            diagnosticsMode = $DiagnosticsMode
            preparationMode = $PreparationMode
            packTargetMiB = $PackTargetMiB
            maxWorkers = $MaxWorkers
            isWarmup = $index -lt $WarmupRuns
            runIndex = if ($index -lt $WarmupRuns) { $index } else { $index - $WarmupRuns }
        })
    }
}

foreach ($scenario in @('cold-no-cache', 'unchanged-warm', 'one-body-edit',
        'type-schema-edit', 'module-state-edit')) {
    Add-PlannedRows $scenario Summary Parallel 64 4
}
foreach ($mode in @('Disabled', 'Summary', 'Verbose')) {
    Add-PlannedRows ("diagnostics-" + $mode.ToLowerInvariant()) $mode Parallel 64 4
}
foreach ($target in @(4, 16, 64)) {
    Add-PlannedRows "pack-$target-serial" Summary Serial $target 1
    Add-PlannedRows "pack-$target-parallel" Summary Parallel $target 4
}
$plan | ConvertTo-Json -Depth 4 |
    Set-Content -LiteralPath (Join-Path $resolvedOutput 'Plan.json') -Encoding UTF8
if ($PlanOnly) {
    Write-Host "Cache V2 benchmark plan written: $resolvedOutput"
    Write-Host "Measured/warmup rows: $($plan.Count)"
    exit 0
}

$deadlineUtc = (Get-Date).ToUniversalTime().AddMilliseconds($TimeoutMs)
$rows = New-Object System.Collections.Generic.List[object]
$launchOrdinal = 0

function Invoke-BenchmarkLaunch {
    param(
        [Parameter(Mandatory = $true)][string]$Scenario,
        [Parameter(Mandatory = $true)][string]$FixtureScenario,
        [Parameter(Mandatory = $true)][string]$CacheRoot,
        [Parameter(Mandatory = $true)][string]$DiagnosticsMode,
        [Parameter(Mandatory = $true)][string]$PreparationMode,
        [Parameter(Mandatory = $true)][int]$PackTargetMiB,
        [Parameter(Mandatory = $true)][int]$MaxWorkers,
        [bool]$RecordRow,
        [bool]$IsWarmup,
        [int]$RunIndex
    )

    $script:launchOrdinal++
    [void](Set-AngelscriptCacheSmokeFixtureScenario `
        -Fixture $fixture -Scenario $FixtureScenario)
    $safeName = '{0:D3}-{1}-{2}' -f $script:launchOrdinal,
        ($Scenario -replace '[^A-Za-z0-9_.-]', '-'), $RunIndex
    $reportPath = Join-Path $reportsRoot "$safeName.json"
    $logPath = Join-Path $logsRoot "$safeName.log"
    $dumpPath = Join-Path $dumpsRoot "$safeName.json"
    $remainingMs = [int][Math]::Floor(
        ($deadlineUtc - (Get-Date).ToUniversalTime()).TotalMilliseconds)
    $launchTimeout = Resolve-AngelscriptCachePackageLaunchTimeoutMs `
        -RemainingTimeoutMs $remainingMs
    $extra = @("-as-cache-pack-target-mib=$PackTargetMiB")
    if ($PreparationMode -eq 'Serial') {
        $extra += '-as-cache-force-serial-preparation'
    }
    else {
        $extra += "-as-cache-preparation-workers=$MaxWorkers"
    }
    $launch = Invoke-AngelscriptPackagedCacheLaunch `
        -ArchiveRoot $resolvedArchive `
        -Executable $layout.Executable `
        -CacheRoot $CacheRoot `
        -ReportPath $reportPath `
        -LogPath $logPath `
        -DiagnosticsMode $DiagnosticsMode `
        -ExtraArguments $extra `
        -TimeoutMs $launchTimeout
    if ($launch.TimedOut -or $launch.ExitCode -ne 0) {
        throw "Benchmark launch $safeName failed: exit=$($launch.ExitCode) timedOut=$($launch.TimedOut) log=$logPath"
    }

    $dump = Invoke-AngelscriptCacheV2Dump `
        -ArchiveRoot $resolvedArchive `
        -CacheRoot $CacheRoot `
        -ToolPath $dumpTool `
        -OutputPath $dumpPath `
        -GenerationSelectors @('Current') `
        -SessionReport $(if ($DiagnosticsMode -eq 'Disabled') { '' } else { $reportPath }) `
        -TimeoutMs ([Math]::Min(120000, $launchTimeout))
    $namespace = @($dump.namespaces)[0]
    $currentPointer = @($namespace.pointers | Where-Object slot -eq 'Current')[0]
    $generation = @($namespace.generations |
        Where-Object generation_id -eq $currentPointer.generation_id)[0]
    $records = @($generation.records)
    $packs = @($generation.packs)
    $report = $null
    if ($DiagnosticsMode -ne 'Disabled') {
        $report = Read-AngelscriptCacheReport -Path $reportPath
    }

    if (-not $RecordRow) {
        return
    }

    # Do not assign an array-valued `if` expression directly: PowerShell
    # pipeline unrolling turns a one-module report into a scalar PSCustomObject,
    # which has no strict-mode Count property.
    $modules = @()
    if ($null -ne $report) {
        $modules = @($report.current.modules)
    }
    $reuse = if ($null -ne $report -and [bool]$report.functionReuse.present) {
        $report.functionReuse
    } else { $null }
    $trace = if ($null -ne $report) { $report.decisionTrace } else { $null }
    $flushCandidates = @()
    if ($null -ne $trace) {
        $flushCandidates = @($trace.events |
            Where-Object stageName -eq 'LifecycleFlush' |
            Select-Object -Last 1)
    }
    $flushEvent = if ($flushCandidates.Count -gt 0) {
        $flushCandidates[0]
    } else { $null }
    $rows.Add([pscustomobject][ordered]@{
        timestampUtc = (Get-Date).ToUniversalTime().ToString('o')
        engineVersion = $engineVersion
        platform = 'Win64'
        configuration = $Configuration
        scenario = $Scenario
        diagnosticsMode = $DiagnosticsMode
        preparationMode = $PreparationMode
        packTargetMiB = $PackTargetMiB
        maxWorkers = $MaxWorkers
        isWarmup = $IsWarmup
        runIndex = $RunIndex
        exitCode = $launch.ExitCode
        totalMs = $launch.DurationMs
        stagedSourceFiles = $context.stagedSourceFileCount
        moduleCount = [int]$generation.module_count
        typeRecordCount = @($records | Where-Object record_kind -eq 'TypeSchema').Count
        functionRecordCount = @($records | Where-Object record_kind -eq 'FunctionBody').Count
        globalCount = if ($modules.Count -gt 0) {
            [int](($modules | ForEach-Object { @($_.state.globals).Count } |
                Measure-Object -Sum).Sum)
        } else { $null }
        candidateModuleCount = if ($null -ne $reuse) { [int]$reuse.candidateModuleCount } else { $null }
        restoredFunctionCount = if ($null -ne $reuse) { [int]$reuse.restoredFunctionCount } else { $null }
        compiledMissCount = if ($null -ne $reuse) { [int]$reuse.compiledMissCount } else { $null }
        notCacheableCount = if ($null -ne $reuse) { [int]$reuse.notCacheableCount } else { $null }
        rejectedCorruptCount = if ($null -ne $reuse) { [int]$reuse.rejectedCorruptCount } else { $null }
        canonicalRecordBytes = [uint64](($records | Measure-Object raw_size -Sum).Sum)
        packCount = $packs.Count
        storedPackBytes = [uint64](($packs | Measure-Object size -Sum).Sum)
        manifestBytes = [uint64]$generation.size
        reportBytes = if ($null -ne $report) { [uint64](Get-Item $reportPath).Length } else { 0 }
        traceEventCount = if ($null -ne $trace) { @($trace.events).Count } else { 0 }
        traceEvictedCount = if ($null -ne $trace) { [uint64]$trace.evictedEventCount } else { 0 }
        lifecycleFlushUs = if ($null -ne $flushEvent) { [uint64]$flushEvent.elapsedMicroseconds } else { $null }
        generationId = [string]$currentPointer.generation_id
        sourceSnapshot = [string]$generation.source_snapshot
        reportPath = if ($null -ne $report) { $reportPath } else { '' }
        dumpPath = $dumpPath
        logPath = $logPath
    })
}

function Invoke-PlannedSeries {
    param(
        [string]$Scenario,
        [string]$CacheRoot,
        [string[]]$FixtureSequence,
        [string]$DiagnosticsMode = 'Summary',
        [string]$PreparationMode = 'Parallel',
        [int]$PackTargetMiB = 64,
        [int]$MaxWorkers = 4,
        [switch]$SeedBaseline
    )
    if ($SeedBaseline) {
        Invoke-BenchmarkLaunch -Scenario "$Scenario-seed" -FixtureScenario Baseline `
            -CacheRoot $CacheRoot -DiagnosticsMode Summary `
            -PreparationMode $PreparationMode -PackTargetMiB $PackTargetMiB `
            -MaxWorkers $MaxWorkers -RecordRow $false -IsWarmup $false -RunIndex -1
    }
    $total = $WarmupRuns + $MeasuredRuns
    for ($index = 0; $index -lt $total; ++$index) {
        $isWarmup = $index -lt $WarmupRuns
        $runIndex = if ($isWarmup) { $index } else { $index - $WarmupRuns }
        $fixtureName = $FixtureSequence[$index % $FixtureSequence.Count]
        Invoke-BenchmarkLaunch -Scenario $Scenario -FixtureScenario $fixtureName `
            -CacheRoot $CacheRoot -DiagnosticsMode $DiagnosticsMode `
            -PreparationMode $PreparationMode -PackTargetMiB $PackTargetMiB `
            -MaxWorkers $MaxWorkers -RecordRow $true -IsWarmup $isWarmup `
            -RunIndex $runIndex
    }
}

try {
    for ($index = 0; $index -lt ($WarmupRuns + $MeasuredRuns); ++$index) {
        $isWarmup = $index -lt $WarmupRuns
        $runIndex = if ($isWarmup) { $index } else { $index - $WarmupRuns }
        Invoke-BenchmarkLaunch -Scenario 'cold-no-cache' -FixtureScenario Baseline `
            -CacheRoot (Join-Path $cacheRoots "cold-$index") `
            -DiagnosticsMode Summary -PreparationMode Parallel `
            -PackTargetMiB 64 -MaxWorkers 4 -RecordRow $true `
            -IsWarmup $isWarmup -RunIndex $runIndex
    }

    Invoke-PlannedSeries 'unchanged-warm' (Join-Path $cacheRoots 'warm') `
        @('Baseline') -SeedBaseline
    Invoke-PlannedSeries 'one-body-edit' (Join-Path $cacheRoots 'body') `
        @('BodyEdit', 'Baseline') -SeedBaseline
    Invoke-PlannedSeries 'type-schema-edit' (Join-Path $cacheRoots 'type') `
        @('TypeSchemaEdit', 'Baseline') -SeedBaseline
    Invoke-PlannedSeries 'module-state-edit' (Join-Path $cacheRoots 'state') `
        @('ModuleStateEdit', 'Baseline') -SeedBaseline

    $diagnosticCache = Join-Path $cacheRoots 'diagnostics'
    Invoke-BenchmarkLaunch -Scenario 'diagnostics-seed' -FixtureScenario Baseline `
        -CacheRoot $diagnosticCache -DiagnosticsMode Summary `
        -PreparationMode Parallel -PackTargetMiB 64 -MaxWorkers 4 `
        -RecordRow $false -IsWarmup $false -RunIndex -1
    foreach ($mode in @('Disabled', 'Summary', 'Verbose')) {
        Invoke-PlannedSeries ("diagnostics-" + $mode.ToLowerInvariant()) `
            $diagnosticCache @('Baseline') -DiagnosticsMode $mode
    }

    foreach ($target in @(4, 16, 64)) {
        foreach ($preparation in @('Serial', 'Parallel')) {
            for ($index = 0; $index -lt ($WarmupRuns + $MeasuredRuns); ++$index) {
                $isWarmup = $index -lt $WarmupRuns
                $runIndex = if ($isWarmup) { $index } else { $index - $WarmupRuns }
                Invoke-BenchmarkLaunch `
                    -Scenario ("pack-$target-" + $preparation.ToLowerInvariant()) `
                    -FixtureScenario Baseline `
                    -CacheRoot (Join-Path $cacheRoots "pack-$target-$preparation-$index") `
                    -DiagnosticsMode Summary -PreparationMode $preparation `
                    -PackTargetMiB $target `
                    -MaxWorkers $(if ($preparation -eq 'Serial') { 1 } else { 4 }) `
                    -RecordRow $true -IsWarmup $isWarmup -RunIndex $runIndex
            }
        }
    }
}
finally {
    [void](Set-AngelscriptCacheSmokeFixtureScenario -Fixture $fixture -Scenario Baseline)
}

$rawPath = Join-Path $resolvedOutput 'Raw.csv'
$rows | Export-Csv -LiteralPath $rawPath -NoTypeInformation -Encoding UTF8
$summaryRows = foreach ($group in @($rows | Where-Object { -not $_.isWarmup } |
        Group-Object scenario,diagnosticsMode,preparationMode,packTargetMiB,maxWorkers)) {
    $values = @($group.Group | ForEach-Object { [double]$_.totalMs })
    $flushValues = @($group.Group | Where-Object { $null -ne $_.lifecycleFlushUs } |
        ForEach-Object { [double]$_.lifecycleFlushUs })
    [pscustomobject][ordered]@{
        scenario = $group.Group[0].scenario
        diagnosticsMode = $group.Group[0].diagnosticsMode
        preparationMode = $group.Group[0].preparationMode
        packTargetMiB = $group.Group[0].packTargetMiB
        maxWorkers = $group.Group[0].maxWorkers
        measuredRuns = $group.Count
        totalMsMin = ($values | Measure-Object -Minimum).Minimum
        totalMsMedian = Get-BenchmarkMedian $values
        totalMsMax = ($values | Measure-Object -Maximum).Maximum
        lifecycleFlushUsMin = if ($flushValues.Count) { ($flushValues | Measure-Object -Minimum).Minimum } else { $null }
        lifecycleFlushUsMedian = Get-BenchmarkMedian $flushValues
        lifecycleFlushUsMax = if ($flushValues.Count) { ($flushValues | Measure-Object -Maximum).Maximum } else { $null }
        packCount = ($group.Group | Select-Object -Last 1).packCount
        storedPackBytes = ($group.Group | Select-Object -Last 1).storedPackBytes
        reportBytesMedian = Get-BenchmarkMedian @($group.Group | ForEach-Object { [double]$_.reportBytes })
        traceEventsMedian = Get-BenchmarkMedian @($group.Group | ForEach-Object { [double]$_.traceEventCount })
    }
}
$summaryPath = Join-Path $resolvedOutput 'Summary.csv'
$summaryRows | Export-Csv -LiteralPath $summaryPath -NoTypeInformation -Encoding UTF8

$result = [ordered]@{
    kind = 'AngelscriptCacheV2Benchmark'
    status = 'Passed'
    rowCount = $rows.Count
    warmupRows = @($rows | Where-Object isWarmup).Count
    measuredRows = @($rows | Where-Object { -not $_.isWarmup }).Count
    raw = $rawPath
    summary = $summaryPath
    context = Join-Path $resolvedOutput 'Context.json'
    packageEvidenceRoot = $benchmarkRoot
    completedAtUtc = (Get-Date).ToUniversalTime().ToString('o')
}
$result | ConvertTo-Json -Depth 5 |
    Set-Content -LiteralPath (Join-Path $resolvedOutput 'Result.json') -Encoding UTF8
Write-Host "Cache V2 benchmark passed: $resolvedOutput"
Write-Host "Rows: $($rows.Count), measured: $($result.measuredRows), warmup: $($result.warmupRows)"
exit 0
