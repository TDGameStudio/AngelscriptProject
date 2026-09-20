---
task_graph:
  version: 1
  depends_on:
    "1.1": []
    "2.1": []
    "3.1": []
    "4.1": []
    "5.1": []
    "6.1": []
    "7.1": []
    "8.1": []
    "9.1": []
    "10.1": ["1.1", "2.1", "3.1", "4.1", "5.1", "6.1", "7.1", "8.1", "9.1"]
    "11.1": ["10.1"]
---

# Rewrite container fixtures into type directories

## Goal

Replace flat container pockets with per-type observation directories, project them, and publish prefix FileTags.

## Architecture

CodeGen already discovers any non-Pending `.as`. This Change deletes `Containers/<Type>.as` and hand-writes `Containers/<Type>/<Observation>.as`. Nine author tasks have no edges. See [design.md](design.md).

## Global constraints

- Do not edit Language, Unreal first-batch, or create `Math/`.
- Do not dump Pending or generate `.as` from scripts.
- Observation names come from [attachments/drafts/glossary.md](attachments/drafts/glossary.md) and [attachments/drafts/findings/per-type-trees.md](attachments/drafts/findings/per-type-trees.md).
- Execution conventions: `.agents/skills/harness/references/execution-conventions.md`.

## File map

```diff
 AngelscriptTestCode/Containers/  # 1.1–9.1
 AngelscriptTestCode/CodeGenTool/tests/  # 1.1–9.1
 Plugins/Angelscript/Source/AngelscriptTest/
   TestCode/Generated/Containers/  # 10.1
   FrameworkTests/HostApiFixtureCorpusTests.cpp  # 11.1
 openspec/specs/angelscript/testing/host-api-fixtures/  # 11.1
```

## Requirement coverage

| Requirement | Tasks |
|---|---|
| Observation FileTags under `Containers/<Type>/` | 1.1–9.1, 10.1, 11.1 |
| Query `Containers/TArray/AddAndOrder` | 1.1, 10.1, 11.1 |
| Flat `Containers/TArray` retired | 1.1, 11.1 |
| Fail polarity follows Bind Throw | 1.1, 2.1, 4.1, 5.1, 7.1 |
| Pending is not the admitted source | 1.1–9.1 |

Self-review 2026-09-17: coverage maps the delta inventory requirement; placeholder scan clean; FileTags match the glossary. Record: attachments/data/planning-validation.md.

## 1. TArray

## [x] 1.1 Author TArray observation files

Delete the three flat TArray pockets. Hand-write the TArray tree from [target-layout.md](attachments/drafts/findings/target-layout.md). Do not generate C++ here.

**Outcome**

`Containers/TArray/AddAndOrder` and `Containers/TArray/EmptyConstruction` parse as parentless `@begin` v1. Flat `Containers/TArray.as` is gone. Pending TArray paths stay undiscovered. Excluded: TMap and other type directories.

**Interfaces**

Consumes:

```
parse_source_file(source: SourceInput) -> ParsedFile  # container_parser.py:243
discover_sources(author_root: Path)                    # discovery.py:46
```

Produces:

```
Containers/TArray/AddAndOrder
Containers/TArray/EmptyConstruction
Containers/TArray/RuntimeFail/InsertIndexPastNum
tests.test_tarray_directory_authors
```

Source: [glossary.md](attachments/drafts/glossary.md).

**Cases**

1. **AddAndOrderParses** — new RED
   Given `AngelscriptTestCode/Containers/TArray/AddAndOrder.as`. When `parse_source_file` runs. Then FileTag is `Containers/TArray/AddAndOrder`, format is `v1`, one parentless version tagged `AddAndOrder` exists, and the clean source contains `Values.Add`.

2. **EmptyConstructionRenamed** — new RED
   Given the TArray author tree. When version tags are collected. Then `EmptyConstruction` is present and no version tag equals `array`.

3. **FlatTArrayAbsent** — new RED
   Given `discover_sources` on `AngelscriptTestCode`. When FileTags are collected. Then `Containers/TArray` is absent and `Containers/TArray/AddAndOrder` is present.

4. **DiscoverySkipsPendingTArray** — existing control
   Given `Pending/Containers/TArray/TArrayAddAndOrder.as` still on disk. When `discover_sources` runs. Then that Pending path is absent.

**Files**

```diff
- AngelscriptTestCode/Containers/TArray.as
- AngelscriptTestCode/Containers/TArrayCompileFail.as
- AngelscriptTestCode/Containers/TArrayRuntimeFail.as
+ AngelscriptTestCode/Containers/TArray/
+ AngelscriptTestCode/CodeGenTool/tests/test_tarray_directory_authors.py
```

Does not include Generated C++ or other type directories.

**Verification**

```
python AngelscriptTestCode/CodeGenTool/tests/test_tarray_directory_authors.py
```

Working directory: workspace root. PASS when all four cases execute and pass. The test inserts `CodeGenTool` on `sys.path` the same way `test_discovery.py` does.

**Evidence**

- RED `python AngelscriptTestCode/CodeGenTool/tests/test_tarray_directory_authors.py`: AddAndOrderParses FileNotFound `AddAndOrder.as`; EmptyConstructionRenamed missing `EmptyConstruction`; FlatTArrayAbsent still saw `Containers/TArray`. DiscoverySkipsPendingTArray already green.
- GREEN same command (coordinator re-run): 4/4 OK in 0.412s. Flat `TArray.as` / `TArrayCompileFail.as` / `TArrayRuntimeFail.as` gone. 98 observation files (53 + 18 CompileFail + 27 RuntimeFail) including `AddAndOrder`, `EmptyConstruction`, `RuntimeFail/InsertIndexPastNum`. Pending TArray path stays undiscovered.
- Naming assumed: none.

## 2. TMap

## [x] 2.1 Author TMap observation files

Delete the three flat TMap pockets. Split the dump blocks into observation files from [per-type-trees.md](attachments/drafts/findings/per-type-trees.md). Do not generate C++ here.

**Outcome**

`Containers/TMap/ContainsKey` parses. `contains-contains` is gone. Missing-key index is `RuntimeFail/IndexMissingKey`. Excluded: TArray files.

**Interfaces**

Consumes:

```
parse_source_file(source: SourceInput) -> ParsedFile  # container_parser.py:243
discover_sources(author_root: Path)                    # discovery.py:46
```

Produces:

```
Containers/TMap/ContainsKey
Containers/TMap/RuntimeFail/IndexMissingKey
tests.test_tmap_directory_authors
```

Source: [glossary.md](attachments/drafts/glossary.md).

**Cases**

1. **ContainsKeyParses** — new RED
   Given `AngelscriptTestCode/Containers/TMap/ContainsKey.as`. When `parse_source_file` runs. Then FileTag is `Containers/TMap/ContainsKey` and one parentless version tagged `ContainsKey` exists.

2. **DumpTagAbsent** — new RED
   Given the TMap author tree. When version tags are collected. Then `contains-contains` is absent.

3. **FlatTMapAbsent** — new RED
   Given `discover_sources`. When FileTags are collected. Then `Containers/TMap` is absent and `Containers/TMap/ContainsKey` is present.

**Files**

```diff
- AngelscriptTestCode/Containers/TMap.as
- AngelscriptTestCode/Containers/TMapCompileFail.as
- AngelscriptTestCode/Containers/TMapRuntimeFail.as
+ AngelscriptTestCode/Containers/TMap/
+ AngelscriptTestCode/CodeGenTool/tests/test_tmap_directory_authors.py
```

**Verification**

```
python AngelscriptTestCode/CodeGenTool/tests/test_tmap_directory_authors.py
```

Working directory: workspace root. PASS when all three cases execute and pass.

**Evidence**

- RED `python AngelscriptTestCode/CodeGenTool/tests/test_tmap_directory_authors.py`: ContainsKeyParses FileNotFound `ContainsKey.as`; DumpTagAbsent still saw `contains-contains`; FlatTMapAbsent still saw `Containers/TMap`. `FAILED (failures=2, errors=1)`.
- GREEN same command (coordinator re-run): 3/3 OK in 0.419s. Flat `TMap.as` / `TMapCompileFail.as` / `TMapRuntimeFail.as` gone. 96 observation files (70 + 20 CompileFail + 6 RuntimeFail). Missing-key `[]` is `RuntimeFail/IndexMissingKey` (throws, no default-insert).
- Naming assumed: type-axis dumps `ContainsKeyFString` / `IndexAccess*` / `NumCountsPairs*` and `&in` `*In` siblings. Iterator-without-Proceed leaves live under RuntimeFail because Bind throws `Iterator out of bounds.`

## 3. TSet

## [x] 3.1 Author TSet observation files

Delete the three flat TSet pockets. Hand-write the TSet tree. Keep non-TSet Pending files out. Do not generate C++ here.

**Outcome**

`Containers/TSet/AddDuplicateIgnored` parses. Flat `Containers/TSet` is gone. Excluded: InputSettings Pending files.

**Interfaces**

Consumes:

```
parse_source_file(source: SourceInput) -> ParsedFile  # container_parser.py:243
discover_sources(author_root: Path)                    # discovery.py:46
```

Produces:

```
Containers/TSet/AddDuplicateIgnored
tests.test_tset_directory_authors
```

Source: [glossary.md](attachments/drafts/glossary.md).

**Cases**

1. **AddDuplicateIgnoredParses** — new RED
   Given `AngelscriptTestCode/Containers/TSet/AddDuplicateIgnored.as`. When `parse_source_file` runs. Then FileTag is `Containers/TSet/AddDuplicateIgnored` and one parentless version tagged `AddDuplicateIgnored` exists.

2. **FlatTSetAbsent** — new RED
   Given `discover_sources`. When FileTags are collected. Then `Containers/TSet` is absent and `Containers/TSet/AddDuplicateIgnored` is present.

**Files**

```diff
- AngelscriptTestCode/Containers/TSet.as
- AngelscriptTestCode/Containers/TSetCompileFail.as
- AngelscriptTestCode/Containers/TSetRuntimeFail.as
+ AngelscriptTestCode/Containers/TSet/
+ AngelscriptTestCode/CodeGenTool/tests/test_tset_directory_authors.py
```

**Verification**

```
python AngelscriptTestCode/CodeGenTool/tests/test_tset_directory_authors.py
```

Working directory: workspace root. PASS when both cases execute and pass.

**Evidence**

- RED `python AngelscriptTestCode/CodeGenTool/tests/test_tset_directory_authors.py`: AddDuplicateIgnoredParses missing `Containers/TSet/AddDuplicateIgnored.as`; FlatTSetAbsent still saw `Containers/TSet`. `FAILED (failures=2)`.
- GREEN same command (coordinator re-run): 2/2 OK in 0.195s. Flat `TSet.as` / `TSetCompileFail.as` / `TSetRuntimeFail.as` gone. 46 observation files (28 + 16 CompileFail + 2 RuntimeFail). Duplicate Add keeps Num at 1.
- Naming assumed: none. `EmptyReservedSlack` uses tree name; body observes `Empty(Slack)` then a later Add because Max is unbound.

## 4. TOptional

## [x] 4.1 Author TOptional observation files

Delete the three flat TOptional pockets. Hand-write the optional-value tree, including `StoredZeroIsSet` and `GetValueUnset`. Do not generate C++ here.

**Outcome**

`Containers/TOptional/StoredZeroIsSet` and `RuntimeFail/GetValueUnset` parse. Flat `Containers/TOptional` is gone.

**Interfaces**

Consumes:

```
parse_source_file(source: SourceInput) -> ParsedFile  # container_parser.py:243
discover_sources(author_root: Path)                    # discovery.py:46
```

Produces:

```
Containers/TOptional/StoredZeroIsSet
Containers/TOptional/RuntimeFail/GetValueUnset
tests.test_toptional_directory_authors
```

Source: [glossary.md](attachments/drafts/glossary.md).

**Cases**

1. **StoredZeroIsSetParses** — new RED
   Given `AngelscriptTestCode/Containers/TOptional/StoredZeroIsSet.as`. When `parse_source_file` runs. Then FileTag is `Containers/TOptional/StoredZeroIsSet` and the body observes a stored zero as set.

2. **FlatTOptionalAbsent** — new RED
   Given `discover_sources`. When FileTags are collected. Then `Containers/TOptional` is absent.

**Files**

```diff
- AngelscriptTestCode/Containers/TOptional.as
- AngelscriptTestCode/Containers/TOptionalCompileFail.as
- AngelscriptTestCode/Containers/TOptionalRuntimeFail.as
+ AngelscriptTestCode/Containers/TOptional/
+ AngelscriptTestCode/CodeGenTool/tests/test_toptional_directory_authors.py
```

**Verification**

```
python AngelscriptTestCode/CodeGenTool/tests/test_toptional_directory_authors.py
```

Working directory: workspace root. PASS when both cases execute and pass.

**Evidence**

- RED `python AngelscriptTestCode/CodeGenTool/tests/test_toptional_directory_authors.py`: StoredZeroIsSetParses missing FileTag `Containers/TOptional/StoredZeroIsSet`; FlatTOptionalAbsent still saw `Containers/TOptional`. `FAILED (failures=2)`.
- GREEN same command (coordinator re-run): 2/2 OK in 0.351s. Flat `TOptional.as` / `TOptionalCompileFail.as` / `TOptionalRuntimeFail.as` gone. 27 observation files (16 + 8 CompileFail + 3 RuntimeFail) including `StoredZeroIsSet` (`Set(0)` / `IsSet`) and `RuntimeFail/GetValueUnset`.
- Naming assumed: `UTOptionalPropertyHolder`, `UTOptionalPropertySetAndResetHolder`, `UTOptionalPropertyPerInstanceHolder`, `UTOptionalOfArrayPropertyHost` — existing TOptional holder convention.

## 5. TSoftObjectPtr

## [x] 5.1 Author TSoftObjectPtr observation files

Delete the flat TSoftObjectPtr pockets. Repair SYNTAX. Move `t-soft-class-path-load` off this tree. Add RuntimeFail only with Bind evidence. Do not generate C++ here.

**Outcome**

`Containers/TSoftObjectPtr/LoadAsync` parses without a missing `}`. Flat `Containers/TSoftObjectPtr` is gone. Soft class-path load is not on this FileTag prefix.

**Interfaces**

Consumes:

```
parse_source_file(source: SourceInput) -> ParsedFile  # container_parser.py:243
discover_sources(author_root: Path)                    # discovery.py:46
```

Produces:

```
Containers/TSoftObjectPtr/LoadAsync
tests.test_tsoftobjectptr_directory_authors
```

Source: [glossary.md](attachments/drafts/glossary.md).

**Cases**

1. **LoadAsyncParses** — new RED
   Given `AngelscriptTestCode/Containers/TSoftObjectPtr/LoadAsync.as`. When `parse_source_file` runs. Then FileTag is `Containers/TSoftObjectPtr/LoadAsync` and the source is a complete parentless program.

2. **FlatSoftPtrAbsent** — new RED
   Given `discover_sources`. When FileTags are collected. Then `Containers/TSoftObjectPtr` is absent and `Containers/TSoftObjectPtr/LoadAsync` is present.

**Files**

```diff
- AngelscriptTestCode/Containers/TSoftObjectPtr.as
- AngelscriptTestCode/Containers/TSoftObjectPtrCompileFail.as
+ AngelscriptTestCode/Containers/TSoftObjectPtr/
+ AngelscriptTestCode/CodeGenTool/tests/test_tsoftobjectptr_directory_authors.py
```

**Verification**

```
python AngelscriptTestCode/CodeGenTool/tests/test_tsoftobjectptr_directory_authors.py
```

Working directory: workspace root. PASS when both cases execute and pass.

**Evidence**

- RED `python AngelscriptTestCode/CodeGenTool/tests/test_tsoftobjectptr_directory_authors.py`: LoadAsyncParses missing `LoadAsync.as`; FlatSoftPtrAbsent still saw `Containers/TSoftObjectPtr`. `FAILED (failures=2)`.
- GREEN same command (coordinator re-run): 2/2 OK in 0.217s. Flat `TSoftObjectPtr.as` / `TSoftObjectPtrCompileFail.as` gone. 25 observation files (21 + 2 CompileFail + 2 RuntimeFail). `LoadAsync` is a closed UCLASS with `HandleObjectLoaded`. Soft class-path load omitted. RuntimeFail added from Bind Throw (`Actor soft references cannot be loaded…`, `Provided class is does not inherit from TSoftClassPtr subtype.`).
- Naming assumed: `UTSSoftObjectPtrLoadAsyncReceiver` and sibling holders — per-file unique UCLASS names after TOptional/TObjectPtr. `TSoftObjectPtrDirectoryAuthorTests` — sibling `*DirectoryAuthorTests` class.

## 6. TWeakObjectPtr

## [x] 6.1 Author TWeakObjectPtr observation files

Delete the flat TWeakObjectPtr pockets. Pascalize existing observations and add `InvalidatedIsStaleNotExplicitlyNull`. Do not generate C++ here.

**Outcome**

`Containers/TWeakObjectPtr/InvalidatedIsStaleNotExplicitlyNull` parses. Flat `Containers/TWeakObjectPtr` is gone.

**Interfaces**

Consumes:

```
parse_source_file(source: SourceInput) -> ParsedFile  # container_parser.py:243
discover_sources(author_root: Path)                    # discovery.py:46
```

Produces:

```
Containers/TWeakObjectPtr/InvalidatedIsStaleNotExplicitlyNull
tests.test_tweakobjectptr_directory_authors
```

Source: [glossary.md](attachments/drafts/glossary.md).

**Cases**

1. **StaleAfterGcParses** — new RED
   Given `AngelscriptTestCode/Containers/TWeakObjectPtr/InvalidatedIsStaleNotExplicitlyNull.as`. When `parse_source_file` runs. Then FileTag is `Containers/TWeakObjectPtr/InvalidatedIsStaleNotExplicitlyNull` and the body names `IsStale`.

2. **FlatWeakAbsent** — new RED
   Given `discover_sources`. When FileTags are collected. Then `Containers/TWeakObjectPtr` is absent.

**Files**

```diff
- AngelscriptTestCode/Containers/TWeakObjectPtr.as
- AngelscriptTestCode/Containers/TWeakObjectPtrCompileFail.as
+ AngelscriptTestCode/Containers/TWeakObjectPtr/
+ AngelscriptTestCode/CodeGenTool/tests/test_tweakobjectptr_directory_authors.py
```

**Verification**

```
python AngelscriptTestCode/CodeGenTool/tests/test_tweakobjectptr_directory_authors.py
```

Working directory: workspace root. PASS when both cases execute and pass.

**Evidence**

- RED `python AngelscriptTestCode/CodeGenTool/tests/test_tweakobjectptr_directory_authors.py`: StaleAfterGcParses missing `InvalidatedIsStaleNotExplicitlyNull.as`; FlatWeakAbsent still saw `Containers/TWeakObjectPtr`. `FAILED (failures=2)`.
- GREEN same command (coordinator re-run): 2/2 OK in 0.199s. Flat `TWeakObjectPtr.as` / `TWeakObjectPtrCompileFail.as` gone. 27 observation files (23 + 4 CompileFail). `InvalidatedIsStaleNotExplicitlyNull` names `IsStale`. No RuntimeFail — no Bind Throw.
- Naming assumed: `TWeakObjectPtrDirectoryAuthorTests` — local unittest class after `UnrealAuthorTests`. UCLASS names reused the old pocket (`UTWeakObjectPtrInvalidationObject` and siblings).

## 7. TSubclassOf

## [x] 7.1 Author TSubclassOf observation files

Delete the flat TSubclassOf pockets. Hand-write hierarchy/CDO files and extra RuntimeFail write paths. Do not generate C++ here.

**Outcome**

`Containers/TSubclassOf/AssignDerivedClassIntoBaseHolder` and `RuntimeFail/AssignUnrelatedViaOpAssign` parse. Flat `Containers/TSubclassOf` is gone.

**Interfaces**

Consumes:

```
parse_source_file(source: SourceInput) -> ParsedFile  # container_parser.py:243
discover_sources(author_root: Path)                    # discovery.py:46
```

Produces:

```
Containers/TSubclassOf/AssignDerivedClassIntoBaseHolder
Containers/TSubclassOf/RuntimeFail/AssignUnrelatedViaOpAssign
tests.test_tsubclassof_directory_authors
```

Source: [glossary.md](attachments/drafts/glossary.md).

**Cases**

1. **DerivedIntoBaseParses** — new RED
   Given `AngelscriptTestCode/Containers/TSubclassOf/AssignDerivedClassIntoBaseHolder.as`. When `parse_source_file` runs. Then FileTag is `Containers/TSubclassOf/AssignDerivedClassIntoBaseHolder`.

2. **FlatSubclassAbsent** — new RED
   Given `discover_sources`. When FileTags are collected. Then `Containers/TSubclassOf` is absent.

**Files**

```diff
- AngelscriptTestCode/Containers/TSubclassOf.as
- AngelscriptTestCode/Containers/TSubclassOfCompileFail.as
- AngelscriptTestCode/Containers/TSubclassOfRuntimeFail.as
+ AngelscriptTestCode/Containers/TSubclassOf/
+ AngelscriptTestCode/CodeGenTool/tests/test_tsubclassof_directory_authors.py
```

**Verification**

```
python AngelscriptTestCode/CodeGenTool/tests/test_tsubclassof_directory_authors.py
```

Working directory: workspace root. PASS when both cases execute and pass.

**Evidence**

- RED `python AngelscriptTestCode/CodeGenTool/tests/test_tsubclassof_directory_authors.py`: DerivedIntoBaseParses missing `AssignDerivedClassIntoBaseHolder.as`; FlatSubclassAbsent still saw `Containers/TSubclassOf`. `FAILED (failures=2)`.
- GREEN same command (coordinator re-run): 2/2 OK in 0.191s. Flat `TSubclassOf.as` / `TSubclassOfCompileFail.as` / `TSubclassOfRuntimeFail.as` gone. 30 observation files including `AssignDerivedClassIntoBaseHolder` and `RuntimeFail/AssignUnrelatedViaOpAssign`.
- Naming assumed: remaining TSubclassOf FileTags — from `per-type-trees.md` TSubclassOf section.

## 8. TObjectPtr

## [x] 8.1 Author TObjectPtr observation files

Delete the flat TObjectPtr pockets. Pascalize existing observations and add `FillWithNewObject`. Do not generate C++ here.

**Outcome**

`Containers/TObjectPtr/DefaultConstructionIsNull` parses. Flat `Containers/TObjectPtr` is gone.

**Interfaces**

Consumes:

```
parse_source_file(source: SourceInput) -> ParsedFile  # container_parser.py:243
discover_sources(author_root: Path)                    # discovery.py:46
```

Produces:

```
Containers/TObjectPtr/DefaultConstructionIsNull
tests.test_tobjectptr_directory_authors
```

Source: [glossary.md](attachments/drafts/glossary.md).

**Cases**

1. **DefaultNullParses** — new RED
   Given `AngelscriptTestCode/Containers/TObjectPtr/DefaultConstructionIsNull.as`. When `parse_source_file` runs. Then FileTag is `Containers/TObjectPtr/DefaultConstructionIsNull`.

2. **FlatObjectPtrAbsent** — new RED
   Given `discover_sources`. When FileTags are collected. Then `Containers/TObjectPtr` is absent.

**Files**

```diff
- AngelscriptTestCode/Containers/TObjectPtr.as
- AngelscriptTestCode/Containers/TObjectPtrCompileFail.as
+ AngelscriptTestCode/Containers/TObjectPtr/
+ AngelscriptTestCode/CodeGenTool/tests/test_tobjectptr_directory_authors.py
```

**Verification**

```
python AngelscriptTestCode/CodeGenTool/tests/test_tobjectptr_directory_authors.py
```

Working directory: workspace root. PASS when both cases execute and pass.

**Evidence**

- RED `python AngelscriptTestCode/CodeGenTool/tests/test_tobjectptr_directory_authors.py`: DefaultNullParses missing `DefaultConstructionIsNull.as`; FlatObjectPtrAbsent still saw `Containers/TObjectPtr`. `FAILED (failures=2)`.
- GREEN same command (coordinator re-run): 2/2 OK in 0.197s. Flat `TObjectPtr.as` / `TObjectPtrCompileFail.as` gone. 24 observation files (21 + 3 CompileFail) including `DefaultConstructionIsNull`, `FillWithNewObject`, `ReplaceTarget`.
- Naming assumed: `UTObjectPtr<Stem>Object` / `UTObjectPtr<Stem>Holder` — local UCLASS fixtures matching the TOptional holder convention. Observer wrappers `AssignedPointerReadsBack`, `FilledPointerHoldsObject`, `ReplacedPointerHoldsNewObject` around the `&in` / `&out` / `&inout` samples.

## 9. SoftObjectPath

## [x] 9.1 Author SoftObjectPath observation files

Delete the flat SoftObjectPath pocket. Rename `Queries_02-*` to ClassPath observations. Open Fail directories only if Bind diagnoses `::::`. Do not generate C++ here.

**Outcome**

`Containers/SoftObjectPath/ClassPathIsValid` parses. Flat `Containers/SoftObjectPath` is gone.

**Interfaces**

Consumes:

```
parse_source_file(source: SourceInput) -> ParsedFile  # container_parser.py:243
discover_sources(author_root: Path)                    # discovery.py:46
```

Produces:

```
Containers/SoftObjectPath/ClassPathIsValid
tests.test_softobjectpath_directory_authors
```

Source: [glossary.md](attachments/drafts/glossary.md).

**Cases**

1. **ClassPathIsValidParses** — new RED
   Given `AngelscriptTestCode/Containers/SoftObjectPath/ClassPathIsValid.as`. When `parse_source_file` runs. Then FileTag is `Containers/SoftObjectPath/ClassPathIsValid` and no version tag equals `Queries_02-is-valid`.

2. **FlatPathAbsent** — new RED
   Given `discover_sources`. When FileTags are collected. Then `Containers/SoftObjectPath` is absent.

**Files**

```diff
- AngelscriptTestCode/Containers/SoftObjectPath.as
+ AngelscriptTestCode/Containers/SoftObjectPath/
+ AngelscriptTestCode/CodeGenTool/tests/test_softobjectpath_directory_authors.py
```

**Verification**

```
python AngelscriptTestCode/CodeGenTool/tests/test_softobjectpath_directory_authors.py
```

Working directory: workspace root. PASS when both cases execute and pass.

**Evidence**

- RED `python AngelscriptTestCode/CodeGenTool/tests/test_softobjectpath_directory_authors.py`: ClassPathIsValidParses missing `ClassPathIsValid.as`; FlatPathAbsent still saw `Containers/SoftObjectPath`. `FAILED (failures=2)`.
- GREEN same command (coordinator re-run): 2/2 OK in 0.202s. Flat `SoftObjectPath.as` gone. 18 observation files; no `Queries_02-is-valid`. Fail directories skipped — Bind_SoftObjectPath has no Throw for malformed `::::`.
- Naming assumed: remaining SoftObjectPath stems (`TryLoad`, `ResolveObject`, `ClassPathIsNull`, …) — from `per-type-trees.md` SoftObjectPath section.

## 10. Projections

## [x] 10.1 Generate container observation units

Run the existing generator so every new author file has a signed projection and retired flat units are gone.

**Outcome**

`codegen.py check` reports container observation FileTags synchronized. No `Containers/TArray.generated.cpp` remains.

**Files**

```diff
- Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/Containers/TArray.generated.cpp
- Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/Containers/TArrayCompileFail.generated.cpp
- Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/Containers/TArrayRuntimeFail.generated.cpp
+ Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/Containers/TArray/
+ Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/Containers/TMap/
+ Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/Containers/TSet/
+ Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/Containers/TOptional/
+ Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/Containers/TSoftObjectPtr/
+ Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/Containers/TWeakObjectPtr/
+ Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/Containers/TSubclassOf/
+ Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/Containers/TObjectPtr/
+ Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/Containers/SoftObjectPath/
```

Only signed Generated/Containers units owned by the nine author trees. Other Generated trees stay out.

**Verification**

```
python AngelscriptTestCode/CodeGenTool/codegen.py check
```

Working directory: workspace root. PASS when the command exits 0 after generate. Document-only check is not enough if generate was skipped.

**Evidence**

- RED `python AngelscriptTestCode/CodeGenTool/codegen.py check`: missing directory units (`Containers/TArray/AddAndOrder.generated.cpp` and siblings) and stale flat `Containers/TArray.generated.cpp` / `TArrayCompileFail` / `TArrayRuntimeFail` (same for the other eight types).
- GREEN same command after `codegen.py generate` (second generate; first left Language/Syntax drift while uncommitted Language authors were still moving): "Test-code generated projections are synchronized." Flat `Containers/TArray.generated.cpp` gone. `Containers/TArray/AddAndOrder.generated.cpp` present.
- Naming assumed: none. Generate also rewrote `Generated/Language/**` to match already-dirty Language authors from the prior Language Change; those paths stay outside this card's Files.

## 11. Spec and corpus

## [x] 11.1 Publish prefix FileTags in spec and corpus

Update host-api-fixtures and `HostApiFixtureCorpus` so the representative lookup is `Containers/TArray/AddAndOrder`, not flat `Containers/TArray`. Keep `Unreal/FMath` and the Pending/Math Function control.

**Outcome**

Current spec names `Containers/TArray/AddAndOrder`. `CorpusHasTArrayPrefix` finds a `Containers/TArray/` tag. `Get` of flat `Containers/TArray` is unsuccessful. `CorpusHasPendingMathFunctionIn` still holds.

**Interfaces**

Consumes:

```
FAngelscriptTestCode::Get(FStringView FileTag, FStringView VersionTag)  # AngelscriptTestCode.h:26
FAngelscriptTestCode::FindFiles                                        # HostApiFixtureCorpusTests.cpp:20
```

Produces:

```
TEST_METHOD(CorpusHasTArrayPrefix)
TEST_METHOD(CorpusHasTArrayAddAndOrder)
```

Source: [glossary.md](attachments/drafts/glossary.md). Neighbor `CorpusHasTArrayAndFMath` is rewritten, not kept as an exact-tag assertion.

**Cases**

1. **CorpusHasTArrayAddAndOrder** — new RED
   Given an activated database after 10.1 projections compile. When `Get` is called with FileTag `Containers/TArray/AddAndOrder` and VersionTag `AddAndOrder`. Then Get succeeds and `Get` of `Containers/TArray` is unsuccessful.

2. **CorpusHasTArrayPrefix** — new RED
   Given the same `FindFiles({Containers})` result. When Tags are inspected. Then at least one Tag starts with `Containers/TArray/` and none equals `Containers/TArray`.

3. **CorpusHasPendingMathFunctionIn** — existing control
   Given the same binary. When `Get(Unreal/FVector, function-parameters-in)` runs. Then it succeeds.

**Files**

```diff
  Plugins/Angelscript/Source/AngelscriptTest/FrameworkTests/HostApiFixtureCorpusTests.cpp
  openspec/specs/angelscript/testing/host-api-fixtures/spec.md
  openspec/changes/angelscript/feature-container-type-directories/specs/angelscript/testing/host-api-fixtures/spec.md
```

**Verification**

```
pwsh -NoProfile -Command "Import-Module ./.agents/skills/harness/scripts/Harness.psd1; $c = New-HarnessContext -WorkspaceRoot (Get-Location).Path; Invoke-Harness -Command ue.test -Context $c -Parameters @{ TestPrefix = 'Angelscript.UnitTest.Framework.HostApiFixtureCorpus'; Fast = $true }"
```

Working directory: workspace root. Build first per execution conventions. PASS when the three methods run and the prefix assertions are among them.

**Evidence**

- RED `ue.test` HostApiFixtureCorpus Fast after 10.1 projections (old tests): run `0be3f94ba75143818d75e102f589cfe8` Failed. `CorpusHasTArrayAndFMath` failed at `bHasTArray` (`File.Tag == Containers/TArray`). `CorpusHasPendingMathFunctionIn` and `LanguageTopicOmitsHostApi` succeeded (2/3).
- GREEN same prefix after rewriting `CorpusHasTArrayPrefix` / `CorpusHasTArrayAddAndOrder`: run `6bd4055872f541018e7a30bc77886a7c` Succeeded. 4/4: CorpusHasPendingMathFunctionIn, CorpusHasTArrayAddAndOrder, CorpusHasTArrayPrefix, LanguageTopicOmitsHostApi.
- Naming assumed: none.
- Omitted: Quick, Performance, Integration, full suite — card selector is HostApiFixtureCorpus Fast only; no adjacent failure after GREEN.
