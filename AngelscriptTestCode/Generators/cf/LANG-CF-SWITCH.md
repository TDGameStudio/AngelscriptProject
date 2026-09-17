# LANG-CF-SWITCH

Author reference for `FSwitchGenerator`. This file is not part of the ordinary `.as` projection.

## Axes

Documented order, uppercase catalog tokens, hyphen-separated. Multiword tokens keep internal underscores.

1. Selector: `INT8` | `INT16` | `INT` | `INT64` | `UINT8` | `UINT16` | `UINT` | `UINT64` | `ENUM` | `TYPEDEF` | `BOUNDARY` | `UNSUPPORTED`
2. Case: `FIRST` | `MIDDLE` | `LAST` | `DEFAULT` | `NO_MATCH` | `FALLTHROUGH` | `GROUPED` | `DUPLICATE` | `NON_CONSTANT`
3. Exit: `BREAK` | `FALLTHROUGH` | `RETURN` | `EXCEPTION`

Product ID prefix: `LANG-CF-SWITCH`. Complete set: 12×9×4 = 432 cells. Normal-return aggregate = 209. Compile reject = 146. Runtime fault = 77 (`EXCEPTION` on non-reject cells).

Reject cells:

- every `UNSUPPORTED` selector
- every `DUPLICATE` or `NON_CONSTANT` case
- `DEFAULT` or `NO_MATCH` paired with `FALLTHROUGH`

Example: `LANG-CF-SWITCH-INT8-FIRST-BREAK` → `int EntryLangCfSwitchInt8FirstBreak()`.

## Source branches

Shared helpers, emitted once per aggregate or isolated reject module: `enum ESelector`, `typedef int SelectorAlias`, `class FUnsupported`, and `int BoundaryControl()`.

Each entry declares a typed `Value`, optional `DynamicCase` for `NON_CONSTANT`, then `switch (Value)` with the selected case/default layout and exit (`break`, implicit fallthrough, `return Trace`, or `Trace += 1 / 0`).

`BuildSwitchSource` is positive-only and returns empty for reject cells. `BuildRejectSource` and `ListRejectCaseIds` own the 146 reject modules. Empty `FunctionName` emits `Entry`. Invalid identifiers such as `bad-name` emit no source.

## Observation

Independent oracle for normal-return cells:

- Trace seed: FIRST 11, MIDDLE 12, LAST 13, DEFAULT 14, NO_MATCH 15, FALLTHROUGH 16, GROUPED 17
- `FALLTHROUGH` case adds 1
- `BOUNDARY` selector adds 6
- Exit `FALLTHROUGH` adds 100; exit `RETURN` adds 200

`GetExpected` uses this formula for the 209 normal IDs and returns 0 for reject, fault, and unknown IDs. That zero fallback is not membership proof. There is no real expected-zero normal cell.

Normal rows are `ReturnValue` + `Standalone`. Fault rows are `RuntimeException` / `Divide by zero` with no integer expectation. Reject rows are `CompileReject` with no declaration. No host, lifecycle, or limited-observation notes apply.
