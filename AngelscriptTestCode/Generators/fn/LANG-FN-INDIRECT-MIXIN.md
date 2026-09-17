# LANG-FN-INDIRECT-MIXIN

Author reference for `FFnIndirectMixinGenerator`. This file is not part of the ordinary `.as` projection.

## Axes

1. Scenario: `DECLARATION_METADATA` | `COMPATIBLE_DIRECT` | `COMPATIBLE_NESTED` | `NULL_OR_UNBOUND` | `INCOMPATIBLE_SIGNATURE` | `REBUILD_OR_REBIND`

Complete set: 6 cells. Normal-return aggregate = 4. Compile reject = 2 (`NULL_OR_UNBOUND`, `INCOMPATIBLE_SIGNATURE`).

Example: `LANG-FN-INDIRECT-MIXIN-DECLARATION_METADATA`.

## Source branches

Shared `FMixinReceiver` (`Value = 40`) and `mixin int AddValue(..., int Delta)` returning `Self.Value + Delta + 0`.

- Compatible/direct/metadata/rebuild: `Value.AddValue(2)`
- Nested: `InvokeMixin(Value)` which calls `AddValue(2)`
- Null/unbound: `Value.MissingMixin(2)`
- Incompatible: `int Value = 40;` then `Value.AddValue(2)`

`BuildMixinSource` is positive-only.

## Observation

Normal expected is `40 + 2 + 0 = 42`. `REBUILD_OR_REBIND` keeps that source oracle and is `SourceOnly` + `bLimitedObservation` because the rebuilt marker-10 result is host lifecycle. Rejects have no integer. Unknown `GetExpected` is 0.
