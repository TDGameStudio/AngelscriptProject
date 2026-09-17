# LANG-REF-FORK-DERIVED-INREF

Author reference for `FRefForkDerivedInrefGenerator`. This file is not part of the ordinary `.as` projection.

## Axes

Documented order, uppercase catalog tokens, hyphen-separated. Multiword tokens keep internal underscores.

1. Source: `DERIVED`
2. Target: `BASE_INREF`

Product ID prefix: `LANG-REF-FORK-DERIVED-INREF`. The single catalog member keeps the inspected identity `LANG-REF-FORK-DERIVED-TO-BASE-INREF` rather than a cartesian rewrite. Complete set: 1 cell. Normal-return aggregate = 0. Compile reject = 1. Runtime fault = 0.

Example: `LANG-REF-FORK-DERIVED-TO-BASE-INREF` → `int EntryLangRefForkDerivedToBaseInref()`.

## Source branches

One reject module:

- `FRefDerived Source = MakeRefDerived(16);`
- `RequireRootInput(Source, Source)` against a host `const FRefRoot&in` pair

`BuildRefForkDerivedInrefSource` is positive-only and always returns empty. `BuildRejectSource` and `ListRejectCaseIds` own the one module. `BuildAllSource` emits no entries and reports `OutCaseCount = 0`.

## Observation

There are no normal-return cells. `GetExpected` returns 0 for every ID including unknown IDs. That zero fallback is not membership proof.

The row is `CompileReject` with no declaration and `SourceOnly` execution. Host recovery after the derived-to-base input-reference diagnostic is outside this source product.
