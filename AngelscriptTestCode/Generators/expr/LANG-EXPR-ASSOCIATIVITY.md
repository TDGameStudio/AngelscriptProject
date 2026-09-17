# LANG-EXPR-ASSOCIATIVITY

Author reference for `FExprAssociativityGenerator`. This file is not part of the ordinary `.as` projection.

## Axes

Documented order, uppercase catalog tokens, hyphen-separated. Multiword tokens keep internal underscores.

1. Grouping: `UNPARENTHESIZED` | `LEFT_PARENTHESIZED` | `RIGHT_PARENTHESIZED`
2. Level: `MULTIPLICATIVE` | `ADDITIVE` | `SHIFT` | `RELATIONAL` | `EQUALITY` | `BITWISE_AND` | `BITWISE_XOR` | `BITWISE_OR` | `LOGICAL_AND` | `LOGICAL_OR` | `CONDITIONAL` | `ASSIGNMENT`
3. Sequence: `REPEATED_OPERATOR` | `MIXED_SAME_LEVEL`

Product ID prefix: `LANG-EXPR-ASSOCIATIVITY`. Complete set: 3×12×2 = 72 cells. Normal-return aggregate = 60. Compile reject = 12 (`ASSIGNMENT-*` and `LOGICAL_AND|LOGICAL_OR-REPEATED_OPERATOR`). Runtime fault = 0.

Example: `LANG-EXPR-ASSOCIATIVITY-UNPARENTHESIZED-MULTIPLICATIVE-REPEATED_OPERATOR` → `int EntryLangExprAssociativityUnparenthesizedMultiplicativeRepeatedOperator()`.

## Source branches

Shared helpers once per aggregate or isolated module: `MarkPrecedence`, `BoolCode`, `FoldPrecedence`, `struct FPrecedenceProbe`, and `ObservePrecedence` overloads.

Selected expression follows `BuildAssociativityExpressions` plus grouping:

- Regular repeated: `A op B op C` / `(A op B) op C` / `A op (B op C)`
- Regular mixed with a distinct secondary token: `A * B / C`, `A + B - C`, `A << B >> C`, `A < B >= C`, `A == B != C`
- Regular mixed without a distinct secondary token uses `Q`: `A & Q & C`, `A && Q && C`
- Conditional repeated: `A ? B : C ? D : E`; mixed: `A ? B ? C : D : E`
- Assignment repeated: `A = B = C`; mixed: `A += B = C`

Reject cells are the fork expression boundary: all assignment sequences, plus unparenthesized-style `&&`/`||` without `Q`. `BuildPrecedenceSource` is positive-only.

## Observation

`GetExpected` is the `SelectedUsesLeftControl` marker: left parenthesized and left-associative unparenthesized rows return 1; right parenthesized and right-associative unparenthesized rows return 0. That int32 is a grouping-direction marker, not `ObservePrecedence` Code. Rows are `ReturnValue` + `RequiresHostSetup` + `bLimitedObservation`. Host notes name `MarkPrecedence`.

`GetExpected` is 0 for reject and unknown IDs. That fallback is not membership proof. Right-parenthesized normal cells keep a real expected zero.
