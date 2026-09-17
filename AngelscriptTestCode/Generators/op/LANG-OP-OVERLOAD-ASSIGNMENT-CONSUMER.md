# LANG-OP-OVERLOAD-ASSIGNMENT-CONSUMER

Author reference for `FOpOverloadAssignmentConsumerGenerator`. This file is not part of the ordinary `.as` projection.

## Axes

Documented order, uppercase catalog tokens, hyphen-separated. Multiword tokens keep internal underscores.

1. Scenario: `ASSIGNMENT_INT_PARAMETER` | `ASSIGNMENT_VALUE_PARAMETER` | `ASSIGNMENT_AMBIGUOUS_INT8` | `ASSIGNMENT_MISSING_ADD_ASSIGN`
2. Context: `ASSIGNMENT` | `RETURN` | `CONDITION` | `OVERLOAD_ARGUMENT` | `CHAIN` | `SWITCH_INDEX`

Product ID prefix: `LANG-OP-OVERLOAD-ASSIGNMENT-CONSUMER`. Complete set: 4×6 = 24 cells. Normal-return aggregate = 12. Compile reject = 12. Runtime fault = 0.

Example: `LANG-OP-OVERLOAD-ASSIGNMENT-CONSUMER-ASSIGNMENT_INT_PARAMETER-ASSIGNMENT` → `int EntryLangOpOverloadAssignmentConsumerAssignmentIntParameterAssignment()`.

## Source branches

Success types are scenario-qualified (`FOverloadedAssignmentIntParameter`, `FOverloadedAssignmentValueParameter`) and appear once in the aggregate with `ReturnValueMarker` / `ConsumeValueMarker` / `ChainValueMarker` overloads.

- Success `opAssign` sets `Value` to Marker 114 (int) or 115 (value). This fork materializes assignment as a statement, then feeds `Left` through the consumer context.
- Ambiguous reject declares `opAssign(int64)` and `opAssign(uint64)` and uses `Left = int8(6)`.
- Missing reject keeps value `opAssign` and uses `Left += Right`.

Reject modules are isolated and keep `// OP_OVERLOAD_OPERATION_CAUSE`. `BuildScenarioSource` is positive-only.

## Observation

`GetExpected` is Marker 114 or 115 for the twelve success IDs and 0 for reject or unknown IDs. That zero fallback is not membership proof. Marker is a scenario identity, not full-width arithmetic proof.

Success rows are `ReturnValue` + `Standalone` with limited observation. Reject rows are `CompileReject` + `SourceOnly`.
