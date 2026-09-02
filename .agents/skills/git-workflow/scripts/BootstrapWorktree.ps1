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
$modulePath = Join-Path $PSScriptRoot 'Workspace.psd1'
Import-Module $modulePath -Force
$defaultRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..\..\..'))
$root = if ([string]::IsNullOrWhiteSpace($ProjectRoot)) { $defaultRoot } else { (Resolve-Path -LiteralPath $ProjectRoot).Path }

if ($Force) {
    throw '-Force is no longer supported. Bootstrap never overwrites data or moves a dirty submodule.'
}
if (-not [string]::IsNullOrWhiteSpace($EngineRoot)) {
    Write-Warning '-EngineRoot is retained for one compatibility cycle; bootstrap copies an existing ignored AgentConfig.ini.'
}
if ($NoPrewarm) {
    Write-Verbose '-NoPrewarm is retained for compatibility; bootstrap has no build or prewarm side effects.'
}

if ($AllRegisteredWorktrees) {
    $lines = & git -C $root worktree list --porcelain 2>&1
    if ($LASTEXITCODE -ne 0) { throw "Unable to list worktrees from '$root': $($lines -join [Environment]::NewLine)" }
    $roots = @($lines | Where-Object { $_ -like 'worktree *' } | ForEach-Object { $_.Substring(9).Trim() })
    $source = $roots | Where-Object { Test-Path -LiteralPath (Join-Path $_ 'AgentConfig.ini') -PathType Leaf } | Select-Object -First 1
    foreach ($item in $roots) {
        Initialize-HardnessWorkspace -ProjectRoot $item -SourceRoot $source
    }
    return
}

Initialize-HardnessWorkspace -ProjectRoot $root
