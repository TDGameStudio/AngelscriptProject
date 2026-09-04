## ADDED Requirements

### Requirement: Flexible Scenario Card authoring

Maintained Harness specifications SHALL express durable behavior through `Requirement` and `Scenario` headings, with one `WHEN` trigger and one `THEN` result in an ordinary behavioral scenario. Authors MAY add `GIVEN`, `AND`, or `BUT` clauses and quoted `Context`, `Inputs`, `Observables`, `Boundaries`, or `Verification` detail only when that information materially clarifies a complex behavior for a zero-context reader. Every optional clause and detail line SHALL remain ordinary Markdown and MUST NOT become a parser field, ordering rule, required placeholder, scenario identifier, checkbox, dependency edge, Ready state, or execution record.

Scenario Cards MUST retain the existing artifact ownership boundaries. Specs own durable externally observable behavior and stable behavioral or proof boundaries; design owns technical choices and rationale; tasks own affected paths, implementation steps, dependencies, and exact execution commands; attachments own one-off observations, run output, investigation history, and closure evidence. A `Verification` detail MAY identify a stable invariant, test family, or acceptance route, but MUST NOT embed transient output or impersonate task execution state. When the required `WHEN` and `THEN` already make a scenario clear, the author MUST omit unused optional clauses and detail labels.

#### Scenario: Enrich a complex behavior scenario
- **GIVEN** a durable behavior has multiple relevant preconditions, outputs, exclusions, or proof boundaries
- **WHEN** an author records that behavior in a Harness specification
- **THEN** the Scenario Card retains one clear behavioral flow and adds only the optional clauses and quoted detail that materially help a zero-context reader
- **AND** each added detail remains durable, externally meaningful, and owned by the specification
- **BUT** the card does not acquire task state, implementation steps, transient evidence, or a second machine-readable schema

> Context: Rich detail is progressive authoring guidance for complex behavior, not a required field matrix.
>
> Observables: Requirement and Scenario headings, the `WHEN` trigger, and the `THEN` result remain recognizable exactly as they are in a compact scenario.
>
> Boundaries: Optional labels may be omitted, reordered, or replaced by clearer ordinary Markdown without changing OpenSpec parser behavior.
>
> Verification: OpenSpec authoring-contract fixtures and strict specification validation cover both rich and compact cards while preserving their Requirement and Scenario structure.

#### Scenario: Keep a simple behavior scenario compact
- **WHEN** one trigger and one observable result completely express the durable behavior
- **THEN** the Scenario Card keeps only its useful `WHEN` and `THEN` clauses instead of adding empty or boilerplate detail

## MODIFIED Requirements

### Requirement: Harness-recognized Task Graph

`tasks.md` MUST be the change's only current execution state and DAG. A current-format file MUST declare one versioned YAML-frontmatter `task_graph.depends_on` map whose quoted stable `X.Y` keys exactly match the top-level Markdown checkbox IDs. The Markdown body MUST retain each task's checkbox state, `Files:`, and exact verification command. A completed task MUST NOT return to incomplete, and an ID MUST NOT be reused or renumbered.

#### Scenario: Derive ready work through Harness
- **GIVEN** the current Task Graph has matching frontmatter and Markdown task IDs and contains no invalid dependency cycle
- **WHEN** Harness reads a current `tasks.md` and all `depends_on` predecessors of an incomplete task are complete
- **THEN** the task is Ready through the Harness task route and may run in parallel only when its files, artifacts, and resource leases are also disjoint
- **AND** a completed task is never returned Ready, while an incomplete task with any incomplete predecessor remains blocked
- **BUT** a cyclic or structurally invalid graph produces structured issues and no Ready work

> Inputs: The versioned `task_graph.depends_on` map, top-level checkbox states, stable task IDs, and each task's declared file surface.
>
> Observables: The task route reports natural task order, completion state, normalized direct predecessors, derived Ready state, and any structured Task Graph issues.
>
> Boundaries: Dependency readiness is necessary but does not by itself authorize parallel execution when files, artifacts, or exclusive resources overlap.
>
> Verification: Harness and OpenSpec Task Graph fixtures cover completed, Ready, blocked, independent, missing-change, and cyclic cases.

#### Scenario: Read historical task records
- **GIVEN** a task record uses either the historical `After:`-only dialect without Task Graph frontmatter or the current frontmatter dialect without live `After:` fields
- **WHEN** validation or archive audit encounters an older `After:`-only task record without Task Graph frontmatter
- **THEN** it remains readable, while a file that mixes both dependency dialects fails validation
- **BUT** historical readability does not make `After:` a valid dependency source for newly authored current-format tasks

> Inputs: A complete legacy task body or a current `task_graph.depends_on` map and its matching Markdown task IDs.
>
> Observables: A valid legacy record yields its historical dependency relationships; mixed current and legacy syntax yields the specific structured validation issue.
>
> Boundaries: Dependency-looking text inside fenced examples is documentation rather than live Task Graph input, and reading a legacy record does not rewrite it.
>
> Verification: Task-plan contract fixtures cover legacy readability, mixed-syntax rejection, exact graph/body parity, and fenced-example exclusion.

### Requirement: Exploration markers and durable carryover

Pre-Change exploration MAY use the project marker vocabulary and compact Markdown visualizations to make facts, decisions, risks, boundaries, and knowledge candidates easy to scan. Every marker MUST retain a plain-text label and MUST NOT be the sole machine-readable state. The decision-complete handoff MUST classify accepted carryover before Change planning. After the target Change is created, canonical truth MUST enter proposal/spec/design/tasks; non-obvious decisions and their useful visuals MUST enter indexed talks when their rationale prevents re-decision; reusable evidence-backed insights or reusable visuals MUST enter indexed change-local knowledge.

When an extended user-led exploration establishes multiple interacting cross-capability constraints, meaningful corrections, rejected interpretations, or non-obvious rationale that canonical artifacts would flatten and future agents would otherwise re-decide, planning MUST preserve one selective indexed intent talk. The talk MUST retain provenance, capture date, source limits, architecture-changing corrections, exclusions, and canonical mappings. It MUST NOT impersonate an earlier record when reconstructed later. Clear defects, mechanical documentation changes, one-step requests, routine task-local choices, and decisions fully represented by canonical artifacts MUST NOT create a required talk or a not-required placeholder. Transient questions, navigation state, task state, progress evidence, and the full exploration transcript MUST NOT be copied into the Change.

#### Scenario: Carry accepted exploration into a new Change
- **GIVEN** the target Change exists and the decision-complete handoff has classified its accepted carryover
- **WHEN** an accepted handoff contains a non-obvious decision and a reusable insight after the target Change is created
- **THEN** the decision and useful visualization are indexed in one talk, the reusable insight is indexed in change-local knowledge, and settled current truth is copied into the canonical planning artifacts
- **AND** transient questions, navigation state, execution progress, and the full exploration transcript remain outside the Change
- **BUT** a talk is retained only when its rationale prevents likely re-decision, and knowledge is retained only when the insight is reusable beyond the originating task

> Inputs: The accepted handoff, its evidence and provenance, the non-obvious decision, the reusable insight, and the settled canonical behavior.
>
> Observables: Proposal, specification, design, or tasks contain current truth; the attachment index names the talk and knowledge candidate; the capability knowledge index changes only after explicit promotion.
>
> Boundaries: The talk owns decision rationale, the knowledge candidate owns reusable guidance, and neither becomes a parallel source of current requirements or task state.
>
> Verification: Canonical artifacts and their attachment and knowledge indexes provide the stable ownership oracle for every retained carryover item.

### Requirement: Evidence-gated replan

A Review finding MUST NOT directly trigger Replan. Harness may apply a Replan only after evidence proves that a requirement, design, acceptance condition, task boundary, dependency edge, or completion record is invalid, and it MUST preserve a lightweight immutable semantic-diff record.

#### Scenario: Replace an invalid plan branch
- **GIVEN** the relevant evidence has been reproduced or independently verified against the accepted planning artifacts
- **WHEN** verified evidence invalidates part of the existing Task DAG
- **THEN** the system records old-task dispositions, preserves valid work, updates current artifacts/tasks, and creates one `status: applied` Replan file
- **AND** the Replan records the affected behavior, task and edge changes, retained work, and resulting canonical plan
- **BUT** a finding, severity label, preference, or implementation defect inside an otherwise valid task does not by itself authorize Replan

> Inputs: The exact evidence reference and the affected requirement, design boundary, acceptance condition, task boundary, dependency edge, or completion record.
>
> Observables: One immutable applied Replan records old-task disposition and a bounded semantic diff, while the current canonical artifacts and Task Graph contain the repaired truth.
>
> Boundaries: Valid completed work remains preserved; local implementation repair stays in its owning task or material issue when planning truth remains valid.
>
> Verification: Replan protocol fixtures require applied-only state, old-task dispositions, preserved work, and a bounded task, edge, artifact, and path-status diff.

### Requirement: Explicit Review intake and direct closure

Harness MUST NOT start Incident Review, Final Review, or any other Review automatically from impact, diff size, task count, a local defect, or a verification result. When no Review has been explicitly requested, verified work MAY proceed directly to completed closure and archive after tasks, durable-spec sync, attachments, and evidence are ready; it MUST NOT create a placeholder Review or a not-required Review disposition. A problem found during implementation or verification SHALL be diagnosed and repaired inside the current task when planning truth remains valid, or SHALL trigger the evidence-gated replan path when requirements, design, verification, artifacts, or Task DAG truth became invalid.

The user or an external agent MAY explicitly request a fixed-snapshot Review. Harness SHALL register that Review with a unique file and materializable immutable content reference, reproduce and triage its findings, and MAY run the assigned reviewer asynchronously when useful; asynchronous execution is optional and does not become the default lifecycle. A finding never directly triggers replan. Before completed archive, every explicitly registered Review file MUST be `closed` or `superseded`, no Critical or Required finding may remain open or deferred, and resolutions MUST retain evidence. Review records MUST preserve actual lifecycle times, concrete findings, and detailed resolution history without a report line limit.

#### Scenario: Process an explicitly requested Review
- **WHEN** the user or an external agent requests Review of an exact snapshot
- **THEN** Harness registers and triages the Review, optionally delegates it asynchronously, and blocks archive only until that explicit Review is resolved or superseded
- **AND** the Review is bound to one materializable immutable snapshot and retains its actual assignment, completion, and closure lifecycle
- **BUT** report arrival or finding severity does not trigger Replan until evidence proves that accepted planning truth is invalid

> Context: Review is an explicit intake path rather than automatic lifecycle cadence.
>
> Inputs: The requesting authority, Review kind, exact immutable snapshot reference and digest, and any already available verification evidence.
>
> Observables: One unique Review file records concrete findings, dispositions, repair evidence, any required re-review, and a final `closed` or `superseded` state.
>
> Boundaries: An asynchronous reviewer writes only its assigned Review file; disjoint work may continue, but the reviewed work cannot archive while its explicit Review remains unresolved.
>
> Verification: Review protocol fixtures accept valid closed and superseded lifecycles and reject invalid requesters, snapshots, timestamps, verdicts, open blocking findings, and unowned deferred advice.

### Requirement: Harness dogfooding feedback

Harness SHALL expose cheap visible feedback during self-hosted evolution. `harness.status` MUST report installation and selected-workspace identity without a detailed repository scan. `harness.observe` MUST append a versioned, timestamped raw observation or lifecycle span under ignored `Saved/Harness/` data without changing tracked workflow truth; raw observations remain non-blocking until explicitly admitted. A material dogfooding discovery MUST NOT remain only in conversation, a final handoff, or ignored data. It MUST enter the existing v2 material implementation-issue lifecycle in one exact suitable active Change before affected implementation continues or final handoff completes. If no suitable active owner exists after the source Change archived, a successor Change and issue MUST be created without modifying the archive.

Whether evidence crosses the material threshold remains a bounded agent/user judgment. Once admitted, every v2 issue MUST appear exactly once in the owning attachment index and remain open until it is resolved with evidence, rejected with evidence, or superseded by an exact existing v2 issue. Open or structurally invalid v2 issues MUST block completed, abandoned, and superseded archive closure. A material issue SHALL trigger Replan only when its evidence invalidates accepted planning truth and MUST NOT start Review automatically.

`harness.evolution.status` MUST summarize ignored observation availability, v2 material-issue counts and terminal states for an exact active Change, open issue paths, structural errors, and the canonical versioned workflow evaluation without replaying raw history or attachment bodies. Every Harness or OpenSpec self-hosting Change MUST create one indexed compact `attachments/data/workflow-evaluation.md` before closure, with parseable schema/result frontmatter, exact Change identity, final capture time, elapsed lifecycle stages, friction, corrective actions, superseded owners, and raw-data provenance. Historical unversioned evaluations remain immutable compatibility evidence.

#### Scenario: Close a self-hosting Change
- **GIVEN** one exact Harness or OpenSpec Change and its requested archive closure kind have been selected
- **WHEN** a Harness or OpenSpec Change is ready for any archive closure kind
- **THEN** every admitted v2 issue is structurally valid and terminal, one indexed final versioned workflow evaluation is tracked, and raw Saved observations remain ignored
- **AND** the terminal check evaluates that exact Change rather than inferring closure readiness from an unscoped scan
- **BUT** an ignored raw observation remains non-blocking unless it has been explicitly admitted as a material issue

> Inputs: The exact Change identity, indexed v2 issue frontmatter, the canonical workflow-evaluation frontmatter, and the requested closure kind.
>
> Observables: Evolution status reports issue counts and terminal states, open paths, structural errors, the final evaluation result, and whether the exact Change is closure-ready.
>
> Boundaries: Status reads versioned frontmatter without replaying issue, evaluation, or raw-observation bodies; open or malformed issues and a missing, invalid, or failed final evaluation block closure.
>
> Verification: Harness evolution and protocol fixtures cover open, resolved, rejected, superseded, self-superseded, malformed, unindexed, and invalid-evaluation states.
