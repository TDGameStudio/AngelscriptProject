---
issue_schema: openspec-material-issue-v2
issue_id: issue-20260908-092042-borrowed-constructor-unwind
status: resolved
source: verification
source_ref: cb61a0dc77104497861eaeca5a9702c8
affected_tasks: ["6.8"]
resolved_at: 2026-09-08T09:45:46.885771+08:00
resolution_ref: "data/residual-admission-verification.md#68-frame-owned-lifetime-admission"
created_at: 2026-09-08T09:21:27.986033+08:00
---

## Symptom

After implementing verified construction states, source unwind corrupts the allocator following failed constructor execution. Basic lifetime admission remains 12/12 GREEN.

## Investigation Log

Shared VM 60116d7161cb4574a3364f4d8a9fa83c crashed after BrokenConstructorDestroysCompletedLocalOnly. Unwind-only 83f9d5ff694045d891a3b320fbe8afb3 reproduced heap corruption at a later allocation. Exact BrokenConstructorDestroysCompletedLocalOnly with ExtraArguments=@('-stompmalloc') run cb61a0dc77104497861eaeca5a9702c8 moved the failure to Free in CleanStackFrame during Execute. No source mutation occurred between these runs.

Additional diagnosis: ordinary source regression 7ad6823f37824b779eb9fbacefb5b0d5 passed all 112 cases, but stomp run c15916ececc2493a829927f6490ffdab caught a remaining out-of-bounds read in ReleaseRegisteredVmPayloadsFromFrame at the Slot read (line 5909). Top-level no-argument Frame is one-past-stack, so offset zero is never a local. The fallback now scans complete pointers inside Frame[-Dwords..-1], including the final complete local pointer. This is a second invalid assumption in the same fallback ownership/range boundary.

## Root Cause

ReleaseRegisteredVmPayloadsFromFrame scans offset zero and matching local payloads without distinguishing borrowed this from owned locals. The constructor receiver is the caller's pending allocation. Its premature release leaves the caller's tracked unconstructed slot stale; the new correct not-constructed state then reaches raw free of that stale payload. The prior marker placement concealed the ownership error. The exact destructor-exclusion regression is being added before repair.

## Disposition

Repair within 6.8 after the indexed boundary replan. Preserve borrowed receivers/reference arguments and aliases while retaining owned manual-frame drain behavior. Separately repair the immediate source conditional-return producer defect inside existing scope; it is an ordinary local fix, not this issue's root cause.

## Evidence

### Failure Evidence (RED)

Harness ue.test NativeEngine.VMSourceUnwind (83f9d5ff694045d891a3b320fbe8afb3), and exact NativeEngine.VMSourceUnwind.BrokenConstructorDestroysCompletedLocalOnly with Fast=true, TimeoutMs=600000, ExtraArguments=@('-stompmalloc') (cb61a0dc77104497861eaeca5a9702c8) both failed exit 3. Raw run-local Unreal.log retains call stacks. No complete report exists.

### Resolution Evidence (GREEN)

Build 85253bd4e50f49ad8785de7730e280b8, stomp unwind 2084fffa9dc645ddb261a9ec51ca3143 eight/eight Success, and shared VM 7e2826123d8f48a79cef82f34b6636c2 381/381 Success without warnings prove the corrected consumer. The stomp run has one unrelated engine LogHttp network probe timeout warning. Exact public cases and source identity are retained in data/residual-admission-verification.md.

### What This Proves

Failed-constructor unwind has an allocator failure in the new consumer path and the original no-Context-edit boundary is invalid.

### What This Does Not Prove

The crash alone does not prove all alias ownership cases. Dedicated destructor and retained-reference controls and affected regression are still required.

## Links

- `../replans/replan-20260908-092042-borrowed-constructor-unwind.md`
- `../data/residual-admission-verification.md`
