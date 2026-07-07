# Tasks: Refactor Crash Snapshot as Extension

## 1. Preparation And Analysis

- [x] 1.1 Review the existing crash snapshot implementation and confirm global state remains process-level.
- [x] 1.2 Review the Runtime extension pattern from `FAngelscriptCodeCoverageExtension`.
- [x] 1.3 Confirm `FAngelscriptEngineExtensionRegistry::UnregisterExtension()` does not detach existing engines automatically.

## 2. TDD Coverage

- [x] 2.1 Add sequential engine lifecycle coverage under `Angelscript.TestModule.Dump.CrashSnapshot`.
- [x] 2.2 Add overlapping engine lifecycle coverage under `Angelscript.TestModule.Dump.CrashSnapshot`.
- [x] 2.3 Run RED build and confirm failure is caused by missing crash snapshot extension/test accessors.

## 3. Runtime Implementation

- [x] 3.1 Declare `FAngelscriptCrashSnapshotExtension` in `AngelscriptCrashSnapshot.h`.
- [x] 3.2 Implement `OnEngineAttached()` and `OnEngineDetached()` with duplicate attach/detach guards.
- [x] 3.3 Track active engine count with `std::atomic<int32>` and protect attached engine identity with `FCriticalSection`.
- [x] 3.4 Register the crash handler on first engine attach and unregister it on final engine detach.
- [x] 3.5 Preserve `WriteSnapshotForTesting()`, `ConfigureForTesting()`, and crash snapshot JSON format.

## 4. Module Integration

- [x] 4.1 Register the crash snapshot extension from `FAngelscriptRuntimeModule::StartupModule()`.
- [x] 4.2 Store the extension registration handle in `FAngelscriptRuntimeModule`.
- [x] 4.3 Remove direct `FAngelscriptCrashSnapshot::Startup()` / `Shutdown()` calls from RuntimeModule.
- [x] 4.4 Ensure module shutdown unregisters the extension and force-cleans handler state because registry unregister does not detach current engines.

## 5. Documentation And Verification

- [x] 5.1 Update the Chinese engine extension guide to list `FAngelscriptCrashSnapshotExtension` as implemented.
- [x] 5.2 Update this OpenSpec record to match the focused automation completion scope.
- [x] 5.3 Run build verification with `Tools\RunBuild.ps1`.
- [x] 5.4 Run CrashSnapshot focused tests with `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Dump.CrashSnapshot"`.

## 6. Focused Verification Completed

- [x] 6.1 Run crash-only child process verification with `Tools\RunTests.ps1 -TestPrefix "Angelscript.CrashOnly.CrashSnapshot" -Label crash-snapshot-extension-crashonly -TimeoutMs 600000`.
- [x] 6.2 Run OpenSpec strict validation.
- [x] 6.3 Run final build verification after documentation/OpenSpec edits.

## Deferred Non-Blocking Checks Recorded

- [x] Manual PIE smoke is deferred; not part of this focused automation completion scope.
- [x] Full `RunTestSuite.ps1` is deferred; not part of this focused automation completion scope.
- [x] Mac/Linux/Standalone validation is deferred; not available in the current Windows automation environment.
