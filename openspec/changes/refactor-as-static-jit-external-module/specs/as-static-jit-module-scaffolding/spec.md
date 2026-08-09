## ADDED Requirements

### Requirement: Scaffold derives a project-owned Runtime module

The plugin SHALL provide `-run=AngelscriptStaticJIT -Mode=Scaffold`, derive the module name as `<ProjectName>AngelscriptStaticJIT`, create it under the project `Source/` tree, and add a Runtime/PostDefault module descriptor to `.uproject` with a dependency on `AngelscriptRuntime`.

#### Scenario: Current host project is scaffolded

- **WHEN** Scaffold runs for `AngelscriptProject.uproject`
- **THEN** it creates module `AngelscriptProjectAngelscriptStaticJIT`
- **AND** the `.uproject` descriptor makes the module eligible for Game and Editor targets

#### Scenario: Project name contains non-identifier characters

- **WHEN** the `.uproject` base name contains characters invalid in a C++/UBT module identifier
- **THEN** Scaffold applies one documented deterministic identifier normalization
- **AND** Verify reports the derived module name consistently

### Requirement: Scaffold uses fixed translation-unit buckets

The initial scaffold SHALL create exactly 32 owned bucket `.cpp` files and generated aggregators. Function slices SHALL map to a bucket deterministically from the complete stable function key; changing the bucket count SHALL require a full scaffold/profile rebuild.

#### Scenario: Function is generated twice

- **WHEN** identical function identities and content are generated in separate runs
- **THEN** slice path, bucket assignment, aggregator ordering, provider entry ordering, and bytes are identical

#### Scenario: New function is added during an Editor session

- **WHEN** Generate adds a new function after the module was fully built
- **THEN** it updates an existing bucket aggregator and content-addressed slice
- **AND** it does not require adding a new translation unit to the active target

### Requirement: Scaffold is idempotent and protects user files

Scaffold MUST mark owned files with a scaffold version, write missing or byte-different owned files atomically, and MUST NOT overwrite arbitrary user-owned source.

#### Scenario: Scaffold runs twice without changes

- **WHEN** a valid scaffold is processed twice
- **THEN** the second run reports no changes
- **AND** it does not update timestamps/content of byte-identical files

#### Scenario: User file conflicts with an owned path

- **WHEN** a target path exists without the expected ownership/version marker
- **THEN** Scaffold stops with the conflicting path
- **AND** it does not overwrite or delete the file

### Requirement: First use requires target verification

Scaffold SHALL report that a complete Editor/Game build is required before Live Coding can update generated buckets, and Verify SHALL confirm that UBT discovers the module for both target types through the project descriptor.

#### Scenario: Module has not been built into the Editor target

- **WHEN** Generate/Refresh is requested before the scaffolded module is part of the current Editor binary/Live Coding session
- **THEN** the tool refuses Live Coding refresh with the required full-build instruction
- **AND** AS execution remains on VM

### Requirement: Generate and Verify share deterministic generation

`Mode=Generate` SHALL update owned generated artifacts for the current successful AS compilation. `Mode=Verify` SHALL generate into a temporary comparison root and fail when committed/current artifacts are missing, stale, structurally invalid, or semantically different without modifying the project module.

#### Scenario: Generated artifacts are current

- **WHEN** Verify runs with unchanged scripts, profile, generator, and scaffold
- **THEN** it reports all slices, buckets, and provider manifest current
- **AND** source files remain unmodified

#### Scenario: One slice is stale

- **WHEN** a function body changes without regenerating the project provider
- **THEN** Verify identifies the stable function key, expected content hash, bucket, and stale/missing path
- **AND** it returns failure

### Requirement: Removed functions do not remain in active manifests

Generate MUST remove deleted/renamed function entries from bucket aggregators and the provider manifest. It MAY prune an old content-addressed slice only after proving no current aggregator/manifest references it.

#### Scenario: Function is deleted

- **WHEN** Generate runs after a function is removed from successful AS compilation
- **THEN** no active provider entry or aggregator includes that function key
- **AND** Verify does not treat an unreferenced historical slice as an active entry
