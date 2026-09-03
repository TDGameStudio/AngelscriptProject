@{
    RootModule        = 'Harness.psm1'
    ModuleVersion     = '3.0.0'
    GUID              = '7be2b94d-ccea-41c4-97ef-b5f39425847a'
    Author            = 'AngelscriptProject'
    CompanyName       = 'AngelscriptProject'
    Copyright         = '(c) AngelscriptProject contributors'
    Description       = 'Lightweight, workspace-derived route dispatcher for AngelscriptProject skills.'
    PowerShellVersion = '7.0'
    CompatiblePSEditions = @('Core')
    FunctionsToExport = @(
        'New-HarnessContext',
        'Get-HarnessCommand',
        'Invoke-Harness',
        'Test-HarnessInstallation'
    )
    CmdletsToExport   = @()
    VariablesToExport = @()
    AliasesToExport   = @()
}
