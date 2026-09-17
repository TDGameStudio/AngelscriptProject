# LANG-CTOR-KIND-CALL

Author reference for `FCtorKindCallGenerator`. This file is not part of the ordinary `.as` projection.

## Axes

Documented order, uppercase catalog tokens, hyphen-separated. Multiword tokens keep internal underscores.

1. Call: `LOCAL` | `TEMPORARY` | `FIELD` | `RETURN` | `ARGUMENT` | `BASE_CALL` | `COPY_DECLARATION` | `ASSIGNMENT`
2. Kind: `IMPLICIT_DEFAULT` | `DECLARED_DEFAULT` | `PARAMETERIZED` | `OVERLOADED` | `COPY` | `CONVERSION`
3. Object: `SCRIPT_VALUE` | `SCRIPT_REFERENCE` | `BASE` | `DERIVED` | `NATIVE_VALUE` | `NATIVE_REFERENCE`

Product ID prefix: `LANG-CTOR-KIND-CALL`. Complete set: 8×6×6 = 288 cells. Normal-return aggregate = 257. Compile reject = 31. Runtime fault = 0.

Reject rule: `BASE_CALL` unless the object is `DERIVED` and the kind is not `IMPLICIT_DEFAULT` (31 cells).

Example: `LANG-CTOR-KIND-CALL-LOCAL-IMPLICIT_DEFAULT-SCRIPT_VALUE` → `int EntryLangCtorKindCallLocalImplicitDefaultScriptValue()`.

## Source branches

Shared helpers, emitted once per aggregate or isolated reject module:

- `RecordConstructorKindSelected`, `RecordConstructorCallRoute`, `RecordConstructorTransferObservation`, `RecordConstructorScriptCopy`
- native stubs `FNativeCaseValue`, `FNativeCaseReference`, and `MakeNativeReference*` factories

Script types are emitted once per (kind, object) as `FKindObject{Kind}{Object}`. Implicit default value objects use `Type Selected;` without a call. Parameterized uses `Type(7)`, overloaded `Type(3, 4)`, conversion `Type(int64(int8(7)))`. Copy kinds construct from a mutated source and record transfer. Call routes:

- local / argument: construct `Selected` and return `.Value`
- temporary / return: return `(expr).Value`
- field: store a copy, return stored value
- base call: construct, then illegal/legal `super()`
- copy declaration: `Copied = Selected` after mutating source to 9
- assignment: `Assigned = Selected` after mutating source to 9

`BuildConstructorSelectionSource` is positive-only. Empty `FunctionName` emits `Entry`.

## Observation

`Base = (Kind==IMPLICIT_DEFAULT) || (Kind==DECLARED_DEFAULT && Object==NATIVE_VALUE) ? 0 : 7`.

If the object is a reference, the call is not `BASE_CALL`, and the cell is a copy kind or a copy-declaration/assignment call, the observed value is 9 instead of `Base`.

`LOCAL-IMPLICIT_DEFAULT-SCRIPT_VALUE` is a real expected zero and keeps `ExpectedReturn` set. Reject IDs and unknown IDs return 0 from `GetExpected` without membership proof. Normal rows are `ReturnValue` + `RequiresHostSetup`.
