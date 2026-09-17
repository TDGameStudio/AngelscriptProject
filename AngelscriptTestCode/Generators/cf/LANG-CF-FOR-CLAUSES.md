# LANG-CF-FOR-CLAUSES

Author reference for `FForLoopGenerator`. This file is not part of the ordinary `.as` projection.

## Axes

Documented order, uppercase catalog tokens, hyphen-separated:

1. Init presence: `PRESENT` | `OMITTED`
2. Condition presence: `PRESENT` | `OMITTED`
3. Increment presence: `PRESENT` | `OMITTED`
4. Count: `ZERO` (Limit=0) | `ONE` (Limit=1) | `MANY` (Limit=4)

Product ID prefix: `LANG-CF-FOR-CLAUSES`. Complete set: 2×2×2×3 = 24 cells. All 24 are normal-return aggregate entries. Reject = 0. Runtime fault = 0.

Example: `LANG-CF-FOR-CLAUSES-PRESENT-OMITTED-PRESENT-ONE` → `int EntryLangCfForClausesPresentOmittedPresentOne()`.

## Source branches

Shared helpers, emitted once per aggregate or dump:

- `InitializeIndex` increments `InitCount` and returns 0.
- `CountCondition` increments `ConditionCount` and returns `Index < Limit`.
- `CountIncrement` increments `IncrementCount` then `Index`.

Each entry declares local `Limit`, `Index`, `InitCount`, `BodyCount`, `ConditionCount`, and `IncrementCount`, then a `for` whose omitted clauses stay empty.

- Condition omitted: body uses `if (Index >= Limit - 1) break;` so the loop remains finite.
- Increment omitted: body uses `++Index;`.
- Typed `BuildForSource` with empty `FunctionName` emits `Entry`. Invalid identifiers such as `bad-name` emit no source.

## Observation

Packed int32: `Init*1000 + Body*100 + Cond*10 + Inc`.

- Init = 1 if the init clause is present, else 0.
- Body = `Limit` when a condition is present; otherwise `Limit` if `Limit > 0`, else 1.
- Cond = `Limit + 1` when a condition is present, else 0.
- Inc = `Limit` when both increment and condition are present; `Body-1` when increment is present and condition is omitted and Body > 0; else 0.

`GetExpected` uses this formula for catalog IDs and returns 0 for unknown IDs. That zero fallback is not membership proof. Every listed case is `ReturnValue` + `Standalone` with `ExpectedReturn` set. No host, lifecycle, or limited-observation notes apply.
