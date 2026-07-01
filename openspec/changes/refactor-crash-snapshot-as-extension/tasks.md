# Tasks: Refactor Crash Snapshot as Extension

## 1. Preparation And Analysis

- [ ] 1.1 Review the existing crash snapshot implementation and confirm all global state and dependencies.
- [ ] 1.2 Review `FClassReloadHelper::FClassReloadHelperExtension` as the reference implementation.
- [ ] 1.3 Confirm thread safety and multi-engine support in `FAngelscriptEngineExtensionRegistry`.

## 2. Create Extension Class

- [ ] 2.1 Declare `FAngelscriptCrashSnapshotExtension` in `AngelscriptCrashSnapshot.h`.
- [ ] 2.2 Implement the `IAngelscriptExtension` interface, including `OnEngineAttached` and `OnEngineDetached`.
- [ ] 2.3 Add a static `ActiveEngineCount` reference counter and use `std::atomic<int32>` for thread safety.
- [ ] 2.4 Check the reference count in `OnEngineAttached` and call `Startup()` on first attachment.
- [ ] 2.5 Check the reference count in `OnEngineDetached` and call `Shutdown()` on final detachment.

## 3. Refactor Crash Snapshot Interface

- [ ] 3.1 Keep `Startup()` / `Shutdown()` as public static methods for extension use.
- [ ] 3.2 Add comments explaining these methods are now managed by the extension system and should not be called directly.
- [ ] 3.3 Confirm `WriteSnapshotForTesting` and `ConfigureForTesting` remain unaffected.

## 4. Update Module Initialization

- [ ] 4.1 Register the extension in `FAngelscriptRuntimeModule::StartupModule()`.
- [ ] 4.2 Use `FAngelscriptEngineExtensionRegistry::Get().RegisterExtension(MakeShared<FAngelscriptCrashSnapshotExtension>())`.
- [ ] 4.3 Remove the direct `FAngelscriptCrashSnapshot::Startup()` call from `StartupModule()`.
- [ ] 4.4 Remove the direct `FAngelscriptCrashSnapshot::Shutdown()` call from `ShutdownModule()`.
- [ ] 4.5 Optionally store the extension registration handle and unregister during module unload.

## 5. Build And Basic Verification

- [ ] 5.1 Run `Tools\RunBuild.ps1` and confirm compilation succeeds.
- [ ] 5.2 Verify editor startup has no error logs.
- [ ] 5.3 Verify crash snapshot logs are correct for engine attachment and detachment.

## 6. Test Existing Functionality <!-- Non-TDD -->

- [ ] 6.1 Run crash snapshot automation tests if they exist.
- [ ] 6.2 Use the `as.Test.ConfigureCrashSnapshot` command to verify the test interface.
- [ ] 6.3 Use `WriteSnapshotForTesting` to verify snapshot generation.
- [ ] 6.4 Verify crash snapshot JSON format is unchanged.

## 7. Multi-Engine Instance Tests <!-- TDD -->

- [ ] 7.1 Create a test verifying reference counts are correct across repeated engine creation/destruction.
- [ ] 7.2 Create a test verifying crash handler registration when the first engine attaches.
- [ ] 7.3 Create a test verifying crash handler unregistration when the last engine detaches.
- [ ] 7.4 Create a test verifying intermediate engine destruction does not affect crash handler state.
- [ ] 7.5 Run `Tools\RunTests.ps1 -Filter "CrashSnapshot"` and verify all tests pass.

## 8. Integration Tests <!-- Non-TDD -->

- [ ] 8.1 Start PIE in the editor and verify the crash snapshot system works correctly.
- [ ] 8.2 Enter and exit PIE repeatedly in the editor and verify there are no memory leaks.
- [ ] 8.3 Verify standalone game builds if crash snapshots are supported there.

## 9. Documentation Updates

- [ ] 9.1 Update comments in `AngelscriptCrashSnapshot.h` to describe the new lifecycle management.
- [ ] 9.2 Record final implementation details in the design document if they differ from the plan.
- [ ] 9.3 Update `AGENTS.md` or related documentation to record that crash snapshots are now an extension.

## 10. Cleanup And Verification

- [ ] 10.1 Check that no stale direct `Startup()` / `Shutdown()` calls remain.
- [ ] 10.2 Run the full test suite with `Tools\RunTestSuite.ps1` and confirm no regressions.
- [ ] 10.3 Verify the crash snapshot system works on all supported platforms: Windows, Mac, and Linux.
- [ ] 10.4 Review code and confirm thread safety, including `std::atomic` reference counting.
- [ ] 10.5 Run final build verification with `Tools\RunBuild.ps1`.
