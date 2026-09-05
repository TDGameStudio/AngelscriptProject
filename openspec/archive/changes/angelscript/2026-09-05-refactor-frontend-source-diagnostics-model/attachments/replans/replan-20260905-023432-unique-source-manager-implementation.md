---
replan_id: replan-20260905-023432-unique-source-manager-implementation
status: applied
source: verification
source_ref: run-8d50869f797a421ebf421d793298f080
scope: UBT implementation-unit basename identity
base_commit: d4f69984b0611ca44956577c242266edad24002b
base_tasks_sha256: 91f0d50335515f1423724571345cce7e01b845259a9367f4efc4751c8e61742f
result_tasks_sha256: 35c529247d761c848fd130770ef3bfdcad69817cdf77a4bfbed4ef8be305021c
created_at: 2026-09-05T02:34:32+08:00
resume_task: 1.1
---

# Replan: give the new source-manager implementation a unique basename

## Trigger and Evidence

Managed build `8d50869f797a421ebf421d793298f080` proved that UBT rejects `source/as_source_manager.cpp` and `source/frontend/as_source_manager.cpp` as duplicate input filenames before C++ compilation. The accepted Task file list therefore cannot build while the preserved production source remains present.

## Decision

Keep the public frontend header and type names unchanged. Rename only the new implementation unit to `frontend/as_frontend_source_manager.cpp`, using an `as_frontend_` prefix whenever a new implementation basename would otherwise collide with a preserved production unit in the same UE module.

## Impact

Task `1.1` and the placement decision now name the unique implementation unit. Requirements, APIs, Task dependencies, verification commands, and production-isolation boundaries do not change.

## Old Task Disposition

Task `1.1` remains incomplete and resumes from its GREEN implementation step. The intentional missing-header RED remains valid; the UBT filename failure becomes planning-correction evidence rather than task completion evidence.

## Diff Snapshot

- Task changes: one Task `1.1` file path and one Replan context block.
- Edge changes: none.
- Design changes: one UBT basename-identity placement rule.
- Implementation changes: rename the new manager `.cpp` only; preserve all header/API work and existing production sources.

## Preserved Work

The SourceDiagnostics RED tests, frontend location/snapshot/manager API, snapshot implementation, stable-anchor behavior, and every unchanged Task remain applicable. No production source or public runtime API is rolled back.

## References and Result

- Issue: `implementation/issue-20260905-023432-ubt-duplicate-source-basename.md`.
- UBT log: `Saved/Harness/Unreal/Runs/8d50869f797a421ebf421d793298f080/Command.log`.
- Result: resume Task `1.1` with `as_frontend_source_manager.cpp` and the same scoped build/test verification.

