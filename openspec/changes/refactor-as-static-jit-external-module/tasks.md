## 1. Shared Identity And Provider ABI

- [ ] 1.1 <!-- Non-TDD --> Confirm the `as-script-artifact-identity` API and golden vectors from `refactor-as-incremental-function-cache` task group 1 before changing provider registration; consume no Cache V2 store/generation API.
- [ ] 1.2 <!-- TDD --> Add provider ABI/layout/version tests for compatible views, truncated/unknown views, invalid counts, full-hash identity, environment/profile mismatch, and display-GUID collision.
- [ ] 1.3 <!-- TDD --> Implement the Runtime public provider interface, copied provider catalog, typed rejection results, and deterministic provider ordering.
- [ ] 1.4 <!-- TDD --> Add per-engine route snapshot tests for exact hit, every typed miss reason, duplicate/stale generations, provider departure, safe publication, and two-engine FunctionId reuse.
- [ ] 1.5 <!-- TDD --> Implement engine-owned route manager/snapshots/handles and attach them at compile safe points without retaining provider-owned views.

## 2. Function-Granular Generation And Routed Calls

- [ ] 2.1 <!-- TDD --> Add generated-output golden tests for full content-addressed symbols, stable slice paths, 32-bucket assignment, sorted aggregators, and unchanged-file preservation.
- [ ] 2.2 <!-- TDD --> Refactor StaticJIT generation to emit per-function slices, provider entries, content-addressed implementation symbols, and fixed-bucket aggregators.
- [ ] 2.3 <!-- TDD --> Add Native-caller/current-callee parity tests for changed body, VM miss, refreshed Native hit, virtual override, arguments/references/returns, exceptions, and object lifetime.
- [ ] 2.4 <!-- TDD --> Implement hot-reloadable route invocation for script-to-script calls and preserve direct calls only for completely validated immutable cooked provider sets.
- [ ] 2.5 <!-- TDD --> Add route snapshot lifetime and thread-safe execution tests and implement safe-point publication/old-snapshot retention.

## 3. Project Module Scaffold, Generate, And Verify

- [ ] 3.1 <!-- TDD --> Add generator tests for project-name normalization, module naming, Runtime/PostDefault `.uproject` registration, Build.cs dependency, exactly 32 buckets, and UBT Game/Editor discovery.
- [ ] 3.2 <!-- TDD --> Implement the shared Scaffold/Generate/Verify service with versioned owned-file markers, atomic writes, idempotency, and user-file conflict refusal.
- [ ] 3.3 <!-- TDD --> Add the `AngelscriptStaticJIT` commandlet modes and deterministic temporary-root Verify comparison with stable-key/content diagnostics.
- [ ] 3.4 <!-- TDD --> Generate and commit the host validation module `AngelscriptProjectAngelscriptStaticJIT`, update `.uproject`, and prove one full Editor/Game build discovers it.
- [ ] 3.5 <!-- TDD --> Convert AOT fixtures/runner to the provider module, per-function slices, fixed buckets, and provider-manifest verification.

## 4. Editor And PIE Routing

- [ ] 4.1 <!-- TDD --> Add Editor/PIE tests proving AS compilation remains authoritative, exact matches attach before ClassGenerator, and one changed function falls back without clearing other routes.
- [ ] 4.2 <!-- TDD --> Enable the new provider route in Editor while keeping the old FunctionId/global database path disabled and structured compilation events read-only.
- [ ] 4.3 <!-- TDD --> Add soft-reload UASFunction matrix failures for specialized/generic/static/virtual/thread-safe shapes and old Raw/Parms/VM pointer retention.
- [ ] 4.4 <!-- TDD --> Implement route-aware hot-reloadable UASFunction selection/dispatch and keep direct pointer wrappers limited to completely matched immutable cooked profiles.

## 5. Explicit Live Coding Refresh

- [ ] 5.1 <!-- TDD --> Add Editor service tests for idle/AS-error/in-progress/scaffold-missing/Live-Coding-unavailable/compile-failed/patch-failed/provider-stale/provider-valid states.
- [ ] 5.2 <!-- TDD --> Implement Generate/Refresh StaticJIT Editor action using the shared generator, `ILiveCodingModule::Compile()`, patch-complete delegate, newer-generation validation, and route refresh.
- [ ] 5.3 <!-- TDD --> Add an integration seam that simulates patch generations and a real Editor verification procedure proving changed function VM-before-patch and Native-after-patch behavior.
- [ ] 5.4 <!-- Non-TDD --> Record the unsupported-platform/full-build path and ensure Runtime/packaged targets have no LiveCoding dependency.

## 6. Diagnostics And Global-State Removal

- [ ] 6.1 <!-- TDD --> Extend StaticJIT diagnostics tests for providers, generations, full/display keys, transient FunctionId context, entry kinds, route state, miss reasons, bucket/slice, and execution counters.
- [ ] 6.2 <!-- TDD --> Implement deterministic diagnostics API and `as.StaticJIT.DumpDiagnostics` output for no-engine/no-provider/match/mismatch cases.
- [ ] 6.3 <!-- TDD --> Prove provider-route parity with the old immutable AOT fixture path, including raw/parms/VM entries and multi-engine behavior.
- [ ] 6.4 <!-- Non-TDD --> Remove `FJITDatabase`, single `FStaticJITCompiledInfo::ActiveInfo`, persisted FunctionId registration, whole-cache `DataGuid` clearing, and blanket Editor JIT skip after parity passes.

## 7. Runtime, Cooked, Documentation, And Final Verification

- [ ] 7.1 <!-- TDD --> Add Development Game and packaged immutable-provider tests for module load, exact set match, direct-call eligibility, stale-set rejection, and VM fallback without Editor/LiveCoding.
- [ ] 7.2 <!-- Non-TDD --> Benchmark Editor route overhead, provider enumeration/refresh, fixed-bucket rebuild scope, VM fallback, and immutable cooked direct calls under `benchmarks/`.
- [ ] 7.3 <!-- Non-TDD --> Update Chinese StaticJIT/module-generation/Editor workflow guidance first, then English README/build/test/package guidance and AGENTS architecture facts.
- [ ] 7.4 <!-- Non-TDD --> Run scaffold Verify, canonical build, StaticJIT AOT runner, StaticJIT/HotReload/UASFunction prefixes, package smoke, configured All suite, strict OpenSpec validation, and `git diff --check`; record exact results.
