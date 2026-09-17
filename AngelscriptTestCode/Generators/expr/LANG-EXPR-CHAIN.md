# LANG-EXPR-CHAIN

Author reference for `FExprChainGenerator`. This file is not part of the ordinary `.as` projection.

## Axes

Documented order, uppercase catalog tokens, hyphen-separated.

1. Context: `INITIALIZER` | `ARGUMENT` | `RETURN` | `CONDITION` | `ASSIGNMENT`
2. Depth: `TWO` | `THREE` | `EIGHT` | `DEEP_BOUNDARY` (2 / 3 / 8 / 32)
3. Shape: `CALL_MEMBER` | `MEMBER_CALL` | `INDEX_MEMBER` | `MEMBER_INDEX` | `CAST_MEMBER` | `CALL_INDEX_CAST` | `MEMBER_CALL_INDEX` | `CAST_CALL_MEMBER_INDEX`
4. State: `VALID` | `NULL_RECEIVER` | `INVALID_INTERMEDIATE` | `EXCEPTION_INTERMEDIATE` | `MISSING_TERMINAL`

Product ID prefix: `LANG-EXPR-CHAIN`. Complete set: 5×4×8×5 = 800 cells. Normal-return = 160 (`VALID`). Compile reject = 320 (`INVALID_INTERMEDIATE`, `MISSING_TERMINAL`). Runtime fault = 320 (`NULL_RECEIVER`, `EXCEPTION_INTERMEDIATE`). Faults stay in `OutCaseCount` (480 non-reject).

Example: `LANG-EXPR-CHAIN-INITIALIZER-TWO-CALL_MEMBER-VALID` → `int EntryLangExprChainInitializerTwoCallMemberValid()`.

## Source branches

Shared helpers once: `ObserveChain`, `RecoverExpressionChain`. Return-context producers are case-qualified `ProduceChainValue_<Entry>()`.

Chain root is `MakeChain()`. Each depth step applies the repeating shape pattern (`StepCall`, `GetMember`, `[stage]`, `opCast`). `INVALID_INTERMEDIATE` injects `.BreakToInt()` at `FailureStage=(Depth+1)/2`. `MISSING_TERMINAL` ends with `.MissingTerminal` instead of `.Value`.

Contexts:

- initializer: `int Result = <expr>; return Result;`
- argument: `return ObserveChain(<expr>);`
- return: dedicated producer, then `return ProduceChainValue_<Entry>();`
- condition: `if (<expr> == ExpectedValue) return 1; return 0;`
- assignment: `int Result = 0; Result = <expr>; return Result;`

`BuildExpressionChainSource` is positive-only and rejects compile-failure states.

## Observation

`ExpectedValue = 100 + sum(Call=1, Member=3, Index=5, Cast=7)` over depth. Condition valid cells return 1. Valid rows are `ReturnValue` + `RequiresHostSetup`. `NULL_RECEIVER` exception text is `Null pointer access`. `EXCEPTION_INTERMEDIATE` text is `Expression chain intermediate exception`. Host notes name `MakeChain` / `FChainNode`.

`GetExpected` is 0 for reject, fault, and unknown IDs. That fallback is not membership proof. There is no real expected-zero valid cell.
