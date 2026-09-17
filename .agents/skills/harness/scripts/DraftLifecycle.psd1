@{
    RootModule = 'DraftLifecycle.psm1'
    ModuleVersion = '1.0.0'
    GUID = '78862138-1385-4077-8aca-d62096500ed4'
    Author = 'AngelscriptProject'
    PowerShellVersion = '7.0'
    CompatiblePSEditions = @('Core')
    FunctionsToExport = @(
        'New-HarnessDraft',
        'Get-HarnessDraftStatus',
        'Test-HarnessDraft',
        'Close-HarnessDraft',
        'Invoke-HarnessDraftRecord'
    )
    CmdletsToExport = @()
    VariablesToExport = @()
    AliasesToExport = @()
}
