# LANG-OP-UNARY

Author reference for `FOpUnaryGenerator`. This file is not part of the ordinary `.as` projection.

## Axes

Documented order, uppercase catalog tokens, hyphen-separated.

1. Category: `MUTABLE_LVALUE` | `CONST_LVALUE` | `TEMPORARY` | `FIELD` | `ALIAS`
2. Operation: `POSITIVE_INT8` … `POSITIVE_FLOAT64` | `NEGATIVE_INT8` … `NEGATIVE_FLOAT64` | `BIT_NOT_INT8` … `BIT_NOT_UINT64` (28 pairs)
3. Value: `ZERO` | `ONE` | `NEGATIVE` | `NEAR_MIN` | `NEAR_MAX`

Product ID prefix: `LANG-OP-UNARY`. Complete set: 5×28×5 = 700 cells. All 700 are normal-return. Compile reject = 0. Runtime fault = 0.

Example: `LANG-OP-UNARY-MUTABLE_LVALUE-POSITIVE_INT-ZERO` → `int EntryLangOpUnaryMutableLvaluePositiveIntZero()`.

## Source branches

Shared `ObserveUnaryNumericType` overloads return 201–210. Temporary, field, and alias helpers are type-qualified; alias helpers also include the operation token so `+`/`-`/`~` do not collide. Each entry hardcodes `Type(literal)` from `MakeArgument` (`0`, `1`, `-3`, `min+1`/`max-2`, `max-1`/`max/2`) and applies `+`, `-`, or `~`. Empty `FunctionName` emits `Entry`.

## Observation

`GetExpected` is the result-type marker (201 + result type index). Unary `+`/`-` on unsigned integers promote to the signed width. The int32 is not `ExpectedBits`. All rows are `ReturnValue` + `Standalone` with `bLimitedObservation`. Unknown IDs also return 0 from `GetExpected`; that fallback is not membership proof.
