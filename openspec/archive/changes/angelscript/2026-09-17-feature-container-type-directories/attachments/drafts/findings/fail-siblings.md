# Fail sibling completion

Source: draft finding (Chinese original; approval R3/R6). Quality deletes leftover fragments. Coverage adds independent `@begin` cases from Bind Throw text only.

Destination FileTags are `Containers/<Type>/CompileFail/<Observation>` and `.../RuntimeFail/<Observation>`. The table below names the current flat pockets being retired.

| current flat FileTag | current begins | quality | Bind throws still missing |
|---|---|---|---|
| `Containers/TArrayRuntimeFail` | 22 | leftover Pending comments | InsertIndexPastNum, SwapSecondIndexOutOfBounds, LastIndexFromEndOutOfBounds, IteratorProceedPastEnd, RemoveAtSwapOutOfBounds |
| `Containers/TArrayCompileFail` | 18 | repeated UCLASS | enough; do not invent unbound APIs |
| `Containers/TMapRuntimeFail` | 2 | leftover comments; iterator summary overclaims | GetKey/SetValue/RemoveCurrent without Proceed; IndexMissingKeyWrite |
| `Containers/TMapCompileFail` | 19 | repeated UCLASS | enough |
| `Containers/TSetRuntimeFail` | 1 | leftover comment | IteratorProceedPastEnd |
| `Containers/TSetCompileFail` | 16 | repeated UCLASS | enough; keep non-TSet Pending files out |
| `Containers/TOptionalRuntimeFail` | 1 | leftover comment | GetValueAfterReset, GetValueAfterAssignUnset |
| `Containers/TOptionalCompileFail` | 8 | repeated UCLASS | `TOptional<TSet<int>>` only if Validate rejects it |
| `Containers/TSoftObjectPtrCompileFail` | 2 | clean | optional `TSoftObjectPtr<int>` |
| TSoftObjectPtr RuntimeFail | none | — | Actor LoadAsync forbidden; AssignClass not subtype. Create the directory only with Bind evidence |
| `Containers/TSubclassOfRuntimeFail` | 1 | Set only | opAssign and implicit construct |
| SoftObjectPath Fail | none | Pending has `::::` | only if Bind still diagnoses it |

## TArray Throw sentences

`Bind_TArray.cpp` / `Bind_TArray.h` are the only coverage oracle. Named destination leaves: `InsertIndexPastNum`, `SwapSecondIndexOutOfBounds`, `LastIndexFromEndOutOfBounds`, `IteratorProceedPastEnd`. Do not write `AS_ITERATOR_DEBUGGING` cases unless that config is the test host.

## TMap `[]`

`Bind_TMap.h` OpIndex: a missing key always throws `Could not find key in map for index operator.` Mutable does not default-insert. Add `IndexMissingKeyWrite`. Do not write a default-insert case.

## Fail author shape

`@begin InsertIndexPastNum`; summary holds the Throw sentence; one condition per file. `@topic Containers`. No leftover `with Add(10);` lines.
