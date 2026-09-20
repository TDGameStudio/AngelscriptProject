---
task_graph:
  version: 1
  depends_on:
    "1.1": []
    "1.2": ["1.1"]
    "1.3": ["1.1", "1.2"]
    "1.4": ["1.1", "1.3"]
    "1.5": ["1.4"]
    "1.6": ["1.4", "1.5"]
    "2.1": []
    "2.2": ["1.2", "1.3", "1.4", "1.5", "1.6", "2.1"]
    "2.3": ["1.6", "2.1", "2.2"]
    "2.4": ["1.6", "2.1", "2.2", "2.3"]
---

# Explained lifecycle decisions and Git closure

## Goal

Make accepted planning and closure understandable, version-bound, Git-persisted and recoverable while keeping topic discussions continuous.

## Architecture

Harness composes exact Git candidate operations with Create/Replan/closure and queue state. Existing topic drafts own feedback, and the Skills own explanations and question continuation. See design.md for responsibilities and proposed interfaces.

## Global constraints

- Candidate planning only: no task is executed or complete in this draft.
- Keep normal hooks, outside staged changes, canonical/replica ownership, true task outcomes and historical archives intact.
- No new independent harness-update Skill, automatic integration/push/removal, or historical backlog cleanup.
- Execution conventions: .agents/skills/harness/references/execution-conventions.md.

## Requirement coverage

| Requirement and acceptance | Tasks |
| --- | --- |
| R1 Exact explained Git selections | 1.1, 1.4 |
| R2 Complete planning before Create | 1.2, 2.2 |
| R3 Formal Replan commits without old-code checkpoints | 1.3, 2.2 |
| R4 One completed close Gate and recovery | 1.4, 1.6 |
| R5 Honest abandoned/superseded preservation and withdrawal | 1.5, 1.6 |
| R6 Queue authority and partial-close state | 1.6 |
| R7 Topic-draft feedback, batch selection and no duplicate ledger | 2.1, 2.2 |
| R8 Continuing Grill and all three explanations | 2.2 |
| R9 Compatible contracts and integrated proof | 2.4 |
| R10 Explanation-driven method/specification/knowledge/retrieval improvement | 2.1, 2.3 |

Self-review 2026-09-20: coverage maps all R1-R10; placeholder scan and inspected symbol/file checks recorded in attachments/data/planning-validation.md; no implementation evidence is claimed.

## [ ] 1.1 Bind exact Git candidates to previewed content

Commit only the approved attributable content, including an explicit patch within a shared file, while retaining normal hooks and unrelated live/index state. Exclude automatic ownership inference, push and integration.

**Outcome**

Commit only the approved attributable content, including an explicit patch within a shared file, while retaining normal hooks and unrelated live/index state. Exclude automatic ownership inference, push and integration.

**Interfaces**

Consumes (inspected source or named prerequisite output):

```text
Complete-HarnessGitCommit(WorkspaceRoot, RepositoryScopes, PreserveOutsideStaged, PluginsOnly, CommitMessage, SubmoduleCommitMessages, TargetBranches)  # GitOperations.psm1:574
Invoke-GitScopedCommitAttempt(...)  # GitOperations.psm1:467
```

Produces (proposed extension, with naming source):

```text
Complete-HarnessGitCommit(..., RepositoryPatches, ExpectedPlanRevision)
WhatIf result.PlanRevision  # proposed parameters/property follow existing PascalCase Git API convention
```

**Cases**

1. **Preview drift rejects mutation** — new RED
   Given HEAD H and selected patch P, preview V; when selected bytes or HEAD change before commit with V, then refs and live index stay unchanged and the result identifies stale input.

2. **Shared file keeps the other edit** — new RED
   Given HEAD contains a=0,b=0 and the live file contains a=1,b=2, when the explicit approved patch changes only a to 1, then the new commit has a=1,b=0 and b=2 remains a live uncommitted edit.

3. **Outside staged content survives** — existing control
   Given owned a.txt and staged unrelated b.txt, when exact a.txt commits in preservation mode, then b.txt index mode, content and patch match their captured pre-operation values.

4. **Hooks and multi-repository partial success** — boundary
   Given the plugin commit succeeds but the parent hook rejects its candidate, then the plugin commit is reported once, the parent ref/index remain at pre-attempt state and retry does not duplicate the plugin commit.


**Files**

```diff
 .agents/skills/git-operations/scripts/GitOperations.psm1
 .agents/skills/git-operations/tests/GitOperations.Tests.ps1
 .agents/skills/git-operations/tests/PluginCommits.Tests.ps1
```

**Verification**

Run from D:/Workspace/AngelscriptProject using isolated PowerShell test processes.

```powershell
pwsh -NoProfile -File '.agents/skills/git-operations/tests/GitOperations.Tests.ps1'
if ($LASTEXITCODE -ne 0) { throw 'Task verification failed' }
pwsh -NoProfile -File '.agents/skills/git-operations/tests/PluginCommits.Tests.ps1'
if ($LASTEXITCODE -ne 0) { throw 'Task verification failed' }
```

All selected fixtures must execute and pass for the final owned content. Record exact commands and results; proposed commands above are not passing evidence.

## [ ] 1.2 Create and save complete planning candidates

Preview the complete first plan without canonical mutation, bind it to the real Create decision, then materialize/validate/commit exactly that plan with recoverable ownership. Retain the separate disposition/execution arrangement and historical-plan compatibility.

**Outcome**

Preview the complete first plan without canonical mutation, bind it to the real Create decision, then materialize/validate/commit exactly that plan with recoverable ownership. Retain the separate disposition/execution arrangement and historical-plan compatibility.

**Interfaces**

Consumes (inspected source or named prerequisite output):

```text
New-HarnessChange(Context, ChangeId, Title, Goal, Origin, DraftId, Scope, PlanOnly, Gate, SessionId)  # ChangeGate.psm1:233
preview(context, operation, parameters, historical=False)  # handoff.py:117
Test-HarnessChangeSeed(Context, ChangeId)  # ChangeGate.psm1:279
Complete-HarnessGitCommit(..., ExpectedPlanRevision)  # produced by 1.1
```

Produces (proposed extension, with naming source):

```text
New-HarnessChange(..., Candidates, GitPlan)
HandoffRevision binds candidate planning and Git intent  # existing route and parameter conventions; extend current receipt schema with historical reads
```

**Cases**

1. **Read-only full candidate preview** — new RED
   Given proposal/design/tasks and applicable specs in a draft candidate, when PlanOnly runs, then strict candidate validation occurs in an isolated area and no canonical Change directory or Git ref is created.

2. **Changed candidate needs new decision** — new RED
   Given displayed revision V, when tasks or selected Git content change, then the old Gate cannot create or commit the revised candidate.

3. **Complete plan persists even while waiting** — new RED
   Given an accepted candidate, when creation and checks succeed, then proposal/design/tasks/specs and provenance are committed; choosing later leaves implementation blocked while that plan remains readable.

4. **Interrupted creation resumes ownership** — boundary
   Given native creation succeeded and formal-record commit failed, when the exact request retries, then it keeps the same UID and receipt, validates remaining work and creates no duplicate followup or commit.

5. **Legacy plan remains readable** — existing control
   Given a Change admitted by the existing historical contract, when read or explicitly planned through its compatibility path, then it is not retroactively forced through an invented earlier Gate.


**Files**

```diff
 .agents/skills/harness/scripts/ChangeGate.psm1
 .agents/skills/harness/scripts/handoff.py
 .agents/skills/harness/scripts/Harness.psm1
 .agents/skills/harness/tests/HarnessChangeGate.Tests.ps1
 .agents/skills/harness/tests/HarnessHandoff.Tests.ps1
```

**Verification**

Run from D:/Workspace/AngelscriptProject using isolated PowerShell test processes.

```powershell
pwsh -NoProfile -File '.agents/skills/harness/tests/HarnessChangeGate.Tests.ps1'
if ($LASTEXITCODE -ne 0) { throw 'Task verification failed' }
pwsh -NoProfile -File '.agents/skills/harness/tests/HarnessHandoff.Tests.ps1'
if ($LASTEXITCODE -ne 0) { throw 'Task verification failed' }
```

All selected fixtures must execute and pass for the final owned content. Record exact commands and results; proposed commands above are not passing evidence.

## [ ] 1.3 Commit accepted Replan records without checkpointing implementation

Persist accepted Replan candidates and provenance in Git with exact retries. Keep incomplete implementation uncommitted and preserve valid tasks/evidence; do not restart execution before the arrangement.

**Outcome**

Persist accepted Replan candidates and provenance in Git with exact retries. Keep incomplete implementation uncommitted and preserve valid tasks/evidence; do not restart execution before the arrangement.

**Interfaces**

Consumes (inspected source or named prerequisite output):

```text
harness.replan.apply(Change, TalkId, SessionId, ExpectedRevision, ReplanId, Candidates, ExpectedHashes, ResumeTask, PlanOnly, Gate)  # references/discussions.md; replans.py:105
consume_gate(context, operation, parameters, prepared=None)  # handoff.py:137
```

Produces (proposed extension, with naming source):

```text
harness.replan.apply(..., GitPlan)  # follows the proposed creation GitPlan contract from 1.2; no new implementation checkpoint action
```

**Cases**

1. **Only formal records commit** — new RED
   Given modified implementation code and accepted new tasks/design, when Replan applies with its shown GitPlan, then only formal planning and its generated provenance are committed; the code diff remains uncommitted.

2. **Commit failure retains recoverable applied state** — new RED
   Given the journal writes applied planning but its Git hook fails, then status reports planning-applied/commit-pending and blocks continuation; exact retry commits the same operation without another applied record.

3. **Stale planning baseline fails** — existing control
   Given ExpectedHashes from old tasks, when accepted planning changed concurrently, then candidate application fails before changing formal files.

4. **Wait and completed task identity survive** — boundary
   Given preserved completed task IDs and a post-Replan later arrangement, then IDs/evidence remain intact and no old execution request resumes implementation.


**Files**

```diff
 .agents/skills/harness/scripts/replans.py
 .agents/skills/harness/scripts/handoff.py
 .agents/skills/harness/scripts/Workflow.psm1
 .agents/skills/harness/scripts/execution.py
 .agents/skills/harness/tests/test_replans.py
 .agents/skills/harness/tests/HarnessHandoff.Tests.ps1
```

**Verification**

Run from D:/Workspace/AngelscriptProject using isolated PowerShell test processes.

```powershell
pwsh -NoProfile -File '.agents/skills/harness/tests/HarnessHandoff.Tests.ps1'
if ($LASTEXITCODE -ne 0) { throw 'Task verification failed' }
python -m unittest discover -s '.agents/skills/harness/tests' -p 'test_replans.py'
if ($LASTEXITCODE -ne 0) { throw 'Replan fixture failed' }
```

All selected fixtures must execute and pass for the final owned content. Record exact commands and results; proposed commands above are not passing evidence.

**Notes**

Also run python -m unittest discover -s .agents/skills/harness/tests -p test_replans.py. Inspect the current public dispatch before extending its exact parameter forwarding.

## [ ] 1.4 Gate completed closure and persist all owned results

Present/consume a concrete close decision and recover completed closure through implementation commits, terminal evaluation, native archive, archived validation and canonical-record commit. A raw public archive call cannot bypass the new decision.

**Outcome**

Present/consume a concrete close decision and recover completed closure through implementation commits, terminal evaluation, native archive, archived validation and canonical-record commit. A raw public archive call cannot bypass the new decision.

**Interfaces**

Consumes (inspected source or named prerequisite output):

```text
Invoke-Harness(Command, Context, Parameters, ArgumentList)  # Harness.psm1 public dispatcher
Complete-HarnessGitCommit(..., ExpectedPlanRevision)  # 1.1
Get-HarnessEvolutionStatus(...)  # Harness.psm1 terminal evaluation
handoff receipt and GitPlan  # 1.2/1.3
```

Produces (proposed extension, with naming source):

```text
harness.change.close
Close-HarnessChange(Context, ChangeId, ClosureKind, SessionId, PlanOnly, Gate, GitPlan, Dispositions)
# Proposed route/module/function names follow New-HarnessChange and Close-HarnessDraft conventions; this task produces them.
```

**Cases**

1. **Unapproved archive fails before move** — new RED
   Given valid terminal evidence but no actual close decision, when the public archive mutation runs, then the active record stays in place and no Git ref moves.

2. **One approval covers shown completed closure** — new RED
   Given a verified Change and exact close preview, when the real decision is consumed, then owned plugin changes commit, terminal proof uses the resulting source, native archive/validation succeeds and canonical record changes commit.

3. **Stale preview cannot absorb another edit** — new RED
   Given approved close content, when a selected file changes, then closure blocks before the affected mutation and requests a fresh preview instead of adding the new bytes.

4. **Primary commit failure after archive** — boundary
   Given archive validation succeeded but the parent hook fails, then state reports archived/commit-pending; retry preserves the archive and earlier commits and completes only the remaining owned commit.

5. **Replica uses canonical context** — boundary
   Given an editable replica plugin and primary canonical records, then each commit uses its owning repository/context; no replica root Git target or implicit integration is fabricated.


**Files**

```diff
+.agents/skills/harness/scripts/ChangeClosure.psm1
 .agents/skills/harness/scripts/Harness.psm1
 .agents/skills/harness/scripts/handoff.py
+.agents/skills/harness/tests/HarnessClosure.Tests.ps1
 .agents/skills/harness/tests/HarnessMutationGate.Tests.ps1
 .agents/skills/harness/tests/HarnessEvolution.Tests.ps1
```

**Verification**

Run from D:/Workspace/AngelscriptProject using isolated PowerShell test processes.

```powershell
pwsh -NoProfile -File '.agents/skills/harness/tests/HarnessClosure.Tests.ps1'
if ($LASTEXITCODE -ne 0) { throw 'Task verification failed' }
pwsh -NoProfile -File '.agents/skills/harness/tests/HarnessMutationGate.Tests.ps1'
if ($LASTEXITCODE -ne 0) { throw 'Task verification failed' }
pwsh -NoProfile -File '.agents/skills/harness/tests/HarnessEvolution.Tests.ps1'
if ($LASTEXITCODE -ne 0) { throw 'Task verification failed' }
```

All selected fixtures must execute and pass for the final owned content. Record exact commands and results; proposed commands above are not passing evidence.

**Notes**

Task 1.6 connects the complete close outcome to queue progression. Do not promote unfinished specs or update immutable archives merely to store the final parent commit SHA.

## [ ] 1.5 Preserve and withdraw incomplete implementations honestly

Support abandoned and superseded close plans using explicit task dispositions, incomplete checkpoints and exact withdrawal/carryover. Preserve unrelated work and normal hooks; do not interpret dissatisfaction or Replan as abandonment.

**Outcome**

Support abandoned and superseded close plans using explicit task dispositions, incomplete checkpoints and exact withdrawal/carryover. Preserve unrelated work and normal hooks; do not interpret dissatisfaction or Replan as abandonment.

**Interfaces**

Consumes (inspected source or named prerequisite output):

```text
Close-HarnessChange(..., ClosureKind, Dispositions, GitPlan)  # 1.4
Complete-HarnessGitCommit(..., RepositoryPatches, ExpectedPlanRevision)  # 1.1
```

Produces (proposed extension, with naming source):

```text
Existing close plan stages extended for incomplete checkpoint, exact withdrawal and replacement carryover; no new public route.
```

**Cases**

1. **Abandon retains history and removes only owned code** — new RED
   Given owned A and unrelated B edits plus a shown checkpoint/withdrawal plan, when abandoned closure succeeds, then Git retains A in an incomplete checkpoint, the final live state withdraws only A, B survives and no incomplete task is marked complete.

2. **Ambiguous withdrawal stops** — new RED
   Given overlapping dependent hunks that cannot be separated, when closure is requested, then no blanket file restore or reset occurs and the exact unresolved disposition is reported.

3. **Superseded work follows replacement** — new RED
   Given replacement R accepts component A but not B, then closure records R, retains/transfers A as shown and withdraws only B; unfinished deltas are not synced as completed contracts.

4. **Hook rejection is a blocker** — boundary
   Given the incomplete checkpoint is rejected by a normal hook, then closure reports failure without bypassing the hook, withdrawing unsaved code or claiming a saved checkpoint.


**Files**

```diff
 .agents/skills/harness/scripts/ChangeClosure.psm1
 .agents/skills/git-operations/scripts/GitOperations.psm1
 .agents/skills/harness/tests/HarnessClosure.Tests.ps1
 .agents/skills/git-operations/tests/GitOperations.Tests.ps1
```

**Verification**

Run from D:/Workspace/AngelscriptProject using isolated PowerShell test processes.

```powershell
pwsh -NoProfile -File '.agents/skills/harness/tests/HarnessClosure.Tests.ps1'
if ($LASTEXITCODE -ne 0) { throw 'Task verification failed' }
pwsh -NoProfile -File '.agents/skills/git-operations/tests/GitOperations.Tests.ps1'
if ($LASTEXITCODE -ne 0) { throw 'Task verification failed' }
```

All selected fixtures must execute and pass for the final owned content. Record exact commands and results; proposed commands above are not passing evidence.

## [ ] 1.6 Resume queue execution from the full close outcome

Make archive plus required Git/withdrawal completion the queue boundary; report partial states faithfully and retain pending-input, exact-range and post-handoff wait authority.

**Outcome**

Make archive plus required Git/withdrawal completion the queue boundary; report partial states faithfully and retain pending-input, exact-range and post-handoff wait authority.

**Interfaces**

Consumes (inspected source or named prerequisite output):

```text
inspect_record(context, item)  # change_queue.py:57
derive(context, state)  # execution.py:117
Close-HarnessChange completion and recovery facts  # 1.4/1.5
```

Produces (proposed extension, with naming source):

```text
Existing queue/execution status gains full close completion dependency; a new isolated HarnessLifecycle.Tests.ps1 fixture follows repository test naming convention.
```

**Cases**

1. **Archive alone cannot advance queue** — new RED
   Given queue A then B and A archived with canonical commit pending, when status/controller resumes, then B remains unstarted; A becomes complete only after its remaining close stage succeeds.

2. **Retry advances once** — new RED
   Given a lost response after final commit, when recovery inspects matching operation/ref evidence twice, then it reports one completion and starts no item beyond the authorized range.

3. **Feedback and wait still block** — existing control
   Given pending feedback or a current later arrangement, when old authorization exists, then status remains blocked/waiting without acknowledging or reviving that authority.

4. **Generic unattended request is insufficient** — boundary
   Given run-queue authority without the scope/conditions of the close plan, then execution awaits the specific decision; already explicit matching authority is not asked twice.

5. **End-to-end fixture closure** — new RED
   Given an isolated primary plus editable plugin, run complete Create, one Replan, completed close and a separate abandoned close; then each expected planning/result commit exists, outside sentinels survive, archives validate and queue state matches actual completed operations.


**Files**

```diff
 .agents/skills/harness/scripts/change_queue.py
 .agents/skills/harness/scripts/execution.py
 .agents/skills/harness/scripts/ChangeQueue.psm1
 .agents/skills/harness/tests/test_change_queue.py
 .agents/skills/harness/tests/test_execution.py
 .agents/skills/harness/tests/HarnessQueue.Tests.ps1
+.agents/skills/harness/tests/HarnessLifecycle.Tests.ps1
```

**Verification**

Run from D:/Workspace/AngelscriptProject using isolated PowerShell test processes.

```powershell
pwsh -NoProfile -File '.agents/skills/harness/tests/HarnessQueue.Tests.ps1'
if ($LASTEXITCODE -ne 0) { throw 'Task verification failed' }
pwsh -NoProfile -File '.agents/skills/harness/tests/HarnessLifecycle.Tests.ps1'
if ($LASTEXITCODE -ne 0) { throw 'Task verification failed' }
python -m unittest discover -s '.agents/skills/harness/tests' -p 'test_change_queue.py'
if ($LASTEXITCODE -ne 0) { throw 'Controller fixture failed' }
python -m unittest discover -s '.agents/skills/harness/tests' -p 'test_execution.py'
if ($LASTEXITCODE -ne 0) { throw 'Controller fixture failed' }
```

All selected fixtures must execute and pass for the final owned content. Record exact commands and results; proposed commands above are not passing evidence.

**Notes**

Also run python -m unittest discover -s .agents/skills/harness/tests -p test_change_queue.py and the corresponding test_execution.py selection. Fixtures must not depend on this live Change staying active.

## [ ] 2.1 Capture upgrade feedback in topic drafts only

Route sourced new workflow friction to canonical topic drafts, merge recurrence, support user-selected batch treatment and preserve historical data without a parallel new-upgrade ledger. Capture alone does not create a Change or block unrelated execution.

**Outcome**

Route sourced new workflow friction to canonical topic drafts, merge recurrence, support user-selected batch treatment and preserve historical data without a parallel new-upgrade ledger. Capture alone does not create a Change or block unrelated execution.

**Interfaces**

Consumes (inspected source or named prerequisite output):

```text
Add-HarnessObservation(Context, Category, Summary, Change, Stage, CorrelationId, DurationMs, SourceRef, DedupKey, OwnerDraftId)  # Harness.psm1:896
New-HarnessDraft(...) and Get-HarnessDraftStatus(...)  # DraftLifecycle.psm1:91,109
Get-HarnessFeedbackInbox(Context, Limit)  # Feedback.psm1:15
```

Produces (proposed extension, with naming source):

```text
harness.observe accepts OwnerScope beside OwnerDraftId and returns the owning draft reference; query/triage operate on draft scopes for new feedback. Existing historical observations retain explicit read compatibility; no new feedback schema or mode.
```

**Cases**

1. **Capture creates only draft records** — new RED
   Given a sourced explanation improvement signal with no matching topic, when harness.observe runs, then one ignored topic draft owns the finding and no new Saved observation/inbox/triage record, Change, queue item or Skill edit is produced; an unproven cause remains a hypothesis, not a proven Skill defect.

2. **Recurrence reuses topic** — new RED
   Given the same issue under another actual SourceRef, then the existing scope retains both sources and updated conclusion without duplicating the topic or full discussion transcript.

3. **Capture during execution does not expand scope** — new RED
   Given an unrelated improvement suggestion during authorized A, then its draft persists and A continues after ordinary input triage; the suggestion does not become an A implementation task.

4. **Batch disposition is not repair evidence** — boundary
   Given two draft topics, when a user selects one for later treatment, then the other is unchanged and neither selection, handoff nor draft archive claims the defect repaired.

5. **Historical records and measurements remain isolated** — existing control
   Given old Saved observations and a performance fixture, then queries do not migrate/delete old records and synthetic capture writes only in the fixture draft root.


**Files**

```diff
 .agents/skills/harness/scripts/Harness.psm1
 .agents/skills/harness/scripts/Feedback.psm1
 .agents/skills/harness/scripts/DraftLifecycle.psm1
 .agents/skills/harness/tests/HarnessFeedback.Tests.ps1
 .agents/skills/harness/tests/HarnessDraft.Tests.ps1
 .agents/skills/harness/tests/Harness.Performance.Tests.ps1
```

**Verification**

Run from D:/Workspace/AngelscriptProject using isolated PowerShell test processes.

```powershell
pwsh -NoProfile -File '.agents/skills/harness/tests/HarnessFeedback.Tests.ps1'
if ($LASTEXITCODE -ne 0) { throw 'Task verification failed' }
pwsh -NoProfile -File '.agents/skills/harness/tests/HarnessDraft.Tests.ps1'
if ($LASTEXITCODE -ne 0) { throw 'Task verification failed' }
```

All selected fixtures must execute and pass for the final owned content. Record exact commands and results; proposed commands above are not passing evidence.

## [ ] 2.2 Make the active discussion and three explanations explicit

Place one actionable continuation loop in Grill, active-discussion precedence in Harness and focused references in Brainstorming. Explain Create/Replan/closure fully and connect understanding feedback to task 2.3. Actually submit eligible selectable popup Gates after explanation, preserve decision provenance and keep feedback-only drafts/user-led convergence distinct. This is a guidance and consumer-validation task, not a new runtime agent controller.

**Outcome**

Place one actionable continuation loop in Grill, active-discussion precedence in Harness and focused references in Brainstorming. Explain Create/Replan/closure fully and connect understanding feedback to task 2.3. Actually submit eligible selectable popup Gates after explanation, preserve decision provenance and keep feedback-only drafts/user-led convergence distinct. This is a guidance and consumer-validation task, not a new runtime agent controller.

**Files**

```diff
 .agents/skills/harness/SKILL.md
 .agents/skills/harness/references/handoff-gate.md
 .agents/skills/harness/references/closure.md
 .agents/skills/harness/references/evolution.md
 .agents/skills/harness/references/discussions.md
 .agents/skills/grill/SKILL.md
 .agents/skills/grill/references/rounds.md
 .agents/skills/grill/references/hosts.md
 .agents/skills/brainstorming/SKILL.md
 .agents/skills/brainstorming/references/deep-exploration.md
 .agents/skills/brainstorming/references/drafts.md
 .agents/skills/openspec-create-change/SKILL.md
 .agents/skills/openspec-update-change/SKILL.md
 .agents/skills/openspec-apply-change/SKILL.md
 .agents/skills/openspec-archive-change/SKILL.md
 .agents/skills/git-operations/SKILL.md
 .agents/skills/git-operations/references/commits.md
 .agents/skills/change-queue/SKILL.md
 .agents/skills/harness/tests/Protocol.Tests.ps1
```

**Verification**

Run from D:/Workspace/AngelscriptProject using isolated PowerShell test processes.

```powershell
pwsh -NoProfile -File '.agents/skills/harness/tests/Protocol.Tests.ps1'
if ($LASTEXITCODE -ne 0) { throw 'Task verification failed' }
```

All selected fixtures must execute and pass for the final owned content. Record exact commands and results; proposed commands above are not passing evidence.

**Notes**

Retain independent multi-turn consumer traces with side questions, partial answers, no-ready-choice coverage inspection, explicit pause, inadequate explanation at each Gate and feedback-only capture. Include eligible popup submission, approval-prohibited tool rejection, pending/cancelled forms, explicit answers and unavailable/invisible form fallback. Inspect actual submitted questions/decisions and their provenance; static keywords or a fabricated explained flag are insufficient. Report whether the historical failure reproduced and every host limitation; do not claim measured improvement from the earlier offline tie. Add the accepted trace summary under this Change attachments and index it.

## [ ] 2.3 Improve explanations and enrich owning capability knowledge

Make understanding feedback drive evidence-based improvement of explanation method, specification clarity, capability knowledge or retrieval. Support timely factual publication within existing authority, retain uncertain or unselected work in topic drafts, return to the original work and prove later explanations reuse the admitted material. Publish this implemented lifecycle knowledge in its owning capability; do not fill unrelated module knowledge bases.

**Outcome**

Make understanding feedback drive evidence-based improvement of explanation method, specification clarity, capability knowledge or retrieval. Support timely factual publication within existing authority, retain uncertain or unselected work in topic drafts, return to the original work and prove later explanations reuse the admitted material. Publish this implemented lifecycle knowledge in its owning capability; do not fill unrelated module knowledge bases.

**Files**

```diff
 .agents/skills/explaining-work/SKILL.md
 .agents/skills/explaining-work/references/method.md
+.agents/skills/explaining-work/references/improvement.md
 .agents/skills/harness/references/evolution.md
 .agents/skills/openspec/references/knowledge.md
 .agents/skills/openspec/references/specs.md
 .agents/skills/harness/tests/Protocol.Tests.ps1
 openspec/specs/harness/core/knowledges/harness-evolution.md
 openspec/specs/harness/core/knowledges/INDEX.md
+openspec/specs/harness/git/knowledges/lifecycle-checkpoints.md
 openspec/specs/harness/git/knowledges/INDEX.md
```

**Verification**

Run from D:/Workspace/AngelscriptProject using isolated PowerShell test processes.

```powershell
pwsh -NoProfile -File '.agents/skills/harness/tests/Protocol.Tests.ps1'
if ($LASTEXITCODE -ne 0) { throw 'Task verification failed' }
Import-Module ./.agents/skills/harness/scripts/Harness.psd1
$knowledgeContext = New-HarnessContext -WorkspaceRoot (Get-Location).Path
foreach ($capability in @('harness/core','harness/git')) {
    $knowledgeSpecCheck = Invoke-Harness -Command openspec.validate -Context $knowledgeContext -ArgumentList @($capability,'--type','spec','--strict','--json')
    if ($knowledgeSpecCheck.status -ne 'Succeeded') { throw 'Knowledge capability validation failed' }
}
```

All selected fixtures must execute and pass for the final owned content. Record exact commands and results; proposed commands above are not passing evidence.

**Notes**

Document/knowledge task: inspect evidence and current links, preserve archived originals, distinguish repair/regression admission from factual source/contract/example admission and avoid fabricated behavior RED. Retain independent consumer traces covering ordinary module confusion, a specific method gap, ambiguous confusion requiring Grill, unclear intended spec behavior, missing knowledge, existing knowledge not retrieved, conflicting evidence, authorized factual publication, missing authority and a later explanation reading the updated INDEX/entry. Assert the actual explanation, source reads, correct draft ownership, return point and absence of unrequested Skill/spec edits; no mandatory quiz or numerical reliability claim. The lifecycle-checkpoints article must explain the now-implemented planning/code/archive stages and partial recovery, cite this Change proof and complement existing delivery-authorities. Index each admitted file exactly once with summary, served capability, provenance and current status. Store and index the consumer/provenance audit in this Change attachments. Run strict harness/core and harness/git spec validation below; these checks do not by themselves prove factual explanation quality.

## [ ] 2.4 Align durable contracts and validate the integrated lifecycle

Apply the prepared core/Git deltas, update project entry/route guidance and release notice consistently, and retain final direct fixture/record evidence for the implemented content. Sync specifications only through the lifecycle; immutable historical archives stay unchanged.

**Outcome**

Apply the prepared core/Git deltas, update project entry/route guidance and release notice consistently, and retain final direct fixture/record evidence for the implemented content. Sync specifications only through the lifecycle; immutable historical archives stay unchanged.

**Files**

```diff
 AGENTS.md
 .agents/skills/README.md
 .agents/skills/harness/references/routing.md
 .agents/skills/harness/references/queries.md
 .agents/skills/harness/references/verification.md
 .agents/skills/harness/updates.json
 .agents/skills/harness/scripts/Test-Harness.ps1
 .agents/skills/harness/tests/Test-Harness.Tests.ps1
 .agents/skills/openspec/references/record-schema.md
 .agents/skills/openspec/SKILL.md
 openspec/specs/harness/core/spec.md
 openspec/specs/harness/git/spec.md
```

**Verification**

Run from D:/Workspace/AngelscriptProject using isolated PowerShell test processes.

```powershell
pwsh -NoProfile -File '.agents/skills/harness/tests/Protocol.Tests.ps1'
if ($LASTEXITCODE -ne 0) { throw 'Task verification failed' }
pwsh -NoProfile -File '.agents/skills/harness/tests/Test-Harness.Tests.ps1'
if ($LASTEXITCODE -ne 0) { throw 'Task verification failed' }
pwsh -NoProfile -File '.agents/skills/harness/tests/HarnessLifecycle.Tests.ps1'
if ($LASTEXITCODE -ne 0) { throw 'Task verification failed' }
Import-Module ./.agents/skills/harness/scripts/Harness.psd1
$proofContext = New-HarnessContext -WorkspaceRoot (Get-Location).Path
$recordCheck = Invoke-Harness -Command openspec.validate -Context $proofContext -ArgumentList @('harness/feature-lifecycle-git-closure','--type','change','--strict','--json')
if ($recordCheck.status -ne 'Succeeded') { throw 'Change validation failed' }
foreach ($capability in @('harness/core','harness/git')) {
    $specCheck = Invoke-Harness -Command openspec.validate -Context $proofContext -ArgumentList @($capability,'--type','spec','--strict','--json')
    if ($specCheck.status -ne 'Succeeded') { throw 'Specification validation failed' }
}
```

All selected fixtures must execute and pass for the final owned content. Record exact commands and results; proposed commands above are not passing evidence.

**Notes**

Register new isolated closure/lifecycle fixtures in the test inventory. Run strict validation of the active Change and affected core/Git specifications through Harness; baseline specs passed during preparation. Broaden only for newly demonstrated shared failures. No Unreal build, Automation or real-workspace Git fixture is justified by this scope.
