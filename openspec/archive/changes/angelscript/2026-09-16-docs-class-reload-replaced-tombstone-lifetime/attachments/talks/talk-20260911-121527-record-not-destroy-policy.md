# Record the tombstone; do not destroy it in this Change

## Context

The user asked to create a Change that records FullReload `_REPLACED_N` UClass lifetime and marks related materials for later replan, without choosing a destroy policy now.

## Evidence

- `CreateFullReloadClass` sets `CLASS_NewerVersionExists`, renames, and leaves RootSet/`RF_Standalone`.
- `CleanupRemovedClass` is the only inspected path that unroots a renamed `UASClass`.
- `ForceGarbageCollection(true)` is commented as old instances.
- `GetMostUpToDateClass` exists so stale pointers can walk `NewerVersion`.

## Options

| Option | Result |
| --- | --- |
| A. Docs Change that records the split and lists replan owners | Policy stays unchosen; later Change designs destroy/unroot/GC |
| B. Fix Change that unroots replaced classes after reinstancing | Needs a user-owned lifetime decision and a FullReload proving matrix |
| C. Spec that SHALL linger until editor shutdown | Locks today's tombstones as required product behavior |

## Settled Decision

Option A. This Change records; a later Change that chooses lifetime policy replans the listed owners.

## Consequences and Flip Condition

Do not add ClassGenerator lifetime edits or a current-spec SHALL for linger or collect. Flip when the user authorizes a lifetime-policy Change with an explicit destroy/unroot/GC decision and its proving command.

## Sources

- User request 2026-09-11: create a Change, record the `_REPLACED_N` tombstone fact, mark related materials for later replan.
- `Plugins/Angelscript/Source/AngelscriptRuntime/ClassGenerator/AngelscriptClassGenerator_FullReload.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/ClassGenerator/AngelscriptClassGenerator_Reinstancing.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/ClassGenerator/AngelscriptClassGenerator.cpp`
