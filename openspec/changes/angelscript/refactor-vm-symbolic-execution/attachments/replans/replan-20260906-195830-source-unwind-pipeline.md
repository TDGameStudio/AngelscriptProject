---
replan_id: replan-20260906-195830-source-unwind-pipeline
status: applied
source: implementation
source_ref: "10.5 VMSourceUnwind: emission-only images fail verifier/link/EXCEPTION cleanup; GREEN 44bea54f7f374930b7b057e426529124 required builder/linker/as_context.cpp/as_vm_object.cpp"
scope: "10.5 owns the source-exception pipeline, not emitter-only records"
base_commit: d8343d314f0b948a43a323fc443cf305ff2f5dc3
base_tasks_sha256: 6359c476bc192df4fa2d27fb252d941831e5464de35ede5e1a4b9404ac8b7bd0
result_tasks_sha256: a96bdc3727bdf143ac3d081a19dcea455f85ba5230f136074e301f94543a3bf0
created_at: 2026-09-06T19:58:30+08:00
resume_task: "10.5"
---

## Trigger and Evidence

Ready 10.5 `VMSourceUnwind` cannot be proven from emitter-only Files. Observed RED: Finish left Cleanup TypeSlot unmapped and `InitializedObjectSlots` empty (verifier Unverified); linker `objVariablesOnHeap=0` treated ALLOC heaps as in-place; `Execute` returned EXCEPTION without `CleanStack`; heap SDK objects used UASClass `ReleaseRawScriptObject`; SCRIPT `~Box` never ran through SYSTEM-only `asVmInvokeDestruct`; `Broken X;` ALLOC-only skipped constructor `Fail`. GREEN `44bea54f7f374930b7b057e426529124` required `as_bytecode_image_builder.*`, `as_bytecode_linker.*`, `as_context.cpp` and `as_vm_object.cpp`. The user expanded those Files without an applied record; card prose still said emitter-only.

This invalidates the 10.5 task boundary, not the 10.4/10.5 split or the DAG.

## Decision

Keep task ID 10.5, verify prefix and incoming edges. Own the source-exception pipeline on that node: Exception DestroyObject as `asOBJ_INIT`, Normal as `asOBJ_UNINIT`; Finish TypeSlot remap; link `objVariablePos`/`Info`/`Types`/`objVariablesOnHeap` and lineNumbers; `CleanStack` before EXCEPTION; SCRIPT dtors via `metadataBehaviours` and SDK heap `asVmRelease`; default-ctor CALL after ALLOC-without-ConstructExpr. Do not add 10.6: one prefix proves one feature group. Codec remains 6.2/11.1. No new 8.7/9.4. 11.2 Files stay emitter/support until its own RED.

## Impact

No Task ID or edge change. Design canonical-source handoff now describes the pipeline. 10.5 Files already listed the extra owners; card/design/INDEX now match. Shared builder/linker with completed 11.1 serialize at apply time; do not invent 10.5←11.1.

## Old Task Disposition

- 10.5 pending, same ID; Files/handoff corrected
- 10.4 preserved GREEN (lexical/transfer destroy)
- 8.3/8.5 preserved (object domain / Context limits; not source-emitted exception cleanup)
- All other checked nodes preserved

## Diff Snapshot

```text
?? openspec/changes/angelscript/refactor-vm-symbolic-execution/
```

git diff --stat is empty for this untracked Change.

- Task + / -: none
- Task ~: 10.5 pipeline ownership and cases
- Edge + / -: none; same acyclic 44-node graph, Ready 10.5
- Artifact ~: tasks.md, design.md, INDEX.md, acceptance-gap-matrix.md
- Artifact +: this applied record

## Preserved Work

No product/test source is edited by this record. Historical 1.1-5.5, follow-ups through 10.4 and 11.1 stay `[x]`. Prior applied replans and both Review files stay immutable. Existing `VMSourceUnwind` GREEN is evidence that the Files are necessary; this record does not mark 10.5 complete.

## References and Result

Resume at Ready 10.5. Re-run `Angelscript.UnitTest.NativeEngine.VMSourceUnwind`, record Evidence, then `[x]`. 11.2 starts only after that checkbox. Strict change validation is the planning proof.
