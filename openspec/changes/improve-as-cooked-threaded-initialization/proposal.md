## Why

`FAngelscriptEngine::ShouldInitializeThreaded()` currently forces **game-thread** initialization
for cooked builds (`AS_USE_BIND_DB`) as a precaution. This was introduced while debugging the
cooked packaging crash. The actual root cause of that crash was an ordering bug —
`Load(Binds.Cache)` ran before the engine-owned `FAngelscriptBindDatabase` was constructed, so the
cache populated the fallback `LegacyBindDatabase` and bind-time readers saw an empty database. That
root cause is already fixed (BindDatabase is now constructed before the load).

Hazelight upstream runs cooked initialization **on a worker thread by default** and it works there,
so threaded cooked init is not inherently unsafe. The current game-thread forcing is therefore a
likely-unnecessary precaution that sacrifices upstream's parallel-init startup optimization (running
AngelScript init concurrently with the rest of engine startup, reducing the startup hitch).

This change records the intent to **restore worker-thread cooked initialization** once it is verified
end-to-end against a packaged build, regaining the startup-time benefit and re-aligning with upstream.

## What Changes

- Remove the `#if AS_USE_BIND_DB ... return false` precautionary block in
  `FAngelscriptEngine::ShouldInitializeThreaded()` so cooked builds initialize on a worker thread by
  default (matching upstream: `return !bSkipThreadedInitialize`).
- Keep `-as-skip-threaded-initialize` / `bSkipThreadedInitialize` as the escape hatch to force
  game-thread init if a regression is found.
- Before removing the block, **verify** that the rest of this fork's engine-scoped-state refactor is
  worker-thread safe during cooked init (this is the real open risk, not the bind database).

## Capabilities

### Modified Capabilities
- `as-cooked-packaging-runtime`: the requirement that cooked builds initialize on the game thread is
  relaxed to "initialize on a worker thread by default (game thread only via
  `-as-skip-threaded-initialize`)", once verified.

## Impact

- Runtime: `FAngelscriptEngine::ShouldInitializeThreaded()` in
  `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.cpp` (remove the precaution;
  update the explanatory comment).
- Risk surface: any global/static state touched during `Initialize_AnyThread()` /
  `BindScriptTypes()` that is not safe to mutate off the game thread. The engine-scoped-state
  flattening refactor that diverged from upstream is the area to audit.
- Verification: requires a packaged (cooked) run, not just editor automation, since the threaded path
  only activates in non-editor builds.
- No public API change; behavior change is gated behind verification.
