# Isolated end-to-end lifecycle fixture; real OpenSpec, Git and queue adapters.
function Get-LifecycleFixtureCandidates {
    return @{
        'proposal.md'="# Why`n`nPersist a complete documentation plan.`n"
        'design.md'="## Call chains`n`nnone — documentation fixture with no implementation call chain.`n"
        'tasks.md'=@'
---
task_graph:
  version: 1
  depends_on:
    "1.1": []
---
# Complete fixture
## Goal
Prove a persisted plan.
## Architecture
Document the fixture.
## Global constraints
No external work.
## Requirement coverage
Fixture guidance: 1.1.
## [ ] 1.1 Document fixture guidance

Write bounded guidance.

**Outcome**

The fixture has a self-contained guide.

**Files**

```diff
+guide.md
```

**Verification**

```powershell
Test-Path guide.md
```
'@
        'specs/harness/fixture/spec.md'="## ADDED Requirements`n`n### Requirement: Persist fixture guidance`n`nThe fixture SHALL retain its guide.`n`n#### Scenario: Read guidance`n`n- **WHEN** the fixture is read`n- **THEN** the guide is available`n"
    }
}
function Write-LifecycleFixture($Path,$Text) { [void][IO.Directory]::CreateDirectory((Split-Path $Path)); [IO.File]::WriteAllText($Path,$Text) }
function Invoke-LifecycleFixture($Context,$Command,$Parameters=@{},$Arguments=@()) {
    $r=Invoke-Harness -Context $Context -Command $Command -Parameters $Parameters -ArgumentList $Arguments
    if ($r.status -ne 'Succeeded') { throw "$Command : $($r.error.message)" }
    return $r.data
}
function Add-LifecycleFixturePlugin($FixtureRoot,$Case) {
    $origin=Join-Path $FixtureRoot 'Saved/fixture-plugin'
    [void][IO.Directory]::CreateDirectory($origin)
    & git -C $origin init -q -b main
    & git -C $origin config user.name Fixture
    & git -C $origin config user.email fixture@example.invalid
    Write-LifecycleFixture (Join-Path $origin 'Foo.uplugin') '{"FileVersion":3}'
    Write-LifecycleFixture (Join-Path $origin 'owned.txt') "plugin baseline`n"
    & git -C $origin add .
    & git -C $origin commit -qm baseline
    & git -C $FixtureRoot -c protocol.file.allow=always submodule add -q $origin Plugins/Foo
    if ($LASTEXITCODE) { throw 'Isolated plugin setup failed' }
    & git -C $FixtureRoot commit -qm 'fixture plugin baseline' -- .gitmodules Plugins/Foo
    $plugin=Join-Path $FixtureRoot 'Plugins/Foo'
    & git -C $plugin config user.name Fixture
    & git -C $plugin config user.email fixture@example.invalid
    Write-LifecycleFixture (Join-Path $plugin 'owned.txt') "plugin result`n"
    Write-LifecycleFixture (Join-Path $plugin 'outside.txt') "plugin outside staged sentinel`n"
    & git -C $plugin add outside.txt
    $Case.Parameters.GitPlan.Implementation=@{RepositoryScopes=@{'Plugins/Foo'=@('owned.txt')};CommitMessage='fixture plugin implementation'}
    $Case.Parameters.GitPlan.Records.RepositoryScopes['.']+=@('Plugins/Foo')
    return $plugin
}
function New-LifecycleFixture($ProjectRoot,$FixtureRoot,$Id='harness/test-lifecycle-closure') {
    [void][IO.Directory]::CreateDirectory($FixtureRoot)
    & git -C $FixtureRoot init -q -b main
    & git -C $FixtureRoot config user.name Fixture
    & git -C $FixtureRoot config user.email fixture@example.invalid
    Write-LifecycleFixture (Join-Path $FixtureRoot '.gitignore') "Saved/`n.workspaces/`nopenspec/drafts/`nAgentConfig.ini`n"
    Write-LifecycleFixture (Join-Path $FixtureRoot 'Fixture.uproject') '{"FileVersion":3,"Modules":[],"Plugins":[]}'
    Write-LifecycleFixture (Join-Path $FixtureRoot 'owned.txt') "owned baseline`n"
    & git -C $FixtureRoot add .gitignore Fixture.uproject owned.txt
    & git -C $FixtureRoot commit -qm baseline
    foreach ($relative in @('.agents/skills/harness/scripts','.agents/skills/workspace-lifecycle/scripts','.agents/skills/git-operations/scripts','.agents/skills/openspec/bin')) {
        $destination=Join-Path $FixtureRoot $relative
        [void][IO.Directory]::CreateDirectory((Split-Path $destination))
        Copy-Item -LiteralPath (Join-Path $ProjectRoot $relative) -Destination $destination -Recurse
    }
    $ctx=New-HarnessContext -WorkspaceRoot $FixtureRoot
    Invoke-LifecycleFixture $ctx openspec.init @{} @('--project-id','fixture','--title','Fixture','--workflow','angelscript') | Out-Null
    Copy-Item -LiteralPath (Join-Path $ProjectRoot 'openspec/workflows/angelscript') -Destination (Join-Path $FixtureRoot 'openspec/workflows/angelscript') -Recurse
    Invoke-LifecycleFixture $ctx openspec.domain @{} @('create','harness','--title','Harness','--json') | Out-Null
    return New-LifecycleFixtureChange $ctx $FixtureRoot $Id
}
function New-LifecycleFixtureChange($ctx,$FixtureRoot,$Id) {
    $p=@{ChangeId=$Id;Title='Lifecycle fixture';Goal='Prove exact lifecycle persistence';Origin='Direct';Reason='Hermetic fixture';HandoffText='Complete fixture design and planning checkpoint';SessionId='lifecycle-fixture';Candidates=(Get-LifecycleFixtureCandidates);GitPlan=@{RepositoryScopes=@{'.'=@('openspec/changes/'+$Id)};CommitMessage='fixture planning'}}
    $shown=Invoke-LifecycleFixture $ctx harness.change.create ($p+@{PlanOnly=$true})
    $p.Gate=@{ConvergenceSource='fixture:ready';DecisionSource='fixture:create';Decision='create';TargetChange=$Id;HandoffRevision=$shown.HandoffRevision}
    $created=Invoke-LifecycleFixture $ctx harness.change.create $p
    $questions=@(@{id='draft-disposition';question='Draft';answer='not-applicable';source='not-applicable:no-draft'},@{id='execution-disposition';question='Execute';answer='now';source='fixture:execute'})
    $settled=Invoke-LifecycleFixture $ctx harness.talk.update @{Change=$Id;TalkId=$created.Followup;SessionId='lifecycle-fixture';ExpectedRevision=1;Status='settled';Questions=$questions}
    Invoke-LifecycleFixture $ctx harness.execution.start @{Change=$Id;Scope='Change';SessionId='lifecycle-fixture';SourceRef='fixture:execute'} | Out-Null
    Invoke-LifecycleFixture $ctx harness.talk.update @{Change=$Id;TalkId=$created.Followup;SessionId='lifecycle-fixture';ExpectedRevision=$settled.revision;Status='closed';Disposition='no-change';Arrangements=@{draft=@{status='applied';decision='not-applicable';source='not-applicable:no-draft'};execution=@{status='applied';decision='now';source='fixture:execute'}}} | Out-Null
    $changeRoot=Join-Path $ctx.OpenSpecRoot ('openspec/changes/'+$Id)
    Write-LifecycleFixture (Join-Path $changeRoot 'tasks.md') ([IO.File]::ReadAllText((Join-Path $changeRoot 'tasks.md')).Replace('## [ ]','## [x]'))
    if ($ctx.Topology -ne 'Replica') {
    Write-LifecycleFixture (Join-Path $FixtureRoot 'owned.txt') "owned result`n"
    Write-LifecycleFixture (Join-Path $FixtureRoot 'outside.txt') "outside staged sentinel`n"
    & git -C $FixtureRoot add outside.txt
    }
    Add-Content (Join-Path $changeRoot 'attachments/INDEX.md') '- data/workflow-evaluation.md — fixture terminal evidence.'
    $view=Invoke-LifecycleFixture $ctx harness.evolution.status @{Change=$Id}
    Write-LifecycleFixture (Join-Path $changeRoot 'attachments/data/workflow-evaluation.md') "---`nrecord: harness-workflow-evaluation-v1`nresult: passed`nchange: $Id`nclosure_kind: completed`ninput_sha256: $($view.CurrentInputSha256)`ncaptured_at: $([DateTimeOffset]::UtcNow.ToString('o'))`n---`n`n# Evidence`nReal fixture checks; no Unreal behavior is claimed.`n"
    return @{Context=$ctx;Id=$Id;Root=$changeRoot;Parameters=@{ChangeId=$Id;ClosureKind='completed';SessionId='lifecycle-fixture';GitPlan=@{Implementation=@{};Records=@{RepositoryScopes=@{'.'=@('openspec/changes/'+$Id)+$(if ($ctx.Topology -ne 'Replica') { @('owned.txt') } else { @() })};CommitMessage='fixture completed closure'}};Dispositions=@{Closure=@{kind='completed'};SpecSync='not-applicable: fixture-only contract';Verification='attachments/data/workflow-evaluation.md'}}}
}
function Invoke-LifecycleFixtureReplan($Case) {
    $ctx=$Case.Context; $id=$Case.Id
    $talk=Invoke-LifecycleFixture $ctx harness.talk.create @{Change=$id;SessionId='lifecycle-fixture';Kind='grill';Theme='accepted-guidance';Summary='Clarify the fixture design';SourceRef='fixture:replan-discussion';ResumeTask='1.1';Questions=@(@{id='Q1';question='Which guidance?';answer=$null;source=$null})}
    $settled=Invoke-LifecycleFixture $ctx harness.talk.update @{Change=$id;TalkId=$talk.talk_id;SessionId='lifecycle-fixture';ExpectedRevision=$talk.revision;Status='settled';Questions=@(@{id='Q1';question='Which guidance?';answer='Retain the existing task and clarify its design';source='fixture:replan-answer'})}
    $plan=@{Change=$id;TalkId=$talk.talk_id;SessionId='lifecycle-fixture';ExpectedRevision=$settled.revision;ReplanId='replan-20260920-120000-fixture';ResumeTask='1.1';ExpectedHashes=@{'design.md'=(Get-FileHash (Join-Path $Case.Root 'design.md') -Algorithm SHA256).Hash.ToLowerInvariant()};Candidates=@{'design.md'="## Call chains`n`nnone — documentation fixture with accepted clarified guidance and its existing task.`n"};HandoffText='Retain completed task identity and clarify the accepted design.';GitPlan=@{RepositoryScopes=@{'.'=@('openspec/changes/'+$id)};CommitMessage='fixture accepted Replan'}}
    $plan.ExpectedHashes['tasks.md']=(Get-FileHash (Join-Path $Case.Root 'tasks.md') -Algorithm SHA256).Hash.ToLowerInvariant()
    $shown=Invoke-LifecycleFixture $ctx harness.replan.apply ($plan+@{PlanOnly=$true})
    $applied=Invoke-LifecycleFixture $ctx harness.replan.apply ($plan+@{Gate=@{ConvergenceSource='fixture:replan-ready';DecisionSource='fixture:replan-apply';Decision='replan';TargetChange=$id;HandoffRevision=$shown.HandoffRevision}})
    $followup=$applied.handoff.post_talk_id
    $status=Invoke-LifecycleFixture $ctx harness.talk.status @{Change=$id;TalkId=$followup}
    $qs=@(@{id='draft-disposition';question='Draft';answer='not-applicable';source='not-applicable:no-draft'},@{id='execution-disposition';question='Continue';answer='now';source='fixture:replan-continue'})
    $settled=Invoke-LifecycleFixture $ctx harness.talk.update @{Change=$id;TalkId=$followup;SessionId='lifecycle-fixture';ExpectedRevision=$status.records[0].revision;Status='settled';Questions=$qs}
    Invoke-LifecycleFixture $ctx harness.execution.start @{Change=$id;Scope='Change';SessionId='lifecycle-fixture';SourceRef='fixture:replan-continue'} | Out-Null
    Invoke-LifecycleFixture $ctx harness.talk.update @{Change=$id;TalkId=$followup;SessionId='lifecycle-fixture';ExpectedRevision=$settled.revision;Status='closed';Disposition='no-change';Arrangements=@{draft=@{status='applied';decision='not-applicable';source='not-applicable:no-draft'};execution=@{status='applied';decision='now';source='fixture:replan-continue'}}} | Out-Null
    $view=Invoke-LifecycleFixture $ctx harness.evolution.status @{Change=$id}
    $evaluation=Join-Path $Case.Root 'attachments/data/workflow-evaluation.md'
    Write-LifecycleFixture $evaluation ([regex]::Replace([IO.File]::ReadAllText($evaluation),'(?m)^input_sha256:.*$',('input_sha256: '+$view.CurrentInputSha256)))
    return $applied.PlanningCommit
}
