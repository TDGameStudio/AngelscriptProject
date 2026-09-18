#requires -Version 7.0
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
if (Test-Path (Join-Path $PSScriptRoot 'WorkspaceReplica.ps1')) { . (Join-Path $PSScriptRoot 'WorkspaceReplica.ps1') }

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
        $selected = [Environment]::GetEnvironmentVariable('HARNESS_WORKSPACE_ROOT', 'Process')
        if ([string]::IsNullOrWhiteSpace($selected)) { Get-WorkspaceRepositoryRootFromModule } else { $selected }
    }
    else {
        $Path
    }
    $resolved = (Resolve-Path -LiteralPath $candidate -ErrorAction Stop).Path
    if (Get-Command Find-WorkspaceReplicaRoot -ErrorAction SilentlyContinue) {
        $replicaRoot = Find-WorkspaceReplicaRoot $resolved
        if ($replicaRoot) { return $replicaRoot }
    }
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

function Assert-WorkspaceExistingPathSafe {
    param(
        [Parameter(Mandatory = $true)][string]$Target,
        [string]$Purpose = 'workspace operation'
    )

    $targetPath = [System.IO.Path]::GetFullPath($Target).TrimEnd('\', '/')
    $root = [System.IO.Path]::GetPathRoot($targetPath)
    $relative = $targetPath.Substring($root.Length).TrimStart('\', '/')
    $current = $root
    foreach ($segment in @($relative -split '[\\/]')) {
        if ([string]::IsNullOrWhiteSpace($segment)) { continue }
        $current = Join-Path $current $segment
        $item = Get-Item -LiteralPath $current -Force -ErrorAction SilentlyContinue
        if ($null -eq $item) { break }
        if (($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0) {
            throw "Refusing $Purpose because the physical path chain contains reparse point '$current'."
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

function Assert-WorkspaceIniName {
    param(
        [Parameter(Mandatory = $true)][string]$Value,
        [Parameter(Mandatory = $true)][string]$Kind
    )
    if ($Value -notmatch '^[A-Za-z][A-Za-z0-9_.-]{0,63}$') {
        throw "Invalid AgentConfig.ini $Kind '$Value'. Use 1-64 ASCII letters, digits, dots, underscores, or hyphens and start with a letter."
    }
    return $Value
}

function Get-WorkspaceIniValue {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$Section,
        [Parameter(Mandatory = $true)][string]$Key
    )
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        return $null
    }
    $activeSection = ''
    foreach ($line in [System.IO.File]::ReadAllLines($Path)) {
        $trimmed = $line.Trim()
        if ($trimmed -match '^\[([^]]+)\]$') {
            $activeSection = $matches[1].Trim()
            continue
        }
        if (-not $activeSection.Equals($Section, [System.StringComparison]::OrdinalIgnoreCase) -or
            [string]::IsNullOrWhiteSpace($trimmed) -or $trimmed.StartsWith(';') -or $trimmed.StartsWith('#')) {
            continue
        }
        $separator = $line.IndexOf('=')
        if ($separator -lt 0) { continue }
        $candidateKey = $line.Substring(0, $separator).Trim()
        if ($candidateKey.Equals($Key, [System.StringComparison]::OrdinalIgnoreCase)) {
            return $line.Substring($separator + 1).Trim()
        }
    }
    return $null
}

function Get-WorkspaceIniKeyNames {
    param([Parameter(Mandatory = $true)][string]$Path)
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { return @() }
    $activeSection = ''
    $keys = New-Object System.Collections.Generic.List[string]
    foreach ($line in [System.IO.File]::ReadAllLines($Path)) {
        $trimmed = $line.Trim()
        if ($trimmed -match '^\[([^]]+)\]$') {
            $activeSection = $matches[1].Trim()
            continue
        }
        if ([string]::IsNullOrWhiteSpace($activeSection) -or [string]::IsNullOrWhiteSpace($trimmed) -or
            $trimmed.StartsWith(';') -or $trimmed.StartsWith('#')) { continue }
        $separator = $line.IndexOf('=')
        if ($separator -lt 0) { continue }
        $key = $line.Substring(0, $separator).Trim()
        if (-not [string]::IsNullOrWhiteSpace($key)) {
            $keys.Add("$activeSection.$key") | Out-Null
        }
    }
    return @($keys | Sort-Object -Unique)
}

function Test-WorkspaceIniSection {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$Section
    )
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { return $false }
    foreach ($line in [System.IO.File]::ReadAllLines($Path)) {
        if ($line.Trim() -match '^\[([^]]+)\]$' -and
            $matches[1].Trim().Equals($Section, [System.StringComparison]::OrdinalIgnoreCase)) {
            return $true
        }
    }
    return $false
}

function Rename-WorkspaceIniSection {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$From,
        [Parameter(Mandatory = $true)][string]$To
    )
    [void](Assert-WorkspaceIniName -Value $From -Kind 'section')
    [void](Assert-WorkspaceIniName -Value $To -Kind 'section')
    if (-not (Test-WorkspaceIniSection -Path $Path -Section $From)) { return $false }
    if (Test-WorkspaceIniSection -Path $Path -Section $To) {
        throw "AgentConfig.ini contains both [$From] and [$To]; refusing to merge managed workspace identity."
    }

    $raw = [System.IO.File]::ReadAllText($Path)
    $newLine = if ($raw.Contains("`r`n")) { "`r`n" } else { "`n" }
    $lines = @([regex]::Split($raw, '\r?\n'))
    $renamed = $false
    for ($index = 0; $index -lt $lines.Count; $index++) {
        if ($lines[$index].Trim() -match '^\[([^]]+)\]$' -and
            $matches[1].Trim().Equals($From, [System.StringComparison]::OrdinalIgnoreCase)) {
            $lines[$index] = "[$To]"
            $renamed = $true
            break
        }
    }
    if (-not $renamed) { return $false }
    $text = $lines -join $newLine
    $directory = Split-Path -Parent $Path
    $temporary = Join-Path $directory ('.AgentConfig.{0}.tmp' -f [guid]::NewGuid().ToString('N'))
    try {
        [System.IO.File]::WriteAllText($temporary, $text, [System.Text.UTF8Encoding]::new($false))
        [System.IO.File]::Move($temporary, $Path, $true)
    }
    finally {
        if (Test-Path -LiteralPath $temporary -PathType Leaf) { Remove-Item -LiteralPath $temporary -Force }
    }
    return $true
}

function Set-WorkspaceIniValueInternal {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$Section,
        [Parameter(Mandatory = $true)][string]$Key,
        [AllowEmptyString()][Parameter(Mandatory = $true)][string]$Value
    )
    [void](Assert-WorkspaceIniName -Value $Section -Kind 'section')
    [void](Assert-WorkspaceIniName -Value $Key -Kind 'key')
    if ($Value.Contains("`r") -or $Value.Contains("`n") -or $Value.Contains([char]0)) {
        throw 'AgentConfig.ini values must be single-line text without NUL characters.'
    }

    $raw = if (Test-Path -LiteralPath $Path -PathType Leaf) { [System.IO.File]::ReadAllText($Path) } else { '' }
    $newLine = if ($raw.Contains("`r`n")) { "`r`n" } else { "`n" }
    $hadTrailingNewLine = $raw.EndsWith("`n")
    $sourceLines = @()
    if (-not [string]::IsNullOrEmpty($raw)) {
        $sourceLines = @([regex]::Split($raw, '\r?\n'))
    }
    if ($sourceLines.Count -gt 0 -and $sourceLines[-1] -eq '' -and $hadTrailingNewLine) {
        $sourceLines = if ($sourceLines.Count -eq 1) { @() } else { @($sourceLines[0..($sourceLines.Count - 2)]) }
    }
    $lines = New-Object System.Collections.Generic.List[string]
    foreach ($line in $sourceLines) { $lines.Add([string]$line) | Out-Null }

    $sectionStart = -1
    $sectionEnd = $lines.Count
    for ($index = 0; $index -lt $lines.Count; $index++) {
        $trimmed = $lines[$index].Trim()
        if ($trimmed -match '^\[([^]]+)\]$') {
            if ($sectionStart -ge 0) {
                $sectionEnd = $index
                break
            }
            if ($matches[1].Trim().Equals($Section, [System.StringComparison]::OrdinalIgnoreCase)) {
                $sectionStart = $index
            }
        }
    }

    if ($sectionStart -lt 0) {
        if ($lines.Count -gt 0 -and -not [string]::IsNullOrWhiteSpace($lines[$lines.Count - 1])) {
            $lines.Add('') | Out-Null
        }
        $lines.Add("[$Section]") | Out-Null
        $lines.Add("$Key=$Value") | Out-Null
    }
    else {
        $keyIndex = -1
        for ($index = $sectionStart + 1; $index -lt $sectionEnd; $index++) {
            $line = $lines[$index]
            $trimmed = $line.Trim()
            if ([string]::IsNullOrWhiteSpace($trimmed) -or $trimmed.StartsWith(';') -or $trimmed.StartsWith('#')) { continue }
            $separator = $line.IndexOf('=')
            if ($separator -lt 0) { continue }
            if ($line.Substring(0, $separator).Trim().Equals($Key, [System.StringComparison]::OrdinalIgnoreCase)) {
                $keyIndex = $index
                break
            }
        }
        if ($keyIndex -ge 0) {
            $lines[$keyIndex] = "$Key=$Value"
        }
        else {
            $lines.Insert($sectionEnd, "$Key=$Value")
        }
    }

    $directory = Split-Path -Parent $Path
    if (-not (Test-Path -LiteralPath $directory -PathType Container)) {
        throw "AgentConfig.ini target directory does not exist: $directory"
    }
    $text = (@($lines) -join $newLine) + $newLine
    $temporary = Join-Path $directory ('.AgentConfig.{0}.tmp' -f [guid]::NewGuid().ToString('N'))
    $encoding = New-Object System.Text.UTF8Encoding($false)
    try {
        [System.IO.File]::WriteAllText($temporary, $text, $encoding)
        [System.IO.File]::Move($temporary, $Path, $true)
    }
    finally {
        if (Test-Path -LiteralPath $temporary -PathType Leaf) {
            Remove-Item -LiteralPath $temporary -Force
        }
    }
}

function Update-WorkspaceIniDocument {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [object[]]$Updates = @(),
        [object[]]$Removals = @()
    )

    foreach ($operation in @($Updates) + @($Removals)) {
        [void](Assert-WorkspaceIniName -Value ([string]$operation.Section) -Kind 'section')
        [void](Assert-WorkspaceIniName -Value ([string]$operation.Key) -Kind 'key')
    }
    foreach ($update in @($Updates)) {
        $value = [string]$update.Value
        if ($value.Contains("`r") -or $value.Contains("`n") -or $value.Contains([char]0)) {
            throw 'AgentConfig.ini values must be single-line text without NUL characters.'
        }
    }

    $raw = if (Test-Path -LiteralPath $Path -PathType Leaf) { [System.IO.File]::ReadAllText($Path) } else { '' }
    $newLine = if ($raw.Contains("`r`n")) { "`r`n" } else { "`n" }
    $sourceLines = @()
    if (-not [string]::IsNullOrEmpty($raw)) {
        $sourceLines = @([regex]::Split($raw, '\r?\n'))
    }
    if ($sourceLines.Count -gt 0 -and $sourceLines[-1] -eq '' -and $raw.EndsWith("`n")) {
        $sourceLines = if ($sourceLines.Count -eq 1) { @() } else { @($sourceLines[0..($sourceLines.Count - 2)]) }
    }

    $managedKeys = @($Updates) + @($Removals)
    $lines = New-Object System.Collections.Generic.List[string]
    $activeSection = ''
    foreach ($line in $sourceLines) {
        $trimmed = $line.Trim()
        if ($trimmed -match '^\[([^]]+)\]$') {
            $activeSection = $matches[1].Trim()
            $lines.Add([string]$line) | Out-Null
            continue
        }
        $removeLine = $false
        if (-not [string]::IsNullOrWhiteSpace($activeSection) -and
            -not [string]::IsNullOrWhiteSpace($trimmed) -and
            -not $trimmed.StartsWith(';') -and -not $trimmed.StartsWith('#')) {
            $separator = $line.IndexOf('=')
            if ($separator -ge 0) {
                $candidateKey = $line.Substring(0, $separator).Trim()
                foreach ($managedKey in $managedKeys) {
                    if ($activeSection.Equals([string]$managedKey.Section, [System.StringComparison]::OrdinalIgnoreCase) -and
                        $candidateKey.Equals([string]$managedKey.Key, [System.StringComparison]::OrdinalIgnoreCase)) {
                        $removeLine = $true
                        break
                    }
                }
            }
        }
        if (-not $removeLine) { $lines.Add([string]$line) | Out-Null }
    }

    foreach ($update in @($Updates)) {
        $section = [string]$update.Section
        $key = [string]$update.Key
        $value = [string]$update.Value
        $sectionStart = -1
        $sectionEnd = $lines.Count
        for ($index = 0; $index -lt $lines.Count; $index++) {
            $trimmed = $lines[$index].Trim()
            if ($trimmed -match '^\[([^]]+)\]$') {
                if ($sectionStart -ge 0) {
                    $sectionEnd = $index
                    break
                }
                if ($matches[1].Trim().Equals($section, [System.StringComparison]::OrdinalIgnoreCase)) {
                    $sectionStart = $index
                }
            }
        }
        if ($sectionStart -lt 0) {
            if ($lines.Count -gt 0 -and -not [string]::IsNullOrWhiteSpace($lines[$lines.Count - 1])) {
                $lines.Add('') | Out-Null
            }
            $lines.Add("[$section]") | Out-Null
            $lines.Add("$key=$value") | Out-Null
        }
        else {
            $lines.Insert($sectionEnd, "$key=$value")
        }
    }

    $directory = Split-Path -Parent $Path
    if (-not (Test-Path -LiteralPath $directory -PathType Container)) {
        throw "AgentConfig.ini target directory does not exist: $directory"
    }
    $text = (@($lines) -join $newLine) + $newLine
    $temporary = Join-Path $directory ('.AgentConfig.{0}.tmp' -f [guid]::NewGuid().ToString('N'))
    $encoding = New-Object System.Text.UTF8Encoding($false)
    try {
        [System.IO.File]::WriteAllText($temporary, $text, $encoding)
        [System.IO.File]::Move($temporary, $Path, $true)
    }
    finally {
        if (Test-Path -LiteralPath $temporary -PathType Leaf) {
            Remove-Item -LiteralPath $temporary -Force
        }
    }
}

function Test-WorkspaceManagedIdentity {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)]$Identity
    )

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { return $false }
    foreach ($entry in @(
        @('SchemaVersion', '3'),
        @('WorkspaceRoot', $Identity.WorkspaceRoot),
        @('PrimaryRoot', $Identity.PrimaryRoot),
        @('GitCommonDir', $Identity.GitCommonDir)
    )) {
        $actual = Get-WorkspaceIniValue -Path $Path -Section 'Harness' -Key $entry[0]
        if ([string]::IsNullOrWhiteSpace([string]$actual)) { return $false }
        $matches = if ($entry[0] -in @('WorkspaceRoot', 'PrimaryRoot', 'GitCommonDir')) {
            Test-WorkspacePathEqual -Left $actual -Right ([string]$entry[1])
        }
        else {
            ([string]$actual).Equals([string]$entry[1], [System.StringComparison]::OrdinalIgnoreCase)
        }
        if (-not $matches) { return $false }
    }
    if ($null -ne (Get-WorkspaceIniValue -Path $Path -Section 'Harness' -Key 'WorkspaceKind')) { return $false }
    if ($null -ne (Get-WorkspaceIniValue -Path $Path -Section 'Harness' -Key 'GoalName')) { return $false }
    if ($null -ne (Get-WorkspaceIniValue -Path $Path -Section 'References' -Key 'HazelightAngelscriptEngineRoot')) { return $false }
    return $true
}

function New-WorkspaceIdentityFromRegistration {
    param(
        [Parameter(Mandatory = $true)]$Registration,
        [Parameter(Mandatory = $true)][string]$GitCommonDir
    )

    $identity = [pscustomobject][ordered]@{
        SchemaVersion = '3'
        HarnessRoot   = [System.IO.Path]::GetFullPath((Get-WorkspaceRepositoryRootFromModule))
        WorkspaceRoot = [System.IO.Path]::GetFullPath($Registration.WorkspaceRoot)
        PrimaryRoot   = [System.IO.Path]::GetFullPath($Registration.PrimaryRoot)
        GitCommonDir  = [System.IO.Path]::GetFullPath($GitCommonDir)
        Topology      = $Registration.Topology
        WorktreeName  = $Registration.WorktreeName
        Branch        = $Registration.Branch
        Head          = $Registration.Head
        Managed       = $false
        WorkspaceId   = 'git_' + [BitConverter]::ToString([Security.Cryptography.SHA256]::Create().ComputeHash([Text.Encoding]::UTF8.GetBytes($Registration.WorkspaceRoot.ToLowerInvariant()))).Replace('-', '').Substring(0, 32).ToLowerInvariant()
        OpenSpecRoot  = [System.IO.Path]::GetFullPath($Registration.WorkspaceRoot)
        Repositories  = @{}
    }
    $identity.Managed = Test-WorkspaceManagedIdentity -Path (Join-Path $identity.WorkspaceRoot 'AgentConfig.ini') -Identity $identity
    return $identity
}

function Get-WorkspaceIdentity {
    param([string]$ProjectRoot = '')

    $root = Resolve-WorkspaceRepository -Path $ProjectRoot
    if (Test-Path (Join-Path $root '.harness/workspace.json')) { return Get-WorkspaceReplicaIdentity $root }
    $registrations = @(Get-WorkspaceRegistrationRecords -Repository $root)
    $record = @($registrations | Where-Object { Test-WorkspacePathEqual -Left $_.WorkspaceRoot -Right $root })
    if ($record.Count -ne 1) {
        throw "Workspace is not registered with Git: $root"
    }
    $commonDirectory = Get-WorkspaceCommonGitDirectory -Repository $root
    return New-WorkspaceIdentityFromRegistration -Registration $record[0] -GitCommonDir $commonDirectory
}

function Get-HarnessWorkspaceContext {
    [CmdletBinding()]
    param(
        [Alias('WorkspaceRoot')][string]$ProjectRoot = '',
        [switch]$Refresh
    )

    if ($Refresh) { [void](Clear-HarnessWorkspaceCache) }
    return Get-WorkspaceIdentity -ProjectRoot $ProjectRoot
}

function Get-WorkspaceProjectFile {
    param([Parameter(Mandatory = $true)][string]$ProjectRoot)
    $files = @(Get-ChildItem -LiteralPath $ProjectRoot -Filter '*.uproject' -File -ErrorAction Stop)
    if ($files.Count -ne 1) {
        throw "Expected exactly one .uproject file at workspace root '$ProjectRoot'; found $($files.Count)."
    }
    return [System.IO.Path]::GetFullPath($files[0].FullName)
}

function Set-WorkspaceManagedConfiguration {
    param(
        [Parameter(Mandatory = $true)][string]$ProjectRoot,
        [string]$SourceRoot = ''
    )
    $root = Resolve-WorkspaceRepository -Path $ProjectRoot
    $identity = Get-WorkspaceIdentity -ProjectRoot $root
    $target = Join-Path $root 'AgentConfig.ini'
    $ignore = Invoke-WorkspaceGit -Repository $root -Arguments @('check-ignore', '--quiet', '--', 'AgentConfig.ini') -AllowFailure
    if ($ignore.ExitCode -ne 0) {
        throw "Refusing to materialize AgentConfig.ini because it is not ignored in '$root'."
    }

    $copied = $false
    if (-not (Test-Path -LiteralPath $target -PathType Leaf)) {
        $source = if ([string]::IsNullOrWhiteSpace($SourceRoot)) { Join-Path $identity.PrimaryRoot 'AgentConfig.ini' } else { Join-Path ([System.IO.Path]::GetFullPath($SourceRoot)) 'AgentConfig.ini' }
        if ((Test-Path -LiteralPath $source -PathType Leaf) -and -not (Test-WorkspacePathEqual -Left $source -Right $target)) {
            Copy-Item -LiteralPath $source -Destination $target
            $copied = $true
        }
    }

    if (Test-WorkspaceIniSection -Path $target -Section 'Hardness') {
        $legacySchema = Get-WorkspaceIniValue -Path $target -Section 'Hardness' -Key 'SchemaVersion'
        if ([string]$legacySchema -cne '2') {
            throw "AgentConfig.ini [Hardness] uses unsupported schema '$legacySchema'; only schema v2 can migrate through workspace.bootstrap."
        }
        [void](Rename-WorkspaceIniSection -Path $target -From 'Hardness' -To 'Harness')
    }

    $projectFile = Get-WorkspaceProjectFile -ProjectRoot $root
    $updates = @(
        [pscustomobject]@{ Section = 'Paths'; Key = 'ProjectFile'; Value = $projectFile },
        [pscustomobject]@{ Section = 'Harness'; Key = 'SchemaVersion'; Value = $identity.SchemaVersion },
        [pscustomobject]@{ Section = 'Harness'; Key = 'WorkspaceRoot'; Value = $identity.WorkspaceRoot },
        [pscustomobject]@{ Section = 'Harness'; Key = 'PrimaryRoot'; Value = $identity.PrimaryRoot },
        [pscustomobject]@{ Section = 'Harness'; Key = 'GitCommonDir'; Value = $identity.GitCommonDir }
    )
    $removals = @(
        [pscustomobject]@{ Section = 'Harness'; Key = 'WorkspaceKind' },
        [pscustomobject]@{ Section = 'Harness'; Key = 'GoalName' },
        [pscustomobject]@{ Section = 'References'; Key = 'HazelightAngelscriptEngineRoot' }
    )
    Update-WorkspaceIniDocument -Path $target -Updates $updates -Removals $removals
    $identity = Get-WorkspaceIdentity -ProjectRoot $root
    return [pscustomobject]@{ Path = $target; Copied = $copied; Identity = $identity; ProjectFile = $projectFile }
}

function Get-HarnessWorkspaceConfigStatus {
    [CmdletBinding()]
    param([Alias('WorkspaceRoot')][string]$ProjectRoot = '')
    $identity = Get-WorkspaceIdentity -ProjectRoot $ProjectRoot
    $root = $identity.WorkspaceRoot
    $path = Join-Path $root 'AgentConfig.ini'
    $errors = New-Object System.Collections.Generic.List[string]
    $exists = Test-Path -LiteralPath $path -PathType Leaf
    $ignored = $false
    if (-not $exists) {
        $errors.Add('AgentConfig.ini is missing.') | Out-Null
    }
    else {
        $ignored = (Invoke-WorkspaceGit -Repository $root -Arguments @('check-ignore', '--quiet', '--', 'AgentConfig.ini') -AllowFailure).ExitCode -eq 0
        if (-not $ignored) { $errors.Add('AgentConfig.ini exists but is not ignored.') | Out-Null }
        if (Test-WorkspaceIniSection -Path $path -Section 'Hardness') {
            $legacySchema = Get-WorkspaceIniValue -Path $path -Section 'Hardness' -Key 'SchemaVersion'
            $errors.Add("AgentConfig.ini contains legacy [Hardness] schema v$legacySchema; run workspace.bootstrap to migrate it to [Harness] schema v3.") | Out-Null
        }
        foreach ($entry in @(
            @('SchemaVersion', $identity.SchemaVersion),
            @('WorkspaceRoot', $identity.WorkspaceRoot),
            @('PrimaryRoot', $identity.PrimaryRoot),
            @('GitCommonDir', $identity.GitCommonDir)
        )) {
            $actual = Get-WorkspaceIniValue -Path $path -Section 'Harness' -Key $entry[0]
            $expected = [string]$entry[1]
            $matches = if ($entry[0] -in @('PrimaryRoot', 'WorkspaceRoot', 'GitCommonDir')) {
                -not [string]::IsNullOrWhiteSpace([string]$actual) -and (Test-WorkspacePathEqual -Left $actual -Right $expected)
            }
            else { ([string]$actual).Equals($expected, [System.StringComparison]::OrdinalIgnoreCase) }
            if (-not $matches) { $errors.Add("AgentConfig.ini [Harness] $($entry[0]) does not match this workspace.") | Out-Null }
        }
        foreach ($obsoleteKey in @('WorkspaceKind', 'GoalName')) {
            if ($null -ne (Get-WorkspaceIniValue -Path $path -Section 'Harness' -Key $obsoleteKey)) {
                $errors.Add("AgentConfig.ini [Harness] $obsoleteKey is obsolete in schema v3.") | Out-Null
            }
        }
        if ($null -ne (Get-WorkspaceIniValue -Path $path -Section 'References' -Key 'HazelightAngelscriptEngineRoot')) {
            $errors.Add('AgentConfig.ini [References] HazelightAngelscriptEngineRoot is obsolete; run workspace.bootstrap to remove it.') | Out-Null
        }
        $expectedProject = Get-WorkspaceProjectFile -ProjectRoot $root
        $configuredProject = Get-WorkspaceIniValue -Path $path -Section 'Paths' -Key 'ProjectFile'
        if ([string]::IsNullOrWhiteSpace([string]$configuredProject) -or -not (Test-WorkspacePathEqual -Left $configuredProject -Right $expectedProject)) {
            $errors.Add('AgentConfig.ini [Paths] ProjectFile does not belong to this workspace.') | Out-Null
        }
    }
    $engineRoot = if ($exists) { Get-WorkspaceIniValue -Path $path -Section 'Paths' -Key 'EngineRoot' } else { $null }
    $configurationReady = -not [string]::IsNullOrWhiteSpace([string]$engineRoot)
    return [pscustomobject][ordered]@{
        ProjectRoot       = $root
        Path              = $path
        Exists            = $exists
        Ignored           = $ignored
        Identity          = $identity
        IdentityValid     = $errors.Count -eq 0
        ConfigurationReady = $configurationReady
        Keys              = if ($exists) { @(Get-WorkspaceIniKeyNames -Path $path) } else { @() }
        Errors            = @($errors | ForEach-Object { $_ })
    }
}

function Get-HarnessWorkspaceConfigValue {
    [CmdletBinding()]
    param(
        [Alias('WorkspaceRoot')][string]$ProjectRoot = '',
        [Parameter(Mandatory = $true)][string]$Section,
        [Parameter(Mandatory = $true)][string]$Key
    )
    $snapshot = Get-HarnessWorkspaceConfigValues -ProjectRoot $ProjectRoot -Entries @(
        [pscustomobject]@{ Section = $Section; Key = $Key }
    )
    return $snapshot.Values[0]
}

function Get-HarnessWorkspaceConfigValues {
    [CmdletBinding()]
    param(
        [Alias('WorkspaceRoot')][string]$ProjectRoot = '',
        [Parameter(Mandatory = $true)][ValidateCount(1, 64)][object[]]$Entries,
        [switch]$RequireExecutionGuard,
        [string]$CallerPath = ''
    )

    $root = Resolve-WorkspaceRepository -Path $ProjectRoot
    $status = if ($RequireExecutionGuard) {
        Assert-HarnessWorkspaceExecution -ProjectRoot $root -SelectedWorkspaceRoot $root -CallerPath $CallerPath
    }
    else {
        Get-HarnessWorkspaceConfigStatus -ProjectRoot $root
    }
    if (-not $status.IdentityValid) { throw "AgentConfig.ini is not valid for this workspace: $($status.Errors -join '; ')" }

    $values = New-Object System.Collections.Generic.List[object]
    foreach ($entry in @($Entries)) {
        if ($null -eq $entry -or $null -eq $entry.PSObject.Properties['Section'] -or $null -eq $entry.PSObject.Properties['Key']) {
            throw 'Each configuration entry must provide Section and Key.'
        }
        $section = [string]$entry.Section
        $key = [string]$entry.Key
        [void](Assert-WorkspaceIniName -Value $section -Kind 'section')
        [void](Assert-WorkspaceIniName -Value $key -Kind 'key')
        $value = Get-WorkspaceIniValue -Path $status.Path -Section $section -Key $key
        $values.Add([pscustomobject][ordered]@{
            ProjectRoot = $status.ProjectRoot
            Section     = $section
            Key         = $key
            Exists      = $null -ne $value
            Value       = $value
        }) | Out-Null
    }

    return [pscustomobject][ordered]@{
        ProjectRoot = $status.ProjectRoot
        ConfigPath  = $status.Path
        Identity    = $status.Identity
        Values      = @($values | ForEach-Object { $_ })
    }
}

function Set-HarnessWorkspaceConfigValue {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Alias('WorkspaceRoot')][string]$ProjectRoot = '',
        [Parameter(Mandatory = $true)][string]$Section,
        [Parameter(Mandatory = $true)][string]$Key,
        [AllowEmptyString()][Parameter(Mandatory = $true)][string]$Value
    )
    [void](Assert-WorkspaceIniName -Value $Section -Kind 'section')
    [void](Assert-WorkspaceIniName -Value $Key -Kind 'key')
    if ($Section.Equals('Harness', [System.StringComparison]::OrdinalIgnoreCase) -or
        $Section.Equals('Hardness', [System.StringComparison]::OrdinalIgnoreCase) -or
        ($Section.Equals('Paths', [System.StringComparison]::OrdinalIgnoreCase) -and $Key.Equals('ProjectFile', [System.StringComparison]::OrdinalIgnoreCase))) {
        throw "AgentConfig.ini [$Section] $Key is managed by Harness and cannot be set directly."
    }
    if ($Section.Equals('References', [System.StringComparison]::OrdinalIgnoreCase) -and
        $Key.Equals('HazelightAngelscriptEngineRoot', [System.StringComparison]::OrdinalIgnoreCase)) {
        throw 'AgentConfig.ini [References] HazelightAngelscriptEngineRoot is obsolete and cannot be set.'
    }
    $status = Get-HarnessWorkspaceConfigStatus -ProjectRoot $ProjectRoot
    if (-not $status.IdentityValid) { throw "AgentConfig.ini is not valid for this workspace: $($status.Errors -join '; ')" }
    if ($PSCmdlet.ShouldProcess($status.Path, "set [$Section] $Key")) {
        Set-WorkspaceIniValueInternal -Path $status.Path -Section $Section -Key $Key -Value $Value
    }
    return Get-HarnessWorkspaceConfigValue -ProjectRoot $status.ProjectRoot -Section $Section -Key $Key
}

function Get-HarnessAngelscriptMainBaselineStatus {
    param(
        [Parameter(Mandatory = $true)][string]$ProjectRoot,
        [Parameter(Mandatory = $true)][AllowEmptyString()][string]$ParentBranch
    )

    $pluginRelativePath = 'Plugins/Angelscript'
    $pluginPath = [System.IO.Path]::GetFullPath((Join-Path $ProjectRoot $pluginRelativePath))
    $errors = New-Object System.Collections.Generic.List[string]
    $configuredSubmodule = @(
        Get-WorkspaceSubmodules -Repository $ProjectRoot |
            Where-Object { ([string]$_.Path).Replace('\', '/').Equals($pluginRelativePath, [System.StringComparison]::OrdinalIgnoreCase) }
    )
    $configured = $configuredSubmodule.Count -eq 1
    $applicable = $ParentBranch.Equals('main', [System.StringComparison]::Ordinal) -and $configured
    $initialized = $false
    $head = ''
    $localMain = ''
    $originMain = ''
    $baseline = ''
    $baselineSource = 'None'
    $originContained = $true

    if ($applicable) {
        if (-not (Test-WorkspacePathInside -Parent $ProjectRoot -Child $pluginPath)) {
            $errors.Add("Plugins/Angelscript path escapes workspace '$ProjectRoot'.") | Out-Null
        }
        elseif (-not (Test-WorkspaceSubmoduleRepository -Repository $ProjectRoot -Submodule $configuredSubmodule[0] -Path $pluginPath)) {
            $errors.Add("Plugins/Angelscript is configured but not initialized in '$ProjectRoot'.") | Out-Null
        }
        else {
            $initialized = $true
            $headResult = Invoke-WorkspaceGit -Repository $pluginPath -Arguments @('rev-parse', '--verify', 'HEAD^{commit}') -AllowFailure
            if ($headResult.ExitCode -eq 0) {
                $head = (($headResult.Output | Select-Object -Last 1).Trim()).ToLowerInvariant()
            }
            else {
                $errors.Add('Plugins/Angelscript HEAD is not a valid commit.') | Out-Null
            }

            $localResult = Invoke-WorkspaceGit -Repository $pluginPath -Arguments @('rev-parse', '--verify', 'refs/heads/main^{commit}') -AllowFailure
            if ($localResult.ExitCode -eq 0) {
                $localMain = (($localResult.Output | Select-Object -Last 1).Trim()).ToLowerInvariant()
            }
            $originResult = Invoke-WorkspaceGit -Repository $pluginPath -Arguments @('rev-parse', '--verify', 'refs/remotes/origin/main^{commit}') -AllowFailure
            if ($originResult.ExitCode -eq 0) {
                $originMain = (($originResult.Output | Select-Object -Last 1).Trim()).ToLowerInvariant()
            }

            if (-not [string]::IsNullOrWhiteSpace($localMain)) {
                $baseline = $localMain
                $baselineSource = 'LocalMain'
            }
            elseif (-not [string]::IsNullOrWhiteSpace($originMain)) {
                $baseline = $originMain
                $baselineSource = 'OriginMain'
            }
            else {
                $errors.Add('Plugins/Angelscript has no local main ref or fetched origin/main ref for the primary main baseline.') | Out-Null
            }

            if (-not [string]::IsNullOrWhiteSpace($localMain) -and -not [string]::IsNullOrWhiteSpace($originMain)) {
                $contains = Invoke-WorkspaceGit -Repository $pluginPath -Arguments @('merge-base', '--is-ancestor', $originMain, $localMain) -AllowFailure
                $originContained = $contains.ExitCode -eq 0
                if (-not $originContained) {
                    $errors.Add("Plugins/Angelscript local main '$localMain' is behind or diverged from fetched origin/main '$originMain'; origin/main is not contained by local main.") | Out-Null
                }
            }

            if (-not [string]::IsNullOrWhiteSpace($head) -and -not [string]::IsNullOrWhiteSpace($baseline) -and $head -ne $baseline) {
                $errors.Add("Plugins/Angelscript HEAD '$head' does not match latest known main baseline '$baseline' from $baselineSource.") | Out-Null
            }
        }
    }

    return [pscustomobject][ordered]@{
        Applicable       = $applicable
        Configured       = $configured
        Aligned          = -not $applicable -or $errors.Count -eq 0
        ParentBranch     = $ParentBranch
        PluginPath       = $pluginPath
        Initialized      = $initialized
        Head             = $head
        LocalMain        = $localMain
        OriginMain       = $originMain
        Baseline         = $baseline
        BaselineSource   = $baselineSource
        OriginContained  = $originContained
        NetworkRefreshed = $false
        Errors           = @($errors | ForEach-Object { [string]$_ })
    }
}

function Assert-HarnessWorkspaceExecution {
    [CmdletBinding()]
    param(
        [Alias('WorkspaceRoot')][Parameter(Mandatory = $true)][string]$ProjectRoot,
        [string]$SelectedWorkspaceRoot = '',
        [string]$CallerPath = ''
    )
    $status = Get-HarnessWorkspaceConfigStatus -ProjectRoot $ProjectRoot
    if (-not $status.IdentityValid) { throw "Workspace execution identity is invalid: $($status.Errors -join '; ')" }
    $selected = if (-not [string]::IsNullOrWhiteSpace($SelectedWorkspaceRoot)) { $SelectedWorkspaceRoot } else { [Environment]::GetEnvironmentVariable('HARNESS_WORKSPACE_ROOT', 'Process') }
    if (-not [string]::IsNullOrWhiteSpace($selected) -and -not (Test-WorkspacePathEqual -Left $selected -Right $status.ProjectRoot)) {
        throw "Harness selected workspace '$selected' but the command targets '$($status.ProjectRoot)'."
    }
    $selectedPrimary = [Environment]::GetEnvironmentVariable('HARNESS_PRIMARY_ROOT', 'Process')
    if (-not [string]::IsNullOrWhiteSpace($selectedPrimary) -and -not (Test-WorkspacePathEqual -Left $selectedPrimary -Right $status.Identity.PrimaryRoot)) {
        throw "Harness selected primary root '$selectedPrimary' but the command targets workspace '$($status.ProjectRoot)' owned by '$($status.Identity.PrimaryRoot)'."
    }
    $selectedCommon = [Environment]::GetEnvironmentVariable('HARNESS_GIT_COMMON_DIR', 'Process')
    if (-not [string]::IsNullOrWhiteSpace($selectedCommon) -and -not (Test-WorkspacePathEqual -Left $selectedCommon -Right $status.Identity.GitCommonDir)) {
        throw "Harness selected Git common directory '$selectedCommon' but the command targets '$($status.Identity.GitCommonDir)'."
    }
    $caller = if ([string]::IsNullOrWhiteSpace($CallerPath)) { (Get-Location).Path } else { $CallerPath }
    if (Test-Path -LiteralPath $caller) {
        $callerFull = [System.IO.Path]::GetFullPath($caller)
        $registered = @(Get-HarnessWorkspaceList -WorkspaceRoot $status.Identity.PrimaryRoot | ForEach-Object WorkspaceRoot | Sort-Object Length -Descending)
        $callerWorkspace = @($registered | Where-Object { (Test-WorkspacePathEqual -Left $_ -Right $callerFull) -or (Test-WorkspacePathInside -Parent $_ -Child $callerFull) } | Select-Object -First 1)
        $trustedScripts = Join-Path $status.Identity.HarnessRoot '.agents'
        if ($callerWorkspace.Count -eq 1 -and -not (Test-WorkspacePathInside -Parent $trustedScripts -Child $callerFull) -and -not (Test-WorkspacePathEqual -Left $callerWorkspace[0] -Right $status.ProjectRoot)) {
            throw "The current shell belongs to workspace '$($callerWorkspace[0])' but the command targets '$($status.ProjectRoot)'."
        }
    }
    $baseline = Get-HarnessAngelscriptMainBaselineStatus -ProjectRoot $status.ProjectRoot -ParentBranch $status.Identity.Branch
    if (-not $baseline.Aligned) {
        throw "AngelScript main baseline validation failed: $($baseline.Errors -join '; ')"
    }
    $status | Add-Member -NotePropertyName AngelscriptMainBaseline -NotePropertyValue $baseline -Force
    return $status
}

function Set-HarnessWorkspaceSession {
    [CmdletBinding()]
    param([Alias('WorkspaceRoot')][string]$ProjectRoot = '')

    $status = Get-HarnessWorkspaceConfigStatus -ProjectRoot $ProjectRoot
    if (-not $status.IdentityValid) { throw "Workspace selection identity is invalid: $($status.Errors -join '; ')" }
    [Environment]::SetEnvironmentVariable('HARNESS_WORKSPACE_ROOT', $status.ProjectRoot, 'Process')
    [Environment]::SetEnvironmentVariable('HARNESS_PRIMARY_ROOT', $status.Identity.PrimaryRoot, 'Process')
    [Environment]::SetEnvironmentVariable('HARNESS_GIT_COMMON_DIR', $status.Identity.GitCommonDir, 'Process')
    [Environment]::SetEnvironmentVariable('HARNESS_WORKSPACE_MODE', $null, 'Process')
    [Environment]::SetEnvironmentVariable('HARNESS_GOAL_NAME', $null, 'Process')
    foreach ($legacyName in @('HARDNESS_WORKSPACE_ROOT', 'HARDNESS_PRIMARY_ROOT', 'HARDNESS_GIT_COMMON_DIR', 'HARDNESS_WORKSPACE_MODE', 'HARDNESS_GOAL_NAME')) {
        [Environment]::SetEnvironmentVariable($legacyName, $null, 'Process')
    }
    [void](Clear-HarnessWorkspaceCache)
    return [pscustomobject][ordered]@{
        WorkspaceRoot = $status.ProjectRoot
        PrimaryRoot   = $status.Identity.PrimaryRoot
        GitCommonDir  = $status.Identity.GitCommonDir
        Topology      = $status.Identity.Topology
        WorktreeName  = $status.Identity.WorktreeName
        Activated     = $true
    }
}

function Get-WorkspaceRegistrationRecords {
    param([Parameter(Mandatory = $true)][string]$Repository)

    $result = Invoke-WorkspaceGit -Repository $Repository -Arguments @('worktree', 'list', '--porcelain')
    $rawRecords = New-Object System.Collections.Generic.List[object]
    $current = [ordered]@{}
    foreach ($line in @($result.Output) + '') {
        if ([string]::IsNullOrWhiteSpace($line)) {
            if ($current.Contains('WorkspaceRoot')) {
                $rawRecords.Add([pscustomobject]$current) | Out-Null
            }
            $current = [ordered]@{}
            continue
        }
        if ($line -like 'worktree *') {
            $current.WorkspaceRoot = [System.IO.Path]::GetFullPath($line.Substring(9).Trim())
        }
        elseif ($line -like 'HEAD *') {
            $current.Head = $line.Substring(5).Trim().ToLowerInvariant()
        }
        elseif ($line -like 'branch refs/heads/*') {
            $current.Branch = $line.Substring(18).Trim()
        }
        elseif ($line -eq 'detached') {
            $current.Branch = ''
        }
        elseif ($line -like 'locked*') {
            $current.Locked = $true
        }
        elseif ($line -eq 'prunable') {
            $current.Prunable = $true
        }
    }
    if ($rawRecords.Count -eq 0) {
        throw "Git returned no registered worktrees for '$Repository'."
    }

    $primary = [System.IO.Path]::GetFullPath($rawRecords[0].WorkspaceRoot)
    $records = New-Object System.Collections.Generic.List[object]
    foreach ($raw in $rawRecords) {
        $root = [System.IO.Path]::GetFullPath($raw.WorkspaceRoot)
        $isPrimary = Test-WorkspacePathEqual -Left $root -Right $primary
        $records.Add([pscustomobject][ordered]@{
            WorkspaceRoot = $root
            PrimaryRoot   = $primary
            Topology      = if ($isPrimary) { 'Primary' } else { 'Worktree' }
            WorktreeName  = if ($isPrimary) { '' } else { Split-Path -Leaf $root }
            Branch        = if ($raw.PSObject.Properties.Name -contains 'Branch') { [string]$raw.Branch } else { '' }
            Head          = if ($raw.PSObject.Properties.Name -contains 'Head') { [string]$raw.Head } else { '' }
            Locked        = ($raw.PSObject.Properties.Name -contains 'Locked') -and [bool]$raw.Locked
            Prunable      = ($raw.PSObject.Properties.Name -contains 'Prunable') -and [bool]$raw.Prunable
        }) | Out-Null
    }
    return @($records | ForEach-Object { $_ })
}

function Get-PrimaryWorkspaceRoot {
    param([Parameter(Mandatory = $true)][string]$Repository)
    return [System.IO.Path]::GetFullPath((@(Get-WorkspaceRegistrationRecords -Repository $Repository)[0]).PrimaryRoot)
}

function Get-RegisteredWorkspaceRoots {
    param([Parameter(Mandatory = $true)][string]$Repository)
    return @(Get-WorkspaceRegistrationRecords -Repository $Repository | ForEach-Object { $_.WorkspaceRoot })
}

function Clear-HarnessWorkspaceCache {
    [CmdletBinding()]
    param()
    return [pscustomobject]@{ Cleared = $true; Scope = 'Process'; CachedEntries = 0 }
}

function Get-HarnessWorkspaceList {
    [CmdletBinding()]
    param(
        [Alias('WorkspaceRoot')][string]$ProjectRoot = '',
        [switch]$Refresh
    )

    if ($Refresh) { [void](Clear-HarnessWorkspaceCache) }
    $repository = (Get-WorkspaceIdentity (Resolve-WorkspaceRepository -Path $ProjectRoot)).PrimaryRoot
    $records = @(Get-WorkspaceRegistrationRecords -Repository $repository)
    $commonDirectory = Get-WorkspaceCommonGitDirectory -Repository $repository
    $contexts = New-Object System.Collections.Generic.List[object]
    foreach ($record in $records) {
        $contexts.Add((New-WorkspaceIdentityFromRegistration -Registration $record -GitCommonDir $commonDirectory)) | Out-Null
    }
    $registry = Join-Path $repository 'Saved/Harness/Workspaces'
    if (Test-Path $registry) {
        foreach ($file in Get-ChildItem $registry -Filter 'workspace_*.json' -File) {
            $entry = Get-Content $file.FullName -Raw | ConvertFrom-Json
            $contexts.Add((Get-WorkspaceReplicaIdentity $entry.WorkspaceRoot)) | Out-Null
        }
    }
    return @($contexts | ForEach-Object { $_ })
}

function Get-HarnessWorkspaceStatus {
    [CmdletBinding()]
    param(
        [Alias('WorkspaceRoot')][string]$ProjectRoot = '',
        [switch]$Detailed,
        [switch]$Refresh
    )

    if ($Refresh) { [void](Clear-HarnessWorkspaceCache) }
    $configStatus = Get-HarnessWorkspaceConfigStatus -ProjectRoot $ProjectRoot
    $identity = $configStatus.Identity
    $root = $identity.WorkspaceRoot
    $result = [ordered]@{
        ProjectRoot        = $root
        DetailLevel        = if ($Detailed) { 'Detailed' } else { 'Fast' }
        Context            = $identity
        SchemaVersion      = $identity.SchemaVersion
        HarnessRoot        = $identity.HarnessRoot
        WorkspaceRoot      = $identity.WorkspaceRoot
        PrimaryRoot        = $identity.PrimaryRoot
        GitCommonDir       = $identity.GitCommonDir
        Topology           = $identity.Topology
        WorktreeName       = $identity.WorktreeName
        Branch             = $identity.Branch
        Head               = $identity.Head
        Managed            = $identity.Managed
        Registered         = $true
        ConfigurationReady = $configStatus.ConfigurationReady
        Configuration      = $configStatus
    }
    if (-not $Detailed) {
        return [pscustomobject]$result
    }

    if ($identity.Topology -eq 'Replica') {
        $details = Get-WorkspaceReplicaDetails $root
        $result.Dirty = $details.Dirty
        $result.Changes = @()
        $result.IgnoredFiles = @()
        $result.Submodules = @($details.Submodules)
        $result.SnapshotErrors = @($details.Errors)
        return [pscustomobject]$result
    }

    $dirty = @(Get-WorkspaceDirtyLines -Repository $root)
    $ignoredFiles = @(Get-WorkspaceIgnoredLines -Repository $root | ForEach-Object { $_.Substring(3) })
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
            $subIgnored = @(Get-WorkspaceIgnoredLines -Repository $fullPath | ForEach-Object { $_.Substring(3) })
            $submodules.Add([pscustomobject]@{ Name = $submodule.Name; Path = $path; Initialized = $true; Expected = $expected; Actual = $actual; Exact = $actual -eq $expected; Dirty = $subDirty.Count -gt 0; Payload = @(); IgnoredFiles = $subIgnored }) | Out-Null
        }
        else {
            $payload = @(Get-WorkspacePathPayload -Path $fullPath)
            $submodules.Add([pscustomobject]@{ Name = $submodule.Name; Path = $path; Initialized = $false; Expected = $expected; Actual = $null; Exact = $false; Dirty = $false; Payload = $payload; IgnoredFiles = @() }) | Out-Null
        }
    }
    $result.Dirty = $dirty.Count -gt 0
    $result.Changes = $dirty
    $result.IgnoredFiles = $ignoredFiles
    $result.Submodules = @($submodules | ForEach-Object { $_ })
    $result.AngelscriptMainBaseline = Get-HarnessAngelscriptMainBaselineStatus -ProjectRoot $root -ParentBranch $identity.Branch
    return [pscustomobject]$result
}

function New-HarnessWorkspace {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true)][ValidatePattern('^[A-Za-z0-9._-]{1,80}$')][string]$Name,
        [string]$Branch = '',
        [string]$RepositoryRoot = '',
        [string]$StartPoint = 'HEAD',
        [string[]]$EditablePlugins = @(),
        [string[]]$RequiredPlugins = @(),
        [string[]]$HostFiles = @()
    )

    $requestedRepository = Resolve-WorkspaceRepository -Path $RepositoryRoot
    $repository = (Get-WorkspaceIdentity $requestedRepository).PrimaryRoot
    if ($StartPoint -ne 'HEAD') { throw 'Replica creation pins each plugin HEAD; parent StartPoint is not applicable.' }
    if (-not $PSCmdlet.ShouldProcess((Join-Path $repository ".workspaces/$Name"), 'create minimal project and selected plugin worktrees')) {
        return [pscustomobject]@{ Created = $false; Mutates = $false }
    }
    return New-WorkspaceReplica -RepositoryRoot $repository -Name $Name -Branch $Branch -EditablePlugins $EditablePlugins -RequiredPlugins $RequiredPlugins -HostFiles $HostFiles
}

function Initialize-HarnessWorkspace {
    [CmdletBinding()]
    param(
        [Alias('WorkspaceRoot')][string]$ProjectRoot = ''
    )

    $root = Resolve-WorkspaceRepository -Path $ProjectRoot
    $identity = Get-WorkspaceIdentity $root
    $source = $identity.PrimaryRoot
    $config = Set-WorkspaceManagedConfiguration -ProjectRoot $root -SourceRoot $source
    $submodules = if ($identity.Topology -eq 'Replica') { @() } else { @(Initialize-WorkspaceSubmodules -Repository $root) }
    [void](Clear-HarnessWorkspaceCache)
    return [pscustomobject]@{ ProjectRoot = $root; SourceRoot = $source; AgentConfigCopied = $config.Copied; Configuration = $config; Submodules = $submodules }
}

function Test-HarnessWorkspace {
    [CmdletBinding()]
    param(
        [Alias('WorkspaceRoot')][string]$ProjectRoot = '',
        [switch]$RequireClean
    )

    $errors = New-Object System.Collections.Generic.List[string]
    $warnings = New-Object System.Collections.Generic.List[string]
    $status = Get-HarnessWorkspaceStatus -ProjectRoot $ProjectRoot -Detailed -Refresh
    if ($status.Topology -eq 'Replica') { foreach ($issue in $status.SnapshotErrors) { $errors.Add($issue) } }
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
    if (-not $status.Configuration.IdentityValid) {
        foreach ($configError in @($status.Configuration.Errors)) {
            $errors.Add([string]$configError) | Out-Null
        }
    }
    if (-not $status.Configuration.ConfigurationReady) {
        $warnings.Add('AgentConfig.ini is workspace-valid but consumer configuration is incomplete; set [Paths] EngineRoot before UE build or test execution.') | Out-Null
    }
    if ($RequireClean -and $status.Dirty) {
        $errors.Add('Workspace has uncommitted changes.') | Out-Null
    }
    return [pscustomobject]@{ IsValid = $errors.Count -eq 0; Errors = @($errors | ForEach-Object { $_ }); Warnings = @($warnings | ForEach-Object { $_ }); Status = $status }
}

function Enter-WorkspaceRemovalLease {
    param([Parameter(Mandatory = $true)][string]$Root)
    $manifest = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../../unreal-engine-develop/scripts/UnrealEngineDevelop.psd1'))
    $module = Import-Module $manifest -PassThru -ErrorAction Stop
    $lease = & $module { param($Root) Enter-UnrealWorkspaceRemovalLease -WorkspaceRoot $Root } $Root
    return [pscustomobject]@{ Module = $module; Lease = $lease }
}

function Exit-WorkspaceRemovalLease {
    param($Lease)
    if ($null -ne $Lease) { & $Lease.Module { param($Held) Exit-UnrealWorkspaceRemovalLease -Lease $Held } $Lease.Lease }
}

function Remove-HarnessWorkspace {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    param(
        [Parameter(Mandatory = $true)][string]$WorktreeRoot,
        [string]$RepositoryRoot = '',
        [switch]$DiscardIgnoredFiles
    )

    $requestedRepository = Resolve-WorkspaceRepository -Path $RepositoryRoot
    $repository = Get-PrimaryWorkspaceRoot -Repository $requestedRepository
    $target = (Resolve-Path -LiteralPath $WorktreeRoot -ErrorAction Stop).Path
    if (Test-Path -LiteralPath (Join-Path $target '.harness/workspace.json')) {
        return Remove-WorkspaceReplica -Root $target -PrimaryRoot $repository -DiscardIgnoredFiles:$DiscardIgnoredFiles -WhatIf:$WhatIfPreference
    }
    $container = Join-Path $repository '.worktrees'
    if (Test-WorkspacePathEqual -Left $target -Right $repository) {
        throw 'Refusing to remove the primary repository checkout.'
    }

    $registered = @(Get-RegisteredWorkspaceRoots -Repository $repository)
    $isRegistered = @($registered | Where-Object { Test-WorkspacePathEqual -Left $_ -Right $target }).Count -eq 1
    if (-not $isRegistered) {
        $targetItem = Get-Item -LiteralPath $target -Force -ErrorAction Stop
        $remainingEntries = @(if ($targetItem.PSIsContainer) { Get-ChildItem -LiteralPath $target -Force -ErrorAction Stop } else { $targetItem })
        $isCanonicalResidueRoot = Test-WorkspacePathEqual -Left (Split-Path -Parent $target) -Right $container
        if ($targetItem.PSIsContainer -and $remainingEntries.Count -eq 0 -and $isCanonicalResidueRoot -and $DiscardIgnoredFiles) {
            if ($PSCmdlet.ShouldProcess($target, 'remove empty unregistered worktree residue; preserve branches')) {
                $removalLease = Enter-WorkspaceRemovalLease -Root $target
                try {
                    [void](Assert-WorkspacePathChainSafe -Root $repository -Target $target -Purpose 'empty workspace residue removal')
                    Remove-Item -LiteralPath $target -Force -ErrorAction Stop
                } finally { Exit-WorkspaceRemovalLease -Lease $removalLease }
            }
            return [pscustomobject]@{ WorktreeRoot = $target; Removed = -not (Test-Path -LiteralPath $target); BranchPreserved = $true; DiscardedIgnoredFiles = @() }
        }
        throw "Refusing to remove '$target': it is not a registered Git worktree."
    }
    if (Test-WorkspacePathInside -Parent $repository -Child $target) {
        [void](Assert-WorkspacePathChainSafe -Root $repository -Target $target -Purpose 'workspace removal')
    }
    else {
        [void](Assert-WorkspaceExistingPathSafe -Target $target -Purpose 'workspace removal')
    }
    $verification = Test-HarnessWorkspace -ProjectRoot $target -RequireClean
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
        $removalLease = Enter-WorkspaceRemovalLease -Root $target
        try {
            $verification = Test-HarnessWorkspace -ProjectRoot $target -RequireClean
            if (-not $verification.IsValid) { throw "Worktree changed before removal: $($verification.Errors -join '; ')" }
            if (Test-WorkspacePathInside -Parent $repository -Child $target) {
                [void](Assert-WorkspacePathChainSafe -Root $repository -Target $target -Purpose 'workspace removal')
            }
            else {
                [void](Assert-WorkspaceExistingPathSafe -Target $target -Purpose 'workspace removal')
            }
            # Git requires --force for any worktree that has ever initialized a
            # submodule. The explicit clean checks above are the safety gate; this
            # flag only bypasses Git's structural submodule refusal.
            [void](Invoke-WorkspaceGit -Repository $repository -Arguments @('worktree', 'remove', '--force', $target))
            [void](Clear-HarnessWorkspaceCache)
            if (Test-Path -LiteralPath $target) {
                $targetItem = Get-Item -LiteralPath $target -Force -ErrorAction Stop
                if (-not $targetItem.PSIsContainer) {
                    throw "Git unregistered worktree '$target' but the residual target is not a directory; it was preserved."
                }
                [void](Assert-WorkspacePathChainSafe -Root $repository -Target $target -Purpose 'post-remove empty directory cleanup')
                $remainingEntries = @(Get-ChildItem -LiteralPath $target -Force -ErrorAction Stop)
                if ($remainingEntries.Count -gt 0) {
                    throw "Git unregistered worktree '$target' but residual content remains; it was preserved for explicit recovery."
                }
                # A Windows process can briefly keep the worktree root open after
                # Git removes every entry. Non-recursive deletion fails closed if
                # any content appears after the empty-directory check.
                Remove-Item -LiteralPath $target -Force -ErrorAction Stop
            }
        } finally { Exit-WorkspaceRemovalLease -Lease $removalLease }
    }
    $removed = -not (Test-Path -LiteralPath $target)
    if (-not $removed -and -not $WhatIfPreference) {
        throw "Workspace removal did not remove '$target'."
    }
    return [pscustomobject]@{ WorktreeRoot = $target; Removed = $removed; BranchPreserved = $true; DiscardedIgnoredFiles = @($ignoredFiles | ForEach-Object { $_ }) }
}

Export-ModuleMember -Function @(
    'Get-HarnessWorkspaceContext',
    'Get-HarnessWorkspaceList',
    'Get-HarnessWorkspaceStatus',
    'Clear-HarnessWorkspaceCache',
    'New-HarnessWorkspace',
    'Initialize-HarnessWorkspacePlugins',
    'Initialize-HarnessWorkspace',
    'Test-HarnessWorkspace',
    'Remove-HarnessWorkspace',
    'Get-HarnessWorkspaceConfigStatus',
    'Get-HarnessWorkspaceConfigValue',
    'Get-HarnessWorkspaceConfigValues',
    'Set-HarnessWorkspaceConfigValue',
    'Set-HarnessWorkspaceSession',
    'Assert-HarnessWorkspaceExecution'
)
