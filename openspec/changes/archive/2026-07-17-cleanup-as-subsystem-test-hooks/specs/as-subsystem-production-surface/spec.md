## ADDED Requirements

### Requirement: Subsystem production surface contains no automation hooks

`UAngelscriptSubsystem` SHALL expose only production lifecycle and engine access behavior. Its declaration and implementation MUST NOT contain `WITH_DEV_AUTOMATION_TESTS` branches, test-only setters, test-only locator overrides, or test-only static state.

#### Scenario: Production subsystem header is compiled with unit tests enabled

- **WHEN** the plugin is built with AngelScript unit tests enabled
- **THEN** `UAngelscriptSubsystem` still has the same production public surface as a consumer build
- **AND** no `Set*ForTesting` or `Reset*ForTesting` method is available on the class

### Requirement: Scan-free engines remain fixture-owned

The `AngelscriptTest` module SHALL NOT create or inject a scan-free engine during `StartupModule`. Individual CQTest fixtures MAY create scan-free engines and scopes for their own test lifetime. `UAngelscriptSubsystem` SHALL retain its normal production startup path.

#### Scenario: A CQTest needs a scan-free engine

- **WHEN** a test fixture creates a scan-free full engine
- **THEN** the fixture owns the engine and its `FAngelscriptEngineScope`
- **AND** the production Subsystem startup path is unchanged

### Requirement: Tests use production subsystem behavior

Subsystem and runtime-module tests SHALL use ambient engine scopes, public subsystem lifecycle methods, or the real `GEngine` subsystem. They MUST NOT replace `UAngelscriptSubsystem::Get()` or inject an initialization callback into the subsystem.

#### Scenario: Subsystem adopts a test engine

- **WHEN** a test activates an `FAngelscriptEngineScope` and initializes a transient subsystem
- **THEN** the subsystem exposes the ambient engine through `GetEngine()`
- **AND** it does not claim ownership of or shut down the test-owned engine

#### Scenario: Scoped engine overrides the real subsystem fallback

- **WHEN** the real engine subsystem has a primary engine and a test activates a scoped engine
- **THEN** `FAngelscriptEngine::TryGetCurrentEngine()` returns the scoped engine inside the scope
- **AND** returns the real subsystem engine after the scope exits
