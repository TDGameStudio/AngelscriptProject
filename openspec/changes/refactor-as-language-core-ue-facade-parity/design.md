## Context

The UE preprocessor is mature, UE-aware, and directly constructs the descriptor graph consumed by ClassGenerator. The Standalone frontend consumes values and a complete offline bundle and does not need UE source loading, reflection materialization, callback timing, or descriptor ownership. The former plan to make a shared LanguageCore the single frontend owner is therefore withdrawn.

## Goals / Non-Goals

**Goals:**

- Preserve UE production behavior and keep UE source changes narrow.
- Define a repeatable gate for future algorithm-level compatibility.
- Allow Standalone and UE to converge gradually without a new architectural layer.

**Non-Goals:**

- Replacing or splitting `FAngelscriptPreprocessor`.
- Lowering portable declaration IR into UE descriptors.
- Simulating UE filesystem, reflection, UObject, ClassGenerator, or lifecycle APIs in Compat.
- Requiring cross-host source sharing for Standalone release readiness.

## Decisions

1. UE is authoritative for UE preprocessing; Standalone owns its frontend privately.
2. A compatibility candidate must name one bounded algorithm and an observable result, such as module-name normalization or range-for lowering.
3. Before extraction, focused UE characterization and Standalone coverage must prove both hosts require the same behavior.
4. A shared helper is allowed only when its API contains value types, has no UE or Standalone host ownership, and is smaller than the duplicated host implementations it replaces.
5. Production switches only after exact behavior evidence passes in both hosts. Unclassified differences keep the implementations separate.
6. Compatibility helpers must not form a general `Language`, facade, descriptor, reflection, or source-loading layer.
7. Each candidate has its own tests and can be accepted or rejected independently; no migration sequence is implied.

## Risks / Trade-offs

- **Temporary duplication** → Accept it and keep host ownership explicit until a concrete shared helper is demonstrably smaller and safer.
- **Semantic drift** → Use focused behavior fixtures and compare normalized results before sharing an algorithm.
- **Shared helpers regrow into a layer** → Reject APIs that carry session ownership, descriptors, reflection, IO, callbacks, or host-specific configuration.

## Migration Plan

There is no bulk migration. First remove the current Runtime Language layer under `feature-ue-angelscript-standalone-compiler`. Later changes may nominate one candidate, add characterization, decide whether sharing is justified, and close that candidate independently.

## Open Questions

None. Candidate-specific decisions remain intentionally deferred until evidence exists.
