#requires -Version 7.0
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Invoke-HarnessWorkflowCore {
    param([Parameter(Mandatory)]$Context, [string]$Group, [string]$Action, [hashtable]$Parameters)
    $roots = @{}
    foreach ($key in @('WorkspaceId','WorkspaceRoot','OpenSpecRoot','HarnessRoot','PrimaryRoot','Topology')) {
        $property = $Context.PSObject.Properties[$key]
        $roots[$key] = if ($null -ne $property -and $property.Value) { [string]$property.Value } else { [string]$Context.WorkspaceRoot }
    }
    $output = @((@{context=$roots;parameters=$Parameters} | ConvertTo-Json -Depth 60 -Compress) |
        & python -X utf8 (Join-Path $Context.HarnessRoot '.agents/skills/harness/scripts/workflow.py') $Group $Action)
    $code = $LASTEXITCODE
    $data = ($output -join "`n") | ConvertFrom-Json -Depth 60
    if ($code) { throw "Harness $Group.$Action failed: $($data.error)" }
    return $data
}

function Invoke-HarnessTalk {
    param([Parameter(Mandatory)]$Context, [ValidateSet('create','update','status')][string]$Action,
        [Parameter(Mandatory)][string]$Change, [string]$TalkId, [string]$SessionId,
        [string]$Kind, [string]$Theme, [string]$Summary, [string]$SourceRef, [string]$ResumeTask,
        [string]$Scope, [string]$Status, [string]$Disposition, [object[]]$Questions, [int]$ExpectedRevision,
        [string]$Purpose, [hashtable]$Arrangements, [string]$ReplacementTalkId, [string]$ResolutionSource)
    $values = @{}; foreach ($key in $PSBoundParameters.Keys) { if ($key -notin @('Context','Action')) { $values[$key] = $PSBoundParameters[$key] } }
    Invoke-HarnessWorkflowCore -Context $Context -Group talk -Action $Action -Parameters $values
}

function Invoke-HarnessReplan {
    param([Parameter(Mandatory)]$Context, [ValidateSet('apply','status')][string]$Action,
        [Parameter(Mandatory)][string]$Change, [string]$TalkId, [string]$SessionId, [string]$ReplanId,
        [int]$ExpectedRevision, [hashtable]$Candidates, [hashtable]$ExpectedHashes, [string]$ResumeTask,
        [switch]$PlanOnly, [hashtable]$Gate, [string]$HandoffText, [string]$DraftId, [string]$Scope, [hashtable]$GitPlan)
    $values = @{}; foreach ($key in $PSBoundParameters.Keys) { if ($key -notin @('Context','Action')) { $values[$key] = if ($PSBoundParameters[$key] -is [switch]) { [bool]$PSBoundParameters[$key] } else { $PSBoundParameters[$key] } } }
    if ($Action -eq 'apply') { $values.RequireGitPlan=$true }
    $result=Invoke-HarnessWorkflowCore -Context $Context -Group replan -Action $Action -Parameters $values
    if ($Action -eq 'apply' -and -not $PlanOnly -and $result.PSObject.Properties['planning_schema']) {
        Import-Module (Join-Path $Context.HarnessRoot '.agents/skills/harness/scripts/PlanningGit.psm1')
        $commit=Complete-HarnessReplanGit -Context $Context -Applied $result
        $result | Add-Member PlanningCommit $commit
        $result | Add-Member PlanningStage 'complete'
    }
    return $result
}

function Invoke-HarnessExecution {
    param([Parameter(Mandatory)]$Context, [ValidateSet('start','checkpoint','status','input')][string]$Action,
        [Parameter(Mandatory)][string]$SessionId, [string]$Change, [ValidateSet('Change','Queue')][string]$Scope,
        [string]$SourceRef, [string]$State, [string]$Reason, [string]$Phase, [string]$ResumeTask,
        [string[]]$AcknowledgeInputs, [int]$ExpectedRevision, [string]$PreviousSessionId, [switch]$PreviousSessionStopped, [string]$ProgressRef,
        [string]$InputId, [string]$Summary, [ValidateSet('feedback','pause')][string]$Kind)
    $values = @{}
    foreach ($key in $PSBoundParameters.Keys) {
        if ($key -in @('Context','Action')) { continue }
        if ($PSBoundParameters[$key] -is [switch]) { $values[$key] = [bool]$PSBoundParameters[$key] }
        else { $values[$key] = $PSBoundParameters[$key] }
    }
    Invoke-HarnessWorkflowCore -Context $Context -Group execution -Action $Action -Parameters $values
}

Export-ModuleMember -Function Invoke-HarnessTalk,Invoke-HarnessReplan,Invoke-HarnessExecution,Invoke-HarnessWorkflowCore
