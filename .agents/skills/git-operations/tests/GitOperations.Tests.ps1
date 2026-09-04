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
    [void](Invoke-TestGit -Repository $Path -Arguments @('config', 'user.name', 'Harness Git Fixture'))
    [void](Invoke-TestGit -Repository $Path -Arguments @('config', 'user.email', 'harness-git@example.invalid'))
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

$commitCommand = Get-Command Complete-HarnessGitCommit
Assert-True ('WorkspaceRoot' -in @($commitCommand.Parameters.Keys)) 'commit requires an exact WorkspaceRoot'
Assert-True ('PreserveOutsideStaged' -in @($commitCommand.Parameters.Keys)) 'commit exposes explicit outside-staged preservation'
$mergeCommand = Get-Command Merge-HarnessGitWorkspace
Assert-True ('SourceWorkspaceRoot' -in @($mergeCommand.Parameters.Keys)) 'integration requires an exact source workspace root'
$exportedCommands = @((Get-Command -Module GitOperations).Name | Sort-Object)
Assert-Equal 'Complete-HarnessGitCommit,Get-HarnessGitStatus,Merge-HarnessGitWorkspace,Publish-HarnessGitBranches' ($exportedCommands -join ',') 'the module exports only the unified Git operation surface'

$fixtureRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("harness-git-{0}" -f [guid]::NewGuid().ToString('N'))
$childRoot = Join-Path $fixtureRoot 'child-source'
$childRemote = Join-Path $fixtureRoot 'child-remote.git'
$parentRoot = Join-Path $fixtureRoot 'parent'
$parentRemote = Join-Path $fixtureRoot 'parent-remote.git'

try {
    [void](New-Item -ItemType Directory -Path $fixtureRoot -Force)

    $hookIsolationRoot = Join-Path $fixtureRoot 'hook-isolation-outside-success'
    Initialize-TestRepository -Path $hookIsolationRoot
    [System.IO.File]::WriteAllText((Join-Path $hookIsolationRoot 'scoped.txt'), "scoped base`n")
    [System.IO.File]::WriteAllText((Join-Path $hookIsolationRoot 'outside.txt'), "outside base`n")
    [void](Invoke-TestGit -Repository $hookIsolationRoot -Arguments @('add', '--', 'scoped.txt', 'outside.txt'))
    [void](Invoke-TestGit -Repository $hookIsolationRoot -Arguments @('commit', '-m', 'hook isolation base'))
    [System.IO.File]::WriteAllText((Join-Path $hookIsolationRoot 'scoped.txt'), "scoped requested change`n")
    [System.IO.File]::WriteAllText((Join-Path $hookIsolationRoot 'outside.txt'), "outside must remain unstaged`n")
    $hookDirectory = Join-Path $hookIsolationRoot '.git\hooks'
    [System.IO.File]::WriteAllText((Join-Path $hookDirectory 'pre-commit'), "#!/bin/sh`ngit add -- outside.txt`nexit 0`n", [System.Text.UTF8Encoding]::new($false))
    $hookIsolationHead = Get-TestHead -Repository $hookIsolationRoot
    $hookIsolationIndexPath = ([string]((Invoke-TestGit -Repository $hookIsolationRoot -Arguments @('rev-parse', '--path-format=absolute', '--git-path', 'index')).Output | Select-Object -Last 1)).Trim()
    $hookIsolationIndexHash = (Get-FileHash -LiteralPath $hookIsolationIndexPath -Algorithm SHA256).Hash
    Assert-ThrowsMatch {
        Complete-HarnessGitCommit -WorkspaceRoot $hookIsolationRoot -RepositoryScopes @{ '.' = @('scoped.txt') } -CommitMessage 'hook-expanded candidate must fail' | Out-Null
    } 'hook|outside|scope' 'a hook-expanded candidate is rejected as a scoped commit'
    Assert-Equal $hookIsolationHead (Get-TestHead -Repository $hookIsolationRoot) 'hook-expanded candidate never advances the affected repository HEAD'
    Assert-Equal $hookIsolationIndexHash (Get-FileHash -LiteralPath $hookIsolationIndexPath -Algorithm SHA256).Hash 'hook-expanded candidate restores the complete live index byte-for-byte'
    Assert-Equal ' M outside.txt| M scoped.txt' (((Invoke-TestGit -Repository $hookIsolationRoot -Arguments @('status', '--short')).Output | Sort-Object) -join '|') 'hook isolation preserves the caller worktree and staged/unstaged shape'

    $failingHookRoot = Join-Path $fixtureRoot 'hook-isolation-outside-failure'
    Initialize-TestRepository -Path $failingHookRoot
    [System.IO.File]::WriteAllText((Join-Path $failingHookRoot 'scoped.txt'), "scoped base`n")
    [System.IO.File]::WriteAllText((Join-Path $failingHookRoot 'outside.txt'), "outside base`n")
    [void](Invoke-TestGit -Repository $failingHookRoot -Arguments @('add', '--', 'scoped.txt', 'outside.txt'))
    [void](Invoke-TestGit -Repository $failingHookRoot -Arguments @('commit', '-m', 'failing hook base'))
    [System.IO.File]::WriteAllText((Join-Path $failingHookRoot 'scoped.txt'), "scoped requested change`n")
    [System.IO.File]::WriteAllText((Join-Path $failingHookRoot 'outside.txt'), "outside must remain unstaged`n")
    [System.IO.File]::WriteAllText((Join-Path $failingHookRoot '.git\hooks\pre-commit'), "#!/bin/sh`ngit add -- outside.txt`nexit 1`n", [System.Text.UTF8Encoding]::new($false))
    $failingHookHead = Get-TestHead -Repository $failingHookRoot
    $failingHookIndexPath = ([string]((Invoke-TestGit -Repository $failingHookRoot -Arguments @('rev-parse', '--path-format=absolute', '--git-path', 'index')).Output | Select-Object -Last 1)).Trim()
    $failingHookIndexHash = (Get-FileHash -LiteralPath $failingHookIndexPath -Algorithm SHA256).Hash
    Assert-ThrowsMatch {
        Complete-HarnessGitCommit -WorkspaceRoot $failingHookRoot -RepositoryScopes @{ '.' = @('scoped.txt') } -CommitMessage 'failing hook candidate must restore' | Out-Null
    } 'hook|exit|failed' 'a failing hook reports failure through scoped commit isolation'
    Assert-Equal $failingHookHead (Get-TestHead -Repository $failingHookRoot) 'a failing hook leaves HEAD unchanged'
    Assert-Equal $failingHookIndexHash (Get-FileHash -LiteralPath $failingHookIndexPath -Algorithm SHA256).Hash 'a failing hook restores the complete live index byte-for-byte'

    $messageHookRoot = Join-Path $fixtureRoot 'hook-isolation-commit-message'
    Initialize-TestRepository -Path $messageHookRoot
    [System.IO.File]::WriteAllText((Join-Path $messageHookRoot 'scoped.txt'), "scoped base`n")
    [System.IO.File]::WriteAllText((Join-Path $messageHookRoot 'outside.txt'), "outside base`n")
    [void](Invoke-TestGit -Repository $messageHookRoot -Arguments @('add', '--', 'scoped.txt', 'outside.txt'))
    [void](Invoke-TestGit -Repository $messageHookRoot -Arguments @('commit', '-m', 'message hook base'))
    [System.IO.File]::WriteAllText((Join-Path $messageHookRoot 'scoped.txt'), "scoped requested change`n")
    [System.IO.File]::WriteAllText((Join-Path $messageHookRoot 'outside.txt'), "outside must remain unstaged`n")
    [System.IO.File]::WriteAllText((Join-Path $messageHookRoot '.git\hooks\commit-msg'), "#!/bin/sh`ngit add -- outside.txt`nexit 0`n", [System.Text.UTF8Encoding]::new($false))
    $messageHookHead = Get-TestHead -Repository $messageHookRoot
    $messageHookIndexPath = ([string]((Invoke-TestGit -Repository $messageHookRoot -Arguments @('rev-parse', '--path-format=absolute', '--git-path', 'index')).Output | Select-Object -Last 1)).Trim()
    $messageHookIndexHash = (Get-FileHash -LiteralPath $messageHookIndexPath -Algorithm SHA256).Hash
    Assert-ThrowsMatch {
        Complete-HarnessGitCommit -WorkspaceRoot $messageHookRoot -RepositoryScopes @{ '.' = @('scoped.txt') } -CommitMessage 'message hook candidate must fail' | Out-Null
    } 'hook|outside|scope' 'a commit-message hook cannot stage an outside path into the live index'
    Assert-Equal $messageHookHead (Get-TestHead -Repository $messageHookRoot) 'an outside-staging commit-message hook leaves HEAD unchanged'
    Assert-Equal $messageHookIndexHash (Get-FileHash -LiteralPath $messageHookIndexPath -Algorithm SHA256).Hash 'an outside-staging commit-message hook leaves the live index byte-for-byte unchanged'

    $intentHookRoot = Join-Path $fixtureRoot 'hook-isolation-intent-to-add'
    Initialize-TestRepository -Path $intentHookRoot
    [System.IO.File]::WriteAllText((Join-Path $intentHookRoot 'scoped.txt'), "scoped base`n")
    [void](Invoke-TestGit -Repository $intentHookRoot -Arguments @('add', '--', 'scoped.txt'))
    [void](Invoke-TestGit -Repository $intentHookRoot -Arguments @('commit', '-m', 'intent hook base'))
    [System.IO.File]::WriteAllText((Join-Path $intentHookRoot 'scoped.txt'), "scoped requested change`n")
    [System.IO.File]::WriteAllText((Join-Path $intentHookRoot 'outside-new.txt'), "outside remains untracked`n")
    [System.IO.File]::WriteAllText((Join-Path $intentHookRoot '.git\hooks\pre-commit'), "#!/bin/sh`ngit add -N -- outside-new.txt`nexit 0`n", [System.Text.UTF8Encoding]::new($false))
    $intentHookHead = Get-TestHead -Repository $intentHookRoot
    $intentHookIndexPath = ([string]((Invoke-TestGit -Repository $intentHookRoot -Arguments @('rev-parse', '--path-format=absolute', '--git-path', 'index')).Output | Select-Object -Last 1)).Trim()
    $intentHookIndexHash = (Get-FileHash -LiteralPath $intentHookIndexPath -Algorithm SHA256).Hash
    Assert-ThrowsMatch {
        Complete-HarnessGitCommit -WorkspaceRoot $intentHookRoot -RepositoryScopes @{ '.' = @('scoped.txt') } -CommitMessage 'intent hook candidate must fail' | Out-Null
    } 'intent-to-add|hook|outside' 'a hook-created outside intent-to-add entry is rejected'
    Assert-Equal $intentHookHead (Get-TestHead -Repository $intentHookRoot) 'outside intent-to-add never advances HEAD'
    Assert-Equal $intentHookIndexHash (Get-FileHash -LiteralPath $intentHookIndexPath -Algorithm SHA256).Hash 'outside intent-to-add never changes the live index'
    Assert-Equal ' M scoped.txt|?? outside-new.txt' (((Invoke-TestGit -Repository $intentHookRoot -Arguments @('status', '--short')).Output | Sort-Object) -join '|') 'outside intent-to-add cleanup preserves the caller worktree shape'

    $positiveHookRoot = Join-Path $fixtureRoot 'hook-isolation-scope-local'
    Initialize-TestRepository -Path $positiveHookRoot
    [System.IO.File]::WriteAllText((Join-Path $positiveHookRoot 'scoped.txt'), "scoped base`n")
    [System.IO.File]::WriteAllText((Join-Path $positiveHookRoot 'outside.txt'), "outside base`n")
    [void](Invoke-TestGit -Repository $positiveHookRoot -Arguments @('add', '--', 'scoped.txt', 'outside.txt'))
    [void](Invoke-TestGit -Repository $positiveHookRoot -Arguments @('commit', '-m', 'positive hook base'))
    [System.IO.File]::WriteAllText((Join-Path $positiveHookRoot 'scoped.txt'), "unformatted requested change`n")
    [System.IO.File]::WriteAllText((Join-Path $positiveHookRoot 'outside.txt'), "outside remains unstaged`n")
    [System.IO.File]::WriteAllText((Join-Path $positiveHookRoot '.git\hooks\pre-commit'), "#!/bin/sh`nprintf 'formatted by hook\n' > scoped.txt`ngit add -- scoped.txt`nexit 0`n", [System.Text.UTF8Encoding]::new($false))
    [System.IO.File]::WriteAllText((Join-Path $positiveHookRoot '.git\hooks\commit-msg'), @'
#!/bin/sh
printf '\nHooked-Message\n' >> "$1"
exit 0
'@, [System.Text.UTF8Encoding]::new($false))
    $positiveHookCommit = Complete-HarnessGitCommit -WorkspaceRoot $positiveHookRoot -RepositoryScopes @{ '.' = @('scoped.txt') } -CommitMessage 'scope-local hook commit'
    Assert-Equal 1 @($positiveHookCommit.Commits).Count 'scope-local hooks retain a successful exact commit'
    Assert-Equal 'formatted by hook' ([string]((Invoke-TestGit -Repository $positiveHookRoot -Arguments @('show', 'HEAD:scoped.txt')).Output -join "`n")).Trim() 'the commit retains scope-local pre-commit formatting'
    Assert-True (((Invoke-TestGit -Repository $positiveHookRoot -Arguments @('log', '-1', '--pretty=%B')).Output -join "`n") -match 'Hooked-Message') 'the commit retains commit-message hook output'
    Assert-Equal ' M outside.txt' (((Invoke-TestGit -Repository $positiveHookRoot -Arguments @('status', '--short')).Output | Sort-Object) -join '|') 'scope-local hooks leave outside work unstaged and unchanged'

    Initialize-TestRepository -Path $childRoot
    [System.IO.File]::WriteAllText((Join-Path $childRoot 'child.txt'), "child base`n")
    [void](Invoke-TestGit -Repository $childRoot -Arguments @('add', 'child.txt'))
    [void](Invoke-TestGit -Repository $childRoot -Arguments @('commit', '-m', 'child base'))
    & git init --bare --initial-branch=main $childRemote 2>&1 | Out-Null
    if ($LASTEXITCODE -ne 0) { throw 'Unable to create child bare remote.' }
    [void](Invoke-TestGit -Repository $childRoot -Arguments @('remote', 'add', 'origin', $childRemote))
    [void](Invoke-TestGit -Repository $childRoot -Arguments @('push', '-u', 'origin', 'main'))

    Initialize-TestRepository -Path $parentRoot
    [System.IO.File]::WriteAllText((Join-Path $parentRoot '.gitignore'), ".worktrees/`nignored-local.txt`n")
    [System.IO.File]::WriteAllText((Join-Path $parentRoot 'README.md'), "parent base`n")
    [void](Invoke-TestGit -Repository $parentRoot -Arguments @('add', '.gitignore', 'README.md'))
    [void](Invoke-TestGit -Repository $parentRoot -Arguments @('commit', '-m', 'parent base'))
    [void](Invoke-TestGit -Repository $parentRoot -Arguments @('-c', 'protocol.file.allow=always', 'submodule', 'add', '--name', 'sdk', $childRemote, 'Modules/Child'))
    [void](Invoke-TestGit -Repository $parentRoot -Arguments @('commit', '-am', 'add child'))
    & git init --bare --initial-branch=main $parentRemote 2>&1 | Out-Null
    if ($LASTEXITCODE -ne 0) { throw 'Unable to create parent bare remote.' }
    [void](Invoke-TestGit -Repository $parentRoot -Arguments @('remote', 'add', 'origin', $parentRemote))
    [void](Invoke-TestGit -Repository $parentRoot -Arguments @('push', '-u', 'origin', 'main'))

    $nestedRoot = Join-Path $parentRoot 'nested'
    [void](New-Item -ItemType Directory -Path $nestedRoot)
    Assert-ThrowsMatch {
        Get-HarnessGitStatus -WorkspaceRoot $nestedRoot | Out-Null
    } 'exact Git worktree root|WorkspaceRoot' 'public Git operations reject an enclosing-workspace child path'
    Remove-Item -LiteralPath $nestedRoot

    [System.IO.File]::WriteAllText((Join-Path $parentRoot 'scoped.txt'), "commit only this path`n")
    [System.IO.File]::WriteAllText((Join-Path $parentRoot 'literal[1].txt'), "literal pathspec content`n")
    [System.IO.File]::WriteAllText((Join-Path $parentRoot 'literal1.txt'), "must not match bracket pathspec`n")
    [System.IO.File]::WriteAllText((Join-Path $parentRoot 'unrelated.txt'), "preserve this path`n")
    [void](Invoke-TestGit -Repository $parentRoot -Arguments @('add', 'unrelated.txt'))
    $primaryHeadBefore = Get-TestHead -Repository $parentRoot
    $primaryOutsideIndexBefore = ((Invoke-TestGit -Repository $parentRoot -Arguments @('ls-files', '--stage', '--', 'unrelated.txt')).Output -join "`n")
    Assert-ThrowsMatch {
        Complete-HarnessGitCommit -WorkspaceRoot $parentRoot -RepositoryScopes @{ '.' = @('scoped.txt', 'literal[1].txt') } -CommitMessage 'scoped primary commit' | Out-Null
    } 'staged paths outside|unrelated' 'Primary scoped commit rejects unrelated pre-staged content'
    Assert-Equal $primaryHeadBefore (Get-TestHead -Repository $parentRoot) 'default outside-staged rejection preserves primary HEAD'
    Assert-Equal $primaryOutsideIndexBefore ((Invoke-TestGit -Repository $parentRoot -Arguments @('ls-files', '--stage', '--', 'unrelated.txt')).Output -join "`n") 'default outside-staged rejection preserves the outside index entry'

    $primaryPreview = Complete-HarnessGitCommit -WorkspaceRoot $parentRoot -RepositoryScopes @{ '.' = @('scoped.txt', 'literal[1].txt') } -CommitMessage 'scoped primary preview' -PreserveOutsideStaged -WhatIf
    Assert-True $primaryPreview.Preview 'preserving outside staged content supports a non-mutating preview'
    Assert-True $primaryPreview.PreserveOutsideStaged 'preview reports the explicit preservation mode'
    Assert-Equal 1 @($primaryPreview.PreservedStaged).Count 'preview inventories the repository with outside staged content'
    Assert-Equal 'Pending' $primaryPreview.PreservedStaged[0].Validation 'preview does not claim an unexecuted preservation postcondition'
    Assert-Equal $primaryHeadBefore (Get-TestHead -Repository $parentRoot) 'preservation preview does not change primary HEAD'
    Assert-Equal $primaryOutsideIndexBefore ((Invoke-TestGit -Repository $parentRoot -Arguments @('ls-files', '--stage', '--', 'unrelated.txt')).Output -join "`n") 'preservation preview does not change the outside index entry'

    $currentCommit = Complete-HarnessGitCommit -WorkspaceRoot $parentRoot -RepositoryScopes @{ '.' = @('scoped.txt', 'literal[1].txt') } -CommitMessage 'scoped primary commit' -PreserveOutsideStaged
    Assert-Equal 1 @($currentCommit.Commits).Count 'Primary scoped preservation creates one parent commit'
    Assert-True $currentCommit.PreserveOutsideStaged 'actual result reports the explicit preservation mode'
    Assert-Equal 'Preserved' $currentCommit.PreservedStaged[0].Validation 'actual result proves the outside staged snapshot was preserved'
    Assert-Equal $currentCommit.PreservedStaged[0].BeforeSha256 $currentCommit.PreservedStaged[0].AfterSha256 'outside staged fingerprint is identical before and after commit'
    Assert-Equal $primaryOutsideIndexBefore ((Invoke-TestGit -Repository $parentRoot -Arguments @('ls-files', '--stage', '--', 'unrelated.txt')).Output -join "`n") 'path-only primary commit preserves the exact outside index entry'
    Assert-Equal 'literal[1].txt,scoped.txt' (((Invoke-TestGit -Repository $parentRoot -Arguments @('diff-tree', '--no-commit-id', '--name-only', '-r', 'HEAD^', 'HEAD')).Output | Where-Object { $_ } | Sort-Object) -join ',') 'path-only primary commit contains only literal requested paths'
    Assert-True (((Invoke-TestGit -Repository $parentRoot -Arguments @('status', '--short', '--', 'literal1.txt')).Output -join "`n") -match '^\?\?') 'literal pathspec never expands to an adjacent matching name'
    Assert-True (-not $currentCommit.GitStateComplete) 'outside staged content keeps aggregate Git state incomplete'
    Assert-True $currentCommit.ScopedGitStateComplete 'the requested primary scope is complete after path-only commit'

    $noScopedHead = Get-TestHead -Repository $parentRoot
    $noScopedResult = Complete-HarnessGitCommit -WorkspaceRoot $parentRoot -RepositoryScopes @{ '.' = @('README.md') } -CommitMessage 'must not commit outside staged content' -PreserveOutsideStaged
    Assert-Equal 0 @($noScopedResult.Commits).Count 'outside staged content alone never creates a scoped commit'
    Assert-Equal $noScopedHead (Get-TestHead -Repository $parentRoot) 'outside staged content alone preserves HEAD'
    Assert-Equal $primaryOutsideIndexBefore ((Invoke-TestGit -Repository $parentRoot -Arguments @('ls-files', '--stage', '--', 'unrelated.txt')).Output -join "`n") 'outside staged content alone preserves the index entry'
    [void](Invoke-TestGit -Repository $parentRoot -Arguments @('restore', '--staged', 'unrelated.txt'))
    [System.IO.File]::Delete((Join-Path $parentRoot 'literal1.txt'))

    [System.IO.File]::WriteAllText((Join-Path $parentRoot '.hidden-scope.txt'), "hidden staged path`n")
    [System.IO.File]::WriteAllText((Join-Path $parentRoot 'hidden-scope.txt'), "different visible path`n")
    [void](Invoke-TestGit -Repository $parentRoot -Arguments @('add', '.hidden-scope.txt'))
    Assert-ThrowsMatch {
        Complete-HarnessGitCommit -WorkspaceRoot $parentRoot -RepositoryScopes @{ '.' = @('hidden-scope.txt') } -CommitMessage 'must not alias dotfile scope' | Out-Null
    } 'staged paths outside|hidden-scope' 'Primary scoped commit never aliases a leading-dot path to a visible path'
    [void](Invoke-TestGit -Repository $parentRoot -Arguments @('restore', '--staged', '.hidden-scope.txt'))
    [System.IO.File]::Delete((Join-Path $parentRoot '.hidden-scope.txt'))
    [System.IO.File]::Delete((Join-Path $parentRoot 'hidden-scope.txt'))

    Assert-True (Test-Path -LiteralPath (Join-Path $parentRoot 'unrelated.txt') -PathType Leaf) 'Primary scoped commit preserves unrelated untracked content'
    Assert-True (((Invoke-TestGit -Repository $parentRoot -Arguments @('status', '--short', '--', 'unrelated.txt')).Output -join "`n") -match '^\?\?') 'unrelated path remains untracked after scoped commit'
    [System.IO.File]::Delete((Join-Path $parentRoot 'unrelated.txt'))

    [System.IO.File]::WriteAllText((Join-Path $parentRoot 'outside-ita.txt'), "intent to add outside scope`n")
    [void](Invoke-TestGit -Repository $parentRoot -Arguments @('add', '--intent-to-add', '--', 'outside-ita.txt'))
    Assert-ThrowsMatch {
        Complete-HarnessGitCommit -WorkspaceRoot $parentRoot -RepositoryScopes @{ '.' = @('README.md') } -CommitMessage 'reject outside intent to add' -PreserveOutsideStaged | Out-Null
    } 'intent-to-add|outside-ita' 'preservation rejects an outside intent-to-add entry before mutation'
    [void](Invoke-TestGit -Repository $parentRoot -Arguments @('reset', '--', 'outside-ita.txt'))
    [System.IO.File]::Delete((Join-Path $parentRoot 'outside-ita.txt'))

    Assert-ThrowsMatch {
        Complete-HarnessGitCommit -WorkspaceRoot $parentRoot -RepositoryScopes @{ '.' = @('README.md') } -AllChanges -CommitMessage 'ambiguous preservation mode' -PreserveOutsideStaged -WhatIf | Out-Null
    } 'PreserveOutsideStaged|AllChanges' 'preservation requires exact RepositoryScopes and rejects AllChanges'

    [System.IO.File]::WriteAllText((Join-Path $parentRoot 'rename-source.txt'), "rename boundary fixture`n")
    [void](Invoke-TestGit -Repository $parentRoot -Arguments @('add', 'rename-source.txt'))
    [void](Invoke-TestGit -Repository $parentRoot -Arguments @('commit', '-m', 'add rename boundary fixture'))
    [System.IO.File]::Move((Join-Path $parentRoot 'rename-source.txt'), (Join-Path $parentRoot 'rename-target.txt'))
    [void](Invoke-TestGit -Repository $parentRoot -Arguments @('add', '-A', '--', 'rename-source.txt', 'rename-target.txt'))
    $renameBoundaryHead = Get-TestHead -Repository $parentRoot
    Assert-ThrowsMatch {
        Complete-HarnessGitCommit -WorkspaceRoot $parentRoot -RepositoryScopes @{ '.' = @('rename-target.txt') } -CommitMessage 'must reject cross-scope rename' -PreserveOutsideStaged | Out-Null
    } 'rename/copy crossing|rename-source.*rename-target' 'preservation rejects a staged rename crossing the exact scope before mutation'
    Assert-Equal $renameBoundaryHead (Get-TestHead -Repository $parentRoot) 'cross-scope rename rejection preserves HEAD'
    [void](Invoke-TestGit -Repository $parentRoot -Arguments @('restore', '--source=HEAD', '--staged', '--worktree', '--', 'rename-source.txt', 'rename-target.txt'))
    [System.IO.File]::Copy((Join-Path $parentRoot 'rename-source.txt'), (Join-Path $parentRoot 'copy-target.txt'))
    [void](Invoke-TestGit -Repository $parentRoot -Arguments @('add', '--', 'copy-target.txt'))
    Assert-ThrowsMatch {
        Complete-HarnessGitCommit -WorkspaceRoot $parentRoot -RepositoryScopes @{ '.' = @('copy-target.txt') } -CommitMessage 'must reject cross-scope copy' -PreserveOutsideStaged | Out-Null
    } 'rename/copy crossing|rename-source.*copy-target' 'preservation rejects a staged copy crossing the exact scope before mutation'
    [void](Invoke-TestGit -Repository $parentRoot -Arguments @('restore', '--staged', '--', 'copy-target.txt'))
    [System.IO.File]::Delete((Join-Path $parentRoot 'copy-target.txt'))

    $unmergedRoot = Join-Path $fixtureRoot 'unmerged'
    Initialize-TestRepository -Path $unmergedRoot
    [System.IO.File]::WriteAllText((Join-Path $unmergedRoot 'conflict.txt'), "base`n")
    [void](Invoke-TestGit -Repository $unmergedRoot -Arguments @('add', 'conflict.txt'))
    [void](Invoke-TestGit -Repository $unmergedRoot -Arguments @('commit', '-m', 'unmerged base'))
    [void](Invoke-TestGit -Repository $unmergedRoot -Arguments @('checkout', '-b', 'unmerged-side'))
    [System.IO.File]::WriteAllText((Join-Path $unmergedRoot 'conflict.txt'), "side`n")
    [void](Invoke-TestGit -Repository $unmergedRoot -Arguments @('commit', '-am', 'unmerged side'))
    [void](Invoke-TestGit -Repository $unmergedRoot -Arguments @('checkout', 'main'))
    [System.IO.File]::WriteAllText((Join-Path $unmergedRoot 'conflict.txt'), "main`n")
    [void](Invoke-TestGit -Repository $unmergedRoot -Arguments @('commit', '-am', 'unmerged main'))
    $mergeConflict = Invoke-TestGit -Repository $unmergedRoot -Arguments @('merge', 'unmerged-side') -AllowFailure
    Assert-True ($mergeConflict.ExitCode -ne 0) 'unmerged fixture produces an actual merge conflict'
    $unmergedHead = Get-TestHead -Repository $unmergedRoot
    Assert-ThrowsMatch {
        Complete-HarnessGitCommit -WorkspaceRoot $unmergedRoot -RepositoryScopes @{ '.' = @('conflict.txt') } -CommitMessage 'must reject unmerged index' -PreserveOutsideStaged | Out-Null
    } 'unmerged index paths|conflict.txt' 'preservation rejects an unmerged index during global preflight'
    Assert-Equal $unmergedHead (Get-TestHead -Repository $unmergedRoot) 'unmerged preflight rejection preserves HEAD'

    $baseParentRemote = Get-TestHead -Repository $parentRoot -Revision 'refs/remotes/origin/main'
    $baseChildRemote = Get-TestHead -Repository (Join-Path $parentRoot 'Modules/Child') -Revision 'refs/remotes/origin/main'
    $worktreeRoot = Join-Path $fixtureRoot 'linked-integration-fixture'
    [void](Invoke-TestGit -Repository $parentRoot -Arguments @('worktree', 'add', '-b', 'integration-fixture', $worktreeRoot, 'HEAD'))
    [void](Invoke-TestGit -Repository $worktreeRoot -Arguments @('-c', 'protocol.file.allow=always', 'submodule', 'update', '--init', '--checkout'))
    $linkedChild = Join-Path $worktreeRoot 'Modules/Child'

    Assert-ThrowsMatch {
        Complete-HarnessGitCommit -WorkspaceRoot $parentRoot -AllChanges -CommitMessage 'primary all changes must fail' -WhatIf | Out-Null
    } 'registered linked worktree|AllChanges' 'AllChanges is reserved for an exact registered linked worktree'

    $targetChild = Join-Path $parentRoot 'Modules/Child'
    [System.IO.File]::WriteAllText((Join-Path $targetChild 'target-only.txt'), "target branch child work`n")
    [void](Invoke-TestGit -Repository $targetChild -Arguments @('add', 'target-only.txt'))
    [void](Invoke-TestGit -Repository $targetChild -Arguments @('commit', '-m', 'target child divergence'))
    [void](Invoke-TestGit -Repository $parentRoot -Arguments @('add', 'Modules/Child'))
    [void](Invoke-TestGit -Repository $parentRoot -Arguments @('commit', '-m', 'record target child divergence'))

    [System.IO.File]::AppendAllText((Join-Path $linkedChild 'child.txt'), "linked child`n")
    [System.IO.File]::WriteAllText((Join-Path $worktreeRoot 'workspace.txt'), "linked parent`n")
    [System.IO.File]::WriteAllText((Join-Path $worktreeRoot 'ignored-local.txt'), "ignored local state`n")
    $status = Get-HarnessGitStatus -WorkspaceRoot $worktreeRoot
    Assert-True $status.Dirty 'status aggregates parent and initialized submodule changes'
    Assert-Equal 2 @($status.Repositories).Count 'status reports the parent and top-level submodule independently'

    $previewChildHead = Get-TestHead -Repository $linkedChild
    Assert-ThrowsMatch {
        Complete-HarnessGitCommit -WorkspaceRoot $worktreeRoot -AllChanges -CommitMessage 'detached submodule requires branch' -WhatIf | Out-Null
    } 'TargetBranches|Detached scoped repository' 'a detached dirty submodule requires an explicit actual target branch'
    $commitBranches = @{ 'Modules/Child' = 'integration-fixture' }
    $commitPreview = Complete-HarnessGitCommit -WorkspaceRoot $worktreeRoot -AllChanges -CommitMessage 'linked parent preview' -SubmoduleCommitMessages @{ 'Modules/Child' = 'linked child preview' } -TargetBranches $commitBranches -WhatIf
    Assert-True $commitPreview.Preview 'Linked-worktree commit preview reports preview mode'
    Assert-True (-not $commitPreview.ScopedGitStateComplete) 'Linked-worktree commit preview does not claim dirty scoped state is complete'
    Assert-Equal 0 @($commitPreview.Commits).Count 'Linked-worktree commit preview creates no commits'
    Assert-True (@($commitPreview.IncludedChanges | Where-Object { $_.Repository -eq '.' -and 'workspace.txt' -in @($_.Paths) }).Count -eq 1) 'AllChanges preview lists parent paths'
    Assert-True (@($commitPreview.IncludedChanges | Where-Object { $_.Repository -eq 'Modules/Child' -and 'child.txt' -in @($_.Paths) }).Count -eq 1) 'AllChanges preview lists submodule paths'
    Assert-True (@($commitPreview.IncludedChanges.Paths) -notcontains 'ignored-local.txt') 'AllChanges preview excludes ignored paths'
    Assert-Equal $previewChildHead (Get-TestHead -Repository $linkedChild) 'Linked-worktree commit preview preserves the detached submodule HEAD'
    Assert-Equal 1 (Invoke-TestGit -Repository $linkedChild -Arguments @('show-ref', '--verify', '--quiet', 'refs/heads/integration-fixture') -AllowFailure).ExitCode 'Linked-worktree commit preview creates no submodule branch'

    [System.IO.File]::WriteAllText((Join-Path $worktreeRoot 'parent-outside.txt'), "preserve parent staged state`n")
    [System.IO.File]::WriteAllText((Join-Path $linkedChild 'child-outside.txt'), "preserve child staged state`n")
    [void](Invoke-TestGit -Repository $worktreeRoot -Arguments @('add', 'parent-outside.txt'))
    [void](Invoke-TestGit -Repository $linkedChild -Arguments @('add', 'child-outside.txt'))
    $parentOutsideBefore = ((Invoke-TestGit -Repository $worktreeRoot -Arguments @('ls-files', '--stage', '--', 'parent-outside.txt')).Output -join "`n")
    $childOutsideBefore = ((Invoke-TestGit -Repository $linkedChild -Arguments @('ls-files', '--stage', '--', 'child-outside.txt')).Output -join "`n")
    $preservedMultiRepositoryCommit = Complete-HarnessGitCommit -WorkspaceRoot $worktreeRoot -RepositoryScopes @{
        '.' = @('workspace.txt')
        'Modules/Child' = @('child.txt')
    } -CommitMessage 'linked parent scoped preservation' -SubmoduleCommitMessages @{ 'Modules/Child' = 'linked child scoped preservation' } -TargetBranches $commitBranches -PreserveOutsideStaged
    Assert-Equal 2 @($preservedMultiRepositoryCommit.Commits).Count 'scoped preservation commits the dirty child and parent'
    Assert-Equal 'Modules/Child' $preservedMultiRepositoryCommit.Commits[0].Repository 'scoped preservation commits the child before the parent'
    Assert-Equal '.' $preservedMultiRepositoryCommit.Commits[1].Repository 'scoped preservation commits the parent after the child'
    Assert-Equal 2 @($preservedMultiRepositoryCommit.PreservedStaged).Count 'scoped preservation proves outside staged state in both repositories'
    Assert-True (@($preservedMultiRepositoryCommit.PreservedStaged | Where-Object Validation -ne 'Preserved').Count -eq 0) 'every multi-repository outside staged snapshot is preserved'
    Assert-Equal $parentOutsideBefore ((Invoke-TestGit -Repository $worktreeRoot -Arguments @('ls-files', '--stage', '--', 'parent-outside.txt')).Output -join "`n") 'parent outside index entry remains exact'
    Assert-Equal $childOutsideBefore ((Invoke-TestGit -Repository $linkedChild -Arguments @('ls-files', '--stage', '--', 'child-outside.txt')).Output -join "`n") 'child outside index entry remains exact'
    Assert-Equal (Get-TestHead -Repository $linkedChild) (Get-TestHead -Repository $worktreeRoot -Revision 'HEAD:Modules/Child') 'scoped parent commit records the newly committed child gitlink'
    [void](Invoke-TestGit -Repository $worktreeRoot -Arguments @('restore', '--staged', 'parent-outside.txt'))
    [void](Invoke-TestGit -Repository $linkedChild -Arguments @('restore', '--staged', 'child-outside.txt'))
    [System.IO.File]::Delete((Join-Path $worktreeRoot 'parent-outside.txt'))
    [System.IO.File]::Delete((Join-Path $linkedChild 'child-outside.txt'))

    [System.IO.File]::AppendAllText((Join-Path $linkedChild 'child.txt'), "linked child all changes`n")
    [System.IO.File]::AppendAllText((Join-Path $worktreeRoot 'workspace.txt'), "linked parent all changes`n")

    $commit = Complete-HarnessGitCommit -WorkspaceRoot $worktreeRoot -AllChanges -CommitMessage 'linked parent result' -SubmoduleCommitMessages @{ 'Modules/Child' = 'linked child result' } -TargetBranches $commitBranches
    Assert-True (-not $commit.Preview) 'actual linked-worktree commit is not reported as a preview'
    Assert-Equal 'Modules/Child' $commit.Commits[0].Repository 'Linked-worktree commit records submodules before the parent'
    Assert-Equal 'integration-fixture' $commit.Commits[0].Branch 'detached submodule commit uses the explicitly selected actual branch'
    Assert-Equal '.' $commit.Commits[-1].Repository 'Linked-worktree commit records the parent last'
    Assert-Equal 'integration-fixture' $commit.Commits[-1].Branch 'linked parent commit keeps its actual branch without a required prefix'
    Assert-True $commit.GitStateComplete 'Linked-worktree commit leaves non-ignored repositories clean'
    $sourceHead = Get-TestHead -Repository $worktreeRoot
    $sourceChildHead = Get-TestHead -Repository $linkedChild
    Assert-Equal $sourceChildHead (Get-TestHead -Repository $worktreeRoot -Revision 'HEAD:Modules/Child') 'parent gitlink records the committed linked-worktree submodule'
    Assert-Equal $baseParentRemote (Get-TestHead -Repository $parentRoot -Revision 'refs/remotes/origin/main') 'commit does not publish the parent branch'
    Assert-Equal $baseChildRemote (Get-TestHead -Repository (Join-Path $parentRoot 'Modules/Child') -Revision 'refs/remotes/origin/main') 'commit does not publish the submodule branch'

    [System.IO.File]::WriteAllText((Join-Path $parentRoot 'local-note.txt'), "unrelated local primary work`n")
    $targets = @{ '.' = 'main'; 'Modules/Child' = 'main' }
    $preview = Merge-HarnessGitWorkspace -WorkspaceRoot $parentRoot -SourceWorkspaceRoot $worktreeRoot -ExpectedSourceHead $sourceHead -TargetBranches $targets -WhatIf
    Assert-True $preview.Preview 'integration supports a non-mutating reviewed preview'
    Assert-True (-not $preview.Integrated) 'preview does not claim integration'
    Assert-True (@($preview.Plans | Where-Object { [string]::IsNullOrWhiteSpace($_.SourceRoot) }).Count -eq 0) 'preview reports an exact source root for every repository plan'
    Assert-Equal 'Merge' (@($preview.Plans | Where-Object Repository -eq 'Modules/Child')[0].Action) 'preview detects divergent submodule history'
    Assert-ThrowsMatch {
        Merge-HarnessGitWorkspace -WorkspaceRoot $parentRoot -SourceWorkspaceRoot $worktreeRoot -ExpectedSourceHead ('0' * 40) -TargetBranches $targets -WhatIf | Out-Null
    } 'ExpectedSourceHead|does not match|source HEAD' 'integration is pinned to the reviewed source snapshot'
    Assert-ThrowsMatch {
        Merge-HarnessGitWorkspace -WorkspaceRoot $parentRoot -SourceWorkspaceRoot $childRoot -ExpectedSourceHead (Get-TestHead $childRoot) -TargetBranches @{ '.' = 'main' } -WhatIf | Out-Null
    } 'registered linked|common' 'integration rejects a source outside the target Git common directory'
    Assert-ThrowsMatch {
        Merge-HarnessGitWorkspace -WorkspaceRoot $worktreeRoot -SourceWorkspaceRoot $parentRoot -ExpectedSourceHead (Get-TestHead $parentRoot) -TargetBranches @{ '.' = 'integration-fixture' } -WhatIf | Out-Null
    } 'canonical primary' 'integration requires the canonical primary target'

    $integrated = Merge-HarnessGitWorkspace -WorkspaceRoot $parentRoot -SourceWorkspaceRoot $worktreeRoot -ExpectedSourceHead $sourceHead -TargetBranches $targets -CommitMessage 'integrate fixture workspace'
    Assert-True $integrated.Integrated 'explicit integration completes locally'
    Assert-True $integrated.SourcePreserved 'integration preserves the source workspace'
    Assert-True (Test-Path -LiteralPath (Join-Path $parentRoot 'local-note.txt') -PathType Leaf) 'non-overlapping primary work is preserved'
    Assert-Equal $sourceHead (Get-TestHead -Repository $worktreeRoot) 'integration does not rewrite the reviewed source'
    $parentLineage = @((Invoke-TestGit -Repository $parentRoot -Arguments @('rev-list', '--parents', '-n', '1', 'HEAD')).Output[0] -split '\s+')
    Assert-Equal 3 $parentLineage.Count 'parent integration preserves source history with a merge commit'
    $integratedChildHead = Get-TestHead -Repository (Join-Path $parentRoot 'Modules/Child')
    Assert-Equal $integratedChildHead (Get-TestHead -Repository $parentRoot -Revision 'HEAD:Modules/Child') 'parent integration records the final integrated submodule head'
    Assert-Equal 0 (Invoke-TestGit -Repository (Join-Path $parentRoot 'Modules/Child') -Arguments @('merge-base', '--is-ancestor', $sourceChildHead, $integratedChildHead) -AllowFailure).ExitCode 'integrated submodule contains the reviewed source commit'
    $childLineage = @((Invoke-TestGit -Repository (Join-Path $parentRoot 'Modules/Child') -Arguments @('rev-list', '--parents', '-n', '1', $integratedChildHead)).Output[0] -split '\s+')
    Assert-Equal 3 $childLineage.Count 'divergent submodule integration preserves both histories with a merge commit'
    Assert-Equal $baseParentRemote (Get-TestHead -Repository $parentRoot -Revision 'refs/remotes/origin/main') 'integration remains local until push is explicit'
    Assert-Equal $baseChildRemote (Get-TestHead -Repository (Join-Path $parentRoot 'Modules/Child') -Revision 'refs/remotes/origin/main') 'integration does not implicitly publish submodules'

    Assert-ThrowsMatch {
        Publish-HarnessGitBranches -WorkspaceRoot $parentRoot -RepositoryBranches @{ '.' = 'main' } -WhatIf | Out-Null
    } 'submodule|explicitly include|not known reachable' 'parent publication refuses an unpublished gitlink unless the submodule is explicit'
    $pushPreview = Publish-HarnessGitBranches -WorkspaceRoot $parentRoot -RepositoryBranches @{ '.' = 'main'; 'Modules\Child' = 'main' } -WhatIf
    Assert-True $pushPreview.Preview 'push has an explicit non-mutating preview'
    Assert-Equal 'Modules/Child' $pushPreview.Plans[0].Repository 'push orders submodules before the parent'
    Assert-Equal '.' $pushPreview.Plans[-1].Repository 'push orders the parent last'
    Assert-True (-not $pushPreview.Forced) 'push never uses force semantics'
    Assert-Equal $baseParentRemote (Get-TestHead -Repository $parentRoot -Revision 'refs/remotes/origin/main') 'push preview changes no parent remote ref'

    $push = Publish-HarnessGitBranches -WorkspaceRoot $parentRoot -RepositoryBranches @{ '.' = 'main'; 'Modules/Child' = 'main' }
    Assert-True $push.Pushed 'push occurs only through the explicit publish command'
    Assert-True (-not $push.Forced) 'actual push remains non-force'
    Assert-Equal (Get-TestHead -Repository $parentRoot) (Get-TestHead -Repository $parentRoot -Revision 'refs/remotes/origin/main') 'explicit push publishes the parent branch'
    Assert-Equal (Get-TestHead -Repository (Join-Path $parentRoot 'Modules/Child')) (Get-TestHead -Repository (Join-Path $parentRoot 'Modules/Child') -Revision 'refs/remotes/origin/main') 'explicit push publishes the submodule branch first'
    Assert-True (Test-Path -LiteralPath $worktreeRoot -PathType Container) 'commit, integration, and push never clean up the source workspace'

    $pushCommand = Get-Command Publish-HarnessGitBranches
    Assert-True ('Force' -notin @($pushCommand.Parameters.Keys)) 'the public push command exposes no force switch'

    $conflictRoot = Join-Path $fixtureRoot 'linked-conflict-fixture'
    [void](Invoke-TestGit -Repository $parentRoot -Arguments @('worktree', 'add', '-b', 'conflict-fixture', $conflictRoot, 'HEAD'))
    [void](Invoke-TestGit -Repository $conflictRoot -Arguments @('-c', 'protocol.file.allow=always', 'submodule', 'update', '--init', '--checkout'))
    $conflictChild = Join-Path $conflictRoot 'Modules/Child'
    [System.IO.File]::AppendAllText((Join-Path $conflictChild 'child.txt'), "conflict-source child`n")
    [System.IO.File]::WriteAllText((Join-Path $conflictRoot 'README.md'), "Source rewrites the same line`n")
    [void](Complete-HarnessGitCommit -WorkspaceRoot $conflictRoot -AllChanges -CommitMessage 'source conflict' -SubmoduleCommitMessages @{ 'Modules/Child' = 'source child before parent conflict' } -TargetBranches @{ 'Modules/Child' = 'conflict-fixture' })
    $conflictSourceHead = Get-TestHead -Repository $conflictRoot
    $conflictSourceChildHead = Get-TestHead -Repository $conflictChild
    [System.IO.File]::WriteAllText((Join-Path $parentRoot 'README.md'), "Primary rewrites the same line`n")
    [void](Invoke-TestGit -Repository $parentRoot -Arguments @('add', 'README.md'))
    [void](Invoke-TestGit -Repository $parentRoot -Arguments @('commit', '-m', 'primary conflict'))
    $beforeConflictHead = Get-TestHead -Repository $parentRoot
    Assert-ThrowsMatch {
        Merge-HarnessGitWorkspace -WorkspaceRoot $parentRoot -SourceWorkspaceRoot $conflictRoot -ExpectedSourceHead $conflictSourceHead -TargetBranches @{ '.' = 'main'; 'Modules/Child' = 'main' } | Out-Null
    } 'ordinary conflicts|could not be limited|README' 'ordinary parent conflicts abort instead of being resolved automatically'
    Assert-Equal $beforeConflictHead (Get-TestHead -Repository $parentRoot) 'ordinary conflict abort preserves the target HEAD'
    Assert-True (-not (Test-Path -LiteralPath (Join-Path $parentRoot '.git\MERGE_HEAD') -PathType Leaf)) 'ordinary conflict leaves no merge in progress'
    Assert-True (Test-Path -LiteralPath $conflictRoot -PathType Container) 'conflict handling preserves the source worktree'
    Assert-Equal $conflictSourceChildHead (Get-TestHead -Repository (Join-Path $parentRoot 'Modules/Child')) 'submodule integration completed before the later parent conflict'
    $resumePreview = Merge-HarnessGitWorkspace -WorkspaceRoot $parentRoot -SourceWorkspaceRoot $conflictRoot -ExpectedSourceHead $conflictSourceHead -TargetBranches @{ '.' = 'main'; 'Modules/Child' = 'main' } -WhatIf
    $resumeSubmodule = @($resumePreview.Plans | Where-Object Repository -eq 'Modules/Child')[0]
    Assert-Equal 'AlreadyIntegrated' $resumeSubmodule.Action 'a retry recognizes the submodule integration completed before the parent conflict'
    Assert-True $resumeSubmodule.Resumed 'the preview identifies a resumable partial multi-repository integration'
}
finally {
    Remove-Module GitOperations -Force -ErrorAction SilentlyContinue
    if (Test-Path -LiteralPath $fixtureRoot) { Remove-Item -LiteralPath $fixtureRoot -Recurse -Force }
}

Write-Output 'GitOperations.Tests.ps1: PASS'
