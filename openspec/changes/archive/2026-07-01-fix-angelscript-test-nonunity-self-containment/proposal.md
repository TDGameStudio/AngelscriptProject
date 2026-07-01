## Why

Another machine reported compile failures in `AngelscriptTest` where helper symbols such as `ExecuteScriptFunction`, `ASTEST_CREATE_ENGINE`, `FParserAccessor`, `CompileScriptModule`, and `CreateIsolatedFullEngine` were not found, plus one `asCModule*` to `asIScriptModule*` conversion failure. The failures are consistent with test `.cpp` files relying on unity-build include order or transitive includes instead of declaring their own direct helper dependencies.

This matters now because the previous unity-symbol hygiene pass removed lookup leakage in unity chunks, but the opposite failure mode remains: when UBT/UBA changes unity grouping, disables unity for a file, or compiles a source file as its own translation unit, tests that are not self-contained fail only on some machines.

## What Changes

- Extend the Angelscript test symbol hygiene rule from "do not leak helper symbols across unity chunks" to "each test translation unit must be self-contained in unity and non-unity builds."
- Fix the known failing test sources by adding direct includes for the helper APIs they use.
- Qualify or locally import helper namespaces at the call site instead of relying on earlier unity-included files.
- Make AngelScript SDK internal/public interface boundaries explicit where a test passes `asCModule*` to APIs declared as `asIScriptModule*`.
- Add a repeatable audit note/script plan for include ownership and unqualified helper lookup risks in `Plugins/Angelscript/Source/AngelscriptTest`.
- Verify through the standard project build entry point, with `-NoXGE` available to remove external distributed-executor capacity from the signal.

## Capabilities

### New Capabilities

- None.

### Modified Capabilities

- `angelscript-test-unity-build-symbol-hygiene`: Extend the existing test symbol hygiene contract so Angelscript C++ automation tests explicitly declare their own helper dependencies and compile regardless of UBT unity chunking.

## Impact

- Primary code area: `Plugins/Angelscript/Source/AngelscriptTest/**/*.cpp`.
- Initial known files:
  - `AngelScriptSDK/AngelscriptGlobalVarTests.cpp`
  - `AngelScriptSDK/AngelscriptParserTests.cpp`
  - `StaticJIT/AOT/AngelscriptStaticJITAotGeneration.cpp`
  - `StaticJIT/AngelscriptStaticJITDiagnosticsTests.cpp`
  - `HotReload/AngelscriptHotReloadVersionChainTests.cpp`
- Primary helper headers:
  - `AngelScriptSDK/AngelscriptSDKTestExecutionHelpers.h`
  - `AngelScriptSDK/AngelscriptNativeTestSupport.h`
  - `Shared/AngelscriptTestMacros.h`
  - `Shared/AngelscriptTestEngineAcquisition.h`
  - `Shared/AngelscriptFunctionalTestUtils.h`
- No runtime plugin behavior, public script API, generated UHT binding contract, or host project behavior is intended to change.
- Verification should use `Tools\RunBuild.ps1`, not direct `Build.bat` or UBT invocation.
