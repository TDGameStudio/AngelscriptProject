# Drop native AngelScript cycle collection

## Context

The user asked to delete AngelScript's built-in GC because the Unreal plugin does not need it. Explore confirmed the plugin path is already off the collector, while the reconstructed VM and current `angelscript/runtime/vm` spec still require cycle reclamation.

## Evidence

- Plugin Engine: `asEP_AUTO_GARBAGE_COLLECT = 0` in `AngelscriptEngine.cpp`.
- UObject binds: `asOBJ_REF | asOBJ_NOCOUNT | asOBJ_IMPLICIT_HANDLE`.
- Script instances: `UASClass::AllocScriptObject` -> `StaticAllocateObject`.
- `asCScriptObject` GC notify is commented out.
- Host schema: `DetectAngelscriptReferences` still emits UE `ReferenceSchema`.
- VM: `as_gc.cpp` compiled; `VMGC` 9 methods call `GarbageCollect`; shutdown calls `GarbageCollect()` then `gc.ReportAndReleaseUndestroyedObjects()`.
- Current spec: "SDK SHALL reclaim unreachable AS cycles".
- Sibling Changes: observability non-goal is removing AS GC; explicit-ownership still plans instance cycle collection.

## Options

| Option | Result |
| --- | --- |
| A. Delete `as_gc` and drop the VM cycle contract | Matches the plugin model; VM tests and two active Changes must replan |
| B. Keep SDK GC, only document plugin bypass | Collector stays "have but unused" on the plugin path; user request rejected |
| C. No-op public `GarbageCollect` | Code remains; tests can fake success |

## Settled Decision

Option A. Reject `asOBJ_GC`. Destroy acyclic objects on last release. Leak unrooted cycles while the Engine lives. Drain remaining VM leases at shutdown. Keep Unreal GC schema emission.

## Consequences and Flip Condition

`VMGC.UnrootedSelfCycleFinalizesOnce` and `DelegateCaptureCycleIsReclaimed` cease to be requirements. If native non-UObject objects must reclaim unrooted cycles at runtime, abandon this Change.

## Visual

```
UObject script instance  -> UE GC + ReferenceSchema   (kept)
Native VM asOBJ_REF      -> last Release / shutdown    (kept)
asCGarbageCollector      -> deleted
asOBJ_GC publication     -> explicit error
```

## Sources

- `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/ClassGenerator/ASClass_Construction.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_gc.cpp`
- `openspec/specs/angelscript/runtime/vm/spec.md`
- `Temp/gc/as-gc研究.md`
