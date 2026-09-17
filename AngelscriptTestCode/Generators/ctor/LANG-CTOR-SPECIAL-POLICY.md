# LANG-CTOR-SPECIAL-POLICY

Author reference for `FCtorSpecialPolicyGenerator`. This file is not part of the ordinary `.as` projection.

## Axes

Documented order, uppercase catalog tokens, hyphen-separated. Multiword tokens keep internal underscores.

1. Observation: `COMPILE` | `METADATA` | `RUNTIME` | `LIFECYCLE`
2. Scenario: `IMPLICIT_STRUCT_DEFAULT` | `DECLARED_STRUCT_DEFAULT` | `PARAMETER_PRESERVES_GENERATED_DEFAULT` | `PARAMETER_SUPPRESSES_DEFAULT_OPTION_OFF` | `IMPLICIT_STRUCT_COPY` | `DECLARED_STRUCT_COPY` | `IMPLICIT_STRUCT_ASSIGNMENT` | `DECLARED_STRUCT_ASSIGNMENT` | `USER_DESTRUCTOR_COPY` | `CLASS_FACTORY_DEFAULT` | `CLASS_PARAMETER_FACTORY` | `DERIVED_GENERATED_DEFAULT` | `DERIVED_EXPLICIT_SUPER` | `MISSING_BASE_DEFAULT_OPTION_OFF` | `COPY_AFTER_USER_CONSTRUCTOR` | `ASSIGNMENT_SELF_STABILITY`

Product ID prefix: `LANG-CTOR-SPECIAL-POLICY`. Complete set: 4×16 = 64 cells. Normal-return aggregate = 44. Compile reject = 20 (5 reject scenarios × 4 observations). Runtime fault = 0.

Reject scenarios: `PARAMETER_SUPPRESSES_DEFAULT_OPTION_OFF`, `IMPLICIT_STRUCT_COPY`, `USER_DESTRUCTOR_COPY`, `MISSING_BASE_DEFAULT_OPTION_OFF`, `COPY_AFTER_USER_CONSTRUCTOR`.

Example: `LANG-CTOR-SPECIAL-POLICY-COMPILE-IMPLICIT_STRUCT_DEFAULT` → `int EntryLangCtorSpecialPolicyCompileImplicitStructDefault()`.

## Source branches

Shared helpers, emitted once per aggregate or isolated reject module:

- `RecordConstructorPolicyMarker`
- `FNativeCaseValue`

Types are emitted once per scenario with unique tags. Implicit default constructs `FPolicyValue` with no user constructor. Declared default writes 12. Parameter-preserving cells construct both a defaulted value and `ParameterValue(13)`. Copy/assignment cells mutate a source then copy or assign. Class factory/parameter cells construct `FPolicyClass`. Derived generated default relies on a generated derived type; derived explicit super calls `super(13)`. Self-assignment writes 42 then `Value = Value`.

`BuildConstructorPolicySource` is positive-only. Empty `FunctionName` emits `Entry`.

## Observation

`GetExpected` for normal scenarios:

- implicit struct default → 0
- declared struct default → 12
- parameter preserves generated default → 13
- declared struct copy → 32
- implicit struct assignment → 34
- declared struct assignment → 36
- class factory default → 20
- class parameter factory → 21
- derived generated default → 34
- derived explicit super → 26
- assignment self stability → 84

`COMPILE-IMPLICIT_STRUCT_DEFAULT` is a real expected zero and keeps `ExpectedReturn` set. Limited observation applies when the observation axis is not `RUNTIME`. Normal rows are `ReturnValue` + `RequiresHostSetup`.
