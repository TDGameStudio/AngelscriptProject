# LANG-OP-OVERLOAD-BOOLEAN-CONSUMER

Author reference for `FOpOverloadBooleanConsumerGenerator`. This file is not part of the ordinary `.as` projection.

## Axes

Documented order, uppercase catalog tokens, hyphen-separated. Multiword tokens keep internal underscores.

1. Scenario: `COMPARISON_INT_PARAMETER` | `COMPARISON_VALUE_PARAMETER` | `COMPARISON_AMBIGUOUS_INT8` | `COMPARISON_MISSING_LESS`
2. Context: `ASSIGNMENT` | `RETURN` | `CONDITION` | `OVERLOAD_ARGUMENT` | `CHAIN`

Product ID prefix: `LANG-OP-OVERLOAD-BOOLEAN-CONSUMER`. Complete set: 4×5 = 20 cells. Normal-return aggregate = 10. Compile reject = 10. Runtime fault = 0.

Example: `LANG-OP-OVERLOAD-BOOLEAN-CONSUMER-COMPARISON_INT_PARAMETER-ASSIGNMENT` → `int EntryLangOpOverloadBooleanConsumerComparisonIntParameterAssignment()`.

## Source branches

Success types are scenario-qualified and appear once in the aggregate with shared `ReturnBoolMarker` / `ConsumeBoolMarker` / `ChainBoolMarker`.

- Success evaluates `Left == 6` or `Left == Right` and maps true to Marker 107 or 108.
- Ambiguous reject declares `opEquals(int64)` and `opEquals(uint64)` and uses `Left == int8(6)`.
- Missing reject keeps value `opEquals` and uses `Left < Right`.

Reject modules are isolated and keep `// OP_OVERLOAD_OPERATION_CAUSE`. `BuildScenarioSource` is positive-only.

## Observation

`GetExpected` is Marker 107 or 108 for the ten success IDs and 0 for reject or unknown IDs. That zero fallback is not membership proof. Marker is a scenario identity, not full-width arithmetic proof.

Success rows are `ReturnValue` + `Standalone` with limited observation. Reject rows are `CompileReject` + `SourceOnly`.
