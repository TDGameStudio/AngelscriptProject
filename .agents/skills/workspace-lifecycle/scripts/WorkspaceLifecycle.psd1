@{
    RootModule        = 'WorkspaceLifecycle.psm1'
    ModuleVersion     = '3.0.0'
    GUID              = 'ba79e4fe-c71b-4fc1-a429-154e8fd860d7'
    Author            = 'AngelscriptProject'
    CompanyName       = 'AngelscriptProject'
    Copyright         = '(c) AngelscriptProject contributors'
    Description       = 'Safe project-local workspace lifecycle and local configuration for Harness.'
    PowerShellVersion = '7.0'
    CompatiblePSEditions = @('Core')
    FunctionsToExport = @(
        'Get-HarnessWorkspaceContext',
        'Get-HarnessWorkspaceList',
        'Get-HarnessWorkspaceStatus',
        'Clear-HarnessWorkspaceCache',
        'New-HarnessWorkspace',
        'Initialize-HarnessWorkspacePlugins',
        'Initialize-HarnessWorkspace',
        'Test-HarnessWorkspace',
        'Remove-HarnessWorkspace',
        'Get-HarnessWorkspaceConfigStatus',
        'Get-HarnessWorkspaceConfigValue',
        'Get-HarnessWorkspaceConfigValues',
        'Set-HarnessWorkspaceConfigValue',
        'Set-HarnessWorkspaceSession',
        'Assert-HarnessWorkspaceExecution'
    )
    CmdletsToExport   = @()
    VariablesToExport = @()
    AliasesToExport   = @()
}
