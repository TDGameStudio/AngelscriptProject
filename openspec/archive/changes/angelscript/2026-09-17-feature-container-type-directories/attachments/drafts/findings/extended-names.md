# The leaf must say what the case observes

Source: draft finding (Chinese original; approval R5). Language already uses `ClassHandleCast`. Pending used `TArrayAddAndOrder.as`. Flat `TArray.as` and short `add.as` are both rejected.

```
TArray.as                         // FileTag names only the type
add.as                            // method alias; body is insertion order
Language/Casting/ClassHandleCast.as
Pending/.../TArrayAddAndOrder.as
```

`array` is worse: the tag looks like “the whole array”, the summary says Last() is 40, the body tests empty construction.

## Rule (R5)

Leaf = lengthened Pascal observation, not a method alias. The directory already names the type. Do not prefix `TArray`.

```
Containers/<Type>/<Observation>.as
Containers/<Type>/CompileFail/<Observation>.as
Containers/<Type>/RuntimeFail/<Observation>.as
```

- FileTag = path without `.as`. `Get(Containers/TArray/AddAndOrder, AddAndOrder)`
- One `@begin` per file; tag equals the Pascal stem
- Filename states the assertion
- Type-axis variants are their own files: `AddAndOrderFString.as`
- Fail uses the same grain: `IndexOutOfBounds.as`

Must not: a type-root `TArray.as`; short or axis names (`add`, `Queries_02-is-valid`); `TArrayAddAndOrder.as`.

## TArray current `@begin` → observation

Name from the body, not the old tag.

| current @begin | body actually asserts | Pascal |
|---|---|---|
| array | default int32/FName empty | EmptyConstruction |
| swap | Swap(0,2) exchanges 10 and 30 | SwapElements |
| last | Last() write-through, Last(1) from end | LastValidIndex |
| copy | Copy source [1..2] onto dest[0] | CopyRange |
| for | range-for visits every element | ForEachElement |
| empty-iterator-canproceed-false | empty mutable iterator cannot Proceed | EmptyIteratorCannotProceed |
| empty-const-iterator-cannotproceed | empty const iterator cannot Proceed | EmptyConstIteratorCannotProceed |
| assignment | copy assign | CopyAssign |
| move-assign-from | move from rvalue | MoveAssignFrom |
| add | Add insertion order | AddAndOrder |
| append | Append another array | AppendOtherArray |
| insert | Insert shifts following | InsertShiftsFollowing |
| add-unique | duplicate AddUnique is false | AddUniqueRejectsDuplicate |
| empty / reset | Num 0 | EmptyClearsNum / ResetClearsNum |
| index | `[]` read/write | IndexAccess |
| num | Num counts elements | NumCountsElements |
| property | UPROPERTY TArray | ObjectProperty |
| u-object-references | UObject elements | UObjectReferences |

Coverage uses the same grain: `ReserveClampsBelowNum`, `InsertIndexPastNum`. Pointer pockets that are already long only Pascalize. Full other-type trees: [per-type-trees.md](per-type-trees.md).
