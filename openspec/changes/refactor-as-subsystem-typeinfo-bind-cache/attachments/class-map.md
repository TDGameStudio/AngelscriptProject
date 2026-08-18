# Class map after this change

Canonical object model for `refactor-as-subsystem-typeinfo-bind-cache`. Not compiled C++.

## Three lifetimes

| Object | Owner | Job |
|---|---|---|
| `FAngelscriptBind` | process, file-static collection | **Discover** who to call. CRT only. Does not hold type content. |
| `FAngelscriptTypeBindInfo` | `UAngelscriptSubsystem` store | **Record** one script-visible type (declaration + methods + adapter recipe + conditions). |
| `asITypeInfo*` | one `asIScriptEngine` | AngelScript runtime type after Apply. |
| `FAngelscriptType` | one engine TypeDB | UE adapter after Apply (GC, property, debugger, `GetCppForm`). |

There is no `FAngelscriptTypeBindInfoProvider`. Do not store `asITypeInfo*` or live `FAngelscriptType*` on TypeBindInfo.

Per-call “who implements this DSL”: `attachments/dsl-ownership.md`. `Adapter` / `DefaultArrayType`: `attachments/angelscript-type-adapter.md`.

## Two different "Register" words

| Name | When | What it does |
|---|---|---|
| `RegisterFVector` / `RegisterJson` | Expand, once per surface | Writes `FAngelscriptTypeBindInfo`. Does **not** call into a live `asIScriptEngine`. |
| `asIScriptEngine::RegisterObjectType` / `RegisterObjectMethod` | Apply, each engine | Installs the recorded row into **this** engine. |

The authoring function is `RegisterXxx`. Engine APIs stay written as `asIScriptEngine::RegisterObjectType` (not bare `Register*`).

## Process vs engine

```text
CRT
  FAngelscriptBind(Name, RegisterKind, &RegisterXxx)     // discover
  FAngelscriptBind(Name, Phase, lambda)          // v1 unmigrated / ReplayOnly

one recording Expand (per bind surface this process needs)
  run those callbacks once
  anything is recordable: type, enum, method, property, adapter, namespace
  write FAngelscriptTypeBindInfoStore
  no asIScriptEngine::RegisterObjectType / RegisterObjectMethod

each FAngelscriptEngine
  Apply sealed store by EApplySlot: Type → Infrastructure → Members
  asIScriptEngine::RegisterObjectType / RegisterObjectMethod + MakeShared adapter
  do not re-run RegisterXxx (except ReplayOnly)
```

Expand is **one recording phase** relative to Apply. Inside Expand, callbacks are ordered only by `RegisterKind` (data dependency: generated modules, live `UClass`). That is not `EAngelscriptBindPhase` and not type-vs-method.

## Class roles

| Class | After this change |
|---|---|
| `FAngelscriptBind` | Discovery ticket. Migrated ctor: `RegisterKind` + `&RegisterXxx`. Legacy ctor: `Phase` + lambda, still run once at Expand through the recorder. ReplayOnly uses `asIScriptEngine::RegisterObjectType` / `RegisterObjectMethod` on that engine. |
| `FAngelscriptBinds` | DSL façade inside a callback. Recording mode appends to the store. Live mode only for ReplayOnly. |
| `FAngelscriptTypeBindInfoStore` | Expand write face / sealed catalog: `Value` / `Enum` / `FindOrAdd`. |
| `FAngelscriptTypeBindInfo` | One row = one type name. |
| `FAngelscriptTypeBindInfoMember` | One recorded action + `EApplySlot` metadata. |
| `FAngelscriptBoundFunction` | Recording: mutates the member (`.NativeFunction`, `.EditorOnly`). Must not hold `asIScriptFunction*`. |
| `UAngelscriptSubsystem` | Owns the store. Seals binds, runs Expand, waits before primary Apply. |
| `FAngelscriptEngine` | Apply from the store into its `asIScriptEngine` + TypeDB. |
| BindDB | Cooked **input** to Expand. Not a second Apply path. |

```text
FAngelscriptBind                 who
        │ Expand records once
        ▼
FAngelscriptTypeBindInfo         what (process)
        │ Apply per engine
        ▼
asITypeInfo + FAngelscriptType   runtime (this engine)
```
