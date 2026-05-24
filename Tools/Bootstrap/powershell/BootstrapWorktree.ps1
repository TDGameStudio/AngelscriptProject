[CmdletBinding()]
param(
    [string]$ProjectRoot = '',

    [switch]$AllRegisteredWorktrees,

    [string]$EngineRoot = '',

    [switch]$NoPrewarm,

    [switch]$Force
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot '..\..\Shared\UnrealCommandUtils.ps1')

function Resolve-BootstrapProjectRoot {
    param(
        [string]$ProjectRootValue
    )

    if ([string]::IsNullOrWhiteSpace($ProjectRootValue)) {
        return (Resolve-Path (Join-Path $PSScriptRoot '..\..\..')).Path
    }

    return (Resolve-Path $ProjectRootValue).Path
}

function Get-RegisteredWorktreeRoots {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RepositoryRoot
    )

    $gitOutput = & git -C $RepositoryRoot worktree list --porcelain 2>$null
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to enumerate git worktrees from '$RepositoryRoot'."
    }

    $roots = New-Object System.Collections.Generic.List[string]
    foreach ($line in $gitOutput) {
        if ($line -like 'worktree *') {
            $roots.Add((Normalize-PathValue -Path $line.Substring(9))) | Out-Null
        }
    }

    return @($roots)
}

function Get-WorktreeConfigSnapshot {
    param(
        [Parameter(Mandatory = $true)]
        [string]$WorktreeRoot
    )

    $configPath = Join-Path $WorktreeRoot 'AgentConfig.ini'
    if (-not (Test-Path -LiteralPath $configPath -PathType Leaf)) {
        return $null
    }

    return Read-IniFile -Path $configPath
}

function Get-PreferredConfigValue {
    param(
        [hashtable]$PrimaryConfig,
        [hashtable]$FallbackConfig,
        [Parameter(Mandatory = $true)]
        [string]$Section,
        [Parameter(Mandatory = $true)]
        [string]$Key,
        [string]$DefaultValue = ''
    )

    $primaryValue = if ($null -ne $PrimaryConfig) {
        Get-IniValue -Config $PrimaryConfig -Section $Section -Key $Key -DefaultValue ''
    }
    else {
        ''
    }

    if (-not [string]::IsNullOrWhiteSpace($primaryValue)) {
        return $primaryValue
    }

    $fallbackValue = if ($null -ne $FallbackConfig) {
        Get-IniValue -Config $FallbackConfig -Section $Section -Key $Key -DefaultValue ''
    }
    else {
        ''
    }

    if (-not [string]::IsNullOrWhiteSpace($fallbackValue)) {
        return $fallbackValue
    }

    return $DefaultValue
}

function Resolve-ProjectFileForBootstrap {
    param(
        [Parameter(Mandatory = $true)]
        [string]$WorktreeRoot
    )

    $uproject = Get-ChildItem -LiteralPath $WorktreeRoot -Filter *.uproject -File | Select-Object -First 1
    if ($null -eq $uproject) {
        throw "Could not resolve a .uproject file from '$WorktreeRoot'."
    }

    return (Normalize-PathValue -Path $uproject.FullName)
}

function Get-BootstrapConfigTemplate {
    param(
        [Parameter(Mandatory = $true)]
        [string]$WorktreeRoot,

        [string]$EngineRootOverride,

        [hashtable]$ExistingConfig,

        [hashtable]$SourceConfig
    )

    $resolvedProjectFile = Resolve-ProjectFileForBootstrap -WorktreeRoot $WorktreeRoot
    $resolvedEngineRoot = if (-not [string]::IsNullOrWhiteSpace($EngineRootOverride)) {
        Normalize-PathValue -Path $EngineRootOverride
    }
    else {
        $candidateEngineRoot = Get-PreferredConfigValue -PrimaryConfig $ExistingConfig -FallbackConfig $SourceConfig -Section 'Paths' -Key 'EngineRoot' -DefaultValue ''
        if ([string]::IsNullOrWhiteSpace($candidateEngineRoot)) {
            throw "Could not resolve EngineRoot for '$WorktreeRoot'. Pass -EngineRoot or bootstrap from a worktree that already has AgentConfig.ini."
        }
        Normalize-PathValue -Path $candidateEngineRoot
    }

    return [ordered]@{
        Paths      = [ordered]@{
            EngineRoot  = $resolvedEngineRoot
            ProjectFile = $resolvedProjectFile
        }
        Build      = [ordered]@{
            Architecture     = Get-PreferredConfigValue -PrimaryConfig $ExistingConfig -FallbackConfig $SourceConfig -Section 'Build' -Key 'Architecture' -DefaultValue 'x64'
            Configuration    = Get-PreferredConfigValue -PrimaryConfig $ExistingConfig -FallbackConfig $SourceConfig -Section 'Build' -Key 'Configuration' -DefaultValue 'Development'
            DefaultTimeoutMs = Get-PreferredConfigValue -PrimaryConfig $ExistingConfig -FallbackConfig $SourceConfig -Section 'Build' -Key 'DefaultTimeoutMs' -DefaultValue '180000'
            EditorTarget     = Get-PreferredConfigValue -PrimaryConfig $ExistingConfig -FallbackConfig $SourceConfig -Section 'Build' -Key 'EditorTarget' -DefaultValue 'AngelscriptProjectEditor'
            Platform         = Get-PreferredConfigValue -PrimaryConfig $ExistingConfig -FallbackConfig $SourceConfig -Section 'Build' -Key 'Platform' -DefaultValue 'Win64'
        }
        References = [ordered]@{
            HazelightAngelscriptEngineRoot = Get-PreferredConfigValue -PrimaryConfig $ExistingConfig -FallbackConfig $SourceConfig -Section 'References' -Key 'HazelightAngelscriptEngineRoot' -DefaultValue ''
        }
        Test       = [ordered]@{
            DefaultTimeoutMs = Get-PreferredConfigValue -PrimaryConfig $ExistingConfig -FallbackConfig $SourceConfig -Section 'Test' -Key 'DefaultTimeoutMs' -DefaultValue '600000'
        }
    }
}

function Invoke-SubmoduleInit {
    param(
        [Parameter(Mandatory = $true)]
        [string]$WorktreeRoot
    )

    $gitmodulesPath = Join-Path $WorktreeRoot '.gitmodules'
    if (-not (Test-Path -LiteralPath $gitmodulesPath -PathType Leaf)) {
        return
    }

    $submoduleNames = @()
    foreach ($line in (Get-Content -LiteralPath $gitmodulesPath)) {
        if ($line -match '^\s*path\s*=\s*(.+)$') {
            $submoduleNames += $Matches[1].Trim()
        }
    }

    if ($submoduleNames.Count -eq 0) {
        return
    }

    Write-Host ("[bootstrap] Found {0} submodule(s): {1}" -f $submoduleNames.Count, ($submoduleNames -join ', '))

    $prevEAP = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    $initOutput = & git -C $WorktreeRoot submodule init 2>&1
    $initExitCode = $LASTEXITCODE
    $ErrorActionPreference = $prevEAP
    if ($initExitCode -ne 0) {
        Write-Warning "[bootstrap] git submodule init had warnings (exit $initExitCode): $initOutput"
    }

    foreach ($subPath in $submoduleNames) {
        $subFullPath = Join-Path $WorktreeRoot $subPath
        $subSourceDir = Join-Path $subFullPath 'Source'

        if ((Test-Path -LiteralPath $subSourceDir -PathType Container)) {
            Write-Host ("[bootstrap] Submodule already populated: {0}" -f $subPath)
            continue
        }

        Write-Host ("[bootstrap] Updating submodule: {0}" -f $subPath)
        $prevEAP = $ErrorActionPreference
        $ErrorActionPreference = 'Continue'
        $updateOutput = & git -C $WorktreeRoot submodule update -- $subPath 2>&1
        $updateExitCode = $LASTEXITCODE
        $ErrorActionPreference = $prevEAP
        if ($updateExitCode -eq 0) {
            Write-Host ("[bootstrap] Submodule updated: {0}" -f $subPath)
            continue
        }

        Write-Warning ("[bootstrap] git submodule update failed for {0} (exit {1}): {2}" -f $subPath, $updateExitCode, $updateOutput)
        Write-Warning ("[bootstrap] Fallback: checking if local submodule object store can provide a worktree...")

        $commonDir = & git -C $WorktreeRoot rev-parse --git-common-dir 2>$null
        if ([string]::IsNullOrWhiteSpace($commonDir)) {
            Write-Warning ("[bootstrap] Cannot resolve git-common-dir for fallback. Submodule {0} left uninitialized." -f $subPath)
            continue
        }

        $normalizedSubPath = $subPath.Replace('\', '/')
        $submoduleGitDir = Join-Path (Resolve-Path $commonDir).Path "modules/$normalizedSubPath"
        if (-not (Test-Path -LiteralPath $submoduleGitDir -PathType Container)) {
            Write-Warning ("[bootstrap] No local object store at {0}. Submodule {1} left uninitialized." -f $submoduleGitDir, $subPath)
            continue
        }

        # A failed 'git submodule update' may have left a stub at $subFullPath
        # (typically just a '.git' link file with no Source/). 'git worktree add'
        # refuses to populate an existing non-empty path, so drop the stub here.
        # Source/ was already checked above; reaching this point means the
        # submodule is not properly populated, so anything in $subFullPath is
        # leftover junk from the failed update.
        if (Test-Path -LiteralPath $subFullPath -PathType Container) {
            Write-Host ("[bootstrap] Cleaning partial submodule stub before fallback: {0}" -f $subFullPath)
            Remove-Item -LiteralPath $subFullPath -Recurse -Force -ErrorAction SilentlyContinue
        }

        $worktreeBranch = (Split-Path $WorktreeRoot -Leaf)
        Write-Host ("[bootstrap] Creating submodule worktree from local object store: {0} -> {1}" -f $submoduleGitDir, $subFullPath)
        $prevEAP = $ErrorActionPreference
        $ErrorActionPreference = 'Continue'
        $wtOutput = & git --git-dir $submoduleGitDir worktree add $subFullPath -b $worktreeBranch 2>&1
        $wtExitCode = $LASTEXITCODE
        $ErrorActionPreference = $prevEAP
        if ($wtExitCode -eq 0) {
            Write-Host ("[bootstrap] Submodule worktree created: {0} (branch: {1})" -f $subPath, $worktreeBranch)
        }
        else {
            Write-Warning ("[bootstrap] Submodule worktree creation failed for {0} (exit {1}): {2}" -f $subPath, $wtExitCode, $wtOutput)
            Write-Warning ("[bootstrap] Submodule {0} left uninitialized. Manual setup required — see Documents/Guides/SubmoduleWorktreeWorkflow.md" -f $subPath)
        }
    }
}

function Invoke-WorktreeBootstrap {
    param(
        [Parameter(Mandatory = $true)]
        [string]$WorktreeRoot,

        [string]$EngineRootOverride,

        [hashtable]$SourceConfig,

        [switch]$SkipPrewarm,

        [switch]$ForceRewrite
    )

    $resolvedWorktreeRoot = Normalize-PathValue -Path $WorktreeRoot
    $configPath = Join-Path $resolvedWorktreeRoot 'AgentConfig.ini'
    $existingConfig = Get-WorktreeConfigSnapshot -WorktreeRoot $resolvedWorktreeRoot
    $targetConfig = Get-BootstrapConfigTemplate -WorktreeRoot $resolvedWorktreeRoot -EngineRootOverride $EngineRootOverride -ExistingConfig $existingConfig -SourceConfig $SourceConfig

    $shouldWrite = $true
    if (-not $ForceRewrite -and $null -ne $existingConfig) {
        $existingJson = $existingConfig | ConvertTo-Json -Depth 8
        $targetJson = $targetConfig | ConvertTo-Json -Depth 8
        $shouldWrite = $existingJson -ne $targetJson
    }

    if ($shouldWrite) {
        Write-IniFile -Path $configPath -Config $targetConfig
        Write-Host ("[bootstrap] Wrote AgentConfig.ini: {0}" -f $configPath)
    }
    else {
        Write-Host ("[bootstrap] AgentConfig.ini already normalized: {0}" -f $configPath)
    }

    Invoke-SubmoduleInit -WorktreeRoot $resolvedWorktreeRoot

    if ($SkipPrewarm) {
        return
    }

    $prewarm = Ensure-TargetInfoJson -EngineRoot $targetConfig.Paths.EngineRoot -ProjectFile $targetConfig.Paths.ProjectFile -ProjectRoot $resolvedWorktreeRoot
    if ($prewarm.Status -eq 'TimedOut' -or $prewarm.Status -eq 'Failed') {
        throw "TargetInfo.json prewarm failed for '$resolvedWorktreeRoot': $($prewarm.Message)"
    }
}

$resolvedProjectRoot = Resolve-BootstrapProjectRoot -ProjectRootValue $ProjectRoot
$worktreeRoots = if ($AllRegisteredWorktrees) {
    Get-RegisteredWorktreeRoots -RepositoryRoot $resolvedProjectRoot
}
else {
    @($resolvedProjectRoot)
}

$normalizedWorktreeRoots = @($worktreeRoots | ForEach-Object { Normalize-PathValue -Path $_ } | Select-Object -Unique)
foreach ($worktreeRoot in $normalizedWorktreeRoots) {
    $sourceConfig = $null
    foreach ($candidateRoot in $normalizedWorktreeRoots) {
        if ($candidateRoot -eq $worktreeRoot) {
            continue
        }

        $candidateConfig = Get-WorktreeConfigSnapshot -WorktreeRoot $candidateRoot
        if ($null -ne $candidateConfig) {
            $sourceConfig = $candidateConfig
            break
        }
    }

    Invoke-WorktreeBootstrap -WorktreeRoot $worktreeRoot -EngineRootOverride $EngineRoot -SourceConfig $sourceConfig -SkipPrewarm:$NoPrewarm -ForceRewrite:$Force
}
