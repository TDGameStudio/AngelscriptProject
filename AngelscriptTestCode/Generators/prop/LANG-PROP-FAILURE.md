# LANG-PROP-FAILURE

Author reference for `FPropFailureGenerator`. This file is not part of the ordinary `.as` projection.

## Axes

Documented order, uppercase catalog tokens, hyphen-separated. Multiword tokens keep internal underscores.

1. Failure: `REMOVED_PROPERTY_DECORATOR` | `REMOVED_VIRTUAL_PROPERTY` | `MISSING_GETTER` | `MISSING_SETTER` | `REGISTERED_MISMATCHED_TYPES` | `REGISTERED_DUPLICATE_GETTER` | `REGISTERED_DUPLICATE_SETTER` | `RECURSIVE_GETTER` | `RECURSIVE_SETTER` | `THROWING_GETTER` | `THROWING_SETTER` | `NULL_RECEIVER` | `INACCESSIBLE_FIELD` | `COMPOUND_VALUE_RECEIVER`
2. Probe: `DIRECT` | `ALTERNATE_PATH`
3. Recovery: `FRESH_MODULE` | `SAME_MODULE_OR_CONTEXT`

Product ID prefix: `LANG-PROP-FAILURE`. Complete set: 14×2×2 = 56 cells. Normal-return aggregate = 0. Compile reject = 36. Runtime fault = 20 (16 divide-by-zero + 4 null). Non-reject aggregate = 20.

Reject kinds: removed decorator/virtual property, missing getter/setter, registered mismatched/duplicate accessors, inaccessible field, compound value receiver.

Example: `LANG-PROP-FAILURE-NULL_RECEIVER-DIRECT-FRESH_MODULE` → `int EntryLangPropFailureNullReceiverDirectFreshModule()`.

## Source branches

Each owned module starts with `// Recovery: FRESH_MODULE|SAME_MODULE_OR_CONTEXT`. Removed decorator emits `int GetValue() property`. Removed virtual property emits a `get` block. Inaccessible field uses `private int Hidden`. Compound value receiver mutates `Receiver.Access`. Null receiver assigns `nullptr`. Recursive/throwing kinds return `1 / Zero`. Alternate-path probes wrap the trigger in a helper.

`BuildPropertyFailureSource` is positive-only and returns empty for reject cells, including the default constructor. `BuildRejectSource` and `ListRejectCaseIds` own the 36 reject modules. Empty `FunctionName` emits `Entry` for fault cells. Invalid identifiers such as `bad-name` emit no source.

## Observation

There is no normal-return integer. Fault rows are `RuntimeException` + `Standalone`: `Null pointer access` for `NULL_RECEIVER`, otherwise `Divide by zero`. Reject rows are `CompileReject` with no declaration. `GetExpected` is 0 for every ID, including unknown IDs; that fallback is not membership proof.
