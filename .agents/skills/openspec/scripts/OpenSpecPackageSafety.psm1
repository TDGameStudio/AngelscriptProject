Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-OpenSpecFullPath {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$Description
    )

    if ([string]::IsNullOrWhiteSpace($Path)) { throw "$Description path is empty." }
    try { [System.IO.Path]::GetFullPath($Path) }
    catch { throw "Invalid $Description path '$Path': $($_.Exception.Message)" }
}

function Assert-OpenSpecNoReparseComponents {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$Description
    )

    $pathFull = Get-OpenSpecFullPath -Path $Path -Description $Description
    $volumeRoot = [System.IO.Path]::GetPathRoot($pathFull)
    if ([string]::IsNullOrWhiteSpace($volumeRoot)) { throw "Unable to resolve the volume root for $Description path: $pathFull" }

    $current = $volumeRoot
    $components = [System.Collections.Generic.List[string]]::new()
    $components.Add($current)
    $relative = $pathFull.Substring($volumeRoot.Length).TrimStart('\', '/')
    foreach ($segment in ($relative -split '[\\/]')) {
        if ([string]::IsNullOrWhiteSpace($segment)) { continue }
        $current = Join-Path $current $segment
        $components.Add($current)
    }

    foreach ($component in $components) {
        $item = Get-Item -LiteralPath $component -Force -ErrorAction SilentlyContinue
        if ($null -eq $item) {
            # Once an ancestor is absent, no deeper ordinary filesystem component can exist.
            break
        }
        if (($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0) {
            throw "Refusing $Description path through a reparse point or link: $($item.FullName)"
        }
    }

    $pathFull
}

function Assert-OpenSpecSafeExistingPath {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$Description,
        [switch]$Container,
        [switch]$Leaf
    )

    $pathFull = Assert-OpenSpecNoReparseComponents -Path $Path -Description $Description
    $item = Get-Item -LiteralPath $pathFull -Force -ErrorAction SilentlyContinue
    if ($null -eq $item) { throw "Required $Description path is missing: $pathFull" }
    if ($Container -and -not $item.PSIsContainer) { throw "Required $Description path is not a directory: $pathFull" }
    if ($Leaf -and $item.PSIsContainer) { throw "Required $Description path is not a file: $pathFull" }
    $pathFull
}

function Assert-OpenSpecSafeContainedPath {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][string]$Root,
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$Description
    )

    $rootFull = Assert-OpenSpecSafeExistingPath -Path $Root -Description "$Description root" -Container
    $candidateFull = Get-OpenSpecFullPath -Path $Path -Description $Description
    $rootPrefix = $rootFull.TrimEnd('\', '/') + [System.IO.Path]::DirectorySeparatorChar
    if (-not $candidateFull.StartsWith($rootPrefix, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Unsafe $Description path escapes its root '$rootFull': $candidateFull"
    }
    [void](Assert-OpenSpecNoReparseComponents -Path $candidateFull -Description $Description)
    $candidateFull
}

function Assert-OpenSpecSafeTree {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][string]$Root,
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$Description
    )

    $pathFull = Assert-OpenSpecSafeContainedPath -Root $Root -Path $Path -Description $Description
    $rootItem = Get-Item -LiteralPath $pathFull -Force -ErrorAction SilentlyContinue
    if ($null -eq $rootItem) { return $pathFull }
    if (($rootItem.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0) {
        throw "Refusing $Description tree rooted at a reparse point or link: $pathFull"
    }
    if (-not $rootItem.PSIsContainer) { return $pathFull }

    $pending = [System.Collections.Generic.Stack[string]]::new()
    $pending.Push($pathFull)
    while ($pending.Count -gt 0) {
        $directory = $pending.Pop()
        foreach ($child in @(Get-ChildItem -LiteralPath $directory -Force)) {
            if (($child.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0) {
                throw "Refusing $Description tree containing a reparse point or link: $($child.FullName)"
            }
            if ($child.PSIsContainer) { $pending.Push($child.FullName) }
        }
    }
    $pathFull
}

function Assert-OpenSpecPackagePreflight {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][string]$ProjectRoot,
        [Parameter(Mandatory = $true)][string]$SourceRoot,
        [Parameter(Mandatory = $true)][string]$SourceDocs,
        [Parameter(Mandatory = $true)][string]$SkillRoot
    )

    $projectFull = Assert-OpenSpecSafeExistingPath -Path $ProjectRoot -Description 'project root' -Container
    $sourceFull = Assert-OpenSpecSafeContainedPath -Root $projectFull -Path $SourceRoot -Description 'OpenSpec source root'
    [void](Assert-OpenSpecSafeExistingPath -Path $sourceFull -Description 'OpenSpec source root' -Container)
    $skillFull = Assert-OpenSpecSafeContainedPath -Root $projectFull -Path $SkillRoot -Description 'OpenSpec skill root'
    [void](Assert-OpenSpecSafeExistingPath -Path $skillFull -Description 'OpenSpec skill root' -Container)
    $docsFull = Assert-OpenSpecSafeContainedPath -Root $sourceFull -Path $SourceDocs -Description 'OpenSpec command docs root'
    [void](Assert-OpenSpecSafeExistingPath -Path $docsFull -Description 'OpenSpec command docs root' -Container)
}

function Move-OpenSpecSafePackageItem {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][string]$Root,
        [Parameter(Mandatory = $true)][string]$Source,
        [Parameter(Mandatory = $true)][string]$Destination,
        [Parameter(Mandatory = $true)][string]$Description
    )

    $sourceFull = Assert-OpenSpecSafeTree -Root $Root -Path $Source -Description "$Description source"
    if (-not (Test-Path -LiteralPath $sourceFull)) { throw "Required $Description source is missing: $sourceFull" }
    $destinationFull = Assert-OpenSpecSafeContainedPath -Root $Root -Path $Destination -Description "$Description destination"
    $destinationParent = Split-Path -Parent $destinationFull
    $rootFull = [System.IO.Path]::GetFullPath($Root).TrimEnd('\', '/')
    if ($destinationParent.TrimEnd('\', '/').Equals($rootFull, [System.StringComparison]::OrdinalIgnoreCase)) {
        [void](Assert-OpenSpecSafeExistingPath -Path $rootFull -Description "$Description destination parent" -Container)
    }
    else {
        [void](Assert-OpenSpecSafeContainedPath -Root $rootFull -Path $destinationParent -Description "$Description destination parent")
    }
    Move-Item -LiteralPath $sourceFull -Destination $destinationFull
}

function Remove-OpenSpecSafePackagePath {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][string]$Root,
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$Description
    )

    $pathFull = Assert-OpenSpecSafeContainedPath -Root $Root -Path $Path -Description $Description
    if (-not (Test-Path -LiteralPath $pathFull)) { return }
    [void](Assert-OpenSpecSafeTree -Root $Root -Path $pathFull -Description $Description)
    $item = Get-Item -LiteralPath $pathFull -Force
    if (($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0) {
        throw "Refusing to remove linked $Description recovery path: $pathFull"
    }
    if ($item.PSIsContainer) { Remove-Item -LiteralPath $pathFull -Recurse -Force }
    else { Remove-Item -LiteralPath $pathFull -Force }
}

Export-ModuleMember -Function @(
    'Assert-OpenSpecSafeExistingPath',
    'Assert-OpenSpecSafeContainedPath',
    'Assert-OpenSpecSafeTree',
    'Assert-OpenSpecPackagePreflight',
    'Move-OpenSpecSafePackageItem',
    'Remove-OpenSpecSafePackagePath'
)
