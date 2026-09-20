---
task_graph:
  version: 1
  depends_on:
    "1.1": []
    "2.1": []
    "3.1": ["1.1", "2.1"]
---

# Record SuperClass and keep Projected CompileOutput

## Goal

Fill authored SuperClass / ImplementedInterfaces at Resolved and keep Project as CompileOutput authority. ClassGen UserData is not accepted here.

## Architecture

Project fills SuperClass from resolved bases. RefreshCompileOutput keeps that Project after definitions exist. ClassGen bind-helper work is withdrawn so a later Change can own module materialization. See [design.md](design.md).

## Global constraints

- TestDir is `Angelscript.UnitTest.NativeEngine.Compile`. SuperClass stays on `ReflectionDescriptors`. CompileOutput stays on `CompileLifecycle`.
- Use `WITH_ANGELSCRIPT_TESTS`. Do not enable `WITH_ANGELSCRIPT_UNITTESTS` or `ASTEST_CREATE_ENGINE`.
- Do not restore `asCScriptEngine::GetModule`. Do not forge `asCModule` shells in this Change.
- Do not rewrite `FAngelscriptClassGenerator`. Do not invent a publisher type.
- Do not assert or redesign delegate / event UserData.
- Frontend farthest stage remains `Resolved`. Do not fill `CodeSuperClass` inside `CompileDeclarations`.
- Execution conventions: `.agents/skills/harness/references/execution-conventions.md`.

## File map

```diff
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Compile/as_descriptor_consumer.cpp  # · 1.1
 Plugins/Angelscript/Source/AngelscriptTest/NativeEngine/Compile/AngelscriptFrontendReflectionDescriptorTests.cpp  # · 1.1
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_builder.cpp  # · 2.1
 Plugins/Angelscript/Source/AngelscriptTest/NativeEngine/Compile/CompileLifecycleTests.cpp  # · 2.1
 Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.h  # · 3.1
 Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.cpp  # · 3.1
 Plugins/Angelscript/Source/AngelscriptRuntime/ClassGenerator/AngelscriptClassGenerator.h  # · 3.1
-Plugins/Angelscript/Source/AngelscriptTest/NativeEngine/Compile/ClassGenMaterializationTests.cpp  # · 3.1
```

## Requirement coverage

| Requirement | Tasks |
|---|---|
| Resolved class descriptors record authored SuperClass and ImplementedInterfaces | 1.1 |
| CodeSuperClass, Class, Struct, ScriptType stay null at Resolved | 1.1 |
| CompileOutput keeps Projected descriptors after DefinitionsFrozen / ByteCodeEmitted | 2.1 |
| ScriptType stays null on Builder CompileOutput | 2.1 |
| ClassGen UserData is withdrawn; bind helper and ClassGenMaterialization tests are removed | 3.1 |

Self-review 2026-09-17: coverage complete after ClassGen withdraw; no placeholder phrases; symbols match `design.md` and [glossary.md](attachments/drafts/glossary.md). Record: `attachments/data/planning-validation.md`.

## 1. Resolved inheritance fields

## [x] 1.1 Fill SuperClass and ImplementedInterfaces from resolved bases

`ProjectRecord` already writes `ClassName`, `bIsStruct`, properties, and methods. It leaves `SuperClass` and `ImplementedInterfaces` empty. After this task those fields come from `GetResolvedBases`. Runtime pointers stay null.

**Outcome**

`Pawn : Actor` projects `SuperClass == "Actor"`. `Ticking : ITickable` projects `ImplementedInterfaces` containing `ITickable`. `CodeSuperClass`, `Class`, `Struct`, and `ScriptType` stay null. Excluded: native `UClass*` lookup, ClassGen, delegate UserData.

**Interfaces**

Consumes (existing):

```cpp
// as_descriptor_consumer.cpp:160
bool ProjectRecord(const asCRecordDecl& Record, const asCCompilationSession& Session, ...);
// as_decl.h:198
TConstArrayView<asCType*> asCRecordDecl::GetResolvedBases() const;
// as_decl.h:192
asETypeDeclKind asCRecordDecl::GetDeclaredTypeKind() const;
// as_compilation_session.h:32
asCRecordDecl* asCCompilationSession::FindRecordDeclaration(const asSStableKey& Identity) const;
// as_type.h:77
const asSStableKey& asCNominalType::GetDeclarationIdentity() const;
// as_decl.h:139
const FString& asCNamedDecl::GetName() const;
// as_compilation_session_records.cpp:38
// one non-interface object base; extra object bases are invalid
// AngelscriptDescriptors.h:201
FString FAngelscriptClassDesc::SuperClass;
TArray<FString> FAngelscriptClassDesc::ImplementedInterfaces;
UClass* FAngelscriptClassDesc::CodeSuperClass; // must stay null here
```

Produces: no new public names. New methods stay on existing `ReflectionDescriptors` (`AngelscriptFrontendReflectionDescriptorTests.cpp:71`).

**Cases**

1. **ResolvedClassRecordsAuthoredSuperClass** — new RED
   Given `UCLASS() class Actor {}; UCLASS() class Pawn : Actor {};` When `FSemanticRun` projects Then `Pawn.SuperClass == "Actor"`, `Actor.SuperClass` is empty, and `Pawn.CodeSuperClass == nullptr`.
2. **ResolvedClassRecordsImplementedInterfaces** — new RED
   Given `interface ITickable {}; UCLASS() class Ticking : ITickable {};` When projected Then `Ticking.ImplementedInterfaces` contains `"ITickable"` and `Ticking.SuperClass` is empty.
3. **ResolvedDescriptorsRetainSemanticKeysAndNullMaterializationPointers** — existing control
   Given `UCLASS() class Actor {};` Then lifecycle is `Resolved` and `Class`, `Struct`, `ScriptType`, and `CodeSuperClass` stay null (`AngelscriptFrontendReflectionDescriptorTests.cpp:165`).
4. **EnumAndDelegateDescriptorsRemainResolvedAndUnmaterialized** — existing control
   Given `UENUM() enum EMode { Idle, Run }; delegate void OnDone(int Code);` Then `EMode.Enum == nullptr` and `OnDone.Function == nullptr` (`AngelscriptFrontendReflectionDescriptorTests.cpp:217`). The test still does not read materialized delegate fields.

**Files**

```diff
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Compile/as_descriptor_consumer.cpp
 Plugins/Angelscript/Source/AngelscriptTest/NativeEngine/Compile/AngelscriptFrontendReflectionDescriptorTests.cpp
```

No other descriptor consumers or ClassGen files.

**Verification**

Workspace root `D:\Workspace\AngelscriptProject`. After the new methods exist in source, build `AngelscriptProjectEditor` Win64 Development through `ue.build` when the current editor binary does not contain them. Then run:

```
pwsh -NoProfile -Command "Import-Module ./.agents/skills/harness/scripts/Harness.psd1; $c = New-HarnessContext -WorkspaceRoot (Get-Location).Path; Invoke-Harness -Command ue.test -Context $c -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.Compile.ReflectionDescriptors'; Fast = $true; TimeoutMs = 600000 }"
```

Cases 1–2 execute and pass. Cases 3–4 stay green. `CodeSuperClass` is null on every Resolved class in this prefix.

**Notes**

Resolve each base through `dyn_cast<asCNominalType>` then `FindRecordDeclaration`. Treat `asETypeDeclKind::Interface` as an implemented interface. The first non-interface record name is `SuperClass`. Do not default empty SuperClass to `"UObject"` in this task.

**Evidence**

GREEN `ue.test` prefix `Angelscript.UnitTest.NativeEngine.Compile.ReflectionDescriptors` Fast after build `7e720f5d7fd242aeb78aecde2d5f2d2f`. Run `a8ef03b3b61b4f5184fa8a443503ccdc`: 19/19. Cases 1–2 present as `ResolvedClassRecordsAuthoredSuperClass` and `ResolvedClassRecordsImplementedInterfaces`. Cases 3–4 stayed in the same prefix. Report: `Saved/Harness/Unreal/Runs/a8ef03b3b61b4f5184fa8a443503ccdc/Summary.json`.

## 2. CompileOutput authority

## [x] 2.1 Keep Projected CompileOutput after definitions exist

`RefreshCompileOutput` currently replaces Projected modules with a TypeInfo name scan once `ModuleDefinitions` exist. After this task Project remains the authority at `DefinitionsFrozen` and `ByteCodeEmitted`. ScriptType stays null.

**Outcome**

A USTRUCT with a UPROPERTY still reports `bIsStruct == true` and property `X` after definitions are built. Unattributed `class Widget` still reports `ClassName == "Widget"`. Excluded: ClassGen, SuperClass fill (owned by 1.1), Engine registration.

**Interfaces**

Consumes (existing):

```cpp
// as_builder.cpp:255
void RefreshCompileOutput();
// as_builder.cpp:259
if (ModuleDefinitions) { /* TypeInfo scan; this branch must not replace Project */ }
// as_builder.cpp:287
DescriptorConsumer.Project(*Session, Sources, Projected, true);
// as_compile_output.h:12
TConstArrayView<TSharedRef<FAngelscriptModuleDesc>> asCDefinitionCompileOutput::GetModules() const;
// as_builder.h:47
const asCCompileOutput* asCBuilder::GetCompileOutput() const;
```

Produces: no new public names. New methods stay on existing `CompileLifecycle` (`CompileLifecycleTests.cpp:18`).

**Cases**

1. **ProjectedUStructSurvivesDefinitionsFrozen** — new RED
   Given `USTRUCT() struct FPoint { UPROPERTY() int X; };` When `RunThrough(DefinitionsFrozen)` Then `GetCompileOutput()` has `FPoint.bIsStruct == true`, one property named `X`, and `ScriptType == nullptr`.
2. **ProjectedUStructSurvivesByteCodeEmitted** — new RED
   Given the same `FPoint` source When `RunThrough()` with the default stop Then CompileOutput still has `bIsStruct == true` and property `X`.
3. **CompileOutputReportsClassName** — existing control
   Given `class Widget { int A; }` When `RunThrough(DefinitionsFrozen)` Then `ClassName == "Widget"` (`CompileLifecycleTests.cpp:160`).
4. **CompileOutputLeavesScriptTypeNull** — existing control
   Given `class Widget { int A; }` Then `ScriptType` and each `ScriptFunction` stay null (`CompileLifecycleTests.cpp:172`).

**Files**

```diff
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_builder.cpp
 Plugins/Angelscript/Source/AngelscriptTest/NativeEngine/Compile/CompileLifecycleTests.cpp
```

No descriptor-consumer or ClassGen files.

**Verification**

Workspace root `D:\Workspace\AngelscriptProject`. After the new methods exist in source, build `AngelscriptProjectEditor` Win64 Development through `ue.build` when the current editor binary does not contain them. Then run:

```
pwsh -NoProfile -Command "Import-Module ./.agents/skills/harness/scripts/Harness.psd1; $c = New-HarnessContext -WorkspaceRoot (Get-Location).Path; Invoke-Harness -Command ue.test -Context $c -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.Compile.CompileLifecycle'; Fast = $true; TimeoutMs = 600000 }"
```

Cases 1–2 execute and pass. Cases 3–4 stay green. `RegisterInstallsEngineAndTypeId` in this prefix remains green.

**Notes**

Call `Project` whenever the session is publishable, including after `ModuleDefinitions` exist. The TypeInfo scan must not become CompileOutput. `bIncludeUnattributedRecords` stays true so `Widget` remains visible.

**Evidence**

First `ue.test` prefix `Angelscript.UnitTest.NativeEngine.Compile.CompileLifecycle` Fast run `71293a3f20034eaba1afd0fc7d68e069` failed 26/27 on `TakeSetDestroyDeletesTypes` at the dangling-pointer compare (`CompileLifecycleTests.cpp:132`). That oracle compared a freed TypeInfo address to the next allocation. Replaced it with `asSDefinitionDestroyCounters` (`Types >= 1`) and a second independent `Gone` compile. Rebuild `c5aeae8d2200439dbcbdad80ddfc293c`. GREEN run `a609056a9144444c860e5e824bc7bcd2`: 27/27 including `ProjectedUStructSurvivesDefinitionsFrozen`, `ProjectedUStructSurvivesByteCodeEmitted`, `CompileOutputReportsClassName`, `CompileOutputLeavesScriptTypeNull`, and `RegisterInstallsEngineAndTypeId`. Report: `Saved/Harness/Unreal/Runs/a609056a9144444c860e5e824bc7bcd2/Summary.json`.

## 3. Withdraw ClassGen

## [x] 3.1 Withdraw ClassGen UserData from this Change

The previous 3.1 outcome (ClassGen UserData after FullReload) cannot be proven without old `asCModule` shells. This card keeps the ID and withdraws that work. SuperClass and Project stay.

**Outcome**

`BindRegisteredTypesForClassGeneration` is gone. `ClassGenMaterializationTests.cpp` is gone. `PerformFullReload` / `PerformSoftReload` are no longer exported for that test. `angelscript/runtime/class-generation` is not a capability of this Change. Module / ClassGen join is follow-up work, not executed here.

**Files**

```diff
 Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.h
 Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/ClassGenerator/AngelscriptClassGenerator.h
-Plugins/Angelscript/Source/AngelscriptTest/NativeEngine/Compile/ClassGenMaterializationTests.cpp
-openspec/changes/angelscript/feature-classgen-type-materialization/specs/angelscript/runtime/class-generation/spec.md
```

Do not add a replacement bind helper. Do not restore `GetModule`.

**Verification**

Workspace root `D:\Workspace\AngelscriptProject`. After the listed deletions and reversions, build `AngelscriptProjectEditor` Win64 Development through `ue.build` when the current editor binary still contains the withdrawn symbols. Then run:

```
pwsh -NoProfile -Command "Import-Module ./.agents/skills/harness/scripts/Harness.psd1; $c = New-HarnessContext -WorkspaceRoot (Get-Location).Path; if (Test-Path 'Plugins/Angelscript/Source/AngelscriptTest/NativeEngine/Compile/ClassGenMaterializationTests.cpp') { throw 'ClassGenMaterializationTests.cpp must be removed' }; if ((Get-Content -Raw 'Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.h') -match 'BindRegisteredTypesForClassGeneration') { throw 'BindRegisteredTypesForClassGeneration must be removed' }; $a = Invoke-Harness -Command ue.test -Context $c -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.Compile.ReflectionDescriptors'; Fast = $true; TimeoutMs = 600000 }; if ($a.status -ne 'Succeeded') { throw 'ReflectionDescriptors failed' }; $b = Invoke-Harness -Command ue.test -Context $c -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.Compile.CompileLifecycle'; Fast = $true; TimeoutMs = 600000 }; if ($b.status -ne 'Succeeded') { throw 'CompileLifecycle failed' }"
```

The withdrawn test file and bind symbol are absent. 1.1 SuperClass cases and 2.1 Projected USTRUCT cases stay green on their own prefixes.

**Notes**

Old UserData acceptance is cancelled. Record the module-materialization follow-up in INDEX; do not create that Change from this card.

**Evidence**

`ClassGenMaterializationTests.cpp` is absent. `BindRegisteredTypesForClassGeneration` is absent from `AngelscriptEngine.h`. `PerformFullReload` / `PerformSoftReload` exports reverted. Class-generation spec delta deleted. Shared GREEN: ReflectionDescriptors `a8ef03b3b61b4f5184fa8a443503ccdc` and CompileLifecycle `a609056a9144444c860e5e824bc7bcd2` after withdraw build `7e720f5d7fd242aeb78aecde2d5f2d2f` / `c5aeae8d2200439dbcbdad80ddfc293c`. Module / ClassGen join is follow-up, not executed here.
