# Implementation Tasks

This checklist is the live implementation record. Checked tasks have source or research evidence recorded in `verification.md`; unchecked tasks remain future work even when a later design section mentions them. The plan is intentionally revisable: implementation discoveries may rewrite `design.md`, `implementation-plan.md`, and this checklist. Incremental investigations, failed approaches, migration samples, performance data, and long logs belong under `attachments/` or another focused change attachment; keep this file as a clean acceptance checklist and explain any reopened/superseded evidence in `verification.md`.

## 1. Freeze The Unified AngelScript JIT Lifecycle

- [x] 1.1 <!-- Non-TDD --> Reconfirm the local 2.38 lifecycle evidence (`NewFunction`, delayed `SetJITFunction`, `CleanFunction`, interface-version property) and record any fork drift discovered immediately before implementation.
- [x] 1.2 <!-- TDD --> Add native SDK tests that fail until one non-versioned `asIJITCompiler` lifecycle can publish and retrieve a complete VM/Raw/Parms/UserData binding after compilation.
- [x] 1.3 <!-- TDD --> Add lifecycle tests for replacement, explicit clear, function destruction, module discard, compiler replacement, compiler removal, re-entrant execution, and exactly-once release.
- [x] 1.4 <!-- TDD --> Replace the fork's current compile/release callbacks and separate public JIT pointer ownership with the unified delayed binding API; remove JIT interface version selection rather than retaining v1/v2 adapters.
- [x] 1.5 <!-- TDD --> Make `asCScriptFunction` own safe binding replacement/retirement and ensure every destruction/rollback path releases the complete binding exactly once.
- [x] 1.6 <!-- TDD --> Refactor `FStaticJITGenerator` into an observer/generation consumer of compiled functions so generation never swaps the live engine's execution compiler.
- [x] 1.7 <!-- Non-TDD --> Update vendored interface documentation and fork-difference notes to explain the maintained-fork-owned lifecycle and the intentional incompatibility with both old fork and upstream version-switching APIs.

## 2. Neutralize Stable Artifact Identity And Route Ownership

- [x] 2.1 <!-- Non-TDD --> Reconfirm the stable function/type/module identity and execution/debug/profile/environment hashes delivered by `refactor-as-incremental-function-cache`; consume identity contracts without depending on Cache V2 storage internals.
- [x] 2.2 <!-- TDD --> Add compile-time layout and behavioral tests for neutral artifact reference descriptors, immutable route values, route generations, and typed mismatch results used by both Cache V2 and StaticJIT.
- [x] 2.3 <!-- TDD --> Move/rename reusable `FAngelscriptCache*Route*` and reference-value concepts into neutral Runtime artifact types without changing Cache V2 behavior.
- [x] 2.4 <!-- TDD --> Update Cache V2 to use the neutral types and prove source compile, incremental hit/miss, dependency invalidation, and fresh-engine restoration remain unchanged.
- [x] 2.5 <!-- TDD --> Add two-engine tests proving stable identity equality despite reordered/reused FunctionIds and proving route/function/reference state remains engine-local.

## 3. Define The Current Provider ABI And Stable Reference Slots

- [x] 3.1 <!-- TDD --> Add ABI/layout tests for `FAngelscriptJITProviderId`, `FAngelscriptJITProviderGeneration`, `FAngelscriptJITEntryPoints`, `FAngelscriptJITReferenceSlot`, `FAngelscriptJITArtifactEntry`, `FAngelscriptJITProviderView`, and `IAngelscriptJITArtifactProvider` including invalid sizes/counts/pointers/order and multi-AS-module entry ownership.
- [x] 3.2 <!-- TDD --> Implement one current provider ABI revision and a Runtime multi-provider Registry with copied/validated catalogs, owner-scoped registration/unregistration, deterministic enumeration, and no legacy provider adapter.
- [x] 3.3 <!-- TDD --> Add provider-match matrix tests for stable module/function key, execution content, profile, environment, ABI, entry-point completeness, reference descriptor, duplicate entry, artifact-set mismatch, and different-Provider exact ambiguity.
- [x] 3.4 <!-- TDD --> Implement stable reference descriptors for function/type/global/string/import/runtime-helper references and resolve them into engine-local immutable slots during route construction.
- [x] 3.5 <!-- TDD --> Add reference-slot tests for missing/ambiguous/wrong-kind targets, reordered engine objects, provider refresh, module discard, and two-engine isolation.
- [x] 3.6 <!-- TDD --> Implement safe per-ProviderId generation publication and retirement so one provider module unload/Live Coding replacement cannot invalidate in-flight bindings, reference slots, or unrelated Providers.
- [x] 3.7 <!-- TDD --> Route VM, Raw, and Parms generated entries through `FScriptExecution` and the complete AS binding without relying on a process-global current Engine or provider-owned memory.
- [x] 3.8 <!-- TDD --> Add concurrent `AngelscriptTestJIT`/project/plugin Provider tests, one-Provider-multiple-AS-module tests, ProviderId conflict/recovery tests, and two-engine isolation tests proving selection never depends on registration or UE module load order.
- [x] 3.9 <!-- TDD --> Remove generated bucket/translation-unit topology from `FAngelscriptJITProviderView`, bump the current Provider ABI revision for the layout change, and update Runtime validation, generator emit, diagnostics, and ABI/layout tests without an old-revision adapter.

## 4. Route Current Script And UASFunction Calls

- [x] 4.1 <!-- TDD --> Add script-to-script parity tests for Native hit, VM miss, changed callee body, refreshed Native hit, exceptions, references, object lifetime, recursion, imports, and current virtual override.
- [x] 4.2 <!-- TDD --> Implement reloadable-profile call sites so they resolve the current callee and current immutable binding/route rather than embedding a content-specific Native pointer.
- [x] 4.3 <!-- TDD --> Add `UASFunction` matrix tests for specialized/generic, no-param, primitive/reference/object return, static, virtual, thread-safe, world-context, and reflected Parms dispatch.
- [x] 4.4 <!-- TDD --> Make Editor/PIE `UASFunction` wrappers read the current ScriptFunction/binding and prove one changed method cannot retain its prior VM/Raw/Parms entry while unchanged methods remain Native.
- [x] 4.5 <!-- TDD --> Add safe-publication tests where re-entrant and thread-safe calls overlap script/provider replacement, then implement binding snapshot retention until the last active reader exits.
- [x] 4.6 <!-- TDD --> Limit direct content-specific calls to completely validated immutable cooked artifact sets and fail closed to current VM dispatch on any incomplete set.

## 5. Build The Shared Generator And Project Module Tooling

The previously completed per-function-slice/32-bucket form of 5.1, 5.2, 5.3, 5.5, and 5.6 was superseded by the approved strict per-AS-module `.jit.cpp` decision. Its evidence remains in `verification.md` as historical implementation evidence, but these tasks are reopened against the current design.

- [x] 5.1 <!-- TDD --> Replace generator goldens with strict per-AS-module cases proving one module with many functions emits one stable source-relative `<SourceStem>.<ShortStableModuleKey>.<TargetProfile>.jit.cpp`, several modules emit one file each, functions sort by full key, symbols remain content-addressed, reference/entry metadata is deterministic, body changes retain the module path, unrelated module bytes/timestamps remain unchanged, and no function slice or bucket is emitted.
- [x] 5.2 <!-- TDD --> Refactor shared StaticJIT emission and output metadata to group functions by StableModuleKey and generate one real source-relative profile `.jit.cpp` per non-empty AS module plus explicit generated-module records, provider metadata, and owned-file inventory; keep ownership revision 2, bump readable manifest schema to 3, remove slice paths/bucket assignment/fixed-bucket output, and remove the superseded generators/tests.
- [x] 5.3 <!-- TDD --> Update profile tests for `EditorDevelopment`, `GameDevelopment`, and `GameShipping`, proving independent per-profile module sources, correct compile guards, isolated output identity, and rejection across profile/environment/ABI boundaries.
- [x] 5.4 <!-- TDD --> Implement shared Runtime emission/comparison primitives plus separate Editor project orchestration with versioned owned-file markers, atomic replacement, unchanged-byte preservation, user-file conflict refusal, deterministic temporary-root verification, and stale-output diagnostics.
- [x] 5.5 <!-- TDD --> Refactor fixed `AngelscriptJIT` scaffold/path tests for Runtime/PostDefault `.uproject` registration, Runtime dependency, target discovery, reserved-name conflict refusal, project-domain-derived ProviderId, a bucket-free stable module shell, per-AS-module generated source ownership, and idempotent reruns.
- [x] 5.6 <!-- TDD --> Adapt the `AngelscriptEditor`-owned project `-run=AngelscriptJIT -Mode=Scaffold|Generate|Verify` commandlet to real per-profile module `.jit.cpp` output, keep project orchestration out of Runtime/test modules, and report whether the generated UBT source-file set changed and therefore requires a normal full build.
- [x] 5.7 <!-- TDD --> Make Verify read-only and report provider/profile/ABI, StableModuleKey, module source, affected stable function keys, symbols, and every unexpected/missing/mismatched owned-file difference with a non-zero commandlet result.

## 6. Establish The Editor-Only AngelscriptTestJIT Proof Module

- [x] 6.1 <!-- TDD --> Add build/ownership tests that fail until `AngelscriptTestJIT` is an Editor-only fixed plugin-test carrier with dependency chain `AngelscriptRuntime <- AngelscriptTestJIT <- AngelscriptTest`, a stable test ProviderId, and no project name/source/settings/scaffold/descriptor/output dependency.
- [x] 6.2 <!-- Non-TDD --> Create the bucket-free `AngelscriptTestJIT` module shell with a null/current generated-provider selector, then commit exactly one generated `.jit.cpp` per non-empty fixture AS module; exclude the entire module from non-Editor targets.
- [x] 6.3 <!-- TDD --> Move StaticJIT generated fixtures/probes out of `AngelscriptTest` into `AngelscriptTestJIT`, and implement the separate `AngelscriptTest`-owned `-run=AngelscriptTestJIT -Mode=Generate|Verify` orchestration using only committed test fixtures and the fixed test output root.
- [x] 6.4 <!-- TDD --> Replace the legacy local test `.Cache` prerequisite with source compilation plus an isolated Cache V2 root and a second fresh `asIScriptEngine` restoration path.
- [x] 6.5 <!-- TDD --> Add source-engine, Cache-V2-engine, mismatch, multi-engine, provider-refresh, UASFunction, test-plus-project-Provider coexistence, and owner-scoped unregister tests with detailed ProviderId/generation/module/key/binding/reference/route logs.
- [x] 6.6 <!-- Non-TDD --> Update the StaticJIT AOT runner to execute baseline Editor build, `-run=AngelscriptTestJIT -Mode=Generate`, rebuild, test Verify, and focused tests in a reproducible order without invoking project Scaffold/source discovery.

## 7. Scaffold And Validate The Host Project JIT Module

- [x] 7.1 <!-- TDD --> Run commandlet service tests against an isolated project descriptor and prove scaffold does not overwrite user-owned Build.cs, module source, or descriptor edits.
- [x] 7.2 <!-- Non-TDD --> Scaffold and commit the host `Source/AngelscriptJIT` module plus its `.uproject` Runtime/PostDefault registration as the real-project proof.
- [x] 7.3 <!-- Non-TDD --> Perform the required first full Editor and Game build so UBT discovers the new module before any Live Coding refresh is attempted.
- [x] 7.4 <!-- TDD --> Generate the host project's current AS artifacts for explicit profiles, rebuild them, and prove Verify is clean and a repeated Generate preserves unchanged files byte-for-byte.

## 8. Enable Editor And PIE StaticJIT Routing

- [x] 8.1 <!-- TDD --> Add Editor/PIE tests proving current AS source compilation remains authoritative, ClassGenerator/hot reload first accepts the new structural generation, complete exact bindings attach before post-compile and reflected-dispatch consumers run, and one changed function falls back without clearing unrelated bindings.
- [x] 8.2 <!-- TDD --> Enable multi-provider discovery and engine-local routing in Editor/PIE while keeping incompatible or cross-Provider-ambiguous functions non-fatal, owner-scoped, and visible through typed reasons.
- [x] 8.3 <!-- TDD --> Add body-only, whitespace/debug-only, signature/metadata, class-layout, inheritance, import, and deleted-function edit scenarios and assert the expected execution-identity and fallback scope.
- [x] 8.4 <!-- TDD --> Ensure hot reload/class reinstancing continues to own structural class changes while StaticJIT only rebinds functions that exist in the newly authoritative compile generation.
- [x] 8.5 <!-- Non-TDD --> Audit the old development-mode `FJITDatabase` guard after focused Editor, PIE, hot-reload, Cache V2, and UASFunction tests pass: prove it excludes only the superseded FunctionId path while the Provider route remains enabled, retain the guard until task 10.3 deletes the legacy path, and do not re-enable legacy FunctionId attachment in Editor.

## 9. Add Explicit Live Coding Refresh

- [x] 9.1 <!-- TDD --> Add Editor service tests for idle, AS compile errors, unscaffolded module, missing first full build, added/removed AS-module source set, Live Coding unavailable, compile in progress, compilation failure, patch failure, stale provider generation, valid newer generation, and route-refresh failure.
- [x] 9.2 <!-- TDD --> Implement an explicit Generate/Refresh StaticJIT Editor action that first compiles authoritative AS source and writes owned generated artifacts, requests `ILiveCodingModule::Compile()` only when every generated `.jit.cpp` path already belongs to the active target, and otherwise requires a normal full build while retaining VM correctness.
- [x] 9.3 <!-- TDD --> On patch completion, validate a strictly newer compatible provider generation before publishing new bindings; retain VM routes and explain failure when generation/ABI/profile/artifact identity is stale.
- [x] 9.4 <!-- TDD --> Add a deterministic fake patch-generation seam, then document and run a real Editor smoke proving changed function VM-before-patch and Native-after-patch without closing the Editor.
- [x] 9.5 <!-- Non-TDD --> Keep save-time behavior to invalidation/recompile only; document that automatic C++ generation/Live Coding on every `.as` save is intentionally out of scope.

## 10. Development/Shipping Behavior And Legacy Removal

- [x] 10.1 <!-- TDD --> Add Development Game and Shipping/provider tests for multiple module load/unload, exact complete artifact-set acceptance, ProviderId conflict rejection, immutable direct-call eligibility, stale-set rejection, VM fallback, and absence of Editor/LiveCoding/test-module dependencies.
- [x] 10.2 <!-- TDD --> Add package/multi-start tests proving stable provider matching across processes and proving numeric FunctionId, pointer values, and cache creation order do not affect selection.
- [x] 10.3 <!-- Non-TDD --> Remove `FJITDatabase`, single `FStaticJITCompiledInfo::ActiveInfo`, persisted FunctionId registration, whole-cache `DataGuid` pairing/clearing, and other superseded global path only after source/cache/editor/cooked parity passes.
- [x] 10.4 <!-- Non-TDD --> Remove obsolete generator/test `.Cache` files, flags, commands, and documentation; do not add compatibility readers or migration branches because the plugin is still in development.

## 11. Diagnostics, Performance, Documentation, And Final Verification

- [x] 11.1 <!-- TDD --> Extend diagnostics tests for multiple ProviderIds/UE modules/generations, per-Provider AS-module membership, exact conflicts, complete identities, transient FunctionId context, VM/Raw/Parms binding, reference slots, engine routes, mismatch reasons, StableModuleKey/generated-module-source ownership, execution counters, and deterministic machine-readable dumps.
- [x] 11.2 <!-- TDD --> Implement read-only diagnostics plus `as.StaticJIT.DumpDiagnostics`, including safe no-engine/no-provider/no-cache cases and no `FAngelscriptEngine::*ForTesting` expansion.
- [x] 11.3 <!-- Non-TDD --> Add/update a Python dump inspector for the schema-revisioned machine-readable output and test it with checked-in valid, mismatch, and malformed fixtures independently of C++ automation.
- [x] 11.4 <!-- Non-TDD --> Benchmark provider catalog load, stable-reference resolution, route lookup/refresh, Editor VM fallback, Cache V2 restore plus JIT bind, generated file count, unchanged-module preservation, and representative/largest per-AS-module `.jit.cpp` rebuild scope; audit packaged immutable direct-call status, record that production direct emission remains disabled, and store raw data under this change's `benchmarks/` attachment.
- [x] 11.5 <!-- Non-TDD --> Update Chinese JIT lifecycle/module-generation/Editor/Live Coding/cache-coordination/debugging guidance first, then English README/build/test/package/fork-strategy and AGENTS architecture facts.
- [x] 11.6 <!-- Non-TDD --> Run the complete impact-focused final matrix: native SDK lifecycle, Runtime/Cache V2, isolated `AngelscriptTestJIT`, project `AngelscriptJIT`, multi-provider/multi-AS-module, StaticJIT/HotReload/UASFunction, real Editor/PIE/Live Coding, and Development/Shipping package/multi-start smoke; then run strict OpenSpec validation and targeted parent/plugin `git diff --check`. Treat configured `All` as an optional diagnostic rather than a completion gate, and record any partial run, unrelated failure, exact reports/counts, and measurement limitations.

## 12. Make Generated Module Sources Readable Without Weakening Identity

- [x] 12.1 <!-- TDD --> Replace `Profiles/<Profile>/Modules/<full-key>.<Profile>.jit.cpp` expectations with direct profile/source-relative paths and `<SourceStem>.<short-key>.<Profile>.jit.cpp`, including deterministic 8/12/16-character collision extension across case-insensitive UBT basenames.
- [x] 12.2 <!-- TDD --> Add deterministic module/function metadata blocks and immediate Raw/VM/Parms comments that identify the canonical AS declaration and virtual source location while retaining complete internal `ASJIT_<FunctionKey>_<ExecutionHash>` symbols.
- [x] 12.3 <!-- TDD --> Carry virtual module paths and canonical function declaration/source coordinates from real compiled modules, using the preprocessor class declaration line for compiler-synthesized class functions whose AngelScript `declaredAt` remains zero.
- [x] 12.4 <!-- TDD --> Bump manifest schema to 3, retain ownership revision 2 and Provider ABI 2, make Verify reports readable, and update inspectors/package smoke validation.
- [x] 12.5 <!-- TDD --> Implement read-only legacy `Generated/Profiles` detection and Generate-only revision-2 inventory migration that preserves invalid/user-owned paths, retires only inventory-listed files, removes only empty wrappers, and requires a normal build instead of Live Coding.
- [x] 12.6 <!-- Non-TDD --> Regenerate `AngelscriptTestJIT` and all three project profiles, compile the new source set, update current OpenSpec/docs, and run the focused generation/project/TestJIT/Verify/tooling matrix without the unrelated `All` suite.

## 13. Remove Private Wrappers From Both Generated-Code Carriers

- [x] 13.1 <!-- TDD --> Move project Scaffold/current-output expectations from `Source/AngelscriptJIT/Private` to module-root `AngelscriptJITModule.cpp` plus `Generated`, with ownership-validated migration and preservation of unowned legacy files.
- [x] 13.2 <!-- TDD --> Move fixed `AngelscriptTestJIT` implementation sources, probe header, and generated-output expectations from `Private`/`Public` to the module root plus `Generated`; expose the root header to `AngelscriptTest` only through its private include path while retaining `ANGELSCRIPTTESTJIT_API`.
- [x] 13.3 <!-- TDD --> Update package smoke, diagnostics, documentation, and both legacy-root checks for the no-`Private` contract.
- [x] 13.4 <!-- Non-TDD --> Regenerate both carriers, remove only empty legacy wrappers, run the focused tests and normal Editor build, and record exact evidence without running the unrelated `All` suite.
