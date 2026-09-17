# LANG-FN-RETURN

Author reference for `FFnReturnGenerator`. This file is not part of the ordinary `.as` projection.

## Axes

Documented order, uppercase catalog tokens, hyphen-separated. Multiword tokens keep internal underscores.

1. Path: `DIRECT` | `IF_ELSE` | `SWITCH` | `EARLY` | `RECURSIVE_BASE` | `EXCEPTION` | `MISSING_INVALID` | `INCOMPATIBLE_INVALID`
2. Type: `VOID` | `INT8` | `INT16` | `INT` | `INT64` | `UINT8` | `UINT16` | `UINT` | `UINT64` | `FLOAT32` | `FLOAT64` | `BOOL` | `ENUM` | `TYPEDEF` | `SCRIPT_VALUE` | `SCRIPT_REFERENCE` | `NULL_REFERENCE`

Product ID prefix: `LANG-FN-RETURN`. Complete set: 8×17 = 136 cells. Normal-return aggregate = 86. Compile reject = 33 (`INCOMPATIBLE_INVALID` all 17; `MISSING_INVALID` all except `VOID`). Runtime fault = 17 (`EXCEPTION` × 17). Non-reject `OutCaseCount` = 103.

Example: `LANG-FN-RETURN-DIRECT-VOID` → `int EntryLangFnReturnDirectVoid()`.

## Source branches

Each cell emits a typed `Probe` plus a wrapping `int` entry. Aggregate and dump uniquify probe names from the entry stem. Isolated `Entry` / `ProbeEntry` modules keep the short `Probe` name. Shared `ENativeCaseEnum`, `FScriptCaseValue`, and `FScriptCaseReference` appear once in the aggregate.

- `DIRECT`: immediate typed return (or `return;` for `VOID`).
- `IF_ELSE` / `SWITCH` / `EARLY`: both arms return the same typed value.
- `RECURSIVE_BASE`: `Probe_Recursive(int Depth)` bottoms out at the typed return.
- `EXCEPTION`: `int Crash = 1 / Zero;` then a dead typed return.
- `MISSING_INVALID`: no return statement. `VOID` remains a normal cell; every other type is compile-reject.
- `INCOMPATIBLE_INVALID`: returns the incompatible expression for that type.

The `int` entry unwraps void (`Probe(); return 0;`), floats (`Observed == Observed ? 0 : 1`), bool, object `.Value`, and handle-null (`Result is null`).

`BuildReturnSource` is positive-only and returns empty for reject cells. `BuildRejectSource` and `ListRejectCaseIds` own the 33 reject modules. Empty `FunctionName` emits `Entry`. Invalid identifiers such as `bad-name` emit no source.

## Observation

Independent integer observation is `0` for `VOID`, `FLOAT32`, `FLOAT64`, and `NULL_REFERENCE`; `1` for `BOOL` and `ENUM`; `7` for the remaining types. Float rows are limited observation. `TYPEDEF` needs host `RegisterTypedef NativeCaseAlias`.

`GetExpected` uses that integer for normal IDs and returns `0` for fault, reject, and unknown IDs. Real expected-zero normal cells (`VOID`, floats, `NULL_REFERENCE`) keep a populated `ExpectedReturn` optional and are not confused with an unknown ID.

Normal rows are `ReturnValue`. Fault rows are `RuntimeException` with text `Divide by zero` and stay in `OutCaseCount`. Reject rows are `CompileReject` with no declaration and `SourceOnly` execution.
