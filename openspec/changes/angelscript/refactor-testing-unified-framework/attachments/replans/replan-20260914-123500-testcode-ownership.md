---
replan_id: replan-20260914-123500-testcode-ownership
status: applied
source: change
source_ref: "angelscript/refactor-test-code-structured-registration global prerequisite: release overlapping TestCode delivery before product tasks"
scope: "angelscript/refactor-testing-unified-framework: withdraw shard/aggregate/history-carrier TestCode ownership"
base_commit: c76d28ccd3c4366f3b33b190afa2b08bede26f56
base_tasks_sha256: 61adabba8719e628f424e03b012bd4009f840895e1e5ac54f34e90d2e2240269
result_tasks_sha256: c85ec8ee12a2423fd971343b2de72e1821d33050ecba7963d15ff99c27e37d25
created_at: 2026-09-14T12:35:00Z
resume_task: "1.1"
---

# Applied TestCode-ownership replan

## Trigger and Evidence

Accepted structured-registration handoff and its Task DAG require this planning-only Change to stop claiming source-history/diff as the generated TestCode carrier, byte-shard/aggregate release, and overlapping `AngelscriptTestCode` / `TestCode/Generated` files. Derived Ready state on the successor Change does not waive that prerequisite. Inspected current Files trees listed `NewVersion/Generated/TestCode/**` and `emit-cpp` shard/aggregate work; design and the test-code delta still mandated that competing delivery.

## Decision

Keep this Change planning-only and preserve every permanent task ID. Checked-in AngelScript originals, v1 fixture protocol, and one-mirrored-file structured registrations belong to `angelscript/refactor-test-code-structured-registration`. This Change may still own `FAngelscriptTestCode` facade work, TestSource case/row admission, data-driven rows, and later reload-history materialization, but those products must not generate or replace structured registrations.

## Impact

Owned artifacts: `proposal.md`, `design.md`, `tasks.md`, `attachments/INDEX.md`, `specs/angelscript/testing/test-code/spec.md`, `specs/angelscript/testing/source-history/spec.md`, `attachments/data/class-contracts.md`, `attachments/data/planning-validation.md`. No implementation or current durable spec outside this Change is modified.

## Old Task Disposition

- `1.1`, `2.1`, `2.2`, `4.1`, `4.2`, `5.1`, `5.2`, `7.1`, `7.2`: preserved; no overlapping TestCode-carrier claim.
- `2.3`, `2.4`: revised in place; history/diff is later reload-history only.
- `3.1`: revised in place from shard/aggregate emit-cpp to a withdrawal/negative-export proof.
- `3.2`, `3.3`, `6.1`, `6.2`: revised in place; consume structured registrations; `NewVersion/Generated/TestCode/**` removed from Files.

No task is cancelled, removed, or marked complete. DAG edges are unchanged.

## Diff Snapshot

- Task `~`: architecture, global constraints, coverage row wording, and the pending cards listed above.
- Task `+/-`: none. DAG edge `+/-`: none.
- Artifact `~`: proposal, design, test-code and source-history deltas, class contracts, planning-validation addendum, INDEX.
- Artifact `+`: this replan.

Affected `git status --short` after applying this replan (includes the already applied 2026-09-12 working-tree maintenance):

```text
 M openspec/changes/angelscript/refactor-testing-unified-framework/attachments/INDEX.md
 M openspec/changes/angelscript/refactor-testing-unified-framework/attachments/data/class-contracts.md
 M openspec/changes/angelscript/refactor-testing-unified-framework/attachments/data/planning-validation.md
 M openspec/changes/angelscript/refactor-testing-unified-framework/design.md
 M openspec/changes/angelscript/refactor-testing-unified-framework/proposal.md
 M openspec/changes/angelscript/refactor-testing-unified-framework/specs/angelscript/testing/source-history/spec.md
 M openspec/changes/angelscript/refactor-testing-unified-framework/specs/angelscript/testing/test-code/spec.md
 M openspec/changes/angelscript/refactor-testing-unified-framework/tasks.md
?? openspec/changes/angelscript/refactor-testing-unified-framework/attachments/replans/replan-20260914-123500-testcode-ownership.md
```

Affected `git diff --stat` for this ownership slice versus the 2026-09-12 working-tree baseline is the Task DAG rewrite plus the listed artifact updates; authoring/baseline/data-driven spec touch-ups remain the earlier maintenance.

## Preserved Work

All sixteen tasks remain unchecked. Unrelated workspace edits, the 2026-09-12 maintenance attachments, and the successor structured-registration Change are preserved. No product implementation is authorized by this replan.

## References and Result

Resume this Change at planning-only `1.1`. Product implementation of structured registration may now start on `angelscript/refactor-test-code-structured-registration` tasks `1.1` and `2.1`.
