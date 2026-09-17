# LANG-PROP-REBUILD

Author reference for `FPropRebuildGenerator`. This file is not part of the ordinary `.as` projection.

## Axes

Documented order, uppercase catalog tokens, hyphen-separated. Multiword tokens keep internal underscores.

1. Observation: `METADATA` | `RUNTIME` | `OLD_HANDLE_CLEANUP`
2. Path: `REBUILD` | `SAVE_LOAD`
3. Scenario: `STORED_SAME_SOURCE` | `STORED_VALUE` | `STORED_FIELD_TYPE` | `STORED_FIELD_ORDER` | `STORED_INHERITANCE` | `REGISTERED_SAME_SOURCE` | `REGISTERED_READ_VALUE` | `REGISTERED_GETTER_PRESENCE` | `REGISTERED_SETTER_PRESENCE` | `REGISTERED_CONSTNESS` | `REGISTERED_INDEXED_SAME_SOURCE` | `REGISTERED_INDEXED_VALUE` | `REGISTERED_INDEXED_CONSTNESS` | `REGISTERED_INDEXED_INDEX_TYPE` | `REGISTERED_INDEXED_OVERLOAD_SET`

Product ID prefix: `LANG-PROP-REBUILD`. Complete set: 3×2×15 = 90 cells. All 90 are normal-return. Compile reject = 0. Runtime fault = 0.

Example: `LANG-PROP-REBUILD-METADATA-REBUILD-STORED_SAME_SOURCE` → `int EntryLangPropRebuildMetadataRebuildStoredSameSource()`.

## Source branches

Each entry comments `// Observation` and `// Path`. Stored scenarios emit case-qualified `FStoredRebuildBase_<Entry>` / `FStoredRebuildDerived_<Entry>` with second-version field type, order, or inheritance. Registered scenarios construct `CreateFRebuildRegisteredA|B` or `CreateFRebuildIndexedA|B` and either write `Receiver.Value = 73`, read `Receiver.Value`, or read `Receiver.Value[Index]`.

`BuildScenarioSource` accepts every documented cell. Empty `FunctionName` emits `Entry`. Invalid identifiers such as `bad-name` emit no source.

## Observation

`GetExpected = ExpectedRuntimeValue(Scenario, /*bSecondVersion=*/true)`:

- `REGISTERED_SETTER_PRESENCE`: `73`
- changed stored/read/indexed-value scenarios: `29`, plus `1` when indexed
- otherwise: `11`, plus `1` when indexed

Unknown IDs return 0 from `GetExpected`; that fallback is not membership proof. There is no real expected-zero normal cell.

`RUNTIME` rows are `ReturnValue` + `Standalone`. `METADATA` and `OLD_HANDLE_CLEANUP` rows are `ReturnValue` + `SourceOnly`. Every row is limited observation. Notes state that the dump is second-version source only and does not execute rebuild, save/load, or old-handle cleanup.
