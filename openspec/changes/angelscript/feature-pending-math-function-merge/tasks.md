---
task_graph:
  version: 1
  depends_on:
    "1.1": []
    "2.1": ["1.1"]
    "3.1": ["2.1"]
    "4.1": ["2.1"]
---

# Complete Pending/Math Function program merge

## Goal

Admit the 30 leftover Pending/Math Function programs onto the existing Unreal type pockets.

## Architecture

Append parentless `@begin` cases to `Unreal/FVector`, `FVector2D`, `FTransform`, `FRotator`, and `FLinearColor`. CodeGen already discovers those files. See [design.md](design.md).

## Global constraints

- Do not create `AngelscriptTestCode/Math/`.
- Do not edit FQuat, Unreal first-batch Casting/World, or Language.
- Destination FileTags are the existing Unreal type pockets from archived host-api-fixtures.
- Execution conventions: `.agents/skills/harness/references/execution-conventions.md`.

## File map

```diff
 AngelscriptTestCode/Unreal/  # 1.1
 AngelscriptTestCode/CodeGenTool/tests/test_pending_math_authors.py  # 1.1
 Plugins/Angelscript/Source/AngelscriptTest/
   TestCode/Generated/Unreal/  # 2.1
   FrameworkTests/HostApiFixtureCorpusTests.cpp  # 4.1
 openspec/specs/angelscript/testing/host-api-fixtures/  # 3.1
```

## Requirement coverage

| Requirement | Tasks |
|---|---|
| Function programs on Unreal type FileTags | 1.1, 2.1, 4.1 |
| host-api-fixtures Math merge text | 3.1 |
| Pending is not the admitted source | 1.1 |

Self-review 2026-09-17: coverage maps every delta requirement; placeholder scan clean; symbols match existing Unreal type FileTags. Record: attachments/data/planning-validation.md.

## 1. Authors

## [x] 1.1 Author leftover Pending/Math Function cases

Rewrite the 30 Function* files into the five existing Unreal type pockets as parentless `@begin` cases. Do not generate C++ here.

**Outcome**

Each leftover Pending/Math Function file has a kebab-stem version on `Unreal/<Type>`. Pending copies are not admitted sources. FQuat is unchanged.

**Interfaces**

Consumes:

```
parse_source_file(source: SourceInput) -> ParsedFile  # container_parser.py:243
discover_sources(author_root: Path)                    # discovery.py:46
```

Produces:

```
Unreal/FVector Unreal/FVector2D Unreal/FTransform
Unreal/FRotator Unreal/FLinearColor
tests.test_pending_math_authors
```

Source: existing FileTags from archived host-api-fixtures; version tags are kebab Pending stems.

**Cases**

1. **FunctionParametersInParses** — new RED
   Given `Unreal/FVector.as`. When `parse_source_file` runs. Then a parentless version tagged `function-parameters-in` exists and its clean source contains `&in`.

2. **AllThirtyStemsPresent** — new RED
   Given the five Unreal type authors. When version tags are collected. Then each of the 30 leftover stems is present on its type FileTag.

3. **DiscoverySkipsPendingMath** — existing control
   Given `Pending/Math/FVector/FunctionParametersIn.as` still on disk. When `discover_sources` runs. Then that Pending path is absent and `Unreal/FVector.as` is present.

**Files**

```diff
 AngelscriptTestCode/Unreal/FVector.as
 AngelscriptTestCode/Unreal/FVector2D.as
 AngelscriptTestCode/Unreal/FTransform.as
 AngelscriptTestCode/Unreal/FRotator.as
 AngelscriptTestCode/Unreal/FLinearColor.as
 AngelscriptTestCode/CodeGenTool/tests/test_pending_math_authors.py
```

Does not include Generated C++ or FQuat.

**Verification**

```
python AngelscriptTestCode/CodeGenTool/tests/test_pending_math_authors.py
```

Working directory: workspace root. PASS when all three cases execute and pass. The test file inserts `CodeGenTool` on `sys.path` the same way `test_discovery.py` does.

**Evidence**

- RED `python AngelscriptTestCode/CodeGenTool/tests/test_pending_math_authors.py`: FunctionParametersInParses and AllThirtyStemsPresent missing all 30 kebab stems. DiscoverySkipsPendingMath already green.
- GREEN same command: 3/3 OK. `Unreal/FVector` has parentless `function-parameters-in` containing `&in`. All 30 leftover stems present. Pending Math path is not discovered.
- Naming assumed: none.

## 2. Projections

## [x] 2.1 Generate the five thickened Unreal math pockets

Run the existing generator so the five author files have matching signed projections.

**Outcome**

`codegen.py check` reports the five FileTags synchronized. No Pending/Math path is projected.

**Files**

```diff
 Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/Unreal/FVector.generated.cpp
 Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/Unreal/FVector2D.generated.cpp
 Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/Unreal/FTransform.generated.cpp
 Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/Unreal/FRotator.generated.cpp
 Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/Unreal/FLinearColor.generated.cpp
```

Only these signed generated units among the Change-owned projections.

**Verification**

```
python AngelscriptTestCode/CodeGenTool/codegen.py check
```

Working directory: workspace root. PASS when the command exits 0 after generate. Document-only check is not enough if generate was skipped.

**Evidence**

- RED `python AngelscriptTestCode/CodeGenTool/codegen.py check`: changed Unreal/FLinearColor.generated.cpp, FRotator, FTransform, FVector, FVector2D.
- GREEN same command after `codegen.py generate`: "Test-code generated projections are synchronized." `Unreal/FVector.generated.cpp` contains Tag `function-parameters-in`. No Pending/Math path is projected.
- Naming assumed: none.

## 3. Records

## [x] 3.1 Record the completed Pending/Math Function merge

Update the current host-api-fixtures spec so the Math merge includes Function parameter and return programs.

**Outcome**

Current `host-api-fixtures` spec names `function-parameters-in` on `Unreal/FVector`.

**Files**

```diff
 openspec/specs/angelscript/testing/host-api-fixtures/spec.md
 openspec/specs/angelscript/testing/host-api-fixtures/spec.yaml
```

**Verification**

```
Select-String -Path openspec/specs/angelscript/testing/host-api-fixtures/spec.md -Pattern 'function-parameters-in'
```

Working directory: workspace root. PASS when the current spec contains `function-parameters-in`.

**Evidence**

- GREEN `Select-String -Path openspec/specs/angelscript/testing/host-api-fixtures/spec.md -Pattern 'function-parameters-in'`: matched the new scenario WHEN and Inputs. `harness.specs.write` Succeeded sha256 `fe7f67dbb93ded9bd7bce8ff3a0ca9dbcaaef0df1c1143a2a87f294693dff2e3`. `openspec validate angelscript/testing/host-api-fixtures --type spec --strict` PASS.
- Naming assumed: none.

## 4. Corpus

## [x] 4.1 Corpus can Get the FVector Function in-parameter case

Add a Framework method that `Get`s `Unreal/FVector` / `function-parameters-in` and does not use `root`.

**Outcome**

`CorpusHasPendingMathFunctionIn` succeeds. `Get(Unreal/FVector, root)` is not the representative lookup.

**Interfaces**

Consumes:

```
FAngelscriptTestCode::Get  # AngelscriptTestCode.h:26
```

Produces:

```
TEST_METHOD CorpusHasPendingMathFunctionIn
```

Source: existing class `HostApiFixtureCorpus` in `HostApiFixtureCorpusTests.cpp:7`. Method name from this card.

**Cases**

1. **CorpusHasPendingMathFunctionIn** — new RED
   Given an activated database after 2.1. When `Get(Unreal/FVector, function-parameters-in)` runs. Then the result is success and the source bytes contain `&in`.

2. **CorpusStillHasFMath** — existing control
   Given `FindFiles({Unreal})`. When Tags are inspected. Then `Unreal/FMath` is present.

**Files**

```diff
 Plugins/Angelscript/Source/AngelscriptTest/FrameworkTests/HostApiFixtureCorpusTests.cpp
```

**Verification**

```
Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.Framework.HostApiFixtureCorpus'; Fast = $true; TimeoutMs = 600000 }
```

Working directory: workspace root. Build first per execution conventions. PASS when the new method and the existing FMath method run.

**Evidence**

- RED `ue.test` prefix `Angelscript.UnitTest.Framework.HostApiFixtureCorpus` run `6da3a5fb218542c7a97c3480ec24c821`: `CorpusHasPendingMathFunctionIn` Success; `CorpusHasTArrayAndFMath` Fail at `bHasTArray` because `Generated/Containers` had been deleted to avoid an earlier C4883. `Get(Unreal/FVector, function-parameters-in)` already succeeded.
- GREEN after restoring `AngelscriptTestCode/Containers` and regenerating those projections: `ue.build` run `663810e674c144dc9d06d1945d76e428` Succeeded; `ue.test` run `2d1083c9810b4db690b3e69705ca8a64` Outcome Passed, 3/3 including `CorpusHasPendingMathFunctionIn` and `CorpusHasTArrayAndFMath`. `Get(Unreal/FVector, root)` is not the representative lookup.
- Naming assumed: none.
