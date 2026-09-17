# LANG-OP-POWER-NEGATIVE-EXPONENT

Author reference for `FOpPowerNegativeExponentGenerator`. This file is not part of the ordinary `.as` projection.

## Axes

Documented order, uppercase catalog tokens, hyphen-separated.

1. Base: `INT8` | `INT16` | `INT` | `INT64` | `UINT8` | `UINT16` | `UINT` | `UINT64` | `FLOAT32` | `FLOAT64`
2. Exponent: `INT8` | `INT16` | `INT` | `INT64` | `FLOAT32` | `FLOAT64`
3. Shape: `CONSTANT` | `MUTABLE_LVALUE` | `CONST_LVALUE` | `FUNCTION_RETURN`
4. Scenario: `NEGATIVE_EXPONENT`

Product ID prefix: `LANG-OP-POWER-NEGATIVE-EXPONENT`. Complete set: 10×6×4 = 240 cells. Normal-return = 144. Compile reject = 96. Runtime fault = 0.

Example: `LANG-OP-POWER-NEGATIVE-EXPONENT-INT-INT-CONSTANT-NEGATIVE_EXPONENT` → `int EntryLangOpPowerNegativeExponentIntIntConstantNegativeExponent()`.

## Source branches

Operands are `2 ** -2` with catalog-typed casts. Constant inlines both casts. Mutable and const lvalues bind `Base` and `Exponent`. Function-return emits case-qualified `PowerBase_<Entry>` and `PowerExponent_<Entry>` helpers. Every entry returns `int(Result)`. Empty `FunctionName` emits `Entry`. Invalid identifiers such as `bad-name` emit no source. Positive-only `BuildPowerSource` rejects compile-reject cells.

## Categories

Compile reject when the compile-time-known unsigned integer base meets an integer exponent (`Overflow in exponent operation`), or when a runtime integer result meets `Cannot pow on integer values`. Those 96 IDs stay out of `BuildAllSource` and `OutCaseCount`.

## Observation

`GetExpected` is the truncated int32 of `2 ** -2` (0). Float and 64-bit result kinds are limited observations; they are not `ExpectedResultBits`. Unknown IDs also return 0 from `GetExpected`; that fallback is not membership proof. Real zero cells keep `ExpectedReturn` set.
