#Requires -Version 7.0
#Requires -PSEdition Core

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$script:UnrealSkillRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$script:UnrealDataRoot = Join-Path $script:UnrealSkillRoot 'data'
$script:UnrealRunSchema = 'harness-unreal-run'
$script:UnrealRequestSchema = 'harness-unreal-request'
$script:UnrealTerminalStates = @('Succeeded', 'Failed', 'TimedOut', 'Cancelled')

foreach ($privateFile in @(
    'Common.ps1'
    'Engine.ps1'
    'Concurrency.ps1'
    'Run.ps1'
    'WindowsPath.ps1'
    'AutomationReport.ps1'
    'Operations.ps1'
    'Suites.ps1'
)) {
    $path = Join-Path $PSScriptRoot "Private/$privateFile"
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        throw "Unreal private module file is missing: $path"
    }
    . $path
}

Export-ModuleMember -Function @(
    'Get-HarnessUnrealStatus'
    'Get-HarnessUnrealEngineList'
    'Get-HarnessUnrealTargetList'
    'Get-HarnessUnrealProcessList'
    'Get-HarnessUnrealUbtCapabilities'
    'Invoke-HarnessUnrealUbt'
    'Invoke-HarnessUnrealBuild'
    'Invoke-HarnessUnrealTest'
    'Get-HarnessUnrealSuiteList'
    'New-HarnessUnrealSuitePlan'
    'Invoke-HarnessUnrealSuite'
    'Invoke-HarnessUnrealCommandlet'
    'Get-HarnessUnrealRunStatus'
    'Stop-HarnessUnrealRun'
)
