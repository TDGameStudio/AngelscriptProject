# LANG-EXPR-SOURCE-BOUNDARY

Author reference for `FExprSourceBoundaryGenerator`. This file is not part of the ordinary `.as` projection.

## Axes

Documented order, uppercase catalog tokens, hyphen-separated. Multiword tokens keep internal underscores.

1. Build: `FIRST` | `SAME_REBUILD` | `CHANGED_REBUILD`
2. Context: `INITIALIZER` | `ARGUMENT` | `RETURN` | `CONDITION` | `INDEX`
3. Scenario: `PARENTHESES_ONE` | `PARENTHESES_EIGHT` | `PARENTHESES_SIXTY_FOUR` | `CHAIN_ONE` | `CHAIN_EIGHT` | `CHAIN_THIRTY_TWO` | `ARGUMENTS_ZERO` | `ARGUMENTS_ONE` | `ARGUMENTS_MANY` | `NUMERIC_MINIMUM` | `NUMERIC_MAXIMUM` | `WHITESPACE` | `COMMENTS` | `MULTILINE`

Product ID prefix: `LANG-EXPR-SOURCE-BOUNDARY`. Complete set: 3×5×14 = 210 cells. Normal-return aggregate = 210. Compile reject = 0. Runtime fault = 0.

Example: `LANG-EXPR-SOURCE-BOUNDARY-FIRST-INITIALIZER-PARENTHESES_ONE` → `int EntryLangExprSourceBoundaryFirstInitializerParenthesesOne()`.

## Source branches

Shared helpers, emitted once: `FBoundaryChain`, `MakeBoundaryChain`, `BoundaryArgumentsZero` (seed 41), `BoundaryArgumentsZeroChanged` (seed 58), `BoundaryArgumentsOne`, `BoundaryArgumentsMany`, `ObserveBoundary`, and `FBoundaryIndex`.

Seed is `changed_rebuild ? 58 : 41`. Parentheses wrap `int64(Seed)`. Chains append `.Step()` then `.Value`. Argument-zero first/same-rebuild call `BoundaryArgumentsZero()`; changed-rebuild calls `BoundaryArgumentsZeroChanged()` so the two seeds do not share one mutable helper. Numeric min/max use the documented `int64(-2147483647 - 1)` / `int64(2147483647)` forms. Return context uses a case-qualified `ProduceBoundary_<Entry>()`.

`BuildExpressionBoundarySource` returns empty for invalid enums or `bad-name`. Empty `FunctionName` emits `Entry`.

## Observation

`GetExpected` is the documented int32 narrowing of `ExpectedBoundaryResult`: seed, seed+chain depth, seed+120, `MIN_int32`/`MAX_int32` and their ±17 changed-rebuild variants, or seed+3 for whitespace/comments/multiline.

First-build rows are `ReturnValue` + `Standalone` with `bLimitedObservation`. Same-rebuild and changed-rebuild rows keep the same scalar oracle but are `SourceOnly` lifecycle variants; no rebuild protocol is executed. There is no real expected-zero normal cell.
