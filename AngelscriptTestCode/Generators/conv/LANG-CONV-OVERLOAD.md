# LANG-CONV-OVERLOAD

Author reference for `FConvOverloadGenerator`. This file is not part of the ordinary `.as` projection.

## Axes

Documented order, uppercase catalog tokens, hyphen-separated. Multiword tokens keep internal underscores.

1. Context: `OVERLOAD` | `OPERATOR` | `DEFAULT_ARGUMENT` | `PROPERTY` | `INDEX` | `CONDITIONAL`
2. Conversion: `IDENTITY` | `PROMOTION` | `NARROWING` | `CONSTRUCTOR` | `OPERATOR` | `REFERENCE_CAST`
3. Outcome: `EXACT` | `SELECTED_CONVERSION` | `AMBIGUOUS` | `REJECTED`

Product ID prefix: `LANG-CONV-OVERLOAD`. Complete set: 6×6×4 = 144 cells. Normal-return aggregate = 72 (`exact` and `selected_conversion`). Compile reject = 72 (`ambiguous` and `rejected`). Runtime fault = 0.

Example: `LANG-CONV-OVERLOAD-OVERLOAD-IDENTITY-EXACT` → `int EntryLangConvOverloadOverloadIdentityExact()`.

## Source branches

Case-dependent types and context surfaces use a deterministic suffix from the CaseId after `EntryLangConvOverload`, so aggregate definitions do not collide.

Source values: `identity`/`constructor` `int` 11/14; `promotion` `int8` 12; `narrowing` `int64` 13; `operator` `FResolutionOperatorSource{Suffix}(15)`; `reference_cast` null derived handle.

Normal contexts:

- overload: `SelectResolution{Suffix}(SourceValue)` (+100)
- operator: `Context + SourceValue` (+7)
- default_argument: `DefaultResolution{Suffix}(SourceValue)` (+5)
- property: `Holder.Value = SourceValue` then `Holder.Result`
- index: `Index[SourceValue]` (+1)
- conditional: `true ? SourceValue : fallback` then `ObserveResolution{Suffix}`

`ambiguous` / `rejected` emit equally ranked or unrelated surfaces so compilation fails. `BuildResolutionSource` is positive-only. Empty `FunctionName` emits `Entry`. Invalid identifiers such as `bad-name` emit no source.

## Observation

`ExpectedSelectedMarker`: exact uses source markers 11/12/13/14/15/-1; selected constructor = 114; selected operator = 215; otherwise the source marker.

`GetExpected = marker + context offset` (`overload +100`, `operator +7`, `default_argument +5`, `index +1`, property/conditional +0).

Normal rows are `ReturnValue` + `Standalone`. Reject rows are `CompileReject` with no declaration. `GetExpected` is 0 for reject and unknown IDs; that fallback is not membership proof.
