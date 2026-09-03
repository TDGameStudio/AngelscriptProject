## RENAMED Requirements

- FROM: `### Requirement: Explicit workspace modes`
- TO: `### Requirement: Unified workspace context`
- FROM: `### Requirement: Autonomous Goal execution within authority`
- TO: `### Requirement: Autonomous execution within authority`
- FROM: `### Requirement: Ready-to-integrate finish state`
- TO: `### Requirement: Ready-to-deliver finish state`
- FROM: `### Requirement: Event-driven asynchronous Review and closure`
- TO: `### Requirement: Explicit Review intake and direct closure`

## MODIFIED Requirements

### Requirement: Progressive skill routing

Hardness SHALL remain the single short entry for project workflow and SHALL load only the selected leaf module or focused reference. Workspace lifecycle, Git mutation, OpenSpec primitives, task status, and Hardness observation SHALL retain separate routes and authority boundaries. Default context MUST NOT bulk-load command documentation, attachments, historical observations, Replans, or leaf implementations. Unreal development routes are intentionally absent until their independent Change is complete.

#### Scenario: Route one project command
- **WHEN** a caller requests one installed Hardness command
- **THEN** the dispatcher loads only the owning leaf, returns the common result envelope, and does not acquire unrelated workflow authority

#### Scenario: Exclude the deferred Unreal leaf
- **WHEN** this Change completes before Unreal development integration
- **THEN** no `unreal.*` placeholder route is published and the existing Unreal Skill remains independently invocable until its own Change is verified

### Requirement: Unified workspace context

Hardness MUST use one Git-derived workspace model in both the primary checkout and any registered linked worktree. Codex `/goal` is an external continuation facility only and MUST NOT select a repository mode, imply worktree creation, constrain branch names, or change Git authority. New worktrees default to `.worktrees/<name>` on branch `<name>`, while existing registered worktrees remain valid at their current path and branch. Integration, non-force push, and worktree removal MUST remain three separate operations requiring explicit user intent.

#### Scenario: Work in the primary checkout
- **WHEN** the caller selects the registered primary checkout
- **THEN** Hardness targets that exact root without creating, switching, or labeling a Goal workspace and preserves unrelated local changes

#### Scenario: Work in an existing linked worktree
- **WHEN** the caller selects any worktree registered in the same Git common directory
- **THEN** Hardness accepts its actual path and branch without requiring `.worktrees/<name>` or a branch prefix

#### Scenario: Interpret Codex Goal continuation
- **WHEN** work is running under Codex `/goal`
- **THEN** repository selection still comes from the explicit or discoverable WorkspaceRoot and no Goal/Current repository state is created

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

### Requirement: Ready-to-execute Task authoring

Before a Task DAG is accepted, planning MUST map affected files, artifacts, and exclusive resources; divide work into independently reviewable outcomes; state exact or explicitly bounded paths, cross-task interfaces, and exact verification; and map every requirement and acceptance condition to at least one node. Each task card MAY add concise free-form detail such as Context, Constraints, Inputs, Produces, Watch, Notes, or Evidence when it materially helps execution, but those labels are optional prose rather than a fixed schema. Only the existing DAG frontmatter, checkbox ID, `Files:`, and verify text remain machine-readable, and this Change MUST NOT modify the OpenSpec parser or executable for task-card enrichment.

#### Scenario: Execute a detailed task card
- **WHEN** a node needs local constraints, inputs, or known hazards beyond its outcome and paths
- **THEN** the card includes only the useful prose needed by a zero-context implementer and OpenSpec derives the same task ID, dependencies, files, verification, and Ready state

#### Scenario: Keep a simple task card small
- **WHEN** outcome, files, and verification already make a node executable
- **THEN** the card omits optional labels instead of adding empty or boilerplate sections

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

### Requirement: Harness dogfooding feedback

Hardness SHALL expose cheap visible feedback during self-hosted evolution. `hardness.status` MUST report installation and selected-workspace identity without a detailed repository scan. `hardness.observe` MUST append a versioned, timestamped observation or lifecycle span under ignored `Saved/Hardness/` data without changing tracked workflow truth. `hardness.evolution.status` MUST summarize ignored observation availability and the most recent tracked workflow evaluation without replaying all raw history. Every Hardness or OpenSpec self-hosting Change MUST create one compact tracked workflow evaluation before completed closure, covering elapsed lifecycle stages, friction, corrective actions, deferred items, and raw-data provenance.

#### Scenario: Record a local workflow observation
- **WHEN** an agent detects workflow friction, a useful timing boundary, or a candidate invariant
- **THEN** `hardness.observe` appends an independent ignored record and returns its run ID and exact local path

#### Scenario: Review evolution without loading raw history
- **WHEN** a caller invokes `hardness.evolution.status`
- **THEN** the result reports counts, latest timestamps, and the latest tracked evaluation reference without bulk-loading observation bodies

#### Scenario: Close a self-hosting Change
- **WHEN** a Hardness or OpenSpec Change is ready for completed closure
- **THEN** one indexed compact workflow evaluation is already tracked in that Change and raw Saved observations remain ignored

### Requirement: Reusable PowerShell entry

Hardness SHALL require PowerShell 7.0 or later with the Core edition and SHALL support repeated Workspace, Git, observation, and OpenSpec invocations in one session without polluting caller location or shared global state. Every invocation SHALL return an independent run ID and the common result envelope. Session-local caches MAY retain bounded stable facts but MUST NOT cache dirty state, branch tips, authorization decisions, or mutation preconditions.

#### Scenario: Reuse one PowerShell 7 session
- **WHEN** Hardness commands run repeatedly in one supported session
- **THEN** leaf modules remain reusable, caller location is restored, every invocation has an independent run ID, and no Windows PowerShell 5.1 path is exposed

#### Scenario: Invalidate safety-sensitive facts
- **WHEN** a command depends on current branch, HEAD, registration, dirtiness, or explicit authority
- **THEN** Hardness reads the current fact instead of trusting a stale cache

### Requirement: Autonomous execution within authority

Hardness SHALL autonomously investigate, select in-scope technical solutions, update/replan, implement, verify, and re-review in the selected workspace without interrupting the user for ordinary technical choices or Review findings. It MUST stop when progress requires new authority, risks destructive user-data changes, requires integration, push, publication, or removal without authorization, lacks external credentials, or faces irreconcilable explicit instructions. This autonomy is independent of whether Codex `/goal` is active.

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

## ADDED Requirements

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
