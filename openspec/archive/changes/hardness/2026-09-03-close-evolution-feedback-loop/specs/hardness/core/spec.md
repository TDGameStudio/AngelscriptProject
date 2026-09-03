## MODIFIED Requirements

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
