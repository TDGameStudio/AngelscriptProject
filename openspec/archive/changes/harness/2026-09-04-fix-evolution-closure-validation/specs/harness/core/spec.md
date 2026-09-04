## ADDED Requirements

### Requirement: Fail-closed active evolution closure

Harness SHALL evaluate terminal closure only for one exact active Change and one explicit `completed`, `abandoned`, or `superseded` closure kind. It MUST consume the portable OpenSpec TaskPlan rather than parse Task DAG YAML. A completed closure MUST have a valid non-empty TaskPlan whose every node is complete; incomplete closure kinds MAY retain incomplete nodes for explicit disposition by the portable closure manifest. Ordinary status MAY inspect immutable archives, but terminal policy MUST reject an archived target and leave historical audit to strict archived validation.

Active material issues and Reviews MUST be discovered recursively and validated against the exact active TaskPlan, attachment index, lifecycle schema, evidence body, timestamps, and terminal disposition. Active schema-less issues or Reviews MUST NOT receive historical compatibility. A superseded issue MUST reference one exact active, indexed, non-superseded v2 owner with a reciprocal source reference. Review absence SHALL remain valid, while any existing Review MUST be closed or superseded with no open or deferred Critical/Required finding.

The canonical workflow evaluation MUST name the requested closure kind, include a lowercase SHA-256 of every ordinary active Change input except itself, and be captured no earlier than the latest terminal issue or Review event. Harness SHALL report the current input digest during ordinary exact status so the evaluation can be written last. Any later input mutation MUST make the evaluation stale and block terminal closure.

#### Scenario: Reject incomplete completed closure
- **WHEN** terminal evaluation requests `completed` for an active Change whose portable TaskPlan is missing, invalid, empty, or contains an incomplete node
- **THEN** Harness reports the exact task blocker and does not declare the Change closure-ready

#### Scenario: Reject stale workflow evaluation
- **WHEN** an active Change input differs from the digest recorded by its passed workflow evaluation or its evaluation predates a terminal issue or Review event
- **THEN** terminal evaluation fails until current evidence is captured last with the requested closure kind
  > Observables: Ordinary exact status exposes `CurrentInputSha256`, the recorded digest, evaluation freshness, and bounded closure blockers.

#### Scenario: Reject unfinished active evidence
- **WHEN** an active material issue or existing Review is schema-less, malformed, unindexed, task-invalid, time-invalid, open, improperly superseded, or retains an open/deferred Critical or Required finding
- **THEN** terminal evaluation rejects the exact evidence owner without changing its files or starting a Review automatically

#### Scenario: Preserve immutable archive compatibility
- **WHEN** a caller inspects an archived Change containing historical evidence formats
- **THEN** ordinary evolution status remains read-only and terminal evaluation directs the caller to strict archived validation instead of applying new active-record requirements or rewriting history
