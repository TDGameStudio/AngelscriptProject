# LANG-CTOR-BOUNDARY

Author reference for `FCtorBoundaryGenerator`. This file is not part of the ordinary `.as` projection.

## Axes

Documented order, uppercase catalog tokens, hyphen-separated. Multiword tokens keep internal underscores.

1. Scenario: `DUPLICATE_DEFAULT_SIGNATURE` | `DUPLICATE_PARAMETER_SIGNATURE` | `MISMATCHED_CONSTRUCTOR_NAME` | `CONSTRUCTOR_VALUE_RETURN` | `SUPER_OUTSIDE_CONSTRUCTOR` | `SUPER_AFTER_STATEMENT` | `REPEATED_SUPER` | `MISSING_BASE_ARGUMENT` | `AMBIGUOUS_BASE_ARGUMENT` | `INACCESSIBLE_BASE` | `RECURSIVE_VALUE_FIELD_DIRECT` | `RECURSIVE_VALUE_FIELD_INDIRECT` | `RECURSIVE_CONSTRUCTOR_DIRECT` | `RECURSIVE_CONSTRUCTOR_INDIRECT` | `MUTABLE_REFERENCE_GLOBAL` | `MODULE_DISCARD_CONST_VALUE_GLOBAL` | `ENGINE_SHUTDOWN_CONST_VALUE_GLOBAL`
2. Observation: `COMPILE_OR_EXECUTION_STATE` | `DIAGNOSTIC_OR_METADATA` | `LIFECYCLE_CLEANUP` | `RECOVERY_OR_TEARDOWN`

Product ID prefix: `LANG-CTOR-BOUNDARY`. Complete set: 17×4 = 68 cells. Normal-return aggregate = 20. Compile reject = 40 (10 reject scenarios × 4 observations). Runtime fault = 8 (`RECURSIVE_CONSTRUCTOR_DIRECT` and `RECURSIVE_CONSTRUCTOR_INDIRECT` × 4). Faults remain in `OutCaseCount` (28 non-reject aggregate entries).

Example: `LANG-CTOR-BOUNDARY-DUPLICATE_DEFAULT_SIGNATURE-COMPILE_OR_EXECUTION_STATE` → `int EntryLangCtorBoundaryDuplicateDefaultSignatureCompileOrExecutionState()`.

## Source branches

Shared helper, emitted once per aggregate or isolated reject module:

- empty `RecordConstructorBoundaryMarker(int Marker)`

Types are emitted once per scenario. Each scenario owns uniquely tagged `FBoundary*` names so cases cannot share mutable initialization.

- Duplicate default: two parameterless constructors writing 41 and 42.
- Duplicate parameter: two `int` constructors; limited observation, expected 0.
- Mismatched name: constructor named `FBoundaryOther`.
- Value return: constructor body `return 1;`.
- Super outside: free function calling `super()`.
- Super after statement: derived constructor records, then `super(7)`.
- Repeated super: two `super()` calls.
- Missing / ambiguous / inaccessible base: `super()` against a required, overloaded, or private base constructor.
- Recursive value fields: direct self-member or A↔B cycle.
- Recursive constructors: construct another instance of the same or peer type (stack overflow).
- Mutable reference global: retained class global.
- Module discard / engine shutdown: `const` retained value global initialized to 71.

`BuildConstructorBoundarySource` is positive-only and returns empty for reject scenarios. `BuildRejectSource` and `ListRejectCaseIds` own the 40 reject modules. Empty `FunctionName` emits `Entry`. Invalid identifiers such as `bad-name` emit no source.

## Observation

`GetExpected` for normal IDs:

- `DUPLICATE_DEFAULT_SIGNATURE` → 42
- `SUPER_AFTER_STATEMENT` → 7
- `MODULE_DISCARD_CONST_VALUE_GLOBAL` and `ENGINE_SHUTDOWN_CONST_VALUE_GLOBAL` → 71
- `DUPLICATE_PARAMETER_SIGNATURE` → 0 (populated `ExpectedReturn`; limited)

Reject and fault IDs return 0 from `GetExpected`. That zero fallback is not membership proof. Fault rows are `RuntimeException` with exact text `Stack overflow` and no integer value. Reject rows are `CompileReject` with no declaration. Executable rows are `RequiresHostSetup` with constructor-boundary host notes. Limited observation applies to every duplicate-parameter row, to discard/shutdown rows except compile-or-execution-state, and to any remaining non-reject row whose observation is not compile-or-execution-state.
