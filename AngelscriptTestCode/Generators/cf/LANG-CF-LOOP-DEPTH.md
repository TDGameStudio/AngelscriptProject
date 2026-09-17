# LANG-CF-LOOP-DEPTH

Author reference for `FLoopDepthGenerator`. This file is not part of the ordinary `.as` projection.

## Axes

1. Loop: `WHILE` | `DO_WHILE` | `FOR`
2. Count: `ZERO` | `ONE` | `TWO` | `MANY` (limits 0/1/2/4)
3. Transfer: `NONE` | `BREAK` | `CONTINUE` | `RETURN`

Complete set: 3×4×4 = 48 cells, all normal-return.

Example: `LANG-CF-LOOP-DEPTH-WHILE-ZERO-NONE` → `int EntryLangCfLoopDepthWhileZeroNone()`.

## Source branches

Shared helpers once: `CountCondition` and `CountIncrement`.

- while: `while (CountCondition(...)) { ++BodyCount; transfer-or-increment }`
- do_while: `do { if (Index >= Limit) break; ++BodyCount; transfer-or-increment } while (CountCondition(...));`
- for: `for (Index = 0; CountCondition(...); CountIncrement(...)) { ++BodyCount; transfer }`

`break`/`return` skip increment helpers on while/do_while. `continue` on while/do_while increments then continues. Packed return is `BodyCount * 100 + ConditionCount * 10 + IncrementCount`.

## Observation

Limit 0: Body=0, Inc=0, Cond=0 for do_while else 1.
`break`/`return` with Limit>0: Body=1, Inc=0, Cond=0 for do_while else 1.
Otherwise: Body=Limit, Inc=Limit, Cond=Limit (do_while) or Limit+1.

`DO_WHILE-ZERO-*` keeps `ExpectedReturn` 0. Unknown `GetExpected` is also 0 and is not membership proof. All rows are `ReturnValue` + `Standalone`.
