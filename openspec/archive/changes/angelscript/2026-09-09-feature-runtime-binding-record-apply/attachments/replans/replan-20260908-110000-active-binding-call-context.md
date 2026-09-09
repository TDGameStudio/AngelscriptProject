---
replan_id: replan-20260908-110000-active-binding-call-context
status: applied
source: verification
source_ref: "task-3.3; run-fa5053495ab144c3b7293826e348a0a9"
scope: "Task 3.3 active native call auxiliary transport"
base_commit: a9afd56e73b9289ed32dee8210d7b96ac0b3b578
base_tasks_sha256: b797363349cd20eb2d7e9c243709a7d844df14d24f7091cf705d68278135fb64
result_tasks_sha256: 0ba2cd931a6164a3266a9105ab66396b821886cce75b492f9a8db9dadc3b453a
created_at: 2026-09-08T11:00:11.940Z
resume_task: "3.3"
---

## Trigger and Evidence

Isolation RED fa5053495ab144c3b7293826e348a0a9 exited 255 with five failures and four existing controls successful. NativeCallbacksResolveTheExecutingOwnerAndAdapter and GenericExecutionOverridesAmbientScopeAndRestoresIt fail owner identity. GenericRuntimeHelperReadsTheCapturedAuxiliary, NativeAuxiliaryAndOwnerRestoreAfterNestedOtherEngineCall and RebindingOneOwnerKeepsActiveAuxiliaryGenerationAndOtherOwner return -1 because the Runtime helper reads null frozen metadata userData. The report SHA-256 is E893ECCF97503727911419C156D2D5EC4461619112FAF0FD6A1D9A6E9FFFF28D.

Source inspection confirms TryGetCurrentEngine starts with the ambient scope stack, while GetCurrentFunctionUserDataPtr reads asCScriptFunction::userData. Task 2.5 correctly captures auxiliary in each acquired native binding generation, but task 3.3 omits as_context.* where that exact invocation is held. Looking up the newest sidecar during a running callback would violate the executing-generation requirement.

## Decision

Extend pending task 3.3 Files to as_context.*. Resolve an active Context's exact native Engine before an ambient scope. Expose auxiliary data only for the duration of its acquired native invocation, restoring the previous value after nesting. The binding Runtime helper consumes that invocation data. Preserve immutable metadata and the dormant legacy helper path.

## Impact

Only task 3.3 ownership expands. Candidate validation compares the complete YAML graph and all checkbox/verification lines byte-for-byte; all 42 nodes, eight completed nodes, prerequisites and proving selectors remain unchanged. Current design makes this exact call-data boundary explicit. No new task or user-facing requirement is introduced.

## Old Task Disposition

Task 3.3 is preserved, pending and Ready. All completed tasks remain checked.

## Diff Snapshot

- Before status: current Change and Isolation test are untracked; Core/AngelscriptEngine.cpp is modified by preceding tasks.
- as_context.cpp already contains task 2.5's two-line generic auxiliary argument change (one insertion/one deletion); as_context.h is unchanged against plugin HEAD.
- Task ~3.3 Files; Task +/- none; Edge +/- none.
- Artifacts ~design.md, ~tasks.md, ~INDEX.md; add this record and its inverse task hunk.

## Preserved Work

Preserve all prior task proofs, the full Runtime provider objective, the nine-case Isolation RED report and four passing ownership controls, and the open Harness external-build admission issue. No product code is modified in this planning update.

## References and Result

The inverse uncommitted task hunk is data/replans/replan-20260908-110000-active-binding-call-context-before.patch. Resume 3.3 after strict validation; implementation requires fresh complete GREEN and adjacent VM native-call verification because invocation transport changes. This applied record is immutable.
