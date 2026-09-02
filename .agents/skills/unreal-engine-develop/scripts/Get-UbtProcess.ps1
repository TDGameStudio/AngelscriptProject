[CmdletBinding()]
param(
    [string]$WorktreeRoot = '',

    [switch]$CurrentWorktreeOnly
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot 'Shared\UnrealCommandUtils.ps1')

$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..\..\..')).Path
$filterRoot = if ($CurrentWorktreeOnly -and [string]::IsNullOrWhiteSpace($WorktreeRoot)) {
    $projectRoot
}
else {
    $WorktreeRoot
}

$processes = @(Get-UbtProcessInfo -RepositoryRoot $projectRoot -WorktreeRoot $filterRoot)
if ($processes.Count -eq 0) {
    Write-Host 'No UBT-related processes found.'
    exit 0
}

$processes | Select-Object `
    ProcessId, `
    ParentProcessId, `
    ProcessName, `
    Kind, `
    StartedAt, `
    Branch, `
    WorktreeRoot, `
    ProjectFile, `
    Target, `
    Platform, `
    Configuration, `
    UsesNoMutex, `
    UsesNoEngineChanges
