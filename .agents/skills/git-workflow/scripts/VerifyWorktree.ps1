[CmdletBinding()]
param([string]$ProjectRoot = '', [switch]$RequireClean)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSScriptRoot 'Workspace.psd1') -Force
$result = Test-HardnessWorkspace -ProjectRoot $ProjectRoot -RequireClean:$RequireClean
$result
if (-not $result.IsValid) { exit 1 }
