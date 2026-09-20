# Fixture-only constructor for records admitted by the pre-complete-plan contract.
# This exercises the retained creation/recovery engine, never a public new-Change
# bypass. New public Create semantics are covered in HarnessChangeGate.Tests.ps1.
function Invoke-HistoricalFixtureCreate {
    param($Context, [hashtable]$Parameters)
    Import-Module (Join-Path $Context.HarnessRoot '.agents/skills/harness/scripts/ChangeGate.psd1')
    $module=Get-Module -All ChangeGate | Where-Object { $_.Path -eq (Join-Path $Context.HarnessRoot '.agents/skills/harness/scripts/ChangeGate.psm1') } | Select-Object -First 1
    try {
        $data=& $module { param($FixtureContext,$Values) Invoke-HarnessChangeCreateCore -Context $FixtureContext @Values } $Context $Parameters
        return [pscustomobject]@{status='Succeeded';data=$data;error=$null}
    } catch {
        return [pscustomobject]@{status='Failed';data=$null;error=[pscustomobject]@{message=$_.Exception.Message}}
    }
}
