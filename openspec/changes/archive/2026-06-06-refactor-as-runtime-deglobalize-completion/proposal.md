# refactor-as-runtime-deglobalize-completion

## Why

`refactor-as-runtime-typeinfo-engine-scoped` already archived the TypeInfo + legacy fallback + ContextPool deglobalization work into baseline spec `as-engine-scoped-runtime-state`. This change closes the remaining process-wide state in the deglobalization track in one pass:

**Runtime layer (`as-engine-scoped-runtime-state` delta):**

- `Bind_UEnum.cpp:334` still had process-wide `static TMap<FName, asITypeInfo*> GScriptEnumTypeLookupByName`. In multi-engine scenarios, enum TypeInfo bound by a previous engine could remain in the table, and a later engine looking up the same enum name could receive an `asITypeInfo*` from the wrong engine.
- `Bind_FString.cpp:424` had `static TArray<FToStringType> LegacyToStringList`. The main path had already migrated, but the `FToStringType::TypeInfo` field (`Helper_ToString.h:27`) could still expose cross-engine `asITypeInfo*` through fallback paths and needed a fence.
- Existing `FString::Format` / `FText::Format` tests only covered single-engine behavior. They lacked the regression chain "previous engine populates state → destroy → new engine formats again."

**Editor / Runtime layer (`as-engine-owned-hooks` delta):**

- `AngelscriptClassGenerator.h:31-38` exposed eight process-wide static delegates (`OnClassReload` / `OnEnumCreated` / `OnEnumChanged` / `OnStructReload` / `OnDelegateReload` / `OnFullReload` / `OnPostReload` / `OnLiteralAssetReload`). Their semantics match the compile-lifecycle hooks already handled by archived baseline `as-engine-owned-hooks`: multicast hooks fired along engine lifecycle boundaries. Because they were process-wide, multi-engine execution could produce:
  - Editor `ClassReloadHelper.h` maintaining a **global `static FReloadState`** shared by all eight delegates, so Engine A could process classes added by Engine B.
  - `OnPostReload` triggering global menu extension reset / `FBlueprintActionDatabase` / `FComponentTypeRegistry::InvalidateClass`, letting two engines overwrite each other.

Moving the hooks onto `FAngelscriptClassGenerator` members is not a deglobalization solution. `ClassGenerator` is a worker object that performs class generation, not the owner of engine instance lifecycle. The correct home is `FAngelscriptEngine::Hooks` (`FAngelscriptEngineHooks`), matching the already-baselined compile-lifecycle hooks.

Finally, run a complete build + suite verification as the final validation point for the whole deglobalization track.

## What Changes

### Runtime deglobalization

- Convert `GScriptEnumTypeLookupByName` to engine-keyed storage and connect it to the `ClearForEngine` path registered through `FAngelscriptStaticTypeInfoRegistry`.
- Fence the `FToStringType::TypeInfo` fallback path: prefer engine-owned `ToStringList`; if fallback remains, allow metadata only.
- Add multi-engine `FString::Format` / `FText::Format` regression tests.

### Move ClassGen delegates to FAngelscriptEngineHooks

- Add reload hook fields to `FAngelscriptEngineHooks` (7 or 8, depending on whether `OnLiteralAssetReload` can merge with existing `OnLiteralAssetCreated`).
- Delete the eight static delegates from `FAngelscriptClassGenerator`. Change every trigger point to call `FAngelscriptEngine::Get().GetHooks().GetOnXxx().Broadcast(...)`.
- Evaluate and adjust calling conventions for static methods such as `PerformReload()` so they can carry engine context.

### ClassReloadHelper per-engine refactor

- Change Editor `ClassReloadHelper.h` global `static FReloadState` to per-engine storage.
- Migrate every Editor subscriber (~10 AddLambda / AddRaw sites) from `FAngelscriptClassGenerator::OnXxx.AddLambda(...)` to `FAngelscriptEngine::Get().GetHooks().GetOnXxx().AddLambda(...)`, attached per engine through the `as-engine-extension-registry` attach/replay mechanism.

### Test migration + isolation coverage

- Migrate existing hot reload tests to subscribe through the new hook surface.
- Add a multi-engine isolation test: when Engine A reloads, Engine B's subscribed lambda is not fired.

### Final verification

- Whole-project build + Smoke / RuntimeCpp / Bindings / HotReload / Engine suites all pass.

## Capabilities

### New Capabilities

- None.

### Modified Capabilities

- **as-engine-scoped-runtime-state**: add three requirement deltas: enum lookup is engine-keyed, ToString fallback is fenced, and format multi-engine acceptance is covered.
- **as-engine-owned-hooks**: add two requirement deltas: ClassGen no longer owns process-wide reload delegates, and Editor reload state is per-engine.

## Impact

- **AngelscriptRuntime**: `Binds/Bind_UEnum.cpp`, `Binds/Bind_FString.cpp`, `Binds/Helper_ToString.h`, `Core/AngelscriptEngineHooks.h`, `ClassGenerator/AngelscriptClassGenerator.h/cpp`, `Binds/Bind_UObject.cpp`.
- **AngelscriptEditor**: `ClassReloadHelper.h/cpp`, `ScriptEditorMenuExtension.cpp`, and other subscribers.
- **AngelscriptTest**: `Bindings/AngelscriptFStringBindingsTests.cpp` (multi-engine format); `HotReload/Angelscript*HotReload*Tests.cpp` (subscription migration + isolation test).
- **Build / test workflow**: use only `Tools\RunBuild.ps1`, `Tools\RunTests.ps1`, and `Tools\RunTestSuite.ps1`.
