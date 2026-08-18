# Recording notes

How bind fill providers become `TArray<FAngelscriptTypeBindInfo>` without a live `asIScriptEngine`. Layout: `storage.md`.

## Two collections after this change

```text
FAngelscriptBind collection (static)    file-static callback + RegisterKind
                                        (legacy: Phase + lambda)
                                        discovers WHO to call

UAngelscriptSubsystem::TypeBindInfos    filled at the recording Expand
  TArray<FAngelscriptTypeBindInfo>      one row = one type
                                        WHAT was recorded
```

There is no `FAngelscriptTypeBindInfoProvider`. `FAngelscriptBind` stays the discovery object. Expand is one recording phase: a Bind callback may record type, methods, adapter, enum values, namespace functions — anything. Engines **apply** the rows; they do not re-run Bind callbacks (except ReplayOnly).

## Recording is one write; Apply still types-then-methods

Expand does not call `asIScriptEngine::RegisterObjectType` / `RegisterObjectMethod`. One Register function writes declaration + adapter + methods onto the same row. Each member carries `EApplySlot { Type, Infrastructure, Members }`. Apply uses those slots because a live `asIScriptEngine` still cannot register methods before the type.

Do not keep `Bind_FVector_TypeDeclarations` and `Bind_FVector` as two recording providers. Do not keep `Bind_Json_TypeDeclarations`. Tag `TArray.Add` as `Infrastructure` instead of a second Register function.

`EAngelscriptBindPhase` is not an expand schedule for migrated files. Provider `RegisterKind` is only Explicit / Generated / Reflection / PostReflection (data dependency). `FindOrAdd` means `RegisterFColor` does not wait for a UStruct type-only Register function — there is no type-only Register function.

Unmigrated `FAngelscriptBind` lambdas MAY still run in today's seven-phase order until that file migrates. Then the enum can be deleted.

## Two fill tracks

| Track | When | Example |
|---|---|---|
| Named Register function | Type set known in C++ (`FColor`, `FVector`, `TArray`) | `RegisterFColor(Store)` |
| Expand-time generator | Must query `UClass` / BindDB / profiles | `RegisterBlueprintTypes(Store)` |

Do not construct finished TypeInfo as a C++ static global. `StaticStruct()` and Blueprint `UClass` iteration belong inside expand-time functions, never `CRT` constructors.

Existing `FAngelscriptBind` lambdas are the same discovery objects in v1; recording mode writes TypeBindInfo instead of `asIScriptEngine::RegisterObjectType` / `RegisterObjectMethod`.

## Recorder answers queries

Today `ExistingClassForTarget("FVector")` talks to `asIScriptEngine`. During expand it must talk to the in-progress array: find/create the `FVector` row, return a recording class handle whose `Method()` appends a member.

`HasMethod` reads that row's members. `GetTypeInfo()` on `FAngelscriptBinds` during expand returns null or a recorder stub — never a cached `asITypeInfo*`.

## Conditions

Do not interpret C++ `if` branches. Run one expansion pass per bind surface this process needs. Tag members with `VisibleOn`. Apply filters.

`CompileOutInTest` is stored as policy on the member, then applied with the **target** engine's `bSimulateCooked` / build configuration.

## Parallelism

Only Explicit fill functions that are UObject-free. Reflection generators stay on the Game Thread.

## Native recipes

`.NativeFunction` / `.NativeFunctionHeader` / `.ExternalNativeCall` write onto the member of that type's TypeInfo. They are not a reason to keep `asIScriptFunction*`. Generate catalog in `refactor-as-primary-engine-typed-ast-generate` can later view these members; this change does not implement Generate lookup.
