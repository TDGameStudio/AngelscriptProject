@{
    RootModule        = 'UnrealEngineDevelop.psm1'
    ModuleVersion     = '1.0.0'
    GUID              = 'e40891cb-066b-45d8-b49d-1e51b74b6f67'
    Author            = 'AngelscriptProject'
    CompanyName       = 'AngelscriptProject'
    Copyright         = '(c) AngelscriptProject contributors'
    Description       = 'Workspace-safe Unreal Engine discovery and execution leaf for Hardness.'
    PowerShellVersion = '7.0'
    CompatiblePSEditions = @('Core')
    FunctionsToExport = @(
        'Get-HardnessUnrealStatus'
        'Get-HardnessUnrealEngineList'
        'Get-HardnessUnrealTargetList'
        'Get-HardnessUnrealProcessList'
        'Get-HardnessUnrealUbtCapabilities'
        'Invoke-HardnessUnrealUbt'
        'Invoke-HardnessUnrealBuild'
        'Invoke-HardnessUnrealTest'
        'Get-HardnessUnrealSuiteList'
        'New-HardnessUnrealSuitePlan'
        'Invoke-HardnessUnrealSuite'
        'Invoke-HardnessUnrealCommandlet'
        'Get-HardnessUnrealRunStatus'
        'Stop-HardnessUnrealRun'
    )
    CmdletsToExport   = @()
    VariablesToExport = @()
    AliasesToExport   = @()
}
