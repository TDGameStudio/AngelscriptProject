# Proposal: Refactor Code Coverage as Extension

## Why

The current code coverage system, `FAngelscriptCodeCoverage`, is created directly in `FAngelscriptEngine::Initialize_AnyThread()` through `new FAngelscriptCodeCoverage`, then registers test framework hooks in `PostInitialize_GameThread()` through a `FCoreDelegates::OnPostEngineInit` lambda. This design creates several problems:

1. **Unclear lifecycle management**: the object is held through a raw pointer and destruction behavior is unclear.
2. **Initialization timing depends on a global callback**: `OnPostEngineInit` uses a lambda closure that is hard to trace and test.
3. **Extension system is bypassed**: code coverage is an optional diagnostic feature and should be managed through the extension system.
4. **Inconsistent with crash snapshot architecture**: similar diagnostic systems should share the same extension pattern.

Refactoring code coverage into an engine extension gives the system:

- unified lifecycle management through `IAngelscriptExtension`
- direct initialization when an engine is attached, without delaying through `OnPostEngineInit`
- architecture consistent with other extensions such as crash snapshots
- simpler testing and debugging

## What Changes

- Manage `FAngelscriptCodeCoverage` through the `IAngelscriptExtension` interface instead of a raw pointer inside the engine.
- Add `FAngelscriptCodeCoverageExtension`, implementing `OnEngineAttached` and `OnEngineDetached` lifecycle hooks.
- Remove `CodeCoverage = new FAngelscriptCodeCoverage` from `FAngelscriptEngine::Initialize_AnyThread()`.
- Remove the `OnPostEngineInit` lambda closure from `PostInitialize_GameThread()`.
- Create the `FAngelscriptCodeCoverage` instance and call `AddTestFrameworkHooks()` from the extension's `OnEngineAttached`.
- Clean up the code coverage object from the extension's `OnEngineDetached`.
- Support independent per-engine-instance coverage tracking, with separate coverage data for each engine instance.
- Preserve the existing coverage API and report generation logic.

## Capabilities

### New Capabilities

- `code-coverage-extension`: complete implementation of the code coverage system as an engine extension, including lifecycle management, per-engine-instance tracking, and test framework hook integration.

### Modified Capabilities

None. This is an internal refactor and does not modify an existing specification.

## Impact

**Code Impact:**

- `AngelscriptRuntime/CodeCoverage/AngelscriptCodeCoverage.h`: update the interface and add the extension class.
- `AngelscriptRuntime/CodeCoverage/AngelscriptCodeCoverage.cpp`: refactor initialization logic.
- `AngelscriptRuntime/Core/AngelscriptEngine.h`: remove the raw `CodeCoverage` pointer member.
- `AngelscriptRuntime/Core/AngelscriptEngine.cpp`: remove direct construction and lambda registration code.
- `AngelscriptRuntime/Core/AngelscriptRuntimeModule.cpp`: register the extension.

**Behavior Impact:**

- Code coverage initializes when a `FAngelscriptEngine` instance is created, if `CoverageEnabled()` is true.
- Test framework hooks register immediately when the engine attaches and no longer depend on `OnPostEngineInit`.
- Each engine instance owns an independent `FAngelscriptCodeCoverage` object.
- Coverage report generation logic remains unchanged.
- Existing APIs remain compatible: `MapExecutableLines`, `HitLine`, `StartRecording`, and `StopRecordingAndWriteReport`.

**Dependency Impact:**

- The engine extension registry becomes a required dependency for the code coverage system.
- The dependency on `FCoreDelegates::OnPostEngineInit` is removed.
- Engine instance lifecycle controls code coverage activation.

**Advantages:**

- Supports independent coverage tracking in multi-engine-instance environments.
- Clarifies lifecycle management through the extension interface instead of raw pointers.
- Makes initialization timing explicit at engine attachment instead of through a global callback.
- Aligns architecture with other extensions such as crash snapshots and hot reload.
