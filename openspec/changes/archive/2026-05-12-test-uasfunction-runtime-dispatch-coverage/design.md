## Context

`UASFunction` owns several execution surfaces: generic BPVM/Parms adapters, specialized primitive/object/reference wrappers, raw JIT subclasses, direct optimized helper methods, and source/generated metadata predicates. The current ASFunction tests cover important smoke paths, but they do not systematically stress ABI-sensitive argument layout, failure fallback, stale function pointers, or virtual override safety.

## Goals / Non-Goals

**Goals:**

- Cover direct optimized calls and wrapper entry points with observable script behavior.
- Verify both `ProcessEvent` and direct `RuntimeCallEvent` preserve reflected parameter and return layouts.
- Prove virtual dispatch resolves to the actual script override even when an optimized `UASFunction` is invoked through a parent declaration.
- Make stale/discard and metadata predicate behavior explicit.

**Non-Goals:**

- Refactor `UASFunction` dispatch architecture.
- Require every local environment to generate raw JIT subclasses.
- Add broad BlueprintEvent/BlueprintCallable coverage unrelated to `UASFunction` dispatch.

## Decisions

- Use the existing runtime integration layer under `AngelscriptTest/ClassGenerator` with prefix `Angelscript.TestModule.ClassGenerator.ASFunction`; it already hosts ASFunction dispatch, optimized call, metadata, process-event, and world-context tests.
- Implement in two phases: direct call/metadata first, then wrapper ABI/virtual dispatch. This keeps failures local and matches the risk split in the review reports.
- Tests SHALL not assume JIT availability. They may record and accept either specialized non-JIT or `_JIT` subclasses, but behavior assertions must be identical.
- If a test needs to exercise the context slow path directly, prefer test-local pointer preservation/restoration on public `UASFunction` fields or a minimal test-only helper over production API changes.

## Risks / Trade-offs

- ABI matrix tests can become verbose -> use local helpers for reflected param buffers and property reads.
- JIT availability differs by build -> assert behavior and subclass family, not exact JIT class.
- Exception/default fallback can produce expected logs -> scope expected errors so tests fail only on unexpected diagnostics.
- Multi-file source metadata may reflect current module-first behavior rather than declaration-file precision -> document the current behavior in the test name and assertions instead of silently redefining it.
