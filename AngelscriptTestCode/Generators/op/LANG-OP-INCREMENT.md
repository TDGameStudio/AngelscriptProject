# LANG-OP-INCREMENT

Author reference for `FOpIncrementGenerator`. This file is not part of the ordinary `.as` projection.

## Axes

Documented order, uppercase catalog tokens, hyphen-separated.

1. Category: `LOCAL` | `FIELD` | `PROPERTY` | `ALIAS`
2. Observation: `BEFORE` | `EXPRESSION_RESULT` | `AFTER`
3. Operator: `PRE_INCREMENT` | `POST_INCREMENT` | `PRE_DECREMENT` | `POST_DECREMENT`
4. Type: `INT8` | `INT16` | `INT` | `INT64` | `UINT8` | `UINT16` | `UINT` | `UINT64` | `FLOAT32` | `FLOAT64`

Product ID prefix: `LANG-OP-INCREMENT`. Complete set: 4×3×4×10 = 480 cells. All 480 are normal-return. Compile reject = 0. Runtime fault = 0.

Example: `LANG-OP-INCREMENT-LOCAL-BEFORE-PRE_INCREMENT-INT` → `int EntryLangOpIncrementLocalBeforePreIncrementInt()`.

## Source branches

Shared helpers, emitted once per aggregate:

- `FIncrementFieldOwner_<type>` per numeric type.
- `Apply<Op>Alias_<type>` per operator/type.

Locals use `++`/`--` on a mutable value. Fields mutate `Owner.Value`. Property uses host `MakeIncrementProperty_<type>` getter/setter ABI. Alias calls the helper. Input is `12` or `12.5`. Return is `int(...)` of the selected observation. Empty `FunctionName` emits `Entry`.

## Observation

`GetExpected`: before=12; expression_result=prefix?final:12; after=final; final=increment?13:11. int32 truncates 64-bit and float observations (`bLimitedObservation`). Unknown IDs return 0 from `GetExpected`; that fallback is not membership proof.

Property rows are `RequiresHostSetup`. Other rows are `Standalone`.
