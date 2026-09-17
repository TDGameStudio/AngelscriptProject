# LANG-CF-CONDITION

Author reference for `FConditionGenerator`. This file is not part of the ordinary `.as` projection.

## Axes

Documented order, uppercase catalog tokens, hyphen-separated. Multiword tokens keep internal underscores.

1. Statement: `IF` | `WHILE` | `DO_WHILE` | `FOR`
2. Condition: `BOOL_LITERAL` | `VARIABLE` | `COMPARISON` | `LOGICAL` | `SIDE_EFFECT_CALL` | `OVERLOADED_CONVERSION` | `INVALID_TYPE`
3. Truth: `FALSE` | `TRUE` (legacy nest order)

Product ID prefix: `LANG-CF-CONDITION`. Complete set: 4×7×2 = 56 cells. Normal-return aggregate = 48. Compile reject = 8 (`INVALID_TYPE` × every statement × both truths). Runtime fault = 0.

Example prefix: `LANG-CF-CONDITION-IF-BOOL_LITERAL` → complete cells `...-FALSE` and `...-TRUE` → `int EntryLangCfConditionIfBoolLiteralTrue()`.

## Source branches

Shared helpers, emitted once per aggregate or isolated reject module:

- `struct FConditionValue` with `opImplConv()` returning `Value`.
- empty `class FInvalidCondition`.
- `EvaluateCondition` increments `EvaluationCount` and returns the bool.

Each entry declares `ConditionValue`, `Trace`, `Guard`, and `EvaluationCount`.

- `if`: `if (cond) { Trace = 1; }`
- `while`: `while ((cond) && Guard < 1) { ++Trace; ++Guard; }`
- `do_while`: `do { ++Trace; ++Guard; } while ((cond) && Guard < 1);`
- `for`: `for (; (cond) && Guard < 1; ++Guard) { ++Trace; }`

Condition text uses the truth axis: `true`/`false`, `ConditionValue`, `2 > 1` / `2 < 1`, `ConditionValue && true/false`, `EvaluateCondition(...)`, `FConditionValue(ConditionValue)`, or `FInvalidCondition()`.

`BuildConditionSource` is positive-only and returns empty for `INVALID_TYPE`. `BuildRejectSource` and `ListRejectCaseIds` own the eight reject modules. Empty `FunctionName` emits `Entry`. Invalid identifiers such as `bad-name` emit no source.

## Observation

Packed int32: `Trace * 10 + EvaluationCount`.

- Trace = 1 when the statement is `do_while` or truth is true; otherwise 0.
- EvaluationCount = 0 unless `side_effect_call`.
- `side_effect_call`: 2 when truth is true and the statement is `while` or `for`; otherwise 1.

`GetExpected` uses this formula for the 48 normal IDs and returns 0 for reject IDs and unknown IDs. That zero fallback is not membership proof. `IF-BOOL_LITERAL-FALSE` is a real expected zero and keeps `ExpectedReturn` set.

Normal rows are `ReturnValue` + `Standalone`. Reject rows are `CompileReject` with no declaration and no integer expectation. No host, lifecycle, or limited-observation notes apply.
