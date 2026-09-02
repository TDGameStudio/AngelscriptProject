---
replan_id: replan-20260902-185805-add-risk-review-gates
status: applied
source: agent
source_ref: design.md#5-review-can-lead-to-replan-only-after-triage
scope: L1-downstream-branches
base_commit: 4129487f63fab930800a896ae7f932d7bd4e6e70
base_tasks_sha256: 57ff797d42de66fa5950e6084b71e1f4f2885a3bd59a6ab5be8764400f93e17f
result_tasks_sha256: 5f894e82eecea73d62cdd6a23c0df41f9aaedc7646d71f9bdc6521ed69be081c
created_at: 2026-09-02T10:58:05Z
resume_task: "1.2"
---

# Replan — Add high-risk review gates

## Trigger and Evidence

`design.md` requires automatic Review only at planned high-risk slices and the final gate. The initial `tasks.md` contained only final Task 4.1 and omitted the OpenSpec release boundary and the Hardness/UE coordination boundary, so the Task DAG did not implement the already selected acceptance policy.

## Decision

Add two fixed-snapshot Review Gates:

- `1.3`: OpenSpec source commit, tag, EXE, and package.
- `2.4`: Hardness, Workspace, and UE leaf/shim coordination.

Both gates require triage, repair, evidence, re-review, and a closed/superseded state. Final Review 4.1 remains.

## Impact

- Scope: L1 downstream branches; objective, proposal, spec, and design are unchanged.
- `3.1` waits for `1.3` so an unreviewed OpenSpec package cannot become the parent distribution.
- `3.2` waits for `2.4` so documentation and commits cannot freeze an unreviewed coordination boundary.
- Resume remains Task `1.2`; completed Task `1.1` is unaffected.

## Old Task Disposition

| Task | Previous state | Disposition | Replacement | Reason |
|---|---|---|---|---|
| 1.1 | done | preserved | — | OpenSpec identity and baseline validation remain valid |
| 1.2, 2.1–2.3 | pending | preserved | — | Implementation scope and verification are unchanged; only post-slice Review Gates are added |
| 3.1 | pending | preserved | — | `After` changes from 1.2 to 1.3 |
| 3.2 | pending | preserved | — | `After` changes from 2.3 to 2.4 |
| 4.1–4.2 | pending | preserved | — | Final Review and closure remain unchanged |

## Diff Snapshot

### Paths / status

```text
?? openspec/changes/angelscript/tooling/refactor-hardness-skill-system/tasks.md
?? openspec/changes/angelscript/tooling/refactor-hardness-skill-system/attachments/replans/replan-20260902-185805-add-risk-review-gates.md
```

The change records were untracked at the base commit, so Git had no line-level diff-stat baseline. The exact semantic difference follows.

### Tasks

```text
+ 1.3 OpenSpec high-risk Review Gate
+ 2.4 Hardness/Workspace/UE coordination Review Gate
~ 3.1 dependency only
~ 3.2 dependency only
```

### DAG edges

```text
+ 1.2 -> 1.3
+ 1.3 -> 3.1
+ 2.2 -> 2.4
+ 2.3 -> 2.4
+ 2.4 -> 3.2
- 1.2 -> 3.1
- 2.3 -> 3.2
```

### Artifacts

```text
proposal: unchanged
specs: unchanged
design: unchanged
tasks: 2 nodes added, 2 downstream dependency declarations replaced
```

## Preserved Work

Task 1.1's CLI-created identity, proposal, spec, design, task baseline, and doctor/workflow/strict-validation evidence remain intact. No in-progress local code required recovery outside Git, so no patch sidecar was created.

## References and Result

- `design.md` Decision 5.
- `attachments/INDEX.md` Hard conclusions.
- Result: the Replan was applied, `tasks.md` SHA-256 became `5f894e82eecea73d62cdd6a23c0df41f9aaedc7646d71f9bdc6521ed69be081c`, and work resumed from Task `1.2`.
