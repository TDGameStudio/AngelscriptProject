# Hardness Core

## Purpose

This capability defines how the AngelscriptProject Skill harness selects a workspace, dispatches project commands, maintains a resumable execution plan, handles explicit Review input, and replans autonomously without crossing user authority boundaries.

## Requirements

### Requirement: Progressive skill routing

Hardness SHALL remain the single short entry for project workflow and SHALL load only the selected leaf module or focused reference. Workspace lifecycle, Git mutation, OpenSpec primitives, task status, Hardness observation, and Unreal development SHALL retain separate routes and authority boundaries. Default context MUST NOT bulk-load command documentation, attachments, historical observations, Replans, or leaf implementations.

#### Scenario: Route one project command
- **WHEN** a caller requests one installed Hardness command
- **THEN** the dispatcher loads only the owning leaf, returns the common result envelope, and does not acquire unrelated workflow authority

#### Scenario: Route an Unreal operation
- **WHEN** a caller requests a verified `ue.*` route
- **THEN** Hardness supplies the exact WorkspaceRoot context to the Unreal leaf and the leaf enforces its own engine/process authority

### Requirement: Unified workspace context

Hardness MUST use one Git-derived workspace model in both the primary checkout and any registered linked worktree. Codex `/goal` is an external continuation facility only and MUST NOT select a repository mode, imply worktree creation, constrain branch names, or change Git authority. New worktrees default to `.worktrees/<name>` on branch `<name>`, while existing registered worktrees remain valid at their current path and branch. Integration, non-force push, and worktree removal MUST remain three separate operations requiring explicit user intent.

#### Scenario: Work in the primary checkout
- **WHEN** the caller selects the registered primary checkout
- **THEN** Hardness targets that exact root without creating, switching, or assigning a repository mode and preserves unrelated local changes

#### Scenario: Work in an existing linked worktree
- **WHEN** the caller selects any worktree registered in the same Git common directory
- **THEN** Hardness accepts its actual path and branch without requiring `.worktrees/<name>` or a branch prefix

#### Scenario: Interpret Codex Goal continuation
- **WHEN** work is running under Codex `/goal`
- **THEN** repository selection still comes from the explicit or discoverable WorkspaceRoot and no repository-mode state is created

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

Hardness MUST distinguish deep pre-creation discovery from task-local technical exploration. Before a new feature, architecture refactor, or major behavior-change Change is created, unresolved scope, architecture, or integration choices MUST trigger the read-only Explore Gate. A decision-complete handoff or an already explicit approved plan MAY proceed directly to Change creation. After target Change creation, deep Explore MUST NOT restart; task-local uncertainty stays in Apply unless evidence invalidates canonical planning truth and triggers update/replan. A request to explain architecture, workflow, state, ownership, or three or more related branches SHOULD invoke `visual-explain`; routine one-step work and already-clear prose MUST NOT incur that cost.

#### Scenario: Shape a major change before planning
- **WHEN** a major change still contains blocking design choices before registration
- **THEN** `openspec-explore` produces a decision-complete handoff before the target Change is created

#### Scenario: Continue from an explicit accepted plan
- **WHEN** scope, boundaries, and verification are already decision-complete
- **THEN** Hardness creates or updates the canonical Change without repeating deep exploration

#### Scenario: Explain a multi-branch workflow
- **WHEN** the user needs to understand a workflow with multiple states, branches, or owners
- **THEN** Hardness routes a small useful visualization and keeps the underlying canonical state in plain text

### Requirement: Exploration markers and durable carryover

Pre-Change exploration MAY use the project marker vocabulary and compact Markdown visualizations to make facts, decisions, risks, boundaries, and knowledge candidates easy to scan. Every marker MUST retain a plain-text label and MUST NOT be the sole machine-readable state. The decision-complete handoff MUST classify accepted carryover before Change planning. After the target Change is created, canonical truth MUST enter proposal/spec/design/tasks; non-obvious decisions and their useful visuals MUST enter indexed talks when their rationale prevents re-decision; reusable evidence-backed insights or reusable visuals MUST enter indexed change-local knowledge.

When an extended user-led exploration establishes multiple interacting cross-capability constraints, meaningful corrections, rejected interpretations, or non-obvious rationale that canonical artifacts would flatten and future agents would otherwise re-decide, planning MUST preserve one selective indexed intent talk. The talk MUST retain provenance, capture date, source limits, architecture-changing corrections, exclusions, and canonical mappings. It MUST NOT impersonate an earlier record when reconstructed later. Clear defects, mechanical documentation changes, one-step requests, routine task-local choices, and decisions fully represented by canonical artifacts MUST NOT create a required talk or a not-required placeholder. Transient questions, navigation state, task state, progress evidence, and the full exploration transcript MUST NOT be copied into the Change.

#### Scenario: Scan a question round without changing semantics
- **WHEN** interactive pre-Change exploration uses markers for a decision frontier
- **THEN** each marked line remains understandable without emoji and durable task/review/issue state continues to come from its canonical schema

#### Scenario: Carry accepted exploration into a new Change
- **WHEN** an accepted handoff contains a non-obvious decision and a reusable insight after the target Change is created
- **THEN** the decision and useful visualization are indexed in one talk, the reusable insight is indexed in change-local knowledge, and settled current truth is copied into the canonical planning artifacts

#### Scenario: Preserve a major user-intent baseline
- **WHEN** a major user-led refactor is shaped by several interacting goals, corrections, exclusions, or rejected interpretations whose rationale would otherwise be lost
- **THEN** planning indexes one concise intent talk with exact provenance and canonical mappings while proposal/spec/design/tasks retain current truth

#### Scenario: Keep routine work free of intent boilerplate
- **WHEN** a Change is a clear defect, mechanical edit, one-step request, or contains no rationale beyond its canonical artifacts
- **THEN** no intent talk or not-required placeholder is created and closure does not infer one from conversation or diff size

#### Scenario: Repair missing historical carryover honestly
- **WHEN** later evidence shows that required user rationale was never recorded before a source Change was archived
- **THEN** a suitable active Change records a clearly dated reconstruction and does not edit the immutable archive or claim contemporaneous provenance

#### Scenario: Reject transcript accumulation
- **WHEN** exploration contains temporary held/reopened navigation, redundant prose, progress state, or a one-off visualization with no later decision or reuse value
- **THEN** the handoff discards it rather than creating a parallel exploration diary

### Requirement: Ready-to-execute Task authoring

Before a Task DAG is accepted, planning MUST map affected files, artifacts, and exclusive resources; divide work into independently reviewable outcomes; state exact or explicitly bounded paths, cross-task interfaces, and exact verification; and map every requirement and acceptance condition to at least one node. Each task card MAY add concise free-form detail such as Context, Constraints, Inputs, Produces, Watch, Notes, or Evidence when it materially helps execution, but those labels are optional prose rather than a fixed schema. Only the existing DAG frontmatter, checkbox ID, `Files:`, and verify text remain machine-readable, and this Change MUST NOT modify the OpenSpec parser or executable for task-card enrichment.

#### Scenario: Execute a detailed task card
- **WHEN** a node needs local constraints, inputs, or known hazards beyond its outcome and paths
- **THEN** the card includes only the useful prose needed by a zero-context implementer and OpenSpec derives the same task ID, dependencies, files, verification, and Ready state

#### Scenario: Keep a simple task card small
- **WHEN** outcome, files, and verification already make a node executable
- **THEN** the card omits optional labels instead of adding empty or boilerplate sections

### Requirement: Material implementation issue history

`attachments/implementation/` MUST contain only material technical issue lifecycles. A problem is material when it blocks or repeats, needs non-obvious investigation, invalidates prior evidence, crosses a task/module/repository, changes approach, requires non-trivial Critical/Required Review repair, needs a durable handoff, preserves a failed path likely to recur, forces a manual bypass of a maintained Hardness route, or is explicitly admitted by the user as a Harness self-evolution problem. Multiple symptoms with one root cause and repair MUST remain one issue. Routine TDD RED, first expected failures, immediate corrections, transient timing variation, unverified preferences, progress summaries, and ordinary final success MUST NOT create issues.

New issues MUST use `issue_schema: openspec-material-issue-v2` with an exact issue ID, `open | resolved | rejected | superseded` status, source evidence, affected Task IDs, and creation time. They MUST retain the detailed Symptom, Investigation Log, Root Cause, Disposition, RED/GREEN evidence with proof limits, and Links body. Open issues MUST omit terminal fields. Resolved or rejected issues MUST provide resolution time and evidence reference. Superseded issues MUST provide resolution time and an exact `hardness/<change>#issue-<id>` reference to an existing v2 issue. Historical issue records without `issue_schema` remain readable legacy v1 records and MUST NOT be rewritten.

#### Scenario: Resolve an investigated root cause
- **WHEN** a material issue is resolved
- **THEN** one indexed v2 issue records source and affected tasks, chronological investigation, demonstrated root cause, disposition, exact RED/GREEN evidence, rejected evidence when material, and what the evidence proves and does not prove

#### Scenario: Reject or supersede work explicitly
- **WHEN** an admitted issue will not be repaired in its owning Change
- **THEN** it becomes rejected with evidence or superseded by an exact existing v2 issue rather than being deferred in prose

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

### Requirement: Explicit Review intake and direct closure

Hardness MUST NOT start Incident Review, Final Review, or any other Review automatically from impact, diff size, task count, a local defect, or a verification result. When no Review has been explicitly requested, verified work MAY proceed directly to completed closure and archive after tasks, durable-spec sync, attachments, and evidence are ready; it MUST NOT create a placeholder Review or a not-required Review disposition. A problem found during implementation or verification SHALL be diagnosed and repaired inside the current task when planning truth remains valid, or SHALL trigger the evidence-gated replan path when requirements, design, verification, artifacts, or Task DAG truth became invalid.

The user or an external agent MAY explicitly request a fixed-snapshot Review. Hardness SHALL register that Review with a unique file and materializable immutable content reference, reproduce and triage its findings, and MAY run the assigned reviewer asynchronously when useful; asynchronous execution is optional and does not become the default lifecycle. A finding never directly triggers replan. Before completed archive, every explicitly registered Review file MUST be `closed` or `superseded`, no Critical or Required finding may remain open or deferred, and resolutions MUST retain evidence. Review records MUST preserve actual lifecycle times, concrete findings, and detailed resolution history without a report line limit.

#### Scenario: Archive verified work without Review
- **WHEN** every task and required verification passes, durable truth is synchronized, closure evidence is ready, and no Review was explicitly requested
- **THEN** Hardness prepares completed closure and archives directly without creating a Review record or impact classification ceremony

#### Scenario: Replan a discovered planning failure
- **WHEN** implementation or verification evidence invalidates a requirement, design boundary, verification contract, required artifact, or Task DAG edge
- **THEN** Hardness applies the replan protocol, preserves valid work, repairs the new plan, and verifies again without starting Review automatically

#### Scenario: Process an explicitly requested Review
- **WHEN** the user or an external agent requests Review of an exact snapshot
- **THEN** Hardness registers and triages the Review, optionally delegates it asynchronously, and blocks archive only until that explicit Review is resolved or superseded

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

Hardness SHALL expose cheap visible feedback during self-hosted evolution. `hardness.status` MUST report installation and selected-workspace identity without a detailed repository scan. `hardness.observe` MUST append a versioned, timestamped raw observation or lifecycle span under ignored `Saved/Hardness/` data without changing tracked workflow truth; raw observations remain non-blocking until explicitly admitted. A material dogfooding discovery MUST NOT remain only in conversation, a final handoff, or ignored data. It MUST enter the existing v2 material implementation-issue lifecycle in one exact suitable active Change before affected implementation continues or final handoff completes. If no suitable active owner exists after the source Change archived, a successor Change and issue MUST be created without modifying the archive.

Whether evidence crosses the material threshold remains a bounded agent/user judgment. Once admitted, every v2 issue MUST appear exactly once in the owning attachment index and remain open until it is resolved with evidence, rejected with evidence, or superseded by an exact existing v2 issue. Open or structurally invalid v2 issues MUST block completed, abandoned, and superseded archive closure. A material issue SHALL trigger Replan only when its evidence invalidates accepted planning truth and MUST NOT start Review automatically.

`hardness.evolution.status` MUST summarize ignored observation availability, v2 material-issue counts and terminal states for an exact active Change, open issue paths, structural errors, and the canonical versioned workflow evaluation without replaying raw history or attachment bodies. Every Hardness or OpenSpec self-hosting Change MUST create one indexed compact `attachments/data/workflow-evaluation.md` before closure, with parseable schema/result frontmatter, exact Change identity, final capture time, elapsed lifecycle stages, friction, corrective actions, superseded owners, and raw-data provenance. Historical unversioned evaluations remain immutable compatibility evidence.

#### Scenario: Record a local raw observation
- **WHEN** an agent detects a timing boundary, transient friction, or candidate invariant that has not been classified as material
- **THEN** `hardness.observe` appends an independent ignored record and returns its run ID and exact local path without creating tracked work or blocking closure

#### Scenario: Admit a material dogfooding issue
- **WHEN** user, agent, implementation, verification, or Review evidence exposes a repeatable safety, correctness, lifecycle, evidence, or high-friction Hardness gap
- **THEN** the problem enters one suitable active Change as an indexed open v2 material issue with exact source evidence and owner tasks

#### Scenario: Preserve an immutable archive after a late issue
- **WHEN** a post-move gate, exact commit, or final delivery step exposes a material issue after the source Change was archived
- **THEN** the completed archive remains unchanged and one suitable active Change owns the issue before final handoff, with a successor created only when no suitable owner exists

#### Scenario: Route an issue without automatic Review
- **WHEN** an admitted issue does not invalidate planning truth
- **THEN** it is repaired in its owning task, rejected with evidence, or superseded by an exact v2 issue without starting Review or Replan automatically

#### Scenario: Inspect evolution state cheaply
- **WHEN** a caller invokes `hardness.evolution.status` for one exact active Change
- **THEN** the result reports raw observation metadata, v2 issue counts/states/open paths, structural errors, and the canonical workflow-evaluation result using frontmatter only

#### Scenario: Close a self-hosting Change
- **WHEN** a Hardness or OpenSpec Change is ready for any archive closure kind
- **THEN** every admitted v2 issue is structurally valid and terminal, one indexed final versioned workflow evaluation is tracked, and raw Saved observations remain ignored

### Requirement: Progressive harness knowledge promotion

Reusable harness knowledge MUST be loaded progressively and promoted explicitly. Change attachments own current evidence; capability-side `knowledges/` owns stable reusable guidance; project instructions own only cross-capability invariants. Every capability knowledge directory MUST have one `INDEX.md` that links every knowledge file exactly once with summary, served requirement/capability, source, and status. Archive MUST NOT promote knowledge implicitly.

#### Scenario: Promote a stable learning
- **WHEN** a finding is evidence-backed, remains valid after repair and verification, applies beyond one task, and changes future agent decisions
- **THEN** closure copies a concise generalized record into the Hardness capability knowledge and indexes it without copying transient logs, hashes, or incident chronology

#### Scenario: Retain one-off evidence locally
- **WHEN** an observation is specific to one failure, machine, snapshot, or temporary workaround
- **THEN** it remains in the change Review/implementation/data attachment and is not loaded as durable harness knowledge

#### Scenario: Load capability knowledge progressively
- **WHEN** a later task needs reusable guidance from a capability
- **THEN** it reads that capability's knowledge INDEX and loads only the linked current file needed by the task

### Requirement: Reusable PowerShell entry

Hardness SHALL require PowerShell 7.0 or later with the Core edition and SHALL support repeated Workspace, Git, observation, and OpenSpec invocations in one session without polluting caller location or shared global state. Every invocation SHALL return an independent run ID and the common result envelope. Session-local caches MAY retain bounded stable facts but MUST NOT cache dirty state, branch tips, authorization decisions, or mutation preconditions.

#### Scenario: Reuse one PowerShell 7 session
- **WHEN** Hardness commands run repeatedly in one supported session
- **THEN** leaf modules remain reusable, caller location is restored, every invocation has an independent run ID, and no Windows PowerShell 5.1 path is exposed

#### Scenario: Invalidate safety-sensitive facts
- **WHEN** a command depends on current branch, HEAD, registration, dirtiness, or explicit authority
- **THEN** Hardness reads the current fact instead of trusting a stale cache

### Requirement: Autonomous execution within authority

Hardness SHALL autonomously investigate, select in-scope technical solutions, update/replan, implement, verify, and resolve explicitly registered Review findings in the selected workspace without interrupting the user for ordinary technical choices. It MUST stop when progress requires new authority, risks destructive user-data changes, requires integration, push, publication, or removal without authorization, lacks external credentials, or faces irreconcilable explicit instructions. This autonomy is independent of whether Codex `/goal` is active.

#### Scenario: Resolve an in-scope Review finding
- **WHEN** a Required finding can be repaired within the accepted scope and current authority
- **THEN** Hardness completes triage, repair, verification, and re-review in the same selected workspace without requesting an ordinary technical decision

### Requirement: Ready-to-deliver finish state

Successful work MUST reach committed, verified, and closure-ready state while preserving its selected workspace and branch for inspection. Any explicitly registered Review MUST also be resolved or superseded. `git.commit` MAY establish scoped Git closure without claiming verification completion. `git.integrate` MAY run only after explicit user authorization against the exact verified source workspace and HEAD. `git.push` and `workspace.remove` MUST remain distinct later operations requiring separate explicit user intent.

#### Scenario: Finish in the selected workspace
- **WHEN** all tasks and verification complete and any explicitly registered Review is resolved
- **THEN** Hardness reports commits, evidence, excluded tests, elapsed workflow evaluation, and delivery options without automatically integrating, pushing, or removing a workspace

#### Scenario: Integrate after explicit authorization
- **WHEN** the user explicitly requests local integration
- **THEN** the coordinator checks the exact reviewed source HEAD, preserves unrelated target changes, integrates affected submodules before the parent, and leaves remote state and source workspace unchanged

### Requirement: Optional low-cost Codex hooks

The repository MAY provide project-local Codex `SessionStart` and `SubagentStart` hooks that call the same fast Hardness status contract. Hooks MUST be optional, bounded, PowerShell 7-only, non-mutating, and fail open with concise diagnostics. They MUST NOT run detailed Git/submodule scans, create workflow records automatically, become required by Cursor or Grok, or add `Stop` or `PostToolUse` hooks in this Change.

#### Scenario: Start a trusted Codex session
- **WHEN** Codex trusts the project hook configuration and emits `SessionStart` or `SubagentStart`
- **THEN** the hook resolves the event workspace from its working directory and injects a bounded status summary without changing repository state

#### Scenario: Run in another client
- **WHEN** Cursor, Grok, or a Codex session without trusted project hooks uses Hardness
- **THEN** all cross-client workflow routes remain functional without the hooks

### Requirement: Visible OpenSpec maintenance state

Hardness SHALL expose a read-only `openspec.maintenance.status` route that compares the packaged executable and release manifest with the recorded `Tools/openspec` source submodule state. It MUST report source path, source HEAD, source dirtiness, packaged version/hash, and alignment or maintenance-needed reasons without fetching, rebuilding, tagging, replacing, or committing the executable. Upgrade execution remains an explicit future OpenSpec maintenance Change.

#### Scenario: Inspect an aligned package
- **WHEN** the packaged manifest, executable identity, and recorded source commit agree
- **THEN** maintenance status reports aligned with the exact source and package identities

#### Scenario: Detect maintenance work
- **WHEN** source state, manifest, or package identity differs
- **THEN** the route reports evidence and recommends a separate maintenance Change without mutating either repository
