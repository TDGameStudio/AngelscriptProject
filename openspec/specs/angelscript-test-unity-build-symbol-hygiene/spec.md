# angelscript-test-unity-build-symbol-hygiene Specification

## Purpose
TBD - created by archiving change fix-angelscript-test-unity-symbol-scope. Update Purpose after archive.
## Requirements
### Requirement: Test helper namespace imports stay local
Angelscript C++ automation test `.cpp` files SHALL NOT use file-level `using namespace` declarations for test helper/support namespaces. Test helper/support namespaces include namespaces whose purpose is scoped to test implementation, such as names ending in `_Private`, names ending in `TestHelpers`, `AngelscriptNativeTestSupport`, `AngelscriptSDKTestSupport`, and related AngelScriptSDK helper namespaces.

#### Scenario: Helper namespace used by one test method
- **WHEN** a test method needs several helpers from a test helper/support namespace
- **THEN** the `using namespace` declaration is placed inside that method body or the helper names are explicitly qualified

#### Scenario: Helper namespace used by class setup or teardown
- **WHEN** `BEFORE_ALL`, `BEFORE_EACH`, `AFTER_EACH`, or `AFTER_ALL` needs helpers from a test helper/support namespace
- **THEN** the import is local to that hook body or the helper names are explicitly qualified

#### Scenario: AngelScriptSDK support namespace used by CQTest
- **WHEN** an AngelScriptSDK CQTest uses helpers from `AngelscriptNativeTestSupport` or `AngelscriptSDKTestSupport`
- **THEN** the namespace import is placed inside each CQTest method or hook that needs it, or the helper names are explicitly qualified

### Requirement: File-private helper namespaces are explicitly qualified
Angelscript C++ automation test `.cpp` files SHALL NOT use `using namespace` directives for namespaces ending in `_Private` at any scope. The `_Private` namespace definitions MAY remain as the file-local helper ownership boundary.

#### Scenario: Private helper used by one CQTest method
- **WHEN** a CQTest method needs a helper from a namespace ending in `_Private`
- **THEN** the helper is referenced with explicit namespace qualification

#### Scenario: Private helper used by non-CQTest automation code
- **WHEN** an `IMPLEMENT_SIMPLE_AUTOMATION_TEST` body, helper function, or lambda needs a helper from a namespace ending in `_Private`
- **THEN** the helper is referenced with explicit namespace qualification

### Requirement: CQTest-owned helpers live inside the CQTest class
Angelscript C++ automation test `.cpp` files SHALL NOT define file-level namespaces ending in `_Private` when those helpers are used by a single `TEST_CLASS_WITH_FLAGS` class. Those helpers MUST be declared inside the owning CQTest class under `private:` as static functions, constants, nested structs, or ordinary fixture state as appropriate.

#### Scenario: Helper used only by one CQTest class
- **WHEN** a helper constant, nested struct, or function is used only by one `TEST_CLASS_WITH_FLAGS` class
- **THEN** the helper is moved into that class body and is not kept in a file-level `_Private` namespace

#### Scenario: CQTest methods still need registration visibility
- **WHEN** private helpers are inserted before CQTest hooks or `TEST_METHOD` declarations
- **THEN** the class restores `public:` before `BEFORE_ALL`, `BEFORE_EACH`, `AFTER_EACH`, `AFTER_ALL`, or `TEST_METHOD` declarations so CQTest registration remains valid

#### Scenario: Helper is shared by several CQTest classes
- **WHEN** a helper is intentionally shared by multiple `TEST_CLASS_WITH_FLAGS` classes in the same `.cpp`
- **THEN** the helper is moved to a shared base/helper type or the remaining file-level helper is explicitly reviewed instead of being imported with `using namespace`

### Requirement: Unity build hazards are fixed at source
Angelscript C++ automation tests SHALL remain compatible with Unreal unity build by avoiding helper-symbol patterns that leak across generated unity translation units.

#### Scenario: Two unity-included tests define same anonymous helper name
- **WHEN** two test `.cpp` files in the same generated unity chunk define a generic helper name in anonymous namespace
- **THEN** at least one helper is renamed to a file-specific name or moved to a named namespace with non-leaking use sites

#### Scenario: A generic file-scope name causes `/w4459`
- **WHEN** a test local or file-scope symbol with a generic name hides a wider symbol in a unity translation unit
- **THEN** the test symbol is renamed to a context-specific name or scoped more narrowly

### Requirement: Broad utility namespace imports are handled separately
The first-pass refactor SHALL focus on test helper/support namespaces that are known to affect unity build lookup and SHALL NOT require removing broad functional utility namespace imports such as `AngelscriptFunctionalTestUtils` unless they cause a concrete unity conflict.

#### Scenario: Shared utility namespace import appears at file scope
- **WHEN** a test `.cpp` imports a shared utility namespace used across many tests
- **THEN** the import may remain until a separate shared-utility cleanup task or a concrete collision requires changing it

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

