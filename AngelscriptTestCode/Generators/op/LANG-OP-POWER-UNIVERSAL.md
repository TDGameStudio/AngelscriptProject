# LANG-OP-POWER-UNIVERSAL

Author reference for `FOpPowerUniversalGenerator`. This file is not part of the ordinary `.as` projection.

## Axes

Documented order, uppercase catalog tokens, hyphen-separated.

1. Base: `INT8` | `INT16` | `INT` | `INT64` | `UINT8` | `UINT16` | `UINT` | `UINT64` | `FLOAT32` | `FLOAT64`
2. Exponent: `INT8` | `INT16` | `INT` | `INT64` | `UINT8` | `UINT16` | `UINT` | `UINT64` | `FLOAT32` | `FLOAT64`
3. Shape: `CONSTANT` | `MUTABLE_LVALUE` | `CONST_LVALUE` | `FUNCTION_RETURN`
4. Scenario: `ZERO_EXPONENT` | `ONE_EXPONENT` | `NEAR_LIMIT` | `OVERFLOW`

Product ID prefix: `LANG-OP-POWER-UNIVERSAL`. Complete set: 10×10×4×4 = 1600 cells. Normal-return = 848. Compile reject = 680. Runtime `power_overflow` = 72.

Example: `LANG-OP-POWER-UNIVERSAL-INT-INT-CONSTANT-ZERO_EXPONENT` → `int EntryLangOpPowerUniversalIntIntConstantZeroExponent()`.

## Source branches

Literals follow the legacy constructor: `2**0`, `2**1`, `1**near-limit`, and overflow (`2**width-bound` or max-float`**2` on the float/integer fast path). Shared helpers are case-qualified function-return accessors only. Every non-reject entry, including the 72 overflow faults, stays in `BuildAllSource` / `OutCaseCount`. Empty `FunctionName` emits `Entry`. Positive-only `BuildPowerSource` rejects compile-reject cells.

## Categories

Compile-time overflow and runtime integer `**` are compile rejects. Runtime float overflow is `RuntimeException` with exact text `Overflow in exponent operation`. Const-lvalue mixed-sign overflow remains a wrapped normal return.

## Observation

`GetExpected` is 1 for zero/near-limit, 2 for one-exponent, and 0 for wrap/fault/reject. Float, 64-bit, and wrap rows are limited observations; they are not `ExpectedResultBits`. Unknown IDs also return 0 from `GetExpected`; that fallback is not membership proof. Wrap zeros keep `ExpectedReturn` set.
