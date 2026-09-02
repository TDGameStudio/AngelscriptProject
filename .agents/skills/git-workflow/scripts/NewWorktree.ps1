[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [Parameter(Mandatory = $true)][string]$Name,
    [string]$Branch = '',
    [string]$EngineRoot = '',
    [switch]$Verify,
    [switch]$DryRun,
    [switch]$NoOpenSpec,
    [switch]$NoPrewarm,
    [switch]$Force
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$modulePath = Join-Path $PSScriptRoot 'Workspace.psd1'
Import-Module $modulePath -Force
$repositoryRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..\..\..'))
$branchName = if ([string]::IsNullOrWhiteSpace($Branch)) { "goal/$Name" } else { $Branch }

if ($Force) {
    throw '-Force is no longer supported. Existing branches, paths, and dirty submodules are never overwritten.'
}
if (-not [string]::IsNullOrWhiteSpace($EngineRoot)) {
    Write-Warning '-EngineRoot is retained for one compatibility cycle; AgentConfig.ini is copied as an ignored file instead.'
}
if ($NoOpenSpec) {
    Write-Verbose '-NoOpenSpec is no longer needed: worktree creation never scaffolds OpenSpec records.'
}
if ($NoPrewarm) {
    Write-Verbose '-NoPrewarm is retained for compatibility; worktree creation has no build side effects.'
}

$previewOnly = $DryRun -or $WhatIfPreference
$result = New-HardnessWorkspace -Name $Name -Branch $branchName -RepositoryRoot $repositoryRoot -WhatIf:$previewOnly
if ($DryRun) {
    $result
    return
}
if ($Verify -and $result.Created) {
    $verification = Test-HardnessWorkspace -ProjectRoot $result.WorktreeRoot
    if (-not $verification.IsValid) {
        throw "New worktree failed verification: $($verification.Errors -join '; ')"
    }
}
$result
