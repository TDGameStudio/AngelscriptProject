#requires -Version 7.0
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

function Get-WorkspaceIdentity {
    param([Parameter(Mandatory = $true)][string]$ProjectRoot)
    $root = Resolve-WorkspaceRepository -Path $ProjectRoot
    $primary = Get-PrimaryWorkspaceRoot -Repository $root
    $registered = @(Get-RegisteredWorkspaceRoots -Repository $primary)
    if (-not (@($registered | Where-Object { Test-WorkspacePathEqual -Left $_ -Right $root }).Count -eq 1)) {
        throw "Workspace is not registered with Git: $root"
    }
    $isPrimary = Test-WorkspacePathEqual -Left $root -Right $primary
    $goalName = if ($isPrimary) { '' } else { Split-Path -Leaf $root }
    return [pscustomobject][ordered]@{
        SchemaVersion = '1'
        WorkspaceKind = if ($isPrimary) { 'Primary' } else { 'Goal' }
        PrimaryRoot   = [System.IO.Path]::GetFullPath($primary)
        WorkspaceRoot = [System.IO.Path]::GetFullPath($root)
        GitCommonDir  = [System.IO.Path]::GetFullPath((Get-WorkspaceCommonGitDirectory -Repository $root))
        GoalName      = $goalName
    }
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

    $projectFile = Get-WorkspaceProjectFile -ProjectRoot $root
    Set-WorkspaceIniValueInternal -Path $target -Section 'Paths' -Key 'ProjectFile' -Value $projectFile
    foreach ($entry in @(
        @('SchemaVersion', $identity.SchemaVersion),
        @('WorkspaceKind', $identity.WorkspaceKind),
        @('PrimaryRoot', $identity.PrimaryRoot),
        @('WorkspaceRoot', $identity.WorkspaceRoot),
        @('GitCommonDir', $identity.GitCommonDir),
        @('GoalName', $identity.GoalName)
    )) {
        Set-WorkspaceIniValueInternal -Path $target -Section 'Hardness' -Key $entry[0] -Value ([string]$entry[1])
    }
    return [pscustomobject]@{ Path = $target; Copied = $copied; Identity = $identity; ProjectFile = $projectFile }
}

function Get-HardnessWorkspaceConfigStatus {
    [CmdletBinding()]
    param([string]$ProjectRoot = '')
    $root = Resolve-WorkspaceRepository -Path $ProjectRoot
    $path = Join-Path $root 'AgentConfig.ini'
    $errors = New-Object System.Collections.Generic.List[string]
    $identity = Get-WorkspaceIdentity -ProjectRoot $root
    $exists = Test-Path -LiteralPath $path -PathType Leaf
    $ignored = $false
    if (-not $exists) {
        $errors.Add('AgentConfig.ini is missing.') | Out-Null
    }
    else {
        $ignored = (Invoke-WorkspaceGit -Repository $root -Arguments @('check-ignore', '--quiet', '--', 'AgentConfig.ini') -AllowFailure).ExitCode -eq 0
        if (-not $ignored) { $errors.Add('AgentConfig.ini exists but is not ignored.') | Out-Null }
        foreach ($entry in @(
            @('SchemaVersion', $identity.SchemaVersion),
            @('WorkspaceKind', $identity.WorkspaceKind),
            @('PrimaryRoot', $identity.PrimaryRoot),
            @('WorkspaceRoot', $identity.WorkspaceRoot),
            @('GitCommonDir', $identity.GitCommonDir),
            @('GoalName', $identity.GoalName)
        )) {
            $actual = Get-WorkspaceIniValue -Path $path -Section 'Hardness' -Key $entry[0]
            $expected = [string]$entry[1]
            $matches = if ($entry[0] -in @('PrimaryRoot', 'WorkspaceRoot', 'GitCommonDir')) {
                -not [string]::IsNullOrWhiteSpace([string]$actual) -and (Test-WorkspacePathEqual -Left $actual -Right $expected)
            }
            else { ([string]$actual).Equals($expected, [System.StringComparison]::OrdinalIgnoreCase) }
            if (-not $matches) { $errors.Add("AgentConfig.ini [Hardness] $($entry[0]) does not match this workspace.") | Out-Null }
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

function Get-HardnessWorkspaceConfigValue {
    [CmdletBinding()]
    param(
        [string]$ProjectRoot = '',
        [Parameter(Mandatory = $true)][string]$Section,
        [Parameter(Mandatory = $true)][string]$Key
    )
    [void](Assert-WorkspaceIniName -Value $Section -Kind 'section')
    [void](Assert-WorkspaceIniName -Value $Key -Kind 'key')
    $status = Get-HardnessWorkspaceConfigStatus -ProjectRoot $ProjectRoot
    if (-not $status.IdentityValid) { throw "AgentConfig.ini is not valid for this workspace: $($status.Errors -join '; ')" }
    $value = Get-WorkspaceIniValue -Path $status.Path -Section $Section -Key $Key
    return [pscustomobject]@{ ProjectRoot = $status.ProjectRoot; Section = $Section; Key = $Key; Exists = $null -ne $value; Value = $value }
}

function Set-HardnessWorkspaceConfigValue {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [string]$ProjectRoot = '',
        [Parameter(Mandatory = $true)][string]$Section,
        [Parameter(Mandatory = $true)][string]$Key,
        [AllowEmptyString()][Parameter(Mandatory = $true)][string]$Value
    )
    [void](Assert-WorkspaceIniName -Value $Section -Kind 'section')
    [void](Assert-WorkspaceIniName -Value $Key -Kind 'key')
    if ($Section.Equals('Hardness', [System.StringComparison]::OrdinalIgnoreCase) -or
        ($Section.Equals('Paths', [System.StringComparison]::OrdinalIgnoreCase) -and $Key.Equals('ProjectFile', [System.StringComparison]::OrdinalIgnoreCase))) {
        throw "AgentConfig.ini [$Section] $Key is managed by Hardness and cannot be set directly."
    }
    $status = Get-HardnessWorkspaceConfigStatus -ProjectRoot $ProjectRoot
    if (-not $status.IdentityValid) { throw "AgentConfig.ini is not valid for this workspace: $($status.Errors -join '; ')" }
    if ($PSCmdlet.ShouldProcess($status.Path, "set [$Section] $Key")) {
        Set-WorkspaceIniValueInternal -Path $status.Path -Section $Section -Key $Key -Value $Value
    }
    return Get-HardnessWorkspaceConfigValue -ProjectRoot $status.ProjectRoot -Section $Section -Key $Key
}

function Assert-HardnessWorkspaceExecution {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][string]$ProjectRoot,
        [string]$SelectedWorkspaceRoot = '',
        [string]$CallerPath = ''
    )
    $status = Get-HardnessWorkspaceConfigStatus -ProjectRoot $ProjectRoot
    if (-not $status.IdentityValid) { throw "Workspace execution identity is invalid: $($status.Errors -join '; ')" }
    $selected = if (-not [string]::IsNullOrWhiteSpace($SelectedWorkspaceRoot)) { $SelectedWorkspaceRoot } else { [Environment]::GetEnvironmentVariable('HARDNESS_WORKSPACE_ROOT', 'Process') }
    if (-not [string]::IsNullOrWhiteSpace($selected) -and -not (Test-WorkspacePathEqual -Left $selected -Right $status.ProjectRoot)) {
        throw "Hardness selected workspace '$selected' but the command targets '$($status.ProjectRoot)'."
    }
    $caller = if ([string]::IsNullOrWhiteSpace($CallerPath)) { (Get-Location).Path } else { $CallerPath }
    if (Test-Path -LiteralPath $caller) {
        $callerFull = [System.IO.Path]::GetFullPath($caller)
        $registered = @(Get-RegisteredWorkspaceRoots -Repository $status.Identity.PrimaryRoot | Sort-Object Length -Descending)
        $callerWorkspace = @($registered | Where-Object { (Test-WorkspacePathEqual -Left $_ -Right $callerFull) -or (Test-WorkspacePathInside -Parent $_ -Child $callerFull) } | Select-Object -First 1)
        if ($callerWorkspace.Count -eq 1 -and -not (Test-WorkspacePathEqual -Left $callerWorkspace[0] -Right $status.ProjectRoot)) {
            throw "The current shell belongs to workspace '$($callerWorkspace[0])' but the command targets '$($status.ProjectRoot)'."
        }
    }
    return $status
}

function Set-HardnessWorkspaceSession {
    [CmdletBinding()]
    param(
        [string]$ProjectRoot = '',
        [ValidateSet('Current', 'Goal')][string]$Mode = 'Current',
        [string]$GoalName = ''
    )
    $status = Get-HardnessWorkspaceConfigStatus -ProjectRoot $ProjectRoot
    if (-not $status.IdentityValid) { throw "Workspace activation identity is invalid: $($status.Errors -join '; ')" }
    if ($Mode -eq 'Goal' -and $status.Identity.WorkspaceKind -ne 'Goal') { throw 'Goal activation requires a registered Goal workspace.' }
    if ($Mode -eq 'Goal' -and -not [string]::IsNullOrWhiteSpace($GoalName) -and $GoalName -ne $status.Identity.GoalName) {
        throw "GoalName '$GoalName' does not match workspace Goal '$($status.Identity.GoalName)'."
    }
    [Environment]::SetEnvironmentVariable('HARDNESS_WORKSPACE_ROOT', $status.ProjectRoot, 'Process')
    [Environment]::SetEnvironmentVariable('HARDNESS_PRIMARY_ROOT', $status.Identity.PrimaryRoot, 'Process')
    [Environment]::SetEnvironmentVariable('HARDNESS_WORKSPACE_MODE', $Mode, 'Process')
    [Environment]::SetEnvironmentVariable('HARDNESS_GOAL_NAME', $status.Identity.GoalName, 'Process')
    return [pscustomobject]@{ WorkspaceRoot = $status.ProjectRoot; PrimaryRoot = $status.Identity.PrimaryRoot; Mode = $Mode; GoalName = $status.Identity.GoalName; Activated = $true }
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

    $configStatus = Get-HardnessWorkspaceConfigStatus -ProjectRoot $root
    return [pscustomobject]@{
        ProjectRoot = $root
        Branch      = [string](($branchResult.Output | Select-Object -Last 1).Trim())
        IsWorktree  = ([string]$gitDirectory).Trim() -ne ([string]$commonDirectory).Trim()
        Dirty       = $dirty.Count -gt 0
        Changes     = $dirty
        Submodules  = @($submodules | ForEach-Object { $_ })
        Configuration = $configStatus
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
        $configResult = Set-WorkspaceManagedConfiguration -ProjectRoot $target -SourceRoot $repository
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
        AgentConfigCopied = $configResult.Copied
        Configuration     = $configResult
        Submodules        = $submodules
    }
}

function Initialize-HardnessWorkspace {
    [CmdletBinding()]
    param(
        [string]$ProjectRoot = ''
    )

    $root = Resolve-WorkspaceRepository -Path $ProjectRoot
    $source = Get-PrimaryWorkspaceRoot -Repository $root
    $config = Set-WorkspaceManagedConfiguration -ProjectRoot $root -SourceRoot $source
    $submodules = @(Initialize-WorkspaceSubmodules -Repository $root)
    return [pscustomobject]@{ ProjectRoot = $root; SourceRoot = $source; AgentConfigCopied = $config.Copied; Configuration = $config; Submodules = $submodules }
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
        $targetItem = Get-Item -LiteralPath $target -Force -ErrorAction Stop
        $remainingEntries = @(if ($targetItem.PSIsContainer) { Get-ChildItem -LiteralPath $target -Force -ErrorAction Stop } else { $targetItem })
        $isCanonicalGoalRoot = Test-WorkspacePathEqual -Left (Split-Path -Parent $target) -Right $container
        if ($targetItem.PSIsContainer -and $remainingEntries.Count -eq 0 -and $isCanonicalGoalRoot -and $DiscardIgnoredFiles) {
            if ($PSCmdlet.ShouldProcess($target, 'remove empty unregistered worktree residue; preserve branches')) {
                [void](Assert-WorkspacePathChainSafe -Root $repository -Target $target -Purpose 'empty workspace residue removal')
                Remove-Item -LiteralPath $target -Force -ErrorAction Stop
            }
            return [pscustomobject]@{ WorktreeRoot = $target; Removed = -not (Test-Path -LiteralPath $target); BranchPreserved = $true; DiscardedIgnoredFiles = @() }
        }
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
    }
    $removed = -not (Test-Path -LiteralPath $target)
    if (-not $removed -and -not $WhatIfPreference) {
        throw "Workspace removal did not remove '$target'."
    }
    return [pscustomobject]@{ WorktreeRoot = $target; Removed = $removed; BranchPreserved = $true; DiscardedIgnoredFiles = @($ignoredFiles | ForEach-Object { $_ }) }
}

Export-ModuleMember -Function @(
    'Get-HardnessWorkspaceStatus',
    'New-HardnessWorkspace',
    'Initialize-HardnessWorkspace',
    'Test-HardnessWorkspace',
    'Remove-HardnessWorkspace',
    'Get-HardnessWorkspaceConfigStatus',
    'Get-HardnessWorkspaceConfigValue',
    'Set-HardnessWorkspaceConfigValue',
    'Set-HardnessWorkspaceSession',
    'Assert-HardnessWorkspaceExecution'
)
