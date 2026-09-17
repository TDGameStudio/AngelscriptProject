# LANG-FN-INDIRECT-SCRIPT-FUNCDEF

Author reference for `FFnIndirectScriptFuncdefGenerator`. This file is not part of the ordinary `.as` projection.

## Axes

1. Scenario: `DECLARATION_METADATA` | `COMPATIBLE_DIRECT` | `COMPATIBLE_NESTED` | `NULL_OR_UNBOUND` | `INCOMPATIBLE_SIGNATURE` | `REBUILD_OR_REBIND`

Complete set: 6 cells. Aggregate entries = 0. Compile reject = 6.

Example: `LANG-FN-INDIRECT-SCRIPT-FUNCDEF-DECLARATION_METADATA`.

## Source branches

Each reject module emits `funcdef int FScriptCallback_<SCENARIO>(int Value);`, `int Target(int Value)` (`Value + 1` only for nested), and an isolated entry that returns `Target(42)` except `NULL_OR_UNBOUND` which returns `0`.

`BuildScriptFuncdefSource` is positive-only and empty for every catalog cell.

## Observation

No normal-return integer. The current fork parser rejects script-level `funcdef`. `GetExpected` is 0.
