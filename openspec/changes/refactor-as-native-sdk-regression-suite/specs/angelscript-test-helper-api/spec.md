## MODIFIED Requirements

### Requirement: Public helper include surface is documented
The test guidance SHALL identify the supported `AngelscriptTest` helper headers that extension test modules may include directly. The native SDK implementation SHALL be split behind its documented compatibility includes without requiring consumers to include internal support headers directly.

#### Scenario: Runtime and binding helpers are documented
- **WHEN** an extension test module needs engine macros, runtime compile helpers, binding module builders, binding assertions, or global function invocation
- **THEN** the documented helper surface MUST include the corresponding `Shared/AngelscriptTestMacros.h`, `Shared/AngelscriptTestEngineHelper.h`, `Shared/AngelscriptBindingsCoverage.h`, `Shared/AngelscriptBindingsModuleBuilder.h`, `Shared/AngelscriptBindingsAssertions.h`, and `Shared/AngelscriptGlobalFunctionInvoker.h` headers

#### Scenario: Functional and reflection helpers are documented
- **WHEN** an extension test module needs UE functional world helpers or reflective property/function access
- **THEN** the documented helper surface MUST include `Shared/AngelscriptFunctionalTestUtils.h`, `Shared/AngelscriptTestWorld.h`, and `Shared/AngelscriptReflectiveAccess.h`

#### Scenario: Native SDK helpers are documented
- **WHEN** an extension test module needs pure AngelScript SDK test helpers
- **THEN** the documented stable surface MUST include `AngelScriptSDK/AngelscriptNativeTestSupport.h` and `AngelScriptSDK/AngelscriptTestAdapter.h`
- **AND** those headers SHALL remain compatible aggregation/adapter entry points

#### Scenario: Native SDK implementation headers remain internal
- **WHEN** native helper implementation is documented
- **THEN** the five headers beneath `AngelScriptSDK/Support` SHALL be described as internal themed implementation headers
- **AND** extension consumers SHALL NOT be required to include them directly

## ADDED Requirements

### Requirement: Native SDK helper implementation has five focused owners
The native SDK helper implementation SHALL be divided into engine, module, execution, compiler, and builder support headers, each with one responsibility and no test registration.

#### Scenario: Support header inventory is inspected
- **WHEN** `AngelScriptSDK/Support` is inspected
- **THEN** `AngelscriptNativeEngineTestSupport.h`, `AngelscriptNativeModuleTestSupport.h`, `AngelscriptNativeExecutionTestSupport.h`, `AngelscriptNativeCompilerTestSupport.h`, and `AngelscriptNativeBuilderTestSupport.h` SHALL exist
- **AND** the root `AngelscriptNativeTestSupport.h` SHALL aggregate them without defining helper implementations

#### Scenario: Obsolete helper implementations are searched
- **WHEN** the test module is scanned after migration
- **THEN** `AngelscriptSDKTestUtilities.h`, `AngelscriptSDKTestExecutionHelpers.h`, and the root `AngelscriptBuilderTestSupport.h` SHALL NOT exist
- **AND** there SHALL be exactly one in-memory byte stream implementation and one context invocation implementation

### Requirement: Native SDK helper contracts are deterministic
The focused support headers SHALL expose the exact ownership and lookup/execution contracts defined in `design.md` and SHALL NOT introduce alternate engine, stream, or invoker paths.

#### Scenario: Engine helper is constructed
- **WHEN** `FNativeTestEngine` is created with `BareSdk` or `ForkCompatibility`
- **THEN** it SHALL own one raw engine and one `FNativeMessageCollector`
- **AND** `BareSdk` SHALL leave optional properties at SDK defaults
- **AND** `ForkCompatibility` SHALL apply exactly the 16 recorded fork properties
- **AND** destruction SHALL release case-owned contexts/modules before shutting down the engine

#### Scenario: Module function is looked up
- **WHEN** `FScopedNativeModule::FindFunctionByDecl` is called
- **THEN** it SHALL delegate only to exact declaration lookup
- **AND** name lookup SHALL return all matches through a separate method
- **AND** no helper SHALL select a same-name or sole module function as a fallback

#### Scenario: Function is executed
- **WHEN** `FNativeFunctionInvoker` prepares and executes a function
- **THEN** arguments and return values SHALL be selected from declared type IDs
- **AND** float and double SHALL use their distinct SDK return accessors
- **AND** finished, suspended, aborted, exception, prepare failure, and execute failure SHALL remain distinct outcomes

#### Scenario: Module bytecode is persisted
- **WHEN** save/load coverage needs an in-memory stream
- **THEN** it SHALL use the one `FMemoryBinaryStream`
- **AND** the stream SHALL support reset, truncation, read-error observation, and byte inspection for positive and negative cases

#### Scenario: Compatibility adapter executes source
- **WHEN** `AngelscriptTestAdapter.h` exposes `SDKExecuteString`
- **THEN** it SHALL delegate to the focused module/context/invoker owners
- **AND** it SHALL use one documented exact entry declaration
- **AND** it SHALL have no name-only or sole-function fallback
