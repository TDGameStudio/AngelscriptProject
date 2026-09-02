<#
.SYNOPSIS
    List Unreal Engine installations registered on this Windows machine as JSON.

.DESCRIPTION
    Mirrors DesktopPlatform EnumerateEngineInstallations:
      1. LauncherInstalled.dat AppName starting with UE_ (identifier is the suffix, e.g. 5.8)
      2. HKCU\SOFTWARE\Epic Games\Unreal Engine\Builds (GUID -> path)
    Also reads HKLM\SOFTWARE\EpicGames\Unreal Engine\<ver>\InstalledDirectory,
    which ushell uses to resolve a non-GUID EngineAssociation.

    Does not delete invalid HKCU values (UnrealVersionSelector may). Stdout is JSON only.

.PARAMETER Pretty
    Indent JSON. Default is compact.

.PARAMETER OnlyExisting
    Omit registrations whose directory is missing on disk.

.PARAMETER OnlyValid
    Omit roots that fail the official Engine/Binaries + Engine/Build check.

.PARAMETER ProjectRoot
    Optional worktree root used to attach currentProject from AgentConfig.ini.
    Defaults to this repository root (four levels above the script).

.NOTES
    Runtime is collect -> merge by path -> probe disk -> filter -> JSON stdout.
    Stdout is JSON only; warnings stay inside the payload.

==============================================================================
                    Phase 1: Collect registrations
==============================================================================
Get-EngineInstallations.ps1
├─1─ Read-LauncherInstallations          // %ProgramData%\Epic\...\LauncherInstalled.dat
│       AppName "UE_*"  -> identifier = suffix ("5.8")
├─2─ Read-HkcuBuildInstallations         // HKCU\...\Unreal Engine\Builds
│       value name      -> identifier = {GUID}
└─3─ Read-HklmInstalledInstallations     // HKLM\...\EpicGames\Unreal Engine\<ver>
        InstalledDirectory -> identifier = "5.7"   (ushell resolve; not UVS enumerate)

        │
        ▼  each row -> Add-EngineInstallation
==============================================================================
                    Phase 2: Merge
==============================================================================
Dictionary[normalized-path]
    Sources[]       launcher | hkcu-builds | hklm-installed
    Identifiers[]   "5.8" and/or {GUID}
        │
        ▼  ConvertTo-EngineRecord  (preferred identifier: stock version over GUID)
==============================================================================
                    Phase 3: Probe + classify
==============================================================================
exists              Test-Path engine root
isValidRoot         Engine\Binaries + Engine\Build          // official IsValidRootDirectory
isSourceDistribution  SourceDistribution.txt (or GPF.bat)
isStockRelease      identifier is not a GUID
kind                source | stock | binary
Build.version / hasUbt / hasEditor
        │
        ▼  -OnlyExisting / -OnlyValid  drop rows
==============================================================================
                    Phase 4: Emit
==============================================================================
currentProject from AgentConfig.ini  +  engines[]  +  warnings[]
        │
        ▼  ConvertTo-Json -> [Console]::Out     // no Write-Host
#>
[CmdletBinding()]
param(
    [switch]$Pretty,

    [switch]$OnlyExisting,

    [switch]$OnlyValid,

    [string]$ProjectRoot = ''
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot 'Shared\UnrealCommandUtils.ps1')

function Get-DefaultProjectRoot {
    return (Resolve-Path (Join-Path $PSScriptRoot '..\..\..\..')).Path
}

function Get-LauncherInstalledDatPath {
    return (Join-Path $env:ProgramData 'Epic\UnrealEngineLauncher\LauncherInstalled.dat')
}

function Test-IsStockEngineIdentifier {
    param([string]$Identifier)
    if ([string]::IsNullOrWhiteSpace($Identifier)) {
        return $false
    }
    $guid = [guid]::Empty
    return -not [guid]::TryParse($Identifier.Trim('{}'), [ref]$guid)
}

function Test-IsValidEngineRootDirectory {
    param([string]$RootDir)
    if ([string]::IsNullOrWhiteSpace($RootDir) -or -not (Test-Path -LiteralPath $RootDir -PathType Container)) {
        return $false
    }
    $binaries = Join-Path $RootDir 'Engine\Binaries'
    $build = Join-Path $RootDir 'Engine\Build'
    return (Test-Path -LiteralPath $binaries -PathType Container) -and
        (Test-Path -LiteralPath $build -PathType Container)
}

function Test-IsSourceDistribution {
    param([string]$RootDir)
    if ([string]::IsNullOrWhiteSpace($RootDir)) {
        return $false
    }

    $buildVersionPath = Join-Path $RootDir 'Engine\Build\Build.version'
    if (-not (Test-Path -LiteralPath $buildVersionPath -PathType Leaf)) {
        $generateProjectFiles = Join-Path $RootDir 'GenerateProjectFiles.bat'
        if (Test-Path -LiteralPath $generateProjectFiles -PathType Leaf) {
            return $true
        }
    }

    $sourceDistribution = Join-Path $RootDir 'Engine\Build\SourceDistribution.txt'
    return Test-Path -LiteralPath $sourceDistribution -PathType Leaf
}

function New-EngineAccumulator {
    return New-Object 'System.Collections.Generic.Dictionary[string,hashtable]' ([System.StringComparer]::OrdinalIgnoreCase)
}

function Add-EngineInstallation {
    param(
        [Parameter(Mandatory = $true)]
        [System.Collections.Generic.Dictionary[string,hashtable]]$Accumulator,

        [Parameter(Mandatory = $true)]
        [string]$Path,

        [Parameter(Mandatory = $true)]
        [string]$Source,

        [string]$Identifier = '',

        [AllowEmptyCollection()]
        [System.Collections.Generic.List[string]]$Warnings
    )

    $trimmed = $Path.Trim().Trim('"')
    if ([string]::IsNullOrWhiteSpace($trimmed)) {
        $Warnings.Add("Skipped empty path from '$Source'.") | Out-Null
        return
    }

    try {
        $normalized = Normalize-PathValue -Path $trimmed
    }
    catch {
        $Warnings.Add("Skipped invalid path from '$Source': $trimmed ($($_.Exception.Message))") | Out-Null
        return
    }

    $key = $normalized.ToLowerInvariant()
    if (-not $Accumulator.ContainsKey($key)) {
        $Accumulator[$key] = @{
            Path         = $normalized
            Sources      = New-Object 'System.Collections.Generic.List[string]'
            Identifiers  = New-Object 'System.Collections.Generic.List[string]'
        }
    }

    $entry = $Accumulator[$key]
    if (-not $entry.Sources.Contains($Source)) {
        $entry.Sources.Add($Source) | Out-Null
    }
    if (-not [string]::IsNullOrWhiteSpace($Identifier) -and -not $entry.Identifiers.Contains($Identifier)) {
        $entry.Identifiers.Add($Identifier) | Out-Null
    }
}

function Read-LauncherInstallations {
    param(
        [Parameter(Mandatory = $true)]
        [System.Collections.Generic.Dictionary[string,hashtable]]$Accumulator,

        [AllowEmptyCollection()]
        [System.Collections.Generic.List[string]]$Warnings
    )

    $datPath = Get-LauncherInstalledDatPath
    if (-not (Test-Path -LiteralPath $datPath -PathType Leaf)) {
        return
    }

    try {
        $raw = [System.IO.File]::ReadAllText($datPath)
        $parsed = $raw | ConvertFrom-Json
        foreach ($item in @($parsed.InstallationList)) {
            $appName = [string]$item.AppName
            # Official: AppName.RemoveFromStart("UE_") then identifier is the remainder ("5.8").
            if (-not $appName.StartsWith('UE_', [System.StringComparison]::Ordinal)) {
                continue
            }
            $identifier = $appName.Substring(3)
            if ([string]::IsNullOrWhiteSpace($identifier)) {
                continue
            }
            Add-EngineInstallation `
                -Accumulator $Accumulator `
                -Path ([string]$item.InstallLocation) `
                -Source 'launcher' `
                -Identifier $identifier `
                -Warnings $Warnings
        }
    }
    catch {
        $Warnings.Add("Failed to read LauncherInstalled.dat: $($_.Exception.Message)") | Out-Null
    }
}

function Read-HkcuBuildInstallations {
    param(
        [Parameter(Mandatory = $true)]
        [System.Collections.Generic.Dictionary[string,hashtable]]$Accumulator,

        [AllowEmptyCollection()]
        [System.Collections.Generic.List[string]]$Warnings
    )

    $registryPath = 'HKCU:\Software\Epic Games\Unreal Engine\Builds'
    if (-not (Test-Path -LiteralPath $registryPath)) {
        return
    }

    try {
        $item = Get-Item -LiteralPath $registryPath
        foreach ($name in @($item.GetValueNames())) {
            if ([string]::IsNullOrWhiteSpace($name)) {
                continue
            }
            Add-EngineInstallation `
                -Accumulator $Accumulator `
                -Path ([string]$item.GetValue($name)) `
                -Source 'hkcu-builds' `
                -Identifier $name `
                -Warnings $Warnings
        }
    }
    catch {
        $Warnings.Add("Failed to read HKCU Builds: $($_.Exception.Message)") | Out-Null
    }
}

function Read-HklmInstalledInstallations {
    param(
        [Parameter(Mandatory = $true)]
        [System.Collections.Generic.Dictionary[string,hashtable]]$Accumulator,

        [AllowEmptyCollection()]
        [System.Collections.Generic.List[string]]$Warnings
    )

    $roots = @(
        'HKLM:\SOFTWARE\EpicGames\Unreal Engine',
        'HKLM:\SOFTWARE\WOW6432Node\EpicGames\Unreal Engine'
    )

    foreach ($root in $roots) {
        if (-not (Test-Path -LiteralPath $root)) {
            continue
        }

        try {
            foreach ($child in @(Get-ChildItem -LiteralPath $root)) {
                $installed = [string]$child.GetValue('InstalledDirectory')
                if ([string]::IsNullOrWhiteSpace($installed)) {
                    continue
                }
                Add-EngineInstallation `
                    -Accumulator $Accumulator `
                    -Path $installed `
                    -Source 'hklm-installed' `
                    -Identifier $child.PSChildName `
                    -Warnings $Warnings
            }
        }
        catch {
            $Warnings.Add("Failed to read '$root': $($_.Exception.Message)") | Out-Null
        }
    }
}

function Read-BuildVersionInfo {
    param([Parameter(Mandatory = $true)][string]$EngineRoot)

    $versionPath = Join-Path $EngineRoot 'Engine\Build\Build.version'
    if (-not (Test-Path -LiteralPath $versionPath -PathType Leaf)) {
        return $null
    }

    $raw = [System.IO.File]::ReadAllText($versionPath)
    return ($raw | ConvertFrom-Json)
}

function Get-PreferredIdentifier {
    param([string[]]$Identifiers)

    $stock = @($Identifiers | Where-Object { Test-IsStockEngineIdentifier -Identifier $_ } | Sort-Object)
    if ($stock.Count -gt 0) {
        return [string]$stock[0]
    }
    if ($Identifiers.Count -gt 0) {
        return [string]$Identifiers[0]
    }
    return $null
}

function ConvertTo-EngineRecord {
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$Entry
    )

    $path = [string]$Entry.Path
    $exists = Test-Path -LiteralPath $path -PathType Container
    $isValidRoot = Test-IsValidEngineRootDirectory -RootDir $path
    $isSourceDistribution = $false
    if ($exists) {
        $isSourceDistribution = Test-IsSourceDistribution -RootDir $path
    }

    $identifiers = @($Entry.Identifiers | Sort-Object)
    $preferred = Get-PreferredIdentifier -Identifiers $identifiers
    $isStockRelease = Test-IsStockEngineIdentifier -Identifier $preferred

    $kind = 'binary'
    if ($isSourceDistribution) {
        $kind = 'source'
    }
    elseif ($isStockRelease) {
        $kind = 'stock'
    }

    $buildVersion = $null
    if ($exists) {
        try {
            $buildVersion = Read-BuildVersionInfo -EngineRoot $path
        }
        catch {
            $buildVersion = $null
        }
    }

    $major = $null
    $minor = $null
    $patch = $null
    $changelist = $null
    $branchName = $null
    $version = $null
    $isLicenseeVersion = $null
    if ($null -ne $buildVersion) {
        $major = [int]$buildVersion.MajorVersion
        $minor = [int]$buildVersion.MinorVersion
        $patch = [int]$buildVersion.PatchVersion
        $changelist = [int]$buildVersion.Changelist
        $branchName = [string]$buildVersion.BranchName
        $version = '{0}.{1}.{2}' -f $major, $minor, $patch
        $isLicenseeVersion = [bool]([int]$buildVersion.IsLicenseeVersion)
    }

    $hasUbt = $false
    $hasEditor = $false
    if ($exists) {
        $hasUbt = Test-Path -LiteralPath (Join-Path $path 'Engine\Binaries\DotNET\UnrealBuildTool\UnrealBuildTool.dll') -PathType Leaf
        $hasEditor = (
            (Test-Path -LiteralPath (Join-Path $path 'Engine\Binaries\Win64\UnrealEditor-Cmd.exe') -PathType Leaf) -or
            (Test-Path -LiteralPath (Join-Path $path 'Engine\Binaries\Win64\UnrealEditor.exe') -PathType Leaf)
        )
    }

    return [ordered]@{
        path                  = $path
        identifier            = $preferred
        identifiers           = $identifiers
        exists                = $exists
        isValidRoot           = $isValidRoot
        kind                  = $kind
        isStockRelease        = $isStockRelease
        isSourceDistribution  = $isSourceDistribution
        sources               = @($Entry.Sources | Sort-Object)
        version               = $version
        major                 = $major
        minor                 = $minor
        patch                 = $patch
        changelist            = $changelist
        branchName            = $branchName
        isLicenseeVersion     = $isLicenseeVersion
        hasUbt                = $hasUbt
        hasEditor             = $hasEditor
    }
}

function Get-CurrentProjectInfo {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ResolvedProjectRoot,

        [Parameter(Mandatory = $true)]
        [System.Collections.Generic.Dictionary[string,hashtable]]$Accumulator
    )

    $configPath = Join-Path $ResolvedProjectRoot 'AgentConfig.ini'
    if (-not (Test-Path -LiteralPath $configPath -PathType Leaf)) {
        return $null
    }

    $config = Read-IniFile -Path $configPath
    $engineRootValue = Get-IniValue -Config $config -Section 'Paths' -Key 'EngineRoot' -DefaultValue ''
    $engineRoot = $null
    $registered = $false
    if (-not [string]::IsNullOrWhiteSpace($engineRootValue)) {
        $engineRoot = Normalize-PathValue -Path $engineRootValue
        $registered = $Accumulator.ContainsKey($engineRoot.ToLowerInvariant())
    }

    return [ordered]@{
        projectRoot = (Normalize-PathValue -Path $ResolvedProjectRoot)
        configPath  = (Normalize-PathValue -Path $configPath)
        engineRoot  = $engineRoot
        registered  = $registered
    }
}

$warnings = New-Object 'System.Collections.Generic.List[string]'
$accumulator = New-EngineAccumulator
$resolvedProjectRoot = if ([string]::IsNullOrWhiteSpace($ProjectRoot)) {
    Get-DefaultProjectRoot
}
else {
    Normalize-PathValue -Path $ProjectRoot
}

Read-LauncherInstallations -Accumulator $accumulator -Warnings $warnings
Read-HkcuBuildInstallations -Accumulator $accumulator -Warnings $warnings
Read-HklmInstalledInstallations -Accumulator $accumulator -Warnings $warnings

$records = New-Object 'System.Collections.Generic.List[object]'
foreach ($entry in @($accumulator.Values)) {
    $record = ConvertTo-EngineRecord -Entry $entry
    if ($OnlyExisting -and -not $record.exists) {
        continue
    }
    if ($OnlyValid -and -not $record.isValidRoot) {
        continue
    }
    $records.Add($record) | Out-Null
}

$sorted = @(
    $records | Sort-Object `
        @{ Expression = { -not $_.isValidRoot } }, `
        @{ Expression = { -not $_.exists } }, `
        @{ Expression = { if ($null -eq $_.major) { -1 } else { $_.major } }; Descending = $true }, `
        @{ Expression = { if ($null -eq $_.minor) { -1 } else { $_.minor } }; Descending = $true }, `
        @{ Expression = { if ($null -eq $_.patch) { -1 } else { $_.patch } }; Descending = $true }, `
        @{ Expression = { $_.path } }
)

$payload = [ordered]@{
    generatedAtUtc = [DateTime]::UtcNow.ToString('o')
    currentProject = Get-CurrentProjectInfo -ResolvedProjectRoot $resolvedProjectRoot -Accumulator $accumulator
    engines        = @($sorted)
    warnings       = @($warnings)
}

$json = ConvertTo-Json -InputObject $payload -Depth 8 -Compress:(-not $Pretty)
[Console]::Out.Write($json)
if ($Pretty) {
    [Console]::Out.WriteLine()
}
