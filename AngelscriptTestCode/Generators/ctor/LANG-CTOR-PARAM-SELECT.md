# LANG-CTOR-PARAM-SELECT

Author reference for `FCtorParamSelectGenerator`. This file is not part of the ordinary `.as` projection.

## Axes

Documented order, uppercase catalog tokens, hyphen-separated. Multiword tokens keep internal underscores.

1. Arity: `ONE` | `TWO` | `FIVE` | `SIXTEEN` (counts 1, 2, 5, 16)
2. Selection: `EXACT` | `PROMOTION` | `EXPLICIT_CONVERSION` | `AMBIGUOUS` | `MISSING`
3. Type: first 15 NativeTypeCases — `INT8` | `INT16` | `INT` | `INT64` | `UINT8` | `UINT16` | `UINT` | `UINT64` | `FLOAT32` | `FLOAT64` | `BOOL` | `ENUM` | `TYPEDEF` | `SCRIPT_VALUE` | `NATIVE_VALUE`

Product ID prefix: `LANG-CTOR-PARAM-SELECT`. Complete set: 4×5×15 = 300 cells. Normal-return aggregate = 152. Compile reject = 148. Runtime fault = 0.

Reject: every `AMBIGUOUS` and `MISSING` cell, plus `PROMOTION` when the type is not `INT8`, `INT16`, `INT`, `UINT8`, `UINT16`, `UINT`, `FLOAT32`, or `TYPEDEF`.

Example: `LANG-CTOR-PARAM-SELECT-ONE-EXACT-INT8` → `int EntryLangCtorParamSelectOneExactInt8()`.

## Source branches

Shared helpers, emitted once per aggregate or isolated reject module:

- `RecordConstructorArgument`, `RecordConstructorParameterConsumed`, `RecordConstructorSelected`
- `ENativeCaseEnum`, `typedef int NativeCaseAlias`, `FScriptCaseValue`, `FNativeCaseValue`, `FNoPromotion`, `FNoMatch`
- one `Observe{Type}` function per type

Each cell owns `struct FConstructorProbe{Arity}{Selection}{Type}` so checksum state cannot leak. Arguments are `Observe{Type}(i, literal)` with bool `true`/`false`, enum `ENativeCaseEnum::Value{N}`, otherwise `Type(N)`. Explicit conversion wraps that expression in the explicit target type.

`BuildConstructorParameterSource` is positive-only. Empty `FunctionName` emits `Entry`.

## Observation

Checksum: for `i = 0 .. N-1`, bool contributes `1` on even `i` and `0` on odd `i`; every other type contributes `i+1`. Sum is `N(N+1)/2` except bool (`ONE`→1, `TWO`→1, `FIVE`→3, `SIXTEEN`→8).

`GetExpected` uses that checksum for the 152 normal IDs and returns 0 for reject and unknown IDs. Normal rows are `ReturnValue` + `RequiresHostSetup`.
