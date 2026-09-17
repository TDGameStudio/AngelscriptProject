# LANG-FN-INDIRECT-REGISTERED-FUNCDEF

Author reference for `FFnIndirectRegisteredFuncdefGenerator`. This file is not part of the ordinary `.as` projection.

## Axes

1. Scenario: `DECLARATION_METADATA` | `COMPATIBLE_DIRECT` | `COMPATIBLE_NESTED` | `NULL_OR_UNBOUND` | `INCOMPATIBLE_SIGNATURE` | `REBUILD_OR_REBIND`

Complete set: 6 cells. Aggregate entries = 0. Compile reject = 6.

Example: `LANG-FN-INDIRECT-REGISTERED-FUNCDEF-DECLARATION_METADATA`.

## Source branches

Every reject module starts with host note `RegisterFuncdef("int FCallback(int Value)")` and `funcdef int FCallback(int Value);`. Compatible cells add `int Target(int Value)` (`Value + 1`, nested `IndirectHelper`, or rebuild `Value + 10`). Incompatible adds `double Target(double Value)`.

`BuildRegisteredTargetSource` is positive-only and empty for every catalog cell.

## Observation

No normal-return integer. Rows are `CompileReject` + `SourceOnly` because registration is host `RegisterFuncdef`.
