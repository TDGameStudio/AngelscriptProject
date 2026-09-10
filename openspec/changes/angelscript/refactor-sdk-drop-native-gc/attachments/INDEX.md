# INDEX

## Current position

Planning complete for `angelscript/refactor-sdk-drop-native-gc`. Ready work starts at 1.1 after apply. Product code is unchanged.

## Hard conclusions

- The Unreal plugin does not use AngelScript native GC; UObject + `ReferenceSchema` remain required.
- The reconstructed VM currently does use `as_gc.cpp` and the current VM spec requires cycle collection; this Change drops that requirement.
- Runtime unrooted cycles leak; shutdown walks VM object leases.
- `feature-memory-gc-observability` and `feature-types-explicit-ownership` must replan; this Change does not edit them.

## Forbidden

- Do not no-op `GarbageCollect` to keep a fake collector API.
- Do not remove `DetectAngelscriptReferences` / `EmitReferenceInfo`.
- Do not treat Unreal `CollectGarbage` during class reload as native AS GC.
- Do not enable `WITH_ANGELSCRIPT_UNITTESTS` to keep old collector tests compiling.

## Attachment index

- talks/talk-20260910-171000-drop-native-gc.md — why delete the collector despite live VM cycle tests — read before revisiting scope
