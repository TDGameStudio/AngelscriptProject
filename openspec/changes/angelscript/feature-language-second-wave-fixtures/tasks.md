---
task_graph:
  version: 1
  depends_on:
    "1.1": []
    "2.1": ["1.1"]
    "3.1": ["2.1"]
    "4.1": ["2.1"]
---

# Admit second-wave Language theme pockets

## Goal

Admit Auto, Class, Inheritance, Destructors, Typedef, and Mixin as Language theme pockets with CompileFail siblings, without thickening the first wave or moving Unreal material.

## Architecture

Pending second-wave files are rewritten into six `@begin` pockets at `AngelscriptTestCode/Language/<Theme>.as`. CodeGen already discovers non-Pending sources. See [design.md](design.md).

## Global constraints

- Do not reopen parser/Builder grammar.
- Do not edit Unreal, World, Bindings leftovers, or first-wave theme bodies except `ClassDeclarationCompileFail` overlap.
- New public names come from [attachments/drafts/glossary.md](attachments/drafts/glossary.md).
- Execution conventions: `.agents/skills/harness/references/execution-conventions.md`.

## File map

```diff
 AngelscriptTestCode/
   Language/  # 1.1
   Language/Migration/  # 3.1
   CodeGenTool/tests/test_second_wave_authors.py  # 1.1
 Plugins/Angelscript/Source/AngelscriptTest/
   TestCode/Generated/Language/  # 2.1
   FrameworkTests/LanguageFixtureCorpusTests.cpp  # 4.1
 .agents/skills/angelscript-test/  # 3.1
 openspec/specs/angelscript/testing/language-fixtures/  # 3.1
```

## Requirement coverage

| Requirement | Tasks |
|---|---|
| Six second-wave FileTags plus CompileFail | 1.1, 2.1, 4.1 |
| Class/super negatives not duplicated | 1.1, 3.1 |
| language-fixtures inventory updated | 3.1 |
| Projections match authors | 2.1 |
| No Unreal/Bindings/first-wave thicken | Global constraints |

Self-review 2026-09-17: coverage maps every delta requirement; placeholder scan clean; symbols match glossary. Record: attachments/data/planning-validation.md.

## 1. Authors

## [x] 1.1 Author six theme pockets and merge Class fail overlap

Rewrite Pending Auto, Class, Inheritance, Destructors, Typedef, and Mixin into `Language/<Theme>.as` plus `Language/<Theme>CompileFail.as`. Move overlapping cases off `Language/Syntax/ClassDeclarationCompileFail`. Do not generate C++ here.

**Outcome**

Six positive FileTags and their CompileFail siblings parse as current `@begin` containers with at least one parentless version each. `invalid-class-without-name` and `invalid-super-outside-class` exist on Class or Inheritance Fail files only. Pending second-wave files are not the admitted source.

**Interfaces**

Consumes:

```
parse_source_file(source: SourceInput) -> ParsedFile  # container_parser.py:243
discover_sources(author_root: Path)                    # discovery.py:46
```

Produces:

```
Language/Auto Language/Class Language/Inheritance
Language/Destructors Language/Typedef Language/Mixin
Language/<Theme>CompileFail
tests.test_second_wave_authors
```

Source: [glossary.md](attachments/drafts/glossary.md). Test module follows `CodeGenTool/tests/test_discovery.py`.

**Cases**

1. **SixPocketsParse** — new RED
   Given the six new author files on disk. When `parse_source_file` runs on each. Then FileTag equals `Language/<Theme>` or `Language/<Theme>CompileFail`, file `@version` is `v1`, and each file has at least one version with empty Parent.

2. **ClassFailNotDuplicated** — new RED
   Given the Class/Inheritance CompileFail authors and `Language/Syntax/ClassDeclarationCompileFail.as` if it still exists. When version tags are collected. Then `invalid-class-without-name` and `invalid-super-outside-class` appear in exactly one FileTag.

3. **DiscoverySkipsPending** — existing control
   Given `Pending/Language/Auto` still present. When `discover_sources` runs. Then those Pending paths are absent and the new `Language/Auto.as` path is present.

**Files**

```diff
 AngelscriptTestCode/Language/Auto.as
 AngelscriptTestCode/Language/AutoCompileFail.as
 AngelscriptTestCode/Language/Class.as
 AngelscriptTestCode/Language/ClassCompileFail.as
 AngelscriptTestCode/Language/Inheritance.as
 AngelscriptTestCode/Language/InheritanceCompileFail.as
 AngelscriptTestCode/Language/Destructors.as
 AngelscriptTestCode/Language/DestructorsCompileFail.as
 AngelscriptTestCode/Language/Typedef.as
 AngelscriptTestCode/Language/TypedefCompileFail.as
 AngelscriptTestCode/Language/Mixin.as
 AngelscriptTestCode/Language/MixinCompileFail.as
 AngelscriptTestCode/Language/Syntax/ClassDeclarationCompileFail.as
 AngelscriptTestCode/CodeGenTool/tests/test_second_wave_authors.py
```

Does not include Generated C++ or Skill/spec.

**Verification**

```
python AngelscriptTestCode/CodeGenTool/tests/test_second_wave_authors.py
```

Working directory: workspace root. PASS when all three cases execute and pass. The test file inserts `CodeGenTool` on `sys.path` the same way `test_discovery.py` does.

**Evidence**

- RED `python AngelscriptTestCode/CodeGenTool/tests/test_second_wave_authors.py`: SixPocketsParse missing all 12 `Language/<Theme>.as` files; ClassFailNotDuplicated missing `ClassCompileFail.as`; DiscoverySkipsPending absent `Language/Auto.as` (Pending already skipped).
- GREEN same command: 3/3 OK. Twelve pockets parse as `@begin` v1 with parentless versions and no Tag `root`. `invalid-class-without-name` lives only on `Language/ClassCompileFail`; `invalid-super-outside-class` only on `Language/InheritanceCompileFail`. `Language/Syntax/ClassDeclarationCompileFail.as` removed.
- Naming assumed: none.

## 2. Projections

## [x] 2.1 Generate Language projections for the six themes

Run the existing generator so each new author file has a signed `.generated.cpp` under `TestCode/Generated/Language/`.

**Outcome**

`codegen.py check` reports the six positives and their CompileFail siblings synchronized. No Pending path is projected.

**Files**

```diff
+ Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/Language/Auto.generated.cpp
+ Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/Language/AutoCompileFail.generated.cpp
+ Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/Language/Class.generated.cpp
+ Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/Language/ClassCompileFail.generated.cpp
+ Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/Language/Inheritance.generated.cpp
+ Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/Language/InheritanceCompileFail.generated.cpp
+ Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/Language/Destructors.generated.cpp
+ Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/Language/DestructorsCompileFail.generated.cpp
+ Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/Language/Typedef.generated.cpp
+ Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/Language/TypedefCompileFail.generated.cpp
+ Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/Language/Mixin.generated.cpp
+ Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/Language/MixinCompileFail.generated.cpp
- Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/Language/Syntax/ClassDeclarationCompileFail.generated.cpp
```

Only these signed generated units. Drop the ClassDeclarationCompileFail projection if that author file is removed.

**Verification**

```
python AngelscriptTestCode/CodeGenTool/codegen.py check
```

Working directory: workspace root. PASS when the command exits 0 after generate. Document-only check is not enough if generate was skipped.

**Evidence**

- RED `python AngelscriptTestCode/CodeGenTool/codegen.py check` exit 1: missing the 12 `Language/<Theme>.generated.cpp` units; stale `Language/Syntax/ClassDeclarationCompileFail.generated.cpp`.
- GREEN `python AngelscriptTestCode/CodeGenTool/codegen.py generate` then `check`: both exit 0, "Test-code generated projections are synchronized." Stale ClassDeclarationCompileFail projection removed. No Pending path projected.
- Unrelated untracked `AngelscriptTestCode/Containers` authors were also discovered by the global generator. Their TArray/TMap projections failed MSVC C4883 (`ue.build` run `35386fb4bc9d4df7ac65f2981fb7ad72`). Those Container projections were removed; the sibling authors were parked only for the Language build/test and restored afterward. This Change does not own Containers.
- Naming assumed: none.

## 3. Records

## [x] 3.1 Update language-fixtures spec, Skill example, and Migration census

Record the six FileTags in the durable spec, point the Skill at one second-wave example besides StructFields, and mark the six Pending themes adapted in Language Migration.

**Outcome**

Current `language-fixtures` spec names the six FileTags. Migration rows for the six Pending trees are `adapted` to the glossary FileTags. Skill text still uses StructFields as the Family example and mentions `Language/Class` as a parentless second-wave pocket.

**Files**

```diff
 openspec/specs/angelscript/testing/language-fixtures/spec.md
 openspec/specs/angelscript/testing/language-fixtures/spec.yaml
 .agents/skills/angelscript-test/SKILL.md
 .agents/skills/angelscript-test/references/test-code-database.md
 AngelscriptTestCode/Language/Migration/README.md
 AngelscriptTestCode/Pending/Language/Migration.md
```

**Verification**

```
Select-String -Path openspec/specs/angelscript/testing/language-fixtures/spec.md -Pattern 'Language/Auto'
```

Working directory: workspace root. PASS when the current spec contains `Language/Auto` after sync from this Change delta, and `AngelscriptTestCode/Language/Migration/README.md` contains destination `Language/Auto`.

**Evidence**

- `Select-String` on `openspec/specs/angelscript/testing/language-fixtures/spec.md` matches `Language/Auto` in the inventory requirement and the second-wave scenario.
- `AngelscriptTestCode/Language/Migration/README.md` lists destination `Language/Auto` for `Pending/Language/Auto`.
- Skill still uses StructFields as the Family example and names `Language/Class` as a parentless second-wave pocket.
- Pending six-theme rows are `adapted` to the glossary FileTags. Properties and leftover Const stay Pending.
- Naming assumed: none.

## 4. Corpus

## [x] 4.1 Corpus lists the six second-wave FileTags

Add a Framework test that `FindFiles` for topic Language includes the six glossary positives and does not require `root`.

**Outcome**

`CorpusHasSecondWaveThemes` finds `Language/Auto` through `Language/Mixin`. `Get(Language/Auto, root)` is not used as the representative lookup.

**Interfaces**

Consumes:

```
FAngelscriptTestCode::FindFiles  # AngelscriptTestCode.h:31
FAngelscriptTestCode::Get        # AngelscriptTestCode.h:26
```

Produces:

```
TEST_METHOD CorpusHasSecondWaveThemes
```

Source: existing class `LanguageFixtureCorpus` in `LanguageFixtureCorpusTests.cpp:217`. Method name from this card.

**Cases**

1. **CorpusHasSecondWaveThemes** — new RED
   Given an activated database after 2.1 projections compile. When `FindFiles({Language})` runs. Then the result contains FileTags `Language/Auto`, `Language/Class`, `Language/Inheritance`, `Language/Destructors`, `Language/Typedef`, and `Language/Mixin`.

2. **CorpusStillHasClassHandleCast** — existing control
   Given the same `FindFiles` result. When Tags are inspected. Then `Language/Casting/ClassHandleCast` is present and `Language/Casting/ClassCast` is absent.

**Files**

```diff
 Plugins/Angelscript/Source/AngelscriptTest/FrameworkTests/LanguageFixtureCorpusTests.cpp
```

**Verification**

```
Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.Framework.LanguageFixtureCorpus'; Fast = $true; TimeoutMs = 600000 }
```

Working directory: workspace root. Build first per execution conventions. PASS when both methods in this class run and the new method is among them.

**Evidence**

- `ue.build` run `35386fb4bc9d4df7ac65f2981fb7ad72` Failed: MSVC C4883 in sibling `Generated/Containers/TArray.generated.cpp` and `TMap.generated.cpp` (not this Change). Container projections removed; authors restored after proof.
- `ue.build` run `7fe2aaafaf784beb8ebfbcee0deef4e4` Succeeded.
- `ue.test` TestPrefix `Angelscript.UnitTest.Framework.LanguageFixtureCorpus` Fast run `d76ae3f860e742428f6d3721183aa1b6` Succeeded; report `Saved/Harness/Unreal/Runs/d76ae3f860e742428f6d3721183aa1b6/AutomationReport/index.json`; 3/3 discovered and executed, 0 failed.
- Cases: CorpusHasSecondWaveThemes Success; CorpusHasClassHandleCast Success (existing control for CorpusStillHasClassHandleCast). DumpsAllAuthoredSources also Success on the same binary.
- New Automation RED was not observable as a missing-method run; FileTags were already projected by 2.1. First executable selector is this GREEN snapshot. `Get(Language/Auto, root)` is asserted unsuccessful.
- Naming assumed: none.
- Omitted: Quick, Performance, Integration, full Framework — this card owns only LanguageFixtureCorpus.
