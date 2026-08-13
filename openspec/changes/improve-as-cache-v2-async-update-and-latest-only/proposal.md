## Why

Cache V2 already freezes a generation after a successful compile or hot reload, but callers have no first-class “update cache now” request, and the store keeps Previous plus unreachable packs until a manual Compact. After many reloads the namespace fills with history the product no longer wants. The write path must stay asynchronous so Editor/game threads do not wait on Pack I/O.

## What Changes

- Add a public async **cache update** request (C++ / Blueprint / `as.Cache.Update`) that compiles current authoritative source at a game-thread safe point, then publishes on the existing freeze → worker Pack path.
- Keep save/hot-reload success as the primary automatic write trigger. Shutdown still only flushes an already frozen generation; it still MUST NOT discover, preprocess, or compile.
- **BREAKING** store retention: after a successful `Current` commit from hot reload or an explicit update, the namespace keeps only that latest Current (and `PendingColdStart` if PIE still needs it). Previous is cleared and unreachable manifests/packs in **this** namespace are swept. Crash-safe: sweep only after `CurrentCommitted`.
- Do not delete other Compatibility/Context directory trees. Those remain explicit ForceClean / manual Saved cleanup.
- Diagnostics report update request status, publication outcome, and post-sweep retained roots.

## Capabilities

### New Capabilities

- `as-cache-async-update-api`: Explicit async cache-update request, queue/busy/shutdown status, completion callback, and console/Blueprint/C++ surface. Does not compile during Engine shutdown.

### Modified Capabilities

- `as-incremental-script-cache`: Latest-only retention after a successful Current publication; Previous is no longer a long-lived root; unreachable objects in the active namespace are swept after commit rather than waiting for a later Compact.

## Impact

- Runtime: `AngelscriptCacheService`, Store publication/compaction, `UAngelscriptSubsystem`, console commands, settings/docs.
- Tests: Cache lifecycle, store retention, new async-update prefix under `Angelscript.TestModule.Cache`.
- Docs: `Documents/Guides/AngelscriptCacheV2_ZH.md`, `Documents/Knowledges/ZH/RT_CacheV2.md`.
- Store contract in archived `store-publication-v1.md` is superseded for Previous/orphan lifetime; pointer wire and Pack/Manifest formats stay.
