# Tasks: Refactor Code Coverage as Extension

## 1. Preparation And Analysis

- [x] 1.1 Review the existing code coverage implementation and confirm all call sites and dependencies.
- [x] 1.2 Search for every location that accesses `Engine.CodeCoverage`.
- [x] 1.3 Confirm the current destruction behavior of `FAngelscriptCodeCoverage`, including whether a memory leak exists.
- [x] 1.4 Review `AddTestFrameworkHooks()` and confirm its module-loading dependencies.

## 2. Create Extension Class

- [x] 2.1 Declare `FAngelscriptCodeCoverageExtension` in `AngelscriptCodeCoverage.h`.
- [x] 2.2 Implement the `IAngelscriptExtension` interface, including `OnEngineAttached` and `OnEngineDetached`.
- [x] 2.3 Add extension-owned per-engine `TUniquePtr<FAngelscriptCodeCoverage>` storage.
- [x] 2.4 Record the associated `FAngelscriptEngine*` for each coverage object.
- [x] 2.5 Check `CoverageEnabled()` in `OnEngineAttached` and create the coverage object when enabled.
- [x] 2.6 Call `Coverage->AddTestFrameworkHooks()` in `OnEngineAttached` under `WITH_EDITOR`.
- [x] 2.7 Clean up the coverage object when `OnEngineDetached` removes the engine entry.

## 3. Add Access Helper

- [x] 3.1 Implement the static `FAngelscriptCodeCoverageExtension::GetForEngine(FAngelscriptEngine&)` helper.
- [x] 3.2 Use extension registration state to find the extension instance for a specific engine.
- [x] 3.3 Return the engine-specific coverage pointer, allowing `nullptr`.
- [x] 3.4 Add a public `GetCoverage(FAngelscriptEngine&)` accessor for extension-instance access.

## 4. Remove Engine Member Pointer

- [x] 4.1 Remove the `FAngelscriptCodeCoverage* CodeCoverage = nullptr;` member from `FAngelscriptEngine`.
- [x] 4.2 Remove coverage object creation from `Initialize_AnyThread()`, around lines 1817-1821.
- [x] 4.3 Remove the `OnPostEngineInit` lambda from `PostInitialize_GameThread()`, around lines 2007-2015.
- [x] 4.4 Confirm no stale `CodeCoverage` member access remains.

## 5. Update Engine Internal Call Sites

- [x] 5.1 Find every `CodeCoverage != nullptr` check in `AngelscriptEngine.cpp`.
- [x] 5.2 Update the `MapExecutableLines` call in `CompileModules`.
- [x] 5.3 Update the `HitLine` call in the line callback.
- [x] 5.4 Update the coverage line-callback state check to use the extension.
- [x] 5.5 Convert all calls to use `FAngelscriptCodeCoverageExtension::GetForEngine(...)`.

## 6. Update State Dump Call Sites

- [x] 6.1 Find the `Engine.CodeCoverage` access in `AngelscriptStateDump.cpp`, around line 1157.
- [x] 6.2 Change it to access coverage through `FAngelscriptCodeCoverageExtension::GetForEngine(Engine)`.
- [x] 6.3 Confirm state dump logic still works.

## 7. Register Extension

- [x] 7.1 Add extension registration in `FAngelscriptRuntimeModule::StartupModule()`.
- [x] 7.2 Wrap registration with `#if WITH_AS_COVERAGE`.
- [x] 7.3 Register through `FAngelscriptCodeCoverageExtension::Startup()`.
- [x] 7.4 Confirm registration order, aligned with the crash snapshot startup.

## 8. Build And Basic Verification

- [x] 8.1 Run `Tools\RunBuild.ps1` and confirm compilation succeeds.
- [ ] 8.2 Verify editor startup has no error logs.
- [ ] 8.3 Verify code coverage logs are correct when coverage is enabled.
- [x] 8.4 Confirm `CoverageEnabled()` logic still works.

## 9. Test Coverage Functionality <!-- Non-TDD -->

- [ ] 9.1 Enable code coverage through the relevant environment variables or configuration.
- [x] 9.2 Run the focused code coverage automation test prefix.
- [x] 9.3 Verify recording/report flow via focused code coverage tests.
- [x] 9.4 Verify runtime no longer generates coverage HTML files.
- [x] 9.5 Verify coverage report content and format as JSON-only output.
- [x] 9.6 Verify `MapExecutableLines` correctly collects executable lines.
- [x] 9.7 Verify `HitLine` correctly records line execution.

## 10. Multi-Engine Instance Tests <!-- TDD -->

- [ ] 10.1 Create a test verifying multiple engine instances can track coverage independently.
- [ ] 10.2 Create a test verifying coverage objects are destroyed when engine instances are destroyed.
- [ ] 10.3 Create a test verifying `GetForEngine` returns the correct coverage object.
- [ ] 10.4 Create a test verifying `GetForEngine` returns `nullptr` when coverage is not enabled.
- [x] 10.5 Run `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Core.CodeCoverage"` and verify all focused coverage tests pass.

## 11. Memory Leak Check <!-- Non-TDD -->

- [ ] 11.1 Use memory analysis tooling to check engine creation/destruction loops.
- [x] 11.2 Verify extension-owned `TUniquePtr` storage destroys `FAngelscriptCodeCoverage` at detach/removal.
- [x] 11.3 Verify test framework delegate handles are removed in the coverage destructor.
- [ ] 11.4 Enter and exit PIE repeatedly in the editor and check for memory growth.

## 12. Integration Tests <!-- Non-TDD -->

- [ ] 12.1 Run the full automation test suite in the editor.
- [x] 12.2 Verify coverage reports generate correctly after focused tests finish.
- [x] 12.3 Verify coverage data resets correctly between repeated recording calls.
- [x] 12.4 Verify `ResetHits()` works correctly.

## 13. AddTestFrameworkHooks Robustness <!-- Non-TDD -->

- [x] 13.1 Check whether `AddTestFrameworkHooks()` verifies `IAutomationControllerModule` loading.
- [x] 13.2 If the module is not loaded, add logging rather than crashing.
- [x] 13.3 Verify the extension is guarded so non-editor builds do not call `AddTestFrameworkHooks`.

## 14. Documentation Updates

- [x] 14.1 Update comments in `AngelscriptCodeCoverage.h` to describe JSON report behavior.
- [x] 14.2 Record final implementation details in the design document if they differ from the plan.
- [x] 14.3 Update `AGENTS.md` / `AGENTS_ZH.md` and related documentation to record that code coverage is now an extension.
- [x] 14.4 Document `GetForEngine()` usage and best practices in `Documents/Guides/AngelscriptEngineExtension.md`.

## 15. Cleanup And Verification

- [x] 15.1 Search and confirm all `Engine.CodeCoverage` references have been updated.
- [x] 15.2 Check that no stale code coverage `OnPostEngineInit` lambda closure remains.
- [ ] 15.3 Run the full test suite with `Tools\RunTestSuite.ps1` and confirm no regressions.
- [ ] 15.4 Verify the code coverage system works on all supported platforms: Windows, Mac, and Linux.
- [x] 15.5 Run final build verification with `Tools\RunBuild.ps1`.
- [x] 15.6 Verify the `WITH_AS_COVERAGE` compile condition is applied correctly.
