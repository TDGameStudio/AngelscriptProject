# LANG-EXPR-LAZY-EVALUATION

Author reference for `FExprLazyEvaluationGenerator`. This file is not part of the ordinary `.as` projection.

## Axes

Documented order, uppercase catalog tokens, hyphen-separated.

1. Form: `LOGICAL_AND` | `LOGICAL_OR` | `CONDITIONAL`
2. Operand outcome: `VALUE` | `SIDE_EFFECT` | `EXCEPTION`
3. Selector: `FALSE` | `TRUE`
4. Source shape: `SINGLE_LINE` | `COMMENTS` | `MULTILINE` | `PARENTHESIZED`

Product ID prefix: `LANG-EXPR-LAZY-EVALUATION`. Complete set: 3×3×2×4 = 72 cells. Normal-return = 60. Compile reject = 0. Runtime fault = 12 (`EXCEPTION` when the guarded operand is selected). Faults stay in `OutCaseCount`.

Example: `LANG-EXPR-LAZY-EVALUATION-LOGICAL_AND-VALUE-FALSE-SINGLE_LINE` → `int EntryLangExprLazyEvaluationLogicalAndValueFalseSingleLine()`.

## Source branches

Shared helpers once: `RecordExpressionBool`, `RecordExpressionInt`, `RaiseGuardedBool` (`1 / Zero > 0`), `RaiseGuardedInt` (`1 / Zero`).

Selector is `RecordExpressionBool(1, true|false)`. Guarded operand is `true`/`41`, `RecordExpressionBool(2, true)` / `RecordExpressionInt(2, 41)`, or `RaiseGuardedBool` / `RaiseGuardedInt`. Forms:

- `&&` / `||` then `? 1 : 0`
- conditional `? guarded : RecordExpressionInt(3, 23)`

Comments, parentheses, and multiline only change layout.

## Observation

`IsGuardedOperandSelected`: `&&` uses the selector; `||` uses the negated selector; conditional uses the selector. `GetExpected`: `&&` → selector?1:0; `||` → 1; conditional → selector?41:23. Guarded exception rows are `RuntimeException` with `Divide by zero`. All rows are `Standalone`.

`LOGICAL_AND-VALUE-FALSE-*` keep a real expected zero. `GetExpected` is 0 for fault and unknown IDs. That fallback is not membership proof.
