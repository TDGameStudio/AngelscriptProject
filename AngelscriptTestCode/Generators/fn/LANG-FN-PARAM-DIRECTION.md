# LANG-FN-PARAM-DIRECTION

Author reference for `FFnParamDirectionGenerator`. This file is not part of the ordinary `.as` projection.

## Axes

Documented order, uppercase catalog tokens, hyphen-separated. Multiword tokens keep internal underscores.

1. Direction: `VALUE` | `IN` | `OUT` | `INOUT`
2. Type: `INT8` | `INT16` | `INT` | `INT64` | `UINT8` | `UINT16` | `UINT` | `UINT64` | `FLOAT32` | `FLOAT64` | `BOOL` | `ENUM` | `TYPEDEF` | `SCRIPT_VALUE` | `NATIVE_VALUE`

Product ID prefix: `LANG-FN-PARAM-DIRECTION`. Complete set: 4×15 = 60 cells. Normal-return aggregate = 60. Compile reject = 0. Runtime fault = 0.

Example: `LANG-FN-PARAM-DIRECTION-VALUE-INT8` → `int EntryLangFnParamDirectionValueInt8()`.

## Source branches

Each cell emits a unique `Probe` plus an `int` entry. Aggregate and dump uniquify probe names from the entry stem. Isolated `Entry` / `ProbeEntry` modules keep the short `Probe` name. Shared `ENativeCaseEnum` and `FScriptCaseValue` appear once in the aggregate.

- `VALUE` / `IN`: `bool Probe(Type[& in] Value)` returns the one-literal read; the entry constructs that literal and requires the probe and post-call value both still match.
- `OUT`: `void Probe(Type& out Value)` writes the one-literal; the entry starts from the zero-literal and observes the write.
- `INOUT`: `void Probe(Type& inout Value)` reads then writes the one-literal; the entry starts from the one-literal.

Object types (`SCRIPT_VALUE`, `NATIVE_VALUE`) compare and assign `.Value`. `TYPEDEF` uses host `NativeCaseAlias`.

`BuildParameterDirectionSource` is positive-only. Empty `FunctionName` emits `Entry`. Invalid identifiers such as `bad-name` emit no source.

## Observation

Independent observation is `1` for every cell. `GetExpected` returns that value for the 60 IDs and `0` for unknown IDs. That zero fallback is not membership proof. There is no real expected-zero normal cell.

Normal rows are `ReturnValue`. `TYPEDEF` and `NATIVE_VALUE` are `RequiresHostSetup`; all others are `Standalone`. No lifecycle or limited-observation notes apply.
