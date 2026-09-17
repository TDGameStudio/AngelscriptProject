# LANG-PROP-VISIBILITY

Author reference for `FPropVisibilityGenerator`. This file is not part of the ordinary `.as` projection.

## Axes

Documented order, uppercase catalog tokens, hyphen-separated. Multiword tokens keep internal underscores.

1. Access path: `OWNER_METHOD` | `OWNER_CONSTRUCTOR` | `OWNER_DESTRUCTOR` | `ACCESSOR_BODY` | `DIRECT_DERIVED` | `DEEP_DERIVED` | `UNRELATED_TYPE` | `GLOBAL_SAME_MODULE` | `BASE_VIEW_FROM_DERIVED` | `DERIVED_VIEW_FROM_GLOBAL`
2. Operation: `READ` | `WRITE`
3. Visibility: `DEFAULT` | `PRIVATE` | `PROTECTED`

Product ID prefix: `LANG-PROP-VISIBILITY`. Complete set: 10×2×3 = 60 cells. Normal-return aggregate = 42. Compile reject = 18. Runtime fault = 0.

Reject cells:

- derived paths (`DIRECT_DERIVED`, `DEEP_DERIVED`, `BASE_VIEW_FROM_DERIVED`) when visibility is `PRIVATE`
- unrelated / global / derived-view-from-global paths when visibility is not `DEFAULT`

Owner method, constructor, destructor, and accessor-body paths always compile.

Example: `LANG-PROP-VISIBILITY-OWNER_METHOD-READ-DEFAULT` → `int EntryLangPropVisibilityOwnerMethodReadDefault()`.

## Source branches

Shared helpers, emitted once per aggregate or isolated reject module: destructor observation storage and `RecordPropertyVisibilityDestructor` / `ReadPropertyVisibilityDestructor`.

Each case owns `FVisibilityOwner_<Entry>` plus derived, deep-derived, and optional unrelated types. The field is `VisibleValue = 41` with an optional `private`/`protected` prefix. Reads observe `VisibleValue`; writes assign `67` and reread through `ReadVisibleValue()`.

`BuildPropertyVisibilitySource` is positive-only and returns empty for reject cells. `BuildRejectSource` and `ListRejectCaseIds` own the 18 reject modules. Empty `FunctionName` emits `Entry`. Invalid identifiers such as `bad-name` emit no source.

## Observation

`GetExpected = Operation.ExpectedValue`: `41` for read, `67` for write. `GetExpected` uses this formula for the 42 normal IDs and returns 0 for reject and unknown IDs. That zero fallback is not membership proof. There is no real expected-zero normal cell.

Owner-destructor rows are `RequiresHostSetup`. Other normal rows are `Standalone`. Reject rows are `CompileReject` with no declaration.
