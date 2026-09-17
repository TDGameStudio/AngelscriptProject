# LANG-CF-SWITCH-PLACEMENT

Author reference for `FSwitchPlacementGenerator`. This file is not part of the ordinary `.as` projection.

## Axes

Documented order, uppercase catalog tokens, hyphen-separated. Multiword tokens keep internal underscores.

1. Scope: `FUNCTION` | `BRANCH` | `LOOP` | `AFTER_SWITCH`
2. Kind: `CASE_OUTSIDE` | `DEFAULT_OUTSIDE` | `DUPLICATE_DEFAULT` | `CASE_AFTER_DEFAULT`

Product ID prefix: `LANG-CF-SWITCH-PLACEMENT`. Complete set: 4×4 = 16 cells. Normal-return aggregate = 0. Compile reject = 16. Runtime fault = 0.

Example: `LANG-CF-SWITCH-PLACEMENT-FUNCTION-CASE_OUTSIDE` → `int EntryLangCfSwitchPlacementFunctionCaseOutside()`. Catalog membership token `LANG-CF-SWITCH-PLACEMENT` is the product prefix, not a cell.

## Source branches

No shared helpers. Each reject module is a single illegal function:

- `CASE_OUTSIDE`: bare `case 1:` that adds 10
- `DEFAULT_OUTSIDE`: bare `default:` that adds 20
- `DUPLICATE_DEFAULT`: `switch` with two `default` labels adding 30 then 40
- `CASE_AFTER_DEFAULT`: `switch` with `default` adding 50 then `case 1` adding 60

Scope wrappers:

- `FUNCTION`: illegal construct at function scope
- `BRANCH`: wrap in `if (true) { ... }`
- `LOOP`: wrap in `while (false) { ... }`
- `AFTER_SWITCH`: emit a valid `switch` first, then the illegal construct

`BuildSwitchPlacementSource` is positive-only and always returns empty because every cell is reject. `BuildRejectSource` and `ListRejectCaseIds` own all 16 modules. `BuildAllSource` emits no entries and reports `OutCaseCount = 0`. Empty `FunctionName` is unused on the positive builder. Invalid identifiers such as `bad-name` emit no source.

## Observation

There are no normal-return cells. `GetExpected` returns 0 for every ID including unknown IDs. That zero fallback is not membership proof.

Every row is `CompileReject` with no declaration and `SourceOnly` execution. No host, lifecycle, or limited-observation notes apply.
