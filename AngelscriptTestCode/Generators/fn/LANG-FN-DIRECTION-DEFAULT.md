# LANG-FN-DIRECTION-DEFAULT

Author reference for `FFnDirectionDefaultGenerator`. This file is not part of the ordinary `.as` projection.

## Axes

1. Type: `INT8` | `INT16` | `INT` | `INT64` | `UINT8` | `UINT16` | `UINT` | `UINT64` | `FLOAT32` | `FLOAT64` | `BOOL`
2. Direction: `VALUE` | `IN` | `OUT` | `INOUT`
3. Default state: `NONE_EXPLICIT` | `NONE_OMITTED` | `PRESENT_EXPLICIT` | `PRESENT_OMITTED`
4. Target: `GLOBAL` | `NAMESPACE_GLOBAL` | `INSTANCE_METHOD`

Complete set: 11×4×4×3 = 528 cells. Normal-return aggregate = 309. Compile reject = 219.

Example: `LANG-FN-DIRECTION-DEFAULT-INT8-VALUE-NONE_EXPLICIT-GLOBAL`.

## Source branches

Script type spellings: integers/bool keep their names; `float32` and `float64` stay explicit. Zero/one literals: `0`/`1`, `0.0f`/`1.0f`, `0.0`/`1.0`, `false`/`true`.

A `bool` probe reads the expected value when the direction reads and writes `One` when the direction writes. The int entry returns that bool as `1`/`0`, plus writeback `Value == One` when an explicit argument is written.

`NONE_OMITTED` always rejects. `PRESENT_OMITTED` compiles for `value`, for `in` only on `{int,float32,float64,bool}`, and rejects `out`/`inout`.

## Observation

Every normal cell's `ExpectedReturn` is 1. Reject and unknown `GetExpected` is 0. Entry declaration is `int Entry<PascalCase>()`. No host registration is required for these primitive cells.
