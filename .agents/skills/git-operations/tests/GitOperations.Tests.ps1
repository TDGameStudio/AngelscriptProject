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
    param(
        [Parameter(Mandatory = $true)][string]$Repository,
        [Parameter(Mandatory = $true)][string[]]$Arguments,
        [switch]$AllowFailure
    )
    $oldAllow = $env:GIT_ALLOW_PROTOCOL
    $oldPreference = $ErrorActionPreference
    $env:GIT_ALLOW_PROTOCOL = 'file'
    $ErrorActionPreference = 'Continue'
    try { $output = @(& git -C $Repository @Arguments 2>&1); $exitCode = $LASTEXITCODE }
    finally { $env:GIT_ALLOW_PROTOCOL = $oldAllow; $ErrorActionPreference = $oldPreference }
    if (-not $AllowFailure -and $exitCode -ne 0) { throw "git -C '$Repository' $($Arguments -join ' ') failed ($exitCode): $($output -join [Environment]::NewLine)" }
    return [pscustomobject]@{ ExitCode = $exitCode; Output = @($output | ForEach-Object { [string]$_ }) }
}

function Initialize-TestRepository {
    param([Parameter(Mandatory = $true)][string]$Path)
    [void](New-Item -ItemType Directory -Path $Path -Force)
    & git -C $Path init --initial-branch=main 2>&1 | Out-Null
    if ($LASTEXITCODE -ne 0) { & git -C $Path init 2>&1 | Out-Null; [void](Invoke-TestGit -Repository $Path -Arguments @('checkout', '-b', 'main')) }
    [void](Invoke-TestGit -Repository $Path -Arguments @('config', 'user.name', 'Hardness Git Fixture'))
    [void](Invoke-TestGit -Repository $Path -Arguments @('config', 'user.email', 'hardness-git@example.invalid'))
}

function Get-TestHead {
    param([string]$Repository, [string]$Revision = 'HEAD')
    return ([string]((Invoke-TestGit -Repository $Repository -Arguments @('rev-parse', $Revision)).Output | Select-Object -Last 1)).Trim()
}

$manifest = Join-Path $PSScriptRoot '..\scripts\GitOperations.psd1'
$moduleFile = Join-Path $PSScriptRoot '..\scripts\GitOperations.psm1'
$tokens = $null
$parseErrors = $null
[void][System.Management.Automation.Language.Parser]::ParseFile($moduleFile, [ref]$tokens, [ref]$parseErrors)
Assert-Equal 0 @($parseErrors).Count 'GitOperations.psm1 must parse without errors'
Import-Module $manifest -Force

$fixtureRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("hardness-git-{0}" -f [guid]::NewGuid().ToString('N'))
$childRoot = Join-Path $fixtureRoot 'child-source'
$childRemote = Join-Path $fixtureRoot 'child-remote.git'
$parentRoot = Join-Path $fixtureRoot 'parent'
$parentRemote = Join-Path $fixtureRoot 'parent-remote.git'

try {
    [void](New-Item -ItemType Directory -Path $fixtureRoot -Force)
    Initialize-TestRepository -Path $childRoot
    [System.IO.File]::WriteAllText((Join-Path $childRoot 'child.txt'), "child base`n")
    [void](Invoke-TestGit -Repository $childRoot -Arguments @('add', 'child.txt'))
    [void](Invoke-TestGit -Repository $childRoot -Arguments @('commit', '-m', 'child base'))
    & git init --bare --initial-branch=main $childRemote 2>&1 | Out-Null
    if ($LASTEXITCODE -ne 0) { throw 'Unable to create child bare remote.' }
    [void](Invoke-TestGit -Repository $childRoot -Arguments @('remote', 'add', 'origin', $childRemote))
    [void](Invoke-TestGit -Repository $childRoot -Arguments @('push', '-u', 'origin', 'main'))

    Initialize-TestRepository -Path $parentRoot
    [System.IO.File]::WriteAllText((Join-Path $parentRoot '.gitignore'), ".worktrees/`n")
    [System.IO.File]::WriteAllText((Join-Path $parentRoot 'README.md'), "parent base`n")
    [void](Invoke-TestGit -Repository $parentRoot -Arguments @('add', '.gitignore', 'README.md'))
    [void](Invoke-TestGit -Repository $parentRoot -Arguments @('commit', '-m', 'parent base'))
    [void](Invoke-TestGit -Repository $parentRoot -Arguments @('-c', 'protocol.file.allow=always', 'submodule', 'add', '--name', 'sdk', $childRemote, 'Modules/Child'))
    [void](Invoke-TestGit -Repository $parentRoot -Arguments @('commit', '-am', 'add child'))
    & git init --bare --initial-branch=main $parentRemote 2>&1 | Out-Null
    if ($LASTEXITCODE -ne 0) { throw 'Unable to create parent bare remote.' }
    [void](Invoke-TestGit -Repository $parentRoot -Arguments @('remote', 'add', 'origin', $parentRemote))
    [void](Invoke-TestGit -Repository $parentRoot -Arguments @('push', '-u', 'origin', 'main'))

    [System.IO.File]::WriteAllText((Join-Path $parentRoot 'scoped.txt'), "commit only this path`n")
    [System.IO.File]::WriteAllText((Join-Path $parentRoot 'unrelated.txt'), "preserve this path`n")
    [void](Invoke-TestGit -Repository $parentRoot -Arguments @('add', 'unrelated.txt'))
    Assert-ThrowsMatch {
        Complete-HardnessGitCommit -ProjectRoot $parentRoot -Mode Current -RepositoryScopes @{ '.' = @('scoped.txt') } -CommitMessage 'scoped current commit' | Out-Null
    } 'staged paths outside|unrelated' 'Current scoped commit rejects unrelated pre-staged content'
    [void](Invoke-TestGit -Repository $parentRoot -Arguments @('restore', '--staged', 'unrelated.txt'))

    [System.IO.File]::WriteAllText((Join-Path $parentRoot '.hidden-scope.txt'), "hidden staged path`n")
    [System.IO.File]::WriteAllText((Join-Path $parentRoot 'hidden-scope.txt'), "different visible path`n")
    [void](Invoke-TestGit -Repository $parentRoot -Arguments @('add', '.hidden-scope.txt'))
    Assert-ThrowsMatch {
        Complete-HardnessGitCommit -ProjectRoot $parentRoot -Mode Current -RepositoryScopes @{ '.' = @('hidden-scope.txt') } -CommitMessage 'must not alias dotfile scope' | Out-Null
    } 'staged paths outside|hidden-scope' 'Current scoped commit never aliases a leading-dot path to a visible path'
    [void](Invoke-TestGit -Repository $parentRoot -Arguments @('restore', '--staged', '.hidden-scope.txt'))
    [System.IO.File]::Delete((Join-Path $parentRoot '.hidden-scope.txt'))
    [System.IO.File]::Delete((Join-Path $parentRoot 'hidden-scope.txt'))

    $currentCommit = Complete-HardnessGitCommit -ProjectRoot $parentRoot -Mode Current -RepositoryScopes @{ '.' = @('scoped.txt') } -CommitMessage 'scoped current commit'
    Assert-Equal 1 @($currentCommit.Commits).Count 'Current scoped commit creates one parent commit'
    Assert-True (Test-Path -LiteralPath (Join-Path $parentRoot 'unrelated.txt') -PathType Leaf) 'Current scoped commit preserves unrelated untracked content'
    Assert-True (((Invoke-TestGit -Repository $parentRoot -Arguments @('status', '--short', '--', 'unrelated.txt')).Output -join "`n") -match '^\?\?') 'unrelated path remains untracked after scoped commit'
    [System.IO.File]::Delete((Join-Path $parentRoot 'unrelated.txt'))

    $baseParentRemote = Get-TestHead -Repository $parentRoot -Revision 'refs/remotes/origin/main'
    $baseChildRemote = Get-TestHead -Repository (Join-Path $parentRoot 'Modules/Child') -Revision 'refs/remotes/origin/main'
    $worktreeRoot = Join-Path $parentRoot '.worktrees\integration-fixture'
    [void](Invoke-TestGit -Repository $parentRoot -Arguments @('worktree', 'add', '-b', 'goal/integration-fixture', $worktreeRoot, 'HEAD'))
    [void](Invoke-TestGit -Repository $worktreeRoot -Arguments @('-c', 'protocol.file.allow=always', 'submodule', 'update', '--init', '--checkout'))
    $goalChild = Join-Path $worktreeRoot 'Modules/Child'

    $targetChild = Join-Path $parentRoot 'Modules/Child'
    [System.IO.File]::WriteAllText((Join-Path $targetChild 'target-only.txt'), "target branch child work`n")
    [void](Invoke-TestGit -Repository $targetChild -Arguments @('add', 'target-only.txt'))
    [void](Invoke-TestGit -Repository $targetChild -Arguments @('commit', '-m', 'target child divergence'))
    [void](Invoke-TestGit -Repository $parentRoot -Arguments @('add', 'Modules/Child'))
    [void](Invoke-TestGit -Repository $parentRoot -Arguments @('commit', '-m', 'record target child divergence'))

    [System.IO.File]::AppendAllText((Join-Path $goalChild 'child.txt'), "goal child`n")
    [System.IO.File]::WriteAllText((Join-Path $worktreeRoot 'goal.txt'), "goal parent`n")
    $status = Get-HardnessGitStatus -ProjectRoot $worktreeRoot
    Assert-True $status.Dirty 'status aggregates parent and initialized submodule changes'
    Assert-Equal 2 @($status.Repositories).Count 'status reports the parent and top-level submodule independently'

    $previewChildHead = Get-TestHead -Repository $goalChild
    $commitPreview = Complete-HardnessGitCommit -ProjectRoot $worktreeRoot -Mode Goal -GoalName integration-fixture -AllChanges -CommitMessage 'goal parent preview' -SubmoduleCommitMessages @{ 'Modules/Child' = 'goal child preview' } -WhatIf
    Assert-True $commitPreview.Preview 'Goal commit preview reports preview mode'
    Assert-True (-not $commitPreview.ScopedGitStateComplete) 'Goal commit preview does not claim dirty scoped state is complete'
    Assert-Equal 0 @($commitPreview.Commits).Count 'Goal commit preview creates no commits'
    Assert-Equal $previewChildHead (Get-TestHead -Repository $goalChild) 'Goal commit preview preserves the detached submodule HEAD'
    Assert-Equal 1 (Invoke-TestGit -Repository $goalChild -Arguments @('show-ref', '--verify', '--quiet', 'refs/heads/goal/integration-fixture') -AllowFailure).ExitCode 'Goal commit preview creates no submodule branch'

    $commit = Complete-HardnessGitCommit -ProjectRoot $worktreeRoot -Mode Goal -GoalName integration-fixture -AllChanges -CommitMessage 'goal parent result' -SubmoduleCommitMessages @{ 'Modules/Child' = 'goal child result' }
    Assert-True (-not $commit.Preview) 'actual Goal commit is not reported as a preview'
    Assert-Equal 'Modules/Child' $commit.Commits[0].Repository 'Goal commit records submodules before the parent'
    Assert-Equal '.' $commit.Commits[-1].Repository 'Goal commit records the parent last'
    Assert-True $commit.GitStateComplete 'Goal commit leaves its repositories clean'
    $sourceHead = Get-TestHead -Repository $worktreeRoot
    $sourceChildHead = Get-TestHead -Repository $goalChild
    Assert-Equal $sourceChildHead (Get-TestHead -Repository $worktreeRoot -Revision 'HEAD:Modules/Child') 'parent gitlink records the committed Goal submodule'
    Assert-Equal $baseParentRemote (Get-TestHead -Repository $parentRoot -Revision 'refs/remotes/origin/main') 'commit does not publish the parent branch'
    Assert-Equal $baseChildRemote (Get-TestHead -Repository (Join-Path $parentRoot 'Modules/Child') -Revision 'refs/remotes/origin/main') 'commit does not publish the submodule branch'

    [System.IO.File]::WriteAllText((Join-Path $parentRoot 'local-note.txt'), "unrelated local primary work`n")
    $targets = @{ '.' = 'main'; 'Modules/Child' = 'main' }
    $preview = Merge-HardnessGitGoal -ProjectRoot $parentRoot -GoalName integration-fixture -ExpectedSourceHead $sourceHead -TargetBranches $targets -WhatIf
    Assert-True $preview.Preview 'integration supports a non-mutating reviewed preview'
    Assert-True (-not $preview.Integrated) 'preview does not claim integration'
    Assert-Equal 'Merge' (@($preview.Plans | Where-Object Repository -eq 'Modules/Child')[0].Action) 'preview detects divergent submodule history'
    Assert-ThrowsMatch {
        Merge-HardnessGitGoal -ProjectRoot $parentRoot -GoalName integration-fixture -ExpectedSourceHead ('0' * 40) -TargetBranches $targets -WhatIf | Out-Null
    } 'ExpectedSourceHead|does not match|source HEAD' 'integration is pinned to the reviewed Goal snapshot'

    $integrated = Merge-HardnessGitGoal -ProjectRoot $parentRoot -GoalName integration-fixture -ExpectedSourceHead $sourceHead -TargetBranches $targets -CommitMessage 'integrate fixture goal'
    Assert-True $integrated.Integrated 'explicit integration completes locally'
    Assert-True $integrated.SourcePreserved 'integration preserves the source workspace'
    Assert-True (Test-Path -LiteralPath (Join-Path $parentRoot 'local-note.txt') -PathType Leaf) 'non-overlapping primary work is preserved'
    Assert-Equal $sourceHead (Get-TestHead -Repository $worktreeRoot) 'integration does not rewrite the reviewed source'
    $parentLineage = @((Invoke-TestGit -Repository $parentRoot -Arguments @('rev-list', '--parents', '-n', '1', 'HEAD')).Output[0] -split '\s+')
    Assert-Equal 3 $parentLineage.Count 'parent integration preserves Goal history with a merge commit'
    $integratedChildHead = Get-TestHead -Repository (Join-Path $parentRoot 'Modules/Child')
    Assert-Equal $integratedChildHead (Get-TestHead -Repository $parentRoot -Revision 'HEAD:Modules/Child') 'parent integration records the final integrated submodule head'
    Assert-Equal 0 (Invoke-TestGit -Repository (Join-Path $parentRoot 'Modules/Child') -Arguments @('merge-base', '--is-ancestor', $sourceChildHead, $integratedChildHead) -AllowFailure).ExitCode 'integrated submodule contains the reviewed Goal commit'
    $childLineage = @((Invoke-TestGit -Repository (Join-Path $parentRoot 'Modules/Child') -Arguments @('rev-list', '--parents', '-n', '1', $integratedChildHead)).Output[0] -split '\s+')
    Assert-Equal 3 $childLineage.Count 'divergent submodule integration preserves both histories with a merge commit'
    Assert-Equal $baseParentRemote (Get-TestHead -Repository $parentRoot -Revision 'refs/remotes/origin/main') 'integration remains local until push is explicit'
    Assert-Equal $baseChildRemote (Get-TestHead -Repository (Join-Path $parentRoot 'Modules/Child') -Revision 'refs/remotes/origin/main') 'integration does not implicitly publish submodules'

    Assert-ThrowsMatch {
        Publish-HardnessGitBranches -ProjectRoot $parentRoot -RepositoryBranches @{ '.' = 'main' } -WhatIf | Out-Null
    } 'submodule|explicitly include|not known reachable' 'parent publication refuses an unpublished gitlink unless the submodule is explicit'
    $pushPreview = Publish-HardnessGitBranches -ProjectRoot $parentRoot -RepositoryBranches @{ '.' = 'main'; 'Modules\Child' = 'main' } -WhatIf
    Assert-True $pushPreview.Preview 'push has an explicit non-mutating preview'
    Assert-Equal 'Modules/Child' $pushPreview.Plans[0].Repository 'push orders submodules before the parent'
    Assert-Equal '.' $pushPreview.Plans[-1].Repository 'push orders the parent last'
    Assert-True (-not $pushPreview.Forced) 'push never uses force semantics'
    Assert-Equal $baseParentRemote (Get-TestHead -Repository $parentRoot -Revision 'refs/remotes/origin/main') 'push preview changes no parent remote ref'

    $push = Publish-HardnessGitBranches -ProjectRoot $parentRoot -RepositoryBranches @{ '.' = 'main'; 'Modules/Child' = 'main' }
    Assert-True $push.Pushed 'push occurs only through the explicit publish command'
    Assert-True (-not $push.Forced) 'actual push remains non-force'
    Assert-Equal (Get-TestHead -Repository $parentRoot) (Get-TestHead -Repository $parentRoot -Revision 'refs/remotes/origin/main') 'explicit push publishes the parent branch'
    Assert-Equal (Get-TestHead -Repository (Join-Path $parentRoot 'Modules/Child')) (Get-TestHead -Repository (Join-Path $parentRoot 'Modules/Child') -Revision 'refs/remotes/origin/main') 'explicit push publishes the submodule branch first'
    Assert-True (Test-Path -LiteralPath $worktreeRoot -PathType Container) 'commit, integration, and push never clean up the Goal workspace'

    $pushCommand = Get-Command Publish-HardnessGitBranches
    Assert-True ('Force' -notin @($pushCommand.Parameters.Keys)) 'the public push command exposes no force switch'

    $conflictRoot = Join-Path $parentRoot '.worktrees\conflict-fixture'
    [void](Invoke-TestGit -Repository $parentRoot -Arguments @('worktree', 'add', '-b', 'goal/conflict-fixture', $conflictRoot, 'HEAD'))
    [System.IO.File]::WriteAllText((Join-Path $conflictRoot 'README.md'), "Goal rewrites the same line`n")
    [void](Invoke-TestGit -Repository $conflictRoot -Arguments @('add', 'README.md'))
    [void](Invoke-TestGit -Repository $conflictRoot -Arguments @('commit', '-m', 'goal conflict'))
    $conflictSourceHead = Get-TestHead -Repository $conflictRoot
    [System.IO.File]::WriteAllText((Join-Path $parentRoot 'README.md'), "Primary rewrites the same line`n")
    [void](Invoke-TestGit -Repository $parentRoot -Arguments @('add', 'README.md'))
    [void](Invoke-TestGit -Repository $parentRoot -Arguments @('commit', '-m', 'primary conflict'))
    $beforeConflictHead = Get-TestHead -Repository $parentRoot
    Assert-ThrowsMatch {
        Merge-HardnessGitGoal -ProjectRoot $parentRoot -GoalName conflict-fixture -ExpectedSourceHead $conflictSourceHead -TargetBranches @{ '.' = 'main' } | Out-Null
    } 'ordinary conflicts|could not be limited|README' 'ordinary parent conflicts abort instead of being resolved automatically'
    Assert-Equal $beforeConflictHead (Get-TestHead -Repository $parentRoot) 'ordinary conflict abort preserves the target HEAD'
    Assert-True (-not (Test-Path -LiteralPath (Join-Path $parentRoot '.git\MERGE_HEAD') -PathType Leaf)) 'ordinary conflict leaves no merge in progress'
    Assert-True (Test-Path -LiteralPath $conflictRoot -PathType Container) 'conflict handling preserves the source worktree'
}
finally {
    Remove-Module GitOperations -Force -ErrorAction SilentlyContinue
    if (Test-Path -LiteralPath $fixtureRoot) { Remove-Item -LiteralPath $fixtureRoot -Recurse -Force }
}

Write-Output 'GitOperations.Tests.ps1: PASS'
