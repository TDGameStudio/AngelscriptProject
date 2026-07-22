## MODIFIED Requirements

### Requirement: StaticJIT AOT source generation is reproducible

The test module SHALL provide a documented dedicated workflow that generates
StaticJIT C++ artifacts and their matching ignored local precompiled cache from
committed test fixtures, rebuilds the generated C++, and detects when checked-in
generated artifacts are stale. StaticJIT AOT runtime tests SHALL consume the
cache only after this generated-and-compiled preparation workflow completes.

#### Scenario: Generate checked-in AOT source

- **WHEN** the StaticJIT AOT generation commandlet runs in generate mode
- **THEN** it writes deterministic generated StaticJIT C++ artifacts under the
Angelscript test module source tree
- **AND** it writes a matching precompiled cache to the ignored local
StaticJIT generated-artifact directory
- **AND** the generated artifacts correspond to the committed test fixtures

#### Scenario: Detect stale generated source

- **WHEN** the StaticJIT AOT generation commandlet runs in verify mode after
fixtures or generation logic changed
- **THEN** it compares regenerated output with the checked-in generated
artifacts
- **AND** it validates the regenerated local precompiled cache's fixture GUID,
build identifier, and semantic fixture contents
- **AND** it reports a failure if the generated source output is stale or the
regenerated cache is invalid

#### Scenario: Dedicated runner prepares the AOT artifact pair

- **WHEN** `Tools/RunStaticJITTests.ps1` is invoked
- **THEN** it performs a baseline build before invoking the AOT generation
commandlet
- **AND** it rebuilds the project after the commandlet generated the matching
cache and C++ artifacts
- **AND** it runs the requested StaticJIT automation prefix only after the
second build succeeds
- **AND** it stops at the first failed phase rather than running runtime tests
against an unmatched cache/C++ pair
