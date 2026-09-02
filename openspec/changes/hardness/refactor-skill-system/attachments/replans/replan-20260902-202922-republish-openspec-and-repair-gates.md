---
replan_id: replan-20260902-202922-republish-openspec-and-repair-gates
status: applied
source: review
source_ref: "attachments/reviews/review-20260902-194012-openspec-07-package.md and strict change validation"
scope: release-and-verification-contracts
base_commit: 4129487f63fab930800a896ae7f932d7bd4e6e70
base_tasks_sha256: 5f894e82eecea73d62cdd6a23c0df41f9aaedc7646d71f9bdc6521ed69be081c
result_tasks_sha256: 69e80f5e169377522f30adf531bec0ae9d6412a2a901a179a444a578e912b10e
created_at: 2026-09-02T20:29:22.8178059+08:00
resume_task: "1.2"
---

# Replan — Republish OpenSpec and repair gates

## Trigger and Evidence

The first OpenSpec fixed-snapshot Review established that annotated `v0.7.0` failed its release gate. Moving that tag after repair would destroy the reviewed snapshot's immutability, so the original boundary of repairing and republishing 0.7.0 was false. Review Findings 1–13 were implementation defects that required resolution but did not individually trigger Replan. Finding 11 triggered Replan because it exposed the conflict between release acceptance and an immutable tag.

Actual strict validation also proved two verification contracts wrong. The project `angelscript` workflow explicitly does not require Requirement/Scenario structure but selected `requirements-v1`; and Task 4.2 embedded PowerShell escape backticks inside a Markdown code span, making the Task DAG node unparsable. Deleted wrappers and incorrect paths also meant that several original verification commands no longer proved their acceptance conditions.

## Decision

- Preserve `v0.7.0` as the immutable candidate that failed its Review Gate. Advance the repaired source to 0.7.1, create a new annotated `v0.7.1`, and republish the package.
- Use `record-v1` for the project `angelscript` workflow because it requires artifacts and a valid Task DAG without forcing every spec into delta Requirement/Scenario form. Keep `requirements-v1` as a tested explicit strict profile.
- Correct the version/release evidence for Tasks 1.2, 1.3, and 3.1 and the real paths/verification commands for Tasks 2.2, 3.2, 4.1, and 4.2.

## Impact

- Proposal, delta spec, and design current truth advance to OpenSpec 0.7.1 and the immutable failed-candidate policy.
- Every Task ID and DAG edge is preserved; no ID is added, deleted, or reused.
- Tasks `1.2`, `1.3`, `2.2`, `3.1`, `3.2`, `4.1`, and `4.2` change only their acceptance contract or file boundary. Completed Task `1.1` remains checked and is not reopened.
- Resume remains Task `1.2`.

## Old Task Disposition

| Task | Previous state | Disposition | Reason |
|---|---|---|---|
| 1.1 | done | preserved unchanged | Initial identity and repository baseline remain valid |
| 1.2, 1.3, 3.1 | pending | modified in place | Release and review snapshots must point to 0.7.1 |
| 2.2, 3.2 | pending | modified in place | Reference and guide paths changed |
| 4.1, 4.2 | pending | modified in place | Deleted wrappers and nested backticks cannot form valid gates |
| 2.1, 2.3, 2.4 | pending | preserved | Implementation boundaries and dependencies remain valid |

## Diff Snapshot

```text
paths/status: 85 changed or untracked paths in the isolated goal worktree
diff stat: tracked parent paths 49 files, +537/-5162; active change tree remains untracked at the base commit
tasks: ~1.2 ~1.3 ~2.2 ~3.1 ~3.2 ~4.1 ~4.2; no task +/-
edges: no edge +/-
artifacts: ~proposal ~design ~delta-spec ~tasks ~workflow.yaml
```

## Preserved Work

The first OpenSpec implementation, `v0.7.0` fixed snapshot, original Review findings, passing Workspace/Hardness/UE tests, and Task 1.1 evidence remain intact. The text was recoverable from the worktree and original Review, so no patch sidecar was created.

## References and Result

- `attachments/reviews/review-20260902-194012-openspec-07-package.md`
- `design.md` Decisions 8–9
- `openspec/workflows/angelscript/workflow.yaml`
- Result: the repaired Task DAG contained 11 nodes and strict change validation passed `1/1`; `tasks.md` SHA-256 became `69e80f5e169377522f30adf531bec0ae9d6412a2a901a179a444a578e912b10e`, and work resumed from Task `1.2`.
