## ADDED Requirements

### Requirement: Test translation units declare direct helper dependencies
Angelscript C++ automation test `.cpp` files SHALL include the header that directly declares each test helper, macro, or support type used by that file. A file SHALL NOT depend on another `.cpp` in the same generated unity chunk to include a helper header first.

#### Scenario: SDK execution helper used by a native SDK test
- **WHEN** an AngelScriptSDK test calls `ExecuteScriptFunction` or constructs `FSdkFunctionInvoker`
- **THEN** that `.cpp` directly includes `AngelscriptSDKTestExecutionHelpers.h`

#### Scenario: Native SDK support accessor used by a parser or builder test
- **WHEN** an AngelScriptSDK test references `AngelscriptNativeTestSupport` types or functions such as `FParserAccessor`
- **THEN** that `.cpp` directly includes `AngelscriptNativeTestSupport.h` or a narrower header that declares the referenced symbol

#### Scenario: Shared engine macro used by a runtime integration test
- **WHEN** an Angelscript test uses `ASTEST_CREATE_ENGINE`, `ASTEST_GET_ENGINE`, `ASTEST_CREATE_ENGINE_FULL`, `ASTEST_CREATE_ENGINE_NATIVE`, or `ASTEST_RESET_ENGINE`
- **THEN** that `.cpp` directly includes `AngelscriptTestMacros.h`

#### Scenario: Engine acquisition helper used without macros
- **WHEN** an Angelscript test calls `CreateIsolatedFullEngine`, `AcquireTransientFullTestEngine`, or another acquisition helper directly
- **THEN** that `.cpp` directly includes `AngelscriptTestEngineAcquisition.h` or the owning helper header that declares the symbol

### Requirement: Helper namespace visibility is local and explicit
Angelscript C++ automation tests SHALL resolve helper functions through explicit namespace qualification or function-body imports. A test SHALL NOT rely on namespace directives introduced by other unity-included `.cpp` files.

#### Scenario: Functional helper used by a hot-reload test
- **WHEN** a test calls helpers from `AngelscriptFunctionalTestUtils`, such as `CompileScriptModule`, `SpawnScriptActor`, `BeginPlayActor`, or `ReadPropertyValue`
- **THEN** the call is explicitly qualified with `AngelscriptFunctionalTestUtils::` or the containing function has a local `using namespace AngelscriptFunctionalTestUtils;`

#### Scenario: Local namespace import is used for readability
- **WHEN** a test function needs several helpers from the same helper namespace
- **THEN** any `using namespace` directive is placed inside that function body and does not appear at file scope

#### Scenario: Unity chunk order changes
- **WHEN** UBT changes the generated unity chunk order or compiles a test file outside its previous chunk
- **THEN** helper lookup for that file remains unchanged because all helper namespaces are resolved by that file's own includes and local scope

### Requirement: SDK internal pointers cross public APIs explicitly
Tests that inspect AngelScript SDK internals SHALL make conversions to public SDK interfaces explicit and visible at the call site when calling runtime/test APIs declared on public AngelScript interfaces.

#### Scenario: Internal module pointer passed to public module API
- **WHEN** a test has an `asCModule*` and calls an API declared as accepting `asIScriptModule*`
- **THEN** the file includes the header that makes `asCModule : asIScriptModule` visible or casts once at the API boundary to `asIScriptModule*`

#### Scenario: StaticJIT diagnostics AOT generation uses compiled module descriptor
- **WHEN** StaticJIT AOT diagnostics generation passes `FAngelscriptModuleDesc::ScriptModule` to `GenerateStaticJITAotArtifactsForDiagnostics`
- **THEN** the call compiles without relying on unity include order for SDK class hierarchy visibility

### Requirement: Self-containment verification is repeatable
The change SHALL provide a repeatable way to verify that the reported failure class is fixed and to diagnose similar future failures.

#### Scenario: Source-level audit is run after helper include fixes
- **WHEN** the implementation updates the reported files
- **THEN** the implementer runs or records a static audit that checks the reported helper symbols against their owning includes and namespace usage

#### Scenario: Build verification is run through the standard project entry point
- **WHEN** the implementation is ready for validation
- **THEN** the implementer runs `Tools\RunBuild.ps1` with an explicit timeout and label, optionally with `-NoXGE` to remove distributed executor capacity as a variable
