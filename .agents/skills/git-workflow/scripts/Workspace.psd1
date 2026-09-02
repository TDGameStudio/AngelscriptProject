@{
    RootModule        = 'Workspace.psm1'
    ModuleVersion     = '1.0.0'
    GUID              = 'ba79e4fe-c71b-4fc1-a429-154e8fd860d7'
    Author            = 'AngelscriptProject'
    CompanyName       = 'AngelscriptProject'
    Copyright         = '(c) AngelscriptProject contributors'
    Description       = 'Safe project-local Git worktree operations for Hardness.'
    PowerShellVersion = '7.0'
    CompatiblePSEditions = @('Core')
    FunctionsToExport = @(
        'Get-HardnessWorkspaceStatus',
        'New-HardnessWorkspace',
        'Initialize-HardnessWorkspace',
        'Test-HardnessWorkspace',
        'Complete-HardnessWorkspace',
        'Remove-HardnessWorkspace'
    )
    CmdletsToExport   = @()
    VariablesToExport = @()
    AliasesToExport   = @()
}
