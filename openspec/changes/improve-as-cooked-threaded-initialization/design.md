## Context

`ShouldInitializeThreaded()` decides whether `Initialize_AnyThread()` runs on a worker task or the
game thread:

- **Editor**: game thread by default (`bForceThreadedInitialize` to opt in) — unchanged.
- **Cooked (this fork, current)**: forced game thread under `AS_USE_BIND_DB` as a precaution.
- **Cooked (upstream Hazelight)**: worker thread by default (`return !bSkipThreadedInitialize`).

The threaded path wraps init in `FGCScopeGuard`, swaps `GameThreadTLD` to the worker's
`asCThreadManager::GetLocalData()`, runs `Initialize_AnyThread()`, then the game thread spins
`ProcessThreadUntilIdle` + `Sleep` until done. Native `UClass`/`UScriptStruct` are registered during
module load (well before `PostDefault` AngelScript init), and `FindObject<>` reads the global object
hash under a lock, so worker-thread type resolution of native types is safe — upstream relies on this.

The cooked crash that motivated the current precaution was **not** a threading bug: `Binds.Cache` was
loaded into the fallback `LegacyBindDatabase` because the engine-owned `BindDatabase` had not been
constructed yet, leaving the real database empty. That is fixed independently. So the remaining
question for going back to worker-thread init is purely: **is the rest of this fork's
engine-scoped-state safe to initialize off the game thread?**

## Goals / Non-Goals

**Goals:**
- Restore worker-thread cooked initialization by default, matching upstream, to regain parallel-init
  startup.
- Preserve `-as-skip-threaded-initialize` as the game-thread escape hatch.
- Do it only after explicit verification on a packaged build.

**Non-Goals:**
- Changing editor initialization behavior.
- Touching the bind-database ordering fix (already correct and required regardless of thread).
- Rewriting the threading model itself.

## Decisions

### 1. Remove the precautionary block, rely on the upstream default
Delete the `#if AS_USE_BIND_DB { if (!bForceThreadedInitialize) return false; }` block so the function
ends at `return !RuntimeConfig.bSkipThreadedInitialize` for cooked builds. Update the comment to state
worker-thread cooked init is the supported default and the bind-database ordering was the real fix.

### 2. Verification is part of the change, not optional
Because the threaded path only activates in non-editor builds, editor automation does not exercise it.
The change is only complete after a packaged run confirms: no `not-a-data-type` errors, no startup
crash, scripts load, and the test map enters cleanly — the same bar used for the original packaging fix.

### 3. Audit engine-scoped global/static state for worker-thread safety
Before/while flipping the flag, audit state mutated during `Initialize_AnyThread()` / `BindScriptTypes()`
for off-game-thread hazards. Candidates: any non-engine-owned global maps/lists still touched during
bind, static caches populated lazily, and anything assuming `IsInGameThread()`. The engine-scoped-state
flattening refactor (this fork's divergence from upstream) is the prime suspect; `GlobalStateContainmentMatrix.md`
is a useful starting inventory.

## Risks / Trade-offs

- [Hidden non-thread-safe global state crashes only in packaged threaded init] → Verify on a real
  package; keep `-as-skip-threaded-initialize` as an immediate rollback without a rebuild.
- [Intermittent/racy failures hard to reproduce] → If any flakiness appears, revert to the precaution
  and capture a repro before retrying; do not ship a flaky threaded path.
- [Editor path unaffected] → Low risk; this only changes cooked behavior.

## Migration Plan

Single-line behavior flip plus comment. Rollback is re-adding the block or shipping with
`-as-skip-threaded-initialize`. No data or API migration.

## Open Questions

- Which specific globals (if any) in `Initialize_AnyThread()` / `BindScriptTypes()` are unsafe off the
  game thread in this fork? (Resolve via the audit in Decision 3.)
- Should there be an automated cooked/threaded smoke test (commandlet or packaged-run harness) to guard
  against regressions, rather than relying on a manual packaged run?
