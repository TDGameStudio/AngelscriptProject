---
replan_id: replan-20260903-130536-place-final-review-after-deliverables
status: applied
source: user
source_ref: "conversation: Final Review must run only after every substantive task and deliverable is complete"
scope: Final Review ordering, capability knowledge materialization, complete snapshot freeze, and archive boundary
base_commit: 4f6db850d8c2ab990e97db0b3dd4c477ebd40160
base_tasks_sha256: 671347bef57bcf408793386bd6aef0d497e64b1e8480dc4128c30ac4a30eb2a6
result_tasks_sha256: 0d0d88171d2dedca16d94d175267dd5de80dc4e2df07dd4fdbe5a9e3ee8fa103
created_at: 2026-09-03T13:05:36+08:00
resume_task: "4.13"
---

# Place Final Review After Every Deliverable

## Trigger and Evidence

When closure readiness was inspected after commit `4f6db850`, the coordinator attempted to allocate Final Review while Tasks 4.12 and 5.3 still planned capability-knowledge content and closure preparation. The user correctly rejected that ordering: a Review cannot be final while substantive outputs remain. The assignment file was created locally but no reviewer was dispatched; it was removed immediately and is not retained as a Review event.

## Decision

Make Final Review the last semantic Task DAG node. Materialize every intended capability-knowledge file, update all protocol/spec/test content, prepare closure inputs, rerun proving verification, and commit the complete semantic snapshot first. Final Review then covers those exact bytes. Only Review/Task/attachment-INDEX lifecycle bookkeeping and the deterministic closure/archive metadata or move may follow approval without re-freeze.

## Impact

- Completed Tasks `1.1` through `4.10` and commit `4f6db850` remain valid baseline work.
- Pending Tasks `4.11`, `4.12`, and `5.3` are superseded before execution.
- The unused open assignment created after `4f6db850` produced no reviewer output and was deleted rather than misrepresented as a superseded Review.
- New Tasks `4.13`, `5.4`, and `5.5` materialize all final content, freeze/commit it, and run Final Review last. Completed archive follows the fully complete DAG as deterministic lifecycle work.

## Old Task Disposition

- `1.1`, `2.1`, `2.2`, `3.1`, `3.2`, `3.4`, `4.1`, `4.3`, `4.4`, `4.5`, `4.6`, `4.8`, `4.9`, `4.10`: preserved complete.
- `4.11`: superseded before reviewer dispatch because its snapshot excluded later semantic deliverables.
- `4.12`: superseded before execution by `4.13`, which materializes capability knowledge before Final Review.
- `5.3`: superseded before execution by `5.4` for complete snapshot/closure preparation and `5.5` for the last semantic gate; archive follows after all DAG nodes complete.

## Diff Snapshot

```text
base commit: 4f6db850d8c2ab990e97db0b3dd4c477ebd40160
affected status: only active Hardness/OpenSpec protocol, knowledge, tests, and Change records; unrelated dirty workspace paths remain excluded
unused assignment: review-20260903-130402-hardness-workflow-subagent.md created locally, never dispatched, then deleted

Task -: 4.11, 4.12, 5.3
Task +: 4.13, 5.4, 5.5

Edge -: 4.10 -> 4.11, 4.11 -> 4.12, 4.12 -> 5.3
Edge +: 4.10 -> 4.13, 4.13 -> 5.4, 5.4 -> 5.5

Artifact +: this Replan, exploration-carryover capability knowledge, Review-scheduling capability knowledge
Artifact ~: Review/attachment/knowledge protocols, proposal/design/delta/current specs, protocol tests, capability INDEX, tasks.md, attachments/INDEX.md
```

## Preserved Work

- Commit `4f6db850` and its passing strict/focused/PS7 Quick evidence.
- Both earlier immutable approving Reviews and the resolved recovery issue.
- All marker/carryover and event-driven Review decisions.
- Every unrelated main-workspace edit, plugin/submodule state, executable, and excluded root README hunk.

## References and Result

- User correction: current conversation statement that Final Review belongs after all tasks complete.
- Current plan: `openspec/changes/hardness/restore-exploration-authoring-contracts/tasks.md`.
- Result Task DAG SHA-256: `0d0d88171d2dedca16d94d175267dd5de80dc4e2df07dd4fdbe5a9e3ee8fa103`.
- Resume at Task `4.13`; do not allocate Final Review until Task `5.4` freezes and commits every semantic output.
