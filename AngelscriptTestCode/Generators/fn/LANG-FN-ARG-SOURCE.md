# LANG-FN-ARG-SOURCE

Author reference for `FFnArgSourceGenerator`. This file is not part of the ordinary `.as` projection.

## Axes

Documented order, uppercase catalog tokens, hyphens between axes and underscores inside multiword values.

1. Direction: `VALUE` | `IN` | `OUT` | `INOUT`
2. Source: `LITERAL` | `LOCAL_LVALUE` | `CONST_LOCAL` | `GLOBAL_CONST` | `FIELD` | `FUNCTION_RETURN` | `ARITHMETIC_EXPRESSION` | `CONDITIONAL_EXPRESSION` | `NULL` | `BASE_VIEW` | `DERIVED_VIEW`

Product ID prefix: `LANG-FN-ARG-SOURCE`. Complete set: 4×11 = 44 cells. Normal-return aggregate = 22. Compile reject = 17. Runtime fault = 5 (`BASE_VIEW` all compiling directions plus `DERIVED_VIEW-VALUE`). Faults stay in `BuildAllSource` / `OutCaseCount` (27 non-reject).

Example: `LANG-FN-ARG-SOURCE-VALUE-LITERAL` → `int EntryLangFnArgSourceValueLiteral()`.

## Source branches

Shared helpers once in the aggregate: `GlobalConstValue`, `ProvideValue`, `FHolder`, `FBase`, `FDerived`. Each cell has a unique `Probe` plus entry locals for its source.

- `LITERAL`: argument `7`
- `LOCAL_LVALUE`: `int Value = 7;` then `Value`
- `CONST_LOCAL`: `const int Value = 7;`
- `GLOBAL_CONST`: `GlobalConstValue`
- `FIELD`: `FHolder Holder;` then `Holder.Value`
- `FUNCTION_RETURN`: `ProvideValue()`
- `ARITHMETIC_EXPRESSION`: `3 + 4`
- `CONDITIONAL_EXPRESSION`: `true ? 7 : 8`
- `NULL`: `FNativeCaseReference NullValue = nullptr;`
- `BASE_VIEW` / `DERIVED_VIEW`: constructed `FBase` / `FDerived` with `Value = 7`

`out`/`inout` probes write `9` (or `FDerived()` for object sources). `BuildArgumentSource` is positive-only.

## Observation

- Readable non-null: 7
- Readable null: 1
- Writable int/field: 18
- `BASE_VIEW` / `DERIVED_VIEW`: `RuntimeException` text `Null pointer access`; `GetExpected` is 0
- Reject and unknown IDs: `GetExpected` is 0 and is not membership proof

`NULL` rows are `RequiresHostSetup` (`FNativeCaseReference`). Fault rows stay executable declarations in the aggregate.
