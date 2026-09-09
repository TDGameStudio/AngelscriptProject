---
replan_id: replan-20260908-101200-native-auxiliary-transport
status: applied
source: verification
source_ref: "run-8ae4a58ca4774c4db1456afd19601600; GenericCallbackObservesAuxiliary"
scope: "Task 2.5 native auxiliary sidecar and generic invocation ownership"
base_commit: a9afd56e73b9289ed32dee8210d7b96ac0b3b578
base_tasks_sha256: 0c1016b194c1caa10ae7306532fa637f5e9048cf69cac17e02dc6b83e54d7603
result_tasks_sha256: ea2a56b5956009319a830c5194fe141f7cb30479363bf92ebcbb6c1bfaa65159
created_at: 2026-09-08T10:13:42.628Z
resume_task: "2.5"
---

## Trigger and Evidence

Shared RuntimeBindings run 8ae4a58ca4774c4db1456afd19601600 exited 3 during GenericCallbackObservesAuxiliary, with a null read in the fixture callback. Four preceding native cases completed successfully, but the crash left no complete report and is not GREEN. The callback used GetAuxiliary; asCGeneric delegates it to asCScriptFunction::GetAuxiliary, whose current implementation returns zero. The recorded address reaches DetectCallingConvention, but asSSystemFunctionInterface has no auxiliary field. Task 2.5 promises generic auxiliary support but omits these owning files.

## Decision

Extend task 2.5's Files to as_callfunc.* and as_generic.*. Preserve auxiliary data in the per-engine callable sidecar, copy it with each binding generation, and pass the exact acquired generation into the generic invocation. Frozen function metadata remains unchanged. Make the fixture observe and assert the auxiliary pointer before dereferencing, so this failure becomes a reportable assertion instead of terminating the entire proving run.

## Impact

No behavior requirement, task ID, dependency edge, proving selector or completed checkbox changes. Candidate validation preserves the exact YAML Task DAG, 42 outcomes and six completed nodes. Only the pending task's file ownership expands. Design records the existing per-engine ownership contract's concrete auxiliary transport.

## Old Task Disposition

Task 2.5 remains pending and Ready. No task is reopened or superseded.

## Diff Snapshot

- Before status: the active Change and new task 2.5 test/apply/native batch files are untracked. Existing task 2.5 FunctionCallers.h and as_scriptengine.h have in-progress edits.
- Newly required as_callfunc.h/.cpp and as_generic.h/.cpp are unchanged against the plugin HEAD. as_context.cpp is also unchanged before this correction.
- Task ~2.5 Files only. Task +/-: none. Edge +/-: none.
- Artifact ~design.md, ~tasks.md, ~INDEX.md; add this applied record and the inverse task hunk.

## Preserved Work

Preserve all six completed proofs, initial 15-case native RED, current native implementation, the incomplete crash evidence, full Runtime provider scope and the separate open Harness admission issue. No product code is changed by this planning update.

## References and Result

Resume task 2.5 after strict validation. The bounded data/replans/replan-20260908-101200-native-auxiliary-transport-before.patch restores the prior uncommitted task hunk. Source and result hashes above bind the task versions; this record is immutable. The current proving run must be repeated completely after the auxiliary fix.
