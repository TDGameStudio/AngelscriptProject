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
    $openspecTarget = Join-Path $Root '.agents\skills\openspec'
    [void](New-Item -ItemType Directory -Path $workspaceTarget -Force)
    [void](New-Item -ItemType Directory -Path $gitTarget -Force)
    [void](New-Item -ItemType Directory -Path (Join-Path $openspecTarget 'bin') -Force)
    Copy-Item -LiteralPath (Join-Path $SourceRoot '.agents\skills\workspace-lifecycle\scripts\WorkspaceLifecycle.psm1') -Destination $workspaceTarget
    Copy-Item -LiteralPath (Join-Path $SourceRoot '.agents\skills\workspace-lifecycle\scripts\WorkspaceLifecycle.psd1') -Destination $workspaceTarget
    Copy-Item -LiteralPath (Join-Path $SourceRoot '.agents\skills\git-operations\scripts\GitOperations.psm1') -Destination $gitTarget
    Copy-Item -LiteralPath (Join-Path $SourceRoot '.agents\skills\git-operations\scripts\GitOperations.psd1') -Destination $gitTarget
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
    $context = New-HardnessContext -Mode Current -ProjectRoot $repoRoot
    Assert-Equal 'Current' $context.Mode 'current mode is explicit'
    Assert-Equal $repoRoot $context.ProjectRoot 'context uses the requested project root'

    $routes = @(Get-HardnessCommand)
    foreach ($name in @(
        'workspace.status', 'workspace.new', 'workspace.bootstrap', 'workspace.verify', 'workspace.remove', 'workspace.activate',
        'workspace.config.status', 'workspace.config.get', 'workspace.config.set',
        'git.status', 'git.commit', 'git.integrate', 'git.push',
        'task.status',
        'openspec.validate', 'openspec.change'
    )) {
        Assert-True ($name -in @($routes.Name)) "route '$name' must be registered"
    }
    Assert-Equal 0 @($routes | Where-Object { $_.Name -match '^(ue\.|staticjit\.|cache\.|coverage$|standalone\.|engine\.|execution\.|toolchain\.)' }).Count 'deferred Unreal leaf routes are not published by the Hardness core snapshot'

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
    $taskCurrentRoot = Join-Path $scratch 'task-current'
    $taskCurrentExeDirectory = Join-Path $taskCurrentRoot '.agents\skills\openspec\bin'
    [void](New-Item -ItemType Directory -Path $taskCurrentExeDirectory -Force)
    Copy-Item -LiteralPath $sourceOpenSpec -Destination (Join-Path $taskCurrentExeDirectory 'openspec.exe')
    $taskCurrentContext = New-HardnessContext -Mode Current -ProjectRoot $taskCurrentRoot

    $taskCurrentInit = Invoke-Hardness -Command 'openspec.init' -Context $taskCurrentContext -ArgumentList @(
        '--project-id', 'hardness-task-current',
        '--title', 'Hardness Task Current Fixture'
    )
    Assert-Equal 'Succeeded' $taskCurrentInit.status 'Current Task Graph fixture initializes through the selected workspace'
    $taskCurrentDomain = Invoke-Hardness -Command 'openspec.domain' -Context $taskCurrentContext -ArgumentList @(
        'create', 'fixture', '--title', 'Fixture', '--description', 'Fixture', '--json'
    )
    Assert-Equal 'Succeeded' $taskCurrentDomain.status 'Current Task Graph fixture domain is created'
    $taskCurrentChange = Invoke-Hardness -Command 'openspec.change' -Context $taskCurrentContext -ArgumentList @(
        'create', 'fixture/dag', '--title', 'Task DAG', '--goal', 'Verify Hardness task recognition', '--json'
    )
    Assert-Equal 'Succeeded' $taskCurrentChange.status 'Current Task Graph fixture change is created'

    $taskSeparator = [string][char]0x2014
    $taskCurrentPath = Join-Path $taskCurrentRoot 'openspec\changes\fixture\dag\tasks.md'
    $taskCurrentDocument = @'
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
    $taskCurrentDocument = $taskCurrentDocument.Replace('__TASK_SEPARATOR__', $taskSeparator)
    [System.IO.File]::WriteAllText($taskCurrentPath, $taskCurrentDocument, [System.Text.UTF8Encoding]::new($false))

    $taskStatus = Invoke-Hardness -Command 'task.status' -Context $taskCurrentContext -Parameters @{ Change = 'fixture/dag' }
    Assert-Equal 'Succeeded' $taskStatus.status 'task.status recognizes a Current workspace Task Graph'
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
    [System.IO.File]::WriteAllText($taskCurrentPath, $taskCycleDocument, [System.Text.UTF8Encoding]::new($false))
    $cycleStatus = Invoke-Hardness -Command 'task.status' -Context $taskCurrentContext -Parameters @{ Change = 'fixture/dag' }
    Assert-Equal 'Succeeded' $cycleStatus.status 'task.status preserves a successfully inspected invalid Task Graph in its envelope'
    Assert-Equal 'waiting' $cycleStatus.data.state 'an invalid Task Graph remains waiting instead of becoming schedulable'
    Assert-True ('cycle' -in @($cycleStatus.data.taskIssues.code)) 'task.status preserves OpenSpec cycle diagnostics'
    Assert-Equal 0 @($cycleStatus.data.tasks | Where-Object ready).Count 'task.status never produces Ready work from a cycle'

    $missingTaskStatus = Invoke-Hardness -Command 'task.status' -Context $taskCurrentContext -Parameters @{ Change = 'fixture/missing' }
    Assert-Equal 'Failed' $missingTaskStatus.status 'task.status reports a missing change through the common failed envelope'
    Assert-True ($missingTaskStatus.exitCode -ne 0) 'task.status preserves the missing-change native exit code'
    Assert-True (-not [string]::IsNullOrWhiteSpace([string]$missingTaskStatus.error.message)) 'task.status preserves the missing-change diagnostic'

    $fixtureProject = Join-Path $scratch 'fixture-project'
    [void](New-Item -ItemType Directory -Path $fixtureProject)
    [void](Invoke-FixtureGit -Repository $fixtureProject -Arguments @('init', '-b', 'main'))
    $fixtureModuleDirectory = Join-Path $fixtureProject '.agents\skills\workspace-lifecycle\scripts'
    $fixtureGitModuleDirectory = Join-Path $fixtureProject '.agents\skills\git-operations\scripts'
    [void](New-Item -ItemType Directory -Path $fixtureModuleDirectory -Force)
    [void](New-Item -ItemType Directory -Path $fixtureGitModuleDirectory -Force)
    Copy-Item -LiteralPath (Join-Path $repoRoot '.agents\skills\workspace-lifecycle\scripts\WorkspaceLifecycle.psm1') -Destination $fixtureModuleDirectory
    Copy-Item -LiteralPath (Join-Path $repoRoot '.agents\skills\workspace-lifecycle\scripts\WorkspaceLifecycle.psd1') -Destination $fixtureModuleDirectory
    Copy-Item -LiteralPath (Join-Path $repoRoot '.agents\skills\git-operations\scripts\GitOperations.psm1') -Destination $fixtureGitModuleDirectory
    Copy-Item -LiteralPath (Join-Path $repoRoot '.agents\skills\git-operations\scripts\GitOperations.psd1') -Destination $fixtureGitModuleDirectory
    [System.IO.File]::WriteAllText((Join-Path $fixtureProject '.gitignore'), ".worktrees/`nAgentConfig.ini`n")
    [System.IO.File]::WriteAllText((Join-Path $fixtureProject 'Fixture.uproject'), "{}`n")
    [System.IO.File]::WriteAllText((Join-Path $fixtureProject 'fixture.txt'), "fixture`n")
    [void](Invoke-FixtureGit -Repository $fixtureProject -Arguments @('add', '--', '.'))
    [void](Invoke-FixtureGit -Repository $fixtureProject -Arguments @('-c', 'user.name=Hardness Tests', '-c', 'user.email=hardness-tests@example.invalid', 'commit', '-m', 'fixture'))

    $fixtureWorkspace = Join-Path $fixtureProject '.worktrees\fixture-goal'
    [void](Invoke-FixtureGit -Repository $fixtureProject -Arguments @('worktree', 'add', '-b', 'goal/fixture-goal', $fixtureWorkspace, 'HEAD'))

    Assert-Throws { New-HardnessContext -Mode Goal -ProjectRoot $fixtureProject -GoalName '..\escape' } 'GoalName|safe|invalid|traversal' 'GoalName traversal is rejected before route selection'
    Assert-Throws { New-HardnessContext -Mode Goal -ProjectRoot $fixtureProject -GoalName 'nested/escape' } 'GoalName|safe|invalid|traversal' 'GoalName path separators are rejected'
    Assert-Throws { New-HardnessContext -Mode Goal -ProjectRoot $fixtureProject -GoalName 'fixture-goal' -WorkspaceRoot (Join-Path $scratch 'outside-goal') } 'canonical|workspace|outside|match' 'an arbitrary explicit Goal workspace root is rejected'

    $linkedOriginContext = New-HardnessContext -Mode Goal -ProjectRoot $fixtureWorkspace -GoalName 'fixture-goal'
    Assert-Equal $fixtureWorkspace $linkedOriginContext.WorkspaceRoot 'a linked origin resolves Goal workspaces from the canonical primary .worktrees container'
    Assert-Equal $fixtureProject $linkedOriginContext.PrimaryRoot 'a linked origin records the canonical primary checkout'

    $createContext = New-HardnessContext -Mode Goal -ProjectRoot $fixtureWorkspace -GoalName 'future-goal'
    $expectedCreateRoot = Join-Path $fixtureProject '.worktrees\future-goal'
    Assert-Equal $expectedCreateRoot $createContext.WorkspaceRoot 'a create candidate is derived below the primary .worktrees container'
    $candidateRoute = Invoke-Hardness -Command 'workspace.status' -Context $createContext
    Assert-Equal 'Failed' $candidateRoute.status 'a non-create Goal route rejects a not-yet-created candidate'
    Assert-Match $candidateRoute.error.message 'registered worktree|registered Goal workspace' 'candidate rejection occurs at the Goal authority boundary'
    $createResult = Invoke-Hardness -Command 'workspace.new' -Context $createContext
    Assert-Equal 'Succeeded' $createResult.status 'workspace.new alone may use and create a canonical candidate'
    Assert-True $createResult.data.Created 'workspace.new creates the requested registered Goal workspace'
    Assert-Equal $expectedCreateRoot $createResult.data.WorktreeRoot 'workspace.new returns the same canonical root selected by the context'
    $createdRoute = Invoke-Hardness -Command 'workspace.status' -Context $createContext
    Assert-Equal 'Succeeded' $createdRoute.status 'the same Goal context routes successfully after workspace.new registers its candidate'
    Assert-Equal $expectedCreateRoot $createdRoute.data.ProjectRoot 'create and subsequent route resolution agree exactly'

    [void](Invoke-FixtureGit -Repository $fixtureProject -Arguments @('worktree', 'remove', '--force', $expectedCreateRoot))
    [void](New-Item -ItemType Directory -Path $expectedCreateRoot)
    $orphanWithoutIntent = Invoke-Hardness -Command 'workspace.remove' -Context $createContext
    Assert-Equal 'Failed' $orphanWithoutIntent.status 'an empty unregistered Goal root still requires explicit recovery intent'
    Assert-True (Test-Path -LiteralPath $expectedCreateRoot -PathType Container) 'a rejected orphan recovery preserves the empty root'
    $overrideTarget = Join-Path $fixtureProject '.worktrees\override-target'
    [void](New-Item -ItemType Directory -Path $overrideTarget)
    $orphanOverride = Invoke-Hardness -Command 'workspace.remove' -Context $createContext -Parameters @{ DiscardIgnoredFiles = $true; WorktreeRoot = $overrideTarget }
    Assert-Equal 'Failed' $orphanOverride.status 'Goal recovery parameters cannot redirect removal away from the authorized context target'
    Assert-True (Test-Path -LiteralPath $expectedCreateRoot -PathType Container) 'a rejected target override preserves the authorized orphan root'
    Assert-True (Test-Path -LiteralPath $overrideTarget -PathType Container) 'a rejected target override preserves the alternate directory'
    $orphanPreview = Invoke-Hardness -Command 'workspace.remove' -Context $createContext -Parameters @{ DiscardIgnoredFiles = $true; WhatIf = $true }
    Assert-Equal 'Succeeded' $orphanPreview.status 'explicit WhatIf previews empty unregistered Goal recovery through Hardness'
    Assert-True (-not $orphanPreview.data.Removed) 'orphan recovery WhatIf does not remove the empty root'
    Assert-True (Test-Path -LiteralPath $expectedCreateRoot -PathType Container) 'orphan recovery WhatIf preserves the empty root'
    $orphanRecovery = Invoke-Hardness -Command 'workspace.remove' -Context $createContext -Parameters @{ DiscardIgnoredFiles = $true }
    Assert-Equal 'Succeeded' $orphanRecovery.status 'explicit recovery removes an empty unregistered Goal root through Hardness'
    Assert-True $orphanRecovery.data.Removed 'Hardness reports successful empty-root recovery'
    Assert-True (-not (Test-Path -LiteralPath $expectedCreateRoot)) 'empty unregistered Goal recovery removes the residual directory'
    $preservedFutureBranch = @((Invoke-FixtureGit -Repository $fixtureProject -Arguments @('branch', '--list', 'goal/future-goal')))
    Assert-True (($preservedFutureBranch -join "`n") -match 'goal/future-goal') 'empty-root recovery preserves the Goal branch'

    $unregisteredRoot = Join-Path $fixtureProject '.worktrees\unregistered-goal'
    $unregisteredModuleDirectory = Join-Path $unregisteredRoot '.agents\skills\workspace-lifecycle\scripts'
    [void](New-Item -ItemType Directory -Path $unregisteredModuleDirectory -Force)
    $unregisteredSentinel = Join-Path $scratch 'unregistered-leaf-imported.txt'
    $escapedSentinel = $unregisteredSentinel.Replace("'", "''")
    $maliciousModule = @"
[System.IO.File]::WriteAllText('$escapedSentinel', 'imported')
function Get-HardnessWorkspaceStatus { [pscustomobject]@{ Imported = `$true } }
Export-ModuleMember -Function 'Get-HardnessWorkspaceStatus'
"@
    [System.IO.File]::WriteAllText((Join-Path $unregisteredModuleDirectory 'WorkspaceLifecycle.psm1'), $maliciousModule)
    $maliciousManifest = @"
@{
    RootModule = 'WorkspaceLifecycle.psm1'
    ModuleVersion = '1.0.0'
    GUID = '$([guid]::NewGuid())'
    FunctionsToExport = @('Get-HardnessWorkspaceStatus')
    CmdletsToExport = @()
    VariablesToExport = @()
    AliasesToExport = @()
}
"@
    [System.IO.File]::WriteAllText((Join-Path $unregisteredModuleDirectory 'WorkspaceLifecycle.psd1'), $maliciousManifest)
    $unregisteredOpenSpecDirectory = Join-Path $unregisteredRoot '.agents\skills\openspec\bin'
    [void](New-Item -ItemType Directory -Path $unregisteredOpenSpecDirectory -Force)
    [System.IO.File]::WriteAllBytes((Join-Path $unregisteredOpenSpecDirectory 'openspec.exe'), [byte[]](1, 2, 3, 4))

    $unregisteredContext = New-HardnessContext -Mode Goal -ProjectRoot $fixtureProject -GoalName 'unregistered-goal'
    $unregisteredPowerShell = Invoke-Hardness -Command 'workspace.status' -Context $unregisteredContext
    Assert-Equal 'Failed' $unregisteredPowerShell.status 'an unregistered Goal workspace cannot run a PowerShell leaf'
    Assert-Match $unregisteredPowerShell.error.message 'registered worktree|registered Goal workspace' 'PowerShell leaf rejection reports missing registration'
    Assert-True (-not (Test-Path -LiteralPath $unregisteredSentinel)) 'an unregistered Goal workspace is rejected before importing its leaf module'
    $unregisteredNative = Invoke-Hardness -Command 'openspec.status' -Context $unregisteredContext -ArgumentList @('--json')
    Assert-Equal 'Failed' $unregisteredNative.status 'an unregistered Goal workspace cannot run a native leaf'
    Assert-Match $unregisteredNative.error.message 'registered worktree|registered Goal workspace' 'native leaf rejection reports missing registration rather than executing the file'
    $unregisteredRemoval = Invoke-Hardness -Command 'workspace.remove' -Context $unregisteredContext -Parameters @{ DiscardIgnoredFiles = $true }
    Assert-Equal 'Failed' $unregisteredRemoval.status 'explicit recovery never authorizes a nonempty unregistered Goal root'
    Assert-True (-not (Test-Path -LiteralPath $unregisteredSentinel)) 'a rejected nonempty recovery never imports an unregistered leaf module'

    $goalContext = New-HardnessContext -Mode Goal -ProjectRoot $fixtureProject -GoalName 'fixture-goal' -WorkspaceRoot $fixtureWorkspace
    $goalResult = Invoke-Hardness -Command 'workspace.status' -Context $goalContext
    Assert-Equal 'Succeeded' $goalResult.status 'goal route can load its leaf from the isolated workspace'
    Assert-Equal $fixtureWorkspace $goalResult.data.ProjectRoot 'goal routes operate on WorkspaceRoot, not the primary checkout'

    $fixtureOpenSpecDirectory = Join-Path $fixtureWorkspace '.agents\skills\openspec\bin'
    [void](New-Item -ItemType Directory -Path $fixtureOpenSpecDirectory -Force)
    Copy-Item -LiteralPath $sourceOpenSpec -Destination (Join-Path $fixtureOpenSpecDirectory 'openspec.exe')
    Push-Location $fixtureProject
    try {
        $callerLocation = (Get-Location).Path
        $nativeInit = Invoke-Hardness -Command 'openspec.init' -Context $goalContext -ArgumentList @(
            '--project-id', 'hardness-goal-fixture',
            '--title', 'Hardness Goal Fixture'
        )
        Assert-Equal 'Succeeded' $nativeInit.status 'Goal native mutation succeeds in the selected workspace'
        Assert-Equal $callerLocation (Get-Location).Path 'Goal native mutation restores the caller location'
        Assert-True (Test-Path -LiteralPath (Join-Path $fixtureWorkspace 'openspec\project.yaml') -PathType Leaf) 'Goal native mutation writes inside WorkspaceRoot'
        Assert-True (-not (Test-Path -LiteralPath (Join-Path $fixtureProject 'openspec'))) 'Goal native mutation never writes into the primary checkout'

        $nativeCreate = Invoke-Hardness -Command 'openspec.domain' -Context $goalContext -ArgumentList @(
            'create', 'goal/fixture', '--title', 'Goal Fixture', '--json'
        )
        Assert-Equal 'Succeeded' $nativeCreate.status 'Goal native domain creation succeeds in the selected workspace'
        $nativeRead = Invoke-Hardness -Command 'openspec.domain' -Context $goalContext -ArgumentList @('list', '--json')
        Assert-Equal 'Succeeded' $nativeRead.status 'Goal native read succeeds in the selected workspace'
        Assert-True ((@($nativeRead.data.Output) -join "`n") -match 'goal/fixture') 'Goal native read observes the selected workspace data'
        Assert-Equal $callerLocation (Get-Location).Path 'Goal native read restores the caller location'

        $goalTaskChange = Invoke-Hardness -Command 'openspec.change' -Context $goalContext -ArgumentList @(
            'create', 'goal/fixture/task-route', '--title', 'Goal Task Route', '--goal', 'Verify Goal Task Graph routing', '--json'
        )
        Assert-Equal 'Succeeded' $goalTaskChange.status 'Goal Task Graph fixture change is created inside WorkspaceRoot'
        $goalTaskPath = Join-Path $fixtureWorkspace 'openspec\changes\goal\fixture\task-route\tasks.md'
        $goalTaskDocument = @'
---
task_graph:
  version: 1
  depends_on:
    "1.1": []
---

## Tasks

- [ ] 1.1 Goal workspace task __TASK_SEPARATOR__ verify: `goal`
  > Files: `goal`
'@
        $goalTaskDocument = $goalTaskDocument.Replace('__TASK_SEPARATOR__', $taskSeparator)
        [System.IO.File]::WriteAllText($goalTaskPath, $goalTaskDocument, [System.Text.UTF8Encoding]::new($false))
        $goalTaskStatus = Invoke-Hardness -Command 'task.status' -Context $goalContext -Parameters @{ Change = 'goal/fixture/task-route' }
        Assert-Equal 'Succeeded' $goalTaskStatus.status 'task.status recognizes the Goal workspace Task Graph'
        Assert-Equal 'goal/fixture/task-route' $goalTaskStatus.data.changeId 'Goal task.status reads the selected WorkspaceRoot change'
        Assert-True (($goalTaskStatus.data.tasks | Where-Object id -eq '1.1').ready) 'Goal task.status returns Ready work from WorkspaceRoot'
        Assert-Equal $callerLocation (Get-Location).Path 'Goal task.status restores the caller location'
    }
    finally {
        Pop-Location
    }

    [void](Invoke-FixtureGit -Repository $fixtureProject -Arguments @('worktree', 'remove', '--force', $fixtureWorkspace))
    [void](New-Item -ItemType Directory -Path $fixtureWorkspace)
    $staleOriginRecovery = Invoke-Hardness -Command 'workspace.remove' -Context $linkedOriginContext -Parameters @{ DiscardIgnoredFiles = $true }
    Assert-Equal 'Succeeded' $staleOriginRecovery.status 'empty-root recovery uses PrimaryRoot after the context origin worktree disappears'
    Assert-True $staleOriginRecovery.data.Removed 'stale-origin recovery removes the empty residual directory'
    Assert-True (-not (Test-Path -LiteralPath $fixtureWorkspace)) 'stale-origin recovery leaves no directory behind'
    $preservedFixtureBranch = @((Invoke-FixtureGit -Repository $fixtureProject -Arguments @('branch', '--list', 'goal/fixture-goal')))
    Assert-True (($preservedFixtureBranch -join "`n") -match 'goal/fixture-goal') 'stale-origin recovery preserves the original Goal branch'

    $incompleteHealth = Test-HardnessInstallation -ProjectRoot $fixtureProject
    Assert-True (-not $incompleteHealth.IsValid) 'installation fails when the required OpenSpec leaf is missing'
    Assert-Equal 1 @($incompleteHealth.Errors | Where-Object { $_ -match 'missing|required.*OpenSpec|manifest|package' }).Count 'the required OpenSpec package is reported as an error'

    $validFixture = New-InstallationFixture -Root (Join-Path $scratch 'health-valid') -SourceRoot $repoRoot
    $validFixtureHealth = Test-HardnessInstallation -ProjectRoot $validFixture
    Assert-True $validFixtureHealth.IsValid 'a complete fixed OpenSpec 0.8.1 package passes installation health'
    Assert-Equal '0.8.1' $validFixtureHealth.OpenSpecPackage.Version 'health reports the verified final OpenSpec identity'
    Assert-True $validFixtureHealth.OpenSpecPackage.Verified 'health distinguishes a verified package from mere file presence'

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
