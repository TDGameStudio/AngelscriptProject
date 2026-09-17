# LANG-REF-DIRECTION-FORK-GLOBAL

Author reference for `FRefDirectionForkGlobalGenerator`. This file is not part of the ordinary `.as` projection.

## Axes

Documented order, uppercase catalog tokens, hyphen-separated.

1. State: `MUTABLE`

Product ID prefix: `LANG-REF-DIRECTION-FORK-GLOBAL`. Complete set: 1 cell. Normal-return aggregate = 0. Compile reject = 1. Runtime fault = 0.

Example: `LANG-REF-DIRECTION-FORK-GLOBAL-MUTABLE` → `int EntryLangRefDirectionForkGlobalMutable()`.

## Source branches

One reject module:

- mutable script global `int GReferenceDirectionForkRestriction = 0;`
- unique entry returns that global

`BuildRefDirectionForkGlobalSource` is positive-only and always returns empty. `BuildRejectSource` and `ListRejectCaseIds` own the one module. `BuildAllSource` emits no entries and reports `OutCaseCount = 0`.

## Observation

There are no normal-return cells. `GetExpected` returns 0 for every ID including unknown IDs. That zero fallback is not membership proof.

The row is `CompileReject` with no declaration and `SourceOnly` execution. Host recovery after the mutable-global diagnostic is outside this source product.
