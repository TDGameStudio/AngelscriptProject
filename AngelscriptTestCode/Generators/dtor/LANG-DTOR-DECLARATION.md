# LANG-DTOR-DECLARATION

Author reference for `FDtorDeclarationGenerator`. This file is not part of the ordinary `.as` projection.

## Axes

Documented order, uppercase catalog tokens, hyphen-separated. Multiword tokens keep internal underscores.

1. Scenario: `IMPLICIT_SCRIPT_VALUE` | `DECLARED_SCRIPT_VALUE` | `IMPLICIT_SCRIPT_REFERENCE` | `DECLARED_SCRIPT_REFERENCE` | `NATIVE_VALUE` | `NATIVE_REFERENCE` | `EMPTY_DESTRUCTOR` | `FIELD_DESTRUCTOR` | `BASE_DERIVED_DESTRUCTOR` | `PRIVATE_DESTRUCTOR` | `THROWING_DESTRUCTOR` | `THROWING_DERIVED_MEMBERS_BASE` | `MALFORMED_DESTRUCTOR`
2. Observation: `COMPILE` | `METADATA` | `RUNTIME` | `CLEANUP`

Product ID prefix: `LANG-DTOR-DECLARATION`. Complete set: 13×4 = 52 cells. Enumeration nests Scenario (outer) then Observation (inner).

Normal-return aggregate = 40. Compile reject = 4 (`MALFORMED_DESTRUCTOR` × every observation). Runtime fault (`divide_by_zero`) = 8 (`THROWING_DESTRUCTOR` and `THROWING_DERIVED_MEMBERS_BASE` × every observation). OutCaseCount = 48 (faults stay in the aggregate).

Example: `LANG-DTOR-DECLARATION-IMPLICIT_SCRIPT_VALUE-COMPILE` → `int EntryLangDtorDeclarationImplicitScriptValueCompile()`.

## Source branches

Shared types are emitted once per aggregate. Isolated single-case modules emit only the scenario's types. `int RunDestructorDeclarationRecovery()` is appended to every non-reject module.

Scenario types and entry construction:

- `IMPLICIT_SCRIPT_VALUE`: `struct FImplicitValue` with `FNativeCaseValue Tracked` and `Value = 41`; entry constructs `FImplicitValue Object` and returns `Object.Value`.
- `DECLARED_SCRIPT_VALUE`: declared `~FDeclaredValue()` records marker 102; `Value = 42`.
- `IMPLICIT_SCRIPT_REFERENCE`: `class FImplicitReference`; `Value = 43`; entry uses `FImplicitReference()`.
- `DECLARED_SCRIPT_REFERENCE`: declared destructor records 104; `Value = 44`.
- `NATIVE_VALUE`: `FNativeCaseValue Object(45)`.
- `NATIVE_REFERENCE`: `CreateNativeCaseReference(46)`.
- `EMPTY_DESTRUCTOR`: empty `~FEmptyDestructor()`; `Value = 47`.
- `FIELD_DESTRUCTOR`: `FDeclarationField1..3` (markers 301–303) plus `FFieldOwner` (marker 399); `Value = 48`.
- `BASE_DERIVED_DESTRUCTOR`: `FDestructorBase` (502) / `FDestructorDerived` (501); `Value = 49`.
- `PRIVATE_DESTRUCTOR`: `private ~FPrivateDestructor()` records 601; `Value = 50`.
- `THROWING_DESTRUCTOR`: `FThrowingDestructor` records 701; entry adds `int Fault = 1 / Zero`.
- `THROWING_DERIVED_MEMBERS_BASE`: member and base/derived markers 811/812/802/801; entry adds `1 / Zero`.
- `MALFORMED_DESTRUCTOR`: `~FMalformedDestructor(int InvalidParameter)` reject module; entry returns 0.

Observation does not change source text; it only labels the catalog cell. `BuildDestructorDeclarationSource` is positive-only and returns empty for `MALFORMED_DESTRUCTOR`. `BuildRejectSource` and `ListRejectCaseIds` own the four reject modules. Empty `FunctionName` emits `Entry`. Invalid identifiers such as `bad-name` emit no source.

## Observation

`GetExpected` is the scenario `ExpectedValue` for the 40 normal IDs: 41–50 in documented scenario order through `PRIVATE_DESTRUCTOR`. Fault and reject IDs, and unknown IDs, return 0; that zero fallback is not membership proof.

Normal rows are `ReturnValue` + `RequiresHostSetup`. Fault rows are `RuntimeException` with exact text `Divide by zero` and no integer expectation. Reject rows are `CompileReject` + `SourceOnly` with no declaration. Host notes name `FNativeCaseValue`, `FNativeCaseReference`, and `RecordDestructorDeclarationMarker`.
