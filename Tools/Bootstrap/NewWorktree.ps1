[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Name,

    [string]$EngineRoot = '',

    [switch]$Verify,

    [switch]$DryRun,

    [switch]$NoOpenSpec,

    [switch]$NoPrewarm,

    [switch]$Force
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot '..\Shared\UnrealCommandUtils.ps1')

# ---------------------------------------------------------------------------
# Resolve & validate
# ---------------------------------------------------------------------------

$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$bootstrapScript = Join-Path $PSScriptRoot 'powershell\BootstrapWorktree.ps1'

function Test-NameValid {
    param([string]$Value)
    if ([string]::IsNullOrWhiteSpace($Value)) { return $false }
    if ($Value.Length -gt 80) { return $false }
    if ($Value -match '[\\/:\*\?"<>\|\s]') { return $false }
    if ($Value -match '\.\.') { return $false }
    return $true
}

if (-not (Test-NameValid -Value $Name)) {
    throw "Invalid -Name '$Name'. Use only letters, digits, '.', '-', '_' (no spaces / slashes / '..'); max 80 chars."
}

$reservedNames = @('main', 'master', 'HEAD', 'head')
if ($reservedNames -contains $Name) {
    throw "-Name '$Name' is a reserved branch name. Pick a unique change identifier (e.g. feature-foo, fix-bar)."
}

if (-not (Test-Path -LiteralPath (Join-Path $projectRoot '.git') -PathType Any)) {
    throw "Project root '$projectRoot' does not appear to be a git repository (missing .git)."
}

if (-not (Test-Path -LiteralPath $bootstrapScript -PathType Leaf)) {
    throw "Required helper script not found: $bootstrapScript"
}

$worktreeRel  = Join-Path '.worktrees' $Name
$worktreeRoot = Join-Path $projectRoot $worktreeRel
$openspecDir  = Join-Path $projectRoot (Join-Path 'openspec\changes' $Name)

if (Test-Path -LiteralPath $worktreeRoot -PathType Any) {
    throw "Worktree directory already exists: $worktreeRoot. Pick another -Name or remove the existing one."
}

$prevEAP = $ErrorActionPreference
$ErrorActionPreference = 'Continue'
$null = & git -C $projectRoot rev-parse --verify --quiet "refs/heads/$Name" 2>$null
$branchExists = ($LASTEXITCODE -eq 0)
$ErrorActionPreference = $prevEAP
if ($branchExists) {
    throw "Branch '$Name' already exists in '$projectRoot'. Pick another -Name or delete the existing branch."
}

if ((-not $NoOpenSpec) -and (Test-Path -LiteralPath $openspecDir -PathType Container)) {
    $existingItems = @(Get-ChildItem -LiteralPath $openspecDir -Force -ErrorAction SilentlyContinue)
    if ($existingItems.Count -gt 0 -and -not $Force) {
        throw "OpenSpec change directory already exists and is not empty: $openspecDir. Use -Force to overwrite, or -NoOpenSpec to skip."
    }
}

# ---------------------------------------------------------------------------
# Resolve EngineRoot (param > main workspace AgentConfig.ini)
# ---------------------------------------------------------------------------

function Resolve-EngineRoot {
    param(
        [string]$Override,
        [string]$ProjectRootPath
    )

    if (-not [string]::IsNullOrWhiteSpace($Override)) {
        return Normalize-PathValue -Path $Override
    }

    $configPath = Join-Path $ProjectRootPath 'AgentConfig.ini'
    if (-not (Test-Path -LiteralPath $configPath -PathType Leaf)) {
        throw "Cannot resolve EngineRoot: '$configPath' missing and -EngineRoot not supplied."
    }

    $config = Read-IniFile -Path $configPath
    $value = Get-IniValue -Config $config -Section 'Paths' -Key 'EngineRoot' -DefaultValue ''
    if ([string]::IsNullOrWhiteSpace($value)) {
        throw "Cannot resolve EngineRoot: AgentConfig.ini at '$configPath' has empty [Paths] EngineRoot. Pass -EngineRoot explicitly."
    }

    return Normalize-PathValue -Path $value
}

$resolvedEngineRoot = Resolve-EngineRoot -Override $EngineRoot -ProjectRootPath $projectRoot

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

function Write-Phase {
    param([string]$Title)
    Write-Host ''
    Write-Host ("== {0} ==" -f $Title) -ForegroundColor Cyan
}

function Invoke-CheckedGit {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Arguments,

        [string]$ErrorContext = 'git'
    )

    # Git frequently writes informational/progress messages to stderr.
    # Switch ErrorActionPreference to Continue so the harness's Stop preference
    # does not treat those messages as fatal NativeCommandErrors.
    $prevEAP = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {
        $output = & git @Arguments 2>&1
        $exitCode = $LASTEXITCODE
    }
    finally {
        $ErrorActionPreference = $prevEAP
    }

    if ($exitCode -ne 0) {
        throw ("{0} failed (exit {1}): {2}" -f $ErrorContext, $exitCode, ($output -join "`n"))
    }
    foreach ($line in $output) {
        Write-Host $line
    }
}

function Invoke-CheckedPowerShell {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Arguments,

        [string]$ErrorContext = 'powershell'
    )

    $prevEAP = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {
        & powershell.exe @Arguments
        $exitCode = $LASTEXITCODE
    }
    finally {
        $ErrorActionPreference = $prevEAP
    }

    if ($exitCode -ne 0) {
        throw ("{0} failed (exit {1})." -f $ErrorContext, $exitCode)
    }
}

function New-OpenSpecSkeleton {
    param([string]$TargetDir)

    New-Item -ItemType Directory -Path $TargetDir -Force | Out-Null
    $specsDir = Join-Path $TargetDir 'specs'
    New-Item -ItemType Directory -Path $specsDir -Force | Out-Null

    $emptyFiles = @(
        (Join-Path $TargetDir 'proposal.md'),
        (Join-Path $TargetDir 'tasks.md'),
        (Join-Path $TargetDir 'design.md'),
        (Join-Path $specsDir '.gitkeep')
    )
    foreach ($file in $emptyFiles) {
        if (-not (Test-Path -LiteralPath $file -PathType Leaf)) {
            New-Item -ItemType File -Path $file -Force | Out-Null
        }
    }
}

# ---------------------------------------------------------------------------
# DryRun
# ---------------------------------------------------------------------------

if ($DryRun) {
    Write-Phase 'Dry run plan'
    Write-Host ("ProjectRoot     : {0}" -f $projectRoot)
    Write-Host ("WorktreeRoot    : {0}" -f $worktreeRoot)
    Write-Host ("Branch (parent) : {0}  (base = current HEAD)" -f $Name)
    Write-Host ("EngineRoot      : {0}" -f $resolvedEngineRoot)
    if (-not $NoOpenSpec) {
        Write-Host ("OpenSpec dir    : {0}" -f $openspecDir)
    }
    Write-Host ''
    Write-Host 'Planned commands:' -ForegroundColor Yellow
    Write-Host ("  1. git -C `"{0}`" worktree add `"{1}`" -b `"{2}`"" -f $projectRoot, $worktreeRel, $Name)

    $bootstrapArgs = @("-ProjectRoot `"$worktreeRoot`"", "-EngineRoot `"$resolvedEngineRoot`"")
    if ($NoPrewarm) { $bootstrapArgs += '-NoPrewarm' }
    if ($Force)     { $bootstrapArgs += '-Force' }
    Write-Host ("  2. powershell -File `"{0}`" {1}" -f $bootstrapScript, ($bootstrapArgs -join ' '))

    if (-not $NoOpenSpec) {
        Write-Host ("  3. mkdir `"{0}`" + create proposal.md / tasks.md / design.md / specs/.gitkeep" -f $openspecDir)
    }
    if ($Verify) {
        Write-Host ("  4. powershell -File `"{0}\Tools\RunBuild.ps1`" -Label `"worktree-verify-{1}`"" -f $worktreeRoot, $Name)
    }
    Write-Host ''
    Write-Host 'No filesystem or git changes were made.' -ForegroundColor Green
    return
}

# ---------------------------------------------------------------------------
# Phase A: create parent worktree
# ---------------------------------------------------------------------------

Write-Phase ("Phase A: create parent worktree '{0}'" -f $worktreeRel)
Invoke-CheckedGit -Arguments @('-C', $projectRoot, 'worktree', 'add', $worktreeRel, '-b', $Name) -ErrorContext 'git worktree add'

if (-not (Test-Path -LiteralPath $worktreeRoot -PathType Container)) {
    throw "git worktree add reported success but '$worktreeRoot' does not exist."
}

# ---------------------------------------------------------------------------
# Phase B: bootstrap submodules + AgentConfig + TargetInfo
# ---------------------------------------------------------------------------

Write-Phase 'Phase B: bootstrap submodules + AgentConfig.ini'
$bootstrapForwarded = @(
    '-NoProfile'
    '-ExecutionPolicy'; 'Bypass'
    '-File'; $bootstrapScript
    '-ProjectRoot'; $worktreeRoot
    '-EngineRoot';  $resolvedEngineRoot
)
if ($NoPrewarm) { $bootstrapForwarded += '-NoPrewarm' }
if ($Force)     { $bootstrapForwarded += '-Force' }

Invoke-CheckedPowerShell -Arguments $bootstrapForwarded -ErrorContext "BootstrapWorktree.ps1 (worktree at '$worktreeRoot' is left in place for manual recovery; see Documents/Guides/SubmoduleWorktreeWorkflow.md)"

# ---------------------------------------------------------------------------
# Phase C: OpenSpec skeleton
# ---------------------------------------------------------------------------

if (-not $NoOpenSpec) {
    Write-Phase ("Phase C: create OpenSpec skeleton 'openspec/changes/{0}'" -f $Name)
    try {
        New-OpenSpecSkeleton -TargetDir $openspecDir
        Write-Host ("[openspec] Created: {0}" -f $openspecDir)
    }
    catch {
        Write-Warning ("[openspec] Failed to create skeleton at {0}: {1}" -f $openspecDir, $_.Exception.Message)
        Write-Warning '[openspec] You can manually create proposal.md / tasks.md / design.md / specs/.gitkeep before running openspec-propose.'
    }
}

# ---------------------------------------------------------------------------
# Phase D: optional verify build
# ---------------------------------------------------------------------------

if ($Verify) {
    Write-Phase 'Phase D: verify build via RunBuild.ps1'
    $worktreeRunBuild = Join-Path $worktreeRoot 'Tools\RunBuild.ps1'
    if (-not (Test-Path -LiteralPath $worktreeRunBuild -PathType Leaf)) {
        throw "RunBuild.ps1 not found in new worktree: $worktreeRunBuild"
    }

    Invoke-CheckedPowerShell -Arguments @(
        '-NoProfile'
        '-ExecutionPolicy'; 'Bypass'
        '-File'; $worktreeRunBuild
        '-Label'; ("worktree-verify-{0}" -f $Name)
    ) -ErrorContext "RunBuild.ps1 (worktree at '$worktreeRoot' is left in place; check the build log)"
}

# ---------------------------------------------------------------------------
# Phase E: summary
# ---------------------------------------------------------------------------

Write-Phase 'Done'
Write-Host ("Worktree     : {0}" -f $worktreeRoot)
Write-Host ("Branch       : {0}" -f $Name)
Write-Host ("AgentConfig  : {0}" -f (Join-Path $worktreeRoot 'AgentConfig.ini'))
if (-not $NoOpenSpec) {
    Write-Host ("OpenSpec dir : {0}" -f $openspecDir)
}
Write-Host ''
Write-Host 'Next steps:' -ForegroundColor Yellow
Write-Host ("  cd {0}" -f $worktreeRel)
Write-Host '  # then continue with one of:'
Write-Host '  #   openspec propose / openspec apply'
Write-Host '  #   powershell -File Tools\RunBuild.ps1'
Write-Host '  #   powershell -File Tools\RunTests.ps1'
