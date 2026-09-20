---
task_graph:
  version: 1
  depends_on:
    "1.1": []
---

# Join Register modules to ClassGen on Initial compile

## Goal

`CompileModules(Initial)` skips the dead Stage1–4 block after Builder+Register and ClassGen materializes class / struct / enum UserData.

## Architecture

Preprocessor `ModuleDesc` stays the ClassGen input. Only Initial source compile runs one Builder+Register on the host Engine. See [design.md](design.md).

## Global constraints

- Do not skip FullReload or SoftReloadOnly.
- Do not restore `ALWAYS_CREATE`, `Build`, or `BindRegisteredTypesForClassGeneration`.
- Do not rewrite ClassGen or create UObject in the frontend.
- Test identity stays `Angelscript.UnitTest.NativeEngine.Compile.ClassGenMaterialization`.
- Execution conventions: `.agents/skills/harness/references/execution-conventions.md`.

## File map

```diff
 Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.cpp  # · 1.1
 Plugins/Angelscript/Source/AngelscriptTest/NativeEngine/Compile/ClassGenMaterializationTests.cpp  # · 1.1
```

## Requirement coverage

| Requirement | Tasks |
|---|---|
| Initial compile materializes Unreal reflection from preprocessor descriptors | 1.1 |
| Initial compile materializes class, struct, and enum | 1.1 |
| FullReload and SoftReloadOnly do not gain this skip | 1.1 |
| Frontend Resolved pointers stay null | 1.1 |

Self-review 2026-09-18: coverage maps every delta requirement; placeholder scan clean; symbols match glossary `ClassGenMaterialization` and `CompileModules`. Record: attachments/data/planning-validation.md.

## 1. Initial join

## [x] 1.1 Materialize class, struct, and enum through CompileModules Initial

`CompileModules(Initial)` currently errors in Stage1 and never reaches ClassGen. After this task a host-engine Initial compile of one preprocessor module yields UserData for one class, one struct, and one enum.

**Outcome**

Initial source compile runs Builder+Register, attaches same-name `asCModule` shells, skips Stage1–4, and existing ClassGen writes UserData plus reverse pointers. Excluded: reload skip, CacheV2 reuse, delegate / event UserData, restoring the withdrawn bind helper.

**Interfaces**

Consumes (existing, `AngelscriptEngine.h:401` and `AngelscriptEngine.h:623`):

```
enum class ECompileType : uint8 { Initial, SoftReloadOnly, FullReload };
ECompileResult CompileModules(
    ECompileType CompileType,
    const TArray<TSharedRef<FAngelscriptModuleDesc>>& Modules,
    TArray<TSharedRef<FAngelscriptModuleDesc>>& OutCompiledModules,
    ...);
```

Consumes (existing, `AngelscriptEngine.cpp:7543` and `AngelscriptEngine.cpp:6351`):

```
Legacy module compilation is unavailable; use frozen Builder inputs.
Module->bCompileError = true;  // unconditional globals loop when ScriptModule != nullptr
```

Consumes (existing, `as_engine_compile_registration.h` and `NativeSourceExecutionTestSupport.h:147`):

```
asERegistrationResult Register(TArray<TUniquePtr<asCDefinitions>> Sets, const asCCompileOutput& Output);
RegisterCompiledDefinitions(Engine, Builder)
```

Consumes (existing host test pattern, `PostBindBasicTypesTests.cpp:199` and `AngelscriptEngine.h` `FAngelscriptEngineScope`):

```
FAngelscriptEngine::Create(Config, FAngelscriptEngineDependencies::CreateDefault())
FAngelscriptEngineScope
FAngelscriptEngine::GetPackage()
```

Produces (glossary `attachments/drafts/glossary.md`):

```
TEST_CLASS ClassGenMaterialization
Angelscript.UnitTest.NativeEngine.Compile.ClassGenMaterialization
Plugins/Angelscript/Source/AngelscriptTest/NativeEngine/Compile/ClassGenMaterializationTests.cpp
```

**Cases**

1. **InitialMaterializesClassStructEnum** — new RED
   Given a scoped host `FAngelscriptEngine` that owns a script package and one `FAngelscriptModuleDesc` named `ClassGen.Join` whose `Code` is `class ClassGenJoinActor {}` plus `struct ClassGenJoinItem { int Value; }` plus `enum ClassGenJoinColor { Red, Blue }`, with the actor `ClassDesc.CodeSuperClass = UObject::StaticClass()` and `bSuperIsCodeClass = true`, and the struct `bIsStruct = true` When `CompileModules(ECompileType::Initial, InModules, Out)` Then `bCompileError` is false, `ScriptModule` is non-null, actor/struct/enum `GetUserData()` are `UASClass*` / `UASStruct*` / `UEnum*`, `UASClass.ScriptTypePtr` and `UASStruct.ScriptType` equal those asTypes, and `EnumDesc.Enum` is non-null.
2. **ReloadKeepsLegacyStageError** — boundary
   Given the same module construction When `CompileModules(ECompileType::FullReload, InModules, Out)` Then the compile still reports the Legacy Stage1 error and does not attach UserData in this Change.
3. **ResolvedPointersStayNull** — existing control
   Given NativeEngine ReflectionDescriptors When `CompileDeclarations` finishes Then `CodeSuperClass`, `Class`, `Struct`, and `ScriptType` stay null. Oracle: existing `ResolvedDescriptorsRetainSemanticKeysAndNullMaterializationPointers`.

**Files**

```diff
 Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.cpp
+Plugins/Angelscript/Source/AngelscriptTest/NativeEngine/Compile/ClassGenMaterializationTests.cpp
```

No ClassGen algorithm files. No `AngelscriptEngine.h` unless a private helper must be declared.

**Verification**

Import Harness in the current PowerShell 7 session. After a successful `ue.build` of `AngelscriptProjectEditor` (Win64, Development), run from the workspace root.

```powershell
Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.Compile.ClassGenMaterialization'; Fast = $true; TimeoutMs = 600000 }
```

Observe the Initial UserData case red before the skip lands, then green on the same prefix. `ReloadKeepsLegacyStageError` stays on the Legacy Stage1 message. Shared ReflectionDescriptors control may run on its own prefix and is recorded as omitted-from-this-command existing control. Omitted: Full NativeEngine.Compile, editor `.as` suite, CacheV2.

**Notes**

Write the ClassGenMaterialization tests first and keep the proving prefix red until the Initial skip is in `CompileModules`. Use `FAngelscriptEngine::Create`, not `CreateForBindings` and not `asCreateScriptEngine()`, so `GetPackage()` and ClassGen see the same host Engine.

**Evidence**

- RED `ue.test` TestPrefix `Angelscript.UnitTest.NativeEngine.Compile.ClassGenMaterialization` Fast run `cacd9f1c2aa744a8aeaa35d8da0865a5` Outcome Failed; 2/2. Stage1 still dead, no `ScriptModule` / UserData.
- Shutdown UAF after ClassGen completed: run `7cf7a8b60dd74ae8aeaf5e1ba82dd550` (`InternalReset` `DestroyInternal` on a retired definition type) and run `b3f203c7b7694b6aa26c9c588ee63fdb` (skip-`DestroyInternal` still AV `0x0`). Root cause in `issue-20260918-104000-register-shell-shutdown-uaf`.
- `ue.build` AngelscriptProjectEditor run `20af04076b8b446991e8443f18087de8` Succeeded after unlink-before-retire.
- GREEN `ue.test` TestPrefix `Angelscript.UnitTest.NativeEngine.Compile.ClassGenMaterialization` Fast run `c2495efd85ad4112a36d9d244c754893` Outcome Passed; report `Saved/Harness/Unreal/Runs/c2495efd85ad4112a36d9d244c754893/AutomationReport/index.json`; 2/2 discovered and executed, 0 failed. Cases: `InitialMaterializesClassStructEnum` Success; `ReloadKeepsLegacyStageError` Success. Omitted: full NativeEngine.Compile, editor `.as` suite, CacheV2, and ReflectionDescriptors `ResolvedDescriptorsRetainSemanticKeysAndNullMaterializationPointers` (existing control, own prefix).
- Naming assumed: `ClassGenMaterialization` — glossary test class. `CompileInitialModulesThroughBuilder` — cpp-local Initial Builder+Register helper. `DetachDefinitionOwnedTypes` — unlink definition-owned shell types before `RetireExternalDefinitions` deletes them.
