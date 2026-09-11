## MODIFIED Requirements

### Requirement: Explicit Review intake and direct closure

Harness MUST NOT start Incident Review, Final Review, or any other Review automatically from impact, diff size, task count, a local defect, or a verification result. When no Review has been explicitly requested, verified work MAY proceed directly to completed closure and archive after tasks, durable-spec sync, attachments, and evidence are ready; it MUST NOT create a placeholder Review or a not-required Review disposition. A problem found during implementation or verification SHALL be diagnosed and repaired inside the current task when planning truth remains valid, or SHALL trigger the evidence-gated replan path when requirements, design, verification, artifacts, or Task DAG truth became invalid.

The user or an external agent MAY explicitly request a fixed-snapshot Review. Harness SHALL register that Review with a unique file and materializable immutable content reference, reproduce and triage its findings, and MAY run the assigned reviewer asynchronously when useful; asynchronous execution is optional and does not become the default lifecycle. A finding never directly triggers replan. Before completed archive, every explicitly registered Review file MUST be `closed` or `superseded`, no Critical or Required finding may remain open or deferred, and resolutions MUST retain evidence. Review records MUST preserve actual lifecycle times, concrete findings, and detailed resolution history without a report line limit.

The single `code-review` Skill owns the reviewer's stance. A reviewer MUST read tests and task cards before code, MUST inspect other revisions read-only, MUST NOT dispatch further reviewers, and MUST label a finding whose defect lies in the requirement, design, or task card as a planning finding without prescribing Replan. Severity MUST use the retained names with fixed meaning: `Critical` is wrong behavior, data or safety loss, or a broken contract that blocks; `Required` must be fixed before the Change closes but does not endanger the snapshot's correctness claim; `Advisory` is optional and MAY be deferred only with a named follow-up. A re-review MUST check only the previous findings' resolution conditions against a new immutable snapshot; a new scope MUST become a new Review. The coordinator MAY fan one snapshot out into several Reviews by area with distinct reviewers and non-overlapping scopes, MUST clarify every ambiguous finding before repairing any, and MUST route a finding that contradicts a user-owned decision to the user when attended or to `openspec-update-change` when unattended.

#### Scenario: Archive verified work without Review

- **WHEN** every task and required verification passes, durable truth is synchronized, closure evidence is ready, and no Review was explicitly requested

- **THEN** Harness prepares completed closure and archives directly without creating a Review record or impact classification ceremony

#### Scenario: Replan a discovered planning failure

- **WHEN** implementation or verification evidence invalidates a requirement, design boundary, verification contract, required artifact, or Task DAG edge

- **THEN** Harness applies the replan protocol, preserves valid work, repairs the new plan, and verifies again without starting Review automatically

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

#### Scenario: Preserve detailed Review evidence

- **WHEN** findings require extensive evidence, impact analysis, resolution conditions, or re-review history

- **THEN** the Review file retains the necessary detail without a line cap while avoiding redundant verification already supplied with the snapshot

#### Scenario: Classify a finding by fixed severity

- **WHEN** the reviewer records a finding against the assigned snapshot

- **THEN** the finding carries `Critical`, `Required`, or `Advisory` with the fixed meaning, file or record location, observation, impact, evidence or reproduction, and a concrete resolution condition

    | Severity | Meaning | Closure effect |
    |---|---|---|
    | `Critical` | Wrong behavior, data or safety loss, or a broken contract | Blocks; must be resolved |
    | `Required` | Must be fixed before the Change closes; does not endanger the correctness claim | Blocks until resolved or rejected with evidence |
    | `Advisory` | Optional improvement | May be deferred only with a named follow-up |

- **AND** a finding whose defect is in the requirement, design, or task card is labelled a planning finding and does not prescribe Replan

- **AND** the Review lists what was checked and found sound so a re-review can bound its scope

#### Scenario: Re-review a repaired snapshot

- **WHEN** the coordinator requests a re-review after repairing findings

- **THEN** the re-review checks only the previous findings' resolution conditions against a new immutable snapshot and appends its result under each original finding

- **BUT** a request that widens the scope becomes a new Review file rather than another round of the same chain

#### Scenario: Fan a snapshot out by area

- **WHEN** one snapshot is too broad for a single reviewer pass

- **THEN** the coordinator assigns several Review files with distinct reviewers and non-overlapping scopes before any reviewer starts

- **BUT** a reviewer never dispatches another reviewer for part of its own assignment

#### Scenario: Triage a finding that contradicts a user-owned decision

- **WHEN** a finding asks to reverse a decision recorded in the design or an indexed talk

- **THEN** the coordinator does not repair it locally; attended, it puts the decision to the user, and unattended, it parks the finding through `openspec-update-change`

- **AND** every ambiguous finding is clarified before any finding in the same Review is repaired
