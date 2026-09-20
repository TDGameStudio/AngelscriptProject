---
task_graph:
  version: 1
  depends_on:
    "1.1": []
    "1.2": []
    "2.1": ["1.1", "1.2"]
    "3.1": ["2.1"]
    "4.1": ["2.1"]
---

# Admit host API fixtures from Bindings leftovers

## Goal

Rewrite Bindings leftovers and Pending/Containers into admitted `Containers/` and `Unreal/<Type>` pockets under the current `@begin` contract.

## Architecture

CodeGen already discovers non-Pending `.as` files. This Change adds Containers authors, extra Unreal type authors, projections, a host-api-fixtures spec, and a Framework corpus class. See [design.md](design.md).

## Global constraints

- Do not edit Language second-wave themes or the Unreal first-batch 124 UClass + 124 World source list.
- Do not revive an admitted `Bindings/` root.
- Do not write AActor into `Containers/`.
- New public names come from [attachments/drafts/glossary.md](attachments/drafts/glossary.md).
- Execution conventions: `.agents/skills/harness/references/execution-conventions.md`.

## File map

```diff
 AngelscriptTestCode/Containers/  # 1.1
 AngelscriptTestCode/Unreal/  # 1.2
 AngelscriptTestCode/CodeGenTool/tests/test_host_api_authors.py  # 1.1, 1.2
 Plugins/Angelscript/Source/AngelscriptTest/
   TestCode/Generated/Containers/  # 2.1
   TestCode/Generated/Unreal/  # 2.1
   FrameworkTests/HostApiFixtureCorpusTests.cpp  # 4.1
 .agents/skills/angelscript-test/  # 3.1
 openspec/specs/angelscript/testing/host-api-fixtures/  # 3.1
```

## Requirement coverage

| Requirement | Tasks |
|---|---|
| Admitted Containers inventory | 1.1, 2.1, 3.1, 4.1 |
| Remaining Bindings types land under Unreal type folders | 1.2, 2.1, 3.1, 4.1 |
| Two source piles merge | 1.1, 1.2 |
| Language corpus does not own these Tags | 3.1, 4.1 |

Self-review 2026-09-17: coverage maps every delta requirement; placeholder scan clean; symbols match glossary. Record: attachments/data/planning-validation.md.

## 1. Authors

## [x] 1.1 Author Containers theme pockets

Rewrite Bindings TArray/TMap/TSet/TOptional/TSoftObjectPtr/SoftObjectPath plus Pending/Containers (including TWeakObjectPtr, TSubclassOf, TObjectPtr, Reject, Negative, Exception, thicken) into `Containers/` pockets with `@begin` cases and Fail siblings. Move TSet files whose summary states they are not TSet API out of TSet. Do not generate C++ here.

**Outcome**

Every glossary Containers FileTag parses with `@version v1` and at least one parentless version. Bindings leftover paths under `Pending/Bindings-不要这个目录了测试之后收集移交/TArray` are not admitted sources.

**Interfaces**

Consumes:

```
parse_source_file(source: SourceInput) -> ParsedFile  # container_parser.py:243
discover_sources(author_root: Path)                    # discovery.py:46
```

Produces:

```
Containers/TArray Containers/TArrayCompileFail Containers/TArrayRuntimeFail
Containers/TMap Containers/TSet Containers/TOptional
Containers/TSoftObjectPtr Containers/TWeakObjectPtr
Containers/TSubclassOf Containers/TObjectPtr Containers/SoftObjectPath
tests.test_host_api_authors
```

Source: [glossary.md](attachments/drafts/glossary.md). Fail siblings exist only when that polarity is present in the two source piles.

**Cases**

1. **ContainersTArrayParses** — new RED
   Given `AngelscriptTestCode/Containers/TArray.as`. When `parse_source_file` runs. Then FileTag is `Containers/TArray`, grammar version is v1, and at least one version has empty Parent.

2. **TArrayRuntimeFailFromPending** — new RED
   Given `Containers/TArrayRuntimeFail`. When versions are listed. Then at least one VersionTag comes from a Pending/Containers TArray Exception program such as index out of bounds.

3. **DiscoveryAdmitsContainersSkipsPending** — new RED
   Given `AngelscriptTestCode/Containers/TArray.as`. When `discover_sources` runs. Then `Containers/TArray` is in the set and `Pending/Containers/TArray/TArraySetNumGrow.as` is not.

**Files**

```diff
+ AngelscriptTestCode/Containers/TArray.as
+ AngelscriptTestCode/Containers/TArrayCompileFail.as
+ AngelscriptTestCode/Containers/TArrayRuntimeFail.as
+ AngelscriptTestCode/Containers/TMap.as
+ AngelscriptTestCode/Containers/TSet.as
+ AngelscriptTestCode/Containers/TOptional.as
+ AngelscriptTestCode/Containers/TSoftObjectPtr.as
+ AngelscriptTestCode/Containers/TWeakObjectPtr.as
+ AngelscriptTestCode/Containers/TSubclassOf.as
+ AngelscriptTestCode/Containers/TObjectPtr.as
+ AngelscriptTestCode/Containers/SoftObjectPath.as
+ AngelscriptTestCode/CodeGenTool/tests/test_host_api_authors.py
```

Further TMap/TSet Fail siblings are added under the same directory when that polarity exists in the source piles.

**Verification**

```
python AngelscriptTestCode/CodeGenTool/tests/test_host_api_authors.py
```

Working directory: workspace root. PASS when the three cases execute and pass. The test file inserts `CodeGenTool` on `sys.path` the same way `test_discovery.py` does.

**Evidence**

- Observed RED: `python AngelscriptTestCode/CodeGenTool/tests/test_host_api_authors.py` failed 4 tests (13 errors + 1 failure) because `AngelscriptTestCode/Containers/` did not exist; `Containers/TArray` was absent from discovery.
- Observed GREEN: same command, 4/4 PASS on the written pockets. Cases: ContainersTArrayParses, TArrayRuntimeFailFromPending (`index-out-of-bounds`), DiscoveryAdmitsContainersSkipsPending, plus required-pocket parse.
- Admitted authors: `Containers/{TArray,TMap,TSet,TOptional,TSoftObjectPtr,TWeakObjectPtr,TSubclassOf,TObjectPtr,SoftObjectPath}` plus Fail siblings where Pending Reject/Negative/Exception polarity exists. Bindings leftover `Pending/Bindings-*/TArray` is not an admitted source.
- Merge rule: Bindings `Observe_*` is the positive skeleton; Pending one-concern files thicken (SetNum grow/shrink, missing-key, overwrite); Pending in/out/inout matrices and `Advance/` are not copied. Fail cases keep one program per Reject/Negative/Exception version.
- TSet files whose summary states `Not TSet API` stay in Pending and are not in `Containers/TSet` (parked for 1.2, not deleted): `TextBlockSetFontAppliesSlateFontInfoFields`, `SetupPlayerInputComponent`, `PhysicsConstraintPresetRecipes`, `PrimitiveCollisionSetup`, `ProjectileMovementSettings`, `PhysicsConstraintComponentSettings`, `InputSettingsAndRuntimeMappingApi`, `InputBindingCollectionsVisibleAfterSetup`, `FVectorSpecifierAndSetProperties`, `CharacterMovementPhysicsSettings`, `ActorOwnerAndRelevancySettings`.
- Naming assumed: `Containers/TMapCompileFail`, `Containers/TMapRuntimeFail`, `Containers/TSetCompileFail`, `Containers/TSetRuntimeFail`, `Containers/TOptionalCompileFail`, `Containers/TOptionalRuntimeFail`, `Containers/TSoftObjectPtrCompileFail`, `Containers/TWeakObjectPtrCompileFail`, `Containers/TSubclassOfCompileFail`, `Containers/TSubclassOfRuntimeFail`, `Containers/TObjectPtrCompileFail` — Fail sibling FileTags follow `TArrayCompileFail` / `TArrayRuntimeFail` when that polarity exists.
- Omitted: `codegen.py check`, Unreal projections, UE Automation — 1.1 admits authors only.

## [x] 1.2 Author remaining Bindings types under Unreal

Rewrite Bindings leftover folders that are not T* / SoftObjectPath, plus overlapping Pending/Math 111 files, into `Unreal/<Type>` pockets. Merge into an Unreal first-batch theme when the type is FString/FText/FName (Strings), Input*, or AActor/UWorld (World/Actor). Park misfiled TSet gameplay from 1.1 here or under the colliding Unreal theme. Do not rewrite Unreal/Casting or World first-batch sources owned by `feature-unreal-fixture-root`.

**Outcome**

`Unreal/FMath` parses with at least one parentless version. `Unreal/FString` content is merged or explicitly folded into `Unreal/Strings` if that FileTag already exists from the sibling Change. No Bindings leftover remains the admitted source.

**Interfaces**

Consumes:

```
parse_source_file(source: SourceInput) -> ParsedFile  # container_parser.py:243
```

Produces:

```
Unreal/FMath Unreal/FVector Unreal/FString
Unreal/AActor Unreal/UObject Unreal/Json
tests.test_host_api_authors
```

Source: [glossary.md](attachments/drafts/glossary.md) non-T* root. Additional `<Type>` leaves follow the Bindings folder names listed in [bindings-intake.md](attachments/drafts/findings/bindings-intake.md).

**Cases**

1. **UnrealFMathParses** — new RED
   Given `AngelscriptTestCode/Unreal/FMath.as` or the merged math pocket that absorbed FMath. When `parse_source_file` runs. Then FileTag starts with `Unreal/` and at least one version has empty Parent.

2. **ActorNotUnderContainers** — new RED
   Given admitted author files after 1.1 and 1.2. When FileTags are listed. Then no Tag equals `Containers/AActor`.

3. **PendingMathMerged** — new RED
   Given Pending/Math FVector programs and Bindings FVector Observe entries. When the admitted FVector or math pocket is parsed. Then both sources are represented as `@begin` cases, not as a second FileTag under `Pending/`.

**Files**

```diff
+ AngelscriptTestCode/Unreal/FMath.as
+ AngelscriptTestCode/Unreal/FVector.as
+ AngelscriptTestCode/Unreal/FString.as
+ AngelscriptTestCode/Unreal/AActor.as
+ AngelscriptTestCode/Unreal/UObject.as
+ AngelscriptTestCode/Unreal/Json.as
  AngelscriptTestCode/CodeGenTool/tests/test_host_api_authors.py
```

Remaining Bindings folder names from [bindings-intake.md](attachments/drafts/findings/bindings-intake.md) become more `Unreal/<Type>.as` files in the same task.

**Verification**

```
python AngelscriptTestCode/CodeGenTool/tests/test_host_api_authors.py
```

Working directory: workspace root. PASS when the 1.2 cases in that module execute and pass. Shared module with 1.1; 1.1 cases remain passing.

**Evidence**

- Observed RED: same proving module failed UnrealFMathParses and PendingMathMerged (files missing). Containers 1.1 cases were also red on this snapshot because `Containers/` had been removed from the workspace; they were regenerated with 1.2.
- Observed GREEN: `python AngelscriptTestCode/CodeGenTool/tests/test_host_api_authors.py` 7/7 PASS. Cases: ContainersTArrayParses, TArrayRuntimeFailFromPending, DiscoveryAdmitsContainersSkipsPending, required container pockets, UnrealFMathParses, ActorNotUnderContainers, PendingMathMerged (`equals` from Bindings FVector + `construction` from Pending/Math).
- Merge destinations: FString/FText/FName/FStringTableRegistry -> `Unreal/Strings`; Input* -> `Unreal/Input`; AActor/UWorld -> `Unreal/World/Actor` (first-batch cases kept). `Unreal/Casting` not rewritten. No `Containers/AActor`.
- Remaining Bindings folders became `Unreal/<Type>.as`. Pending/Math Reject polarity became `*CompileFail` siblings on the matching math type.
- Naming assumed: `Unreal/GameplaySettings` — parks the 11 TSet files whose summary states they are not TSet API.
- Omitted: `codegen.py check` and UE Automation — owned by 2.1 / 4.1.

## 2. Projections

## [x] 2.1 Generate host-API projections

Run the existing generator for Containers authors and the new Unreal type authors.

**Outcome**

`codegen.py check` reports every Containers FileTag from 1.1 and every Unreal type FileTag from 1.2 synchronized under `TestCode/Generated/`.

**Files**

```diff
+ Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/Containers/TArray.generated.cpp
+ Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/Unreal/FMath.generated.cpp
```

2.1 also writes the remaining Generated mirrors for 1.1 and 1.2 authors. It does not replace first-batch Casting/World projections owned by `feature-unreal-fixture-root`.

**Verification**

```
python AngelscriptTestCode/CodeGenTool/codegen.py check
```

Working directory: workspace root. PASS when the command exits 0 after generate.

**Evidence**

- Observed RED: `python AngelscriptTestCode/CodeGenTool/codegen.py check` reported missing `Containers/TArray.generated.cpp`, `Unreal/FMath.generated.cpp`, and the rest of the 1.1/1.2 projections.
- Observed GREEN: `python AngelscriptTestCode/CodeGenTool/codegen.py generate` then `check` both printed `Test-code generated projections are synchronized.` and exited 0. `TArray.generated.cpp` and `FMath.generated.cpp` exist. First-batch Casting/World projections were updated only where 1.2 appended merge cases (`Unreal/World/Actor`, `Unreal/Strings`, `Unreal/Input`).
- Omitted: UE Automation — owned by 4.1.

## 3. Records

## [x] 3.1 Publish host-api-fixtures spec and Skill routing

Add the durable host-API capability and teach the Skill that TArray authors belong under `Containers/`, remaining Bindings types under `Unreal/<Type>`, and Language stays host-free.

**Outcome**

Current specs include `angelscript/testing/host-api-fixtures`. The Skill names `Containers/TArray` as the container example and does not send Bindings leftovers to `Language/`.

**Files**

```diff
 openspec/specs/angelscript/testing/host-api-fixtures/spec.md
 openspec/specs/angelscript/testing/host-api-fixtures/spec.yaml
 .agents/skills/angelscript-test/SKILL.md
 .agents/skills/angelscript-test/references/test-code-database.md
```

**Verification**

```
Select-String -Path openspec/specs/angelscript/testing/host-api-fixtures/spec.md -Pattern 'Containers/TArray' -SimpleMatch
```

Working directory: workspace root. PASS when the current spec exists after sync and contains `Containers/TArray`. Create `spec.yaml` only under `openspec/specs/`, never inside this Change's `specs/` leaf.

**Evidence**

- `openspec spec create angelscript/testing/host-api-fixtures` wrote `openspec/specs/angelscript/testing/host-api-fixtures/spec.yaml`. Current `spec.md` contains `Containers/TArray`. `Select-String` matched three lines. `openspec.validate angelscript/testing/host-api-fixtures --type spec --strict` passed.
- Skill and `test-code-database.md` now name `Containers/TArray` and route remaining Bindings types to `Unreal/<Type>`, not `Language/` or a revived `Bindings/` root.
- No `spec.yaml` was added under this Change's `specs/` leaf.

## 4. Corpus

## [x] 4.1 Corpus lists Containers TArray and Unreal FMath

Add `HostApiFixtureCorpus` that finds `Containers/TArray` by topic Containers and `Unreal/FMath` (or the merged math Tag) by topic Unreal, and does not see those Tags under topic Language.

**Outcome**

`CorpusHasTArrayAndFMath` passes. `LanguageTopicOmitsHostApi` passes.

**Interfaces**

Consumes:

```
FAngelscriptTestCode::FindFiles  # AngelscriptTestCode.h:31
```

Produces:

```
TEST_CLASS HostApiFixtureCorpus
TEST_METHOD CorpusHasTArrayAndFMath
TEST_METHOD LanguageTopicOmitsHostApi
```

Source: glossary corpus class; identity prefix `Angelscript.UnitTest.Framework` as in `LanguageFixtureCorpusTests.cpp:218`.

**Cases**

1. **CorpusHasTArrayAndFMath** — new RED
   Given activated registrations after 2.1. When `FindFiles({Containers})` and `FindFiles({Unreal})` run. Then Tags include `Containers/TArray` and `Unreal/FMath` or the merged math Tag recorded in 1.2 Evidence.

2. **LanguageTopicOmitsHostApi** — new RED
   Given the same database. When `FindFiles({Language})` runs. Then no returned Tag starts with `Containers/` and none equals `Unreal/FMath`.

**Files**

```diff
 Plugins/Angelscript/Source/AngelscriptTest/FrameworkTests/HostApiFixtureCorpusTests.cpp
```

**Verification**

```
Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.Framework.HostApiFixtureCorpus'; Fast = $true; TimeoutMs = 600000 }
```

Working directory: workspace root. Build first per execution conventions. PASS when both methods run.

**Evidence**

- Observed preimplementation Automation RED is absent: `HostApiFixtureCorpus` did not exist until this card. First executable selector is the GREEN snapshot below.
- Build `ue.build` run `1eda0518c2eb4b138886842dccc80fd7` Succeeded.
- Proving command `ue.test` TestPrefix `Angelscript.UnitTest.Framework.HostApiFixtureCorpus` Fast run `eab4483ac90d4313ae08b7e2315c0609` Succeeded; report `Saved/Harness/Unreal/Runs/eab4483ac90d4313ae08b7e2315c0609/AutomationReport/index.json`; 2/2 discovered and executed.
- Cases: CorpusHasTArrayAndFMath, LanguageTopicOmitsHostApi — both Success.
- Omitted: Quick, Performance, Integration, full Framework — this card owns only the host-API corpus class.
