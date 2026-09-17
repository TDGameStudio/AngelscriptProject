# LANG-CONV-ENUM-ALIAS

Author reference for `FConvEnumAliasGenerator`. This file is not part of the ordinary `.as` projection.

## Axes

Documented order, uppercase catalog tokens, hyphen-separated. Multiword tokens keep internal underscores.

1. Source: `ENUM` | `ALIAS_INT8` | `ALIAS_INT` | `ALIAS_INT64` | `ALIAS_UINT` | `ALIAS_UINT64`
2. Target: `ENUM` | `INT8` | `INT` | `INT64` | `UINT` | `UINT64` | `FLOAT64`
3. Form: `ASSIGNMENT` | `INITIALIZER` | `ARGUMENT` | `RETURN` | `PROMOTION` | `EXPLICIT_CAST`
4. Value: `ZERO` | `ONE` | `NEGATIVE` | `NEAR_MIN` | `NEAR_MAX`

Product ID prefix: `LANG-CONV-ENUM-ALIAS`. Complete set: 6×7×6×5 = 1260 cells. Normal-return aggregate = 1130. Compile reject = 130. Runtime fault = 0.

Example: `LANG-CONV-ENUM-ALIAS-ENUM-ENUM-ASSIGNMENT-ZERO` → `int EntryLangConvEnumAliasEnumEnumAssignmentZero()`.

## Source branches

Shared once in the aggregate: `enum EConversionEnum` and the five `typedef` aliases. Pass/return helpers are type-qualified (`PassEnumAliasTargetInt8`, `ReturnEnumAliasTargetEnumFloat64`). This fork emits `float` for the `FLOAT64` target.

- `ASSIGNMENT` / `INITIALIZER`: direct store of `SourceValue`
- `ARGUMENT`: `PassEnumAliasTarget<Target>(SourceValue)`
- `RETURN`: `ReturnEnumAliasTarget<Source><Target>(SourceValue)`
- `PROMOTION`: `SourceValue + Target(0)`
- `EXPLICIT_CAST`: `Target(SourceValue)` only; alias-to-enum explicit casts stay normal

Rejects match `LANG-CONV-FAILURE` `numeric_to_enum`: implicit `ALIAS_*` → `ENUM` (125) and `ENUM` → `ENUM` `PROMOTION` (5). `BuildEnumAliasConversionSource` is positive-only.

## Observation

Normal `GetExpected` is 1 after `ActualValue == ExpectedValue`. Expected literals follow `SourceValueForCase` plus signed/unsigned normalize or `%.17g` for float64. `alias_uint` wraps through `uint32`; `alias_uint64` through `uint64` then int64 bits.

`GetExpected` returns 0 for reject and unknown IDs. That zero fallback is not membership proof. There is no real expected-zero cell.
