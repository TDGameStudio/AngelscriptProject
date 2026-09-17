# LANG-CONV-FLOAT-FINITE-SPECIAL

Author reference for `FConvFloatFiniteSpecialGenerator`. This file is not part of the ordinary `.as` projection.

## Axes

Documented order, uppercase catalog tokens, hyphen-separated. Multiword tokens keep internal underscores.

1. SourceType: `FLOAT32` | `FLOAT64`
2. TargetType: `INT8` | `INT16` | `INT` | `INT64` | `UINT8` | `UINT16` | `UINT` | `UINT64` | `FLOAT32` | `FLOAT64`
3. Form: `ASSIGNMENT` | `ARGUMENT` | `RETURN` | `EXPLICIT_CAST`
4. Value: `POSITIVE_ZERO` | `NEGATIVE_ZERO` | `SUBNORMAL`

Product ID prefix: `LANG-CONV-FLOAT-FINITE-SPECIAL`. Complete set: 2×10×4×3 = 240 cells. All 240 are non-reject aggregate entries.

Example: `LANG-CONV-FLOAT-FINITE-SPECIAL-FLOAT32-INT8-ASSIGNMENT-POSITIVE_ZERO` → `int EntryLangConvFloatFiniteSpecialFloat32Int8AssignmentPositiveZero()`.

## Source branches

Pass/return helpers are type-qualified. This fork emits `float` for `FLOAT64` script types.

- Source literals: `0.0`, `-0.0`, `1.40129846e-45f`, or `4.9406564584124654e-324`
- Integer targets return `int(Converted)`
- `FLOAT32` targets return `ObserveFloat32Bits(Converted)`
- `FLOAT64` targets return `ObserveFloat64Bits(Converted)`

`ObserveFloat32Bits` / `ObserveFloat64Bits` are the int32-entry adaptation of the host return-slot bit oracle. Empty `FunctionName` emits `Entry`.

## Observation

`ExpectedFiniteBits`:

- `POSITIVE_ZERO` → 0
- `NEGATIVE_ZERO` → float32 `0x80000000`; float64 `0x8000000000000000`; integers 0
- `SUBNORMAL` → float32 source to float32 is `float::denorm_min` bits (1); float64 source to float32 is 0; float32 source to float64 is `double(float::denorm_min)` bits (`0x36A0000000000000`); float64 source to float64 is 1; integers 0

Integer and representable-bit rows set `ExpectedReturn` to that int32. Float64 patterns that do not fit int32 are `SourceOnly` + limited observation; `GetExpected` is 0 and is not membership proof. `FLOAT32-INT8-ASSIGNMENT-POSITIVE_ZERO` is a real expected zero.
