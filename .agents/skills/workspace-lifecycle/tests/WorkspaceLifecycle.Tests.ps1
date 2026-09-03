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

function Assert-ThrowsMatch {
    param([scriptblock]$Action, [string]$Pattern, [string]$Message)
    $caught = $null
    try { & $Action } catch { $caught = $_ }
    if ($null -eq $caught -or $caught.Exception.Message -notmatch $Pattern) {
        $actual = if ($null -eq $caught) { '<no exception>' } else { $caught.Exception.Message }
        throw "Assertion failed: $Message (actual '$actual')"
    }
}

function Invoke-TestGit {
    param([Parameter(Mandatory = $true)][string]$Repository, [Parameter(Mandatory = $true)][string[]]$Arguments)
    $oldAllow = $env:GIT_ALLOW_PROTOCOL
    $oldPreference = $ErrorActionPreference
    $env:GIT_ALLOW_PROTOCOL = 'file'
    $ErrorActionPreference = 'Continue'
    try { $output = @(& git -C $Repository @Arguments 2>&1); $exitCode = $LASTEXITCODE }
    finally { $env:GIT_ALLOW_PROTOCOL = $oldAllow; $ErrorActionPreference = $oldPreference }
    if ($exitCode -ne 0) { throw "git -C '$Repository' $($Arguments -join ' ') failed ($exitCode): $($output -join [Environment]::NewLine)" }
    return @($output | ForEach-Object { [string]$_ })
}

function Initialize-TestRepository {
    param([Parameter(Mandatory = $true)][string]$Path)
    [void](New-Item -ItemType Directory -Path $Path -Force)
    & git -C $Path init --initial-branch=main 2>&1 | Out-Null
    if ($LASTEXITCODE -ne 0) { & git -C $Path init 2>&1 | Out-Null; Invoke-TestGit -Repository $Path -Arguments @('checkout', '-b', 'main') | Out-Null }
    Invoke-TestGit -Repository $Path -Arguments @('config', 'user.name', 'Hardness Fixture') | Out-Null
    Invoke-TestGit -Repository $Path -Arguments @('config', 'user.email', 'hardness-fixture@example.invalid') | Out-Null
}

$workspaceManifest = Join-Path $PSScriptRoot '..\scripts\WorkspaceLifecycle.psd1'
$workspaceModuleFile = Join-Path $PSScriptRoot '..\scripts\WorkspaceLifecycle.psm1'
$gitManifest = Join-Path $PSScriptRoot '..\..\git-operations\scripts\GitOperations.psd1'
$tokens = $null
$parseErrors = $null
[void][System.Management.Automation.Language.Parser]::ParseFile($workspaceModuleFile, [ref]$tokens, [ref]$parseErrors)
Assert-Equal 0 @($parseErrors).Count 'WorkspaceLifecycle.psm1 must parse without errors'
Import-Module $workspaceManifest -Force
Import-Module $gitManifest -Force
$workspaceModule = Get-Module WorkspaceLifecycle

$fixtureRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("hardness-workspace-{0}" -f [guid]::NewGuid().ToString('N'))
$childRoot = Join-Path $fixtureRoot 'child'
$parentRoot = Join-Path $fixtureRoot 'parent'
$savedSession = @{
    Root = [Environment]::GetEnvironmentVariable('HARDNESS_WORKSPACE_ROOT', 'Process')
    Primary = [Environment]::GetEnvironmentVariable('HARDNESS_PRIMARY_ROOT', 'Process')
    Mode = [Environment]::GetEnvironmentVariable('HARDNESS_WORKSPACE_MODE', 'Process')
    Goal = [Environment]::GetEnvironmentVariable('HARDNESS_GOAL_NAME', 'Process')
}

try {
    Initialize-TestRepository -Path $childRoot
    [System.IO.File]::WriteAllText((Join-Path $childRoot 'marker.txt'), "v1`n")
    Invoke-TestGit -Repository $childRoot -Arguments @('add', 'marker.txt') | Out-Null
    Invoke-TestGit -Repository $childRoot -Arguments @('commit', '-m', 'child v1') | Out-Null

    Initialize-TestRepository -Path $parentRoot
    [System.IO.File]::WriteAllText((Join-Path $parentRoot '.gitignore'), ".worktrees/`nAgentConfig.ini`n")
    [System.IO.File]::WriteAllText((Join-Path $parentRoot 'Fixture.uproject'), "{}`n")
    [System.IO.File]::WriteAllText((Join-Path $parentRoot 'README.md'), "fixture`n")
    Invoke-TestGit -Repository $parentRoot -Arguments @('add', '.gitignore', 'Fixture.uproject', 'README.md') | Out-Null
    Invoke-TestGit -Repository $parentRoot -Arguments @('commit', '-m', 'parent base') | Out-Null
    Invoke-TestGit -Repository $parentRoot -Arguments @('-c', 'protocol.file.allow=always', 'submodule', 'add', '--name', 'sdk', $childRoot, 'Modules/Child') | Out-Null
    Invoke-TestGit -Repository $parentRoot -Arguments @('commit', '-am', 'add child') | Out-Null

    $primaryProjectFile = [System.IO.Path]::GetFullPath((Join-Path $parentRoot 'Fixture.uproject'))
    [System.IO.File]::WriteAllText((Join-Path $parentRoot 'AgentConfig.ini'), "; preserve this comment`n[Paths]`nEngineRoot=C:\FixtureEngine`nProjectFile=$primaryProjectFile`n`n[LocalAgent]`nProfile=fixture`n")
    [void](Initialize-HardnessWorkspace -ProjectRoot $parentRoot)
    $primaryConfig = Get-HardnessWorkspaceConfigStatus -ProjectRoot $parentRoot
    Assert-True $primaryConfig.IdentityValid 'bootstrap stamps the primary workspace identity'
    Assert-Equal 'Primary' $primaryConfig.Identity.WorkspaceKind 'primary workspace is identified explicitly'

    [System.IO.File]::WriteAllText((Join-Path $parentRoot 'primary-user-work.txt'), "must stay uncommitted`n")
    Assert-ThrowsMatch {
        Complete-HardnessGitCommit -ProjectRoot $parentRoot -Mode Goal -GoalName fixture-goal -AllChanges -CommitMessage 'must refuse primary' -WhatIf | Out-Null
    } 'primary|Goal worktree' 'Goal commit refuses the primary checkout even under WhatIf'
    [System.IO.File]::Delete((Join-Path $parentRoot 'primary-user-work.txt'))

    $gitmodulesPath = Join-Path $parentRoot '.gitmodules'
    $validGitmodules = [System.IO.File]::ReadAllText($gitmodulesPath)
    [System.IO.File]::WriteAllText($gitmodulesPath, "[submodule `"broken`"`n  path = Modules/Child`n")
    Assert-ThrowsMatch { Get-HardnessWorkspaceStatus -ProjectRoot $parentRoot | Out-Null } 'gitmodules|config|failed|parse' 'malformed .gitmodules is an error'
    [System.IO.File]::WriteAllText($gitmodulesPath, $validGitmodules)

    $submoduleRecords = @(& $workspaceModule { param($root) Get-WorkspaceSubmodules -Repository $root } $parentRoot)
    Assert-Equal 'sdk' $submoduleRecords[0].Name 'submodule parser preserves the logical name'
    Assert-Equal 'Modules/Child' $submoduleRecords[0].Path 'submodule parser preserves the checkout path'
    $moduleStore = & $workspaceModule { param($root) Get-WorkspaceSubmoduleStore -Repository $root -Name 'sdk' } $parentRoot
    Assert-True ($moduleStore.EndsWith((Join-Path 'modules' 'sdk'), [System.StringComparison]::OrdinalIgnoreCase)) 'fallback storage is keyed by logical name'

    $created = New-HardnessWorkspace -Name 'fixture-goal' -Branch 'goal/fixture-goal' -RepositoryRoot $parentRoot
    $worktreeRoot = Join-Path $parentRoot '.worktrees\fixture-goal'
    Assert-Equal $worktreeRoot $created.WorktreeRoot 'workspace is created in the canonical local directory'
    Assert-True (-not (Test-Path -LiteralPath (Join-Path $worktreeRoot 'openspec\changes\fixture-goal'))) 'workspace creation does not scaffold OpenSpec records'

    $goalConfig = Get-HardnessWorkspaceConfigStatus -ProjectRoot $worktreeRoot
    Assert-True $goalConfig.IdentityValid 'new workspace receives a valid local identity'
    Assert-Equal 'Goal' $goalConfig.Identity.WorkspaceKind 'new workspace is identified as Goal'
    Assert-Equal 'fixture-goal' $goalConfig.Identity.GoalName 'Goal name is persisted in managed metadata'
    Assert-Equal ([System.IO.Path]::GetFullPath((Join-Path $worktreeRoot 'Fixture.uproject'))) (Get-HardnessWorkspaceConfigValue -ProjectRoot $worktreeRoot -Section Paths -Key ProjectFile).Value 'ProjectFile is rebound to the Goal workspace'
    Assert-Equal 'fixture' (Get-HardnessWorkspaceConfigValue -ProjectRoot $worktreeRoot -Section LocalAgent -Key Profile).Value 'local settings are copied from the primary workspace'
    Assert-True ((Get-Content -LiteralPath (Join-Path $worktreeRoot 'AgentConfig.ini') -Raw).Contains('; preserve this comment')) 'configuration comments survive managed updates'
    [void](Set-HardnessWorkspaceConfigValue -ProjectRoot $worktreeRoot -Section LocalAgent -Key Profile -Value 'goal-fixture')
    Assert-Equal 'goal-fixture' (Get-HardnessWorkspaceConfigValue -ProjectRoot $worktreeRoot -Section LocalAgent -Key Profile).Value 'controlled config set updates a non-reserved key'
    Assert-ThrowsMatch { Set-HardnessWorkspaceConfigValue -ProjectRoot $worktreeRoot -Section Hardness -Key GoalName -Value other | Out-Null } 'managed|cannot be set' 'managed identity fields cannot be overwritten'
    Assert-ThrowsMatch { Set-HardnessWorkspaceConfigValue -ProjectRoot $worktreeRoot -Section LocalAgent -Key Notes -Value "line1`nline2" | Out-Null } 'single-line|NUL' 'multiline config injection is rejected'

    $sourceProjectRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..\..\..'))
    foreach ($fixtureWorkspaceRoot in @($parentRoot, $worktreeRoot)) {
        $fixtureModuleRoot = Join-Path $fixtureWorkspaceRoot '.agents\skills\workspace-lifecycle\scripts'
        [void](New-Item -ItemType Directory -Path $fixtureModuleRoot -Force)
        Copy-Item -LiteralPath (Join-Path $sourceProjectRoot '.agents\skills\workspace-lifecycle\scripts\WorkspaceLifecycle.psm1') -Destination $fixtureModuleRoot
        Copy-Item -LiteralPath (Join-Path $sourceProjectRoot '.agents\skills\workspace-lifecycle\scripts\WorkspaceLifecycle.psd1') -Destination $fixtureModuleRoot
    }
    . (Join-Path $sourceProjectRoot 'Tools\Shared\UnrealCommandUtils.ps1')

    $activation = Set-HardnessWorkspaceSession -ProjectRoot $worktreeRoot -Mode Goal -GoalName fixture-goal
    Assert-Equal $worktreeRoot $activation.WorkspaceRoot 'Goal activation selects only the current process session'
    [void](Assert-HardnessWorkspaceExecution -ProjectRoot $worktreeRoot -CallerPath $worktreeRoot)
    Assert-ThrowsMatch { Assert-HardnessWorkspaceExecution -ProjectRoot $parentRoot -CallerPath $worktreeRoot | Out-Null } 'selected workspace|targets' 'a Goal session cannot target the primary workspace'
    Assert-ThrowsMatch { Assert-HardnessWorkspaceExecution -ProjectRoot $worktreeRoot -SelectedWorkspaceRoot $worktreeRoot -CallerPath $parentRoot | Out-Null } 'current shell belongs|targets' 'a primary-root caller cannot target the Goal by accident'
    Push-Location $worktreeRoot
    try {
        $resolvedGoalConfig = Resolve-AgentConfiguration -ProjectRoot $worktreeRoot
        Assert-Equal ([System.IO.Path]::GetFullPath((Join-Path $worktreeRoot 'Fixture.uproject'))) $resolvedGoalConfig.ProjectFile 'shared Unreal configuration accepts the matching Goal execution without launching UE'
        Assert-ThrowsMatch { Resolve-AgentConfiguration -ProjectRoot $parentRoot | Out-Null } 'selected workspace|targets' 'shared Unreal configuration rejects a primary launch from the Goal session before UE starts'
        $alternateConfig = Join-Path $worktreeRoot 'AlternateAgentConfig.ini'
        [System.IO.File]::Copy((Join-Path $worktreeRoot 'AgentConfig.ini'), $alternateConfig)
        Assert-ThrowsMatch { Resolve-AgentConfiguration -ProjectRoot $worktreeRoot -ConfigPath $alternateConfig | Out-Null } 'Hardness-managed|ConfigPath' 'a custom config path cannot bypass managed workspace identity'
        [System.IO.File]::Delete($alternateConfig)
    }
    finally { Pop-Location }
    [void](Set-HardnessWorkspaceSession -ProjectRoot $parentRoot -Mode Current)
    Push-Location $parentRoot
    try {
        $resolvedPrimaryConfig = Resolve-AgentConfiguration -ProjectRoot $parentRoot
        Assert-Equal $primaryProjectFile $resolvedPrimaryConfig.ProjectFile 'shared Unreal configuration accepts matching Current execution without launching UE'
    }
    finally { Pop-Location }
    [void](Set-HardnessWorkspaceSession -ProjectRoot $worktreeRoot -Mode Goal -GoalName fixture-goal)

    $expectedChild = ((Invoke-TestGit -Repository $parentRoot -Arguments @('rev-parse', 'HEAD:Modules/Child')) | Select-Object -Last 1).Trim()
    $actualChild = ((Invoke-TestGit -Repository (Join-Path $worktreeRoot 'Modules\Child') -Arguments @('rev-parse', 'HEAD')) | Select-Object -Last 1).Trim()
    Assert-Equal $expectedChild $actualChild 'submodule checkout matches the exact parent gitlink'
    $nestedPreview = New-HardnessWorkspace -Name 'nested-probe' -RepositoryRoot $worktreeRoot -WhatIf
    Assert-Equal (Join-Path $parentRoot '.worktrees\nested-probe') $nestedPreview.WorktreeRoot 'new resolves the canonical container from a linked workspace'

    $childMarker = Join-Path $worktreeRoot 'Modules\Child\marker.txt'
    [System.IO.File]::AppendAllText($childMarker, "dirty-preserved`n")
    [void](Initialize-HardnessWorkspace -ProjectRoot $worktreeRoot)
    Assert-True ((Get-Content -LiteralPath $childMarker -Raw) -match 'dirty-preserved') 'bootstrap preserves dirty submodule work at the exact gitlink'
    Assert-True (Test-HardnessWorkspace -ProjectRoot $worktreeRoot).IsValid 'dirty content does not invalidate exact gitlink identity'
    Assert-True (-not (Test-HardnessWorkspace -ProjectRoot $worktreeRoot -RequireClean).IsValid) 'RequireClean rejects dirty submodule work'
    Assert-ThrowsMatch { Remove-HardnessWorkspace -WorktreeRoot $worktreeRoot -RepositoryRoot $parentRoot | Out-Null } 'dirty' 'cleanup refuses a dirty workspace'

    [System.IO.File]::WriteAllText((Join-Path $worktreeRoot 'goal.txt'), "goal result`n")
    $worktreeCountBeforeCommit = @((Invoke-TestGit -Repository $parentRoot -Arguments @('worktree', 'list', '--porcelain')) | Where-Object { $_ -like 'worktree *' }).Count
    $remoteRefsBeforeCommit = @((Invoke-TestGit -Repository $parentRoot -Arguments @('for-each-ref', '--format=%(refname)', 'refs/remotes/'))).Count
    $commitResult = Complete-HardnessGitCommit -ProjectRoot $worktreeRoot -Mode Goal -GoalName fixture-goal -AllChanges -CommitMessage 'finish fixture goal' -SubmoduleCommitMessages @{ 'Modules/Child' = 'finish fixture child' }
    Assert-Equal 2 @($commitResult.Commits).Count 'Goal commit records the dirty submodule before the parent'
    Assert-True $commitResult.GitStateComplete 'Goal commit leaves the selected workspace clean'
    $finishedChild = ((Invoke-TestGit -Repository (Join-Path $worktreeRoot 'Modules\Child') -Arguments @('rev-parse', 'HEAD')) | Select-Object -Last 1).Trim()
    $recordedChild = ((Invoke-TestGit -Repository $worktreeRoot -Arguments @('rev-parse', 'HEAD:Modules/Child')) | Select-Object -Last 1).Trim()
    Assert-Equal $finishedChild $recordedChild 'parent commit records the committed submodule gitlink'
    Assert-True (Test-Path -LiteralPath $worktreeRoot -PathType Container) 'commit never removes the workspace'
    Assert-Equal $worktreeCountBeforeCommit @((Invoke-TestGit -Repository $parentRoot -Arguments @('worktree', 'list', '--porcelain')) | Where-Object { $_ -like 'worktree *' }).Count 'commit does not create or remove worktrees'
    Assert-Equal $remoteRefsBeforeCommit @((Invoke-TestGit -Repository $parentRoot -Arguments @('for-each-ref', '--format=%(refname)', 'refs/remotes/'))).Count 'commit does not publish refs'

    Assert-ThrowsMatch { Remove-HardnessWorkspace -WorktreeRoot $worktreeRoot -RepositoryRoot $parentRoot | Out-Null } 'ignored|AgentConfig' 'cleanup refuses ignored local data without explicit discard intent'
    [void](Remove-HardnessWorkspace -WorktreeRoot $worktreeRoot -RepositoryRoot $parentRoot -DiscardIgnoredFiles)
    Assert-True (-not (Test-Path -LiteralPath $worktreeRoot)) 'explicit cleanup removes a clean registered workspace'
    Assert-True (((Invoke-TestGit -Repository $parentRoot -Arguments @('branch', '--list', 'goal/fixture-goal')) -join "`n") -match 'goal/fixture-goal') 'workspace cleanup preserves the Goal branch'

    [void](New-Item -ItemType Directory -Path $worktreeRoot)
    Assert-ThrowsMatch { Remove-HardnessWorkspace -WorktreeRoot $worktreeRoot -RepositoryRoot $parentRoot | Out-Null } 'not a registered' 'unregistered empty-root recovery requires explicit cleanup intent'
    $preview = Remove-HardnessWorkspace -WorktreeRoot $worktreeRoot -RepositoryRoot $parentRoot -DiscardIgnoredFiles -WhatIf
    Assert-True (-not $preview.Removed) 'cleanup WhatIf leaves an orphan directory untouched'
    $recovered = Remove-HardnessWorkspace -WorktreeRoot $worktreeRoot -RepositoryRoot $parentRoot -DiscardIgnoredFiles
    Assert-True $recovered.Removed 'explicit cleanup can recover an empty canonical orphan'
    Assert-True $recovered.BranchPreserved 'orphan cleanup preserves the Goal branch'
}
finally {
    [Environment]::SetEnvironmentVariable('HARDNESS_WORKSPACE_ROOT', $savedSession.Root, 'Process')
    [Environment]::SetEnvironmentVariable('HARDNESS_PRIMARY_ROOT', $savedSession.Primary, 'Process')
    [Environment]::SetEnvironmentVariable('HARDNESS_WORKSPACE_MODE', $savedSession.Mode, 'Process')
    [Environment]::SetEnvironmentVariable('HARDNESS_GOAL_NAME', $savedSession.Goal, 'Process')
    Remove-Module GitOperations -Force -ErrorAction SilentlyContinue
    Remove-Module WorkspaceLifecycle -Force -ErrorAction SilentlyContinue
    if (Test-Path -LiteralPath $fixtureRoot) { Remove-Item -LiteralPath $fixtureRoot -Recurse -Force }
}

[void](& (Join-Path $PSScriptRoot 'WorkspaceLifecycle.Safety.Tests.ps1'))
Write-Output 'WorkspaceLifecycle.Tests.ps1: PASS'
