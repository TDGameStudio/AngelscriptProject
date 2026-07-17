## Context

Hazelight's `angelscript-master` is an Unreal Engine fork containing both plugin changes and engine-side Angelscript support. The prior audit examined a recent window of 20 repository commits, but the intended historical marker `472bb2fab5a0` was never written to `audit-state.json`. GitHub's repository-wide compare endpoint is also capped for this large repository, so it cannot be used as the source of truth for a complete incremental audit.

The local project is a standalone plugin fork. Runtime code lives in `Plugins/Angelscript`, while OpenSpec and audit records live in the parent repository. The local checkout already contains unrelated user changes and one plugin formatting change that must be committed separately before this work.

## Goals / Non-Goals

**Goals:**

- Audit every relevant Angelscript-related commit between the historical marker and the current Hazelight head.
- Make the audit helper path-scoped, paginated, deduplicated, and independent of the repository-wide compare limit.
- Preserve a complete inventory even when a change is deferred or already solved locally.
- Adopt only five low-risk, plugin-local fixes in the first implementation batch.
- Establish a real machine checkpoint after human-reviewed verification.

**Non-Goals:**

- Do not wholesale-sync the Hazelight Unreal Engine fork.
- Do not change floating-point `Pow` semantics in this batch.
- Do not import engine-side UHT, CoreUObject, StructViewer, Kismet, or other engine patches.
- Do not implement GAS-specific changes in the core plugin change.
- Do not resolve every deferred item in the same OpenSpec.

## Decisions

### Complete range source

Recent-window mode remains available for quick inspection. Complete-range mode queries GitHub's paginated commits endpoint separately for configured Angelscript-related paths, stops at the base marker or its date boundary, deduplicates full SHAs, and fetches per-commit details for changed files. The repository-wide compare endpoint is not used in this mode.

### Audit paths

The default complete-range paths include the core plugin, optional Angelscript extensions, UHT support, and script examples. GAS remains classified as out of default implementation scope even when it is included in the inventory.

### First implementation batch

The first batch contains only changes with an equivalent local plugin path and bounded behavior:

- replace the `TrimQuotes` trivial member-pointer bind with a lambda;
- stop `UObjectTickable` ticking before marking it garbage;
- expose `CreateWidget`'s determined output type metadata;
- remove the incorrect trivial constructor registration for `FLatentActionInfo`;
- use the local lambda binding path for EnhancedInput `GetHandle`, which provides the same no-native-form behavior as Hazelight's `METHOD_NOJIT` without introducing the upstream `FASBindFunctionPointers` infrastructure absent from this fork.

### Pow semantics

Current integer exponent overflow checks remain unchanged. Current interpreter floating exponent paths throw when the result equals `HUGE_VAL`, while StaticJIT already skips that check. Hazelight removes only the floating compile-time and interpreter checks so floating overflow returns the platform floating overflow value, normally `+inf`, instead of an AngelScript exception. This remains deferred because it changes script-visible semantics and existing tests.

### Checkpoint update

The checkpoint is updated only after the inventory, local comparisons, first-batch tests, and build are complete. The intended baseline is `472bb2fab5a0bc76d0a86a1dd80750a4118b8418`; the reviewed head is `138a7e186082b639375b95545e0177b18f13c4be`.

## Risks / Trade-offs

- **GitHub path history does not contain the base commit** → use the base commit timestamp as a fallback boundary and report the path-specific boundary in JSON.
- **Multiple paths return duplicate commits** → deduplicate by full SHA before author grouping and file inspection.
- **Unreal Engine paths include unrelated commits** → retain them in the inventory with explicit UE-follow or reference-only classifications.
- **Existing plugin and parent changes are dirty** → stage exact paths only and commit the pre-existing plugin formatting change separately.
- **Binding fixes may be compile-only regressions** → add native-form or signature assertions before production edits and verify with the project runners.

## Migration Plan

1. Commit the existing plugin formatting-only change.
2. Create and populate this OpenSpec with the complete audit inventory.
3. Update and smoke-test the complete-range audit helper.
4. Add regression tests, observe the expected red state, then implement the five low-risk fixes.
5. Run targeted tests and the editor build.
6. Record the reviewed checkpoint and audit log.
7. Commit the plugin submodule first, then the parent OpenSpec, skill changes, and gitlink.

## Open Questions

- Whether to adopt the deferred floating `Pow` semantic change in a later OpenSpec.
- Whether engine-side UHT property caching should be handled by a separately maintained patched engine.
- Whether the deferred StaticJIT, HotReload, Placeable, and TArray changes should be grouped or split into capability-specific changes.
