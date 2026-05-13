## Current State

AngelscriptEngine supports multi-instance lifecycles (Init → Compile → Run → Shutdown). The test module relies on this mechanism for engine isolation. The Shutdown path has the following defects:

### UObject Root Reference Leaks

ClassGenerator creates UObjects with `RF_MarkAsRootSet` in methods such as `FAngelscriptClassGenerator::CreateNewClass`:

```
AngelscriptClassGenerator.cpp:2711  UASClass         RF_MarkAsRootSet
AngelscriptClassGenerator.cpp:2761  UASStruct        RF_MarkAsRootSet
AngelscriptClassGenerator.cpp:2813  UDelegateFunction RF_MarkAsRootSet
AngelscriptClassGenerator.cpp:3814  UUserDefinedEnum  RF_MarkAsRootSet
```

The Shutdown path (`FAngelscriptEngine::Shutdown()` line 1590-1608) only clears script pointers (`ScriptTypePtr`, `OwnerScriptEngine`, etc.) but **never calls `RemoveFromRoot()`**. `CleanupRemovedClass()` (line 4981-5033) has `RemoveFromRoot()` logic but is only invoked during hot reload class replacement, not on the shutdown path.

Package (`AngelscriptPackage`) calls `RemoveFromRoot()` at the end of shutdown, but internal UObjects remain independently rooted.

### Uncleaned Global Static Containers

| Container | Definition | Shutdown Behavior | Risk |
|-----------|-----------|-------------------|------|
| `GBlueprintEventsByScriptName` | `Bind_BlueprintEvent.cpp:68` `TMap<UClass*, TMap<FString, UFunction*>>` | Only cleaned in PrecompiledData scenario | Holds dangling UClass*/UFunction* from destroyed engine |
| `AngelscriptGameplayTagsLookup` | `Bind_FGameplayTag.cpp:24` `TSet<FName>` | Preserved (not cleaned) | Dedup index for global TChunkedArray; clearing causes linear array growth or breaks Rebind mechanism |
| `CachedEditorClasses` | `Bind_BlueprintType.cpp:941` `static TMap<UClass*, bool>` | Never cleaned | Holds dangling UClass* from destroyed engine |

### FName Pool Accumulation

`FNamePool` is append-only (UE architectural design). Each engine cycle creates unique FNames through `Rename(*OldClassName_REPLACED_N*)`, causing permanent accumulation. This cannot be fixed at the plugin level, but reducing rename frequency can mitigate it.

## Goals

- After Shutdown, all owned UASClass/UASStruct/UDelegateFunction/UUserDefinedEnum are removed from GC root, allowing subsequent GC to reclaim them
- Global static containers are cleaned on engine shutdown, eliminating dangling pointer risk
- Normal single-engine lifecycle and hot reload behavior are unaffected

## Non-Goals

- Fix FName Pool append-only design (UE engine level)
- Modify UE allocator behavior or switch allocators
- Proactively trigger `CollectGarbage()` after shutdown (left to the caller)

## Technical Approach

### 1. Add RemoveFromRoot to Shutdown Path

In `FAngelscriptEngine::Shutdown()`, append to the existing UASClass cleanup loop:

```cpp
ASClass->RemoveFromRoot();
ASClass->ClearFlags(RF_Standalone);
```

Add a similar cleanup loop for UASStruct, UDelegateFunction, and UUserDefinedEnum using `ForEachObjectWithPackage` to iterate objects within `AngelscriptPackage`.

### 2. Global Container Cleanup

At the end of `ReleaseOwnedSharedStateResources()` (after AS engine release):

```cpp
extern TMap<UClass*, TMap<FString, UFunction*>> GBlueprintEventsByScriptName;
GBlueprintEventsByScriptName.Empty();

// AngelscriptGameplayTagsLookup is intentionally NOT cleared.
// It is the dedup index for the AngelscriptGameplayTags TChunkedArray,
// which provides stable addresses for AS global variables. Clearing the lookup
// without clearing the array causes linear growth; clearing both breaks
// AngelscriptRebindGameplayTagsToCurrentEngine() which relies on the array
// as the tag truth source for clone/test engines.
```

`CachedEditorClasses` is a function-local static. It is refactored to file-scope `GCachedEditorClasses` with an exposed `ResetCachedEditorClasses()` cleanup function.

### 3. GScriptEnumTypeLookupByName Already Has Reset

`Bind_UEnum.cpp:376` already calls `Reset()` at bind entry. No additional handling needed.

### 4. GScriptNativeForms Leak Cleanup (Phase 2)

`StaticJITBinds.cpp:27` defines `static TMap<asIScriptFunction*, FScriptFunctionNativeForm*> GScriptNativeForms` with two problems:
- Keys are `asIScriptFunction*` — each engine instance creates its own function objects, becoming dangling pointers after engine destruction
- Values are `new FScriptNativeXxx(...)` allocations that are never `delete`d, growing linearly with engine cycles

This leak only occurs in precompile mode (`IsGeneratingPrecompiledData()` is true), as all `BindNativeXxx` methods have that guard.

Fix: Add `static void ReleaseAllNativeForms()` to `FScriptFunctionNativeForm`, iterating the map to delete values + Empty. The base class has `virtual ~FScriptFunctionNativeForm() {}`, making deletion through the base pointer safe.

### 5. AngelscriptDocs TMap Cleanup (Phase 2)

Four static TMaps in `AngelscriptDocs.cpp:28-31` (`UnrealDocumentation`, `UnrealTypeDocumentation`, `GlobalVariableDocumentation`, `UnrealPropertyDocumentation`) are never cleared. Keys are int-type IDs/function IDs that may differ across engine cycles, creating stale data risk.

Fix: Add `static void ResetAllDocumentation()` to `FAngelscriptDocs`, calling `Empty()` on all four TMaps.

### 6. De-globalization Assessment

A full audit of all global static containers (20+) in AngelscriptRuntime was performed, categorizing them as: reasonable globals (process-level constants/managers), fixed with cleanup, newly discovered leaks, and low-priority optional. Full de-globalization (moving into SharedState) is technically feasible but low ROI — the current shutdown cleanup sufficiently resolves the memory leak problem.

## Tradeoffs

| Decision | Option A | Option B | Choice |
|----------|----------|----------|--------|
| UObject cleanup timing | RemoveFromRoot at Shutdown, defer GC | ConditionalBeginDestroy for immediate destruction | A — Safer, avoids destroy order dependencies |
| Global container cleanup location | In ReleaseOwnedSharedStateResources | Add cleanup function in each Bind file | A — Centralized management, fewer omissions |
| CachedEditorClasses | Expose static cleanup function | Convert to engine-instance-level cache | A — Minimal change |

## Risks

- **Hot reload compatibility**: `CleanupRemovedClass` and the new shutdown cleanup may conflict in execution order. Must ensure the shutdown path only processes objects where `OwnerScriptEngine == Engine`.
- **Multi-engine shared instances**: SharedState's `ActiveParticipants` mechanism already exists; shutdown cleanup must only execute global container clearing after all participants have exited.
- **Test behavior changes**: Post-cleanup GC may reclaim previously residual objects, causing behavioral changes in tests that depend on residual state.

## Investigation: Memory Instrumentation Strategy and Decision Record

### Instrumentation Purpose

Full test suite process memory peaked at ~12.9GB with ~51.6MB growth per engine cycle. To distinguish "real leaks" from "allocator retention / UE architectural growth," temporary memory instrumentation was added at the following locations:

### Instrumentation 1: Init Phase Step Tracking (`AngelscriptEngine.cpp` Initialize_GameThread)

```cpp
auto LogPhaseMemory = [this](const TCHAR* Phase)
{
    FPlatformMemoryStats MemStats = FPlatformMemory::GetStats();
    UE_LOG(Angelscript, Display, TEXT("[InitPhase:%s] engine=%p PhysMB=%llu VirtMB=%llu"),
        Phase, this,
        MemStats.UsedPhysical / (1024 * 1024),
        MemStats.UsedVirtual / (1024 * 1024));
};
```

Called after `PreInitialize`, `EnsureSharedStateCreated`, `BindScriptTypes`, `InitializeOwnedSharedState`, and `DebugServer` phases.

**Finding**: A single bind phase (121 Bind_*.cpp files) contributes ~800-1200MB, the primary memory consumer, but this is legitimate business data.

### Instrumentation 2: Shutdown Phase Step Tracking (`AngelscriptEngine.cpp` Shutdown)

```cpp
auto LogShutdownPhaseMemory = [this](const TCHAR* Phase)
{
    FPlatformMemoryStats MemStats = FPlatformMemory::GetStats();
    UE_LOG(Angelscript, Display, TEXT("[ShutdownPhase:%s] engine=%p PhysMB=%llu VirtMB=%llu"),
        Phase, this,
        MemStats.UsedPhysical / (1024 * 1024),
        MemStats.UsedVirtual / (1024 * 1024));
};
```

Called at Shutdown start and before/after Release.

**Finding**: After AS engine `ShutDownAndRelease()`, PhysMB barely decreases, indicating the allocator does not return pages.

### Instrumentation 3: Release Phase Step Tracking (`AngelscriptEngine.cpp` ReleaseOwnedSharedStateResources)

```cpp
auto LogReleaseMem = [](const TCHAR* Phase)
{
    FPlatformMemoryStats MemStats = FPlatformMemory::GetStats();
    UE_LOG(Angelscript, Display, TEXT("[ReleasePhase:%s] PhysMB=%llu VirtMB=%llu"),
        Phase,
        MemStats.UsedPhysical / (1024 * 1024),
        MemStats.UsedVirtual / (1024 * 1024));
};
```

Called after AS engine release, each TypeDB/BindState/BindDB/StaticNames Reset, global container cleanup, and JIT/Docs cleanup step. Also outputs AS engine object statistics and Docs TMap counts.

**Findings**:
- `TypeDatabase.Reset()` and `BindDatabase.Reset()` release small amounts of memory
- Global container cleanup itself has minimal memory impact, but eliminates dangling pointer risk
- The allocator does not return memory overall — `FMemory::Trim(true)` has limited effect on mimalloc

### Instrumentation 4: Per-Bind Tracking (`AngelscriptBinds.cpp` CallBinds)

```cpp
const FPlatformMemoryStats BindsStartMem = FPlatformMemory::GetStats();
// ... per-bind tracking ...
const uint64 PrePhys = FPlatformMemory::GetStats().UsedPhysical / (1024 * 1024);
Bind.Function();
const uint64 PostPhys = FPlatformMemory::GetStats().UsedPhysical / (1024 * 1024);
if (PostPhys > PrePhys)
{
    UE_LOG(Angelscript, Display, TEXT("[BindMem] #%03d '%s' +%lluMB (total %lluMB)"),
        BindIndex, *Bind.BindName.ToString(), PostPhys - PrePhys, PostPhys);
}
```

**Finding**: Identified the highest-consumption binds (Blueprint type registration, Actor binding, etc.), but these are all legitimate business logic.

### Instrumentation 5: Memory Lifecycle Tests (`AngelscriptEngineMemoryLifecycleTests.cpp`)

A ~555-line test file under `Source/AngelscriptTest/GC/` containing:
- `FMemorySnapshot` struct: captures process memory, UObject counts, per-type UObject breakdowns
- Before/after comparison output at each phase
- Full create → destroy → GC cycle memory tracking

**Finding**: Provided quantitative evidence proving UObject leaks and global container accumulation.

### Removal Decision

All instrumentation was removed after diagnostics completed, for these reasons:
1. **Performance overhead**: Each bind (121 total) calling `FPlatformMemory::GetStats()` adds unnecessary system calls
2. **Log noise**: Normal operation does not need this output; it interferes with meaningful logs
3. **Diagnostic purpose achieved**: Real leaks identified and fixed; remaining growth confirmed as UE architectural behavior

The retained meaningful code (~131 lines) focuses purely on the fixes, with no diagnostic logging.

### Post-Fix Regression Verification

After committing fixes, a full build verification (Build succeeded) and test regression run were executed. One regression was discovered:

- **GameplayTagNamespaceGlobals test failure**: Initially `AngelscriptGameplayTagsLookup.Empty()` caused subsequent engine cycles to encounter duplicate GameplayTag registration. The root cause is that `AngelscriptGameplayTagsLookup` serves as a dedup index for the global `AngelscriptGameplayTags` TChunkedArray — clearing the lookup without clearing the array causes linear growth, and clearing both breaks `AngelscriptRebindGameplayTagsToCurrentEngine()`. Fix: preserve `AngelscriptGameplayTagsLookup` and add comments explaining the rationale.
