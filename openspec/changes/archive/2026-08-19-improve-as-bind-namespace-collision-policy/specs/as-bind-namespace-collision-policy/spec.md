## ADDED Requirements

### Requirement: Bind-time collision observation is counted per engine
The system SHALL count exact-duplicate suppressions and incompatible same-key collisions while publishing reflected or manual functions into a canonical namespace, on the target engine's bind state.

#### Scenario: Exact duplicate increments the exact-duplicate counter
- **WHEN** an incoming function matches an existing declaration in the same namespace by complete identity
- **THEN** the existing declaration remains authoritative
- **AND** the engine's exact-duplicate counter increases by one
- **AND** initialization MUST NOT fail solely because of that exact duplicate

#### Scenario: Incompatible collision increments the incompatible counter
- **WHEN** an incoming function matches an existing callable key in the same namespace but differs in return or declaration shape
- **THEN** the engine's incompatible-collision counter increases by one
- **AND** binding MUST fail through `HasRegistrationFailure`

#### Scenario: BindScriptTypes logs a collision summary
- **WHEN** `BindScriptTypes` finishes executing registered binds
- **AND** either collision counter is greater than zero
- **THEN** the engine MUST log both counts
- **AND** the log MUST distinguish exact-duplicate from incompatible

### Requirement: Incompatible collision diagnostics keep the first failure
When multiple incompatible same-key collisions occur during one bind pass, the system SHALL retain the first published diagnostic and still fail closed.

#### Scenario: First incompatible collision is the published diagnostic
- **WHEN** two incoming functions each collide incompatibly with an already bound callable in the same namespace
- **THEN** `HasRegistrationFailure` is true
- **AND** `GetRegistrationFailureDiagnostic` identifies the first incoming owner class path and declaration
- **AND** the second incoming function is not registered

#### Scenario: Later collision does not clear the failure
- **WHEN** an incompatible collision is recorded and a later incoming function also collides
- **THEN** `bDirectBindFailed` remains true
- **AND** the later function is skipped rather than bound as a second overload

### Requirement: Exact duplicates stay suppressions
Exact complete-declaration matches MUST NOT be treated as initialization failures.

#### Scenario: Default FMath aggregation may suppress Kismet duplicates
- **WHEN** the default initialized engine maps `UKismetMathLibrary` onto `FMath`
- **AND** a Kismet static function has the same complete AS declaration as an existing manual FMath binding
- **THEN** the manual binding remains
- **AND** the engine MUST still reach a publication-ready state
