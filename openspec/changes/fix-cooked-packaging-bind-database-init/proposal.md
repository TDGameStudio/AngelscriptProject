## Why

The project had never been successfully packaged (cooked build). Earlier attempts failed at multiple stages — the plugin would not compile for non-editor targets, the cook commandlet crashed on shutdown, AngelScript caches were not staged, and even after staging the packaged `.exe` crashed during AngelScript engine startup with hundreds of `"X is not a data type in global namespace"` errors. The root cause of the runtime crash was an initialization-ordering bug: `Binds.Cache` was loaded into a temporary static fallback database instead of the engine-owned `BindDatabase`, leaving the engine's database empty so every `ExistingClass` lookup failed in cooked builds.

This change records the end-to-end work required to make `Tools\RunPackage.ps1` produce a runnable packaged build whose AngelScript runtime initializes correctly from precompiled caches.

## What Changes

- **Fix bind database init ordering (root cause)**: construct the engine-owned `BindDatabase` before calling `FAngelscriptBindDatabase::Get().Load(Binds.Cache)`, so cached bind data populates the engine's real database instead of the static `LegacyBindDatabase` fallback.
- **Force game-thread init for cooked builds**: `FAngelscriptEngine::ShouldInitializeThreaded()` returns `false` when `AS_USE_BIND_DB` is active (cooked), unless `bForceThreadedInitialize`, to make `FindObject<>` type resolution reliable.
- **Harden `CompileOut*` binds**: null-guard `CompileOutInTest` / `CompileOutIfNoLog` / `CompileOutAsEnsure` / `CompileOutAsCheck` so a failed bind cannot crash the engine.
- **Fix engine-exit GC crash**: `GAngelscriptEnginesReleasedForExit` flag + guard in `FASStructOps::Destruct` to skip script destructors after the engine is released at exit.
- **Compile plugin for non-editor targets**: guard editor-only metadata access (`HasMetaData`/`GetMetaData`) with `WITH_EDITORONLY_DATA`, and emit `#if WITH_EDITOR` guards around editor-only entries in the UHT function-table generator.
- **Stage AngelScript caches & scripts**: `DirectoriesToAlwaysStageAsUFS` corrected to `../Script` (relative to `Content/`); maps and default map configured for cooking.
- **Add packaging tooling**: new `Tools\RunPackage.ps1` automates a precompiled-data pre-step (`-as-generate-precompiled-data -as-skip-static-jit-codegen`) plus `BuildCookRun`.
- **Add StaticJIT skip flag**: `bSkipStaticJITCodeGen` / `-as-skip-static-jit-codegen` so precompiled-data generation does not crash on StaticJIT codegen.
- **Relocate `Example_Actor.as`** out of editor-only `Examples/` into `Script/Game/` so `BP_AExampleActorType`'s parent type cooks in a non-editor build.

## Capabilities

### New Capabilities
- `as-cooked-packaging-runtime`: how the AngelScript runtime loads precompiled caches and binds types in cooked/packaged builds, plus the staging and packaging tooling contract that supports it.

### Modified Capabilities
- `engine-shutdown-resource-cleanup`: extends shutdown cleanup so script struct destructors are skipped once engines are released for process exit, preventing a use-after-release crash during cook/packaged-exit GC.

## Impact

- Runtime: `AngelscriptEngine.cpp/.h`, `AngelscriptBinds.cpp`, `AngelscriptBindDatabase.cpp`, `ASStruct.cpp`, `Helper_FunctionSignature.h`, `BlueprintCallableReflectiveFallback.cpp`, `AngelscriptStateDump.cpp`.
- UHT tool: `AngelscriptFunctionTableCodeGenerator.cs`.
- Config: `Config/DefaultEngine.ini`, `Config/DefaultGame.ini`.
- Tooling: new `Tools\RunPackage.ps1`.
- Scripts: `Script/Examples/Core/Example_Actor.as` → `Script/Game/Example_Actor.as`.
