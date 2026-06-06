# Design: refactor-as-engine-clone-removal

## Context

The AngelScript engine (`FAngelscriptEngine`) was designed with a Full/Clone dual-mode architecture to support fast engine reuse in tests. A Full engine performs expensive type-binding (~500ms), then Clone engines share its `FAngelscriptOwnedSharedState` via `TSharedPtr` and only maintain isolated module namespaces.

In practice, the test module evolved a simpler pattern: a single persistent Full engine with module-level resets between tests. The Clone mechanism is no longer exercised by any production path, and the shared-state reference counting exists solely to coordinate Clone shutdown order—a concern that belongs in the test module, not the runtime.

The ongoing deglobalization effort (Phases 1-2 complete) provides additional motivation: removing Clone eliminates one of the remaining shared-ownership patterns that complicate engine lifecycle reasoning.

## Goals / Non-Goals

**Goals:**

1. Create `FAngelscriptTestEngine` in the test module that encapsulates all test-specific engine management.
2. Remove Clone mechanism entirely from `FAngelscriptEngine` and `FAngelscriptOwnedSharedState`.
3. Simplify runtime engine lifecycle to single-owner semantics (`TUniquePtr`).
4. Maintain test execution performance (no measurable regression in suite total time).
5. Minimize diff surface in `AngelscriptRuntime`—test concerns move out, not new test hooks added in.

**Non-Goals:**

- Changing the AngelScript VM (`asCScriptEngine`) architecture or context pooling.
- Moving `FAngelscriptOwnedSharedState` out of the `.cpp` file (it remains an implementation detail).
- Refactoring the type-binding system or precompiled data paths.
- Altering the test assertion framework (`FAngelscriptTest`).

## Decisions

### D1: Inheritance over composition for FAngelscriptTestEngine

`FAngelscriptTestEngine` inherits `FAngelscriptEngine` (C++ struct inheritance). This allows direct access to protected/public engine internals without accessor indirection, and the test module already links against runtime.

Rationale: Composition would require forwarding dozens of methods; inheritance is zero-cost and `USTRUCT` supports it. No virtual functions are added to the base class.

### D2: No virtual functions added to FAngelscriptEngine

The base class gains no virtual methods. `FAngelscriptTestEngine` adds new methods (non-virtual) for test-specific operations. This keeps runtime binary layout unchanged and avoids vtable overhead for a USTRUCT used in hot paths.

Rationale: The test engine is never used polymorphically through a base pointer in production code.

### D3: TSharedPtr → TUniquePtr for SharedState

With Clone removed, `FAngelscriptOwnedSharedState` has exactly one owner. `TUniquePtr` makes ownership explicit and removes the shared-pointer control block overhead.

Rationale: Single-owner semantics match the simplified lifecycle; compile errors at any forgotten shared usage catch regressions immediately.

### D4: Shared test engine uses singleton Full engine + ResetModules()

`FAngelscriptTestEngine::GetSharedEngine()` returns a long-lived Full engine. Between tests, `ResetModules()` discards compiled modules and runs GC without destroying the engine or re-running type binding.

Rationale: This is what `GetOrCreateSharedCloneEngine()` + `ResetSharedCloneEngine()` already does in practice. Formalizing it as a first-class API eliminates the Clone indirection.

### D5: Protected access for key runtime members

Where `FAngelscriptTestEngine` needs access to engine internals (e.g., module map, script engine pointer), the relevant members in `FAngelscriptEngine` are changed from `private` to `protected`. This is the minimal runtime change needed to support the subclass.

Rationale: Adding getter methods would increase the public API surface. Protected access is appropriate for a tightly-coupled subclass in the same project.

### D6: Dump system follows the enum, not the other way around

`AngelscriptStateDump.cpp` references `EAngelscriptEngineCreationMode` only through the read-only `GetCreationModeString` helper to print a `CreationMode` column in the CSV state dump. There are no other consumers of the `CreationMode` field, and the dump is purely a diagnostic artefact.

When Phase 3 removes the enum, `GetCreationModeString` and the `CreationMode` column in the CSV output are deleted alongside it. No replacement is required because the column was tautological once Clone is gone (every engine is Full).

Rationale: Treating the dump as a downstream consumer of the enum (rather than a dependency that constrains the refactor) keeps Phase 3's runtime API removal self-contained.

### D7: Inline `FAngelscriptOwnedSharedState` into `FAngelscriptEngine`

The struct existed solely to be the unit of "what gets shared between Full + Clones" — multiple engines could hold the same `TSharedPtr<FAngelscriptOwnedSharedState>` and observe the same type/bind databases. With Clone removed (Phases 3-4), the struct collapses to a single-owner value aggregate that just adds indirection (`SharedState->X` vs `X`).

Three things become removable in one pass:

1. **5 mirror fields** (`ScriptEngine`, `PrimaryContext`, `PrecompiledData`, `StaticJIT`, `DebugServer`): These duplicate state that already lives on `FAngelscriptEngine` (`Engine`, `PrecompiledData`, `StaticJIT`, `DebugServer`) or `GameThreadTLD->primaryContext`. The duplication only existed because Clone needed to "see" the source engine's resources through the shared struct; now there's exactly one owner. The mirror fields, `InitializeOwnedSharedState()` (which assigns them), and the 4 dual-ownership guards in `Shutdown()` (lines 1426/1433/1439/1445 of pre-refactor `AngelscriptEngine.cpp`) all go away together.

2. **`EnsureSharedStateCreated()` lazy init**: Once the struct is gone, the 7 owned members live as direct `TUniquePtr<...>` fields on `FAngelscriptEngine`. They are constructed inside `Initialize()` / `InitializeWithoutInitialCompile()` at the same point `EnsureSharedStateCreated()` previously fired — no behavior change, one less indirection.

3. **`ReleaseOwnedSharedStateResources()`**: The free-function helper that walks the struct on shutdown collapses into `Shutdown()` directly, since the engine now releases its own fields.

Rationale: Continuing the clone-removal cleanup in the same change keeps the refactor coherent — the struct is a Clone-era artifact and its removal is the natural conclusion of D3 (TSharedPtr → TUniquePtr). The 30+ `SharedState->X` access sites become `X`, and 50+ `SharedState.IsValid() ? SharedState->X.Get() : nullptr` accessors become `X.Get()` (equivalent semantics: both return nullptr pre-init). No public API or test surface changes.

Risks: Build-time blast radius (~30-50 mechanical replacements in `AngelscriptEngine.cpp`); easily caught by the existing build verification step at the end of Section 6.

### D8: Single `Create()` factory driven by `FAngelscriptEngineConfig::bSkipInitialCompile`

After Phase 6 has flattened SharedState, the runtime still exposes two static factory functions on `FAngelscriptEngine`:

```cpp
static TUniquePtr<FAngelscriptEngine> Create(const FAngelscriptEngineConfig&, const FAngelscriptEngineDependencies&);            // Initialize() with initial compile
static TUniquePtr<FAngelscriptEngine> CreateUncompiled(const FAngelscriptEngineConfig&, const FAngelscriptEngineDependencies&);  // InitializeWithoutInitialCompile() — no initial compile pass
```

Surveying after Phase 2 lands: `CreateUncompiled` has 47+ direct callers (33 in `AngelscriptTest/Core`, 12 in `AngelscriptEditor/Tests`, 2 in `AngelscriptTest/Shared` wrappers), `Create` has exactly 1 (the test-engine wrapper, which currently delegates to `CreateUncompiled`). Both factories perform the same construction (`MakeUnique<FAngelscriptEngine>(Config, Deps)`) and the same initialization down to the *single* difference of whether the post-init initial-compile pass runs — that pass is itself already gated by `Config.bGeneratePrecompiledData` / `Config.bDevelopmentMode`. The two factories are a behavior toggle, not two ownership / lifecycle paths.

We collapse them into a single factory:

```cpp
static TUniquePtr<FAngelscriptEngine> Create(const FAngelscriptEngineConfig& InConfig, const FAngelscriptEngineDependencies& InDependencies)
{
    TUniquePtr<FAngelscriptEngine> Engine = MakeUnique<FAngelscriptEngine>(InConfig, InDependencies);
    if (InConfig.bSkipInitialCompile)
    {
        Engine->InitializeWithoutInitialCompile();
    }
    else
    {
        Engine->Initialize();
    }
    return Engine;
}
```

The toggle lives on the existing `FAngelscriptEngineConfig` struct as a new field `bSkipInitialCompile = false` (default reflects the production path: full Initialize). `FAngelscriptTestEngine::Create()` constructs a config copy with the flag flipped to `true`, then delegates to `FAngelscriptEngine::Create()`.

**Caller migration shape:**

| Caller group | Count | Migration |
|---|---|---|
| `AngelscriptTest/Core/*` and `AngelscriptTest/Functional/*` | 33 | Replace `FAngelscriptEngine::CreateUncompiled(Config, Deps)` with `FAngelscriptTestEngine::Create(Config, Deps)`. The wrapper sets the flag internally so call sites stay short. |
| `AngelscriptTest/Shared/AngelscriptTestUtilities.h` and `AngelscriptTestEngineHelper.h` | 2 | Replace with `FAngelscriptTestEngine::Create()` (these *are* the test wrappers). |
| `AngelscriptEditor/Tests/*` | 12 | Cannot use `FAngelscriptTestEngine` (no `AngelscriptTest` dependency). Set `Config.bSkipInitialCompile = true;` inline before calling `FAngelscriptEngine::Create(Config, Deps)`. |

After migration, `FAngelscriptEngine::CreateUncompiled` is deleted from the header and `.cpp`.

**Why this lands now, not later:** The CreateUncompiled migration in Phase 2 (task 2.6) already touched 9 of these call sites to pivot them off the Clone-mode `CreateUncompiledWithMode` API. Doing the final factory consolidation immediately after — while Phase 2's migration is still in working memory and `git blame` already points at this change — keeps related churn in a single commit history. Deferring it would mean touching the same caller bodies twice across two changes.

**Why a config flag, not two methods:** The two factories already shared 100% of construction and 95% of initialization. The "do I want initial compile?" axis is data, not control flow. Putting it on `FAngelscriptEngineConfig` keeps factories at the single-entry-point pattern UE uses for engine construction (e.g. `FAutomationFrameworkSpec::CreateAutomationContext`), and the flag is naturally adjacent to the other initialization toggles already on the struct (`bSkipThreadedInitialize`, `bForceThreadedInitialize`, etc.).

**Why not delete `Create` instead:** `Create` is the production-shaped factory (full initialize). Deleting it and renaming `CreateUncompiled` would require renaming 1 production-adjacent caller and the test wrapper, plus the cognitive cost of "uncompiled" being the default. The flag-on-default-`Create` shape matches caller intuition: production code calls `Create(Config)` with default flags; test code sets the explicit flag.

Risks:
- **Caller blast radius**: ~47 call sites change in this section. Mitigated by the test-module wrapper absorbing 33 of them, leaving only 12 editor sites + 2 wrapper sites needing inline flag changes.
- **Silent behavioral drift if a caller forgets the flag**: A test caller that meant to skip initial compile but forgets to set the flag would suddenly run the full compile pass (slower but correct). Mitigated by the test-module wrapper being the only path test code uses; direct `FAngelscriptEngine::Create` calls are limited to the 12 editor sites which all set the flag inline at the construction point.

## Risks / Trade-offs

### R1: Test performance if ResetModules is more expensive than Clone creation

**Risk**: Module reset may trigger more cleanup work than creating a fresh Clone with an empty module namespace.

**Mitigation**: Profile `ResetModules()` vs old Clone path. The current `ResetSharedCloneEngine()` already performs the same cleanup steps, so no regression is expected. Add a timing assertion in CI if needed.

### R2: Tests that rely on truly isolated engine state

**Risk**: A few tests may depend on Clone's isolated module namespace (e.g., testing module name collisions).

**Mitigation**: `FAngelscriptTestEngine::Create()` provides a fresh Full engine for tests needing full isolation. These are rare (~2-3 tests) and the ~500ms cost is acceptable for targeted use.

### R3: Breaking existing test code during migration

**Risk**: 421 test `.cpp` files and 15 Clone call sites need updating (the runtime-internal forwarder in `CreateUncompiledWithMode` removes alongside the API).

**Mitigation**: Phase the migration. Keep old macros working via updated implementations in Phase 2 before removing Clone in Phase 3. This allows incremental validation.

## Migration Plan

1. **Phase 1** (Additive): Create `FAngelscriptTestEngine` with `ResetModules()` and `GetSharedEngine()`. Old macros/utilities still work.
2. **Phase 2** (Test-side): Update macros and utilities to route through `FAngelscriptTestEngine`. Replace 15 `CreateCloneFrom` calls. Validate all 421 tests pass.
3. **Phase 3** (Runtime removal): Delete Clone API from `FAngelscriptEngine`. Simplify `Shutdown()`. Remove the `GetCreationModeString` helper and the `CreationMode` column from `Dump/AngelscriptStateDump.cpp` (see D6).
4. **Phase 4** (SharedState lifecycle): Change `TSharedPtr` → `TUniquePtr`, remove reference-counting fields.
5. **Phase 5** (Cleanup): Migrate helper functions from `AngelscriptTestEngineHelper.h` into `FAngelscriptTestEngine` methods. Evaluate moving `AngelscriptRuntime/Testing/` code to test module.
6. **Phase 6** (SharedState flatten — see D7): Inline the 7 owned data members of `FAngelscriptOwnedSharedState` directly onto `FAngelscriptEngine`; delete the 5 duplicate mirror fields, `EnsureSharedStateCreated()`, `InitializeOwnedSharedState()`, `ReleaseOwnedSharedStateResources()`, and the `FAngelscriptOwnedSharedState` struct itself.
7. **Phase 7** (Factory consolidation — see D8): Add `FAngelscriptEngineConfig::bSkipInitialCompile`; rewrite `FAngelscriptEngine::Create` to dispatch on the flag; migrate ~47 `CreateUncompiled` call sites (33 `AngelscriptTest/Core` + 2 `AngelscriptTest/Shared` wrappers via `FAngelscriptTestEngine::Create`; 12 `AngelscriptEditor/Tests` via inline flag set + `FAngelscriptEngine::Create`); delete `CreateUncompiled` from the runtime API.
