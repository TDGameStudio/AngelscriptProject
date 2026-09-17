# LANG-OP-INCREMENT-TYPE-REJECTION

Author reference for `FOpIncrementTypeRejectionGenerator`. This file is not part of the ordinary `.as` projection.

## Axes

Documented order, uppercase catalog tokens, hyphen-separated.

1. Category: `LOCAL` | `FIELD` | `PROPERTY` | `ALIAS`
2. Operator: `PRE_INCREMENT` | `POST_INCREMENT` | `PRE_DECREMENT` | `POST_DECREMENT`

Product ID prefix: `LANG-OP-INCREMENT-TYPE-REJECTION`. Complete set: 4×4 = 16 cells. All 16 are compile reject of `bool ++/--`. Aggregate count = 0.

Example: `LANG-OP-INCREMENT-TYPE-REJECTION-LOCAL-PRE_INCREMENT` → isolated `int EntryLangOpIncrementTypeRejectionLocalPreIncrement()`.

## Source branches

Local mutates a `bool Value`. Field uses `FRejectedBoolIncrementField`. Property uses host `MakeIncrementProperty_bool`. Alias mutates a local `bool Value`. Causal marker: `INCREMENT_CAUSE`. Typed `BuildBoolRejectionSource` emits reject source; `bad-name` and invalid enums emit empty.

## Observation

No normal-return integer. `GetExpected` is 0 for every ID; membership is `ListCases` / `ListRejectCaseIds`.
