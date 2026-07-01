# Container Coverage Matrix, TArray / TMap / TSet

> **This matrix is the design specification header for container tests**: each row is a concrete verifiable scenario guiding six container test files. ⬜ rows are pending, ✅ rows identify the covering `TEST_METHOD`, and 🚫 rows are fork rejections guarded by negative compile assertions.
>
> - Test files: `TArrayAdvanced`(23) / `TMapAdvanced`(11) / `TSetAdvanced`(8) / `ContainerAdvanced`(7) / `ContainerNested`(7) / `ContainerParameter`(4) Tests.cpp
> - Automation prefix: `Angelscript.TestModule.Coverage.<topic>`
> - See `../coverage-matrix.md` for the legend; fork boundaries are detailed in `../coverage-gaps.md §2.1/§2.2`.

## 1. TArray Operations, AngelscriptCoverageTArrayAdvancedTests.cpp

| Scenario | Status | Coverage Test Method | Notes / Pending Work |
|------|------|------------|-------------|
| Sort and reverse, Sort / reverse traversal | ✅ | `TArraySortAndReverse` | Ascending sort, reverse traversal |
| Insert and remove by index | ✅ | `TArrayInsertAndRemoveAt` | Insert / RemoveAt |
| Find, FindIndex / Contains | ✅ | `TArrayFind` / `TArrayAdvancedSearch` | Supported find paths |
| Reserve capacity | ✅ | `TArrayReserve` / `TArraySetNumAndCapacity` | Reserve / SetNum / Max |
| for-each iteration | ✅ | `TArrayForEachIteration` | Range traversal |
| Index validity query, IsValidIndex | ✅ | inside `TArrayEdgeCasesEmpty` | Query validity only |
| Runtime semantics for out-of-bounds `[]` access | ✅ | `TArrayOutOfBoundsIndexAccess` | Both read and write out-of-bounds `[]` throw stable script exception `Array index out of bounds.` |
| Append and merge | ✅ | `TArrayAppendAndMerge` | Append |
| AddUnique and RemoveAll(value) | ✅ | `TArrayAddUniqueAndRemoveAll` | Deduplicated add / value removal |
| Swap elements | ✅ | `TArraySwapElements` | Swap |
| Bulk operations | ✅ | `TArrayBulkOperations` | Bulk add/remove |
| Duplicate handling | ✅ | `TArrayDuplicateHandling` | Duplicate value semantics |
| Empty array boundary | ✅ | `TArrayEdgeCasesEmpty` | Empty container operations |
| Element types: FString / FVector / FName / UObject references | ✅ | `TArrayFString` `TArrayFVector` `TArrayWithFName` `TArrayUObjectReferences` | Element type coverage |
| Property specifiers and meta | ✅ | `TArrayPropertySpecifiersAndMeta` | Flags such as EditAnywhere |
| Unbound API aliases, Find/FindLast/Reverse/RemoveAll(Pred) | 🚫 | `TArrayUnsupportedApiAliases` | Expected compile failure |
| Unbound algorithms, StableSort/Heap/FilterByPredicate and related APIs | 🚫 | `TArrayUnsupportedAlgorithms` | Expected compile failure |
| Nested `TArray<TArray<>>`, including deep/local forms | 🚫 | `TArrayNestedContainers` | Diagnostic: `Containers cannot be nested` |
| Nested `TArray<TMap<>>` / `TArray<TSet<>>` | 🚫 | `TArrayNestedMapAndSetContainers` | Same diagnostic |

## 2. TMap Operations, AngelscriptCoverageTMapAdvancedTests.cpp

| Scenario | Status | Coverage Test Method | Notes / Pending Work |
|------|------|------------|-------------|
| Add/remove/find aggregate | ✅ | `TMapAdvancedOperations` / `TMapOverwriteRemoveContainsKeysValues` | Add/Remove/Contains/Keys/Values |
| Iteration | ✅ | `TMapIteration` | Explicit iterator |
| Key type matrix | ✅ | `TMapKeyTypes` | int/FString/FName and related key types |
| Value type matrix, FString/FVector/int | ✅ | `TMapValueTypes` | Scalar and math struct values |
| User USTRUCT value round trip | ✅ | `TMapUserStructValues` | `TMap<int, user USTRUCT>` Add/Find/index/overwrite round trip |
| FindOrAdd | ✅ | `TMapFindOrAdd` | FindOrAdd semantics |
| Remove operations | ✅ | `TMapRemoveOperations` | Remove variants |
| Empty Map boundary | ✅ | `TMapEdgeCases` | Empty container |
| Unbound API aliases, pointer-style Find/Generate*Array/FindRef and related APIs | 🚫 | `TMapUnsupportedApiAliases` | Expected compile failure |
| Nested `TMap<K,TArray<>>` | 🚫 | `TMapWithArrayValues` | Diagnostic: `Containers cannot be nested` |

## 3. TSet Operations, AngelscriptCoverageTSetAdvancedTests.cpp

| Scenario | Status | Coverage Test Method | Notes / Pending Work |
|------|------|------------|-------------|
| Add/remove/find aggregate | ✅ | `TSetAdvancedOperations` | Add/Remove/Contains |
| Iteration | ✅ | `TSetIteration` | Traversal |
| Supported set operations | ✅ | `TSetSetOperations` | Supported paths such as Append for union |
| Element type matrix | ✅ | `TSetElementTypes` | Element type coverage |
| As parameter | ✅ | `TSetAsParameter` | Parameter semantics |
| Array conversion | ✅ | `TSetArrayConversion` | Set <-> Array |
| Deduplication / reset | ✅ | `TSetDuplicateDedupeRemoveReset` `TSetResetAndCapacity` | Deduplication, Reset, capacity |

## 4. Cross-Container Parameters / Return Values / Non-UPROPERTY

| Scenario | Status | Coverage Test Method | Notes / Pending Work |
|------|------|------------|-------------|
| Containers as parameters, value/in/out/inout | ✅ | `ContainerAsParameter` / `TMapAsParameter` / `TSetAsParameter` | Parameter coverage for all containers |
| Containers as return values | ✅ | `ContainerAsReturnValue` / `TSetAsReturnValue` | Returning containers |
| Container reference return | ✅ | `ContainerReferenceReturn` | Reference return semantics |
| Mixed container parameters | ✅ | `MixedContainerParameters` | Multi-container signatures |
| Advanced iterator operations | ✅ | `ContainerIteratorAdvancedOperations` | Iterator combinations |
| Non-UPROPERTY containers, locals/script-internal | ✅ | `NonUPropertyContainers` | Non-reflected containers |
| Struct containing array, then used as array element, allowed form | ✅ | `ArrayOfStructsContainingArrays` | Uses struct wrapping to avoid nesting limit |
| Nested combinations, uniformly unsupported declarations | 🚫 | `NestedContainerCombinationsUnsupported` | Expected compile failure |

## 5. Nested Container Boundaries, AngelscriptCoverageContainerNestedTests.cpp, All 🚫

> The current fork rejects "container nested inside container" at compile time. This group guards that boundary with negative compile assertions to avoid repeated future attempts.

| Scenario | Status | Coverage Test Method |
|------|------|------------|
| `TArray<TArray<int>>`, two-dimensional | 🚫 | `NestedArrays_TwoDimensionalMatrix` |
| `TArray<TArray<TArray<int>>>`, deep | 🚫 | `NestedArrays_DeepMatrix` |
| Local deep nested array | 🚫 | `NestedArrays_LocalDeepMatrix` |
| `TArray<TMap<int,FString>>` | 🚫 | `ArrayOfMaps` |
| `TMap<int,TArray<int>>` | 🚫 | `MapOfArrays_OneToMany` |
| `TArray<TSet<int>>` | 🚫 | `ArrayOfSets` |
| `TMap<int,TMap<FString,float>>` | 🚫 | `MapOfMaps_TwoDimensionalMapping` |

---

## Summary

| Dimension | Scenarios | Covered (✅) | Pending (⬜) | Boundary (🚫) |
|------|------|----------|----------|---------|
| 1 TArray operations | 19 | 15 | 0 | 4 |
| 2 TMap operations | 10 | 8 | 0 | 2 |
| 3 TSet operations | 7 | 7 | 0 | 0 |
| 4 cross-container parameters/returns | 8 | 7 | 0 | 1 |
| 5 nested boundaries | 7 | 0 | 0 | 7 |

**Corresponding test methods**: 23+11+8+7+7+4 = 60 existing methods.
**Pending (⬜), added by 2026-06-30 deep audit**: none.

**Closed on 2026-07-01**:
- **G5** — TArray out-of-bounds `[]` runtime semantics: `TArrayOutOfBoundsIndexAccess` covers read/write out-of-bounds exceptions.
- **G6** — `TMap<K, user USTRUCT>` value round trip: covered by `TMapUserStructValues`.

The remaining supported surface is covered, while unbound UE APIs and container nesting are locked as 🚫 boundaries. If the fork later binds any API in `../coverage-gaps.md §2.1`, migrate the corresponding 🚫 row to ⬜ and add a positive test.
