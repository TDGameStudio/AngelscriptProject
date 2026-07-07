# as-script-test-suite-runner Specification

## Purpose
TBD - created by archiving change refactor-as-script-test-suite-runner. Update Purpose after archive.
## Requirements
### Requirement: Script tests inherit a native suite base
The Angelscript test framework SHALL discover script-side tests from classes that inherit the native script test suite base rather than module-level global test functions.

#### Scenario: Derived suite class is discovered
- **WHEN** a compiled script module contains a script class derived from the native script test suite base
- **THEN** the framework registers that class as a script test suite

#### Scenario: Non-derived class is ignored
- **WHEN** a compiled script module contains a class named like a test suite that does not derive from the native script test suite base
- **THEN** the framework does not register that class as a script test suite

#### Scenario: Global test function is ignored
- **WHEN** a compiled script module contains a module-level `Test_*(FUnitTest& T)` function
- **THEN** the new script suite runner does not register it as a test

### Requirement: Suite methods use fixed lifecycle names
The Angelscript test framework SHALL recognize optional no-argument `BeforeAll`, `BeforeEach`, `AfterEach`, and `AfterAll` lifecycle methods on a discovered suite class.

#### Scenario: Lifecycle methods run around tests
- **WHEN** a suite defines lifecycle methods and one or more `Test_*` methods
- **THEN** the runner executes `BeforeAll` once before methods, `BeforeEach` before each method, `AfterEach` after each method, and `AfterAll` once after methods

### Requirement: Test methods are inherited-base instance methods
The Angelscript test framework SHALL register only no-argument suite instance methods named `Test_*` that return `void`.

#### Scenario: Valid method is registered
- **WHEN** a derived suite defines `void Test_Example()`
- **THEN** the runner registers `Test_Example` as a suite test method

#### Scenario: Invalid method signature is ignored or rejected
- **WHEN** a suite defines a `Test_*` method with an incompatible signature
- **THEN** the runner does not execute it as a valid script test method and reports a discovery diagnostic

### Requirement: Native base exposes test helper methods
The native script test suite base SHALL provide script-callable helper methods for assertions, fatal failures, fixture access, and world-backed test helpers.

#### Scenario: Test calls inherited assertion
- **WHEN** a derived suite method calls an inherited assertion helper such as `RequireEquals`
- **THEN** the helper reports through the active suite runner without requiring a context parameter

### Requirement: Native base is a transient UClass
The native script test suite base SHALL be implemented as an abstract transient native `UCLASS` derived from `UObject`, exported by the Angelscript runtime module, and usable as the code superclass for generated Angelscript test classes.

#### Scenario: Script suite derives from native UClass
- **WHEN** a script declares `class UExampleTests : UAngelscriptTestSuite`
- **THEN** the generated script class uses `UAngelscriptTestSuite` as its native superclass

#### Scenario: Runner creates generated suite instance
- **WHEN** the runner executes a discovered script suite
- **THEN** it creates a transient instance from the generated suite `UClass` before invoking `Configure`, lifecycle methods, or `Test_*` methods

#### Scenario: Runner owns injected world state
- **WHEN** a suite uses a world fixture
- **THEN** the runner injects the active `World` and `GameInstance` into the native base instance without exposing public script methods that can arbitrarily replace the fixture world

### Requirement: Fixture selection is explicit
The Angelscript test framework SHALL default script suites to a pure fixture and SHALL create engine world state only when a suite explicitly requests a world fixture.

#### Scenario: Pure fixture is default
- **WHEN** a suite has no fixture configuration
- **THEN** the runner executes it without creating a test `World` or `GameInstance`

#### Scenario: World fixture is explicit
- **WHEN** a suite configures a world fixture
- **THEN** the runner creates a transient test world for that suite execution

#### Scenario: Game instance class is per fixture
- **WHEN** a suite configures a world fixture with a game instance class
- **THEN** the runner uses that game instance class for the suite fixture instead of a global test setting

### Requirement: Assertions distinguish fatal and non-fatal failures
The native script test suite base SHALL provide non-fatal expectation APIs that continue the current method and fatal requirement APIs that stop the current method.

#### Scenario: Non-fatal expectation continues
- **WHEN** an `Expect*` assertion fails inside a `Test_*` method
- **THEN** the failure is recorded and subsequent statements in that method continue executing

#### Scenario: Fatal requirement stops method
- **WHEN** a `Require*` assertion or `Fail` fails inside a `Test_*` method
- **THEN** the failure is recorded and the current method stops before executing subsequent statements

### Requirement: Automation registration preserves suite lifecycle
The Angelscript test framework SHALL register script tests in UE Automation at suite granularity for the first implementation.

#### Scenario: Suite command runs all methods
- **WHEN** UE Automation runs a registered script suite command
- **THEN** the command executes all discovered `Test_*` methods in that suite under one lifecycle session

### Requirement: Old script test entrypoints are retired
The Angelscript test framework SHALL NOT expose old script-side global unit or integration test entrypoints through the new runner.

#### Scenario: Old unit test entrypoint is not exposed
- **WHEN** UE Automation enumerates script suite tests
- **THEN** global `Test_*(FUnitTest& T)` functions are absent from the new script suite test list

#### Scenario: Old integration test entrypoint is not exposed
- **WHEN** UE Automation enumerates script suite tests
- **THEN** global `IntegrationTest_*(FIntegrationTest& T)` functions are absent from the new script suite test list

