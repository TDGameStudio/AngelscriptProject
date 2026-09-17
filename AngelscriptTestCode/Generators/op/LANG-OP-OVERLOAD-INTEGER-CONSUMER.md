# LANG-OP-OVERLOAD-INTEGER-CONSUMER

Author reference for `FOpOverloadIntegerConsumerGenerator`. This file is not part of the ordinary `.as` projection.

## Axes

Documented order, uppercase catalog tokens, hyphen-separated. Multiword tokens keep internal underscores.

1. Scenario: `UNARY_MEMBER` | `UNARY_CONST_MEMBER` | `BINARY_INT_MEMBER` | `BINARY_INT_CONST_MEMBER` | `BINARY_INT64_PROMOTION` | `BINARY_VALUE_PARAMETER` | `INDEX_INT_PARAMETER` | `INDEX_INT64_PROMOTION` | `CALL_INT_MEMBER` | `CALL_INT64_PROMOTION` | `CONVERSION_INT_TARGET` | `BINARY_AMBIGUOUS_INT8` | `INDEX_AMBIGUOUS_INT8` | `CALL_AMBIGUOUS_INT8` | `CONVERSION_AMBIGUOUS_TARGET` | `UNARY_MISSING_COMPLEMENT` | `BINARY_MISSING_SUBTRACT` | `INDEX_MISSING_SECOND_ARGUMENT` | `CALL_MISSING_SECOND_ARGUMENT` | `CONVERSION_MISSING_TARGET`
2. Context: `ASSIGNMENT` | `RETURN` | `CONDITION` | `OVERLOAD_ARGUMENT` | `CHAIN` | `SWITCH_INDEX`

Product ID prefix: `LANG-OP-OVERLOAD-INTEGER-CONSUMER`. Complete set: 20×6 = 120 cells. Normal-return aggregate = 66. Compile reject = 54. Runtime fault = 0.

Example: `LANG-OP-OVERLOAD-INTEGER-CONSUMER-UNARY_MEMBER-ASSIGNMENT` → `int EntryLangOpOverloadIntegerConsumerUnaryMemberAssignment()`.

## Source branches

Each scenario owns a qualified type so incompatible overloads cannot share one aggregate definition. Shared integer helpers (`ReturnIntMarker`, `ConsumeIntMarker`, `ChainIntMarker`) appear once.

Success expressions: `-Left`, `Left + 6`, `Left + int8(6)`, `Left + Right`, `Left[6]`, `Left[int8(6)]`, `Left(6)`, `Left(int8(6))`, `int(Left)`. Markers are 101–106 and 109–113.

Ambiguous rejects use `int8(6)` against dual int64/uint64 overloads, or `ConsumeAmbiguous(Left)` for conversion. Missing rejects use `~Left`, `Left - Right`, two-argument index/call, or `ConsumeMissingConversion(Left)`.

`BuildScenarioSource` is positive-only. Reject modules keep `// OP_OVERLOAD_OPERATION_CAUSE`.

## Observation

`GetExpected` is the scenario Marker for the 66 success IDs and 0 for reject or unknown IDs. That zero fallback is not membership proof. Marker is a scenario identity, not full-width arithmetic proof. `[AS-FORK-LIMITATION]` notes that some ambiguous overloads may resolve on the current fork; they remain reject-category source cells.

Success rows are `ReturnValue` + `Standalone` with limited observation. Reject rows are `CompileReject` + `SourceOnly`.
