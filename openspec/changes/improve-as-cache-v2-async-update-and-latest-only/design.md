## Context

V1 already:

- Freezes pointer-free artifacts after a successful compile/hot reload and prepares Packs on workers.
- Exposes `Flush` (wait for prepared work), `Compact` (explicit mark/sweep), `ForceClean`, `RequestRuntimeReload`.
- Retains Current, Previous, and PendingColdStart as physical roots. Orphan finals are allowed until Compact. Startup never sweeps.

The product now wants an explicit update API, all publication I/O to stay async, and **no in-namespace history after a successful hot-reload/update commit**.

Shutdown compilation remains forbidden (`as-incremental-script-cache` shutdown requirement).

## Goals / Non-Goals

**Goals:**

- One queued async update request that uses the same compile → freeze → worker publish path as a successful Editor reload.
- Callers never block the game thread on Pack compression or disk rename.
- After `CurrentCommitted` from reload or update, this namespace’s live root is Current only (plus PendingColdStart when PIE still owns a cold candidate).
- Sweep of unmarked strict-name finals in this namespace happens in the same committed publication, after the pointer switch, using the existing two-phase lock/reacquire pattern so a pinned reader is not invalidated.

**Non-Goals:**

- Compiling or discovering source during `FAngelscriptEngine::Shutdown()`.
- Deleting sibling Compatibility/Context trees.
- Changing Pack/Manifest/pointer wire, RecordId, or VM codec.
- Making Compact-on-startup.
- Replacing `RequestRuntimeReload` (packaged code-only live reload). Update is cache-maintaining compile+publish, not a second reload policy.
- Hierarchical manifests or pack regrouping (separate change).

## Decisions

### 1. Update request is compile-then-publish, not Flush-only

`RequestAngelscriptCacheUpdate` / `as.Cache.Update` / Blueprint `RequestCacheUpdate`:

1. Reject when shutting down (`ShuttingDown`) or when another update/reload already owns the gate (`Busy`).
2. Queue on the engine mutation gate (game-thread safe point).
3. Discover current source and run the same transaction as an Editor full/soft compile for the active target.
4. On success, freeze the DTO and schedule the existing async Pack/Manifest writer.
5. Return immediately with `Queued`. Completion fires when Current is committed **and** latest-only sweep has finished or been safely deferred.

Flush stays “wait for an already frozen generation.” Update is “make Current match current source, then publish.”

**Rejected:** Flush-only “update” — it cannot refresh from disk if nothing is frozen.
**Rejected:** Shutdown hook that compiles — teardown cannot own the mutation gate or ClassGenerator.

### 2. Publication I/O stays on workers

Unchanged: freeze inside the mutation gate; workers see only the immutable DTO. The update API MUST NOT call `Flush` on the request thread except when the caller explicitly uses `as.Cache.Flush`.

If a second update arrives while workers are writing the first, it is `Busy` (or coalesced into one follow-up compile after commit). V1 chooses **Busy + one queued follow-up at most** so a save-storm does not start N compiles.

### 3. Latest-only after successful Current commit

```text
Current replace succeeds
        |
        v
Clear Previous pointer (atomic remove / absent slot)
        |
        v
Phase B style: reacquire lock, roots = Current
               (+ PendingColdStart if that pointer is still present)
        |
        v
Sweep unmarked Packs/Manifests/temps in THIS namespace only
```

Failed compile/reinstancing: do not advance Current, do not sweep last-good files.
PIE structural: still publish PendingColdStart only; do not delete Current; do not treat Pending as “latest to keep alone” until a later full/cold transaction promotes it.

Crash before Current replace: previous Current remains; incomplete temps are not accepted. No sweep of the old tree.

**Rejected:** Keep Previous forever “just in case.” Product asked to drop in-namespace history after a successful reload.
**Rejected:** Delete other hex namespace directories. Those are different Compatibility/Context, not “old Tick packs.”

### 4. Reader pinning still wins over sweep

Sweep uses the existing handle-safe unlink / deferred delete. A session that pinned the old Current may keep reading those bytes until it closes; deletion can defer. The new Current is already the pointer root.

### 5. API surface

Reuse reload-style enums rather than inventing a second family where possible:

| Surface | Name |
|---------|------|
| C++ | `RequestAngelscriptCacheUpdate` on the engine/service |
| Blueprint | `UAngelscriptSubsystem::RequestCacheUpdate` + `OnCacheUpdateCompleted` |
| Console | `as.Cache.Update` |
| Status | `Queued`, `Busy`, `ShuttingDown`, `Disabled` (cache off), then completion `Published`, `NoChanges`, `CompileFailed`, `Cancelled` |

`NoChanges` is allowed when source snapshot already equals Current and no pending write exists.

## Risks / Trade-offs

- **[Risk] Lost Previous fallback after a bad Current that still committed.**
  → Mitigation: only commit Current after the same validation V1 already requires; failed compile never commits. Recovery is ForceClean + recompile from source, which is already the source-authoritative rule.

- **[Risk] Sweep deletes a pack still needed by a pinned reader.**
  → Mitigation: existing pin + delete-sharing / deferred delete. Tests must overlap a read session with a latest-only publish.

- **[Risk] Save-storm Busy drops updates.**
  → Mitigation: single coalesced follow-up after the in-flight publish. Tests cover two rapid requests.

- **[Risk] PIE Pending + latest-only accidentally drops live Current.**
  → Mitigation: Pending publication does not run the Current latest-only sweep. Promotion of Pending is a Current commit and then sweeps everything except the new Current (Pending slot cleared).

## Migration Plan

- Existing stores with Previous and orphans: next successful reload/update in that namespace sweeps them. No startup migration.
- Docs: shutdown still flush-only; Compact remains for an explicit “rewrite reachable without compiling”; ForceClean still wipes identity.
- Rollback: restore Previous-as-root + Compact-only sweep by reverting this change; wire format unchanged.

## Open Questions

None blocking the record. If later we want idle Compact of **other** Compatibility trees, that is a separate change.
