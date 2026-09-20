---
task_graph:
  version: 1
  depends_on:
    "1.1": []
---

# Join UFUNCTION ProcessEvent after ClassGen

## Goal

After `CompileModules(Initial)` and existing ClassGen, a hand-filled BlueprintCallable method is a live `UASFunction` whose ProcessEvent returns 7.

## Architecture

Host `ModuleDesc.Methods` stay the ClassGen input. The fixture hand-fills one method the same way `ClassGenMaterialization` hand-fills SuperClass. See [design.md](design.md).

## Global constraints

- Do not copy Builder CompileOutput Methods onto the host ClassDesc.
- Do not run the real preprocessor in this fixture.
- Do not rewrite ClassGen or create UObject in the frontend.
- Do not restore `ALWAYS_CREATE`, `Build`, or CacheV2 reuse.
- Test identity stays `Angelscript.UnitTest.NativeEngine.Compile.ClassGenCall`.
- Execution conventions: `.agents/skills/harness/references/execution-conventions.md`.

## File map

```diff
 Plugins/Angelscript/Source/AngelscriptTest/NativeEngine/Compile/ClassGenCallTests.cpp  # · 1.1
 Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.cpp  # · 1.1
 Plugins/Angelscript/Source/AngelscriptRuntime/ClassGenerator/AngelscriptClassGenerator_Analyze.cpp  # · 1.1
```

Engine and Analyze appear only if RED shows the method unbound or ProcessEvent fails.

## Requirement coverage

| Requirement / acceptance condition | Tasks |
|---|---|
| Initial compile materializes a callable UFUNCTION | 1.1 |
| Initial ProcessEvent returns a UFUNCTION result | 1.1 |
| No construct, reload, Language corpus, or Builder Method copy | 1.1 |

Self-review 2026-09-18: coverage maps every delta requirement; placeholder scan clean; symbols match glossary `ClassGenCall` and `InitialProcessEventReturnsValue`. Record: attachments/data/planning-validation.md.

## 1. Initial call

## [x] 1.1 ProcessEvent a hand-filled UFUNCTION after Initial ClassGen

`ClassGenMaterialization` compiles an empty actor and never fills `Methods`. After this task a scoped host Initial compile of `ClassGenCallActor` with one hand-filled `GetValue` yields a `UASFunction` whose ProcessEvent returns 7.

**Outcome**

Initial source compile still Builder+Registers and runs existing ClassGen. Analyze binds `FunctionDesc.ScriptFunction` from the hand-filled `ScriptFunctionName`. Generation creates `UASFunction`. `NewObject` then ProcessEvent returns 7. Excluded: real preprocessor, copying Builder Methods, script construct, method-body reload, Language corpus execute.

**Interfaces**

Consumes (existing, `AngelscriptEngine.h:623` and `ClassGenMaterializationTests.cpp:52`):

```
ECompileResult CompileModules(
    ECompileType CompileType,
    const TArray<TSharedRef<FAngelscriptModuleDesc>>& Modules,
    TArray<TSharedRef<FAngelscriptModuleDesc>>& OutCompiledModules,
    ...);
FAngelscriptEngine::Create(Config, FAngelscriptEngineDependencies::CreateDefault())
FAngelscriptEngineScope
FAngelscriptEngine::GetPackageInstance()
```

Consumes (existing, `AngelscriptDescriptors.h:141` and `AngelscriptDescriptors.h:219`):

```
struct FAngelscriptFunctionDesc
{
    FString FunctionName;
    FString ScriptFunctionName;
    bool bBlueprintCallable;
    asIScriptFunction* ScriptFunction;
    UFunction* Function;
};
TArray<TSharedRef<FAngelscriptFunctionDesc>> Methods;
```

Consumes (existing, `AngelscriptClassGenerator_Analyze.cpp:564` and `ASFunction.h:15`):

```
for (auto FunctionDesc : ClassData.NewClass->Methods)
    FunctionMap.Find(FunctionDesc->ScriptFunctionName);
class asIScriptFunction* ScriptFunction;
```

Consumes (existing, `AngelscriptTestEngineHelper.cpp:629`):

```
Object->ProcessEvent(Function, &OutResult);
```

Produces (glossary `attachments/drafts/glossary.md`):

```
TEST_CLASS ClassGenCall
TEST_METHOD InitialProcessEventReturnsValue
Angelscript.UnitTest.NativeEngine.Compile.ClassGenCall
ClassGenCallActor
Plugins/Angelscript/Source/AngelscriptTest/NativeEngine/Compile/ClassGenCallTests.cpp
```

**Cases**

1. **InitialProcessEventReturnsValue** — new RED
   Given a scoped host `FAngelscriptEngine` that owns a script package and one `FAngelscriptModuleDesc` named `ClassGen.Call` whose `Code` is `class ClassGenCallActor { UFUNCTION() int GetValue() { return 7; } }`, with `ClassDesc.ClassName = ClassGenCallActor`, `SuperClass = UObject`, `bSuperIsCodeClass = true`, `CodeSuperClass = UObject::StaticClass()`, and one `Methods` row `FunctionName = GetValue`, `ScriptFunctionName = GetValue`, `bBlueprintCallable = true` When `CompileModules(ECompileType::Initial, InModules, Out)` then `NewObject` of that `UASClass` and `ProcessEvent` on `GetValue` Then `bCompileError` is false, `ScriptModule` is non-null, `UASFunction::ScriptFunction` is non-null, and ProcessEvent writes return dword 7.

2. **InitialStillMaterializesActor** — existing control
   Given the same compile When ClassGen finishes Then actor `GetUserData()` is `UASClass*` and `UASClass.ScriptTypePtr` equals the asType. Oracle: same observations as `ClassGenMaterialization.InitialMaterializesClassStructEnum` on this actor only.

**Files**

```diff
+Plugins/Angelscript/Source/AngelscriptTest/NativeEngine/Compile/ClassGenCallTests.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/ClassGenerator/AngelscriptClassGenerator_Analyze.cpp
```

Do not edit ClassGen Generation or ASFunction dispatch unless RED proves they reject this signature. Do not add a preprocessor fixture.

**Verification**

Import Harness in the current PowerShell 7 session. After a successful `ue.build` of `AngelscriptProjectEditor` (Win64, Development), run from the workspace root.

```powershell
Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.Compile.ClassGenCall'; Fast = $true; TimeoutMs = 600000 }
```

PASS when both cases execute and `InitialProcessEventReturnsValue` is green. The Automation report lists the complete `Angelscript.UnitTest.NativeEngine.Compile.ClassGenCall` paths.

**Notes**

Observe RED on the written test before changing product code. If Builder+ClassGen already bind the hand-filled method, the task is the fixture plus the spec; do not invent an Engine copy of Builder Methods.

**Evidence**

- First proving run `ue.test` prefix `Angelscript.UnitTest.NativeEngine.Compile.ClassGenCall` Fast: run `28706b296f65495baad7735a206965e7`, Summary `Passed` 1/1. Path `Angelscript.UnitTest.NativeEngine.Compile.ClassGenCall.InitialProcessEventReturnsValue` Success. `InitialStillMaterializesActor` assertions (UASClass UserData + ScriptTypePtr) held in the same method.
- No product edit. Analyze already binds hand-filled `Methods`; ProcessEvent already returns 7. Naming assumed: none.
