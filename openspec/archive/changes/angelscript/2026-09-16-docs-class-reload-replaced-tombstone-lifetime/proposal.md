## Why

FullReload creates a new `UASClass` and renames the previous object to `_REPLACED_N`. That renamed object is an intentional tombstone: it is not `BeginDestroy`'d, it is excluded from lookup and spawning, and it only exists so holders of the old `UClass*` can walk `NewerVersion` to the current class. After live instances reinstance, the tombstone usually stays rooted/`RF_Standalone` until editor shutdown.

That lifetime is easy to misread as a leak or as a missing `BeginDestroy`. A later lifetime-policy Change needs the current split recorded: replacement tombstones stay; script-deleted classes are unrooted; `ForceGarbageCollection` targets old instances, not the replaced `UClass`.

Skipped-gate assumption: this Change only records that fact and inventories related owners for a later replan. It does not choose or implement unroot, `BeginDestroy`, or GC of replaced classes.

## What Changes

- Record the replacement-tombstone versus script-deleted unroot split in a change-local knowledge candidate.
- Inventory code, tests, historical knowledge, current specs, and active Changes that must replan before any later destroy/GC policy.
- Do not edit plugin source, ClassGenerator, ClassReloadHelper, SDK linker, or current capability specs.

## Capabilities

### New Capabilities

None. This Change does not add a host hot-reload or UClass-lifetime capability.

### Modified Capabilities

None. Current specs do not require `_REPLACED_N` objects to linger or to be destroyed. A later policy Change owns any durable requirement.

## Impact

Parent-repository OpenSpec record only. `Plugins/Angelscript` source and tests stay unchanged.

Active Changes that still talk about class reload, host GC, or UObject generation must replan themselves when a lifetime policy is chosen. This Change lists them and does not edit their `tasks.md`:

- `angelscript/refactor-sdk-drop-native-gc` keeps host `CollectGarbage` during class reload and treats it as Unreal GC, not native AS GC.
- `angelscript/feature-memory-gc-observability` treats UObject occupancy as a host view; replaced `UASClass` tombstones are an uncounted generation.
- `angelscript/refactor-defaults-constructor-unification` depends on CDO replay and reinstancing after FullReload.

## Boundaries

- Do not `RemoveFromRoot`, clear `RF_Standalone`, or `BeginDestroy` replaced classes in this Change.
- Do not lock the current linger-until-shutdown behavior into a current spec SHALL.
- Do not edit sibling Change Task DAGs.
- Do not treat `ForceGarbageCollection(true)` after reinstancing as proof that the old `UASClass` is collected.
- Reconstruction startup dormancy stays; this record does not reactivate DirectoryWatcher.
