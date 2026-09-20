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

- The accepted candidate is preserved under attachments/drafts; task checkboxes and Evidence below record actual implementation, not planning predictions.
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

## [x] 1.1 Bind exact Git candidates to previewed content

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

**Evidence**

- Grouped behavioral RED observed with `pwsh -NoProfile -File .agents/skills/git-operations/tests/GitOperations.Tests.ps1`: selected-byte drift committed without rejection, mixed-file selection committed the unrelated b edit, and an in-scope hook rewrite was accepted. Added only the new parameter/output skeleton before observing these real behavior failures.
- GREEN: the same full direct GitOperations fixture passed; `pwsh -NoProfile -File .agents/skills/git-operations/tests/PluginCommits.Tests.ps1` also passed. Existing outside-index, hook, detached-branch, multi-repository partial-success and integration controls remained exercised. The mixed-file case proves HEAD contains a=1/b=0, the staged file retains a=1/b=2 and outside staged content and live bytes survive.
- Preview binds baseline, branch, selected live/index/candidate content, explicit patch and commit intent. Derived parent gitlinks follow approved plugin results. Exact candidates reject hook byte changes; legacy authorized calls keep their hook behavior.
- An initial GREEN attempt exposed preview environment cleanup respecting WhatIf and leaking GIT_INDEX_FILE; corrected cleanup and added an environment-restoration assertion. Final full fixture passed after this correction.
- Naming assumed: Get-GitCommitCandidate and Assert-GitAcceptedCandidateTree are private helpers following the module's existing Get/Assert-Git naming convention. No new exported command was introduced.

## [x] 1.2 Create and save complete planning candidates

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

**Evidence**

- RED observed in the direct creation fixture: incomplete candidates were admitted, candidate drift reused the old Gate, and accepted planning was not committed. The initial persistence fixture had missing task-card paragraph separators; after correcting the fixture, replayed the actual HEAD creation engine in a bounded isolated PowerShell process with only new parameter skeletons. The valid-input replay again failed all five grouped behaviors (invalid plan, persistence, stale content, missing complete candidates, and hook failure). No production file was reverted or fake RED injected.
- Additional RED: after a real hook rejected the planning commit, an early completed arrangement made status permit execution. Planning recovery now independently blocks execution until its exact commit completes.
- GREEN: `pwsh -NoProfile -File .agents/skills/harness/tests/HarnessChangeGate.Tests.ps1` and `pwsh -NoProfile -File .agents/skills/harness/tests/HarnessHandoff.Tests.ps1` passed. The real fixture proves read-only preflight, strict TaskPlan checks, committed complete planning, stale Gate rejection, mandatory complete new-Change input, unchanged UID on retry, normal hook enforcement and conflict rejection for changed generated records.
- Historical fixtures explicitly construct the retained pre-complete-plan engine through a test-only helper; public new creation has no legacy bypass. Persisted historical intents/records remain resumable. Adjacent queue/workflow test setup now identifies those historical fixtures explicitly; their later verification belongs to tasks 1.3/1.6/2.4.
- Additional boundary proof during integrated protocol inspection: `HarnessChangeGate.Tests.ps1 -LinkPreflightOnly` first observed a missing local design evidence link pass the read-only preview. The owning preflight now validates the same design/export link boundary as post-create seed/plan verification and stages accepted binary exports in its isolated area. That focused RED became GREEN, and the full `HarnessChangeGate.Tests.ps1` passed with both the invalid-link case and a valid selected-spec link. This prevents an invalid accepted dependency from first surfacing after canonical creation.
- Naming assumed: Complete-HarnessCreatedPlan, planning_commit_status and HistoricalChangeFixture follow owning module/test conventions. Recovery state is ignored operational state, separate from feedback drafts; a fresh checkout can recognize a Git-persisted origin without inventing a new Gate.

## [x] 1.3 Commit accepted Replan records without checkpointing implementation

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

**Evidence**

- RED: the real public workflow fixture accepted the Replan but `HEAD:openspec/changes/<fixture>/tasks.md` did not contain its accepted new task. This was observed after adding only the forwarded GitPlan parameter, before implementing persistence.
- GREEN: `pwsh -NoProfile -File .agents/skills/harness/tests/HarnessWorkflow.Tests.ps1` passed, including its 12 discussion, 14 Replan and 35 execution unit cases and the real portable-CLI/Git integration. Also passed the task's `HarnessHandoff.Tests.ps1` and direct `python -X utf8 -m unittest discover -s .agents/skills/harness/tests -p test_replans.py` selection.
- Public integration proves complete candidate preflight, mandatory Git intent, stale commit-intent rejection, normal pre-commit rejection, visible commit-pending blocking, unchanged immutable applied receipt on recovery, exact commit deduplication, preservation of outside staged content, and unfinished implementation remaining outside HEAD. The original follow-up arrangement still controls execution.
- The retained historical transaction engine is exercised separately by the Python fixtures. New public Replan requires GitPlan; an existing historical applied record can still recover its own accepted request. A supplied replacement decision source cannot overwrite a consumed Gate.
- Naming assumed: planning_git.py and PlanningGit.psm1 separate canonical state/validation from same-process PowerShell Git execution. validate_candidate is shared by preview and application. No child PowerShell worker or implementation checkpoint was added.

## [x] 1.4 Gate completed closure and persist all owned results

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

**Evidence**

- RED: `HarnessMutationGate.Tests.ps1` showed a valid terminal evaluation could still archive without a close decision. The new public closure fixture also observed its stale-candidate requirement fail against the route/function skeleton before implementation.
- GREEN: `pwsh -NoProfile -File .agents/skills/harness/tests/HarnessClosure.Tests.ps1`, `HarnessMutationGate.Tests.ps1` and `HarnessEvolution.Tests.ps1` passed. The real closure fixture uses complete Create, its actual fixture arrangement, a queue binding, a real plugin repository/worktree, normal hooks, native archive and strict archived validation.
- The fixture proves read-only preview; selected-byte drift rejected before any plugin/ref/archive mutation; plugin commit before terminal evidence; canonical hook failure reported after archive; read-only archived/commit-pending recovery; unchanged archive and earlier plugin commit on retry; parent and plugin outside staged sentinels retained; final exact parent commit and selected gitlink; and deduplicated successful retry.
- A second exact fixture runs in a real minimal replica. Its editable plugin commits in the replica, canonical records commit in the primary, the replica root has no fabricated parent repository, and the primary plugin branch/gitlink remain unchanged without integration authority.
- Recovery journals bind source content, actual Gate and canonical/execution roots. Generated receipt/index/evaluation writes retain before/after bytes and reject external changes. The final Git tree derives only from the accepted parent candidate plus the native archive and explicitly selected resulting gitlinks; no self-referential final commit SHA is written into the archive.
- The portable CLI only supports aggregate `validate --archived --strict --json`, not an exact ID with --archived. Closure consumes exactly one matching per-item result and records the aggregate run ID and other-invalid count. A read-only live probe found unrelated historical-format failures; no historical archive was edited and no all-archive pass is claimed.
- Naming assumed: GitPlan has Implementation and Records groups using the existing exact Git arguments; Dispositions carries Closure, SpecSync and Verification. LifecycleFixture.ps1 is an isolated test helper. These are internal shapes under the proposed public close route, not new user Gates.

## [x] 1.5 Preserve and withdraw incomplete implementations honestly

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

**Evidence**

- RED: the valid abandoned case in `HarnessIncompleteClosure.Tests.ps1` failed because incomplete closure was unsupported. Its malformed withdrawal control did not mutate refs or files; after implementation it is rejected by actual patch preflight.
- GREEN: `pwsh -NoProfile -File .agents/skills/harness/tests/HarnessIncompleteClosure.Tests.ps1 -Scenario Abandoned` and the corresponding `-Scenario Superseded` both passed. The latter saves both components, rejects the withdrawal with a normal hook, retries without another checkpoint, retains exactly the replacement's accepted component and withdraws only the rejected component. Both retain unrelated staging and true unfinished task states. An earlier combined run passed abandoned checks then exposed an incorrect replacement query route; the corrected route was exercised by the passing superseded selection.
- GREEN: the declared `HarnessClosure.Tests.ps1` and `GitOperations.Tests.ps1` commands passed after the incomplete-stage implementation. Existing completed/replica behavior and exact mixed-hunk/hook controls remain proved.
- `python -X utf8 -m unittest discover -s .agents/skills/harness/tests -p test_closure_withdrawal.py` passed 2 direct real-Git cases for same-file retained/rejected/unrelated hunks and binary/add/delete preservation. Preview preserves HEAD, live bytes and the live index. The withdrawal compiler uses an isolated index and file copies; runtime only applies journalled before/after images and rejects external conflicts. No blanket restore/reset is used.
- A fixture assertion originally assumed LF working files; a minimal reproduction proved normal Git autocrlf produces CRLF after patch application while the Git blob is correct. The assertion now normalizes line endings only; binary checks remain byte-exact.
- Naming assumed: `closure_withdrawal.py`, `New-ClosureWithdrawals`, `Complete-ClosureWithdrawal` and `GitPlan.Withdrawal` follow the owning close operation. `WithdrawalVerification` names the baseline and evidence; an explicit carryover patch proves the retained result. Final canonical content derives from the known checkpoint/withdrawal HEAD plus the originally approved record patch, preserving carryover. Queue interpretation is deliberately left to task 1.6.

## [x] 1.6 Resume queue execution from the full close outcome

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

**Evidence**

- RED: direct `test_change_queue.py` cases observed an uncommitted new archive and a corrupt close receipt both incorrectly reported archive-pending. `test_execution.py` observed the same pending final commit incorrectly become advancing. The tests asserted real queue file immutability as well as derived eligibility.
- GREEN: `python -X utf8 -m unittest discover -s .agents/skills/harness/tests -p test_change_queue.py` (25 cases), corresponding `test_execution.py` (36 cases), and `pwsh -NoProfile -File .agents/skills/harness/tests/HarnessQueue.Tests.ps1` passed. Existing authorization-prefix, takeover, source, pause, historical archive and replica boundaries remain covered.
- GREEN: `pwsh -NoProfile -File .agents/skills/harness/tests/HarnessLifecycle.Tests.ps1` passed. Its real isolated sequence includes complete Create, an actual fixture Replan/arrangement, completed multi-repository close with hook failure after archive, exact retry, a minimal replica, separate abandoned parent/plugin close, superseded carryover and withdrawal, and truthful queue advancement. No stage tests against this live Change or changes the real queue. An initial integration setup omitted the required tasks.md baseline hash; that fixture was corrected before the passing run.
- The integrated fixture proves close-pending blocks advance and additional implementation, the final canonical commit unlocks advancement, committed archives remain recognizable without ignored machine-local recovery state, abandoned/superseded outcomes stay labelled as such, and a replacement is not auto-authorized. The queue also checks actual Git archive blobs using normal attribute/line-ending normalization rather than trusting a moved directory or journal label alone.
- Prerequisite repair: real `HarnessQueue.Tests.ps1` previously failed when successful empty `ue.process.list` yielded a null entry under StrictMode. The bounded null guard is now exercised alongside active/uninspectable-process takeover denial. Actual earlier queue takeover/registration used the user's explicit stopped-session decision, not a fabricated token-only authorization.
- Naming assumed: `closure_status.py` owns read-only close persistence evidence; `close-pending` and execution phase `closing` distinguish recoverable closure from archive-pending advancement. Administrative exhaustion of the authorized range does not turn an abandoned objective into completed work.

## [x] 2.1 Capture upgrade feedback in topic drafts only

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

**Evidence**

- RED: `pwsh -NoProfile -File .agents/skills/harness/tests/HarnessFeedback.Tests.ps1` failed the new observable requirement that public capture's returned artifact belongs to its ignored topic draft instead of Saved.
- GREEN: the same direct feedback fixture and `pwsh -NoProfile -File .agents/skills/harness/tests/HarnessDraft.Tests.ps1` passed. Cases cover recurrence in the same owner, actual source retention, selected-scope/evidence requirements, read-only queries, unresolved recurrence after resolution, no formal Change/queue creation, no parallel ledger, historical read compatibility and malformed-data rejection.
- Capture uses existing topic README/CONTEXT/design scopes. Canonical record roots and safe/reparse-free paths are enforced; per-design writes serialize through a named mutex and triage rejects changed observation blocks. Uncertain causes remain sourced questions.
- Historical observations and archived draft findings remain readable and unchanged. Further work must select an active topic with actual provenance; the new triage no longer writes historical Saved decision ledgers.
- The performance probe was updated to assert a single owning draft artifact in its isolated fixture with draft ignore rules. Full performance measurement was not selected: this task proves storage/authority correctness with direct fixtures and makes no latency claim.
- Naming assumed: Add-HarnessDraftFeedback plus private Get/Assert/ConvertTo/Enter-HarnessFeedback helpers follow the owning module's verb-prefix convention. The public route remains harness.observe with the proposed OwnerScope addition.

## [x] 2.2 Make the active discussion and three explanations explicit

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

**Evidence**

- `pwsh -NoProfile -File .agents/skills/harness/tests/Protocol.Tests.ps1 -ActiveChange harness/feature-lifecycle-git-closure` passed after the focused lifecycle/explanation link updates. Default Protocol still reports four pre-existing missing-proof fields in the unrelated builder-source issue; an isolated HEAD-script replay reproduced them. The selector narrows only active-issue ownership, not structural or historical checks. No global pass is claimed.
- Indexed `data/lifecycle-consumer-audit.md`, before/after discussion traces and the Gate trace retain actual simulated submissions and source decisions. Both matched four-turn discussion arms continued and paused correctly, so the historical premature stop did not reproduce. Post-edit branches covered Create/Replan/Close explanation, pending/cancelled/invisible forms, preselected options, approval-prohibited/unavailable host selection and an exhausted open frontier.
- Evidence establishes those bounded consumer responses and structural discoverability, not real UI rendering, user comprehension or measured prompt reliability. Feedback-only source ownership and knowledge reuse continue in 2.3.
- The owning Replan reference was aligned with the same mandatory GitPlan/persistence contract to avoid an adjacent stale instruction. Existing illustrative explanation methods remain available.

## [x] 2.3 Improve explanations and enrich owning capability knowledge

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

**Evidence**

- `Protocol.Tests.ps1 -ActiveChange harness/feature-lifecycle-git-closure` passed. Owning core/git specifications passed strict validation before and after semantic sync. The focused OpenSpecSkill surface audit passed for the changed lifecycle/Brainstorming/explaining-work guidance and both capability directories, including unique knowledge indexes and links.
- Indexed consumer audit/raw traces retain a current-source two-turn explanation and seven independent synthetic branches plus an actual later reuse round. The current-source consumer read and applied the published lifecycle knowledge before explaining; feedback stayed in one topic. The synthetic consumer actually submitted ambiguity/intent questions, published one authorized factual article/INDEX, retained unselected/conflicting questions, avoided duplicate knowledge, and later reread/applied that article. These are bounded observations, not a reliability or UI-render claim.
- Updated explaining-work method/improvement routing and split knowledge admission by factual versus repair-derived claim. Published git/lifecycle-checkpoints.md and updated core/harness-evolution.md with source/contract/proof boundaries and INDEX provenance. No independent harness-update Skill, invented behavior RED or historical-archive edit was added.
- Full OpenSpecSkill authoring audit remains non-green on original-language provenance, including 24 lines in this Change's unchanged HEAD origin and unrelated historical active material. Actual user/export provenance is preserved. Its bounded policy question is captured through the real harness.observe route in ignored harness/lifecycle-validation-feedback, scope source-evidence-language; no repair or formal successor is selected. Raw consumer source is text/JSON evidence, while maintained planning/audit remains English.

## [x] 2.4 Align durable contracts and validate the integrated lifecycle

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

**Evidence**

- Final `HarnessLifecycle.Tests.ps1` passed on implemented source: complete Create/Replan and real primary/plugin/replica closure, abandoned/superseded withdrawal/carryover, parent-hook interruption, preserved unrelated staging and fully persisted queue advancement. Its two Python withdrawal cases passed. Earlier task-specific unit/route proofs remain recorded above; no broad UE run was justified.
- `Harness.Tests.ps1`, `HarnessMutationGate.Tests.ps1`, `HarnessEvolution.Tests.ps1` and `Test-Harness.Tests.ps1` all passed. The main dispatcher fixture was aligned with source-required topic capture and initialized native records before draft creation after a bounded reproduction established the init-order rejection. Inventory now exposes all three new closure/lifecycle scripts; its minimal performance correctness samples do not establish latency.
- Targeted Protocol and supported OpenSpecSkill SurfacePaths audits passed. Two legacy literal phrases were preserved in the revised factual/repair admission text without changing its meaning. Full repository audits retain the disclosed unrelated issue/original-language provenance boundaries; neither is relabelled green.
- Core/git spec baselines and merged targets passed strict validation. Semantic merge retained unspecified cards and explicitly replaced old feedback/primary-stage clauses plus qualified legacy hook formatting to match already approved behavior. `data/spec-sync-audit.json` retains identities and baseline digests; original accepted exports remain immutable.
- Seed/plan checks and strict owning Change validation passed. `data/final-verification.md`, consumer evidence and `data/final-source-manifest.json` identify actual proof, scope and limitations. The update notice publishes this bounded implemented workflow. Final local commit/archive is a separate actual presented close decision, still pending; task completion is not that approval.
