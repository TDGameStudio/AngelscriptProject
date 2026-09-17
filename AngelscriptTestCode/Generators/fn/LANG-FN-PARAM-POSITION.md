# LANG-FN-PARAM-POSITION

Author reference for `FFnParamPositionGenerator`. This file is not part of the ordinary `.as` projection.

## Axes

Documented order, uppercase catalog tokens, hyphen-separated. Multiword tokens keep internal underscores.

1. Direction: `VALUE` | `IN` | `OUT` | `INOUT`
2. Position: `FIRST` | `MIDDLE` | `LAST`
3. Type: `INT8` | `INT16` | `INT` | `INT64` | `UINT8` | `UINT16` | `UINT` | `UINT64` | `FLOAT32` | `FLOAT64` | `BOOL` | `ENUM` | `TYPEDEF` | `SCRIPT_VALUE` | `NATIVE_VALUE`

Product ID prefix: `LANG-FN-PARAM-POSITION`. Complete set: 4×3×15 = 180 cells. Normal-return aggregate = 180. Compile reject = 0. Runtime fault = 0.

Example: `LANG-FN-PARAM-POSITION-VALUE-FIRST-INT8` → `int EntryLangFnParamPositionValueFirstInt8()`.

## Source branches

Each cell emits a unique three-parameter `Probe` plus an `int` entry. The typed target occupies `FIRST` / `MIDDLE` / `LAST`; the other two slots are `int` sentinels `101` / `202` / `303`. Aggregate and dump uniquify probe names from the entry stem. Isolated `Entry` / `ProbeEntry` modules keep the short `Probe` name. Shared `ENativeCaseEnum` and `FScriptCaseValue` appear once in the aggregate.

`OUT` and `INOUT` write a near-maximum (or object `1`) into the target. `INOUT` bool writes the zero-literal. Scalar entries construct the zero-literal for `OUT` and the one-literal otherwise. Object entries always construct `Type(1)`, including `OUT`, matching the cited legacy oracle. The entry then calls `Probe` with `Target` in the selected slot and requires both sentinel checks and the post-call target value.

`BuildParameterPositionSource` is positive-only. Empty `FunctionName` emits `Entry`. Invalid identifiers such as `bad-name` emit no source.

## Observation

Independent observation is `1` for every cell. `GetExpected` returns that value for the 180 IDs and `0` for unknown IDs. That zero fallback is not membership proof. There is no real expected-zero normal cell.

Normal rows are `ReturnValue`. `TYPEDEF` and `NATIVE_VALUE` are `RequiresHostSetup`; all others are `Standalone`. No lifecycle or limited-observation notes apply.
