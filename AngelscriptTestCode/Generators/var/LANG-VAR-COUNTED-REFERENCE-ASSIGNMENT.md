# LANG-VAR-COUNTED-REFERENCE-ASSIGNMENT

Author reference for `FVarCountedReferenceAssignmentGenerator`. This file is not part of the ordinary `.as` projection.

## Axes

Documented order, uppercase catalog tokens, hyphen-separated. Multiword tokens keep internal underscores.

1. Scenario: `FACTORY_LOCAL` | `OVERWRITE` | `NULL_ASSIGNMENT` | `PARAMETER_RETURN` | `EXCEPTION_FRAME` | `SAVE_LOAD` | `PARAMETER_RETURN_SAVE_LOAD`

Product ID prefix: `LANG-VAR-COUNTED-REFERENCE-ASSIGNMENT`. Complete set: 7 cells. Normal-return = 6. Compile reject = 0. Runtime fault = 1 (`EXCEPTION_FRAME`). Faults stay in `OutCaseCount`.

Example: `LANG-VAR-COUNTED-REFERENCE-ASSIGNMENT-FACTORY_LOCAL` → `int EntryLangVarCountedReferenceAssignmentFactoryLocal()`.

## Source branches

Shared helpers, emitted once per aggregate or isolated module: script `FNativeCaseReference`, `CreateNativeCaseReference`, `PassCountedReference`, and `RaiseCountedReferenceException` (`1 / Zero`).

- `factory_local` / `save_load`: copy `CreateNativeCaseReference(410)` into a local and return `Value.Value`
- `overwrite`: replace `420` with `CreateNativeCaseReference(421)`
- `null_assignment`: assign `nullptr` and return `1` when the handle is null
- `parameter_return` / `parameter_return_save_load`: `PassCountedReference(Value)` after `CreateNativeCaseReference(440)`
- `exception_frame`: `RaiseCountedReferenceException() + Value.Value` after `CreateNativeCaseReference(450)`

`BuildReferenceAssignmentSource` accepts every valid scenario. Empty `FunctionName` emits `Entry`. Invalid identifiers such as `bad-name` emit no source.

## Observation

Independent oracle:

- `factory_local` / `save_load` → 410
- `overwrite` → 421
- `null_assignment` → 1
- `parameter_return` / `parameter_return_save_load` → 440

`GetExpected` uses this table for the six non-fault IDs and returns 0 for the fault ID and unknown IDs. That zero fallback is not membership proof. There is no real expected-zero normal cell.

Normal rows are `ReturnValue` + `Standalone`. `save_load` and `parameter_return_save_load` keep the same return oracle but are `SourceOnly` with limited observation because bytecode save/load is host-only. The fault row is `RuntimeException` / `Divide by zero` with no integer expectation.
