# How `FAngelscriptType` is handled

`FAngelscriptTypeBindInfo` does **not** replace `FAngelscriptType`. Three objects remain:

| Object | Lifetime | Job |
|---|---|---|
| `asITypeInfo*` | one `asIScriptEngine` | AngelScript runtime type |
| `FAngelscriptType` (`TSharedRef`, in that engine's TypeDB) | one `FAngelscriptEngine` | UE adapter: property, GC, debugger, `GetCppForm`, `GetByClass` |
| `FAngelscriptTypeBindInfo` | process, subsystem array | bind snapshot + **adapter recipe** to rebuild the above |

Today `Bind_FVector_TypeInfrastructure` does `MakeShared<FVectorType>()` then `RegisterTypeForTarget`. After this change, expand records `Row.Adapter<FVectorType>()`; apply does the `MakeShared` + `Register` into **this** engine's `FAngelscriptTypeDatabase`.

## Why the live adapter stays per-engine

`FAngelscriptType` virtuals close over engine-scoped state:

- `GetAngelscriptTypeInfo(Usage)` returns `asITypeInfo*`
- `FAngelscriptTypeUsage` holds `asITypeInfo* ScriptClass` or `FProperty*`
- TypeDB maps: `TypesByClass`, `TypesByAngelscriptName`, `TypeFinders`
- GC / debugger / `CreateProperty` run against that engine's objects

A process-wide `TSharedRef<FVectorType>` would dangle when Engine A tears down. TypeBindInfo must not store `FAngelscriptType*` or `asITypeInfo*`.

## What expand records

On the TypeBindInfo row (`ApplySlot=Infrastructure`):

- **Adapter recipe:** factory id (`FVectorType`, `FAngelscriptArrayType`) or `AdapterFromClass` / `AdapterFromStruct` (the `UClass*` / `UScriptStruct*` identity, not the live adapter).
- **Type finder:** the same `TFunction<bool(FProperty*, FAngelscriptTypeUsage&)>` registered today (`FVector_NetQuantize*` → `FVector`, `FArrayProperty` → `TArray<Inner>`). The function pointer / lambda is process C++ identity; apply registers it on that engine's TypeDB.
- **Default array flag** (TArray only): `DefaultArrayType()` records that this template is AngelScript's default array type. It is **not** an `FAngelscriptType`. Apply later calls `asIScriptEngine::RegisterDefaultArrayType` and stores `TypeDB.ArrayTemplateTypeInfo`.
- **CppForm snapshot:** `FCppForm` copied from `GetCppForm` **when recorded**, for Generate. Runtime still calls the live virtual on the per-engine adapter.

## `Adapter<T>()` vs `DefaultArrayType()` — who implements what

These two DSL calls on `TArray_` look similar in `RegisterTArray`. They are **not** the same object and are **not** implemented by `Bind_TArray.cpp`.

```text
Bind file (authoring)
  TArray_.Adapter<FAngelscriptArrayType>()
  TArray_.DefaultArrayType()
        │
        ▼ Expand (once) — FAngelscriptTypeBindInfo methods, no asIScriptEngine
  row.AdapterRecipe.Factory = &MakeShared<FAngelscriptArrayType>
  row.bDefaultArrayType = true
        │
        ▼ Apply (each engine) — FAngelscriptTypeBindInfoApply
  MakeShared<FAngelscriptArrayType>()
  FAngelscriptType::Register(ThisEngine.TypeDB, Adapter)
  ThisEngine.asIScriptEngine.RegisterDefaultArrayType("TArray<T>")
  ThisEngine.TypeDB.ArrayTemplateTypeInfo = Engine.GetTypeInfoByName("TArray")
```

| Call in `RegisterTArray` | What it records | Who implements the DSL | Who actually runs on Apply | Existing class that already does the work |
|---|---|---|---|---|
| `Adapter<FAngelscriptArrayType>()` | A **factory** for a per-engine `FAngelscriptType` | `FAngelscriptTypeBindInfo::Adapter<T>()` (new, ~one template that stores `[]{ return MakeShared<T>(); }`) | `FAngelscriptType::Register(TypeDB, MakeShared<T>())` — same as today's `RegisterTypeForTarget` | **`FAngelscriptArrayType`** in `Bind_TArray.h` / `Bind_TArray_Type.cpp` (GC, property, debugger, `GetCppForm`). Not rewritten. |
| `DefaultArrayType()` | A **flag**: this template is the script default array | `FAngelscriptTypeBindInfo::DefaultArrayType()` (new, sets a bool / member kind) | `asIScriptEngine::RegisterDefaultArrayType("TArray<T>")` **and** `TypeDB.ArrayTemplateTypeInfo = GetTypeInfoByName("TArray")` | AngelScript engine (`as_scriptengine.cpp`) + `FAngelscriptTypeDatabase::ArrayTemplateTypeInfo`. Not rewritten. |

`Adapter<T>()` is **not** `asIScriptEngine::RegisterObjectType`. Type declaration is `Store.Value<FScriptArray>("TArray<class T>")`. The adapter is the **UE TypeDB** object that answers "how does `TArray<T>` become an `FArrayProperty`, how is it GC'd, how does JIT spell `TArray<FVector>`".

`DefaultArrayType()` is **not** the adapter. Today `Bind_TArray_TypeInfrastructure` does two extra lines that only TArray needs:

```cpp
Binds.GetTargetTypeDatabase().ArrayTemplateTypeInfo = Binds.GetTargetScriptEngine().GetTypeInfoByName("TArray");
Binds.GetTargetScriptEngine().RegisterDefaultArrayType("TArray<T>");
```

- `RegisterDefaultArrayType` — AngelScript language: this template is the default array (initializer / `T[]` machinery).
- `ArrayTemplateTypeInfo` — plugin cache so other code (`Bind_AActor_Functions`, `Bind_USceneComponent`, `Bind_UDataTable`) can test `ObjectType->templateBaseType == ArrayTemplateTypeInfo` ("is this a `TArray<…>` specialization?"). That pointer is **per engine** and cannot live on TypeBindInfo.

Apply must run `DefaultArrayType` in the **Infrastructure** slot: `RegisterObjectType("TArray<class T>")` already happened in the Type slot, so `GetTypeInfoByName("TArray")` is valid.

### What `Bind_TArray.cpp` does **not** implement

`RegisterTArray` does not contain `MakeShared`, `RegisterTypeForTarget`, or `RegisterDefaultArrayType`. Those stay in:

1. **TypeBindInfo recorder** — `Adapter<T>()` / `DefaultArrayType()` / `TypeFinder()` write recipes.
2. **Apply** — walks recipes into **this** engine.
3. **Already-existing types** — `FAngelscriptArrayType`, `FAngelscriptArrayIteratorType`, `FAngelscriptArrayConstIteratorType` keep their virtuals. `FArrayOperations` stays the VM thunk. `asCScriptEngine::RegisterDefaultArrayType` stays upstream AngelScript.

The only new C++ template is the one-line factory inside `Adapter<T>()`. No type-list metaprogramming.

`GetCppForm` on `FVectorType` / `FAngelscriptArrayType` stays a virtual. TypeBindInfo does not become a second implementation of GC/property/debugger.

## What apply does

For each visible row, `ApplySlot=Infrastructure`:

1. Construct a new `TSharedRef<FAngelscriptType>` from the recipe (`MakeShared<FVectorType>()` / `MakeShared<FAngelscriptArrayType>()`, or the UStruct/UClass helper).
2. `FAngelscriptType::Register(ThisEngine.TypeDB, Adapter)`.
3. Register recorded type finders on `ThisEngine.TypeDB`.
4. If `bDefaultArrayType`: `asIScriptEngine::RegisterDefaultArrayType` for that template name, then `TypeDB.ArrayTemplateTypeInfo = GetTypeInfoByName(...)`.
5. Do **not** reuse Engine A's adapter object.

`GetByClass(ThisEngine.TypeDB, AActor::StaticClass())` works again after that engine's apply, same as today.

## Queries during expand

Today PostReflection/`GetByClass` decides whether to add `Spawn`. During expand there is no TypeDB yet. After this change `RegisterBlueprintTypes` writes `Spawn` on that class row while filling it; lookup is the in-progress TypeBindInfo, not TypeDB / `asITypeInfo*`.

Recorder answers from the in-progress TypeBindInfo array: a row with `Kind=ObjectHandle` and an `AdapterFromClass` recipe counts as "this class is bound". Do not create a throwaway TypeDB just to answer that.

## What is not cached process-wide

- The `TSharedRef<FAngelscriptType>` itself
- `FAngelscriptTypeDatabase` (still per `FAngelscriptEngine`)
- `asITypeInfo*` reached through `GetAngelscriptTypeInfo`

BindDB stays cooked **input** to expansion (which UStructs/UClasses exist). TypeDB stays the per-engine **runtime** adapter table. TypeBindInfo is the process **recipe**.
