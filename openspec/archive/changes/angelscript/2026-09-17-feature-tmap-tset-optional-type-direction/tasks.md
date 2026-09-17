---
task_graph:
  version: 1
  depends_on:
    "1.1": []
    "2.1": []
    "3.1": []
    "4.1": ["1.1", "2.1", "3.1"]
    "5.1": ["4.1"]
---

# Port TMap TSet TOptional type-axis and direction observations

## Goal

Hand-author TMap remaining, TSet, and TOptional observation leaves for TestSource-old Function type suffixes and UFUNCTION directions, then project and query them.

## Architecture

Existing local observes and admitted TMap `*In` stay. New siblings follow [attachments/drafts/glossary.md](attachments/drafts/glossary.md). Three author cards have no edges. Generate and corpus join after authors. See [design.md](design.md).

## Global constraints

- TMap, TSet, and TOptional only. Do not edit pointer trees, SoftObjectPath, Language, or Unreal.
- Hand-write every `.as`. Do not generate authors from scripts.
- Do not dump TestSource-old Advance, Negative, Reject, or misplaced TSet Function files.
- Do not rename admitted TMap `*In` FileTags.
- Observation names come from [attachments/drafts/glossary.md](attachments/drafts/glossary.md).
- Execution conventions: `.agents/skills/harness/references/execution-conventions.md`.

## File map

```diff
 AngelscriptTestCode/Containers/TMap/  # 1.1
 AngelscriptTestCode/Containers/TSet/  # 2.1
 AngelscriptTestCode/Containers/TOptional/  # 3.1
 AngelscriptTestCode/CodeGenTool/tests/  # 1.1–4.1
 Plugins/Angelscript/Source/AngelscriptTest/
   TestCode/Generated/Containers/  # 4.1
   FrameworkTests/HostApiFixtureCorpusTests.cpp  # 5.1
 openspec/specs/angelscript/testing/host-api-fixtures/  # 5.1
```

## Requirement coverage

| Requirement | Tasks |
|---|---|
| Query TMap FString Add and FillByAddPair | 1.1, 4.1, 5.1 |
| Query TSet FString Add and FillByAddElement | 2.1, 4.1, 5.1 |
| Query TOptional FString Set and FillBySetValue | 3.1, 4.1, 5.1 |
| Existing local observes remain | 1.1, 2.1, 3.1, 5.1 |
| TMap `ContainsKeyIn` remains | 1.1, 5.1 |
| Remaining Function type and direction leaves | 1.1, 2.1, 3.1, 4.1 |
| Pointer wrappers and SoftObjectPath unchanged | 1.1–3.1, 5.1 |

Self-review 2026-09-17: coverage maps the added three-tree requirement; placeholder scan clean; FileTags match the glossary. Record: attachments/data/planning-validation.md.

## 1. TMap

## [x] 1.1 Author TMap remaining type and direction files

Keep `AddPairInsertsKeyValue.as` and admitted `*In` leaves. Hand-write typed observes, `FillBy` / `Mutate` for subjects that already have `*In`, and full type-plus-direction sets for the remaining old Function subjects. Do not generate C++ here.

**Outcome**

`Containers/TMap/AddPairInsertsKeyValueFString` and `Containers/TMap/FillByAddPairInsertsKeyValue` parse as parentless `@begin` v1. Existing `AddPairInsertsKeyValue` and `ContainsKeyIn` still parse. Excluded: TSet, TOptional, pointer trees.

**Interfaces**

Consumes:

```
parse_source_file(source: SourceInput) -> ParsedFile  # container_parser.py:243
discover_sources(author_root: Path)                    # discovery.py:46
```

Produces:

```
Containers/TMap/AddPairInsertsKeyValueFString
Containers/TMap/FillByAddPairInsertsKeyValue
Containers/TMap/ReadAddPairInsertsKeyValue
Containers/TMap/MutateAddPairInsertsKeyValue
tests.test_tmap_type_direction
```

Source: [attachments/drafts/glossary.md](attachments/drafts/glossary.md) TMap table.

**Cases**

1. **AddPairFStringParses** — new RED
   Given `AngelscriptTestCode/Containers/TMap/AddPairInsertsKeyValueFString.as`. When `parse_source_file` runs. Then FileTag is `Containers/TMap/AddPairInsertsKeyValueFString`, one parentless version tagged `AddPairInsertsKeyValueFString` exists, and the clean source contains `TMap<FString` and `Add`.

2. **FillByAddPairParses** — new RED
   Given `AngelscriptTestCode/Containers/TMap/FillByAddPairInsertsKeyValue.as`. When `parse_source_file` runs. Then the entry is `FillByAddPairInsertsKeyValue` and the clean source contains `TMap<int32, int32>&out` or `TMap<int, int>&out`.

3. **ExistingAddPairControl** — existing control
   Given `AngelscriptTestCode/Containers/TMap/AddPairInsertsKeyValue.as`. When `parse_source_file` runs. Then FileTag remains `Containers/TMap/AddPairInsertsKeyValue` with version `AddPairInsertsKeyValue`.

4. **ExistingContainsKeyInControl** — existing control
   Given `AngelscriptTestCode/Containers/TMap/ContainsKeyIn.as`. When `parse_source_file` runs. Then version `ContainsKeyIn` remains and the clean source contains `&in`.

**Files**

```diff
+ AngelscriptTestCode/Containers/TMap/AddPairInsertsKeyValueFString.as
+ AngelscriptTestCode/Containers/TMap/ReadAddPairInsertsKeyValue.as
+ AngelscriptTestCode/Containers/TMap/FillByAddPairInsertsKeyValue.as
+ AngelscriptTestCode/Containers/TMap/MutateAddPairInsertsKeyValue.as
+ AngelscriptTestCode/Containers/TMap/FillByContainsKey.as
+ AngelscriptTestCode/Containers/TMap/MutateContainsKey.as
+ AngelscriptTestCode/Containers/TMap/FillByNumCountsPairs.as
+ AngelscriptTestCode/Containers/TMap/MutateNumCountsPairs.as
+ AngelscriptTestCode/Containers/TMap/FillByIndexAccessReadsStoredValue.as
+ AngelscriptTestCode/Containers/TMap/MutateIndexAccessReadsStoredValue.as
+ AngelscriptTestCode/CodeGenTool/tests/test_tmap_type_direction.py
```

Also hand-write the remaining TMap typed and direction siblings required by the twelve old Function subjects and the glossary. Do not recreate or rename `*In` files. Those extra leaves stay under `Containers/TMap/` and follow `<Stem><Type>` / `Read|FillBy|Mutate<Stem>` except where `*In` already exists.

**Verification**

```
python AngelscriptTestCode/CodeGenTool/tests/test_tmap_type_direction.py
```

Working directory: workspace root. PASS when all four cases execute and pass. The test inserts `CodeGenTool` on `sys.path` the same way `test_tarray_add_type_direction.py` does.

**Evidence**

- RED `python AngelscriptTestCode/CodeGenTool/tests/test_tmap_type_direction.py`: AddPairFStringParses / FillByAddPairParses FileNotFound. ExistingAddPairControl and ExistingContainsKeyInControl green. `FAILED (errors=2)`.
- GREEN same command (coordinator re-run): 4/4 OK. 340 new authors; 225 typed-direction leaves. `AddPairInsertsKeyValueFString` constructs `TMap<FString, int>` and calls `Add`. `FillByAddPairInsertsKeyValue` declares `TMap<int, int>&out`. `ContainsKeyIn` still `const TMap<int, int>&in`.
- Naming assumed: remaining `<Stem><Type>` / `Read|FillBy|Mutate<Stem>` / typed directions; IndexAccess FillBy/Mutate keep `IndexAccessReadsStoredValue` / shorter `IndexAccess<Type>` to match existing `*In`. No `Read*` where `*In` exists.

## 2. TSet

## [x] 2.1 Author TSet type and direction files

Keep `AddElementIsContained.as` and `EmptyConstructionFName.as`. Hand-write typed observes and three-direction sets from the nine real old Function subjects. Skip Physics / Input misplaced files.

**Outcome**

`Containers/TSet/AddElementIsContainedFString` and `Containers/TSet/FillByAddElementIsContained` parse. Existing `AddElementIsContained` still parses. Excluded: TMap, TOptional, misplaced TSet Function files.

**Interfaces**

Consumes:

```
parse_source_file(source: SourceInput) -> ParsedFile  # container_parser.py:243
```

Produces:

```
Containers/TSet/AddElementIsContainedFString
Containers/TSet/FillByAddElementIsContained
Containers/TSet/ReadAddElementIsContained
Containers/TSet/MutateAddElementIsContained
tests.test_tset_type_direction
```

Source: [attachments/drafts/glossary.md](attachments/drafts/glossary.md) TSet table.

**Cases**

1. **AddElementFStringParses** — new RED
   Given `AngelscriptTestCode/Containers/TSet/AddElementIsContainedFString.as`. When `parse_source_file` runs. Then FileTag is `Containers/TSet/AddElementIsContainedFString` and the clean source contains `TSet<FString>` and `Add`.

2. **FillByAddElementParses** — new RED
   Given `AngelscriptTestCode/Containers/TSet/FillByAddElementIsContained.as`. When `parse_source_file` runs. Then the entry is `FillByAddElementIsContained` and the clean source contains `TSet<int32>&out` or `TSet<int>&out`.

3. **ExistingAddElementControl** — existing control
   Given `AngelscriptTestCode/Containers/TSet/AddElementIsContained.as`. When `parse_source_file` runs. Then version `AddElementIsContained` remains.

**Files**

```diff
+ AngelscriptTestCode/Containers/TSet/AddElementIsContainedFString.as
+ AngelscriptTestCode/Containers/TSet/ReadAddElementIsContained.as
+ AngelscriptTestCode/Containers/TSet/FillByAddElementIsContained.as
+ AngelscriptTestCode/Containers/TSet/MutateAddElementIsContained.as
+ AngelscriptTestCode/Containers/TSet/EmptyConstructionFString.as
+ AngelscriptTestCode/CodeGenTool/tests/test_tset_type_direction.py
```

Also hand-write the remaining TSet typed and direction siblings required by the nine real Function files. Do not recreate `EmptyConstructionFName.as`. EmptyConstruction gets type observes only.

**Verification**

```
python AngelscriptTestCode/CodeGenTool/tests/test_tset_type_direction.py
```

Working directory: workspace root. PASS when all three cases execute and pass.

**Evidence**

- RED `python AngelscriptTestCode/CodeGenTool/tests/test_tset_type_direction.py`: AddElementFStringParses / FillByAddElementParses FileNotFound. ExistingAddElementControl green. `FAILED (errors=2)`.
- GREEN same command (coordinator re-run): 3/3 OK after authors. Later typed-direction backfill: 180 `Read|FillBy|Mutate<Stem><Type>` leaves (top-level 308). `ReadAddElementIsContainedFString` is `const TSet<FString>&in`; `FillByAddElementIsContainedFString` is `TSet<FString>&out`; `MutateAddElementIsContainedFString` is `TSet<FString>&inout`. EmptyConstruction stays typed-observe only.
- Naming assumed: remaining `<Stem><Type>` / `Read|FillBy|Mutate<Stem>` / `Read|FillBy|Mutate<Stem><Type>` — glossary and TArray typed-direction convention.

## 3. TOptional

## [x] 3.1 Author TOptional type and direction files

Keep `SetValue.as`. Hand-write typed observes and three-direction sets from the seven old Function subjects.

**Outcome**

`Containers/TOptional/SetValueFString` and `Containers/TOptional/FillBySetValue` parse. Existing `SetValue` still parses. Excluded: TMap, TSet, pointer trees.

**Interfaces**

Consumes:

```
parse_source_file(source: SourceInput) -> ParsedFile  # container_parser.py:243
```

Produces:

```
Containers/TOptional/SetValueFString
Containers/TOptional/FillBySetValue
Containers/TOptional/ReadSetValue
Containers/TOptional/MutateSetValue
tests.test_toptional_type_direction
```

Source: [attachments/drafts/glossary.md](attachments/drafts/glossary.md) TOptional table.

**Cases**

1. **SetValueFStringParses** — new RED
   Given `AngelscriptTestCode/Containers/TOptional/SetValueFString.as`. When `parse_source_file` runs. Then FileTag is `Containers/TOptional/SetValueFString` and the clean source contains `TOptional<FString>` and `Set`.

2. **FillBySetValueParses** — new RED
   Given `AngelscriptTestCode/Containers/TOptional/FillBySetValue.as`. When `parse_source_file` runs. Then the entry is `FillBySetValue` and the clean source contains `TOptional<int32>&out` or `TOptional<int>&out`.

3. **ExistingSetValueControl** — existing control
   Given `AngelscriptTestCode/Containers/TOptional/SetValue.as`. When `parse_source_file` runs. Then version `SetValue` remains.

**Files**

```diff
+ AngelscriptTestCode/Containers/TOptional/SetValueFString.as
+ AngelscriptTestCode/Containers/TOptional/ReadSetValue.as
+ AngelscriptTestCode/Containers/TOptional/FillBySetValue.as
+ AngelscriptTestCode/Containers/TOptional/MutateSetValue.as
+ AngelscriptTestCode/Containers/TOptional/EmptyConstructionFString.as
+ AngelscriptTestCode/CodeGenTool/tests/test_toptional_type_direction.py
```

Also hand-write the remaining TOptional typed and direction siblings required by the seven Function files. EmptyConstruction gets type observes only.

**Verification**

```
python AngelscriptTestCode/CodeGenTool/tests/test_toptional_type_direction.py
```

Working directory: workspace root. PASS when all three cases execute and pass.

**Evidence**

- RED `python AngelscriptTestCode/CodeGenTool/tests/test_toptional_type_direction.py`: SetValueFStringParses / FillBySetValueParses FileNotFound. ExistingSetValueControl green. `FAILED (errors=2)`.
- GREEN same command (coordinator re-run): 3/3 OK. 143 new authors; 90 typed-direction leaves including `ReadSetValueFString` (`const TOptional<FString>&in`). `SetValueFString` has `TOptional<FString>` + `Set`. `FillBySetValue` has `TOptional<int32>&out`.
- Naming assumed: remaining `<Stem><Type>` / `Read|FillBy|Mutate<Stem>` / `Read|FillBy|Mutate<Stem><Type>` — glossary pattern. EmptyConstruction types only.

## 4. Projections

## [x] 4.1 Generate TMap TSet TOptional type and direction units

Run the existing generator so every new author file has a signed projection. Identity still requires stem = `@begin` = entry.

**Outcome**

`codegen.py check` reports synchronized projections. `test_container_observation_identity.py` still passes. No method-alias stems were introduced.

**Interfaces**

Consumes:

```
discover_sources(author_root: Path)  # discovery.py:46
```

Produces:

```
AddPairInsertsKeyValueFString.generated.cpp
AddElementIsContainedFString.generated.cpp
SetValueFString.generated.cpp
```

Source: existing `codegen.py generate` / `check` convention from the TArray Change.

**Cases**

1. **IdentityStillHolds** — existing control
   Given the new author files. When `test_container_observation_identity.py` runs. Then it exits 0.

2. **ProjectionsSynchronized** — new RED
   Given generate has written the representative `.generated.cpp` files. When `codegen.py check` runs. Then it reports synchronized projections.

**Files**

```diff
+ Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/Containers/TMap/AddPairInsertsKeyValueFString.generated.cpp
+ Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/Containers/TMap/FillByAddPairInsertsKeyValue.generated.cpp
+ Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/Containers/TSet/AddElementIsContainedFString.generated.cpp
+ Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/Containers/TOptional/SetValueFString.generated.cpp
```

Only signed Generated units owned by the new authors. Other Generated trees stay out.

**Verification**

```
python AngelscriptTestCode/CodeGenTool/tests/test_container_observation_identity.py && python AngelscriptTestCode/CodeGenTool/codegen.py check
```

Working directory: workspace root. PASS when identity exits 0 and check exits 0 after generate. Document-only check is not enough if generate was skipped.

### Evidence

```
=== 4.1 RED identity+check before generate ===
identity 2/2 OK
missing: Containers/TMap/AddPairInsertsKeyValueFString.generated.cpp
stale: Containers/TSet/EmptyConstructionFName.generated.cpp
check_exit=1
Generate not yet run.

=== 4.1 GREEN after generate ===
python AngelscriptTestCode/CodeGenTool/codegen.py generate
generate_exit=0
python AngelscriptTestCode/CodeGenTool/tests/test_container_observation_identity.py
Ran 2 tests in 0.867s OK identity_exit=0
python AngelscriptTestCode/CodeGenTool/codegen.py check
check_exit=0
Files present:
Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/Containers/TMap/AddPairInsertsKeyValueFString.generated.cpp
Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/Containers/TMap/FillByAddPairInsertsKeyValue.generated.cpp
Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/Containers/TSet/AddElementIsContainedFString.generated.cpp
Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/Containers/TOptional/SetValueFString.generated.cpp
```

## 5. Spec and corpus

## [x] 5.1 Publish type and direction FileTags in spec and corpus

Update current host-api-fixtures and `HostApiFixtureCorpus` so `Get` of the six representative FileTags succeeds. Keep the TArray type-and-direction controls and TMap `ContainsKeyIn`.

**Outcome**

Current spec names the three-tree type-and-direction requirement. `CorpusHasTMapTSetOptionalTypeAndDirection` finds the six FileTags. Existing TArray and `ContainsKeyIn` Gets still hold.

**Interfaces**

Consumes:

```
FAngelscriptTestCode::Get(FStringView FileTag, FStringView VersionTag)  # AngelscriptTestCode.h:26
```

Produces:

```
TEST_METHOD(CorpusHasTMapTSetOptionalTypeAndDirection)
```

Source: this card; neighbor methods in `HostApiFixtureCorpusTests.cpp`. Naming assumed at planning: method name follows `CorpusHasTArrayTypeAndDirection`.

**Cases**

1. **CorpusHasTMapTSetOptionalTypeAndDirection** — new RED
   Given an activated database after 4.1 projections compile. When `Get` is called with the six FileTags named in the spec scenario. Then all six Gets succeed.

2. **CorpusHasTArrayTypeAndDirection** — existing control
   Given the same binary. When `Get(Containers/TArray/AddAndOrderFString, AddAndOrderFString)` runs. Then it succeeds.

3. **ContainsKeyInRemains** — existing control
   Given the same binary. When `Get(Containers/TMap/ContainsKeyIn, ContainsKeyIn)` runs. Then it succeeds.

**Files**

```diff
  Plugins/Angelscript/Source/AngelscriptTest/FrameworkTests/HostApiFixtureCorpusTests.cpp
  openspec/specs/angelscript/testing/host-api-fixtures/spec.md
  openspec/changes/angelscript/feature-tmap-tset-optional-type-direction/specs/angelscript/testing/host-api-fixtures/spec.md
```

**Verification**

```
pwsh -NoProfile -Command "Import-Module ./.agents/skills/harness/scripts/Harness.psd1; $c = New-HarnessContext -WorkspaceRoot (Get-Location).Path; Invoke-Harness -Command ue.test -Context $c -Parameters @{ TestPrefix = 'Angelscript.UnitTest.Framework.HostApiFixtureCorpus'; Fast = $true }"
```

Working directory: workspace root. Build first per execution conventions. PASS when the prefix methods run and `CorpusHasTMapTSetOptionalTypeAndDirection` is among them.

### Evidence

```
=== 5.1 spec write ===
harness.specs.write spec=angelscript/testing/host-api-fixtures
sha256=13c298d5dac81dfdf7862688b7df5bd27db8e5160af20b03d0f5f3dac4b44b33 then blank-line fix Succeeded
Requirement added: TMap TSet TOptional Function type and direction observations

=== 5.1 ue.build ===
RunId=f7f40ec404f84d64b76e4c64fc3cf6f4
State=Succeeded ExitCode=0 DurationMs=60189
Label=AngelscriptProjectEditor

=== 5.1 GREEN HostApiFixtureCorpus Fast ===
RunId=db6568d4a4a142469626c515ddb2d828
Summary.json Outcome=Passed Complete=true Total=6 Succeeded=6 Failed=0 NotRun=0 InProcess=0
Angelscript.UnitTest.Framework.HostApiFixtureCorpus.CorpusHasTMapTSetOptionalTypeAndDirection Success
Angelscript.UnitTest.Framework.HostApiFixtureCorpus.CorpusHasTArrayTypeAndDirection Success
Angelscript.UnitTest.Framework.HostApiFixtureCorpus.CorpusHasTArrayAddAndOrder Success
Angelscript.UnitTest.Framework.HostApiFixtureCorpus.CorpusHasTArrayPrefix Success
Angelscript.UnitTest.Framework.HostApiFixtureCorpus.CorpusHasPendingMathFunctionIn Success
Angelscript.UnitTest.Framework.HostApiFixtureCorpus.LanguageTopicOmitsHostApi Success
ContainsKeyInRemains covered inside CorpusHasTMapTSetOptionalTypeAndDirection via Get(Containers/TMap/ContainsKeyIn, ContainsKeyIn)

Omitted: Quick, Performance, Integration, full Automation. Reason: proving selector is HostApiFixtureCorpus Fast; no adjacent failure.
```
