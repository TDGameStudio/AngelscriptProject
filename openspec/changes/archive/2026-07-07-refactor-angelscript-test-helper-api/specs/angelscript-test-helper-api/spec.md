## ADDED Requirements

### Requirement: Extension modules consume test helpers through module dependency

Extension plugin test modules that need Angelscript test helpers SHALL depend on `AngelscriptTest` and include documented helper headers through the module include path rather than hardcoded paths into the Angelscript plugin source tree.

#### Scenario: GAS test module uses documented dependency

- **WHEN** `AngelscriptGASTest` includes documented Angelscript test helper headers
- **THEN** it MUST compile through its `AngelscriptTest` module dependency without a `PrivateIncludePaths` entry that points to `Plugins/Angelscript/Source/AngelscriptTest`

#### Scenario: Extension module avoids source layout coupling

- **WHEN** an extension plugin test module consumes Angelscript test helpers
- **THEN** its build rule MUST NOT add private or public include paths that hardcode the `AngelscriptTest` source directory

### Requirement: Public helper include surface is documented

The test guidance SHALL identify the supported `AngelscriptTest` helper headers that extension test modules may include directly.

#### Scenario: Runtime and binding helpers are documented

- **WHEN** an extension test module needs engine macros, runtime compile helpers, binding coverage helpers, binding module builders, binding assertions, or global function invocation
- **THEN** the documented helper surface MUST include the corresponding `Shared/AngelscriptTestMacros.h`, `Shared/AngelscriptTestEngineHelper.h`, `Shared/AngelscriptBindingsCoverage.h`, `Shared/AngelscriptBindingsModuleBuilder.h`, `Shared/AngelscriptBindingsAssertions.h`, and `Shared/AngelscriptGlobalFunctionInvoker.h` headers

#### Scenario: Functional and reflection helpers are documented

- **WHEN** an extension test module needs UE functional world helpers or reflective property/function access
- **THEN** the documented helper surface MUST include `Shared/AngelscriptFunctionalTestUtils.h`, `Shared/AngelscriptTestWorld.h`, and `Shared/AngelscriptReflectiveAccess.h`

#### Scenario: Native SDK helpers are documented

- **WHEN** an extension test module needs pure AngelScript SDK test helpers
- **THEN** the documented helper surface MUST include `AngelScriptSDK/AngelscriptNativeTestSupport.h` and `AngelScriptSDK/AngelscriptTestAdapter.h`

### Requirement: Internal test helpers remain outside the stable extension API

The helper API documentation SHALL distinguish supported extension helper headers from internal-only `AngelscriptTest` fixtures and themed test implementation directories.

#### Scenario: Internal directories are not promoted accidentally

- **WHEN** documentation describes the extension helper API
- **THEN** it MUST NOT present `Core`, `Debugger`, `Dump`, `Preprocessor`, `ClassGenerator`, or other themed test implementation directories as stable external include surfaces

## Testing Requirements

- Target test layer: Bindings CQTest and UE Functional extension tests.
- Expected Automation prefix: `Angelscript.GAS.*`.
- Recommended helpers/harnesses: `FCoverageModuleScope`, `FBindingsCoverageProfile`, `AngelscriptTestSupport`, `FASGlobalFunctionInvoker`, `FAngelscriptTestWorld`, and `Shared/AngelscriptTestMacros.h`.
- Verification entry points:
  - `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label angelscript-test-helper-api -TimeoutMs 180000 -NoXGE`
  - `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.GAS." -Label angelscript-gas-helper-api -TimeoutMs 600000`
