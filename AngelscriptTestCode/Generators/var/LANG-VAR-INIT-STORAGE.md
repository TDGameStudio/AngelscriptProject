# LANG-VAR-INIT-STORAGE

Author reference for `FVarInitStorageGenerator`. This file is not part of the ordinary `.as` projection.

## Axes

1. Initializer: `DEFAULT` | `LITERAL` | `EXPRESSION` | `COPY` | `CONSTRUCTOR` | `FUNCTION_RETURN` | `CONDITIONAL`
2. Storage: `LOCAL` | `CONST_LOCAL` | `AUTO` | `LOOP_INITIALIZER` | `BRANCH_LOCAL` | `CONST_GLOBAL` | `FIELD_LINKAGE`
3. Type: `INT8` | `INT16` | `INT` | `INT64` | `UINT8` | `UINT16` | `UINT` | `UINT64` | `FLOAT32` | `FLOAT64` | `BOOL` | `ENUM` | `TYPEDEF` | `SCRIPT_VALUE` | `NATIVE_VALUE`

Product ID prefix: `LANG-VAR-INIT-STORAGE`. Complete set: 735 cells. Normal-return = 713. Compile reject = 22 (`default`+`auto` = 15, `const_global`+`native_value` = 7). Runtime fault = 0.

Example: `LANG-VAR-INIT-STORAGE-DEFAULT-LOCAL-INT8` → `int EntryLangVarInitStorageDefaultLocalInt8()`.

## Source branches

Shared helpers once: `ENativeCaseEnum`, `NativeCaseAlias`, script/native values, unique `MakeVariableValue{Type}`, unique `FVariableHolder{Init}{Type}`, and unique `VariableValue{Init}{Type}` const globals.

Entries return the observed oracle value (0/1/2) so `GetExpected` matches the generated return and is not a constant 1.

## Observation

- `default` → 0
- `expression` and type is not bool/enum/object → 2
- otherwise → 1

Default cells are real expected-zero rows. `GetExpected` returns 0 for reject IDs and unknown IDs; that fallback is not membership proof.

`BuildVariableSource` accepts every compiling cell. Empty `FunctionName` emits `Entry`. Positive builders refuse reject-category inputs.
