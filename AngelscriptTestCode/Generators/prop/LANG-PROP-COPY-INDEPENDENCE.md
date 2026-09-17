# LANG-PROP-COPY-INDEPENDENCE

Author reference for `FPropCopyIndependenceGenerator`. This file is not part of the ordinary `.as` projection.

## Axes

Documented order, uppercase catalog tokens, hyphen-separated. Multiword tokens keep internal underscores.

1. Mutation: `SOURCE_AFTER_TRANSFER` | `TARGET_AFTER_TRANSFER` | `NESTED_MEMBER`
2. Transfer: `COPY_CONSTRUCT` | `ASSIGN` | `SELF_ASSIGN`
3. Type: `INT8` | `INT16` | `INT` | `INT64` | `UINT8` | `UINT16` | `UINT` | `UINT64` | `FLOAT32` | `FLOAT64` | `BOOL` | `ENUM` | `TYPEDEF` | `SCRIPT_VALUE` | `NATIVE_VALUE` | `SCRIPT_REFERENCE` | `NATIVE_REFERENCE`
4. View: `EXACT` | `BASE` | `DERIVED`

Product ID prefix: `LANG-PROP-COPY-INDEPENDENCE`. Complete set: 3×3×17×3 = 459 cells. All 459 are normal-return. Compile reject = 0. Runtime fault = 0.

Example: `LANG-PROP-COPY-INDEPENDENCE-SOURCE_AFTER_TRANSFER-COPY_CONSTRUCT-INT8-EXACT` → `int EntryLangPropCopyIndependenceSourceAfterTransferCopyConstructInt8Exact()`.

## Source branches

Shared helpers, emitted once per aggregate: `enum ENativeCaseEnum` and `struct FScriptCaseValue`. Each case owns `FPropertyCopyPayload_<Entry>`, `FPropertyCopyBase_<Entry>`, and `FPropertyCopyDerived_<Entry>`.

Transfers emit `TransferTarget = Receiver.Source` (or nested payload), `Receiver.Target = Receiver.Source`, or self-assign of source/target/nested target. Mutations then write the mutated source, target, or `NestedSource.Stored`. Bool/enum init as `1`/`0` and mutate as `1-Before`; other types init `11`/`22` and mutate to `37`.

`BuildPropertyCopySource` accepts every documented cell. Empty `FunctionName` emits `Entry`. Invalid identifiers such as `bad-name` emit no source.

## Observation

`GetExpected = ExpectedSource * 1000 + ExpectedTarget`.

- Self-assign: source-after mutates source and keeps the original target; otherwise source stays and target mutates.
- Reference types share identity: both sides observe the mutated source value.
- Otherwise source-after mutates source and target keeps the pre-transfer source; other mutations keep source and apply the mutated source value to the target side.

`LANG-PROP-COPY-INDEPENDENCE-SOURCE_AFTER_TRANSFER-SELF_ASSIGN-BOOL-EXACT` is a real expected-zero (`0`). Unknown IDs also return 0 from `GetExpected`; that fallback is not membership proof.

Reference rows are `ReturnValue` + `SourceOnly` with limited observation. Other rows are `RequiresHostSetup`. Wide/float/native-value rows keep limited observation. Host notes name `RecordPropertyCopyObservation`.
