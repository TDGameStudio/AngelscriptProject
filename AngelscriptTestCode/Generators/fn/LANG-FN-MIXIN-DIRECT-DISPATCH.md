# LANG-FN-MIXIN-DIRECT-DISPATCH

Author reference for `FFnMixinDirectDispatchGenerator`. This file is not part of the ordinary `.as` projection.

## Axes

1. Namespace: `GLOBAL` | `NESTED`

Complete set: 2 cells. Both are normal-return aggregate entries. Reject = 0.

Example: `LANG-FN-MIXIN-DIRECT-DISPATCH-GLOBAL`.

## Source branches

Both cells declare `struct Counter` / `mixin void AddToCounter(Counter& Self, int Delta)` and invoke `Value.AddToCounter(3);` then `return Value.Value;`.

- `GLOBAL`: helpers at file scope; aggregate names are uniquified from the entry
- `NESTED`: helpers inside `namespace Tools<Entry>`

Empty `FunctionName` emits `Entry` with unsuffixed `Counter` / `AddToCounter`. `ProbeEntry` changes only the requested entry identity and helper suffix.

## Observation

Expected return is 3. Both rows are `ReturnValue` + `Standalone`. Unknown `GetExpected` is 0 and is not membership proof.
