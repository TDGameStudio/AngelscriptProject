# Tasks

> This change records work that was completed during a packaging-debugging session.
> All items below are done; raw investigation trace is in `notes/packaging-investigation.md`.

## 1. Non-Editor Compilation

- [x] 1.1 Guard editor-only entries in `AngelscriptFunctionTableCodeGenerator.cs` with `#if WITH_EDITOR` / `WITH_EDITORONLY_DATA`
- [x] 1.2 Move/guard `GetPrimaryScriptName` / `GetScriptNameForFunction` in `Helper_FunctionSignature.h` behind `WITH_EDITORONLY_DATA`
- [x] 1.3 Guard `HasMetaData`/`GetMetaData` calls in `AngelscriptBinds.cpp`, `BlueprintCallableReflectiveFallback.cpp`, `AngelscriptStateDump.cpp`
- [x] 1.4 Rebuild plugin for non-editor target until BUILD passes

## 2. Packaging Configuration & Tooling

- [x] 2.1 Set `GameDefaultMap`/`ServerDefaultMap` to `/Game/Test/ActorTestMap` in `DefaultEngine.ini`
- [x] 2.2 Add `+MapsToCook` for `ActorTestMap` in `DefaultGame.ini`
- [x] 2.3 Fix `DirectoriesToAlwaysStageAsUFS` to `../Script` (relative to `Content/`)
- [x] 2.4 Create `Tools\RunPackage.ps1` wrapping precompiled-data pre-step + `BuildCookRun`
- [x] 2.5 Fix `RunPackage.ps1` boolean parameter parsing (`-Command "& ..."`)

## 3. Precompiled Data Generation

- [x] 3.1 Add `bSkipStaticJITCodeGen` to `FAngelscriptEngineConfig` + parse `-as-skip-static-jit-codegen`
- [x] 3.2 Respect skip flag in StaticJIT setup
- [x] 3.3 Wire precompiled-data pre-step (`-as-generate-precompiled-data -as-skip-static-jit-codegen`) into `RunPackage.ps1`
- [x] 3.4 Relocate `Example_Actor.as` from `Script/Examples/Core/` to `Script/Game/`
- [x] 3.5 Remove the `-as-force-preprocess-editor-code` force flag once relocation made it unnecessary

## 4. Shutdown / Exit Crash

- [x] 4.1 Add `GAngelscriptEnginesReleasedForExit` + `AreEnginesReleasedForExit()` in `AngelscriptEngine.cpp/.h`
- [x] 4.2 Set the flag in `Shutdown()` when `IsEngineExitRequested()`
- [x] 4.3 Guard `FASStructOps::Destruct` to skip `CallDestructor` after engine release

## 5. Cooked Runtime Binding (Root Cause)

- [x] 5.1 Force game-thread init for cooked builds in `ShouldInitializeThreaded()` under `AS_USE_BIND_DB`
- [x] 5.2 Construct engine-owned `BindDatabase` BEFORE `FAngelscriptBindDatabase::Get().Load(Binds.Cache)`
- [x] 5.3 Null-guard `CompileOutInTest` / `CompileOutIfNoLog` / `CompileOutAsEnsure` / `CompileOutAsCheck`

## 6. Verification

- [x] 6.1 BUILD + cook + stage + pak complete with exit code 0
- [x] 6.2 Confirm `Binds.Cache` / `PrecompiledScript.Cache` staged
- [x] 6.3 Launch packaged `AngelscriptProject.exe`: zero `not-a-data-type` errors, no crash, enters `ActorTestMap`, precompiled scripts load
