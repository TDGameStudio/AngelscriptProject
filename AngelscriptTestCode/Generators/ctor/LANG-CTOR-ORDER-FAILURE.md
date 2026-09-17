# LANG-CTOR-ORDER-FAILURE

Author reference for `FCtorOrderFailureGenerator`. This file is not part of the ordinary `.as` projection.

## Axes

Documented order, uppercase catalog tokens, hyphen-separated. Multiword tokens keep internal underscores.

1. Failure: `NONE` | `BASE` | `MEMBER_FIRST` | `MEMBER_MIDDLE` | `MEMBER_LAST` | `DERIVED_BODY` | `COPY` | `CONVERSION`
2. Depth: `FLAT_MEMBERS` | `NESTED_MEMBERS` | `DEEP_NESTED_MEMBERS` | `BASE_AND_DERIVED_MEMBERS`
3. Observation: `VALUES` | `EVENT_ORDER` | `CLEANUP` | `CONTEXT_REUSE`

Product ID prefix: `LANG-CTOR-ORDER-FAILURE`. Complete set: 8×4×4 = 128 cells. Normal-return aggregate = 16 (`NONE` × 4 depths × 4 observations). Compile reject = 0. Runtime fault = 112. Every cell stays in `OutCaseCount`.

Example: `LANG-CTOR-ORDER-FAILURE-NONE-FLAT_MEMBERS-VALUES` → `int EntryLangCtorOrderFailureNoneFlatMembersValues()`.

## Source branches

Shared helpers, emitted once per aggregate:

- `RecordConstructorFailureBegin`, `RecordConstructorFailureComplete`, `RecordConstructorFailureDestroy`
- `ConvertConstructorFailureInput`
- `FNativeCaseValue`

Each (failure, depth) pair owns uniquely tagged stage values, optional wrappers, and `FCtorFailGraph{Failure}{Depth}`. Member values are 20/30/40; graph `Total()` is `10 + First + Middle + Last + 50` = 150 when construction completes.

A failing stage emits `int Trigger = 1 / 0;` after `RecordConstructorFailureBegin`. Copy and conversion failures also inject that trigger in the graph constructor. Host `SetException` is normalized to this script divide-by-zero.

`BuildConstructorFailureSource` accepts every valid axis combination, including faults. Empty `FunctionName` emits `Entry`.

## Observation

Normal rows (`NONE`) return 150. Fault rows are `RuntimeException` with exact text `Divide by zero` and no integer value. `GetExpected` is 150 for `NONE` IDs and 0 for faults and unknown IDs. Limited observation applies when the observation axis is not `VALUES`. Executable rows are `RequiresHostSetup`.
