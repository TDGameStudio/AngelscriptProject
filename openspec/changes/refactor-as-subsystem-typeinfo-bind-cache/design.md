## Context

Today bind discovery is already process-wide: file-static `FAngelscriptBind` records seal into one callback collection. `UAngelscriptSubsystem` loads generated modules, seals that collection, and owns the primary `FAngelscriptEngine`, but it stores **no** expanded bind surface. Each engine still does this:

```text
ExecuteRegisteredBinds
  → every lambda
    → GetTargetEngine() / TypeDB / BindDB
    → asIScriptEngine::Register*
```

`FAngelscriptType` remains the per-engine adapter (property, GC, debugger, `GetCppForm`). `asITypeInfo` remains the AngelScript runtime type object. Neither is a process snapshot of "what this type binds".

StaticJIT generation and isolation tests create extra engines and pay full replay. Lambdas are not pure: they read editor-script flags, `bSimulateCooked`, BindDB vs reflection (`AS_USE_BIND_DB` is compile-time `!WITH_EDITOR`), and live UE data (UClass lists, collision profiles).

This change adds a **third** object, named by product intent:

| Name | Lifetime | Meaning |
|---|---|---|
| `asITypeInfo` | one `asIScriptEngine` | AngelScript runtime type |
| `FAngelscriptType` | one `FAngelscriptEngine` TypeDB | UE adapter (GC, property, JIT spelling helper) |
| `FAngelscriptTypeBindInfo` | process, on `UAngelscriptSubsystem` | snapshot of **one** script-visible type's bind surface |

`refactor-as-manual-binding-architecture` made "no expanded cache" an explicit non-goal. `refactor-as-primary-engine-typed-ast-generate` deferred a bind-surface snapshot. This change is that snapshot, scoped as a per-type array rather than one opaque blob.

## Goals / Non-Goals

**Goals:**

- One `FAngelscriptTypeBindInfo` per script-visible type (including enum, template, and namespace-as-type).
- `UAngelscriptSubsystem` holds `TArray<FAngelscriptTypeBindInfo>` and a name index.
- `FAngelscriptBind` stays the CRT discovery object. One recording Expand writes the full bind surface (types and methods) into that array. Each later engine Applies the array.
- Parallelize **expansion** of eligible Explicit fills. Apply into `asIScriptEngine` stays sequential in this change.
- Keep `FAngelscriptType` adapters, BindDB, and per-engine TypeDB. TypeBindInfo does not replace them.

**Non-Goals:**

- A second discovery type (`FAngelscriptTypeBindInfoProvider`).
- Keeping `EAngelscriptBindPhase` as the migrated authoring or expand schedule (it remains only on unmigrated `FAngelscriptBind` until those files migrate).
- Concurrent `Register*` / atomic type insertion into one live `asIScriptEngine` (follow-on: `feature-as-multithreaded-type-registration`).
- Symbolic execution of `if (ShouldUseEditorScripts())` inside existing lambdas. v1 records by **surface expansion passes** and tags members.
- Auto-generating AS declaration strings from C++ pointers.
- Merging BindDB, TypeInfo, and the Generate native-form catalog into one disk format.
- Implementing matching-profile TypedASTJIT Generate or Cache V2 HIR.
- Moving TypeInfo into `UAngelscriptGameInstanceSubsystem` (world-scoped; wrong lifetime).
- Making `FAngelscriptTypeBindInfo` a `USTRUCT`/`UPROPERTY` (it holds native callable identities and must not be GC-serialized).

## Decisions

### 0. Class map (process record vs engine runtime)

**Choice:** Keep today's `FAngelscriptBind` as the only discovery object. Add `FAngelscriptTypeBindInfo` as the process catalog row. Do not add `FAngelscriptTypeBindInfoProvider`.

Full diagram and table: `attachments/class-map.md`. Per-call ownership (`Store.Value` / `Method` / `Adapter` / `NativeTemplateInstantiatedCall`): `attachments/dsl-ownership.md`.

```text
FAngelscriptBind                 discover who (CRT)
        │ one recording Expand
        ▼
FAngelscriptTypeBindInfo         record what (process, one type)
        │ Apply per FAngelscriptEngine
        ▼
asITypeInfo + FAngelscriptType   runtime (this engine only)
```

Expand records **anything** on the bind surface (type, enum, method, property, adapter, namespace). `EApplySlot` on each member is Apply metadata. `RegisterKind` on `FAngelscriptBind` is only data dependency (Explicit vs needs live `UClass`).

### 1. `FAngelscriptTypeBindInfo` is exactly one type

**Name:** `FAngelscriptTypeBindInfo`, not `FAngelscriptTypeInfo`. `asITypeInfo` is the AngelScript runtime type object; `FAngelscriptType` is the per-engine UE adapter. This struct is the process-level **bind surface** for one script type (declarations, members, conditions, native recipes). Putting `Bind` in the identifier is the point.

**Choice:** One struct instance describes one Angelscript type name (`FVector`, `UObject`, `TArray`, `ECollisionChannel`, `Hash` as a namespace type). The subsystem stores an array of them, not one process mega-object.

**Fields (logical, pointer-free except UE/callable identities):**

- Identity: `AngelscriptTypeName`, `EAngelscriptTypeBindKind` (`Value`, `ObjectHandle`, `Enum`, `Interface`, `Template`, `Namespace`), optional UE path (`UClass`/`UScriptStruct`/`UEnum` as `TWeakObjectPtr` or name+path, never `asITypeInfo*`).
- Type-level `FAngelscriptBindCondition`.
- Ordered members: type declaration, adapter/ToString/finder, constructors, destructor, methods, properties, behaviours, static/namespace functions. Each member has `EApplySlot { Type, Infrastructure, Members }` so Apply can still `RegisterObjectType` before `RegisterObjectMethod` without a second store.
- Optional `FCppForm` recipe (C++ spelling, header, primitive, native-nest flags) copied from today's `FAngelscriptType::GetCppForm` **when recorded**, not as a live virtual call during Generate.
- Native member recipe: name, header, trivial, reviewed linkage when the DSL supplied `.NativeFunction` / `.NativeFunctionHeader` / `.ExternalNativeCall`.
- `DeclarationOrder` / `MemberOrder` so apply can reconstruct engine registration order across types.

Layout: `attachments/storage.md`.

**Why not one global bind IR blob:** the user-facing unit is a type. Tests, dumps, and later parallel apply all want "give me `FVector`".

**Namespaces and true globals:** a `Kind=Namespace` TypeInfo (`Hash`, `System`, `AssetRegistry`) holds those functions. Do not invent a second subsystem array for globals.

**`FAngelscriptType` adapters:** still registered per engine (they close over BindDB/TypeDB). TypeInfo records *that this type has an adapter kind* and enough data to re-register the adapter on apply (factory id / `RegisterTypeForTarget` equivalent). Adapter **objects** stay engine-owned.

### 2. The array lives on `UAngelscriptSubsystem`

**Choice:** Native members on `UAngelscriptSubsystem`:

```text
TArray<FAngelscriptTypeBindInfo> TypeBindInfos;
TMap<FName, int32> TypeBindInfoIndexByName;
EAngelscriptTypeBindStoreState { Empty, Expanding, Sealed, Failed };
```

Not `UPROPERTY`. Not a static in `AngelscriptBinds.cpp`.

**Why this subsystem:** it already loads generated bind modules, seals the callback collection, and creates the primary engine. That is the correct lifetime (Engine subsystem, editor and game). `UAngelscriptGameInstanceSubsystem` is per-world and must not own process bind snapshots.

**Compatibility bootstrap without `GEngine`:** same store accessed through a process helper that the subsystem adopts on `Initialize`, equivalent to today's bind-collection singleton — but the **canonical owner after subsystem init** is the subsystem. Tests that construct a throwaway `UAngelscriptSubsystem` must not clobber a sealed primary array; they either read the process store or use an explicit `FAngelscriptTypeBindInfoStore` injected for isolation.

**Overturns:** "The subsystem SHALL NOT own a bind array / expanded registration data" from `as-direct-bind-callback-execution` (still unarchived in `refactor-as-manual-binding-architecture`). The sealed **callback** collection remains process-global and compact. The **expanded** per-type array is the new subsystem-owned cache.

### 3. Authoring is two tracks: named Register functions vs expand-time generators

**Choice:** Do **not** construct finished `FAngelscriptTypeBindInfo` rows as C++ static objects. Do **not** add `FAngelscriptTypeBindInfoProvider`. Static initialization still uses **`FAngelscriptBind`**: it only discovers a Register callback. The subsystem array is filled during a **single recording Expand**, when UE reflection exists. That recording pass can record type declarations, methods, adapters, properties, enums, namespaces — anything the bind surface contains. Apply is a later, separate walk.

There are two Register styles, and both are required. **One type, one Register function.** Type declaration, adapter, methods, and the rest of that type's bind surface are written in the same named function, registered by one `FAngelscriptBind`. `EJsonType` is not a second `FAngelscriptBind`. `TArray.Add` is not a second Register function.

**`EAngelscriptBindPhase` is not kept as an authoring or expand schedule.** those seven values exist today because each lambda immediately calls `asIScriptEngine::RegisterObjectType` / `RegisterObjectMethod`, so the process had to run TypeDeclarations globally before ExplicitBindings. After this change that order is **metadata**:

- On each **member**: `EApplySlot { Type, Infrastructure, Members }`. Apply still `RegisterObjectType` then `RegisterObjectMethod`.
- On each **`FAngelscriptBind`**: `EAngelscriptBindRegisterKind { Explicit, Generated, Reflection, PostReflection }` — only "does this Register function need live `UClass`, or must it patch rows that already exist". Not type-vs-method.

Unmigrated `FAngelscriptBind` may still carry a Phase until that file migrates. Migrated files MUST NOT take `EAngelscriptBindPhase`. After migration the enum can be removed. Template methods (`TArray.Add`) are tagged `Infrastructure` so Apply keeps specialization timing without a second Register function. Full examples: `attachments/authoring-examples.md`. Storage: `attachments/storage.md`.

**Track A — explicit types (`FColor`, `FVector`, `TArray`).**  
One named function per bind file (or per type family). File-static discovery points at that function. `FindOrAdd` is allowed: `RegisterFColor` may create the `FColor` row; `RegisterUStructs` later merges flags/reflected properties onto the same row.

```cpp
static void RegisterFVector(FAngelscriptTypeBindInfoStore& Store)
{
	FAngelscriptTypeBindInfo& Row = Store.Value<FVector>("FVector")
		.POD()
		.ExtraObjectFlags(asOBJ_BASICMATHTYPE);

	Row.Adapter<FVectorType>();
	Row.ToString(&FAngelscriptFVectorBinds::AppendToString);
	Row.TypeFinder(/* NetQuantize* — StaticStruct() is legal here */);

	Row.Constructor("void f(float64 X, float64 Y, float64 Z)",
			&FAngelscriptFVectorBinds::ConstructXYZ, "FVector", true)
		.NoDiscard();
	Row.Property("float64 X", &FVector::X);
	Row.Method("float64 Size() const", METHOD_TRIVIAL(FVector, Size));
}

AS_FORCE_LINK const FAngelscriptBind Bind_FVector(
	TEXT("FVector"),
	EAngelscriptBindRegisterKind::Explicit,
	&RegisterFVector);
```

This is still "static declaration" of **who to call**, not of the finished TypeInfo. `FVector_NetQuantize` finders that need `StaticStruct()` run **inside** `RegisterFVector` at expand time, not at `CRT` init.

**Track B — reflected / Blueprint / dynamic UClass sets.**  
These cannot be a closed static TypeInfo list. `Bind_BlueprintType`, `Bind_UStruct`, `Bind_UEnum`, CollisionProfile names, and cooked BindDB walks MUST stay expand-time generators: a named function that **iterates live `UClass` / BindDB** and `FindOrAdd`s many TypeInfo rows. A reflection generator writes a **complete** class row in that same callback (declaration, adapter, reflected members, and Actor `Spawn` when the class is an Actor).

```cpp
static void RegisterBlueprintTypes(FAngelscriptTypeBindInfoStore& Store)
{
	for (UClass* Class : /* captured native classes or BindDB */)
	{
		FAngelscriptTypeBindInfo& Row = Store.FindOrAddObject(TypeNameOf(Class), Class);
		AppendReflectedProperties(Row, Class);
		AppendReflectedFunctions(Row, Class);
	}
}

AS_FORCE_LINK const FAngelscriptBind Bind_BlueprintType(
	TEXT("BlueprintType"),
	EAngelscriptBindRegisterKind::Reflection,
	&RegisterBlueprintTypes);
```

Post-reflection patches are rare. Actor `Spawn` is written on the subclass row inside the Blueprint generator, not a leftover TypeDeclarations/Explicit split. `RegisterKind=PostReflection` stays only for fills that must see **every** Reflection row already created.

**Why not only static `FAngelscriptTypeBindInfo` objects:** C++ static init cannot walk Blueprint-generated `UClass`, cannot safely call `StaticStruct()` in all TUs, and would freeze a type set before modules load. That is exactly today's reason `Bind_BlueprintType` is a lambda.

**Why not only lambdas:** `FColor` does not need `TObjectRange`. A named Register function is easier to edit and test than a 200-line file-static lambda, and it can still be discovered statically.

**v1 compatibility:** keep the existing `FAngelscriptBind(Name, Phase, lambda)` constructor. End state: those callbacks run once during recording Expand and engines Apply. Until a file is recording-safe, v1 uses the bootstrap below.

### 3a. v1 bootstrap (settled before C++)

Unmigrated lambdas still call `GetTargetScriptEngine()`, `GetTypeInfoByName`, `MakeShared` + `RegisterTypeForTarget`, and capture `FAngelscriptTypeDatabase*` inside TypeFinders. They cannot run in an engine-free Expand. Do not pretend wrapping today's `Bind_TArray` lambda is Expand.

**Settled:**

1. **Dual-run (strategy B) for unmigrated providers.** Primary `BindScriptTypes` still `ExecuteRegisteredBinds`. `as.BindFromTypeBindInfo` defaults to `0`. A recording pass may fill TypeBindInfo for diagnostics or for types whose Register functions are recording-safe. It does not replace live `Register*` until that type is on the apply allowlist.
2. **One callback ABI.** CRT stays `void (*)(FAngelscriptBinds&)`. Do not add `void (*)(FAngelscriptTypeBindInfoStore&)` in v1. Recording `FAngelscriptBinds` exposes `GetRecordingStore()`. Target `Store.Value` / `Adapter<T>` authoring is called through that handle. `FAngelscriptBind(Name, RegisterKind, Callback)` uses the same callback type.
3. **TypeFinder / adapter recipes.** Do not store lambdas that capture `TSharedRef<FAngelscriptType>` or `FAngelscriptTypeDatabase*`. Record a factory (`MakeShared<T>` at Apply) and a finder that resolves TypeDB from the **apply-time** engine. Rewrite `Bind_FVector` / `Bind_TArray` finders before those types can Apply-from-TypeInfo on a second engine.
4. **Apply side channels, not only `Register*`.** Apply also rebuilds: adapter factory, TypeFinder recipe, ToString list (`FToStringHelper` / `GetTargetToStringList`), `ClassFunctionBindings`, DefaultArrayType + `ArrayTemplateTypeInfo`, documentation, native-form flags. Recording `FAngelscriptBoundFunction` points at a **member record**, not a live `FunctionId` (today `IsValid()` is false without an engine, so `.PassScriptObjectTypeAsFirstParam()` / `.NativeTemplateInstantiatedCall()` would no-op).

**Apply is per-type, not all-or-nothing.** Extra engines Apply only rows whose providers fully recorded. Everything else stays `ExecuteRegisteredBinds` / `ReplayOnly`. Do not set the flag so a sealed store drives the whole engine while BlueprintType is still ReplayOnly.

Engine-free Expand (register-timing end state) is the goal for **migrated** Register functions only. Parallel expand stays last and does not speed up the first engine.

### 4. Recording backend, not a second script engine

**Choice:** `FAngelscriptBinds` gains a recording mode whose `Method` / `Property` / `ReferenceClass` / `RegisterType` paths append to TypeInfo instead of calling `asIScriptEngine`. Queries that today's lambdas make (`ExistingClassForTarget`, `HasMethod`, `GetTypeInfo`) read the **in-progress TypeInfo array**, not `asITypeInfo*`.

**Why not expand by creating a throwaway `FAngelscriptEngine`:** that is current replay. It is not thread-safe, and it produces engine pointers we refuse to cache.

**Expand order is RegisterKind (data dependency), not `EAngelscriptBindPhase`.** Migrated Register functions run `Explicit` (complete named Register functions, UObject-free ones MAY be parallel) → `Generated` → `Reflection` → `PostReflection`. Within a pass, `FindOrAdd` means `RegisterFColor` does not wait for a UStruct "type-only" Register function — there is no type-only Register function. Unmigrated `FAngelscriptBind` lambdas MAY still execute in today's seven-phase order until that file migrates. Parallelism is only **within** a pass among providers marked eligible (see decision 5).

**Callable identities:** store the same `asSFuncPtr` / named owner / `FUNC` pointer the lambda would have passed to `Register*`. Apply uses them. This is process-lifetime C++ identity, not an AngelScript object.

### 5. Parallel expansion is bounded; reflection stays on the Game Thread

**Choice:** After seal, `UAngelscriptSubsystem` runs expansion:

1. `Explicit` (complete named Register functions) → `Generated` → `Reflection` → `PostReflection` → `Finalization`. Do **not** invent `TypeDeclarations` / `TypeInfrastructure` RegisterKinds. Unmigrated lambdas may still be grouped by their original `EAngelscriptBindPhase` until migrated.
2. Inside a pass, providers in `ParallelExpand` may run on the thread pool if they are classified **UObject-free and engine-free** (no `TObjectIterator`, no `FindObject`, no `asIScriptEngine`, no `GetTargetBindDatabase` mutation that is not the recorder). Default for unknown providers: Game Thread sequential.
3. Each worker writes a **private** shard (`ParallelForWithTaskContext`), not a shared `TArray::Add`. Merge by `AngelscriptTypeName` on the Game Thread after join (append members, reject conflicting type kinds). `FCriticalSection` is only for that merge / name-index insert, never around every `.Method()`.
4. Reflection **capture** (`TObjectRange` / BindDB walk) stays Game Thread. Once `ClassesToBind` indices exist, keep today's unique-index `ParallelFor` prepare (`as.Bind.ParallelPrepare`) writing only `ClassesToBind[i]` — the same pattern as Phase 2A. Do not invent a concurrent `TMap` catalog. Details: `attachments/multithreaded-write.md`. Named UE call sites (shader types, `FRepLayout`, `FAttributeTypeRegistrar`, Chaos/Zen `ParallelForWithTaskContext`): `attachments/ue-analogs.md`.

**Why not "every lambda on a worker":** UE reflection and `UCollisionProfile::GetProfileNames()` are not thread-safe. `asIScriptEngine` is not thread-safe. Most small `Bind_FVector` lambdas **are** eligible once they stop calling `GetTargetEngine()` for registration and use the recorder.

**Async:** expansion MAY start on a background task after seal, but **primary engine bind MUST wait** for `Sealed` or `Failed`. Do not tick the Editor with a half-applied engine. Optional: overlap generated-module load with nothing else; seal still precedes expand.

### 6. Conditions are recorded; apply filters per engine

**Choice:** `FAngelscriptBindCondition` on type and member:

| Field | Meaning |
|---|---|
| `EditorScripts` | `Any` / `Required` / `Forbidden` |
| `SimulateCooked` | `Any` / `Required` / `Forbidden` |
| `EditorOnlyTrait` | maps today's `.EditorOnly()` |
| `CompileOutPolicy` | maps `CompileOutInTest` / Shipping (record the **policy**, do not pre-mutate as if the expander's engine were Shipping) |

`AS_USE_BIND_DB` is compile-time. One process, one expansion path (Editor reflection **or** cooked BindDB). It is not a runtime condition bit.

**v1 expansion passes:** do **not** pretend one Editor-flagged lambda run records the Shipping `else` branch. Record by pass:

- Pass `EditorDevelopment`: `ShouldUseEditorScripts=true`, `bSimulateCooked=false`. Tag produced members `VisibleOn.EditorDevelopment`.
- If this process will bind a cooked/generation surface: Pass `GameShipping` / `GameDevelopment` with those flags, merge by `(TypeName, Declaration)`, union visibility bits.
- Cooked packaged process: only the cooked pass.

Apply: engine surface ⊆ member visibility, plus condition predicates, plus `.EditorOnly()` vs `ShouldUseEditorScripts()`.

**Why not one union pass:** lambdas contain real `if (ShouldUseEditorScripts())` branches. Without rewriting them to DSL predicates, a second pass is the only correct recorder.

**ConfigSettings** that change the type set (`AdditionalEditorOnlyScriptPackageNames`, `bAllowRawConstructorsForComponentsAndActors`) hash into the TypeInfo seal identity. Changing them requires process restart (same as today's bind-once-at-startup reality).

### 7. Engine bind applies TypeInfo sequentially

**Choice:** `FAngelscriptEngine` initialization, after its `asIScriptEngine` exists:

1. Read sealed `TypeBindInfos` from the subsystem (or injected store in tests).
2. Filter by this engine's surface.
3. Apply in `DeclarationOrder`, then per-row `ApplySlot` (`Type` → `Infrastructure` → `Members`) and `MemberOrder`. This is where AngelScript's type-before-method rule is honored. Template methods tagged `Infrastructure` register before other types' `Members` (same timing as today's `Bind_TArray_MethodSurface`).
4. Re-create per-engine `FAngelscriptType` adapters and type finders from recorded adapter recipes.
5. Do **not** call `ExecuteRegisteredBinds` for providers that fully recorded. Providers that failed to record (or are explicitly `ReplayOnly`, e.g. NativeModuleFunctionAddress exception until its own change) still replay.

**v1 apply is single-threaded.** Throughput win for extra engines is "skip reflection walk + skip lambda C++", not parallel `Register*`. Extra engines Apply only fully recorded types until the flag covers a whole surface.

**Parity:** for a given surface, `GetObjectTypeCount` / method counts / BindDB-equivalent declarations MUST match today's lambda replay. BindingArchitecture and Bindings suites lock this.

**Parity:** for a given surface, `GetObjectTypeCount` / method counts / BindDB-equivalent declarations MUST match today's lambda replay. BindingArchitecture and Bindings suites lock this.

### 8. Follow-on: threaded AngelScript registration

**Choice:** record the intent, do not implement.

AngelScript's `asCScriptEngine` type/function registration is not atomic. Concurrent `RegisterObjectType` on one engine is undefined. A later change would need:

- per-engine registration lock (easy, little speedup), or
- sharded type registry + atomic type-id allocation (hard, real speedup), plus
- apply by independent TypeInfo groups (templates first, then values, then objects).

TypeInfo's per-type array is the **prerequisite data shape** for that work. This change stops at sequential apply.

### 9. Relationship to other OpenSpecs

- **Do not implement** `refactor-as-primary-engine-typed-ast-generate` here.
- Function native-form catalog in that change keys recipes by declaration. TypeInfo **member native recipes** are the same facts stored next to the type. When both land, Generate SHOULD read TypeInfo (or a view over it) instead of a second table. Until then, recording `.NativeFunction*` into TypeInfo is enough for apply; Generate may keep today's collect-on pointer map.
- BindDB stays the cooked **input** to expansion, not a second apply path. Cooked still expands BindDB → TypeInfo once, then every engine applies TypeInfo.

## Risks / Trade-offs

- **[Parity drift]** Recorder misses a `FAngelscriptBinds` API → silent missing method. → Fail closed: unhandled bind API marks provider `ReplayOnly` or fails seal. Golden counts from BindingArchitecture.
- **[Wrong surface]** One Editor pass used for Shipping apply. → Require visibility bits; refuse apply if the engine surface was never expanded.
- **[Thread safety]** Worker touches `TObjectIterator`. → Default sequential; allowlist + tests that run workers under the automation race detector where available.
- **[Memory]** Expanded TypeBindInfo is larger than callback pointers. → Accept for Editor/test/generation; this is the point. Do not persist TypeBindInfo to disk in v1. Expected cost model: `attachments/performance.md`. Author examples: `attachments/authoring-examples.md`.
- **[Subsystem vs static store]** Tests constructing subsystems. → Explicit store pointer; primary seal is process-once.
- **[Name collision]** `FAngelscriptTypeInfo` was rejected because it reads as `asITypeInfo`. Use `FAngelscriptTypeBindInfo`. Dump labels say "type-bind info"; never store `asITypeInfo*` on it.

## Migration Plan

1. Land TypeInfo types + empty subsystem array + tests (no behavior change).
2. Recording `FAngelscriptBinds` for a synthetic probe; `FAngelscriptBoundFunction` writes member records. Dual-run: primary still `ExecuteRegisteredBinds`; flag default 0.
3. Rewrite TypeFinder/adapter capture on `Bind_FVector` (then `Bind_TArray`) into recipes. Extra engines Apply **only those types**.
4. Grow the apply allowlist (ToString, ClassFunctionBindings, DefaultArrayType, reflection generators). Do not flip the whole engine to Apply while BlueprintType is ReplayOnly.
5. Switch extra engines of a fully recorded surface, then primary, behind `as.BindFromTypeBindInfo`.
6. Enable parallel expand for allowlisted Explicit fills.
7. Keep lambda replay as `ReplayOnly` until NativeModuleFunctionAddress converges.

Rollback: feature flag `as.BindFromTypeBindInfo` (default **0** until parity) restores `ExecuteRegisteredBinds`.

## File map

| Path | Responsibility |
|---|---|
| `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptTypeBindInfo.h` | `FAngelscriptTypeBindInfo`, `EApplySlot`, conditions, member records, kind enum |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptTypeBindInfo.cpp` | lookup, merge, visibility filter |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptTypeBindInfoStore.h` | array + index + seal state; used by subsystem |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptTypeBindInfoRecorder.cpp` | recording `FAngelscriptBinds` backend; record-pass expand; shard merge |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptTypeBindInfoApply.cpp` | sequential `Register*` by ApplySlot |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptSubsystem.h/.cpp` | own the store; expand after callback seal; wait before primary bind |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptBinds.h/.cpp` | recording vs engine target; stop being the only apply path |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.cpp` | bind from store when a type is allowlisted; replay otherwise |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FVector.cpp` | first production recipe migration |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_TArray.cpp` | second production recipe migration |
| `Plugins/Angelscript/Source/AngelscriptTest/Core/AngelscriptTypeBindInfoTests.cpp` | unit: one type, conditions, merge, no AS pointers |
| `Plugins/Angelscript/Source/AngelscriptTest/Core/AngelscriptTypeBindInfoApplyTests.cpp` | isolated engine apply parity vs replay |
| `openspec/changes/refactor-as-subsystem-typeinfo-bind-cache/attachments/class-map.md` | class roles after the refactor |

## Open Questions

- Exact allowlist of first parallel Explicit fills (`Bind_FVector`, `Bind_FColor`, other POD families). Resolve during task 6.1 with a source audit, not by guessing.
- Whether a second surface pass is expanded eagerly at Editor startup or lazily on first Shipping generation Engine. Prefer **lazy second pass**, then merge, so ordinary Editor start pays one expand.
