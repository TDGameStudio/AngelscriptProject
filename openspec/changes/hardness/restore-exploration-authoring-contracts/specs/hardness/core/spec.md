## ADDED Requirements

### Requirement: Two-tier exploration

Hardness MUST distinguish deep pre-creation discovery from task-local technical exploration. A new feature, architecture refactor, or major behavior change without an accepted decision-complete handoff MUST pass a read-only Explore Gate before its target OpenSpec Change is created. After target Change creation, that Change MUST NOT invoke deep Explore; existing truth changes through update/replan. A clear defect repair, mechanical documentation change, or approved ready-to-execute plan MAY skip the pre-creation gate. Technical uncertainty inside a Ready task MUST remain in the implementation leaf unless evidence invalidates current requirements, design, verification, dependency, or artifact truth.

For OpenSpec-scoped implementation, a decision-complete handoff MUST NOT substitute for an active Change. Hardness MUST resolve the canonical active Change and Ready Task DAG before implementation mutation in either Current or Goal mode.

#### Scenario: Shape a major change before creation
- **WHEN** a major behavior change has unresolved scope, architecture, or integration choices
- **THEN** deep exploration establishes evidence, viable options, a recommendation and flip condition, failures, verification, and an OpenSpec handoff before the target Change is created

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

### Requirement: Event-driven asynchronous Review

Hardness MUST expose exactly three Review routes: Incident Review, Final Review, and External Review. Incident Review MUST start automatically only after evidence demonstrates a major security/trust, destructive data/history, public compatibility, cross-repository atomicity, or invalidated cross-boundary completion problem. A completed Change with broad public, cross-boundary, security/destructive, compatibility/release, production-performance, or architectural impact MUST receive one approving Final Review after scope freeze against its current final snapshot. A verified small low-impact Change MUST instead record `Final Review: not required` with rationale and MUST NOT create a placeholder Review. Diff size alone MUST NOT determine impact. The user or another agent MAY start an External Review at any time; Hardness MUST register, reproduce, and triage it without treating the report or its severity as an automatic Replan.

Every new Review MUST use a unique Review file and immutable content reference. When a reviewer subagent is available, Hardness SHOULD dispatch it asynchronously and MAY continue disjoint main-thread work. Knowledge promotion, closure, archive, integration, and completion claims MUST wait for the applicable gate. If task-owned final scope changes after assignment, that result MUST NOT close the current Final Review; Hardness MUST absorb late changes and request one batched incremental Final Review after the next scope freeze. Review records MUST preserve actual assignment, completion, and closure times and MUST NOT impose a report line limit.

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

## MODIFIED Requirements

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
