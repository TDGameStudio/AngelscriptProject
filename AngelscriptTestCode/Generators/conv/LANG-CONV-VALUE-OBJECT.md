# LANG-CONV-VALUE-OBJECT

Author reference for `FConvValueObjectGenerator`. This file is not part of the ordinary `.as` projection.

## Axes

Documented order, uppercase catalog tokens, hyphen-separated. Multiword tokens keep internal underscores.

1. Availability: `IMPLICIT_CONSTRUCTOR` | `EXPLICIT_CONSTRUCTOR` | `IMPLICIT_OPERATOR` | `EXPLICIT_OPERATOR` | `CONSTRUCTOR_AND_OPERATOR` | `NONE`
2. Target: `SAME_VALUE` | `OTHER_VALUE` | `INT` | `FLOAT64` | `BOOL`
3. Form: `ASSIGNMENT` | `INITIALIZER` | `ARGUMENT` | `RETURN` | `EXPLICIT_CAST` | `DIRECT_CONSTRUCTOR`
4. Outcome: `DIRECT` | `SELECTED` | `AMBIGUOUS` | `REJECTED`

Product ID prefix: `LANG-CONV-VALUE-OBJECT`. Complete set: 6×5×6×4 = 720 cells. Normal-return aggregate = 200. Compile reject = 520. Runtime fault = 0.

Example: `LANG-CONV-VALUE-OBJECT-IMPLICIT_CONSTRUCTOR-SAME_VALUE-ASSIGNMENT-DIRECT` → `int EntryLangConvValueObjectImplicitConstructorSameValueAssignmentDirect()`.

## Source branches

Case-dependent structs are qualified by the CaseId suffix after `EntryLangConvValueObject`. `float64` uses catalog spelling `double`. Every entry starts with `SourceValue(7)`.

`FValueConversionTarget{Suffix}` publishes an implicit, explicit, or combined converting constructor when availability includes a constructor. `FValueConversionSource{Suffix}` publishes `opImplConv` / `opConv` when availability includes an operator. Operator markers: implicit other-value 207, explicit other-value 307, bool true/false, numeric `Value + 200` / `Value + 300`.

Forms:

- assignment / initializer / argument / return / `explicit_cast` `{Target}(SourceValue)` / `direct_constructor` `{Target} TargetValue(SourceValue)`
- `ambiguous` calls `SelectValueAmbiguity{Suffix}`
- `rejected` calls `RejectValueConversion{Suffix}`

`ShouldCompile` is false for `ambiguous`/`rejected` and for `direct`/`selected` rows whose availability cannot serve the form (`HasImplicitSelectedPath` vs `HasExplicitSelectedPath`). `BuildValueObjectConversionSource` is positive-only. Empty `FunctionName` emits `Entry`. Invalid identifiers such as `bad-name` emit no source.

## Observation

`ExpectedSelectedMarker`: `same_value` = 7 (`SourceValue(7).Value`); `other_value` constructor path 107, implicit-operator 207, explicit-operator 307; `bool` 0 for explicit-operator else 1; numeric 307 for explicit-operator else 207.

`EXPLICIT_OPERATOR-BOOL-EXPLICIT_CAST-DIRECT` is a real expected zero and keeps `ExpectedReturn` set.

Normal rows are `ReturnValue` + `Standalone`. Reject rows are `CompileReject` with no declaration. `GetExpected` is 0 for reject and unknown IDs; that fallback is not membership proof.
