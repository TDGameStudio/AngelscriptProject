## ADDED Requirements

### Requirement: Collection finalization is observed once

When development/test observation is enabled, the runtime SHALL record the global callback collection's module-load/finalization status, provider count, per-phase counts, stable identity order, duplicate errors, late-append errors, and finalization duration. Repeated reads SHALL NOT consume or rebuild the collection.

#### Scenario: Subsystem finalizes the collection

- **WHEN** generated modules have loaded and finalization succeeds
- **THEN** observation reports one successful finalization with exact provider and phase counts
- **AND** no second callback array or expanded binding data is produced for diagnostics

#### Scenario: Late provider is rejected

- **WHEN** an append is attempted after seal
- **THEN** observation retains the module, name, phase, source, restart-required status, and failure time
- **AND** the sealed order remains unchanged

### Requirement: Direct callback execution timing is recorded per engine

When built with `WITH_DEV_AUTOMATION_TESTS` or `AS_PRINT_STATS`, each full engine binding pass SHALL measure each direct provider callback. Records SHALL expose engine identity/epoch, owner module, logical bind name, source, phase, status, duration, first failure, and publication result. Builds without either define SHALL incur no per-provider clock or detailed-record storage overhead.

#### Scenario: Provider callback succeeds

- **WHEN** an engine executes a sealed callback successfully
- **THEN** observation contains one record for that engine/provider/phase with elapsed duration and success status

#### Scenario: Provider callback fails

- **WHEN** direct registration fails during one callback
- **THEN** that callback record retains the failure, elapsed duration, declaration/target context, and unpublished-engine result
- **AND** no later provider is reported as executed

#### Scenario: A second engine initializes

- **WHEN** another full engine replays the callbacks
- **THEN** it receives a distinct execution observation keyed to that engine/epoch
- **AND** global collection finalization is not repeated

#### Scenario: Observation is disabled

- **WHEN** neither `WITH_DEV_AUTOMATION_TESTS` nor `AS_PRINT_STATS` is defined
- **THEN** callback execution performs no per-provider timing calls or detailed timing allocations

### Requirement: Timing observations are queryable without side effects

The observation surface SHALL expose finalized provider order plus the selected engine's ordered callback records and seven phase totals without consuming them. It SHALL distinguish collection finalization, direct callback execution, registration failure, and engine publication.

#### Scenario: Test reads observations after engine creation

- **WHEN** a test requests timing/state after successful initialization
- **THEN** it can verify provider order, all seven phase totals, callback status, and publication status
- **AND** reading does not invoke or re-sort callbacks

#### Scenario: Repeated reads occur

- **WHEN** the same observation is queried more than once
- **THEN** each read returns equivalent data
- **AND** callback execution counts do not change

### Requirement: Top-N direct callback summaries are logged

When `AS_PRINT_STATS` is enabled, successful or failed binding initialization SHALL emit machine-grep-friendly top-N direct callback durations, with default N equal to 10, plus total duration for all seven phases. Stable columns SHALL identify engine/epoch, owner, bind, phase, status, and duration.

#### Scenario: Stats output is enabled

- **WHEN** an engine finishes or aborts direct binding with `AS_PRINT_STATS`
- **THEN** the `Angelscript` log contains top-N callback entries and seven phase totals
- **AND** it does not report legacy two-step construction/application timing categories

## REMOVED Requirements

### Requirement: Binding build and apply nodes have separate timing

**Reason**: The selected architecture directly executes callbacks and has no build/apply split or retained operation nodes.

**Migration**: Observe one-time collection finalization and per-engine direct callback execution.

### Requirement: Legacy integer-order timing remains authoritative

**Reason**: Integer `BindOrder` is replaced by seven explicit phases.

**Migration**: Use `EAngelscriptBindPhase` totals and stable provider identities.
