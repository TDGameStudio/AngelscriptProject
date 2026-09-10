---
task_graph:
  version: 1
  depends_on:
    "1.1": []
    "2.1": ["1.1"]
    "3.1": ["2.1"]
---

Import the Harness module in the current PowerShell 7 session and keep one Context for every proving command:

```powershell
Import-Module ./.agents/skills/harness/scripts/Harness.psd1
$context = New-HarnessContext -WorkspaceRoot (Get-Location).Path
```

NewVersion CQTest identities stay under `Angelscript.UnitTest.NativeEngine.<Area>.<Scenario>`. Do not enable `WITH_ANGELSCRIPT_UNITTESTS`. Do not call Unreal `CollectGarbage` as a substitute for the deleted native collector in NativeEngine tests.

Current collector callers to consume: `VMGCTests.cpp` methods `EngineGarbageCollectAfterExecution`, `UnrootedSelfCycleFinalizesOnce`, `UnrootedTwoNodeCycleFinalizesEachOnce`, `RootedCycleSurvivesThenDies`, `WeakRefValidThenInvalidAfterCollection`, `RefCpyVBalancesAddRefRelease`, `PreparedContextRootsLiveObject`, `FullAndIncrementalReachSameDestructorSet`, `DelegateCaptureCycleIsReclaimed`; plus `GarbageCollect` / `asOBJ_GC` uses in `VMShutdownDrainTests.cpp`, `VMRuntimeDrainTests.cpp`, `VMRootLifetimeTests.cpp`, `VMIntegrationTests.cpp`, `VMDispatchTests.cpp`, and `CallableSDKTests.cpp`.

- [ ] 1.1 Reject asOBJ_GC publication and stop writing VM tests against the collector

    **Outcome**

    Publishing a type with `asOBJ_GC` or a GC behaviour fails with an explicit error. NativeEngine tests allocate ordinary `asOBJ_REF | asOBJ_SCRIPT_OBJECT` objects and no longer call `GarbageCollect`, `GetGCStatistics`, or `SetEngineProperty(asEP_AUTO_GARBAGE_COLLECT, ...)`. Unrooted cycles are asserted to stay alive after execute. Acyclic last-release destruction remains. This task does not delete `as_gc.cpp`.

    **Context and interfaces**

    `asCScriptEngine::RegisterObjectType` currently allows `asOBJ_REF | asOBJ_GC` and rejects combining `asOBJ_GC` with `asOBJ_NOCOUNT`. Metadata `DefineType` in `FDetachedDefinitionFixture` forwards flags into the image. After this task, both surfaces reject `asOBJ_GC` and `asBEHAVE_GETREFCOUNT` / `SETGCFLAG` / `GETGCFLAG` / `ENUMREFS` / `RELEASEREFS`.

    Replace class `VMGC` in `VMGCTests.cpp` with class `VMLifetime` under TestDir `Angelscript.UnitTest.NativeEngine`. Keep `RefCpyVBalancesAddRefRelease` and `PreparedContextRootsLiveObject` as last-release / context-root cases without a collect call.

    **Cases**

    | Case | Input | Expected | Role |
    | --- | --- | --- | --- |
    | RejectGcFlag | `DefineType(..., asOBJ_REF \| asOBJ_GC \| asOBJ_SCRIPT_OBJECT)` then freeze/register | publication error; type not usable | New RED |
    | RejectGcBehaviour | type without `asOBJ_GC` plus `asBEHAVE_ENUMREFS` | illegal-behaviour error | New RED |
    | AcceptNoCount | `asOBJ_REF \| asOBJ_NOCOUNT` | success | Regression control |
    | UnrootedSelfCycleLeaks | self `REFCPY` then `FREE`; no collect | destructor count 0 after execute | Replaces `UnrootedSelfCycleFinalizesOnce` collect assertion |
    | LastReleaseDestroys | acyclic object, final `asVmRelease` | destructor count 1 exactly once | Replaces collect-driven destruction |
    | WeakFlagFollowsRelease | weak flag valid while live; invalid after last release | no collect call | Replaces `WeakRefValidThenInvalidAfterCollection` |
    | RefCpyBalances | `REFCPY` then `FREE` | AddRef/Release balanced; object dies on last release | Existing `RefCpyVBalancesAddRefRelease` |
    | ContextRootLives | prepared context still holds object | object survives execute until Unprepare/Release | Existing `PreparedContextRootsLiveObject` without collect |

    Drain/root/integration/dispatch files in this task's Files list must compile without `GarbageCollect` or `asOBJ_GC`. Shutdown leftover destruction without a collect call is allowed to stay RED until 2.1; do not reintroduce a collect call to make them green.

    **Implementation**

    1. Add `VMLifetime` cases above, including the two rejection cases, and strip collector calls/flags from the listed VM and CallableSDK tests. Run the proving selection. Observe RejectGcFlag / RejectGcBehaviour RED. Observe rewritten leak and last-release cases green if they already match today's auto-GC-off behaviour.
    2. Reject `asOBJ_GC` in `RegisterObjectType` and metadata type publication. Reject GC behaviours when the type is not garbage-collected (all types, after the flag is illegal).
    3. Rerun the same selection. Rejection cases GREEN. Do not delete `as_gc.cpp` here.

    **Files**

    - `Plugins/Angelscript/Source/AngelscriptRuntime/Core/angelscript.h`
    - `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_scriptengine.cpp`
    - `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_scriptengine.h`
    - `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_metadata_image.cpp`
    - `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/VM/VMGCTests.cpp`
    - `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/VM/VMShutdownDrainTests.cpp`
    - `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/VM/VMRuntimeDrainTests.cpp`
    - `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/VM/VMRootLifetimeTests.cpp`
    - `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/VM/VMIntegrationTests.cpp`
    - `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/VM/VMDispatchTests.cpp`
    - `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/LanguageSurface/CallableSDKTests.cpp`

    **Verification**

    ```powershell
    $result = Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.VMLifetime'; Fast = $true; TimeoutMs = 600000 }
    if ($result.exitCode -ne 0) { throw 'Owned proving selection failed' }
    ```

    Completion requires `RejectGcFlag`, `RejectGcBehaviour`, `UnrootedSelfCycleLeaks`, `LastReleaseDestroys`, and `WeakFlagFollowsRelease` to execute and pass. Drain/root/integration/dispatch files listed above must compile without collector APIs; their leftover-shutdown behaviour is proven in 2.1. Record the actual RunId in Evidence after execution.

- [ ] 2.1 Delete the native collector and drain remaining VM objects through leases

    **Outcome**

    `as_gc.cpp` / `as_gc.h` are gone. `asIScriptEngine` has no garbage-collect methods and no `asEP_AUTO_GARBAGE_COLLECT`. `$func` and callable types are not `asOBJ_GC`. `asVmAllocateObject` does not notify a collector. `ShutDownAndRelease` destroys remaining leased VM objects without `GarbageCollect()`. Engine teardown does not call `ReportAndReleaseUndestroyedObjects` on a collector.

    **Context and interfaces**

    Current teardown in `asCScriptEngine::ShutDownAndRelease` calls `GarbageCollect()` then later `gc.ReportAndReleaseUndestroyedObjects()`. `asCScriptEngine` holds `asCGarbageCollector gc`. `asCScriptFunction` delegate construction calls `gc.AddScriptObjectToGC`. `asCCallableType` sets `asOBJ_REF | asOBJ_GC | asOBJ_CALLABLE_TYPE`. `asVmAllocateObject` calls `NotifyGarbageCollectorOfNewObject` when `asOBJ_GC` is set.

    Replace that with the existing `vmObjectLeases` drain: every remaining leased payload is released/destroyed during shutdown after admission is closed, unless an external caller still holds it (current `RetainedObjectDelaysDestroyUntilFinalRelease`).

    **Cases**

    | Case | Input | Expected | Role |
    | --- | --- | --- | --- |
    | NoPublicCollect | compile against `asIScriptEngine` | no `GarbageCollect` / `GetGCStatistics` / `NotifyGarbageCollectorOfNewObject` / `GetObjectInGC` / `GCEnumCallback` / `ForwardGC*` | New compile contract |
    | NoAutoGcProperty | `SetEngineProperty(asEP_AUTO_GARBAGE_COLLECT, 0)` | invalid property / does not compile | New |
    | ShutdownAbortsSuspended | suspended context holding a VM object, then `ShutDownAndRelease` + Abort | destructor 1 without collect | Replaces drain collect call |
    | RetainedObjectAcrossShutdown | allocate, shutdown, then `asVmRelease` | destructor 0 until final release, then 1 | Existing drain case without collect |
    | DelegateCaptureNotCollected | delegate holds object that holds delegate | still alive after execute; no collect API | Replaces `DelegateCaptureCycleIsReclaimed` |
    | TwoEngineIsolation | A/B each own objects | destroying A does not destroy B's objects | Regression from root-lifetime tests |

    Enabled targets must not compile `AngelscriptNativeGarbageCollectorTests.cpp` against missing `as_gc.h`. Dormant legacy files that are ubt-ignored may remain on disk.

    **Implementation**

    1. After 1.1 tests exist, extend drain/lifetime cases for shutdown-without-collect and missing public APIs. Observe RED where shutdown still depends on `gc`.
    2. Delete `as_gc.cpp` / `as_gc.h`. Remove `gc` from `asCScriptEngine`. Remove public GC methods and `asEP_AUTO_GARBAGE_COLLECT`. Strip GC notify from `as_vm_object.cpp`, `as_scriptfunction.cpp`, `as_scriptobject.cpp`, `as_typeinfo.cpp`, `as_context.cpp`, and `as_restore.cpp` if that file is still compiled. Implement shutdown lease destruction.
    3. Rerun the proving selection GREEN. Confirm a search of enabled sources has no `asCGarbageCollector` or `Engine->GarbageCollect`.

    **Files**

    - `Plugins/Angelscript/Source/AngelscriptRuntime/Core/angelscript.h`
    - `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_gc.cpp`
    - `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_gc.h`
    - `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_scriptengine.cpp`
    - `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_scriptengine.h`
    - `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_vm_object.cpp`
    - `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_scriptfunction.cpp`
    - `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_scriptobject.cpp`
    - `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_typeinfo.cpp`
    - `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_context.cpp`
    - `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_restore.cpp`
    - `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/VM/VMGCTests.cpp`
    - `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/VM/VMShutdownDrainTests.cpp`
    - `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/VM/VMRuntimeDrainTests.cpp`
    - `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/VM/VMRootLifetimeTests.cpp`

    **Verification**

    ```powershell
    $result = Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.VM'; Fast = $true; TimeoutMs = 600000 }
    if ($result.exitCode -ne 0) { throw 'Owned proving selection failed' }
    ```

    The VM prefix is required because deleting the collector is a shared compile and lifetime contract across VMLifetime, drain, root, integration, and dispatch. Completion needs those classes to run without `GarbageCollect`, shutdown leftover cases to destroy through leases, and `as_gc.cpp` absent from the built module. Record RunId and omitted heavier suites (full plugin suite, Performance) with reason: impact is native VM lifetime, not UObject gameplay.

- [ ] 3.1 Keep Unreal ReferenceSchema emission and drop collector inventory

    **Outcome**

    Script-held UObject references still reach UE GC through `DetectAngelscriptReferences` / `EmitReferenceInfo`. `NeverRequiresGC` types still skip that work. Standalone/source inventories no longer list `as_gc.cpp`. Dump/registration `asOBJ_GC` / `bGarbageCollected` traits become always-false or omitted, never a live collector flag.

    **Context and interfaces**

    `FAngelscriptClassGenerator::DetectAngelscriptReferences` still walks script properties and writes `Class->ReferenceSchema`. `FAngelscriptArrayType` / Map / Set / Optional / UObject / UStruct `EmitReferenceInfo` remain. `FTraceHandleType::NeverRequiresGC` remains true. `ClassReloadHelper.cpp` may still call Unreal `CollectGarbage` on reload; that is host GC, not this task's deletion target.

    `AngelscriptStandaloneArchitectureTests.cpp` currently requires `"as_gc.cpp"` in the ThirdParty source list. `AngelscriptOfflineSymbolExporter.cpp` and `AngelscriptRegistrationLoader.cpp` still decode `asOBJ_GC`.

    **Cases**

    | Case | Input | Expected | Role |
    | --- | --- | --- | --- |
    | SchemaBuilt | script class with non-UPROPERTY `UObject` handle | `ReferenceSchema` non-empty | Existing `FAngelscriptASClassReferenceSchemaTests.BuildsSchemaForScriptHeldObjectHandle` if that class is enabled; otherwise add a NewVersion equivalent |
    | SoftReloadStable | repeated soft reload | schema member count unchanged | Existing soft-reload case |
    | NeverRequiresGc | `FTraceHandle` property | no schema member for that field | Control |
    | InventoryOmitsAsGc | standalone architecture source list | no `as_gc.cpp` / `as_gc.h` | New RED then GREEN |
    | DumpHasNoLiveGcFlag | symbol export of a ref type | no collector-true trait | New |

    The reconstruction baseline does not treat `Angelscript.TestModule.Generator.ASClass.ReferenceSchema` as the enabled gate. Add `HostGcSchema` under TestDir `Angelscript.UnitTest.ClassGenerator` in NewVersion. That class compiles a `UObject` script holder with a non-UPROPERTY object handle, asserts `UASClass::ReferenceSchema` is non-empty, and asserts `as_gc.cpp` is absent from the maintained ThirdParty source directory. Do not reactivate the legacy generator corpus.

    **Implementation**

    1. Add/adjust inventory and dump cases; run them with the schema control. Observe inventory RED while `as_gc.cpp` is still listed.
    2. Remove `as_gc.cpp` from the architecture expected list. Stop exporting a live GC trait. Do not change `DetectAngelscriptReferences` behaviour.
    3. Rerun GREEN. Confirm `ClassReloadHelper` still references Unreal `CollectGarbage` only.

    **Files**

    - `Plugins/Angelscript/Standalone/Tests/AngelscriptStandaloneArchitectureTests.cpp`
    - `Plugins/Angelscript/Standalone/Source/Registration/AngelscriptRegistrationLoader.cpp`
    - `Plugins/Angelscript/Source/AngelscriptRuntime/Dump/AngelscriptOfflineSymbolExporter.cpp`
    - `Plugins/Angelscript/Source/AngelscriptRuntime/ClassGenerator/AngelscriptClassGenerator_Reinstancing.cpp`
    - `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/ClassGenerator/HostGcSchemaTests.cpp`
    - `Plugins/Angelscript/Source/AngelscriptEditor/HotReload/ClassReloadHelper.cpp`

    **Verification**

    ```powershell
    $result = Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.ClassGenerator.HostGcSchema'; Fast = $true; TimeoutMs = 600000 }
    if ($result.exitCode -ne 0) { throw 'Owned proving selection failed' }
    ```

    Completion requires the NewVersion schema case to see a non-empty `ReferenceSchema` and the inventory case to see no `as_gc.cpp`. `ClassReloadHelper` may still call Unreal `CollectGarbage`; that is host GC. Do not run the full Automation suite. Record RunId in Evidence after execution.
