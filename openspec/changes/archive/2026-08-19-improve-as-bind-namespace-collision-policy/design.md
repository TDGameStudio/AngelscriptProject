## Context

When two reflected or manual functions land in the same AngelScript namespace with the same callable name and parameter identity:

- **Exact duplicate** — complete declaration matches (including return shape). The existing binding stays; the incoming one is suppressed.
- **Incompatible collision** — callable key matches, return or declaration shape does not. Binding MUST fail via `bDirectBindFailed` / `HasRegistrationFailure()`.

`IsEquivalentScriptSignatureAlreadyBound` in `Bind_BlueprintCallable.cpp` implements both. Incompatible collisions currently set `bDirectBindFailed = true` and then **unconditionally overwrite** `DirectBindFailureDiagnostic`. `FAngelscriptBinds::RecordRegistrationFailure` already keeps the first diagnostic and returns. A later collision in the same bind pass still fails the engine, but the published error names the last incoming function instead of the first.

Default FMath aggregation is expected to produce a small number of exact duplicates (inventory listed `Min` / `Max` / `FindNearestPointsOnLineSegments`) and zero incompatible collisions. That has not been re-measured with bind-time counters on a live engine.

`improve-as-library-namespace-canonicalization` is implemented in worktree `D:\as-lns` (plugin `06ba716`, parent `84c551f`) and is not yet on `main`. Uncommitted observation logs were started on that worktree (`Bind_BlueprintCallable.cpp`, `AngelscriptBinds.h`, `AngelscriptEngine.cpp`) and MUST be finished or rewritten here rather than forgotten.

## Goals / Non-Goals

**Goals:**

- Know how many exact-duplicate suppressions and incompatible collisions happen on the default initialized engine.
- Keep incompatible collisions fail-closed.
- Publish the first incompatible-collision diagnostic, matching `RecordRegistrationFailure`.
- Record the chosen policy so a later engine with extra mapped libraries does not silently drop later collisions' diagnostics.

**Non-Goals:**

- Reopening FMath as the sole public Math namespace, mappings, or `Math::` / `MathLibrary::` aliases.
- Turning exact duplicates into bind failures.
- Deleting leftover no-database `FAngelscriptFunctionSignature` constructors (separate review item).
- Tightening `Foo::::Bar` namespace validation (separate review item).
- TestCatalog Phase2C / `Syntax_FString.md` index nits (docs, not this change).

## Decisions

1. **Observe first, then freeze diagnostic policy.** Add per-engine counters and logs before changing first-failure-wins, so the default engine count is evidence rather than a guess.
   - Alternative: fix first-failure-wins immediately. Rejected as the only step, because it does not answer “how many collisions exist”.
2. **Two counters on `FAngelscriptBindState`.** `LibraryNamespaceExactDuplicateCount` and `LibraryNamespaceIncompatibleCollisionCount`, reset with the bind state (per engine).
   - Alternative: process-global atomics. Rejected; tests create isolated engines.
3. **Log levels.** Each exact duplicate at `Log`; each incompatible collision at `Warning` (bind will fail); `BindScriptTypes` summary at `Display` when either count is non-zero, otherwise `Verbose`.
   - Alternative: `Display` on every isolated test engine including zeros. Rejected; too noisy.
4. **First failure wins for incompatible diagnostics.** If `bDirectBindFailed` is already true, keep the existing diagnostic, still increment the incompatible counter, still skip the incoming function.
   - Alternative: concatenate every collision into one diagnostic. Deferred until counts show more than one incompatible collision on a realistic engine.
5. **Tests drive the real bind path.** Reuse the canonicalization fixtures (`UAngelscriptNamespaceMapLibraryA/B::CollisionValue` under one mapping) and assert `HasRegistrationFailure` plus the first incoming class path. Do not reimplement collision detection in the test.

## Risks / Trade-offs

- [Default engine has unexpected incompatible collisions] → Summary log at Display will show it; fail closed remains; do not “fix” by suppressing.
- [Exact-duplicate log volume at editor startup] → Keep per-event at `Log`, not `Display`.
- [FMath change not yet on main] → Implement this follow-up after that plugin commit is present, or in the same worktree; do not patch main’s pre-canonicalization `Bind_FMath` MathNamespace path.
- [Observation logs already dirty on `D:\as-lns`] → Diff that worktree first; finish or rewrite rather than duplicating a third copy.

## Migration Plan

No project `.ini` or script migration. Shipping diagnostic text for the first incompatible collision stays in the current `Incompatible collision in namespace '%s' from %s: incoming '%s' vs existing '%s'` shape.

Rollback is reverting the three Runtime files plus the Namespace.Engine tests.

## Open Questions

- After the default-engine count is captured: keep per-event exact-duplicate logs permanently, or summary-only?
- If a realistic project mapping produces multiple incompatible collisions, switch from first-failure-wins to a bounded multi-collision diagnostic?
