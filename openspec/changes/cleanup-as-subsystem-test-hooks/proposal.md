## Why

`UAngelscriptSubsystem` is a production `UEngineSubsystem`, but its public surface and lifecycle implementation currently contain `WITH_DEV_AUTOMATION_TESTS` setters, static override state, and alternate initialization/lookup branches. Part of that surface is dead after subsystem consolidation, while the remaining hooks let tests mutate production subsystem behavior instead of using test-owned engine scopes and fixtures.

## What Changes

- Remove every `WITH_DEV_AUTOMATION_TESTS` block and test-only API from `UAngelscriptSubsystem`.
- Remove the dead editor/commandlet startup-environment override and the now-redundant `ShouldBootstrapAngelscript()` wrapper.
- Remove the process-level `AngelscriptTestUseScanFreeStartupEngine` startup option and its cross-module engine lifetime coupling.
- Keep scan-free engines available through CQTest-owned fixtures for tests that need them.
- Refactor subsystem and runtime-module tests to use the real engine subsystem, ambient engine scopes, and test-side engine helpers instead of replacing `UAngelscriptSubsystem::Get()` or its initialization function.
- Keep `FAngelscriptRuntimeModule` test hooks out of scope; they are a separate production-surface issue.

## Capabilities

### New Capabilities

- `as-subsystem-production-surface`: `UAngelscriptSubsystem` exposes production lifecycle behavior only, while tests control their engines through test-module-owned scopes and fixtures.

### Modified Capabilities

None.

## Impact

- `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptSubsystem.h`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptSubsystem.cpp`
- `Plugins/Angelscript/Source/AngelscriptTest/AngelscriptTestModule.cpp`
- `Plugins/Angelscript/Source/AngelscriptTest/Core/AngelscriptEngineSubsystemTests.cpp`
- `Plugins/Angelscript/Source/AngelscriptTest/Core/AngelscriptRuntimeModuleTests.cpp`
- Documentation describing test engine acquisition and CQTest fixture ownership.
- Dual-repository workflow: implementation is committed in `Plugins/Angelscript` before the parent gitlink and OpenSpec record.
