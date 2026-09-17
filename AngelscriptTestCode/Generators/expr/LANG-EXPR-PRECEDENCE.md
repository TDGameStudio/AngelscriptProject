# LANG-EXPR-PRECEDENCE

Author reference for `FExprPrecedenceGenerator`. This file is not part of the ordinary `.as` projection.

## Axes

Documented order, uppercase catalog tokens, hyphen-separated. Multiword tokens keep internal underscores.

1. Grouping: `UNPARENTHESIZED` | `LEFT_PARENTHESIZED` | `RIGHT_PARENTHESIZED`
2. Left level: `MULTIPLICATIVE` | `ADDITIVE` | `SHIFT` | `RELATIONAL` | `EQUALITY` | `BITWISE_AND` | `BITWISE_XOR` | `BITWISE_OR` | `LOGICAL_AND` | `LOGICAL_OR` | `CONDITIONAL` | `ASSIGNMENT`
3. Right level: same tokens as left

Product ID prefix: `LANG-EXPR-PRECEDENCE`. Complete set: 3×12×12 = 432 cells. Normal-return aggregate = 231. Compile reject = 201 (`IsForkExpressionBoundary` on any of the three grouping forms). Runtime fault = 0.

Example: `LANG-EXPR-PRECEDENCE-UNPARENTHESIZED-MULTIPLICATIVE-ADDITIVE` → `int EntryLangExprPrecedenceUnparenthesizedMultiplicativeAdditive()`.

## Source branches

Shared helpers, emitted once per aggregate or isolated reject module: `MarkPrecedence`, `BoolCode`, `FoldPrecedence`, `struct FPrecedenceProbe` with the documented operator methods, and `ObservePrecedence` overloads.

Each entry declares probes `A(2,true)` … `E(11,true)` and `bool Q = false`, then `return ObservePrecedence(<selected form>);`.

Regular×regular forms are `A L B R C`, `(A L B) R C`, and `A L (B R C)`. Conditional and assignment pairs use the documented special templates, including `A ? B : C ? D : E`, `A = B = C`, and `A L B ? C : D = E`.

`BuildPrecedenceSource` is positive-only and returns empty for fork-boundary cells. `BuildRejectSource` and `ListRejectCaseIds` own the 201 reject modules. Empty `FunctionName` emits `Entry`. Invalid identifiers such as `bad-name` emit no source.

## Observation

Limited grouping-direction marker, not the runtime `FoldPrecedence` Code:

- `1` when `SelectedUsesLeftControl` is true (left-parenthesized, or unparenthesized with `bUnparenthesizedUsesLeft`)
- `0` when the selected grouping uses the right control

`GetExpected` uses this marker for the 231 normal IDs and returns 0 for reject and unknown IDs. That zero fallback is not membership proof. `RIGHT_PARENTHESIZED-MULTIPLICATIVE-ADDITIVE` is a real expected zero and keeps `ExpectedReturn` set.

Normal rows are `ReturnValue` + `SourceOnly` with `bLimitedObservation`. Reject rows are `CompileReject` with no declaration. Host `MarkPrecedence` is emitted as an empty script function; runtime Code/bytecode comparison is out of scope.
