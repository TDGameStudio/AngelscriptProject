# When Register functions run

A Register function is **not** a per-engine bind callback. It is the expand-time producer of `TypeBindInfos`.

## v1 vs end state

**End state** is the timeline below: Expand before primary Apply, no `asIScriptEngine` during Expand, extra engines Apply only.

**v1 bootstrap** (design decision 3a): unmigrated lambdas still need a live `FAngelscriptBinds` target. Primary `BindScriptTypes` keeps `ExecuteRegisteredBinds`. Recording-safe / migrated Register functions may Expand without `Register*`. Extra engines Apply **only** those fully recorded types; other providers replay. `as.BindFromTypeBindInfo` defaults to `0`.

Do not run today's `Bind_TArray` TypeInfrastructure lambda in an engine-free Expand (`GetTypeInfoByName`, `RegisterDefaultArrayType`, TypeFinder capturing TypeDB).

## Process timeline

```text
1. Static / CRT / module load
   FAngelscriptBind constructors
   → discover &RegisterXxx (or today's lambda)
   → the Register function is NOT called
   → StaticStruct() / TObjectRange forbidden here

2. Game Thread: PrepareForEngineInitialization
   (UAngelscriptSubsystem::Initialize or InitializeAngelscript)
   → load BindModules.Cache generated modules (more providers appear)
   → seal the callback collection
   → TypeBindInfo store: Empty → Expanding
   → the Register function is NOT called yet

3. Expand (once per needed bind surface, still before primary `asIScriptEngine` Apply)
   → THIS is when every Register function / recorder lambda runs
   → migrated Register functions: complete named functions, ordered only by RegisterKind
        Explicit          ← RegisterFVector / RegisterJson write type + adapter + methods
        Generated         ← UHT surface, still one Register function per generated family
        Reflection        ← RegisterUStructs / RegisterBlueprintTypes write each row complete
        PostReflection    ← only genuine "patch after every Reflection row exists"
        Finalization      ← validate; not a Bind_*.cpp Phase
   → unmigrated FAngelscriptBind lambdas MAY still run in today's seven phases
   → store: Expanding → Sealed (or Failed)

4. Primary FAngelscriptEngine::Initialize → BindScriptTypes
   → Apply sealed TypeBindInfo (`asIScriptEngine::RegisterObjectType` / `RegisterObjectMethod` by `EApplySlot`, not by `EAngelscriptBindPhase`)
   → the Register function is NOT called again
   → ReplayOnly providers still ExecuteRegisteredBinds here

5. Extra engines (isolation tests, StaticJIT generation of the same surface)
   → BindScriptTypes apply only
   → the Register function is NOT called

6. .as hot reload
   → recompile scripts
   → the Register function is NOT called (native bind surface unchanged)

7. Process restart
   → start over from (1)
```

## How many times

| Event | Register function runs? |
|---|---|
| C++ static init | No |
| Generated-module load | No (only more providers register) |
| First expand, EditorDevelopment surface | Yes, all providers, RegisterKind order |
| Second expand, GameShipping / generate surface | Yes again, **only if this process will bind that surface** |
| Each later Engine of an already-expanded surface | No |
| `.as` save / hot reload | No |
| Config that changes the type set | Requires process restart, then expand again |

v1 unmigrated lambdas still run at step 4 via `ExecuteRegisteredBinds`. Step 3 runs only recording-safe / migrated Register functions. After a file migrates, it leaves step 4 (except ReplayOnly).

## What a Register function must see when it runs

- Generated bind modules already loaded.
- Callback collection sealed (no more `AS_FORCE_LINK` providers).
- UE types exist: `StaticStruct()`, native `UClass`, BindDB if cooked.
- **No** requirement that `asIScriptEngine` exists. A Register function must not call `asIScriptEngine::RegisterObjectType` / `RegisterObjectMethod`.
- Primary engine bind **waits** for Sealed. Editor must not tick a half-applied engine.

## `EAngelscriptBindPhase` vs metadata

Migrated files MUST NOT use `EAngelscriptBindPhase`. That enum is an execution schedule for live `asIScriptEngine::RegisterObjectType` / `RegisterObjectMethod`. After migration:

| Datum | Where | Job |
|---|---|---|
| `EApplySlot` | each **member** | Apply `RegisterObjectType` before `RegisterObjectMethod` |
| `EAngelscriptBindRegisterKind` | each **`FAngelscriptBind`** | Explicit vs needs `UClass` vs rare post-row patch |
| `EAngelscriptBindPhase` | unmigrated `FAngelscriptBind` only | compatibility until that file migrates, then delete |

There is no `RegisterKind::TypeDeclarations` or `RegisterKind::TypeInfrastructure`. `TArray.Add` is `ApplySlot=Infrastructure` inside `RegisterTArray`. `EJsonType` is written inside `RegisterJson`. Actor `Spawn` is written on the class row inside `RegisterBlueprintTypes`.
