# LANG-INH-CAST

Author reference for `FInhCastGenerator`. This file is not part of the ordinary `.as` projection.

## Axes

1. Constness: `MUTABLE` | `CONST`
2. Relation: `EXACT` | `UPCAST` | `DOWNCAST_SUCCESS` | `DOWNCAST_FAILURE` | `SIBLING` | `NULL`
3. Use: `ASSIGN` | `ARGUMENT` | `RETURN` | `IDENTITY_COMPARE` | `MEMBER_CALL`

Product ID prefix: `LANG-INH-CAST`. Complete set: 2×6×5 = 60 cells. Normal-return aggregate = 60. Compile reject = 0. Runtime fault = 0.

Example: `LANG-INH-CAST-MUTABLE-EXACT-ASSIGN` → `int EntryLangInhCastMutableExactAssign()`.

## Source branches

Shared once per aggregate: `FCastRoot`, `FCastDerived`, `FCastSibling`, and script-local factories. Every use emits `cast<T>(expr)`. Per-case `ObserveCast` / `ReturnCast` helpers take a unique suffix.

Successful relations: exact, upcast, downcast_success.

## Observation

- identity_compare: 1 for successful relations or null, else 0 (real expected zero for sibling / downcast_failure)
- other uses: 2 for successful relations, else -1

`GetExpected` unknown IDs return 0 without being membership proof. No host notes apply.
