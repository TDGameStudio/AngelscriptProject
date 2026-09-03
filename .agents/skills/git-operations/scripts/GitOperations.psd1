@{
    RootModule        = 'GitOperations.psm1'
    ModuleVersion     = '1.0.0'
    GUID              = 'b798bdc8-ae3d-467e-bfa7-055421ed6e0c'
    Author            = 'AngelscriptProject'
    CompanyName       = 'AngelscriptProject'
    Copyright         = '(c) AngelscriptProject contributors'
    Description       = 'Scoped multi-repository Git commits and explicit local integration for Hardness.'
    PowerShellVersion = '7.0'
    CompatiblePSEditions = @('Core')
    FunctionsToExport = @(
        'Get-HardnessGitStatus',
        'Complete-HardnessGitCommit',
        'Merge-HardnessGitGoal',
        'Publish-HardnessGitBranches'
    )
    CmdletsToExport   = @()
    VariablesToExport = @()
    AliasesToExport   = @()
}
