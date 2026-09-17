# LANG-EXPR-RESOLUTION

Author reference for `FExprResolutionGenerator`. This file is not part of the ordinary `.as` projection.

## Axes

Documented order, uppercase catalog tokens, hyphen-separated. Multiword tokens keep internal underscores.

1. Context: `INITIALIZER` | `ASSIGNMENT` | `ARGUMENT` | `RETURN` | `CONDITION` | `INDEX` | `MEMBER_RECEIVER`
2. Shape: `IDENTIFIER` | `CALL` | `MEMBER` | `SCOPED_NAME`
3. State: `EXACT` | `NAMESPACE_QUALIFIED` | `OVERLOAD` | `CONVERSION` | `MISSING` | `AMBIGUOUS` | `INACCESSIBLE` | `WRONG_TYPE`

Product ID prefix: `LANG-EXPR-RESOLUTION`. Complete set: 7×4×8 = 224 cells. Normal-return aggregate = 112 (`IsSuccessfulState`). Compile reject = 112 (`missing`, `ambiguous`, `inaccessible`, `wrong_type`). Runtime fault = 0.

Example: `LANG-EXPR-RESOLUTION-INITIALIZER-IDENTIFIER-EXACT` → `int EntryLangExprResolutionInitializerIdentifierExact()`.

## Source branches

Shared helpers, emitted once per aggregate or isolated reject module: script `RecordResolution`, `FNativeCaseValue`, owner/namespace resolution fixtures, `ObserveResolution`, and `FResolutionIndexProbe`.

Successful states emit `Base + ShapeOrdinal` markers: exact=100, namespace_qualified=200, overload=300, conversion=400; identifier=1, call=2, member=3, scoped_name=4. Reject states emit the documented missing/ambiguous/hidden/wrong tokens.

Return context uses a case-qualified `ProduceResolution_<Entry>()`. Setup locals (`ExactIdentifier`, `ResolutionOwner`, `QualifiedOwner`, …) stay inside the producing function so entries cannot inherit prior mutable state.

`BuildExpressionResolutionSource` is positive-only. Empty `FunctionName` emits `Entry`. Invalid identifiers such as `bad-name` emit no source.

## Observation

`GetExpected` is `Base + ShapeOrdinal` for the 112 successful IDs and 0 for reject and unknown IDs. That zero fallback is not membership proof. There is no real expected-zero normal cell.

Normal rows are `ReturnValue` + `Standalone`. Reject rows are `CompileReject` with no declaration and `SourceOnly` execution. Host `RecordResolution` / access-mask fixtures are replaced by script stand-ins; native hidden-symbol enforcement is out of scope.
