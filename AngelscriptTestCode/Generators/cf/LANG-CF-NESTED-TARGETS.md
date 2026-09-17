# LANG-CF-NESTED-TARGETS

Author reference for `FNestedTargetGenerator`. This file is not part of the ordinary `.as` projection.

## Axes

1. Nesting: `NESTED_LOOP` | `BRANCH_LOOP` | `THREE_LEVEL`
2. Transfer: `BREAK` | `CONTINUE` | `RETURN`
3. Target: `INNER` | `OUTER`

Complete set: 3×3×2 = 18 cells, all normal-return.

Example: `LANG-CF-NESTED-TARGETS-NESTED_LOOP-BREAK-INNER` → `int EntryLangCfNestedTargetsNestedLoopBreakInner()`.

## Source branches

Outer `for (Outer < 2)` adds 1, then:

- nested_loop: inner `for` adds 10
- branch_loop: `if (Outer >= 0)` adds 2 then inner adds 10
- three_level: `if` + middle adds 10 + inner adds 100

Inner target emits `break`/`continue`/`return Trace` inside the innermost loop. Outer target emits the same after `Trace += 1000` and before `Trace += 10000`.

## Observation

`SimulateExpectedTrace` walks the same nest: inner transfers abort that loop (or return), outer transfers abort the Outer loop (or return). All rows are `ReturnValue` + `Standalone`. No cell has expected 0; unknown `GetExpected` is the zero fallback.
