## ADDED Requirements

### Requirement: Replacement RuntimeBindings fixtures own explicit engines

The system SHALL expose replacement binding tests under `Angelscript.UnitTest.RuntimeBindings.<Group>.<Scenario>` using explicitly owned engines and replacement-only fixtures.

#### Scenario: Discover and execute Runtime binding tests
- **WHEN** the default editor build discovers and executes RuntimeBindings tests
- **THEN** the tests use `WITH_ANGELSCRIPT_TESTS` and own any created binding engines and contexts explicitly
- **BUT** legacy test gates, force-includes, engine pools and public test prefixes remain inactive

#### Scenario: Preserve the dormant startup baseline
- **WHEN** the host starts without an explicit binding-engine request
- **THEN** the existing dormant subsystem, services and legacy test isolation baseline remains satisfied
