# LANG-OP-COMPARISON-ENUM-ALIAS

Author reference for `FOpComparisonEnumAliasGenerator`. This file is not part of the ordinary `.as` projection.

Naming assumed: `EOpComparisonEnumAliasFamily` — product stem plus IntegralFamily axis.
Naming assumed: `EOpComparisonEnumAliasOperator` — product stem plus Operator axis.
Naming assumed: `EOpComparisonEnumAliasPair` — product stem plus IntegralPair axis.
Naming assumed: `EOpComparisonEnumAliasOrder` — product stem plus Order axis.

## Axes

Documented order, uppercase catalog tokens, hyphen-separated. Multiword tokens keep internal underscores.

1. Family: `ENUM` | `ALIAS`
2. Operator: `LESS` | `LESS_EQUAL` | `GREATER` | `GREATER_EQUAL` | `EQUAL` | `NOT_EQUAL`
3. Pair: `EQUAL_ZERO` | `EQUAL_NAMED` | `BELOW_ADJACENT` | `ABOVE_ADJACENT` | `MINIMUM_BOUNDARY` | `MAXIMUM_BOUNDARY`
4. Order: `LEFT_RIGHT` | `RIGHT_LEFT`

Complete set: 2 × 6 × 6 × 2 = 144 cells. All normal-return. Compile reject = 0. Runtime fault = 0.

Example: `LANG-OP-COMPARISON-ENUM-ALIAS-ENUM-LESS-EQUAL_ZERO-LEFT_RIGHT` → `int EntryLangOpComparisonEnumAliasEnumLessEqualZeroLeftRight()`.

## Source branches

Shared helpers, emitted once:

- `enum EComparisonEnum { Minimum = -128, MinusOne = -1, Zero = 0, One = 1, Maximum = 127 }`
- comment that `ComparisonAlias` is registered by the host
- `TraceEnumOperand` / `TraceAliasOperand` calling `RecordComparisonIntegerOperand`

Pair literals: `(0,0)` `(1,1)` `(-1,0)` `(1,0)` `(-128,-1)` `(127,1)`. Enum uses named enumerators; alias uses `ComparisonAlias(n)`.

- `LEFT_RIGHT`: `Trace*(1, Left) <op> Trace*(2, Right)`
- `RIGHT_LEFT`: `Trace*(2, Right) <op> Trace*(1, Left)`

Empty `FunctionName` emits `Entry`. `bad-name` emits no source.

## Observation

`GetExpected = ExpectedComparison(expressionLeft, expressionRight, op) ? 1 : 0` after applying order. `EQUAL_ZERO` + `LESS` is a real expected zero and keeps `ExpectedReturn` set. Unknown IDs also return 0; that fallback is not membership.

All rows are `ReturnValue` + `RequiresHostSetup`. Host notes name `RecordComparisonIntegerOperand` and the alias typedef.
