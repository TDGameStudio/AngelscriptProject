# LANG-FN-MIXIN-FREE-CALL-REJECTION

Author reference for `FFnMixinFreeCallRejectionGenerator`. This file is not part of the ordinary `.as` projection.

## Axes

Documented order, uppercase catalog tokens, hyphen-separated. Multiword tokens keep internal underscores.

1. Namespace: `GLOBAL` | `NESTED`

Product ID prefix: `LANG-FN-MIXIN-FREE-CALL-REJECTION`. Complete set: 2 cells. Normal-return aggregate = 0. Compile reject = 2. Runtime fault = 0.

Example: `LANG-FN-MIXIN-FREE-CALL-REJECTION-GLOBAL` → `int EntryLangFnMixinFreeCallRejectionGlobal()`.

## Source branches

Each isolated reject module declares `struct Counter`, `mixin void AddToCounter(Counter& Self, int Delta)`, and an `int` entry that performs the free call `AddToCounter(Value, 3);`. `NESTED` wraps those declarations in `namespace Tools`.

`BuildFnMixinFreeCallRejectionSource` is positive-only and returns empty for every reject cell. `BuildRejectSource` and `ListRejectCaseIds` own both reject modules. `BuildAllSource` emits no aggregate entries and reports `OutCaseCount = 0`. Empty `FunctionName` is still rejected by the positive-only builder. Invalid identifiers such as `bad-name` emit no source.

## Observation

Reject cells have no normal-return comparison. The source trigger is the free-call form `AddToCounter(Value, 3)` against a mixin that only matches member dispatch. `GetExpected` returns 0 for both IDs and for unknown IDs. That zero fallback is not membership proof. There is no real expected-zero normal cell.

Reject rows are `CompileReject` with no callable declaration and `SourceOnly` execution. No host, lifecycle, or limited-observation notes apply.
