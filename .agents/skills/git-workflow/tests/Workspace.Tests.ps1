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

function Assert-ThrowsMatch {
    param([scriptblock]$Action, [string]$Pattern, [string]$Message)
    $thrown = $false
    try {
        & $Action
    }
    catch {
        $thrown = $_.Exception.Message -match $Pattern
    }
    Assert-True $thrown $Message
}

function Invoke-TestGit {
    param(
        [Parameter(Mandatory = $true)][string]$Repository,
        [Parameter(Mandatory = $true)][string[]]$Arguments
    )

    $oldAllow = $env:GIT_ALLOW_PROTOCOL
    $oldPreference = $ErrorActionPreference
    $env:GIT_ALLOW_PROTOCOL = 'file'
    $ErrorActionPreference = 'Continue'
    try {
        $output = & git -C $Repository @Arguments 2>&1
        $exitCode = $LASTEXITCODE
    }
    finally {
        $env:GIT_ALLOW_PROTOCOL = $oldAllow
        $ErrorActionPreference = $oldPreference
    }
    if ($exitCode -ne 0) {
        throw "git -C '$Repository' $($Arguments -join ' ') failed ($exitCode): $($output -join [Environment]::NewLine)"
    }
    return @($output)
}

function Initialize-TestRepository {
    param([string]$Path)
    [void](New-Item -ItemType Directory -Path $Path -Force)
    & git -C $Path init --initial-branch=main 2>&1 | Out-Null
    if ($LASTEXITCODE -ne 0) {
        & git -C $Path init 2>&1 | Out-Null
        Invoke-TestGit -Repository $Path -Arguments @('checkout', '-b', 'main') | Out-Null
    }
    Invoke-TestGit -Repository $Path -Arguments @('config', 'user.name', 'Hardness Fixture') | Out-Null
    Invoke-TestGit -Repository $Path -Arguments @('config', 'user.email', 'hardness-fixture@example.invalid') | Out-Null
}

$manifest = Join-Path $PSScriptRoot '..\scripts\Workspace.psd1'
$moduleFile = Join-Path $PSScriptRoot '..\scripts\Workspace.psm1'
$tokens = $null
$errors = $null
[void][System.Management.Automation.Language.Parser]::ParseFile($moduleFile, [ref]$tokens, [ref]$errors)
Assert-Equal 0 @($errors).Count 'Workspace.psm1 must parse without errors'
Import-Module $manifest -Force

$fixtureRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("hardness-workspace-{0}" -f [guid]::NewGuid().ToString('N'))
$childRoot = Join-Path $fixtureRoot 'child'
$parentRoot = Join-Path $fixtureRoot 'parent'

try {
    Initialize-TestRepository -Path $childRoot
    [System.IO.File]::WriteAllText((Join-Path $childRoot 'marker.txt'), "v1`n")
    Invoke-TestGit -Repository $childRoot -Arguments @('add', 'marker.txt') | Out-Null
    Invoke-TestGit -Repository $childRoot -Arguments @('commit', '-m', 'child v1') | Out-Null

    Initialize-TestRepository -Path $parentRoot
    [System.IO.File]::WriteAllText((Join-Path $parentRoot '.gitignore'), ".worktrees/`nAgentConfig.ini`n")
    [System.IO.File]::WriteAllText((Join-Path $parentRoot 'README.md'), "fixture`n")
    Invoke-TestGit -Repository $parentRoot -Arguments @('add', '.gitignore', 'README.md') | Out-Null
    Invoke-TestGit -Repository $parentRoot -Arguments @('commit', '-m', 'parent base') | Out-Null
    Invoke-TestGit -Repository $parentRoot -Arguments @('-c', 'protocol.file.allow=always', 'submodule', 'add', '--name', 'sdk', $childRoot, 'Modules/Child') | Out-Null
    Invoke-TestGit -Repository $parentRoot -Arguments @('commit', '-am', 'add child') | Out-Null

    [System.IO.File]::WriteAllText((Join-Path $parentRoot 'AgentConfig.ini'), "[Paths]`nEngineRoot=C:\FixtureEngine`n")
    $expectedChild = ((Invoke-TestGit -Repository $parentRoot -Arguments @('rev-parse', 'HEAD:Modules/Child')) | Select-Object -Last 1).Trim()

    [System.IO.File]::WriteAllText((Join-Path $parentRoot 'primary-user-work.txt'), "must stay uncommitted`n")
    Assert-ThrowsMatch {
        Complete-HardnessWorkspace -ProjectRoot $parentRoot -WhatIf | Out-Null
    } 'primary|Goal worktree' 'finish refuses the primary checkout even under WhatIf'
    [System.IO.File]::Delete((Join-Path $parentRoot 'primary-user-work.txt'))

    $gitmodulesPath = Join-Path $parentRoot '.gitmodules'
    $validGitmodules = [System.IO.File]::ReadAllText($gitmodulesPath)
    [System.IO.File]::WriteAllText($gitmodulesPath, "[submodule `"broken`"`n  path = Modules/Child`n")
    Assert-ThrowsMatch {
        Get-HardnessWorkspaceStatus -ProjectRoot $parentRoot | Out-Null
    } 'gitmodules|config|failed|parse' 'malformed .gitmodules is an error, not an empty submodule set'
    [System.IO.File]::WriteAllText($gitmodulesPath, $validGitmodules)

    $workspaceModule = Get-Module Workspace
    $submoduleRecords = @(& $workspaceModule { param($root) Get-WorkspaceSubmodules -Repository $root } $parentRoot)
    Assert-Equal 'sdk' $submoduleRecords[0].Name 'submodule parser preserves the logical section name independently from its path'
    Assert-Equal 'Modules/Child' $submoduleRecords[0].Path 'submodule parser preserves the checkout path'
    $moduleStore = & $workspaceModule { param($root) Get-WorkspaceSubmoduleStore -Repository $root -Name 'sdk' } $parentRoot
    Assert-True ($moduleStore.EndsWith((Join-Path 'modules' 'sdk'), [System.StringComparison]::OrdinalIgnoreCase)) 'local fallback resolves object storage by logical name, not checkout path'
    Assert-True (Test-Path -LiteralPath $moduleStore -PathType Container) 'logical-name object store exists in the fixture'

    $created = New-HardnessWorkspace -Name 'fixture-goal' -Branch 'goal/fixture-goal' -RepositoryRoot $parentRoot
    $worktreeRoot = Join-Path $parentRoot '.worktrees\fixture-goal'
    Assert-Equal $worktreeRoot $created.WorktreeRoot 'workspace is created in the canonical local directory'
    Assert-True (Test-Path -LiteralPath (Join-Path $worktreeRoot 'AgentConfig.ini') -PathType Leaf) 'ignored AgentConfig.ini is copied'
    Assert-True (-not (Test-Path -LiteralPath (Join-Path $worktreeRoot 'openspec\changes\fixture-goal'))) 'workspace creation does not scaffold OpenSpec records'
    $actualChild = ((Invoke-TestGit -Repository (Join-Path $worktreeRoot 'Modules\Child') -Arguments @('rev-parse', 'HEAD')) | Select-Object -Last 1).Trim()
    Assert-Equal $expectedChild $actualChild 'submodule checkout matches the exact parent gitlink'

    $nestedPreview = New-HardnessWorkspace -Name 'nested-probe' -RepositoryRoot $worktreeRoot -WhatIf
    Assert-Equal (Join-Path $parentRoot '.worktrees\nested-probe') $nestedPreview.WorktreeRoot 'new resolves the primary canonical worktree container from a linked worktree'

    $childMarker = Join-Path $worktreeRoot 'Modules\Child\marker.txt'
    [System.IO.File]::AppendAllText($childMarker, "dirty-preserved`n")
    [void](Initialize-HardnessWorkspace -ProjectRoot $worktreeRoot -SourceRoot $parentRoot)
    Assert-True ((Get-Content -LiteralPath $childMarker -Raw) -match 'dirty-preserved') 'bootstrap never deletes dirty submodule work'

    $verification = Test-HardnessWorkspace -ProjectRoot $worktreeRoot
    Assert-True $verification.IsValid 'dirty content does not change the exact checked-out gitlink'

    Invoke-TestGit -Repository $parentRoot -Arguments @('config', 'submodule.sdk.ignore', 'dirty') | Out-Null
    $cleanVerification = Test-HardnessWorkspace -ProjectRoot $worktreeRoot -RequireClean
    Assert-True (-not $cleanVerification.IsValid) 'RequireClean rejects an explicitly detected dirty submodule even when the parent hides it'
    Invoke-TestGit -Repository $parentRoot -Arguments @('config', '--unset', 'submodule.sdk.ignore') | Out-Null

    $removeRefused = $false
    try {
        Remove-HardnessWorkspace -WorktreeRoot $worktreeRoot -RepositoryRoot $parentRoot | Out-Null
    }
    catch {
        $removeRefused = $_.Exception.Message -match 'dirty'
    }
    Assert-True $removeRefused 'remove refuses a dirty worktree'
    Assert-True (Test-Path -LiteralPath $childMarker -PathType Leaf) 'refused remove preserves the worktree'

    $junctionPath = Join-Path $parentRoot '.worktrees\fixture-junction'
    [void](New-Item -ItemType Junction -Path $junctionPath -Target $worktreeRoot)
    Assert-ThrowsMatch {
        Remove-HardnessWorkspace -WorktreeRoot $junctionPath -RepositoryRoot $parentRoot | Out-Null
    } 'reparse' 'remove refuses a reparse-point target before force removal'
    [System.IO.Directory]::Delete($junctionPath)

    $worktreeChild = Join-Path $worktreeRoot 'Modules\Child'
    Invoke-TestGit -Repository $worktreeChild -Arguments @('checkout', '-b', 'unsafe-current') | Out-Null
    Assert-ThrowsMatch {
        Complete-HardnessWorkspace -ProjectRoot $worktreeRoot -WhatIf | Out-Null
    } 'dedicated|goal/fixture-goal|branch' 'finish refuses to commit a dirty submodule on an unrelated named branch'
    Invoke-TestGit -Repository $worktreeChild -Arguments @('checkout', '--detach', $expectedChild) | Out-Null
    Invoke-TestGit -Repository $worktreeChild -Arguments @('branch', '-D', 'unsafe-current') | Out-Null

    [System.IO.File]::WriteAllText((Join-Path $childRoot 'unrelated.txt'), "unrelated branch`n")
    Invoke-TestGit -Repository $childRoot -Arguments @('add', 'unrelated.txt') | Out-Null
    Invoke-TestGit -Repository $childRoot -Arguments @('commit', '-m', 'child unrelated v2') | Out-Null
    $unrelatedChild = ((Invoke-TestGit -Repository $childRoot -Arguments @('rev-parse', 'HEAD')) | Select-Object -Last 1).Trim()
    Invoke-TestGit -Repository $worktreeChild -Arguments @('fetch', 'origin', $unrelatedChild) | Out-Null
    Invoke-TestGit -Repository $worktreeChild -Arguments @('branch', 'goal/fixture-goal', $unrelatedChild) | Out-Null
    Assert-ThrowsMatch {
        Complete-HardnessWorkspace -ProjectRoot $worktreeRoot -WhatIf | Out-Null
    } 'different|does not point|branch' 'finish rejects an existing goal submodule branch at a different commit'
    Invoke-TestGit -Repository $worktreeChild -Arguments @('branch', '-D', 'goal/fixture-goal') | Out-Null

    [System.IO.File]::WriteAllText((Join-Path $worktreeRoot 'goal.txt'), "goal result`n")
    $worktreeCountBeforeFinish = @((Invoke-TestGit -Repository $parentRoot -Arguments @('worktree', 'list', '--porcelain')) | Where-Object { $_ -like 'worktree *' }).Count
    $remoteRefsBeforeFinish = @((Invoke-TestGit -Repository $parentRoot -Arguments @('for-each-ref', '--format=%(refname)', 'refs/remotes/'))).Count
    $finished = Complete-HardnessWorkspace -ProjectRoot $worktreeRoot -CommitMessage 'finish fixture goal' -SubmoduleCommitMessage 'finish fixture child'
    Assert-True (-not [string]::IsNullOrWhiteSpace([string]$finished.ParentCommit)) 'finish creates the parent commit after submodule commits'
    Assert-Equal 1 @($finished.SubmoduleCommits).Count 'finish commits the dirty submodule'
    Assert-True $finished.GitStateComplete 'finish reports only that the scoped Git state is complete'
    Assert-True ('ReadyToIntegrate' -notin @($finished.PSObject.Properties.Name)) 'workspace leaf never claims Goal-level integration authority'
    $finishedChild = ((Invoke-TestGit -Repository (Join-Path $worktreeRoot 'Modules\Child') -Arguments @('rev-parse', 'HEAD')) | Select-Object -Last 1).Trim()
    $recordedChild = ((Invoke-TestGit -Repository $worktreeRoot -Arguments @('rev-parse', 'HEAD:Modules/Child')) | Select-Object -Last 1).Trim()
    Assert-Equal $finishedChild $recordedChild 'parent commit records the newly committed submodule gitlink'
    Assert-True (Test-HardnessWorkspace -ProjectRoot $worktreeRoot -RequireClean).IsValid 'finish leaves an exact clean workspace'
    Assert-True (Test-Path -LiteralPath $worktreeRoot -PathType Container) 'finish never removes the worktree'
    Assert-Equal $worktreeCountBeforeFinish @((Invoke-TestGit -Repository $parentRoot -Arguments @('worktree', 'list', '--porcelain')) | Where-Object { $_ -like 'worktree *' }).Count 'finish does not add, remove, or merge worktrees'
    Assert-Equal $remoteRefsBeforeFinish @((Invoke-TestGit -Repository $parentRoot -Arguments @('for-each-ref', '--format=%(refname)', 'refs/remotes/'))).Count 'finish does not push remote refs'

    Assert-ThrowsMatch {
        Remove-HardnessWorkspace -WorktreeRoot $worktreeRoot -RepositoryRoot $worktreeRoot | Out-Null
    } 'ignored|AgentConfig' 'remove refuses ignored local data unless destructive discard is explicit'
    [void](Remove-HardnessWorkspace -WorktreeRoot $worktreeRoot -RepositoryRoot $worktreeRoot -DiscardIgnoredFiles)
    Assert-True (-not (Test-Path -LiteralPath $worktreeRoot)) 'explicit remove deletes a clean registered worktree'
    $remainingBranch = @((Invoke-TestGit -Repository $parentRoot -Arguments @('branch', '--list', 'goal/fixture-goal')))
    Assert-True (($remainingBranch -join "`n") -match 'goal/fixture-goal') 'workspace removal preserves its branch'

    [void](New-Item -ItemType Directory -Path $worktreeRoot)
    Assert-ThrowsMatch {
        Remove-HardnessWorkspace -WorktreeRoot $worktreeRoot -RepositoryRoot $parentRoot | Out-Null
    } 'not a registered' 'an unregistered empty root still requires explicit recovery intent'
    $nestedResidue = Join-Path $worktreeRoot 'nested'
    [void](New-Item -ItemType Directory -Path $nestedResidue)
    Assert-ThrowsMatch {
        Remove-HardnessWorkspace -WorktreeRoot $nestedResidue -RepositoryRoot $parentRoot -DiscardIgnoredFiles | Out-Null
    } 'not a registered' 'empty-root recovery rejects nested directories below a canonical Goal root'
    Assert-True (Test-Path -LiteralPath $nestedResidue -PathType Container) 'rejected nested recovery preserves the directory'
    Remove-Item -LiteralPath $nestedResidue -Force
    $orphanPreview = Remove-HardnessWorkspace -WorktreeRoot $worktreeRoot -RepositoryRoot $parentRoot -DiscardIgnoredFiles -WhatIf
    Assert-True (-not $orphanPreview.Removed) 'empty-root recovery WhatIf does not remove the directory'
    Assert-True (Test-Path -LiteralPath $worktreeRoot -PathType Container) 'empty-root recovery WhatIf preserves the directory'
    $orphanRecovery = Remove-HardnessWorkspace -WorktreeRoot $worktreeRoot -RepositoryRoot $parentRoot -DiscardIgnoredFiles
    Assert-True $orphanRecovery.Removed 'explicit recovery removes an empty unregistered worktree root'
    Assert-True $orphanRecovery.BranchPreserved 'empty-root recovery never deletes the preserved branch'
}
finally {
    Remove-Module Workspace -Force -ErrorAction SilentlyContinue
    if (Test-Path -LiteralPath $fixtureRoot) {
        Remove-Item -LiteralPath $fixtureRoot -Recurse -Force
    }
}

[void](& (Join-Path $PSScriptRoot 'Workspace.Safety.Tests.ps1'))
Write-Output 'Workspace.Tests.ps1: PASS'
