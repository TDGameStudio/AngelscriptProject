---
replan_id: replan-20260903-172915-align-performance-entry-and-contract-test
status: applied
source: implementation
source_ref: "Task 3.2 performance scenario and output-path audit"
scope: public performance runner defaults and its contract test
base_commit: 2cb1c62e1f54eb907b8fd6f2ed9b2438042f7d27
base_tasks_sha256: 77a0d47ef320163e841351c97e1270ce390f34ff12e45c95e703cc84e6663853
result_tasks_sha256: fef458f5930980872059da467c90773b17f0cc4af41429ce1fc12ac9f55b0a23
created_at: 2026-09-03T17:29:15+08:00
resume_task: "3.2"
---

# Align the Performance Entrypoint and Contract Test

## Trigger and Evidence

Task 3.2's pre-edit audit found that both `Hardness.Performance.Tests.ps1` and the public `Test-Hardness.ps1` runner still defaulted raw output to `Saved/Harness/Hardness/Performance`, while the accepted design requires `Saved/Hardness/Performance`. The runner contract test also fixed the old four-scenario count and must change with the planned fast-status, detailed-status, and observation measurements. Those two coupled files were missing from Task 3.2's Files list.

## Decision

Add the public runner and its focused contract test to Task 3.2. Move only the performance default to `Saved/Hardness/Performance`, expand the asserted scenario set, and keep raw evidence ignored. Do not change the public gate profiles or introduce machine timing as a fragile acceptance threshold.

## Impact

- Task 3.2 owns the complete public performance surface it verifies.
- All existing task states, dependency edges, and the exact final performance command remain unchanged.
- Task 3.1's completed Quick result remains valid; the updated runner contract receives its own Task 3.2 focused verification before the final measurement.

## Old Task Disposition

- `1.1` through `3.1`: preserved complete.
- `3.2`: preserved ready with two coupled files added before implementation.
- `3.3`, `4.1`: preserved pending.

## Diff Snapshot

```text
Task ~: 3.2 Files adds Test-Hardness.ps1 and Test-Hardness.Tests.ps1
Edge +/-: none
Artifact +: this Replan
Artifact ~: tasks.md, attachments/INDEX.md
```

## Preserved Work

All unified workspace implementation, authoring, Hook, Quick-gate, and unrelated main-workspace content remains unchanged.

## References and Result

- Result Task DAG SHA-256: `fef458f5930980872059da467c90773b17f0cc4af41429ce1fc12ac9f55b0a23`.
- Resume at Task `3.2`.
