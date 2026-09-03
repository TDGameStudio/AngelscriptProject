@{
    RootModule        = 'UnrealEngineDevelop.psm1'
    ModuleVersion     = '3.0.0'
    GUID              = 'e40891cb-066b-45d8-b49d-1e51b74b6f67'
    Author            = 'AngelscriptProject'
    CompanyName       = 'AngelscriptProject'
    Copyright         = '(c) AngelscriptProject contributors'
    Description       = 'Workspace-safe Unreal Engine discovery and execution leaf for Harness.'
    PowerShellVersion = '7.0'
    CompatiblePSEditions = @('Core')
    FunctionsToExport = @(
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
    CmdletsToExport   = @()
    VariablesToExport = @()
    AliasesToExport   = @()
}
