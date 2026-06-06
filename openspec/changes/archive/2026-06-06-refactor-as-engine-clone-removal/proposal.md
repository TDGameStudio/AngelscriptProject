# refactor-as-engine-clone-removal

## Why

`FAngelscriptEngine` contains a Clone mechanism (`EAngelscriptEngineCreationMode::Clone`) that allows creating lightweight engine copies sharing `FAngelscriptOwnedSharedState`. Investigation reveals:

- Clone has **zero production callers** (including `CreateUncompiledWithMode`, which is only called from test code).
- The Clone coordination logic (`ActiveParticipants`, `ActiveCloneCount`, `bPendingOwnerRelease`) adds unnecessary complexity to the runtime shutdown path.
- Test-specific concerns (module reset, engine pooling, transient engine creation) have leaked into `AngelscriptRuntime`, making the runtime harder to reason about independently.
- Most tests already use a persistent shared engine with module-level reset, not true Clone semantics.

Removing Clone and extracting test logic into a dedicated `FAngelscriptTestEngine` subclass simplifies the runtime while preserving test performance.

## What Changes

- **New**: `FAngelscriptTestEngine` struct in `AngelscriptTest` module, inheriting `FAngelscriptEngine`.
- **Remove**: `EAngelscriptEngineCreationMode` enum, `CreateCloneFrom()`, `CreateUncompiledWithMode()`, Clone-related members from `FAngelscriptEngine`.
- **Simplify**: `FAngelscriptOwnedSharedState` drops reference-counting fields; ownership changes from `TSharedPtr` to `TUniquePtr`.
- **Simplify**: `Shutdown()` no longer performs deferred-release coordination.
- **Inline**: After Clone removal `FAngelscriptOwnedSharedState` has no isolation purpose left — its 5 raw-pointer fields (`ScriptEngine`, `PrimaryContext`, `PrecompiledData`, `StaticJIT`, `DebugServer`) duplicate state already on `FAngelscriptEngine` / `GameThreadTLD`, and its 7 owned data members (`TypeDatabase`, `BindState`, `ToStringList`, `BindDatabase`, `BlueprintEventSignatureRegistry`, `StaticNames`, `StaticNamesByIndex`) are all 1:1 with the owning engine. The struct is removed; the 7 owned members move directly onto `FAngelscriptEngine`; the 5 mirror fields and the dual-ownership safety guards in `Shutdown()` go away. `EnsureSharedStateCreated()` / `InitializeOwnedSharedState()` / `ReleaseOwnedSharedStateResources()` collapse into the engine's own init/shutdown path.
- **Migrate**: 15 test-side `CreateCloneFrom` call sites adopt `FAngelscriptTestEngine` APIs (4 in `AngelscriptEngineIsolationTests.cpp`, 9 in `AngelscriptMultiEngineLifecycleTests.cpp`, 1 in `AngelscriptEnginePerformanceTests.cpp`, 1 in `AngelscriptTestUtilities.h`); 1 internal forwarder in `AngelscriptEngine.cpp::CreateUncompiledWithMode` is removed alongside the API.
- **Cleanup**: `AngelscriptStateDump.cpp` references `EAngelscriptEngineCreationMode` 3 times only via the read-only `GetCreationModeString` helper for CSV output; both the helper and the `CreationMode` column in the engine state dump are removed when the enum disappears.
- **Consolidate factories**: After Phase 6's flattening lands, the Phase 2 migration of `CreateUncompiledWithMode → CreateUncompiled` leaves the runtime exposing two near-identical static factories — `Create()` (initialize + initial compile) and `CreateUncompiled()` (initialize, skip initial compile). The split is purely a behavioral toggle, not two different ownership / initialization paths. Section 7 collapses them into a single `FAngelscriptEngine::Create(Config, Dependencies)` factory and routes the "skip initial compile" branch through a new `FAngelscriptEngineConfig::bSkipInitialCompile` flag. `FAngelscriptTestEngine::Create()` sets the flag internally; the 47 direct `CreateUncompiled` call sites in `AngelscriptTest` + `AngelscriptEditor/Tests` migrate to either `FAngelscriptTestEngine::Create()` (33 test-module sites) or to `FAngelscriptEngine::Create()` with `bSkipInitialCompile=true` set inline (12 editor-test sites that cannot depend on `AngelscriptTest`, plus 2 test-module wrapper sites). `CreateUncompiled` is then deleted from the runtime API surface.

## Capabilities

### New Capabilities

- **FAngelscriptTestEngine**: Test-module-owned engine subclass providing `ResetModules()`, `FullReset()`, shared-engine singleton, and test helper methods (compile-from-memory, execute functions).

### Modified Capabilities

- **FAngelscriptEngine**: Simplified to Full-mode-only; no Clone branching in `MakeModuleName`, `Shutdown`, or initialization paths. Absorbs the 7 owned data members previously held by `FAngelscriptOwnedSharedState` (type / bind databases, ToString list, blueprint event signature registry, per-engine static name table). Exposes a single `Create(Config, Dependencies)` factory whose post-construction behavior is driven by `FAngelscriptEngineConfig::bSkipInitialCompile`; the separate `CreateUncompiled` factory is removed.
- **FAngelscriptOwnedSharedState**: Removed entirely. Its role as the "Clone-shareable resource bag" is gone with Clone; its remaining purpose (a sub-aggregate inside one engine) added pure indirection.

## Impact

- **AngelscriptRuntime**: `AngelscriptEngine.h/.cpp` modified (removal of Clone API surface, `EAngelscriptEngineCreationMode` enum, and SharedState simplification). `Dump/AngelscriptStateDump.cpp` drops the `GetCreationModeString` helper and the `CreationMode` field in CSV output (the field has no consumers besides this dump).
- **AngelscriptTest**: New files `AngelscriptTestEngine.h/.cpp`; updates to `AngelscriptTestMacros.h`, `AngelscriptTestUtilities.h`, `AngelscriptTestEngineHelper.h`, `AngelscriptTestEnginePool.h`.
- **Test consumers**: All 421 test `.cpp` files in `AngelscriptTest/` compile and pass without regression; macro interface remains stable. (Baseline as of 2026-05-20 commit `91ac208` with the bind/free regression suite landed.)
- **Build rules**: No new module dependencies (AngelscriptTest already depends on AngelscriptRuntime).
- **Breaking change — CSV consumers**: The engine-overview CSV row produced by `AngelscriptStateDump` loses four columns: `InstanceId`, `CreationMode`, `OwnsEngine`, `SourceEngineId`. Any external tooling that parses this CSV by column index must be updated; consumers parsing by header name are unaffected for the surviving columns.
- **Breaking change — CSV consumers**: The engine-overview CSV row produced by `AngelscriptStateDump` loses four columns: `InstanceId`, `CreationMode`, `OwnsEngine`, `SourceEngineId`. Any external tooling that parses this CSV by column index must be updated; consumers parsing by header name are unaffected for the surviving columns.
