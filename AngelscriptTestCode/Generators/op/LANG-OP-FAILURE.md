# LANG-OP-FAILURE

Author reference for `FOpFailureGenerator`. This file is not part of the ordinary `.as` projection.

## Axes

Documented order, uppercase catalog tokens, hyphen-separated.

1. Family: `UNSUPPORTED_OPERAND` | `DIVIDE_ZERO` | `MODULO_ZERO` | `INVALID_SHIFT_COUNT` | `SIGNED_OVERFLOW` | `SIGNED_REMAINDER_OVERFLOW` | `POWER_OVERFLOW` | `INVALID_LVALUE` | `CONST_MUTATION` | `MISSING_OVERLOAD` | `AMBIGUOUS_OVERLOAD` | `INVALID_SIGNATURE` | `DUPLICATE_OPERATOR` | `NULL_RECEIVER` | `LEFT_OPERAND_EXCEPTION` | `RIGHT_OPERAND_EXCEPTION` | `ASSIGNMENT_EXCEPTION`
2. Observation: `DIAGNOSTIC_OR_EXCEPTION` | `CLEANUP` | `RECOVERY_RESULT`
3. Recovery: `FRESH_MODULE` | `SAME_MODULE_OR_CONTEXT`

Product ID prefix: `LANG-OP-FAILURE`. Complete set: 17×3×2 = 102 cells. Normal-return = 6 (`INVALID_SHIFT_COUNT`). Compile reject = 42. Runtime fault = 54. Observation/recovery label the same family source; they do not change the trigger text.

Example: `LANG-OP-FAILURE-INVALID_SHIFT_COUNT-DIAGNOSTIC_OR_EXCEPTION-FRESH_MODULE` → `int EntryLangOpFailureInvalidShiftCountDiagnosticOrExceptionFreshModule()`.

## Source branches

Each family emits one causal trigger (`OP_CAUSE` or `ASSIGNMENT_CAUSE`). Shared aggregate helper: `FThrowingAssignment`. Reject families keep isolated modules. Empty `FunctionName` emits `Entry`. The typed builder rejects compile-reject families, `bad-name`, and invalid enums.

## Observation

Masked shift `GetExpected = int32(1u << 31)` with `bLimitedObservation`. Faults carry exact exception text and no integer. Host callback exceptions (`Operator left/right/assignment exception`) are limited approximated host faults. Unknown IDs and non-normal cells return 0 from `GetExpected`; that fallback is not membership proof.
