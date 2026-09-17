#requires -Version 7.0
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Invoke-HarnessChangeQueue {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]$Context,
        [Parameter(Mandatory)][ValidateSet('status','set','remove','reorder','claim','release','pause','takeover','advance','checkpoint')][string]$Action,
        [string]$TargetWorkspaceRoot = '', [string[]]$Changes = @(), [string]$Change = '',
        [int]$ExpectedRevision = -1, [string]$SessionId = '', [string]$Token = '',
        [string]$Reason = '', [switch]$PreviousControllerStopped, [object[]]$Repositories = @()
    )
    Import-Module (Join-Path $Context.HarnessRoot '.agents/skills/workspace-lifecycle/scripts/WorkspaceLifecycle.psd1')
    $selected = Get-HarnessWorkspaceContext -WorkspaceRoot $Context.WorkspaceRoot
    if ($TargetWorkspaceRoot) {
        if ($selected.WorkspaceRoot -ne $selected.PrimaryRoot -or $Action -notin @('status','set','remove','reorder','pause')) { throw 'Only the control center can target another queue for status or management.' }
        $target = Get-HarnessWorkspaceContext -WorkspaceRoot $TargetWorkspaceRoot
        if ($target.PrimaryRoot -ne $selected.PrimaryRoot) { throw 'Target belongs to another control center.' }
        $selected = $target
    }
    if ($selected.Topology -notin @('Primary','Replica')) { throw 'Existing linked worktrees are parked and are not attached to queues.' }
    if ($Action -eq 'takeover') {
        if (-not $PreviousControllerStopped) { throw 'Explicit takeover requires confirming the previous controller has stopped.' }
        $processes = Invoke-Harness -Command ue.process.list -Context $selected
        if ($processes.status -ne 'Succeeded') { throw 'Cannot inspect managed Unreal activity before takeover.' }
        if (@($processes.data | Where-Object { $_.WorkspaceMatch -or [string]::IsNullOrWhiteSpace($_.CommandLine) }).Count) { throw 'Active or unidentified Unreal processes require inspection before takeover.' }
    }
    $parameters = @{Changes=$Changes; Change=$Change; ExpectedRevision=$ExpectedRevision; SessionId=$SessionId; Token=$Token; Reason=$Reason; PreviousControllerStopped=[bool]$PreviousControllerStopped}
    if ($PSBoundParameters.ContainsKey('Repositories')) { $parameters.Repositories = $Repositories }
    $payload = @{context=$selected; parameters=$parameters} | ConvertTo-Json -Depth 40 -Compress
    $output = @($payload | & python -X utf8 (Join-Path $PSScriptRoot 'change_queue.py') $Action 2>&1)
    if ($LASTEXITCODE) { throw "Change queue failed: $($output -join "`n")" }
    $data = ($output -join "`n") | ConvertFrom-Json
    $progress = $null; $planState = 'none'; $ready = $null; $issues = @()
    if ($data.recoveryPending) { $planState = 'recovery-needed' }
    elseif ($data.currentChange -and $data.recordState -ne 'active') {
        $planState = $data.recordState; $issues = @($data.recordIssues)
    }
    elseif ($data.currentChange) {
        $tasks = Join-Path $selected.OpenSpecRoot "openspec/changes/$($data.currentChange)/tasks.md"
        if (-not (Test-Path -LiteralPath $tasks)) { $planState = 'plan-needed' }
        else {
            $plan = Invoke-Harness -Command task.status -Context $selected -Parameters @{Change=$data.currentChange}
            if ($plan.status -eq 'Succeeded') {
                $progress = $plan.data.progress; $ready = @($plan.data.tasks | Where-Object ready).Count
                $planState = $plan.data.state
                $issues = if ('taskIssues' -in $plan.data.PSObject.Properties.Name) { @($plan.data.taskIssues) } else { @() }
            } else { $planState = 'invalid-plan'; $issues = @($plan.error.message) }
        }
    }
    $discussions = $null
    if ($data.currentChange -and $data.recordState -eq 'active') {
        Import-Module (Join-Path $Context.HarnessRoot '.agents/skills/harness/scripts/Workflow.psm1')
        $discussions = Invoke-HarnessReplan -Context $selected -Action status -Change $data.currentChange
    }
    $data | Add-Member -NotePropertyMembers @{planState=$planState; progress=$progress; ready=$ready; taskIssues=$issues; activity='unknown'; workflow=$discussions} -Force
    return $data
}
Export-ModuleMember -Function Invoke-HarnessChangeQueue
