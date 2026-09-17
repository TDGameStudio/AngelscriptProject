# LANG-OP-LOGICAL-NOT

Author reference for `FOpLogicalNotGenerator`. This file is not part of the ordinary `.as` projection.

## Axes

Documented order, uppercase catalog tokens, hyphen-separated.

1. Category: `MUTABLE_LVALUE` | `CONST_LVALUE` | `TEMPORARY` | `FIELD` | `ALIAS`
2. Value: `FALSE` | `TRUE`

Product ID prefix: `LANG-OP-LOGICAL-NOT`. Complete set: 5×2 = 10 cells. All 10 are normal-return. Compile reject = 0. Runtime fault = 0.

Example: `LANG-OP-LOGICAL-NOT-MUTABLE_LVALUE-FALSE` → `int EntryLangOpLogicalNotMutableLvalueFalse()`.

## Source branches

Shared helpers, emitted once per aggregate or isolated module:

- `ObserveLogicalNotType(bool)` returns 301; `ObserveLogicalNotType(int)` returns 399.
- `MakeLogicalNotTemporary` identity helper.
- `struct FLogicalNotOwner` with `bool Value`.
- `ApplyLogicalNotAlias(bool& in)` returns `!ObserveNotOperand(Value)`.

Each entry hardcodes `bool Input = false|true` and evaluates `!` on a category-specific operand:

- mutable: `bool Value = Input;` then `!ObserveNotOperand(Value)`
- const: `const bool Value = Input;` then `!ObserveNotOperand(Value)`
- temporary: `!MakeLogicalNotTemporary(ObserveNotOperand(Input))`
- field: `Owner.Value = Input;` then `!ObserveNotOperand(Owner.Value)`
- alias: `ApplyLogicalNotAlias(Value)`

Return is `Result ? 1 : 0`. Empty `FunctionName` emits `Entry`. Invalid identifiers such as `bad-name` emit no source.

## Observation

`GetExpected = Value ? 0 : 1` (`!Input` as int32). Five `TRUE` cells keep `ExpectedReturn` 0. Unknown IDs also return 0 from `GetExpected`; that fallback is not membership proof.

All rows are `ReturnValue` + `RequiresHostSetup`. Host notes name `ObserveNotOperand`.
