# LANG-FN-ARITY-TARGET

Author reference for `FFnArityTargetGenerator`. This file is not part of the ordinary `.as` projection.

## Axes

1. Arity: `ZERO` | `ONE` | `TWO` | `THREE` | `EIGHT` | `CURRENT_BOUNDARY` | `BOUNDARY_PLUS_ONE`
2. Target: `GLOBAL` | `NAMESPACE_GLOBAL` | `INSTANCE_METHOD`

Counts: 0, 1, 2, 3, 8, 64, 65. Complete set: 7×3 = 21 cells. All 21 are normal-return aggregate entries. Reject = 0. Fault = 0.

Example: `LANG-FN-ARITY-TARGET-ZERO-GLOBAL` → `int EntryLangFnArityTargetZeroGlobal()`.

## Source branches

Each cell emits a unique probe under the selected target, then a PascalCase entry that calls it with `1..N`.

- `GLOBAL`: free `Probe`
- `NAMESPACE_GLOBAL`: `namespace N<Entry>` wrapping the probe
- `INSTANCE_METHOD`: `struct FOwner<Entry>` method

Zero-arity probe returns `42`. Otherwise the probe sums `P0 + P1 + ...`.

## Observation

`Count == 0 ? 42 : Count * (Count + 1) / 2`. `GetExpected` uses this formula for every catalog ID. Unknown IDs return 0 and that zero is not membership proof. All rows are `ReturnValue` + `Standalone`.
