> Implementation status (2026-08-13): the user explicitly authorized implementation in the current main checkout. Keep this checklist synchronized with verified milestones and put detailed evidence or problems in the change attachments.

## 1. Freeze BytecodeJIT Behavior And Extract The Current Generator

- [x] 1.1 <!-- Non-TDD --> Confirm `refactor-as-static-jit-multi-provider` has complete Binding publication, stable references/routes/readers, and safe per-Provider generation publication/retirement; record the exact prerequisite plugin/parent commits or dirty-workspace baseline in `implementation-plan.md`.
- [x] 1.2 <!-- TDD --> Extend the current deterministic StaticJIT fixture so generation request fields, emitted implementation text, references, symbols, per-module files, Provider manifest, and owned-file inventory are captured before structural edits.
- [x] 1.3 <!-- TDD --> Add a class-boundary characterization proving the existing generation entry points use one bytecode generator and retain current cross-function/two-pass analysis and one-module-one-TU behavior.
- [x] 1.4 <!-- TDD --> Create `StaticJIT/BytecodeJIT/FAngelscriptBytecodeJIT` and move the bytecode analyzer, `FStaticJITContext`, opcode handlers, bind lowering, reference analysis, and body/entry emission together without formatting or behavior changes.
- [x] 1.5 <!-- TDD --> Keep `FAngelscriptStaticJIT` as a temporary delegating lifecycle facade and prove all pre-extraction golden/determinism tests remain byte-for-byte equal.

## 2. Define The Internal Static Backend Contract

- [x] 2.1 <!-- TDD --> Add failing value/validation tests for `FAngelscriptStaticJITBackendId`, including exact `"bytecode"`/`"typed-ast"` spelling, empty/unknown values, duplicate factories, and type separation from Runtime BackendId.
- [x] 2.2 <!-- TDD --> Define private per-task `IAngelscriptStaticJITBackend`, immutable task-wide request/view with separate complete `CompiledSourceGraph` and `EmitModuleSet`, emitted-function result, typed per-function disposition, and factory contract with no exported third-party ABI.
- [x] 2.3 <!-- TDD --> Implement `FAngelscriptStaticJITGenerator` with deterministic factory lookup, one backend instance per task, no retained Engine-local pointers, and backend-neutral handoff to `FAngelscriptJITGeneration`.
- [x] 2.4 <!-- TDD --> Register BytecodeJIT as `"bytecode"`; preserve existing `GenerateStaticJITProviderArtifacts(...)` overloads as bytecode-default facades and add an explicit backend/capture generation request for programmatic callers.
- [x] 2.5 <!-- TDD --> Add fake Static backends proving task-wide analysis, per-function TypedASTJIT-to-BytecodeJIT-to-VM fallback, fatal task errors, mixed-backend functions in one module TU, and backend provenance outside Provider identity.

## 3. Add A Side-Effect-Free StaticJIT Generation Engine

- [x] 3.1 <!-- TDD --> Add failing generation tests with unique UCLASS/USTRUCT/delegate/UFUNCTION names proving complete descriptor/Entry-Plan information is produced while no script reflection object, CDO, reload/reinstancing event, class redirect, or current Editor route is created.
- [x] 3.2 <!-- TDD --> Add two-simultaneous-Engine tests proving complete Bind replay per target profile, Engine-local raw type/function identity, equal normalized stable identities, and independent teardown.
- [x] 3.3 <!-- TDD --> Add `EAngelscriptEnginePurpose::StaticJITGeneration` to `FAngelscriptEngineConfig`, keep ordinary Runtime/Editor initialization as the default purpose, and route project/test generation through the explicit purpose without accumulating unrelated generation booleans.
- [x] 3.4 <!-- TDD --> Factor ClassGenerator descriptor analysis from reload planning/materialization so generation resolves script functions, receivers, UFUNCTION roots, signatures, and Entry Plans without calling Soft/Full Reload or creating UObjects.
- [x] 3.5 <!-- TDD --> Publish a generation-local complete compiled module/function/type/global/descriptor/dependency view plus a separate `EmitModuleSet`, freeze the backend-neutral generation view while the temporary Engine is alive, and reject pointer/ID retention in backend output.
- [x] 3.6 <!-- TDD --> Compile the complete Provider source graph for the selected target profile but emit only the requested module set; keep project and plugin Provider source domains separate.

## 4. Define The Backend-Neutral Runtime JIT Contract

- [x] 4.1 <!-- TDD --> Add failing ABI/layout tests for Runtime BackendId, factory metadata, compile snapshot headers, typed outcomes, and code-lease ownership, including invalid size/revision/count/pointer/platform cases.
- [x] 4.2 <!-- TDD --> Add a fake Runtime factory/session that can succeed, block, cancel, fail, report unsupported, return stale revisions, and expose code-lifetime counters without MIR or LLVM.
- [x] 4.3 <!-- TDD --> Implement `FAngelscriptRuntimeJITBackendId`, current factory ABI metadata, modular-feature discovery, deterministic duplicate rejection, and copied validated factory snapshots.
- [x] 4.4 <!-- TDD --> Implement one selected Runtime backend session per AngelScript Engine, including serialized/concurrent capability handling and teardown ordering.
- [x] 4.5 <!-- TDD --> Define supported/unsupported/failure/cancel/stale outcomes and stable diagnostic reasons without exposing concrete backend types in `AngelscriptRuntime`.
- [x] 4.6 <!-- TDD --> Implement `FAngelscriptRuntimeJITCodeLease` and prove unpublished, replaced, active, and teardown resources release exactly once.

## 5. Build Runtime Snapshots And The Request State Machine

- [x] 5.1 <!-- TDD --> Add snapshot tests for stable identity/revision, target/Entry ABI, scalar frame layout, normalized invocation/receiver/profile, copied bytecode, instruction/control-flow validation, and ordered helper/reference tokens.
- [x] 5.2 <!-- TDD --> Implement Engine-thread snapshot capture with no worker-visible `asIScriptFunction`, module, UObject, UFunction pointer, raw fork trait bits, source AST, or typed HIR.
- [x] 5.3 <!-- TDD --> Add malformed-bytecode, invalid-control-flow, wrong-stack-layout, unknown-profile, external-implicit-this, and ABI-mismatch cases that fail closed before concrete backend invocation.
- [x] 5.4 <!-- TDD --> Prove immediate module discard after queueing cannot make a background backend dereference released Engine data.
- [x] 5.5 <!-- TDD --> Add Engine-local revision state, selected backend/configuration generation, request coalescing, terminal-unsupported memoization, and retry rules.
- [x] 5.6 <!-- TDD --> Implement `EagerSync`, `EagerBackground`, and `LazyFirstCall` through one publication state machine, including concurrent claim, VM-while-pending, cancellation, and exception-safe resource release.
- [x] 5.7 <!-- TDD --> Add Hot Reload/module-replacement tests proving stale results never attach to replacement functions.

## 6. Move Compiler Ownership To The Coordinator

- [x] 6.1 <!-- TDD --> Add lifecycle tests that fail if a Runtime plugin/factory installs or replaces `asIJITCompiler`, or if one Engine owns more than one coordinator.
- [x] 6.2 <!-- TDD --> Introduce `FAngelscriptJITCoordinator` and move function-ready/release callbacks from the temporary `FAngelscriptStaticJIT` facade without changing maintained-fork Binding lifecycle.
- [x] 6.3 <!-- TDD --> Remove the old class facade after Coordinator ownership is proven; retain BytecodeJIT and generation compatibility functions under the Static generator.
- [x] 6.4 <!-- TDD --> Implement `Auto`, `VMOnly`, `StaticAOTOnly`, and `RuntimeOnly` with exact AOT-before-Runtime ordering in Auto and deterministic invalid-configuration behavior.
- [x] 6.5 <!-- TDD --> Publish Runtime VMEntry-only Bindings through current immutable routes and prove two Engines selecting the same Runtime backend have isolated sessions, requests, helpers, routes, and teardown.

## 7. Enforce Lifetime, Host And Dispatch Boundaries

- [x] 7.1 <!-- TDD --> Add replacement/plugin-unload tests where active calls finish on old code while new calls use replacement Runtime, AOT, or VM routes.
- [x] 7.2 <!-- TDD --> Prove Runtime results never enter the AOT provider registry, Static generation, Cache V2, precompiled data, another Engine, or typed-HIR storage.
- [x] 7.3 <!-- TDD --> Add whole-function Runtime eligibility/fallback tests for unsupported calls, managed values, receiver profiles, suspend/latent behavior, cleanup/exception state, and Entry ABI mismatch.
- [x] 7.4 <!-- TDD --> Add DebugServer/CodeCoverage gates and UASFunction coverage proving a Runtime VMEntry does not fabricate Raw/Parms entries and reflected execution remains VM-correct.
- [x] 7.5 <!-- Non-TDD --> Enforce that Runtime backend worker/lowering headers include no UObject, UFunction, Blueprint, ClassGenerator, World, GC, Editor, typed-HIR, or Static backend APIs.

## 8. Add Diagnostics, Documentation And Verification

- [x] 8.1 <!-- TDD --> Extend non-Shipping diagnostics with requested/actual Static BackendId, capture profile, Static fallback chain, execution mode, Runtime backend/policy, factory/session availability, actual tier, request/result state, latency, code size, and code-lease counts.
- [x] 8.2 <!-- TDD --> Preserve `as.StaticJIT.DumpDiagnostics` AOT behavior, add generic coordinator diagnostics, and extend state snapshots only through public observer surfaces.
- [x] 8.3 <!-- TDD --> Add compile/execution markers consumable by BytecodeJIT, TypedASTJIT, and Runtime backend tests without public AngelScript test hooks.
- [x] 8.4 <!-- Non-TDD --> Update Chinese StaticJIT/compiler/runtime architecture first, then English consumer guidance, with the independent Static/Runtime contracts, generation-only Engine, backend IDs, fallbacks, and five execution paths.
- [x] 8.5 <!-- Non-TDD --> Run strict OpenSpec validation, the canonical build, focused StaticJIT/RuntimeJIT/Native compiler prefixes, Standalone, and the configured All suite; record exact current results and dirty submodule/parent gitlink state.
- [x] 8.6 <!-- Non-TDD --> Freeze the Runtime ABI revision and fake-backend conformance harness consumed by the MIR/LLVM plugin changes; hand the Static contract to `feature-as-typed-semantic-aot` after groups 1-3 pass.
