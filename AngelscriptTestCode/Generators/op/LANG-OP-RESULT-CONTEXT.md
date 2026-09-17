# LANG-OP-RESULT-CONTEXT

Author reference for `FOpResultContextGenerator`. This file is not part of the ordinary `.as` projection.

## Axes

Documented order, uppercase catalog tokens, hyphen-separated.

1. Family: `UNARY` | `ARITHMETIC` | `POWER` | `BITWISE` | `SHIFT` | `COMPARISON` | `LOGICAL` | `ASSIGNMENT` | `INCREMENT` | `OVERLOADED`
2. Context: `ASSIGNMENT` | `RETURN` | `CONDITION` | `OVERLOAD_ARGUMENT` | `CHAIN` | `SWITCH_OR_INDEX`
3. Outcome: `EXACT` | `CONVERTED` | `AMBIGUOUS` | `REJECTED`

Product ID prefix: `LANG-OP-RESULT-CONTEXT`. Complete set: 10×6×4 = 240 cells. Non-reject aggregate = 180. Compile reject = 60. Runtime fault = 0.

Example: `LANG-OP-RESULT-CONTEXT-UNARY-ASSIGNMENT-EXACT` → `int EntryLangOpResultContextUnaryAssignmentExact()`.

## Source branches

Shared consumers (`TraceInt`/`TraceFloat`/`TraceBool`, `VerifyExact`/`VerifyConverted`, `FContextValue`, `FContextIndexProbe`, reject/ambiguous helpers) occur once per aggregate. Each family emits its operator expression. Return context adds a case-qualified `ReturnContextProbe_<Entry>`. Rejected outcomes are isolated modules. Empty `FunctionName` emits `Entry`. Positive-only `BuildSource` rejects `REJECTED` cells.

## Categories

`REJECTED` is compile reject (60). `AMBIGUOUS` stays in the aggregate as source-only limited observation: the current fork resolves the tied conversion set and has no exact int32 observation. `EXACT` and `CONVERTED` are standalone `ReturnValue` rows.

## Observation

`GetExpected` is 1 for exact/converted (`ExecuteExactFunction(..., 1)`). Ambiguous and rejected return 0. Unknown IDs also return 0 from `GetExpected`; that fallback is not membership proof. Host/lifecycle recovery stays out of this source product.
