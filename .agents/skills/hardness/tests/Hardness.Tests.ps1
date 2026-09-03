[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Assert-True {
    param([bool]$Condition, [string]$Message)
    if (-not $Condition) {
        throw "Assertion failed: $Message"
    }
}

function Assert-Equal {
    param($Expected, $Actual, [string]$Message)
    if ($Expected -ne $Actual) {
        throw "Assertion failed: $Message (expected '$Expected', actual '$Actual')"
    }
}

function Assert-Match {
    param([string]$Actual, [string]$Pattern, [string]$Message)
    if ($Actual -notmatch $Pattern) {
        throw "Assertion failed: $Message (actual '$Actual', pattern '$Pattern')"
    }
}

function Assert-Throws {
    param([scriptblock]$Action, [string]$Pattern, [string]$Message)
    try {
        & $Action
    }
    catch {
        Assert-Match -Actual $_.Exception.Message -Pattern $Pattern -Message $Message
        return
    }
    throw "Assertion failed: $Message (action did not throw)"
}

function Invoke-FixtureGit {
    param([string]$Repository, [string[]]$Arguments)
    $previousPreference = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {
        $output = @(& git -C $Repository @Arguments 2>&1)
        $exitCode = $LASTEXITCODE
    }
    finally {
        $ErrorActionPreference = $previousPreference
    }
    if ($exitCode -ne 0) {
        throw "Fixture git command failed: git -C '$Repository' $($Arguments -join ' ')`n$($output -join [Environment]::NewLine)"
    }
    return @($output | ForEach-Object { [string]$_ })
}

function New-InstallationFixture {
    param(
        [Parameter(Mandatory = $true)][string]$Root,
        [Parameter(Mandatory = $true)][string]$SourceRoot
    )

    $workspaceTarget = Join-Path $Root '.agents\skills\workspace-lifecycle\scripts'
    $gitTarget = Join-Path $Root '.agents\skills\git-operations\scripts'
    $unrealTarget = Join-Path $Root '.agents\skills\unreal-engine-develop\scripts'
    $openspecTarget = Join-Path $Root '.agents\skills\openspec'
    [void](New-Item -ItemType Directory -Path $workspaceTarget -Force)
    [void](New-Item -ItemType Directory -Path $gitTarget -Force)
    [void](New-Item -ItemType Directory -Path $unrealTarget -Force)
    [void](New-Item -ItemType Directory -Path (Join-Path $openspecTarget 'bin') -Force)
    Copy-Item -LiteralPath (Join-Path $SourceRoot '.agents\skills\workspace-lifecycle\scripts\WorkspaceLifecycle.psm1') -Destination $workspaceTarget
    Copy-Item -LiteralPath (Join-Path $SourceRoot '.agents\skills\workspace-lifecycle\scripts\WorkspaceLifecycle.psd1') -Destination $workspaceTarget
    Copy-Item -LiteralPath (Join-Path $SourceRoot '.agents\skills\git-operations\scripts\GitOperations.psm1') -Destination $gitTarget
    Copy-Item -LiteralPath (Join-Path $SourceRoot '.agents\skills\git-operations\scripts\GitOperations.psd1') -Destination $gitTarget
    Copy-Item -LiteralPath (Join-Path $SourceRoot '.agents\skills\unreal-engine-develop\scripts\UnrealEngineDevelop.psm1') -Destination $unrealTarget
    Copy-Item -LiteralPath (Join-Path $SourceRoot '.agents\skills\unreal-engine-develop\scripts\UnrealEngineDevelop.psd1') -Destination $unrealTarget
    Copy-Item -LiteralPath (Join-Path $SourceRoot '.agents\skills\openspec\bin\openspec.exe') -Destination (Join-Path $openspecTarget 'bin\openspec.exe')
    Copy-Item -LiteralPath (Join-Path $SourceRoot '.agents\skills\openspec\commands') -Destination $openspecTarget -Recurse
    Copy-Item -LiteralPath (Join-Path $SourceRoot '.agents\skills\openspec\release-manifest.json') -Destination $openspecTarget
    return $Root
}

function Set-FixtureManifestValue {
    param(
        [Parameter(Mandatory = $true)][string]$Root,
        [Parameter(Mandatory = $true)][string]$Name,
        $Value
    )

    $path = Join-Path $Root '.agents\skills\openspec\release-manifest.json'
    $metadata = Get-Content -LiteralPath $path -Raw | ConvertFrom-Json
    $metadata.$Name = $Value
    $json = $metadata | ConvertTo-Json -Depth 20 -Compress
    [System.IO.File]::WriteAllText($path, $json, [System.Text.UTF8Encoding]::new($false))
}

$manifest = Join-Path $PSScriptRoot '..\scripts\Hardness.psd1'
$moduleFile = Join-Path $PSScriptRoot '..\scripts\Hardness.psm1'

$tokens = $null
$errors = $null
[void][System.Management.Automation.Language.Parser]::ParseFile($moduleFile, [ref]$tokens, [ref]$errors)
Assert-Equal 0 @($errors).Count 'Hardness.psm1 must parse without errors'

$scratch = Join-Path ([System.IO.Path]::GetTempPath()) ("hardness-import-{0}" -f [guid]::NewGuid().ToString('N'))
[void](New-Item -ItemType Directory -Path $scratch)
try {
    Push-Location $scratch
    try {
        Import-Module $manifest -Force
        Assert-Equal 0 @(Get-ChildItem -LiteralPath $scratch -Force).Count 'module import must not write to the current directory'
        Assert-Equal 0 @(Get-Module UnrealEngineDevelop -All).Count 'importing Hardness must not import the Unreal leaf'
    }
    finally {
        Pop-Location
    }

    $expectedFunctions = @(
        'New-HardnessContext',
        'Get-HardnessCommand',
        'Invoke-Hardness',
        'Test-HardnessInstallation'
    )
    $exported = @((Get-Module Hardness).ExportedFunctions.Keys | Sort-Object)
    Assert-Equal (($expectedFunctions | Sort-Object) -join '|') (($exported | Sort-Object) -join '|') 'public API must stay minimal'

    $repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..\..\..')).Path
    $context = New-HardnessContext -WorkspaceRoot $repoRoot
    foreach ($property in @('SchemaVersion', 'HarnessRoot', 'WorkspaceRoot', 'PrimaryRoot', 'GitCommonDir', 'Topology', 'WorktreeName', 'Branch', 'Head', 'Managed')) {
        Assert-True ($property -in @($context.PSObject.Properties.Name)) "context must contain '$property'"
    }
    Assert-Equal '2' $context.SchemaVersion 'workspace context schema is versioned'
    Assert-Equal $repoRoot $context.HarnessRoot 'context loads the harness from this checkout'
    Assert-Equal $repoRoot $context.WorkspaceRoot 'context targets the requested registered workspace'
    Assert-Equal 'Primary' $context.Topology 'the main checkout derives Primary topology from Git'
    Assert-True ('Mode' -notin @($context.PSObject.Properties.Name)) 'repository mode is not part of context'
    Assert-True ('GoalName' -notin @($context.PSObject.Properties.Name)) 'Goal name is not part of context'
    $contextParameters = @((Get-Command New-HardnessContext).Parameters.Keys)
    Assert-True ('Mode' -notin $contextParameters) 'New-HardnessContext exposes no mode compatibility parameter'
    Assert-True ('GoalName' -notin $contextParameters) 'New-HardnessContext exposes no Goal-name compatibility parameter'
    Assert-True ('ProjectRoot' -notin $contextParameters) 'WorkspaceRoot is the only repository-selection parameter'

    $routes = @(Get-HardnessCommand)
    foreach ($name in @(
        'workspace.list', 'workspace.status', 'workspace.new', 'workspace.bootstrap', 'workspace.verify', 'workspace.remove', 'workspace.activate',
        'workspace.config.status', 'workspace.config.get', 'workspace.config.set',
        'git.status', 'git.commit', 'git.integrate', 'git.push',
        'hardness.status', 'hardness.observe', 'hardness.evolution.status', 'openspec.maintenance.status',
        'task.status',
        'openspec.validate', 'openspec.change'
    )) {
        Assert-True ($name -in @($routes.Name)) "route '$name' must be registered"
    }
    $expectedUnrealRoutes = [ordered]@{
        'ue.status'           = 'Get-HardnessUnrealStatus'
        'ue.engine.list'      = 'Get-HardnessUnrealEngineList'
        'ue.target.list'      = 'Get-HardnessUnrealTargetList'
        'ue.process.list'     = 'Get-HardnessUnrealProcessList'
        'ue.ubt.capabilities' = 'Get-HardnessUnrealUbtCapabilities'
        'ue.ubt.invoke'       = 'Invoke-HardnessUnrealUbt'
        'ue.build'            = 'Invoke-HardnessUnrealBuild'
        'ue.test'             = 'Invoke-HardnessUnrealTest'
        'ue.commandlet'       = 'Invoke-HardnessUnrealCommandlet'
        'ue.suite.list'       = 'Get-HardnessUnrealSuiteList'
        'ue.suite.plan'       = 'New-HardnessUnrealSuitePlan'
        'ue.suite.run'        = 'Invoke-HardnessUnrealSuite'
        'ue.run.status'       = 'Get-HardnessUnrealRunStatus'
        'ue.run.cancel'       = 'Stop-HardnessUnrealRun'
    }
    $unrealRoutes = @($routes | Where-Object { $_.Name -like 'ue.*' })
    Assert-Equal $expectedUnrealRoutes.Count $unrealRoutes.Count 'Hardness publishes exactly the complete Unreal route surface'
    Assert-Equal (($expectedUnrealRoutes.Keys | Sort-Object) -join '|') (($unrealRoutes.Name | Sort-Object) -join '|') 'Hardness publishes no missing or extra Unreal route'
    foreach ($routeName in $expectedUnrealRoutes.Keys) {
        $route = $unrealRoutes | Where-Object Name -eq $routeName | Select-Object -First 1
        Assert-Equal 'PowerShell' $route.Kind "$routeName is a PowerShell leaf route"
        Assert-Equal '.agents/skills/unreal-engine-develop/scripts/UnrealEngineDevelop.psd1' $route.Target "$routeName resolves the reviewed Unreal manifest from HarnessRoot"
        Assert-Equal $expectedUnrealRoutes[$routeName] $route.EntryPoint "$routeName maps to its exact public function"
    }
    $buildRoute = $unrealRoutes | Where-Object Name -eq 'ue.build' | Select-Object -First 1
    Assert-True $buildRoute.Defaults.ContainsKey('BuildConcurrency') 'ue.build exposes the typed BuildConcurrency route default'
    Assert-Equal 'Auto' $buildRoute.Defaults.BuildConcurrency 'ue.build defaults BuildConcurrency to Auto'
    $cancelRoute = $unrealRoutes | Where-Object Name -eq 'ue.run.cancel' | Select-Object -First 1
    Assert-True (-not $cancelRoute.Defaults.ContainsKey('Confirm')) 'ue.run.cancel does not silently disable confirmation'
    Assert-Equal 0 @($routes | Where-Object { $_.Name -match '^(staticjit\.|cache\.|coverage$|standalone\.|engine\.|execution\.|toolchain\.)' }).Count 'unimplemented non-Unreal leaf routes remain unpublished'

    $first = Invoke-Hardness -Command 'workspace.status' -Context $context
    $second = Invoke-Hardness -Command 'workspace.status' -Context $context
    foreach ($result in @($first, $second)) {
        foreach ($property in @('schemaVersion', 'command', 'runId', 'status', 'exitCode', 'durationMs', 'artifacts', 'data', 'error')) {
            Assert-True ($property -in @($result.PSObject.Properties.Name)) "result must contain '$property'"
        }
        Assert-Equal '1.0' $result.schemaVersion 'result schema is versioned'
        Assert-Equal 'workspace.status' $result.command 'result identifies its route'
        Assert-Equal 'Succeeded' $result.status 'workspace status succeeds repeatedly in one session'
        Assert-Equal 0 $result.exitCode 'successful route returns exit code zero'
        Assert-Equal 0 @($result.artifacts).Count 'a route with no artifacts returns an empty array, not a null entry'
    }
    Assert-True ($first.runId -ne $second.runId) 'each invocation gets a distinct run id'

    $unknown = Invoke-Hardness -Command 'missing.route' -Context $context
    Assert-Equal 'Failed' $unknown.status 'unknown route returns a failed envelope instead of terminating the session'
    Assert-True (-not [string]::IsNullOrWhiteSpace([string]$unknown.error.message)) 'failed envelope contains an error message'

    $nativeFailure = Invoke-Hardness -Command 'openspec.validate' -Context $context -ArgumentList @('__hardness_missing_target__', '--json')
    Assert-Equal 'Failed' $nativeFailure.status 'a native non-zero exit returns a failed envelope'
    Assert-Equal 1 $nativeFailure.exitCode 'native exit code is preserved'
    Assert-True ($null -ne $nativeFailure.data) 'native failure preserves its diagnostic data'
    Assert-True (@($nativeFailure.data.Output).Count -gt 0) 'native failure preserves stdout and stderr output'

    $sourceOpenSpec = Join-Path $repoRoot '.agents\skills\openspec\bin\openspec.exe'
    $taskWorkspaceRoot = Join-Path $scratch 'task-workspace'
    $taskWorkspaceExeDirectory = Join-Path $taskWorkspaceRoot '.agents\skills\openspec\bin'
    [void](New-Item -ItemType Directory -Path $taskWorkspaceExeDirectory -Force)
    Copy-Item -LiteralPath $sourceOpenSpec -Destination (Join-Path $taskWorkspaceExeDirectory 'openspec.exe')
    [void](Invoke-FixtureGit -Repository $taskWorkspaceRoot -Arguments @('init', '-b', 'main'))
    [System.IO.File]::WriteAllText((Join-Path $taskWorkspaceRoot '.gitignore'), "Saved/`nAgentConfig.ini`n")
    [System.IO.File]::WriteAllText((Join-Path $taskWorkspaceRoot 'Fixture.uproject'), "{}`n")
    $taskWorkspaceContext = New-HardnessContext -WorkspaceRoot $taskWorkspaceRoot

    $taskWorkspaceInit = Invoke-Hardness -Command 'openspec.init' -Context $taskWorkspaceContext -ArgumentList @(
        '--project-id', 'hardness-task-workspace',
        '--title', 'Hardness Task Workspace Fixture'
    )
    Assert-Equal 'Succeeded' $taskWorkspaceInit.status 'Task Graph fixture initializes through the selected workspace'
    $taskWorkspaceDomain = Invoke-Hardness -Command 'openspec.domain' -Context $taskWorkspaceContext -ArgumentList @(
        'create', 'fixture', '--title', 'Fixture', '--description', 'Fixture', '--json'
    )
    Assert-Equal 'Succeeded' $taskWorkspaceDomain.status 'Task Graph fixture domain is created'
    $taskWorkspaceChange = Invoke-Hardness -Command 'openspec.change' -Context $taskWorkspaceContext -ArgumentList @(
        'create', 'fixture/dag', '--title', 'Task DAG', '--goal', 'Verify Hardness task recognition', '--json'
    )
    Assert-Equal 'Succeeded' $taskWorkspaceChange.status 'Task Graph fixture change is created'

    $taskSeparator = [string][char]0x2014
    $taskWorkspacePath = Join-Path $taskWorkspaceRoot 'openspec\changes\fixture\dag\tasks.md'
    $taskWorkspaceDocument = @'
---
task_graph:
  version: 1
  depends_on:
    "1.1": []
    "1.2": ["1.1"]
    "1.10": []
    "2.1": ["1.2"]
---

## Tasks

- [ ] 1.10 Independent work __TASK_SEPARATOR__ verify: `independent`
  > Files: `independent`

- [ ] 2.1 Blocked work __TASK_SEPARATOR__ verify: `blocked`
  > Files: `blocked`

- [ ] 1.2 Ready work __TASK_SEPARATOR__ verify: `ready`
  > Files: `ready`

- [x] 1.1 Completed base __TASK_SEPARATOR__ verify: `base`
  > Files: `base`
'@
    $taskWorkspaceDocument = $taskWorkspaceDocument.Replace('__TASK_SEPARATOR__', $taskSeparator)
    [System.IO.File]::WriteAllText($taskWorkspacePath, $taskWorkspaceDocument, [System.Text.UTF8Encoding]::new($false))

    $taskStatus = Invoke-Hardness -Command 'task.status' -Context $taskWorkspaceContext -Parameters @{ Change = 'fixture/dag' }
    Assert-Equal 'Succeeded' $taskStatus.status 'task.status recognizes a selected workspace Task Graph'
    Assert-Equal 'fixture/dag' $taskStatus.data.changeId 'task.status returns the selected change'
    Assert-True ('tasks' -in @($taskStatus.data.PSObject.Properties.Name)) 'task.status returns parsed TaskPlan data'
    Assert-True ('Output' -notin @($taskStatus.data.PSObject.Properties.Name)) 'task.status does not expose an untyped native-output wrapper'
    Assert-Equal '1.1|1.2|1.10|2.1' (@($taskStatus.data.tasks.id) -join '|') 'task.status presents task IDs in natural numeric order'
    $completedTask = $taskStatus.data.tasks | Where-Object id -eq '1.1' | Select-Object -First 1
    $readyTask = $taskStatus.data.tasks | Where-Object id -eq '1.2' | Select-Object -First 1
    $independentTask = $taskStatus.data.tasks | Where-Object id -eq '1.10' | Select-Object -First 1
    $blockedTask = $taskStatus.data.tasks | Where-Object id -eq '2.1' | Select-Object -First 1
    Assert-True $completedTask.done 'task.status preserves completed checkbox state'
    Assert-True (-not $completedTask.ready) 'completed work is never returned Ready'
    Assert-Equal '1.1' (@($readyTask.after) -join '|') 'task.status preserves normalized direct predecessors'
    Assert-True $readyTask.ready 'an incomplete task with completed predecessors is Ready'
    Assert-True $independentTask.ready 'an incomplete root task is Ready'
    Assert-True (-not $blockedTask.ready) 'an incomplete task with an incomplete predecessor remains blocked'
    foreach ($duplicateState in @('readyTasks', 'readyTaskIds', 'blockedTasks', 'blockedTaskIds')) {
        Assert-True ($duplicateState -notin @($taskStatus.data.PSObject.Properties.Name)) "task.status does not duplicate derived state as '$duplicateState'"
    }

    $taskCycleDocument = @'
---
task_graph:
  version: 1
  depends_on:
    "1.1": ["1.2"]
    "1.2": ["1.1"]
---

## Tasks

- [ ] 1.1 First __TASK_SEPARATOR__ verify: `first`
  > Files: `first`

- [ ] 1.2 Second __TASK_SEPARATOR__ verify: `second`
  > Files: `second`
'@
    $taskCycleDocument = $taskCycleDocument.Replace('__TASK_SEPARATOR__', $taskSeparator)
    [System.IO.File]::WriteAllText($taskWorkspacePath, $taskCycleDocument, [System.Text.UTF8Encoding]::new($false))
    $cycleStatus = Invoke-Hardness -Command 'task.status' -Context $taskWorkspaceContext -Parameters @{ Change = 'fixture/dag' }
    Assert-Equal 'Succeeded' $cycleStatus.status 'task.status preserves a successfully inspected invalid Task Graph in its envelope'
    Assert-Equal 'waiting' $cycleStatus.data.state 'an invalid Task Graph remains waiting instead of becoming schedulable'
    Assert-True ('cycle' -in @($cycleStatus.data.taskIssues.code)) 'task.status preserves OpenSpec cycle diagnostics'
    Assert-Equal 0 @($cycleStatus.data.tasks | Where-Object ready).Count 'task.status never produces Ready work from a cycle'

    $missingTaskStatus = Invoke-Hardness -Command 'task.status' -Context $taskWorkspaceContext -Parameters @{ Change = 'fixture/missing' }
    Assert-Equal 'Failed' $missingTaskStatus.status 'task.status reports a missing change through the common failed envelope'
    Assert-True ($missingTaskStatus.exitCode -ne 0) 'task.status preserves the missing-change native exit code'
    Assert-True (-not [string]::IsNullOrWhiteSpace([string]$missingTaskStatus.error.message)) 'task.status preserves the missing-change diagnostic'

    $fixtureProject = Join-Path $scratch 'fixture-project'
    [void](New-Item -ItemType Directory -Path $fixtureProject)
    [void](Invoke-FixtureGit -Repository $fixtureProject -Arguments @('init', '-b', 'main'))
    $fixtureModuleDirectory = Join-Path $fixtureProject '.agents\\skills\\workspace-lifecycle\\scripts'
    $fixtureGitModuleDirectory = Join-Path $fixtureProject '.agents\\skills\\git-operations\\scripts'
    [void](New-Item -ItemType Directory -Path $fixtureModuleDirectory -Force)
    [void](New-Item -ItemType Directory -Path $fixtureGitModuleDirectory -Force)
    Copy-Item -LiteralPath (Join-Path $repoRoot '.agents\\skills\\workspace-lifecycle\\scripts\\WorkspaceLifecycle.psm1') -Destination $fixtureModuleDirectory
    Copy-Item -LiteralPath (Join-Path $repoRoot '.agents\\skills\\workspace-lifecycle\\scripts\\WorkspaceLifecycle.psd1') -Destination $fixtureModuleDirectory
    Copy-Item -LiteralPath (Join-Path $repoRoot '.agents\\skills\\git-operations\\scripts\\GitOperations.psm1') -Destination $fixtureGitModuleDirectory
    Copy-Item -LiteralPath (Join-Path $repoRoot '.agents\\skills\\git-operations\\scripts\\GitOperations.psd1') -Destination $fixtureGitModuleDirectory
    [System.IO.File]::WriteAllText((Join-Path $fixtureProject '.gitignore'), ".worktrees/`nAgentConfig.ini`nSaved/`n")
    [System.IO.File]::WriteAllText((Join-Path $fixtureProject 'Fixture.uproject'), "{}`n")
    [System.IO.File]::WriteAllText((Join-Path $fixtureProject 'fixture.txt'), "fixture`n")
    [void](Invoke-FixtureGit -Repository $fixtureProject -Arguments @('add', '--', '.'))
    [void](Invoke-FixtureGit -Repository $fixtureProject -Arguments @('-c', 'user.name=Hardness Tests', '-c', 'user.email=hardness-tests@example.invalid', 'commit', '-m', 'fixture'))

    $externalContainer = Join-Path $scratch 'external-worktrees'
    [void](New-Item -ItemType Directory -Path $externalContainer)
    $fixtureWorkspace = Join-Path $externalContainer 'fixture-workspace'
    [void](Invoke-FixtureGit -Repository $fixtureProject -Arguments @('worktree', 'add', '-b', 'feature/fixture-workspace', $fixtureWorkspace, 'HEAD'))

    $fixturePrimaryContext = New-HardnessContext -WorkspaceRoot $fixtureProject
    $workspaceContext = New-HardnessContext -WorkspaceRoot $fixtureWorkspace
    Assert-Equal $repoRoot $workspaceContext.HarnessRoot 'a target worktree does not change the loaded harness root'
    Assert-Equal $fixtureWorkspace $workspaceContext.WorkspaceRoot 'context targets an arbitrary registered worktree'
    Assert-Equal $fixtureProject $workspaceContext.PrimaryRoot 'context records the registered primary checkout'
    Assert-Equal 'Worktree' $workspaceContext.Topology 'linked topology derives from Git registration'
    Assert-Equal 'feature/fixture-workspace' $workspaceContext.Branch 'context preserves the actual branch name'
    Assert-True ('Mode' -notin @($workspaceContext.PSObject.Properties.Name)) 'linked context has no repository mode'
    Assert-True ('GoalName' -notin @($workspaceContext.PSObject.Properties.Name)) 'linked context has no Goal name'

    $fastStatus = Invoke-Hardness -Command 'workspace.status' -Context $workspaceContext
    Assert-Equal 'Succeeded' $fastStatus.status 'fast workspace status succeeds for an arbitrary registered worktree'
    Assert-Equal 'Fast' $fastStatus.data.DetailLevel 'workspace status defaults to the fast tier'
    Assert-True ('Changes' -notin @($fastStatus.data.PSObject.Properties.Name)) 'fast status does not perform a dirty-state scan'
    $detailedStatus = Invoke-Hardness -Command 'workspace.status' -Context $workspaceContext -Parameters @{ Detailed = $true }
    Assert-Equal 'Succeeded' $detailedStatus.status 'detailed workspace status is an explicit route option'
    Assert-Equal 'Detailed' $detailedStatus.data.DetailLevel 'detailed status identifies its cost tier'
    Assert-True ('Changes' -in @($detailedStatus.data.PSObject.Properties.Name)) 'detailed status includes live dirty state'

    $workspaceList = Invoke-Hardness -Command 'workspace.list' -Context $workspaceContext
    Assert-Equal 'Succeeded' $workspaceList.status 'workspace.list enumerates the selected common Git directory'
    Assert-Equal 2 @($workspaceList.data).Count 'workspace.list returns the primary and arbitrary linked worktree'
    Assert-True ($fixtureWorkspace -in @($workspaceList.data.WorkspaceRoot)) 'workspace.list preserves the actual external worktree path'

    $hardnessStatus = Invoke-Hardness -Command 'hardness.status' -Context $workspaceContext
    Assert-Equal 'Succeeded' $hardnessStatus.status 'hardness.status provides a fast cross-client status surface'
    Assert-Equal $fixtureWorkspace $hardnessStatus.data.Workspace.WorkspaceRoot 'hardness.status stays bound to the selected workspace'
    Assert-True (-not $hardnessStatus.data.DetailedScan) 'hardness.status never opts into detailed repository scans'

    $observation = Invoke-Hardness -Command 'hardness.observe' -Context $workspaceContext -Parameters @{
        Category = 'Timing'
        Summary = 'Fixture status timing remained bounded.'
        Change = 'hardness/refactor-unified-workspace-core'
        Stage = 'apply'
        DurationMs = 42
    }
    Assert-Equal 0 @(Get-Module UnrealEngineDevelop -All).Count 'non-Unreal routes must not import the Unreal leaf'
    Assert-Equal 'Succeeded' $observation.status 'hardness.observe writes one ignored bounded record'
    Assert-Equal 1 @($observation.artifacts).Count 'observation path is exposed as an artifact'
    Assert-True (Test-Path -LiteralPath $observation.data.Path -PathType Leaf) 'observation file exists below the selected workspace'
    $observationRecord = Get-Content -LiteralPath $observation.data.Path -Raw | ConvertFrom-Json
    Assert-Equal 'hardness-observation-v1' $observationRecord.schemaVersion 'observation records use a versioned schema'
    Assert-Equal $fixtureWorkspace $observationRecord.workspaceRoot 'observation records cannot drift to the harness checkout'
    Assert-Equal 42 $observationRecord.durationMs 'observation preserves an optional timing span'
    Assert-Equal 0 @((Invoke-FixtureGit -Repository $fixtureWorkspace -Arguments @('status', '--porcelain=v1')) | Where-Object { $_ -like '*Saved/Hardness*' }).Count 'ignored observations never enter Git status'

    $evolution = Invoke-Hardness -Command 'hardness.evolution.status' -Context $workspaceContext
    Assert-Equal 'Succeeded' $evolution.status 'hardness.evolution.status summarizes ignored evidence'
    Assert-Equal 1 $evolution.data.ObservationCount 'evolution status counts observation files without replaying bodies'
    Assert-True (-not $evolution.data.RawBodiesLoaded) 'evolution status reports that raw bodies were not loaded'

    $maintenance = Invoke-Hardness -Command 'openspec.maintenance.status' -Context $context
    Assert-Equal 'Succeeded' $maintenance.status 'OpenSpec maintenance status is a read-only route'
    Assert-True ('RecordedCommit' -in @($maintenance.data.PSObject.Properties.Name)) 'maintenance status reports the parent gitlink'
    Assert-True ('PackagedSha256' -in @($maintenance.data.PSObject.Properties.Name)) 'maintenance status reports the actual package hash'
    Assert-True (-not $maintenance.data.Mutated) 'maintenance status never mutates source or package state'

    $unregisteredRoot = Join-Path $scratch 'unregistered-workspace'
    $unregisteredModuleDirectory = Join-Path $unregisteredRoot '.agents\\skills\\workspace-lifecycle\\scripts'
    [void](New-Item -ItemType Directory -Path $unregisteredModuleDirectory -Force)
    $unregisteredSentinel = Join-Path $scratch 'unregistered-leaf-imported.txt'
    $escapedSentinel = $unregisteredSentinel.Replace("'", "''")
    [System.IO.File]::WriteAllText((Join-Path $unregisteredModuleDirectory 'WorkspaceLifecycle.psm1'), "[System.IO.File]::WriteAllText('$escapedSentinel', 'imported')")
    Assert-Throws { New-HardnessContext -WorkspaceRoot $unregisteredRoot | Out-Null } 'Git|repository|registered|workspace' 'an unregistered path cannot become a Hardness context'
    Assert-True (-not (Test-Path -LiteralPath $unregisteredSentinel)) 'target workspace content is never imported as harness code'

    $created = Invoke-Hardness -Command 'workspace.new' -Context $fixturePrimaryContext -Parameters @{ Name = 'future-workspace' }
    Assert-Equal 'Succeeded' $created.status 'workspace.new creates an explicitly named workspace from the selected primary'
    Assert-Equal 'future-workspace' $created.data.Branch 'new workspace branch defaults exactly to Name'
    $createdContext = New-HardnessContext -WorkspaceRoot $created.data.WorktreeRoot
    $removePreview = Invoke-Hardness -Command 'workspace.remove' -Context $createdContext -Parameters @{ WhatIf = $true; DiscardIgnoredFiles = $true }
    Assert-Equal 'Succeeded' $removePreview.status 'workspace.remove is explicitly previewable from the exact linked context'
    Assert-True (-not $removePreview.data.Removed) 'removal preview leaves the worktree registered'

    Push-Location $fixtureProject
    try {
        $callerLocation = (Get-Location).Path
        $nativeInit = Invoke-Hardness -Command 'openspec.init' -Context $workspaceContext -ArgumentList @(
            '--project-id', 'hardness-workspace-fixture',
            '--title', 'Hardness Workspace Fixture'
        )
        Assert-Equal 'Succeeded' $nativeInit.status 'native mutation succeeds in the selected workspace'
        Assert-Equal $callerLocation (Get-Location).Path 'native mutation restores the caller location'
        Assert-True (Test-Path -LiteralPath (Join-Path $fixtureWorkspace 'openspec\\project.yaml') -PathType Leaf) 'native mutation writes inside WorkspaceRoot'
        Assert-True (-not (Test-Path -LiteralPath (Join-Path $fixtureProject 'openspec'))) 'native mutation never writes into the primary checkout'
    }
    finally {
        Pop-Location
    }

    $evolutionChangeRoot = Join-Path $fixtureWorkspace 'openspec\changes\fixture\evolution'
    $evolutionAttachmentRoot = Join-Path $evolutionChangeRoot 'attachments'
    $evolutionImplementationRoot = Join-Path $evolutionAttachmentRoot 'implementation'
    $evolutionDataRoot = Join-Path $evolutionAttachmentRoot 'data'
    [void](New-Item -ItemType Directory -Path $evolutionImplementationRoot -Force)
    [void](New-Item -ItemType Directory -Path $evolutionDataRoot -Force)
    [System.IO.File]::WriteAllText((Join-Path $evolutionChangeRoot 'change.yaml'), @'
api_version: openspec.dev/v1
kind: change
metadata:
  uid: change_fixture-evolution
  id: fixture/evolution
  title: Evolution fixture
workflow: angelscript
created_at: 2026-09-03T00:00:00Z
goal: Exercise the exact evolution closure gate.
'@, [System.Text.UTF8Encoding]::new($false))
    $evolutionIssuePath = Join-Path $evolutionImplementationRoot 'issue-20260903-160000-fixture-finding.md'
    $openEvolutionIssue = @'
---
issue_schema: openspec-material-issue-v2
issue_id: issue-20260903-160000-fixture-finding
status: open
source: dogfooding
source_ref: "run:fixture-red"
affected_tasks: ["1.1"]
created_at: 2026-09-03T16:00:00+08:00
---

# Fixture Finding

The body deliberately contains `status: resolved`; evolution status must read frontmatter only.
'@
    [System.IO.File]::WriteAllText($evolutionIssuePath, $openEvolutionIssue, [System.Text.UTF8Encoding]::new($false))
    $evolutionEvaluationPath = Join-Path $evolutionDataRoot 'workflow-evaluation.md'
    $evolutionEvaluation = @'
---
record: hardness-workflow-evaluation-v1
result: passed
change: fixture/evolution
captured_at: 2026-09-03T16:10:00+08:00
---

# Workflow Evaluation

The body deliberately contains `result: failed`; evolution status must read frontmatter only.
'@
    [System.IO.File]::WriteAllText($evolutionEvaluationPath, $evolutionEvaluation, [System.Text.UTF8Encoding]::new($false))
    [System.IO.File]::WriteAllText((Join-Path $evolutionAttachmentRoot 'INDEX.md'), @'
# INDEX

## Attachment index

- `implementation/issue-20260903-160000-fixture-finding.md` - material evolution finding.
- `data/workflow-evaluation.md` - final workflow evaluation.
'@, [System.Text.UTF8Encoding]::new($false))

    $activeEvolution = Invoke-Hardness -Command 'hardness.evolution.status' -Context $workspaceContext -Parameters @{ Change = 'fixture/evolution' }
    Assert-Equal 'Succeeded' $activeEvolution.status 'exact evolution structural status remains inspectable while a material issue is open'
    Assert-Equal 'fixture/evolution' $activeEvolution.data.ChangeId 'exact evolution status remains bound to the requested change'
    Assert-Equal 1 $activeEvolution.data.V2IssueCount 'exact evolution status counts admitted v2 issues'
    Assert-Equal 1 $activeEvolution.data.IssueCounts.Open 'exact evolution status reports the open state'
    Assert-Equal 1 @($activeEvolution.data.OpenIssuePaths).Count 'exact evolution status returns the open issue path'
    Assert-Equal 'passed' $activeEvolution.data.LatestEvaluationResult 'workflow evaluation result comes from frontmatter, not its body'
    Assert-True (-not $activeEvolution.data.ClosureReady) 'an open v2 issue is not closure-ready'
    Assert-True (-not $activeEvolution.data.RawBodiesLoaded) 'exact evolution status never loads issue or evaluation bodies'

    $blockedEvolution = Invoke-Hardness -Command 'hardness.evolution.status' -Context $workspaceContext -Parameters @{ Change = 'fixture/evolution'; RequireTerminal = $true }
    Assert-Equal 'Failed' $blockedEvolution.status 'the exact terminal gate rejects an open admitted issue'
    Assert-Match $blockedEvolution.error.message 'open material issue' 'the exact terminal gate identifies the open owner'

    $rejectedEvolutionIssue = $openEvolutionIssue.Replace('status: open', 'status: rejected').Replace("created_at: 2026-09-03T16:00:00+08:00", "created_at: 2026-09-03T16:00:00+08:00`nresolved_at: 2026-09-03T16:20:00+08:00`nresolution_ref: talk:fixture-decision")
    [System.IO.File]::WriteAllText($evolutionIssuePath, $rejectedEvolutionIssue, [System.Text.UTF8Encoding]::new($false))
    $terminalEvolution = Invoke-Hardness -Command 'hardness.evolution.status' -Context $workspaceContext -Parameters @{ Change = 'fixture/evolution'; RequireTerminal = $true }
    Assert-Equal 'Succeeded' $terminalEvolution.status 'the exact terminal gate accepts evidence-backed rejected disposition'
    Assert-Equal 1 $terminalEvolution.data.IssueCounts.Rejected 'exact evolution status reports the rejected terminal state'
    Assert-True $terminalEvolution.data.ClosureReady 'terminal issue disposition plus a valid evaluation is closure-ready'

    $successorChangeRoot = Join-Path $fixtureWorkspace 'openspec\changes\fixture\evolution-successor'
    $successorImplementationRoot = Join-Path $successorChangeRoot 'attachments\implementation'
    [void](New-Item -ItemType Directory -Path $successorImplementationRoot -Force)
    [System.IO.File]::WriteAllText((Join-Path $successorChangeRoot 'change.yaml'), @'
api_version: openspec.dev/v1
kind: change
metadata:
  uid: change_fixture-evolution-successor
  id: fixture/evolution-successor
  title: Evolution successor fixture
workflow: angelscript
created_at: 2026-09-03T00:00:00Z
goal: Own the superseded fixture concern.
'@, [System.Text.UTF8Encoding]::new($false))
    $successorIssueName = 'issue-20260903-163000-successor-owner.md'
    [System.IO.File]::WriteAllText((Join-Path $successorImplementationRoot $successorIssueName), @'
---
issue_schema: openspec-material-issue-v2
issue_id: issue-20260903-163000-successor-owner
status: open
source: dogfooding
source_ref: "issue:fixture/evolution#issue-20260903-160000-fixture-finding"
affected_tasks: ["1.1"]
created_at: 2026-09-03T16:30:00+08:00
---

# Successor Owner
'@, [System.Text.UTF8Encoding]::new($false))
    [System.IO.File]::WriteAllText((Join-Path $successorChangeRoot 'attachments\INDEX.md'), "# INDEX`n`n- ``implementation/$successorIssueName`` - successor owner.`n", [System.Text.UTF8Encoding]::new($false))
    $supersededEvolutionIssue = @'
---
issue_schema: openspec-material-issue-v2
issue_id: issue-20260903-160000-fixture-finding
status: superseded
source: dogfooding
source_ref: "run:fixture-red"
affected_tasks: ["1.1"]
created_at: 2026-09-03T16:00:00+08:00
resolved_at: 2026-09-03T16:35:00+08:00
superseded_by: fixture/evolution-successor#issue-20260903-163000-successor-owner
---

# Fixture Finding
'@
    [System.IO.File]::WriteAllText($evolutionIssuePath, $supersededEvolutionIssue, [System.Text.UTF8Encoding]::new($false))
    $supersededEvolution = Invoke-Hardness -Command 'hardness.evolution.status' -Context $workspaceContext -Parameters @{ Change = 'fixture/evolution'; RequireTerminal = $true }
    Assert-Equal 'Succeeded' $supersededEvolution.status 'the terminal gate accepts an exact existing v2 successor owner'
    Assert-Equal 1 $supersededEvolution.data.IssueCounts.Superseded 'exact evolution status reports the superseded terminal state'

    $selfSupersededIssue = $supersededEvolutionIssue.Replace('fixture/evolution-successor#issue-20260903-163000-successor-owner', 'fixture/evolution#issue-20260903-160000-fixture-finding')
    [System.IO.File]::WriteAllText($evolutionIssuePath, $selfSupersededIssue, [System.Text.UTF8Encoding]::new($false))
    $selfSupersededEvolution = Invoke-Hardness -Command 'hardness.evolution.status' -Context $workspaceContext -Parameters @{ Change = 'fixture/evolution'; RequireTerminal = $true }
    Assert-Equal 'Failed' $selfSupersededEvolution.status 'the terminal gate rejects a self-superseded material issue'
    Assert-Match $selfSupersededEvolution.error.message 'cannot reference itself' 'self-supersession has an exact diagnostic'
    [System.IO.File]::WriteAllText($evolutionIssuePath, $rejectedEvolutionIssue, [System.Text.UTF8Encoding]::new($false))

    $invalidCapturedEvaluation = $evolutionEvaluation.Replace('captured_at: 2026-09-03T16:10:00+08:00', 'captured_at: not-a-timestamp')
    [System.IO.File]::WriteAllText($evolutionEvaluationPath, $invalidCapturedEvaluation, [System.Text.UTF8Encoding]::new($false))
    $invalidEvolution = Invoke-Hardness -Command 'hardness.evolution.status' -Context $workspaceContext -Parameters @{ Change = 'fixture/evolution' }
    Assert-Equal 'Succeeded' $invalidEvolution.status 'structural status reports invalid evaluation metadata without hiding the finding summary'
    Assert-True (@($invalidEvolution.data.StructuralErrors | Where-Object { $_ -match 'captured_at' }).Count -eq 1) 'invalid evaluation captured_at is reported exactly'
    $invalidTerminalEvolution = Invoke-Hardness -Command 'hardness.evolution.status' -Context $workspaceContext -Parameters @{ Change = 'fixture/evolution'; RequireTerminal = $true }
    Assert-Equal 'Failed' $invalidTerminalEvolution.status 'the exact terminal gate rejects invalid workflow evaluation metadata'

    $unscopedTerminalEvolution = Invoke-Hardness -Command 'hardness.evolution.status' -Context $workspaceContext -Parameters @{ RequireTerminal = $true }
    Assert-Equal 'Failed' $unscopedTerminalEvolution.status 'RequireTerminal cannot scan every change implicitly'
    Assert-Match $unscopedTerminalEvolution.error.message 'exact Change' 'RequireTerminal requests an exact change identity'

    [void](Invoke-FixtureGit -Repository $fixtureProject -Arguments @('worktree', 'remove', '--force', $created.data.WorktreeRoot))
    [void](Invoke-FixtureGit -Repository $fixtureProject -Arguments @('worktree', 'remove', '--force', $fixtureWorkspace))

    $incompleteHealth = Test-HardnessInstallation -ProjectRoot $fixtureProject
    Assert-True (-not $incompleteHealth.IsValid) 'installation fails when the required OpenSpec leaf is missing'
    Assert-Equal 1 @($incompleteHealth.Errors | Where-Object { $_ -match 'OpenSpec' }).Count 'the required OpenSpec package is reported as an error'

    $validFixture = New-InstallationFixture -Root (Join-Path $scratch 'health-valid') -SourceRoot $repoRoot
    $validFixtureHealth = Test-HardnessInstallation -ProjectRoot $validFixture
    Assert-True $validFixtureHealth.IsValid 'a complete fixed OpenSpec 0.8.1 package passes installation health'
    Assert-Equal '0.8.1' $validFixtureHealth.OpenSpecPackage.Version 'health reports the verified final OpenSpec identity'
    Assert-True $validFixtureHealth.OpenSpecPackage.Verified 'health distinguishes a verified package from mere file presence'
    Assert-Equal 0 @(Get-Module UnrealEngineDevelop -All).Count 'installation validation checks the Unreal manifest without importing it'

    $missingUnrealFixture = New-InstallationFixture -Root (Join-Path $scratch 'health-missing-unreal') -SourceRoot $repoRoot
    Remove-Item -LiteralPath (Join-Path $missingUnrealFixture '.agents\skills\unreal-engine-develop\scripts\UnrealEngineDevelop.psd1') -Force
    $missingUnrealHealth = Test-HardnessInstallation -ProjectRoot $missingUnrealFixture
    Assert-True (-not $missingUnrealHealth.IsValid) 'installation fails when the required Unreal leaf manifest is missing'
    Assert-Match (@($missingUnrealHealth.Errors) -join ' ') 'Unreal.*manifest|manifest.*Unreal' 'the missing Unreal manifest has a bounded diagnostic'
    Assert-Equal 0 @(Get-Module UnrealEngineDevelop -All).Count 'a missing Unreal manifest check does not import another Unreal module'

    $corruptFixture = New-InstallationFixture -Root (Join-Path $scratch 'health-corrupt-exe') -SourceRoot $repoRoot
    [System.IO.File]::WriteAllBytes((Join-Path $corruptFixture '.agents\skills\openspec\bin\openspec.exe'), [byte[]](1, 2, 3, 4))
    $corruptHealth = Test-HardnessInstallation -ProjectRoot $corruptFixture
    Assert-True (-not $corruptHealth.IsValid) 'corrupt executable bytes never pass installation health'
    Assert-Match (@($corruptHealth.Errors) -join ' ') 'hash|identity|size' 'corrupt executable bytes fail a static identity check before execution'

    $wrongHashFixture = New-InstallationFixture -Root (Join-Path $scratch 'health-wrong-hash') -SourceRoot $repoRoot
    Set-FixtureManifestValue -Root $wrongHashFixture -Name 'sha256' -Value ('f' * 64)
    $wrongHashHealth = Test-HardnessInstallation -ProjectRoot $wrongHashFixture
    Assert-True (-not $wrongHashHealth.IsValid) 'a manifest with the wrong executable hash is rejected'
    Assert-Match (@($wrongHashHealth.Errors) -join ' ') 'hash|identity' 'wrong manifest hash has a bounded package diagnostic'

    $wrongVersionFixture = New-InstallationFixture -Root (Join-Path $scratch 'health-wrong-version') -SourceRoot $repoRoot
    Set-FixtureManifestValue -Root $wrongVersionFixture -Name 'version' -Value '0.8.0'
    $wrongVersionHealth = Test-HardnessInstallation -ProjectRoot $wrongVersionFixture
    Assert-True (-not $wrongVersionHealth.IsValid) 'a non-final manifest version is rejected'
    Assert-Match (@($wrongVersionHealth.Errors) -join ' ') 'version|identity' 'wrong manifest version has a bounded package diagnostic'

    $missingManifestFixture = New-InstallationFixture -Root (Join-Path $scratch 'health-missing-manifest') -SourceRoot $repoRoot
    Remove-Item -LiteralPath (Join-Path $missingManifestFixture '.agents\skills\openspec\release-manifest.json') -Force
    $missingManifestHealth = Test-HardnessInstallation -ProjectRoot $missingManifestFixture
    Assert-True (-not $missingManifestHealth.IsValid) 'a package without a release manifest is rejected'
    Assert-Match (@($missingManifestHealth.Errors) -join ' ') 'manifest.*missing|missing.*manifest' 'missing manifest is reported explicitly'

    $schemaFixture = New-InstallationFixture -Root (Join-Path $scratch 'health-invalid-manifest-schema') -SourceRoot $repoRoot
    $schemaManifestPath = Join-Path $schemaFixture '.agents\skills\openspec\release-manifest.json'
    $schemaManifest = Get-Content -LiteralPath $schemaManifestPath -Raw | ConvertFrom-Json
    $schemaManifest.PSObject.Properties.Remove('sourceTagType')
    [System.IO.File]::WriteAllText($schemaManifestPath, ($schemaManifest | ConvertTo-Json -Depth 20 -Compress), [System.Text.UTF8Encoding]::new($false))
    $schemaHealth = Test-HardnessInstallation -ProjectRoot $schemaFixture
    Assert-True (-not $schemaHealth.IsValid) 'an incomplete release-manifest schema is rejected'
    Assert-Match (@($schemaHealth.Errors) -join ' ') 'schema|sourceTagType' 'manifest schema mismatch identifies the missing field'

    $missingDocsFixture = New-InstallationFixture -Root (Join-Path $scratch 'health-missing-docs') -SourceRoot $repoRoot
    Remove-Item -LiteralPath (Join-Path $missingDocsFixture '.agents\skills\openspec\commands') -Recurse -Force
    $missingDocsHealth = Test-HardnessInstallation -ProjectRoot $missingDocsFixture
    Assert-True (-not $missingDocsHealth.IsValid) 'a package without command docs is rejected'
    Assert-Match (@($missingDocsHealth.Errors) -join ' ') 'command doc|commands|missing' 'missing command docs are reported explicitly'

    $mismatchedDocsFixture = New-InstallationFixture -Root (Join-Path $scratch 'health-mismatched-docs') -SourceRoot $repoRoot
    [System.IO.File]::AppendAllText((Join-Path $mismatchedDocsFixture '.agents\skills\openspec\commands\status.md'), "`nfixture mismatch`n")
    $mismatchedDocsHealth = Test-HardnessInstallation -ProjectRoot $mismatchedDocsFixture
    Assert-True (-not $mismatchedDocsHealth.IsValid) 'command docs that do not match the final digest are rejected'
    Assert-Match (@($mismatchedDocsHealth.Errors) -join ' ') 'digest|identity' 'command-doc mismatch has a bounded package diagnostic'

    $manifestDocsFixture = New-InstallationFixture -Root (Join-Path $scratch 'health-manifest-docs') -SourceRoot $repoRoot
    Set-FixtureManifestValue -Root $manifestDocsFixture -Name 'commandDocsDigest' -Value ('e' * 64)
    $manifestDocsHealth = Test-HardnessInstallation -ProjectRoot $manifestDocsFixture
    Assert-True (-not $manifestDocsHealth.IsValid) 'a manifest with the wrong command-doc digest is rejected'
    Assert-Match (@($manifestDocsHealth.Errors) -join ' ') 'digest|identity' 'wrong manifest command-doc digest is reported'

    $health = Test-HardnessInstallation -ProjectRoot $repoRoot
    Assert-True $health.IsValid 'installation self-check succeeds'
    Assert-Equal 0 @($health.Errors).Count 'installation self-check reports no errors'
    Assert-Equal 0 @($health.Warnings).Count 'the installed harness has no missing required leaf warnings'
}
finally {
    Remove-Module Hardness -Force -ErrorAction SilentlyContinue
    if (Test-Path -LiteralPath $scratch) {
        Remove-Item -LiteralPath $scratch -Recurse -Force
    }
}

Write-Output 'Hardness.Tests.ps1: PASS'
