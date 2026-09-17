# LANG-OP-INTEGRAL-BITWISE

Author reference for `FOpIntegralBitwiseGenerator`. This file is not part of the ordinary `.as` projection.

## Axes

Documented order, uppercase catalog tokens, hyphen-separated.

1. Category: `MUTABLE_LVALUE` | `CONST_LVALUE` | `TEMPORARY` | `FIELD` | `ALIAS`
2. Operator: `BIT_AND` | `BIT_OR` | `BIT_XOR` | `SHIFT_LEFT` | `SHIFT_RIGHT_LOGICAL` | `SHIFT_RIGHT_ARITHMETIC`
3. Right: `ZERO` | `ONE` | `SOURCE_WIDTH_MINUS_ONE` | `SOURCE_WIDTH` | `SOURCE_WIDTH_PLUS_ONE` | `LARGE` | `NEGATIVE`
4. Type: `INT8` | `INT16` | `INT` | `INT64` | `UINT8` | `UINT16` | `UINT` | `UINT64`

Product ID prefix: `LANG-OP-INTEGRAL-BITWISE`. Complete set: 5×6×7×8 = 1680 cells. All 1680 are normal-return. Compile reject = 0. Runtime fault = 0.

Example: `LANG-OP-INTEGRAL-BITWISE-MUTABLE_LVALUE-BIT_AND-ZERO-INT` → `int EntryLangOpIntegralBitwiseMutableLvalueBitAndZeroInt()`.

## Source branches

Shared helpers, emitted once per aggregate:

- `ObserveBitwiseType` overloads (int/uint/int64/uint64).
- `MakeBitwiseTemporary_<type>` and `FBitwiseFieldOwner_<type>`.
- `Apply<Op>Alias_<type>`.

Source bits: `0xA5` / `0xA55A` / `0xA55AA55A` / `0xA55AA55AA55AA55A`. Operators: `&` `|` `^` `<<` `>>` `>>>`. Right is the documented integer. Return is `int(expression)`. Empty `FunctionName` emits `Entry`.

## Observation

`GetExpected` is the low 32 bits of `ExpectedBits` after promotion and `Right & (Width-1)` for shifts. `bLimitedObservation` is true; int32 is not full-width proof. `BIT_AND`+`ZERO` is a real expected 0. Unknown IDs also return 0 from `GetExpected`; that fallback is not membership proof.
