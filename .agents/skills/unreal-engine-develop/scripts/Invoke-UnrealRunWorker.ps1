[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string] $RequestPath
)

#Requires -Version 7.0
#Requires -PSEdition Core

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$manifest = Join-Path $PSScriptRoot 'UnrealEngineDevelop.psd1'
Import-Module $manifest -Force -ErrorAction Stop
$module = Get-Module UnrealEngineDevelop -ErrorAction Stop
$result = & $module { param($Path) Invoke-UnrealRequestWorker -RequestPath $Path } $RequestPath
$exitCode = if ($null -ne $result -and $null -ne $result.exitCode) { [int] $result.exitCode } else { 1 }
exit $exitCode
