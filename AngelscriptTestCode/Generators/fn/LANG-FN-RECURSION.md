# LANG-FN-RECURSION

Author reference for `FFnRecursionGenerator`. This file is not part of the ordinary `.as` projection.

## Axes

Documented order, uppercase catalog tokens, hyphen-separated. Multiword tokens keep internal underscores.

1. Depth: `ZERO` | `ONE` | `EIGHT` | `CONFIGURED_LIMIT`
2. Outcome: `RETURN` | `EXCEPTION`
3. Type: `PRIMITIVE` | `VALUE_OBJECT` | `REFERENCE_OBJECT`

Product ID prefix: `LANG-FN-RECURSION`. Complete set: 4×2×3 = 24 cells. Normal-return aggregate = 6. Compile reject = 12 (`EIGHT` and `CONFIGURED_LIMIT`, current-fork mutual prototype boundary). Runtime fault = 6 (`ZERO`/`ONE` × `EXCEPTION`). Non-reject `OutCaseCount` = 12.

Example: `LANG-FN-RECURSION-ZERO-RETURN-PRIMITIVE` → `int EntryLangFnRecursionZeroReturnPrimitive()`.

## Source branches

Each cell emits uniquified `RecurseA` helpers and an `int` entry. Isolated `Entry` / `ProbeEntry` modules keep the short `RecurseA` name. Shared `CleanAfterRecursion` appears once in the aggregate.

- `ZERO` / `ONE`: self-recursion through `RecurseA`. Execution depth is `0` or `1`.
- `EIGHT` / `CONFIGURED_LIMIT`: mutual `RecurseA`/`RecurseB` with a prototype forward declaration. Those twelve cells are compile-reject; `BuildRecursionSource` returns empty for them.
- `RETURN` base: primitive returns `Value`, value object returns `Value.Value`, reference object returns `Accumulator`.
- `EXCEPTION` base: `return 1 / Zero;`.

`BuildRecursionSource` is positive-only. `BuildRejectSource` and `ListRejectCaseIds` own the 12 reject modules. Empty `FunctionName` emits `Entry`. Invalid identifiers such as `bad-name` emit no source.

## Observation

Independent marker for a normal return is `1 + ExecutionDepth`. `ExecutionDepth` is the ordinary depth except `CONFIGURED_LIMIT`, which uses `11` for `RETURN` and `13` for `EXCEPTION` (those cells remain reject). Fault and reject IDs have no normal-return comparison.

`GetExpected` uses the marker for the 6 normal IDs and returns `0` for fault, reject, and unknown IDs. That zero fallback is not membership proof. There is no real expected-zero normal cell.

Normal rows are `ReturnValue`. Fault rows are `RuntimeException` with text `Divide by zero` and stay in `OutCaseCount`. `VALUE_OBJECT` and `REFERENCE_OBJECT` are `RequiresHostSetup`. Reject rows are `CompileReject` with no declaration and `SourceOnly` execution.
