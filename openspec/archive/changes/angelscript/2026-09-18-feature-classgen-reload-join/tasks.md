---
task_graph:
  version: 1
  depends_on:
    "1.1": []
    "1.2": ["1.1"]
---

# Join hot reload to ClassGen through per-file definition sets

## Goal

Register one `asCDefinitions` per `.as`, then let `CompileModules` FullReload and SoftReloadOnly retire those sets, Builder+Register, skip Stage1–4, and update ClassGen UserData.

## Architecture

Preprocessor `ModuleDesc` stays the ClassGen input. Initial ownership splits to one compile set per file so reload can retire that file without `RetireExternalDefinitions`. See [design.md](design.md).

## Global constraints

- Do not restore `ALWAYS_CREATE`, `Build`, or `BindRegisteredTypesForClassGeneration`.
- Do not rewrite ClassGen, create UObject in the frontend, or retire the host graph.
- Do not implement CacheV2 reuse or replace-by-key inside one set.
- Test identity stays `Angelscript.UnitTest.NativeEngine.Compile.ClassGenReload`.
- Execution conventions: `.agents/skills/harness/references/execution-conventions.md`.

## File map

```diff
 Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.cpp  # · 1.1 1.2
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_scriptengine.h  # · 1.2
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_scriptengine_registration.cpp  # · 1.2
 Plugins/Angelscript/Source/AngelscriptRuntime/ClassGenerator/AngelscriptClassGenerator_Reinstancing.cpp  # · 1.2
 Plugins/Angelscript/Source/AngelscriptTest/NativeEngine/Compile/ClassGenMaterializationTests.cpp  # · 1.2
+Plugins/Angelscript/Source/AngelscriptTest/NativeEngine/Compile/ClassGenReloadTests.cpp  # · 1.1 1.2
```

## Requirement coverage

| Requirement | Tasks |
|---|---|
| Initial compile materializes Unreal reflection from preprocessor descriptors | 1.1 |
| Initial compile materializes class, struct, and enum | 1.1 |
| Types from different preprocessor modules belong to different `asCDefinitions` | 1.1 |
| Frontend Resolved pointers stay null | 1.1 |
| Hot reload rematerializes Unreal reflection from preprocessor descriptors | 1.2 |
| FullReload updates class, struct, and enum UserData | 1.2 |
| SoftReloadOnly updates UserData without the dead Stage path | 1.2 |
| Failed reload keeps the last generation | 1.2 |

Self-review 2026-09-18: coverage maps every delta requirement; placeholder scan clean; symbols match glossary `ClassGenReload` and `CompileModules`. Record: attachments/data/planning-validation.md.

## 1. Per-file sets then reload

## [x] 1.1 Register one definition set per preprocessor module

`CompileInitialModulesThroughBuilder` currently feeds every new file to one `asCBuilder` and one `Register`. After this task each preprocessor `ModuleDesc` is its own Builder+Register, and types from two files live in different `asCDefinitions`. ClassGen Initial materialization for a single file stays.

**Outcome**

Initial source compile Registers one compile set per `ModuleDesc`, with Dependencies = host graph plus already attached script sets. Single-file class/struct/enum UserData still materializes. Excluded: Full/Soft skip, selected-set retire, CacheV2 reuse, restoring the withdrawn bind helper.

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

Consumes (existing, `AngelscriptEngine.cpp:289` and `AngelscriptEngine.cpp:381`):

```
bool CompileInitialModulesThroughBuilder(...);
Units.Add(Builder.TakeDefinitions());
Registration.Register(MoveTemp(Units), *Output);
```

Consumes (existing, `as_builder.h:46` and `as_engine_compile_registration.h:14`):

```
TUniquePtr<asCDefinitions> TakeDefinitions();
asERegistrationResult Register(TArray<TUniquePtr<asCDefinitions>> Sets, const asCCompileOutput& Output);
```

Consumes (existing, `as_typeinfo.h:163`):

```
asCDefinitions* GetDefinitions() const;
```

Produces (glossary `attachments/drafts/glossary.md`):

```
TEST_CLASS ClassGenReload
Angelscript.UnitTest.NativeEngine.Compile.ClassGenReload
Plugins/Angelscript/Source/AngelscriptTest/NativeEngine/Compile/ClassGenReloadTests.cpp
```

**Cases**

1. **InitialRegistersPerFileDefinitionSets** — new RED
   Given a scoped host `FAngelscriptEngine` with a script package and two preprocessor modules `ClassGen.Reload.Alpha` (`class ClassGenReloadAlpha {}`, `CodeSuperClass = UObject::StaticClass()`, `bSuperIsCodeClass = true`) and `ClassGen.Reload.Beta` (`class ClassGenReloadBeta {}`, same super) When `CompileModules(ECompileType::Initial, InModules, Out)` Then both modules have `bCompileError` false and non-null `ScriptModule`, both class `GetUserData()` are `UASClass*`, and `static_cast<asCTypeInfo*>(AlphaType)->GetDefinitions()` is non-null and a different pointer from Beta's `GetDefinitions()`.
2. **InitialMaterializesClassStructEnum** — existing control
   Given NativeEngine Compile `ClassGenMaterialization.InitialMaterializesClassStructEnum` When Initial compile still runs one file Then class/struct/enum UserData still materializes. Oracle: that existing method. Omitted from this card's proving prefix.

**Files**

```diff
 Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.cpp
+Plugins/Angelscript/Source/AngelscriptTest/NativeEngine/Compile/ClassGenReloadTests.cpp
```

No engine retire API and no ClassGen algorithm files. No `AngelscriptEngine.h` unless a private helper must be declared.

**Verification**

Import Harness in the current PowerShell 7 session. After a successful `ue.build` of `AngelscriptProjectEditor` (Win64, Development), run from the workspace root.

```powershell
Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.Compile.ClassGenReload'; Fast = $true; TimeoutMs = 600000 }
```

Observe `InitialRegistersPerFileDefinitionSets` red while one Builder still takes every file, then green on the same prefix. Omitted: `ClassGenMaterialization` (existing control, own prefix), Full NativeEngine.Compile, editor `.as` suite, CacheV2.

**Notes**

Write the ClassGenReload per-file case first and keep that prefix red until the Initial helper loops one Builder+Register per `ModuleDesc`. Later modules pass already attached script sets in `Options.Dependencies`. Use `FAngelscriptEngine::Create`, not `CreateForBindings` and not `asCreateScriptEngine()`.

**Evidence**

- RED `ue.test` TestPrefix `Angelscript.UnitTest.NativeEngine.Compile.ClassGenReload` Fast run `3aed7b9d56624d7b9282cd7be6c6dfd4` Outcome Failed; 1/1. `InitialRegistersPerFileDefinitionSets` failed on `Each preprocessor module must own its asCDefinitions` while one Builder still took both files.
- `ue.build` AngelscriptProjectEditor run `87c38ea6d0bb4100aa3638f3dd98661b` Succeeded after per-file Builder+Register.
- GREEN `ue.test` TestPrefix `Angelscript.UnitTest.NativeEngine.Compile.ClassGenReload` Fast run `68cacdb9d5fb41b7b1f4d017e460fe28` Outcome Passed; report `Saved/Harness/Unreal/Runs/68cacdb9d5fb41b7b1f4d017e460fe28/AutomationReport/index.json`; 1/1 discovered and executed, 0 failed. Case: `InitialRegistersPerFileDefinitionSets` Success. Omitted: `ClassGenMaterialization` (existing control, own prefix), full NativeEngine.Compile, editor `.as` suite, CacheV2.
- Naming assumed: `CompileOneModuleThroughBuilder` — cpp-local one-module Builder+Register. `ScriptSetFromHost` — collect the registered compile set after attach.

## [x] 1.2 Skip dead stages on FullReload and SoftReloadOnly

`CompileModules` still enters Stage1–4 unless `CompileType == Initial`. After this task FullReload and SoftReloadOnly retire the previous compile sets, Builder+Register, skip that block, and ClassGen updates UserData. A failed compile keeps the last generation.

**Outcome**

Reload compile types use the same per-file Builder+Register as Initial, after retiring only those compile definitionSets and dependents. `ClassGenMaterialization.ReloadKeepsLegacyStageError` no longer requires the Stage1 death error. Excluded: CacheV2 reuse, full-engine `RetireExternalDefinitions`, ClassGen algorithm rewrite, replace-by-key.

**Interfaces**

Consumes (existing, `AngelscriptEngine.cpp:5931` and `AngelscriptEngine.cpp:5969`):

```
if (CompileType == ECompileType::Initial) { ... bCompiledThroughBuilder = true; }
if (!bCompiledThroughBuilder) { /* Stage1–4 */ }
```

Consumes (existing, `as_scriptengine.h:338` and `as_scriptengine_registration.cpp:389`):

```
void RetireExternalDefinitions();
```

Consumes (existing, `as_typeinfo.h:163` and `AngelscriptEngine.cpp:5608`):

```
asCDefinitions* GetDefinitions() const;
void SwapInModules(...);  // renames last-good shell only after success
```

Produces (convention beside `RetireExternalDefinitions`, `as_scriptengine.h`):

```
void RetireDefinitionSets(TConstArrayView<asCDefinitions*> Sets);
```

Produces (glossary `attachments/drafts/glossary.md`, same test class as 1.1):

```
TEST_METHOD FullReloadUpdatesClassStructEnum
TEST_METHOD SoftReloadOnlyUpdatesUserData
TEST_METHOD FailedReloadKeepsLastGeneration
```

**Cases**

1. **FullReloadUpdatesClassStructEnum** — new RED
   Given Setup When `CompileModules(ECompileType::FullReload, Replacement, Out)` with `struct ClassGenReloadItem { int Value; int Extra; }` replacing `int Value` Then the replacement module has `bCompileError` false, non-null `ScriptModule`, actor/struct/enum `GetUserData()` are `UASClass*` / `UASStruct*` / `UEnum*`, reverse pointers match those asTypes, and `EnumDesc.Enum` is non-null.
2. **SoftReloadOnlyUpdatesUserData** — new RED
   Given Setup When `CompileModules(ECompileType::SoftReloadOnly, Replacement, Out)` with the same type shapes and `int GetValue() { return 2; }` replacing `return 1` Then `bCompileError` is false, `ScriptModule` is non-null, the actor `GetUserData()` is `UASClass*`, and the compile does not emit `Legacy module compilation is unavailable; use frozen Builder inputs.`
3. **FailedReloadKeepsLastGeneration** — new RED
   Given Setup When `CompileModules(ECompileType::FullReload, Broken, Out)` with source `class ClassGenReloadActor {` Then the broken module has `bCompileError` true, `asIScriptEngine::GetModule` for `ClassGen.Reload` still finds the Initial shell, and that actor `GetUserData()` is still `UASClass*`.
4. **ReloadKeepsLegacyStageError** — existing control
   Given `ClassGenMaterialization.ReloadKeepsLegacyStageError` When this task replaces that Stage1-death oracle Then that method must not still require the Legacy Stage1 error. Replaces: the 1.1-era Materialization reload boundary.

Setup: a scoped host `FAngelscriptEngine` with a script package; `CompileModules(Initial)` of one module `ClassGen.Reload` whose code is `class ClassGenReloadActor { int GetValue() { return 1; } }` plus `struct ClassGenReloadItem { int Value; }` plus `enum ClassGenReloadColor { Red, Blue }`, actor `CodeSuperClass = UObject::StaticClass()` and `bSuperIsCodeClass = true`, struct `bIsStruct = true`. Replacement modules reuse that name and those descriptors.

**Files**

```diff
 Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_scriptengine.h
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_scriptengine_registration.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/ClassGenerator/AngelscriptClassGenerator_Reinstancing.cpp
 Plugins/Angelscript/Source/AngelscriptTest/NativeEngine/Compile/ClassGenMaterializationTests.cpp
 Plugins/Angelscript/Source/AngelscriptTest/NativeEngine/Compile/ClassGenReloadTests.cpp
```

No ClassGen algorithm rewrite. The Reinstancing edit only skips the no-arg `beh.construct` ensure when the new frontend has not published that id. No `ALWAYS_CREATE` / `Build`. Do not call `RetireExternalDefinitions` from the reload path.

**Verification**

Import Harness in the current PowerShell 7 session. After a successful `ue.build` of `AngelscriptProjectEditor` (Win64, Development), run from the workspace root.

```powershell
Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.Compile.ClassGen'; Fast = $true; TimeoutMs = 600000 }
```

Observe the three `ClassGenReload` reload cases red before the skip/retire lands, then green on this prefix. The same prefix must execute `ClassGenMaterialization` without requiring the Stage1 death error. Omitted: full NativeEngine.Compile, editor `.as` suite, CacheV2.

**Notes**

Retire only compile sets taken from the previous generation's `GetDefinitions()`. Keep host Dependencies. Do not rename the last-good shell until `SwapInModules` succeeds.

**Evidence**

- RED `ue.test` TestPrefix `Angelscript.UnitTest.NativeEngine.Compile.ClassGen` Fast run `2ee44a886337468d8aef40c2e7d766bb` Outcome Failed; 5 discovered, 2 succeeded (`InitialMaterializesClassStructEnum`, `InitialRegistersPerFileDefinitionSets`), 3 failed on Legacy Stage1.
- `ue.build` AngelscriptProjectEditor run `00186a17f15d4aaf8dcbfdc90aa15efa` Succeeded after Unpublish/Register skip, last-good name restore, and the no-arg construct ensure guard.
- GREEN `ue.test` TestPrefix `Angelscript.UnitTest.NativeEngine.Compile.ClassGen` Fast run `78006b5aa4964f6d8c8d32bf4ed55e55` Outcome Passed; report `Saved/Harness/Unreal/Runs/78006b5aa4964f6d8c8d32bf4ed55e55/AutomationReport/index.json`; 5/5 discovered and executed, 0 failed. Cases: `InitialMaterializesClassStructEnum` Success; `InitialRegistersPerFileDefinitionSets` Success; `FullReloadUpdatesClassStructEnum` Success; `SoftReloadOnlyUpdatesUserData` Success; `FailedReloadKeepsLastGeneration` Success. Omitted: full NativeEngine.Compile, editor `.as` suite, CacheV2.
- Naming assumed: `UnpublishDefinitionSets` — hide one compile set from the engine index without destroying the host graph. `RetireDefinitionSets` — convention beside `RetireExternalDefinitions`. `FillScriptConstructBehavior` — best-effort no-arg ctor bind after attach. `ClassGenReloadFull/Soft/Keep*` — per-case type names so leftover UObjects in `/Script/Angelscript` do not collide.
