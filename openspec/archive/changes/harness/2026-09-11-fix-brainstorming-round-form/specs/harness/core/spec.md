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
    settled, numbers the questions, and states a recommended answer. The round
    is compact Markdown using the marker vocabulary: one heading per round,
    one `❔ Open decision:` paragraph per question with lettered option
    bullets, a recommendation line and a flip-condition line. After the
    written round is sent, the same questions are issued through the host's
    structured answer form when one exists, with matching letters and the
    recommended option first; the form never replaces the written round, and
    a cancelled or missing form falls back to a text reply. The round and the
    user's reply are appended verbatim to the draft log. Facts are
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
