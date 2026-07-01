# Tasks: Refactor Code Coverage as Extension

## 1. Preparation And Analysis

- [ ] 1.1 Review the existing code coverage implementation and confirm all call sites and dependencies.
- [ ] 1.2 Search for every location that accesses `Engine.CodeCoverage`.
- [ ] 1.3 Confirm the current destruction behavior of `FAngelscriptCodeCoverage`, including whether a memory leak exists.
- [ ] 1.4 Review `AddTestFrameworkHooks()` and confirm its module-loading dependencies.

## 2. Create Extension Class

- [ ] 2.1 Declare `FAngelscriptCodeCoverageExtension` in `AngelscriptCodeCoverage.h`.
- [ ] 2.2 Implement the `IAngelscriptExtension` interface, including `OnEngineAttached` and `OnEngineDetached`.
- [ ] 2.3 Add a `TUniquePtr<FAngelscriptCodeCoverage> Coverage` member to own the coverage object.
- [ ] 2.4 Add a `FAngelscriptEngine* AttachedEngine` member to record the associated engine.
- [ ] 2.5 Check `CoverageEnabled()` in `OnEngineAttached` and create the coverage object when enabled.
- [ ] 2.6 Call `Coverage->AddTestFrameworkHooks()` in `OnEngineAttached` under `WITH_EDITOR`.
- [ ] 2.7 Clean up the coverage object through `Coverage.Reset()` in `OnEngineDetached`.

## 3. Add Access Helper

- [ ] 3.1 Implement the static `FAngelscriptCodeCoverageExtension::GetForEngine(FAngelscriptEngine&)` helper.
- [ ] 3.2 Use `FAngelscriptEngineExtensionRegistry` inside `GetForEngine` to find the extension instance.
- [ ] 3.3 Return `Coverage.Get()` from the extension instance, allowing `nullptr`.
- [ ] 3.4 Add a public `GetCoverage()` accessor for extension-instance access.

## 4. Remove Engine Member Pointer

- [ ] 4.1 Remove the `FAngelscriptCodeCoverage* CodeCoverage = nullptr;` member from `FAngelscriptEngine`.
- [ ] 4.2 Remove coverage object creation from `Initialize_AnyThread()`, around lines 1817-1821.
- [ ] 4.3 Remove the `OnPostEngineInit` lambda from `PostInitialize_GameThread()`, around lines 2007-2015.
- [ ] 4.4 Confirm no stale `CodeCoverage` member access remains.

## 5. Update Engine Internal Call Sites

- [ ] 5.1 Find every `CodeCoverage != nullptr` check in `AngelscriptEngine.cpp`.
- [ ] 5.2 Update the `MapExecutableLines` call in `CompileModules`, around line 5081.
- [ ] 5.3 Update the `HitLine` call in the line callback, around line 6117.
- [ ] 5.4 Update the coverage status display in `GetOnScreenMessages`, around line 6210.
- [ ] 5.5 Convert all calls to use `FAngelscriptCodeCoverageExtension::GetForEngine(*this)`.

## 6. Update State Dump Call Sites

- [ ] 6.1 Find the `Engine.CodeCoverage` access in `AngelscriptStateDump.cpp`, around line 1157.
- [ ] 6.2 Change it to access coverage through `FAngelscriptCodeCoverageExtension::GetForEngine(Engine)`.
- [ ] 6.3 Confirm state dump logic still works.

## 7. Register Extension

- [ ] 7.1 Add extension registration in `FAngelscriptRuntimeModule::StartupModule()`.
- [ ] 7.2 Wrap registration with `#if WITH_AS_COVERAGE`.
- [ ] 7.3 Use `FAngelscriptEngineExtensionRegistry::Get().RegisterExtension(MakeShared<FAngelscriptCodeCoverageExtension>())`.
- [ ] 7.4 Confirm registration order, aligned with the crash snapshot extension.

## 8. Build And Basic Verification

- [ ] 8.1 Run `Tools\RunBuild.ps1` and confirm compilation succeeds.
- [ ] 8.2 Verify editor startup has no error logs.
- [ ] 8.3 Verify code coverage logs are correct when coverage is enabled.
- [ ] 8.4 Confirm `CoverageEnabled()` logic still works.

## 9. Test Coverage Functionality <!-- Non-TDD -->

- [ ] 9.1 Enable code coverage through the relevant environment variables or configuration.
- [ ] 9.2 Run the automation test suite.
- [ ] 9.3 Verify test framework hooks trigger correctly: `StartRecording` / `StopRecordingAndWriteReport`.
- [ ] 9.4 Inspect the generated coverage report HTML files.
- [ ] 9.5 Verify coverage report content and format are unchanged.
- [ ] 9.6 Verify `MapExecutableLines` correctly collects executable lines.
- [ ] 9.7 Verify `HitLine` correctly records line execution.

## 10. Multi-Engine Instance Tests <!-- TDD -->

- [ ] 10.1 Create a test verifying multiple engine instances can track coverage independently.
- [ ] 10.2 Create a test verifying coverage objects are destroyed when engine instances are destroyed.
- [ ] 10.3 Create a test verifying `GetForEngine` returns the correct coverage object.
- [ ] 10.4 Create a test verifying `GetForEngine` returns `nullptr` when coverage is not enabled.
- [ ] 10.5 Run `Tools\RunTests.ps1 -Filter "CodeCoverage"` and verify all tests pass.

## 11. Memory Leak Check <!-- Non-TDD -->

- [ ] 11.1 Use memory analysis tooling to check engine creation/destruction loops.
- [ ] 11.2 Verify `TUniquePtr` correctly destroys `FAngelscriptCodeCoverage`.
- [ ] 11.3 Verify test framework delegate handles are correctly removed.
- [ ] 11.4 Enter and exit PIE repeatedly in the editor and check for memory growth.

## 12. Integration Tests <!-- Non-TDD -->

- [ ] 12.1 Run the full automation test suite in the editor.
- [ ] 12.2 Verify coverage reports generate correctly after tests finish.
- [ ] 12.3 Verify coverage data resets correctly between repeated test runs.
- [ ] 12.4 Verify `ResetHits()` works correctly.

## 13. AddTestFrameworkHooks Robustness <!-- Non-TDD -->

- [ ] 13.1 Check whether `AddTestFrameworkHooks()` verifies `IAutomationControllerModule` loading.
- [ ] 13.2 If the module is not loaded, add logging rather than crashing.
- [ ] 13.3 Verify the extension works outside editor environments without calling `AddTestFrameworkHooks`.

## 14. Documentation Updates

- [ ] 14.1 Update comments in `AngelscriptCodeCoverage.h` to describe the new lifecycle management.
- [ ] 14.2 Record final implementation details in the design document if they differ from the plan.
- [ ] 14.3 Update `AGENTS.md` or related documentation to record that code coverage is now an extension.
- [ ] 14.4 Document `GetForEngine()` usage and best practices.

## 15. Cleanup And Verification

- [ ] 15.1 Search and confirm all `Engine.CodeCoverage` references have been updated.
- [ ] 15.2 Check that no stale `OnPostEngineInit` lambda closure remains.
- [ ] 15.3 Run the full test suite with `Tools\RunTestSuite.ps1` and confirm no regressions.
- [ ] 15.4 Verify the code coverage system works on all supported platforms: Windows, Mac, and Linux.
- [ ] 15.5 Run final build verification with `Tools\RunBuild.ps1`.
- [ ] 15.6 Verify the `WITH_AS_COVERAGE` compile condition is applied correctly.
