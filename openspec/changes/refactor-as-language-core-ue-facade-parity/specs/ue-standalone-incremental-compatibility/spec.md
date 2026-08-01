## ADDED Requirements

### Requirement: Unreal frontend remains authoritative
The system SHALL keep `FAngelscriptPreprocessor` and its UE descriptor/ClassGenerator path authoritative for Unreal production preprocessing unless a separately characterized bounded algorithm is explicitly switched.

#### Scenario: Standalone compatibility work begins
- **WHEN** a Standalone behavior overlaps a UE preprocessing behavior
- **THEN** the UE facade, descriptor graph, callbacks, source loading, and ClassGenerator ownership remain unchanged by default

### Requirement: Compatibility is candidate-based
Each compatibility effort SHALL identify one bounded algorithm, its observable output, and real consumers in both hosts before implementation sharing is considered.

#### Scenario: Candidate has matching needs
- **WHEN** focused UE and Standalone tests demonstrate identical required behavior
- **THEN** the candidate may evaluate duplication, host-local adaptation, or an algorithm-specific value-only helper

#### Scenario: Candidate has unexplained differences
- **WHEN** normalized results differ without an approved classification
- **THEN** production implementations remain separate

### Requirement: Shared helper boundary remains narrow
A shared compatibility helper MUST use host-neutral values and MUST NOT own source sessions, descriptors, reflection, asynchronous UE IO, callbacks, UObject/ClassGenerator state, or host lifecycle.

#### Scenario: Proposed extraction crosses a host boundary
- **WHEN** an implementation would require any prohibited ownership or expand Standalone Compat to simulate UE runtime systems
- **THEN** the extraction is rejected and host-local implementations are retained

### Requirement: Behavior evidence precedes production switching
The system SHALL characterize UE behavior and cover the matching Standalone workflow before a production host delegates to a shared or adapted implementation.

#### Scenario: Candidate is promoted
- **WHEN** both focused test sets pass and the dependency audit confirms the narrow boundary
- **THEN** production may switch only that candidate and all other algorithms retain their current owners

### Requirement: Standalone release is independent
Standalone release readiness SHALL NOT depend on completing any future cross-host compatibility candidate.

#### Scenario: No candidate is promoted
- **WHEN** the Standalone private frontend and complete offline-bundle workflow pass their release gates
- **THEN** Standalone remains releasable with duplicated host algorithms
