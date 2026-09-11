## MODIFIED Requirements

### Requirement: Two-tier exploration

Harness MUST distinguish deep pre-creation brainstorming from task-local technical exploration. Before a new feature, architecture refactor, or major behavior-change Change is created, unresolved scope, architecture, integration, or user-owned product choices MUST trigger the Brainstorm Gate owned by the `brainstorming` Skill. The gate MUST NOT be skipped while any user-owned decision remains unconfirmed; a clear defect repair or mechanical documentation change MAY skip it only with one stated assumption. A decision-complete handoff or an already explicit approved plan MAY proceed directly to Change creation. Brainstorming MUST run only with the user present; unattended continuation MUST NOT open brainstorming or start a draft. After target Change creation, `design`-mode brainstorming MUST NOT reopen for that Change's scope and Apply MUST NOT ask the user questions; `research` and `proposal` drafts are independent of any Change and MAY be opened at any time, but a finding that changes an active plan is planning-invalidating evidence for update/replan; task-local uncertainty stays in Apply unless evidence invalidates canonical planning truth and triggers update/replan. A user-owned decision that surfaces inside a task MUST be recorded as planning-invalidating evidence and parked through `openspec-update-change` replan with the agent's recommendation until the next attended grill round answers it. A request to explain architecture, workflow, state, ownership, or three or more related branches SHOULD invoke `visual-explain`; routine one-step work and already-clear prose MUST NOT incur that cost.

#### Scenario: Shape a major change before planning

- **WHEN** a major change still contains blocking design choices or unconfirmed user-owned decisions before registration

- **THEN** `brainstorming` runs grilling rounds until the frontier is empty and produces a decision-complete handoff before the target Change is created

    Every question to the user is a grill round, including a single question
    or a naming choice. Each round opens with a situation brief (what was
    inspected, what is settled, why these questions are unblocked now, the
    overall recommendation), then asks every question whose prerequisites are
    settled, numbers the questions, and states a recommended answer. Facts are
    investigated by the agent; decisions are put to the user. No Change, code,
    or apply action occurs before the user approves the presented design.

#### Scenario: Continue from an explicit accepted plan

- **WHEN** scope, boundaries, naming, and verification are already decision-complete

- **THEN** Harness creates or updates the canonical Change without repeating brainstorming

#### Scenario: Skip the gate for a clear defect

- **WHEN** the request is a clear defect repair or mechanical documentation change with no user-owned decision left open

- **THEN** the agent states the one assumption that justifies skipping and proceeds

- **BUT** an unconfirmed user-owned choice reopens the gate regardless of perceived simplicity

#### Scenario: Park a user-owned decision found during unattended continuation

- **GIVEN** an unattended run is implementing a Ready task of an approved Change

- **WHEN** the task reveals a product-scope or behavior choice the design never settled

- **THEN** the agent records the finding, routes it to `openspec-update-change` replan as an open decision with its recommendation, and stops advancing that branch

- **BUT** it does not open `brainstorming`, create a draft, or decide the choice locally

#### Scenario: Explain a multi-branch workflow

- **WHEN** the user needs to understand a workflow with multiple states, branches, or owners

- **THEN** Harness routes a small useful visualization and keeps the underlying canonical state in plain text

### Requirement: Exploration markers and durable carryover

Pre-Change brainstorming MAY use the project marker vocabulary and compact Markdown visualizations to make facts, decisions, risks, boundaries, and knowledge candidates easy to scan. Every marker MUST retain a plain-text label and MUST NOT be the sole machine-readable state. The final brainstorming round MUST present every carryover candidate with its draft source, target (talk or knowledge), and reason, and the user MUST confirm the list before it enters the decision-complete handoff. `openspec-create-change` MUST be the only Skill that creates the target Change from a designed draft; in the same step it MUST copy the approved draft `design.md` and `handoff.md` into indexed `attachments/drafts/` and materialize exactly the confirmed candidates — non-obvious decisions and their useful visuals into indexed talks, reusable evidence-backed insights or visuals into indexed change-local knowledge — with provenance back to the draft round or finding. Afterwards canonical truth MUST enter proposal/spec/design/tasks through `openspec-continue-change`, which MUST NOT recreate the seeded carryover.

When an extended user-led exploration establishes multiple interacting cross-capability constraints, meaningful corrections, rejected interpretations, or non-obvious rationale that canonical artifacts would flatten and future agents would otherwise re-decide, planning MUST preserve one selective indexed intent talk. The talk MUST retain provenance, capture date, source limits, architecture-changing corrections, exclusions, and canonical mappings. It MUST NOT impersonate an earlier record when reconstructed later. Clear defects, mechanical documentation changes, one-step requests, routine task-local choices, and decisions fully represented by canonical artifacts MUST NOT create a required talk or a not-required placeholder. Transient navigation state, task state, and progress evidence MUST NOT be copied into the Change; the full round log stays in the draft, which is the durable owner of the conversation.

#### Scenario: Scan a grilling round without changing semantics

- **WHEN** interactive pre-Change brainstorming uses markers for a decision frontier

- **THEN** each marked line remains understandable without emoji and durable task/review/issue state continues to come from its canonical schema

#### Scenario: Carry accepted exploration into a new Change

- **GIVEN** the target Change exists and the decision-complete handoff has classified its accepted carryover

- **WHEN** an accepted handoff contains a non-obvious decision and a reusable insight after the target Change is created

- **THEN** `openspec-create-change` copies the approved draft `design.md` and `handoff.md` into `attachments/drafts/`, indexes them once, materializes the confirmed decision and its visualization as one talk and the confirmed insight as change-local knowledge, and `openspec-continue-change` then copies settled current truth into the canonical planning artifacts

    The draft README records `status: handed-off` and `target_change` in the
    same step so the source discussion and the Change point at each other.
    Each talk cites the draft round or finding it came from in English;
    the original wording stays in the draft `log.md`.

- **AND** the round log, findings, and glossary remain in the draft rather than the Change

- **BUT** a talk is retained only when its rationale prevents likely re-decision, and knowledge is retained only when the insight is reusable beyond the originating task

    > Inputs: The accepted handoff, its evidence and provenance, the non-obvious decision, the reusable insight, and the settled canonical behavior.
    >
    > Observables: Proposal, specification, design, or tasks contain current truth; the attachment index names the draft copies, the talk, and the knowledge candidate; the capability knowledge index changes only after explicit promotion.
    >
    > Boundaries: The draft owns the conversation, the talk owns decision rationale, the knowledge candidate owns reusable guidance, and none becomes a parallel source of current requirements or task state.
    >
    > Verification: Canonical artifacts and their attachment and knowledge indexes provide the stable ownership oracle for every retained carryover item.

#### Scenario: Preserve a major user-intent baseline

- **WHEN** a major user-led refactor is shaped by several interacting goals, corrections, exclusions, or rejected interpretations whose rationale would otherwise be lost

- **THEN** planning indexes one concise intent talk with exact provenance and canonical mappings while proposal/spec/design/tasks retain current truth

#### Scenario: Keep routine work free of intent boilerplate

- **WHEN** a Change is a clear defect, mechanical edit, one-step request, or contains no rationale beyond its canonical artifacts

- **THEN** no intent talk, draft copy, or not-required placeholder is created and closure does not infer one from conversation or diff size

#### Scenario: Repair missing historical carryover honestly

- **WHEN** later evidence shows that required user rationale was never recorded before a source Change was archived

- **THEN** a suitable active Change records a clearly dated reconstruction and does not edit the immutable archive or claim contemporaneous provenance

#### Scenario: Reject transcript accumulation inside the Change

- **WHEN** brainstorming contains temporary held/reopened navigation, redundant prose, progress state, or a one-off visualization with no later decision or reuse value

- **THEN** the Change receives only the approved design, handoff, qualifying talks, and knowledge, while the draft keeps the rest

## ADDED Requirements

### Requirement: Persistent brainstorming drafts

Every brainstorming session MUST record itself under `openspec/drafts/<domain>/<topic>/` from its first round, and a draft MUST be opened as soon as a reply contains a proposal, a trade-off, or more than one diagram. Brainstorming MUST write nothing outside the draft. The draft MUST contain `README.md` with `mode` (`research`, `proposal`, or `design`), `status` (`exploring`, `designed`, `handed-off`, `parked`, or `abandoned`), `opened`, and, once known, `target_change`; only a `design` draft MAY reach `designed`; an append-only `log.md` holding each round's questions, the user's answers in their own words, and agent conclusions; `findings/` for agent evidence; `glossary.md` for chosen and rejected names; `design.md` for the approved design; and `handoff.md` for the decision-complete handoff. Drafts MUST remain under `openspec/drafts/` after Change creation. Drafts MUST NOT carry task state, Ready state, or checkboxes, MUST NOT be scanned by Harness Change validation, and MUST NOT be treated as an OpenSpec artifact by the portable CLI. `design.md` and `handoff.md` MUST be English; `log.md` and `findings/` MAY retain the user's original-language wording.

#### Scenario: Open a draft on the first round

- **WHEN** `brainstorming` asks its first grilling round

- **THEN** `openspec/drafts/<domain>/<topic>/README.md` exists with `status: exploring` and `log.md` contains the round and, once answered, the user's reply

#### Scenario: Abandon a draft

- **WHEN** the user drops the idea before a Change is created

- **THEN** the draft README records `status: abandoned` and nothing is copied into any Change

#### Scenario: Research request with diagrams

- **WHEN** the user asks how a subsystem works and the reply carries more than one diagram or a comparison

- **THEN** a `mode: research` draft is opened and announced once, the diagrams and conclusions are written to `findings/<topic>.md`, and no design approval is requested

#### Scenario: Proposal request

- **WHEN** the user asks for a proposal

- **THEN** a `mode: proposal` draft writes `design.md` first as a marked proposal draft and subsequent grill questions each name the section they would change

- **AND** creating a Change from it requires upgrading the draft to `mode: design` and completing the naming and carryover rounds

#### Scenario: Park a draft without a Change

- **WHEN** the exploration is worth keeping but the user decides not to create a Change now

- **THEN** the draft README records `status: parked` with one line on what would revive it, the findings and glossary stay discoverable under `openspec/drafts/`, and no Change or attachment is created

- **AND** reviving it reopens `brainstorming` on the same directory with `status: exploring`, appending to `log.md` rather than starting over

#### Scenario: Validate records with drafts present

- **WHEN** strict OpenSpec validation or Harness `task.status` runs while `openspec/drafts/` contains files

- **THEN** the drafts produce no diagnostics and no Ready work, and the active Change list is unchanged

### Requirement: Naming confirmation before implementation

New public names — types, modules, files, and key functions — MUST be confirmed by the user before code is written. `brainstorming` MUST grill each new public name after inspecting neighbouring conventions and record the choice in the draft `glossary.md` and the design's vocabulary section. Task authoring MUST list every new public name the task introduces in its "Context and interfaces" detail. Apply MUST NOT ask the user for a name: when implementation requires a new public name that the task does not list, Apply MUST choose the convention-derived name and record `Naming assumed: <name>` in the task's Evidence, and verification MUST surface every assumed name for user review before the task closes.

#### Scenario: Grill a name during planning

- **WHEN** the design introduces a new public type

- **THEN** the round presents the recommended name, alternatives, and the neighbouring convention evidence, and the settled name is written to `glossary.md` and later to the task's interfaces

#### Scenario: Continue past an unplanned name in Apply

- **WHEN** a Ready task requires a new public class or file whose name is not in its "Context and interfaces"

- **THEN** the agent proceeds with the convention-derived name and records `Naming assumed: <name> — <reason>` in the task Evidence

    Attended and unattended runs behave identically; Apply has no interactive
    stop. Verification lists every `Naming assumed` entry so the user can
    rename before commit.

- **BUT** repeated assumed names indicate that task authoring skipped the naming round, which is corrected in planning rather than by asking during Apply
