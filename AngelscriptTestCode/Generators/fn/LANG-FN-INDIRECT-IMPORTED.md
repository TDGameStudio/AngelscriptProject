# LANG-FN-INDIRECT-IMPORTED

Author reference for `FFnIndirectImportedGenerator`. This file is not part of the ordinary `.as` projection.

## Axes

1. Scenario: `DECLARATION_METADATA` | `COMPATIBLE_DIRECT` | `COMPATIBLE_NESTED` | `NULL_OR_UNBOUND` | `INCOMPATIBLE_SIGNATURE` | `REBUILD_OR_REBIND`

Complete set: 6 cells. Aggregate entries = 0. Compile reject = 6. `BuildAllSource` sets `OutCaseCount = 0`.

Example: `LANG-FN-INDIRECT-IMPORTED-DECLARATION_METADATA`.

## Source branches

Every reject module contains `import int SharedValue() from "ImportProvider";` plus an isolated entry. Compatible/nested/rebuild modules also emit a provider stub (`return 42;`, `ProviderHelper`, or `ReplacementSharedValue`). Incompatible emits `int SharedValue(int Value)`.

`BuildImportProviderSource` is positive-only and therefore empty for every catalog cell.

## Observation

No normal-return integer. `GetExpected` is 0. Rows are `CompileReject` + `SourceOnly` because import binding is host module protocol, not a standalone aggregate.
