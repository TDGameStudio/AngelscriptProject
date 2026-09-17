# LANG-OP-POWER-FRACTIONAL-EXPONENT

Author reference for `FOpPowerFractionalExponentGenerator`. This file is not part of the ordinary `.as` projection.

## Axes

Documented order, uppercase catalog tokens, hyphen-separated. Multiword tokens keep internal underscores.

1. Base type: `INT8` | `INT16` | `INT` | `INT64` | `UINT8` | `UINT16` | `UINT` | `UINT64` | `FLOAT32` | `FLOAT64`
2. Exponent type: `FLOAT32` | `FLOAT64`
3. Source shape: `CONSTANT` | `MUTABLE_LVALUE` | `CONST_LVALUE` | `FUNCTION_RETURN`
4. Scenario: `FRACTIONAL_EXPONENT`

Product ID prefix: `LANG-OP-POWER-FRACTIONAL-EXPONENT`. Complete set: 10×2×4 = 80 cells. All 80 are normal-return. Compile reject = 0. Runtime fault = 0.

Example: `LANG-OP-POWER-FRACTIONAL-EXPONENT-INT-FLOAT32-CONSTANT-FRACTIONAL_EXPONENT` → `int EntryLangOpPowerFractionalExponentIntFloat32ConstantFractionalExponent()`.

## Source branches

Shared helpers, emitted once per aggregate or isolated module:

- `ObserveNumericType(float32)` returns 105; `ObserveNumericType(float64)` returns 106.

Operands are `Base(4)` and `Exponent(0.5)`:

- constant: `ObserveNumericType(int(4) ** float32(0.5))`
- mutable: `Base` / `Exponent` locals, then `Base ** Exponent`
- const: `const` locals, then `Base ** Exponent`
- function_return: case-qualified `PowerBaseValue<BASE><EXP>()` and `PowerExponentValue<BASE><EXP>()`

Empty `FunctionName` emits `Entry`. Invalid identifiers such as `bad-name` emit no source.

## Observation

`GetExpected` is TypeMarker 106 when the base or exponent is `float64`, otherwise 105. int32 TypeMarker is not full-width power-bit proof (`ExpectedResultBits` of 2.0 remains outside this source delivery). Unknown IDs return 0 from `GetExpected`; that fallback is not membership proof. There is no real expected-zero normal cell.

All rows are `ReturnValue` + `Standalone` with limited observation.
