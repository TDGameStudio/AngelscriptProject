# LANG-CONV-NONFINITE-PRECONVERSION

Author reference for `FConvNonfinitePreconversionGenerator`. This file is not part of the ordinary `.as` projection.

## Axes

Documented order, uppercase catalog tokens, hyphen-separated. Multiword tokens keep internal underscores.

1. Source: `FLOAT32` | `FLOAT64`
2. Target: `INT8` | `INT16` | `INT` | `INT64` | `UINT8` | `UINT16` | `UINT` | `UINT64` | `FLOAT32` | `FLOAT64`
3. Form: `ASSIGNMENT` | `ARGUMENT` | `RETURN` | `EXPLICIT_CAST`
4. Value: `POSITIVE_INFINITY` | `NEGATIVE_INFINITY` | `NAN`

Product ID prefix: `LANG-CONV-NONFINITE-PRECONVERSION`. Complete set: 2×10×4×3 = 240 cells. Normal-return = 0. Compile reject = 0. Runtime fault = 240 (`divide_by_zero`). Faults remain in `BuildAllSource` `OutCaseCount`.

Example: `LANG-CONV-NONFINITE-PRECONVERSION-FLOAT32-INT8-ASSIGNMENT-POSITIVE_INFINITY` → `int EntryLangConvNonfinitePreconversionFloat32Int8AssignmentPositiveInfinity()`.

## Source branches

Script spellings are catalog `ScriptType` values: `float32` → `float`, `float64` → `double`. Shared aggregate helpers, emitted once:

- `PassNumeric{Target}({Target} Value)` identity for argument form
- `ReturnNumeric{Target}({Source} Value)` identity for return form

Each entry constructs the non-finite source with in-script divide-by-zero, then applies the form:

- `Unit = 1.0`, `Zero = 0.0`
- `positive_infinity`: `SourceValue = Unit / Zero`
- `negative_infinity`: `SourceValue = -Unit / Zero`
- `nan`: `SourceValue = Zero / Zero`
- assignment: `Converted;` then `Converted = SourceValue`
- argument: `Converted = PassNumeric{Target}(SourceValue)`
- return: `Converted = ReturnNumeric{Target}(SourceValue)`
- explicit_cast: `Converted = {Target}(SourceValue)`

Return is `0`. Empty `FunctionName` emits `Entry`. Invalid identifiers such as `bad-name` emit no source.

## Observation

All 240 rows are `RuntimeException` + `Standalone` with `ExpectedException = "Divide by zero"`. `GetExpected` is 0 for every known and unknown ID. That zero fallback is not membership proof. No `ExpectedReturn` is set. No host, lifecycle, or limited-observation notes apply.
