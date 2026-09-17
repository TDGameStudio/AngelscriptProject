# LANG-OP-UNARY-REJECTION

Author reference for `FOpUnaryRejectionGenerator`. This file is not part of the ordinary `.as` projection.

## Axes

Documented order, uppercase catalog tokens, hyphen-separated.

1. Category: `MUTABLE_LVALUE` | `CONST_LVALUE` | `TEMPORARY` | `FIELD` | `ALIAS`
2. Failure: `POSITIVE_BOOL` | `NEGATIVE_BOOL` | `BIT_NOT_BOOL` | `LOGICAL_NOT_SIGNED` | `LOGICAL_NOT_UNSIGNED` | `LOGICAL_NOT_FLOAT` | `BIT_NOT_FLOAT32` | `BIT_NOT_FLOAT64`

Product ID prefix: `LANG-OP-UNARY-REJECTION`. Complete set: 5×8 = 40 cells. Normal-return = 0. Compile reject = 40. Runtime fault = 0.

Example: `LANG-OP-UNARY-REJECTION-MUTABLE_LVALUE-POSITIVE_BOOL` → isolated `int EntryLangOpUnaryRejectionMutableLvaluePositiveBool()`.

## Source branches

Each reject module is isolated. Temporary emits `MakeInvalidUnaryTemporary`; field emits `FInvalidUnaryOwner`. The invalid operator is applied to a category-specific operand and marked `// UNARY_CAUSE`. `BuildAllSource` is empty with `OutCaseCount = 0`. `BuildUnaryFailureSource` is the typed reject constructor: empty `FunctionName` emits `Entry`; `ProbeEntry` changes only that identity.

## Observation

There is no normal-return oracle. `GetExpected` is 0 for every listed reject and for unknown IDs. That fallback is not membership proof. Consumers use `ListCases` / `ListRejectCaseIds` and isolated `BuildRejectSource`.
