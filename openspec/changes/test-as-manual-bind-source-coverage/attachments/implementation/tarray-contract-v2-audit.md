# TArray exact migration audit

## Scope and evidence

This is a read-only migration map for all eight files under `TestSource/Bindings/TArray/`. It covers all 45 current namespace-level callables and every authored MB-100 surface (`MB-100-S001` through `MB-100-S050`). The existing authored-rule identity remains the behavioral `caseId`; each proposed behavior below has a stable kebab-case `subcaseId`. No proposed source symbol contains `Observe_`, `SurfaceNNN`, `_Nominal`, or an alias retaining an old symbol.

Evidence read:

- all `TestSource/Bindings/TArray/*.as` sources;
- `TestSource/Generation/Rules/Authored/TS-BIND-TARRAY-001.json` through `-008.json`;
- registrations and implementation in `Bind_TArray.cpp`, `Bind_TArray.h`, and `Bind_TArray_Type.cpp`;
- `AngelscriptTArrayBindingsTests.cpp`, `AngelscriptTArraySyntaxCompatBindingsTests.cpp`, and `AngelscriptCoverageTArrayAdvancedTests.cpp`.

The runtime registrations confirm the AS-facing generic methods and iterator protocol. Important exact diagnostics from the implementation are:

- index, `Last`, `Swap`, `RemoveAt`, and `RemoveAtSwap`: `Array index out of bounds.`;
- `Insert` outside `[0, Num]`: `Array index out of bounds. Need to insert between 0 and ArraySize`;
- explicit iterator `Proceed` past the end: `Iterator out of bounds.`;
- `Copy` self/range failures: `Cannot copy an array into itself.`, `Count should not be negative.`, `Source array out of bounds.`, or `Target array out of bounds.`;
- negative `SetNum`/`SetNumZeroed`: `Invalid negative Num`.

The strongest current C++ tests independently establish ascending `Sort`, beginning/middle/end `Insert` and ordered `RemoveAt`, first-match `FindIndex`, capacity-preserving `Reserve`, mutable foreach aliasing, explicit iterator traversal, `FString`/`FName`/`UObject` instantiations, append-empty behavior, both `AddUnique` outcomes, `SetNum` zero-initialization, `Swap`, empty/singleton behavior, and the exact out-of-bounds index exception. The proposed vectors below preserve these facts while removing compound self-checks.

## Contract conventions used in this map

- Container inputs that must not change are `const TArray<T>&in`; mutated receivers are `TArray<T>&inout`; constructed results are returns or `&out` writebacks.
- Scalar API inputs are values. String-like API inputs use `const FString&in`. Object references use the existing AS spelling `UObject`.
- A raw API `bool` remains `bool`; no boolean below is a comparison wrapper. Void mutation APIs expose the mutated receiver. Removal counts, indices, query values, element reads, equality, `AddUnique`, and `CanProceed` are returned raw.
- `ordered[...]` means exact element order. `unordered[...]` means an exact multiset comparison, not mere membership. `relation(...)` is a typed relation comparison supported by the proposed v2 vector model.
- All exceptions are exact comparisons unless stated otherwise. On an exception vector, a receiver writeback is checked only when the runtime performs the bounds check before mutation.
- Every proposed function needs the quoted comment facts directly attached above its declaration. The implementer may turn the facts into fluent prose, but must not omit CaseId, subcase, role, inputs, outputs/writebacks, or boundary/ownership.
- The only zero-argument functions are the two default-construction entries. Their required-name reason is: “Zero arguments are intrinsic to the bound `TArray<T>` default constructor; the return value exposes the constructed empty array.”

## TS-BIND-TARRAY-001 — construction and assignment

Source: `TestSource/Bindings/TArray/Test_ConstructionAndAssignment_01.as`  
Namespace: `TS_TArray_ConstructionAndAssignment_01`  
Existing rule: `TS-BIND-TARRAY-001.json`; `GEN-TS-BIND-TARRAY-001`; MB-100; surfaces `S004`, `S010`, `S042`, `S046`; Positive/Engine.

### Complete old-callable map

| Old exact declaration | Current behavior / compound self-check | Proposed subcases |
|---|---|---|
| `bool Observe_Assignment_Nominal()` | Combines int and string array copy assignment, later source mutation, mutable iterator assignment, const iterator assignment, and four `CanProceed` predicates. | `copy-assign-int-independent`, `copy-assign-string`, `assign-mutable-iterator`, `assign-const-iterator` |
| `bool Observe_MoveAssignFrom_Nominal()` | Combines destination contents, source-empty state, and counts into one bool. | `move-assign-storage` |

### Exact replacement functions and vectors

1. `copy-assign-int-independent` — semantic name `CopyAssignThenMutateSource`; role `Act`; surface `MB-100-S004`.
   - Declaration: `void CopyAssignThenMutateSource(TArray<int32>&inout Source, int32 AppendedValue, TArray<int32>&out Destination)`
   - Vectors: `Source=ordered[1,2], AppendedValue=3 -> return=void, Source=ordered[1,2,3], Destination=ordered[1,2]`; `Source=ordered[], AppendedValue=7 -> Source=ordered[7], Destination=ordered[]`.
   - Comment facts: “CaseId TS-BIND-TARRAY-001, subcase copy-assign-int-independent, Act. Copy-assign Source to Destination, then append AppendedValue to Source. Destination is an independent element copy; Source and Destination writebacks expose both states. Empty input is valid.”

2. `copy-assign-string` — `CopyAssignStrings`; role `Act`; surface `S004` generic-type evidence.
   - Declaration: `void CopyAssignStrings(const TArray<FString>&in Source, TArray<FString>&out Destination)`
   - Vectors: `Source=ordered["Alpha"] -> Destination=ordered["Alpha"]`; `Source=ordered[] -> Destination=ordered[]`.
   - Comment facts: “CaseId TS-BIND-TARRAY-001, subcase copy-assign-string, Act. Copy-assign the const FString array into Destination. The source is unchanged and Destination contains independent copies; empty input remains empty.”

3. `assign-mutable-iterator` — `AssignedMutableIteratorCanProceed`; role `Read`; surfaces `S042` plus creation surface `S049`.
   - Declaration: `bool AssignedMutableIteratorCanProceed(TArray<int32>&inout Values)`
   - Vectors: `Values=ordered[] -> return=false, Values unchanged`; `Values=ordered[1,2] -> return=true, Values unchanged`.
   - Comment facts: “CaseId TS-BIND-TARRAY-001, subcase assign-mutable-iterator, Read. Create a mutable iterator, assign it to a default iterator, and return the assigned iterator's raw CanProceed property. Iterator assignment aliases array storage and does not mutate Values.”

4. `assign-const-iterator` — `AssignedConstIteratorCanProceed`; role `Read`; surfaces `S046` plus `S050`.
   - Declaration: `bool AssignedConstIteratorCanProceed(const TArray<int32>&in Values)`
   - Vectors: `Values=ordered[] -> false`; `Values=ordered[1,2] -> true`.
   - Comment facts: “CaseId TS-BIND-TARRAY-001, subcase assign-const-iterator, Read. Create a const iterator, assign it to a default const iterator, and return raw CanProceed. The iterator aliases read-only array storage.”

5. `move-assign-storage` — `MoveAssignArray`; role `Act`; surface `S010`.
   - Declaration: `void MoveAssignArray(TArray<int32>&inout Source, TArray<int32>&inout Destination)`
   - Vectors: `Source=ordered[10,20], Destination=ordered[1] -> Source=ordered[], Destination=ordered[10,20]`; `Source=ordered[], Destination=ordered[1,2] -> Source=ordered[], Destination=ordered[]`.
   - Comment facts: “CaseId TS-BIND-TARRAY-001, subcase move-assign-storage, Act. Move Source storage into Destination and expose both writebacks. Source is consumed and becomes empty; previous Destination elements are replaced. Moving an array into itself is outside this positive subcase.”

Recommendation: split the current `Observe_Assignment_Nominal` exactly as above. The four surfaces have different raw outputs/ownership semantics; merging them would retain the compound-bool defect.

## TS-BIND-TARRAY-002 — operators

Source: `TestSource/Bindings/TArray/Test_Operators_01.as`  
Namespace: `TS_TArray_Operators_01`  
Existing rule: `TS-BIND-TARRAY-002.json`; `GEN-TS-BIND-TARRAY-002`; surfaces `S002`, `S003`, `S005`; Positive + NegativeDiagnostic/Engine.

### Complete old-callable map

| Old exact declaration | Current behavior / compound self-check | Proposed subcases |
|---|---|---|
| `bool Observe_Index_Nominal()` | Combines mutable read, alias write, later reads, const read, and FName instantiation into one bool. | `mutable-index-write-through`, `const-index-read`, `name-index-read` |
| `bool Observe_Equality_Nominal()` | Combines four equality outcomes into one bool. | `array-equality` |
| `void ExerciseExpectedFailure()` | Hard-coded read at index 8; generic name hides trigger. | `index-read-out-of-bounds` |

### Exact replacement functions and vectors

1. `mutable-index-write-through` — `WriteIndexedValue`; role `Act`; surface `S002`.
   - Declaration: `int32 WriteIndexedValue(TArray<int32>&inout Values, int32 Index, int32 Replacement)`
   - Vectors: `Values=ordered[1,2], Index=0, Replacement=9 -> return=1, Values=ordered[9,2]`; `Values=ordered[1,2], Index=1, Replacement=7 -> return=2, Values=ordered[1,7]`.
   - Comment facts: “CaseId TS-BIND-TARRAY-002, subcase mutable-index-write-through, Act. Return the raw value read through the mutable subscript reference, then assign Replacement through that alias. Values exposes the write-through; invalid indices throw.”

2. `const-index-read` — `ReadIndexedValue`; role `Read`; surface `S003`.
   - Declaration: `int32 ReadIndexedValue(const TArray<int32>&in Values, int32 Index)`
   - Vectors: `[9,2],0 -> 9`; `[9,2],1 -> 2`.
   - Comment facts: “CaseId TS-BIND-TARRAY-002, subcase const-index-read, Read. Return the raw element obtained from the const subscript overload. Values is not mutated; invalid indices throw.”

3. `name-index-read` — `ReadIndexedName`; role `Read`; surface `S003` generic `FName` evidence.
   - Declaration: `FName ReadIndexedName(const TArray<FName>&in Names, int32 Index)`
   - Vectors: `Names=ordered[n"Alpha"], Index=0 -> n"Alpha"`.
   - Comment facts: “CaseId TS-BIND-TARRAY-002, subcase name-index-read, Read. Return the raw FName obtained through const subscript, preserving the non-primitive value exactly.”

4. `array-equality` — `ArraysEqual`; role `Read`; surface `S005`.
   - Declaration: `bool ArraysEqual(const TArray<int32>&in Left, const TArray<int32>&in Right)`
   - Vectors: `[1,2],[1,2] -> true`; `[],[] -> true`; `[1,2],[] -> false`; `[1,2],[1] -> false`; `[1,2],[2,1] -> false`.
   - Comment facts: “CaseId TS-BIND-TARRAY-002, subcase array-equality, Read. Return the raw element-wise equality result. Equality requires the same length and corresponding values; neither operand is mutated.”

5. `index-read-out-of-bounds` — `TriggerIndexReadPastEnd`; role `NegativeTrigger`; surface `S002/S003` diagnostic.
   - Declaration: `int32 TriggerIndexReadPastEnd(const TArray<int32>&in Values, int32 Index)`
   - Vector: `Values=ordered[1], Index=8 -> exception exact "Array index out of bounds."`.
   - Comment facts: “CaseId TS-BIND-TARRAY-002, subcase index-read-out-of-bounds, NegativeTrigger. Read the requested const index to trigger the bounds check. The receiver is read-only; Index at or beyond Num raises the exact array exception.”

The C++ suite separately tests both read and write out-of-bounds. The authored source currently covers only a read expression, so do not silently claim the write trigger; add it later only as a new reviewed subcase.

## TS-BIND-TARRAY-003 — index and explicit iteration

Source: `TestSource/Bindings/TArray/Test_IndexAndIteration_01.as`  
Namespace: `TS_TArray_IndexAndIteration_01`  
Existing rule: `TS-BIND-TARRAY-003.json`; surfaces `S011`, `S022`, `S041`, `S044`, `S045`, `S048`, `S049`, `S050`; Positive + NegativeDiagnostic/Engine.

### Complete old-callable map

| Old exact declaration | Current behavior / compound self-check | Proposed subcases |
|---|---|---|
| `bool Observe_IsValidIndex_Nominal()` | Five validity results collapsed. | `is-valid-index` |
| `bool Observe_FindIndex_Nominal()` | Empty, duplicate-first, present, and missing indices collapsed. | `find-first-index` |
| `bool Observe_Iterator_Nominal()` | Mutable/const iterator factories, copy constructors, empty state, and four properties collapsed. | `copy-mutable-iterator`, `copy-const-iterator` |
| `bool Observe_Proceed_Nominal()` | Mutable first/second values, alias write, mid/final state collapsed. | `proceed-mutable-at-index` |
| `bool Observe_ConstIterator_Nominal()` | Two values and exhaustion collapsed. | `proceed-const-at-index` |
| `void ExerciseExpectedFailure()` | Hard-coded mutable iterator overrun; generic name. | `proceed-past-end` |

### Exact replacement functions and vectors

1. `is-valid-index` — `IsArrayIndexValid`; role `Read`; surface `S011`.
   - Declaration: `bool IsArrayIndexValid(const TArray<int32>&in Values, int32 Index)`
   - Vectors: `[],0 -> false`; `[],-1 -> false`; `[10,20,30],0 -> true`; same `2 -> true`; same `3 -> false`; same `-1 -> false`.
   - Comment facts: “CaseId TS-BIND-TARRAY-003, subcase is-valid-index, Read. Return the raw IsValidIndex result for Index. Valid indices are zero through Num-1; negative and Num are false; Values is unchanged.”

2. `find-first-index` — `FindFirstValueIndex`; role `Read`; surface `S022`.
   - Declaration: `int32 FindFirstValueIndex(const TArray<int32>&in Values, int32 Value)`
   - Vectors: `[],10 -> -1`; `[10,20,10],10 -> 0`; same `20 -> 1`; same `99 -> -1`.
   - Comment facts: “CaseId TS-BIND-TARRAY-003, subcase find-first-index, Read. Return FindIndex's raw first matching index or -1 when absent. Duplicate values select the first occurrence; Values is unchanged.”

3. `copy-mutable-iterator` — `CopyConstructedMutableIteratorCanProceed`; role `Read`; surfaces `S041` and `S049`.
   - Declaration: `bool CopyConstructedMutableIteratorCanProceed(TArray<int32>&inout Values)`
   - Vectors: `[] -> false, unchanged`; `[10,20] -> true, unchanged`.
   - Comment facts: “CaseId TS-BIND-TARRAY-003, subcase copy-mutable-iterator, Read. Create a mutable iterator, copy-construct another at the same position, and return the copy's raw CanProceed. Both iterators alias Values.”

4. `copy-const-iterator` — `CopyConstructedConstIteratorCanProceed`; role `Read`; surfaces `S045` and `S050`.
   - Declaration: `bool CopyConstructedConstIteratorCanProceed(const TArray<int32>&in Values)`
   - Vectors: `[] -> false`; `[10,20] -> true`.
   - Comment facts: “CaseId TS-BIND-TARRAY-003, subcase copy-const-iterator, Read. Create a const iterator, copy-construct another at the same position, and return raw CanProceed. Values remains read-only.”

5. `proceed-mutable-at-index` — `ProceedMutableAtIndex`; role `Act`; surface `S044`.
   - Declaration: `int32 ProceedMutableAtIndex(TArray<int32>&inout Values, int32 ProceedIndex, int32 Replacement, bool&out CanProceedAfter)`
   - Vectors: `[10,20],0,11 -> return=10, CanProceedAfter=true, Values=[11,20]`; `[10,20],1,21 -> return=20, CanProceedAfter=false, Values=[10,21]`; `[10],0,12 -> return=10, false, Values=[12]`.
   - Comment facts: “CaseId TS-BIND-TARRAY-003, subcase proceed-mutable-at-index, Act. Advance to ProceedIndex, return that Proceed call's raw element value, write Replacement through its mutable alias, and expose raw CanProceed afterward. ProceedIndex must address an existing element.”

6. `proceed-const-at-index` — `ProceedConstAtIndex`; role `Read`; surface `S048`.
   - Declaration: `int32 ProceedConstAtIndex(const TArray<int32>&in Values, int32 ProceedIndex, bool&out CanProceedAfter)`
   - Vectors: `[10,20],0 -> return=10, CanProceedAfter=true`; `[10,20],1 -> return=20, false`; `[10],0 -> 10,false`.
   - Comment facts: “CaseId TS-BIND-TARRAY-003, subcase proceed-const-at-index, Read. Advance the const iterator to ProceedIndex, return that Proceed call's raw value, and expose raw CanProceed. Values is not mutated.”

7. `proceed-past-end` — `TriggerMutableIteratorProceedPastEnd`; role `NegativeTrigger`; surface `S044` diagnostic.
   - Declaration: `int32 TriggerMutableIteratorProceedPastEnd(TArray<int32>&inout Values)`
   - Vectors: `Values=[10] -> exception exact "Iterator out of bounds.", Values unchanged`; `Values=[] -> same exception`.
   - Comment facts: “CaseId TS-BIND-TARRAY-003, subcase proceed-past-end, NegativeTrigger. Exhaust the mutable iterator and call Proceed once more. The extra call raises the exact iterator exception and must not mutate Values.”

Runner/compiler check: `TArrayIterator<T>` and `TArrayConstIterator<T>` are engine value types with reference-bearing internal state. The proposed functions keep them local and expose only primitives/container writebacks. Do not place iterator objects themselves in contract parameters or returns without a later ABI/lifetime test.

## TS-BIND-TARRAY-004 — queries

Source: `TestSource/Bindings/TArray/Test_Queries_01.as`  
Namespace: `TS_TArray_Queries_01`  
Existing rule: `TS-BIND-TARRAY-004.json`; surfaces `S023`, `S031`-`S035`; Positive/Engine.

### Complete old-callable map

| Old exact declaration | Current behavior / compound self-check | Proposed subcases |
|---|---|---|
| `bool Observe_Contains_Nominal()` | Empty/present/missing int and present FString results collapsed. | `contains-int`, `contains-string` |
| `bool Observe_Num_Nominal()` | Empty and populated counts collapsed. | `array-count` |
| `bool Observe_Max_Nominal()` | Empty relation and reserved relation collapsed. | `capacity`, `capacity-after-reserve` |
| `bool Observe_GetAllocatedSize_Nominal()` | Two byte results replaced by relations in script. | `allocated-bytes-after-reserve` |
| `bool Observe_IsEmpty_Nominal()` | Empty and non-empty bools collapsed. | `is-empty` |
| `bool Observe_GetSlack_Nominal()` | Empty relation, exact formula, and nonnegative relation collapsed. | `slack-after-reserve` |

### Exact replacement functions and vectors

1. `contains-int` — `ContainsIntValue`; role `Read`; surface `S023`.
   - Declaration: `bool ContainsIntValue(const TArray<int32>&in Values, int32 Value)`
   - Vectors: `[],1 -> false`; `[1,2,1],2 -> true`; same `9 -> false`.
   - Comment facts: “CaseId TS-BIND-TARRAY-004, subcase contains-int, Read. Return Contains's raw equality result for Value. Both present and absent results are valid; Values is unchanged.”

2. `contains-string` — `ContainsStringValue`; role `Read`; surface `S023` generic string evidence.
   - Declaration: `bool ContainsStringValue(const TArray<FString>&in Values, const FString&in Value)`
   - Vectors: `["Alpha"],"Alpha" -> true`; `["Alpha"],"Beta" -> false`; `[],"Alpha" -> false`.
   - Comment facts: “CaseId TS-BIND-TARRAY-004, subcase contains-string, Read. Return raw string element equality from Contains; neither Values nor Value is changed.”

3. `array-count` — `ArrayCount`; role `Read`; surface `S031`.
   - Declaration: `int32 ArrayCount(const TArray<int32>&in Values)`
   - Vectors: `[] -> 0`; `[1,2] -> 2`.
   - Comment facts: “CaseId TS-BIND-TARRAY-004, subcase array-count, Read. Return Num's raw element count. Capacity is irrelevant and Values is unchanged.”

4. `capacity` — `ArrayCapacity`; role `Read`; surface `S032`.
   - Declaration: `int32 ArrayCapacity(const TArray<int32>&in Values)`
   - Vector: `[] -> return relation >= 0`; `[1] -> return relation >= 1`.
   - Comment facts: “CaseId TS-BIND-TARRAY-004, subcase capacity, Read. Return Max's raw capacity. Capacity is at least Num but allocator growth is not an exact portable value.”

5. `capacity-after-reserve` — `ReserveAndReadCapacity`; role `Act`; surfaces `S032` with `S018` as fixture setup.
   - Declaration: `int32 ReserveAndReadCapacity(TArray<int32>&inout Values, int32 ReservedSize)`
   - Vectors: `Values=[1], ReservedSize=8 -> return relation >= 8, Values=[1]`; `Values=[], ReservedSize=0 -> return relation >= 0, Values=[]`.
   - Comment facts: “CaseId TS-BIND-TARRAY-004, subcase capacity-after-reserve, Act. Reserve the requested capacity, return raw Max, and expose unchanged elements. Reserve changes allocation, not Num.”

6. `allocated-bytes-after-reserve` — `ReserveAndReadAllocatedBytes`; role `Act`; surface `S033` with reserve setup.
   - Declaration: `int64 ReserveAndReadAllocatedBytes(TArray<int32>&inout Values, int32 ReservedSize)`
   - Vectors: `[],0 -> return relation >= 0, Values=[]`; `[1],8 -> return relation >= 32, Values=[1]` (four-byte `int32`, capacity at least eight).
   - Comment facts: “CaseId TS-BIND-TARRAY-004, subcase allocated-bytes-after-reserve, Act. Reserve, then return GetAllocatedSize's raw byte count. Elements are unchanged; byte count is allocator-dependent but nonnegative and at least reserved int32 storage.”

7. `is-empty` — `IsArrayEmpty`; role `Read`; surface `S034`.
   - Declaration: `bool IsArrayEmpty(const TArray<int32>&in Values)`
   - Vectors: `[] -> true`; `[1] -> false`.
   - Comment facts: “CaseId TS-BIND-TARRAY-004, subcase is-empty, Read. Return IsEmpty's raw result; allocation capacity does not make an array non-empty.”

8. `slack-after-reserve` — `ReserveAndReadSlack`; role `Act`; surface `S035` with reserve setup.
   - Declaration: `int32 ReserveAndReadSlack(TArray<int32>&inout Values, int32 ReservedSize, int32&out Capacity)`
   - Vectors: `[1],8 -> return relation == Capacity-1 and >=7, Capacity relation >=8, Values=[1]`; `[],0 -> return relation == Capacity and >=0, Capacity>=0, Values=[]`.
   - Comment facts: “CaseId TS-BIND-TARRAY-004, subcase slack-after-reserve, Act. Reserve, return raw GetSlack, and write raw Max to Capacity. Slack equals Max minus Num; Values' elements do not change.”

Capacity values should remain relation comparisons in vectors; hard-coding allocator slack would make the fixture engine-version fragile.

## TS-BIND-TARRAY-005 — mutation and allocation lifecycle I

Source: `TestSource/Bindings/TArray/Test_MutationAndLifecycle_01.as`  
Namespace: `TS_TArray_MutationAndLifecycle_01`  
Existing rule: `TS-BIND-TARRAY-005.json`; surfaces `S006`, `S007`, `S008`, `S014`-`S019`, `S021`; Positive + NegativeDiagnostic/Engine.

### Complete old-callable map

| Old exact declaration | Current behavior / compound self-check | Proposed subcases |
|---|---|---|
| `bool Observe_Add_Nominal()` | Int, FString, null UObject, Actor CDO identity, counts, and indices collapsed. | `add-int`, `add-string`, `add-object` |
| `bool Observe_Append_Nominal()` | Append populated/empty and source preservation collapsed. | `append-array` |
| `bool Observe_Shuffle_Nominal()` | Count and three membership predicates collapsed. | `shuffle-array` |
| `bool Observe_Insert_Nominal()` | Explicit and default-index insert states collapsed. | `insert-at-index`, `insert-at-default-index` |
| `bool Observe_AddUnique_Nominal()` | Duplicate and unique raw bools plus final state collapsed. | `add-unique` |
| `bool Observe_Empty_Nominal()` | Default and reserved overload state/capacity collapsed. | `empty-default`, `empty-with-reserve` |
| `bool Observe_Reset_Nominal()` | Default and reserved overload state/capacity collapsed. | `reset-default`, `reset-with-reserve` |
| `bool Observe_Reserve_Nominal()` | Explicit/default Reserve, count, capacity, and element value collapsed. | `reserve-capacity`, `reserve-default` |
| `bool Observe_SetNum_Nominal()` | Grow, shrink, and default-to-zero collapsed. | `set-num`, `set-num-default` |
| `bool Observe_SetNumZeroed_Nominal()` | Grow/zero and default-to-zero collapsed. | `set-num-zeroed`, `set-num-zeroed-default` |
| `void ExerciseExpectedFailure()` | Hard-coded negative insert; generic name. | `insert-negative-index` |

### Exact replacement functions and vectors

1. `add-int` — `AddIntValue`; role `Act`; surface `S006`.
   - Declaration: `void AddIntValue(TArray<int32>&inout Values, int32 Value)`
   - Vectors: `[],1 -> [1]`; `[1],2 -> [1,2]`.
   - Comment facts: “CaseId TS-BIND-TARRAY-005, subcase add-int, Act. Append Value to Values and expose exact ordered state. Existing elements retain order.”

2. `add-string` — `AddStringValue`; role `Act`; surface `S006` generic string evidence.
   - Declaration: `void AddStringValue(TArray<FString>&inout Values, const FString&in Value)`
   - Vectors: `[],"Alpha" -> ["Alpha"]`; `["Alpha"],"Beta" -> ["Alpha","Beta"]`.
   - Comment facts: “CaseId TS-BIND-TARRAY-005, subcase add-string, Act. Append a copied FString value and preserve order.”

3. `add-object` — `AddObjectReference`; role `Act`; surface `S006` object identity evidence.
   - Declaration: `void AddObjectReference(TArray<UObject>&inout Objects, UObject Value)`
   - Vectors: `Objects=[], Value=null -> Objects=[null]`; `Objects=[null], Value=fixture Actor CDO -> Objects=[null, same identity as Actor CDO]`.
   - Comment facts: “CaseId TS-BIND-TARRAY-005, subcase add-object, Act. Append the UObject reference, preserving null and exact object identity. The array holds references; it does not clone objects.”

4. `append-array` — `AppendValues`; role `Act`; surface `S007`.
   - Declaration: `void AppendValues(TArray<int32>&inout Values, const TArray<int32>&in Other)`
   - Vectors: `[1],[2,3] -> Values=[1,2,3], Other=[2,3]`; `[1,2,3],[] -> Values unchanged, Other=[]`; `[],[4] -> [4]`.
   - Comment facts: “CaseId TS-BIND-TARRAY-005, subcase append-array, Act. Append all Other elements in order. Other is read-only and remains unchanged; appending empty input is a no-op.”

5. `shuffle-array` — `ShuffleValues`; role `Act`; surface `S008`.
   - Declaration: `void ShuffleValues(TArray<int32>&inout Values)`
   - Vectors: `[1,2,3] -> Values=unordered exact multiset [1,2,3], count=3`; `[] -> []`; `[7] -> [7]`.
   - Comment facts: “CaseId TS-BIND-TARRAY-005, subcase shuffle-array, Act. Randomly permute Values while preserving exact multiplicity and Num. Order is intentionally not asserted.”

6. `insert-at-index` — `InsertValueAtIndex`; role `Act`; surface `S014`.
   - Declaration: `void InsertValueAtIndex(TArray<int32>&inout Values, int32 Value, int32 Index)`
   - Vectors: `[1,3],9,1 -> [1,9,3]`; `[1,3],0,0 -> [0,1,3]`; `[1,3],4,2 -> [1,3,4]`.
   - Comment facts: “CaseId TS-BIND-TARRAY-005, subcase insert-at-index, Act. Insert Value at Index, shifting later elements. Index may equal Num; values outside zero through Num throw.”

7. `insert-at-default-index` — `InsertValueAtDefaultIndex`; role `Act`; surface `S014` default argument.
   - Declaration: `void InsertValueAtDefaultIndex(TArray<int32>&inout Values, int32 Value)`
   - Vectors: `[1,9,3],0 -> [0,1,9,3]`; `[],5 -> [5]`.
   - Comment facts: “CaseId TS-BIND-TARRAY-005, subcase insert-at-default-index, Act. Omit Index so the bound default zero inserts Value at the beginning.”

8. `add-unique` — `AddUniqueValue`; role `Act`; surface `S015`.
   - Declaration: `bool AddUniqueValue(TArray<int32>&inout Values, int32 Value)`
   - Vectors: `[1],1 -> return=false, Values=[1]`; `[1],4 -> true, Values=[1,4]`; `[],4 -> true, Values=[4]`.
   - Comment facts: “CaseId TS-BIND-TARRAY-005, subcase add-unique, Act. Return AddUnique's raw insertion flag and expose Values. Equal existing values return false without mutation; absent values append and return true.”

9. `empty-default` — `EmptyArray`; role `Act`; surface `S016` default argument.
   - Declaration: `void EmptyArray(TArray<int32>&inout Values)`
   - Vectors: `[1,2] -> []`; `[] -> []`.
   - Comment facts: “CaseId TS-BIND-TARRAY-005, subcase empty-default, Act. Call Empty with its default reserved size and expose the empty receiver. Capacity is not part of this subcase.”

10. `empty-with-reserve` — `EmptyArrayWithReserve`; role `Act`; surface `S016`.
    - Declaration: `void EmptyArrayWithReserve(TArray<int32>&inout Values, int32 ReservedSize, int32&out Capacity)`
    - Vectors: `[1],8 -> Values=[], Capacity relation >=8`; `[],0 -> Values=[], Capacity relation >=0`.
    - Comment facts: “CaseId TS-BIND-TARRAY-005, subcase empty-with-reserve, Act. Empty Values while retaining at least ReservedSize capacity; write raw Max to Capacity. Num becomes zero.”

11. `reset-default` — `ResetArray`; role `Act`; surface `S017` default argument.
    - Declaration: `void ResetArray(TArray<int32>&inout Values)`
    - Vectors: `[1,2] -> []`; `[] -> []`.
    - Comment facts: “CaseId TS-BIND-TARRAY-005, subcase reset-default, Act. Reset Values with the bound default, destroying elements while reusing allocation when possible.”

12. `reset-with-reserve` — `ResetArrayWithReserve`; role `Act`; surface `S017`.
    - Declaration: `void ResetArrayWithReserve(TArray<int32>&inout Values, int32 ReservedSize, int32&out Capacity)`
    - Vectors: `[1],4 -> Values=[], Capacity relation >=4`; `[],0 -> Values=[], Capacity relation >=0`.
    - Comment facts: “CaseId TS-BIND-TARRAY-005, subcase reset-with-reserve, Act. Reset all elements while retaining at least ReservedSize capacity; expose raw Max.”

13. `reserve-capacity` — `ReserveArrayCapacity`; role `Act`; surface `S018`.
    - Declaration: `void ReserveArrayCapacity(TArray<int32>&inout Values, int32 ReservedSize, int32&out Capacity)`
    - Vectors: `[1],8 -> Values=[1], Capacity>=8`; `[1,2],1 -> Values=[1,2], Capacity>=2`.
    - Comment facts: “CaseId TS-BIND-TARRAY-005, subcase reserve-capacity, Act. Ensure capacity for at least ReservedSize without changing Num or elements; write raw Max.”

14. `reserve-default` — `ReserveArrayDefault`; role `Act`; surface `S018` default argument.
    - Declaration: `void ReserveArrayDefault(TArray<int32>&inout Values, int32&out Capacity)`
    - Vectors: `[1] -> Values=[1], Capacity>=1`; `[] -> [], Capacity>=0`.
    - Comment facts: “CaseId TS-BIND-TARRAY-005, subcase reserve-default, Act. Invoke Reserve with default zero and expose raw capacity. Elements and Num remain unchanged.”

15. `set-num` — `SetArrayNum`; role `Act`; surface `S019`.
    - Declaration: `void SetArrayNum(TArray<int32>&inout Values, int32 NewNum)`
    - Vectors: `[1],3 -> [1,0,0]`; `[1,2,3],1 -> [1]`; `[],0 -> []`.
    - Comment facts: “CaseId TS-BIND-TARRAY-005, subcase set-num, Act. Resize Values to NewNum. Existing prefix elements survive, removed suffixes disappear, and new int32 elements are default-initialized to zero; negative sizes throw.”

16. `set-num-default` — `SetArrayNumDefault`; role `Act`; surface `S019` default argument.
    - Declaration: `void SetArrayNumDefault(TArray<int32>&inout Values)`
    - Vectors: `[1] -> []`; `[] -> []`.
    - Comment facts: “CaseId TS-BIND-TARRAY-005, subcase set-num-default, Act. Omit NewNum so SetNum uses zero and empties the logical array.”

17. `set-num-zeroed` — `SetArrayNumZeroed`; role `Act`; surface `S021`.
    - Declaration: `void SetArrayNumZeroed(TArray<int32>&inout Values, int32 NewNum)`
    - Vectors: `[1],3 -> [1,0,0]`; `[1,2,3],1 -> [1]`; `[],2 -> [0,0]`.
    - Comment facts: “CaseId TS-BIND-TARRAY-005, subcase set-num-zeroed, Act. Resize primitive Values and explicitly zero newly added storage. Existing prefix elements survive; negative sizes throw.”

18. `set-num-zeroed-default` — `SetArrayNumZeroedDefault`; role `Act`; surface `S021` default argument.
    - Declaration: `void SetArrayNumZeroedDefault(TArray<int32>&inout Values)`
    - Vectors: `[1] -> []`; `[] -> []`.
    - Comment facts: “CaseId TS-BIND-TARRAY-005, subcase set-num-zeroed-default, Act. Omit NewNum so SetNumZeroed uses zero and empties Values.”

19. `insert-negative-index` — `TriggerInsertAtNegativeIndex`; role `NegativeTrigger`; surface `S014` diagnostic.
    - Declaration: `void TriggerInsertAtNegativeIndex(TArray<int32>&inout Values, int32 Value, int32 Index)`
    - Vector: `Values=[1], Value=9, Index=-1 -> exception exact "Array index out of bounds. Need to insert between 0 and ArraySize", Values=[1]`.
    - Comment facts: “CaseId TS-BIND-TARRAY-005, subcase insert-negative-index, NegativeTrigger. Attempt Insert with a negative Index. Bounds validation occurs before mutation and raises the exact insertion exception.”

Runner/compiler check: the object vector needs v2 runner support for a `TArray<UObject>&inout` parameter and identity-aware UObject vector values. If that transport is not yet supported, retain the current local Actor-CDO setup temporarily, rename it semantically, and mark the function as a required fixture helper; do not weaken the null/non-null identity observations.

## TS-BIND-TARRAY-006 — mutation and allocation lifecycle II

Source: `TestSource/Bindings/TArray/Test_MutationAndLifecycle_02.as`  
Namespace: `TS_TArray_MutationAndLifecycle_02`  
Existing rule: `TS-BIND-TARRAY-006.json`; surfaces `S024`-`S030`, `S040`; Positive + NegativeDiagnostic/Engine.

### Complete old-callable map

| Old exact declaration | Current behavior / compound self-check | Proposed subcases |
|---|---|---|
| `bool Observe_RemoveSingle_Nominal()` | Found/missing counts and final ordered state collapsed. | `remove-first` |
| `bool Observe_Remove_Nominal()` | Found/missing counts and final state collapsed. | `remove-all` |
| `bool Observe_RemoveSingleSwap_Nominal()` | Found/missing counts and only Num collapsed; survivor order not exposed. | `remove-first-swap` |
| `bool Observe_RemoveSwap_Nominal()` | Found/missing counts and membership collapsed. | `remove-all-swap` |
| `bool Observe_RemoveAt_Nominal()` | Final state compared by bool. | `remove-at` |
| `bool Observe_RemoveAtSwap_Nominal()` | Only Num and absence compared; order hidden. | `remove-at-swap` |
| `bool Observe_Sort_Nominal()` | Default ascending, explicit descending, explicit ascending, and states collapsed. | `sort-default-ascending`, `sort-direction` |
| `bool Observe_Shrink_Nominal()` | Before/after slack relations, populated state, and empty shrink collapsed. | `shrink-reserved` |
| `void ExerciseExpectedFailure()` | Hard-coded `RemoveAt(-1)`; generic name. | `remove-at-negative-index` |

### Exact replacement functions and vectors

1. `remove-first` — `RemoveFirstValue`; role `Act`; surface `S024`.
   - Declaration: `int32 RemoveFirstValue(TArray<int32>&inout Values, int32 Value)`
   - Vectors: `[1,2,1],1 -> return=1, Values=[2,1]`; `[1,2,1],9 -> 0, Values unchanged`; `[],1 -> 0, []`.
   - Comment facts: “CaseId TS-BIND-TARRAY-006, subcase remove-first, Act. Return RemoveSingle's raw removed count and expose ordered Values. At most the first equal element is removed; a miss returns zero.”

2. `remove-all` — `RemoveAllValues`; role `Act`; surface `S025`.
   - Declaration: `int32 RemoveAllValues(TArray<int32>&inout Values, int32 Value)`
   - Vectors: `[1,2,1],1 -> return=2, Values=[2]`; same `9 -> 0, unchanged`; `[],1 -> 0,[]`.
   - Comment facts: “CaseId TS-BIND-TARRAY-006, subcase remove-all, Act. Return Remove's raw count and expose the order-preserving survivors. Every equal element is removed.”

3. `remove-first-swap` — `RemoveFirstValueBySwap`; role `Act`; surface `S026`.
   - Declaration: `int32 RemoveFirstValueBySwap(TArray<int32>&inout Values, int32 Value)`
   - Vectors: `[1,2,1],1 -> return=1, Values=ordered[1,2]` (last element replaces first); `[1,2,1],9 -> 0, unchanged`; `[],1 -> 0,[]`.
   - Comment facts: “CaseId TS-BIND-TARRAY-006, subcase remove-first-swap, Act. Return RemoveSingleSwap's raw count and expose exact implementation order. The first match is replaced from the end when needed; survivor order is not generally stable.”

4. `remove-all-swap` — `RemoveAllValuesBySwap`; role `Act`; surface `S027`.
   - Declaration: `int32 RemoveAllValuesBySwap(TArray<int32>&inout Values, int32 Value)`
   - Vectors: `[1,2,1],1 -> return=2, Values=ordered[2]`; `[1,2,1],9 -> 0, unchanged`; `[1,2,1,3],1 -> return=2, Values=unordered exact [2,3]`.
   - Comment facts: “CaseId TS-BIND-TARRAY-006, subcase remove-all-swap, Act. Return RemoveSwap's raw count and expose all survivors. All matches are removed; survivor order is unspecified, so multi-survivor vectors use an exact unordered comparison.”

5. `remove-at` — `RemoveValueAt`; role `Act`; surface `S028`.
   - Declaration: `void RemoveValueAt(TArray<int32>&inout Values, int32 Index)`
   - Vectors: `[1,2,3],1 -> [1,3]`; `[1,2,3],0 -> [2,3]`; `[1,2,3],2 -> [1,2]`.
   - Comment facts: “CaseId TS-BIND-TARRAY-006, subcase remove-at, Act. Remove exactly one indexed element while preserving survivor order. Invalid Index throws before mutation.”

6. `remove-at-swap` — `RemoveValueAtBySwap`; role `Act`; surface `S029`.
   - Declaration: `void RemoveValueAtBySwap(TArray<int32>&inout Values, int32 Index)`
   - Vectors: `[1,2,3],0 -> [3,2]`; `[1,2,3],1 -> [1,3]`; `[1,2,3],2 -> [1,2]`.
   - Comment facts: “CaseId TS-BIND-TARRAY-006, subcase remove-at-swap, Act. Remove Index by moving the last element into its slot. Exact writebacks make the swap-removal order visible; invalid Index throws.”

7. `sort-default-ascending` — `SortValuesAscending`; role `Act`; surface `S030` default argument.
   - Declaration: `void SortValuesAscending(TArray<int32>&inout Values)`
   - Vectors: `[3,1,2] -> [1,2,3]`; `[] -> []`; `[7] -> [7]`.
   - Comment facts: “CaseId TS-BIND-TARRAY-006, subcase sort-default-ascending, Act. Omit bDescendingOrder so Sort uses ascending order. Empty and singleton arrays are valid.”

8. `sort-direction` — `SortValuesByDirection`; role `Act`; surface `S030`.
   - Declaration: `void SortValuesByDirection(TArray<int32>&inout Values, bool bDescendingOrder)`
   - Vectors: `[3,1,2],true -> [3,2,1]`; `[3,1,2],false -> [1,2,3]`.
   - Comment facts: “CaseId TS-BIND-TARRAY-006, subcase sort-direction, Act. Sort using the raw bDescendingOrder API input; true orders high-to-low and false low-to-high.”

9. `shrink-reserved` — `ShrinkReservedArray`; role `Act`; surface `S040`.
   - Declaration: `int32 ShrinkReservedArray(TArray<int32>&inout Values, int32 ReservedSize, int32&out SlackBefore)`
   - Vectors: `[1],16 -> SlackBefore relation >=15, return SlackAfter=0, Values=[1]`; `[],16 -> SlackBefore>=16, return=0, Values=[]`.
   - Comment facts: “CaseId TS-BIND-TARRAY-006, subcase shrink-reserved, Act. Reserve first as fixture setup, write raw pre-shrink slack, call Shrink, and return raw post-shrink slack. Num and elements do not change; empty shrink releases slack.”

10. `remove-at-negative-index` — `TriggerRemoveAtNegativeIndex`; role `NegativeTrigger`; surface `S028` diagnostic.
    - Declaration: `void TriggerRemoveAtNegativeIndex(TArray<int32>&inout Values, int32 Index)`
    - Vector: `Values=[1], Index=-1 -> exception exact "Array index out of bounds.", Values=[1]`.
    - Comment facts: “CaseId TS-BIND-TARRAY-006, subcase remove-at-negative-index, NegativeTrigger. Call RemoveAt with a negative Index; bounds validation raises the exact exception before mutation.”

The two swap-removal functions are not redundant with their ordered counterparts: their return counts overlap, but their survivor ordering and implementation surfaces differ. Keep all four.

## TS-BIND-TARRAY-007 — construction, swap, last, copy, foreach, mutable iterator property

Source: `TestSource/Bindings/TArray/Test_Behavior_01.as`  
Namespace: `TS_TArray_Behavior_01`  
Existing rule: `TS-BIND-TARRAY-007.json`; surfaces `S001`, `S009`, `S012`, `S013`, `S020`, `S036`-`S039`, `S043`; Positive + NegativeDiagnostic/Engine.

### Complete old-callable map

| Old exact declaration | Current behavior / compound self-check | Proposed subcases |
|---|---|---|
| `bool Observe_Array_Nominal()` | Default int and FName construction plus Num/IsEmpty collapsed. | `construct-empty-int`, `construct-empty-name` |
| `bool Observe_Swap_Nominal()` | Nontrivial and self-swap plus four state predicates collapsed. | `swap-elements` |
| `bool Observe_Last_Nominal()` | Mutable/const, default/from-end, alias read/write, and five predicates collapsed. | `read-last-const`, `write-last-mutable` |
| `bool Observe_Copy_Nominal()` | Default target and explicit target copies plus state collapsed. | `copy-range-to-start`, `copy-range-at-index` |
| `bool Observe_for_Nominal()` | Four compiler iteration surfaces and four aggregate comparisons collapsed. | `foreach-mutable-values`, `foreach-const-values`, `foreach-mutable-indexed`, `foreach-const-indexed` |
| `bool Observe_Surface043_Nominal()` | Empty, initial populated, and exhausted mutable CanProceed collapsed. | `mutable-can-proceed-after-steps` |
| `void ExerciseExpectedFailure()` | Hard-coded `Swap(-1,0)`; generic name. | `swap-negative-index` |

### Exact replacement functions and vectors

1. `construct-empty-int` — `ConstructEmptyIntArray`; role `Entry`; surface `S001`.
   - Declaration: `TArray<int32> ConstructEmptyIntArray()`
   - Vector: `no inputs -> return ordered[]; Num=0/IsEmpty=true are runner comparisons, not script predicates`.
   - Required-name reason: the zero-argument reason stated in the global conventions.
   - Comment facts: “CaseId TS-BIND-TARRAY-007, subcase construct-empty-int, Entry. Default-construct and return an empty TArray<int32>. Zero arguments intentionally mirror the bound constructor; the caller owns the returned value.”

2. `construct-empty-name` — `ConstructEmptyNameArray`; role `Entry`; surface `S001` generic `FName` evidence.
   - Declaration: `TArray<FName> ConstructEmptyNameArray()`
   - Vector: `no inputs -> return ordered[]`.
   - Required-name reason: same as above.
   - Comment facts: “CaseId TS-BIND-TARRAY-007, subcase construct-empty-name, Entry. Default-construct and return an empty TArray<FName>; zero arguments are the constructor contract.”

3. `swap-elements` — `SwapElements`; role `Act`; surface `S009`.
   - Declaration: `void SwapElements(TArray<int32>&inout Values, int32 FirstIndex, int32 SecondIndex)`
   - Vectors: `[10,20,30],0,2 -> [30,20,10]`; `[10,20,30],1,1 -> unchanged`; `[10,20,30,40],0,3 -> [40,20,30,10]`.
   - Comment facts: “CaseId TS-BIND-TARRAY-007, subcase swap-elements, Act. Exchange the two valid indices and expose exact order. Equal indices are a no-op; either invalid index throws.”

4. `read-last-const` — `ReadLastValueFromEnd`; role `Read`; surface `S012`.
   - Declaration: `int32 ReadLastValueFromEnd(const TArray<int32>&in Values, int32 IndexFromEnd)`
   - Vectors: `[10,20,30],0 -> 30`; same `1 -> 20`; same `2 -> 10`.
   - Comment facts: “CaseId TS-BIND-TARRAY-007, subcase read-last-const, Read. Return the const Last overload's raw value, where zero means the last element. Empty or excessive offsets throw.”

5. `write-last-mutable` — `WriteLastValueFromEnd`; role `Act`; surface `S013`.
   - Declaration: `int32 WriteLastValueFromEnd(TArray<int32>&inout Values, int32 IndexFromEnd, int32 Replacement)`
   - Vectors: `[10,20,30],0,31 -> return=30, Values=[10,20,31]`; `[10,20,30],1,21 -> return=20, Values=[10,21,30]`.
   - Comment facts: “CaseId TS-BIND-TARRAY-007, subcase write-last-mutable, Act. Return the prior value from mutable Last and assign Replacement through the returned alias. IndexFromEnd zero selects the final element.”

6. `copy-range-to-start` — `CopyRangeToStart`; role `Act`; surface `S020` default TargetIndex.
   - Declaration: `void CopyRangeToStart(TArray<int32>&inout Destination, const TArray<int32>&in Source, int32 SourceIndex, int32 Count)`
   - Vectors: `Destination=[0,0,0], Source=[10,20,30,40], SourceIndex=1, Count=2 -> Destination=[20,30,0], Source unchanged`; `Destination=[7], Source=[10],0,0 -> Destination=[7]`.
   - Comment facts: “CaseId TS-BIND-TARRAY-007, subcase copy-range-to-start, Act. Copy Count elements from SourceIndex using default TargetIndex zero. Source is read-only; Destination must already contain the target range.”

7. `copy-range-at-index` — `CopyRangeAtIndex`; role `Act`; surface `S020` explicit target.
   - Declaration: `void CopyRangeAtIndex(TArray<int32>&inout Destination, const TArray<int32>&in Source, int32 SourceIndex, int32 Count, int32 TargetIndex)`
   - Vectors: `Destination=[0,0,0,0], Source=[10,20,30,40],0,2,1 -> Destination=[0,10,20,0]`; `Destination=[9,9], Source=[1,2],1,1,0 -> [2,9]`.
   - Comment facts: “CaseId TS-BIND-TARRAY-007, subcase copy-range-at-index, Act. Copy an exact source range into the pre-sized destination range. Self-copy, negative Count, and source/target range violations throw.”

8. `foreach-mutable-values` — `IncrementMutableValues`; role `Act`; surface `S036`.
   - Declaration: `int32 IncrementMutableValues(TArray<int32>&inout Values, int32 Increment)`
   - Vectors: `[10,20,30],1 -> return sum=63, Values=[11,21,31]`; `[],1 -> return=0, Values=[]`.
   - Comment facts: “CaseId TS-BIND-TARRAY-007, subcase foreach-mutable-values, Act. Iterate mutable value references, add Increment to each live element, and return the resulting sum. The writeback proves aliasing; empty iteration returns zero.”

9. `foreach-const-values` — `SumConstValues`; role `Read`; surface `S037`.
   - Declaration: `int32 SumConstValues(const TArray<int32>&in Values)`
   - Vectors: `[10,20,30] -> 60`; `[] -> 0`.
   - Comment facts: “CaseId TS-BIND-TARRAY-007, subcase foreach-const-values, Read. Iterate const value references and return their sum without mutating Values.”

10. `foreach-mutable-indexed` — `AddIndicesToMutableValues`; role `Act`; surface `S038`.
    - Declaration: `int32 AddIndicesToMutableValues(TArray<int32>&inout Values)`
    - Vectors: `[10,20,30] -> return sum=63, Values=[10,21,32]`; `[] -> 0,[]`.
    - Comment facts: “CaseId TS-BIND-TARRAY-007, subcase foreach-mutable-indexed, Act. Iterate zero-based indices with mutable references, add each index to its element, and return the resulting sum. Writeback proves indexed aliasing.”

11. `foreach-const-indexed` — `SumConstValuesAndIndices`; role `Read`; surface `S039`.
    - Declaration: `int32 SumConstValuesAndIndices(const TArray<int32>&in Values)`
    - Vectors: `[10,20,30] -> 63`; `[] -> 0`.
    - Comment facts: “CaseId TS-BIND-TARRAY-007, subcase foreach-const-indexed, Read. Iterate const values with zero-based indices and return the sum of both while leaving Values unchanged.”

12. `mutable-can-proceed-after-steps` — `MutableIteratorCanProceedAfterSteps`; role `Read`; surface `S043` (factory `S049` is setup).
    - Declaration: `bool MutableIteratorCanProceedAfterSteps(TArray<int32>&inout Values, int32 Steps)`
    - Vectors: `[],0 -> false, unchanged`; `[1],0 -> true`; `[1],1 -> false`; `[1,2],1 -> true`; `[1,2],2 -> false`.
    - Comment facts: “CaseId TS-BIND-TARRAY-007, subcase mutable-can-proceed-after-steps, Read. Create a mutable iterator, perform exactly Steps valid Proceed calls, and return raw CanProceed. Values is not mutated; Steps greater than Num are outside this positive subcase.”

13. `swap-negative-index` — `TriggerSwapWithNegativeIndex`; role `NegativeTrigger`; surface `S009` diagnostic.
    - Declaration: `void TriggerSwapWithNegativeIndex(TArray<int32>&inout Values, int32 NegativeIndex, int32 ValidIndex)`
    - Vector: `[1],-1,0 -> exception exact "Array index out of bounds.", Values=[1]`.
    - Comment facts: “CaseId TS-BIND-TARRAY-007, subcase swap-negative-index, NegativeTrigger. Attempt Swap with one negative and one valid index. Validation happens before mutation and raises the exact array exception.”

The four foreach functions must remain separate: each is a distinct compiler-facing surface (`S036`-`S039`). The two constructor functions are also intentionally separate to preserve both current generic instantiations without returning a compound bool.

## TS-BIND-TARRAY-008 — const iterator property

Source: `TestSource/Bindings/TArray/Test_Behavior_02.as`  
Namespace: `TS_TArray_Behavior_02`  
Existing rule: `TS-BIND-TARRAY-008.json`; surface `S047`; Positive/Engine.

### Complete old-callable map

| Old exact declaration | Current behavior / compound self-check | Proposed subcase |
|---|---|---|
| `bool Observe_Surface047_Nominal()` | Empty, initial populated, mid, and exhausted const `CanProceed` results collapsed. | `const-can-proceed-after-steps` |

### Exact replacement function and vectors

1. `const-can-proceed-after-steps` — `ConstIteratorCanProceedAfterSteps`; role `Read`; surface `S047` (const factory `S050` is setup).
   - Declaration: `bool ConstIteratorCanProceedAfterSteps(const TArray<int32>&in Values, int32 Steps)`
   - Vectors: `[],0 -> false`; `[1,2],0 -> true`; `[1,2],1 -> true`; `[1,2],2 -> false`.
   - Comment facts: “CaseId TS-BIND-TARRAY-008, subcase const-can-proceed-after-steps, Read. Create a const iterator, perform exactly Steps valid Proceed calls, and return raw CanProceed. Values is read-only; Steps greater than Num are outside this positive subcase.”

Do not merge this source with `TS-BIND-TARRAY-007`: the separate rule and surface distinguish the const property from mutable `CanProceed`. The implementation bodies may follow the same shape, but the contract identities must remain distinct.

## Surface coverage cross-check

| Surface range | Proposed coverage |
|---|---|
| `S001` | `ConstructEmptyIntArray`, `ConstructEmptyNameArray` |
| `S002`-`S003` | mutable write-through, const int read, const FName read, index negative trigger |
| `S004` | int independent copy assignment and FString copy assignment |
| `S005` | parameterized raw equality |
| `S006`-`S008` | typed Add functions, Append, Shuffle |
| `S009`-`S010` | Swap positive/negative and MoveAssignFrom writebacks |
| `S011`-`S015` | IsValidIndex, const/mutable Last, explicit/default Insert, AddUnique |
| `S016`-`S021` | Empty, Reset, Reserve, SetNum, Copy, SetNumZeroed, including default arguments |
| `S022`-`S035` | FindIndex, Contains, four removal results, indexed removals, Sort, Num/Max/allocated bytes/IsEmpty/slack |
| `S036`-`S039` | all four foreach compiler protocols, separately |
| `S040` | Shrink with before/after slack and exact contents |
| `S041`-`S050` | mutable/const iterator copy construction, assignment, properties, Proceed, and factories |

No surface is lost by the recommended splits. Incidental calls used only as fixture setup (for example `Reserve` before reading `Max`, `GetSlack`, or `Shrink`) must be listed in function `coverage.apis`, but only the rule-owned surface is primary.

## Duplicate and redundancy rulings

- The current mutable `CanProceed` check in `Test_Behavior_01` overlaps incidental `CanProceed` reads in iterator copy/assignment and `Proceed` functions. Retain the dedicated `S043` function because it parameterizes the empty/initial/exhausted state; incidental checks should not claim `S043` as their primary surface.
- The const counterpart remains in `TS-BIND-TARRAY-008` for the same reason and must not be merged into the mutable case.
- `Observe_Assignment_Nominal` is the largest genuine over-merge: split array assignment, iterator assignment, and const iterator assignment. They share no primary output.
- `Observe_for_Nominal` must split four ways even though the aggregate sums are similar; these are four separate compiler protocol surfaces.
- Ordered removal and swap removal are behaviorally distinct, not duplicates. Exact or unordered final-container vectors make that distinction observable.
- Default-argument calls (`Insert()`, `Empty()`, `Reset()`, `Reserve()`, `SetNum()`, `SetNumZeroed()`, `Sort()`, `Copy(... without TargetIndex)`) should remain separate subcases where the current source explicitly exercises the omitted argument. Combining them behind an explicit parameter would lose default-argument coverage.
- The int/FString/FName/UObject variants are retained only where the current source already uses them. They are generic-instantiation evidence, not aliases.

## Signatures requiring later runner/compiler confirmation

The mapping is statically safe with the following explicit verification gates; do not improvise alternate declarations without recording the result.

1. Verify the v2 runner can invoke global functions with `TArray<T>&inout`, `const TArray<T>&in`, and `TArray<T>&out`, and can compare post-call ordered/unordered containers. These directions are valid AngelScript spellings, but the future runner marshaling is not present in the audited sources.
2. Verify returning `TArray<int32>` and `TArray<FName>` by value from zero-argument entries. If the runner cannot consume container returns, use `void ConstructEmptyIntArray(TArray<int32>&out Values)` and the analogous FName declaration, retaining the recorded zero-argument-constructor reason at the function/fixture level. This is the only approved fallback.
3. Verify `TArray<UObject>&inout` plus an object-valued `UObject` parameter, including null and Actor-CDO identity. If unsupported, preserve local CDO acquisition as a documented required fixture helper rather than replacing identity with counts.
4. Verify `bool&out` and `int32&out` writebacks alongside a primary return. If multi-output marshaling is unavailable, split the raw property/capacity read into an additional semantically named function; do not reintroduce a compound bool.
5. Verify the parser accepts explicit directions on const container references exactly as written (`const TArray<int32>&in`). Existing project sources demonstrate this syntax elsewhere, but the TArray pilot should compile before contracts are frozen.
6. Keep iterator objects local. Returning or accepting `TArrayIterator<T>` would carry an alias into container storage and needs separate lifetime/ABI proof.

## Implementation-ready outcome

The current 45 callables map to 68 proposed semantic functions/subcases (counting intentional generic-type and default-argument splits). Every positive result becomes a raw return, an explicit writeback, or a typed relation in the vector. Every negative function names its trigger and records the exact runtime diagnostic. There are no expected-value parameters, no boolean comparison wrappers, and no source aliases. An implementer can now create the eight v2 contracts and rewrite the eight sources directly from this map without inventing a symbol, declaration, vector, comment fact, or coverage assignment.
