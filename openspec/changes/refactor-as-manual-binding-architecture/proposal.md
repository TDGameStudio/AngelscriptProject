## Why

Hand-written AngelScript bindings currently combine process-wide static `FBind` discovery, implicit current-engine resolution, and mutable "previously bound" function/property state. The surface looks partially fluent, but registration ownership, target engine, ordering, metadata attachment, module lifetime, and removal of the legacy path remain implicit and tightly coupled.

This change records a descriptor-first binding architecture that keeps existing script-visible behavior compatible while making every new binding package, descriptor node, target engine, apply result, and module owner explicit. The complete in-tree manual-binding migration ends with a legacy-disabled build, while the isolated legacy adapter remains temporarily available for downstream compatibility.

## What Changes

- Add a Runtime-module-owned binding registry whose explicitly submitted packages produce immutable per-engine catalog snapshots.
- Add a move-only `FAngelscriptBind` fluent API that directly creates value-only descriptors before any AngelScript registration occurs; ordinary author-written callables take one complete AngelScript declaration contained in one non-multiline string literal, while the surrounding C++ call and fluent chain may wrap freely. The Registry consumes and freezes it without a separate public Builder or `.Build()` step.
- Add explicit expansion descriptors for reflection-, bind-database-, and catalog-derived declarations. Expansion runs while materializing a catalog snapshot, receives only explicit read-only inputs, emits ordinary child descriptors through a restricted writer, and completes parse/normalize/identity validation before any target AS engine is mutated.
- Replace ambient `FAngelscriptType`, ToString, TypeFinder, and `FAngelscriptBindDatabase` writes with explicit auxiliary descriptors and engine-owned apply targets. Genuine process/module registrations, if found by the full inventory, remain outside package construction and use module-owned registration handles.
- Reuse the existing AngelScript declaration grammar through a parsing-context refactor so Registry preflight can parse complete declarations without creating or mutating an engine, normalize them, and compare them with typed C++ callables.
- Apply catalog snapshots to an explicit `FAngelscriptEngine&` and return structured per-package and per-node results.
- Replace global "previous bind" metadata mutation with chainable `FAngelscriptBindNode` views carrying stable descriptor identities.
- Use semantic phases plus explicit package dependencies, validation, and deterministic ordering.
- Aggregate built-in `Bind_*.cpp` providers through an explicit manifest instead of static constructors or build-time directory scanning.
- Give external modules explicit registration handles, late-registration results, snapshot leases, and safe unload diagnostics.
- Isolate the existing `FAngelscriptBinds` / `FBind` / PreviousBind behavior behind `WITH_ANGELSCRIPT_LEGACY_BINDS`, defaulting to enabled during migration.
- Migrate every in-tree manual binding in `AngelscriptRuntime`, `AngelscriptGameplayTags`, and `AngelscriptGAS`, then require a legacy-disabled build and regression run.
- Preserve UHT-generated binding strategies, reflective fallback, native-module function-address behavior, RPC routing, and engine-extension replay as separate existing systems.
- Treat `ThirdParty/Angelscript` as source-owned fork code, despite its historical directory name. Refactor and reorganize the relevant parser, builder, tokenizer, declaration syntax model, type-query boundary, and internal frontend APIs as needed to expose one engine-independent declaration parser. This binding change does not intentionally add language syntax or alter compiler/VM/calling-convention behavior; compatibility is enforced by behavior and parity tests rather than by restricting which fork files may change.

## Capabilities

### New Capabilities

- `as-explicit-binding-package-registry`: Explicit package ownership, descriptor catalog snapshots, deterministic application to a selected engine, lifecycle-safe registration handles, and legacy isolation.

### Modified Capabilities

- `as-typed-bind-dsl`: Replace the thin direct-registration facade with a descriptor-first typed `FAngelscriptBind` API in which complete AngelScript declarations are authoritative, ordinary author-written declarations remain in one non-multiline string literal, and every materialized declaration is parsed before freeze and validated against C++ callables without `ASParam` or automatic declaration generation.
- `as-bind-trait-fluent-api`: Bind fluent traits to explicit `FAngelscriptBindNode` views rather than a just-registered AngelScript ID or `PreviouslyBoundFunction`.
- `as-bind-execution-timing`: Observe deterministic snapshot expansion through catalog-build reports and package/node application through structured apply reports instead of timing only opaque `CallBinds` callbacks.
- `as-engine-scoped-runtime-state`: Remove new-path dependence on `LegacyBindState`, route type/ToString/finder/bind-database work through explicit engine-owned stores, and keep per-engine objects/IDs out of replayable package metadata.

## Impact

- Primary implementation areas are the Runtime binding core, `FAngelscriptEngine` dependency/initialization flow, Runtime module startup, all hand-written bind providers, StaticJIT/native metadata, documentation attachment, bind configuration/state observation, and binding automation tests.
- The current source inventory contains 121 Runtime `Bind_*.cpp` files, one GameplayTags bind file, and five GAS bind files. The supporting research and impact matrix capture the larger registrar and PreviousBind call-site surface.
- Existing script declarations and behavior remain the compatibility authority. Raw AS function/property IDs may change when deterministic package ordering differs from legacy callback order. `Binds.Cache` is a separate reflection-binding database whose current schema contains no package/node identity or raw AS registration IDs; this change preserves that contract unless implementation evidence justifies an explicit later spec revision.
- The only new compilation definition is the temporary plugin compatibility gate `WITH_ANGELSCRIPT_LEGACY_BINDS`; it is not a Project Setting, CVar, `.uplugin` option, or AngelScript compiler macro.
- The maintained AngelScript fork is an implementation area, not an immutable external dependency. The existing builder/registration path and the new binding preflight path will share the refactored declaration frontend; accepted declarations, diagnostics, registration behavior, and the native SDK suite remain compatibility authorities.
- No external library is added. `asbind20` and the local UnrealCSharp binding builders are design references only.
- This is a record-only OpenSpec creation. Source implementation, tests, documentation updates outside this change directory, and archive actions are deferred.
- The 2026-07-30 re-review found two implementation-shaping gaps. They are closed here as snapshot-time descriptor expansion (A1) and explicit lifetime-classified auxiliary registration (B1), refined by source evidence showing that the existing type, ToString, and bind-database stores are engine-owned behind ambient fallback access. See `review-2026-07-30.md`.
