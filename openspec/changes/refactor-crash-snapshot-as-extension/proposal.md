# Proposal: Refactor Crash Snapshot as Extension

## Why

The current crash snapshot system, `FAngelscriptCrashSnapshot`, is globally initialized in `FAngelscriptRuntimeModule::StartupModule()`. Its lifecycle is tied to the module rather than to engine instances. This means the system cannot observe a specific engine instance lifecycle, cannot use the engine extension mechanism for on-demand enable/disable behavior, and is difficult to reason about in multi-engine-instance environments. Refactoring it into an engine extension decouples lifecycle management and makes it an optional diagnostic feature managed per engine instance.

## What Changes

- Convert `FAngelscriptCrashSnapshot` from global static initialization to implementation through the `IAngelscriptExtension` interface.
- Add `FAngelscriptCrashSnapshotExtension`, implementing `OnEngineAttached` and `OnEngineDetached` lifecycle hooks.
- Remove direct `Startup()` / `Shutdown()` calls from `FAngelscriptRuntimeModule`.
- Move `FCoreDelegates::OnHandleSystemError` registration into the extension's `OnEngineAttached` path.
- Support independent crash snapshot behavior in multi-engine-instance environments.
- Preserve existing crash snapshot JSON output format and test interface compatibility.

## Capabilities

### New Capabilities

- `crash-snapshot-extension`: complete implementation of the crash snapshot system as an engine extension, including lifecycle management, engine instance awareness, and lazy initialization.

### Modified Capabilities

None. This is an internal refactor and does not modify an existing specification.

## Impact

**Code Impact:**

- `AngelscriptRuntime/Dump/AngelscriptCrashSnapshot.h`: update public interface and add the extension class.
- `AngelscriptRuntime/Dump/AngelscriptCrashSnapshot.cpp`: refactor initialization logic.
- `AngelscriptRuntime/Core/AngelscriptRuntimeModule.cpp`: remove direct calls and register the extension.
- `AngelscriptRuntime/Core/AngelscriptEngineExtensionRegistry.h`: may need confirmation for multi-engine-instance support.

**Behavior Impact:**

- Crash snapshots register the global crash handler when the first `FAngelscriptEngine` instance is created.
- The global crash handler unregisters when the last engine instance is destroyed.
- Existing test code, including `WriteSnapshotForTesting` and `ConfigureForTesting`, remains compatible.
- Editor and runtime crash snapshot behavior remains unaffected.

**Dependency Impact:**

- The engine extension registry becomes a required dependency for the crash snapshot system.
- Engine instance lifecycle determines whether crash snapshot functionality is active.
