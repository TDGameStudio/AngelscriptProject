## Context

### Current State (Code Facts, Not Inferences)

1. **UHT tool output shape**: `[UhtExporter]` in `Plugins/Angelscript/Source/AngelscriptUHTTool/AngelscriptFunctionTableExporter.cs:21-26` must keep `ModuleName = "AngelscriptRuntime"` and `CppFilters = ["AS_FunctionTable_*.cpp"]`. UE UHT plugin exporters do not allow omitting `ModuleName`; also, when `PluginModule != null`, `UhtExportFactory.MakePath(...)` forces the output path back to the plugin module OutputDirectory, so `factory.MakePath(targetModule, ...)` cannot directly write into the target module. Because of this, current `AngelscriptFunctionTableCodeGenerator.cs:120` places *all* shards in the `AngelscriptRuntime` OutputDirectory. Shard content is `FAngelscriptBinds::AddFunctionEntry(<Class>::StaticClass(), "Func", { ERASE_AUTO_METHOD_PTR(<Class>, Func), ... })`, which depends strongly on `Core/AngelscriptBinds.h` and `Core/FunctionCallers.h`. `DeleteStaleOutputs` likewise enumerates only AngelscriptRuntime's own output directory.
2. **Cross-module unexported functions are pre-filtered**: `AngelscriptHeaderSignatureResolver.cs:109-117` `HasLinkableExport` marks a candidate as `unexported-symbol` when the module is not AngelscriptRuntime, the function does not match `<MODULE>_API` / `UE_API` / `RequiredAPI` / `inline` / `FORCEINLINE` / `constexpr`, and the class is neither `MinimalAPI` nor API-tagged. `AngelscriptFunctionTableCodeGenerator.cs:482-489` degrades that candidate to an `ERASE_NO_FUNCTION()` stub, and runtime falls back to reflection through `BindBlueprintCallableReflectionFallback` in `Bind_BlueprintCallable.cpp:178-197`. The `unexported-symbol` row in `AS_FunctionTable_SkippedReasonSummary.csv` is exactly this stubbed function group.
3. **Reflective fallback performance baseline**: comments in `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/BlueprintCallableReflectiveFallback.cpp:96-105` state that even with `as.ReflectiveFallback.UseCache=1` enabled by default, using `FReflectiveParamCache + FFrame + UFunction::Invoke` is still 3-6x slower than direct `asCALL_THISCALL`; disabling cache falls back to the legacy `ProcessEvent` path and is slower. **Important fact**: the cached path explicitly says "with FUNC_Net branch", meaning the reflection path **preserves RPC routing**. A direct-bind path bypasses that routing, so RPC functions must keep using reflection (see D-RPC-Skip).
4. **Verse has an engine-internal analogous shape**: `Engine/Source/Runtime/CoreUObject/Public/VerseVM/VVMVerseClass.h::FVerseCallableThunk = { const char* NameUTF8; Verse::VNativeFunction::FThunkFn Pointer; }`. Phase 1 investigation adds that Verse's rendezvous point is actually **`COREUOBJECT_API RegisterVerseCallableThunks(UClass*, FVerseCallableThunk*, uint32)` in CoreUObject** (implemented in `Engine/Source/Runtime/CoreUObject/Private/VerseVM/VVMUECodeGen.cpp`). Each engine module's `<Class>.gen.cpp` calls it once from `StaticRegisterNatives()`, writes the thunk table to `UVerseClass::VerseCallableThunks`, and the Verse VM later looks up UClass metadata and fills `VNativeFunction::Thunk`. **Key insight: the cross-module key is not merely "put emitted cpp into the target module"; it is "use a rendezvous point already linked by the engine module"**.
5. **Existing AngelscriptRuntime dependencies** (`AngelscriptRuntime.Build.cs:33-66`): currently links `Engine`, `CoreUObject`, `Core`, `SlateCore`, `UMG`, `AIModule`, `NavigationSystem`, `GameplayTags`, and others for manual binds and reflective fallback. **Hard constraint for this change: add no further engine module dependencies** (especially no reverse links to RenderCore, PhysicsCore, HairStrandsCore, or any module that happens to contain a BlueprintCallable).
6. **`IModularFeatures`** (`Engine/Source/Runtime/Core/Public/Features/IModularFeatures.h`): UE already provides a string-ID central registry in Core, and both engine modules and AngelscriptRuntime already link Core. It provides `RegisterModularFeature(FName, IModularFeature*)`, `GetModularFeatureImplementations(FName)`, and the `OnModularFeatureRegistered` delegate, but UE 5.7 has no global `IModularFeatures::IsAvailable()`. `IModularFeature` is currently an empty interface with no virtual destructor or virtual methods, so the reader layout contains no vtable padding; feature instances still consistently use explicit ctors and make constructor-only instantiation a generated-output invariant. `OnModularFeatureRegistered` is not guaranteed to fire on GameThread.
7. **`Bind_BlueprintCallable.cpp:324`** explicitly comments that the "AS Engine register half" must run on GameThread. Every path that writes `ClassFuncMaps` or calls `BindMethodDirect` must run on GameThread.

### Constraints

- Do not modify engine source; all changes stay inside `Plugins/Angelscript/`.
- **AngelscriptRuntime adds no engine module dependencies** - the cross-module boundary crosses only through `IModularFeatures` (already in Core) and POD data, never through link-time resolution of symbols defined in engine modules.
- Engine modules cannot reverse-depend on `AngelscriptRuntime`, so cross-module emitted cpp cannot `#include "Core/AngelscriptBinds.h"`, cannot use strong-typed forms such as `FAngelscriptBinds::AddFunctionEntry` / `ASAutoCaller` / `FGenericFuncPtr` / PMF, and **cannot include AS SDK headers (`angelscript.h`)**. The latter depends on `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/...` include paths; engine module build.cs files do not have those paths, and adding them would be equivalent to changing engine build configuration.
- Preserve the Launcher / no-engine-rebuild user path: when this path is unavailable, existing `BlueprintCallableReflectiveFallback` must fall back seamlessly.
- **Preserve RPC routing for every `FunctionFlags & (FUNC_Net|FUNC_NetServer|FUNC_NetClient|FUNC_NetMulticast)` function**: these functions continue through reflective fallback and are never emitted into cross-module direct bind.
- Keep the `AS_FunctionTable_*.cpp` filename prefix. It is already not matched by the engine `CodeGen` exporter `CppFilters` patterns `*.generated.cpp` / `*.generated.*.cpp` / `*.gen.cpp` / `*.gen.*.cpp`, so cross-module emitted files will not be mistakenly removed by `CullOutput`; this is the key basis that lets this design land in engine module OutputDirectories.

## Goals / Non-Goals

**Goals:**
- Move *non-RPC, safe-signature* `BlueprintCallable`/`BlueprintPure` UFunctions that are currently turned into `ERASE_NO_FUNCTION()` because of "cross-module + no API macro" onto the same "direct bind" path as functions inside the AngelscriptRuntime module, skipping reflective fallback.
- **Use `IModularFeatures` as the cross-module central rendezvous point**: emitted cpp in each engine module registers a POD-payload feature into `IModularFeatures` during DLL static construction under string ID `"AngelscriptCrossModuleBindings"`; AS Runtime pulls all implementations at `EOrder::Late + 60`, with **no link dependency on any engine module**.
- **Use the same design path for Modular (Editor) and Monolithic (Shipping)**: `IModularFeatures` does not depend on PE export tables and is suitable for both build configurations by design. This change's validation boundary is source-build Development Editor; Monolithic Shipping and Launcher installed-engine smoke remain later release-hardening matrix items. Launcher / no-engine-rebuild users simply have no target-module cross-module shard compiled; runtime pulls an empty registry and reflective fallback remains the safety net.
- **Use raw thunk shape; emitted cpp does not include AS SDK**: thunk signature is `void(*)(UObject* Self, void** Args, void* Ret)`, emitted cpp includes only `Features/IModularFeatures.h` and target class headers, and AS Runtime owns the single generic hook that bridges `asIScriptGeneric` to the raw buffers.
- **Cover the safe UFunction subset**: automatic emit is limited to signatures that need no extra BPVM writeback protocol. Return support: `void`, bool/numeric/enum/struct, `FString`, `FName`, `FText`, `UObject*`. Parameter support: bool/numeric/enum/struct, `FString`, `FName`, `FText`, `UObject*`, `UClass*`, soft object, weak object. Explicitly defer out-param, WorldContextObject, ref-return, static arrays, and `TArray/TSet/TMap` containers.
- **Three ABI defenses**: compile-time `static_assert(sizeof(...))` + runtime `LayoutVersion` magic + null/range validation. `LayoutVersion` is managed by a single-token `cross-module-layout-version.txt` file shared by generator and AS Runtime public header, with documented bump rules.
- **Shutdown timing safety**: `~FAutoReg()` and AS Runtime `OnPreExit` both use a shutdown flag fallback and never dereference `IModularFeatures::Get()` after the Core singleton has been destroyed.
- **Callback thread safety**: `OnModularFeatureRegistered` callbacks marshal to GameThread before writing `ClassFuncMaps` or calling `BindMethodDirect`.
- Use a Day-0 minimal probe to verify (i) whether UBT automatically includes extra `AS_FunctionTable_<Module>_CrossModule_*.cpp` files placed in a target module OutputDirectory, (ii) whether `IModularFeatures::Get()` is ready during engine-module static construction, and (iii) whether AS Runtime can pull the feature through `GetModularFeatureImplementations` at Late+60; any failure means STOP and the whole change is invalid.

**Non-Goals:**
- Do **not** rework internal `UASFunction` dispatch, StaticJIT, or AngelScript JIT entry points; those are covered separately by `uasfunction-runtime-dispatch-coverage` and `uasfunction-dispatch-matrix-and-jit-paths`.
- Do **not** change internals of `BlueprintCallableReflectiveFallback`; it remains the safety net for RPC/Net functions, Launcher path, and "target module did not emit" cases.
- Do **not** move RPC/Net functions onto cross-module direct bind; reflective fallback is the only correct RPC routing path.
- Do **not** add `UFUNCTION` tags or meta extensions; keep existing `BlueprintCallable`/`BlueprintPure` plus `NotInAngelscript`/`BlueprintInternalUseOnly` skip rules and add no user-side burden.
- Do **not** pass PMF / `FGenericFuncPtr` across module boundaries. The cross-module boundary carries only raw thunk function pointers and POD fields.
- Do **not** let emitted cpp include any AS Runtime / AS SDK header, including `angelscript.h`.
- Do **not** add any engine module dependency to `AngelscriptRuntime.Build.cs`.

## Decisions

### D1: Use UHT Cross-Module Emit Instead of Engine Source Changes

**Choice**: the UHT C# plugin keeps `ModuleName="AngelscriptRuntime"`; same-module shards continue using the plugin factory default path, while cross-module shards use the target `UhtModule.Module.OutputDirectory` absolute path and write through `factory.CommitOutput(...)`. The Day-0 probe must first prove this cross-directory output is included by UBT in the target module.

**Why**:
- No engine source changes are required, matching the AGENTS.md goal that the AS plugin remains an independent reusable plugin.
- It mirrors Verse's shape: emit into the module where the function lives.
- UE UHT plugin exporters must specify `ModuleName`, and `factory.MakePath(uhtModule, suffix)` falls back to the plugin module OutputDirectory when `PluginModule != null`, so it cannot be used for target module output.

**Not chosen**:
- Add `<MODULE>_API` to every target UFUNCTION - requires engine source changes and violates constraints.
- Handwrite cross-module forwarders inside AngelscriptRuntime - taking cross-module addresses fails at link time, which is exactly the current `unexported-symbol` root cause.

### D-IMF: Central Rendezvous Point = `IModularFeatures` + POD Payload

**Choice**: emitted cpp in each engine module registers an `IModularFeature` derived class (POD data only, no added virtual methods) from a static global object's constructor into `IModularFeatures::Get()` under string ID `FName("AngelscriptCrossModuleBindings")`. AS Runtime calls `GetModularFeatureImplementations(...)` at Late+60 to pull all current features, and subscribes to `OnModularFeatureRegistered` for late-loaded modules.

**ABI contract** (both sides must keep layout identical; generator output and AS Runtime public header keep it synchronized):

```cpp
struct FAngelscriptCrossModuleEntry
{
    const TCHAR* ClassName;
    const TCHAR* FunctionName;
    void (*Thunk)(class UObject* Self, void** Args, void* Ret);
    uint16  ArgCount;
    uint16  RetSize;     // 0 = void; non-zero = byte size, AS Runtime allocates the Ret buffer from it
    uint32  Flags;       // bit0 Static / bit1 Const / bit2 WorldContext / bit3 HasOutParams / remaining bits reserved
};

struct FAngelscriptCrossModuleFeature : public IModularFeature
{
    const FAngelscriptCrossModuleEntry* Table;
    int32        Count;
    const TCHAR* ModuleName;
    uint32       LayoutVersion;

    FAngelscriptCrossModuleFeature(
        const FAngelscriptCrossModuleEntry* InTable,
        int32 InCount,
        const TCHAR* InModuleName,
        uint32 InLayoutVersion)
        : Table(InTable), Count(InCount), ModuleName(InModuleName), LayoutVersion(InLayoutVersion) {}
};
```

AS Runtime defines a reader with the same layout and reinterpret_casts `IModularFeature*`. UE 5.7 `IModularFeature` is currently an empty non-polymorphic interface, so the reader contains no vtable padding; the Day-0 probe and later `static_assert`s fail early if Core interface shape changes:

```cpp
struct FAngelscriptCrossModuleFeatureReader
{
    const FAngelscriptCrossModuleEntry*  Table;
    int32                                Count;
    const TCHAR*                         ModuleName;
    uint32                               LayoutVersion;
};
```

Instantiation must use the ctor (see D-Aggregate-Init):

```cpp
static const FAngelscriptCrossModuleEntry GTable[] = { /* ... */ };
static FAngelscriptCrossModuleFeature GFeature(
    GTable, UE_ARRAY_COUNT(GTable), TEXT("Engine"), 0xA5C0DE01u);
```

**Why**:
- AS Runtime has **zero new engine module dependencies** (`Features/IModularFeatures.h` comes from Core, already in the dependency list).
- Works for both Modular and Monolithic; IModularFeatures does not depend on PE export tables.
- Module load order is irrelevant: whichever static constructor runs first registers first; late modules are handled through `OnModularFeatureRegistered`.
- Mirrors Verse's shape: the central rendezvous point lives in Core/CoreUObject, and each module emits cpp into its own OutputDirectory.

**Not chosen**:
- Runtime lookup through `FPlatformProcess::GetDllExport` - Monolithic Shipping often strips exported symbols, so this is not guaranteed; the user selected Shipping support, so GetDllExport-only is excluded.
- `extern Get_AS_Bindings_<Module>` plus Build.cs links to engine modules - reverse dependencies explode, the user explicitly rejected this during review, and **this is the fundamental reason for the redesign**.

### D-Aggregate-Init: Derived-Class Ctor Instead of Brace-Init

**Choice**: `FAngelscriptCrossModuleFeature` must explicitly declare a ctor, and instances use `static FFeature GF(GTable, Count, TEXT("..."), 0xA5C0DE01u);`. Even if UE 5.7 `IModularFeature` is currently an empty interface and technically aggregate-initializable, generated output stays constructor-only so both layout and instantiation remain stable long term.

**Why**: constructor-only is a generated-output invariant. It avoids discovering brace-init compatibility only after `IModularFeature` later becomes polymorphic or gains a destructor. The Phase 0 probe and ABI `static_assert`s fail early when interface shape changes instead of allowing the runtime reader to silently drift.

**Not chosen**:
- C++20 `designated initializers` - still creates a second initialization style and makes it harder for generator/reader sides to keep one invariant.
- `T = T(...)` copy-init - direct ctor initialization is clearer and adds no downside.

### D-Thunk: Thunk Signature `void(*)(UObject*, void**, void*)`; AS Runtime Owns asIScriptGeneric Bridging

Emitted cpp thunk shape:

```cpp
static void Thunk_AActor_GetActorLocation(UObject* Self, void** /*Args*/, void* Ret) {
    *static_cast<FVector*>(Ret) = static_cast<const AActor*>(Self)->GetActorLocation();
}

static void Thunk_ACharacter_AddMovementInput(UObject* Self, void** Args, void* /*Ret*/) {
    FVector Dir   = *static_cast<FVector*>(Args[0]);
    float   Scale = *static_cast<float*>(Args[1]);
    bool    bForce= *static_cast<bool*>(Args[2]);
    static_cast<ACharacter*>(Self)->AddMovementInput(Dir, Scale, bForce);
}
```

AS Runtime side: **all cross-module entries share one generic hook** `static void GAngelscriptCrossModuleGenericHook(asIScriptGeneric* G)`, carrying a `FAngelscriptCrossModuleEntry` pointer through AS user data. The hook reads Self and argument slots from `G`, writes them into raw `void** Args`, uses the AS-provided return slot if `RetSize > 0`, and calls `E.Thunk(Self, Args, Ret)`. The current safe scope does not automatically emit out-param / ref-return / WorldContext entries, so no extra out-param writeback protocol is needed.

**Why**:
- Emitted cpp includes only `Features/IModularFeatures.h` (Core) plus target class headers and **does not include `angelscript.h`**. Including AS SDK would require adding AS SDK include paths to engine module build.cs files, violating the "do not change engine" constraint.
- Compared with the original D2 idea where emitted cpp directly accepted `asIScriptGeneric*`, this removes one SDK-header dependency at the cost of one common AS Runtime hook (under 50 lines).
- More stable than passing PMF across modules: a raw thunk is an ordinary C function pointer with a normal cross-DLL ABI.

**Not chosen** (versus original D2):
- Direct `void(*)(asIScriptGeneric*)` shape - excluded because of SDK header dependency.
- Passing binary PMF bits across modules - MSVC PMF size depends on multiple inheritance and carries more cross-DLL risk than raw function pointers.

**Scope note**: static `ScriptMethod` functions and class-level `ScriptMixin` projections stay outside the automatic safe set. They project the first C++ parameter into script `this`; this change's raw thunk bridge does not yet inject that implicit object into `Args[0]`, so emitting them would call the target function with shifted arguments.

### D-Param-Marshal: Current Safe-Scope Thunk Unpack Contract

The generator must emit correct unpacking for the following safe-scope forms according to the `UhtFunction` signature:

| Form | Thunk body | AS Runtime bridge hook behavior |
|---|---|---|
| **static function** | `Self == nullptr`; thunk body calls `T::Func(...)` instead of `static_cast<T*>(Self)->Func(...)` | Hook checks `Flags & bit0 Static`, skips Self extraction; AS Runtime registers via `BindGlobalFunction` (namespace = ClassName) |
| **`const` qualified** | Thunk body calls `static_cast<const T*>(Self)->Func()` | AS Runtime appends `const` to the method declaration (`Flags & bit1 Const`) |
| **non-trivial value parameter/return** (`FString` / `FName` / `FText` / struct) | `Args[i]` is the slot address provided by AS generic; thunk body dereferences through `PassCrossModuleArg<T>`; non-trivial returns are placement-constructed into Ret | Hook side only forwards AS generic slot addresses and does not manage complex lifetimes itself |
| **object/class/soft/weak wrapper parameter** | `Args[i]` is dereferenced as the resolved C++ type and passed to the target function | Hook side only forwards AS generic slot addresses |
| **UENUM tag** | `Args[i]` uses the underlying width (uint8 / int32 / uint64); thunk body `static_cast<EnumType>(*static_cast<UnderlyingType*>(Args[i]))` | Hook writes slots at the underlying width |

`Flags` bit definitions: `bit0 Static`, `bit1 Const`, `bit2 WorldContext`, `bit3 HasOutParams`, `bit4 ReturnByRef` (if a UFunction returns a reference, Ret points to the real value), remaining bits reserved.

**Why**: safe-scope first closes the cross-module link boundary and basic raw thunk bridge, avoiding a premature switch of complex forms to direct path before complete BPVM writeback / WorldContext injection protocols exist. out-param, WorldContext, ref-return, static arrays, and `TArray/TSet/TMap` containers remain later changes.

### D-RPC-Skip: RPC / Net Functions Continue Through Reflective Fallback

**Choice**: `AngelscriptFunctionTableCodeGenerator.ShouldGenerate` and `AngelscriptFunctionTableExporter.IsBlueprintCallable` add a check: if `function.FunctionFlags` contains any of `Net` / `NetServer` / `NetClient` / `NetMulticast`, **skip the cross-module shard path directly and continue through the original reflective fallback**. Record reason `rpc-net-function` in `AS_FunctionTable_SkippedReasonSummary.csv`.

**Why**: `UFunction::Invoke` / `UObject::ProcessEvent` route RPC internally through `FUNC_Net` branches (server-only / client-only / multicast / WithValidation). A raw thunk directly calling `static_cast<T*>(Self)->Func()` bypasses all of it and **turns "marshal to peer; local side only triggers a stub" into "execute the function body locally"**, breaking network replication semantics. `BlueprintCallableReflectiveFallback.cpp:96-105` explicitly says that path is "with FUNC_Net branch", so reflective fallback is the only correct RPC route.

**Risk if skipped**: a client script calling a server-only function executes it locally, bypassing authority validation; NetMulticast no longer multicasts; WithValidation no longer validates. This is a severe *correctness* bug, not a performance issue.

### D-LayoutBump: LayoutVersion Managed by Single-Token `cross-module-layout-version.txt`

**Choice**: add `Plugins/Angelscript/Source/AngelscriptUHTTool/cross-module-layout-version.txt`, with only one content line such as `0xA5C0DE01` (32-bit hex). Generator C# reads the file at startup; emitted cpp and AS Runtime public header both generate/reference this value. **Any add/remove/reorder/widen/narrow field change in the POD region of `FAngelscriptCrossModuleEntry` or `FAngelscriptCrossModuleFeature` MUST bump this file's value** (increment/revision).

**Bump triggers** (must be documented in comments at the top of the file):
- Add or remove POD fields
- Change field order
- Change field width (int32 <-> int64 / uint16 <-> uint32)
- Change field semantics (same name and type but changed `Flags` meaning)
- Modify either the AS Runtime reader side or emitted cpp side unilaterally

**Why**: the magic field is easy to forget. Making it a single file that both generator and runtime are forced to read gives two failure paths: change one layout side without updating the file -> CI `static_assert(sizeof) == EXPECTED` fails; update the file but forget to synchronize layout -> runtime validation rejects all features -> coverage tests fail. Together, these catch layout drift during cold start.

**Not chosen**:
- Let the generator auto-compute `MD5(struct text)` - too clever; manual layout edits become harder to trace.
- Put it in Build.cs `PublicDefinitions` - Build.cs and generator have timing differences; a file token is more stable.

### D3: Keep the `AS_FunctionTable_*` Filename Prefix

Cross-module output naming: `AS_FunctionTable_<Module>_CrossModule_<NNN>.cpp` (`NNN` comes from `MaxEntriesPerShard = 256` shard splitting, reusing the existing shard strategy).

**Why**:
- The engine `CodeGen` exporter `CppFilters` are `*.generated.cpp / *.generated.*.cpp / *.gen.cpp / *.gen.*.cpp`; `AS_FunctionTable_*` does not match and **will not be deleted by `CullOutput`**.
- Reuses `AngelscriptFunctionTableExporter`'s own `CppFilters = ["AS_FunctionTable_*.cpp"]`, keeping cleanup ownership for this exporter's outputs consistent.

### D-MultiShardSameModule: Multiple Same-Module Shards = Multiple Feature Instances

**Choice**: large modules split by `MaxEntriesPerShard = 256`; each shard file has its own anonymous `GFeature` + `GAutoReg`. **The same engine module may register N same-name (`"AngelscriptCrossModuleBindings"`) feature instances in IModularFeatures**. AS Runtime iterates the array returned by `GetModularFeatureImplementations` by *feature instance*, not deduplicated by ModuleName. `ModuleName` is diagnostic-only and may repeat.

**Why**: `IModularFeatures` already supports multiple implementors for the same string ID. Conversely, if same-module shards shared one global object, they would need cross-TU references, introducing `extern` and breaking anonymous-namespace isolation. Multiple instances are simpler.

**Risk**: if a generator bug emits the same entry in two shards, the Late+60 second write is blocked by the D4 priority rule; behavior degrades but does not crash. Regression test 2.4 protects this invariant.

### D4: AS Runtime Injection Phase Uses `EOrder::Late + 60`

Existing shards inject at `EOrder::Late + 50` (`AngelscriptFunctionTableCodeGenerator.cs:306`). New `Bind_CrossModuleDirect.cpp` uses `EOrder::Late + 60`, **after in-module shards so `ClassFuncMaps` is mostly ready**, while still before `Bind_BlueprintCallable.cpp` actually consumes entries.

**Why**:
- Direct-bind tables are visible before `Bind_BlueprintCallable.cpp` consumes them, so `Entry->FuncPtr.IsBound()` can see them and skip fallback.
- Same-name entry priority: if the in-module shard (Late+50) already wrote a direct-bind pointer, the cross-module table (Late+60) sees `Entry->FuncPtr.IsBound()==true` and **does not overwrite**, only fills gaps. This matches the existing "do not overwrite if map entry exists" semantics of `FAngelscriptBinds::AddFunctionEntry`.
- Multiple same-module cross-module features (D-MultiShardSameModule) are processed in the order returned by `GetModularFeatureImplementations`; first wins, later entries do not overwrite.

### D5: Narrow HasLinkableExport to Only Truly Unreachable Symbols

**After change**:
- `Private/` headers continue to skip (existing logic preserved).
- `CustomThunk` continues to skip (existing logic preserved).
- `Interface`/`NativeInterface` continues to emit stub (existing logic preserved; `Bind_BlueprintCallable` uses `CallInterfaceMethod` through `FindFunction + ProcessEvent`).
- **New `FUNC_Net` family skip**: see D-RPC-Skip.
- **Remove** the "cross-module + no API macro -> unexported-symbol" decision, because the new emit path no longer depends on taking a cross-module address.
- Add "target module not in supported modules list" -> emit stub (effectively reflective fallback, behavior unchanged).

### D-StaleCleanup: Stale Shard Cleanup Covers All Supported Modules

**Choice**: change `AngelscriptFunctionTableCodeGenerator.DeleteStaleOutputs` to enumerate **every supported module's OutputDirectory** (driven by the existing `LoadSupportedModules` list) and remove old files matching `AS_FunctionTable_<Module>_CrossModule_*.cpp` that are not in this run's generated set.

**Why**: if a function gets `NotInAngelscript`, moves, or changes signature, an old cross-module shard left behind will still be compiled by UBT, causing duplicate entries, naming conflicts, or link errors. Original `DeleteStaleOutputs` only sees AngelscriptRuntime's own directory, which misses cross-module output 100% of the time.

**Implementation notes**: group `generatedPaths` by module; enumerate per target module during cleanup; keep the existing AngelscriptRuntime directory cleanup behavior.

### D-ShutdownOrder: Safe Protocol for DLL Unload and IModularFeatures Singleton Destruction

**Choice**:
- Emitted cpp uses `FCoreDelegates::OnPreExit` to set this TU's shutdown flag; `~FAutoReg()` no-ops if the flag is true, otherwise performs normal `UnregisterModularFeature`.
- AS Runtime `Bind_CrossModuleDirect.cpp` removes the `OnModularFeatureRegistered` subscription early in `FCoreDelegates::OnPreExit.AddStatic(&Unsubscribe)` so callbacks cannot fire after Core singletons are destroyed.

**Why**: `IModularFeatures` is a Meyers singleton, and Meyers singleton destruction order across DLLs is undefined. If the Core singleton is destroyed first and an engine module unloads later, that module's `~FAutoReg` would dereference through `Get()` and crash.

**Risk if skipped**: intermittent crashes during Editor exit, project switch, or hot reload that are very hard to root-cause.

### D-OnModularFeatureRegisteredThread: Callback Marshals to GameThread

**Choice**: inside AS Runtime's `OnModularFeatureRegistered` subscription callback, **never write `ClassFuncMaps` or call `BindMethodDirect` on the invoking thread**; instead `AsyncTask(ENamedThreads::GameThread, [Feature](){ /* actual processing */ });`.

**Why**: UE does not guarantee this delegate fires on GameThread; dynamic plugin loading or background-thread `RegisterModularFeature` can trigger the callback. The comment in `Bind_BlueprintCallable.cpp:324` already states that "AS Engine register half" must run on GameThread.

**Risk if skipped**: intermittent races between `ClassFuncMaps` mutation and BPVM reads; `BindMethodDirect` may also hit AS Engine asserts when called off GameThread.

### D7: Day-0 Probe Is a STOP Gate

The first task must handwrite a minimal IModularFeatures self-register cpp in the Engine module (not through the generator) and add a headless unit test in AngelscriptRuntime to verify:

1. Whether UBT automatically includes extra `AS_FunctionTable_*_LinkProbe.cpp` files under the target module OutputDirectory in that module's build;
2. Whether `IModularFeatures::Get()` is ready during engine-module static construction and `RegisterModularFeature` succeeds;
3. Whether AngelscriptRuntime can retrieve this probe feature through `GetModularFeatureImplementations` at `EOrder::Late + 60`.

**Any failure means STOP; the whole proposal is invalid, with no workaround path.**

## Risks / Trade-offs

| Risk | Impact | Mitigation |
|---|---|---|
| **R1**: UBT does not automatically include `AS_FunctionTable_*_CrossModule_*.cpp` files in target module OutputDirectories | Whole design is invalid | Day-0 probe (D7), fail means STOP; do not try internal API workarounds such as `AddCustomCppFile` |
| **R2**: `asCALL_GENERIC` + raw thunk is slower than `asCALL_THISCALL` | Direct-bind benefit shrinks | Quantify through a `TestPerformance.md` micro-bench and set a minimum benefit threshold after mass baseline data exists; if below threshold, keep this design but treat "thiscall upgrade" as a later target |
| **R3**: UHT plugin changes trigger full engine-module rebuilds | Development loop gets worse | Strictly follow `SaveIfChanged` - generator output is already sorted by ClassName/FunctionName Ordinal and has no timestamp; new cross-module shards keep stable sort too; tasks.md forbids unstable fields such as `DateTime.Now` in emitted output |
| **R-FUNC_Net**: RPC / Net functions mistakenly direct-bind | Network replication semantics break (server-only runs on clients / NetMulticast does not multicast / WithValidation does not validate) | D-RPC-Skip: generator `ShouldGenerate` explicitly filters `FUNC_Net|FUNC_NetServer|FUNC_NetClient|FUNC_NetMulticast`; `AS_FunctionTable_SkippedReasonSummary.csv` counts it; current change guards it through generator diagnostics tests, while multi-endpoint RPC behavior tests remain later network-matrix work |
| **R-AggregateInit**: `static FFeature GF = { ... }` does not compile | Phase 0 probe hits a wall | D-Aggregate-Init: all example code and generator emit templates use ctor form; static scan tests assert emitted cpp has no `= { GTable,` or similar brace-aggregate-init leftovers |
| **R-Layout** (upgraded from original R7): dual-side `FAngelscriptCrossModuleEntry` / `FAngelscriptCrossModuleFeature` layout drifts | Wrong pointer reads and crash risk | D-LayoutBump: single-token `cross-module-layout-version.txt`; three defenses: (a) compile-time `static_assert(sizeof)` equivalence on both sides; (b) `LayoutVersion` magic mismatch means runtime warn + skip; (c) null/range validation. Fields use pointers/int32/uint32 only; no `bool`/`uint8`. Derived class must not add new virtual methods later |
| **R-StaticInitFiasco**: uncertainty around `IModularFeatures::Get()` readiness during static construction | Engine module DLL crashes during load | `IModularFeatures` is in Core, and Core loads before engine modules in theory; Day-0 probe proves it empirically |
| **R-OnModularFeatureRegistered-Timing**: entries from modules loaded after Late+60 are missed | Some UFunctions never reach ClassFuncMaps | D-LateRegister: subscribe to `OnModularFeatureRegistered` and run the exact same path as Late+60 when the callback fires |
| **R-OnModularFeatureRegisteredThread**: callback fires on a worker thread | Race with BPVM / AS Engine and `ClassFuncMaps` data race | D-OnModularFeatureRegisteredThread: callback marshals through `AsyncTask(ENamedThreads::GameThread, ...)`; Phase 3 adds a worker-thread registration concurrency regression test |
| **R-ShutdownOrder**: `IModularFeatures` singleton is destroyed before DLL unload | Intermittent Editor exit / hot reload crash | D-ShutdownOrder: `OnPreExit` sets shutdown flag and runtime proactively unsubscribes; Phase 5 adds graceful shutdown coverage |
| **R-StaleShardCleanup**: `DeleteStaleOutputs` does not cover cross-module directories | Old shard remains -> duplicate-definition link error | D-StaleCleanup: extend enumeration to all supported modules; Phase 2 adds a dedicated coverage task; incremental build regression tests assert old shards are removed |
| **R-MultiShardSameModule**: multiple same-module feature instances process in the wrong order | Duplicate binding / invalid overwrite | D-MultiShardSameModule: AS Runtime iterates feature instances, D4 priority rules protect first write; Phase 2 adds a multi-shard test |
| **R5**: hot-reload changes to engine module `.h` trigger re-emit | Affects development loop | Cross-module emitted content has stable sort + `SaveIfChanged`; hot-reload path still uses reflective fallback, same as today |
| **R6**: cross-module tables conflict with same-module shards for the same entry | Duplicate binding / overwrite bug | D4 priority rule: same-module shard arrives first, Late+60 only fills missing slots and does not overwrite; unit tests assert it |

(Original R4, "target module did not enable compile-time extern, causing link error", is **removed** - the new mechanism has no link step at all. If the target module does not compile a cross-module shard, `IModularFeatures` naturally returns none and behavior degrades to reflective fallback.)

## Migration Plan

1. **Phase 0** (Day-0 probe): add a minimal IModularFeatures self-register probe -> all three checks pass -> unlock later work; any check fails -> STOP, submit `Documents/Reports/CrossModuleLinkProbe_<Date>.md` with failure reason and archive the change. Also confirm shutdown fallback uses the `OnPreExit` flag + destructor no-op form.
2. **Phase 1** (ABI and public header): add `cross-module-layout-version.txt`, `AngelscriptCrossModuleBindings.h` (POD layout, reader, `LayoutVersionExpected`, ctor, `static_assert`), and `Bind_CrossModuleDirect.cpp` skeleton (generic hook + `OnModularFeatureRegistered` subscription + GameThread marshal + `OnPreExit` unsubscribe); run the raw thunk bridge with a safe-scope entry.
3. **Phase 2** (UHT automation): refactor `AngelscriptFunctionTableExporter` / `AngelscriptHeaderSignatureResolver` / `AngelscriptFunctionTableCodeGenerator`; migrate the safe-scope "unexported-symbol" path to automatic cross-module emit (IModularFeatures self-register form + raw thunk + POD table + ctor instantiation); add RPC/Net skip and reason statistics; extend `DeleteStaleOutputs` to cross-module cleanup.
4. **Phase 3** (tests): add a group of `Angelscript.CppTests.UHTToolResolver.*` resolver/runtime boundary tests covering probe, public header, three ABI defenses, generic hook, late-module `OnModularFeatureRegistered`, worker-thread registration safety, no dedupe across same-module feature instances, and generated-output diagnostics.
5. **Phase 4** (follow-up): Bindings CQTest, complex parameter marshal, multi-endpoint RPC behavior, Monolithic/Launcher/full suite, micro-bench, and numerical refresh of `BindGapAuditMatrix.md` / `TestPerformance.md` move into later hardening changes.
6. **Phase 5** (closure): OpenSpec validate, maintenance documentation updates, review notes prep.

**Rollback**: this change lands as "additive + UHT refactor". Rollback is four steps: (a) restore `AngelscriptHeaderSignatureResolver.HasLinkableExport`, (b) restore the single-output path in `AngelscriptFunctionTableExporter.Export`, (c) remove `Bind_CrossModuleDirect.cpp`, `AngelscriptCrossModuleBindings.h`, and `cross-module-layout-version.txt`, and (d) restore `DeleteStaleOutputs` to a single-directory scope. Runtime returns to existing reflective fallback without breaking ABI.

## Open Questions

- **Q1**: Include minimization strategy for cross-module shards - directly include `<Class>.h`, or be more granular to avoid PCH growth? Measure after Phase 1 end-to-end proof and decide before Phase 2 generator implementation.
- **Q3**: If `asCALL_GENERIC` + raw thunk performance is below expectation, what threshold should trigger a thiscall direct-bind upgrade? Can same-module direct-bind reuse existing shards while only cross-module adds a second table? Decide after Phase 4 micro-bench data.
- **Q-ShutdownIdiom**: Is the `OnPreExit` shutdown flag from the Phase 0 probe enough for Editor exit / DLL unload order? If real testing still shows unload-order problems, the later runtime reader must conservatively no-op and rely on process exit cleanup; it cannot introduce nonexistent `IModularFeatures::IsAvailable()`.

(Original Q2, "exact macro shape for extern skip under Launcher path", is **closed** - the `IModularFeatures` path does not depend on compile-time macros. If the target module does not compile a cross-module shard, no feature registers, runtime pulls an empty set, and reflective fallback handles it without an extra macro switch.)
