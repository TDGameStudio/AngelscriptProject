[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Assert-True {
    param([bool]$Condition, [string]$Message)
    if (-not $Condition) { throw "Assertion failed: $Message" }
}

function Assert-Equal {
    param($Expected, $Actual, [string]$Message)
    if ($Expected -ne $Actual) { throw "Assertion failed: $Message (expected '$Expected', actual '$Actual')" }
}

$runner = Join-Path $PSScriptRoot '..\scripts\Test-Hardness.ps1'
Assert-True (Test-Path -LiteralPath $runner -PathType Leaf) 'Test-Hardness.ps1 exists'

$tokens = $null
$errors = $null
[void][System.Management.Automation.Language.Parser]::ParseFile($runner, [ref]$tokens, [ref]$errors)
Assert-Equal 0 @($errors).Count 'Test-Hardness.ps1 parses in the current host'

$runnerCommand = Get-Command -Name $runner -ErrorAction Stop
Assert-True ('PowerShellHosts' -notin @($runnerCommand.Parameters.Keys)) 'the public runner exposes no legacy multi-host selector'

$quick = @(& $runner -Profile Quick -ListChecks)
$performance = @(& $runner -Profile Performance -ListChecks -WarmupRuns 1 -MeasurementRuns 1)
$explicitPerformance = @(& $runner -Profile Performance -ListChecks -WarmupRuns 1 -MeasurementRuns 1 -TaskChange 'fixture/custom')
$integration = @(& $runner -Profile Integration -ListChecks)

foreach ($name in @(
        'Hardness.PS7',
        'HardnessGateContract.PS7',
        'Protocol.PS7',
        'Workspace.PS7',
        'GitOperations.PS7',
        'OpenSpecSkill.PS7')) {
    Assert-True ($name -in @($quick.Name)) "Quick profile contains $name"
}
Assert-Equal 6 @($quick).Count 'Quick profile remains a focused PowerShell 7 core matrix'
Assert-Equal 0 @($quick | Where-Object Name -match 'PS5|WindowsPowerShell').Count 'Quick exposes no legacy host check'

foreach ($name in @('HardnessPerformance.PS7')) {
    Assert-True ($name -in @($performance.Name)) "Performance profile contains $name"
}
Assert-Equal 1 @($performance).Count 'Performance profile measures only PowerShell 7'

foreach ($name in @('Hardness.Installation', 'OpenSpec.Doctor', 'OpenSpec.Workflow', 'OpenSpec.Validate')) {
    Assert-True ($name -in @($integration.Name)) "Integration profile contains $name"
}
foreach ($name in @('HardnessPerformance.PS7')) {
    Assert-True ($name -in @($integration.Name)) "Integration contains $name"
}
Assert-Equal 11 @($integration).Count 'Integration contains six scripts, one performance run, and four route checks'
Assert-Equal 0 @($integration | Where-Object { $_.Name -match '^(UE\.|Unreal|StaticJIT|Cache|Coverage|Standalone|Engine|Execution|Toolchain)' }).Count 'the deferred UE leaf is absent from every core gate'
Assert-Equal $quick.Count @($integration | Where-Object Kind -eq 'Script').Count 'Integration keeps the complete Quick script matrix'
Assert-Equal $performance.Count @($integration | Where-Object Kind -eq 'Performance').Count 'Integration includes the complete Performance matrix'

foreach ($check in @($integration | Where-Object Kind -in @('Script', 'Performance'))) {
    Assert-Equal 'pwsh.exe' ([System.IO.Path]::GetFileName($check.Executable)) "$($check.Name) launches PowerShell 7"
    Assert-True ($check.Name -notmatch 'PS5|WindowsPowerShell') "$($check.Name) has no legacy host identity"
}

$hardnessManifestData = Import-PowerShellDataFile -LiteralPath (Join-Path $PSScriptRoot '..\scripts\Hardness.psd1')
$workspaceManifestData = Import-PowerShellDataFile -LiteralPath (Join-Path $PSScriptRoot '..\..\workspace-lifecycle\scripts\WorkspaceLifecycle.psd1')
$gitManifestData = Import-PowerShellDataFile -LiteralPath (Join-Path $PSScriptRoot '..\..\git-operations\scripts\GitOperations.psd1')
foreach ($manifestData in @($hardnessManifestData, $workspaceManifestData, $gitManifestData)) {
    Assert-Equal '7.0' ([string]$manifestData.PowerShellVersion) 'public module manifests require PowerShell 7.0 or later'
    Assert-Equal 'Core' (@($manifestData.CompatiblePSEditions) -join '|') 'public module manifests support only the Core edition'
}

foreach ($check in @($quick | Where-Object Kind -eq 'Script')) {
    Assert-True (Test-Path -LiteralPath $check.Path -PathType Leaf) "$($check.Name) references an existing test script"
}
foreach ($check in @($performance)) {
    Assert-True (Test-Path -LiteralPath $check.Path -PathType Leaf) "$($check.Name) references the private performance leaf"
    Assert-True ('-WarmupRuns' -in @($check.Arguments)) "$($check.Name) forwards WarmupRuns"
    Assert-True ('-MeasurementRuns' -in @($check.Arguments)) "$($check.Name) forwards MeasurementRuns"
    Assert-True ('-TaskChange' -notin @($check.Arguments)) "$($check.Name) uses the self-contained Task Graph fixture by default"
}
foreach ($check in @($explicitPerformance)) {
    $taskChangeIndex = [array]::IndexOf([object[]]@($check.Arguments), '-TaskChange')
    Assert-True ($taskChangeIndex -ge 0) "$($check.Name) forwards an explicit TaskChange"
    Assert-Equal 'fixture/custom' $check.Arguments[$taskChangeIndex + 1] "$($check.Name) preserves the explicit TaskChange"
}

$projectRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..\..\..'))
$performanceLeaf = Join-Path $PSScriptRoot 'Hardness.Performance.Tests.ps1'
$contractRoot = Join-Path ([System.IO.Path]::GetTempPath()) ('hardness-performance-contract-' + [guid]::NewGuid().ToString('N'))
[void](New-Item -ItemType Directory -Path $contractRoot)
try {
    $contractRunId = 'contract-run'
    $contractOutput = @(& $performanceLeaf `
            -ProjectRoot $projectRoot `
            -OutputRoot $contractRoot `
            -RunId $contractRunId `
            -WarmupRuns 0 `
            -MeasurementRuns 1 `
            -BatchSize 100 2>&1)
    Assert-Equal 0 $LASTEXITCODE 'the private performance leaf succeeds for a minimal correctness sample'

    $runDirectory = Join-Path $contractRoot $contractRunId
    $summaryPath = Join-Path $runDirectory 'Summary.json'
    $samplesPath = Join-Path $runDirectory 'Samples.csv'
    Assert-True (Test-Path -LiteralPath $summaryPath -PathType Leaf) 'the performance leaf writes Summary.json in its unique run directory'
    Assert-True (Test-Path -LiteralPath $samplesPath -PathType Leaf) 'the performance leaf writes Samples.csv in its unique run directory'
    Assert-Equal 0 @(Get-ChildItem -LiteralPath $runDirectory -Filter '*.tmp' -Force).Count 'atomic writes leave no temporary files'

    $summaryText = [System.IO.File]::ReadAllText($summaryPath)
    $summary = $summaryText | ConvertFrom-Json -ErrorAction Stop
    Assert-Equal 'SchemaVersion|RecordType|RunId|CreatedUtc|PowerShell|Parameters|Scenarios|OverallStatus|Artifacts' (@($summary.PSObject.Properties.Name) -join '|') 'the performance summary schema remains stable'
    Assert-Equal '1.0' $summary.SchemaVersion 'the performance summary schema is versioned'
    Assert-Equal 'HardnessPerformanceRaw' $summary.RecordType 'the performance summary identifies its record type'
    Assert-Equal 'Passed' $summary.OverallStatus 'the minimal performance correctness sample passes its budgets'
    Assert-Equal 'fixture/performance' $summary.Parameters.TaskChange 'the default performance run uses its self-contained Task Graph fixture'
    Assert-Equal 4 @($summary.Scenarios).Count 'the performance summary contains all four scenarios'

    $samples = @(Import-Csv -LiteralPath $samplesPath)
    Assert-Equal 4 $samples.Count 'one measured sample is retained for each scenario'
    Assert-Equal 0 @($samples | Where-Object Correct -ne 'True').Count 'every retained sample passed its behavior assertion'
    Assert-Equal 'Scenario|Phase|Iteration|Unit|Value|Correct' (@($samples[0].PSObject.Properties.Name) -join '|') 'the raw sample table schema remains stable'
    Assert-True ($summaryText -notmatch [regex]::Escape($projectRoot)) 'the performance summary omits the absolute project path'
    foreach ($privateValue in @($env:USERNAME, $env:COMPUTERNAME, $env:USERPROFILE)) {
        if (-not [string]::IsNullOrWhiteSpace([string]$privateValue)) {
            Assert-True ($summaryText -notmatch [regex]::Escape([string]$privateValue)) 'the performance summary omits machine and user identity'
        }
    }

    $summaryHash = (Get-FileHash -LiteralPath $summaryPath -Algorithm SHA256).Hash
    $samplesHash = (Get-FileHash -LiteralPath $samplesPath -Algorithm SHA256).Hash
    $duplicateRejected = $false
    try {
        & $performanceLeaf `
            -ProjectRoot $projectRoot `
            -OutputRoot $contractRoot `
            -RunId $contractRunId `
            -WarmupRuns 0 `
            -MeasurementRuns 1 `
            -BatchSize 100 2>&1 | Out-Null
    }
    catch {
        $duplicateRejected = $_.Exception.Message -match 'Refusing to reuse performance RunId'
    }
    Assert-True $duplicateRejected 'an existing RunId is rejected instead of overwritten'
    Assert-Equal $summaryHash (Get-FileHash -LiteralPath $summaryPath -Algorithm SHA256).Hash 'duplicate rejection preserves Summary.json byte-for-byte'
    Assert-Equal $samplesHash (Get-FileHash -LiteralPath $samplesPath -Algorithm SHA256).Hash 'duplicate rejection preserves Samples.csv byte-for-byte'

    $hungRunId = 'contract-hung-tree'
    $hungTimer = [System.Diagnostics.Stopwatch]::StartNew()
    $hungRejected = $false
    try {
        & $performanceLeaf `
            -ProjectRoot $projectRoot `
            -OutputRoot $contractRoot `
            -RunId $hungRunId `
            -WarmupRuns 0 `
            -MeasurementRuns 1 `
            -BatchSize 100 `
            -FreshProcessTimeoutMs 1500 `
            -FreshProcessProbeMode HangTree 2>&1 | Out-Null
    }
    catch {
        $hungRejected = $_.Exception.Message -match 'fresh-process correctness failed'
    }
    finally {
        $hungTimer.Stop()
    }
    Assert-True $hungRejected 'a deliberately hung fresh child fails the performance run deterministically'
    Assert-True ($hungTimer.Elapsed.TotalSeconds -lt 15) 'the hung-child failure is bounded by the sample timeout and cleanup grace'

    $hungDirectory = Join-Path $contractRoot $hungRunId
    $hungSummaryPath = Join-Path $hungDirectory 'Summary.json'
    $hungSamplesPath = Join-Path $hungDirectory 'Samples.csv'
    $hungFailuresPath = Join-Path $hungDirectory 'Failures.json'
    Assert-True (Test-Path -LiteralPath $hungSummaryPath -PathType Leaf) 'a timeout preserves Summary.json failure evidence'
    Assert-True (Test-Path -LiteralPath $hungSamplesPath -PathType Leaf) 'a timeout preserves Samples.csv failure evidence'
    Assert-True (Test-Path -LiteralPath $hungFailuresPath -PathType Leaf) 'a timeout preserves bounded process-failure details'
    Assert-Equal 0 @(Get-ChildItem -LiteralPath $hungDirectory -Filter '*.tmp' -Force).Count 'timeout evidence retains atomic-write cleanup semantics'

    $hungSummary = Get-Content -LiteralPath $hungSummaryPath -Raw | ConvertFrom-Json -ErrorAction Stop
    $hungSamples = @(Import-Csv -LiteralPath $hungSamplesPath)
    $hungFailures = Get-Content -LiteralPath $hungFailuresPath -Raw | ConvertFrom-Json -ErrorAction Stop
    Assert-Equal 'Failed' $hungSummary.OverallStatus 'a timed-out correctness sample fails the retained run summary'
    Assert-Equal 1 @($hungSamples | Where-Object { $_.Scenario -eq 'FreshProcess' -and $_.Correct -eq 'False' }).Count 'the timed-out fresh sample is retained as incorrect'
    Assert-Equal 'HardnessPerformanceFailures' $hungFailures.RecordType 'failure evidence identifies its stable record type'
    Assert-Equal 'Timeout' $hungFailures.Failures[0].Kind 'the hung child reports a deterministic timeout failure kind'
    Assert-Equal 1500 ([int]$hungFailures.Failures[0].TimeoutMs) 'failure evidence records the enforced wall-clock timeout'
    Assert-True ($hungFailures.Failures[0].TerminationStrategy -in @('KillTree', 'TaskKillTree')) 'timeout cleanup uses a process-tree termination capability'
    Assert-True ([bool]$hungFailures.Failures[0].ProcessExited) 'timeout cleanup confirms the direct child exited'
    Assert-True ([bool]$hungFailures.Failures[0].OutputDrainCompleted) 'the timed-out child closes both redirected streams during bounded cleanup'
    $ownedProcessIds = @($hungFailures.Failures[0].OwnedProcessIds | ForEach-Object { [int]$_ } | Select-Object -Unique)
    Assert-True ($ownedProcessIds.Count -ge 2) 'the controlled hang records both the direct child and its descendant'

    $orphanDeadline = [DateTime]::UtcNow.AddSeconds(5)
    do {
        $aliveOwnedProcesses = @($ownedProcessIds | Where-Object { $null -ne (Get-Process -Id $_ -ErrorAction SilentlyContinue) })
        if ($aliveOwnedProcesses.Count -eq 0) { break }
        Start-Sleep -Milliseconds 100
    } while ([DateTime]::UtcNow -lt $orphanDeadline)
    Assert-Equal 0 $aliveOwnedProcesses.Count 'timeout cleanup leaves no owned parent or descendant process alive'

    $floodRunId = 'contract-flooded-pipes'
    $floodTimer = [System.Diagnostics.Stopwatch]::StartNew()
    & $performanceLeaf `
        -ProjectRoot $projectRoot `
        -OutputRoot $contractRoot `
        -RunId $floodRunId `
        -WarmupRuns 0 `
        -MeasurementRuns 1 `
        -BatchSize 100 `
        -FreshProcessTimeoutMs 10000 `
        -FreshProcessProbeMode Flood | Out-Null
    $floodTimer.Stop()
    Assert-True ($floodTimer.Elapsed.TotalSeconds -lt 15) 'concurrent stdout/stderr draining completes a flooding child within its bound'

    $floodDirectory = Join-Path $contractRoot $floodRunId
    $floodSummary = Get-Content -LiteralPath (Join-Path $floodDirectory 'Summary.json') -Raw | ConvertFrom-Json -ErrorAction Stop
    $floodSamples = @(Import-Csv -LiteralPath (Join-Path $floodDirectory 'Samples.csv'))
    Assert-Equal 'Passed' $floodSummary.OverallStatus 'the flooding child succeeds when both redirected pipes are drained concurrently'
    Assert-Equal 0 @($floodSamples | Where-Object Correct -ne 'True').Count 'the flooding probe retains only correct samples'
    Assert-True (-not (Test-Path -LiteralPath (Join-Path $floodDirectory 'Failures.json'))) 'a successful flooding probe does not create failure evidence'
    Assert-Equal 0 @(Get-ChildItem -LiteralPath $floodDirectory -Filter '*.tmp' -Force).Count 'the flooding probe leaves no atomic-write temporary files'

    Assert-Equal $summaryHash (Get-FileHash -LiteralPath $summaryPath -Algorithm SHA256).Hash 'later failed and successful probes preserve the original Summary.json'
    Assert-Equal $samplesHash (Get-FileHash -LiteralPath $samplesPath -Algorithm SHA256).Hash 'later failed and successful probes preserve the original Samples.csv'
}
finally {
    if (Test-Path -LiteralPath $contractRoot) {
        Remove-Item -LiteralPath $contractRoot -Recurse -Force
    }
}

Write-Output 'Test-Hardness.Tests.ps1: PASS'
