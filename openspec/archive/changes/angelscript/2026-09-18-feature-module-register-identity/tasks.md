---
task_graph:
  version: 1
  depends_on:
    "1.1": []
    "2.1": ["1.1"]
---

# Register per-file asCModule identity

## Goal

After Builder compile, Register creates one `asCModule` per `.as` and restores lookup-only `GetModule`.

## Architecture

Compile stays on `asCDefinitions`. A new `Register(Sets, Output)` overload builds shells from CompileOutput after TypeId install. See [design.md](design.md).

## Global constraints

- Do not restore `AddScriptSection`, `Build`, `ALWAYS_CREATE`, or `GetModule(name, asEGMFlags)`.
- Do not expose `Type.GetModule()`.
- Do not change host `FAngelscriptEngine::GetModule` away from `ModuleDesc`.
- Do not implement ClassGen UserData or UClass materialization.
- Execution conventions: `.agents/skills/harness/references/execution-conventions.md`.

## File map

```diff
 Plugins/Angelscript/Source/AngelscriptRuntime/
   Core/angelscript.h                      # 1.1
   angelscript/as_scriptengine.h           # 1.1
   angelscript/as_scriptengine.cpp         # 1.1
   angelscript/as_engine_compile_registration.h   # 2.1
   angelscript/as_engine_compile_registration.cpp # 2.1
 Plugins/Angelscript/Source/AngelscriptTest/NativeEngine/
   Compile/SDKTests.cpp                    # 1.1
   Compile/CompileLifecycleTests.cpp       # 2.1
   Registration/EngineRegistrationTests.cpp # 1.1
   SourceExecution/NativeSourceExecutionTestSupport.h # 2.1
```

## Requirement coverage

| Requirement | Tasks |
|---|---|
| Register attaches per-file asCModule identity | 2.1 |
| Two source files become two modules | 2.1 |
| Register(Sets) without CompileOutput invents no shells | 2.1 |
| Empty Engine has no modules | 1.1 |
| Engine module lookup is name-only | 1.1 |
| Missing name does not create a module | 1.1 |
| Compile factory stays absent | 1.1 |
| CompileOutput ScriptModule stays null until Register | 2.1 |

Self-review 2026-09-17: coverage maps every delta requirement; placeholder scan clean; symbols match glossary `GetModule(const char* name) const`. Record: attachments/data/planning-validation.md.

## 1. Lookup

## [x] 1.1 Restore lookup GetModule without the compile factory

`asIScriptEngine` currently has an empty Script modules section. After this task the three lookup methods exist, empty-engine lookup returns null, and compile-factory / `Type.GetModule()` stay absent.

**Outcome**

`GetModule(name)`, `GetModuleCount`, and `GetModuleByIndex` look up `scriptModulesByName` / `scriptModules`. Missing or null name returns nullptr. Out-of-range index returns nullptr. Count on a new Engine is 0. Excluded: creating modules, `ALWAYS_CREATE`, `DiscardModule`, `GetModuleFromFuncId`, `Type.GetModule()`.

**Interfaces**

Consumes (existing, `as_scriptengine.h:609`):

```
asCArray<asCModule*> scriptModules;
asCMapByName<asCModule*> scriptModulesByName;
```

Consumes (existing compile-factory lock, `SDKTests.cpp:11`):

```
HasModules / HasCompile / HasModulePointer
TEST_METHOD(ModuleManagementAndMutableProvenanceAreAbsent)
```

Produces (glossary `attachments/drafts/glossary.md`):

```
virtual asIScriptModule* GetModule(const char* name) const = 0;
virtual asUINT GetModuleCount() const = 0;
virtual asIScriptModule* GetModuleByIndex(asUINT index) const = 0;
```

Produces (existing NativeEngine.Compile.SDK convention):

```
HasLookup / HasFactory
TEST_METHOD(LookupGetModuleReturnsNullWhenMissing)
```

**Cases**

1. **LookupSymbolsExist** — new RED
   Given the maintained `asIScriptEngine` / `asCScriptEngine` When a `requires` check calls `GetModule("Old")`, `GetModuleCount()`, and `GetModuleByIndex(0)` Then `HasLookup` is true.
2. **FactoryAndTypeGetModuleStayAbsent** — existing control
   Given the same headers When a `requires` check calls `DiscardModule`, `GetModuleFromFuncId`, `AddScriptSection`, `Build`, or `Type.GetModule()` Then `HasFactory`, `HasCompile`, and `HasModulePointer` stay false.
3. **EmptyEngineLookupIsNull** — new RED
   Given `asCreateScriptEngine()` with no Register When `GetModule("Missing.as")`, `GetModule(nullptr)`, `GetModuleCount()`, and `GetModuleByIndex(0)` Then both pointers are null and count is 0.
4. **RegistrationSurfaceAllowsLookup** — new RED
   Given `EngineRegistrationTests` When the engine object is checked with `requires { Value.GetModule("Dormant"); }` Then the expression is valid (the 09-08 absence assert is gone). Runtime still returns nullptr because no shell exists yet.

**Files**

```diff
 Plugins/Angelscript/Source/AngelscriptRuntime/Core/angelscript.h
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_scriptengine.h
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_scriptengine.cpp
 Plugins/Angelscript/Source/AngelscriptTest/NativeEngine/Compile/SDKTests.cpp
 Plugins/Angelscript/Source/AngelscriptTest/NativeEngine/Registration/EngineRegistrationTests.cpp
```

No ClassGen or host `FAngelscriptEngine` files.

**Verification**

Import Harness in the current PowerShell 7 session. After a successful `ue.build` of `AngelscriptProjectEditor` (Win64, Development), run from the workspace root.

```powershell
Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.Compile.SDK'; Fast = $true; TimeoutMs = 600000 }
```

All four cases execute: lookup `requires` is true; factory / `Type.GetModule()` `requires` stay false; empty-engine lookup returns null. `EngineRegistrationTests` must compile with the flipped `GetModule` assert in the same build. Omitted: full `NativeEngine.Compile` prefix and ClassGen; this card only restores lookup.

**Notes**

Implement lookup against the existing tables only. Do not construct `asCModule` here.

**Evidence**

- Pre-change lock: `SDKTests.cpp` `static_assert(!HasModules)` and `ModuleManagementAndMutableProvenanceAreAbsent` required lookup symbols to be absent. Those symbols were missing on `asIScriptEngine` before this card.
- `ue.build` AngelscriptProjectEditor run `a0a26d432cd046098969a670a5af5a8f` Succeeded (Exit 0). Same binary compiled the flipped `EngineRegistrationTests` `GetModule("Dormant")` require.
- GREEN `ue.test` TestPrefix `Angelscript.UnitTest.NativeEngine.Compile.SDK` Fast run `497d60be63c64b3e9bdf59e63c7801b7` Outcome Passed; report `Saved/Harness/Unreal/Runs/497d60be63c64b3e9bdf59e63c7801b7/AutomationReport/index.json`; 8/8 discovered and executed, 0 failed. Cases: `LookupGetModuleReturnsNullWhenMissing` Success; `ModuleManagementAndMutableProvenanceAreAbsent` Success (HasLookup true, HasFactory / Type.GetModule false); `PublicModuleCompilationAndImportsAreAbsent` Success. Omitted: full NativeEngine.Compile and ClassGen.

## 2. Register shells

## [x] 2.1 Create one asCModule per CompileOutput module at Register

`Register(Sets)` still only binds Engine and TypeId. After this task `Register(Sets, Output)` builds one shell per ModuleDesc, and the Builder helper forwards CompileOutput.

**Outcome**

Two-file compile plus `Register(Sets, Output)` yields two named modules whose `Type.module` and `ScriptModule` match `GetModule(fileKey)`. `Register(Sets)` without Output still creates no shells. CompileOutput `ScriptModule` stays null until that Register. Excluded: ClassGen UserData, restoring `Build`, exposing `Type.GetModule()`.

**Interfaces**

Consumes (existing, `as_engine_compile_registration.h:12`):

```
asERegistrationResult Register(TArray<TUniquePtr<asCDefinitions>> Sets);
```

Consumes (existing, `as_module.cpp:169`, `AngelscriptDescriptors.h:339`):

```
asCModule(const char* name, asCScriptEngine* engine);
FString ModuleName; asCModule* ScriptModule;
FAngelscriptResolvedSourceAnchor.LogicalSourceKey
asCTypeInfo::module
```

Consumes (existing, `as_builder.h:47`):

```
const asCCompileOutput* GetCompileOutput() const;
```

Produces (existing Register overload convention; design `Register(Sets, Output)`):

```
asERegistrationResult Register(
    TArray<TUniquePtr<asCDefinitions>> Sets,
    const asCCompileOutput& Output);
```

Produces (existing CompileLifecycle / helper convention):

```
TEST_METHOD(RegisterCreatesPerFileModules)
RegisterCompiledDefinitions(Engine, Builder) forwards GetCompileOutput()
```

**Cases**

Setup: compile with snapshot `asCBuilder` through default `RunThrough`, then Register on a fresh `asCreateScriptEngine()`.

1. **TwoFilesBecomeTwoModules** — new RED
   Given `First.as` = `class First {}` and `Second.as` = `class Second {}` When `Register(Sets, Output)` succeeds Then `GetModule("First.as")` and `GetModule("Second.as")` are distinct and non-null, `GetModuleCount() >= 2`, `First->module` equals `GetModule("First.as")`, and the First ModuleDesc `ScriptModule` is that same pointer.
2. **SetsOnlyCreatesNoShell** — existing control
   Given the current `RegisterInstallsEngineAndTypeId` input `class Unit { int Value; int Get() { return Value; } }` on `Main.as` When `Register(Sets)` is called without CompileOutput Then `Unit->GetEngine()` is set and `GetModule("Main.as")` is still nullptr.
3. **CompileOutputNullUntilRegister** — existing control
   Given a successful compile of `class Widget {}` When the caller reads CompileOutput before Register Then `ScriptType`, `ScriptFunction`, and `ScriptModule` are null.
4. **MissingNameAfterRegister** — boundary
   Given the two-file Register from case 1 When `GetModule("Other.as")` Then the result is nullptr and the two existing modules remain.
5. **BuilderHelperForwardsOutput** — new RED
   Given the same two-file Builder When `RegisterCompiledDefinitions(Engine, Builder)` runs Then `GetModule("First.as")` is non-null. Host `RegisterCompiledDefinitions(Engine, Set)` without a Builder still creates no shell.

**Files**

```diff
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_engine_compile_registration.h
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_engine_compile_registration.cpp
 Plugins/Angelscript/Source/AngelscriptTest/NativeEngine/Compile/CompileLifecycleTests.cpp
 Plugins/Angelscript/Source/AngelscriptTest/NativeEngine/SourceExecution/NativeSourceExecutionTestSupport.h
```

Do not edit ClassGen. Lookup headers stay in 1.1.

**Verification**

Import Harness in the current PowerShell 7 session. After a successful `ue.build` of `AngelscriptProjectEditor` (Win64, Development), run from the workspace root.

```powershell
Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.Compile.CompileLifecycle'; Fast = $true; TimeoutMs = 600000 }
```

Cases 1–5 execute on that prefix. `RegisterInstallsEngineAndTypeId` remains green. Omitted: ClassGen materialization and the full NativeEngine suite; this card only proves shells and the helper forward.

**Notes**

Match types to ModuleDesc by `LogicalSourceKey` / `StableDeclarationKey`, then `AddClassType` / `AddEnumType` / `AddCallableType`. Push the new shell onto `scriptModules` and `scriptModulesByName`. Do not forge a shell when Output has no modules.

**Evidence**

- RED `ue.test` TestPrefix `Angelscript.UnitTest.NativeEngine.Compile.CompileLifecycle` Fast run `a73e334028154fa685000dad5be76e7a` Outcome Failed; 27/29. `RegisterCreatesPerFileModules` Fail (GetModule("First.as") null at line 370); `RegisterCompiledDefinitionsForwardsOutput` Fail (GetModule("First.as") null at line 392). Stub `Register(Sets, Output)` ignored CompileOutput.
- `ue.build` AngelscriptProjectEditor run `bdd592865db6417a84dbf3626aef08f7` Succeeded (Exit 0) after TypeId install plus per-ModuleDesc `asCModule` attach.
- GREEN `ue.test` TestPrefix `Angelscript.UnitTest.NativeEngine.Compile.CompileLifecycle` Fast run `bba9c525f8f44c7d9274d3df7e981d26` Outcome Passed; report `Saved/Harness/Unreal/Runs/bba9c525f8f44c7d9274d3df7e981d26/AutomationReport/index.json`; 29/29 discovered and executed, 0 failed. Cases: `RegisterCreatesPerFileModules` Success; `RegisterCompiledDefinitionsForwardsOutput` Success; `RegisterInstallsEngineAndTypeId` Success (GetModule("Main.as") still null without Output); `CompileOutputLeavesScriptTypeNull` Success. Omitted: ClassGen materialization and the full NativeEngine suite.
