# Hardness Core

## Purpose

This capability defines how the AngelscriptProject Skill harness selects a workspace, dispatches project commands, maintains a resumable execution plan, and performs autonomous Review and Replan without crossing user authority boundaries.

## Requirements

### Requirement: Progressive skill routing

Hardness SHALL be the single short entry for the project Skill system and SHALL load only the selected leaf Skill or reference from a static route. Default context MUST NOT bulk-load command documentation, attachments, Replan history, or script implementations.

#### Scenario: Route one project command
- **WHEN** an agent requests a registered command in a session that imported Hardness
- **THEN** the system loads only that command's leaf module and returns the common structured result

#### Scenario: Exclude an unfinished leaf
- **WHEN** a project command leaf is intentionally deferred to a separate change
- **THEN** Hardness does not publish placeholder routes or report that leaf as installed until its complete contract is independently verified

### Requirement: Explicit workspace modes

The system MUST support Goal and Current modes. Goal uses an isolated Git worktree by default, while Current remains in the current checkout. Neither mode may automatically merge, push, or remove the workspace after completion.

#### Scenario: Start a Goal task
- **WHEN** native Goal mode starts a change that requires implementation
- **THEN** the system creates an isolated branch below the ignored worktree root, restores exact submodule gitlinks, and safely copies machine-local configuration

#### Scenario: Work directly
- **WHEN** the user explicitly requests work in the current checkout
- **THEN** the system does not create or switch worktrees and preserves existing uncommitted changes

### Requirement: Retained Hardness performance evidence

Hardness SHALL expose one PowerShell 7 performance-test profile that measures fresh-process and persistent-session harness paths independently. Every sample MUST also validate the invoked behavior. Each run MUST write a unique structured summary and raw sample table without overwriting or automatically deleting prior runs, while the change record retains a privacy-trimmed aggregate baseline and hashes of its raw source artifacts. Default TaskStatus sampling MUST use a hermetic temporary Task Graph that does not depend on an active project change; an explicit `-TaskChange` MAY select an active project record intentionally.

#### Scenario: Record a PowerShell 7 performance run
- **WHEN** the Performance profile runs in the supported PowerShell 7 host
- **THEN** it reports its warmup count, measured samples, min/median/p95/max, behavior result, and broad catastrophe-budget result in one unique Saved run directory

#### Scenario: Preserve comparable evidence without a flaky machine gate
- **WHEN** one accepted run is registered as the current baseline
- **THEN** raw machine-specific samples remain ignored local data, a trimmed aggregate is indexed under change attachments before archive, and a single prior-run regression ratio remains advisory until representative history establishes a portable threshold

#### Scenario: Run without an active project change
- **WHEN** the default Performance profile runs after every project change has been archived
- **THEN** TaskStatus measures the real Hardness/OpenSpec route against an isolated temporary Task Graph and removes that fixture after the run

### Requirement: Archive-stable closure gates

Reusable gates cited as closure evidence MUST use hermetic fixtures or stable repository inputs and MUST NOT require the subject record to remain under `openspec/changes/`. A default gate that needs a schedulable Task DAG MUST create a hermetic active fixture. An explicit `-TaskChange` MUST resolve the selected active record or fail without falling back to an archive. A historical protocol audit MAY bind an exact immutable archive path, but archived tasks MUST NOT become `task.status` scheduling input. After a deterministic archive move, the coordinator MUST run strict archived validation plus the smallest applicable non-destructive lifecycle gate that can expose active-path coupling. A newly exposed defect MUST use a follow-up change and MUST NOT rewrite the completed archive.

#### Scenario: Detect active-path coupling after archive
- **WHEN** an applicable gate fails only after its subject change moves to the archive
- **THEN** the archive remains immutable while a follow-up change records the failure, repair, review, and replacement evidence

#### Scenario: Retain accepted evidence before archive
- **WHEN** a performance run is accepted as closure evidence
- **THEN** its privacy-trimmed aggregate and raw-artifact hashes are indexed in the active change before the archive move

#### Scenario: Select an explicit active Task Graph
- **WHEN** a caller passes `-TaskChange` for a missing or archived record
- **THEN** the gate fails that explicit selection and does not silently substitute a fixture or historical Task DAG

#### Scenario: Audit immutable protocol history
- **WHEN** a reusable protocol test intentionally checks the completed dogfood Review/Replan history
- **THEN** it reads the exact immutable archive path without treating that record as current execution state

### Requirement: Hardness-recognized Task Graph

`tasks.md` MUST be the change's only current execution state and DAG. A current-format file MUST declare one versioned YAML-frontmatter `task_graph.depends_on` map whose quoted stable `X.Y` keys exactly match the top-level Markdown checkbox IDs. The Markdown body MUST retain each task's checkbox state, `Files:`, and exact verification command. A completed task MUST NOT return to incomplete, and an ID MUST NOT be reused or renumbered.

#### Scenario: Derive ready work through Hardness
- **WHEN** Hardness reads a current `tasks.md` and all `depends_on` predecessors of an incomplete task are complete
- **THEN** the task is Ready through the Hardness task route and may run in parallel only when its files, artifacts, and resource leases are also disjoint

#### Scenario: Keep presentation separate from execution
- **WHEN** Graph keys and Markdown task blocks are displayed
- **THEN** they use natural numeric task-ID order while dependency edges and Ready state derive only from `depends_on`

#### Scenario: Read historical task records
- **WHEN** validation or archive audit encounters an older `After:`-only task record without Task Graph frontmatter
- **THEN** it remains readable, while a file that mixes both dependency dialects fails validation

### Requirement: Two-tier exploration

Hardness MUST distinguish deep pre-creation discovery from task-local technical exploration. A new feature, architecture refactor, or major behavior change without an accepted decision-complete handoff MUST pass a read-only Explore Gate before its target OpenSpec Change is created. After target Change creation, that Change MUST NOT invoke deep Explore; existing truth changes through update/replan. A clear defect repair, mechanical documentation change, or approved ready-to-execute plan MAY skip the pre-creation gate. Technical uncertainty inside a Ready task MUST remain in the implementation leaf unless evidence invalidates current requirements, design, verification, dependency, or artifact truth.

For OpenSpec-scoped implementation, a decision-complete handoff MUST NOT substitute for an active Change. Hardness MUST resolve the canonical active Change and Ready Task DAG before implementation mutation in either Current or Goal mode.

#### Scenario: Shape a major change before planning
- **WHEN** a major behavior change has unresolved scope, architecture, or integration choices
- **THEN** deep exploration establishes evidence, viable options, a recommendation and flip condition, failures, verification, and an OpenSpec handoff with no blocking engineering decision left

#### Scenario: Begin implementation from an accepted handoff
- **WHEN** an OpenSpec-scoped objective has an accepted handoff but no canonical active Change and Ready task
- **THEN** Hardness creates and plans the Change before implementation mutation instead of treating the handoff as execution state

#### Scenario: Discover missing registration after work starts
- **WHEN** dogfooding finds implementation work that began before its required Change was registered
- **THEN** the coordinator preserves the working tree, records one material process issue, creates an honest recovery Change before commit, maps the existing diff, and reruns verification and review without fabricating prior compliance

#### Scenario: Investigate inside a Ready task
- **WHEN** implementation exposes an in-scope technical uncertainty without invalidating the accepted plan
- **THEN** Goal mode investigates and selects the evidence-backed repair inside that task without restarting deep Explore or interrupting the user

### Requirement: Exploration markers and durable carryover

Pre-Change exploration MAY use the project marker vocabulary and compact Markdown visualizations to make facts, decisions, risks, boundaries, and knowledge candidates easy to scan. Every marker MUST retain a plain-text label and MUST NOT be the sole machine-readable state. The decision-complete handoff MUST classify accepted carryover before Change planning. After the target Change is created, canonical truth MUST enter proposal/spec/design/tasks; non-obvious decisions and their useful visuals MUST enter indexed talks when their rationale prevents re-decision; reusable evidence-backed insights or reusable visuals MUST enter indexed change-local knowledge. Transient questions, navigation state, and the full exploration transcript MUST NOT be copied into the Change.

#### Scenario: Scan a question round without changing semantics
- **WHEN** interactive pre-Change exploration uses markers for a decision frontier
- **THEN** each marked line remains understandable without emoji and durable task/review/issue state continues to come from its canonical schema

#### Scenario: Carry accepted exploration into a new Change
- **WHEN** an accepted handoff contains a non-obvious decision and a reusable insight after the target Change is created
- **THEN** the decision and useful visualization are indexed in one talk, the reusable insight is indexed in change-local knowledge, and settled current truth is copied into the canonical planning artifacts

#### Scenario: Reject transcript accumulation
- **WHEN** exploration contains temporary held/reopened navigation, redundant prose, or a one-off visualization with no later decision or reuse value
- **THEN** the handoff discards it rather than creating a parallel exploration diary

### Requirement: Ready-to-execute Task authoring

Before a Task DAG is accepted, planning MUST map affected files, artifacts, and exclusive resources; divide work into the smallest independently reviewable outcomes; state exact or explicitly bounded paths, cross-task interfaces, and exact verification; and map every requirement and acceptance condition to at least one node. Task text MUST NOT defer unresolved design through placeholders. A plan-only delivery MUST be executable without another planning pass.

#### Scenario: Accept a plan-only delivery
- **WHEN** planning stops before implementation
- **THEN** a zero-context implementer can select each Ready node and determine its outcome, scope, inputs, outputs, files, execution steps, and proving verification directly from the accepted records

### Requirement: Material implementation issue history

`attachments/implementation/` MUST contain only material technical issue lifecycles. A problem is material when it blocks or repeats, needs non-obvious investigation, invalidates prior evidence, crosses a task/module/repository or changes approach, requires non-trivial Critical/Required review repair, needs a deferred handoff, or preserves a failed path likely to recur. Multiple symptoms with one root cause and repair MUST remain one issue. Routine TDD RED, first expected failures, immediate corrections, progress summaries, and ordinary final success MUST NOT create issues.

#### Scenario: Resolve an investigated root cause
- **WHEN** a material issue is resolved
- **THEN** one indexed issue records source and affected tasks, chronological investigation, demonstrated root cause, disposition, exact RED/GREEN evidence, rejected evidence when material, and what the evidence proves and does not prove

#### Scenario: Keep routine execution lightweight
- **WHEN** a first expected test failure is fixed directly by the planned implementation
- **THEN** evidence remains with the task and no implementation attachment is created

### Requirement: Evidence-gated replan

A Review finding MUST NOT directly trigger Replan. Hardness may apply a Replan only after evidence proves that a requirement, design, acceptance condition, task boundary, dependency edge, or completion record is invalid, and it MUST preserve a lightweight immutable semantic-diff record.

#### Scenario: Fix within the current plan
- **WHEN** a finding exposes only an implementation defect inside the current task
- **THEN** the system fixes it in that task or an implementation issue without creating a Replan

#### Scenario: Replace an invalid plan branch
- **WHEN** verified evidence invalidates part of the existing Task DAG
- **THEN** the system records old-task dispositions, preserves valid work, updates current artifacts/tasks, and creates one `status: applied` Replan file

### Requirement: Event-driven asynchronous Review and closure

Hardness MUST expose exactly three Review routes: Incident Review, Final Review, and External Review. Incident Review MUST start automatically only after evidence demonstrates a major security/trust, destructive data/history, public compatibility, cross-repository atomicity, or invalidated cross-boundary completion problem. Routine tasks, expected TDD failures, local repairs, documentation edits, and Advisory observations MUST NOT trigger Review. A completed Change with broad public, cross-boundary, security/destructive, compatibility/release, production-performance, or architectural impact MUST receive one approving Final Review after scope freeze against its current final snapshot. A verified small low-impact Change MUST instead record `Final Review: not required` with rationale and MUST NOT create a placeholder Review. Diff size alone MUST NOT determine impact. The user or another agent MAY start an External Review at any time; Hardness MUST register, reproduce, and triage it without treating the report or its severity as an automatic Replan.

Every new Review MUST use a unique Review file and immutable content reference. When a reviewer subagent is available, Hardness SHOULD dispatch it asynchronously and MAY continue disjoint main-thread work. Knowledge promotion, closure, archive, integration, and completion claims MUST wait for the applicable gate. If task-owned final scope changes after assignment, that result MUST NOT close the current Final Review; Hardness MUST absorb late changes and request one batched incremental Final Review after the next scope freeze. Review records MUST preserve actual assignment, completion, and closure times and MUST NOT impose a report line limit.

Before completed archive, broad-impact work MUST have one approving Final Review `closed` against the current final snapshot, while verified small low-impact work MUST record `Final Review: not required` with rationale. Every existing Review file MUST be `closed` or `superseded`; no Critical or Required finding may remain open or deferred; and every resolved finding MUST include resolution and evidence.

#### Scenario: Finish a small ordinary change
- **WHEN** routine tasks and expected local repairs complete without a demonstrated major incident
- **THEN** Hardness records `Final Review: not required` with low-impact rationale and closes from focused verification without creating a Review file

#### Scenario: Finish a broad-impact change
- **WHEN** completed scope crosses a public, multi-boundary, safety, compatibility, release, production-performance, or architectural impact boundary
- **THEN** Hardness starts one Final Review only after implementation, verification, accepted Replans, and queued user changes reach scope freeze

#### Scenario: Review a major incident asynchronously
- **WHEN** evidence demonstrates a qualifying major incident and an immutable review snapshot is available
- **THEN** Hardness assigns an Incident Review to a reviewer subagent while the main thread may continue disjoint work without crossing the affected gate

#### Scenario: Change reviewed scope while Final Review runs
- **WHEN** task-owned content changes after the Final Review snapshot was assigned
- **THEN** the returned report remains evidence for its immutable snapshot but cannot close the current final gate, and late changes are batched before one incremental Final Review

#### Scenario: Ingest an externally started review
- **WHEN** the user or another agent creates a unique External Review file
- **THEN** Hardness indexes it, binds or reproduces its snapshot and findings, and triages it at the nearest safe boundary without directly triggering Replan

#### Scenario: Preserve detailed Review evidence
- **WHEN** findings require extensive evidence, impact analysis, resolution conditions, or re-review history
- **THEN** the Review file retains the necessary detail without a line cap while avoiding redundant verification already supplied with the snapshot

### Requirement: Deterministic OpenSpec package

The distributed OpenSpec executable MUST be located at `.agents/skills/openspec/bin/openspec.exe` and MUST be reproducible from the parent-recorded `Tools/openspec` commit, immutable 0.8.1 tag layered after preserved 0.8.0 and 0.7.4 snapshots, locked build commands, byte-identical isolated rebuild gate, and release manifest. Existing candidate tags MUST NOT be moved to impersonate a repaired snapshot. The parent repository MUST commit only the final accepted package once per release and MUST NOT commit intermediate or candidate executable builds.

#### Scenario: Validate a packaged release
- **WHEN** installation health checks validate the OpenSpec package
- **THEN** the executable version, SHA-256, source commit, annotated tag object/target, command-document set, release gates, and manifest agree

#### Scenario: Preserve parent binary history
- **WHEN** an OpenSpec release is iterated before final acceptance
- **THEN** candidate executables remain outside parent history and the final accepted package enters the parent repository in exactly one release commit

### Requirement: English OpenSpec maintenance surface

All maintained OpenSpec source documentation, Skills, command references, project workflows/templates, manifests, current specs, active changes, attachments, and new archive records MUST use English. Files explicitly named with `_ZH` MAY remain temporarily and MUST be the only localization exception.

#### Scenario: Reject a non-English maintained record
- **WHEN** package validation scans an ordinary maintained OpenSpec path or supported text file containing a Han character
- **THEN** validation fails and reports the exact relative file and line

#### Scenario: Preserve an explicit localization file
- **WHEN** the same scan encounters a file whose name contains `_ZH`
- **THEN** that file is excluded without exempting sibling files or parent directories

### Requirement: Harness dogfooding feedback

Hardness SHALL support self-hosted evolution in which Hardness and OpenSpec changes are executed through the same harness being developed. Every discovered problem MUST be classified from evidence before it changes durable policy: a local implementation defect remains in the current task or an implementation issue, an invalid planning boundary creates Replan, and a recurring reusable invariant may be promoted to capability knowledge.

#### Scenario: Dogfooding exposes a local defect
- **WHEN** a self-hosted run finds behavior that violates an existing requirement without invalidating the plan
- **THEN** the coordinator records reproducible evidence, adds a regression test, repairs the current task, and does not create Replan

#### Scenario: Dogfooding invalidates the plan
- **WHEN** self-hosted evidence proves that a requirement, acceptance contract, task boundary, or dependency edge is false
- **THEN** the coordinator applies the Replan protocol, preserves valid work, and resumes without asking the user for an in-scope technical decision

### Requirement: Progressive harness knowledge promotion

Reusable harness knowledge MUST be loaded progressively and promoted explicitly. Change attachments own current evidence; capability-side `knowledges/` owns stable reusable guidance; project instructions own only cross-capability invariants. Every capability knowledge directory MUST have one `INDEX.md` that links every knowledge file exactly once with summary, served requirement/capability, source, and status. Archive MUST NOT promote knowledge implicitly.

#### Scenario: Promote a stable learning
- **WHEN** a finding is evidence-backed, remains valid after repair and re-review, applies beyond one task, and changes future agent decisions
- **THEN** closure copies a concise generalized record into the Hardness capability knowledge and indexes it without copying transient logs, hashes, or incident chronology

#### Scenario: Retain one-off evidence locally
- **WHEN** an observation is specific to one failure, machine, snapshot, or temporary workaround
- **THEN** it remains in the change Review/implementation/data attachment and is not loaded as durable harness knowledge

#### Scenario: Load capability knowledge progressively
- **WHEN** a later task needs reusable guidance from a capability
- **THEN** it reads that capability's knowledge INDEX and loads only the linked current file needed by the task

### Requirement: Reusable PowerShell entry

Hardness SHALL require PowerShell 7.0 or later with the Core edition and SHALL support repeated Workspace and OpenSpec invocations in one supported session without polluting the caller environment. Windows PowerShell 5.1 is not a supported harness host. Every invocation SHALL return an independent run ID and the common result envelope.

#### Scenario: Reuse one PowerShell 7 session
- **WHEN** Hardness invokes Workspace or OpenSpec commands repeatedly in one supported PowerShell 7 session
- **THEN** modules remain reusable, the caller location is restored, and each invocation returns an independent run ID and result

#### Scenario: List the gate matrix
- **WHEN** a caller lists Quick, Performance, or Integration checks
- **THEN** every script and performance check launches `pwsh.exe`, every host-qualified result is labeled `PS7`, and no PS5 or multi-host selector is exposed

### Requirement: Autonomous Goal execution within authority

Goal mode SHALL autonomously investigate, choose in-scope technical solutions, replan, implement, verify, and re-review without interrupting the user for ordinary technical choices or Review findings. It MUST stop when progress requires new authority, risks destructive user-data changes, requires merge/push/publication without authorization, lacks external credentials, or faces irreconcilable explicit instructions.

#### Scenario: Reviewer finds a required defect
- **WHEN** a Required finding can be resolved within the existing goal and authority
- **THEN** Hardness completes triage, repair, verification, and re-review without requesting an ordinary technical decision

### Requirement: Ready-to-integrate finish state

A successful Goal MUST reach committed, verified, reviewed, and ready-to-integrate while preserving its branch and worktree for inspection. Integration MAY occur only as a later explicitly authorized action.

#### Scenario: Finish a successful Goal
- **WHEN** all tasks, verification, and Review Gates are closed
- **THEN** the system reports commits, evidence, non-gating tests not run, and integration commands without automatically merging, pushing, or removing the worktree

#### Scenario: Integrate after explicit authorization
- **WHEN** the user explicitly requests integration after all gates pass
- **THEN** the coordinator first audits overlap with the primary checkout, preserves its unrelated dirty changes, and then applies only the reviewed commits without pushing
