# LANG-VAR-FAILURE-BOUNDARY

Author reference for `FVarFailureBoundaryGenerator`. This file is not part of the ordinary `.as` projection.

## Axes

1. Recovery: `FRESH_MODULE` | `SAME_MODULE_OR_CONTEXT`
2. Scenario: `USE_BEFORE_DECLARATION` | `USE_AFTER_SCOPE` | `DUPLICATE_SAME_SCOPE` | `INCOMPATIBLE_INITIALIZER` | `MUTABLE_GLOBAL` | `REFERENCE_GLOBAL` | `UNINITIALIZED_READ` | `INITIALIZER_EXCEPTION` | `FAILED_INITIALIZER_ATOMICITY` | `LONG_IDENTIFIER` | `MANY_LOCALS_SUPPORTED` | `MANY_LOCALS_BOUNDARY` | `STACK_FRAME_PRESSURE` | `MODULE_DISCARD`

Product ID prefix: `LANG-VAR-FAILURE-BOUNDARY`. Complete set: 28 cells. Normal-return = 12. Compile reject = 12 (first six scenarios). Runtime fault = 4 (`initializer_exception` and `failed_initializer_atomicity` × both recoveries). Faults stay in `OutCaseCount` (16).

Example: `LANG-VAR-FAILURE-BOUNDARY-FRESH_MODULE-LONG_IDENTIFIER` → `int EntryLangVarFailureBoundaryFreshModuleLongIdentifier()`.

## Source branches

Shared helpers once: `FNativeCaseValue`, `FNativeCaseReference`, `CreateNativeCaseReference`, and one `FDiscardVariableOwner`. `module_discard` entries use that shared owner so the two recovery cells do not collide.

`many_locals_supported` emits 128 locals. `many_locals_boundary` emits 2048 locals (contract-legal, omitted from representative gold). `stack_frame_pressure` emits 128 value objects (omitted from gold).

## Observation

- `long_identifier` / `module_discard` → 61
- `many_locals_supported` / `stack_frame_pressure` → 128
- `many_locals_boundary` → 2048
- faults → `Divide by zero` (`41 / Zero` or `1 / Zero`)
- `uninitialized_read` → `SourceOnly` limited, no `ExpectedReturn`
- `module_discard` → `SourceOnly` limited with ExpectedReturn 61

`BuildBoundarySource` refuses reject-category inputs. Empty `FunctionName` emits `Entry` for compiling cells.
