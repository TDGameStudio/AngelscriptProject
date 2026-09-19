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

$runner = Join-Path $PSScriptRoot '..\scripts\Test-Harness.ps1'
Assert-True (Test-Path -LiteralPath $runner -PathType Leaf) 'Test-Harness.ps1 exists'

$tokens = $null
$errors = $null
[void][System.Management.Automation.Language.Parser]::ParseFile($runner, [ref]$tokens, [ref]$errors)
Assert-Equal 0 @($errors).Count 'Test-Harness.ps1 parses in the current host'

$runnerCommand = Get-Command -Name $runner -ErrorAction Stop
Assert-True ('PowerShellHosts' -notin @($runnerCommand.Parameters.Keys)) 'the public runner exposes no legacy multi-host selector'
$runnerText = Get-Content -LiteralPath $runner -Raw
Assert-True ($runnerText.Contains('Saved\Harness\Performance')) 'the public runner defaults raw evidence below Saved/Harness'
Assert-True (-not $runnerText.Contains('Saved\Harness\Harness\Performance')) 'the retired nested performance path is absent'

$quick = @(& $runner -Profile Quick -ListChecks)
$performance = @(& $runner -Profile Performance -ListChecks -WarmupRuns 1 -MeasurementRuns 1)
$explicitPerformance = @(& $runner -Profile Performance -ListChecks -WarmupRuns 1 -MeasurementRuns 1 -TaskChange 'fixture/custom')
$integration = @(& $runner -Profile Integration -ListChecks)

foreach ($name in @(
        'Harness.PS7',
        'HarnessDraft.PS7',
        'HarnessChangeGate.PS7',
        'HarnessHandoff.PS7',
        'HarnessRecording.PS7',
        'HarnessEvolution.PS7',
        'HarnessMutationGate.PS7',
        'HarnessCutover.PS7',
        'HarnessGateContract.PS7',
        'Protocol.PS7',
        'Workspace.PS7',
        'WorkspaceRemovalActivity.PS7',
        'WorkspaceQueryPerformance.PS7',
        'GitOperations.PS7',
        'OpenSpecSkill.PS7',
        'UnrealIntegration.PS7',
        'UnrealExternalAdmission.PS7',
        'UnrealCancellationSafety.PS7',
        'UnrealRunAdmission.PS7',
        'UnrealRemovalProcessInspection.PS7')) {
    Assert-True ($name -in @($quick.Name)) "Quick profile contains $name"
}
Assert-Equal 25 @($quick).Count 'Quick profile includes workflow, queue, replica, feedback, mutation and peripheral boundary fixtures'
Assert-Equal '-Tag|ExternalAdmission' ((@($quick | Where-Object Name -eq 'UnrealExternalAdmission.PS7')[0].Arguments | Select-Object -Last 2) -join '|') 'the external UBT check executes its focused admission cases'
Assert-Equal 0 @($quick | Where-Object Name -match 'PS5|WindowsPowerShell').Count 'Quick exposes no legacy host check'

foreach ($name in @('HarnessPerformance.PS7')) {
    Assert-True ($name -in @($performance.Name)) "Performance profile contains $name"
}
Assert-Equal 1 @($performance).Count 'Performance profile measures only PowerShell 7'

foreach ($name in @('Harness.Installation', 'OpenSpec.Doctor', 'OpenSpec.Workflow', 'OpenSpec.Validate')) {
    Assert-True ($name -in @($integration.Name)) "Integration profile contains $name"
}
foreach ($name in @('HarnessPerformance.PS7')) {
    Assert-True ($name -in @($integration.Name)) "Integration contains $name"
}
Assert-Equal 30 @($integration).Count 'Integration contains twenty-five scripts, one performance run, and four route checks'
Assert-Equal 1 @($integration | Where-Object Name -eq 'UnrealIntegration.PS7').Count 'Integration contains the fixture-only Unreal route gate exactly once'
Assert-Equal $quick.Count @($integration | Where-Object Kind -eq 'Script').Count 'Integration keeps the complete Quick script matrix'
Assert-Equal $performance.Count @($integration | Where-Object Kind -eq 'Performance').Count 'Integration includes the complete Performance matrix'

foreach ($check in @($integration | Where-Object Kind -in @('Script', 'Performance'))) {
    Assert-Equal 'pwsh.exe' ([System.IO.Path]::GetFileName($check.Executable)) "$($check.Name) launches PowerShell 7"
    Assert-True ($check.Name -notmatch 'PS5|WindowsPowerShell') "$($check.Name) has no legacy host identity"
}

$harnessManifestData = Import-PowerShellDataFile -LiteralPath (Join-Path $PSScriptRoot '..\scripts\Harness.psd1')
$workspaceManifestData = Import-PowerShellDataFile -LiteralPath (Join-Path $PSScriptRoot '..\..\workspace-lifecycle\scripts\WorkspaceLifecycle.psd1')
$gitManifestData = Import-PowerShellDataFile -LiteralPath (Join-Path $PSScriptRoot '..\..\git-operations\scripts\GitOperations.psd1')
$unrealManifestData = Import-PowerShellDataFile -LiteralPath (Join-Path $PSScriptRoot '..\..\unreal-engine-develop\scripts\UnrealEngineDevelop.psd1')
foreach ($manifestData in @($harnessManifestData, $workspaceManifestData, $gitManifestData, $unrealManifestData)) {
    Assert-Equal '7.0' ([string]$manifestData.PowerShellVersion) 'public module manifests require PowerShell 7.0 or later'
    Assert-Equal 'Core' (@($manifestData.CompatiblePSEditions) -join '|') 'public module manifests support only the Core edition'
}

foreach ($check in @($quick | Where-Object Kind -eq 'Script')) {
    Assert-True (Test-Path -LiteralPath $check.Path -PathType Leaf) "$($check.Name) references an existing test script"
}
Assert-True ($runnerText -match '(?m)^#requires -PSEdition Core\s*$') 'the public runner rejects Windows PowerShell'

$unrealQuickCheck = $quick | Where-Object Name -eq 'UnrealIntegration.PS7' | Select-Object -First 1
Assert-True ($null -ne $unrealQuickCheck) 'Quick exposes the fixture-only Unreal integration check'
Assert-True ('-Tag' -in @($unrealQuickCheck.Arguments)) 'the Unreal Quick check selects a bounded tag'
$unrealTagIndex = [array]::IndexOf([object[]]@($unrealQuickCheck.Arguments), '-Tag')
Assert-Equal 'Integration' $unrealQuickCheck.Arguments[$unrealTagIndex + 1] 'the Unreal Quick check never runs the full or real-UE suite'

$projectRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..\..\..'))
$unrealModulePath = Join-Path $projectRoot '.agents\skills\unreal-engine-develop\scripts\UnrealEngineDevelop.psm1'
$unrealWindowsPath = Join-Path $projectRoot '.agents\skills\unreal-engine-develop\scripts\Private\WindowsPath.ps1'
$unrealModuleText = Get-Content -LiteralPath $unrealModulePath -Raw
Assert-True (Test-Path -LiteralPath $unrealWindowsPath -PathType Leaf) 'the Unreal leaf owns its Windows execution-path implementation'
Assert-True ($unrealModuleText -match "harness-unreal-request") 'the Unreal leaf publishes the stable Request schema'
Assert-True ($unrealModuleText -match "harness-unreal-run") 'the Unreal leaf publishes the stable Run schema'
Assert-True ($unrealModuleText -notmatch '(?i)(?:^|[\\/])Tools[\\/].*\.ps1') 'the Unreal leaf has no operational dependency on root Tools scripts'

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

$performanceLeaf = Join-Path $PSScriptRoot 'Harness.Performance.Tests.ps1'
$contractRoot = Join-Path ([System.IO.Path]::GetTempPath()) ('harness-performance-contract-' + [guid]::NewGuid().ToString('N'))
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
    Assert-Equal 'HarnessPerformanceRaw' $summary.RecordType 'the performance summary identifies its record type'
    Assert-Equal 'Passed' $summary.OverallStatus 'the minimal performance correctness sample passes its budgets'
    Assert-Equal 'fixture/performance' $summary.Parameters.TaskChange 'the default performance run uses its self-contained Task Graph fixture'
    Assert-Equal 8 @($summary.Scenarios).Count 'the performance summary contains all eight focused scenarios'
    Assert-Equal 'FreshProcess|PersistentApi|TaskStatus|FastWorkspaceStatus|HarnessStatus|DetailedWorkspaceStatus|ObservationWrite|EvolutionStatus' (@($summary.Scenarios.Name) -join '|') 'the performance summary keeps the focused scenario order'

    $samples = @(Import-Csv -LiteralPath $samplesPath)
    Assert-Equal 8 $samples.Count 'one measured sample is retained for each scenario'
    Assert-Equal 0 @($samples | Where-Object Correct -ne 'True').Count 'every retained sample passed its behavior assertion'
    Assert-Equal 'Scenario|Phase|Iteration|Unit|Value|Correct' (@($samples[0].PSObject.Properties.Name) -join '|') 'the raw sample table schema remains stable'
    Assert-True ($summaryText -notmatch [regex]::Escape($projectRoot)) 'the performance summary omits the absolute project path'
    foreach ($privateValue in @($env:USERNAME, $env:COMPUTERNAME, $env:USERPROFILE)) {
        if (-not [string]::IsNullOrWhiteSpace([string]$privateValue)) {
            Assert-True ($summaryText -notmatch [regex]::Escape([string]$privateValue)) 'the performance summary omits machine and user identity'
        }
    }

    # An explicit TaskChange selects a real workspace for reads, never for synthetic observations.
    $explicitRoot = Join-Path $contractRoot 'explicit-project'
    [void](New-Item -ItemType Directory -Path $explicitRoot)
    & git -C $explicitRoot init -b main | Out-Null
    Assert-Equal 0 $LASTEXITCODE 'the explicit-project fixture initializes Git'
    [IO.File]::WriteAllText((Join-Path $explicitRoot '.gitignore'), "Saved/`nAgentConfig.ini`n")
    [IO.File]::WriteAllText((Join-Path $explicitRoot 'Fixture.uproject'), "{}`n")
    & git -C $explicitRoot add .gitignore Fixture.uproject
    Assert-Equal 0 $LASTEXITCODE 'the explicit-project fixture stages its baseline'
    & git -C $explicitRoot -c user.name='Harness Fixture' -c user.email=fixture@example.invalid commit -m fixture | Out-Null
    Assert-Equal 0 $LASTEXITCODE 'the explicit-project fixture commits its baseline'
    $explicitBin = Join-Path $explicitRoot '.agents/skills/openspec/bin'
    [void](New-Item -ItemType Directory -Path $explicitBin -Force)
    $explicitExe = Join-Path $explicitBin 'openspec.exe'
    Copy-Item -LiteralPath (Join-Path $projectRoot '.agents/skills/openspec/bin/openspec.exe') -Destination $explicitExe
    & $explicitExe init $explicitRoot --project-id performance-isolation --title 'Performance Isolation' --workflow spec-driven --language en | Out-Null
    Assert-Equal 0 $LASTEXITCODE 'the explicit-project fixture initializes OpenSpec'
    Push-Location -LiteralPath $explicitRoot
    try {
        & $explicitExe domain create fixture --title Fixture --description Fixture --json | Out-Null
        Assert-Equal 0 $LASTEXITCODE 'the explicit-project fixture creates its domain'
        & $explicitExe change create fixture/custom --title 'Explicit task' --goal 'Measure a selected active task' --json | Out-Null
        Assert-Equal 0 $LASTEXITCODE 'the explicit-project fixture creates its active Change'
    }
    finally { Pop-Location }
    $explicitChangeRoot = Join-Path $explicitRoot 'openspec/changes/fixture/custom'
    [IO.File]::WriteAllText((Join-Path $explicitChangeRoot 'tasks.md'), @'
---
task_graph:
  version: 1
  depends_on:
    "1.1": []
---

## Tasks

## [ ] 1.1 Explicit task fixture

**Files**

```diff
 fixture
```

**Verification**

```sh
fixture
```
'@)
    $explicitDataRoot = Join-Path $explicitChangeRoot 'attachments/data'
    [void](New-Item -ItemType Directory -Path $explicitDataRoot -Force)
    [IO.File]::WriteAllText((Join-Path $explicitDataRoot 'harness-origin.json'), '{"schema":1,"changeId":"fixture/custom","origin":"Direct","reason":"Isolated performance contract fixture"}')
    [IO.File]::WriteAllText((Join-Path $explicitChangeRoot 'design.md'), "## Call chains`n`nnone — isolated task parser input.`n")
    $explicitObservations = Join-Path $explicitRoot 'Saved/Harness/Observations'
    [void](New-Item -ItemType Directory -Path $explicitObservations -Force)
    [IO.File]::WriteAllText((Join-Path $explicitObservations 'user-feedback.json'), '{"schemaVersion":"harness-observation-v1","runId":"user-feedback","observedAtUtc":"2026-09-01T00:00:00Z","category":"explanation","summary":"Preserve this real user feedback."}')
    [IO.File]::WriteAllText((Join-Path $explicitObservations 'INBOX.md'), "# Existing user feedback`n")
    $feedbackHashes = @{}
    foreach ($file in @(Get-ChildItem -LiteralPath $explicitObservations -File -Recurse)) {
        $feedbackHashes[$file.FullName] = (Get-FileHash -LiteralPath $file.FullName -Algorithm SHA256).Hash
    }
    & $performanceLeaf -ProjectRoot $explicitRoot -OutputRoot $contractRoot -RunId 'explicit-change' -TaskChange 'fixture/custom' -WarmupRuns 1 -MeasurementRuns 1 -BatchSize 100 | Out-Null
    $explicitSummary = Get-Content -LiteralPath (Join-Path $contractRoot 'explicit-change/Summary.json') -Raw | ConvertFrom-Json
    $explicitSamples = @(Import-Csv -LiteralPath (Join-Path $contractRoot 'explicit-change/Samples.csv'))
    Assert-Equal 'Passed' $explicitSummary.OverallStatus 'the explicit Change performance sample succeeds'
    Assert-Equal 'fixture/custom' $explicitSummary.Parameters.TaskChange 'the explicit Change remains the task.status measurement target'
    Assert-Equal 2 @($explicitSamples | Where-Object { $_.Scenario -eq 'ObservationWrite' -and $_.Correct -eq 'True' }).Count 'warmup and measured observation writes really execute'
    Assert-Equal 2 @(Get-ChildItem -LiteralPath $explicitObservations -File -Recurse).Count 'explicit TaskChange must not add performance probes to the selected workspace feedback store'
    foreach ($path in $feedbackHashes.Keys) {
        Assert-Equal $feedbackHashes[$path] (Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash 'explicit TaskChange preserves existing raw feedback and its inbox byte-for-byte'
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
    Assert-Equal 'HarnessPerformanceFailures' $hungFailures.RecordType 'failure evidence identifies its stable record type'
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
        $resolvedContractRoot = [IO.Path]::GetFullPath($contractRoot)
        $temporaryRoot = [IO.Path]::GetFullPath([IO.Path]::GetTempPath()).TrimEnd('\', '/') + [IO.Path]::DirectorySeparatorChar
        Assert-True ($resolvedContractRoot.StartsWith($temporaryRoot, [StringComparison]::OrdinalIgnoreCase) -and [IO.Path]::GetFileName($resolvedContractRoot).StartsWith('harness-performance-contract-', [StringComparison]::Ordinal)) 'contract cleanup remains inside its owned temporary directory'
        Remove-Item -LiteralPath $resolvedContractRoot -Recurse -Force
    }
}

Write-Output 'Test-Harness.Tests.ps1: PASS'
