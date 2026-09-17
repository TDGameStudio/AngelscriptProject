# LANG-OP-COMPARISON-OVERLOAD

Author reference for `FOpComparisonOverloadGenerator`. This file is not part of the ordinary `.as` projection.

Naming assumed: `EOpComparisonOverloadOperator` — product stem plus Operator axis.
Naming assumed: `EOpComparisonOverloadRelation` — product stem plus OverloadRelation axis.
Naming assumed: `EOpComparisonOverloadOrder` — product stem plus Order axis.
Naming assumed: `EOpComparisonOverloadReceiver` — product stem plus Receiver axis.

## Axes

Documented order, uppercase catalog tokens, hyphen-separated. Multiword tokens keep internal underscores.

1. Operator: `LESS` | `LESS_EQUAL` | `GREATER` | `GREATER_EQUAL` | `EQUAL` | `NOT_EQUAL`
2. Relation: `LESS` | `EQUAL` | `GREATER` | `UNEQUAL`
3. Order: `LEFT_RIGHT` | `RIGHT_LEFT`
4. Receiver: `MUTABLE` | `CONST`

Complete set: 6 × 4 × 2 × 2 = 96 cells. All normal-return. Compile reject = 0. Runtime fault = 0.

Example: `LANG-OP-COMPARISON-OVERLOAD-LESS-LESS-LEFT_RIGHT-MUTABLE` → `int EntryLangOpComparisonOverloadLessLessLeftRightMutable()`.

## Source branches

Shared helper, emitted once: `struct FOverloadedComparisonValue` with host ctor/dtor, mutable/const `opCmp` (markers 101/102) and `opEquals` (201/202).

Relation values: less `(1,2)`, equal `(2,2)`, greater `(3,2)`, unequal `(-4,5)`.

`CONST` applies to the expression receiver only: Left on `LEFT_RIGHT`, Right on `RIGHT_LEFT`. Comparison text is `Left <op> Right` or `Right <op> Left`. Empty `FunctionName` emits `Entry`.

## Observation

`GetExpected = ExpectedComparison(expressionLeft, expressionRight, op) ? 1 : 0`. `LESS` + `EQUAL` is a real expected zero and keeps `ExpectedReturn` set. Unknown `GetExpected` is 0 and is not membership.

All rows are `ReturnValue` + `RequiresHostSetup`. Host notes name the lifecycle and overload recorders.
