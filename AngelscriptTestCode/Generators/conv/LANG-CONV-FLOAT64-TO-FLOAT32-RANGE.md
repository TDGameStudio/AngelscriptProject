# LANG-CONV-FLOAT64-TO-FLOAT32-RANGE

Author reference for `FConvFloat64ToFloat32RangeGenerator`. This file is not part of the ordinary `.as` projection.

## Axes

Documented order, uppercase catalog tokens, hyphen-separated. Multiword tokens keep internal underscores. Source is locked to float64 and target to float32; they do not enter the CaseId.

1. Form: `ASSIGNMENT` | `ARGUMENT` | `RETURN` | `EXPLICIT_CAST`
2. BoundaryDirection: `ABOVE_TARGET_MAX` | `BELOW_TARGET_MIN`

Product ID prefix: `LANG-CONV-FLOAT64-TO-FLOAT32-RANGE`. Complete set: 4×2 = 8 cells. All 8 are non-reject aggregate entries.

Example: `LANG-CONV-FLOAT64-TO-FLOAT32-RANGE-ASSIGNMENT-ABOVE_TARGET_MAX` → `int EntryLangConvFloat64ToFloat32RangeAssignmentAboveTargetMax()`.

## Source branches

This fork emits `float` for the float64 source. Helpers: `PassNumericBoundaryTargetFloat32` and `ReturnNumericBoundaryTargetFloat64Float32`.

- Source literals: `6.805646932e+38` / `-6.805646932e+38`
- Conversion uses assignment, pass-helper, return-helper, or `float32(SourceValue)`
- Entry returns `ObserveFloat32Bits(Converted)`

Overflow becomes float32 inf bits. It is not a `Divide by zero` fault. Empty `FunctionName` emits `Entry`.

## Observation

`GetExpected` is the signed float32 inf pattern and does not depend on Form:

- `ABOVE_TARGET_MAX` → `0x7F800000` (2139095040)
- `BELOW_TARGET_MIN` → `0xFF800000` (-8388608)

Rows are `ReturnValue` + `RequiresHostSetup`. Unknown IDs return 0. That zero fallback is not membership proof. There is no real expected-zero cell.
