# UE analogs for TypeBindInfo expand / apply / parallel write

Knot source: UE5-main (`UnrealEngine@UnrealEngine-ue5-main`). Paths are engine-relative. Recorded so later C++ can copy a named pattern instead of inventing one.

**No 1:1 product analog.** UE does not cache a process-wide AngelScript bind surface. The matches are *pipeline shapes*. Closest overall: shader type list + ShaderCompileWorker + Game Thread finalize. Closest bind-specific: this plugin's BlueprintType Phase 2A/2B.

## Match table

| Our piece | Best UE example | Match quality | Copy? |
|---|---|---|---|
| Static discover Register functions | `FShaderType` `TLinkedList` / `GetTypeList()` | High | Yes — discover only, do not Register in CRT |
| Named Register vs live `UClass` generator | `FAttributeTypeRegistrar` built-in vs user structs | High | Yes — two tracks |
| Expand once, apply many | `FRepLayout` on `UNetDriver::RepLayoutMap` | Medium | Idea yes; ours is process-wide + startup, theirs is per-NetDriver + lazy |
| Unique-index ParallelFor write | BlueprintType prepare; `MeshTransforms::Translate` | High | Yes for Reflection |
| Worker shard then merge | `ParallelForWithTaskContext`; Chaos `PhysicsParallelForWithContext` | High | Yes for Explicit fills |
| Need-UObject bounce to GT | FindInBlueprint `AssetsPendingGatherQueue` MPSC | High | Only if workers hit UObject |
| Many producers, one consumer | Niagara `GatheredData` `TQueue Mpsc` | Medium | Not the catalog |
| Merge lock around `TMap` | Mutable `FBoneNames` | Medium | Merge only |
| Worker compile, GT apply | `FShaderCompilingManager::ProcessAsyncResults` | High for apply-must-be-GT | Apply stays sequential |
| Concurrent intern table | `FNamePool` shards | Low for us | Do **not** copy |

---

## 1. Static discovery — `FShaderType` linked list

**Where:** `Engine/Source/Runtime/RenderCore/Private/Shader.cpp`

```cpp
FShaderType* FShaderType::GetShaderTypeByName(const TCHAR* Name)
{
	for (TLinkedList<FShaderType*>::TIterator It(GetTypeList()); It; It.Next())
	{
		if (FPlatformString::Strcmp(Name, Type->GetName()) == 0)
			return Type;
	}
	return nullptr;
}
```

`IMPLEMENT_SHADER_TYPE` constructs a file-static `FShaderType` that links onto `GetTypeList()`. Construction does **not** compile shaders.

**Map to us:** `AS_FORCE_LINK FAngelscriptBind` = shader type node. Register function / recording Expand = later compile. CRT must not walk `UClass`. Do not add a second provider class.

---

## 2. Two Register tracks — animation `FAttributeTypeRegistrar`

**Where:** `Engine/Source/Runtime/Engine/Private/Animation/AttributeTypes.cpp`

```cpp
struct FAttributeTypeRegistrar
{
	static void RegisterBuiltInTypes()
	{
		AttributeTypes::RegisterType<FFloatAnimationAttribute>();
		AttributeTypes::RegisterType<FVectorAnimationAttribute>();
		// ...
	}

	static void RegisterUserDefinedStructTypes()
	{
		for (const TSoftObjectPtr<UUserDefinedStruct>& UserDefinedStruct
			: UAnimationSettings::Get()->UserDefinedStructAttributes)
		{
			AttributeTypes::RegisterNonBlendableType(UserDefinedStruct.LoadSynchronous());
		}
	}
};
```

**Map to us:** `RegisterBuiltInTypes` = `RegisterFColor` (compile-known). `RegisterUserDefinedStructTypes` = `RegisterBlueprintTypes` (iterate live UE types at expand). Do not freeze Blueprint classes as C++ static TypeBindInfo.

---

## 3. Walk reflection once, reuse — `FRepLayout`

**Where:**

- Cache: `Engine/Source/Runtime/Engine/Private/NetDriver.cpp` `UNetDriver::GetObjectClassRepLayout`
- Build: `Engine/Source/Runtime/Engine/Private/RepLayout.cpp` `FRepLayout::CreateFromClass` → `InitFromClass`
- Map: `Engine/Source/Runtime/Engine/Classes/Engine/NetDriver.h` `RepLayoutMap`

```cpp
TSharedPtr<FRepLayout> UNetDriver::GetObjectClassRepLayout(UClass* Class)
{
	TSharedPtr<FRepLayout>* RepLayoutPtr = RepLayoutMap.Find(Class);
	if (!RepLayoutPtr)
	{
		RepLayoutPtr = &RepLayoutMap.Add(
			Class, FRepLayout::CreateFromClass(Class, ServerConnection, Flags));
	}
	return *RepLayoutPtr;
}
```

**Match:** one `UClass` walk → snapshot of properties/cmds → later replication does not re-walk.

**Mismatch:** lazy, per `UNetDriver`, not sealed at process start. Extra NetDrivers rebuild. We want **process** TypeBindInfo so extra `FAngelscriptEngine`s skip the walk.

---

## 4. Unique-index ParallelFor — already in this plugin + GeometryCore

**This plugin (bind-specific, copy first):**

`Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_BlueprintType.cpp`

- GT builds `ClassesToBind` (stable indices).
- `ParallelFor(ClassesToBind.Num(), PreparePerClass, Unbalanced)` writes only `ClassesToBind[Index].FunctionPreps`.
- CVar `as.Bind.ParallelPrepare`.
- Phase 2B: `ensure(IsInGameThread())`, then `Register*` / BindDB commit.

**UE GeometryCore (same write rule, different domain):**

`Engine/Source/Runtime/GeometryCore/Private/DynamicMesh/MeshTransforms.cpp`

```cpp
ParallelFor(NumVertices, [&](int vid)
{
	if (Mesh.IsVertex(vid))
	{
		Mesh.SetVertex(vid, Mesh.GetVertex(vid) + Translation);
	}
});
```

Each `vid` is exclusive. No `TArray::Add` from workers.

**Also:** GC `CollectAllReferences` / `VerifyGCAssumptions` in `GarbageCollectionVerification.cpp` / `ReferenceChainSearch.cpp` — worker-local `TArray<UObject*>` over a disjoint `GUObjectArray` slice, then `CollectReferences`.

**Map to us:** Reflection Register keeps capture-on-GT + unique-index prepare into TypeBindInfo rows. Compile path already uses the same idea (`BuildParallelParseScripts` in `AngelscriptEngine.cpp`).

---

## 5. Shard then merge — `ParallelForWithTaskContext`

**API:** `Engine/Source/Runtime/Core/Public/Async/ParallelFor.h`

```cpp
OutContexts.Reset();
OutContexts.AddDefaulted(NumContexts);
ParallelForImpl::ParallelForInternal(..., TArrayView<ContextType>(OutContexts));
```

One context per worker. Body writes `Context` only. Caller merges after join.

**Callers:**

- Chaos `PhysicsParallelForWithContext` — `Engine/Source/Runtime/Experimental/Chaos/Private/Chaos/Framework/Parallel.cpp`
- Zen oplog `SummarizeDiffResults` — `Engine/Source/Programs/ZenOplogDiffTool/Private/OutputDiffResultsOperation.cpp` (`ParallelForWithTaskContext(Summaries, N, [&](FDiffSummary& Context, int32 Index){...}); for (Summary : Summaries) Total += Summary;`)

**Map to us:** Explicit Register shards. Merge by `AngelscriptTypeName` on GT. Not a shared `FindOrAdd`.

---

## 6. Worker produce, Game Thread apply — shader compiler

**Where:** `Engine/Source/Runtime/Engine/Private/ShaderCompiler/ShaderCompiler.cpp` `FShaderCompilingManager::ProcessAsyncResults`

```cpp
check(IsInGameThread());
FScopeLock Lock(&CompileQueueSection);
// drain FinishedJobs into PendingFinalizeShaderMaps
ProcessCompiledShaderMaps(PendingFinalizeShaderMaps, TimeBudget);
```

Workers / ShaderCompileWorker finish jobs off-GT. **Finalize and apply shader maps on Game Thread.** Queue lock is only for handoff, not for every instruction.

**Niagara same split:** `FNiagaraShaderScript::BeginCompileShaderMap` `check(IsInGameThread())` then `FNiagaraCompilationQueue::Queue`. `FNiagaraShaderQueueTickable::ProcessQueue` `check(IsInGameThread())` and is **not re-entrant**. File: `Engine/Plugins/FX/Niagara/Source/NiagaraShader/Private/NiagaraShared.cpp`, `NiagaraEditor/.../NiagaraHlslTranslator.cpp`.

**Map to us:** Expand shards may be off-GT. Apply `Register*` is GT sequential, like `ProcessCompiledShaderMaps`. Do not drain apply from two scopes at once.

---

## 7. Need UObject → enqueue for Game Thread — FindInBlueprint

**Where:** `Engine/Source/Editor/Kismet/Private/FindInBlueprintManager.cpp`

```cpp
/** Thread-safe queue for tracking asset paths that need to gather search
    metadata from a loaded object. This must be done on the main thread */
TQueue<FSoftObjectPath, EQueueMode::Mpsc> AssetsPendingGatherQueue;
```

Workers may know a path. Loading / reflecting the `UObject` is GT.

**Also MPSC (payload, not UObject):** Niagara `NiagaraDataInterfaceExport.cpp` `TQueue<FBasicParticleData, EQueueMode::Mpsc> GatheredData` — comment: multiple threads push.

**Map to us:** If an Explicit worker would `FindObject` / `TObjectIterator`, enqueue to GT instead. Do **not** use `TQueue` as TypeBindInfo storage (no name lookup).

---

## 8. Locked `TMap` intern — Mutable `FBoneNames`

**Where:** `Engine/Plugins/Mutable/Source/CustomizableObject/Internal/MuCO/BoneNames.h`

```cpp
TMap<FString, UE::Mutable::Private::FBoneName> BoneNamesMap;
FCriticalSection CriticalSection;
```

`FindOrAdd` is serialized. Fine for a small intern table; bad around every `.Method()`.

**Also:** Android device detection `TMap` + `FCriticalSection* DeviceMapLock`.

**Map to us:** merge / `TypeBindInfoIndexByName` insert only.

---

## 9. Do not copy — `FNamePool` shards

**Where:** `Engine/Source/Runtime/Core/Private/UObject/UnrealNames.cpp` `FNamePool`

```cpp
FNamePoolShard<ENameCase::IgnoreCase> ComparisonShards[FNamePoolShards];
```

Special-purpose concurrent intern with cache-line padding and batch insert. TypeBindInfo is a typed member catalog with phase order and merge-by-name. Copying FName sharding would be the wrong complexity.

---

## 10. Game Thread iterators — do not Register from workers that walk actors

**Where:** `Engine/Plugins/Experimental/WaterAdvanced/.../ShallowWaterRiverActor.cpp`

```cpp
// Guard with IsInGameThread() because TActorIterator asserts game-thread access,
// and this constructor can run on the async loading thread.
if (IsInGameThread() && GetWorld())
{
	for (TActorIterator<ALandscape> It(...); It; ++It) { ... }
}
```

`UAudioBusSubsystem::ShutdownDefaultAudioBuses` `ensure(IsInGameThread())` before `TObjectIterator`. `GetIsEditorLoadingPackage` `ensure`s off GT/ALT.

**Map to us:** Actor `Spawn` Register and Blueprint capture stay GT. `TObjectIterator<UObject>` being `FThreadSafeObjectIterator` does **not** make `UFunction` metadata + bind recording worker-safe.

---

## 11. Weak / non-matches (so we do not cargo-cult them)

| Example | Why it is not our catalog |
|---|---|
| `IModularFeatures::RegisterModularFeature` in `StartupModule` | Process feature list, not a per-type bind snapshot |
| Niagara `FNiagaraCompilationQueue` `TArray` + `check(IsInGameThread())` on Queue | Single-thread queue, not MPSC |
| `FBlueprintCompilationManager::CompileSynchronously` | Per-asset compile, not process bind cache |
| PCG `InitializeCachedOverridableParams` | Per-settings object cache |

---

## Implementation preference (when C++ starts)

1. Keep BlueprintType unique-index ParallelFor; emit TypeBindInfo rows from those slots.
2. Explicit Register: `ParallelForWithTaskContext` shards, GT merge (Chaos/Zen).
3. Apply: shader-compiler style — workers must not `Register*`; one GT drain.
4. Two authoring tracks: `FAttributeTypeRegistrar`.
5. Static discover: `FShaderType` list / our existing `FAngelscriptBind`.
6. Reject: concurrent `TMap` catalog, `FNamePool` copy, `TQueue` as TypeBindInfo.
