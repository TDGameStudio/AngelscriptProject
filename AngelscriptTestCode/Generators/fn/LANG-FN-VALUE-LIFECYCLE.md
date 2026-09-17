# LANG-FN-VALUE-LIFECYCLE

Author reference for `FFnValueLifecycleGenerator`. This file is not part of the ordinary `.as` projection.

## Axes

Documented order, uppercase catalog tokens, hyphen-separated. Multiword tokens keep internal underscores.

1. Failure: `NONE` | `ARGUMENT_EVALUATION` | `BODY` | `RETURN_CONSTRUCTION`
2. Initialized: `ZERO` | `ONE` | `MANY`
3. Transfer: `VALUE_ARGUMENT` | `VALUE_RETURN`

Product ID prefix: `LANG-FN-VALUE-LIFECYCLE`. Complete set: 4×3×2 = 24 cells. Normal-return aggregate = 6. Compile reject = 0. Runtime fault = 18. Non-reject `OutCaseCount` = 24.

Example: `LANG-FN-VALUE-LIFECYCLE-NONE-ZERO-VALUE_ARGUMENT` → `int EntryLangFnValueLifecycleNoneZeroValueArgument()`.

## Source branches

Shared helpers `ProduceArgumentValue`, `ConsumeValueArgument`, `ProduceReturnValue`, and `CleanAfterValueLifecycle` appear once in the aggregate. Isolated `Entry` / `ProbeEntry` modules include those helpers. `ONE` emits `Initialized0(100)`; `MANY` emits four initialized natives `100..103`.

- `VALUE_ARGUMENT` / `NONE`: `ConsumeValueArgument(ProduceArgumentValue(41, false), 1)`.
- `VALUE_ARGUMENT` / `ARGUMENT_EVALUATION`: `1 / Zero` in the divisor position.
- `VALUE_ARGUMENT` / `BODY`: divisor `0`.
- `VALUE_ARGUMENT` / `RETURN_CONSTRUCTION`: `ProduceArgumentValue(41, true)` arms the host copy fault.
- `VALUE_RETURN` mirrors those paths through `ProduceReturnValue` and `return Value.Value`.

`BuildSource` is positive-only. Empty `FunctionName` emits `Entry`. Invalid identifiers such as `bad-name` emit no source.

## Observation

Independent observation for `NONE` is `41`. Fault cells have no normal-return comparison. `GetExpected` returns `41` for the 6 normal IDs and `0` for fault and unknown IDs. That zero fallback is not membership proof. There is no real expected-zero normal cell.

Every row is `RequiresHostSetup` with notes for native `FNativeCaseValue` and `ArmNextNativeCaseValueCopyFault`, and is limited observation. Fault rows stay in `OutCaseCount`: `ARGUMENT_EVALUATION` and `BODY` use `Divide by zero`; `RETURN_CONSTRUCTION` uses `Native case value copy construction fault`.
