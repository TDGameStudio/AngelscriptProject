## Context

The plugin has several mechanisms through which an Unreal Engine API can become visible to AngelScript: explicit `FAngelscriptBind` providers, generated native bindings, reflected UFunctions and properties, generic container/template registrations, script aliases, operators, and global helpers. A raw comparison of provider names or member names against another language integration cannot reliably identify missing functionality.

The local UnrealCSharp project is useful because its `FRegister*.cpp` providers form a concentrated catalogue of manually considered native surfaces. It is not the compatibility authority for this plugin. In particular, AngelScript's established calling conventions, Unreal Engine behavior, existing Hazelight patterns, build-module boundaries, and StaticJIT support determine whether a candidate is appropriate.

This change is deliberately a long-lived working record. It gives future small binding changes a common audit method and priority order without turning an inventory exercise into a broad, disruptive architectural refactor.

## Goals / Non-Goals

**Goals:**

- Make each audited reference member traceable to an AngelScript availability classification and evidence.
- Prevent false gap reports by normalizing differences in static versus instance forms, aliases, operators, global helpers, reflection, and templates.
- Select small, high-value type-family waves that can be implemented and tested independently.
- Keep API documentation, behavioral tests, and focused verification attached to each approved new manual binding.
- Preserve the established `ExplicitBindings` lifecycle and the separation of explicit, generated, and reflective binding paths.

**Non-Goals:**

- Achieving numerical or one-to-one API parity with UnrealCSharp, C#, or any other reference plugin.
- Rewriting existing binding architecture, adding a new bind phase, or moving reflected/template surfaces into explicit providers merely to simplify an inventory.
- Adding source-layout tests that assert file names, anonymous namespaces, lambda style, or declaration placement rather than script behavior.
- Implementing every candidate family listed in `reference-inventory.md` as part of this initial OpenSpec record.

## Decisions

### Maintain a normalized audit matrix, not a raw diff

Each audited candidate will be recorded with its source reference, native type family, C# signature or concept, AngelScript owner and phase where applicable, AngelScript-facing form, disposition, evidence, priority, and rationale.

The dispositions are:

- `AvailableExact` — the same script operation exists with materially equivalent semantics.
- `AvailableEquivalent` — the operation exists through a normalized AngelScript form, such as an instance method, operator, `FMath` helper, or a deliberately renamed API.
- `ReflectionOrTemplate` — the surface is intentionally supplied by reflection or a generic binding mechanism.
- `MissingCandidate` — no equivalent surface was found and the operation warrants a later value/dependency decision.
- `IntentionalNonGoal` — the capability is unsuitable, redundant, unsafe, or not valuable for AngelScript; the rationale is recorded.
- `BlockedByDependency` — a valid candidate cannot be exposed until an engine/module/type dependency is resolved.

This is preferred over generated name diffs because it preserves semantic judgment and makes later reviews reproducible. A raw diff may be retained as research input, but it cannot be used as the implementation backlog by itself.

### Use small family waves and rank candidates before editing runtime code

The audit proceeds in the order recorded in `reference-inventory.md`: foundation geometry, foundation utility values, generic/object wrappers, then dependency-driven specialty types. Within a family, a candidate is ranked higher when it has clear script demand, no existing equivalent, stable Unreal semantics, a small dependency footprint, and an observable focused test.

This is preferred over a repository-wide sweep because type-specific tests and API comments can land together, regressions remain attributable, and the user can redirect the next wave without discarding a large incomplete refactor.

### Treat behavioral tests as the binding contract

Every approved hand-authored API addition requires a focused script-visible test that compiles and calls the public AngelScript form, then observes its result or state. Tests belong with the existing binding test conventions under `AngelscriptTest`; source layout is not a behavior contract.

StaticJIT coverage is added only when the changed declaration/call path has a relevant JIT-specific compatibility risk. It is not a mandatory duplicate test for every ordinary explicit binding.

### Keep lifecycle ownership unchanged

New ordinary manual providers will participate in the existing `EAngelscriptBindPhase::ExplicitBindings` phase. Type registration, generated providers, and reflective paths retain their present phase ownership. This avoids changing initialization ordering in pursuit of catalogue completeness.

### Keep documentation adjacent to the provider

When a wave adds a user-facing API, its actual `FAngelscriptBind` definition receives or updates its file-header AngelScript API table. Purpose and non-obvious parameter notes follow the established `@param`-style documentation convention. This is preferred to duplicate function inventories in split declaration headers, which can drift from the binding that is actually registered.

## Risks / Trade-offs

- **Reference inventory becomes mistaken for a parity promise** → The proposal, matrix dispositions, and every wave review explicitly distinguish discovery data from approved work.
- **Equivalent APIs are missed because syntax differs** → Normalize against constructors, operators, globals, `FMath`, reflection, templates, and existing test coverage before assigning `MissingCandidate`.
- **A broad audit becomes stale before implementation** → Maintain the matrix by family and record evidence/date with each completed or deferred row; do not claim unaudited families are complete.
- **New APIs bypass Unreal semantics or affect StaticJIT unexpectedly** → Base binding shape on native engine behavior, add focused behavioral tests, and add a JIT regression only where the call path warrants it.
- **Specialty types pull in undesirable module dependencies** → Mark the candidate `BlockedByDependency` or `IntentionalNonGoal` rather than expanding runtime dependencies opportunistically.

## Migration Plan

1. Seed the matrix from `reference-inventory.md` and existing AngelScript providers without changing runtime code.
2. Select one small family or coherent API cluster, classify it, and obtain an implementation decision from the matrix.
3. Add behavioral tests before or alongside the approved explicit binding changes, then perform the focused test/build verification recorded for that wave.
4. Update the matrix, provider-adjacent documentation, and OpenSpec task state with the outcome, including deferred or non-goal decisions.
5. Repeat for later waves. If a candidate proves unsuitable, remove it from the active wave and retain an `IntentionalNonGoal` or `BlockedByDependency` record; no runtime migration or rollback is needed for an audit-only entry.

## Open Questions

### Approved value-type wave

The approved high- and medium-priority implementation wave is documented in
`high-medium-value-types-wave.md`: AssetManager value types
(`FPrimaryAssetType`, `FPrimaryAssetId`, `FAssetBundleEntry`,
`FAssetBundleData`), `FBox2D`, `FFrameNumber`, `FFrameTime`, and `FMatrix`.
It uses the configured engine's default `FMatrix` and `FBox2D` aliases rather
than initially exposing separate float/double matrix types. Asset bundles use
the current `FTopLevelAssetPath` representation, and `FindEntry` needs a safe
copied script result rather than a leaked value-owned native pointer.

- Which first family has the strongest immediate script demand after the current binding architecture work settles: color/time/GUID utilities or geometry helpers?
- Should the long-lived matrix remain as Markdown in this change directory or graduate to a maintained guide after more than one completed wave demonstrates a stable format?
- Which existing focused binding test prefixes best partition value-type regression coverage without duplicating broad StaticJIT tests?
