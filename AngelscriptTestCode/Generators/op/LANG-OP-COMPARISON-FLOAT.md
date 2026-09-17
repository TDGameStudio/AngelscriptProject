# LANG-OP-COMPARISON-FLOAT

Author reference for `FOpComparisonFloatGenerator`. This file is not part of the ordinary `.as` projection.

Naming assumed: `EOpComparisonFloatType` — product stem plus FloatType axis.
Naming assumed: `EOpComparisonFloatOperator` — product stem plus Operator axis.
Naming assumed: `EOpComparisonFloatValue` — product stem plus FloatValue axis.
Naming assumed: `EOpComparisonFloatOrder` — product stem plus Order axis.

## Axes

Documented order, uppercase catalog tokens, hyphen-separated. Multiword tokens keep internal underscores. Engine-property float spelling is normalized to catalog `float32` / `float64`.

1. Type: `FLOAT32` | `FLOAT64`
2. Operator: `LESS` | `LESS_EQUAL` | `GREATER` | `GREATER_EQUAL` | `EQUAL` | `NOT_EQUAL`
3. Value: `NEGATIVE_ZERO` | `POSITIVE_ZERO` | `NAN` | `POSITIVE_INFINITY` | `NEGATIVE_INFINITY` | `MINIMUM` | `MAXIMUM` | `EQUAL_PAIR`
4. Order: `LEFT_RIGHT` | `RIGHT_LEFT`

Complete set: 2 × 6 × 8 × 2 = 192 cells. All normal-return. Compile reject = 0. Runtime fault = 0.

Example: `LANG-OP-COMPARISON-FLOAT-FLOAT32-LESS-NEGATIVE_ZERO-LEFT_RIGHT` → `int EntryLangOpComparisonFloatFloat32LessNegativeZeroLeftRight()`.

## Source branches

No shared helpers. Each entry hardcodes Left/Right literals and traces:

- zeros: `-0.0` vs `0.0` (order depends on the value case)
- nan: `0.0 / 0.0` vs `1.0`
- +inf: `1.0 / 0.0` vs type max
- -inf: `-1.0 / 0.0` vs type min
- minimum / maximum: catalog extremes vs `-1.0` / `1.0`
- equal_pair: `13.25`

`LEFT_RIGHT` uses `TraceFloat*(1, Left) <op> TraceFloat*(2, Right)`. Empty `FunctionName` emits `Entry`.

## Observation

Independent relation of the value case, swapped on `RIGHT_LEFT`:

- zeros and `EQUAL_PAIR` → equal
- `MINIMUM` / `NEGATIVE_INFINITY` → less
- `MAXIMUM` / `POSITIVE_INFINITY` → greater
- `NAN` → unordered; fork CMPf/CMPd maps unordered to greater / greater_equal / not_equal true

`NEGATIVE_ZERO` + `LESS` is a real expected zero and keeps `ExpectedReturn` set. Unknown `GetExpected` is 0 and is not membership.

All rows are `ReturnValue` + `RequiresHostSetup`. Host notes name the float trace functions.
