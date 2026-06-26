## Context

`AngelscriptProject` had never been packaged into a cooked/standalone build. The plugin was developed and validated entirely in editor/automation builds, where `WITH_EDITOR` is defined, AngelScript compiles `.as` sources directly, and `FindObject<>` runs on the game thread during a single-threaded editor bootstrap. Packaging exercises a different runtime path:

- Non-editor target: `WITH_EDITOR` / `WITH_EDITORONLY_DATA` are `0`.
- Cooked content: scripts are not compiled from source; the runtime loads `PrecompiledScript.Cache` (bytecode) and `Binds.Cache` (`AS_USE_BIND_DB`) instead.
- Threaded bootstrap: `Initialize_AnyThread()` may run on a worker thread.

Each of these surfaced a distinct latent defect. This document records the decisions; `notes/packaging-investigation.md` keeps the raw debugging trace.

## Goals / Non-Goals

**Goals:**
- A repeatable `Tools\RunPackage.ps1` that produces a runnable packaged build.
- Cooked AngelScript runtime binds all engine types correctly from `Binds.Cache` (zero `not-a-data-type` errors).
- No crashes during cook commandlet shutdown or packaged-exe startup.
- Plugin compiles cleanly for non-editor targets.

**Non-Goals:**
- StaticJIT in packaged builds (intentionally skipped during precompiled-data generation; not part of the runtime contract here).
- Shipping the editor-only `Examples/` scripts in cooked builds.
- Broad re-architecture of the AngelScript bootstrap threading model.

## Decisions

### 1. Construct `BindDatabase` before `Load(Binds.Cache)` — the root cause
`Initialize_AnyThread()` called `FAngelscriptBindDatabase::Get().Load(...)` while the engine-owned `BindDatabase` was still null. `Get()` falls back to a static `LegacyBindDatabase`, so cached bind data populated the fallback while the engine's database stayed empty. Every `ExistingClass` lookup then read the empty engine database and failed, producing the `"X is not a data type in global namespace"` storm (`FMargin`, `UObject`, `UActorComponent`, ...).

Fix: move `BindDatabase = MakeUnique<FAngelscriptBindDatabase>();` to before the `Load` call so the engine's real instance is the one populated.

Alternative considered: make `Get()` lazily allocate the engine database. Rejected — it hides ownership and the fallback exists for legitimate pre-engine callers; fixing the ordering is the smaller, clearer change.

### 2. Force game-thread init for cooked builds
With `AS_USE_BIND_DB`, `ShouldInitializeThreaded()` now returns `false` (unless `bForceThreadedInitialize`). Worker-thread `FindObject<>` resolution raced with game-thread object registration and failed intermittently; the editor path already initializes effectively on the game thread, so this matches proven behavior.

### 3. Defensive null-guards in `CompileOut*`
A failed/missing bind makes `GetFunctionById` return null. The `CompileOut*` helpers dereferenced it unconditionally and crashed. They now early-return the function id when `Function == nullptr`. This is hardening, not the root cause — it converts a hard crash into a recoverable no-op while #1 fixes the actual binding.

### 4. Engine-exit GC guard
At process/cook exit, GC can destroy `UASStruct` instances after the AngelScript engine is released, so `ScriptObject->CallDestructor` touches freed memory. A process-global `GAngelscriptEnginesReleasedForExit` flag (set in `Shutdown()` when `IsEngineExitRequested()`) lets `FASStructOps::Destruct` skip the script destructor during teardown.

### 5. Non-editor compilation via `WITH_EDITORONLY_DATA` guards
Editor-only reflection (`HasMetaData`/`GetMetaData`) and UHT-generated editor-only entries are guarded so the plugin links for non-editor targets. The UHT generator emits `#if WITH_EDITOR` around editor-only function-table entries.

### 6. Staging path `../Script`
`DirectoriesToAlwaysStageAsUFS` resolves relative to `Content/`, so `Script` staged the wrong location and the runtime could not find `Binds.Cache`/`PrecompiledScript.Cache`. Corrected to `../Script`.

### 7. Precompiled-data pre-step with StaticJIT skipped
`RunPackage.ps1` runs `UnrealEditor-Cmd.exe -run=... -as-generate-precompiled-data -as-skip-static-jit-codegen` before `BuildCookRun`. The new `bSkipStaticJITCodeGen` flag avoids a StaticJIT codegen assertion during generation while still producing valid bytecode caches.

### 8. Relocate `Example_Actor.as` to `Script/Game/`
`BP_AExampleActorType` (placed by `ActorTestMap`) inherits `AExampleActorType`, defined under editor-only `Examples/`, which the cooked runtime skips. Moving the file to `Script/Game/` makes the parent type cook without forcing editor scripts via `-as-force-preprocess-editor-code` (that flag was tried, then removed because it pulled in editor-only symbols).

## Risks / Trade-offs

- [Cooked init now game-thread-bound] → Slightly slower bootstrap, but correctness over a parallel speedup that was unsafe anyway; editor already behaves this way.
- [`CompileOut*` no-op on null bind] → Could mask a genuinely missing bind; mitigated because #1 removes the mass-failure case and logs still surface individual missing binds.
- [Engine-exit destructor skip] → Skips script-side cleanup at exit; acceptable because the process/engine is tearing down and OS reclaims memory.
- [Manual config (maps/staging)] → Future map/script layout changes must update `DefaultGame.ini`; documented in tasks.

## Migration Plan

No data migration. Deploy by rebuilding the plugin and running `Tools\RunPackage.ps1`. Rollback is reverting the listed files; the bind-database ordering fix is the only behavior-critical change and is backward compatible (editor builds construct the database the same way, just earlier).

## Open Questions

- Whether to eventually support StaticJIT in packaged builds (currently skipped).
- Whether `bForceThreadedInitialize` should be exposed as a project setting for advanced cooked-perf scenarios.
