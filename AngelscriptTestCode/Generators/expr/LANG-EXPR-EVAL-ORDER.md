# LANG-EXPR-EVAL-ORDER

Author reference for `FExprEvalOrderGenerator`. This file is not part of the ordinary `.as` projection.

## Axes

Documented order, uppercase catalog tokens, hyphen-separated.

1. Composition: `BINARY` | `ASSIGNMENT` | `COMPOUND_ASSIGNMENT` | `CALL_ARGUMENTS` | `CONSTRUCTOR_ARGUMENTS` | `INDEX_ARGUMENTS` | `CALL_CHAIN` | `MEMBER_INDEX_CHAIN` | `NESTED_CAST`
2. Operand count: `TWO` | `THREE` | `EIGHT` (2 / 3 / 8)
3. Outcome: `COMPLETE` | `EXCEPTION_FIRST` | `EXCEPTION_MIDDLE` | `EXCEPTION_LAST`
4. Source shape: `SINGLE_LINE` | `WHITESPACE` | `COMMENTS` | `MULTILINE` | `NESTED_PARENTHESES`

Product ID prefix: `LANG-EXPR-EVAL-ORDER`. Complete set: 9×3×4×5 = 540 cells. Normal-return = 135 (`COMPLETE`). Compile reject = 0. Runtime fault = 405. Faults stay in `OutCaseCount`.

Example: `LANG-EXPR-EVAL-ORDER-BINARY-TWO-COMPLETE-SINGLE_LINE` → `int EntryLangExprEvalOrderBinaryTwoCompleteSingleLine()`.

## Source branches

Shared helpers once: `RecordEagerStage` (throws `1 / Zero` when flagged), `CompleteEagerBoundary`, `FEagerChain`, and count-qualified `CollectEager` / `FEagerConstructedN` / `FEagerIndexerN` for 2, 3, and 8.

Each operand is `RecordEagerStage(stage, stage, throw?)`. Exception stage follows eager execution order (call/ctor/index/chain arguments are reverse). Count-2 `EXCEPTION_MIDDLE` wraps `CompleteEagerBoundary(..., true)`.

Shapes change separators and wrapping only. Assignment/compound assignment keep `Target` local initialization (`0` or `10`) and return `Target`.

## Observation

`GetExpected = n(n+1)/2`, plus 10 for `COMPOUND_ASSIGNMENT`. Fault rows have `ExpectedException = Divide by zero` and no integer. All rows are `Standalone`.

`GetExpected` is 0 for fault and unknown IDs. That fallback is not membership proof. There is no real expected-zero complete cell.
