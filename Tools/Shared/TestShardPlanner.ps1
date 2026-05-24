Set-StrictMode -Version Latest

# Dynamic worker planning for Angelscript parallel test runs.
# Uses latest Saved/Tests timing when available; falls back to baked-in defaults.

$script:AngelscriptDefaultPrefixTimingSec = @{
    'Angelscript.TestModule.Engine'                 = 213.5
    'Angelscript.TestModule.Memory'                 = 127.3
    'Angelscript.TestModule.Functional'             = 107.5
    'Angelscript.TestModule.Debugger'               = 92.9
    'Angelscript.TestModule.Shared'                 = 72.6
    'Angelscript.TestModule.GC'                     = 67.8
    'Angelscript.TestModule.Bindings'               = 61.6
    'Angelscript.TestModule.Editor'                 = 55.4
    'Angelscript.TestModule.Preprocessor'           = 53.5
    'Angelscript.TestModule.StaticJIT'              = 52.7
    'Angelscript.TestModule.AngelScriptSDK'         = 49.9
    'Angelscript.TestModule.Core'                   = 46.8
    'Angelscript.TestModule.Blueprint'              = 44.1
    'Angelscript.TestModule.ScriptClass'            = 42.9
    'Angelscript.TestModule.Syntax'                 = 42.0
    'Angelscript.TestModule.ClassGenerator'         = 36.9
    'Angelscript.TestModule.FunctionLibraries'      = 35.0
    'Angelscript.TestModule.Component'              = 34.4
    'Angelscript.TestModule.Learning'               = 33.7
    'Angelscript.TestModule.HotReload'              = 32.8
    'Angelscript.TestModule.Compiler'               = 32.4
    'Angelscript.TestModule.Actor'                  = 32.0
    'Angelscript.TestModule.Performance'            = 31.6
    'Angelscript.TestModule.GameInstanceSubsystem'  = 31.2
    'Angelscript.TestModule.Validation'             = 30.9
    'Angelscript.TestModule.Interface'              = 29.8
    'Angelscript.TestModule.Delegate'               = 27.1
    'Angelscript.TestModule.Networking'             = 26.8
    'Angelscript.TestModule.WorldSubsystem'         = 26.5
    'Angelscript.TestModule.FileSystem'             = 26.5
    'Angelscript.TestModule.Inheritance'            = 25.8
    'Angelscript.TestModule.Dump'                   = 24.6
    'Angelscript.TestModule.Parity'                 = 24.3
    'Angelscript.Editor'                            = 66.9
    'Angelscript.GAS'                               = 47.6
    'Angelscript.Template'                          = 32.3
}

function Get-AngelscriptDefaultPrefixTimingSec {
    return $script:AngelscriptDefaultPrefixTimingSec
}

function Get-AngelscriptTestPrefixTimingHints {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ProjectRoot,

        [double]$DefaultDurationSec = 35.0
    )

    $defaults = Get-AngelscriptDefaultPrefixTimingSec
    $hints = @{}
    foreach ($prefix in $defaults.Keys) {
        $hints[$prefix] = [PSCustomObject]@{
            Prefix          = $prefix
            DurationSec     = [double]$defaults[$prefix]
            TestCount       = $null
            Source          = 'Default'
            LastObservedUtc = $null
        }
    }

    $testsRoot = Join-Path $ProjectRoot 'Saved\Tests'
    if (-not (Test-Path -LiteralPath $testsRoot -PathType Container)) {
        return $hints
    }

    $metadataFiles = Get-ChildItem -LiteralPath $testsRoot -Recurse -Filter 'RunMetadata.json' -ErrorAction SilentlyContinue
    foreach ($metaFile in $metadataFiles) {
        try {
            $meta = Get-Content -LiteralPath $metaFile.FullName -Raw | ConvertFrom-Json
        }
        catch {
            continue
        }

        if ($null -eq $meta.Target -or [string]::IsNullOrWhiteSpace([string]$meta.Target)) {
            continue
        }

        $prefix = [string]$meta.Target
        if ($null -eq $meta.DurationMs) {
            continue
        }

        $durationSec = [math]::Round([double]$meta.DurationMs / 1000.0, 1)
        if ($durationSec -le 0) {
            continue
        }

        $summaryPath = Join-Path $metaFile.Directory.FullName 'Summary.json'
        $testCount = $null
        if (Test-Path -LiteralPath $summaryPath -PathType Leaf) {
            try {
                $summary = Get-Content -LiteralPath $summaryPath -Raw | ConvertFrom-Json
                if ($null -ne $summary.Total) {
                    $testCount = [int]$summary.Total
                }
            }
            catch {
                $testCount = $null
            }
        }

        $observedAt = $metaFile.LastWriteTimeUtc
        if ($hints.ContainsKey($prefix)) {
            $existing = $hints[$prefix]
            if ($existing.Source -eq 'Observed' -and $null -ne $existing.LastObservedUtc -and $observedAt -le [datetime]$existing.LastObservedUtc) {
                continue
            }
        }

        $hints[$prefix] = [PSCustomObject]@{
            Prefix          = $prefix
            DurationSec     = $durationSec
            TestCount       = $testCount
            Source          = 'Observed'
            LastObservedUtc = $observedAt.ToString('o')
        }
    }

    return $hints
}

function Get-AngelscriptPrefixTimingWeight {
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$Entry,

        [Parameter(Mandatory = $true)]
        [hashtable]$TimingHints,

        [double]$DefaultDurationSec = 35.0
    )

    $prefix = [string]$Entry.Prefix
    if ($TimingHints.ContainsKey($prefix)) {
        return [double]$TimingHints[$prefix].DurationSec
    }

    return $DefaultDurationSec
}

function Get-AngelscriptPrefixTestCountHint {
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$Entry,

        [Parameter(Mandatory = $true)]
        [hashtable]$TimingHints
    )

    $prefix = [string]$Entry.Prefix
    if ($TimingHints.ContainsKey($prefix) -and $null -ne $TimingHints[$prefix].TestCount) {
        return [int]$TimingHints[$prefix].TestCount
    }

    return $null
}

function Plan-AngelscriptBalancedWorkerBuckets {
    param(
        [Parameter(Mandatory = $true)]
        [array]$Entries,

        [Parameter(Mandatory = $true)]
        [int]$WorkerCount,

        [Parameter(Mandatory = $true)]
        [hashtable]$TimingHints,

        [double]$DefaultDurationSec = 35.0
    )

    if ($WorkerCount -lt 1) {
        throw 'WorkerCount must be at least 1.'
    }

    $weightedEntries = @(
        foreach ($entry in $Entries) {
            $weight = Get-AngelscriptPrefixTimingWeight -Entry $entry -TimingHints $TimingHints -DefaultDurationSec $DefaultDurationSec
            $testCount = Get-AngelscriptPrefixTestCountHint -Entry $entry -TimingHints $TimingHints
            [PSCustomObject]@{
                Entry     = $entry
                WeightSec = $weight
                TestCount = $testCount
            }
        }
    )

    $buckets = @(
        for ($slot = 1; $slot -le $WorkerCount; ++$slot) {
            [PSCustomObject]@{
                Slot               = $slot
                Entries            = New-Object 'System.Collections.Generic.List[object]'
                EstimatedWeightSec = 0.0
                EstimatedTestCount = 0
            }
        }
    )

    foreach ($item in ($weightedEntries | Sort-Object -Property WeightSec -Descending)) {
        $targetBucket = @($buckets | Sort-Object -Property EstimatedWeightSec, Slot | Select-Object -First 1)[0]
        $targetBucket.Entries.Add($item.Entry) | Out-Null
        $targetBucket.EstimatedWeightSec += [double]$item.WeightSec
        if ($null -ne $item.TestCount) {
            $targetBucket.EstimatedTestCount += [int]$item.TestCount
        }
    }

    return @($buckets)
}

function Add-AngelscriptEntryToLightestBucket {
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$Entry,

        [Parameter(Mandatory = $true)]
        [array]$Buckets,

        [Parameter(Mandatory = $true)]
        [hashtable]$TimingHints,

        [double]$DefaultDurationSec = 35.0,

        [switch]$Prepend
    )

    $targetBucket = @($Buckets | Sort-Object -Property EstimatedWeightSec, Slot | Select-Object -First 1)[0]
    $weight = Get-AngelscriptPrefixTimingWeight -Entry $Entry -TimingHints $TimingHints -DefaultDurationSec $DefaultDurationSec
    $testCount = Get-AngelscriptPrefixTestCountHint -Entry $Entry -TimingHints $TimingHints

    if ($Prepend) {
        $targetBucket.Entries.Insert(0, $Entry)
    }
    else {
        $targetBucket.Entries.Add($Entry) | Out-Null
    }

    $targetBucket.EstimatedWeightSec += $weight
    if ($null -ne $testCount) {
        $targetBucket.EstimatedTestCount += $testCount
    }
}

function Get-AngelscriptCoarseDynamicPlan {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ProjectRoot,

        [int]$WorkerCount = 4,

        [switch]$ExcludeSlow
    )

    . (Join-Path $PSScriptRoot 'TestSuiteDefinitions.ps1')

    $allEntries = @(Get-AngelscriptTestSuiteEntries -SuiteName 'All')
    $testModuleEntries = @($allEntries | Where-Object { $_.Prefix -like 'Angelscript.TestModule*' })
    $topLevelEntries = @($allEntries | Where-Object { $_.Prefix -notlike 'Angelscript.TestModule*' })

    if ($ExcludeSlow) {
        $slowPrefixes = @(Get-AngelscriptTestSlowPrefixExclusions)
        $testModuleEntries = @($testModuleEntries | Where-Object { $slowPrefixes -notcontains $_.Prefix })
    }

    $timingHints = Get-AngelscriptTestPrefixTimingHints -ProjectRoot $ProjectRoot
    $observedCount = @($timingHints.Values | Where-Object { $_.Source -eq 'Observed' }).Count
    $defaultCount = @($timingHints.Values | Where-Object { $_.Source -eq 'Default' }).Count

    $buckets = @(Plan-AngelscriptBalancedWorkerBuckets `
            -Entries $testModuleEntries `
            -WorkerCount $WorkerCount `
            -TimingHints $timingHints)

    foreach ($topEntry in $topLevelEntries) {
        Add-AngelscriptEntryToLightestBucket `
            -Entry $topEntry `
            -Buckets $buckets `
            -TimingHints $timingHints `
            -Prepend
    }

    $flatEntries = New-Object 'System.Collections.Generic.List[hashtable]'
    foreach ($bucket in ($buckets | Sort-Object -Property Slot)) {
        foreach ($entry in $bucket.Entries) {
            $entryCopy = @{}
            foreach ($key in $entry.Keys) {
                $entryCopy[$key] = $entry[$key]
            }
            $entryCopy['PreferredSlot'] = [int]$bucket.Slot
            $flatEntries.Add($entryCopy) | Out-Null
        }
    }

    return [PSCustomObject]@{
        WorkerCount    = $WorkerCount
        TimingObserved = $observedCount
        TimingDefaults = $defaultCount
        Buckets        = @($buckets)
        Entries        = @($flatEntries)
    }
}

function Write-AngelscriptWorkerPlan {
    param(
        [Parameter(Mandatory = $true)]
        [psobject]$Plan
    )

    Write-Host ''
    Write-Host '================================================================'
    Write-Host '  Dynamic Worker Plan'
    Write-Host '================================================================'
    Write-Host ("Workers            : {0}" -f $Plan.WorkerCount)
    Write-Host ("Timing hints       : {0} observed, {1} default fallback" -f $Plan.TimingObserved, $Plan.TimingDefaults)
    Write-Host ("Total queued runs  : {0}" -f $Plan.Entries.Count)
    Write-Host '----------------------------------------------------------------'

    foreach ($bucket in ($Plan.Buckets | Sort-Object -Property Slot)) {
        $labels = @($bucket.Entries | ForEach-Object { [string]$_.Label })
        $labelText = if ($labels.Count -gt 0) { ($labels -join ', ') } else { '<empty>' }
        $testHint = if ($bucket.EstimatedTestCount -gt 0) { "$($bucket.EstimatedTestCount) tests (est)" } else { 'tests n/a' }
        Write-Host ("Slot {0} | est {1:N0}s ({2:N1} min) | {3}" -f `
                $bucket.Slot, `
                $bucket.EstimatedWeightSec, `
                ($bucket.EstimatedWeightSec / 60.0), `
                $testHint)
        Write-Host ("         prefixes ({0}): {1}" -f $bucket.Entries.Count, $labelText)
    }

    $maxBucketSec = ($Plan.Buckets | Measure-Object -Property EstimatedWeightSec -Maximum).Maximum
    Write-Host '----------------------------------------------------------------'
    Write-Host ("Projected wall time: ~{0:N1} min (max slot, pre-run estimate)" -f ($maxBucketSec / 60.0))
    Write-Host '================================================================'
    Write-Host ''
}

function ConvertTo-AngelscriptWorkerPlanJson {
    param(
        [Parameter(Mandatory = $true)]
        [psobject]$Plan
    )

    $bucketObjects = @(
        foreach ($bucket in ($Plan.Buckets | Sort-Object -Property Slot)) {
            [PSCustomObject]@{
                Slot               = [int]$bucket.Slot
                RunCount           = $bucket.Entries.Count
                EstimatedWeightSec = [math]::Round([double]$bucket.EstimatedWeightSec, 1)
                EstimatedTestCount = if ($bucket.EstimatedTestCount -gt 0) { [int]$bucket.EstimatedTestCount } else { $null }
                Prefixes           = @($bucket.Entries | ForEach-Object {
                        [PSCustomObject]@{
                            Label  = [string]$_.Label
                            Prefix = [string]$_.Prefix
                            Tier   = if ($_.ContainsKey('Tier')) { [string]$_.Tier } else { $null }
                        }
                    })
            }
        }
    )

    return [PSCustomObject]@{
        WorkerCount    = [int]$Plan.WorkerCount
        TimingObserved = [int]$Plan.TimingObserved
        TimingDefaults = [int]$Plan.TimingDefaults
        TotalRunCount  = [int]$Plan.Entries.Count
        ProjectedWallSec = [math]::Round([double]($Plan.Buckets | Measure-Object -Property EstimatedWeightSec -Maximum).Maximum, 1)
        Buckets        = $bucketObjects
    }
}
