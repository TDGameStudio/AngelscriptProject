# LANG-REF-RESOLUTION

Author reference for `FRefResolutionGenerator`. This file is not part of the ordinary `.as` projection.

## Axes

Documented order, uppercase catalog tokens, hyphen-separated. Multiword tokens keep internal underscores.

1. Candidate: `MUTABLE_EXACT` | `CONST_PAIR` | `VALUE_VS_IN` | `BASE_VS_DERIVED` | `RETURN_COVARIANCE` | `NULL_PAIR` | `NUMERIC_CONVERSION` | `COMPETING_CONVERSIONS` | `MISSING_CANDIDATE` | `INCOMPATIBLE_CANDIDATE`
2. Site: `DIRECT` | `HELPER`
3. Source: `MUTABLE_LVALUE` | `CONST_LVALUE` | `TEMPORARY` | `FIELD` | `PARAMETER` | `BASE_VIEW` | `DERIVED_VIEW` | `NULL`

Product ID prefix: `LANG-REF-RESOLUTION`. Complete set: 10×2×8 = 160 cells. Normal-return aggregate = 111. Compile reject = 49. Runtime fault = 0.

Example: `LANG-REF-RESOLUTION-MUTABLE_EXACT-DIRECT-MUTABLE_LVALUE` → `int EntryLangRefResolutionMutableExactDirectMutableLvalue()`.

## Source branches

`FResolutionOwner` is emitted once in the aggregate. Helper and parameter sites use unique `InvokeThroughHelper<Entry>` / `InvokeParameter<Entry>` names so cases cannot collide.

Reject partition:

- every `MISSING_CANDIDATE` and `INCOMPATIBLE_CANDIDATE`
- `MUTABLE_EXACT` + `CONST_LVALUE`
- `CONST_PAIR` except `CONST_LVALUE`
- `NULL_PAIR` + `NULL` + `DIRECT`

`BuildReferenceResolutionSource` is positive-only. Empty `FunctionName` emits `Entry`.

## Observation

`GetExpected` is the documented `ExpectedMarker` for non-covariant legal cells (101/202/301/302/401/402/601/701/802). `RETURN_COVARIANCE` returns the script 1/0 witness. Reject and unknown IDs return 0. That fallback is not membership proof.

Legal rows are `ReturnValue` + `RequiresHostSetup`. Marker rows are limited host-candidate observations. Reject rows are `CompileReject` + `SourceOnly`.
