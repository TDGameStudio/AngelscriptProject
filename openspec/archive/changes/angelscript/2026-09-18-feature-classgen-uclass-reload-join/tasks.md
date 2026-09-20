---
task_graph:
  version: 1
  depends_on:
    "1.1": []
    "1.2": ["1.1"]
    "2.1": ["1.1"]
    "2.2": ["1.1"]
---

# Join UCLASS reload to ProcessEvent

## Goal

After preprocessor-backed `CompileModules`, SoftReload and FullReload keep ProcessEvent working on live `UCLASS` objects and a transient Blueprint child, and a failed reload keeps the old return.

## Architecture

Inline `UCLASS()` source is written to a temp file, preprocessed, then compiled through the host `CompileModules` path already used by `ClassGenCall`. See [design.md](design.md).

## Global constraints

- Do not read `FAngelscriptTestCode` or `AngelscriptTestCode/Language/**`.
- Do not restore `Legacy/HotReload/*.cpp` or `WITH_ANGELSCRIPT_UNITTESTS`.
- Do not use `PerformHotReload` or the watcher thread as the proving entry.
- Test identity stays `Angelscript.UnitTest.NativeEngine.Compile.ClassGenUClassReload`.
- Execution conventions: `.agents/skills/harness/references/execution-conventions.md`.

## File map

```diff
 Plugins/Angelscript/Source/AngelscriptTest/NativeEngine/Compile/ClassGenUClassReloadTests.cpp  # · 1.1 1.2 2.1 2.2
 Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.cpp  # · 1.1 2.1 2.2
 Plugins/Angelscript/Source/AngelscriptRuntime/ClassGenerator/  # · 1.1 1.2 2.1 2.2
```

Runtime paths appear only if RED shows ProcessEvent still bound to the old body or the class pointer is replaced on SoftReload.

## Requirement coverage

| Requirement / acceptance condition | Tasks |
|---|---|
| SoftReload updates a callable UFUNCTION body | 1.1 |
| SoftReload ProcessEvent returns the new body | 1.1 |
| SoftReload Blueprint child ProcessEvents the new parent body | 1.2 |
| FullReload and failed reload keep ProcessEvent | 2.1, 2.2 |
| FullReload adds a property and stays callable | 2.1 |
| Failed reload keeps the old ProcessEvent result | 2.2 |
| No Language corpus, Legacy restore, or PerformHotReload | 1.1, 1.2, 2.1, 2.2 |

Self-review 2026-09-18: coverage maps every delta requirement; placeholder scan clean; symbols match glossary `ClassGenUClassReload`. Record: attachments/data/planning-validation.md.

## 1. SoftReload

## [x] 1.1 SoftReload ProcessEvent returns the new body

`ClassGenCall` ProcessEvents Initial only. `ClassGenReload` SoftReload only checks UserData. After this task a preprocessor-backed SoftReload of `GetVersion` keeps the same `UClass*` and the live object ProcessEvents 2.

**Outcome**

Inline `UCLASS()` source is saved, preprocessed, and compiled with `CompileModules(Initial)` then `SoftReloadOnly`. `GetVersion` changes from `return Version` to `return Version + 1` with `Version` default 1. The `UClass*` is unchanged. The object created before reload ProcessEvents 2. Excluded: Blueprint child, FullReload add-property, Language corpus, `PerformHotReload`.

**Interfaces**

Consumes (existing, `AngelscriptEngine.h:623` and `ClassGenCallTests.cpp:18`):

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

Consumes (existing, `AngelscriptPreprocessor.h:100`):

```
void FAngelscriptPreprocessor::AddFile(const FString& ScriptRelativePath, const FString& ScriptAbsoluteFilename, bool bLoadAsynchronous = false, bool bTreatAsDeleted = false);
bool FAngelscriptPreprocessor::Preprocess();
TArray<TSharedRef<FAngelscriptModuleDesc>> FAngelscriptPreprocessor::GetModulesToCompile();
```

Consumes (existing, `ClassGenCallTests.cpp:102`):

```
Actor->ProcessEvent(Function, &ReturnValue);
```

Produces (glossary `attachments/drafts/glossary.md`):

```
TEST_CLASS ClassGenUClassReload
TEST_METHOD SoftReloadProcessEventUpdatesBody
Angelscript.UnitTest.NativeEngine.Compile.ClassGenUClassReload
ClassGenUClassReloadSoftActor
Plugins/Angelscript/Source/AngelscriptTest/NativeEngine/Compile/ClassGenUClassReloadTests.cpp
```

**Cases**

1. **SoftReloadProcessEventUpdatesBody** — new RED
   Given a scoped host `FAngelscriptEngine` with a script package, ScriptV1 `UCLASS() class ClassGenUClassReloadSoftActor : UObject { UPROPERTY() int Version; default Version = 1; UFUNCTION() int GetVersion() { return Version; } }` written under Saved/Automation and preprocessed, `CompileModules(Initial)` succeeded, `NewObject` ProcessEvent `GetVersion` returned 1 When ScriptV2 changes only `GetVersion` to `return Version + 1` and `CompileModules(SoftReloadOnly)` runs Then the `UClass*` equals the pre-reload class, `bCompileError` is false, and ProcessEvent on the same object writes 2.

2. **InitialStillProcessEventsOne** — existing control
   Given the same Initial compile When ProcessEvent runs before SoftReload Then the return is 1. Oracle: same ProcessEvent observation as `ClassGenCall.InitialProcessEventReturnsValue` on this actor.

**Files**

```diff
+Plugins/Angelscript/Source/AngelscriptTest/NativeEngine/Compile/ClassGenUClassReloadTests.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/ClassGenerator/AngelscriptClassGenerator_Analyze.cpp
```

Do not add Blueprint or FullReload cases here. Do not include Legacy headers.

**Verification**

Import Harness in the current PowerShell 7 session. After a successful `ue.build` of `AngelscriptProjectEditor` (Win64, Development), run from the workspace root.

```powershell
Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.Compile.ClassGenUClassReload.SoftReloadProcessEventUpdatesBody'; Fast = $true; TimeoutMs = 600000 }
```

PASS when `SoftReloadProcessEventUpdatesBody` is Success. The Automation report lists that complete path.

**Notes**

Observe RED on the written method before changing product code. If SoftReload already swaps the body, the task is the fixture plus the spec.

**Evidence**

- RED `ue.test` prefix `...ClassGenUClassReload.SoftReloadProcessEventUpdatesBody` Fast: unknown super `UObject` (a68161c9); Stage 4 StaticClass helper (64de7323); Version overlapped UObject header offset=0; then default Version=0 (3c100dc6, d4e15786); DefaultsFunction null because `GetMethodByDecl` misses definition-graph `metadataMethods` (9892f02f).
- GREEN same prefix run `ce2ddbe3594b444ea08db5500813f625`: ProcessEvent 1 then SoftReload 2, same `UClass*`. Joins: TypeDatabase UObject seed, strip StaticClassHelper, CodeSuperClass layout rebase, preprocessor `__InitDefaults`, `UpdateConstructAndDefaultsFunctions` `GetMethodByName`.
- Naming assumed: none.

## [x] 1.2 SoftReload Blueprint child ProcessEvents the new parent body

Phase 1 also needs a transient Blueprint child. After this task `CreateBlueprint` on `ClassGenUClassReloadBpParent` survives SoftReload and ProcessEvents the new parent body.

**Outcome**

A `/Temp/` Blueprint is created with `FKismetEditorUtilities::CreateBlueprint` from the script parent, compiled, and instantiated. SoftReload changes `GetVersion` from `return Version` (default 30) to `return Version + 12`. The Blueprint class stays a child of the same parent `UClass` and is not a `UASClass`. The instance created before reload ProcessEvents 42. Excluded: Level Blueprint, rename redirect, PIE, FullReload structural child keep.

**Interfaces**

Consumes (existing, `Kismet2/KismetEditorUtilities.h` and this Change 1.1 helper):

```
UBlueprint* FKismetEditorUtilities::CreateBlueprint(UClass* ParentClass, UObject* Outer, FName NewBPName, EBlueprintType BlueprintType, TSubclassOf<UBlueprint> BlueprintClassType, TSubclassOf<UBlueprintGeneratedClass> BlueprintGeneratedClassType, FName CallingContext);
void FKismetEditorUtilities::CompileBlueprint(UBlueprint* Blueprint);
```

Produces (glossary `attachments/drafts/glossary.md`):

```
TEST_METHOD SoftReloadBlueprintChildCallsNewBody
ClassGenUClassReloadBpParent
```

**Cases**

1. **SoftReloadBlueprintChildCallsNewBody** — new RED
   Given Initial compile of `UCLASS() class ClassGenUClassReloadBpParent : UObject { UPROPERTY() int Version; default Version = 30; UFUNCTION() int GetVersion() { return Version; } }`, a transient Blueprint child compiled from that parent, and ProcessEvent on a Blueprint instance returned 30 When SoftReload changes `GetVersion` to `return Version + 12` Then the Blueprint generated class remains `IsChildOf` the same parent `UClass*`, `Cast<UASClass>(BlueprintClass)` is null, and ProcessEvent on the pre-reload instance writes 42.

2. **SoftActorStillUpdates** — existing control
   Given 1.1 When the Soft actor prefix still runs Then `SoftReloadProcessEventUpdatesBody` stays Success.

**Files**

```diff
 Plugins/Angelscript/Source/AngelscriptTest/NativeEngine/Compile/ClassGenUClassReloadTests.cpp
```

Do not edit Level Blueprint or PIE helpers.

**Verification**

Import Harness in the current PowerShell 7 session. After a successful `ue.build` of `AngelscriptProjectEditor` (Win64, Development), run from the workspace root.

```powershell
Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.Compile.ClassGenUClassReload.SoftReloadBlueprintChildCallsNewBody'; Fast = $true; TimeoutMs = 600000 }
```

PASS when `SoftReloadBlueprintChildCallsNewBody` is Success.

**Evidence**

- First proving run `5a96d1048d22462cbb7faed47b75eeac` succeeded: CreateBlueprint child ProcessEvent 30 then SoftReload 42, same parent `UClass*`, generated class is not `UASClass`. 1.1 joins already covered the parent body swap; this task is the Blueprint fixture. Control `SoftReloadProcessEventUpdatesBody` stayed green on `ce2ddbe3594b444ea08db5500813f625`.
- Added editor `UnrealEd`/`BlueprintGraph` deps on `AngelscriptTest` so `CreateBlueprint` links.
- Naming assumed: none.

## 2. FullReload and failure

## [x] 2.1 FullReload adds a property and stays callable

After SoftReload is proven, FullReload must add a field without losing ProcessEvent.

**Outcome**

ScriptV2 adds `UPROPERTY() int Extra` on `ClassGenUClassReloadFullActor`. After `CompileModules(FullReload)` the generated class exposes `Extra` and `GetVersion` still ProcessEvents. Excluded: Blueprint child FullReload, PIE structural downgrade.

**Interfaces**

Consumes (existing, same `CompileModules` as 1.1):

```
ECompileResult CompileModules(ECompileType::FullReload, ...);
FindFProperty<FIntProperty>(Class, TEXT("Extra"));
```

Produces (convention, task Interfaces):

```
TEST_METHOD FullReloadAddsPropertyProcessEvent
ClassGenUClassReloadFullActor
```

**Cases**

1. **FullReloadAddsPropertyProcessEvent** — new RED
   Given Initial `UCLASS() class ClassGenUClassReloadFullActor : UObject { UFUNCTION() int GetVersion() { return 1; } }` When FullReload adds `UPROPERTY() int Extra;` and keeps `GetVersion` returning 1 Then `FindFProperty<FIntProperty>(Class, "Extra")` is non-null and ProcessEvent `GetVersion` writes 1.

**Files**

```diff
 Plugins/Angelscript/Source/AngelscriptTest/NativeEngine/Compile/ClassGenUClassReloadTests.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/ClassGenerator/AngelscriptClassGenerator.cpp
```

Edit ClassGen only if RED shows Extra missing or ProcessEvent dead.

**Verification**

Import Harness in the current PowerShell 7 session. After a successful `ue.build` of `AngelscriptProjectEditor` (Win64, Development), run from the workspace root.

```powershell
Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.Compile.ClassGenUClassReload.FullReloadAddsPropertyProcessEvent'; Fast = $true; TimeoutMs = 600000 }
```

PASS when `FullReloadAddsPropertyProcessEvent` is Success.

**Evidence**

- First proving run `359983c1cd62498fa914bb5fc0e167f5` succeeded: FullReload exposed `Extra` and ProcessEvent still returned 1. No ClassGen.cpp edit.
- Naming assumed: none.

## [x] 2.2 Failed reload keeps the old ProcessEvent result

`ClassGenReload.FailedReloadKeepsLastGeneration` keeps UserData. After this task a live object still ProcessEvents 1 after a broken replacement.

**Outcome**

A broken Soft or Full replacement sets `bCompileError`. `GetModule` still finds the last-good class. ProcessEvent on the pre-failure object still returns 1. Expected compile-error logs are registered. Excluded: Language corpus, file-watch retry queue.

**Interfaces**

Consumes (existing, `ClassGenReloadTests.cpp:219`):

```
CompileModules(FullReload, Broken, Out);
asIScriptEngine::GetModule(name);
```

Produces (convention, task Interfaces):

```
TEST_METHOD FailedReloadKeepsProcessEvent
ClassGenUClassReloadKeepActor
```

**Cases**

1. **FailedReloadKeepsProcessEvent** — new RED
   Given Initial `UCLASS() class ClassGenUClassReloadKeepActor : UObject { UFUNCTION() int GetVersion() { return 1; } }` and a live object whose ProcessEvent already returned 1 When `CompileModules(FullReload)` receives `this is not valid angelscript` for that module Then `bCompileError` is true, last-good `GetModule` still has `UASClass` UserData, and ProcessEvent on the live object still writes 1.

**Files**

```diff
 Plugins/Angelscript/Source/AngelscriptTest/NativeEngine/Compile/ClassGenUClassReloadTests.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.cpp
```

**Verification**

Import Harness in the current PowerShell 7 session. After a successful `ue.build` of `AngelscriptProjectEditor` (Win64, Development), run from the workspace root.

```powershell
Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.Compile.ClassGenUClassReload.FailedReloadKeepsProcessEvent'; Fast = $true; TimeoutMs = 600000 }
```

PASS when `FailedReloadKeepsProcessEvent` is Success.

**Evidence**

- RED `061bbe5f3e48457eaeadfbf19af3d58d`: unexpected `stage-3-failed` log. `4f6a251277624dc9b6ce20802ca41cc0`: unexpected keep-old Error after expecting only `stage-3-failed`.
- GREEN `cbd45ecd38e445bbb35304dfa6bab289`: `bCompileError`, last-good `GetModule` UserData, ProcessEvent still 1. Expected errors: `stage-3-failed` and keep-old script. No Engine.cpp edit.
- Naming assumed: none.
