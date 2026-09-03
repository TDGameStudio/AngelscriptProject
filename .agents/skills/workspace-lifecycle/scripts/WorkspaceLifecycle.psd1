@{
    RootModule        = 'WorkspaceLifecycle.psm1'
    ModuleVersion     = '2.0.0'
    GUID              = 'ba79e4fe-c71b-4fc1-a429-154e8fd860d7'
    Author            = 'AngelscriptProject'
    CompanyName       = 'AngelscriptProject'
    Copyright         = '(c) AngelscriptProject contributors'
    Description       = 'Safe project-local workspace lifecycle and local configuration for Hardness.'
    PowerShellVersion = '7.0'
    CompatiblePSEditions = @('Core')
    FunctionsToExport = @(
        'Get-HardnessWorkspaceContext',
        'Get-HardnessWorkspaceList',
        'Get-HardnessWorkspaceStatus',
        'Clear-HardnessWorkspaceCache',
        'New-HardnessWorkspace',
        'Initialize-HardnessWorkspace',
        'Test-HardnessWorkspace',
        'Remove-HardnessWorkspace',
        'Get-HardnessWorkspaceConfigStatus',
        'Get-HardnessWorkspaceConfigValue',
        'Set-HardnessWorkspaceConfigValue',
        'Set-HardnessWorkspaceSession',
        'Assert-HardnessWorkspaceExecution'
    )
    CmdletsToExport   = @()
    VariablesToExport = @()
    AliasesToExport   = @()
}
