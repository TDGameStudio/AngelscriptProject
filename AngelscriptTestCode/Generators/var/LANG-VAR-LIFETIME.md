# LANG-VAR-LIFETIME

Author reference for `FVarLifetimeGenerator`. This file is not part of the ordinary `.as` projection.

## Axes

1. Exit: `BLOCK_END` | `RETURN` | `BREAK` | `CONTINUE` | `EXCEPTION`
2. Nesting: `ONE` | `SEQUENTIAL` | `NESTED_SCOPES` | `LOOP` | `NESTED_CALL`
3. Owner: `LOCAL_VALUE` | `NESTED_VALUE` | `FIELD` | `REFERENCE`

Product ID prefix: `LANG-VAR-LIFETIME`. Complete set: 100 cells. Normal-return = 80. Compile reject = 0. Runtime fault = 20 (`exception` × 5 nestings × 4 owners). Faults stay in `OutCaseCount` (100).

Example: `LANG-VAR-LIFETIME-BLOCK_END-ONE-LOCAL_VALUE` → `int EntryLangVarLifetimeBlockEndOneLocalValue()`.

## Source branches

Shared helpers once: `FNativeCaseValue`, `FNativeCaseReference`, `CreateNativeCaseReference`, `FNestedLifetimeValue`, `FFieldLifetimeOwner`, and `RaiseVariableLifetimeException` (`1 / Zero`). Nested-call cells emit unique `Nested{EntryName}` helpers.

## Observation

- `block_end` → 71
- `return` → 72
- `break` → 73
- `continue` → 74
- `exception` → `Divide by zero`, no integer expectation

`BuildVariableLifetimeSource` accepts every valid cell. Empty `FunctionName` emits `Entry`.
