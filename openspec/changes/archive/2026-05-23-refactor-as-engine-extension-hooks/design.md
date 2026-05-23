## Context

`AngelscriptRuntime` already exposes observation hooks for compilation and editor integration, but those hooks are not enough for optional features that own state and need to rebind it when the current engine changes. The runtime also already has engine lifecycle and current-engine stack machinery, so the missing piece is a structured extension registry that can participate in those transitions without turning `FAngelscriptEngine` into a bucket of feature-specific fields.

The clearest existing pressure point is GameplayTag support: it uses process-level caches, a dedup lookup, and a "rebind to current engine" path. That behavior is not a good fit for ad hoc delegates, and it is a stronger signal that the runtime needs a generic extension seam.

## Goals / Non-Goals

**Goals:**

1. Provide a small, reusable runtime extension registry for optional AngelScript features.
2. Allow extensions to register, unregister, and replay their engine-local state to the current engine.
3. Keep runtime behavior unchanged when no extensions are registered.
4. Support multiple engine lifecycles in one process without requiring extensions to depend on test-only code.

**Non-Goals:**

- Moving GameplayTag bindings in this change.
- Reworking existing compile/preprocessor delegates.
- Introducing a UObject-based extension system.
- Turning the registry into a general plugin discovery layer.

## Decisions

### D1: Use a runtime-owned registry instead of expanding `FAngelscriptRuntimeModule` delegates

The existing runtime delegates are observation points, not stateful lifecycle managers. A registry is a better fit because it can remember active extensions, replay them onto already-running engines, and detach them on shutdown.

Alternatives considered:

- Add more module delegates. Rejected because delegates do not retain extension identity or replay semantics.
- Use modular features. Rejected because this change is about AngelScript engine lifecycle, not UE feature discovery.
- Store extension state directly on `FAngelscriptEngine`. Rejected because that would push feature-specific responsibilities back into core runtime.

### D2: Bind extensions to engine lifecycle transitions, not only module startup

Extensions need to attach when an engine becomes current, not just when the runtime module starts. That matters for tests, hot reload, and any future second-engine scenario.

Alternatives considered:

- Startup-only registration. Rejected because it cannot replay late-registered extensions to an already-running engine.
- Query-on-demand from each extension. Rejected because it makes the engine lifecycle harder to reason about and scatters attach logic.

### D3: Keep extension state owned by each extension implementation

The registry should coordinate lifecycle, not own feature data. An extension may keep a process-level cache, per-engine cache, or both, but that state should stay inside the extension implementation so the seam remains generic.

Alternatives considered:

- Registry-owned caches. Rejected because the registry would become feature aware.
- Engine-owned feature fields. Rejected because the runtime would again accumulate optional-feature baggage.

### D4: Provide an explicit replay-to-current-engine entry point

Some extensions will need to re-register engine-local globals after a new engine becomes current. A named replay entry point makes that behavior deliberate instead of accidental.

Alternatives considered:

- Implicit replay on every scope push. Rejected because it is too broad and hard to reason about.
- Replay only at registration time. Rejected because it does not cover engine swaps after the extension is already loaded.

## Risks / Trade-offs

- [Multiple active engines can expose stale extension attachments] -> Mitigation: the registry must track active engine attachment state and require extensions to make attach/detach idempotent.
- [Late extension registration can miss the current engine] -> Mitigation: the registry replays registered extensions against any engine that is already active when registration happens.
- [The seam could become a dumping ground for unrelated hooks] -> Mitigation: keep the interface lifecycle-focused and refuse to move feature-specific logic into the core registry.

## Migration Plan

1. Add the extension registry and interface in `AngelscriptRuntime`.
2. Wire engine initialization, shutdown, and current-engine replay points to the registry.
3. Add automation tests that prove empty-registry no-op behavior, late registration replay, and unregister semantics.
4. Leave feature migrations, including GameplayTags, to follow-up changes that consume the new seam.

## Open Questions

- Should the public API expose a small handle type for extension registration, or should extensions unregister themselves by identity?
- Should the replay entry point live on the registry or on the extension interface as a callback pair?
- Should the registry expose explicit engine attach/detach notifications, or should replay be the only public lifecycle operation?
