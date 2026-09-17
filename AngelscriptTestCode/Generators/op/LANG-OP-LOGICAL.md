# LANG-OP-LOGICAL

Author reference for `FOpLogicalGenerator`. This file is not part of the ordinary `.as` projection.

## Axes

Documented order, uppercase catalog tokens, hyphen-separated.

1. Context: `ASSIGNMENT` | `RETURN` | `CONDITION` | `ARGUMENT`
2. Operator: `AND` | `OR` | `XOR`
3. Source: `BOOL_LITERAL` | `BOOL_LVALUE` | `COMPARISON` | `CONVERSION_OPERATOR`
4. Truth: `FALSE_FALSE` | `FALSE_TRUE` | `TRUE_FALSE` | `TRUE_TRUE`

Product ID prefix: `LANG-OP-LOGICAL`. Complete set: 4×3×4×4 = 192 cells. All 192 are normal-return. Compile reject = 0. Runtime fault = 0.

Example: `LANG-OP-LOGICAL-ASSIGNMENT-AND-BOOL_LITERAL-FALSE_FALSE` → `int EntryLangOpLogicalAssignmentAndBoolLiteralFalseFalse()`.

## Source branches

Shared helpers, emitted once per aggregate or isolated module:

- `struct FLogicalConversionValue` with `opImplConv()` calling `TraceLogicalOperand`.
- `ConsumeLogical(bool)`.

Expressions: `L&&R`, `L||R`, `L^^R` (`L!=R` for xor). Literals, lvalues, `Number == 1` comparisons, or explicit conversions. Contexts assign, return, `if`, or pass as an argument. Return is `Result ? 1 : 0`. Empty `FunctionName` emits `Entry`. Invalid identifiers such as `bad-name` emit no source.

## Observation

`GetExpected`: and=`L&&R`, or=`L||R`, xor=`L!=R` as int32. `FALSE_FALSE` and is a real expected 0. Unknown IDs also return 0 from `GetExpected`; that fallback is not membership proof.

All rows are `ReturnValue` + `RequiresHostSetup`. Host notes name `TraceLogicalOperand`.
