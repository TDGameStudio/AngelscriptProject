## 1. Regression characterization and focused test baselines

- [ ] 1.1 <!-- Non-TDD --> Record the exact focused automation prefixes and expected outcomes for the builder, Engine, Editor Settings, FunctionLibraries, Generator suite, StaticJIT AOT, and Debugger failures in `verification.md`.
- [ ] 1.2 <!-- TDD --> Run the previously crashing Builder enum test as the red regression baseline and add the smallest valid-description assertion needed to prove post-build enumeration is safe.
- [ ] 1.3 <!-- TDD --> Run the affected Engine, Editor, FunctionLibraries, and StaticJIT prefixes before changing their fixtures or lifecycle controls; preserve failure output needed to distinguish test-environment defects from product defects.

## 2. StaticJIT AOT generated-artifact preparation

- [ ] 2.1 <!-- TDD --> Capture the cache-only-refresh assertion failure and document why the cache and generated C++ reference IDs must be generated and compiled as one pair.
- [ ] 2.2 <!-- TDD --> Add `Tools/RunStaticJITTests.ps1`, which runs baseline build, Generate commandlet, generated-source rebuild, and the requested StaticJIT prefix in order and stops on the first failure.
- [ ] 2.3 <!-- Non-TDD --> Point fixture setup errors and the testing guide to the dedicated runner; retain the generated-source verification test and the ignored source-tree cache location.
- [ ] 2.4 <!-- Non-TDD --> Delete the obsolete ignored `Source/AngelscriptTest/StaticJIT/AOT/Generated/StaticJITAotFixture.Cache` before preparation if present; confirm no tracked cache is introduced.

## 3. Deterministic test environment and editor setup

- [ ] 3.1 <!-- TDD --> Add a scoped `WITH_DEV_AUTOMATION_TESTS` engine-resolution suppression with RAII restoration coverage, without changing production scoped-engine or subsystem fallback behavior.
- [ ] 3.2 <!-- TDD --> Migrate the no-current-engine assertions in `AngelscriptTest/Core`, the Editor directory-watcher/popup tests, and StaticJIT diagnostics to the explicit suppression rather than `SnapshotAndClear()` alone.
- [ ] 3.3 <!-- TDD --> Change `FAngelscriptEditorModule::StartupModule()` to load its declared `Settings` dependency before registering both Project Settings sections; verify the compile-options validator is bound even when Settings was not preloaded.

## 4. Builder, fixture expectations, and suite definitions

- [ ] 4.1 <!-- TDD --> Remove enum descriptions from every builder diagnostic/ownership container before deleting them, preserving valid post-build global-description enumeration.
- [ ] 4.2 <!-- TDD --> Update Widget and World function-library expected exception stack coordinates to the current `ASTEST_AS` fixture locations and rerun their binding prefixes.
- [ ] 4.3 <!-- TDD --> Replace the stale `ClassGenerator` and `ScriptClass` entries in `Tools/Shared/TestSuiteDefinitions.ps1` with one current, non-duplicating Generator group; verify it discovers all Generator tests.

## 5. Debugger TCP framing robustness

- [ ] 5.1 <!-- TDD --> Extract/test incremental debugger-envelope framing with complete, split-header, split-payload, multiple-envelope, and invalid-length inputs in the Debugger test layer.
- [ ] 5.2 <!-- TDD --> Give `FAngelscriptDebugServer` per-client receive buffers, parse only complete envelopes, discard invalid clients deterministically, and clean receive state on disconnect/shutdown.
- [ ] 5.3 <!-- Non-TDD --> Run the focused Debugger prefix repeatedly through `Tools/RunTests.ps1` to check that the previous full-suite timeout does not recur.

## 6. Verification and commits

- [ ] 6.1 <!-- Non-TDD --> Run focused Automation prefixes for all modified areas using `Tools/RunTests.ps1` and record pass/fail counts in `verification.md`.
- [ ] 6.2 <!-- Non-TDD --> Build the affected plugin through `Tools/RunBuild.ps1`; resolve compile failures with root-cause evidence before proceeding.
- [ ] 6.3 <!-- Non-TDD --> Run `Tools/RunTestSuite.ps1 -Suite All` and record every group result, including the corrected Generator group and StaticJIT AOT tests.
- [ ] 6.4 <!-- Non-TDD --> Review the scoped diff, commit only this change's plugin files in the `Plugins/Angelscript` submodule, then commit the root OpenSpec/tooling changes and updated gitlink without staging pre-existing worktree edits.
