# LANG-CF-LOOP-COND-TRANSFER-DEPTH

Author reference for `FLoopCondTransferGenerator`. This file is not part of the ordinary `.as` projection.

## Axes

Documented order, uppercase catalog tokens, hyphen-separated.

1. Loop: `WHILE` | `DO_WHILE` | `FOR`
2. Condition: `VARIABLE` | `COMPARISON` | `LOGICAL` | `NEGATED` | `SIDE_EFFECT`
3. Count: `ZERO` | `ONE` | `TWO`
4. Transfer: `NONE` | `BREAK` | `CONTINUE` | `RETURN`

Product ID prefix: `LANG-CF-LOOP-COND-TRANSFER-DEPTH`. Complete set: 3×5×3×4 = 180 cells. All 180 are normal-return. Compile reject = 0. Runtime fault = 0.

Example: `LANG-CF-LOOP-COND-TRANSFER-DEPTH-WHILE-VARIABLE-ZERO-NONE` → `int EntryLangCfLoopCondTransferDepthWhileVariableZeroNone()`.

## Source branches

Each entry declares `Limit`, `BodyCalls`, and `Index`. `VARIABLE` also declares `KeepGoing`.

- `while`: `while (cond) { ++BodyCalls; ... ++Index; }`
- `do_while`: `if (Limit == 0) return 0;` then `do { ++BodyCalls; ... ++Index; } while (cond);`
- `for`: `for (; cond; ++Index) { ++BodyCalls; ... }`

Condition text: `KeepGoing`, `Index < Limit`, `(Index < Limit) && (Limit >= 0)`, `!(Index >= Limit)`, or `CheckCondition(Index, Limit)`.

Transfers at `Index == 0`: `break`, `continue` (non-for increments Index first), or `return 1000 + BodyCalls * 100 + GetConditionCalls()`.

Empty `FunctionName` emits `Entry`. Invalid identifiers such as `bad-name` emit no source.

## Observation

Packed int32: `BodyCalls * 100 + ConditionCalls`, or `1000 + BodyCalls * 100 + ConditionCalls` when transfer is `return` and Limit > 0.

- BodyCalls: Limit; `break` clamps to `min(Limit, 1)`; `return` is 1 if Limit > 0 else 0.
- ConditionCalls: 0 unless `SIDE_EFFECT`.
- `SIDE_EFFECT` while/for: `1` plus BodyCalls unless `break`/`return` (then just `1`).
- `SIDE_EFFECT` do_while: BodyCalls, or 0 on `break`/`return`.

`WHILE-VARIABLE-ZERO-NONE` keeps `ExpectedReturn` 0. Unknown IDs also return 0 from `GetExpected`; that fallback is not membership proof.

All rows are `ReturnValue` + `RequiresHostSetup`. Host notes name `GetConditionCalls()` and, for `SIDE_EFFECT`, `CheckCondition`.
