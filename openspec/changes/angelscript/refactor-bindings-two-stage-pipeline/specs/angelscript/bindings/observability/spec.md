## ADDED Requirements

### Requirement: Binding work is attributable to phases and owners

The system SHALL expose consistent time and work-count observations for Record and Install and their internal steps, attributable to the capture/database and exact engine attempt where applicable.

#### Scenario: Observe a capture and two installations

- **WHEN** a host records one database and installs it into two engines with basic observation enabled
- **THEN** observations distinguish the single recording operation from both installations and their type/member/native/adapter work
- **AND** wall-clock duration, aggregate worker CPU duration and synchronization wait duration are separately labeled
- **BUT** overlapping worker CPU time is not reported as elapsed wall-clock time

#### Scenario: Detailed recording identifies worker work

- **WHEN** detailed observation is enabled for parallel recording
- **THEN** provider events and counters are associated with the owning capture even when executed on worker threads
- **AND** disabling detailed observation retains the same binding behavior and semantic result

### Requirement: Binding memory accounting distinguishes ownership and capacity

The system SHALL report binding-owned memory and retained capacity with coverage information, separating shared database resources, per-engine resources, temporary work and externally owned host references.

#### Scenario: Shared database memory is counted once

- **GIVEN** two Engines retain one database and one prepared external metadata graph with separate index/adapter instances
- **WHEN** memory observations are collected before and after destroying one engine
- **THEN** the shared database and external metadata graph are each charged once and remain retained while the surviving Engine needs them
- **AND** only the destroyed Engine's indexes, adapters and mutable execution resources are released from the corresponding accounting

#### Scenario: Capacity and host references have explicit meaning

- **WHEN** a provider fragment releases its logical entries while retaining its allocated capacity and the database retains a UObject reference
- **THEN** used entry counts may fall while allocated capacity remains reported
- **AND** the UObject reference is counted as a host reference without charging the object's transitive asset memory as Binding-owned heap
- **BUT** unavailable allocation coverage is marked unavailable rather than reported as zero owned memory

#### Scenario: UE tracing observes native allocations without duplication

- **WHEN** a traced binding operation performs a known allocation on a worker and later releases it
- **THEN** the trace exposes its native allocation/free lifetime and intended binding category together with phase/counter events
- **AND** observation does not create a second manual allocation event for the same native block

### Requirement: Performance claims use validated comparable samples

The system SHALL retain reproducible serial/parallel and baseline/final binding measurements with input, source/binary and configuration provenance, validating every timed sample's semantic outcome.

#### Scenario: Compare equivalent execution modes

- **WHEN** a benchmark compares Serial and Parallel using a fixed provider/policy input
- **THEN** it reports raw measured samples, separate warmup/first-use information, median/p95, work counts and measured memory values
- **AND** each included sample passes its expected declarations and observable call results
- **BUT** an incomplete or incorrect iteration cannot contribute to a successful performance result

#### Scenario: Observation is unavailable or disabled

- **WHEN** the selected build disables a Stats, Trace or memory observation facility
- **THEN** bindings still produce the same functional result and unsupported measurements are identified explicitly
- **BUT** observation does not create an engine, retain measured resources longer, or fabricate a successful trace capture
