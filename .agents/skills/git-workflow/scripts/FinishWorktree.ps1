[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [string]$ProjectRoot = '',
    [string]$CommitMessage = '[Harness] Chore: complete goal workspace',
    [string]$SubmoduleCommitMessage = '',
    [string]$SubmoduleBranch = ''
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSScriptRoot 'Workspace.psd1') -Force
Complete-HardnessWorkspace -ProjectRoot $ProjectRoot -CommitMessage $CommitMessage -SubmoduleCommitMessage $SubmoduleCommitMessage -SubmoduleBranch $SubmoduleBranch -WhatIf:$WhatIfPreference
