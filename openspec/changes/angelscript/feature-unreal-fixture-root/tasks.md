---
task_graph:
  version: 1
  depends_on:
    "1.1": []
    "2.1": ["1.1"]
    "3.1": ["2.1"]
    "4.1": ["2.1"]
---

# Admit an Unreal author root for UE fixtures

## Goal

Create `AngelscriptTestCode/Unreal/` and rewrite the 124 Language UClass files plus Pending/World into the glossary theme pockets.

## Architecture

CodeGen already discovers non-Pending `.as` files. This Change only adds Unreal authors, projections, an Unreal spec, and a Framework corpus class. See [design.md](design.md).

## Global constraints

- Do not edit Language second-wave themes or the 580 Bindings leftovers.
- Do not revive an admitted `Bindings/` root.
- New public names come from [attachments/drafts/glossary.md](attachments/drafts/glossary.md).
- Execution conventions: `.agents/skills/harness/references/execution-conventions.md`.

## File map

```diff
 AngelscriptTestCode/Unreal/  # 1.1
 AngelscriptTestCode/CodeGenTool/tests/test_unreal_authors.py  # 1.1
 Plugins/Angelscript/Source/AngelscriptTest/
   TestCode/Generated/Unreal/  # 2.1
   FrameworkTests/UnrealFixtureCorpusTests.cpp  # 4.1
 .agents/skills/angelscript-test/  # 3.1
 openspec/specs/angelscript/testing/unreal-fixtures/  # 3.1
```

## Requirement coverage

| Requirement | Tasks |
|---|---|
| Admitted Unreal inventory | 1.1, 2.1, 3.1, 4.1 |
| UE material is not Language | 3.1, 4.1 |
| 580 Bindings leftovers stay out | Global constraints |

Self-review 2026-09-17: coverage maps every delta requirement; placeholder scan clean; symbols match glossary. Record: attachments/data/planning-validation.md.

## 1. Authors

## [x] 1.1 Author first-batch Unreal theme pockets

Rewrite the 124 Language UClass files and 124 World files into the glossary Unreal pockets with `@begin` cases and CompileFail siblings where polarity exists. Do not generate C++ here.

**Outcome**

Every glossary first-batch FileTag parses with `@version v1` and at least one parentless version. `ObjectCastAndTypeChecks` meaning lives under `Unreal/Casting`, not `Language/Casting`. Pending copies are not admitted sources.

**Interfaces**

Consumes:

```
parse_source_file(source: SourceInput) -> ParsedFile  # container_parser.py:243
discover_sources(author_root: Path)                    # discovery.py:46
```

Produces:

```
Unreal/Casting Unreal/Strings Unreal/GarbageCollection
Unreal/Input Unreal/Events Unreal/Reflection
Unreal/ActorClass Unreal/Hooks
Unreal/World/Actor Unreal/World/Component
Unreal/World/Blueprint Unreal/World/Streaming Unreal/World/Subsystem
tests.test_unreal_authors
```

Source: [glossary.md](attachments/drafts/glossary.md).

**Cases**

1. **UnrealPocketsParse** — new RED
   Given each first-batch author file. When `parse_source_file` runs. Then FileTag starts with `Unreal/` and matches a glossary leaf, and at least one version has empty Parent.

2. **CastingIsNotLanguage** — new RED
   Given `Unreal/Casting.as` and `Language/Casting/ClassHandleCast.as`. When FileTags are read. Then the ObjectCast/UCLASS program is only on `Unreal/Casting`.

3. **DiscoveryAdmitsUnreal** — new RED
   Given `AngelscriptTestCode/Unreal/Casting.as`. When `discover_sources` runs. Then `Unreal/Casting` is in the set and `Pending/Language/Casting/UClass/ObjectCastAndTypeChecks.as` is not.

**Files**

```diff
 AngelscriptTestCode/Unreal/
 AngelscriptTestCode/CodeGenTool/tests/test_unreal_authors.py
```

**Verification**

```
python AngelscriptTestCode/CodeGenTool/tests/test_unreal_authors.py
```

Working directory: workspace root. PASS when the three cases execute and pass. The test file inserts `CodeGenTool` on `sys.path` the same way `test_discovery.py` does.

**Evidence**

- RED `python AngelscriptTestCode/CodeGenTool/tests/test_unreal_authors.py`: UnrealPocketsParse missing all 13 glossary author files; CastingIsNotLanguage missing `Unreal/Casting.as`; DiscoveryAdmitsUnreal absent `Unreal/Casting.as`.
- GREEN same command: 3/3 OK. Thirteen positives parse as `@begin` v1 with parentless versions, topic Unreal, and no Tag `root`. `Unreal/Casting` contains `UCLASS`/`Cast<`; `Language/Casting/ClassHandleCast` does not. Discovery lists `Unreal/Casting` and skips `Pending/Language/Casting/UClass/ObjectCastAndTypeChecks.as`.
- Naming assumed: none.

## 2. Projections

## [x] 2.1 Generate Unreal projections

Run the existing generator for the new Unreal author files.

**Outcome**

`codegen.py check` reports every first-batch Unreal FileTag synchronized under `TestCode/Generated/Unreal/`.

**Files**

```diff
+ Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/Unreal/Casting.generated.cpp
+ Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/Unreal/Strings.generated.cpp
+ Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/Unreal/GarbageCollection.generated.cpp
+ Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/Unreal/Input.generated.cpp
+ Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/Unreal/Events.generated.cpp
+ Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/Unreal/Reflection.generated.cpp
+ Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/Unreal/ActorClass.generated.cpp
+ Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/Unreal/Hooks.generated.cpp
+ Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/Unreal/World/Actor.generated.cpp
+ Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/Unreal/World/Component.generated.cpp
+ Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/Unreal/World/Blueprint.generated.cpp
+ Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/Unreal/World/Streaming.generated.cpp
+ Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/Unreal/World/Subsystem.generated.cpp
```

**Verification**

```
python AngelscriptTestCode/CodeGenTool/codegen.py check
```

Working directory: workspace root. PASS when the command exits 0 after generate.

**Evidence**

- RED `python AngelscriptTestCode/CodeGenTool/codegen.py check` exit 1: missing the 13 glossary Unreal units plus CompileFail siblings. Unrelated Containers authors were parked so they did not pollute this check.
- GREEN `generate` then `check`: both exit 0. Listed first-batch projections exist under `TestCode/Generated/Unreal/`. `World/Component.generated.cpp` is 271373 bytes.
- Naming assumed: none.

## 3. Records

## [x] 3.1 Publish unreal-fixtures spec and Skill routing

Add the durable Unreal capability and teach the Skill that UClass/WorldStory authors belong under `Unreal/`, not Language.

**Outcome**

Current specs include `angelscript/testing/unreal-fixtures`. The Skill names `Unreal/Casting` as the UE-cast example and keeps `Language/Syntax/StructFields` as the Language Family example.

**Files**

```diff
 openspec/specs/angelscript/testing/unreal-fixtures/spec.md
 openspec/specs/angelscript/testing/unreal-fixtures/spec.yaml
 .agents/skills/angelscript-test/SKILL.md
 .agents/skills/angelscript-test/references/test-code-database.md
```

**Verification**

```
Select-String -Path openspec/specs/angelscript/testing/unreal-fixtures/spec.md -Pattern 'Unreal/Casting' -SimpleMatch
```

Working directory: workspace root. PASS when the current spec exists after sync and contains `Unreal/Casting`.

**Evidence**

- `openspec spec create angelscript/testing/unreal-fixtures` wrote `spec.yaml` uid `spec_c2d36509-3825-44ad-8426-7341260e0a60`.
- `Select-String` on `openspec/specs/angelscript/testing/unreal-fixtures/spec.md` matches `Unreal/Casting`.
- Skill still uses StructFields as the Language Family example and names `Unreal/Casting` as the UE-cast example.
- Naming assumed: none.

## 4. Corpus

## [x] 4.1 Corpus lists Unreal Casting and World Actor

Add `UnrealFixtureCorpus` that finds `Unreal/Casting` and `Unreal/World/Actor` by topic Unreal and does not see those Tags under topic Language.

**Outcome**

`CorpusHasCastingAndWorldActor` passes. `LanguageTopicOmitsUnreal` passes.

**Interfaces**

Consumes:

```
FAngelscriptTestCode::FindFiles  # AngelscriptTestCode.h:31
```

Produces:

```
TEST_CLASS UnrealFixtureCorpus
TEST_METHOD CorpusHasCastingAndWorldActor
TEST_METHOD LanguageTopicOmitsUnreal
```

Source: glossary corpus class; identity prefix `Angelscript.UnitTest.Framework` as in `LanguageFixtureCorpusTests.cpp:218`.

**Cases**

1. **CorpusHasCastingAndWorldActor** — new RED
   Given activated registrations after 2.1. When `FindFiles({Unreal})` runs. Then Tags include `Unreal/Casting` and `Unreal/World/Actor`.

2. **LanguageTopicOmitsUnreal** — new RED
   Given the same database. When `FindFiles({Language})` runs. Then no returned Tag starts with `Unreal/`.

**Files**

```diff
 Plugins/Angelscript/Source/AngelscriptTest/FrameworkTests/UnrealFixtureCorpusTests.cpp
```

**Verification**

```
Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.Framework.UnrealFixtureCorpus'; Fast = $true; TimeoutMs = 600000 }
```

Working directory: workspace root. Build first per execution conventions. PASS when both methods run.

**Evidence**

- `ue.build` run `fb0a5a386210488dad61629f2baeb113` Succeeded.
- `ue.test` TestPrefix `Angelscript.UnitTest.Framework.UnrealFixtureCorpus` Fast run `da1d0976d03f405a95c35673a4a1362a` Succeeded; report `Saved/Harness/Unreal/Runs/da1d0976d03f405a95c35673a4a1362a/AutomationReport/index.json`; 2/2 discovered and executed, 0 failed.
- Cases: CorpusHasCastingAndWorldActor Success; LanguageTopicOmitsUnreal Success.
- New Automation RED was not observable as a missing-class run; FileTags were already projected by 2.1. First executable selector is this GREEN snapshot.
- Naming assumed: none.
- Omitted: Quick, Performance, Integration, LanguageFixtureCorpus, World execution — this card owns only UnrealFixtureCorpus admission queries.
