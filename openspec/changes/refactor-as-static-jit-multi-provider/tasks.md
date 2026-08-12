# Implementation Tasks

All tasks are intentionally unchecked. This 2026-08-12 refactor replaces the previous implementation checklist; no Runtime, Editor, test-module, project-module, or vendored AngelScript source change is claimed by this OpenSpec-only update.

## 1. Freeze The Unified AngelScript JIT Lifecycle

- [ ] 1.1 <!-- Non-TDD --> Reconfirm the local 2.38 lifecycle evidence (`NewFunction`, delayed `SetJITFunction`, `CleanFunction`, interface-version property) and record any fork drift discovered immediately before implementation.
- [ ] 1.2 <!-- TDD --> Add native SDK tests that fail until one non-versioned `asIJITCompiler` lifecycle can publish and retrieve a complete VM/Raw/Parms/UserData binding after compilation.
- [ ] 1.3 <!-- TDD --> Add lifecycle tests for replacement, explicit clear, function destruction, module discard, compiler replacement, compiler removal, re-entrant execution, and exactly-once release.
- [ ] 1.4 <!-- TDD --> Replace the fork's current compile/release callbacks and separate public JIT pointer ownership with the unified delayed binding API; remove JIT interface version selection rather than retaining v1/v2 adapters.
- [ ] 1.5 <!-- TDD --> Make `asCScriptFunction` own safe binding replacement/retirement and ensure every destruction/rollback path releases the complete binding exactly once.
- [ ] 1.6 <!-- TDD --> Refactor `FStaticJITGenerator` into an observer/generation consumer of compiled functions so generation never swaps the live engine's execution compiler.
- [ ] 1.7 <!-- Non-TDD --> Update vendored interface documentation and fork-difference notes to explain the maintained-fork-owned lifecycle and the intentional incompatibility with both old fork and upstream version-switching APIs.

## 2. Neutralize Stable Artifact Identity And Route Ownership

- [ ] 2.1 <!-- Non-TDD --> Reconfirm the stable function/type/module identity and execution/debug/profile/environment hashes delivered by `refactor-as-incremental-function-cache`; consume identity contracts without depending on Cache V2 storage internals.
- [ ] 2.2 <!-- TDD --> Add compile-time layout and behavioral tests for neutral artifact reference descriptors, immutable route values, route generations, and typed mismatch results used by both Cache V2 and StaticJIT.
- [ ] 2.3 <!-- TDD --> Move/rename reusable `FAngelscriptCache*Route*` and reference-value concepts into neutral Runtime artifact types without changing Cache V2 behavior.
- [ ] 2.4 <!-- TDD --> Update Cache V2 to use the neutral types and prove source compile, incremental hit/miss, dependency invalidation, and fresh-engine restoration remain unchanged.
- [ ] 2.5 <!-- TDD --> Add two-engine tests proving stable identity equality despite reordered/reused FunctionIds and proving route/function/reference state remains engine-local.

## 3. Define The Current Provider ABI And Stable Reference Slots

- [ ] 3.1 <!-- TDD --> Add ABI/layout tests for `FAngelscriptJITProviderId`, `FAngelscriptJITProviderGeneration`, `FAngelscriptJITEntryPoints`, `FAngelscriptJITReferenceSlot`, `FAngelscriptJITArtifactEntry`, `FAngelscriptJITProviderView`, and `IAngelscriptJITArtifactProvider` including invalid sizes/counts/pointers/order and multi-AS-module entry ownership.
- [ ] 3.2 <!-- TDD --> Implement one current provider ABI revision and a Runtime multi-provider Registry with copied/validated catalogs, owner-scoped registration/unregistration, deterministic enumeration, and no legacy provider adapter.
- [ ] 3.3 <!-- TDD --> Add provider-match matrix tests for stable module/function key, execution content, profile, environment, ABI, entry-point completeness, reference descriptor, duplicate entry, artifact-set mismatch, and different-Provider exact ambiguity.
- [ ] 3.4 <!-- TDD --> Implement stable reference descriptors for function/type/global/string/import/runtime-helper references and resolve them into engine-local immutable slots during route construction.
- [ ] 3.5 <!-- TDD --> Add reference-slot tests for missing/ambiguous/wrong-kind targets, reordered engine objects, provider refresh, module discard, and two-engine isolation.
- [ ] 3.6 <!-- TDD --> Implement safe per-ProviderId generation publication and retirement so one provider module unload/Live Coding replacement cannot invalidate in-flight bindings, reference slots, or unrelated Providers.
- [ ] 3.7 <!-- TDD --> Route VM, Raw, and Parms generated entries through `FScriptExecution` and the complete AS binding without relying on a process-global current Engine or provider-owned memory.
- [ ] 3.8 <!-- TDD --> Add concurrent `AngelscriptTestJIT`/project/plugin Provider tests, one-Provider-multiple-AS-module tests, ProviderId conflict/recovery tests, and two-engine isolation tests proving selection never depends on registration or UE module load order.

## 4. Route Current Script And UASFunction Calls

- [ ] 4.1 <!-- TDD --> Add script-to-script parity tests for Native hit, VM miss, changed callee body, refreshed Native hit, exceptions, references, object lifetime, recursion, imports, and current virtual override.
- [ ] 4.2 <!-- TDD --> Implement reloadable-profile call sites so they resolve the current callee and current immutable binding/route rather than embedding a content-specific Native pointer.
- [ ] 4.3 <!-- TDD --> Add `UASFunction` matrix tests for specialized/generic, no-param, primitive/reference/object return, static, virtual, thread-safe, world-context, and reflected Parms dispatch.
- [ ] 4.4 <!-- TDD --> Make Editor/PIE `UASFunction` wrappers read the current ScriptFunction/binding and prove one changed method cannot retain its prior VM/Raw/Parms entry while unchanged methods remain Native.
- [ ] 4.5 <!-- TDD --> Add safe-publication tests where re-entrant and thread-safe calls overlap script/provider replacement, then implement binding snapshot retention until the last active reader exits.
- [ ] 4.6 <!-- TDD --> Limit direct content-specific calls to completely validated immutable cooked artifact sets and fail closed to current VM dispatch on any incomplete set.

## 5. Build The Shared Generator And Project Module Tooling

- [ ] 5.1 <!-- TDD --> Add deterministic generator goldens for full stable keys, content-addressed symbols/paths, per-function slices, stable reference descriptors, provider metadata, exact 32-bucket assignment, sorted aggregators, and removed-function cleanup.
- [ ] 5.2 <!-- TDD --> Refactor StaticJIT emission to generate per-function slices included by exactly 32 fixed bucket translation units, plus current provider metadata and owned-file inventory.
- [ ] 5.3 <!-- TDD --> Add profile tests for `EditorDevelopment`, `GameDevelopment`, and `GameShipping`, proving isolated output identity and rejection across profile/environment/ABI boundaries.
- [ ] 5.4 <!-- TDD --> Implement shared Runtime emission/comparison primitives plus separate Editor project orchestration with versioned owned-file markers, atomic replacement, unchanged-byte preservation, user-file conflict refusal, deterministic temporary-root verification, and stale-output diagnostics.
- [ ] 5.5 <!-- TDD --> Add fixed `AngelscriptJIT` module/path tests for Runtime/PostDefault `.uproject` registration, Runtime dependency, target discovery, reserved-name conflict refusal, project-domain-derived ProviderId, exactly 32 buckets, and idempotent scaffold reruns.
- [ ] 5.6 <!-- TDD --> Implement the `AngelscriptEditor`-owned project `-run=AngelscriptJIT -Mode=Scaffold|Generate|Verify` commandlet on top of shared Runtime emission primitives; keep project source discovery/scaffold orchestration out of Runtime and independent of both test modules.
- [ ] 5.7 <!-- TDD --> Make Verify read-only and report provider/profile/ABI, stable key, slice, symbol, bucket, and unexpected/missing owned-file differences with a non-zero commandlet result.

## 6. Establish The Editor-Only AngelscriptTestJIT Proof Module

- [ ] 6.1 <!-- TDD --> Add build/ownership tests that fail until `AngelscriptTestJIT` is an Editor-only fixed plugin-test carrier with dependency chain `AngelscriptRuntime <- AngelscriptTestJIT <- AngelscriptTest`, a stable test ProviderId, and no project name/source/settings/scaffold/descriptor/output dependency.
- [ ] 6.2 <!-- Non-TDD --> Create the `AngelscriptTestJIT` module shell and exactly 32 initially compilable generated buckets; exclude it from Game/Development/Shipping targets.
- [ ] 6.3 <!-- TDD --> Move StaticJIT generated fixtures/probes out of `AngelscriptTest` into `AngelscriptTestJIT`, and implement the separate `AngelscriptTest`-owned `-run=AngelscriptTestJIT -Mode=Generate|Verify` orchestration using only committed test fixtures and the fixed test output root.
- [ ] 6.4 <!-- TDD --> Replace the legacy local test `.Cache` prerequisite with source compilation plus an isolated Cache V2 root and a second fresh `asIScriptEngine` restoration path.
- [ ] 6.5 <!-- TDD --> Add source-engine, Cache-V2-engine, mismatch, multi-engine, provider-refresh, UASFunction, test-plus-project-Provider coexistence, and owner-scoped unregister tests with detailed ProviderId/generation/module/key/binding/reference/route logs.
- [ ] 6.6 <!-- Non-TDD --> Update the StaticJIT AOT runner to execute baseline Editor build, `-run=AngelscriptTestJIT -Mode=Generate`, rebuild, test Verify, and focused tests in a reproducible order without invoking project Scaffold/source discovery.

## 7. Scaffold And Validate The Host Project JIT Module

- [ ] 7.1 <!-- TDD --> Run commandlet service tests against an isolated project descriptor and prove scaffold does not overwrite user-owned Build.cs, module source, or descriptor edits.
- [ ] 7.2 <!-- Non-TDD --> Scaffold and commit the host `Source/AngelscriptJIT` module plus its `.uproject` Runtime/PostDefault registration as the real-project proof.
- [ ] 7.3 <!-- Non-TDD --> Perform the required first full Editor and Game build so UBT discovers the new module before any Live Coding refresh is attempted.
- [ ] 7.4 <!-- TDD --> Generate the host project's current AS artifacts for explicit profiles, rebuild them, and prove Verify is clean and a repeated Generate preserves unchanged files byte-for-byte.

## 8. Enable Editor And PIE StaticJIT Routing

- [ ] 8.1 <!-- TDD --> Add Editor/PIE tests proving current AS source compilation remains authoritative, complete exact bindings attach before ClassGenerator consumers run, and one changed function falls back without clearing unrelated bindings.
- [ ] 8.2 <!-- TDD --> Enable multi-provider discovery and engine-local routing in Editor/PIE while keeping incompatible or cross-Provider-ambiguous functions non-fatal, owner-scoped, and visible through typed reasons.
- [ ] 8.3 <!-- TDD --> Add body-only, whitespace/debug-only, signature/metadata, class-layout, inheritance, import, and deleted-function edit scenarios and assert the expected execution-identity and fallback scope.
- [ ] 8.4 <!-- TDD --> Ensure hot reload/class reinstancing continues to own structural class changes while StaticJIT only rebinds functions that exist in the newly authoritative compile generation.
- [ ] 8.5 <!-- Non-TDD --> Remove the blanket Editor StaticJIT exclusion only after focused Editor, PIE, hot-reload, Cache V2, and UASFunction tests pass on the new path.

## 9. Add Explicit Live Coding Refresh

- [ ] 9.1 <!-- TDD --> Add Editor service tests for idle, AS compile errors, unscaffolded module, missing first full build, Live Coding unavailable, compile in progress, compilation failure, patch failure, stale provider generation, valid newer generation, and route-refresh failure.
- [ ] 9.2 <!-- TDD --> Implement an explicit Generate/Refresh StaticJIT Editor action that first compiles authoritative AS source, writes owned generated artifacts, then requests `ILiveCodingModule::Compile()` only for an already build-discovered module.
- [ ] 9.3 <!-- TDD --> On patch completion, validate a strictly newer compatible provider generation before publishing new bindings; retain VM routes and explain failure when generation/ABI/profile/artifact identity is stale.
- [ ] 9.4 <!-- TDD --> Add a deterministic fake patch-generation seam, then document and run a real Editor smoke proving changed function VM-before-patch and Native-after-patch without closing the Editor.
- [ ] 9.5 <!-- Non-TDD --> Keep save-time behavior to invalidation/recompile only; document that automatic C++ generation/Live Coding on every `.as` save is intentionally out of scope.

## 10. Development/Shipping Behavior And Legacy Removal

- [ ] 10.1 <!-- TDD --> Add Development Game and Shipping/provider tests for multiple module load/unload, exact complete artifact-set acceptance, ProviderId conflict rejection, immutable direct-call eligibility, stale-set rejection, VM fallback, and absence of Editor/LiveCoding/test-module dependencies.
- [ ] 10.2 <!-- TDD --> Add package/multi-start tests proving stable provider matching across processes and proving numeric FunctionId, pointer values, and cache creation order do not affect selection.
- [ ] 10.3 <!-- Non-TDD --> Remove `FJITDatabase`, single `FStaticJITCompiledInfo::ActiveInfo`, persisted FunctionId registration, whole-cache `DataGuid` pairing/clearing, and other superseded global path only after source/cache/editor/cooked parity passes.
- [ ] 10.4 <!-- Non-TDD --> Remove obsolete generator/test `.Cache` files, flags, commands, and documentation; do not add compatibility readers or migration branches because the plugin is still in development.

## 11. Diagnostics, Performance, Documentation, And Final Verification

- [ ] 11.1 <!-- TDD --> Extend diagnostics tests for multiple ProviderIds/UE modules/generations, per-Provider AS-module membership, exact conflicts, complete identities, transient FunctionId context, VM/Raw/Parms binding, reference slots, engine routes, mismatch reasons, buckets/slices, execution counters, and deterministic machine-readable dumps.
- [ ] 11.2 <!-- TDD --> Implement read-only diagnostics plus `as.StaticJIT.DumpDiagnostics`, including safe no-engine/no-provider/no-cache cases and no `FAngelscriptEngine::*ForTesting` expansion.
- [ ] 11.3 <!-- Non-TDD --> Add/update a Python dump inspector for the schema-revisioned machine-readable output and test it with checked-in valid, mismatch, and malformed fixtures independently of C++ automation.
- [ ] 11.4 <!-- Non-TDD --> Benchmark provider catalog load, stable-reference resolution, route lookup/refresh, Editor VM fallback, Cache V2 restore plus JIT bind, 32-bucket incremental rebuild scope, and immutable cooked direct calls; store raw data under this change's `benchmarks/` attachment.
- [ ] 11.5 <!-- Non-TDD --> Update Chinese JIT lifecycle/module-generation/Editor/Live Coding/cache-coordination/debugging guidance first, then English README/build/test/package/fork-strategy and AGENTS architecture facts.
- [ ] 11.6 <!-- Non-TDD --> Run native SDK lifecycle tests, Runtime/Cache V2 tests, the isolated `AngelscriptTestJIT` workflow, project `AngelscriptJIT` workflow, multi-provider/multi-AS-module tests, StaticJIT/HotReload/UASFunction prefixes, real Editor/PIE smoke, Development and Shipping package/multi-start smoke, configured All suite, strict OpenSpec validation, and `git diff --check`; record exact commands, reports, counts, and limitations before completion.
