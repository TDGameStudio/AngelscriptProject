[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [Parameter(Mandatory = $true)][string]$WorktreeRoot,
    [string]$RepositoryRoot = '',
    [switch]$DiscardIgnoredFiles
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSScriptRoot 'Workspace.psd1') -Force
Remove-HardnessWorkspace -WorktreeRoot $WorktreeRoot -RepositoryRoot $RepositoryRoot -DiscardIgnoredFiles:$DiscardIgnoredFiles -WhatIf:$WhatIfPreference
