## MODIFIED Requirements

### Requirement: StaticJIT AOT source generation is reproducible

The test module SHALL provide a documented commandlet workflow that generates
StaticJIT C++ artifacts from committed test fixtures and detects when checked-in
generated artifacts are stale. StaticJIT AOT runtime tests SHALL provision a
validated, local precompiled cache for the current build without requiring a
cache beneath the source tree.

#### Scenario: Generate checked-in AOT source

- **WHEN** the StaticJIT AOT generation commandlet runs in generate mode
- **THEN** it writes deterministic generated StaticJIT C++ artifacts under the
Angelscript test module source tree
- **AND** it writes a matching precompiled cache only to the local ignored
StaticJIT test-cache location
- **AND** the generated artifacts correspond to the committed test fixtures

#### Scenario: Detect stale generated source

- **WHEN** the StaticJIT AOT generation commandlet runs in verify mode after
fixtures or generation logic changed
- **THEN** it compares regenerated output with the checked-in generated
artifacts
- **AND** it validates the regenerated local precompiled cache's fixture GUID,
current build identifier, and semantic fixture contents
- **AND** it reports a failure if the generated source output is stale or the
regenerated cache is invalid

#### Scenario: Runtime test provisions a missing or stale fixture cache

- **WHEN** a StaticJIT AOT runtime test needs fixture precompiled data and its
local cache is missing, malformed, uses another fixture GUID, or has a stale
build identifier
- **THEN** the test regenerates a cache under `Saved/StaticJIT/AOT/` from the
fixture before loading it
- **AND** it does not write generated C++ artifacts into the source tree
- **AND** the subsequent runtime test uses only the validated current-build
cache
