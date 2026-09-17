# LANG-CONV-FAILURE

Author reference for `FConvFailureGenerator`. This file is not part of the ordinary `.as` projection.

## Axes

Documented order, uppercase catalog tokens, hyphen-separated. Multiword tokens keep internal underscores.

1. Failure: `IMPLICIT_NARROWING` | `NUMERIC_TO_ENUM` | `UNRELATED_REFERENCE` | `BAD_DOWNCAST` | `NULL_VALUE_TARGET` | `AMBIGUOUS_CONSTRUCTOR` | `AMBIGUOUS_OPERATOR` | `EXPLICIT_ONLY_IMPLICIT_USE` | `CONVERSION_EXCEPTION` | `CONSTRUCTOR_EXCEPTION` | `ABI_MISMATCH` | `CONDITIONAL_NO_COMMON_TYPE`
2. Recovery: `FRESH_MODULE` | `SAME_MODULE_OR_CONTEXT`

Product ID prefix: `LANG-CONV-FAILURE`. Complete set: 12×2 = 24 cells. Non-reject aggregate = 10 (4 normal + 6 fault). Compile reject = 14. Faults stay in `OutCaseCount`.

Example: `LANG-CONV-FAILURE-AMBIGUOUS_CONSTRUCTOR-FRESH_MODULE` → `int EntryLangConvFailureAmbiguousConstructorFreshModule()`.

## Source branches

Each entry comments `// Recovery: <TOKEN>`. Isolated reject modules own their helpers. The aggregate emits the five non-reject helper families once plus `RunConversionRecovery` returning 77. Recovery is a source variant, not a third face.

- `AMBIGUOUS_CONSTRUCTOR` / `AMBIGUOUS_OPERATOR`: current fork selects the int64 overload
- `NULL_VALUE_TARGET`: `Target.Value` after a null class handle
- `CONVERSION_EXCEPTION` / `CONSTRUCTOR_EXCEPTION`: script `Value / Zero`, no `throw`
- Remaining seven failures: compile reject at `// CONVERSION_CAUSE`

`BuildFailureSource` is positive-only (normal and fault). Empty `FunctionName` emits `Entry`.

## Observation

- 4 normal rows: `GetExpected` = 1, `ReturnValue` + `Standalone`
- 6 fault rows: no integer; `ExpectedException` is `Null pointer access` or `Divide by zero`; they remain in `BuildAllSource`
- 14 reject rows: `CompileReject`, `GetExpected` 0

Unknown IDs return 0. That zero fallback is not membership proof.
