# LANG-VAR-LOOP-DECL-LIFETIME

Author reference for `FVarLoopDeclLifetimeGenerator`. This file is not part of the ordinary `.as` projection.

## Axes

1. Exit: `NORMAL` | `BREAK` | `CONTINUE` | `RETURN` | `EXCEPTION`
2. Iteration: `ZERO` | `ONE` | `THREE` | `EIGHT`
3. Placement: `FOR_INITIALIZER` | `FOR_BODY` | `WHILE_BODY` | `DO_BODY` | `NESTED_BODY`
4. Type: `SCRIPT_VALUE` | `NATIVE_VALUE`

Product ID prefix: `LANG-VAR-LOOP-DECL-LIFETIME`. Complete set: 200 cells. Normal-return = 168. Compile reject = 0. Runtime fault = 32. Faults stay in `OutCaseCount` (200).

Example: `LANG-VAR-LOOP-DECL-LIFETIME-NORMAL-ZERO-FOR_INITIALIZER-SCRIPT_VALUE` → `int EntryLangVarLoopDeclLifetimeNormalZeroForInitializerScriptValue()`.

## Source branches

Shared helpers once: script `BeginScriptLoopValue` / `EndScriptLoopValue` / `RecordVariableLoopEvent` / `AdvanceVariableLoop`, `FScriptLoopValue`, `FNativeCaseValue`, and `RaiseVariableLoopException`.

## Observation

`GetExpected` = `ReturnBase + ExpectedBodyCount`.

- ReturnBase: normal 7000, break 7100, continue 7200, return 7300, exception 7400
- Full body count: `do_body` uses `max(1, Count)`, others use `Count`
- `break` / `return` / `exception` compress body count to 1 when the full count is > 0
- `exception` is a fault only when that compressed body count is > 0
- `exception` + `zero` + non-`do_body` is 8 non-fault cells returning 7400

`BuildVariableLoopSource` accepts every valid cell. Empty `FunctionName` emits `Entry`.
