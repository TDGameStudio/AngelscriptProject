---
replan_id: replan-20260905-095630-batched-implementation-verification
status: applied
source: user
source_ref: user request to implement more tests and code before unified batch testing
scope: implementation batch size and UE verification cadence
base_commit: d4f69984b0611ca44956577c242266edad24002b
base_tasks_sha256: fd28c90407543a86195ded9eb51ff19787f05a3e37dc4e083950001f8e93fe9c
result_tasks_sha256: 93a7bfb9e6154cddca90ae4b5f4e84d331e887f3231add79face3b664ce56caf
created_at: 2026-09-05T09:56:30+08:00
resume_task: "2.1"
---

## Trigger and Evidence

The user explicitly requested larger implementation and test batches because separate UE launches for each small increment slow execution. Recent narrow Automation runs each cost about 20 seconds, excluding compilation. Build 8639d2c7c51f451c97e42803b33e65ba already produced a fresh successful binary for retained-token fixes; one NativeEngine batch now replaces four adjacent prefix launches.

## Decision

Co-develop tests and implementation for a coherent batch, build once and run NativeEngine once. Retain exact area selectors for diagnosis only. Existing RED observations are preserved; the user-directed batching exception permits implementation before a separate runtime RED launch for each new test. Full report scenarios and their outcomes remain mandatory evidence. Do not label a partially failing batch green.

The fixed 32-byte key header is agreed and has compiled successfully. Detached image implementation can consume that interface while the canonical registry is being implemented, rather than idling until its independent UE run. Shared integration still requires both tasks to pass.

## Impact

- No language, identity, lifetime, Engine registration or isolation behavior changes.
- Task 2.1 uses a single NativeEngine batch to include Bodies, Reflection, Preprocessor and Declarations.
- Other area commands remain available for focused diagnosis; the batch report may satisfy their verification without additional launches.
- Task 3.2 depends on accepted contracts 1.1, with its agreed stable-key ABI consumed from the parallel 3.1 implementation.

## Old Task Disposition

All task IDs, outcomes and existing completed work are preserved. No completed node is unchecked and no implementation scope is dropped.

## Diff Snapshot

- Affected status: dirty plugin submodule; new untracked active Change directory. Parent diff stat: one plugin gitlink dirtiness entry, no changed submodule commit.
- Task updates: ~execution context; ~2.1 verification command.
- Edge replacement: -3.2 <- 3.1; +3.2 <- 1.1.
- Artifacts: ~design.md; ~tasks.md; ~INDEX; +this record.

## Preserved Work

All existing user edits, retained-token fixes, new regression tests and initial RED reports remain unchanged. Stable-key implementation stays with its current owner; metadata ownership is a disjoint writer. Only root starts build/test operations.

## References and Result

Candidate graph was checked for known IDs and cycles before writing (13 nodes). Strict validation and task.status verify the applied state before implementation resumes. New task completion is based on actual Automation scenarios, not dispatch success or stale binaries.
