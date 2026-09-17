#requires -Version 7.0
$ErrorActionPreference = 'Stop'
$projectRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../../../..'))
Import-Module (Join-Path $projectRoot '.agents/skills/harness/scripts/Harness.psd1') -Force
foreach ($suite in @('test_discussions.py','test_replans.py','test_execution.py')) {
    & python -X utf8 -m unittest discover -s $PSScriptRoot -p $suite
    if ($LASTEXITCODE) { throw "$suite failed" }
}
$fixture = Join-Path ([IO.Path]::GetTempPath()) ('harness-workflow-' + [guid]::NewGuid().ToString('N'))
function W($path, $body) { [void][IO.Directory]::CreateDirectory([IO.Path]::GetDirectoryName($path)); [IO.File]::WriteAllText($path, $body) }
function Check($value, $message) { if (-not $value) { throw $message }; "PASS $message" }
function Invoke-WorkflowFixture($command, $parameters=@{}, $arguments=@()) {
    $r = Invoke-Harness -Context $context -Command $command -Parameters $parameters -ArgumentList $arguments
    if ($r.status -ne 'Succeeded') { throw "$command : $($r.error.message)" }
    return $r.data
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
    foreach ($relative in @('.agents/skills/harness/scripts','.agents/skills/workspace-lifecycle/scripts','.agents/skills/openspec/bin')) {
        $destination=Join-Path $fixture $relative
        [void][IO.Directory]::CreateDirectory([IO.Path]::GetDirectoryName($destination))
        Copy-Item -LiteralPath (Join-Path $projectRoot $relative) -Destination $destination -Recurse
    }
    $context = New-HarnessContext -WorkspaceRoot $fixture
    Invoke-WorkflowFixture openspec.init @{} @('--project-id','fixture','--title','Fixture') | Out-Null
    Invoke-WorkflowFixture openspec.domain @{} @('create','harness','--title','Harness') | Out-Null
    $id='harness/test-feedback-loop'
    Invoke-WorkflowFixture harness.change.create @{ChangeId=$id;Title='Feedback loop';Goal='Exercise workflow';Origin='Direct';Reason='Isolated fixture'} | Out-Null
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
    Invoke-HarnessWorkflowCore -Context $context -Group execution -Action hook -Parameters @{hook_event_name='UserPromptSubmit';session_id='fixture-session';turn_id='early-feedback';prompt='Consider behavior A'} | Out-Null
    $beforeTalk=Invoke-WorkflowFixture task.status @{Change=$id}
    Check ($beforeTalk.executionAllowed -eq $false) 'pending input blocks task eligibility before a talk file exists'
    $beforeClosure=Invoke-WorkflowFixture harness.evolution.status @{Change=$id}
    Check ('User input awaits triage' -in $beforeClosure.ClosureBlockers) 'terminal evaluation sees pending input before a talk file exists'
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
    $applied=Invoke-WorkflowFixture harness.replan.apply @{Change=$id;TalkId=$record.talk_id;SessionId='fixture-session';ExpectedRevision=$settled.revision;ReplanId='replan-20260917-120000-behavior';ResumeTask='1.1';ExpectedHashes=$hashes;Candidates=@{'design.md'="# Design`n`n## Call chains`n`nnone — accepted behavior A.`n";'tasks.md'=$afterTasks}}
    Check ($applied.status -eq 'applied') 'real portable CLI validates staged and applied planning artifacts'
    Check ('1.2' -in $applied.task_changes.added -and '1.1 -> 1.2' -in $applied.edge_changes.added) 'applied record captures the actual task and dependency additions'
    $resumed=Invoke-WorkflowFixture harness.execution.status @{SessionId='fixture-session'}
    Check ($resumed.state -eq 'running' -and $resumed.implementationAllowed) 'settled Replan returns execution to the Ready task without another start'
    $source=Join-Path $fixture 'source.jsonl'
    W $source ((@{type='session_meta';payload=@{id='fixture-session';cwd=$fixture;cli_version='0.154.0'}} | ConvertTo-Json -Compress)+"`n"+(@{type='response_item';payload=@{type='message';role='assistant';phase='commentary';content=@(@{type='output_text';text='Original visible explanation'})}} | ConvertTo-Json -Depth 8 -Compress)+"`n")
    $recording=Invoke-WorkflowFixture harness.conversation.record @{Action='bind';SessionId='fixture-session';Change=$id;TalkId=$record.talk_id;Source=$source;StartLine=2}
    Check ($recording.status -eq 'covered') 'public conversation recorder targets the exact Change talk'
    Invoke-WorkflowFixture harness.conversation.record @{Action='unbind';SessionId='fixture-session'} | Out-Null
    $talkPath=Join-Path $changeRoot "attachments/talks/$($record.talk_id).md"
    Check ((Get-Content $talkPath -Raw).Contains('Original visible explanation')) 'conversation original is retained beside current discussion state'
    $info=[Diagnostics.ProcessStartInfo]::new((Get-Command pwsh).Source)
    foreach($arg in @('-NoProfile','-File',(Join-Path $fixture '.agents/skills/harness/scripts/Invoke-HarnessCodexHook.ps1'))) { $info.ArgumentList.Add($arg) }
    $info.WorkingDirectory=$fixture; $info.UseShellExecute=$false; $info.CreateNoWindow=$true
    $info.RedirectStandardInput=$true; $info.RedirectStandardOutput=$true; $info.RedirectStandardError=$true
    $process=[Diagnostics.Process]::Start($info)
    $process.StandardInput.WriteLine((@{hook_event_name='Stop';session_id='fixture-session';cwd=$fixture;permission_mode='default';transcript_path=$source} | ConvertTo-Json -Compress))
    $process.StandardInput.Close()
    $stdout=$process.StandardOutput.ReadToEnd(); $stderr=$process.StandardError.ReadToEnd(); $process.WaitForExit()
    Check ($process.ExitCode -eq 0 -and ($stdout | ConvertFrom-Json).decision -eq 'block') "native command hook continues owned unfinished work: $stderr"
    $process.Dispose()
    Move-WorkflowArchiveFixture $id
    Check ((Invoke-WorkflowFixture harness.execution.status @{SessionId='fixture-session'}).state -eq 'complete') 'standalone completion derives from the exact completed archive'
    $queueIds=@('harness/test-loop-first','harness/test-loop-second')
    foreach($queueId in $queueIds) { Invoke-WorkflowFixture harness.change.create @{ChangeId=$queueId;Title=$queueId;Goal='Queue continuation';Origin='Direct';Reason='Isolated queue fixture'} | Out-Null }
    Invoke-WorkflowFixture harness.queue.set @{Changes=$queueIds;ExpectedRevision=0} | Out-Null
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
    $resolved=[IO.Path]::GetFullPath($fixture)
    $prefix=[IO.Path]::GetFullPath([IO.Path]::GetTempPath()).TrimEnd('\','/')+[IO.Path]::DirectorySeparatorChar+'harness-workflow-'
    if (-not $resolved.StartsWith($prefix,[StringComparison]::OrdinalIgnoreCase)) { throw 'Unsafe fixture cleanup' }
    Remove-Item -LiteralPath $resolved -Recurse -Force
}
