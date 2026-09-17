# LANG-CONV-BOOL-CONTEXT

Author reference for `FConvBoolContextGenerator`. This file is not part of the ordinary `.as` projection.

## Axes

Documented order, uppercase catalog tokens, hyphen-separated. Multiword tokens keep internal underscores.

1. Source: `INT8` | `INT16` | `INT` | `INT64` | `UINT8` | `UINT16` | `UINT` | `UINT64` | `FLOAT32` | `FLOAT64` | `BOOL` | `ENUM` | `TYPEDEF`
2. Context: `IF` | `WHILE` | `TERNARY_CONDITION` | `LOGICAL_AND` | `LOGICAL_OR` | `LOGICAL_XOR`
3. Value: `ZERO` | `ONE` | `NEGATIVE`

Product ID prefix: `LANG-CONV-BOOL-CONTEXT`. Complete set: 13×6×3 = 234 cells. Normal-return aggregate = 18 (`BOOL` × every context × every value). Compile reject = 216. Runtime fault = 0.

Example: `LANG-CONV-BOOL-CONTEXT-BOOL-IF-ZERO` → `int EntryLangConvBoolContextBoolIfZero()`.

## Source branches

`enum` / `typedef` helpers appear only on those reject modules.

- `if` / `while`: branch returns 1, else 0
- `ternary_condition`: `SourceValue ? 1 : 0`
- `logical_and`: `SourceValue && true ? 1 : 0`
- `logical_or`: `SourceValue || false ? 1 : 0`
- `logical_xor`: `SourceValue ^^ false ? 1 : 0`

Bool literals are `false` / `true` / `true` for zero / one / negative. Non-bool sources stay reject modules. `BuildBoolConversionSource` is positive-only. Empty `FunctionName` emits `Entry`.

## Observation

`GetExpected` for the 18 normal IDs is `Value != ZERO ? 1 : 0`. Reject and unknown IDs return 0. `BOOL-IF-ZERO` is a real expected zero and keeps `ExpectedReturn` set.

Normal rows are `ReturnValue` + `Standalone`. Reject rows are `CompileReject` with no declaration.
