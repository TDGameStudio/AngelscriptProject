# as-bind-execution-timing Specification

## Purpose
TBD - created by archiving change refactor-as-bind-eliminate-previously-bound-function. Update Purpose after archive.
## Requirements
### Requirement: CallBinds records per-bind execution timing in development builds

When the runtime is built with `WITH_DEV_AUTOMATION_TESTS` or `AS_PRINT_STATS` defined, `FAngelscriptBinds::CallBinds` SHALL measure the wall-clock duration of each `Bind.Function()` invocation and submit a `{BindName, BindOrder, DurationMs}` record to `FAngelscriptBindExecutionObservation`. Shipping and Test-build configurations without those defines SHALL incur zero overhead from this requirement.

#### Scenario: Per-bind timing recorded under automation tests

- **WHEN** a `WITH_DEV_AUTOMATION_TESTS` build runs `FAngelscriptBinds::CallBinds`
- **THEN** for every executed bind, `FAngelscriptBindExecutionObservation` exposes a record matching that bind's name, its `int32 BindOrder`, and a non-negative duration

#### Scenario: Disabled binds are not timed

- **WHEN** `CallBinds` is invoked with a non-empty `DisabledBindNames` set in a `WITH_DEV_AUTOMATION_TESTS` build
- **THEN** `FAngelscriptBindExecutionObservation` records timing entries only for binds that actually executed; disabled binds produce no timing record

#### Scenario: Shipping build incurs zero overhead

- **WHEN** the runtime is built without `WITH_DEV_AUTOMATION_TESTS` and without `AS_PRINT_STATS`
- **THEN** `CallBinds` does not call `FPlatformTime::Seconds()` per bind and does not allocate per-bind timing storage

### Requirement: Timing data is queryable for tests and diagnostics

`FAngelscriptBindExecutionObservation` SHALL expose a public accessor that returns the recorded per-bind timing entries from the most recent `CallBinds` invocation as an ordered collection. The collection SHALL preserve the order of bind execution. Tests and diagnostics consumers SHALL be able to read the collection without resetting it.

#### Scenario: Test reads recorded timings after CallBinds

- **WHEN** an automation test triggers a fresh `FAngelscriptBinds::CallBinds` and then queries `FAngelscriptBindExecutionObservation` for recorded timings
- **THEN** the returned collection has one entry per executed bind, in the order they ran, each entry exposing `BindName`, `BindOrder`, `DurationMs`

#### Scenario: Repeated reads do not consume the data

- **WHEN** a test reads the recorded timings twice in succession after a single `CallBinds`
- **THEN** both reads return identical contents

### Requirement: Top-N slow-bind summary is logged when stats output is enabled

When `AS_PRINT_STATS` is defined, after `CallBinds` completes the runtime SHALL emit a single `UE_LOG(Angelscript, Log, ...)` summary listing the top N (default N=10) slowest binds by `DurationMs`, plus per-`EOrder` tier (Early / Normal / Late) total accumulated duration. The summary format SHALL be machine-grep-friendly (single-line entries, stable column ordering).

#### Scenario: Stats output emits slow-bind summary

- **WHEN** the runtime is built with `AS_PRINT_STATS` defined and `CallBinds` finishes
- **THEN** the `Angelscript` log channel contains a "[Profiling] CallBinds top-N" line followed by N entries showing `BindName`, `BindOrder`, `DurationMs`, plus a tier-totals line

