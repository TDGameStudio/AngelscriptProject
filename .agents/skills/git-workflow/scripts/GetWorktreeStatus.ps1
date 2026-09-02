[CmdletBinding()]
param([string]$ProjectRoot = '')

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSScriptRoot 'Workspace.psd1') -Force
Get-HardnessWorkspaceStatus -ProjectRoot $ProjectRoot
