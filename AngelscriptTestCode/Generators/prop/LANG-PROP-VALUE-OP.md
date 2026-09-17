# LANG-PROP-VALUE-OP

Author reference for `FPropValueOpGenerator`. This file is not part of the ordinary `.as` projection.

## Axes

Documented order, uppercase catalog tokens, hyphen-separated. Multiword tokens keep internal underscores.

1. Operation: `DEFAULT_READ` | `WRITE` | `COMPOUND_WRITE` | `COPY` | `REFERENCE_MUTATION`
2. Receiver: `MUTABLE` | `CONST` | `BASE_VIEW` | `DERIVED_VIEW`
3. Type: `INT8` | `INT16` | `INT` | `INT64` | `UINT8` | `UINT16` | `UINT` | `UINT64` | `FLOAT32` | `FLOAT64` | `BOOL` | `ENUM` | `TYPEDEF` | `SCRIPT_VALUE` | `NATIVE_VALUE`

Product ID prefix: `LANG-PROP-VALUE-OP`. Complete set: 5×4×15 = 300 cells. Normal-return aggregate = 243. Compile reject = 57. Runtime fault = 0.

Reject cells:

- every `CONST` receiver except `DEFAULT_READ` and `COPY` (45)
- every `COMPOUND_WRITE` on `BOOL`, `ENUM`, `SCRIPT_VALUE`, or `NATIVE_VALUE` that is not already rejected as const (12)

Example: `LANG-PROP-VALUE-OP-DEFAULT_READ-MUTABLE-INT8` → `int EntryLangPropValueOpDefaultReadMutableInt8()`.

## Source branches

Shared helpers, emitted once per aggregate or isolated reject module: `enum ENativeCaseEnum` and `struct FScriptCaseValue`. Each case owns `ObserveStoredProperty_<Entry>`, `FStoredPropertyBase_<Entry>`, `FStoredPropertyDerived_<Entry>`, and `MutateStoredProperty_<Entry>` for reference mutation.

Receivers construct a mutable base, a const base, a derived object viewed as base, or a derived object. Operations write `Stored`, compound-add `Stored`, copy then mutate the copy, or call the mutate helper. The entry returns `CoreResult * 100 + Receiver.ReceiverMarker`.

`BuildStoredPropertySource` is positive-only and returns empty for reject cells. `BuildRejectSource` and `ListRejectCaseIds` own the 57 reject modules. Empty `FunctionName` emits `Entry`. Invalid identifiers such as `bad-name` emit no source.

## Observation

`GetExpected = ExpectedCoreResult * 100 + Receiver.Marker`.

- default_read core: `0`
- copy core: `1` for bool/enum, otherwise `37`
- write / compound / reference-mutation core: `1` for bool/enum, otherwise `29`
- marker: `22` for base/derived view, otherwise `11`

`GetExpected` uses this formula for the 243 normal IDs and returns 0 for reject and unknown IDs. That zero fallback is not membership proof. There is no real expected-zero packed cell.

Typedef and native-value rows are `RequiresHostSetup` with limited observation. Wide/float rows are `Standalone` with limited observation. Other normal rows are `Standalone`.
