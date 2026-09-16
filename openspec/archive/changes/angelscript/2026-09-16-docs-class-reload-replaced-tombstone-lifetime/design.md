## Context

FullReload replacement and script-deleted cleanup share the `_REPLACED_N` rename, but they do not share UObject lifetime flags.

```
CreateFullReloadClass                    // class still exists in script
└─ ReplacedClass
    ├─ CLASS_NewerVersionExists          // skip spawn / menus
    ├─ Rename APlayer_REPLACED_N
    ├─ NewerVersion = NewClass           // GetMostUpToDateClass walk
    ├─ RootSet and RF_Standalone kept
    └─ ScriptTypePtr cleared after swap  // cannot run old AS bodies

CleanupRemovedClass                      // class no longer in script
└─ same rename
    ├─ RemoveFromRoot
    └─ ClearFlags(RF_Standalone)          // GC candidate if unreferenced

post full reload
└─ ForceGarbageCollection(true)       // old instances, not a UClass contract
```

`NewObject<UASClass>(..., RF_Public | RF_Standalone | RF_MarkAsRootSet)` is how both the new class and the original class were created. Replacement does not undo those flags. `GetMostUpToDateClass` walks `NewerVersion` so stale CDO, Blueprint child, and `TSubclassOf` pointers can still find the current class.

## Goals / Non-Goals

**Goals:**

- Freeze the inspected replacement-tombstone lifetime as a reusable finding.
- List every owner a later lifetime-policy Change must replan.
- Keep the record parent-only.

**Non-Goals:**

- Unrooting, destroying, or pooling replaced `UASClass` objects.
- Changing SoftReload pointer retargeting, ClassReloadHelper reinstancing, or SDK `BodyConflict`.
- Current-spec language that requires either linger or collect.
- Editing sibling `tasks.md`.

## Decisions

### Record the split; do not pick a destroy policy here

The user asked to capture that `_REPLACED_N` is an intentional expired `UClass`, not immediate `BeginDestroy`, and to mark related materials for later replan. Choosing unroot-after-reinstance, generation GC, or keep-until-shutdown is a later user-owned decision.

Alternative considered: add a current-spec requirement that replaced classes linger until editor shutdown. Rejected because that would freeze the tombstone as desired product behavior before a policy round.

Alternative considered: unroot replaced classes in this Change. Rejected because reinstancing and Blueprint children still need the `NewerVersion` jump, and no proving matrix was authorized.

### Keep host GC comments in sibling Changes as host GC

`refactor-sdk-drop-native-gc` already forbids treating editor `CollectGarbage` as native AS GC. This record adds that the same `ForceGarbageCollection` call is about reinstanced instances, not a promise that `APlayer_REPLACED_N` is unreachable.

## Risks / Trade-offs

- Repeated FullReload accumulates `*_REPLACED_N` objects in the Angelscript package. The inventory must say that so a later policy can measure it.
- Historical ZH knowledge (`Type_ClassGeneration.md`) already states the `NewerVersion` chain. This Change does not rewrite that dump; a later policy Change decides whether live specs replace it.
- Reconstruction keeps DirectoryWatcher dormant. The recorded path is the preserved host implementation, not the current default startup.
