Set-StrictMode -Version Latest
function Invoke-HarnessSharedSpec {
    [CmdletBinding()]
    param([Parameter(Mandatory)]$Context, [ValidateSet('read','write')][string]$Action,
          [Parameter(Mandatory)][string]$Spec, [string]$ExpectedSha256 = '', [AllowEmptyString()][string]$Content = '')
    Import-Module (Join-Path $Context.HarnessRoot '.agents/skills/workspace-lifecycle/scripts/WorkspaceLifecycle.psd1')
    $selected = Get-HarnessWorkspaceContext -WorkspaceRoot $Context.WorkspaceRoot
    $request = @{root=$selected.OpenSpecRoot; action=$Action; spec=$Spec; expected=$ExpectedSha256; content=$Content} | ConvertTo-Json -Compress
    $output = @($request | & python -X utf8 (Join-Path $PSScriptRoot 'shared_specs.py') 2>&1)
    if ($LASTEXITCODE) { throw "Shared spec operation failed: $($output -join "`n")" }
    return ($output -join "`n") | ConvertFrom-Json
}
Export-ModuleMember -Function Invoke-HarnessSharedSpec
