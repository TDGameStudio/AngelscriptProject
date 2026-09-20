#requires -Version 7.0
$ErrorActionPreference = 'Stop'
$projectRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../../../..'))
Import-Module (Join-Path $projectRoot '.agents/skills/harness/scripts/Harness.psd1') -Force
foreach ($suite in @('test_discussions.py','test_replans.py','test_execution.py')) {
    & python -X utf8 -m unittest discover -s $PSScriptRoot -p $suite
    if ($LASTEXITCODE) { throw "$suite failed" }
}
$fixture = Join-Path ([IO.Path]::GetTempPath()) ('harness-workflow-' + [guid]::NewGuid().ToString('N'))
$unrealModule = Import-Module (Join-Path $projectRoot '.agents/skills/unreal-engine-develop/scripts/UnrealEngineDevelop.psd1') -PassThru
$processReader = & $unrealModule { (Get-Command Get-HarnessUnrealProcessList).ScriptBlock }
# Bound the external process inventory to an idle fixture; all Harness adapters,
# native planning and closure eligibility remain real.
& $unrealModule { function script:Get-HarnessUnrealProcessList { param($WorkspaceRoot) return ,@() } }
. (Join-Path $PSScriptRoot 'HistoricalChangeFixture.ps1')
function W($path, $body) { [void][IO.Directory]::CreateDirectory([IO.Path]::GetDirectoryName($path)); [IO.File]::WriteAllText($path, $body) }
function Check($value, $message) { if (-not $value) { throw $message }; "PASS $message" }
function Invoke-WorkflowFixture($command, $parameters=@{}, $arguments=@()) {
    $r = if ($command -eq 'harness.change.create') { Invoke-HistoricalFixtureCreate -Context $context -Parameters $parameters } else { Invoke-Harness -Context $context -Command $command -Parameters $parameters -ArgumentList $arguments }
    if ($r.status -ne 'Succeeded') { throw "$command : $($r.error.message)" }
    return $r.data
}
function New-ApprovedWorkflowFixture($changeId, $session='fixture-session') {
    $p=@{ChangeId=$changeId;Title=$changeId;Goal='Exercise workflow';Origin='Direct';Reason='Isolated fixture';SessionId=$session;HandoffText="Create the exact workflow fixture $changeId and keep implementation waiting."}
    $preview=Invoke-WorkflowFixture harness.change.create ($p+@{PlanOnly=$true})
    $created=Invoke-WorkflowFixture harness.change.create ($p+@{Gate=@{ConvergenceSource='fixture:ready';DecisionSource='fixture:create';Decision='create';TargetChange=$changeId;HandoffRevision=$preview.HandoffRevision}})
    Complete-WorkflowArrangement $changeId $created.Followup $session later 'fixture:wait'
}
function Complete-WorkflowArrangement($changeId, $talkId, $session, $decision, $source) {
    $view=Invoke-WorkflowFixture harness.talk.status @{Change=$changeId;TalkId=$talkId}
    $talk=$view.records[0]
    $questions=@(@{id='draft-disposition';question='Draft disposition';answer='not-applicable';source='not-applicable:no-draft'},@{id='execution-disposition';question='Execution arrangement';answer=$decision;source=$source})
    $settled=Invoke-WorkflowFixture harness.talk.update @{Change=$changeId;TalkId=$talkId;SessionId=$session;ExpectedRevision=$talk.revision;Status='settled';Questions=$questions}
    if ($decision -eq 'now') {
        $staged=Invoke-WorkflowFixture harness.execution.start @{Change=$changeId;SessionId=$session;Scope='Change';SourceRef=$source}
        $binding=Get-Content -LiteralPath (Join-Path $fixture "Saved/Harness/Execution/$session.json") -Raw | ConvertFrom-Json
        Check ($binding.authorizedHandoffId -eq $talk.handoff_id) "staged execution matches the current handoff (actual=$($binding.authorizedHandoffId), expected=$($talk.handoff_id))"
    }
    Invoke-WorkflowFixture harness.talk.update @{Change=$changeId;TalkId=$talkId;SessionId=$session;ExpectedRevision=$settled.revision;Status='closed';Disposition='no-change';Arrangements=@{draft=@{status='applied';decision='not-applicable';source='not-applicable:no-draft'};execution=@{status='applied';decision=$decision;source=$source}}} | Out-Null
}
function Move-WorkflowArchiveFixture($changeId) {
    $from=[IO.Path]::GetFullPath((Join-Path $fixture "openspec/changes/$changeId"))
    $parts=$changeId.Split('/')
    $to=[IO.Path]::GetFullPath((Join-Path $fixture "openspec/archive/changes/$($parts[0])/20260917-$($parts[1])"))
    $allowed=[IO.Path]::GetFullPath($fixture)+[IO.Path]::DirectorySeparatorChar
    if (-not $from.StartsWith($allowed) -or -not $to.StartsWith($allowed)) { throw 'Archive fixture left its temporary root' }
    [void][IO.Directory]::CreateDirectory([IO.Path]::GetDirectoryName($to))
    Move-Item -LiteralPath $from -Destination $to
    Add-Content -LiteralPath (Join-Path $to 'change.yaml') -Value "`narchive_schema: closure-v1`narchived_at: 2026-09-17T12:00:00Z`nclosure:`n  kind: completed"
    $tasks=Join-Path $to 'tasks.md'
    if(Test-Path -LiteralPath $tasks) { W $tasks ((Get-Content -LiteralPath $tasks -Raw).Replace('## [ ]','## [x]')) }
}
try {
    [void][IO.Directory]::CreateDirectory($fixture)
    & git -C $fixture init -q
    & git -C $fixture config user.name Fixture
    & git -C $fixture config user.email fixture@example.invalid
    W (Join-Path $fixture '.gitignore') "Saved/`n"
    & git -C $fixture add .gitignore
    & git -C $fixture commit -qm baseline
    W (Join-Path $fixture 'Fixture.uproject') '{"FileVersion":3,"Modules":[],"Plugins":[]}'
    foreach ($relative in @('.agents/skills/harness/scripts','.agents/skills/workspace-lifecycle/scripts','.agents/skills/git-operations/scripts','.agents/skills/openspec/bin')) {
        $destination=Join-Path $fixture $relative
        [void][IO.Directory]::CreateDirectory([IO.Path]::GetDirectoryName($destination))
        Copy-Item -LiteralPath (Join-Path $projectRoot $relative) -Destination $destination -Recurse
    }
    $context = New-HarnessContext -WorkspaceRoot $fixture
    Invoke-WorkflowFixture openspec.init @{} @('--project-id','fixture','--title','Fixture') | Out-Null
    Invoke-WorkflowFixture openspec.domain @{} @('create','harness','--title','Harness') | Out-Null
    $id='harness/test-feedback-loop'
    New-ApprovedWorkflowFixture $id
    $changeRoot=Join-Path $fixture "openspec/changes/$id"
    W (Join-Path $changeRoot 'proposal.md') "# Proposal`n`n## Why`n`nExercise the feedback loop.`n`n## What Changes`n`nPreserve accepted behavior A.`n"
    W (Join-Path $changeRoot 'design.md') "# Design`n`n## Call chains`n`nnone — documentation fixture.`n"
    W (Join-Path $changeRoot 'tasks.md') @'
---
task_graph:
  version: 1
  depends_on:
    "1.1": []
---
## [ ] 1.1 Implement behavior

**Files**
```diff
+ fixture.txt
```

**Verification**
```sh
python -c "assert True"
```
'@
    Invoke-WorkflowFixture harness.execution.start @{Change=$id;SessionId='fixture-session';Scope='Change';SourceRef='user:execute'} | Out-Null
    Import-Module (Join-Path $projectRoot '.agents/skills/harness/scripts/Workflow.psm1')
    Invoke-WorkflowFixture harness.execution.input @{SessionId='fixture-session';InputId='early-feedback';SourceRef='user:feedback';Summary='Consider behavior A';Kind='feedback'} | Out-Null
    $beforeTalk=Invoke-WorkflowFixture task.status @{Change=$id}
    Check ($beforeTalk.executionAllowed -eq $false) 'pending input blocks task eligibility before a talk file exists'
    $beforeClosure=Invoke-WorkflowFixture harness.evolution.status @{Change=$id}
    Check ('User input awaits triage' -in $beforeClosure.ClosureBlockers) 'terminal evaluation sees pending input before a talk file exists'
    $pausedQueue=Invoke-WorkflowFixture harness.queue.pause @{Reason='User pauses before controller recovery'}
    Invoke-WorkflowFixture harness.queue.release @{Token=$pausedQueue.controller.token} | Out-Null
    Invoke-WorkflowFixture harness.queue.claim @{SessionId='fixture-session'} | Out-Null
    $pausedRun=Invoke-WorkflowFixture harness.execution.status @{SessionId='fixture-session'}
    Check ($pausedRun.state -eq 'paused' -and -not $pausedRun.implementationAllowed) 'source-free public reclaim preserves the user pause'
    $resume=Invoke-WorkflowFixture harness.execution.checkpoint @{SessionId='fixture-session';ExpectedRevision=$pausedRun.revision;SourceRef='user:resume-after-pause'}
    Check ($resume.state -eq 'running' -and $resume.pendingInputs.Count -eq 1) 'one explicit resume clears only the pause and preserves feedback'
    Invoke-WorkflowFixture ue.process.list | Out-Null
    Invoke-WorkflowFixture harness.queue.takeover @{SessionId='recovery-session';PreviousControllerStopped=$true} | Out-Null
    $transferParams=@{SessionId='recovery-session';Scope='Queue';SourceRef='user:takeover';PreviousSessionId='fixture-session';PreviousSessionStopped=$true}
    $transferred=Invoke-WorkflowFixture harness.execution.start $transferParams
    Check ($transferred.pendingInputs.Count -eq 1 -and $transferred.pendingInputs[0].id -eq 'early-feedback' -and -not $transferred.implementationAllowed) 'public takeover retains the exact untriaged input and execution barrier'
    $retry=Invoke-WorkflowFixture harness.execution.start $transferParams
    Check ($retry.revision -eq $transferred.revision) 'public transfer retry does not duplicate or consume obligations'
    Check (-not (Invoke-WorkflowFixture task.status @{Change=$id}).executionAllowed) 'transferred input remains visible to task eligibility'
    Check ('User input awaits triage' -in (Invoke-WorkflowFixture harness.evolution.status @{Change=$id}).ClosureBlockers) 'transferred input remains visible to terminal evaluation'
    Invoke-WorkflowFixture harness.queue.takeover @{SessionId='fixture-session';PreviousControllerStopped=$true} | Out-Null
    Invoke-WorkflowFixture harness.execution.start @{SessionId='fixture-session';Scope='Queue';SourceRef='user:takeover-back';PreviousSessionId='recovery-session';PreviousSessionStopped=$true} | Out-Null
    $pendingRun=Invoke-WorkflowFixture harness.execution.status @{SessionId='fixture-session'}
    Invoke-WorkflowFixture harness.execution.checkpoint @{SessionId='fixture-session';ExpectedRevision=$pendingRun.revision;AcknowledgeInputs=@('early-feedback')} | Out-Null
    $record=Invoke-WorkflowFixture harness.talk.create @{Change=$id;SessionId='fixture-session';Kind='grill';Theme='behavior';Summary='Choose behavior';SourceRef='message:1';ResumeTask='1.1';Questions=@(@{id='Q1';question='Which behavior?';answer=$null;source=$null})}
    $plan=Invoke-WorkflowFixture task.status @{Change=$id}
    Check ($plan.tasks[0].ready -and -not $plan.executionAllowed) 'native graph readiness stays true while Harness prevents implementation'
    $started=Invoke-WorkflowFixture harness.execution.start @{Change=$id;SessionId='fixture-session';Scope='Change';SourceRef='user:execute'}
    Check ($started.state -eq 'waiting-input') 'public execution waits for the pending answer'
    $wrongAction=Invoke-Harness harness.talk.status -Context $context -Parameters @{Change=$id;Action='create'}
    Check ($wrongAction.status -eq 'Failed') 'a status route cannot be redirected into a mutation'
    $earlyArchive=Invoke-Harness openspec.change -Context $context -ArgumentList @('archive',$id,'--closure-file','missing.json')
    Check ($earlyArchive.status -eq 'Failed' -and $earlyArchive.error.message -match 'Pending discussion') 'archive is rejected before native mutation while a discussion is pending'
    $settled=Invoke-WorkflowFixture harness.talk.update @{Change=$id;TalkId=$record.talk_id;SessionId='fixture-session';ExpectedRevision=$record.revision;Status='settled';Questions=@(@{id='Q1';question='Which behavior?';answer='A';source='message:2'})}
    $hashes=@{}; foreach($name in @('design.md','tasks.md')) { $hashes[$name]=(Get-FileHash (Join-Path $changeRoot $name) -Algorithm SHA256).Hash.ToLowerInvariant() }
    $beforeTasks=Get-Content -LiteralPath (Join-Path $changeRoot 'tasks.md') -Raw
    $afterTasks=$beforeTasks.Replace('"1.1": []', '"1.1": []' + "`n    " + '"1.2": ["1.1"]') + "`n" + ($beforeTasks.Substring($beforeTasks.IndexOf('## [ ]')).Replace('1.1 Implement behavior','1.2 Verify integration').Replace('+ fixture.txt','+ integration.txt'))
    $replanParameters=@{Change=$id;TalkId=$record.talk_id;SessionId='fixture-session';ExpectedRevision=$settled.revision;ReplanId='replan-20260917-120000-behavior';ResumeTask='1.1';ExpectedHashes=$hashes;Candidates=@{'design.md'="# Design`n`n## Call chains`n`nnone — accepted behavior A.`n";'tasks.md'=$afterTasks};HandoffText='Preserve behavior A and add the dependent integration proof task.'}
    W (Join-Path $fixture 'implementation.cpp') 'unfinished implementation remains live'
    W (Join-Path $fixture 'outside.txt') 'outside staged work'
    & git -C $fixture add outside.txt
    $outsideBefore=& git -C $fixture rev-parse ':outside.txt'
    $replanParameters.GitPlan=@{CommitMessage='fixture accepted Replan';RepositoryScopes=@{'.'=@('openspec/changes/'+$id)}}
    $replanPreview=Invoke-WorkflowFixture harness.replan.apply ($replanParameters+@{PlanOnly=$true})
    $acceptReplan=@{ConvergenceSource='message:ready';DecisionSource='message:apply';Decision='replan';TargetChange=$id;HandoffRevision=$replanPreview.HandoffRevision}
    $missingGit=$replanParameters.Clone(); [void]$missingGit.Remove('GitPlan')
    Check ((Invoke-Harness harness.replan.apply -Context $context -Parameters ($missingGit+@{PlanOnly=$true})).status -eq 'Failed') 'new public Replan cannot bypass its Git intent'
    $changedGit=$replanParameters.Clone(); $changedGit.GitPlan=@{CommitMessage='unshown different commit intent';RepositoryScopes=@{'.'=@('openspec/changes/'+$id)}}
    Check ((Invoke-Harness harness.replan.apply -Context $context -Parameters ($changedGit+@{Gate=$acceptReplan})).status -eq 'Failed') 'changed Git intent cannot reuse the displayed Replan Gate'
    W (Join-Path $fixture '.git/hooks/pre-commit') "#!/bin/sh`nexit 1`n"
    $commitFailed=Invoke-Harness harness.replan.apply -Context $context -Parameters ($replanParameters+@{Gate=$acceptReplan})
    Check ($commitFailed.status -eq 'Failed' -and $commitFailed.error.message -match 'pre-commit') 'normal hook failure retains the applied Replan as commit-pending'
    $pendingReplan=Invoke-WorkflowFixture harness.replan.status @{Change=$id}
    Check ($pendingReplan.recoveryNeeded -and -not $pendingReplan.executionAllowed) 'pending Replan Git independently blocks continuation'
    $appliedBefore=(Get-FileHash (Join-Path $changeRoot ('attachments/replans/'+$replanParameters.ReplanId+'.md'))).Hash
    [IO.File]::Delete((Join-Path $fixture '.git/hooks/pre-commit'))
    $applied=Invoke-WorkflowFixture harness.replan.apply ($replanParameters+@{Gate=@{ConvergenceSource='message:ready';DecisionSource='message:apply';Decision='replan';TargetChange=$id;HandoffRevision=$replanPreview.HandoffRevision}})
    Check ($appliedBefore -eq (Get-FileHash (Join-Path $changeRoot ('attachments/replans/'+$replanParameters.ReplanId+'.md'))).Hash) 'commit recovery preserves the immutable applied record'
    $repeated=Invoke-WorkflowFixture harness.replan.apply ($replanParameters+@{Gate=$acceptReplan})
    Check ($repeated.PlanningCommit -eq $applied.PlanningCommit) 'exact retry does not create a duplicate Replan commit'
    $replacedGate=$acceptReplan.Clone(); $replacedGate.DecisionSource='fixture:invented-replacement'
    Check ((Invoke-Harness harness.replan.apply -Context $context -Parameters ($replanParameters+@{Gate=$replacedGate})).status -eq 'Failed') 'retry cannot replace the already consumed actual decision'
    $committedPlan=@(& git -C $fixture show ('HEAD:openspec/changes/'+$id+'/tasks.md') 2>$null)
    Check ($LASTEXITCODE -eq 0 -and ($committedPlan -join "`n").Contains('1.2 Verify integration')) 'accepted Replan planning is committed before its arrangement'
    & git -C $fixture cat-file -e 'HEAD:implementation.cpp' 2>$null
    Check ($LASTEXITCODE -ne 0 -and (Get-Content (Join-Path $fixture 'implementation.cpp') -Raw) -eq 'unfinished implementation remains live') 'Replan does not checkpoint old implementation'
    Check ((& git -C $fixture rev-parse ':outside.txt') -eq $outsideBefore) 'Replan preserves outside staged content'
    Check ($applied.status -eq 'applied') 'real portable CLI validates staged and applied planning artifacts'
    Check ('1.2' -in $applied.task_changes.added -and '1.1 -> 1.2' -in $applied.edge_changes.added) 'applied record captures the actual task and dependency additions'
    $waiting=Invoke-WorkflowFixture harness.execution.status @{SessionId='fixture-session'}
    Check (-not $waiting.implementationAllowed) 'applied Replan waits for its actual post-handoff arrangement'
    Complete-WorkflowArrangement $id $applied.handoff.post_talk_id 'fixture-session' now 'user:continue-replan'
    $resumed=Invoke-WorkflowFixture harness.execution.status @{SessionId='fixture-session'}
    Check ($resumed.state -eq 'running' -and $resumed.implementationAllowed) 'confirmed post-Replan execution arrangement returns to the Ready task'
    $source=Join-Path $fixture 'source.jsonl'
    W $source ((@{type='session_meta';payload=@{id='fixture-session';cwd=$fixture;cli_version='0.154.0'}} | ConvertTo-Json -Compress)+"`n"+(@{type='response_item';payload=@{type='message';role='assistant';phase='commentary';content=@(@{type='output_text';text='Original visible explanation'})}} | ConvertTo-Json -Depth 8 -Compress)+"`n")
    $recording=Invoke-WorkflowFixture harness.conversation.record @{Action='bind';SessionId='fixture-session';Change=$id;TalkId=$record.talk_id;Source=$source;StartLine=2}
    Check ($recording.status -eq 'covered') 'public conversation recorder targets the exact Change talk'
    Invoke-WorkflowFixture harness.conversation.record @{Action='unbind';SessionId='fixture-session'} | Out-Null
    $talkPath=Join-Path $changeRoot "attachments/talks/$($record.talk_id).md"
    Check ((Get-Content $talkPath -Raw).Contains('Original visible explanation')) 'conversation original is retained beside current discussion state'
    Check ((Invoke-WorkflowFixture harness.execution.status @{SessionId='fixture-session'}).state -ne 'complete') 'agent-owned continuation remains until the exact archive, without a Codex Stop hook'
    Move-WorkflowArchiveFixture $id
    $singleQueue=Invoke-WorkflowFixture harness.queue.status
    Invoke-WorkflowFixture harness.queue.advance @{Token=$singleQueue.controller.token} | Out-Null
    Check ((Invoke-WorkflowFixture harness.execution.status @{SessionId='fixture-session'}).state -eq 'complete') 'standalone completion derives from the exact completed archive'
    $queueIds=@('harness/test-loop-first','harness/test-loop-second')
    foreach($queueId in $queueIds) { New-ApprovedWorkflowFixture $queueId 'queue-session' }
    $emptyQueue=Invoke-WorkflowFixture harness.queue.status
    Invoke-WorkflowFixture harness.queue.set @{Changes=$queueIds;ExpectedRevision=$emptyQueue.revision} | Out-Null
    $queueRun=Invoke-WorkflowFixture harness.execution.start @{SessionId='queue-session';Scope='Queue';SourceRef='user:drain'}
    Check ($queueRun.state -eq 'running' -and $queueRun.change -eq $queueIds[0]) 'queue execution binds the selected workspace and first member'
    Move-WorkflowArchiveFixture $queueIds[0]
    Remove-Item -LiteralPath (Join-Path $fixture 'Saved/Harness/Execution/queue-session.json')
    Invoke-WorkflowFixture harness.execution.start @{SessionId='queue-session';Scope='Queue';SourceRef='user:resume'} | Out-Null
    Check ((Invoke-WorkflowFixture harness.execution.status @{SessionId='queue-session'}).phase -eq 'advancing') 'first Change archive returns to queue advance rather than completing execution'
    $queue=Invoke-WorkflowFixture harness.queue.status
    Invoke-WorkflowFixture harness.queue.advance @{Token=$queue.controller.token} | Out-Null
    $second=Invoke-WorkflowFixture harness.execution.status @{SessionId='queue-session'}
    Check ($second.state -eq 'running' -and $second.change -eq $queueIds[1]) 'queue automatically exposes the next member in the same execution binding'
    Move-WorkflowArchiveFixture $queueIds[1]
    $queue=Invoke-WorkflowFixture harness.queue.status
    Invoke-WorkflowFixture harness.queue.advance @{Token=$queue.controller.token} | Out-Null
    Check ((Invoke-WorkflowFixture harness.execution.status @{SessionId='queue-session'}).state -eq 'complete') 'only exhausted authorized queue work completes the execution'
    'Harness workflow integration passed.'
} finally {
    & $unrealModule { param($Original) Set-Item Function:script:Get-HarnessUnrealProcessList $Original } $processReader
    $resolved=[IO.Path]::GetFullPath($fixture)
    $prefix=[IO.Path]::GetFullPath([IO.Path]::GetTempPath()).TrimEnd('\','/')+[IO.Path]::DirectorySeparatorChar+'harness-workflow-'
    if (-not $resolved.StartsWith($prefix,[StringComparison]::OrdinalIgnoreCase)) { throw 'Unsafe fixture cleanup' }
    Remove-Item -LiteralPath $resolved -Recurse -Force
}
