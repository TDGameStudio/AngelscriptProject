---
replan_id: replan-20260904-010308-focus-cutover
status: applied
source: user
source_ref: conversation:2026-09-04-focus-small-change
scope: stable Unreal record names and focused cutover closure
base_commit: 4614ff3568427f3374742dc30cea3b5efd1524bf
base_tasks_sha256: 84d3aec5db52501bc42a0440825f46f113f4b8ce7718e0195b0d3beb668a0bdf
result_tasks_sha256: c7a1c7734eb7fda174bc9a033e8e2c48d2969d0f1e677a9268ee2429143a57cf
created_at: 2026-09-04T01:03:08+08:00
resume_task: "3.2"
---

# Focus the Unreal runner cutover

## Trigger and Evidence

The user required stable names without decorative `v1` or `v2` suffixes and directed this small Change to complete and archive quickly. The previous Task `3.3` bundled a broad root Tools deletion that was much larger than the short-path repair.

## Decision

Use stable Unreal schema and registry names. Keep isolated long-path coverage, then run one real default-executor Build and Smoke gate. Move broad root Tools deletion and the cross-cutting Hardness-to-Harness rename outside this Change.

## Impact

- Task `3.2` now owns the focused real Build and Smoke acceptance.
- Task `3.3` now owns spec synchronization, compact workflow evaluation, validation, and archive.
- No dependency edge changed.

## Old Task Disposition

- Previous Task `3.2` commandlet, suite, cancellation, and parallel-worktree real gates are replaced by isolated lifecycle coverage plus focused real Build and Smoke evidence.
- Previous Task `3.3` root Tools deletion is removed from this Change and remains unimplemented future cleanup.

## Diff Snapshot

- Affected paths: Unreal Skill schema constants/data/tests and this Change's proposal, design, delta spec, tasks, and attachments.
- Tasks: `~3.2`, `~3.3`.
- DAG edges: no changes.
- Git: parent workspace remains dirty with unrelated pre-existing refactor work preserved.

## Preserved Work

Tasks `1.1` through `3.1`, their implementation, physical/execution split, ownership model, exact cleanup, mapped process correlation, and isolated verification remain valid.

## References and Result

- `proposal.md`
- `design.md`
- `specs/hardness/unreal/spec.md`
- `tasks.md`

The updated Task DAG resumes at Task `3.2`.
