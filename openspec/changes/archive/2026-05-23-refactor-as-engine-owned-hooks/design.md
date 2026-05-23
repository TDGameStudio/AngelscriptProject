## Context

`FAngelscriptRuntimeModule` currently owns more than module startup/shutdown. It also exposes static process-wide getters for runtime, debug, editor, and compilation hooks. Many of those hooks are used by `FAngelscriptEngine` or code that operates on the currently active engine, but their storage lives outside the engine and therefore behaves like global mutable state.

The new `IAngelscriptExtension` registry created by `refactor-as-engine-extension-hooks` gives optional features a lifecycle seam for attach/detach/replay, but the older hook APIs still keep engine behavior behind module-level globals. That is inconsistent with the desired single-engine-owner direction and conflicts with the ongoing clone-removal work, which is moving remaining shared runtime state directly onto `FAngelscriptEngine`.

## Goals / Non-Goals

**Goals:**

1. Move engine-scoped hook storage from `FAngelscriptRuntimeModule` to a `FAngelscriptEngine`-owned hook surface.
2. Remove migrated hook getters and static delegate storage from `FAngelscriptRuntimeModule` instead of preserving long-term module forwarding.
3. Preserve the observable hook timing for runtime, preprocessor, compilation, bind, and debug call sites.
4. Keep structured `FAngelscriptCompilationEvents` as an observational event bus, separate from behavior-changing engine hooks.
5. Leave `FAngelscriptRuntimeModule` as a UE module entry and initialization compatibility surface.

**Non-Goals:**

- Moving GameplayTags or GAS behavior in this change.
- Replacing `FAngelscriptCompilationEvents` with engine hooks.
- Introducing UObject-based extension discovery.
- Removing `FAngelscriptRuntimeModule::InitializeAngelscript()` in this change.
- Reworking the DebugServer protocol or editor asset creation UI behavior beyond hook ownership.

## Decisions

### D1: Add a dedicated `FAngelscriptEngineHooks` owner instead of adding 13+ delegates directly to the engine surface

`FAngelscriptEngine` should own the hook state, but directly adding every delegate as a public engine member would make the already-large engine API harder to scan. A small hook container keeps the ownership correct while grouping the extension surface.

Alternatives considered:

- Add every getter directly to `FAngelscriptEngine`. Rejected because it expands the public API with unrelated names and makes future grouping harder.
- Keep static module getters that forward to `FAngelscriptEngine::Get()`. Rejected as the long-term design because it preserves the wrong call pattern and hides the engine ownership boundary.
- Store hooks in the extension registry. Rejected because the registry coordinates extension lifecycle, while these hooks are concrete engine callback lists used by the compiler, binds, and debugger.

### D2: Do not provide module-level forwarding as the final API

The final migrated state should remove `FAngelscriptRuntimeModule::Get*` hook APIs. Callers must use the correct owner: the current engine hook surface for engine-scoped callbacks, or the editor/debug bridge for editor-owned callbacks.

Short-lived local compatibility may be used only within one task if needed to keep a build green while migrating call sites, but the final task in this change removes the old getters.

### D3: Engine hooks own behavior-changing extension points; compilation events remain read-only observations

Hooks such as `GetClassAnalyze()` can mutate generated statics and `bHasStatics`, so they are behavior-changing engine extension points. `FAngelscriptCompilationEvents` emits value-style summaries and remains the place for read-only structured observations.

Alternatives considered:

- Convert all compile delegates into compilation events. Rejected because existing delegates can affect behavior or require mutable module/class data.
- Move compilation events into `FAngelscriptEngineHooks`. Rejected because those events are intentionally listener-driven summaries with no behavior mutation path.

### D4: Migrate editor-only hooks out of the runtime module without making them core engine state

`GetDebugListAssets()`, `GetEditorCreateBlueprint()`, and `GetEditorGetCreateBlueprintDefaultAssetPath()` are editor/debug UI bridge points. They are triggered from runtime debug code, but their concrete behavior is owned by `AngelscriptEditor`. They should move to a small bridge type rather than becoming general engine hooks.

Alternatives considered:

- Put these editor hooks on `FAngelscriptEngineHooks`. Rejected because they expose editor asset creation responsibilities through the runtime engine API.
- Leave them on `FAngelscriptRuntimeModule`. Rejected because that keeps the module as a global hook bucket.

### D5: Current-engine access must be explicit at migrated call sites

Any call site that needs an engine hook must obtain the current engine explicitly. Existing code that already uses `FAngelscriptEngine::Get()` can use `Get().GetHooks()`. Code paths where no current engine is valid must either no-op, use a dedicated bridge, or register through `IAngelscriptExtension::OnEngineAttached()`.

## Risks / Trade-offs

- [Early registration can happen before an engine exists] -> Mitigation: do not preserve invisible module globals; migrate those callers to attach through engine lifecycle or the extension registry, and add tests for late registration where relevant.
- [Multi-engine tests may observe callbacks from the wrong engine] -> Mitigation: add coverage proving hooks registered on one engine do not fire for another independent engine.
- [Editor/debug hooks can accidentally become runtime engine responsibilities] -> Mitigation: create a narrow editor/debug bridge and migrate only the existing editor-facing callbacks there.
- [Public C++ API break for external callers] -> Mitigation: document the breaking change in proposal/spec and keep names mechanically close enough for callers to migrate.
- [Large call-site migration can hide behavior regressions] -> Mitigation: split implementation into hook container, compile/preprocessor migration, bind/debug migration, editor bridge migration, and final getter removal with focused tests after each group.

## Migration Plan

1. Create the hook type declarations and `FAngelscriptEngineHooks` container in runtime core.
2. Add `FAngelscriptEngine::GetHooks()` and make each engine instance own its hook container.
3. Migrate engine compile and preprocessor call sites from `FAngelscriptRuntimeModule` to `FAngelscriptEngineHooks`.
4. Migrate runtime bind and debug call sites to engine hooks where the behavior is engine-scoped.
5. Move editor/debug UI bridge callbacks to a focused bridge type and update `AngelscriptEditor` registration.
6. Remove hook delegate declarations/getters from `FAngelscriptRuntimeModule`.
7. Run targeted hook tests, compiler/preprocessor event tests, debugger/editor smoke coverage, full build, and strict OpenSpec validation.

## Open Questions

- Should the editor/debug bridge live under `AngelscriptRuntime/Debugging` or under a shared editor-facing runtime core header? The implementation should choose the narrowest include boundary that avoids circular dependencies.
