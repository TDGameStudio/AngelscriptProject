# LANG-PROP-INIT-ORDER

Author reference for `FPropInitOrderGenerator`. This file is not part of the ordinary `.as` projection.

## Axes

Documented order, uppercase catalog tokens, hyphen-separated. Multiword tokens keep internal underscores.

1. Observation: `BASE_ENTRY` | `BASE_EXIT` | `DERIVED_ENTRY` | `DERIVED_EXIT`
2. Position: `BASE_FIRST` | `BASE_MIDDLE` | `BASE_LAST` | `DERIVED_FIRST` | `DERIVED_LAST`
3. Source: `DEFAULT_VALUE` | `DECLARATION_INITIALIZER` | `OWNER_LITERAL_ASSIGNMENT` | `OWNER_SOURCE_ASSIGNMENT` | `DERIVED_REASSIGNMENT`
4. Type: `INT8` | `INT16` | `INT` | `INT64` | `UINT8` | `UINT16` | `UINT` | `UINT64` | `FLOAT32` | `FLOAT64` | `BOOL` | `ENUM` | `TYPEDEF` | `SCRIPT_VALUE` | `NATIVE_VALUE`

Product ID prefix: `LANG-PROP-INIT-ORDER`. Complete set: 4×5×5×15 = 1500 cells. All 1500 are normal-return. Compile reject = 0. Runtime fault = 0.

Example: `LANG-PROP-INIT-ORDER-BASE_ENTRY-BASE_FIRST-DEFAULT_VALUE-INT8` → `int EntryLangPropInitOrderBaseEntryBaseFirstDefaultValueInt8()`.

## Source branches

Shared helpers, emitted once per aggregate: `enum ENativeCaseEnum`, `struct FScriptCaseValue`, `RecordPropertyInitializationMarker`, and `RecordPropertyInitializationCheckpoint`.

Each case owns `InitializePropertyValue_<Entry>` when the source uses a declaration initializer, plus `FPropertyInitializationBase_<Entry>` and `FPropertyInitializationDerived_<Entry>`. The observed field sits at base first/middle/last or derived first/last among five sibling marker fields. Base constructor checkpoints use `true` when the target lives on the base, otherwise `false` with `-777`. Derived constructor always checkpoints stages 2 and 3 as available.

`BuildPropertyInitializationSource` accepts every documented cell. Empty `FunctionName` emits `Entry`. Invalid identifiers such as `bad-name` emit no source.

## Observation

`GetExpected = ExpectedFinalValue(Source)`: `0` for `DEFAULT_VALUE` and `DERIVED_REASSIGNMENT`, otherwise `1`. Observation stage is recorded in source as `const int ObservationStage = 0|1|2|3` and does not change the integer oracle.

`LANG-PROP-INIT-ORDER-BASE_ENTRY-BASE_FIRST-DEFAULT_VALUE-INT8` is a real expected-zero. Unknown IDs also return 0 from `GetExpected`; that fallback is not membership proof.

All rows are `ReturnValue` + `RequiresHostSetup`. Wide/float/typedef/native-value rows keep limited observation. Host notes name `RecordPropertyInitializationMarker` and `RecordPropertyInitializationCheckpoint`.
