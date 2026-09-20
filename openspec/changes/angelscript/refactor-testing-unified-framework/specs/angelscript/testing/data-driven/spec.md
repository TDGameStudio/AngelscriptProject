# Data-driven replacement tests

## Purpose

Define typed, independently selectable test rows with local fixtures, reproducible
inputs and evidence that distinguishes actual execution from catalog presence.

## ADDED Requirements

### Requirement: Typed cases support source-free and source-backed inputs

The system SHALL accept C++ typed providers and admitted file-backed case data
without requiring every case to contain AS source.

#### Scenario: A pure C++ data test is registered
- **WHEN** a provider supplies typed inputs and expectations for a C++ operation
- **THEN** its rows can be discovered and executed without AS files or an engine

#### Scenario: A file-backed row fails its fixture schema
- **WHEN** decoding encounters an unknown adapter, incompatible schema or out-of-range value
- **THEN** case admission fails before executing the fixture

### Requirement: Every data row has a stable independent test identity

The system SHALL enumerate each row using its explicit RowId beneath its public
case path and SHALL reject ambiguous or stale selections.

#### Scenario: Rows are reordered
- **WHEN** a provider changes row order without changing row identities
- **THEN** each row retains its Automation path

    > Example: `Angelscript.UnitTest.NativeEngine.Lexer.IntegerLiteral.Rows.HexBoundary`.

#### Scenario: One row is selected
- **WHEN** Automation selects one valid row from the current catalog snapshot
- **THEN** only that row's fixture executes
- **AND** its result identifies the selected CaseId and RowId

#### Scenario: A provider is empty or ambiguous
- **WHEN** a provider returns no rows or repeats a RowId
- **THEN** discovery reports an invalid case definition instead of a successful empty test

    > Observables: The registered family exposes a reserved Rows.CatalogError diagnostic item that fails with the catalog errors without constructing its case fixture. Authors cannot claim that reserved RowId.

#### Scenario: A selected snapshot is stale
- **WHEN** execution receives a selection from a different catalog generation or digest
- **THEN** execution rejects the stale selection rather than resolving a different row silently

### Requirement: Data fixtures have per-item mutable ownership

The system SHALL create a fresh fixture for each executed row and keep immutable
input reuse separate from mutable execution resources.

#### Scenario: A row assertion returns early
- **WHEN** a row exits through a failed assertion
- **THEN** its teardown and registered cleanup execute while the process survives
- **AND** independently selected later rows remain executable

#### Scenario: Setup fails
- **WHEN** setup reports failure after partially acquiring resources
- **THEN** the row body does not execute and the acquired resources are cleaned up

#### Scenario: The managed process crashes
- **WHEN** the process terminates before in-process cleanup can complete
- **THEN** the run reports the crash and known cleanup state
- **BUT** it does not claim successful teardown or a passing row

### Requirement: Capability exclusions do not become passes

The system SHALL distinguish required-unavailable, explicit optional exclusion,
empty selection and executed results.

#### Scenario: A required backend is unavailable
- **WHEN** a selected case requires an unavailable execution capability
- **THEN** selection or setup reports an unavailable prerequisite and the run cannot pass on that case

#### Scenario: An optional capability is excluded
- **WHEN** selection explicitly excludes an optional capability
- **THEN** the exclusion is visible as skipped/unavailable and contributes no passing execution coverage

#### Scenario: Expected compilation failure occurs
- **WHEN** actual compilation fails with the expected structured diagnostic
- **THEN** the negative compile step passes
- **BUT** it does not claim runtime execution coverage

### Requirement: Generators are bounded and reproducible

The system SHALL bind generated cases to a recipe version, named axes and an
explicit seed/count, preserving the complete failed input for reproduction.

#### Scenario: The same recipe request is repeated
- **WHEN** recipe identity, axes, seed and count are unchanged
- **THEN** generated source and row identities are deterministic

#### Scenario: A generated row fails
- **WHEN** execution detects a mismatch
- **THEN** the report retains the source bytes, input parameters, seed, recipe version and failing observation
- **BUT** the generator does not automatically admit the result into the permanent regression corpus

### Requirement: Evidence is bound to the executed content

The system SHALL record source/data/catalog identity, selected adapter, build and
run correlation, phase results and cleanup separately from authored definitions.

#### Scenario: Evidence outlives a source edit
- **WHEN** a source or row is edited after an earlier passing run
- **THEN** the earlier result remains historical and does not establish a pass for the new content

#### Scenario: A structured diagnostic differs
- **WHEN** the observed diagnostic differs in ID, severity, range, related location or fix-it from the typed expectation
- **THEN** the result reports the differing field and expected/actual values
- **BUT** a matching rendered message alone does not erase the structural mismatch
