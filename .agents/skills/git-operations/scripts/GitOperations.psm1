#requires -Version 7.0
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Invoke-GitOperation {
    param(
        [Parameter(Mandatory = $true)][string]$Repository,
        [Parameter(Mandatory = $true)][string[]]$Arguments,
        [switch]$AllowFailure
    )
    $previousPreference = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {
        $output = @(& git -C $Repository @Arguments 2>&1)
        $exitCode = $LASTEXITCODE
    }
    finally { $ErrorActionPreference = $previousPreference }
    $result = [pscustomobject]@{ ExitCode = $exitCode; Output = @($output | ForEach-Object { [string]$_ }) }
    if (-not $AllowFailure -and $exitCode -ne 0) {
        throw "git -C '$Repository' $($Arguments -join ' ') failed ($exitCode): $($result.Output -join [Environment]::NewLine)"
    }
    return $result
}

function Test-GitPathEqual {
    param([string]$Left, [string]$Right)
    return [System.IO.Path]::GetFullPath($Left).TrimEnd('\', '/').Equals(
        [System.IO.Path]::GetFullPath($Right).TrimEnd('\', '/'),
        [System.StringComparison]::OrdinalIgnoreCase)
}

function Test-GitPathInside {
    param([string]$Parent, [string]$Child)
    $parentPath = [System.IO.Path]::GetFullPath($Parent).TrimEnd('\', '/')
    $childPath = [System.IO.Path]::GetFullPath($Child).TrimEnd('\', '/')
    return $childPath.StartsWith($parentPath + [System.IO.Path]::DirectorySeparatorChar, [System.StringComparison]::OrdinalIgnoreCase)
}

function Resolve-GitRepositoryRoot {
    param([string]$Path = '')
    $candidate = if ([string]::IsNullOrWhiteSpace($Path)) { (Get-Location).Path } else { $Path }
    $resolved = [System.IO.Path]::GetFullPath($candidate)
    $result = Invoke-GitOperation -Repository $resolved -Arguments @('rev-parse', '--show-toplevel')
    return [System.IO.Path]::GetFullPath(([string]($result.Output | Select-Object -Last 1)).Trim())
}

function Get-GitPrimaryRoot {
    param([Parameter(Mandatory = $true)][string]$Repository)
    $result = Invoke-GitOperation -Repository $Repository -Arguments @('worktree', 'list', '--porcelain')
    foreach ($line in $result.Output) {
        if ($line -like 'worktree *') { return [System.IO.Path]::GetFullPath($line.Substring(9).Trim()) }
    }
    throw "Git reported no primary worktree for '$Repository'."
}

function Get-GitRegisteredRoots {
    param([Parameter(Mandatory = $true)][string]$Repository)
    $result = Invoke-GitOperation -Repository $Repository -Arguments @('worktree', 'list', '--porcelain')
    return @($result.Output | ForEach-Object {
        if ($_ -like 'worktree *') { [System.IO.Path]::GetFullPath($_.Substring(9).Trim()) }
    } | Where-Object { $_ })
}

function Get-GitTopLevelSubmodules {
    param([Parameter(Mandatory = $true)][string]$Repository)
    if (-not (Test-Path -LiteralPath (Join-Path $Repository '.gitmodules') -PathType Leaf)) { return @() }
    $result = Invoke-GitOperation -Repository $Repository -Arguments @('config', '-f', '.gitmodules', '--get-regexp', '^submodule\..*\.path$') -AllowFailure
    if ($result.ExitCode -eq 1) { return @() }
    if ($result.ExitCode -ne 0) { throw "Unable to parse .gitmodules: $($result.Output -join [Environment]::NewLine)" }
    $records = New-Object System.Collections.Generic.List[object]
    foreach ($line in $result.Output) {
        if ($line -notmatch '^submodule\.(.+)\.path\s+(.+)$') { throw "Unexpected .gitmodules entry: $line" }
        $path = $matches[2].Trim().Replace('\', '/')
        if ([System.IO.Path]::IsPathRooted($path) -or $path -match '(^|/)\.\.(/|$)' -or $path.Contains(':')) {
            throw "Unsafe submodule path '$path'."
        }
        $fullPath = [System.IO.Path]::GetFullPath((Join-Path $Repository $path))
        if (-not (Test-GitPathInside -Parent $Repository -Child $fullPath)) { throw "Submodule path escapes repository: $path" }
        $records.Add([pscustomobject]@{ Name = $matches[1]; Path = $path; FullPath = $fullPath }) | Out-Null
    }
    return @($records | ForEach-Object { $_ })
}

function Get-GitBranch {
    param([string]$Repository)
    return ([string]((Invoke-GitOperation -Repository $Repository -Arguments @('branch', '--show-current')).Output -join '')).Trim()
}

function Get-GitHead {
    param([string]$Repository, [string]$Revision = 'HEAD')
    return ([string]((Invoke-GitOperation -Repository $Repository -Arguments @('rev-parse', $Revision)).Output | Select-Object -Last 1)).Trim()
}

function Get-GitPathState {
    param([Parameter(Mandatory = $true)][string]$Repository)
    # PowerShell converts native stdout to text lines, so NUL-delimited Git output is
    # not stable across hosts. core.quotepath=false keeps ordinary UTF-8 paths readable.
    $staged = @((Invoke-GitOperation -Repository $Repository -Arguments @('-c', 'core.quotepath=false', 'diff', '--cached', '--name-only')).Output | Where-Object { $_ })
    $unstaged = @((Invoke-GitOperation -Repository $Repository -Arguments @('-c', 'core.quotepath=false', 'diff', '--name-only')).Output | Where-Object { $_ })
    $untracked = @((Invoke-GitOperation -Repository $Repository -Arguments @('-c', 'core.quotepath=false', 'ls-files', '--others', '--exclude-standard')).Output | Where-Object { $_ })
    return [pscustomobject]@{ Staged = $staged; Unstaged = $unstaged; Untracked = $untracked; Dirty = ($staged.Count + $unstaged.Count + $untracked.Count) -gt 0 }
}

function Test-GitRepository {
    param([string]$Path)
    if (-not (Test-Path -LiteralPath $Path -PathType Container)) { return $false }
    $probe = Invoke-GitOperation -Repository $Path -Arguments @('rev-parse', '--show-toplevel') -AllowFailure
    return $probe.ExitCode -eq 0 -and (Test-GitPathEqual -Left ([string]($probe.Output | Select-Object -Last 1)) -Right $Path)
}

function Get-HardnessGitStatus {
    [CmdletBinding()]
    param([string]$ProjectRoot = '')
    $root = Resolve-GitRepositoryRoot -Path $ProjectRoot
    $repositories = New-Object System.Collections.Generic.List[object]
    $parentState = Get-GitPathState -Repository $root
    $repositories.Add([pscustomobject]@{ Path = '.'; Root = $root; Branch = Get-GitBranch $root; Head = Get-GitHead $root; Initialized = $true; State = $parentState }) | Out-Null
    foreach ($submodule in @(Get-GitTopLevelSubmodules -Repository $root)) {
        if (Test-GitRepository -Path $submodule.FullPath) {
            $repositories.Add([pscustomobject]@{ Path = $submodule.Path; Root = $submodule.FullPath; Branch = Get-GitBranch $submodule.FullPath; Head = Get-GitHead $submodule.FullPath; Initialized = $true; State = Get-GitPathState $submodule.FullPath }) | Out-Null
        }
        else {
            $repositories.Add([pscustomobject]@{ Path = $submodule.Path; Root = $submodule.FullPath; Branch = ''; Head = ''; Initialized = $false; State = $null }) | Out-Null
        }
    }
    return [pscustomobject]@{ ProjectRoot = $root; PrimaryRoot = Get-GitPrimaryRoot -Repository $root; Repositories = @($repositories | ForEach-Object { $_ }); Dirty = @($repositories | Where-Object { $_.Initialized -and $_.State.Dirty }).Count -gt 0 }
}

function Assert-GitRelativeScope {
    param([Parameter(Mandatory = $true)][string]$Path)
    $normalized = $Path.Trim().Replace('\', '/')
    if ([string]::IsNullOrWhiteSpace($normalized) -or [System.IO.Path]::IsPathRooted($normalized) -or $normalized.Contains(':') -or $normalized -match '(^|/)\.\.(/|$)') {
        throw "Unsafe Git path scope '$Path'."
    }
    return $normalized
}

function Test-GitPathCovered {
    param([string]$Path, [string[]]$Scopes)
    $candidate = $Path.Replace('\', '/').TrimStart('./')
    foreach ($scopeValue in $Scopes) {
        $scope = $scopeValue.Replace('\', '/').TrimStart('./').TrimEnd('/')
        if ($scope -eq '' -or $scope -eq '.' -or $candidate -eq $scope -or $candidate.StartsWith($scope + '/', [System.StringComparison]::OrdinalIgnoreCase)) { return $true }
    }
    return $false
}

function Resolve-GitCommitScopes {
    param(
        [string]$Root,
        [ValidateSet('Current', 'Goal')][string]$Mode,
        [hashtable]$RepositoryScopes,
        [switch]$AllChanges
    )
    if ($AllChanges -and $Mode -ne 'Goal') { throw 'AllChanges is allowed only in Goal mode.' }
    if ($AllChanges -and $null -ne $RepositoryScopes -and $RepositoryScopes.Count -gt 0) { throw 'Choose RepositoryScopes or AllChanges, not both.' }
    if (-not $AllChanges -and ($null -eq $RepositoryScopes -or $RepositoryScopes.Count -eq 0)) { throw 'RepositoryScopes is required unless Goal mode explicitly uses AllChanges.' }
    $known = @{ '.' = $Root }
    foreach ($submodule in @(Get-GitTopLevelSubmodules -Repository $Root)) { $known[$submodule.Path] = $submodule.FullPath }
    $resolved = @{}
    if ($AllChanges) {
        foreach ($key in $known.Keys) {
            if (Test-GitRepository -Path $known[$key]) { $resolved[$key] = @('.') }
        }
        return $resolved
    }
    foreach ($keyValue in $RepositoryScopes.Keys) {
        $key = ([string]$keyValue).Replace('\', '/').TrimEnd('/')
        if (-not $known.ContainsKey($key)) { throw "Repository scope '$key' is not '.' or a configured top-level submodule." }
        $paths = @($RepositoryScopes[$key] | ForEach-Object { Assert-GitRelativeScope -Path ([string]$_) })
        if ($paths.Count -eq 0) { throw "Repository scope '$key' has no paths." }
        $resolved[$key] = $paths
    }
    return $resolved
}

function Complete-HardnessGitCommit {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [string]$ProjectRoot = '',
        [ValidateSet('Current', 'Goal')][string]$Mode = 'Current',
        [string]$GoalName = '',
        [hashtable]$RepositoryScopes = @{},
        [switch]$AllChanges,
        [Parameter(Mandatory = $true)][string]$CommitMessage,
        [hashtable]$SubmoduleCommitMessages = @{},
        [hashtable]$TargetBranches = @{}
    )
    $root = Resolve-GitRepositoryRoot -Path $ProjectRoot
    $primary = Get-GitPrimaryRoot -Repository $root
    if ($Mode -eq 'Goal') {
        if (Test-GitPathEqual -Left $root -Right $primary) { throw 'Goal git.commit requires a registered Goal worktree, not the primary checkout.' }
        $expectedGoal = Split-Path -Leaf $root
        if ([string]::IsNullOrWhiteSpace($GoalName)) { $GoalName = $expectedGoal }
        if ($GoalName -ne $expectedGoal -or -not (Test-GitPathEqual -Left (Split-Path -Parent $root) -Right (Join-Path $primary '.worktrees'))) { throw 'Goal git.commit workspace does not match its canonical Goal name/root.' }
    }
    $scopes = Resolve-GitCommitScopes -Root $root -Mode $Mode -RepositoryScopes $RepositoryScopes -AllChanges:$AllChanges
    $submodules = @(Get-GitTopLevelSubmodules -Repository $root)
    $repositories = @{ '.' = $root }
    foreach ($submodule in $submodules) { $repositories[$submodule.Path] = $submodule.FullPath }

    foreach ($repoKey in $scopes.Keys) {
        $repoRoot = $repositories[$repoKey]
        if (-not (Test-GitRepository -Path $repoRoot)) { throw "Scoped repository '$repoKey' is not initialized." }
        $state = Get-GitPathState -Repository $repoRoot
        $outsideStaged = @($state.Staged | Where-Object { -not (Test-GitPathCovered -Path $_ -Scopes $scopes[$repoKey]) })
        if ($outsideStaged.Count -gt 0) { throw "Repository '$repoKey' has staged paths outside the requested scope: $($outsideStaged -join ', ')" }
    }

    $commits = New-Object System.Collections.Generic.List[object]
    foreach ($repoKey in @($scopes.Keys | Where-Object { $_ -ne '.' } | Sort-Object)) {
        $repoRoot = $repositories[$repoKey]
        $state = Get-GitPathState -Repository $repoRoot
        $scopedDirty = @($state.Staged + $state.Unstaged + $state.Untracked | Where-Object { Test-GitPathCovered -Path $_ -Scopes $scopes[$repoKey] })
        if ($scopedDirty.Count -eq 0) { continue }
        $branch = Get-GitBranch -Repository $repoRoot
        $targetBranch = if ($TargetBranches.ContainsKey($repoKey)) { [string]$TargetBranches[$repoKey] } elseif ($Mode -eq 'Goal') { "goal/$GoalName" } else { $branch }
        if ([string]::IsNullOrWhiteSpace($targetBranch)) { throw "Detached scoped repository '$repoKey' requires an explicit TargetBranches entry." }
        if ([string]::IsNullOrWhiteSpace($branch)) {
            $branchExists = (Invoke-GitOperation -Repository $repoRoot -Arguments @('show-ref', '--verify', '--quiet', "refs/heads/$targetBranch") -AllowFailure).ExitCode -eq 0
            if ($branchExists) {
                $branchHead = Get-GitHead -Repository $repoRoot -Revision "refs/heads/$targetBranch"
                if ($branchHead -ne (Get-GitHead -Repository $repoRoot)) { throw "Existing target branch '$targetBranch' for '$repoKey' is not at the detached checkout HEAD." }
                [void](Invoke-GitOperation -Repository $repoRoot -Arguments @('checkout', $targetBranch))
            }
            else { [void](Invoke-GitOperation -Repository $repoRoot -Arguments @('checkout', '-b', $targetBranch)) }
        }
        elseif ($branch -ne $targetBranch) { throw "Scoped repository '$repoKey' is on '$branch', expected target branch '$targetBranch'." }
        $message = if ($SubmoduleCommitMessages.ContainsKey($repoKey)) { [string]$SubmoduleCommitMessages[$repoKey] } else { $CommitMessage }
        if ($PSCmdlet.ShouldProcess($repoKey, "commit scoped paths on '$targetBranch'")) {
            [void](Invoke-GitOperation -Repository $repoRoot -Arguments (@('add', '-A', '--') + @($scopes[$repoKey])))
            $hasStaged = (Invoke-GitOperation -Repository $repoRoot -Arguments @('diff', '--cached', '--quiet') -AllowFailure).ExitCode
            if ($hasStaged -eq 1) {
                [void](Invoke-GitOperation -Repository $repoRoot -Arguments @('commit', '-m', $message))
                $commits.Add([pscustomobject]@{ Repository = $repoKey; Commit = Get-GitHead $repoRoot; Branch = $targetBranch; Paths = @($scopes[$repoKey]) }) | Out-Null
            }
            elseif ($hasStaged -ne 0) { throw "Unable to inspect staged changes in '$repoKey'." }
        }
    }

    $parentScopes = New-Object System.Collections.Generic.List[string]
    if ($scopes.ContainsKey('.')) { foreach ($path in $scopes['.']) { $parentScopes.Add($path) | Out-Null } }
    foreach ($commit in @($commits | ForEach-Object { $_ })) { if ($commit.Repository -ne '.') { $parentScopes.Add([string]$commit.Repository) | Out-Null } }
    if ($parentScopes.Count -gt 0) {
        $parentState = Get-GitPathState -Repository $root
        $outsideStaged = @($parentState.Staged | Where-Object { -not (Test-GitPathCovered -Path $_ -Scopes @($parentScopes)) })
        if ($outsideStaged.Count -gt 0) { throw "Parent repository has staged paths outside the requested scope: $($outsideStaged -join ', ')" }
        if ($PSCmdlet.ShouldProcess('.', 'commit scoped parent paths and updated gitlinks')) {
            [void](Invoke-GitOperation -Repository $root -Arguments (@('add', '-A', '--') + @($parentScopes | Sort-Object -Unique)))
            $hasStaged = (Invoke-GitOperation -Repository $root -Arguments @('diff', '--cached', '--quiet') -AllowFailure).ExitCode
            if ($hasStaged -eq 1) {
                [void](Invoke-GitOperation -Repository $root -Arguments @('commit', '-m', $CommitMessage))
                $commits.Add([pscustomobject]@{ Repository = '.'; Commit = Get-GitHead $root; Branch = Get-GitBranch $root; Paths = @($parentScopes | Sort-Object -Unique) }) | Out-Null
            }
            elseif ($hasStaged -ne 0) { throw 'Unable to inspect staged parent changes.' }
        }
    }
    $finalStatus = Get-HardnessGitStatus -ProjectRoot $root
    return [pscustomobject]@{ ProjectRoot = $root; Mode = $Mode; Commits = @($commits | ForEach-Object { $_ }); GitStateComplete = -not $finalStatus.Dirty; ScopedGitStateComplete = $true; Status = $finalStatus }
}

function Get-GitMergeAction {
    param([string]$Repository, [string]$TargetHead, [string]$SourceHead)
    if ((Invoke-GitOperation -Repository $Repository -Arguments @('merge-base', '--is-ancestor', $SourceHead, $TargetHead) -AllowFailure).ExitCode -eq 0) { return 'AlreadyIntegrated' }
    if ((Invoke-GitOperation -Repository $Repository -Arguments @('merge-base', '--is-ancestor', $TargetHead, $SourceHead) -AllowFailure).ExitCode -eq 0) { return 'FastForward' }
    return 'Merge'
}

function Get-GitLocalPaths {
    param([string]$Repository)
    $state = Get-GitPathState -Repository $Repository
    return @($state.Unstaged + $state.Untracked | Sort-Object -Unique)
}

function Test-GitPathOverlap {
    param([string]$Left, [string]$Right)
    $a = $Left.Replace('\', '/').Trim('/')
    $b = $Right.Replace('\', '/').Trim('/')
    return $a.Equals($b, [System.StringComparison]::OrdinalIgnoreCase) -or
        $a.StartsWith($b + '/', [System.StringComparison]::OrdinalIgnoreCase) -or
        $b.StartsWith($a + '/', [System.StringComparison]::OrdinalIgnoreCase)
}

function Get-GitCrossRepositoryComparison {
    param(
        [Parameter(Mandatory = $true)][string]$TargetRepository,
        [Parameter(Mandatory = $true)][string]$TargetHead,
        [Parameter(Mandatory = $true)][string]$SourceRepository,
        [Parameter(Mandatory = $true)][string]$SourceHead
    )
    $scratch = Join-Path ([System.IO.Path]::GetTempPath()) ("hardness-git-compare-{0}" -f [guid]::NewGuid().ToString('N'))
    [void][System.IO.Directory]::CreateDirectory($scratch)
    try {
        [void](Invoke-GitOperation -Repository $scratch -Arguments @('init', '--bare'))
        [void](Invoke-GitOperation -Repository $scratch -Arguments @('-c', 'protocol.file.allow=always', 'fetch', '--quiet', '--no-tags', $TargetRepository, $TargetHead))
        [void](Invoke-GitOperation -Repository $scratch -Arguments @('-c', 'protocol.file.allow=always', 'fetch', '--quiet', '--no-tags', $SourceRepository, $SourceHead))
        return [pscustomobject]@{
            Action = Get-GitMergeAction -Repository $scratch -TargetHead $TargetHead -SourceHead $SourceHead
            IncomingPaths = @((Invoke-GitOperation -Repository $scratch -Arguments @('-c', 'core.quotepath=false', 'diff', '--name-only', $TargetHead, $SourceHead)).Output | Where-Object { $_ })
        }
    }
    finally {
        if (Test-Path -LiteralPath $scratch -PathType Container) {
            & {
                $WhatIfPreference = $false
                Remove-Item -LiteralPath $scratch -Recurse -Force
            }
        }
    }
}

function Merge-HardnessGitGoal {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [string]$ProjectRoot = '',
        [Parameter(Mandatory = $true)][ValidatePattern('^[A-Za-z0-9._-]{1,80}$')][string]$GoalName,
        [Parameter(Mandatory = $true)][ValidatePattern('^[0-9a-fA-F]{40}$')][string]$ExpectedSourceHead,
        [Parameter(Mandatory = $true)][hashtable]$TargetBranches,
        [string]$CommitMessage = ''
    )
    $targetRoot = Resolve-GitRepositoryRoot -Path $ProjectRoot
    $primary = Get-GitPrimaryRoot -Repository $targetRoot
    if (-not (Test-GitPathEqual -Left $targetRoot -Right $primary)) { throw 'git.integrate must run from the canonical primary workspace.' }
    if (-not $TargetBranches.ContainsKey('.')) { throw "TargetBranches must include the parent repository key '.'." }
    $targetBranch = [string]$TargetBranches['.']
    if ((Get-GitBranch $targetRoot) -ne $targetBranch) { throw "Primary workspace is not on target branch '$targetBranch'." }
    $sourceRoot = [System.IO.Path]::GetFullPath((Join-Path (Join-Path $primary '.worktrees') $GoalName))
    if (-not (Test-Path -LiteralPath $sourceRoot -PathType Container) -or $sourceRoot -notin @(Get-GitRegisteredRoots -Repository $primary)) { throw "Goal workspace is not registered: $sourceRoot" }
    $actualSourceHead = Get-GitHead -Repository $sourceRoot
    if ($actualSourceHead -ne $ExpectedSourceHead.ToLowerInvariant()) { throw "Goal source HEAD '$actualSourceHead' does not match reviewed ExpectedSourceHead '$ExpectedSourceHead'." }
    $sourceStatus = Get-HardnessGitStatus -ProjectRoot $sourceRoot
    if ($sourceStatus.Dirty) { throw 'Goal source workspace or one of its initialized submodules is dirty.' }
    $targetState = Get-GitPathState -Repository $targetRoot
    if ($targetState.Staged.Count -gt 0) { throw "Primary target has staged changes: $($targetState.Staged -join ', ')" }

    $targetHead = Get-GitHead $targetRoot
    $baseResult = Invoke-GitOperation -Repository $targetRoot -Arguments @('merge-base', $targetHead, $actualSourceHead)
    $base = ([string]($baseResult.Output | Select-Object -Last 1)).Trim()
    $incomingPaths = @((Invoke-GitOperation -Repository $targetRoot -Arguments @('diff', '--name-only', $base, $actualSourceHead)).Output | Where-Object { $_ })
    $localPaths = @(Get-GitLocalPaths -Repository $targetRoot)
    $overlap = @($localPaths | Where-Object { $local = $_; @($incomingPaths | Where-Object { Test-GitPathOverlap -Left $local -Right $_ }).Count -gt 0 })
    if ($overlap.Count -gt 0) { throw "Primary target local paths overlap the incoming Goal: $($overlap -join ', ')" }

    $plans = New-Object System.Collections.Generic.List[object]
    $sourceSubmodules = @(Get-GitTopLevelSubmodules -Repository $sourceRoot)
    foreach ($sourceSubmodule in $sourceSubmodules) {
        $path = $sourceSubmodule.Path
        $sourceOidResult = Invoke-GitOperation -Repository $sourceRoot -Arguments @('rev-parse', "$actualSourceHead`:$path") -AllowFailure
        $targetOidResult = Invoke-GitOperation -Repository $targetRoot -Arguments @('rev-parse', "$targetHead`:$path") -AllowFailure
        if ($sourceOidResult.ExitCode -ne 0 -or $targetOidResult.ExitCode -ne 0) { continue }
        $sourceOid = ([string]($sourceOidResult.Output | Select-Object -Last 1)).Trim()
        $targetOid = ([string]($targetOidResult.Output | Select-Object -Last 1)).Trim()
        if ($sourceOid -eq $targetOid) { continue }
        if (-not $TargetBranches.ContainsKey($path)) { throw "TargetBranches must explicitly select a branch for changed submodule '$path'." }
        $targetSubRoot = Join-Path $targetRoot $path
        if (-not (Test-GitRepository -Path $targetSubRoot)) { throw "Target submodule is not initialized: $path" }
        $sourceSubRoot = Join-Path $sourceRoot $path
        if (-not (Test-GitRepository -Path $sourceSubRoot)) { throw "Goal source submodule is not initialized: $path" }
        $subState = Get-GitPathState -Repository $targetSubRoot
        if ($subState.Staged.Count -gt 0) { throw "Target submodule '$path' has staged changes." }
        $targetSubHead = Get-GitHead $targetSubRoot
        if ($targetSubHead -ne $targetOid) { throw "Target submodule '$path' is at $targetSubHead, but the primary parent records $targetOid." }
        $comparison = Get-GitCrossRepositoryComparison -TargetRepository $targetSubRoot -TargetHead $targetOid -SourceRepository $sourceSubRoot -SourceHead $sourceOid
        $subIncoming = @($comparison.IncomingPaths)
        $subLocal = @(Get-GitLocalPaths -Repository $targetSubRoot)
        $subOverlap = @($subLocal | Where-Object { $local = $_; @($subIncoming | Where-Object { Test-GitPathOverlap -Left $local -Right $_ }).Count -gt 0 })
        if ($subOverlap.Count -gt 0) { throw "Target submodule '$path' local paths overlap the incoming Goal: $($subOverlap -join ', ')" }
        $plans.Add([pscustomobject]@{ Repository = $path; Root = $targetSubRoot; SourceRoot = $sourceSubRoot; SourceHead = $sourceOid; TargetHead = $targetSubHead; TargetBranch = [string]$TargetBranches[$path]; Action = $comparison.Action; LocalPaths = $subLocal }) | Out-Null
    }
    $parentAction = Get-GitMergeAction -Repository $targetRoot -TargetHead $targetHead -SourceHead $actualSourceHead
    $plans.Add([pscustomobject]@{ Repository = '.'; Root = $targetRoot; SourceHead = $actualSourceHead; TargetHead = $targetHead; TargetBranch = $targetBranch; Action = $parentAction; LocalPaths = $localPaths }) | Out-Null
    if ($WhatIfPreference) {
        return [pscustomobject]@{ ProjectRoot = $targetRoot; SourceRoot = $sourceRoot; SourceHead = $actualSourceHead; Preview = $true; Plans = @($plans | ForEach-Object { $_ }); Integrated = $false; RemoteChanged = $false; SourcePreserved = $true }
    }

    $completed = New-Object System.Collections.Generic.List[object]
    foreach ($plan in @($plans | Where-Object Repository -ne '.')) {
        $hasSourceObject = Invoke-GitOperation -Repository $plan.Root -Arguments @('cat-file', '-e', "$($plan.SourceHead)`^{commit}") -AllowFailure
        if ($hasSourceObject.ExitCode -ne 0) {
            [void](Invoke-GitOperation -Repository $plan.Root -Arguments @('-c', 'protocol.file.allow=always', 'fetch', '--quiet', '--no-tags', $plan.SourceRoot, $plan.SourceHead))
        }
        $currentBranch = Get-GitBranch $plan.Root
        if ([string]::IsNullOrWhiteSpace($currentBranch)) {
            $branchExists = (Invoke-GitOperation -Repository $plan.Root -Arguments @('show-ref', '--verify', '--quiet', "refs/heads/$($plan.TargetBranch)") -AllowFailure).ExitCode -eq 0
            if (-not $branchExists) { [void](Invoke-GitOperation -Repository $plan.Root -Arguments @('branch', $plan.TargetBranch, $plan.TargetHead)) }
            [void](Invoke-GitOperation -Repository $plan.Root -Arguments @('checkout', $plan.TargetBranch))
        }
        elseif ($currentBranch -ne $plan.TargetBranch) { throw "Target submodule '$($plan.Repository)' is on '$currentBranch', expected '$($plan.TargetBranch)'." }
        if ($plan.Action -eq 'AlreadyIntegrated') {
            $completed.Add([pscustomobject]@{ Repository = $plan.Repository; Action = $plan.Action; Head = Get-GitHead $plan.Root }) | Out-Null
            continue
        }
        $arguments = if ($plan.Action -eq 'FastForward') { @('merge', '--ff-only', $plan.SourceHead) } else { @('merge', '--no-ff', '--no-edit', '-m', "Integrate Goal $GoalName into $($plan.TargetBranch)", $plan.SourceHead) }
        $merge = Invoke-GitOperation -Repository $plan.Root -Arguments $arguments -AllowFailure
        if ($merge.ExitCode -ne 0) {
            [void](Invoke-GitOperation -Repository $plan.Root -Arguments @('merge', '--abort') -AllowFailure)
            throw "Integration stopped in '$($plan.Repository)' and aborted its merge: $($merge.Output -join [Environment]::NewLine). Earlier repository integrations remain committed and a rerun is safe."
        }
        $completed.Add([pscustomobject]@{ Repository = $plan.Repository; Action = $plan.Action; Head = Get-GitHead $plan.Root }) | Out-Null
    }

    $parentPlan = @($plans | Where-Object Repository -eq '.')[0]
    if ($parentPlan.Action -ne 'AlreadyIntegrated') {
        # A submodule branch must be integrated before the parent gitlink can be
        # resolved, but leaving its checkout at that new head makes the parent
        # appear locally modified and can block Git's merge. Temporarily restore
        # the reviewed target gitlink; the integrated branch itself is preserved.
        foreach ($plan in @($plans | Where-Object Repository -ne '.')) {
            [void](Invoke-GitOperation -Repository $plan.Root -Arguments @('checkout', '--detach', $plan.TargetHead))
        }
        $merge = Invoke-GitOperation -Repository $targetRoot -Arguments @('merge', '--no-ff', '--no-commit', $actualSourceHead) -AllowFailure
        if ($merge.ExitCode -ne 0) {
            $conflicts = @((Invoke-GitOperation -Repository $targetRoot -Arguments @('diff', '--name-only', '--diff-filter=U')).Output | Where-Object { $_ })
            $changedSubmodulePaths = @($plans | Where-Object Repository -ne '.' | ForEach-Object Repository)
            $ordinary = @($conflicts | Where-Object { $_ -notin $changedSubmodulePaths })
            if ($conflicts.Count -eq 0 -or $ordinary.Count -gt 0) {
                [void](Invoke-GitOperation -Repository $targetRoot -Arguments @('merge', '--abort') -AllowFailure)
                foreach ($plan in @($plans | Where-Object Repository -ne '.')) {
                    [void](Invoke-GitOperation -Repository $plan.Root -Arguments @('checkout', $plan.TargetBranch) -AllowFailure)
                }
                $detail = if ($ordinary.Count -gt 0) { $ordinary -join ', ' } else { $merge.Output -join [Environment]::NewLine }
                throw "Parent integration could not be limited to automatic gitlink resolution and was aborted: $detail. Earlier repository integrations remain committed and a rerun is safe."
            }
        }
        foreach ($plan in @($plans | Where-Object Repository -ne '.')) {
            [void](Invoke-GitOperation -Repository $plan.Root -Arguments @('checkout', $plan.TargetBranch))
            $integratedHead = Get-GitHead $plan.Root
            $containsSource = (Invoke-GitOperation -Repository $plan.Root -Arguments @('merge-base', '--is-ancestor', $plan.SourceHead, $integratedHead) -AllowFailure).ExitCode -eq 0
            $containsTarget = (Invoke-GitOperation -Repository $plan.Root -Arguments @('merge-base', '--is-ancestor', $plan.TargetHead, $integratedHead) -AllowFailure).ExitCode -eq 0
            if (-not $containsSource -or -not $containsTarget) {
                [void](Invoke-GitOperation -Repository $targetRoot -Arguments @('merge', '--abort') -AllowFailure)
                throw "Integrated submodule head for '$($plan.Repository)' does not contain both source and target history."
            }
            [void](Invoke-GitOperation -Repository $targetRoot -Arguments @('add', '--', $plan.Repository))
        }
        $message = if ([string]::IsNullOrWhiteSpace($CommitMessage)) { "[Hardness] Refactor: integrate $GoalName" } else { $CommitMessage }
        [void](Invoke-GitOperation -Repository $targetRoot -Arguments @('commit', '-m', $message))
        $completed.Add([pscustomobject]@{ Repository = '.'; Action = $parentPlan.Action; Head = Get-GitHead $targetRoot }) | Out-Null
    }
    return [pscustomobject]@{ ProjectRoot = $targetRoot; SourceRoot = $sourceRoot; SourceHead = $actualSourceHead; Preview = $false; Plans = @($plans | ForEach-Object { $_ }); Completed = @($completed | ForEach-Object { $_ }); Integrated = $true; RemoteChanged = $false; SourcePreserved = (Test-Path -LiteralPath $sourceRoot -PathType Container) }
}

function Publish-HardnessGitBranches {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [string]$ProjectRoot = '',
        [Parameter(Mandatory = $true)][hashtable]$RepositoryBranches,
        [ValidatePattern('^[A-Za-z0-9][A-Za-z0-9._-]{0,63}$')][string]$Remote = 'origin'
    )
    if ($RepositoryBranches.Count -eq 0) { throw 'RepositoryBranches must explicitly name at least one repository and branch.' }
    $root = Resolve-GitRepositoryRoot -Path $ProjectRoot
    $known = @{ '.' = $root }
    $submodules = @(Get-GitTopLevelSubmodules -Repository $root)
    foreach ($submodule in $submodules) { $known[$submodule.Path] = $submodule.FullPath }
    $branches = @{}
    foreach ($keyValue in $RepositoryBranches.Keys) {
        $key = ([string]$keyValue).Replace('\', '/').TrimEnd('/')
        if ($branches.ContainsKey($key)) { throw "Publish repository '$key' was specified more than once after path normalization." }
        $branches[$key] = [string]$RepositoryBranches[$keyValue]
    }
    $plans = New-Object System.Collections.Generic.List[object]
    foreach ($key in $branches.Keys) {
        if (-not $known.ContainsKey($key)) { throw "Publish repository '$key' is not '.' or a configured top-level submodule." }
        $repoRoot = $known[$key]
        if (-not (Test-GitRepository -Path $repoRoot)) { throw "Publish repository '$key' is not initialized." }
        $branch = [string]$branches[$key]
        if ((Invoke-GitOperation -Repository $repoRoot -Arguments @('check-ref-format', '--branch', $branch) -AllowFailure).ExitCode -ne 0) { throw "Invalid publish branch '$branch' for '$key'." }
        if ((Invoke-GitOperation -Repository $repoRoot -Arguments @('show-ref', '--verify', '--quiet', "refs/heads/$branch") -AllowFailure).ExitCode -ne 0) { throw "Local publish branch '$branch' does not exist in '$key'." }
        if ((Invoke-GitOperation -Repository $repoRoot -Arguments @('remote', 'get-url', $Remote) -AllowFailure).ExitCode -ne 0) { throw "Remote '$Remote' does not exist in '$key'." }
        $plans.Add([pscustomobject]@{ Repository = $key; Root = $repoRoot; Branch = $branch; Head = Get-GitHead -Repository $repoRoot -Revision "refs/heads/$branch"; Remote = $Remote }) | Out-Null
    }

    if ($branches.ContainsKey('.')) {
        $parentBranch = [string]$branches['.']
        foreach ($submodule in $submodules) {
            if (-not (Test-GitRepository -Path $submodule.FullPath)) { continue }
            $gitlink = (Invoke-GitOperation -Repository $root -Arguments @('rev-parse', "refs/heads/$parentBranch`:$($submodule.Path)") -AllowFailure)
            if ($gitlink.ExitCode -ne 0) { continue }
            $oid = ([string]($gitlink.Output | Select-Object -Last 1)).Trim()
            $remoteContains = @((Invoke-GitOperation -Repository $submodule.FullPath -Arguments @('branch', '-r', '--contains', $oid) -AllowFailure).Output | Where-Object { $_ -match "^\s*$([regex]::Escape($Remote))/" })
            if ($remoteContains.Count -eq 0) {
                if (-not $branches.ContainsKey($submodule.Path)) {
                    throw "Parent branch '$parentBranch' references submodule '$($submodule.Path)' commit $oid that is not known reachable from '$Remote'; explicitly include that submodule branch before publishing the parent."
                }
                $subBranch = [string]$branches[$submodule.Path]
                $contains = Invoke-GitOperation -Repository $submodule.FullPath -Arguments @('merge-base', '--is-ancestor', $oid, "refs/heads/$subBranch") -AllowFailure
                if ($contains.ExitCode -ne 0) { throw "Publish branch '$subBranch' for '$($submodule.Path)' does not contain parent gitlink $oid." }
            }
        }
    }

    $orderedPlans = @($plans | Sort-Object @{ Expression = { if ($_.Repository -eq '.') { 1 } else { 0 } } }, Repository)
    if ($WhatIfPreference) {
        return [pscustomobject]@{ ProjectRoot = $root; Preview = $true; Plans = $orderedPlans; Pushed = $false; Forced = $false }
    }
    $results = New-Object System.Collections.Generic.List[object]
    foreach ($plan in $orderedPlans) {
        if ($PSCmdlet.ShouldProcess("$($plan.Remote)/$($plan.Branch)", "push $($plan.Repository) branch without force")) {
            $push = Invoke-GitOperation -Repository $plan.Root -Arguments @('push', '--porcelain', '--set-upstream', $plan.Remote, "refs/heads/$($plan.Branch):refs/heads/$($plan.Branch)")
            $results.Add([pscustomobject]@{ Repository = $plan.Repository; Branch = $plan.Branch; Head = $plan.Head; Remote = $plan.Remote; Output = @($push.Output) }) | Out-Null
        }
    }
    return [pscustomobject]@{ ProjectRoot = $root; Preview = $false; Plans = $orderedPlans; Results = @($results | ForEach-Object { $_ }); Pushed = $true; Forced = $false }
}

Export-ModuleMember -Function @(
    'Get-HardnessGitStatus',
    'Complete-HardnessGitCommit',
    'Merge-HardnessGitGoal',
    'Publish-HardnessGitBranches'
)
