param(
    [string]$ManifestPath = (Join-Path $PSScriptRoot 'references\manifest.psd1'),
    [string]$DestinationRoot = (Join-Path $PSScriptRoot 'references'),
    [string]$LocalCacheRoot = (Join-Path $PSScriptRoot 'Temp')
)

$ErrorActionPreference = 'Stop'

function Resolve-NormalizedPath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,

        [Parameter(Mandatory = $true)]
        [string]$BaseDirectory
    )

    if ([System.IO.Path]::IsPathRooted($Path)) {
        return [System.IO.Path]::GetFullPath($Path)
    }

    return [System.IO.Path]::GetFullPath((Join-Path $BaseDirectory $Path))
}

function Invoke-Git {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Arguments,

        [string]$WorkingDirectory = $PSScriptRoot
    )

    & git @Arguments 2>&1 | ForEach-Object { Write-Output $_ }
    if ($LASTEXITCODE -ne 0) {
        throw "git command failed with exit code ${LASTEXITCODE}: git $($Arguments -join ' ')"
    }
}

function Get-GitOutput {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Arguments
    )

    $output = & git @Arguments 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "git command failed with exit code ${LASTEXITCODE}: git $($Arguments -join ' ')"
    }

    return ($output | Out-String).Trim()
}

function Test-PathWithinRoot {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RootPath,

        [Parameter(Mandatory = $true)]
        [string]$CandidatePath
    )

    $normalizedRoot = [System.IO.Path]::TrimEndingDirectorySeparator([System.IO.Path]::GetFullPath($RootPath))
    $normalizedCandidate = [System.IO.Path]::GetFullPath($CandidatePath)

    return $normalizedCandidate.StartsWith($normalizedRoot + [System.IO.Path]::DirectorySeparatorChar, [System.StringComparison]::OrdinalIgnoreCase) -or
        $normalizedCandidate.Equals($normalizedRoot, [System.StringComparison]::OrdinalIgnoreCase)
}

$resolvedManifestPath = Resolve-NormalizedPath -Path $ManifestPath -BaseDirectory $PSScriptRoot
$resolvedDestinationRoot = Resolve-NormalizedPath -Path $DestinationRoot -BaseDirectory $PSScriptRoot
$resolvedLocalCacheRoot = Resolve-NormalizedPath -Path $LocalCacheRoot -BaseDirectory $PSScriptRoot

if (-not (Test-Path $resolvedManifestPath)) {
    throw "Reference manifest not found: $resolvedManifestPath"
}

$dangerRoots = @(
    [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '.codexloop')),
    [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot 'tests\.tmp'))
)

foreach ($dangerRoot in $dangerRoots) {
    if ($resolvedDestinationRoot.StartsWith($dangerRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "DestinationRoot must not live under $dangerRoot"
    }
}

$manifest = Import-PowerShellDataFile -Path $resolvedManifestPath
if ($null -eq $manifest.Repositories -or $manifest.Repositories.Count -eq 0) {
    throw "Manifest contains no repositories: $resolvedManifestPath"
}

New-Item -ItemType Directory -Path $resolvedDestinationRoot -Force | Out-Null

$results = @()

foreach ($repository in $manifest.Repositories) {
    $targetPath = Resolve-NormalizedPath -Path $repository.Path -BaseDirectory $resolvedDestinationRoot
    if (-not (Test-PathWithinRoot -RootPath $resolvedDestinationRoot -CandidatePath $targetPath)) {
        throw "Repository path '$($repository.Path)' must stay within DestinationRoot '$resolvedDestinationRoot'."
    }

    $targetParent = Split-Path -Parent $targetPath
    New-Item -ItemType Directory -Path $targetParent -Force | Out-Null

    if (Test-Path (Join-Path $targetPath '.git')) {
        Invoke-Git -Arguments @('-C', $targetPath, 'fetch', '--all', '--tags', '--prune')
        $status = 'updated'
    } else {
        if (Test-Path $targetPath) {
            throw "Target path exists but is not a git repository: $targetPath"
        }

        try {
            Invoke-Git -Arguments @('clone', '--no-hardlinks', $repository.Url, $targetPath)
            $status = 'cloned'
        } catch {
            $cachePath = Resolve-NormalizedPath -Path $repository.Path -BaseDirectory $resolvedLocalCacheRoot
            if (-not (Test-Path (Join-Path $cachePath '.git'))) {
                throw
            }

            Remove-Item -Path $targetPath -Recurse -Force -ErrorAction SilentlyContinue
            Invoke-Git -Arguments @('clone', '--no-hardlinks', $cachePath, $targetPath)
            $status = 'cloned-from-cache'
        }
    }

    $head = Get-GitOutput -Arguments @('-C', $targetPath, 'rev-parse', '--short', 'HEAD')
    $results += [pscustomobject]@{
        name   = $repository.Name
        path   = $targetPath
        status = $status
        head   = $head
    }
}

$results | ConvertTo-Json -Depth 4
