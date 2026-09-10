#requires -Version 7.0
[CmdletBinding()]
param()
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSScriptRoot '../scripts/Harness.psd1') -Force
$module = Get-Module Harness

$emptyInvalid = '{"changeId":"fixture/old","state":"waiting","progress":{"total":0,"complete":0,"remaining":0},"taskIssues":[{"code":"unsupported-task-format","message":"Rewrite old metadata","line":8}]}'
$plan = & $module { param($Json) ConvertFrom-HarnessTaskPlanOutput -Output @($Json) } $emptyInvalid
if ($plan.tasks.Count -ne 0 -or $plan.state -ne 'waiting' -or $plan.taskIssues[0].code -cne 'unsupported-task-format' -or $plan.taskIssues[0].line -ne 8) {
    throw 'Empty invalid TaskPlan lost its original migration diagnostic or became schedulable.'
}

foreach ($invalid in @(
    '{"changeId":"fixture/bad","state":"ready"}',
    '{"changeId":"fixture/bad","state":"waiting","progress":{"total":1},"taskIssues":[{"code":"bad"}]}',
    '{"changeId":"fixture/bad","state":"waiting","progress":{"total":0},"taskIssues":[]}'
)) {
    $rejected = $false
    try { & $module { param($Json) ConvertFrom-HarnessTaskPlanOutput -Output @($Json) } $invalid | Out-Null }
    catch { $rejected = $_.Exception.Message -like "*missing 'tasks'*" }
    if (-not $rejected) { throw 'Malformed native output was silently converted to an empty plan.' }
}
Write-Output 'TaskOutput.Tests.ps1: PASS'
