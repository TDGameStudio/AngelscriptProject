---
task_graph:
  version: 1
  depends_on:
    "1.1": []
    "1.2": ["1.1"]
    "2.1": ["1.1", "1.2"]
    "3.1": ["2.1"]
    "4.1": ["2.1"]
    "5.1": ["3.1", "4.1"]
---

# Refactor Language fixtures into theme pockets

## Goal

Admit several parentless Language cases, split Fail files, rewrite every Language author fixture, and retarget the test Skill and testing specs.

## Architecture

The code-database parser and Builder stop requiring a privileged `root`. Language `.as` files become theme pockets with `@begin` cases and optional Family. Skill and specs follow the same contract. See [design.md](design.md).

## Global constraints

- Do not edit `AngelscriptTestCode/Language/**` until 1.1 and 1.2 accept `@begin` and parentless versions.
- Do not modify the 122 generator products.
- Do not add asCBuilder diagnostic oracles.
- New public names come from [attachments/drafts/glossary.md](attachments/drafts/glossary.md).
- Execution conventions: `.agents/skills/harness/references/execution-conventions.md`.

## File map

```diff
 Plugins/Angelscript/Source/AngelscriptTest/
   Framework/Source/AngelscriptTestCodeBuilder.cpp  # 1.1
   Framework/Source/AngelscriptTestSourceParser.cpp  # 1.1
   FrameworkTests/ParserTests.cpp  # 1.1
   FrameworkTests/BuilderTests.cpp  # 1.1
   FrameworkTests/AdoptionTests.cpp  # 5.1
   FrameworkTests/GeneratedSourcesTests.cpp  # 5.1
   FrameworkTests/LanguageFixtureCorpusTests.cpp  # 5.1
   TestCode/Generated/Language/  # 5.1
 AngelscriptTestCode/
   CodeGenTool/  # 1.2
   Language/  # 2.1 3.1
 .agents/skills/angelscript-test/  # 4.1
 openspec/specs/angelscript/testing/  # 4.1
```

## Requirement coverage

| Requirement | Tasks |
|---|---|
| Several parentless VersionTags; `root` has no privilege | 1.1, 1.2 |
| `@begin` case identity; function header fields | 1.1, 1.2, 2.1 |
| Casting FileTags and Fail siblings | 2.1 |
| Remaining Language author files | 3.1 |
| Skill and durable specs | 4.1 |
| Projections and `Get(..., "root")` consumers | 5.1 |
| StructFields Family `fields-two` / `add-field` | 3.1, 5.1 |
| No generator products; no diagnostic oracles | Global constraints |

Self-review 2026-09-17: coverage maps every delta requirement; placeholder scan clean; symbols match glossary. Record: attachments/data/planning-validation.md.

## 1. Grammar

## [x] 1.1 Parser and Builder admit parentless cases and `@begin`

Change the C++ fixture protocol so several versions may omit Parent, case headers start with `@begin <tag>`, and a Tag spelled `root` is ordinary. Keep complete bodies, annotation stripping, and cycle/missing-parent failure. Do not rewrite Language author files here.

**Outcome**

Two `@begin` cases with no `@parent` parse and build. `AddVersion` with an empty Parent succeeds. `VersionParentRequired` and `RootMustUseAddRoot` no longer reject that shape. Cycles and missing parents still fail. Language product `.as` files stay on the old star until 2.1.

**Interfaces**

Consumes:

```
FAngelscriptTestCodeBuilder::AddVersion(FAngelscriptTestVersionMeta, FAngelscriptTestSource)
FAngelscriptTestCodeBuilder::AddRoot(...)   // AngelscriptTestCodeBuilder.h:21
FAngelscriptTestSourceParser::Parse         // AngelscriptTestSourceParser.cpp
```

Produces:

```
TEST_METHOD TwoParentlessBeginCasesAdmit
TEST_METHOD AddVersionWithoutParentSucceeds
TEST_METHOD RootTagHasNoPrivilege
```

Source: glossary parentless API; test identities follow `Angelscript.UnitTest.Framework.Parser|Builder` in `ParserTests.cpp:25` and `BuilderTests.cpp`.

**Cases**

1. **TwoParentlessBeginCases** — new RED
   Given a UTF-8 container with `@version v1`, two `@begin alpha` / `@begin beta` blocks, no `@parent`, each closed by `/** @end */`. When C++ Parse+Build runs. Then both VersionTags exist and `Get` of each Tag succeeds.

2. **AddVersionWithoutParent** — new RED
   Given a Builder and two `AddVersion` calls whose VersionMeta Parent is empty. When `Build()` runs. Then both cases are admitted and no `VersionParentRequired` error is present.

3. **MissingParentStillFails** — existing control
   Given `@begin child` with `@parent missing`. When Parse+Build runs. Then construction fails and no Cases are published.

4. **StarRootStillParsesUntilAuthorsMove** — existing control
   Given a current-style `@version root` plus `@parent root` child. When Parse+Build runs. Then it still admits so unmigrated fixtures do not block 1.1.

**Files**

```diff
 Plugins/Angelscript/Source/AngelscriptTest/Framework/Source/AngelscriptTestCodeBuilder.cpp
 Plugins/Angelscript/Source/AngelscriptTest/Framework/Source/AngelscriptTestCodeBuilder.h
 Plugins/Angelscript/Source/AngelscriptTest/Framework/Source/AngelscriptTestSourceParser.cpp
 Plugins/Angelscript/Source/AngelscriptTest/FrameworkTests/ParserTests.cpp
 Plugins/Angelscript/Source/AngelscriptTest/FrameworkTests/BuilderTests.cpp
```

**Verification**

```powershell
Import-Module ./.agents/skills/harness/scripts/Harness.psd1
$context = New-HarnessContext -WorkspaceRoot (Get-Location).Path
Invoke-Harness -Command ue.build -Context $context -Parameters @{ TimeoutMs = 1800000 }
Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.Framework.Parser'; Fast = $true; TimeoutMs = 600000 }
Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.Framework.Builder'; Fast = $true; TimeoutMs = 600000 }
```

Working directory is the selected workspace. Complete when the three new methods and the two controls pass in the Automation report.

**Evidence**

2026-09-17 workspace `d:\Workspace\AngelscriptProject`. RED: `ue.build` `d96d18efc7504f7290ce79df74beefe6` then `ue.test` Parser `eaaeab90520e4a8995d4d8b7700b2ecf` (1 failed: `TwoParentlessBeginCasesAdmit`; controls `MissingParentStillFails` and `StarRootStillParsesUntilAuthorsMove` passed) and Builder `692f1d41ac024d9299dd41f2ffccca24` (2 failed: `AddVersionWithoutParentSucceeds`, `RootTagHasNoPrivilege`). GREEN: `ue.build` then Parser `d25f4197cb8f4fc0a1cf27b0f17e9152` 11/11 and Builder `08641af2438147d5a1c7b7e80828e7b6` 13/13, including the three new methods and both controls. Naming assumed: `FileBeginForbidden` — file header rejects `@begin` the same way it rejects `@parent`. Naming assumed: `CaseIdentityConflict` — a case header may use `@begin` or legacy `@version`, not both.

## [x] 1.2 CodeGenTool parser matches `@begin` and parentless versions

Update the Python container parser and its conformance suite so it emits the same FileMeta / VersionMeta / clean bytes as C++ for `@begin` cases and empty Parent. Do not generate Language projections here.

**Outcome**

`test_source_parser.py` and `test_conformance.py` accept two parentless `@begin` cases and still reject cycles. `codegen.py check` against the still-unmigrated Language tree remains meaningful for files not yet rewritten.

**Interfaces**

Consumes:

```
AngelscriptTestCode/CodeGenTool container_parser (v1 headers)
```

Produces:

```
parse of @begin <tag> as VersionTag
empty Parent on a version with no @parent
```

Source: same glossary as 1.1; Python tests already live under `AngelscriptTestCode/CodeGenTool/tests/`.

**Cases**

1. **PythonTwoParentlessBegin** — new RED
   Given the same two-case `@begin` fixture as 1.1 case 1. When the Python parser runs. Then VersionTags `alpha` and `beta` have empty Parent and equal clean bodies to the C++ parse of those bytes.

2. **PythonConformanceParentless** — new RED · conformance
   Given the shared conformance fixture set used by `test_conformance.py`. When Python and the recorded C++ products are compared. Then parentless `@begin` fixtures match; star-shaped legacy fixtures still match until 2.1 removes them.

**Files**

```diff
 AngelscriptTestCode/CodeGenTool/
 AngelscriptTestCode/CodeGenTool/tests/test_source_parser.py
 AngelscriptTestCode/CodeGenTool/tests/test_conformance.py
```

Exclude `Language/**` author rewrites.

**Verification**

```powershell
python -m pytest AngelscriptTestCode/CodeGenTool/tests/test_source_parser.py AngelscriptTestCode/CodeGenTool/tests/test_conformance.py
```

Working directory is the workspace root. Complete when both modules exit 0 and the new parentless cases are in the passing set.

**Evidence**

2026-09-17 workspace `d:\Workspace\AngelscriptProject`. RED: `python -m pytest AngelscriptTestCode/CodeGenTool/tests/test_source_parser.py AngelscriptTestCode/CodeGenTool/tests/test_conformance.py` failed `test_two_parentless_begin_cases` and `test_positive_protocol_matrix` (`_check_parentless_begin`). GREEN: the same command, 10 passed, including parentless `@begin` cases and still-green star/cycle fixtures. Naming assumed: `FileBeginForbidden` and `CaseIdentityConflict` match the C++ 1.1 codes.

## 2. Casting proving set

## [x] 2.1 Rewrite Casting pockets to theme cases

Replace the four live Casting files with the glossary FileTags, split CompileFail / RuntimeFail siblings, drop privileged `root`, and mark callables with function headers. Move Bleed out of those pockets.

**Outcome**

`ClassHandleCast`, `NullHandle`, `NumericImplicitConversion`, and `NumericExplicitConversion` register without VersionTag `root`. Fail siblings hold only negatives for that theme. One Family example may use `@parent` plus `@range-*`. Bleed (nameless class, self-inheritance, super-outside-class, and the NumericImplicit unary-index case) is not in these FileTags.

**Interfaces**

Consumes:

```
@begin @function @summary @inputs @return   // glossary
```

Produces:

```
AngelscriptTestCode/Language/Casting/ClassHandleCast.as
AngelscriptTestCode/Language/Casting/ClassHandleCastCompileFail.as
AngelscriptTestCode/Language/Casting/ClassHandleCastRuntimeFail.as
AngelscriptTestCode/Language/Casting/NullHandle.as
AngelscriptTestCode/Language/Casting/NumericImplicitConversion.as
AngelscriptTestCode/Language/Casting/NumericExplicitConversion.as
```

and matching Fail siblings when that polarity exists. Source: glossary Casting FileTags.

**Cases**

1. **ClassHandleCastTwoParentless** — new RED
   Given the rewritten `ClassHandleCast.as`. When Python parse + `codegen.py check` for that path runs. Then at least two parentless VersionTags exist and none is required to be `root`.

2. **ClassHandleCastCompileFailIsolated** — new RED
   Given `ClassHandleCastCompileFail.as`. When the file is parsed. Then it contains only compile-fail cases and no `@function` marks.

3. **OldClassCastPathGone** — new RED
   Given the author root after the rewrite. When discovery lists FileTags. Then `Language/Casting/ClassCast` is absent and `Language/Casting/ClassHandleCast` is present.

**Files**

```diff
-AngelscriptTestCode/Language/Casting/ClassCast.as
-AngelscriptTestCode/Language/Casting/Nullptr.as
-AngelscriptTestCode/Language/Casting/NumericImplicit.as
-AngelscriptTestCode/Language/Casting/NumericExplicit.as
+AngelscriptTestCode/Language/Casting/ClassHandleCast.as
+AngelscriptTestCode/Language/Casting/ClassHandleCastCompileFail.as
+AngelscriptTestCode/Language/Casting/ClassHandleCastRuntimeFail.as
+AngelscriptTestCode/Language/Casting/NullHandle.as
+AngelscriptTestCode/Language/Casting/NumericImplicitConversion.as
+AngelscriptTestCode/Language/Casting/NumericExplicitConversion.as
 AngelscriptTestCode/Language/Casting/
```

Other theme directories wait for 3.1. Matching Fail siblings for NullHandle and Numeric* are created when those files have negatives.

**Verification**

```powershell
python AngelscriptTestCode/CodeGenTool/codegen.py check
```

Working directory is the workspace root. Complete when check exits 0 for the new Casting paths and reports the old four FileTags as absent (or only as stale generated cleanup reserved for 5.1).

**Evidence**

2026-09-17 workspace `d:\Workspace\AngelscriptProject`. New Casting FileTags parse: `ClassHandleCast` has parentless `implicit-derived-to-base`, `cast-to-parent`, `cast-downcast`, `cast-round-trip` plus Family child `cast-downcast-null-guard`; `ClassHandleCastCompileFail` has only `invalid-*` cases and no `@function`. Discovery has `Language/Casting/ClassHandleCast` and not `Language/Casting/ClassCast`. `python AngelscriptTestCode/CodeGenTool/codegen.py check` exits 1 with missing projections for the nine new Casting paths and stale `ClassCast` / `Nullptr` / `NumericImplicit` / `NumericExplicit` generated units reserved for 5.1. Bleed (`invalid-class-*`, `invalid-super-outside-class`, unary-index) left these FileTags for 3.1.

## 3. Remaining Language

## [x] 3.1 Rewrite the remaining Language author files

Apply the same pocket format to every Language `.as` outside Casting. Keep current leaf names. Split Fail siblings. Rename StructFields `root` to `fields-two`.

**Outcome**

All Language author files parse as `@begin` cases. `Language/Syntax/StructFields` has parentless `fields-two` and child `add-field`. Negatives live in `*CompileFail.as` / `*RuntimeFail.as`. No Language author file requires VersionTag `root`.

**Interfaces**

Consumes the 1.1 grammar and 2.1 Casting pattern. Produces rewritten files under `AngelscriptTestCode/Language/{Syntax,Operators,ControlFlow,Namespace,Preprocessor}/`. Source: glossary "other Language FileTags keep the current leaf".

**Cases**

1. **StructFieldsFamily** — new RED
   Given rewritten `StructFields.as`. When parsed. Then VersionTag `fields-two` has empty Parent, `add-field` has Parent `fields-two`, and `invalid-duplicate-field` is not in this FileTag.

2. **NoLanguageRootVersion** — new RED
   Given every Language author file after the rewrite. When each file is parsed. Then no required representative VersionTag named `root` remains.

**Files**

```diff
 AngelscriptTestCode/Language/
   Syntax/StructFields.as
   Syntax/
   Operators/
   ControlFlow/
   Namespace/
   Preprocessor/
+AngelscriptTestCode/Language/Syntax/StructFieldsCompileFail.as
```

Casting stays as rewritten in 2.1. Other Fail siblings are created beside the positive leaf they leave.

**Verification**

```powershell
python AngelscriptTestCode/CodeGenTool/codegen.py check
```

Working directory is the workspace root. Complete when check exits 0 on the full Language author tree.

**Evidence**

2026-09-17 workspace `d:\Workspace\AngelscriptProject`. All 95 Language FileTags parse with `@begin`; no VersionTag `root`. `Language/Syntax/StructFields` has parentless `fields-two` and child `add-field`; `invalid-duplicate-field` lives in `StructFieldsCompileFail`. `Language/Syntax/Const` remains. Bleed from Casting is `ClassDeclarationCompileFail` and Overload `unary-index-and-conversion`. `codegen.py check` still reports missing/changed/stale generated units; author-tree parse has no protocol errors. Projection sync is 5.1.

## 4. Skill and specs

## [x] 4.1 Retarget the angelscript-test Skill and durable specs

Replace Skill examples that teach `AddRoot` + `Get(..., "root")`. Merge the Change spec deltas into current `code-database` and `language-fixtures` specs using the sync Skill after the deltas already in this Change are the accepted text.

**Outcome**

`.agents/skills/angelscript-test/SKILL.md` and `references/test-code-database.md` show `@begin`, parentless versions, Fail files, and `fields-two`. Current specs no longer require every Language file to have a `root` version. `cqtest.md` is untouched.

**Files**

```diff
 .agents/skills/angelscript-test/SKILL.md
 .agents/skills/angelscript-test/references/test-code-database.md
 openspec/specs/angelscript/testing/code-database/spec.md
 openspec/specs/angelscript/testing/language-fixtures/spec.md
 openspec/specs/angelscript/testing/code-database/knowledges/negative-script-vs-fixture-protocol.md
```

**Verification**

```powershell
Select-String -Path .agents/skills/angelscript-test/references/test-code-database.md,openspec/specs/angelscript/testing/language-fixtures/spec.md -Pattern 'exactly one node has no @parent|each root version are retrievable|Get\(TEXT\("Language/Syntax/StructFields"\), TEXT\("root"\)\)' | ForEach-Object { $_.Line }
```

Working directory is the workspace root. Complete when that command prints no lines. A labeled note that `AddRoot` is a deprecated alias may remain in the Skill.

**Evidence**

2026-09-17 workspace `d:\Workspace\AngelscriptProject`. `Select-String` on `test-code-database.md` and `language-fixtures/spec.md` printed no lines for the three stale root teachings. `harness.specs.write` published `angelscript/testing/code-database` and `language-fixtures`. `openspec.validate` `--type spec --strict` succeeded for both capabilities and for the Change. `AddRoot` remains documented as a deprecated alias.

## 5. Projections

## [x] 5.1 Regenerate Language projections and retarget Adoption

Run `codegen.py generate` for Language, update Framework tests that `Get` `StructFields` / `ClassCast` `root`, and drop stale `ClassCast.generated.cpp` outputs.

**Outcome**

`AdoptionTests`, `GeneratedSourcesTests`, and `LanguageFixtureCorpusTests` retrieve `fields-two` / Casting glossary FileTags. `Get(..., "root")` is not the Language representative. Generated Language units match author files.

**Interfaces**

Consumes `FAngelscriptTestCode::Get` as used in `AdoptionTests.cpp:41` and `GeneratedSourcesTests.cpp:48`. Produces updated assertions and new `.generated.cpp` paths under `TestCode/Generated/Language/`. Source: existing test identities `Angelscript.UnitTest.Framework`.

**Cases**

1. **AdoptionFieldsTwo** — new RED
   Given generated StructFields. When `Get("Language/Syntax/StructFields", "fields-two")` runs. Then it succeeds and `Get(..., "root")` is not required for that file.

2. **CorpusHasClassHandleCast** — new RED
   Given the admitted Language catalog. When FileTags are listed. Then `Language/Casting/ClassHandleCast` is present and `Language/Casting/ClassCast` is absent.

**Files**

```diff
 Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/Language/
 Plugins/Angelscript/Source/AngelscriptTest/FrameworkTests/AdoptionTests.cpp
 Plugins/Angelscript/Source/AngelscriptTest/FrameworkTests/GeneratedSourcesTests.cpp
 Plugins/Angelscript/Source/AngelscriptTest/FrameworkTests/LanguageFixtureCorpusTests.cpp
```

**Verification**

```powershell
Import-Module ./.agents/skills/harness/scripts/Harness.psd1
$context = New-HarnessContext -WorkspaceRoot (Get-Location).Path
python AngelscriptTestCode/CodeGenTool/codegen.py generate
python AngelscriptTestCode/CodeGenTool/codegen.py check
Invoke-Harness -Command ue.build -Context $context -Parameters @{ TimeoutMs = 1800000 }
Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.Framework.Adoption'; Fast = $true; TimeoutMs = 600000 }
Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.Framework.GeneratedSources'; Fast = $true; TimeoutMs = 600000 }
Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.Framework.LanguageFixtureCorpus'; Fast = $true; TimeoutMs = 600000 }
```

Working directory is the workspace root. Complete when generate+check exit 0 and the three prefixes pass.

**Evidence**

2026-09-17 workspace `d:\Workspace\AngelscriptProject`. `codegen.py generate` then `check` reported synchronized. `ue.build` succeeded. Adoption `3334d94d57b044468a1fa4986759b886` 4/4 including `AdoptionFieldsTwo`. GeneratedSources `b80fafec490548be9f6154da1e93ea1c` 4/4. LanguageFixtureCorpus `a0e512ef108a415f8a272f41918ea65d` 2/2 including `CorpusHasClassHandleCast` after collecting `downcast` / `null-guard`. Stale `ClassCast.generated.cpp` removed. Language projections use `AddVersion` / `fields-two`.
