# LANG-OP-INCREMENT-TARGET-REJECTION

Author reference for `FOpIncrementTargetRejectionGenerator`. This file is not part of the ordinary `.as` projection.

## Axes

Documented order, uppercase catalog tokens, hyphen-separated.

1. Target: `CONST_INVALID` | `TEMPORARY_INVALID`
2. Operator: `PRE_INCREMENT` | `POST_INCREMENT` | `PRE_DECREMENT` | `POST_DECREMENT`
3. Type: `INT8` | `INT16` | `INT` | `INT64` | `UINT8` | `UINT16` | `UINT` | `UINT64` | `FLOAT32` | `FLOAT64`

Product ID prefix: `LANG-OP-INCREMENT-TARGET-REJECTION`. Complete set: 2×4×10 = 80 cells. All 80 are compile reject. Aggregate count = 0.

Example: `LANG-OP-INCREMENT-TARGET-REJECTION-CONST_INVALID-PRE_INCREMENT-INT` → isolated `int EntryLangOpIncrementTargetRejectionConstInvalidPreIncrementInt()`.

## Source branches

Const targets mutate `const T Value`. Temporary targets call `++/--MakeRejectedIncrementTemporary(Input)` after a producer helper that records `RecordIncrementRejectedProducer`. Causal marker: `INCREMENT_CAUSE`. Typed `BuildTargetRejectionSource` emits reject source; `bad-name` and invalid enums emit empty.

## Observation

No normal-return integer. `GetExpected` is 0 for every ID, including known rejects; membership is `ListCases` / `ListRejectCaseIds`.
