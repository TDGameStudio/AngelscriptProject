## MODIFIED Requirements

### Requirement: CallBinds records per-bind execution timing in development builds

When built with `WITH_DEV_AUTOMATION_TESTS` or `AS_PRINT_STATS`, catalog snapshot materialization SHALL measure expansion definitions and store non-negative durations in `FAngelscriptBindingCatalogBuildReport`; the explicit binding applier SHALL measure package and ordinary/auxiliary node application in `FAngelscriptBindingApplyReport`. The legacy compatibility scheduler MAY additionally time opaque callbacks while `WITH_ANGELSCRIPT_LEGACY_BINDS=1`.

Shipping and Test configurations without the timing defines SHALL incur no per-expansion/per-package/per-node clock calls or timing-storage allocation.

#### Scenario: Expansion timing is recorded

- **WHEN** a development automation build materializes a snapshot containing expansion definitions
- **THEN** every executed expansion result SHALL identify PackageId, ExpansionId/revision, generated child count, status, and non-negative duration
- **AND** expansion timing SHALL remain separate from later AS/auxiliary node apply timing.

#### Scenario: Per-package and node timing is recorded

- **WHEN** a development automation build applies a catalog snapshot
- **THEN** every executed package SHALL have an ordered timing result
- **AND** every timed node SHALL identify its PackageId, NodeId, phase, owner, status, and non-negative duration.

#### Scenario: Disabled packages are not executed

- **WHEN** a snapshot resolves a package as disabled by PackageId or legacy alias
- **THEN** no node in that package SHALL execute or receive an execution duration
- **AND** the package result SHALL report a skipped status.

#### Scenario: Shipping build incurs zero timing overhead

- **WHEN** the runtime is built without `WITH_DEV_AUTOMATION_TESTS` and without `AS_PRINT_STATS`
- **THEN** snapshot materialization and the applier SHALL not call `FPlatformTime::Seconds()` per expansion/package/node
- **AND** they SHALL not allocate per-expansion/per-node timing storage.

### Requirement: Timing data is queryable for tests and diagnostics

The catalog build report SHALL expose ordered expansion/generated-child results and the apply report SHALL expose ordered package/ordinary/auxiliary-node results from one engine initialization. `FAngelscriptBindExecutionObservation` SHALL remain a non-consuming compatibility/diagnostic view over the most recent applicable reports during migration.

#### Scenario: Test reads apply timings

- **WHEN** an automation test initializes an engine and queries its binding apply report
- **THEN** the returned results SHALL preserve actual application order
- **AND** each executed entry SHALL expose stable identity and duration.

#### Scenario: Repeated reads do not consume data

- **WHEN** a test reads the same immutable apply report or observation view twice
- **THEN** both reads SHALL return identical contents.

#### Scenario: Two engines retain separate observations

- **WHEN** Engine A and Engine B apply snapshots independently
- **THEN** each engine SHALL retain its own report and AS IDs
- **AND** querying Engine B SHALL not overwrite Engine A's engine-owned result data.

### Requirement: Top-N slow-bind summary is logged when stats output is enabled

When `AS_PRINT_STATS` is defined, the runtime SHALL log machine-grep-friendly summaries of the top N slowest snapshot expansions and binding packages/nodes after successful or failed snapshot build/application, plus accumulated apply totals for `Foundation`, `Default`, and `Late`.

#### Scenario: Stats output emits slow-package summary

- **WHEN** binding application finishes with `AS_PRINT_STATS` enabled
- **THEN** the `Angelscript` log SHALL contain stable-column entries for PackageId, NodeId where applicable, phase, status, and duration
- **AND** a separate expansion summary SHALL identify PackageId, ExpansionId, revision, child count, status, and duration
- **AND** it SHALL contain phase totals for `Foundation`, `Default`, and `Late`.

#### Scenario: Legacy callback is identified explicitly

- **WHEN** an opaque legacy callback is timed in a compatibility build
- **THEN** the summary SHALL label it as legacy provenance and include its legacy bind name
- **AND** it SHALL not fabricate descriptor node identities for registrations hidden inside the callback.
