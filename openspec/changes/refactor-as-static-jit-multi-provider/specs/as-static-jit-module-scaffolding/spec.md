## ADDED Requirements

### Requirement: The plugin has a dedicated Editor-only generated-code test module

The plugin SHALL define `AngelscriptTestJIT` as an Editor/PostDefault module that depends on `AngelscriptRuntime` and is loaded before `AngelscriptTest`. `AngelscriptTest` SHALL privately depend on `AngelscriptTestJIT`; the reverse dependency MUST NOT exist. `AngelscriptTestJIT` SHALL be a fixed plugin-test target, not a project-derived or project-owned module.

#### Scenario: Test target builds generated JIT code

- **WHEN** the Editor target builds the Angelscript plugin tests
- **THEN** generated test-provider buckets compile inside `AngelscriptTestJIT`
- **AND** Automation/CQTest definitions remain owned by `AngelscriptTest`

#### Scenario: Game or Shipping target is built

- **WHEN** a non-Editor target evaluates the plugin modules
- **THEN** `AngelscriptTestJIT` and its fixture code are excluded

#### Scenario: Test-generated code needs a Native probe

- **WHEN** a generated fixture references a test-specific Native surface
- **THEN** the probe is owned/exported by `AngelscriptTestJIT` or replaced with a Runtime surface
- **AND** `AngelscriptTestJIT` never depends on `AngelscriptTest`

#### Scenario: Test JIT generation is requested

- **WHEN** the plugin test workflow runs `-run=AngelscriptTestJIT -Mode=Generate|Verify`
- **THEN** it consumes only committed plugin-test fixtures and an explicit test generation profile
- **AND** it writes or verifies only `AngelscriptTestJIT/Private/Generated`
- **AND** it does not derive a project module name, read the host project `Script/` root, inspect project JIT settings, modify `.uproject`, or emit into project `Source/`

#### Scenario: Project Scaffold is requested

- **WHEN** `-run=AngelscriptJIT -Mode=Scaffold` runs for a project
- **THEN** it does not create, rename, modify, or use `AngelscriptTestJIT`
- **AND** the committed test ProviderId and test generated output remain unchanged

### Requirement: Scaffold creates the fixed project-owned AngelscriptJIT module

The `AngelscriptEditor` module SHALL provide `-run=AngelscriptJIT -Mode=Scaffold`, create the fixed module `AngelscriptJIT` under project `Source/AngelscriptJIT`, and add a Runtime/PostDefault module descriptor to `.uproject` with a private dependency on `AngelscriptRuntime`. It SHALL NOT prefix or suffix the project name. Project tooling SHALL NOT depend on `AngelscriptTest` or `AngelscriptTestJIT`.

#### Scenario: Current host project is scaffolded

- **WHEN** Scaffold runs for `AngelscriptProject.uproject`
- **THEN** it creates `Source/AngelscriptJIT` with UE module name `AngelscriptJIT`
- **AND** the `.uproject` descriptor makes it eligible for Editor and Game targets

#### Scenario: Project Provider identity is generated

- **WHEN** Scaffold or Generate builds the Provider descriptor for `AngelscriptJIT`
- **THEN** ProviderId is derived from the canonical project/source ownership domain rather than the fixed UE module name alone
- **AND** different projects may use the same module name without sharing Provider identity

#### Scenario: Reserved module name already conflicts

- **WHEN** the project already declares an incompatible or user-owned UE module named `AngelscriptJIT`
- **THEN** Scaffold reports the exact descriptor/path conflict
- **AND** it does not derive a longer alternate name or overwrite the existing module

#### Scenario: Runtime discovers the project provider

- **WHEN** the generated module loads
- **THEN** it registers `IAngelscriptJITArtifactProvider` through modular features
- **AND** `AngelscriptRuntime` has no compile-time dependency on the project module

### Requirement: Generated targets use fixed translation-unit buckets

The committed `AngelscriptTestJIT` target and every independently generated project scaffold SHALL each contain exactly 32 owned bucket `.cpp` translation units. They SHALL use the same deterministic bucket algorithm and Provider ABI without sharing source inputs, ProviderIds, manifests, files, or output roots. Function slices SHALL map by `ReadLE64(StableFunctionKey[0..7]) mod 32`; changing bucket count SHALL change the applicable target/profile and require a full build.

#### Scenario: Function is generated twice

- **WHEN** identical function identities/content/profile are generated in separate runs
- **THEN** slice path, symbol, bucket, include ordering, reference-slot ordering, provider entry ordering, JSON metadata, and bytes are identical

#### Scenario: New function is added during an Editor session

- **WHEN** Generate adds a function after the module completed its first full build
- **THEN** it updates an existing bucket include and content-addressed slice
- **AND** it does not add a translation unit to the active Live Coding target

### Requirement: Generated implementation and provider source are content-addressed

Generated function slices SHALL use the complete StableFunctionKey and Execution hash in their path/symbol identity. Fixed module/bucket source SHALL select generated content without retaining removed entries in the active manifest.

#### Scenario: Function body changes

- **WHEN** a stable function receives new executable content
- **THEN** Generate produces a new content-addressed implementation slice
- **AND** the old slice is absent from current buckets/provider entries

#### Scenario: Function is deleted or renamed

- **WHEN** Generate runs after the current successful AS compilation removes the function
- **THEN** no active bucket/provider entry names its old key
- **AND** an unreferenced historical slice may be pruned only after active references are checked

### Requirement: Project generation supports explicit target profiles

The generated project module SHALL support `EditorDevelopment`, `GameDevelopment`, and `GameShipping` profile shards. Generate/Verify SHALL accept one of those profiles or `All`; an isolated generation Engine SHALL use explicit script preprocessor, cooked-binding, artifact-profile, and target inputs rather than inheriting incompatible Editor process assumptions.

#### Scenario: Editor profile is generated

- **WHEN** Generate selects `EditorDevelopment`
- **THEN** it includes the Editor script/binding surface and emits the matching artifact profile/environment
- **AND** Editor fixed buckets select that shard

#### Scenario: Shipping profile is generated from the tool host

- **WHEN** Generate selects `GameShipping`
- **THEN** the isolated Engine uses Shipping-equivalent `EDITOR`, `EDITORONLY_DATA`, `RELEASE`, `TEST`, cooked-binding, and artifact inputs
- **AND** the resulting provider cannot claim the Editor environment fingerprint

#### Scenario: Package profile is missing or stale

- **WHEN** package verification selects a profile without current generated artifacts
- **THEN** Verify fails before packaging acceptance with the missing/stale profile and affected identities

### Requirement: Scaffold is idempotent and protects user files

Scaffold MUST mark owned files with a scaffold revision, write missing or byte-different owned files atomically, preserve byte-identical files, and MUST NOT overwrite arbitrary user source or duplicate an existing module name.

#### Scenario: Scaffold runs twice unchanged

- **WHEN** a valid scaffold is processed twice
- **THEN** the second run reports no changes
- **AND** it does not alter bytes or timestamps of unchanged owned files

#### Scenario: User file conflicts with an owned path

- **WHEN** a target path exists without the expected ownership/revision marker
- **THEN** Scaffold stops with that path
- **AND** it does not overwrite, delete, or partially update project state

#### Scenario: Project descriptor already has conflicting module metadata

- **WHEN** `.uproject` contains the derived name with incompatible type/loading phase
- **THEN** Scaffold reports the structured conflict
- **AND** it does not append a duplicate descriptor

### Requirement: First project-module use requires a complete target build

Scaffold SHALL report that a complete Editor/Game build is required before Live Coding can update buckets. Verify SHALL validate module descriptor, Build.cs Runtime dependency, fixed bucket layout, and target discovery prerequisites.

#### Scenario: Module has not entered the active Editor target

- **WHEN** Generate/Refresh is requested before the scaffolded module is loaded in the Live Coding session
- **THEN** the tool refuses patch refresh and prints the required full-build instruction
- **AND** current functions remain VM-executable

### Requirement: Test and project generation share only deterministic emission primitives

The Runtime generation library SHALL provide common stable-identity, reference capture, function emission, bucket assignment, provider-manifest, and deterministic comparison primitives. `AngelscriptEditor` project tooling and `AngelscriptTest` test tooling SHALL supply separate source discovery, target descriptors, ProviderIds, commands, profiles, ownership roots, and outputs. Neither orchestration path SHALL call through or depend on the other.

#### Scenario: Project generated artifacts are current

- **WHEN** project `-run=AngelscriptJIT -Mode=Verify` runs with unchanged scripts, target profile, generator, scaffold, references, and environment
- **THEN** it reports all slices, buckets, provider manifest, and JSON metadata current
- **AND** source remains unmodified

#### Scenario: One slice or reference is stale

- **WHEN** current identity/content/reference slots differ from generated output
- **THEN** Verify identifies provider, profile, StableFunctionKey, expected hash/ABI, bucket, and stale path
- **AND** it returns failure

#### Scenario: Test Provider is regenerated independently

- **WHEN** `AngelscriptTest` runs `-run=AngelscriptTestJIT -Mode=Generate`
- **THEN** it writes owned output beneath `AngelscriptTestJIT/Private/Generated`
- **AND** the next normal Editor build compiles those fixed buckets
- **AND** no project module, project descriptor, project source root, or project ProviderId is read or changed
