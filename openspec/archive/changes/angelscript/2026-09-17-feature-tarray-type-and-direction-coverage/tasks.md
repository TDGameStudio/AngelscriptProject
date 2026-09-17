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
    "7.1": ["1.1", "2.1", "3.1", "4.1", "5.1", "6.1"]
    "8.1": ["7.1"]
---

# Port TArray type-axis and direction observations

## Goal

Hand-author TArray observation leaves for TestSource-old Function type suffixes and UFUNCTION directions, then project and query them.

## Architecture

Existing int32 observe files stay. New siblings follow [attachments/glossary.md](attachments/glossary.md). Six author cards have no edges. Generate and corpus join after authors. See [design.md](design.md).

## Global constraints

- TArray only. Do not edit other container trees, Language, or Unreal first-batch.
- Hand-write every `.as`. Do not generate authors from scripts.
- Do not dump TestSource-old Advance compose, Negative, or Reject piles.
- Observation names come from [attachments/glossary.md](attachments/glossary.md).
- Execution conventions: `.agents/skills/harness/references/execution-conventions.md`.

## File map

```diff
 AngelscriptTestCode/Containers/TArray/  # 1.1–6.1
 AngelscriptTestCode/CodeGenTool/tests/  # 1.1–7.1
 Plugins/Angelscript/Source/AngelscriptTest/
   TestCode/Generated/Containers/TArray/  # 7.1
   FrameworkTests/HostApiFixtureCorpusTests.cpp  # 8.1
 openspec/specs/angelscript/testing/host-api-fixtures/  # 8.1
```

## Requirement coverage

| Requirement | Tasks |
|---|---|
| Query `Containers/TArray/AddAndOrderFString` | 1.1, 7.1, 8.1 |
| Query `Containers/TArray/FillByAdd` | 1.1, 7.1, 8.1 |
| Existing `AddAndOrder` remains | 1.1, 8.1 |
| Remaining Function type and direction leaves | 2.1, 3.1, 4.1, 5.1, 6.1, 7.1 |
| Other containers unchanged | 1.1–6.1, 8.1 |

Self-review 2026-09-17: coverage maps the added type-and-direction requirement; placeholder scan clean; FileTags match the glossary. Record: attachments/data/planning-validation.md.

## 1. AddAndOrder

## [x] 1.1 Author AddAndOrder type and direction files

`AddAndOrder.as` stays the int32 local observe. Hand-write the 23 glossary siblings from `TestSource-old/Containers/TArray/Function/TArrayAddAndOrder.as`. Do not generate C++ here.

**Outcome**

`Containers/TArray/AddAndOrderFString` and `Containers/TArray/FillByAdd` parse as parentless `@begin` v1. Existing `AddAndOrder` still parses. Excluded: other Function subjects.

**Interfaces**

Consumes:

```
parse_source_file(source: SourceInput) -> ParsedFile  # container_parser.py:243
discover_sources(author_root: Path)                    # discovery.py:46
```

Produces:

```
Containers/TArray/AddAndOrderFString
Containers/TArray/FillByAdd
Containers/TArray/ReadAddOrder
Containers/TArray/AppendWithAdd
tests.test_tarray_add_type_direction
```

Source: [attachments/glossary.md](attachments/glossary.md) AddAndOrder table.

**Cases**

1. **AddAndOrderFStringParses** — new RED
   Given `AngelscriptTestCode/Containers/TArray/AddAndOrderFString.as`. When `parse_source_file` runs. Then FileTag is `Containers/TArray/AddAndOrderFString`, one parentless version tagged `AddAndOrderFString` exists, and the clean source contains `TArray<FString>` and `Add`.

2. **FillByAddParses** — new RED
   Given `AngelscriptTestCode/Containers/TArray/FillByAdd.as`. When `parse_source_file` runs. Then FileTag is `Containers/TArray/FillByAdd`, the entry is `FillByAdd`, and the clean source contains `TArray<int32>&out`.

3. **ReadAddOrderParses** — new RED
   Given `AngelscriptTestCode/Containers/TArray/ReadAddOrder.as`. When `parse_source_file` runs. Then the entry is `ReadAddOrder` and the clean source contains `const TArray<int32>&in`.

4. **AppendWithAddParses** — new RED
   Given `AngelscriptTestCode/Containers/TArray/AppendWithAdd.as`. When `parse_source_file` runs. Then the entry is `AppendWithAdd` and the clean source contains `TArray<int32>&inout`.

5. **ExistingAddAndOrderControl** — existing control
   Given `AngelscriptTestCode/Containers/TArray/AddAndOrder.as`. When `parse_source_file` runs. Then FileTag remains `Containers/TArray/AddAndOrder` with version `AddAndOrder`.

**Files**

```diff
+ AngelscriptTestCode/Containers/TArray/AddAndOrderFloat.as
+ AngelscriptTestCode/Containers/TArray/AddAndOrderBool.as
+ AngelscriptTestCode/Containers/TArray/AddAndOrderFString.as
+ AngelscriptTestCode/Containers/TArray/AddAndOrderFVector.as
+ AngelscriptTestCode/Containers/TArray/AddAndOrderUObject.as
+ AngelscriptTestCode/Containers/TArray/ReadAddOrder.as
+ AngelscriptTestCode/Containers/TArray/ReadAddOrderFloat.as
+ AngelscriptTestCode/Containers/TArray/ReadAddOrderBool.as
+ AngelscriptTestCode/Containers/TArray/ReadAddOrderFString.as
+ AngelscriptTestCode/Containers/TArray/ReadAddOrderFVector.as
+ AngelscriptTestCode/Containers/TArray/ReadAddOrderUObject.as
+ AngelscriptTestCode/Containers/TArray/FillByAdd.as
+ AngelscriptTestCode/Containers/TArray/FillByAddFloat.as
+ AngelscriptTestCode/Containers/TArray/FillByAddBool.as
+ AngelscriptTestCode/Containers/TArray/FillByAddFString.as
+ AngelscriptTestCode/Containers/TArray/FillByAddFVector.as
+ AngelscriptTestCode/Containers/TArray/FillByAddUObject.as
+ AngelscriptTestCode/Containers/TArray/AppendWithAdd.as
+ AngelscriptTestCode/Containers/TArray/AppendWithAddFloat.as
+ AngelscriptTestCode/Containers/TArray/AppendWithAddBool.as
+ AngelscriptTestCode/Containers/TArray/AppendWithAddFString.as
+ AngelscriptTestCode/Containers/TArray/AppendWithAddFVector.as
+ AngelscriptTestCode/Containers/TArray/AppendWithAddUObject.as
+ AngelscriptTestCode/CodeGenTool/tests/test_tarray_add_type_direction.py
```

Does not include Generated C++ or other Function subjects.

**Verification**

```
python AngelscriptTestCode/CodeGenTool/tests/test_tarray_add_type_direction.py
```

Working directory: workspace root. PASS when all five cases execute and pass. The test inserts `CodeGenTool` on `sys.path` the same way `test_tarray_directory_authors.py` does.

**Evidence**

- RED `python AngelscriptTestCode/CodeGenTool/tests/test_tarray_add_type_direction.py`: AddAndOrderFStringParses / FillByAddParses / ReadAddOrderParses / AppendWithAddParses FileNotFound. ExistingAddAndOrderControl green. `FAILED (errors=4)`.
- GREEN same command (coordinator): 5/5 OK. 23 siblings present including `AddAndOrderFString`, `FillByAdd` (`TArray<int32>&out`), `ReadAddOrder` (`const TArray<int32>&in`), `AppendWithAdd` (`TArray<int32>&inout`).
- Naming assumed: none.

## 2. Query subjects

## [x] 2.1 Author query type and direction files

Port type-axis and directions from `TArrayContains.as`, `TArrayNum.as`, `TArrayIndexAccess.as`, `TArrayFind.as`, and `TArrayEmptyConstruction.as`. Keep existing int32 observe files. EmptyConstruction gets type Key observes only.

**Outcome**

`ContainsReportsMembershipFString`, `ReadContainsReportsMembership`, `NumCountsElementsFString`, `IndexAccessReadsAndWritesFString`, `FindIndexReturnsFirstOrMinusOneFString`, and `EmptyConstructionFString` parse. Excluded: AddAndOrder siblings and mutate/remove subjects.

**Interfaces**

Consumes:

```
parse_source_file(source: SourceInput) -> ParsedFile  # container_parser.py:243
```

Produces:

```
Containers/TArray/ContainsReportsMembershipFString
Containers/TArray/ReadContainsReportsMembership
Containers/TArray/EmptyConstructionFString
tests.test_tarray_query_type_direction
```

Source: [attachments/glossary.md](attachments/glossary.md) direction pattern.

**Cases**

1. **ContainsFStringParses** — new RED
   Given `AngelscriptTestCode/Containers/TArray/ContainsReportsMembershipFString.as`. When `parse_source_file` runs. Then FileTag is `Containers/TArray/ContainsReportsMembershipFString` and the clean source contains `TArray<FString>` and `Contains`.

2. **ReadContainsParses** — new RED
   Given `AngelscriptTestCode/Containers/TArray/ReadContainsReportsMembership.as`. When `parse_source_file` runs. Then the clean source contains `const TArray<int32>&in`.

3. **EmptyConstructionFStringParses** — new RED
   Given `AngelscriptTestCode/Containers/TArray/EmptyConstructionFString.as`. When `parse_source_file` runs. Then the clean source contains `TArray<FString>` and `IsEmpty`.

4. **ExistingContainsControl** — existing control
   Given `AngelscriptTestCode/Containers/TArray/ContainsReportsMembership.as`. When `parse_source_file` runs. Then version `ContainsReportsMembership` remains.

**Files**

```diff
+ AngelscriptTestCode/Containers/TArray/ContainsReportsMembershipFloat.as
+ AngelscriptTestCode/Containers/TArray/ContainsReportsMembershipBool.as
+ AngelscriptTestCode/Containers/TArray/ContainsReportsMembershipFString.as
+ AngelscriptTestCode/Containers/TArray/ContainsReportsMembershipFVector.as
+ AngelscriptTestCode/Containers/TArray/ContainsReportsMembershipUObject.as
+ AngelscriptTestCode/Containers/TArray/ReadContainsReportsMembership.as
+ AngelscriptTestCode/Containers/TArray/FillByContainsReportsMembership.as
+ AngelscriptTestCode/Containers/TArray/MutateContainsReportsMembership.as
+ AngelscriptTestCode/Containers/TArray/NumCountsElementsFloat.as
+ AngelscriptTestCode/Containers/TArray/NumCountsElementsFString.as
+ AngelscriptTestCode/Containers/TArray/ReadNumCountsElements.as
+ AngelscriptTestCode/Containers/TArray/FillByNumCountsElements.as
+ AngelscriptTestCode/Containers/TArray/MutateNumCountsElements.as
+ AngelscriptTestCode/Containers/TArray/IndexAccessReadsAndWritesFString.as
+ AngelscriptTestCode/Containers/TArray/ReadIndexAccessReadsAndWrites.as
+ AngelscriptTestCode/Containers/TArray/FillByIndexAccessReadsAndWrites.as
+ AngelscriptTestCode/Containers/TArray/MutateIndexAccessReadsAndWrites.as
+ AngelscriptTestCode/Containers/TArray/FindIndexReturnsFirstOrMinusOneFString.as
+ AngelscriptTestCode/Containers/TArray/ReadFindIndexReturnsFirstOrMinusOne.as
+ AngelscriptTestCode/Containers/TArray/FillByFindIndexReturnsFirstOrMinusOne.as
+ AngelscriptTestCode/Containers/TArray/MutateFindIndexReturnsFirstOrMinusOne.as
+ AngelscriptTestCode/Containers/TArray/EmptyConstructionFloat.as
+ AngelscriptTestCode/Containers/TArray/EmptyConstructionBool.as
+ AngelscriptTestCode/Containers/TArray/EmptyConstructionFString.as
+ AngelscriptTestCode/Containers/TArray/EmptyConstructionFVector.as
+ AngelscriptTestCode/Containers/TArray/EmptyConstructionUObject.as
+ AngelscriptTestCode/CodeGenTool/tests/test_tarray_query_type_direction.py
```

Also hand-write the remaining typed and direction siblings required by the five source Function files and the glossary pattern. Those extra leaves stay under `Containers/TArray/` and are not listed above only when they follow the same `<Stem><Type>` / `Read|FillBy|Mutate<Stem>` rule.

**Verification**

```
python AngelscriptTestCode/CodeGenTool/tests/test_tarray_query_type_direction.py
```

Working directory: workspace root. PASS when all four cases execute and pass.

**Evidence**

- RED `python AngelscriptTestCode/CodeGenTool/tests/test_tarray_query_type_direction.py`: ContainsFStringParses / ReadContainsParses / EmptyConstructionFStringParses FileNotFound. ExistingContainsControl green. `FAILED (errors=3)`.
- GREEN same command (coordinator re-run): 4/4 OK. 97 query authors including `ContainsReportsMembershipFString`, `ReadContainsReportsMembership`, `EmptyConstructionFString`.
- Naming assumed: remaining `<Stem><Type>` / `Read|FillBy|Mutate<Stem>` siblings — glossary pattern.

## 3. Mutate subjects

## [x] 3.1 Author mutate type and direction files

Port type-axis and directions from `TArrayEmptyClear.as`, `TArrayInsert.as`, `TArrayAppend.as`, `TArrayAddUnique.as`, `TArraySwap.as`, `TArraySort.as`, and `TArrayShuffle.as`. Sort has no FVector/UObject leaves.

**Outcome**

`InsertShiftsFollowingFString`, `ReadInsertShiftsFollowing`, `SortAscendingFString`, and `EmptyClearsNumFString` parse. Excluded: Remove family and capacity/copy subjects.

**Interfaces**

Consumes:

```
parse_source_file(source: SourceInput) -> ParsedFile  # container_parser.py:243
```

Produces:

```
Containers/TArray/InsertShiftsFollowingFString
Containers/TArray/ReadInsertShiftsFollowing
Containers/TArray/SortAscendingFString
tests.test_tarray_mutate_type_direction
```

Source: [attachments/glossary.md](attachments/glossary.md).

**Cases**

1. **InsertFStringParses** — new RED
   Given `AngelscriptTestCode/Containers/TArray/InsertShiftsFollowingFString.as`. When `parse_source_file` runs. Then FileTag is `Containers/TArray/InsertShiftsFollowingFString` and the clean source contains `TArray<FString>` and `Insert`.

2. **ReadInsertParses** — new RED
   Given `AngelscriptTestCode/Containers/TArray/ReadInsertShiftsFollowing.as`. When `parse_source_file` runs. Then the clean source contains `const TArray<int32>&in`.

3. **SortFStringParses** — new RED
   Given `AngelscriptTestCode/Containers/TArray/SortAscendingFString.as`. When `parse_source_file` runs. Then the clean source contains `TArray<FString>` and `Sort`.

4. **ExistingInsertControl** — existing control
   Given `AngelscriptTestCode/Containers/TArray/InsertShiftsFollowing.as`. When `parse_source_file` runs. Then version `InsertShiftsFollowing` remains.

**Files**

```diff
+ AngelscriptTestCode/Containers/TArray/InsertShiftsFollowingFString.as
+ AngelscriptTestCode/Containers/TArray/ReadInsertShiftsFollowing.as
+ AngelscriptTestCode/Containers/TArray/FillByInsertShiftsFollowing.as
+ AngelscriptTestCode/Containers/TArray/MutateInsertShiftsFollowing.as
+ AngelscriptTestCode/Containers/TArray/AppendOtherArrayFString.as
+ AngelscriptTestCode/Containers/TArray/ReadAppendOtherArray.as
+ AngelscriptTestCode/Containers/TArray/FillByAppendOtherArray.as
+ AngelscriptTestCode/Containers/TArray/MutateAppendOtherArray.as
+ AngelscriptTestCode/Containers/TArray/AddUniqueRejectsDuplicateFString.as
+ AngelscriptTestCode/Containers/TArray/ReadAddUniqueRejectsDuplicate.as
+ AngelscriptTestCode/Containers/TArray/FillByAddUniqueRejectsDuplicate.as
+ AngelscriptTestCode/Containers/TArray/MutateAddUniqueRejectsDuplicate.as
+ AngelscriptTestCode/Containers/TArray/SwapElementsFString.as
+ AngelscriptTestCode/Containers/TArray/ReadSwapElements.as
+ AngelscriptTestCode/Containers/TArray/FillBySwapElements.as
+ AngelscriptTestCode/Containers/TArray/MutateSwapElements.as
+ AngelscriptTestCode/Containers/TArray/SortAscendingFString.as
+ AngelscriptTestCode/Containers/TArray/ReadSortAscending.as
+ AngelscriptTestCode/Containers/TArray/FillBySortAscending.as
+ AngelscriptTestCode/Containers/TArray/MutateSortAscending.as
+ AngelscriptTestCode/Containers/TArray/ShufflePreservesMembershipFString.as
+ AngelscriptTestCode/Containers/TArray/ReadShufflePreservesMembership.as
+ AngelscriptTestCode/Containers/TArray/FillByShufflePreservesMembership.as
+ AngelscriptTestCode/Containers/TArray/MutateShufflePreservesMembership.as
+ AngelscriptTestCode/Containers/TArray/EmptyClearsNumFString.as
+ AngelscriptTestCode/Containers/TArray/ReadEmptyClearsNum.as
+ AngelscriptTestCode/Containers/TArray/FillByEmptyClearsNum.as
+ AngelscriptTestCode/Containers/TArray/MutateEmptyClearsNum.as
+ AngelscriptTestCode/CodeGenTool/tests/test_tarray_mutate_type_direction.py
```

Also hand-write the remaining Float/Bool/FVector/UObject siblings required by those seven Function files, omitting Sort FVector/UObject.

**Verification**

```
python AngelscriptTestCode/CodeGenTool/tests/test_tarray_mutate_type_direction.py
```

Working directory: workspace root. PASS when all four cases execute and pass.

**Evidence**

- RED `python AngelscriptTestCode/CodeGenTool/tests/test_tarray_mutate_type_direction.py`: InsertFStringParses / ReadInsertParses / SortFStringParses FileNotFound. ExistingInsertControl green. `FAILED (errors=3)`.
- GREEN same command (coordinator re-run): 4/4 OK. 153 mutate authors including `InsertShiftsFollowingFString`, `ReadInsertShiftsFollowing`, `SortAscendingFString`. Sort has no FVector/UObject.
- Naming assumed: remaining typed/direction siblings — glossary pattern.

## 4. Remove family

## [x] 4.1 Author remove type and direction files

Port type-axis and directions from `TArrayRemove.as`, `TArrayRemoveSingle.as`, `TArrayRemoveSwap.as`, `TArrayRemoveAt.as`, and `TArrayRemoveAtSwap.as`. Three-direction sets hang on each of those source files as they already do in TestSource-old.

**Outcome**

`RemoveAllMatchesFString`, `RemoveSinglePreservesOrderFString`, `ReadRemoveAllMatches`, and `FillByRemoveAtIndex` parse. Excluded: AddAndOrder and query/mutate cards.

**Interfaces**

Consumes:

```
parse_source_file(source: SourceInput) -> ParsedFile  # container_parser.py:243
```

Produces:

```
Containers/TArray/RemoveAllMatchesFString
Containers/TArray/ReadRemoveAllMatches
Containers/TArray/RemoveSinglePreservesOrderFString
tests.test_tarray_remove_type_direction
```

Source: [attachments/glossary.md](attachments/glossary.md). Prefer old verbs `FillAndRemoveOneDuplicate` and `RemoveMiddleMatch` when they appear in the source file.

**Cases**

1. **RemoveFStringParses** — new RED
   Given `AngelscriptTestCode/Containers/TArray/RemoveAllMatchesFString.as`. When `parse_source_file` runs. Then FileTag is `Containers/TArray/RemoveAllMatchesFString` and the clean source contains `TArray<FString>` and `Remove`.

2. **ReadRemoveParses** — new RED
   Given `AngelscriptTestCode/Containers/TArray/ReadRemoveAllMatches.as`. When `parse_source_file` runs. Then the clean source contains `const TArray<int32>&in`.

3. **RemoveSingleFStringParses** — new RED
   Given `AngelscriptTestCode/Containers/TArray/RemoveSinglePreservesOrderFString.as`. When `parse_source_file` runs. Then the clean source contains `RemoveSingle`.

4. **ExistingRemoveControl** — existing control
   Given `AngelscriptTestCode/Containers/TArray/RemoveAllMatches.as`. When `parse_source_file` runs. Then version `RemoveAllMatches` remains.

**Files**

```diff
+ AngelscriptTestCode/Containers/TArray/RemoveAllMatchesFString.as
+ AngelscriptTestCode/Containers/TArray/ReadRemoveAllMatches.as
+ AngelscriptTestCode/Containers/TArray/FillByRemoveAllMatches.as
+ AngelscriptTestCode/Containers/TArray/MutateRemoveAllMatches.as
+ AngelscriptTestCode/Containers/TArray/RemoveSinglePreservesOrderFString.as
+ AngelscriptTestCode/Containers/TArray/ReadRemoveSinglePreservesOrder.as
+ AngelscriptTestCode/Containers/TArray/FillByRemoveSinglePreservesOrder.as
+ AngelscriptTestCode/Containers/TArray/MutateRemoveSinglePreservesOrder.as
+ AngelscriptTestCode/Containers/TArray/RemoveSwapFString.as
+ AngelscriptTestCode/Containers/TArray/ReadRemoveSwap.as
+ AngelscriptTestCode/Containers/TArray/FillByRemoveSwap.as
+ AngelscriptTestCode/Containers/TArray/MutateRemoveSwap.as
+ AngelscriptTestCode/Containers/TArray/RemoveAtIndexFString.as
+ AngelscriptTestCode/Containers/TArray/ReadRemoveAtIndex.as
+ AngelscriptTestCode/Containers/TArray/FillByRemoveAtIndex.as
+ AngelscriptTestCode/Containers/TArray/MutateRemoveAtIndex.as
+ AngelscriptTestCode/Containers/TArray/RemoveAtSwapFString.as
+ AngelscriptTestCode/Containers/TArray/ReadRemoveAtSwap.as
+ AngelscriptTestCode/Containers/TArray/FillByRemoveAtSwap.as
+ AngelscriptTestCode/Containers/TArray/MutateRemoveAtSwap.as
+ AngelscriptTestCode/CodeGenTool/tests/test_tarray_remove_type_direction.py
```

Also hand-write the remaining type suffixes from those five Function files.

**Verification**

```
python AngelscriptTestCode/CodeGenTool/tests/test_tarray_remove_type_direction.py
```

Working directory: workspace root. PASS when all four cases execute and pass.

**Evidence**

- RED `python AngelscriptTestCode/CodeGenTool/tests/test_tarray_remove_type_direction.py`: RemoveFStringParses / ReadRemoveParses / RemoveSingleFStringParses FileNotFound. ExistingRemoveControl green. `FAILED (errors=3)`.
- GREEN same command (coordinator re-run): 4/4 OK. 115 remove authors including `RemoveAllMatchesFString`, `ReadRemoveAllMatches`, `RemoveSinglePreservesOrderFString`, `FillByRemoveAtIndex`.
- Naming assumed: remaining typed/direction siblings — glossary pattern.

## 5. Capacity, copy, last, iterator

## [x] 5.1 Author capacity, copy, last, and iterator type and direction files

Port type-axis and directions from `TArrayCapacity.as`, `TArrayCapacityResize.as`, `TArrayCopy.as`, `TArrayCopyAssign.as`, `TArrayMoveAssign.as`, `TArrayReset.as`, `TArrayLastValidIndex.as`, `TArrayIterator.as`, and `TArrayForEach.as`.

**Outcome**

`CopyAssignFString`, `MoveAssignFromFString`, `ReadCopyAssign`, `LastValidIndexFString`, and `ConstIteratorWalkFString` parse. Excluded: AddAndOrder, query, mutate, and remove cards.

**Interfaces**

Consumes:

```
parse_source_file(source: SourceInput) -> ParsedFile  # container_parser.py:243
```

Produces:

```
Containers/TArray/CopyAssignFString
Containers/TArray/ReadCopyAssign
Containers/TArray/MoveAssignFromFString
Containers/TArray/ConstIteratorWalkFString
tests.test_tarray_capacity_copy_type_direction
```

Source: [attachments/glossary.md](attachments/glossary.md). Prefer old verbs `FillByMoveAssign`, `ReplaceByMoveAssign`, `FillThenReset`, `WalkWithConstIterator` when they appear in the source file.

**Cases**

1. **CopyAssignFStringParses** — new RED
   Given `AngelscriptTestCode/Containers/TArray/CopyAssignFString.as`. When `parse_source_file` runs. Then FileTag is `Containers/TArray/CopyAssignFString` and the clean source assigns one `TArray<FString>` onto another.

2. **ReadCopyAssignParses** — new RED
   Given `AngelscriptTestCode/Containers/TArray/ReadCopyAssign.as`. When `parse_source_file` runs. Then the clean source contains `const TArray<int32>&in`.

3. **ConstIteratorFStringParses** — new RED
   Given `AngelscriptTestCode/Containers/TArray/ConstIteratorWalkFString.as`. When `parse_source_file` runs. Then the clean source contains `TArrayConstIterator<FString>` or `TArray<FString>` walked with `Iterator`.

4. **ExistingCopyAssignControl** — existing control
   Given `AngelscriptTestCode/Containers/TArray/CopyAssign.as`. When `parse_source_file` runs. Then version `CopyAssign` remains.

**Files**

```diff
+ AngelscriptTestCode/Containers/TArray/CopyAssignFString.as
+ AngelscriptTestCode/Containers/TArray/ReadCopyAssign.as
+ AngelscriptTestCode/Containers/TArray/FillByCopyAssign.as
+ AngelscriptTestCode/Containers/TArray/MutateCopyAssign.as
+ AngelscriptTestCode/Containers/TArray/MoveAssignFromFString.as
+ AngelscriptTestCode/Containers/TArray/ReadMoveAssignFrom.as
+ AngelscriptTestCode/Containers/TArray/FillByMoveAssignFrom.as
+ AngelscriptTestCode/Containers/TArray/MutateMoveAssignFrom.as
+ AngelscriptTestCode/Containers/TArray/CopyRangeFString.as
+ AngelscriptTestCode/Containers/TArray/ResetClearsNumFString.as
+ AngelscriptTestCode/Containers/TArray/ReadResetClearsNum.as
+ AngelscriptTestCode/Containers/TArray/FillThenReset.as
+ AngelscriptTestCode/Containers/TArray/LastValidIndexFString.as
+ AngelscriptTestCode/Containers/TArray/ReadLastValidIndex.as
+ AngelscriptTestCode/Containers/TArray/FillByLastValidIndex.as
+ AngelscriptTestCode/Containers/TArray/MutateLastValidIndex.as
+ AngelscriptTestCode/Containers/TArray/ConstIteratorWalkFString.as
+ AngelscriptTestCode/Containers/TArray/ReadConstIteratorWalk.as
+ AngelscriptTestCode/Containers/TArray/ForEachElementFString.as
+ AngelscriptTestCode/Containers/TArray/ReadForEachElement.as
+ AngelscriptTestCode/Containers/TArray/FillByForEachElement.as
+ AngelscriptTestCode/Containers/TArray/MutateForEachElement.as
+ AngelscriptTestCode/Containers/TArray/ReserveGrowsMaxWithoutChangingNumFString.as
+ AngelscriptTestCode/Containers/TArray/ReadReserveGrowsMaxWithoutChangingNum.as
+ AngelscriptTestCode/CodeGenTool/tests/test_tarray_capacity_copy_type_direction.py
```

Also hand-write the remaining type and direction siblings from those nine Function files.

**Verification**

```
python AngelscriptTestCode/CodeGenTool/tests/test_tarray_capacity_copy_type_direction.py
```

Working directory: workspace root. PASS when all four cases execute and pass.

**Evidence**

- RED `python AngelscriptTestCode/CodeGenTool/tests/test_tarray_capacity_copy_type_direction.py`: CopyAssignFStringParses / ReadCopyAssignParses / ConstIteratorFStringParses FileNotFound. ExistingCopyAssignControl green. `FAILED (errors=3)`.
- GREEN same command (coordinator re-run): 4/4 OK. 184 capacity/copy/iterator authors including `CopyAssignFString`, `ReadCopyAssign`, `ConstIteratorWalkFString`, `MoveAssignFromFString`, `FillThenReset`.
- Naming assumed: remaining typed/direction siblings — glossary pattern. Reset `&out` keeps old verb `FillThenReset`.

## 6. Return values

## [x] 6.1 Author TArray return-value direction files

Port `TArrayFRotatorFunctionRoundTrip.as`, `TArrayFTransformFunctionRoundTrip.as`, and `FunctionArrayAndConversionRoundTrip.as`. These are UFUNCTION return / in / out / inout of `TArray<T>` for FRotator, FTransform, and FLinearColor.

**Outcome**

`ReturnFRotatorArray`, `ReadFRotatorArray`, `FillByFRotatorArray`, `ReturnFLinearColorArray` parse. Excluded: element-type AddAndOrder siblings.

**Interfaces**

Consumes:

```
parse_source_file(source: SourceInput) -> ParsedFile  # container_parser.py:243
```

Produces:

```
Containers/TArray/ReturnFRotatorArray
Containers/TArray/ReadFRotatorArray
Containers/TArray/FillByFRotatorArray
Containers/TArray/ReturnFLinearColorArray
tests.test_tarray_return_type_direction
```

Source: [attachments/glossary.md](attachments/glossary.md) return-value FileTags.

**Cases**

1. **ReturnFRotatorParses** — new RED
   Given `AngelscriptTestCode/Containers/TArray/ReturnFRotatorArray.as`. When `parse_source_file` runs. Then FileTag is `Containers/TArray/ReturnFRotatorArray` and the entry returns `TArray<FRotator>`.

2. **ReadFRotatorParses** — new RED
   Given `AngelscriptTestCode/Containers/TArray/ReadFRotatorArray.as`. When `parse_source_file` runs. Then the clean source contains `const TArray<FRotator>&in`.

3. **ReturnFLinearColorParses** — new RED
   Given `AngelscriptTestCode/Containers/TArray/ReturnFLinearColorArray.as`. When `parse_source_file` runs. Then the entry returns `TArray<FLinearColor>`.

**Files**

```diff
+ AngelscriptTestCode/Containers/TArray/ReturnIntArray.as
+ AngelscriptTestCode/Containers/TArray/ReturnFRotatorArray.as
+ AngelscriptTestCode/Containers/TArray/ReadFRotatorArray.as
+ AngelscriptTestCode/Containers/TArray/FillByFRotatorArray.as
+ AngelscriptTestCode/Containers/TArray/MutateFRotatorArray.as
+ AngelscriptTestCode/Containers/TArray/ReturnFTransformArray.as
+ AngelscriptTestCode/Containers/TArray/ReadFTransformArray.as
+ AngelscriptTestCode/Containers/TArray/FillByFTransformArray.as
+ AngelscriptTestCode/Containers/TArray/MutateFTransformArray.as
+ AngelscriptTestCode/Containers/TArray/ReturnFLinearColorArray.as
+ AngelscriptTestCode/Containers/TArray/ReadFLinearColorArray.as
+ AngelscriptTestCode/Containers/TArray/FillByFLinearColorArray.as
+ AngelscriptTestCode/Containers/TArray/MutateFLinearColorArray.as
+ AngelscriptTestCode/CodeGenTool/tests/test_tarray_return_type_direction.py
```

Does not include Advance compose boxes.

**Verification**

```
python AngelscriptTestCode/CodeGenTool/tests/test_tarray_return_type_direction.py
```

Working directory: workspace root. PASS when all three cases execute and pass.

**Evidence**

- RED `python AngelscriptTestCode/CodeGenTool/tests/test_tarray_return_type_direction.py`: 0/3; FileNotFoundError for `ReturnFRotatorArray.as`, `ReadFRotatorArray.as`, and `ReturnFLinearColorArray.as`.
- GREEN same command: 3/3 OK. `ReturnFRotatorParses` FileTag `Containers/TArray/ReturnFRotatorArray` with `TArray<FRotator>`; `ReadFRotatorParses` clean source has `const TArray<FRotator>&in`; `ReturnFLinearColorParses` returns `TArray<FLinearColor>`.
- Adjacent identity `test_container_observation_identity.py` 2/2 OK after the 13 authors (not the card prove command).
- Omitted: `codegen.py generate` / UE corpus — owned by 7.1 and 8.1.
- Naming assumed: none.

## 7. Projections

## [x] 7.1 Generate TArray type and direction units

Run the existing generator so every new author file has a signed projection. Identity still requires stem = `@begin` = entry.

**Outcome**

`codegen.py check` reports synchronized projections. `test_container_observation_identity.py` still passes. No method-alias stems were introduced.

**Files**

```diff
+ Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/Containers/TArray/
+     AddAndOrderFString.generated.cpp
+     FillByAdd.generated.cpp
+     ReadAddOrder.generated.cpp
+     ReturnFRotatorArray.generated.cpp
```

Only signed Generated/TArray units owned by the new authors. Other Generated trees stay out.

**Verification**

```
python AngelscriptTestCode/CodeGenTool/tests/test_container_observation_identity.py && python AngelscriptTestCode/CodeGenTool/codegen.py check
```

Working directory: workspace root. PASS when identity exits 0 and check exits 0 after generate. Document-only check is not enough if generate was skipped.

**Evidence**

- GREEN `python AngelscriptTestCode/CodeGenTool/tests/test_container_observation_identity.py && python AngelscriptTestCode/CodeGenTool/codegen.py check` after `codegen.py generate`: identity 2/2 OK; "Test-code generated projections are synchronized." `AddAndOrderFString.generated.cpp` present.
- Naming assumed: none.

## 8. Spec and corpus

## [x] 8.1 Publish type and direction FileTags in spec and corpus

Update current host-api-fixtures and `HostApiFixtureCorpus` so `Get` of `AddAndOrderFString` and `FillByAdd` succeeds. Keep `AddAndOrder`, the TArray prefix, and the Pending/Math Function control.

**Outcome**

Current spec names the type-and-direction requirement. `CorpusHasTArrayTypeAndDirection` finds both FileTags. `CorpusHasTArrayAddAndOrder` still holds.

**Interfaces**

Consumes:

```
FAngelscriptTestCode::Get(FStringView FileTag, FStringView VersionTag)  # AngelscriptTestCode.h:26
```

Produces:

```
TEST_METHOD(CorpusHasTArrayTypeAndDirection)
```

Source: this card; neighbor methods in `HostApiFixtureCorpusTests.cpp:12`.

**Cases**

1. **CorpusHasTArrayTypeAndDirection** — new RED
   Given an activated database after 7.1 projections compile. When `Get` is called with FileTag `Containers/TArray/AddAndOrderFString` version `AddAndOrderFString` and FileTag `Containers/TArray/FillByAdd` version `FillByAdd`. Then both Gets succeed.

2. **CorpusHasTArrayAddAndOrder** — existing control
   Given the same binary. When `Get(Containers/TArray/AddAndOrder, AddAndOrder)` runs. Then it succeeds.

3. **CorpusHasPendingMathFunctionIn** — existing control
   Given the same binary. When `Get(Unreal/FVector, function-parameters-in)` runs. Then it succeeds.

**Files**

```diff
  Plugins/Angelscript/Source/AngelscriptTest/FrameworkTests/HostApiFixtureCorpusTests.cpp
  openspec/specs/angelscript/testing/host-api-fixtures/spec.md
  openspec/changes/angelscript/feature-tarray-type-and-direction-coverage/specs/angelscript/testing/host-api-fixtures/spec.md
```

**Verification**

```
pwsh -NoProfile -Command "Import-Module ./.agents/skills/harness/scripts/Harness.psd1; $c = New-HarnessContext -WorkspaceRoot (Get-Location).Path; Invoke-Harness -Command ue.test -Context $c -Parameters @{ TestPrefix = 'Angelscript.UnitTest.Framework.HostApiFixtureCorpus'; Fast = $true }"
```

Working directory: workspace root. Build first per execution conventions. PASS when the prefix methods run and `CorpusHasTArrayTypeAndDirection` is among them.

**Evidence**

- RED `ue.build` run `a064c86299a04863a132412d1a855945` Failed exit 6. `HostApiFixtureCorpusTests.cpp` C2280: `GetBytes()` is `const &&` and cannot bind a temporary `GetSource()`. FileTags already projected by 7.1, so admission `Get` could not fail until this method compiled.
- GREEN after copying `FAngelscriptTestSource` before `GetBytes()`: `ue.build` run `745b6ef1a7424c9d92e3a3152c155609` Succeeded. Exact card command `ue.test` prefix `Angelscript.UnitTest.Framework.HostApiFixtureCorpus` Fast run `6e42e6da90044bf9b5b8505f5c760d69` Succeeded 5/5: `CorpusHasTArrayTypeAndDirection`, `CorpusHasTArrayAddAndOrder`, `CorpusHasPendingMathFunctionIn`, `CorpusHasTArrayPrefix`, `LanguageTopicOmitsHostApi`.
- Current spec `angelscript/testing/host-api-fixtures` requirement `TArray Function type and direction observations` published (`harness.specs.write` sha256 `48a898e9d03b4e6fed93984a5c8966dc9797f1558cc20b5550f21dff2196a523`). Strict spec and Change validate passed.
- Omitted: Quick, Performance, Integration, full suite — prefix 5/5, no adjacent failure.
- Naming assumed: `ContainsAscii` — file-level ASCII needle scan matching the existing FunctionIn byte walk.
