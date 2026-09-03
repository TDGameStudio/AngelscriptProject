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

function Resolve-GitExactWorkspaceRoot {
    param([Parameter(Mandatory = $true)][string]$WorkspaceRoot)
    if ([string]::IsNullOrWhiteSpace($WorkspaceRoot)) { throw 'WorkspaceRoot must name an exact Git worktree root.' }
    $requested = [System.IO.Path]::GetFullPath($WorkspaceRoot)
    $resolved = Resolve-GitRepositoryRoot -Path $requested
    if (-not (Test-GitPathEqual -Left $requested -Right $resolved)) {
        throw "WorkspaceRoot must be the exact Git worktree root '$resolved', not '$requested'."
    }
    return $resolved
}

function Get-GitCommonDirectory {
    param([Parameter(Mandatory = $true)][string]$Repository)
    $value = ([string]((Invoke-GitOperation -Repository $Repository -Arguments @('rev-parse', '--git-common-dir')).Output | Select-Object -Last 1)).Trim()
    if ([System.IO.Path]::IsPathRooted($value)) { return [System.IO.Path]::GetFullPath($value) }
    return [System.IO.Path]::GetFullPath((Join-Path $Repository $value))
}

function Test-GitRegisteredRoot {
    param(
        [Parameter(Mandatory = $true)][string]$Repository,
        [Parameter(Mandatory = $true)][string]$Candidate
    )
    foreach ($registered in @(Get-GitRegisteredRoots -Repository $Repository)) {
        if (Test-GitPathEqual -Left $registered -Right $Candidate) { return $true }
    }
    return $false
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
    param([Parameter(Mandatory = $true)][Alias('ProjectRoot')][string]$WorkspaceRoot)
    $root = Resolve-GitExactWorkspaceRoot -WorkspaceRoot $WorkspaceRoot
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
    return [pscustomobject]@{ WorkspaceRoot = $root; PrimaryRoot = Get-GitPrimaryRoot -Repository $root; Repositories = @($repositories | ForEach-Object { $_ }); Dirty = @($repositories | Where-Object { $_.Initialized -and $_.State.Dirty }).Count -gt 0 }
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
    $candidate = $Path.Replace('\', '/')
    if ($candidate.StartsWith('./', [System.StringComparison]::Ordinal)) { $candidate = $candidate.Substring(2) }
    $candidate = $candidate.TrimEnd('/')
    foreach ($scopeValue in $Scopes) {
        $scope = $scopeValue.Replace('\', '/')
        if ($scope.StartsWith('./', [System.StringComparison]::Ordinal)) { $scope = $scope.Substring(2) }
        $scope = $scope.TrimEnd('/')
        if ($scope -eq '' -or $scope -eq '.' -or $candidate -eq $scope -or $candidate.StartsWith($scope + '/', [System.StringComparison]::OrdinalIgnoreCase)) { return $true }
    }
    return $false
}

function Resolve-GitCommitScopes {
    param(
        [string]$Root,
        [hashtable]$RepositoryScopes,
        [switch]$AllChanges
    )
    if ($AllChanges -and $null -ne $RepositoryScopes -and $RepositoryScopes.Count -gt 0) { throw 'Choose RepositoryScopes or AllChanges, not both.' }
    if (-not $AllChanges -and ($null -eq $RepositoryScopes -or $RepositoryScopes.Count -eq 0)) { throw 'RepositoryScopes is required unless AllChanges is explicitly selected.' }
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

function Get-GitStagedPaths {
    param(
        [Parameter(Mandatory = $true)][string]$Repository,
        [switch]$IncludeIntentToAdd
    )
    $arguments = @('-c', 'core.quotepath=false', 'diff', '--cached', '--name-only', '--no-renames')
    if ($IncludeIntentToAdd) { $arguments += '--ita-visible-in-index' }
    return @((Invoke-GitOperation -Repository $Repository -Arguments $arguments).Output | Where-Object { $_ } | Sort-Object -Unique)
}

function Get-GitIntentToAddPaths {
    param([Parameter(Mandatory = $true)][string]$Repository)
    $ordinary = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
    foreach ($path in @(Get-GitStagedPaths -Repository $Repository)) { [void]$ordinary.Add([string]$path) }
    return @(Get-GitStagedPaths -Repository $Repository -IncludeIntentToAdd | Where-Object { -not $ordinary.Contains([string]$_) })
}

function Get-GitUnmergedPaths {
    param([Parameter(Mandatory = $true)][string]$Repository)
    $paths = New-Object System.Collections.Generic.List[string]
    $result = Invoke-GitOperation -Repository $Repository -Arguments @('-c', 'core.quotepath=false', 'ls-files', '--unmerged')
    foreach ($line in $result.Output) {
        $separator = $line.IndexOf("`t", [System.StringComparison]::Ordinal)
        if ($separator -lt 0) { throw "Unable to parse unmerged index entry in '$Repository': $line" }
        $paths.Add($line.Substring($separator + 1)) | Out-Null
    }
    return @($paths | Sort-Object -Unique)
}

function Assert-GitNoCrossScopeRenameOrCopy {
    param(
        [Parameter(Mandatory = $true)][string]$Repository,
        [Parameter(Mandatory = $true)][string[]]$Scopes
    )
    $result = Invoke-GitOperation -Repository $Repository -Arguments @(
        '-c', 'core.quotepath=false', 'diff', '--cached', '--name-status', '--no-ext-diff',
        '--find-renames', '--find-copies-harder'
    )
    foreach ($line in $result.Output) {
        if ($line -notmatch '^[RC][0-9]+\t') { continue }
        $parts = @($line -split "`t", 3)
        if ($parts.Count -ne 3) { throw "Unable to parse staged rename/copy entry in '$Repository': $line" }
        $sourceCovered = Test-GitPathCovered -Path $parts[1] -Scopes $Scopes
        $targetCovered = Test-GitPathCovered -Path $parts[2] -Scopes $Scopes
        if ($sourceCovered -ne $targetCovered) {
            throw "Repository '$Repository' has a staged rename/copy crossing the requested scope: $($parts[1]) -> $($parts[2])."
        }
    }
}

function Get-GitOutsideStagedSnapshot {
    param(
        [Parameter(Mandatory = $true)][string]$Repository,
        [Parameter(Mandatory = $true)][string[]]$Scopes
    )
    [string[]]$outsidePaths = @(Get-GitStagedPaths -Repository $Repository |
        Where-Object { -not (Test-GitPathCovered -Path $_ -Scopes $Scopes) })
    [Array]::Sort($outsidePaths, [System.StringComparer]::Ordinal)

    [string[]]$metadata = @()
    [byte[]]$patchBytes = @()
    if ($outsidePaths.Count -gt 0) {
        $metadata = @((Invoke-GitOperation -Repository $Repository -Arguments (
            @('--literal-pathspecs', 'ls-files', '--stage', '--') + @($outsidePaths)
        )).Output | ForEach-Object { [string]$_ })
        [Array]::Sort($metadata, [System.StringComparer]::Ordinal)

        $patchPath = Join-Path ([System.IO.Path]::GetTempPath()) ("hardness-git-staged-{0}.patch" -f [guid]::NewGuid().ToString('N'))
        try {
            [void](Invoke-GitOperation -Repository $Repository -Arguments (
                @(
                    '--literal-pathspecs', 'diff', '--cached', '--binary', '--full-index', '--no-ext-diff',
                    '--no-textconv', '--no-renames', "--output=$patchPath", '--'
                ) + @($outsidePaths)
            ))
            $patchBytes = [System.IO.File]::ReadAllBytes($patchPath)
        }
        finally {
            if (Test-Path -LiteralPath $patchPath -PathType Leaf) {
                & {
                    $WhatIfPreference = $false
                    Remove-Item -LiteralPath $patchPath -Force
                }
            }
        }
    }

    $stream = [System.IO.MemoryStream]::new()
    $writer = [System.IO.BinaryWriter]::new($stream, [System.Text.UTF8Encoding]::new($false), $true)
    try {
        $writer.Write([int]$outsidePaths.Count)
        foreach ($path in $outsidePaths) {
            $bytes = [System.Text.Encoding]::UTF8.GetBytes($path)
            $writer.Write([int]$bytes.Length)
            $writer.Write([byte[]]$bytes)
        }
        $writer.Write([int]$metadata.Count)
        foreach ($entry in $metadata) {
            $bytes = [System.Text.Encoding]::UTF8.GetBytes($entry)
            $writer.Write([int]$bytes.Length)
            $writer.Write([byte[]]$bytes)
        }
        $writer.Write([long]$patchBytes.LongLength)
        $writer.Write([byte[]]$patchBytes)
        $writer.Flush()
        $payload = $stream.ToArray()
    }
    finally {
        $writer.Dispose()
        $stream.Dispose()
    }
    $hash = [Convert]::ToHexString([System.Security.Cryptography.SHA256]::HashData($payload)).ToLowerInvariant()
    return [pscustomobject]@{ Paths = @($outsidePaths); Sha256 = "sha256:$hash" }
}

function Assert-GitOutsideStagedSnapshot {
    param(
        [Parameter(Mandatory = $true)][string]$Repository,
        [Parameter(Mandatory = $true)][string[]]$Scopes,
        [Parameter(Mandatory = $true)]$Expected
    )
    $actual = Get-GitOutsideStagedSnapshot -Repository $Repository -Scopes $Scopes
    $samePaths = @($Expected.Paths).Count -eq @($actual.Paths).Count
    if ($samePaths) {
        for ($index = 0; $index -lt @($Expected.Paths).Count; $index++) {
            if (-not ([string]$Expected.Paths[$index]).Equals([string]$actual.Paths[$index], [System.StringComparison]::Ordinal)) {
                $samePaths = $false
                break
            }
        }
    }
    if (-not $samePaths -or $Expected.Sha256 -ne $actual.Sha256) {
        throw "Repository '$Repository' did not preserve staged paths outside the requested scope (before $($Expected.Sha256), after $($actual.Sha256))."
    }
    return $actual
}

function Assert-GitCommitPathsCovered {
    param(
        [Parameter(Mandatory = $true)][string]$Repository,
        [Parameter(Mandatory = $true)][string]$OldHead,
        [Parameter(Mandatory = $true)][string]$NewHead,
        [Parameter(Mandatory = $true)][string[]]$Scopes
    )
    $changedPaths = @((Invoke-GitOperation -Repository $Repository -Arguments @(
        '-c', 'core.quotepath=false', 'diff-tree', '--no-commit-id', '--name-only', '--no-renames', '-r', $OldHead, $NewHead
    )).Output | Where-Object { $_ })
    $outside = @($changedPaths | Where-Object { -not (Test-GitPathCovered -Path $_ -Scopes $Scopes) })
    if ($outside.Count -gt 0) {
        throw "Commit '$NewHead' in '$Repository' contains paths outside the requested scope: $($outside -join ', ')"
    }
    return $changedPaths
}

function Complete-HardnessGitCommit {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true)][Alias('ProjectRoot')][string]$WorkspaceRoot,
        [hashtable]$RepositoryScopes = @{},
        [switch]$AllChanges,
        [switch]$PreserveOutsideStaged,
        [Parameter(Mandatory = $true)][string]$CommitMessage,
        [hashtable]$SubmoduleCommitMessages = @{},
        [hashtable]$TargetBranches = @{}
    )
    $root = Resolve-GitExactWorkspaceRoot -WorkspaceRoot $WorkspaceRoot
    $primary = Get-GitPrimaryRoot -Repository $root
    if ($PreserveOutsideStaged -and $AllChanges) {
        throw 'PreserveOutsideStaged requires exact RepositoryScopes and cannot be combined with AllChanges.'
    }
    if ($AllChanges -and ((Test-GitPathEqual -Left $root -Right $primary) -or -not (Test-GitRegisteredRoot -Repository $primary -Candidate $root))) {
        throw 'AllChanges is allowed only for an exact registered linked worktree; primary-workspace commits require RepositoryScopes.'
    }
    $parentBranch = Get-GitBranch -Repository $root
    $targetParentBranch = if ($TargetBranches.ContainsKey('.')) { [string]$TargetBranches['.'] } else { $parentBranch }
    if ([string]::IsNullOrWhiteSpace($targetParentBranch)) { throw "Detached parent repository requires an explicit TargetBranches entry for '.'." }
    if ($parentBranch -ne $targetParentBranch) { throw "Parent repository is on '$parentBranch', expected target branch '$targetParentBranch'." }
    $scopes = Resolve-GitCommitScopes -Root $root -RepositoryScopes $RepositoryScopes -AllChanges:$AllChanges
    $submodules = @(Get-GitTopLevelSubmodules -Repository $root)
    $repositories = @{ '.' = $root }
    foreach ($submodule in $submodules) { $repositories[$submodule.Path] = $submodule.FullPath }

    $states = @{}
    $scopedDirtyPaths = @{}
    $preflightHeads = @{}
    $preflightBranches = @{}
    $branchPlans = @{}
    foreach ($repoKey in @($scopes.Keys | Sort-Object)) {
        $repoRoot = $repositories[$repoKey]
        if (-not (Test-GitRepository -Path $repoRoot)) { throw "Scoped repository '$repoKey' is not initialized." }
        $state = Get-GitPathState -Repository $repoRoot
        $states[$repoKey] = $state
        $scopedDirtyPaths[$repoKey] = @($state.Staged + $state.Unstaged + $state.Untracked |
            Where-Object { Test-GitPathCovered -Path $_ -Scopes $scopes[$repoKey] } |
            Sort-Object -Unique)
        $preflightHeads[$repoKey] = Get-GitHead -Repository $repoRoot
        $preflightBranches[$repoKey] = Get-GitBranch -Repository $repoRoot
        $unmerged = @(Get-GitUnmergedPaths -Repository $repoRoot)
        if ($unmerged.Count -gt 0) { throw "Repository '$repoKey' has unmerged index paths: $($unmerged -join ', ')" }
    }

    foreach ($repoKey in @($scopes.Keys | Where-Object { $_ -ne '.' } | Sort-Object)) {
        if (@($scopedDirtyPaths[$repoKey]).Count -eq 0) { continue }
        $repoRoot = $repositories[$repoKey]
        $branch = [string]$preflightBranches[$repoKey]
        $targetBranch = if ($TargetBranches.ContainsKey($repoKey)) { [string]$TargetBranches[$repoKey] } else { $branch }
        if ([string]::IsNullOrWhiteSpace($targetBranch)) { throw "Detached scoped repository '$repoKey' requires an explicit TargetBranches entry." }
        $branchExists = $false
        if ([string]::IsNullOrWhiteSpace($branch)) {
            $branchExists = (Invoke-GitOperation -Repository $repoRoot -Arguments @('show-ref', '--verify', '--quiet', "refs/heads/$targetBranch") -AllowFailure).ExitCode -eq 0
            if ($branchExists) {
                $branchHead = Get-GitHead -Repository $repoRoot -Revision "refs/heads/$targetBranch"
                if ($branchHead -ne [string]$preflightHeads[$repoKey]) { throw "Existing target branch '$targetBranch' for '$repoKey' is not at the detached checkout HEAD." }
            }
        }
        elseif ($branch -ne $targetBranch) { throw "Scoped repository '$repoKey' is on '$branch', expected target branch '$targetBranch'." }
        $branchPlans[$repoKey] = [pscustomobject]@{ Branch = $branch; TargetBranch = $targetBranch; BranchExists = $branchExists }
    }

    $effectiveScopes = @{}
    foreach ($repoKey in $scopes.Keys) { $effectiveScopes[$repoKey] = @($scopes[$repoKey]) }
    $parentScopes = New-Object System.Collections.Generic.List[string]
    if ($scopes.ContainsKey('.')) { foreach ($path in $scopes['.']) { $parentScopes.Add($path) | Out-Null } }
    foreach ($repoKey in @($scopes.Keys | Where-Object { $_ -ne '.' } | Sort-Object)) {
        if (@($scopedDirtyPaths[$repoKey]).Count -gt 0) { $parentScopes.Add([string]$repoKey) | Out-Null }
    }
    if ($parentScopes.Count -gt 0) {
        $effectiveScopes['.'] = @($parentScopes | Sort-Object -Unique)
        if (-not $states.ContainsKey('.')) {
            $states['.'] = Get-GitPathState -Repository $root
            $preflightHeads['.'] = Get-GitHead -Repository $root
            $preflightBranches['.'] = Get-GitBranch -Repository $root
            $unmerged = @(Get-GitUnmergedPaths -Repository $root)
            if ($unmerged.Count -gt 0) { throw "Repository '.' has unmerged index paths: $($unmerged -join ', ')" }
        }
    }

    $outsideSnapshots = @{}
    foreach ($repoKey in @($effectiveScopes.Keys | Sort-Object)) {
        $repoRoot = $repositories[$repoKey]
        $repoScopes = @($effectiveScopes[$repoKey])
        $outsideStaged = @(Get-GitStagedPaths -Repository $repoRoot |
            Where-Object { -not (Test-GitPathCovered -Path $_ -Scopes $repoScopes) })
        $outsideIntentToAdd = @(Get-GitIntentToAddPaths -Repository $repoRoot |
            Where-Object { -not (Test-GitPathCovered -Path $_ -Scopes $repoScopes) })
        if ($outsideIntentToAdd.Count -gt 0) {
            throw "Repository '$repoKey' has unsupported outside intent-to-add paths: $($outsideIntentToAdd -join ', ')"
        }
        if (-not $PreserveOutsideStaged -and $outsideStaged.Count -gt 0) {
            throw "Repository '$repoKey' has staged paths outside the requested scope: $($outsideStaged -join ', ')"
        }
        if ($PreserveOutsideStaged) {
            Assert-GitNoCrossScopeRenameOrCopy -Repository $repoRoot -Scopes $repoScopes
            $snapshot = Get-GitOutsideStagedSnapshot -Repository $repoRoot -Scopes $repoScopes
            if (@($snapshot.Paths).Count -gt 0) { $outsideSnapshots[$repoKey] = $snapshot }
        }
    }

    $includedChanges = New-Object System.Collections.Generic.List[object]
    foreach ($repoKey in @($scopes.Keys | Sort-Object)) {
        $state = Get-GitPathState -Repository $repositories[$repoKey]
        $paths = @($state.Staged + $state.Unstaged + $state.Untracked |
            Where-Object { Test-GitPathCovered -Path $_ -Scopes $scopes[$repoKey] } |
            Sort-Object -Unique)
        if ($paths.Count -gt 0) {
            $includedChanges.Add([pscustomobject]@{ Repository = $repoKey; Paths = $paths }) | Out-Null
        }
    }

    $commits = New-Object System.Collections.Generic.List[object]
    try {
        foreach ($repoKey in @($scopes.Keys | Where-Object { $_ -ne '.' } | Sort-Object)) {
            if (@($scopedDirtyPaths[$repoKey]).Count -eq 0) { continue }
            $repoRoot = $repositories[$repoKey]
            $plan = $branchPlans[$repoKey]
            $message = if ($SubmoduleCommitMessages.ContainsKey($repoKey)) { [string]$SubmoduleCommitMessages[$repoKey] } else { $CommitMessage }
            if ($PSCmdlet.ShouldProcess($repoKey, "commit scoped paths on '$($plan.TargetBranch)'")) {
                if ((Get-GitHead -Repository $repoRoot) -ne [string]$preflightHeads[$repoKey] -or
                    (Get-GitBranch -Repository $repoRoot) -ne [string]$preflightBranches[$repoKey]) {
                    throw "Repository '$repoKey' changed after commit preflight."
                }
                if ($outsideSnapshots.ContainsKey($repoKey)) {
                    [void](Assert-GitOutsideStagedSnapshot -Repository $repoRoot -Scopes @($effectiveScopes[$repoKey]) -Expected $outsideSnapshots[$repoKey])
                }
                if ([string]::IsNullOrWhiteSpace($plan.Branch)) {
                    $checkoutArguments = if ($plan.BranchExists) { @('checkout', $plan.TargetBranch) } else { @('checkout', '-b', $plan.TargetBranch) }
                    [void](Invoke-GitOperation -Repository $repoRoot -Arguments $checkoutArguments)
                }
                $repoScopes = @($effectiveScopes[$repoKey])
                [void](Invoke-GitOperation -Repository $repoRoot -Arguments (@('--literal-pathspecs', 'add', '-A', '--') + $repoScopes))
                $hasStaged = (Invoke-GitOperation -Repository $repoRoot -Arguments (@('--literal-pathspecs', 'diff', '--cached', '--quiet', '--') + $repoScopes) -AllowFailure).ExitCode
                if ($hasStaged -eq 1) {
                    $oldHead = Get-GitHead -Repository $repoRoot
                    if ($PreserveOutsideStaged) {
                        [void](Invoke-GitOperation -Repository $repoRoot -Arguments (@('--literal-pathspecs', 'commit', '--dry-run', '--only', '--') + $repoScopes))
                        [void](Invoke-GitOperation -Repository $repoRoot -Arguments (@('--literal-pathspecs', 'commit', '--only', '-m', $message, '--') + $repoScopes))
                    }
                    else {
                        [void](Invoke-GitOperation -Repository $repoRoot -Arguments @('commit', '-m', $message))
                    }
                    $newHead = Get-GitHead -Repository $repoRoot
                    [void](Assert-GitCommitPathsCovered -Repository $repoRoot -OldHead $oldHead -NewHead $newHead -Scopes $repoScopes)
                    $commits.Add([pscustomobject]@{ Repository = $repoKey; Commit = $newHead; Branch = $plan.TargetBranch; Paths = $repoScopes }) | Out-Null
                }
                elseif ($hasStaged -ne 0) { throw "Unable to inspect scoped staged changes in '$repoKey'." }
            }
        }

        if ($effectiveScopes.ContainsKey('.')) {
            $repoScopes = @($effectiveScopes['.'])
            if ($PSCmdlet.ShouldProcess('.', 'commit scoped parent paths and updated gitlinks')) {
                if ((Get-GitHead -Repository $root) -ne [string]$preflightHeads['.'] -or
                    (Get-GitBranch -Repository $root) -ne [string]$preflightBranches['.']) {
                    throw "Repository '.' changed after commit preflight."
                }
                if ($outsideSnapshots.ContainsKey('.')) {
                    [void](Assert-GitOutsideStagedSnapshot -Repository $root -Scopes $repoScopes -Expected $outsideSnapshots['.'])
                }
                [void](Invoke-GitOperation -Repository $root -Arguments (@('--literal-pathspecs', 'add', '-A', '--') + $repoScopes))
                $hasStaged = (Invoke-GitOperation -Repository $root -Arguments (@('--literal-pathspecs', 'diff', '--cached', '--quiet', '--') + $repoScopes) -AllowFailure).ExitCode
                if ($hasStaged -eq 1) {
                    $oldHead = Get-GitHead -Repository $root
                    if ($PreserveOutsideStaged) {
                        [void](Invoke-GitOperation -Repository $root -Arguments (@('--literal-pathspecs', 'commit', '--dry-run', '--only', '--') + $repoScopes))
                        [void](Invoke-GitOperation -Repository $root -Arguments (@('--literal-pathspecs', 'commit', '--only', '-m', $CommitMessage, '--') + $repoScopes))
                    }
                    else {
                        [void](Invoke-GitOperation -Repository $root -Arguments @('commit', '-m', $CommitMessage))
                    }
                    $newHead = Get-GitHead -Repository $root
                    [void](Assert-GitCommitPathsCovered -Repository $root -OldHead $oldHead -NewHead $newHead -Scopes $repoScopes)
                    $commits.Add([pscustomobject]@{ Repository = '.'; Commit = $newHead; Branch = Get-GitBranch $root; Paths = $repoScopes }) | Out-Null
                }
                elseif ($hasStaged -ne 0) { throw 'Unable to inspect scoped staged parent changes.' }
            }
        }
    }

    catch {
        $commitFailure = $_
        $completed = @($commits | ForEach-Object { "$($_.Repository)=$($_.Commit)" }) -join ', '
        if ([string]::IsNullOrWhiteSpace($completed)) { $completed = '<none>' }
        $preservationFailures = New-Object System.Collections.Generic.List[string]
        foreach ($repoKey in @($outsideSnapshots.Keys | Sort-Object)) {
            try {
                [void](Assert-GitOutsideStagedSnapshot -Repository $repositories[$repoKey] -Scopes @($effectiveScopes[$repoKey]) -Expected $outsideSnapshots[$repoKey])
            }
            catch { $preservationFailures.Add("$repoKey`: $($_.Exception.Message)") | Out-Null }
        }
        $preservation = if ($preservationFailures.Count -eq 0) { 'outside staged snapshots preserved' } else { $preservationFailures -join '; ' }
        throw "Scoped Git commit failed without rollback. Completed commits: $completed. Preservation: $preservation. Cause: $($commitFailure.Exception.Message)"
    }

    $preservedStaged = New-Object System.Collections.Generic.List[object]
    foreach ($repoKey in @($outsideSnapshots.Keys | Sort-Object)) {
        $before = $outsideSnapshots[$repoKey]
        if ($WhatIfPreference) {
            $preservedStaged.Add([pscustomobject]@{
                Repository = $repoKey
                Paths = @($before.Paths)
                BeforeSha256 = $before.Sha256
                AfterSha256 = $null
                Validation = 'Pending'
            }) | Out-Null
        }
        else {
            $after = Assert-GitOutsideStagedSnapshot -Repository $repositories[$repoKey] -Scopes @($effectiveScopes[$repoKey]) -Expected $before
            $preservedStaged.Add([pscustomobject]@{
                Repository = $repoKey
                Paths = @($before.Paths)
                BeforeSha256 = $before.Sha256
                AfterSha256 = $after.Sha256
                Validation = 'Preserved'
            }) | Out-Null
        }
    }

    $finalStatus = Get-HardnessGitStatus -WorkspaceRoot $root
    $scopedGitStateComplete = $true
    foreach ($repoKey in $scopes.Keys) {
        $remainingState = Get-GitPathState -Repository $repositories[$repoKey]
        $remaining = @($remainingState.Staged + $remainingState.Unstaged + $remainingState.Untracked | Where-Object { Test-GitPathCovered -Path $_ -Scopes $scopes[$repoKey] })
        if ($remaining.Count -gt 0) { $scopedGitStateComplete = $false }
    }
    return [pscustomobject]@{
        WorkspaceRoot = $root
        PrimaryRoot = $primary
        AllChanges = [bool]$AllChanges
        PreserveOutsideStaged = [bool]$PreserveOutsideStaged
        IncludedChanges = @($includedChanges | ForEach-Object { $_ })
        PreservedStaged = @($preservedStaged | ForEach-Object { $_ })
        Preview = [bool]$WhatIfPreference
        Commits = @($commits | ForEach-Object { $_ })
        GitStateComplete = -not $finalStatus.Dirty
        ScopedGitStateComplete = $scopedGitStateComplete
        Status = $finalStatus
    }
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

function Merge-HardnessGitWorkspace {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true)][Alias('ProjectRoot')][string]$WorkspaceRoot,
        [Parameter(Mandatory = $true)][string]$SourceWorkspaceRoot,
        [Parameter(Mandatory = $true)][ValidatePattern('^[0-9a-fA-F]{40}$')][string]$ExpectedSourceHead,
        [Parameter(Mandatory = $true)][hashtable]$TargetBranches,
        [string]$CommitMessage = ''
    )
    $targetRoot = Resolve-GitExactWorkspaceRoot -WorkspaceRoot $WorkspaceRoot
    $primary = Get-GitPrimaryRoot -Repository $targetRoot
    if (-not (Test-GitPathEqual -Left $targetRoot -Right $primary)) { throw 'git.integrate must run from the canonical primary workspace.' }
    $sourceRoot = Resolve-GitExactWorkspaceRoot -WorkspaceRoot $SourceWorkspaceRoot
    if (Test-GitPathEqual -Left $sourceRoot -Right $targetRoot) { throw 'SourceWorkspaceRoot must select a registered linked worktree, not the primary target.' }
    if (-not (Test-GitPathEqual -Left (Get-GitCommonDirectory -Repository $targetRoot) -Right (Get-GitCommonDirectory -Repository $sourceRoot))) {
        throw 'SourceWorkspaceRoot and the primary target do not share the same Git common directory.'
    }
    if (-not (Test-GitRegisteredRoot -Repository $primary -Candidate $sourceRoot)) {
        throw "SourceWorkspaceRoot is not a registered linked worktree: $sourceRoot"
    }
    $normalizedTargetBranches = @{}
    foreach ($keyValue in $TargetBranches.Keys) {
        $key = ([string]$keyValue).Replace('\', '/').TrimEnd('/')
        if ($normalizedTargetBranches.ContainsKey($key)) { throw "Target branch repository '$key' was specified more than once after path normalization." }
        $branchValue = ([string]$TargetBranches[$keyValue]).Trim()
        if ([string]::IsNullOrWhiteSpace($branchValue)) { throw "Target branch for repository '$key' must not be empty." }
        $normalizedTargetBranches[$key] = $branchValue
    }
    if (-not $normalizedTargetBranches.ContainsKey('.')) { throw "TargetBranches must include the parent repository key '.'." }
    $targetBranch = [string]$normalizedTargetBranches['.']
    if ((Get-GitBranch $targetRoot) -ne $targetBranch) { throw "Primary workspace is not on target branch '$targetBranch'." }
    $actualSourceHead = Get-GitHead -Repository $sourceRoot
    if ($actualSourceHead -ne $ExpectedSourceHead.ToLowerInvariant()) { throw "Source workspace HEAD '$actualSourceHead' does not match reviewed ExpectedSourceHead '$ExpectedSourceHead'." }
    $sourceStatus = Get-HardnessGitStatus -WorkspaceRoot $sourceRoot
    if ($sourceStatus.Dirty) { throw 'Source workspace or one of its initialized submodules is dirty.' }
    $targetState = Get-GitPathState -Repository $targetRoot
    if ($targetState.Staged.Count -gt 0) { throw "Primary target has staged changes: $($targetState.Staged -join ', ')" }

    $targetHead = Get-GitHead $targetRoot
    $baseResult = Invoke-GitOperation -Repository $targetRoot -Arguments @('merge-base', $targetHead, $actualSourceHead)
    $base = ([string]($baseResult.Output | Select-Object -Last 1)).Trim()
    $incomingPaths = @((Invoke-GitOperation -Repository $targetRoot -Arguments @('diff', '--name-only', $base, $actualSourceHead)).Output | Where-Object { $_ })
    $localPaths = @(Get-GitLocalPaths -Repository $targetRoot)
    $overlap = @($localPaths | Where-Object { $local = $_; @($incomingPaths | Where-Object { Test-GitPathOverlap -Left $local -Right $_ }).Count -gt 0 })
    $sourceSubmodules = @(Get-GitTopLevelSubmodules -Repository $sourceRoot)
    $sourceSubmodulePaths = @($sourceSubmodules | ForEach-Object { $_.Path })
    $ordinaryOverlap = @($overlap | Where-Object { $_ -notin $sourceSubmodulePaths })
    if ($ordinaryOverlap.Count -gt 0) { throw "Primary target local paths overlap the incoming source workspace: $($ordinaryOverlap -join ', ')" }

    $plans = New-Object System.Collections.Generic.List[object]
    foreach ($sourceSubmodule in $sourceSubmodules) {
        $path = $sourceSubmodule.Path
        $sourceOidResult = Invoke-GitOperation -Repository $sourceRoot -Arguments @('rev-parse', "$actualSourceHead`:$path") -AllowFailure
        $targetOidResult = Invoke-GitOperation -Repository $targetRoot -Arguments @('rev-parse', "$targetHead`:$path") -AllowFailure
        if ($sourceOidResult.ExitCode -ne 0 -or $targetOidResult.ExitCode -ne 0) { continue }
        $sourceOid = ([string]($sourceOidResult.Output | Select-Object -Last 1)).Trim()
        $targetOid = ([string]($targetOidResult.Output | Select-Object -Last 1)).Trim()
        if ($sourceOid -eq $targetOid) { continue }
        if (-not $normalizedTargetBranches.ContainsKey($path)) { throw "TargetBranches must explicitly select a branch for changed submodule '$path'." }
        $targetSubRoot = Join-Path $targetRoot $path
        if (-not (Test-GitRepository -Path $targetSubRoot)) { throw "Target submodule is not initialized: $path" }
        $sourceSubRoot = Join-Path $sourceRoot $path
        if (-not (Test-GitRepository -Path $sourceSubRoot)) { throw "Source workspace submodule is not initialized: $path" }
        $subState = Get-GitPathState -Repository $targetSubRoot
        if ($subState.Staged.Count -gt 0) { throw "Target submodule '$path' has staged changes." }
        $targetSubHead = Get-GitHead $targetSubRoot
        $selectedTargetBranch = [string]$normalizedTargetBranches[$path]
        $currentTargetBranch = Get-GitBranch -Repository $targetSubRoot
        if (-not [string]::IsNullOrWhiteSpace($currentTargetBranch) -and $currentTargetBranch -ne $selectedTargetBranch) {
            throw "Target submodule '$path' is on '$currentTargetBranch', expected '$selectedTargetBranch'."
        }
        $resumedIntegration = $false
        if ($targetSubHead -ne $targetOid) {
            $containsRecordedTarget = (Invoke-GitOperation -Repository $targetSubRoot -Arguments @('merge-base', '--is-ancestor', $targetOid, $targetSubHead) -AllowFailure).ExitCode -eq 0
            $containsReviewedSource = (Invoke-GitOperation -Repository $targetSubRoot -Arguments @('merge-base', '--is-ancestor', $sourceOid, $targetSubHead) -AllowFailure).ExitCode -eq 0
            if ([string]::IsNullOrWhiteSpace($currentTargetBranch) -or -not $containsRecordedTarget -or -not $containsReviewedSource) {
                throw "Target submodule '$path' is at $targetSubHead, but the primary parent records $targetOid and no completed integration can be proven."
            }
            $resumedIntegration = $true
        }
        $comparison = if ($resumedIntegration) {
            [pscustomobject]@{ Action = 'AlreadyIntegrated'; IncomingPaths = @() }
        }
        else {
            Get-GitCrossRepositoryComparison -TargetRepository $targetSubRoot -TargetHead $targetOid -SourceRepository $sourceSubRoot -SourceHead $sourceOid
        }
        $subIncoming = @($comparison.IncomingPaths)
        $subLocal = @(Get-GitLocalPaths -Repository $targetSubRoot)
        $subOverlap = @($subLocal | Where-Object { $local = $_; @($subIncoming | Where-Object { Test-GitPathOverlap -Left $local -Right $_ }).Count -gt 0 })
        if ($subOverlap.Count -gt 0) { throw "Target submodule '$path' local paths overlap the incoming source workspace: $($subOverlap -join ', ')" }
        $plans.Add([pscustomobject]@{ Repository = $path; Root = $targetSubRoot; SourceRoot = $sourceSubRoot; SourceHead = $sourceOid; TargetHead = $targetOid; CurrentHead = $targetSubHead; TargetBranch = $selectedTargetBranch; Action = $comparison.Action; Resumed = $resumedIntegration; LocalPaths = $subLocal }) | Out-Null
    }
    $parentAction = Get-GitMergeAction -Repository $targetRoot -TargetHead $targetHead -SourceHead $actualSourceHead
    $plans.Add([pscustomobject]@{ Repository = '.'; Root = $targetRoot; SourceRoot = $sourceRoot; SourceHead = $actualSourceHead; TargetHead = $targetHead; CurrentHead = $targetHead; TargetBranch = $targetBranch; Action = $parentAction; Resumed = $false; LocalPaths = $localPaths }) | Out-Null
    if ($WhatIfPreference) {
        return [pscustomobject]@{ WorkspaceRoot = $targetRoot; SourceWorkspaceRoot = $sourceRoot; SourceHead = $actualSourceHead; Preview = $true; Plans = @($plans | ForEach-Object { $_ }); Integrated = $false; RemoteChanged = $false; SourcePreserved = $true }
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
        $arguments = if ($plan.Action -eq 'FastForward') { @('merge', '--ff-only', $plan.SourceHead) } else { @('merge', '--no-ff', '--no-edit', '-m', "Integrate workspace '$sourceRoot' into $($plan.TargetBranch)", $plan.SourceHead) }
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
        $sourceLabel = Split-Path -Leaf $sourceRoot
        $message = if ([string]::IsNullOrWhiteSpace($CommitMessage)) { "[Hardness] Refactor: integrate workspace $sourceLabel" } else { $CommitMessage }
        [void](Invoke-GitOperation -Repository $targetRoot -Arguments @('commit', '-m', $message))
        $completed.Add([pscustomobject]@{ Repository = '.'; Action = $parentPlan.Action; Head = Get-GitHead $targetRoot }) | Out-Null
    }
    return [pscustomobject]@{ WorkspaceRoot = $targetRoot; SourceWorkspaceRoot = $sourceRoot; SourceHead = $actualSourceHead; Preview = $false; Plans = @($plans | ForEach-Object { $_ }); Completed = @($completed | ForEach-Object { $_ }); Integrated = $true; RemoteChanged = $false; SourcePreserved = (Test-Path -LiteralPath $sourceRoot -PathType Container) }
}

function Publish-HardnessGitBranches {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true)][Alias('ProjectRoot')][string]$WorkspaceRoot,
        [Parameter(Mandatory = $true)][hashtable]$RepositoryBranches,
        [ValidatePattern('^[A-Za-z0-9][A-Za-z0-9._-]{0,63}$')][string]$Remote = 'origin'
    )
    if ($RepositoryBranches.Count -eq 0) { throw 'RepositoryBranches must explicitly name at least one repository and branch.' }
    $root = Resolve-GitExactWorkspaceRoot -WorkspaceRoot $WorkspaceRoot
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
        return [pscustomobject]@{ WorkspaceRoot = $root; Preview = $true; Plans = $orderedPlans; Pushed = $false; Forced = $false }
    }
    $results = New-Object System.Collections.Generic.List[object]
    foreach ($plan in $orderedPlans) {
        if ($PSCmdlet.ShouldProcess("$($plan.Remote)/$($plan.Branch)", "push $($plan.Repository) branch without force")) {
            $push = Invoke-GitOperation -Repository $plan.Root -Arguments @('push', '--porcelain', '--set-upstream', $plan.Remote, "refs/heads/$($plan.Branch):refs/heads/$($plan.Branch)")
            $results.Add([pscustomobject]@{ Repository = $plan.Repository; Branch = $plan.Branch; Head = $plan.Head; Remote = $plan.Remote; Output = @($push.Output) }) | Out-Null
        }
    }
    return [pscustomobject]@{ WorkspaceRoot = $root; Preview = $false; Plans = $orderedPlans; Results = @($results | ForEach-Object { $_ }); Pushed = $true; Forced = $false }
}

Export-ModuleMember -Function @(
    'Get-HardnessGitStatus',
    'Complete-HardnessGitCommit',
    'Merge-HardnessGitWorkspace',
    'Publish-HardnessGitBranches'
)
