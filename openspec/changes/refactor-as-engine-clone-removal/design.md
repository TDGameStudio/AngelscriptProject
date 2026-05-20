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

### D6: Dump system follows the enum, not the other way around

`AngelscriptStateDump.cpp` references `EAngelscriptEngineCreationMode` only through the read-only `GetCreationModeString` helper to print a `CreationMode` column in the CSV state dump. There are no other consumers of the `CreationMode` field, and the dump is purely a diagnostic artefact.

When Phase 3 removes the enum, `GetCreationModeString` and the `CreationMode` column in the CSV output are deleted alongside it. No replacement is required because the column was tautological once Clone is gone (every engine is Full).

Rationale: Treating the dump as a downstream consumer of the enum (rather than a dependency that constrains the refactor) keeps Phase 3's runtime API removal self-contained.

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
4. **Phase 4** (SharedState): Change `TSharedPtr` → `TUniquePtr`, remove reference-counting fields.
5. **Phase 5** (Cleanup): Migrate helper functions from `AngelscriptTestEngineHelper.h` into `FAngelscriptTestEngine` methods. Evaluate moving `AngelscriptRuntime/Testing/` code to test module.
