# LANG-VAR-REFERENCE-INIT

Author reference for `FVarReferenceInitGenerator`. This file is not part of the ordinary `.as` projection.

## Axes

1. Declaration: `EXPLICIT_TYPE` | `AUTO` | `CONST_VIEW`
2. Source: `CONSTRUCTED_LOCAL` | `PARAMETER` | `FUNCTION_RETURN` | `FIELD` | `NULL`
3. Type: `SCRIPT_REFERENCE` | `NATIVE_REFERENCE`
4. Use: `IDENTITY` | `MUTATION` | `ARGUMENT` | `RETURN` | `NULL_COMPARE`

Product ID prefix: `LANG-VAR-REFERENCE-INIT`. Complete set: 150 cells. Normal-return = 128. Compile reject = 20 (`null`+`auto` = 10, `const_view`+`mutation` = 10). Runtime fault = 2 (`null`+`explicit_type`+`mutation` × both types, `Null pointer access`). Faults stay in `OutCaseCount` (130).

Example: `LANG-VAR-REFERENCE-INIT-EXPLICIT_TYPE-CONSTRUCTED_LOCAL-SCRIPT_REFERENCE-IDENTITY` → `int EntryLangVarReferenceInitExplicitTypeConstructedLocalScriptReferenceIdentity()`.

## Source branches

Shared helpers once: script/native reference types, unique `FVariableReferenceHolderScript` / `FVariableReferenceHolderNative`, `PassVariableReference` overloads, and `ObserveVariableReference` overloads. Parameter cells emit unique `Exercise{EntryName}` helpers.

## Observation

Normal rows return 1. Faults carry `Null pointer access` and no integer expectation. `BuildReferenceInitializationSource` refuses reject-category inputs. Empty `FunctionName` emits `Entry`.
