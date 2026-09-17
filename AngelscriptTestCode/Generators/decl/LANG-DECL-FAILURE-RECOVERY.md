# LANG-DECL-FAILURE-RECOVERY

Author reference for `FDeclFailureRecoveryGenerator`. This file is not part of the ordinary `.as` projection.

## Axes

1. Form: `UNBALANCED_CLASS` | `BAD_PARAMETER_LIST` | `UNCLOSED_FUNCTION_BODY` | `MISSING_TYPE_NAME` | `UNEXPECTED_HANDLE` | `UNKNOWN_BASE`
2. Placement: `ENTRY_BODY` | `AFTER_VALID_FUNCTION` | `INSIDE_NAMESPACE`
3. LineEnding: `LF` only. `CRLF` remains on the enum but is filtered out.

Product ID prefix: `LANG-DECL-FAILURE-RECOVERY`. Complete set: 6×3×1 = 18 cells. Normal-return aggregate = 0. Compile reject = 18.

Example: `LANG-DECL-FAILURE-RECOVERY-UNBALANCED_CLASS-ENTRY_BODY-LF`.

## Source branches

Each reject module emits the illegal form, optional `Before()` or `FailureNamespace` wrapper, then `int Entry…() { return 23; }`. `BuildAllSource` is empty with `OutCaseCount = 0`. `BuildInvalidSource` is the typed reject builder: empty FunctionName emits `Entry`; `CRLF` and `bad-name` emit nothing.

`GetExpected` is 0 for every ID. That zero is not membership proof.
