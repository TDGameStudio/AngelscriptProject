# LANG-REF-FAILURE

Author reference for `FRefFailureGenerator`. This file is not part of the ordinary `.as` projection.

## Axes

Documented order, uppercase catalog tokens, hyphen-separated. Multiword tokens keep internal underscores.

1. Failure: `EXPLICIT_HANDLE` | `CONST_REMOVAL` | `TEMPORARY_OUT` | `EXPIRED_LOCAL_RETURN` | `UNRELATED_ASSIGNMENT` | `UNRELATED_CAST` | `NULL_MEMBER_ACCESS` | `STALE_MODULE_OBJECT` | `AMBIGUOUS_OVERLOAD` | `INCOMPATIBLE_INOUT`
2. Recovery: `FRESH_MODULE` | `SAME_MODULE_OR_CONTEXT`

Product ID prefix: `LANG-REF-FAILURE`. Complete set: 10×2 = 20 cells. Normal-return aggregate = 0. Compile reject = 18. Runtime fault = 2 (`NULL_MEMBER_ACCESS` × both recoveries). Faults stay in `OutCaseCount`.

Example: `LANG-REF-FAILURE-NULL_MEMBER_ACCESS-FRESH_MODULE` → `int EntryLangRefFailureNullMemberAccessFreshModule()`.

## Source branches

Each failure kind is its own construction branch. Recovery is a host workflow axis and does not change the failure body.

- `@` handle, const removal, temporary `& out`, expired `int&` return
- unrelated assignment/cast, stale `FModuleOwnedReference`, `SelectAmbiguous`, `MutateDerived` on a root
- `NULL_MEMBER_ACCESS`: `Missing.GetValue()` after `nullptr`, plus shared `RecoverReferenceFailure`

`BuildReferenceFailureSource` is positive-only and emits only the two fault cells. `BuildRejectSource` owns the 18 reject modules. Empty `FunctionName` emits `Entry`.

## Observation

There are no normal-return cells. Fault rows are `RuntimeException` with `Null pointer access` and no integer value. Reject rows are `CompileReject` + `SourceOnly`. `GetExpected` returns 0 for every ID including unknown IDs. That zero fallback is not membership proof.
