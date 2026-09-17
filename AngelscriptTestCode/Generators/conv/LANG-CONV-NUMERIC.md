# LANG-CONV-NUMERIC

Author reference for `FConvNumericGenerator`. This file is not part of the ordinary `.as` projection.

## Axes

Documented order, uppercase catalog tokens, hyphen-separated. Multiword tokens keep internal underscores.

1. Source: `INT8` | `INT16` | `INT` | `INT64` | `UINT8` | `UINT16` | `UINT` | `UINT64` | `FLOAT32` | `FLOAT64`
2. Target: same ten native numeric types
3. Form: `ASSIGNMENT` | `INITIALIZER` | `ARGUMENT` | `RETURN` | `PROMOTION` | `EXPLICIT_CAST`
4. Value: `ZERO` | `ONE` | `NEGATIVE` | `MIN` | `MAX` | `NEAR_BOUNDARY` | `FRACTIONAL`

Product ID prefix: `LANG-CONV-NUMERIC`. Complete set: 10×10×6×7 = 4200 cells. All 4200 are normal-return. Compile reject = 0. Runtime fault = 0.

Example: `LANG-CONV-NUMERIC-INT8-INT8-ASSIGNMENT-ZERO` → `int EntryLangConvNumericInt8Int8AssignmentZero()`.

## Source branches

Script spellings follow catalog `ScriptType`: integers keep their names; `float32` → `float`; `float64` → `double`. Shared aggregate helpers, emitted once:

- `PassNumeric{Target}({Target} Value)` identity
- `ReturnNumeric{Target}({Source} Value)` identity, overloaded on source type

Each entry hardcodes `SourceValue` from `ResolveNumericLiteral` and applies one form:

- assignment: `Converted;` then `Converted = SourceValue`
- initializer: `Converted = SourceValue`
- argument: `Converted = PassNumeric{Target}(SourceValue)`
- return: `Converted = ReturnNumeric{Target}(SourceValue)`
- promotion: `Converted = SourceValue + {Target}(0)`
- explicit_cast: `Converted = {Target}(SourceValue)`

Portable cells then emit `ExpectedValue = {Target}({literal})` and `return Converted == ExpectedValue ? 1 : 0`. Non-portable float-to-integer cells emit `return 1` only. Empty `FunctionName` emits `Entry`. Invalid identifiers such as `bad-name` emit no source.

## Observation

`GetExpected = 1` for every declared cell (verifier/marker). Unknown IDs return 0; that fallback is not membership proof.

`HasPortableExactValue` is false only for floating source, integer target, and value outside `{zero, one, fractional}` except signed-target `negative`. Those rows set `bLimitedObservation` and note that the exact floating-to-integer result is not portable.

Expected literals use `SignedValueForCase` / `UnsignedValueForCase` / `FloatingValueForCase`, then `%.9gf` for `float32` targets and `%.17g` for `float64` targets, or masked/sign-extended integer text.

All rows are `ReturnValue` + `Standalone`.
