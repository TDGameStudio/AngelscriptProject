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
