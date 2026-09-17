# LANG-EXPR-FAILURE

Author reference for `FExprFailureGenerator`. This file is not part of the ordinary `.as` projection.

## Axes

Documented order, uppercase catalog tokens, hyphen-separated.

1. Context: `INITIALIZER` | `ASSIGNMENT` | `ARGUMENT` | `RETURN` | `CONDITION` | `LOOP_CLAUSE` | `SWITCH_SELECTOR` | `INDEX`
2. Failure: `INVALID_LVALUE` | `MISSING_DELIMITER` | `MALFORMED_TERNARY` | `MISSING_SYMBOL` | `AMBIGUOUS_SYMBOL` | `INACCESSIBLE_MEMBER` | `MISSING_MEMBER` | `DIVIDE_ZERO` | `INDEX_OUT_OF_RANGE` | `NULL_ACCESS` | `EXCEPTION_LEFT` | `EXCEPTION_RIGHT`
3. Recovery: `FRESH_MODULE` | `REBUILD_OR_CONTEXT_REUSE`

Product ID prefix: `LANG-EXPR-FAILURE`. Complete set: 8×12×2 = 192 cells. Normal-return = 0. Compile reject = 112 (seven compile kinds × contexts × recoveries). Runtime fault = 80. Faults stay in `OutCaseCount`.

Example: `LANG-EXPR-FAILURE-INITIALIZER-DIVIDE_ZERO-FRESH_MODULE` → `int EntryLangExprFailureInitializerDivideZeroFreshModule()`.

## Source branches

Shared helpers once: `RecordFailureStage`, ambiguous `ResolveAmbiguousFailure` overloads, `FFailureRestricted`, `FFailureIndex`, `FFailureContextIndex`, `ObserveFailure`, `RecoverExpressionFailure`. Return-context producers are case-qualified `ProduceFailure_<Entry>()`.

Failure expressions follow the cited constructor. Contexts place that expression in an initializer, assignment, argument, return producer, `if`, `for` clause, `switch`, or index receiver. Recovery is a source-variant identity; both routes emit the same text.

`BuildExpressionFailureSource` is positive-only and rejects compile-failure kinds.

## Observation

There is no normal-return integer. Compile rejects have neither return nor exception. Runtime rows keep exact texts: `Divide by zero`, `Expression index out of range`, `Null pointer access`, `Expression left operand exception`, `Expression right operand exception`. Execution is `RequiresHostSetup`. Rebuild/reuse rows add `bLimitedObservation` because lifecycle is not executed.

`GetExpected` is 0 for every ID, including unknown. That fallback is not membership proof.
