## Why

The Unreal plugin does not use AngelScript's native cycle collector. Script classes allocate as UObject through `UASClass::AllocScriptObject`, native UObject binds register as `asOBJ_REF | asOBJ_NOCOUNT | asOBJ_IMPLICIT_HANDLE`, and the plugin Engine sets `asEP_AUTO_GARBAGE_COLLECT` to 0. `asCScriptObject` no longer notifies `asCGarbageCollector`. Host lifetime is Unreal GC plus `DetectAngelscriptReferences` / `EmitReferenceInfo`.

The maintained SDK still compiles `as_gc.cpp`, exposes `GarbageCollect` / `NotifyGarbageCollectorOfNewObject`, marks `$func` and callable types `asOBJ_GC`, and the current `angelscript/runtime/vm` spec requires cycle collection. NewVersion tests (`VMGC`, shutdown/root drain) still prove unrooted cycles, weak-ref invalidation after collection, and delegate-capture reclamation.

That collector is unused on the plugin path and expensive to keep as a second ownership domain. This Change removes it from the maintained SDK and replaces the VM contract with reference counting, explicit last-release destruction, and Engine shutdown lease drain. Unreal GC integration is not removed.

## What Changes

- Delete `as_gc.cpp` / `as_gc.h` and the Engine's `asCGarbageCollector` member.
- Remove public native GC APIs and flags: `GarbageCollect`, `GetGCStatistics`, `NotifyGarbageCollectorOfNewObject`, `GetObjectInGC`, `GCEnumCallback`, `ForwardGCEnumReferences`, `ForwardGCReleaseReferences`, `asGC_*`, `asEP_AUTO_GARBAGE_COLLECT`, and GC behaviours (`asBEHAVE_GETREFCOUNT`, `SETGCFLAG`, `GETGCFLAG`, `ENUMREFS`, `RELEASEREFS`).
- Reject `asOBJ_GC` at type publication and metadata definition. `$func` / callable types lose that flag.
- VM objects stay refcounted. Last `Release` runs the destructor. Unrooted cycles are not reclaimed at runtime. Engine shutdown walks remaining VM object leases and destroys them instead of running a collector.
- Weak flags still follow the target's last release, not a collector pass.
- Keep Unreal GC: `DetectAngelscriptReferences`, `EmitReferenceInfo`, `NeverRequiresGC`, and editor `CollectGarbage` during class reload.
- Rewrite NewVersion tests that call `Engine->GarbageCollect` or register `asOBJ_GC`. Dormant legacy GC tests must not compile against removed headers if they remain in any enabled target.

## Capabilities

### New Capabilities

None. This Change removes a collector; it does not add a capability.

### Modified Capabilities

- `angelscript/runtime/vm`: remove the requirement that the SDK reclaim unreachable AS cycles. Native objects destroy on last release or Engine shutdown lease drain. `asOBJ_GC` and public collector APIs are absent. Unreal object GC remains a host concern.

## Impact

Product implementation belongs in `Plugins/Angelscript`: maintained ThirdParty SDK, Runtime Engine setup, dump/registration inventories, NewVersion NativeEngine VM tests, and Standalone architecture inventory. Parent-repository changes are this OpenSpec record and later spec sync. `Source/AngelscriptProject` stays untouched.

Active Changes that still assume a native collector must replan after this record is accepted; this Change does not edit their files:

- `angelscript/feature-memory-gc-observability` lists removing AS GC as a non-goal and plans collector-phase instrumentation.
- `angelscript/feature-types-explicit-ownership` still requires per-Engine instance cycle collection (`Lifetime.Cycles`, `Lifetime.MetadataAndObjectGC`, delta requirement "Instance GC and metadata ownership remain separate").

## Boundaries

- Do not remove or weaken Unreal GC schema emission for script-held `UObject` references.
- Do not introduce a replacement cycle detector, tracing GC, or automatic cycle-break at runtime.
- Do not restore dormant legacy AngelScript startup or `WITH_ANGELSCRIPT_UNITTESTS` as a live path.
- Do not change script syntax, bytecode opcodes, or UE delegate/`FScriptDelegate` behaviour.
- Cycles among refcounted non-UObject objects leak until Engine shutdown drain; that is accepted, not a defect.

## Acceptance

After this Change:

1. `as_gc.cpp` is gone and the public Engine interface has no garbage-collect methods or `asEP_AUTO_GARBAGE_COLLECT`.
2. Publishing a type with `asOBJ_GC` fails with an explicit invalid-flag error; no object is admitted to a collector list.
3. An acyclic refcounted VM object destructor runs exactly once on last `Release`.
4. An unrooted self-cycle or two-node cycle is still alive after the former full-collection point; Engine shutdown then destroys remaining leased objects.
5. Plugin UObject script classes still allocate through `StaticAllocateObject` and still emit Unreal `ReferenceSchema` for non-UPROPERTY script references.
6. `VMGC` cycle-reclamation cases are gone or replaced; remaining NativeEngine VM lifetime tests pass without calling `GarbageCollect`.
