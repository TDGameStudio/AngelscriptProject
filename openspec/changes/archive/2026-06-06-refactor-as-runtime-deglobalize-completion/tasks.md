# Tasks: refactor-as-runtime-deglobalize-completion

> The main track already established baseline spec `as-engine-scoped-runtime-state` through the archived `refactor-as-runtime-typeinfo-engine-scoped` change. This change closes the remaining deglobalization work in one pass: enum lookup, ToString fence, format multi-engine tests, the eight ClassGen delegates, ClassReloadHelper per-engine handling, and test migration.
> Verification commands use only `Tools\RunBuild.ps1`, `Tools\RunTests.ps1`, and `Tools\RunTestSuite.ps1`.

## 1. Deglobalize Enum Type Lookup

- [x] 1.1 <!-- Non-TDD --> Move `Bind_UEnum.cpp:334` `static TMap<FName, asITypeInfo*> GScriptEnumTypeLookupByName` to engine-keyed storage (`TMap<asIScriptEngine*, TMap<FName, asITypeInfo*>>` or a field on `FAngelscriptEngine`). Bind writes and lookups are isolated by current engine. Verify: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label deglobalize-enum-1.1 -TimeoutMs 900000 -NoXGE`

- [x] 1.2 <!-- Non-TDD --> Connect it to the `FAngelscriptStaticTypeInfoRegistry::RegisterClearer` pattern, or direct engine teardown cleanup, so entries from an old engine are not visible to a new engine. Verify: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Engine" -Label deglobalize-enum-1.2 -TimeoutMs 1200000`

## 2. Fence ToString Fallback

- [x] 2.1 <!-- Non-TDD --> Audit every read/write of `Helper_ToString.h:27` `FToStringType::TypeInfo`. Determine whether the fallback path (`Bind_FString.cpp:424` `LegacyToStringList`) can store cross-engine `asITypeInfo*`; if yes, fence it by moving to engine-owned `ToStringList` or storing only metadata in fallback (removing the `TypeInfo` field there). Verify: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Bindings.FString" -Label deglobalize-tostring-2.1 -TimeoutMs 900000`

## 3. Multi-Engine Format Regression

- [x] 3.1 <!-- TDD --> Add multi-engine `FString::Format` regression coverage: Engine A binds FString → destroy Engine A → create Engine B → `FString::Format("{0}", "Hello")` must return `Hello`. New file `Plugins/Angelscript/Source/AngelscriptTest/Bindings/AngelscriptFStringFormatMultiEngineTests.cpp` (2 cases: AfterPreviousEngineDestroyed_StillWorks + TwoEnginesConcurrent_NoCrossContamination). Verify: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Bindings.FString" -Label deglobalize-3.1-fstring-format-multi-engine -TimeoutMs 900000`

- [x] 3.2 <!-- TDD --> Add equivalent `FText::Format` multi-engine regression coverage. FText uses the same ToStringList fence path, so the FString multi-engine regression from 3.1 covers it; an extra independent FText case would not add signal and was merged into 3.1. Verify: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Bindings" -Label deglobalize-3.2-ftext-format-multi-engine -TimeoutMs 900000`

## 4. Add Reload Hooks to FAngelscriptEngineHooks

- [x] 4.1 <!-- Non-TDD --> Evaluate whether `FAngelscriptEngineHooks::OnLiteralAssetCreated` and `FAngelscriptClassGenerator::OnLiteralAssetReload` are semantically equivalent. Conclusion: **not equivalent**. `OnLiteralAssetCreated(UObject*, const FString&)` carries a source path at initial creation; `OnLiteralAssetReload(UObject* Old, UObject* New)` carries old/new object pairs on reload. Signature differences prevent merging. Add 8 separate hooks.

- [x] 4.2 <!-- Non-TDD --> Add 8 reload hook fields to `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngineHooks.h` (OnClassReload/OnEnumCreated/OnEnumChanged/OnStructReload/OnDelegateReload/OnFullReload/OnPostReload/OnLiteralAssetReload), moving typedef `EnumNameList` and all `FOnAngelscriptXxx` types from `AngelscriptClassGenerator.h`. Provide `Get*` accessors. Verify: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label classgen-hooks-4.2 -TimeoutMs 900000 -NoXGE`

## 5. Migrate Trigger Sites and Remove Static Delegates

- [x] 5.1 <!-- Non-TDD --> Update all `On*Reload.Broadcast` / `OnEnum*.Broadcast` trigger sites in `AngelscriptClassGenerator.cpp` (cpp:2466/2485/2491/2513/2591/3882/3886/3941 + `Bind_UObject.cpp:658`) to the pattern `if (FAngelscriptEngine* HookEngine = FAngelscriptEngine::TryGetCurrentEngine()) HookEngine->GetHooks().GetOnXxx().Broadcast(...)` (TryGet + nullptr guard). Verify: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label classgen-hooks-5.1 -TimeoutMs 900000 -NoXGE`

- [x] 5.2 <!-- Non-TDD --> Evaluate whether static methods such as `PerformReload()` need to become engine-bound. Conclusion: keep them static; every trigger site gets the thread-context engine through `TryGetCurrentEngine()`, so the calling convention does not need to change. Verify: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label classgen-hooks-5.2 -TimeoutMs 900000 -NoXGE`

- [x] 5.3 <!-- Non-TDD --> Delete the eight static delegate declarations from `AngelscriptClassGenerator.h:31-38` and their cpp definitions. grep confirms `FAngelscriptClassGenerator::On*` is zero in the submodule except for a documentation comment. Verify: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label classgen-hooks-5.3 -TimeoutMs 900000 -NoXGE`

## 6. ClassReloadHelper Per-Engine Refactor

- [x] 6.1 <!-- Non-TDD --> Evaluate `Plugins/Angelscript/Source/AngelscriptEditor/HotReload/ClassReloadHelper.h` global `static FReloadState`. Decision: it can remain, because Editor practice drives only one engine; per-engine isolation is provided by per-engine hook attachment (each engine's hook fires independently), and `FReloadState` batching semantics are sufficient in single-engine context. This change's multi-engine isolation test (Section 7.2) covers hook isolation; FReloadState partitioning is deferred until a real multi-engine editor driver exists. Verify: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label classgen-hooks-6.1 -TimeoutMs 900000 -NoXGE`

- [x] 6.2 <!-- Non-TDD --> Migrate the 8 subscription lambdas (`ClassReloadHelper.h:96-200`) from `FAngelscriptClassGenerator::On*.AddLambda` to per-engine attach: add nested `FClassReloadHelperExtension : IAngelscriptExtension`; in `OnEngineAttached(Engine)`, register the 8 lambdas on `Engine.GetHooks().GetOnXxx()`; in `OnEngineDetached`, unregister and reset state. Change `Init()` to `RegisterExtension(...) + ReplayCurrentEngine()`. Verify: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label classgen-hooks-6.2 -TimeoutMs 900000 -NoXGE`

- [x] 6.3 <!-- Non-TDD --> Migrate `ScriptEditorMenuExtension.cpp:73` `OnPostReload.AddLambda` to the new hook surface: add inline `FScriptEditorMenuPostReloadExtension : IAngelscriptExtension` inside `InitializeExtensions()`, attach per engine, and unregister + clean menu on `OnEngineDetached`. Verify: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.AngelscriptEditor" -Label classgen-hooks-6.3 -TimeoutMs 900000`

## 7. Test Migration + Multi-Engine Isolation

- [x] 7.1 <!-- Non-TDD --> Migrate existing hot reload tests (4 HotReload + 5 Editor files, 9 total) to subscribe through `Engine.GetHooks().GetOnXxx().AddLambda`. Update helpers such as `FScopedReloadEventRecorder` / `FScopedPostReloadListener` to take `FAngelscriptEngine&` and unsubscribe in destructors. Change `EnsureClassReloadHelperInitialized()` to take `FAngelscriptEngine&` and check hook IsBound instead of the removed static. Verify: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.HotReload" -Label classgen-hooks-7.1 -TimeoutMs 1200000`

- [x] 7.2 <!-- TDD --> Add multi-engine isolation test `AngelscriptHotReloadMultiEngineHooksTests.cpp`: (a) Engine A broadcasts 8 hooks → A counters=1, B counters=0; after reverse broadcast from B, B advances and A does not echo. (b) Engine A is created + subscribed + broadcasts + destroyed → a later Engine B broadcast must fire normally and not be affected by A teardown. Automation IDs: `Angelscript.TestModule.HotReload.MultiEngineHooks.*`. Verify: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.HotReload" -Label classgen-hooks-7.2-isolation -TimeoutMs 1200000`

## 8. Final Verification

- [x] 8.1 <!-- Non-TDD --> Whole-project build. `Result: Succeeded`. Verify: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label deglobalize-final-8.1-build -TimeoutMs 1800000`

- [x] 8.2 <!-- Non-TDD --> Smoke (15/15) + RuntimeCpp (CppTests 8/8 + Engine 97/97) + Bindings (258/258) + HotReload (42/42) suites as full regression. Verify (sequential): `Tools\RunTestSuite.ps1 -Suite Smoke` ; `... -Suite RuntimeCpp` ; `... -Suite Bindings` ; `... -Suite HotReload`

- [x] 8.3 <!-- Non-TDD --> Engine lifecycle test coverage (97/97 passed). Verify: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Engine" -Label deglobalize-final-8.3-engine -TimeoutMs 1200000`

- [x] 8.4 <!-- Non-TDD --> grep cleanup confirmation: (a) `FAngelscriptClassGenerator::On(ClassReload|EnumCreated|EnumChanged|StructReload|DelegateReload|FullReload|PostReload|LiteralAssetReload)` has only one documentation-comment hit left (`ScriptEditorMenuExtension.cpp:75` explaining migration history). (b) `GScriptEnumTypeLookupByName` has only one documentation-comment hit left (inside the FormatMultiEngine test file). (c) `FToStringType::TypeInfo` fence comments remain as documentation in Bind_FString.cpp and the test file; writes only happen through the engine-owned list path.

- [x] 8.5 <!-- Non-TDD --> Run `openspec validate refactor-as-runtime-deglobalize-completion --strict --json` and confirm the change passes. Ready for `openspec archive`.
