# AngelscriptTest Compile Macro Impact Inventory

## Fresh Scan

- Scope: `Plugins/Angelscript/Source/AngelscriptTest/**/*.cpp`
- Total `.cpp` files: 549
- Registration `.cpp` files: 527
- Registration pattern: `TEST_CLASS_WITH_FLAGS|TEST_METHOD|IMPLEMENT_SIMPLE_AUTOMATION_TEST|IMPLEMENT_COMPLEX_AUTOMATION_TEST|DEFINE_SPEC|BEGIN_DEFINE_SPEC`
- Registration files missing `WITH_ANGELSCRIPT_UNITTESTS`: 0 after wrapping
- Files still using `WITH_DEV_AUTOMATION_TESTS`: 0 after migration
- Extension test modules that consume `AngelscriptTest` shared helpers were also aligned after disabled-mode build verification exposed the dependency:
  - `Plugins/AngelscriptGameplayTags/Source/AngelscriptGameplayTagsTest`: 5 registration `.cpp` files migrated from `WITH_DEV_AUTOMATION_TESTS` to `WITH_ANGELSCRIPT_UNITTESTS`.
  - `Plugins/AngelscriptGAS/Source/AngelscriptGASTest`: 24 registration `.cpp` files migrated from `WITH_DEV_AUTOMATION_TESTS` to `WITH_ANGELSCRIPT_UNITTESTS`.

## Registration Wrapping Policy

- Include blocks stay outside the gate.
- Registration bodies use `#if WITH_ANGELSCRIPT_UNITTESTS`.
- Previous `WITH_DEV_AUTOMATION_TESTS` gates were replaced by `WITH_ANGELSCRIPT_UNITTESTS`.
- Feature-specific gates remain in addition to the total switch where required, for example `AS_CAN_GENERATE_JIT`, `AS_JIT_DEBUG_CALLSTACKS`, `WITH_AS_COVERAGE`, and `WITH_EDITOR`.
- Historical disabled tests remain disabled as `#if WITH_ANGELSCRIPT_UNITTESTS && 0` with their existing TODO reason.

## Non-Registration `.cpp` Classification

| File | Classification | Decision |
|---|---|---|
| `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/AngelscriptStructCppOpsTestTypes.cpp` | Test support type implementation | Exempt; no test registration. |
| `Plugins/Angelscript/Source/AngelscriptTest/Bindings/AngelscriptContainerBindingsTests.cpp` | Deprecated empty migration stub | Exempt; no test registration. |
| `Plugins/Angelscript/Source/AngelscriptTest/Compiler/AngelscriptCompilerInterfaceTests.cpp` | Removed-test stub | Exempt; no test registration. |
| `Plugins/Angelscript/Source/AngelscriptTest/Core/AngelscriptUhtCoverageTestTypes.cpp` | Test support UObject/function library implementation | Exempt; no test registration. |
| `Plugins/Angelscript/Source/AngelscriptTest/Coverage/AngelscriptCoverageGCTestHelpers.cpp` | Test-only bind helper | Gated; contains `AS_FORCE_LINK` bind registration for coverage tests. |
| `Plugins/Angelscript/Source/AngelscriptTest/Performance/AngelscriptPerformanceTestTypes.cpp` | Test-only bind helper | Gated; contains `AS_FORCE_LINK` bind registration for performance tests. |
| `Plugins/Angelscript/Source/AngelscriptTest/Shared/AngelscriptConstructionContextProbe.cpp` | Shared test probe implementation | Exempt; no test registration. |
| `Plugins/Angelscript/Source/AngelscriptTest/Shared/AngelscriptDebuggerScriptFixture.cpp` | Shared debugger fixture implementation | Exempt; no test registration. |
| `Plugins/Angelscript/Source/AngelscriptTest/Shared/AngelscriptDebuggerTestClient.cpp` | Shared debugger client implementation | Exempt; no test registration. |
| `Plugins/Angelscript/Source/AngelscriptTest/Shared/AngelscriptDebuggerTestMonitor.cpp` | Shared debugger async invocation helper | Gated; its header declares unit-test-only helper surface. |
| `Plugins/Angelscript/Source/AngelscriptTest/Shared/AngelscriptDebuggerTestSession.cpp` | Shared debugger session implementation | Exempt; no test registration. |
| `Plugins/Angelscript/Source/AngelscriptTest/Shared/AngelscriptMockDebugServer.cpp` | Shared mock debug server implementation | Exempt; no test registration. |
| `Plugins/Angelscript/Source/AngelscriptTest/Shared/AngelscriptNativeInterfaceTestTypes.cpp` | Shared native interface test type implementation | Exempt; no test registration. |
| `Plugins/Angelscript/Source/AngelscriptTest/Shared/AngelscriptNativeScriptTestObject.cpp` | Shared native script test object implementation | Exempt; no test registration. |
| `Plugins/Angelscript/Source/AngelscriptTest/Shared/AngelscriptTestEngine.cpp` | Shared test engine implementation | Exempt; module support needed by gated tests. |
| `Plugins/Angelscript/Source/AngelscriptTest/Shared/AngelscriptTestEngineHelper.cpp` | Shared test engine helper implementation | Partially gated; StaticJIT generation helper remains behind `WITH_ANGELSCRIPT_UNITTESTS && AS_CAN_GENERATE_JIT`. |
| `Plugins/Angelscript/Source/AngelscriptTest/StaticJIT/AOT/AngelscriptStaticJITAotFixture.cpp` | AOT fixture support | Exempt; no test registration. |
| `Plugins/Angelscript/Source/AngelscriptTest/StaticJIT/AOT/AngelscriptStaticJITAotGeneration.cpp` | AOT generation support | Exempt; no test registration. |
| `Plugins/Angelscript/Source/AngelscriptTest/StaticJIT/AOT/AngelscriptStaticJITAotTestCommandlet.cpp` | AOT test commandlet | Exempt; commandlet entry point, no automation registration. |
| `Plugins/Angelscript/Source/AngelscriptTest/StaticJIT/AOT/Generated/AngelscriptJitCode_0.jit.cpp` | Generated AOT artifact | Exempt; generated fixture code. |
| `Plugins/Angelscript/Source/AngelscriptTest/StaticJIT/AOT/Generated/AngelscriptJitInfo.jit.cpp` | Generated AOT artifact | Exempt; generated fixture metadata. |
| `Plugins/Angelscript/Source/AngelscriptTest/Validation/AngelscriptCompileSettingsValidation.cpp` | Compile definition validation | Exempt; deliberately compiles in both modes. |

## Verification Notes

- Disabled-unit-tests build passed with `bCompileAngelscriptUnitTests=false`:
  - Command: `Tools\RunBuild.ps1 -ExtraArgs -NoHotReloadFromIDE -TimeoutMs 1800000`
  - Log: `Saved\Build\build\20260701_123135_767_c2c3036c\Build.log`
  - Metadata: `Saved\Build\build\20260701_123135_767_c2c3036c\RunMetadata.json`
  - Result: `ProcessExitCode=0`, `FinalExitCode=0`.
- Disabled discovery check confirmed the AngelScriptSDK prefix is omitted when the total switch is off:
  - Command: `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK" -Label disabled-angelscript-sdk-discovery -TimeoutMs 600000`
  - Log: `Saved\Tests\disabled-angelscript-sdk-discovery\20260701_123209_079_9a0da0e8\Automation.log`
  - Expected result: `No automation tests matched '^Angelscript.TestModule.AngelScriptSDK'`; script returned `FinalExitCode=1` because absence of matching tests is reported as a test-run failure by the runner.
- Enabled-unit-tests build passed with `bCompileAngelscriptUnitTests=true`:
  - Command: `Tools\RunBuild.ps1 -ExtraArgs -NoHotReloadFromIDE -TimeoutMs 1800000`
  - Log: `Saved\Build\build\20260701_123311_456_180590ea\Build.log`
  - Metadata: `Saved\Build\build\20260701_123311_456_180590ea\RunMetadata.json`
  - Result: `ProcessExitCode=0`, `FinalExitCode=0`.
- Representative AngelScriptSDK automation run passed with unit tests enabled:
  - Command: `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK" -Label enabled-angelscript-sdk -TimeoutMs 600000`
  - Summary: `Saved\Tests\enabled-angelscript-sdk\20260701_123435_432_3238a70f\Summary.json`
  - Result: `421/421` passed, `0` failed, `0` skipped.
- Final checked-in config state: `Config/DefaultAngelscriptCompileOptions.ini` has `bCompileAngelscriptUnitTests=true`.
