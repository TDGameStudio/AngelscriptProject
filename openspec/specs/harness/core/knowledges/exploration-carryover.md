# Exploration Carryover

## Rule

Preserve accepted pre-Change exploration by destination, not by copying its transcript. Visual markers are optional scanning aids with stable English labels; they never become workflow state.

```text
accepted exploration item
  |-> changes current truth?       -> proposal/spec/design/tasks
  |-> prevents likely re-decision? -> indexed talk
  |-> reusable across later work?  -> indexed change-local knowledge
  `-> none of these?                -> discard
```

## Application

- Copy settled requirements, scope, architecture, verification, and executable boundaries into canonical planning artifacts after Change creation.
- Preserve a non-obvious decision or decision-critical visualization in a talk only when its rationale prevents likely re-decision.
- Preserve an evidence-backed reusable insight or visualization in change-local knowledge, then use the explicit capability-admission process when it remains useful beyond one task.
- Discard temporary question state, held/reopened navigation, redundant prose, one-off visuals, and the full transcript.

## Marker Boundary

Every marker line remains complete without emoji. `✅ Settled:` means an accepted decision, never a passing test or closed gate. Historical red/green status circles are not used. YAML, filenames, Task DAG edges, Review state, issue state, and commands remain plain machine-readable text.

## Source

- `openspec/archive/changes/harness/2026-09-03-restore-exploration-authoring-contracts/attachments/knowledges/exploration-marker-carryover.md`
- `openspec/archive/changes/harness/2026-09-03-restore-exploration-authoring-contracts/attachments/talks/talk-20260903-115455-exploration-marker-carryover.md`
