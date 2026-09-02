---
replan_id: replan-20260902-220447-repair-goal-and-unreal-review-boundaries
status: applied
source: review
source_ref: "attachments/reviews/review-20260902-harness-ue-final.md"
scope: goal-authority-async-lifecycle-suite-evidence-and-shim-gates
base_commit: 4129487f63fab930800a896ae7f932d7bd4e6e70
base_tasks_sha256: af807448d314b909aa45b7be1aeb61f6819dc63736e7eed957aa6ceae6fb791d
result_tasks_sha256: d6fd67e86dac556520c40139d4eab5748d35db6d7ede37aa788fd8b46859b8ac
created_at: 2026-09-02T22:04:47.9647113+08:00
resume_task: "2.5"
---

# Replan — Repair Goal and Unreal review boundaries

## Trigger and Evidence

The independent Task 2.4 fixed-snapshot review is `open/request_changes` with one Critical, six Required, and one Advisory finding. A Goal context invoked native OpenSpec routes in the caller's primary-checkout working directory; asynchronous UE runs enforced deadlines and released leases only when polled; two package-smoke routes referenced a missing Skill-owned runner; non-Fine execution could ignore the selected suite; the All catalog omitted live C++ tests while including a nonexistent prefix; Coverage accepted stale non-terminal evidence; general compatibility shims collapsed timeout exit semantics; and Workspace completion overstated integration readiness.

A Review finding does not trigger Replan by severity alone. These findings trigger it because the Goal authority boundary and the completed Task 2.3 verification boundary are false. The existing Task 2.4 review cannot close without a new implementation node, expanded regression gates, and a fresh independent snapshot.

## Decision

- Preserve completed Task 2.3 as the original implementation snapshot and preserve the failed review as evidence.
- Add Task `2.5` for TDD repair of Goal routing, active asynchronous ownership, package execution, suite/catalog truth, Coverage provenance, shim compatibility, and Git-only Workspace completion semantics.
- Make Task `2.4` depend on `2.5`; it remains the independent fixed-snapshot Review Gate rather than absorbing implementation work.
- Keep OpenSpec Task `1.5` independent and Ready so the 0.7.3 release repair can continue in parallel.
- Preserve the no-automatic-integration boundary and the user's explicit exclusions for complete All and StaticJIT All.

## Impact

Only the Task DAG and its navigation records change. Task `2.5` is added, and Task `2.4` changes predecessor from `2.3` to `2.5` while retaining `2.2`. No completed checkbox is reopened, no immutable review or release is rewritten, and no unrelated primary-checkout work is touched.

## Old Task Disposition

| Task | Previous state | Disposition | Reason |
|---|---|---|---|
| 1.1, 1.2, 1.4, 2.1, 2.2, 2.3 | done | preserved unchanged | Their historical implementation snapshots remain evidence |
| 2.5 | absent | added | The failed review invalidated the Goal/UE acceptance boundary |
| 2.4 | pending/Ready | modified and blocked by 2.5 | Re-review must inspect the repaired fixed snapshot |
| 1.5 | pending/Ready | preserved Ready | OpenSpec 0.7.3 repair is independent parallel work |
| 1.3, 3.1, 3.2, 4.1, 4.2 | pending | preserved unchanged | Their existing dependency boundaries remain valid |

## Diff Snapshot

```text
affected path/status: M .agents/skills/**; M Tools/*.ps1; M Tools/openspec; ?? openspec/; 92 total worktree status entries at trigger
tasks: +2.5; ~2.4; six completed checkboxes preserved
edges: +2.3->2.5 +2.5->2.4 -2.3->2.4; 2.2->2.4 preserved
artifacts: ~tasks ~INDEX +harness-ue-review +replan
```

## Preserved Work

The closed Workspace safety review, all prior Replans, six completed task states, the OpenSpec 0.7.0–0.7.2 immutable snapshots, the current 0.7.3 repair, parameter-compatible public shims, and all focused passing evidence remain intact. The new node extends the proof boundary without introducing a second DAG, execution database, or automatic merge/archive behavior. No patch sidecar is needed.

## References and Result

- `attachments/reviews/review-20260902-harness-ue-final.md` (SHA-256 `9550a08165c6ac34669089970830e501f78b2cb295a36d1ba61f35a046d22fb6`)
- `attachments/replans/replan-20260902-185805-add-risk-review-gates.md`
- `attachments/replans/replan-20260902-213906-preserve-072-and-publish-073.md`
- Before the change, the DAG was 13/6/7 with Ready `1.5`/`2.4`, zero issues, and tasks hash `af807448d314b909aa45b7be1aeb61f6819dc63736e7eed957aa6ceae6fb791d`.
- Result: the DAG is 14/6/8 with Ready `1.5`/`2.5`, zero issues, strict validation `1/1`, and tasks hash `d6fd67e86dac556520c40139d4eab5748d35db6d7ede37aa788fd8b46859b8ac`.
- The change UID remains `change_96d0ba36-d839-423e-8a76-f49973b87e18`; both `hardness/refactor-skill-system` and alias `angelscript/tooling/refactor-hardness-skill-system` resolve to the same record.
