Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-WorkspaceRepositoryRootFromModule {
    return [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..\..\..'))
}

function Invoke-WorkspaceGit {
    param(
        [Parameter(Mandatory = $true)][string]$Repository,
        [Parameter(Mandatory = $true)][string[]]$Arguments,
        [switch]$AllowFailure
    )

    $previousPreference = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {
        $output = & git -C $Repository @Arguments 2>&1
        $exitCode = $LASTEXITCODE
    }
    finally {
        $ErrorActionPreference = $previousPreference
    }

    $result = [pscustomobject]@{
        ExitCode = $exitCode
        Output   = @($output | ForEach-Object { [string]$_ })
    }
    if (-not $AllowFailure -and $exitCode -ne 0) {
        throw "git -C '$Repository' $($Arguments -join ' ') failed ($exitCode): $($result.Output -join [Environment]::NewLine)"
    }
    return $result
}

function Invoke-WorkspaceGitRaw {
    param(
        [Parameter(Mandatory = $true)][string[]]$Arguments,
        [switch]$AllowFailure
    )

    $previousPreference = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {
        $output = & git @Arguments 2>&1
        $exitCode = $LASTEXITCODE
    }
    finally {
        $ErrorActionPreference = $previousPreference
    }

    $result = [pscustomobject]@{
        ExitCode = $exitCode
        Output   = @($output | ForEach-Object { [string]$_ })
    }
    if (-not $AllowFailure -and $exitCode -ne 0) {
        throw "git $($Arguments -join ' ') failed ($exitCode): $($result.Output -join [Environment]::NewLine)"
    }
    return $result
}

function Resolve-WorkspaceRepository {
    param([string]$Path)

    $candidate = if ([string]::IsNullOrWhiteSpace($Path)) {
        Get-WorkspaceRepositoryRootFromModule
    }
    else {
        $Path
    }
    $resolved = (Resolve-Path -LiteralPath $candidate -ErrorAction Stop).Path
    $probe = Invoke-WorkspaceGit -Repository $resolved -Arguments @('rev-parse', '--show-toplevel')
    return [System.IO.Path]::GetFullPath(($probe.Output | Select-Object -Last 1).Trim())
}

function Test-WorkspacePathInside {
    param(
        [Parameter(Mandatory = $true)][string]$Parent,
        [Parameter(Mandatory = $true)][string]$Child
    )

    $parentPath = [System.IO.Path]::GetFullPath($Parent).TrimEnd('\', '/') + [System.IO.Path]::DirectorySeparatorChar
    $childPath = [System.IO.Path]::GetFullPath($Child).TrimEnd('\', '/') + [System.IO.Path]::DirectorySeparatorChar
    return $childPath.StartsWith($parentPath, [System.StringComparison]::OrdinalIgnoreCase)
}

function Test-WorkspacePathEqual {
    param(
        [Parameter(Mandatory = $true)][string]$Left,
        [Parameter(Mandatory = $true)][string]$Right
    )

    $leftPath = [System.IO.Path]::GetFullPath($Left).TrimEnd('\', '/')
    $rightPath = [System.IO.Path]::GetFullPath($Right).TrimEnd('\', '/')
    return $leftPath.Equals($rightPath, [System.StringComparison]::OrdinalIgnoreCase)
}

function Assert-WorkspacePathChainSafe {
    param(
        [Parameter(Mandatory = $true)][string]$Root,
        [Parameter(Mandatory = $true)][string]$Target,
        [string]$Purpose = 'workspace operation'
    )

    $rootPath = [System.IO.Path]::GetFullPath($Root).TrimEnd('\', '/')
    $targetPath = [System.IO.Path]::GetFullPath($Target).TrimEnd('\', '/')
    if (-not (Test-WorkspacePathEqual -Left $rootPath -Right $targetPath) -and
        -not (Test-WorkspacePathInside -Parent $rootPath -Child $targetPath)) {
        throw "Refusing $Purpose because '$targetPath' escapes the canonical root '$rootPath'."
    }

    $paths = New-Object System.Collections.Generic.List[string]
    $paths.Add($rootPath) | Out-Null
    if (-not (Test-WorkspacePathEqual -Left $rootPath -Right $targetPath)) {
        $relative = $targetPath.Substring($rootPath.Length).TrimStart('\', '/')
        $current = $rootPath
        foreach ($segment in @($relative -split '[\\/]')) {
            if ([string]::IsNullOrWhiteSpace($segment)) {
                continue
            }
            $current = Join-Path $current $segment
            $paths.Add($current) | Out-Null
        }
    }

    foreach ($candidate in @($paths | ForEach-Object { $_ })) {
        $item = Get-Item -LiteralPath $candidate -Force -ErrorAction SilentlyContinue
        if ($null -eq $item) {
            break
        }
        if (($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0) {
            throw "Refusing $Purpose because the physical path chain contains reparse point '$candidate'."
        }
    }
    return $targetPath
}

function ConvertTo-WorkspaceSubmoduleNamePath {
    param([Parameter(Mandatory = $true)][string]$Name)

    if ([string]::IsNullOrWhiteSpace($Name) -or [System.IO.Path]::IsPathRooted($Name) -or $Name.IndexOf(':') -ge 0) {
        throw "Invalid submodule logical name '$Name': names must be relative to the module-store root."
    }
    $segments = @($Name -split '[\\/]')
    if ($segments.Count -eq 0) {
        throw "Invalid submodule logical name '$Name'."
    }
    $invalidCharacters = [System.IO.Path]::GetInvalidFileNameChars()
    $normalized = New-Object System.Collections.Generic.List[string]
    foreach ($segment in $segments) {
        if ([string]::IsNullOrWhiteSpace($segment) -or $segment -eq '.' -or $segment -eq '..') {
            throw "Invalid submodule logical name '$Name': traversal and empty segments are forbidden."
        }
        if ($segment.IndexOfAny($invalidCharacters) -ge 0 -or $segment.EndsWith('.') -or $segment.EndsWith(' ')) {
            throw "Invalid submodule logical name '$Name': segment '$segment' is not a portable directory name."
        }
        $normalized.Add($segment) | Out-Null
    }
    return ($normalized -join [System.IO.Path]::DirectorySeparatorChar)
}

function Get-WorkspaceSubmodules {
    param([Parameter(Mandatory = $true)][string]$Repository)

    $gitmodules = Join-Path $Repository '.gitmodules'
    if (-not (Test-Path -LiteralPath $gitmodules -PathType Leaf)) {
        return @()
    }

    $result = Invoke-WorkspaceGit -Repository $Repository -Arguments @('config', '-f', '.gitmodules', '--get-regexp', '^submodule\..*\.path$') -AllowFailure
    if ($result.ExitCode -eq 1) {
        return @()
    }
    if ($result.ExitCode -ne 0) {
        throw "Unable to parse .gitmodules ($($result.ExitCode)): $($result.Output -join [Environment]::NewLine)"
    }

    $records = New-Object System.Collections.Generic.List[object]
    foreach ($line in $result.Output) {
        if ($line -notmatch '^submodule\.(.+)\.path\s+(.+)$') {
            throw "Unexpected .gitmodules entry: $line"
        }
        $name = $Matches[1].Trim()
        $path = $Matches[2].Trim()
        if ([string]::IsNullOrWhiteSpace($name) -or [string]::IsNullOrWhiteSpace($path)) {
            throw "Invalid .gitmodules entry: $line"
        }
        [void](ConvertTo-WorkspaceSubmoduleNamePath -Name $name)
        $records.Add([pscustomobject]@{ Name = $name; Path = $path }) | Out-Null
    }
    return @($records | ForEach-Object { $_ })
}

function Get-WorkspaceGitlink {
    param(
        [Parameter(Mandatory = $true)][string]$Repository,
        [Parameter(Mandatory = $true)][string]$SubmodulePath
    )

    $result = Invoke-WorkspaceGit -Repository $Repository -Arguments @('ls-tree', 'HEAD', '--', $SubmodulePath)
    $line = ($result.Output | Select-Object -Last 1)
    if ($line -notmatch '^160000\s+commit\s+([0-9a-fA-F]{40})\s') {
        throw "'$SubmodulePath' is listed in .gitmodules but HEAD does not contain a gitlink for it."
    }
    return $Matches[1].ToLowerInvariant()
}

function Test-WorkspaceGitRepository {
    param([Parameter(Mandatory = $true)][string]$Path)
    if (-not (Test-Path -LiteralPath $Path -PathType Container)) {
        return $false
    }
    $candidate = (Resolve-Path -LiteralPath $Path -ErrorAction Stop).Path
    $probe = Invoke-WorkspaceGit -Repository $candidate -Arguments @('rev-parse', '--show-toplevel') -AllowFailure
    if ($probe.ExitCode -ne 0) {
        return $false
    }
    $topLevel = ($probe.Output | Select-Object -Last 1).Trim()
    return Test-WorkspacePathEqual -Left $candidate -Right $topLevel
}

function Get-WorkspaceDirtyLines {
    param([Parameter(Mandatory = $true)][string]$Repository)
    $result = Invoke-WorkspaceGit -Repository $Repository -Arguments @('status', '--porcelain=v1', '--untracked-files=all')
    return @($result.Output | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
}

function Get-WorkspaceIgnoredLines {
    param([Parameter(Mandatory = $true)][string]$Repository)
    $result = Invoke-WorkspaceGit -Repository $Repository -Arguments @('status', '--ignored', '--porcelain=v1', '--untracked-files=all')
    return @($result.Output | Where-Object { $_ -like '!! *' })
}

function Get-WorkspaceCommonGitDirectory {
    param([Parameter(Mandatory = $true)][string]$Repository)
    $result = Invoke-WorkspaceGit -Repository $Repository -Arguments @('rev-parse', '--git-common-dir')
    $value = ($result.Output | Select-Object -Last 1).Trim()
    if ([System.IO.Path]::IsPathRooted($value)) {
        return [System.IO.Path]::GetFullPath($value)
    }
    return [System.IO.Path]::GetFullPath((Join-Path $Repository $value))
}

function Get-WorkspaceGitDirectory {
    param([Parameter(Mandatory = $true)][string]$Repository)
    $result = Invoke-WorkspaceGit -Repository $Repository -Arguments @('rev-parse', '--git-dir')
    $value = ($result.Output | Select-Object -Last 1).Trim()
    if ([System.IO.Path]::IsPathRooted($value)) {
        return [System.IO.Path]::GetFullPath($value)
    }
    return [System.IO.Path]::GetFullPath((Join-Path $Repository $value))
}

function Resolve-WorkspaceSubmoduleStorePath {
    param(
        [Parameter(Mandatory = $true)][string]$StoreParent,
        [Parameter(Mandatory = $true)][string]$Name,
        [string]$Purpose = 'submodule object-store access'
    )

    $safeName = ConvertTo-WorkspaceSubmoduleNamePath -Name $Name
    $modulesRoot = [System.IO.Path]::GetFullPath((Join-Path $StoreParent 'modules'))
    $candidate = [System.IO.Path]::GetFullPath((Join-Path $modulesRoot $safeName))
    if (-not (Test-WorkspacePathInside -Parent $modulesRoot -Child $candidate)) {
        throw "Invalid submodule logical name '$Name': resolved object store escapes '$modulesRoot'."
    }
    [void](Assert-WorkspacePathChainSafe -Root $StoreParent -Target $candidate -Purpose $Purpose)
    return $candidate
}

function Get-WorkspaceSubmoduleStore {
    param(
        [Parameter(Mandatory = $true)][string]$Repository,
        [Parameter(Mandatory = $true)][string]$Name
    )
    $commonDirectory = Get-WorkspaceCommonGitDirectory -Repository $Repository
    return Resolve-WorkspaceSubmoduleStorePath -StoreParent $commonDirectory -Name $Name
}

function Get-WorkspaceCheckoutSubmoduleStore {
    param(
        [Parameter(Mandatory = $true)][string]$Repository,
        [Parameter(Mandatory = $true)][string]$Name
    )
    $gitDirectory = Get-WorkspaceGitDirectory -Repository $Repository
    return Resolve-WorkspaceSubmoduleStorePath -StoreParent $gitDirectory -Name $Name
}

function Test-WorkspaceSubmoduleRepository {
    param(
        [Parameter(Mandatory = $true)][string]$Repository,
        [Parameter(Mandatory = $true)]$Submodule,
        [Parameter(Mandatory = $true)][string]$Path
    )

    if (-not (Test-WorkspaceGitRepository -Path $Path)) {
        return $false
    }
    $actualCommon = Get-WorkspaceCommonGitDirectory -Repository $Path
    $fallbackStore = Get-WorkspaceSubmoduleStore -Repository $Repository -Name $Submodule.Name
    $checkoutStore = Get-WorkspaceCheckoutSubmoduleStore -Repository $Repository -Name $Submodule.Name
    return (Test-WorkspacePathEqual -Left $actualCommon -Right $fallbackStore) -or
        (Test-WorkspacePathEqual -Left $actualCommon -Right $checkoutStore)
}

function Get-WorkspacePathPayload {
    param([Parameter(Mandatory = $true)][string]$Path)

    if (-not (Test-Path -LiteralPath $Path)) {
        return @()
    }
    $item = Get-Item -LiteralPath $Path -Force -ErrorAction Stop
    if (($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0) {
        return @('[reparse-point]')
    }
    if (-not $item.PSIsContainer) {
        return @('[non-directory]')
    }
    return @(Get-ChildItem -LiteralPath $Path -Force -ErrorAction Stop | ForEach-Object { $_.Name })
}

function Initialize-WorkspaceSubmodules {
    param([Parameter(Mandatory = $true)][string]$Repository)

    $states = New-Object System.Collections.Generic.List[object]
    foreach ($submodule in @(Get-WorkspaceSubmodules -Repository $Repository)) {
        $submodulePath = $submodule.Path
        $stateSource = 'checkout'
        $expected = Get-WorkspaceGitlink -Repository $Repository -SubmodulePath $submodulePath
        $fullPath = [System.IO.Path]::GetFullPath((Join-Path $Repository $submodulePath))
        if (-not (Test-WorkspacePathInside -Parent $Repository -Child $fullPath)) {
            throw "Submodule path escapes the workspace: $submodulePath"
        }
        [void](Assert-WorkspacePathChainSafe -Root $Repository -Target $fullPath -Purpose "submodule bootstrap for '$submodulePath'")

        $existingRepository = Test-WorkspaceSubmoduleRepository -Repository $Repository -Submodule $submodule -Path $fullPath
        if ($existingRepository) {
            $actual = ((Invoke-WorkspaceGit -Repository $fullPath -Arguments @('rev-parse', 'HEAD')).Output | Select-Object -Last 1).Trim().ToLowerInvariant()
            $dirty = @(Get-WorkspaceDirtyLines -Repository $fullPath)
            if ($actual -eq $expected) {
                $states.Add([pscustomobject]@{ Name = $submodule.Name; Path = $submodulePath; Expected = $expected; Actual = $actual; Dirty = $dirty.Count -gt 0; Source = 'existing' }) | Out-Null
                continue
            }
            if ($dirty.Count -gt 0) {
                throw "Submodule '$submodulePath' is dirty at $actual and cannot be moved to required gitlink $expected. HEAD and local files were preserved."
            }
            $stateSource = 'existing'
        }
        else {
            $payload = @(Get-WorkspacePathPayload -Path $fullPath)
            if ($payload.Count -gt 0) {
                throw "Submodule '$submodulePath' is not an initialized expected checkout and '$fullPath' contains payload. Refusing to update or overwrite it: $($payload -join ', ')"
            }
        }

        $update = Invoke-WorkspaceGit -Repository $Repository -Arguments @('-c', 'protocol.file.allow=always', 'submodule', 'update', '--init', '--checkout', '--', $submodulePath) -AllowFailure
        if ($update.ExitCode -ne 0) {
            if (Test-WorkspaceSubmoduleRepository -Repository $Repository -Submodule $submodule -Path $fullPath) {
                $actualResult = Invoke-WorkspaceGit -Repository $fullPath -Arguments @('rev-parse', 'HEAD') -AllowFailure
                $actual = if ($actualResult.ExitCode -eq 0) { ($actualResult.Output | Select-Object -Last 1).Trim().ToLowerInvariant() } else { '' }
                $dirty = @(Get-WorkspaceDirtyLines -Repository $fullPath)
                if ($actual -eq $expected) {
                    $states.Add([pscustomobject]@{ Name = $submodule.Name; Path = $submodulePath; Expected = $expected; Actual = $actual; Dirty = $dirty.Count -gt 0; Source = 'existing' }) | Out-Null
                    continue
                }
                if ($dirty.Count -gt 0) {
                    throw "Submodule '$submodulePath' is dirty at $actual and cannot be moved to required gitlink $expected. No files were removed."
                }
                [void](Invoke-WorkspaceGit -Repository $fullPath -Arguments @('checkout', '--detach', $expected))
            }
            else {
                $partialItems = @(Get-WorkspacePathPayload -Path $fullPath)
                if ($partialItems.Count -gt 0) {
                    throw "Submodule '$submodulePath' failed to initialize and '$fullPath' contains data. Refusing to delete or overwrite it: $($partialItems -join ', ')"
                }
                if (Test-Path -LiteralPath $fullPath -PathType Container) {
                    [void](Assert-WorkspacePathChainSafe -Root $Repository -Target $fullPath -Purpose "empty submodule fallback cleanup for '$submodulePath'")
                    Remove-Item -LiteralPath $fullPath -Force
                }
                elseif (Test-Path -LiteralPath $fullPath) {
                    throw "Submodule target '$fullPath' exists and is not a directory. Refusing to overwrite it."
                }

                $moduleStore = Get-WorkspaceSubmoduleStore -Repository $Repository -Name $submodule.Name
                if (-not (Test-Path -LiteralPath $moduleStore -PathType Container)) {
                    throw "Submodule '$submodulePath' could not be fetched and no local object store exists at '$moduleStore'."
                }
                $recheckedStore = Get-WorkspaceSubmoduleStore -Repository $Repository -Name $submodule.Name
                if (-not (Test-WorkspacePathEqual -Left $moduleStore -Right $recheckedStore)) {
                    throw "Submodule object-store path changed during fallback for '$submodulePath'."
                }
                $hasCommit = Invoke-WorkspaceGitRaw -Arguments @('--git-dir', $moduleStore, 'cat-file', '-e', "$expected`^{commit}") -AllowFailure
                if ($hasCommit.ExitCode -ne 0) {
                    throw "Local object store for '$submodulePath' does not contain required gitlink $expected."
                }
                [void](Get-WorkspaceSubmoduleStore -Repository $Repository -Name $submodule.Name)
                [void](Assert-WorkspacePathChainSafe -Root $Repository -Target $fullPath -Purpose "local submodule fallback for '$submodulePath'")
                [void](Invoke-WorkspaceGitRaw -Arguments @('--git-dir', $moduleStore, 'worktree', 'add', '--detach', $fullPath, $expected))
                $stateSource = 'local-object-store'
            }
        }

        if (-not (Test-WorkspaceSubmoduleRepository -Repository $Repository -Submodule $submodule -Path $fullPath)) {
            throw "Submodule '$submodulePath' is not initialized after bootstrap."
        }
        $actualResult = Invoke-WorkspaceGit -Repository $fullPath -Arguments @('rev-parse', 'HEAD')
        $actual = ($actualResult.Output | Select-Object -Last 1).Trim().ToLowerInvariant()
        if ($actual -ne $expected) {
            throw "Submodule '$submodulePath' resolved to $actual, expected exact gitlink $expected."
        }
        $dirty = @(Get-WorkspaceDirtyLines -Repository $fullPath)
        $states.Add([pscustomobject]@{ Name = $submodule.Name; Path = $submodulePath; Expected = $expected; Actual = $actual; Dirty = $dirty.Count -gt 0; Source = $stateSource }) | Out-Null
    }
    return @($states | ForEach-Object { $_ })
}

function Copy-WorkspaceAgentConfig {
    param(
        [Parameter(Mandatory = $true)][string]$SourceRoot,
        [Parameter(Mandatory = $true)][string]$TargetRoot
    )

    $source = Join-Path $SourceRoot 'AgentConfig.ini'
    $target = Join-Path $TargetRoot 'AgentConfig.ini'
    if (-not (Test-Path -LiteralPath $source -PathType Leaf) -or (Test-Path -LiteralPath $target -PathType Leaf)) {
        return $false
    }
    if ([System.IO.Path]::GetFullPath($source) -eq [System.IO.Path]::GetFullPath($target)) {
        return $false
    }

    $ignore = Invoke-WorkspaceGit -Repository $TargetRoot -Arguments @('check-ignore', '--quiet', '--', 'AgentConfig.ini') -AllowFailure
    if ($ignore.ExitCode -ne 0) {
        throw "Refusing to copy AgentConfig.ini because it is not ignored in '$TargetRoot'."
    }
    Copy-Item -LiteralPath $source -Destination $target
    return $true
}

function Get-PrimaryWorkspaceRoot {
    param([Parameter(Mandatory = $true)][string]$Repository)
    $result = Invoke-WorkspaceGit -Repository $Repository -Arguments @('worktree', 'list', '--porcelain')
    foreach ($line in $result.Output) {
        if ($line -like 'worktree *') {
            return [System.IO.Path]::GetFullPath($line.Substring(9).Trim())
        }
    }
    return $Repository
}

function Get-RegisteredWorkspaceRoots {
    param([Parameter(Mandatory = $true)][string]$Repository)
    $result = Invoke-WorkspaceGit -Repository $Repository -Arguments @('worktree', 'list', '--porcelain')
    return @($result.Output | ForEach-Object {
        if ($_ -like 'worktree *') {
            [System.IO.Path]::GetFullPath($_.Substring(9).Trim())
        }
    } | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
}

function Assert-WorkspaceIsCanonicalGoal {
    param([Parameter(Mandatory = $true)][string]$WorkspaceRoot)

    $root = Resolve-WorkspaceRepository -Path $WorkspaceRoot
    $primary = Get-PrimaryWorkspaceRoot -Repository $root
    if ([System.IO.Path]::GetFullPath($root) -eq [System.IO.Path]::GetFullPath($primary)) {
        throw "Refusing Goal lifecycle operation on the primary checkout '$root'. Use a registered Goal worktree."
    }
    $container = Join-Path $primary '.worktrees'
    if (-not (Test-WorkspacePathInside -Parent $container -Child $root)) {
        throw "Refusing Goal lifecycle operation outside the canonical '$container' directory: $root"
    }
    [void](Assert-WorkspacePathChainSafe -Root $primary -Target $root -Purpose 'Goal lifecycle operation')
    if ($root -notin @(Get-RegisteredWorkspaceRoots -Repository $primary)) {
        throw "Refusing Goal lifecycle operation on an unregistered worktree: $root"
    }
    return [pscustomobject]@{ Root = $root; PrimaryRoot = $primary; Container = $container }
}

function Get-HardnessWorkspaceStatus {
    [CmdletBinding()]
    param([string]$ProjectRoot = '')

    $root = Resolve-WorkspaceRepository -Path $ProjectRoot
    $branchResult = Invoke-WorkspaceGit -Repository $root -Arguments @('branch', '--show-current')
    $gitDirectory = (Invoke-WorkspaceGit -Repository $root -Arguments @('rev-parse', '--git-dir')).Output | Select-Object -Last 1
    $commonDirectory = (Invoke-WorkspaceGit -Repository $root -Arguments @('rev-parse', '--git-common-dir')).Output | Select-Object -Last 1
    $dirty = @(Get-WorkspaceDirtyLines -Repository $root)
    $submodules = New-Object System.Collections.Generic.List[object]
    foreach ($submodule in @(Get-WorkspaceSubmodules -Repository $root)) {
        $path = $submodule.Path
        $fullPath = [System.IO.Path]::GetFullPath((Join-Path $root $path))
        if (-not (Test-WorkspacePathInside -Parent $root -Child $fullPath)) {
            throw "Submodule path escapes the workspace: $path"
        }
        $expected = Get-WorkspaceGitlink -Repository $root -SubmodulePath $path
        if (Test-WorkspaceSubmoduleRepository -Repository $root -Submodule $submodule -Path $fullPath) {
            $actual = ((Invoke-WorkspaceGit -Repository $fullPath -Arguments @('rev-parse', 'HEAD')).Output | Select-Object -Last 1).Trim().ToLowerInvariant()
            $subDirty = @(Get-WorkspaceDirtyLines -Repository $fullPath)
            $submodules.Add([pscustomobject]@{ Name = $submodule.Name; Path = $path; Initialized = $true; Expected = $expected; Actual = $actual; Exact = $actual -eq $expected; Dirty = $subDirty.Count -gt 0; Payload = @() }) | Out-Null
        }
        else {
            $payload = @(Get-WorkspacePathPayload -Path $fullPath)
            $submodules.Add([pscustomobject]@{ Name = $submodule.Name; Path = $path; Initialized = $false; Expected = $expected; Actual = $null; Exact = $false; Dirty = $false; Payload = $payload }) | Out-Null
        }
    }

    return [pscustomobject]@{
        ProjectRoot = $root
        Branch      = [string](($branchResult.Output | Select-Object -Last 1).Trim())
        IsWorktree  = ([string]$gitDirectory).Trim() -ne ([string]$commonDirectory).Trim()
        Dirty       = $dirty.Count -gt 0
        Changes     = $dirty
        Submodules  = @($submodules | ForEach-Object { $_ })
    }
}

function New-HardnessWorkspace {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true)][ValidatePattern('^[A-Za-z0-9._-]{1,80}$')][string]$Name,
        [string]$Branch = '',
        [string]$RepositoryRoot = '',
        [string]$StartPoint = 'HEAD'
    )

    $requestedRepository = Resolve-WorkspaceRepository -Path $RepositoryRoot
    $repository = Get-PrimaryWorkspaceRoot -Repository $requestedRepository
    $branchName = if ([string]::IsNullOrWhiteSpace($Branch)) { "goal/$Name" } else { $Branch }
    $branchCheck = Invoke-WorkspaceGit -Repository $repository -Arguments @('check-ref-format', '--branch', $branchName) -AllowFailure
    if ($branchCheck.ExitCode -ne 0) {
        throw "Invalid worktree branch '$branchName'."
    }
    $branchExists = Invoke-WorkspaceGit -Repository $repository -Arguments @('show-ref', '--verify', '--quiet', "refs/heads/$branchName") -AllowFailure
    if ($branchExists.ExitCode -eq 0) {
        throw "Branch '$branchName' already exists."
    }

    $container = Join-Path $repository '.worktrees'
    $target = Join-Path $container $Name
    if (-not (Test-WorkspacePathInside -Parent $container -Child $target)) {
        throw "Worktree target escapes the canonical .worktrees directory: $target"
    }
    [void](Assert-WorkspacePathChainSafe -Root $repository -Target $target -Purpose 'workspace creation')
    if (Test-Path -LiteralPath $target) {
        throw "Worktree target already exists: $target"
    }
    $ignored = Invoke-WorkspaceGit -Repository $repository -Arguments @('check-ignore', '--quiet', '--', '.worktrees/__hardness_probe__') -AllowFailure
    if ($ignored.ExitCode -ne 0) {
        throw "'$container' is not ignored. Add .worktrees/ to .gitignore before creating a workspace."
    }

    $startCommitResult = Invoke-WorkspaceGit -Repository $requestedRepository -Arguments @('rev-parse', '--verify', "$StartPoint`^{commit}")
    $startCommit = ($startCommitResult.Output | Select-Object -Last 1).Trim()

    if (-not $PSCmdlet.ShouldProcess($target, "create branch '$branchName' from '$startCommit'")) {
        return [pscustomobject]@{ RepositoryRoot = $repository; WorktreeRoot = $target; Branch = $branchName; StartPoint = $startCommit; Created = $false; Mutates = $false }
    }
    if (-not (Test-Path -LiteralPath $container -PathType Container)) {
        [void](New-Item -ItemType Directory -Path $container)
    }
    [void](Assert-WorkspacePathChainSafe -Root $repository -Target $target -Purpose 'workspace creation')
    [void](Invoke-WorkspaceGit -Repository $repository -Arguments @('worktree', 'add', '-b', $branchName, $target, $startCommit))
    try {
        $configCopied = Copy-WorkspaceAgentConfig -SourceRoot $requestedRepository -TargetRoot $target
        $submodules = @(Initialize-WorkspaceSubmodules -Repository $target)
    }
    catch {
        throw "Workspace was created at '$target' but bootstrap failed; it was preserved for recovery. $($_.Exception.Message)"
    }
    return [pscustomobject]@{
        WorktreeRoot      = $target
        RepositoryRoot    = $repository
        Branch            = $branchName
        StartPoint        = $startCommit
        Created           = $true
        Mutates           = $true
        AgentConfigCopied = $configCopied
        Submodules        = $submodules
    }
}

function Initialize-HardnessWorkspace {
    [CmdletBinding()]
    param(
        [string]$ProjectRoot = '',
        [string]$SourceRoot = ''
    )

    $root = Resolve-WorkspaceRepository -Path $ProjectRoot
    $source = if ([string]::IsNullOrWhiteSpace($SourceRoot)) { Get-PrimaryWorkspaceRoot -Repository $root } else { Resolve-WorkspaceRepository -Path $SourceRoot }
    $copied = Copy-WorkspaceAgentConfig -SourceRoot $source -TargetRoot $root
    $submodules = @(Initialize-WorkspaceSubmodules -Repository $root)
    return [pscustomobject]@{ ProjectRoot = $root; SourceRoot = $source; AgentConfigCopied = $copied; Submodules = $submodules }
}

function Test-HardnessWorkspace {
    [CmdletBinding()]
    param(
        [string]$ProjectRoot = '',
        [switch]$RequireClean
    )

    $errors = New-Object System.Collections.Generic.List[string]
    $warnings = New-Object System.Collections.Generic.List[string]
    $status = Get-HardnessWorkspaceStatus -ProjectRoot $ProjectRoot
    foreach ($submodule in @($status.Submodules)) {
        if (-not $submodule.Initialized) {
            $payloadSuffix = if (@($submodule.Payload).Count -gt 0) { " Local payload is present: $(@($submodule.Payload) -join ', ')." } else { '' }
            $errors.Add("Submodule '$($submodule.Path)' is not initialized.$payloadSuffix") | Out-Null
        }
        elseif (-not $submodule.Exact) {
            $errors.Add("Submodule '$($submodule.Path)' is at $($submodule.Actual), expected $($submodule.Expected).") | Out-Null
        }
        if ($submodule.Dirty) {
            $warnings.Add("Submodule '$($submodule.Path)' has local changes.") | Out-Null
            if ($RequireClean) {
                $errors.Add("Submodule '$($submodule.Path)' has local changes.") | Out-Null
            }
        }
    }
    $configPath = Join-Path $status.ProjectRoot 'AgentConfig.ini'
    if (Test-Path -LiteralPath $configPath -PathType Leaf) {
        $ignored = Invoke-WorkspaceGit -Repository $status.ProjectRoot -Arguments @('check-ignore', '--quiet', '--', 'AgentConfig.ini') -AllowFailure
        if ($ignored.ExitCode -ne 0) {
            $errors.Add('AgentConfig.ini exists but is not ignored.') | Out-Null
        }
    }
    if ($RequireClean -and $status.Dirty) {
        $errors.Add('Workspace has uncommitted changes.') | Out-Null
    }
    return [pscustomobject]@{ IsValid = $errors.Count -eq 0; Errors = @($errors | ForEach-Object { $_ }); Warnings = @($warnings | ForEach-Object { $_ }); Status = $status }
}

function Complete-HardnessWorkspace {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [string]$ProjectRoot = '',
        [string]$CommitMessage = '[Harness] Chore: complete goal workspace',
        [string]$SubmoduleCommitMessage = '',
        [string]$SubmoduleBranch = ''
    )

    $goalWorkspace = Assert-WorkspaceIsCanonicalGoal -WorkspaceRoot (Resolve-WorkspaceRepository -Path $ProjectRoot)
    $root = $goalWorkspace.Root
    $parentBranchResult = Invoke-WorkspaceGit -Repository $root -Arguments @('branch', '--show-current')
    $parentBranch = ([string]($parentBranchResult.Output -join '')).Trim()
    if ([string]::IsNullOrWhiteSpace($parentBranch)) {
        throw 'Workspace is detached. Create a parent branch before finishing.'
    }
    $subMessage = if ([string]::IsNullOrWhiteSpace($SubmoduleCommitMessage)) { $CommitMessage } else { $SubmoduleCommitMessage }
    $subBranch = if ([string]::IsNullOrWhiteSpace($SubmoduleBranch)) { $parentBranch } else { $SubmoduleBranch }
    $branchCheck = Invoke-WorkspaceGit -Repository $root -Arguments @('check-ref-format', '--branch', $subBranch) -AllowFailure
    if ($branchCheck.ExitCode -ne 0) {
        throw "Invalid submodule goal branch '$subBranch'."
    }
    $submoduleCommits = New-Object System.Collections.Generic.List[object]
    $submodulePlans = New-Object System.Collections.Generic.List[object]

    foreach ($submodule in @(Get-WorkspaceSubmodules -Repository $root)) {
        $path = $submodule.Path
        $fullPath = Join-Path $root $path
        if (-not (Test-WorkspaceSubmoduleRepository -Repository $root -Submodule $submodule -Path $fullPath)) {
            throw "Cannot finish: submodule '$path' is not initialized."
        }

        $expected = Get-WorkspaceGitlink -Repository $root -SubmodulePath $path
        $actual = ((Invoke-WorkspaceGit -Repository $fullPath -Arguments @('rev-parse', 'HEAD')).Output | Select-Object -Last 1).Trim().ToLowerInvariant()
        $dirty = @(Get-WorkspaceDirtyLines -Repository $fullPath)
        $currentBranch = ([string](((Invoke-WorkspaceGit -Repository $fullPath -Arguments @('branch', '--show-current')).Output) -join '')).Trim()
        $branchExistsResult = Invoke-WorkspaceGit -Repository $fullPath -Arguments @('show-ref', '--verify', '--quiet', "refs/heads/$subBranch") -AllowFailure
        $branchExists = $branchExistsResult.ExitCode -eq 0

        if ($actual -ne $expected) {
            if ($currentBranch -ne $subBranch) {
                throw "Submodule '$path' is at $actual instead of parent gitlink $expected and is not on the dedicated branch '$subBranch'."
            }
            $ancestor = Invoke-WorkspaceGit -Repository $fullPath -Arguments @('merge-base', '--is-ancestor', $expected, $actual) -AllowFailure
            if ($ancestor.ExitCode -ne 0) {
                throw "Submodule '$path' branch '$subBranch' does not descend from required gitlink $expected."
            }
        }

        if ($dirty.Count -gt 0 -and -not [string]::IsNullOrWhiteSpace($currentBranch) -and $currentBranch -ne $subBranch) {
            throw "Submodule '$path' is dirty on branch '$currentBranch'. Finish only commits the dedicated Goal branch '$subBranch'."
        }

        if ($dirty.Count -gt 0 -and [string]::IsNullOrWhiteSpace($currentBranch) -and $branchExists) {
            $branchCommit = ((Invoke-WorkspaceGit -Repository $fullPath -Arguments @('rev-parse', "refs/heads/$subBranch")).Output | Select-Object -Last 1).Trim().ToLowerInvariant()
            if ($branchCommit -ne $actual) {
                throw "Existing submodule branch '$subBranch' for '$path' points to different commit $branchCommit; current exact checkout is $actual."
            }
            $branchLine = "branch refs/heads/$subBranch"
            $occupied = @((Invoke-WorkspaceGit -Repository $fullPath -Arguments @('worktree', 'list', '--porcelain')).Output | Where-Object { $_ -eq $branchLine })
            if ($occupied.Count -gt 0) {
                throw "Existing submodule branch '$subBranch' for '$path' is already checked out by another worktree."
            }
        }

        $submodulePlans.Add([pscustomobject]@{
            Name          = $submodule.Name
            Path          = $path
            FullPath      = $fullPath
            Expected      = $expected
            Actual        = $actual
            Dirty         = $dirty.Count -gt 0
            CurrentBranch = $currentBranch
            BranchExists  = $branchExists
        }) | Out-Null
    }

    if ($WhatIfPreference) {
        $preview = Get-HardnessWorkspaceStatus -ProjectRoot $root
        return [pscustomobject]@{
            ProjectRoot          = $root
            Branch               = $parentBranch
            ParentCommit         = $null
            SubmoduleCommits     = @()
            WouldCommitParent    = $preview.Dirty
            WouldCommitSubmodule = @($submodulePlans | Where-Object Dirty | ForEach-Object Path)
            GitStateComplete     = $false
        }
    }

    foreach ($plan in @($submodulePlans | ForEach-Object { $_ })) {
        if (-not $plan.Dirty) {
            continue
        }
        if ($PSCmdlet.ShouldProcess($plan.Path, 'commit submodule changes before the parent gitlink')) {
            if ([string]::IsNullOrWhiteSpace($plan.CurrentBranch)) {
                if ($plan.BranchExists) {
                    [void](Invoke-WorkspaceGit -Repository $plan.FullPath -Arguments @('checkout', $subBranch))
                }
                else {
                    [void](Invoke-WorkspaceGit -Repository $plan.FullPath -Arguments @('checkout', '-b', $subBranch))
                }
            }
            [void](Invoke-WorkspaceGit -Repository $plan.FullPath -Arguments @('add', '-A'))
            [void](Invoke-WorkspaceGit -Repository $plan.FullPath -Arguments @('commit', '-m', $subMessage))
            $commit = ((Invoke-WorkspaceGit -Repository $plan.FullPath -Arguments @('rev-parse', 'HEAD')).Output | Select-Object -Last 1).Trim()
            $submoduleCommits.Add([pscustomobject]@{ Path = $plan.Path; Commit = $commit }) | Out-Null
        }
    }

    $parentCommit = $null
    $parentNeedsCommit = @(Get-WorkspaceDirtyLines -Repository $root).Count -gt 0 -or $submoduleCommits.Count -gt 0
    if ($parentNeedsCommit -and $PSCmdlet.ShouldProcess($root, 'commit parent changes and updated gitlinks')) {
        [void](Invoke-WorkspaceGit -Repository $root -Arguments @('add', '-A'))
        $staged = Invoke-WorkspaceGit -Repository $root -Arguments @('diff', '--cached', '--quiet') -AllowFailure
        if ($staged.ExitCode -eq 1) {
            [void](Invoke-WorkspaceGit -Repository $root -Arguments @('commit', '-m', $CommitMessage))
            $parentCommit = ((Invoke-WorkspaceGit -Repository $root -Arguments @('rev-parse', 'HEAD')).Output | Select-Object -Last 1).Trim()
        }
        elseif ($staged.ExitCode -ne 0) {
            throw "Unable to inspect staged workspace changes: $($staged.Output -join [Environment]::NewLine)"
        }
    }
    $verification = Test-HardnessWorkspace -ProjectRoot $root -RequireClean
    if (-not $verification.IsValid) {
        throw "Workspace finish verification failed: $($verification.Errors -join '; ')"
    }
    return [pscustomobject]@{ ProjectRoot = $root; Branch = $parentBranch; ParentCommit = $parentCommit; SubmoduleCommits = @($submoduleCommits | ForEach-Object { $_ }); GitStateComplete = $true }
}

function Remove-HardnessWorkspace {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    param(
        [Parameter(Mandatory = $true)][string]$WorktreeRoot,
        [string]$RepositoryRoot = '',
        [switch]$DiscardIgnoredFiles
    )

    $requestedRepository = Resolve-WorkspaceRepository -Path $RepositoryRoot
    $repository = Get-PrimaryWorkspaceRoot -Repository $requestedRepository
    $target = (Resolve-Path -LiteralPath $WorktreeRoot -ErrorAction Stop).Path
    $container = Join-Path $repository '.worktrees'
    if (-not (Test-WorkspacePathInside -Parent $container -Child $target)) {
        throw "Refusing to remove '$target': target is outside '$container'."
    }
    [void](Assert-WorkspacePathChainSafe -Root $repository -Target $target -Purpose 'workspace removal')
    if ([System.IO.Path]::GetFullPath($target) -eq [System.IO.Path]::GetFullPath($repository)) {
        throw 'Refusing to remove the primary repository checkout.'
    }

    $registered = @(Get-RegisteredWorkspaceRoots -Repository $repository)
    if ($target -notin $registered) {
        throw "Refusing to remove '$target': it is not a registered Git worktree."
    }
    $verification = Test-HardnessWorkspace -ProjectRoot $target -RequireClean
    $status = $verification.Status
    if (-not $verification.IsValid) {
        throw "Refusing to remove invalid or dirty worktree '$target': $($verification.Errors -join '; ')"
    }

    $ignoredFiles = New-Object System.Collections.Generic.List[string]
    foreach ($line in @(Get-WorkspaceIgnoredLines -Repository $target)) {
        $ignoredFiles.Add($line.Substring(3)) | Out-Null
    }
    foreach ($submodule in @($status.Submodules | Where-Object Initialized)) {
        $submoduleRoot = Join-Path $target $submodule.Path
        foreach ($line in @(Get-WorkspaceIgnoredLines -Repository $submoduleRoot)) {
            $ignoredFiles.Add("$($submodule.Path)/$($line.Substring(3))") | Out-Null
        }
    }
    if ($ignoredFiles.Count -gt 0 -and -not $DiscardIgnoredFiles) {
        throw "Refusing to remove worktree '$target' because it contains ignored local data. Review it and rerun with -DiscardIgnoredFiles only when deletion is intended: $($ignoredFiles -join ', ')"
    }
    if ($PSCmdlet.ShouldProcess($target, 'remove clean registered worktree; preserve branch')) {
        [void](Assert-WorkspacePathChainSafe -Root $repository -Target $target -Purpose 'workspace removal')
        # Git requires --force for any worktree that has ever initialized a
        # submodule. The explicit clean checks above are the safety gate; this
        # flag only bypasses Git's structural submodule refusal.
        [void](Invoke-WorkspaceGit -Repository $repository -Arguments @('worktree', 'remove', '--force', $target))
    }
    return [pscustomobject]@{ WorktreeRoot = $target; Removed = -not (Test-Path -LiteralPath $target); BranchPreserved = $true; DiscardedIgnoredFiles = @($ignoredFiles | ForEach-Object { $_ }) }
}

Export-ModuleMember -Function @(
    'Get-HardnessWorkspaceStatus',
    'New-HardnessWorkspace',
    'Initialize-HardnessWorkspace',
    'Test-HardnessWorkspace',
    'Complete-HardnessWorkspace',
    'Remove-HardnessWorkspace'
)
