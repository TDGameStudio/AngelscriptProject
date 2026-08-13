# Implementation Notes

## 2026-08-13: implementation baseline and BytecodeJIT characterization

- Parent baseline: `58e860ee52eb113f5115dbd4d0adcd2dea33d37f`.
- Plugin baseline: `3d6f231ab0d902e14a4fe944cf2ea9c1191711e7`.
- Both repositories were clean and the parent gitlink already selected the plugin baseline.
- The prerequisite audit found complete Binding publication, stable reference slots, Engine-local routes, retained readers/code-image leases, deterministic generation replacement, and immutable direct-set validation in the plugin baseline.
- `AngelscriptJITGenerationDeterminismTests` now freezes request profile/provider/environment fields, implementation-template bytes, references, symbols, per-module sources, Provider manifest data, and the owned-file inventory before structural extraction.
- Canonical build: `Tools\RunBuild.ps1 -Label bytecode-jit-characterization-green -TimeoutMs 1800000 -NoXGE` — PASS.
- Focused prefix: `Angelscript.TestModule.StaticJIT.Generation.Determinism` — `8/8 PASS` in 55.522 seconds.

### Incidents

- The first launcher invocation used an outer five-second tool timeout. Its child build completed independently and reported the actual compile result in `Saved/Build/bytecode-jit-characterization/...`; subsequent long-running commands use a yielded execution cell with the project runner's own timeout.
- The first characterization compile correctly rejected a direct `FAngelscriptArtifactProfileKey` equality expression in the new test. The test was corrected to compare the canonical `Hash`, matching the production value contract; no product code changed for that failure.
- The first extracted `GeneratedOutput` run was `5/6 PASS`. The new compatibility/direct-BytecodeJIT byte comparison passed, but a later pre-existing assertion required the readable module filename to contain the complete 64-digit ModuleKey. Diagnostic output proved the current intended path contains the shortest unambiguous key prefix (`5e5b02fa` in the reproducer), as already specified by the deterministic path tests and documentation. The stale assertion was narrowed to the stable eight-digit minimum prefix; generated code and path logic were not changed.

## 2026-08-13: Milestone A completed

- `FAngelscriptBytecodeJIT` is a generation-only class and deliberately does not derive from `asIJITCompiler`.
- Bytecode analysis, `FStaticJITContext`, opcode helpers, bind lowering, reference analysis, and emission now live together under `StaticJIT/BytecodeJIT/`.
- `FAngelscriptStaticJIT` is retained only as the temporary Engine lifecycle facade. Its function-ready callback delegates to the bytecode generator while Binding publication and retirement remain in the facade until Coordinator ownership is implemented.
- The real multi-module fixture invokes both `GenerateStaticJITProviderArtifacts(...)` and `FAngelscriptBytecodeJIT::GenerateProviderArtifacts(...)` and compares Provider generation, relative paths, and file contents byte-for-byte. Its existing cross-function/two-pass and one-module-one-TU assertions remain active.
- Canonical build after the complete directory extraction: `Tools\RunBuild.ps1 -Label bytecode-jit-directory-extraction -TimeoutMs 1800000 -NoXGE` — PASS, 88 actions in approximately 89 seconds.
- Focused generated-output prefix: `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.StaticJIT.GeneratedOutput" -Label bytecode-jit-directory-generated-output -TimeoutMs 600000` — `6/6 PASS`, exit code 0, 57.127 seconds.
- Focused determinism prefix: `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.StaticJIT.Generation.Determinism" -Label bytecode-jit-directory-determinism-final -TimeoutMs 600000` — `8/8 PASS`, exit code 0, 52.023 seconds.

### Additional runner note

- An intermediate determinism invocation again used a five-second outer wait and therefore did not finalize its runner metadata, although its report contained `8/8 Success`. The same focused prefix was immediately rerun with a yielded execution cell; the final invocation above closed with process and final exit code 0 and is the verification result used for this milestone.

## 2026-08-13: Milestone B completed

- Added exact, case-sensitive Static BackendIds `bytecode` and `typed-ast`. Empty, unknown, case variants, `typed_ast`, and reserved non-ID `dual` fail validation. Static and future Runtime BackendIds remain distinct C++ types.
- Added the Runtime-module-owned `IAngelscriptStaticJITBackend` task contract. Its synchronous complete graph exposes Engine-local handles only as temporary views; backend results contain stable keys, generated-function values, typed dispositions, diagnostic provenance, and no Engine-local pointer/ID fields.
- `CompiledSourceGraph` and `EmitModuleSet` are separate. Fake-backend coverage proves every backend sees the complete function graph once while packaging publishes only the requested module set.
- `FAngelscriptStaticJITGenerator` performs deterministic ID lookup, creates each participating backend once per task, validates result provenance/duplicates/graph membership, owns TypedAST-to-Bytecode-to-VM fallback, and leaves `FAngelscriptJITGeneration` as the deterministic Provider packager.
- The built-in BytecodeJIT factory is explicitly and idempotently registered from `FAngelscriptRuntimeModule::StartupModule`. The old free-function overloads, direct BytecodeJIT entry, and new explicit BackendId/capture request all traverse the generator.
- The real two-module fixture compares all three bytecode entry paths and proves identical Provider generation, file paths, and bytes. Fake backends cover duplicate factories, task-wide analysis, one instance per task, fatal short-circuit, capture mismatch, active fallback BackendId, per-function Bytecode/VM fallback, mixed backends in one module TU, and ProviderId independence from provenance.
- Canonical build: `Tools\RunBuild.ps1 -Label static-jit-backend-commit-final -TimeoutMs 1800000 -NoXGE` — PASS, 4 actions, 14.201 seconds.
- Focused backend prefix: `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.StaticJIT.Backend" -Label static-jit-backend-commit-final -TimeoutMs 600000` — `7/7 PASS`, exit code 0, 55.806 seconds.
- Focused generated-output prefix: `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.StaticJIT.GeneratedOutput" -Label static-jit-backend-milestone-generated-output-final -TimeoutMs 600000` — `6/6 PASS`, exit code 0, 59.127 seconds.

### Incidents and review corrections

- The first Static BackendId red build failed because the contract header did not yet exist, as intended. The first green compile then exposed two test-only C++ issues: `is_constructible` cannot inspect an incomplete future Runtime BackendId, and a parenthesized default-ID factory declaration was parsed as a function. The type-separation assertion was kept, the invalid factory used brace initialization, and no production behavior was weakened.
- A later single-test invocation passed before its newly edited assertion had been compiled. `RunTests.ps1` runs the existing Editor DLL and does not build source changes. The test module was rebuilt, after which the assertion correctly failed and exposed that a Bytecode fallback backend received the primary `typed-ast` ID. The generator now passes an active per-backend request; a fresh compile and rerun closed the regression.
- Self-review also added deterministic rejection for duplicate function results and, once the generation graph supplies function views, results outside the complete graph. Identical backend preamble fragments are de-duplicated before packaging so mixed backends cannot duplicate the same generated declarations.

## 2026-08-13: Milestone C completed after review

- Added `EAngelscriptEnginePurpose::StaticJITGeneration`; ordinary Runtime/Editor initialization remains the default. Project generation and non-persistent TestJIT generation fixtures now request this purpose explicitly, while Cache V2 restoration fixtures intentionally retain Runtime purpose.
- The generation purpose always compiles source and replays the complete Bind surface for its target Engine, but it skips test discovery, asset/Editor route publication, reload/reinstancing, redirects, and script reflection materialization.
- ClassGenerator now exposes descriptor-only StaticJIT analysis. It resolves class/struct/delegate/function descriptors, receivers, signatures, roots, and Entry Plans without creating UClasses, UStructs, UFunctions, CDOs, or calling Soft/Full Reload.
- Each generation Engine freezes an immutable `FAngelscriptStaticJITGenerationSnapshot` containing modules, functions, types, globals, descriptors, dependencies, external native calls, target-local handles, and stable copied identities. The backend-neutral request receives that complete graph separately from `EmitModuleSet`.
- Stable source-based content identities cover functions that do not have Cache-verified artifact identity/reference data. Raw bytecode remains copied generation input, but is not used as a cross-Engine stable hash because it embeds Engine-local numeric IDs.
- `FAngelscriptStaticJITGenerator` maps the complete snapshot to backend-neutral views. BytecodeJIT receives local compatibility route/publication adapters for verified functions only; nothing is published into the global Engine route authority or persisted Cache.
- `FPrecompiledData::InitFromActiveScript` now resolves the owning `FAngelscriptEngine` from the supplied script Engine rather than the global primary Engine. This removed the last production generation path dependency on `FAngelscriptEngine::Get()`.
- The generation fixture proves two simultaneously live Engines replay Binds independently, use different raw type/function addresses, produce equal normalized stable identities, and survive independent teardown.
- The final two-module fixture freezes 2 modules, 22 functions, 5 types, 3 globals, and 8 descriptors. The backend observes every function in the complete graph, while packaging emits only the selected module from `EmitModuleSet`.
- Project generation runs each selected target profile in its own generation Engine and preserves project/plugin Provider source-domain separation. TestJIT generation uses the same production snapshot path without reading or writing project JIT artifacts.

### TDD and compatibility findings

- The initial RED compile failed on the intentionally missing generation snapshot header. Subsequent failures exposed the required boundary in stages: generation could not depend on mutable global fixtures, Cache eligibility was narrower than the complete generation graph, raw bytecode hashes changed across Engines because of local IDs, and empty route pointers are valid for functions that are intentionally VM-only.
- The first TestJIT `GeneratedOutputVerify` after switching fixture generation to the new purpose found one C++ body difference. The previous ordinary Engine had materialized a UClass in `asCObjectType::UserData`; the generation Engine correctly leaves it null, and BytecodeJIT had incorrectly treated that implementation detail as a raw-script-reference semantic decision.
- BytecodeJIT now asks `IsRawScriptReference(...)` with explicit knowledge that the target Runtime Engine will materialize script reflection. This keeps generation side-effect-free while preserving the existing emitted AddRef/Release behavior. Regeneration then produced zero diff for the committed `.jit.cpp` and `ProviderManifest.generated.json`.
- Documentation named the commandlet after its source filename (`AngelscriptStaticJITAotTest`), but the actual UCLASS is `UAngelscriptTestJITCommandlet`; the executable commandlet name is `AngelscriptTestJIT`. `Documents/Tools/Tool.md` now records the working name.

### Verification evidence

- Canonical build after the complete graph implementation: `Tools\RunBuild.ps1 -Label static-jit-generation-graph-green-1 -TimeoutMs 1800000 -NoXGE` — PASS, 14 actions, 20.50 seconds.
- Incremental graph build: `Tools\RunBuild.ps1 -Label static-jit-generation-graph-green-2 -TimeoutMs 1800000 -NoXGE` — PASS, 4 actions, 9.49 seconds.
- Final output-compatibility build: `Tools\RunBuild.ps1 -Label static-jit-generation-output-compat -TimeoutMs 1800000 -NoXGE` — PASS, 24 actions, 25.86 seconds.
- Generation Engine prefix: label `static-jit-generation-graph-2` — `3/3 PASS`.
- Static backend regression: label `static-jit-generation-backend-regression` — `7/7 PASS`.
- Generated-output regression: label `static-jit-generation-output-regression` — `6/6 PASS`.
- Project-generation regression: label `static-jit-project-generation-regression` — `11/11 PASS`.
- Project commandlet regression: label `static-jit-commandlet-generation-regression` — `6/6 PASS`; the production builder ran three times through generation-only Engines.
- TestJIT commandlet: `Tools\RunCommandlet.ps1 -Commandlet AngelscriptTestJIT -Label staticjit-generation-purpose-compat-refresh -TimeoutMs 600000 -ExtraArgs '-Mode=Generate'` — exit 0, 0 errors, committed generated output unchanged.
- Exact TestJIT output compatibility: `Tools\RunTests.ps1 -TestPrefix 'Angelscript.TestModule.StaticJIT.AOT.FAngelscriptStaticJITAotTests.GeneratedOutputVerify' -Label static-jit-generation-output-compat-verify -TimeoutMs 600000` — `1/1 PASS`, exit code 0, 144.110 seconds.

### Pre-commit review reopened Milestone C

The first implementation passed its focused functional suites and preserved generated bytes, but an independent lifecycle/contract review found that this was not yet sufficient evidence for the side-effect-free and complete-view requirements. Tasks 3.1, 3.2, 3.4, and 3.5 were reopened before commit. The identified gaps are:

- generation initialization overwrites the thread-global AngelScript primary context, while shutdown releases whichever context is currently in that slot rather than one owned by the terminating Engine;
- full initialization registers a raw global on-screen-message delegate without removing it, leaving a dangling callback after a temporary generation Engine dies;
- generation suppresses only compile Begin/End while intermediate global compilation events still escape, producing an externally visible malformed event sequence;
- generation shutdown walks the process-shared AngelScript package and clears reflected structs/delegates/enums, then clears process-wide Blueprint-event and Editor class caches it does not own;
- commandlet-shaped generation can still write the independent legacy `Binds.Cache` because Cache V2 persistence control does not govern bind-database output;
- the backend-neutral descriptor adapter drops kind/name/receiver/UFUNCTION-root and Entry Plan flags; global functions can retain a zero Entry ABI and class methods currently hardcode Parms eligibility;
- Bytecode lowering still has ambient `FAngelscriptEngine::Get()` lookups and the public request path does not establish the graph owner's Engine scope.

A mixed reflected/raw-type TDD probe also demonstrated that a coarse Engine-wide reflection-target flag is too broad. Top-level project classes are implicitly reflected even without an explicit `UCLASS`, so the final contract must carry the reflection decision per type and use a genuinely non-reflected type for the raw reference path.

### Review closure

- Generation initialization no longer installs a process-wide primary context, extension registry attachment, DebugServer, CodeCoverage attachment, test runners, checker thread, or on-screen-message callback. Ordinary Engines retain their existing behavior and now remove their own on-screen delegate during teardown.
- Generation teardown releases a primary context only when that context belongs to the terminating Engine and skips process-shared package reflection cleanup, Blueprint-event cache cleanup, Editor class cache cleanup, coverage/debug/test teardown, and ambient world synchronization.
- A thread-local `FAngelscriptCompilationEventSuppressionScope` suppresses every compilation event for generation work, rather than suppressing only Begin/End and leaking malformed intermediate sequences.
- Generation can read existing Blueprint-event and Editor-class caches to reproduce the initialized Bind surface but cannot append to them. It also cannot write the independent legacy `Binds.Cache`, including commandlet-shaped/forced configurations.
- Frozen functions now carry nonzero stable Entry ABI plus exact VM/Raw/Parms eligibility. Frozen descriptors and backend-neutral descriptor views retain kind, canonical name, receiver, UFUNCTION-root flag, and exact Entry Plan flags. Funcdefs and delegate wrapper types are enumerated explicitly so completeness validation rejects missing stable descriptor facts.
- Target reflection materialization is represented per type. BytecodeJIT raw-reference lowering consumes that set and every generation lowering lookup uses the request Engine instead of ambient `FAngelscriptEngine::Get()` state.
- The two-Engine fixture now compares the process primary context, global on-screen delegate binding, Blueprint-event cache size, compilation event count, stable/raw identities, and independent destruction before and after generation Engines. A stricter snapshot completeness check first exposed a delegate descriptor with no stable identity; delegate signature and stable-key capture were added before the tests could pass.
- The last RED assertion was a test-fixture error: it marked two script classes as target-materialized but inserted only one into BytecodeJIT's target set. Populating the set from the frozen per-type contract made the test exercise the production rule and retained a synthetic non-reflected script object as the positive raw-reference case.

### Post-review verification evidence

- Canonical incremental build: `Tools\RunBuild.ps1 -Label static-jit-generation-review-final -TimeoutMs 1800000 -NoXGE` — PASS, 4 actions, 15.154 seconds.
- Generation Engine lifecycle/descriptor prefix: `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.StaticJIT.ProjectGeneration.Engine" -Label static-jit-generation-engine-review-final -TimeoutMs 900000` — `3/3 PASS`, exit code 0, 71.010 seconds.
- Static backend contract prefix: `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.StaticJIT.Backend" -Label static-jit-generation-backend-review -TimeoutMs 600000` — `7/7 PASS`, exit code 0, 61.440 seconds.
- Generated-output prefix: `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.StaticJIT.GeneratedOutput" -Label static-jit-generation-output-review -TimeoutMs 600000` — `6/6 PASS`, exit code 0, 69.385 seconds.
- `openspec validate refactor-as-unified-jit-coordinator --strict` — PASS after the milestone record was synchronized.
- Independent post-fix review — `READY TO COMMIT`; all seven reopened lifecycle/contract findings were verified closed, with no new Critical, Important, or Minor concrete issue.
- Plugin milestone commit: `56c51fb [StaticJIT] Feat: isolate generation engine snapshots`.

## 2026-08-13: Runtime JIT backend contract completed

- Added the exported current-revision `JIT/AngelscriptRuntimeJITBackend.h` contract. Runtime BackendId uses fixed 64-byte lowercase ASCII storage and is intentionally type-distinct from Static BackendId.
- Factory metadata reports copied stable ID/display name, supported platform/configuration masks, ABI revision, and serialized/concurrent per-session capability. Modular Feature discovery validates metadata before selection, rejects duplicate IDs deterministically, and never retains the factory's transient metadata strings.
- The compile snapshot ABI already reserves the complete first-slice boundary: stable module/function/revision/Entry ABI, Engine namespace, target shape, normalized invocation/receiver/profile, bytecode, scalar frame values, verified instruction/control-flow tables, and ordered helper tokens. Group 5 will implement authoritative Engine-thread capture and deeper structural validation against this current-revision view.
- One `FAngelscriptRuntimeJITBackendSessionOwner` wraps one selected session for one Engine namespace. It rejects cross-Engine or malformed snapshots before backend invocation and honors `SerializedPerSession` versus `ConcurrentPerSession` with an owner-side lock.
- Compile results use explicit `Compiled`, `Unsupported`, `Cancelled`, `Stale`, `BackendFailure`, and `InvalidInput` outcomes plus stable diagnostic reasons. A compiled result requires a matching revision/Entry ABI, one VMEntry, nonzero code size, and a valid code lease; non-compiled results cannot smuggle executable entries or leases.
- `FAngelscriptRuntimeJITCodeLease` adopts a validated release callback into a thread-safe shared owner. Unpublished results, replacements, active readers, and future-held results release the backend resource exactly once when their final reference exits.

### TDD and compatibility findings

- The intended RED build failed first on the absent `JIT/AngelscriptRuntimeJITBackend.h`. Adding a new test directory also changed unity shard composition and exposed an existing hidden include dependency: `AngelscriptJITExecutionContextTests.cpp` used `ASTEST_AS_ANSI` without directly including `Shared/AngelscriptTestMacros.h`. The direct include was added; no test behavior changed.
- The first focused run was `5/6`; the fake session snapshot carried Engine namespace `17` while the owner was created for `71`. Production correctly returned `InvalidInput` before invoking the backend. The fixture now explicitly aligns its namespace and retains a separate invalid-bytecode assertion.
- The first concurrency/lifetime extension was `6/7`; a `TFuture` still retained each returned shared code lease after the local result reset, so the expected release count remained zero. Moving futures into a nested scope proved the intended active-reader lifetime: resources stay live while the future retains them and release exactly once after the final owner exits.
- A blocking fake compile with two worker calls observes maximum concurrency `1` for serialized sessions and at least `2` for concurrent sessions. No concrete MIR or LLVM backend participates.
- Independent review then tightened five fail-closed boundaries before commit: typed outcome/reason/bytecode-offset compatibility; exact session BackendId/Engine/platform/configuration matching; per-element `StructSize` validation with element indices; duplicate-ID detection before unique-candidate metadata validation; and cancellation that remains callable while a serialized compile holds the compile-only mutex. Dedicated malformed-result, wrong-target, malformed-element, valid-plus-invalid duplicate, and blocking-compile cancellation regressions cover each finding.

### Verification evidence

- Initial full unity rebuild after adding RuntimeJIT directories: `Tools\RunBuild.ps1 -Label runtime-jit-contract-green-1 -TimeoutMs 1800000 -NoXGE` — PASS, 173 actions, 127.522 seconds.
- Final incremental build: `Tools\RunBuild.ps1 -Label runtime-jit-contract-final -TimeoutMs 1800000 -NoXGE` — PASS, 4 actions, 13.81 seconds.
- Pre-review Runtime contract prefix: `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.RuntimeJIT.Coordinator.Contract" -Label runtime-jit-contract-final -TimeoutMs 900000` — `7/7 PASS`, exit code 0, 52.289 seconds.
- Post-review incremental build: `Tools\RunBuild.ps1 -Label runtime-jit-contract-review-green -TimeoutMs 1800000 -NoXGE` — PASS, 8 actions, 13.82 seconds.
- Final Runtime contract prefix: `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.RuntimeJIT.Coordinator.Contract" -Label runtime-jit-contract-review-green -TimeoutMs 900000` — `9/9 PASS`, exit code 0, 53.076 seconds.
- Independent post-fix review — `READY TO COMMIT`; all five scoped Group 4 ABI/session findings were verified closed with no new concrete blocker.
- Plugin milestone commit: `cb0469f [RuntimeJIT] Feat: define backend session contract`.
