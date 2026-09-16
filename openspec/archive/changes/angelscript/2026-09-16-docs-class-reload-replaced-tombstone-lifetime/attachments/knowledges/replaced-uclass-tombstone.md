# Replaced UASClass tombstones

disposition: candidate

## Reusable Insight

FullReload replacement does not `BeginDestroy` the previous `UASClass`. It renames that object to `_REPLACED_N`, sets `CLASS_NewerVersionExists`, and points `NewerVersion` at the new class. The tombstone is out of lookup and spawn. It exists so CDO, Blueprint children, and other stale `UClass*` holders can walk `GetMostUpToDateClass`. After live instances reinstance, RootSet and `RF_Standalone` usually keep the tombstone until editor shutdown. `ForceGarbageCollection(true)` after reload is about old instances, not a contract that the replaced class is collected.

Script-deleted classes share the rename but also `RemoveFromRoot` and clear `RF_Standalone` in `CleanupRemovedClass`. That is the unroot path. Replacement does not use it.

## Evidence

- `CreateFullReloadClass` in `Plugins/Angelscript/Source/AngelscriptRuntime/ClassGenerator/AngelscriptClassGenerator_FullReload.cpp`: `CLASS_NewerVersionExists`, `Rename` to `%s_REPLACED_%d`, new object with `RF_Public | RF_Standalone | RF_MarkAsRootSet`, `ReplacedClass->NewerVersion = NewClass`.
- `CleanupRemovedClass` in `Plugins/Angelscript/Source/AngelscriptRuntime/ClassGenerator/AngelscriptClassGenerator_Reinstancing.cpp`: same rename, then `RemoveFromRoot` and `ClearFlags(RF_Standalone)`.
- `FAngelscriptClassGenerator::PerformReload` in `AngelscriptClassGenerator.cpp`: nulls `ScriptTypePtr` on `ReplacedClass`, then `GEngine->ForceGarbageCollection(true)` with the comment that it avoids littering old instances.
- `UASClass::GetMostUpToDateClass` in `ASClass_Metadata.cpp` walks `NewerVersion` until the tip.
- Engine teardown in `AngelscriptEngine.cpp` unroots `UASClass` objects owned by a released Engine; that is shutdown, not per-reload destroy.

## Boundaries

- Does not decide whether a later Change should unroot, pool, or collect replacement tombstones.
- Does not describe SoftReload, which retargets `UASFunction::ScriptFunction` on the same `UASClass`.
- Historical ZH dumps may still say the `NewerVersion` chain; they are not current specs.
- SDK `BodyConflict` and dormant DirectoryWatcher are separate layers.

## Application

Use this split when planning host hot reload, UObject generation GC, or FullReload tests. Do not treat a surviving `*_REPLACED_N` object as an accidental leak until a lifetime-policy Change says otherwise. Do not treat `ForceGarbageCollection` as proof the old `UClass` is gone.

## Sources

- `openspec/changes/angelscript/docs-class-reload-replaced-tombstone-lifetime/design.md`
- `openspec/changes/angelscript/docs-class-reload-replaced-tombstone-lifetime/attachments/talks/talk-20260911-121527-record-not-destroy-policy.md`
- `Plugins/Angelscript/Source/AngelscriptRuntime/ClassGenerator/AngelscriptClassGenerator_FullReload.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/ClassGenerator/AngelscriptClassGenerator_Reinstancing.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/ClassGenerator/AngelscriptClassGenerator.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/ClassGenerator/ASClass_Metadata.cpp`
