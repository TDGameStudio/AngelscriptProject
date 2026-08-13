## 1. Parser, builder and descriptor contract

- [ ] 1.1 Add failing `AngelscriptPreprocessorDynamicAssetTests.cpp` cases for canonical declarations, namespaces, comments/strings, optional AssetPath, multiple Bundles and exact generated APIs from `attachments/syntax-and-api.md`.
- [ ] 1.2 Add failing diagnostics for UClass old syntax, old property initializer bodies, invalid PrimaryAssetId, empty/None Bundles, invalid paths and every disallowed builder statement.
- [ ] 1.3 Replace `PostProcessLiteralAssets` with token-aware Dynamic Asset parsing/lowering in `Preprocessor/AngelscriptPreprocessor.h/.cpp`; preserve source mapping and never append generated APIs to `PostInitFunctions`.
- [ ] 1.4 Implement normalization for AssetPath, sorted Bundle names, sorted/deduplicated top-level paths and a byte-stable descriptor fingerprint.
- [ ] 1.5 Add `FAngelscriptDynamicAssetDesc` and source owner identity to `FAngelscriptModuleDesc`, including generated API entries, normalized data, source location and descriptor hash.
- [ ] 1.6 Extend `StaticJIT/PrecompiledData.h/.cpp` and offline bundle schema/writer/reader for Dynamic Asset descriptor round trips, updating versions and deterministic fixtures where required.

## 2. Registry and backend ownership

- [ ] 2.1 Define `IAngelscriptDynamicAssetBackend` and add an in-memory fake with call log/failure injection before implementing the real UAssetManager backend.
- [ ] 2.2 Add failing backend tests for unused definitions, first materialization, retry, identical sharing, conflicting fingerprints, disk-scanned Type, external unowned ID and last-owner deletion.
- [ ] 2.3 Add new `Core/AngelscriptDynamicAssetRegistry.h/.cpp` for Engine-local descriptors, owner tokens, Unmaterialized/Materializing/Materialized state and last errors.
- [ ] 2.4 Add the Registry/backend dependency to `FAngelscriptEngineDependencies` and one Registry per `FAngelscriptEngine`; release module owners and all remaining owners in deterministic shutdown order.
- [ ] 2.5 Implement the production shared coordinator around the injected `UAssetManager`, including normalized fingerprint checks, owner sets and detection of disk-scanned/external records.
- [ ] 2.6 Implement and version-test the last-owner deletion contract: `UnloadPrimaryAsset` followed by same ID with empty Bundle data, verifying the record is actually gone on every supported UE version.

## 3. Generated GetId, LoadAsync and Unload API

- [ ] 3.1 Add failing compile/bind tests for `Name::GetId`, both `Name::LoadAsync` overloads, exact default arguments and namespace collisions.
- [ ] 3.2 Refactor `Bind_UAssetManager.h/.cpp` and `Bind_UAssetManager_Functions.cpp` only as needed to expose one reusable internal async adapter without duplicating callback behavior.
- [ ] 3.3 Implement GetId as EnsureMaterialized+return ID, with no Bundle loading and retryable backend errors.
- [ ] 3.4 Implement default LoadAsync using all normalized declared Bundle names and subset LoadAsync forwarding the caller's array, priority and callback arguments.
- [ ] 3.5 Implement Unload so an unmaterialized definition returns 0/no side effect and a materialized definition delegates ID-level unload without releasing descriptor ownership.
- [ ] 3.6 Add tests with the in-memory backend and real AssetManager adapter proving call order is AddDynamicAsset-before-Load, GetId is register-only, Unload retains registration, and callback names are forwarded unchanged.
- [ ] 3.7 Add packaged/runtime negative tests proving no generated path performs synchronous load and missing cooked resources follow existing AssetManager failure behavior.

## 4. Reload and PIE transactions

- [ ] 4.1 Add descriptor comparison tests for textual reorder equivalence, same-ID data change, Type/Name change, shared-owner conflict and unrelated function body changes.
- [ ] 4.2 Implement non-PIE unmaterialized descriptor replacement with zero backend calls and unchanged materialized descriptors with zero update calls.
- [ ] 4.3 Implement exclusive same-ID backend update with prevalidation, commit and rollback; add failure injection tests that keep last-good module/record/fingerprint.
- [ ] 4.4 Implement ID change as old-owner release plus new Unmaterialized definition, including correct behavior when another owner keeps the old record alive.
- [ ] 4.5 Reject same-ID description changes while any other owner retains the old fingerprint; report both owner/module identities without mutating the shared record.
- [ ] 4.6 Add PIE pre-swap classification for any semantic Asset descriptor/API change, queue latest source and leave module/record/load state untouched.
- [ ] 4.7 Add PIE tests for Bundle, AssetPath and ID changes, normalized-equivalent reorder, unrelated soft reload and one latest-source transaction after PIE.

## 5. Literal UObject pipeline removal and migration

- [ ] 5.1 Inventory every `LiteralAsset`, `AssetsPackage`, `__CreateLiteralAsset`, `__PostLiteralAssetSetup`, PostInit and literal reload/save hook reference listed in `design.md`; assign each to migrate, replace or delete before editing.
- [ ] 5.2 Remove literal creation functions from `Binds/Bind_UObject.cpp` and `Bind_UObject_Functions.cpp`, and remove AssetsPackage/RootSet/delegates from `Core/AngelscriptEngine.h/.cpp` after new tests are green.
- [ ] 5.3 Remove literal replacement hookup from `AngelscriptEditor/HotReload/ClassReloadHelper.h` and literal save-back code from `AngelscriptEditor/Core/AngelscriptEditorModule.h/.cpp`.
- [ ] 5.4 Replace `AngelscriptPreprocessorLiteralTests.cpp`, `AngelscriptLiteralAssetPostInitTests.cpp`, `AngelscriptHotReloadLiteralAssetTests.cpp`, Editor literal tests and affected Engine hook tests with Dynamic Asset or Singleton-owned coverage; do not silently delete unique curve serialization behavior without recording its destination/non-goal.
- [ ] 5.5 Migrate Script examples: Dynamic Asset use gets `Name::LoadAsync`; UObject configuration gets sibling `singleton ... { Init { ... } }` and `Name::Get()`.

## 6. Dump, offline and documentation

- [ ] 6.1 Add read-only Dynamic Asset definition/materialized-owner rows and diff keys to `Dump/AngelscriptStateDump.h/.cpp`, proving Dump cannot EnsureMaterialized or load.
- [ ] 6.2 Export/import normalized descriptors in ue-validation bundles and add explicit non-executable traps for GetId/LoadAsync/Unload in Standalone.
- [ ] 6.3 Add `Script/Examples/Core/DynamicAssets.as` showing direct all-Bundle LoadAsync, subset loading, GetId interoperability and Unload.
- [ ] 6.4 Update Chinese-first plugin docs/API stubs with register-vs-load-vs-unload state, cook requirements, shared ID conflicts and exact Singleton migration.

## 7. Verification checkpoints

- [ ] 7.1 Run `Tools\RunBuild.ps1` after descriptor archive, Runtime backend and Editor hook removal compile together.
- [ ] 7.2 Run `Tools\RunTests.ps1 -TestFilter "Angelscript.TestModule.Preprocessor.Asset.Dynamic"` and `Tools\RunTests.ps1 -TestFilter "Angelscript.TestModule.Asset.Dynamic"`.
- [ ] 7.3 Run `Tools\RunTests.ps1 -TestFilter "Angelscript.TestModule.HotReload.DynamicAsset"` including PIE/shared-owner transaction cases.
- [ ] 7.4 Run `Tools\RunTests.ps1 -TestFilter "Angelscript.TestModule.Dump.DynamicAsset"` and `Tools\RunTestSuite.ps1 -Suite Standalone`.
- [ ] 7.5 Run affected Editor class-reload/module tests and an `rg` audit proving no executable literal UObject pipeline remains outside intentional migration diagnostics/history.
- [ ] 7.6 Run `Tools\RunTestSuite.ps1 -Suite All`, record actual discovered/pass/skip/fail counts and compare against live guides.
- [ ] 7.7 Run `openspec validate refactor-as-runtime-asset-model --strict`, inspect `git diff --check`, and map every requirement/scenario to `attachments/test-plan.md` before marking implementation tasks complete.
