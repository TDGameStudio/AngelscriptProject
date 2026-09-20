# INDEX

## Maintenance baseline — 2026-09-12

Read [Current-baseline maintenance](data/maintenance-20260912.md) before historical attachments. It records current source ownership, preserved task state, exact format checks and remaining planning boundaries. Historical talks, research snapshots and applied replans are provenance rather than current API authority.

## Current position

Planning complete for `angelscript/refactor-sdk-drop-native-gc`. Ready work starts at 1.1 after apply. Product code is unchanged.

## Hard conclusions

- The Unreal plugin does not use AngelScript native GC; UObject + `ReferenceSchema` remain required.
- The reconstructed VM currently does use `as_gc.cpp` and the current VM spec requires cycle collection; this Change drops that requirement.
- Runtime unrooted cycles leak; task 2.1 must establish enumerable shutdown membership; the current vmObjectLeases value is only a count.
- Memory observability now targets the accepted removal. Type-ownership and compile-lifecycle predecessors are immutable completed archives; this Change migrates current SDK callers.

## Forbidden

- Do not no-op `GarbageCollect` to keep a fake collector API.
- Do not remove `DetectAngelscriptReferences` / `EmitReferenceInfo`.
- Do not treat Unreal `CollectGarbage` during class reload as native AS GC.
- Do not enable `WITH_ANGELSCRIPT_UNITTESTS` to keep old collector tests compiling.

## Attachment index

- talks/talk-20260910-171000-drop-native-gc.md — why delete the collector despite live VM cycle tests — read before revisiting scope

- [Applied current-baseline replan](replans/replan-20260912-073639-current-baseline.md) — accepted record maintenance; current paths, ownership and proof boundaries; read before resuming the pending plan.
