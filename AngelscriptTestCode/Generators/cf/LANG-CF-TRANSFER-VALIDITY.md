# LANG-CF-TRANSFER-VALIDITY

Author reference for `FTransferValidityGenerator`. This file is not part of the ordinary `.as` projection.

## Axes

Documented order, uppercase catalog tokens, hyphen-separated. Multiword tokens keep internal underscores.

1. Placement: `FUNCTION` | `BRANCH` | `SWITCH` | `LOOP`
2. Transfer: `BREAK` | `CONTINUE`

Product ID prefix: `LANG-CF-TRANSFER-VALIDITY`. Complete set: 4×2 = 8 cells. Normal-return aggregate = 3 (`SWITCH-BREAK`, `LOOP-BREAK`, `LOOP-CONTINUE`). Compile reject = 5 (`FUNCTION-*`, `BRANCH-*`, `SWITCH-CONTINUE`). Runtime fault = 0.

Example: `LANG-CF-TRANSFER-VALIDITY-FUNCTION-BREAK` → `int EntryLangCfTransferValidityFunctionBreak()`.

## Source branches

No shared helpers.

- `FUNCTION`: bare `break;` or `continue;` then `return 0;`
- `BRANCH`: the transfer inside `if (true) { ... }` then `return 0;`
- `SWITCH`: `switch (1)` with a compound `case 1` that emits the transfer then `break;`, default `break;`, then `return 3;`
- `LOOP`: `for (int Index = 0; Index < 2; ++Index)` with `if (Index == 0) { transfer; }` then `return 5;`, after the loop `return 3;`

`BuildValiditySource` is positive-only and returns empty for reject cells. `BuildRejectSource` and `ListRejectCaseIds` own the five reject modules. Empty `FunctionName` emits `Entry`. Invalid identifiers such as `bad-name` emit no source.

## Observation

Independent oracle for the three normal-return cells:

- `SWITCH-BREAK`: valid switch break, then `return 3` → 3
- `LOOP-BREAK`: break on `Index == 0`, then `return 3` → 3
- `LOOP-CONTINUE`: continue on `Index == 0`, then `return 5` on `Index == 1` → 5

`GetExpected` uses this formula for the three normal IDs and returns 0 for reject and unknown IDs. That zero fallback is not membership proof. There is no real expected-zero normal cell.

Normal rows are `ReturnValue` + `Standalone`. Reject rows are `CompileReject` with no declaration and `SourceOnly` execution. No host, lifecycle, or limited-observation notes apply.
