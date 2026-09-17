# LANG-OP-COMPARISON-REFERENCE

Author reference for `FOpComparisonReferenceGenerator`. This file is not part of the ordinary `.as` projection.

## Axes

Documented order, uppercase catalog tokens, hyphen-separated.

1. Operator: `LESS` | `LESS_EQUAL` | `GREATER` | `GREATER_EQUAL` | `EQUAL` | `NOT_EQUAL`
2. Relation: `SAME_NON_NULL` | `DIFFERENT_NON_NULL` | `LEFT_NULL` | `RIGHT_NULL` | `BOTH_NULL` | `DERIVED_BASE_SAME` | `SIBLING_DIFFERENT` | `CONST_SAME`
3. Order: `LEFT_RIGHT` | `RIGHT_LEFT`

Product ID prefix: `LANG-OP-COMPARISON-REFERENCE`. Complete set: 6×8×2 = 96 cells. Normal-return = 32 (`EQUAL`/`NOT_EQUAL`). Compile reject = 64 (ordering operators). Runtime fault = 0.

Example: `LANG-OP-COMPARISON-REFERENCE-EQUAL-SAME_NON_NULL-LEFT_RIGHT` → `int EntryLangOpComparisonReferenceEqualSameNonNullLeftRight()`.

## Source branches

Shared helpers, emitted once per aggregate or isolated module:

- `TraceReferenceOperand` / `TraceConstReferenceOperand` record host identities.

Each entry constructs Left/Right from the relation (`MakeComparisonRoot`, null, derived/sibling factories, or const copies) and compares them with `<` `<=` `>` `>=` `==` `!=`. `RIGHT_LEFT` swaps operand evaluation order. Return is `(compare) ? 1 : 0`. Empty `FunctionName` emits `Entry`. Invalid identifiers such as `bad-name` emit no source. The typed builder rejects ordering params.

## Observation

`GetExpected = (Op==Equal) ? Relation.bEqual : !Relation.bEqual` as int32. Equal relations: same/both-null/derived-base-same/const-same. Unknown IDs and rejects return 0 from `GetExpected`; that fallback is not membership proof.

Equality rows are `ReturnValue` + `RequiresHostSetup`. Ordering rows are `CompileReject` + `SourceOnly`.
