@{
    RootModule        = 'GitOperations.psm1'
    ModuleVersion     = '2.0.0'
    GUID              = 'b798bdc8-ae3d-467e-bfa7-055421ed6e0c'
    Author            = 'AngelscriptProject'
    CompanyName       = 'AngelscriptProject'
    Copyright         = '(c) AngelscriptProject contributors'
    Description       = 'Exact-workspace multi-repository Git commits, reviewed local integration, and explicit non-force publication for Hardness.'
    PowerShellVersion = '7.0'
    CompatiblePSEditions = @('Core')
    FunctionsToExport = @(
        'Get-HardnessGitStatus',
        'Complete-HardnessGitCommit',
        'Merge-HardnessGitWorkspace',
        'Publish-HardnessGitBranches'
    )
    CmdletsToExport   = @()
    VariablesToExport = @()
    AliasesToExport   = @()
}
