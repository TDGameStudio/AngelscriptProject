## Context

Two ownership domains already exist:

```
UObject / UASClass instance     -> UE GC + ReferenceSchema
Native VM object (asVm header)  -> AddRef/Release + asCGarbageCollector
```

The plugin path never puts game objects on the native collector. `AngelscriptEngine` sets `asEP_AUTO_GARBAGE_COLLECT` to 0, UObject binds use `asOBJ_NOCOUNT`, and `UASClass::AllocScriptObject` calls `StaticAllocateObject`. The reconstructed VM still allocates non-UObject objects, registers `asOBJ_GC` types in tests, and `asCScriptEngine::ShutDownAndRelease` calls `GarbageCollect()` then `gc.ReportAndReleaseUndestroyedObjects()`.

Current `angelscript/runtime/vm` requires reclaiming unreachable cycles. This Change drops that requirement. Host Unreal GC is unchanged.

## Goals / Non-Goals

**Goals:**

- Remove the native cycle collector implementation and its public API.
- Keep acyclic refcounted destruction and Engine shutdown lease drain.
- Keep Unreal `DetectAngelscriptReferences` / `EmitReferenceInfo` / `NeverRequiresGC`.
- Make leftover `asOBJ_GC` publication fail loudly.

**Non-Goals:**

- A new cycle detector, tracing GC, or compile-time cycle checker.
- Changing UObject lifetime, hot-reload `CollectGarbage`, or Blueprint reinstancing.
- Reactivating dormant legacy SDK tests as a supported config.
- Editing sibling Changes in place. They replan separately.

## Decisions

### Delete the collector instead of no-op APIs

Leaving `GarbageCollect` as success-with-no-work would hide cycles and keep a fake contract. Tests and hosts that still call it would look green. Removing the methods forces every caller to choose last-release or shutdown drain.

Alternative considered: keep the files and return `asNOT_SUPPORTED`. Rejected because the user asked to delete unused collector code, and the remaining Engine member, flags, and GC behaviours would stay as a second lifetime model.

### Reject `asOBJ_GC` instead of ignoring it

Ignoring the flag would let metadata dumps, standalone registration, and tests keep advertising garbage-collected types. Rejection maps the flag to an explicit publication error. `$func` and `asCCallableType` drop the flag and use ordinary refcount.

### Runtime cycles leak; shutdown walks leases

Breaking cycles at runtime is the only job `as_gc.cpp` had. Without it, an unrooted self-cycle stays allocated while the Engine lives. `vmObjectLeases` already tracks native VM objects for shutdown; drain that list instead of `gc.ReportAndReleaseUndestroyedObjects()`.

Alternative considered: forbid any ref type that can store its own handle. Rejected as a language-frontend feature outside this Change.

### Weak refs follow last release

`GetWeakRefFlagOfScriptObject` remains. Invalidation happens when the object is destroyed by last `Release` or shutdown drain, not after a collector detect pass. `VMGC.WeakRefValidThenInvalidAfterCollection` is replaced by a last-release case.

### Unreal GC stays a host schema problem

Script-held `UObject*` values that are not `UPROPERTY` still need `DetectAngelscriptReferences`. `FTraceHandle` and similar types still use `NeverRequiresGC()`. This Change must not fold that work into the deleted native collector.

### Sibling Changes replan; this Change does not patch them

`feature-memory-gc-observability` cannot instrument collector phases after this lands. `feature-types-explicit-ownership` still plans per-Engine instance cycle collection. Those records keep their IDs; their owners replan against this spec delta.

## Risks / Trade-offs

| Risk | Handling |
|---|---|
| Native VM tests currently prove cycle reclamation | Replace `VMGC` and drain tests that call `GarbageCollect`; expected destructor counts change from "1 after collect" to "0 after execute, 1 after last release or shutdown drain" |
| Delegate capture cycles leak at runtime | Accepted. UE `FScriptDelegate` stays weak on UObject; native funcdef delegates are refcounted |
| Shutdown must still destroy leftovers | Use existing VM object leases; do not resurrect `asCGarbageCollector` for teardown |
| Legacy `AngelscriptNativeGarbageCollectorTests.cpp` includes `as_gc.h` | Exclude or stub that file on every enabled target so the removed header cannot break the build |
| `feature-types-explicit-ownership` tasks still list `as_gc.*` | Documented conflict; that Change replans after this spec is accepted |

Flip condition: if native non-UObject objects must reclaim unrooted cycles while the Engine is live, abandon this Change and keep `as_gc.cpp`.
