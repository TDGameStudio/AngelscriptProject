# Dynamic Asset implementation test plan

## 1. Test organization

| File | Prefix | Purpose |
| --- | --- | --- |
| `Preprocessor/AngelscriptPreprocessorDynamicAssetTests.cpp` | `Angelscript.TestModule.Preprocessor.Asset.Dynamic` | syntax, pure builder, lowering, normalization, migration |
| new `Asset/AngelscriptDynamicAssetRegistryTests.cpp` | `Angelscript.TestModule.Asset.Dynamic.Registry` | local definitions, fake backend, owner/refcount/conflicts |
| new `Asset/AngelscriptDynamicAssetApiTests.cpp` | `Angelscript.TestModule.Asset.Dynamic.API` | GetId/LoadAsync/Unload call order and callbacks |
| new `Asset/AngelscriptDynamicAssetBackendIntegrationTests.cpp` | `Angelscript.TestModule.Asset.Dynamic.Backend` | real UAssetManager Add/update/delete/version behavior |
| `HotReload/AngelscriptHotReloadDynamicAssetTests.cpp` | `Angelscript.TestModule.HotReload.DynamicAsset` | non-PIE transactions and PIE deferral |
| `Dump/AngelscriptDynamicAssetStateDumpTests.cpp` | `Angelscript.TestModule.Dump.DynamicAsset` | read-only rows, owners, failures and diffs |

The fake backend exposes an ordered call log, current records, owner sets and one-shot failure injection for Validate/Acquire/Update/Rollback/Release/Load/Unload. Most Runtime tests use it; only the backend integration file touches the real AssetManager.

## 2. Parser and normalization matrix

| ID | Fixture/action | Required assertion |
| --- | --- | --- |
| A-P01 | canonical ID + one Bundle | exact ID/descriptor/API signatures; no PostInit entry |
| A-P02 | optional AssetPath + multiple Bundles | canonical path and sorted Bundle-name list |
| A-P03 | reordered/duplicated Add calls | byte-identical normalized descriptor/fingerprint |
| A-P04 | namespace declarations | generated namespace differs while PrimaryAssetId does not |
| A-P05 | comments/strings containing `asset` | no false declaration |
| A-P06 | arbitrary call/UObject/loop/branch | `AS-ASSET-003`, candidate not active |
| A-P07 | empty/None Bundle | `AS-ASSET-005`, no descriptor activation |
| A-P08 | invalid AssetPath/top-level path | exact field/path diagnostic |
| A-P09 | old UClass literal | full `USINGLETON` + `singleton` + `Init` migration diagnostic |
| A-P10 | descriptor archive/offline twice | exact round trip and byte determinism |

## 3. Lazy registry and ownership matrix

| ID | Fixture/action | Fake backend assertions |
| --- | --- | --- |
| A-R01 | compile/activate/dump unused declaration | zero Validate/Acquire/Load calls |
| A-R02 | first/repeated GetId | one Acquire, stable ID, zero Load |
| A-R03 | LoadAsync is first call | Acquire occurs before Load in call log |
| A-R04 | Acquire fails once | no owner committed; error recorded; second call retries/succeeds |
| A-R05 | two Engines same ID/fingerprint | one record, two owners, no second Add |
| A-R06 | two owners conflicting fingerprint | second rejected; first record/owner unchanged |
| A-R07 | disk-scanned Type | rejected before Add |
| A-R08 | external unowned record | rejected, never overwritten/adopted |
| A-R09 | one of two Engines shuts down | one owner remains, record remains |
| A-R10 | last owner shuts down | Unload before Remove; record gone |
| A-R11 | unused module unload | zero backend calls |
| A-R12 | deletion failure | tombstone/error retained; ID not reported free |

## 4. Generated API matrix

| ID | Call | Required assertion |
| --- | --- | --- |
| A-A01 | `GetId()` | materialize only; zero loaded UObject/Load calls |
| A-A02 | no-arg `LoadAsync()` | all normalized Bundle names, priority 0, null/None callbacks |
| A-A03 | callback `LoadAsync(...)` | exact priority/object/finished/canceled forwarding |
| A-A04 | subset overload | exact caller Bundle array forwarded after materialization |
| A-A05 | `Unload()` before materialize | returns 0, zero backend calls |
| A-A06 | `Unload()` after load | ID-level unload count returned; owner/record unchanged |
| A-A07 | load again after unload | no re-Acquire; one new Load request |
| A-A08 | missing cooked resource integration | async failure/cancel; no sync load/file fallback |

Use a callback UObject with counter UFUNCTIONs to prove finished and canceled names reach the existing adapter. Do not make timing assertions that depend on one-frame completion; wait through existing latent test helpers.

## 5. Real UAssetManager contract matrix

Run in an isolated ID/Type namespace and clean up even on assertion failure:

- non-empty Bundle AddDynamicAsset creates queryable dynamic record;
- same descriptor update succeeds without loading paths;
- empty Bundle for existing record removes cached bundle/asset record on each supported engine version;
- disk-scanned Type rejects dynamic conversion;
- conflicting external record is detected before AS coordinator overwrite;
- GetId registration alone leaves referenced UObject unloaded;
- UnloadPrimaryAsset returns the engine's actual affected-handle count.

If the deletion behavior changes in a supported engine, fail loudly and implement a version-specific supported deletion adapter before updating the test—never weaken the last-owner invariant.

## 6. Reload matrix

| ID | V1 -> V2 | State | Required assertion |
| --- | --- | --- | --- |
| A-H01 | reorder/duplicate only | materialized | same fingerprint; zero backend update |
| A-H02 | Bundle change | unmaterialized | local descriptor only; later first Load uses V2 |
| A-H03 | Bundle/AssetPath change | sole materialized owner | one transactional update; no implicit Load/Unload |
| A-H04 | update fails | sole owner | old module/record/fingerprint preserved |
| A-H05 | rollback fails after update failure | sole owner | poisoned/tombstone diagnostic, overwrite blocked |
| A-H06 | one shared owner changes fingerprint | shared | candidate rejected; both old owners remain |
| A-H07 | Type or Name change | materialized | old owner release; new ID unmaterialized |
| A-H08 | Type/Name change with another old owner | shared | old record remains for other owner; new still unmaterialized |

## 7. PIE matrix

During single-player PIE, independently edit Type, Name, AssetPath, Bundle name, Bundle path and builder operation. For every semantic edit assert:

1. reload is queued/rejected before swap;
2. old generated API result and descriptor remain active;
3. backend call log, owner count, record and load state do not change;
4. repeated edits coalesce and latest source applies once after PIE.

Add two controls:

- equivalent reorder that normalizes to the same descriptor causes no Asset backend mutation;
- unrelated ordinary function body still follows existing soft reload.

## 8. Legacy removal audit

Before deletion, map each current test to a destination:

| Existing area | Destination |
| --- | --- |
| Preprocessor literal recognition | new Dynamic Asset parser + Singleton migration diagnostics |
| literal PostInit creation | negative “no PostInit/no eager registration” tests |
| literal hot reload UObject replacement | Singleton sibling reload tests or Dynamic Asset descriptor transaction tests |
| Engine literal delegates/multi-engine hooks | Dynamic backend owner/isolation tests |
| Editor literal curve save-back | explicit removed/non-goal record or future Editor asset-authoring proposal |
| Coverage literal tests | Dynamic Asset syntax/API coverage plus Singleton migration coverage |

Final `rg` audit targets: `PostProcessLiteralAssets`, `__CreateLiteralAsset`, `__PostLiteralAssetSetup`, `AssetsPackage`, `OnLiteralAssetCreated`, `PostLiteralAssetSetup`, `OnLiteralAssetReload`. Remaining matches must be intentional migration diagnostics/history only.

## 9. Dump and Standalone matrix

- Dump unused definition: descriptor row, Materialized=false, fake backend call log empty.
- Dump materialized shared ID: per-Engine owners and backend refcount are consistent.
- Dump conflict/failure: both owner identities, fingerprint and LastError visible; no retry.
- Snapshot diff unmaterialized -> materialized -> last-owner removal without loading resources.
- Export same module twice: byte-identical normalized descriptor JSON.
- UE-validation compiles all generated overloads; runtime invocation traps explicitly.

## 10. Verification commands

```powershell
Tools\RunBuild.ps1
Tools\RunTests.ps1 -TestFilter "Angelscript.TestModule.Preprocessor.Asset.Dynamic"
Tools\RunTests.ps1 -TestFilter "Angelscript.TestModule.Asset.Dynamic"
Tools\RunTests.ps1 -TestFilter "Angelscript.TestModule.HotReload.DynamicAsset"
Tools\RunTests.ps1 -TestFilter "Angelscript.TestModule.Dump.DynamicAsset"
Tools\RunTestSuite.ps1 -Suite Standalone
Tools\RunTestSuite.ps1 -Suite All
openspec validate refactor-as-runtime-asset-model --strict
```

Record actual discovery/pass/fail/skip/timeout counts in the implementation evidence. This planning document does not pre-claim future results.
