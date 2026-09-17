# LANG-CTOR-TRANSFER

Author reference for `FCtorTransferGenerator`. This file is not part of the ordinary `.as` projection.

## Axes

Documented order, uppercase catalog tokens, hyphen-separated. Multiword tokens keep internal underscores.

1. Source: `SCRIPT_VALUE_LOCAL` | `SCRIPT_VALUE_TEMPORARY` | `SCRIPT_VALUE_RETURN` | `NATIVE_VALUE_LOCAL` | `NATIVE_VALUE_TEMPORARY` | `NATIVE_VALUE_RETURN` | `SCRIPT_REFERENCE_LOCAL` | `SCRIPT_REFERENCE_TEMPORARY` | `SCRIPT_REFERENCE_RETURN` | `NATIVE_REFERENCE_LOCAL` | `NATIVE_REFERENCE_TEMPORARY` | `NATIVE_REFERENCE_RETURN` | `DERIVED_REFERENCE_EXACT` | `DERIVED_REFERENCE_BASE_VIEW`
2. Workflow: `COPY_DECLARATION_LOCAL` | `FIELD_CONSTRUCTOR_TRANSFER` | `ASSIGNMENT_LOCAL` | `FIELD_ASSIGNMENT_AFTER_DEFAULT` | `ARGUMENT_TRANSFER` | `RETURN_TRANSFER` | `SELF_ASSIGNMENT` | `CHAINED_ASSIGNMENT`
3. Observation: `INITIAL_IDENTITY_VALUE` | `SOURCE_OR_TEMPORARY_STATE` | `TARGET_MUTATION_RELATION` | `LIFECYCLE_CLEANUP`

Product ID prefix: `LANG-CTOR-TRANSFER`. Complete set: 14×8×4 = 448 cells. All 448 are normal-return aggregate entries. Compile reject = 0. Runtime fault = 0.

Example: `LANG-CTOR-TRANSFER-SCRIPT_VALUE_LOCAL-COPY_DECLARATION_LOCAL-INITIAL_IDENTITY_VALUE` → `int EntryLangCtorTransferScriptValueLocalCopyDeclarationLocalInitialIdentityValue()`.

## Source branches

Shared helpers, emitted once per aggregate:

- `RecordConstructorTransferState`
- `FNativeCaseValue`, `FNativeCaseReference`, `FTransferValue`, `FTransferReference`, `FTransferBase`, `FTransferDerived`

Temporary sources construct `Target = Type(7)` only. Retained sources construct `Source` then `Target = Source`. Workflows then:

- copy declaration: `Copied = Target`; mutate target to 23
- field constructor: `Field = Target`; mutate to 23
- assignment: `Assigned = Target`; mutate to 23
- field assignment after default: default `Field` then `Field = Target`
- argument: capture `Auxiliary = Target.Value` then mutate
- return: mutate target to 23
- self assignment: `Target = Target` then mutate to 23
- chained: `Last = Mid = Target` then mutate to 31

`BuildConstructorTransferSource` accepts every valid axis combination. Empty `FunctionName` emits `Entry`.

## Observation

Composite script kinds (script value/reference triples and both derived views) pack `StateValue(v) = v * 10000 + (v + 100)`. Native kinds use `v` directly.

- `INITIAL_IDENTITY_VALUE` → `StateValue(7)`
- `SOURCE_OR_TEMPORARY_STATE` → `-1` for temporary sources, otherwise `StateValue(23)`
- `TARGET_MUTATION_RELATION` → 2 temporary, 1 retained reference, 0 retained value
- `LIFECYCLE_CLEANUP` → 1 (limited observation)

`SCRIPT_VALUE_LOCAL` + `TARGET_MUTATION_RELATION` is a real expected zero and keeps `ExpectedReturn` set. Rows are `ReturnValue` + `RequiresHostSetup`.
