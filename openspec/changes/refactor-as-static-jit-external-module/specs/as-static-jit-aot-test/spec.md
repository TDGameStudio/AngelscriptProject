## MODIFIED Requirements

### Requirement: StaticJIT AOT source generation is reproducible

The test module SHALL provide a documented commandlet workflow that scaffolds or uses a test StaticJIT provider module, generates deterministic per-function slices/fixed buckets/provider manifest from committed fixtures, and detects stale generated artifacts without relying on process-local FunctionIds or whole-cache `DataGuid` pairing.

#### Scenario: Generate checked-in AOT provider source

- **WHEN** the StaticJIT AOT generation commandlet runs in generate mode
- **THEN** it writes deterministic function slices, fixed-bucket aggregators, and a provider manifest under the Angelscript test provider source tree
- **AND** every entry records full stable function/content/profile/ABI identity
- **AND** generated artifacts correspond to the committed test fixtures

#### Scenario: Detect stale generated source

- **WHEN** verify mode runs after fixtures or generation logic changed
- **THEN** it compares regenerated slices, bucket membership, symbols, provider entries, and manifest semantics
- **AND** it reports a failure with the affected stable key/content hash when generated output is stale or incomplete

### Requirement: Generated StaticJIT code participates in the test build

The generated AOT fixture SHALL compile through a Runtime-dependent test provider module using the same versioned provider interface and fixed-bucket layout required of project-generated StaticJIT modules.

#### Scenario: Rebuild after generation compiles provider source

- **WHEN** generated slices and bucket aggregators exist under the test provider module source tree
- **THEN** the standard Unreal build compiles the fixed bucket `.cpp` files
- **AND** module startup registers the versioned provider view without a Runtime-to-test-module dependency

### Requirement: Runtime tests prove provider registration and routed dispatch

The StaticJIT AOT test suite SHALL prove that generated code is published through a compatible provider, matched to current AS functions by full stable identity, attached to engine-owned routes, and executed through normal script and reflected dispatch.

#### Scenario: Generated provider entry is registered

- **WHEN** the test provider module is loaded
- **THEN** diagnostics enumerate its provider name/generation/profile and target fixture entry
- **AND** the entry resolves by full stable key rather than persisted numeric FunctionId

#### Scenario: AngelScript function has a Native route

- **WHEN** the fixture module compiles with identity/content/profile/ABI matching the provider
- **THEN** the engine-owned route reports an exact Native match
- **AND** the current process FunctionId may differ from the generation process without breaking the match

#### Scenario: Normal execution reaches generated code

- **WHEN** the target fixture function is invoked through `Context->Execute()` or its generated UASFunction
- **THEN** a test-visible marker proves the selected provider entry ran
- **AND** the result, arguments, references, object lifetime, exception state, and return behavior match the interpreter

#### Scenario: One fixture function is stale

- **WHEN** one current function has a different content hash from the provider while other entries match
- **THEN** only that function executes through VM with a typed miss reason
- **AND** matching fixture functions continue to execute generated code

### Requirement: Multi-engine StaticJIT constraints are visible

The StaticJIT AOT suite SHALL prove that provider manifests are process-discoverable while function maps, route snapshots, match state, and execution counters are isolated per AngelScript engine.

#### Scenario: Two engines reuse numeric ids

- **WHEN** two test engines compile functions that reuse or reorder numeric FunctionIds
- **THEN** each engine resolves provider entries through its own stable-key map
- **AND** each route and execution marker corresponds to that engine's current function

#### Scenario: One engine refreshes routes

- **WHEN** one test engine publishes a replacement compile generation
- **THEN** its routes are rebuilt without clearing or rebinding the other engine's exact routes
