## MODIFIED Requirements

### Requirement: StaticJIT AOT source generation is reproducible

The `AngelscriptTest` module SHALL own a documented test-only `-run=AngelscriptTestJIT -Mode=Generate|Verify` workflow that converts committed plugin AngelScript fixtures into deterministic provider source under the Editor-only `AngelscriptTestJIT` module. The workflow SHALL use the Runtime stable identity, current provider ABI, execution profile, per-function slice, and fixed 32-bucket emission primitives, but SHALL NOT read, scaffold, generate, verify, name, or modify any project JIT module. It SHALL NOT require or emit a legacy whole-module `.Cache` file beside the generated C++ source.

#### Scenario: Generate checked-in AOT provider source

- **WHEN** the test JIT commandlet runs in Generate mode for committed fixtures
- **THEN** it writes deterministic provider metadata, content-addressed per-function slices, and exactly 32 sorted bucket translation units under `AngelscriptTestJIT`
- **AND** every generated entry records the full stable function key, execution-content hash, profile key, ABI revision, entry-point set, and stable reference-slot requirements
- **AND** unchanged fixture functions preserve their generated paths, symbols, bucket assignment, and bytes
- **AND** no generated output is paired with a legacy test `.Cache` file

#### Scenario: Detect stale generated source

- **WHEN** the test JIT commandlet runs in Verify mode after a fixture, generator, profile, or ABI input changed
- **THEN** it regenerates into an isolated temporary root and compares provider metadata, slices, symbols, bucket membership, and owned-file inventory
- **AND** it reports every stale, missing, or unexpected artifact with its stable key and relevant content/profile/ABI hash
- **AND** it does not modify checked-in generated output

#### Scenario: Test workflow uses the production Runtime emission contract

- **WHEN** the test provider is generated
- **THEN** generation calls the same Runtime identity, function-emission, bucket, provider-ABI, and deterministic-comparison primitives exercised by production providers
- **AND** test orchestration supplies its own committed fixture selection, fixed test ProviderId, command, output root, expected probes, and isolated cache paths
- **AND** it has no dependency on project generation orchestration or the project `AngelscriptJIT` module

### Requirement: Generated StaticJIT code participates in the test build

Generated AOT fixtures SHALL compile in the Editor-only `AngelscriptTestJIT` module. `AngelscriptTestJIT` SHALL depend on `AngelscriptRuntime`, and `AngelscriptTest` SHALL depend on `AngelscriptTestJIT`; neither Runtime nor product targets SHALL depend on the test provider module.

#### Scenario: Rebuild after generation compiles generated source

- **WHEN** generated slices and bucket translation units exist under `AngelscriptTestJIT`
- **THEN** the normal Editor target build discovers and compiles the fixed bucket `.cpp` files
- **AND** module startup publishes one current provider view through the Runtime-owned provider contract
- **AND** the build does not manually enumerate per-function slices in `AngelscriptTestJIT.Build.cs`

#### Scenario: Non-Editor target excludes the test provider

- **WHEN** a Game or Shipping target is built
- **THEN** `AngelscriptTestJIT` and its generated fixtures are not part of that target
- **AND** Runtime has no dependency or conditional lookup that requires the test module

### Requirement: Runtime tests prove AOT registration and dispatch

The StaticJIT AOT suite SHALL prove that a generated provider is discovered, matched by complete stable identity, bound to the current engine through the unified JIT lifecycle, and executed through normal context and reflected call paths. It SHALL exercise both an engine compiled from current source and a second fresh engine restored through Cache V2 using an isolated test cache root.

#### Scenario: Generated provider entry is discovered

- **WHEN** `AngelscriptTestJIT` is loaded and its fixture provider is compatible
- **THEN** diagnostics enumerate the provider name, generation, profile, ABI revision, and target artifact entry
- **AND** the entry is resolved by its full stable identity rather than a persisted numeric FunctionId

#### Scenario: Test and unrelated project Providers are both registered

- **WHEN** the test Provider and one synthetic or host project Provider coexist in the Runtime Registry
- **THEN** fixture functions select only entries owned by the test ProviderId
- **AND** project functions select only entries owned by the project ProviderId
- **AND** refreshing or unregistering one Provider does not clear the other's catalog or routes

#### Scenario: Source-compiled engine receives a complete JIT binding

- **WHEN** a fixture function is compiled from current source and all identity dimensions match the provider
- **THEN** the engine publishes a complete current JIT binding containing the available VM, Raw, and Parms entry points plus engine-local reference slots
- **AND** `Context->Execute()` and representative generated `UASFunction` dispatch reach the generated entry
- **AND** arguments, reference writeback, object lifetime, exceptions, and return values match VM behavior

#### Scenario: Cache-restored fresh engine receives the same logical binding

- **WHEN** the fixture is first compiled into an isolated Cache V2 root and a second fresh engine restores the unchanged artifact set
- **THEN** the restored functions reproduce the same stable identities without reusing process-local function objects or FunctionIds
- **AND** exact provider entries bind to the second engine's own reference slots and routes
- **AND** normal execution reaches generated code with the expected result

#### Scenario: One fixture function is stale

- **WHEN** one current fixture function has a different execution-content, profile, or ABI hash while other provider entries still match
- **THEN** only the mismatched function executes through the current VM path with a typed miss reason
- **AND** matching functions continue to execute their generated bindings
- **AND** no stale Raw, Parms, or VM entry pointer remains reachable

### Requirement: Multi-engine StaticJIT constraints are visible

The StaticJIT AOT suite SHALL prove that immutable provider artifacts may be process-discoverable while stable-reference resolution, function objects, numeric FunctionIds, current bindings, route snapshots, and execution counters remain isolated per AngelScript engine.

#### Scenario: Two engines reuse numeric ids

- **WHEN** two test engines compile or restore equivalent fixtures whose numeric FunctionIds are reused or reordered
- **THEN** each engine independently matches the provider through stable identities
- **AND** each binding references that engine's current function objects, engine-local reference slots, routes, and counters

#### Scenario: One engine refreshes bindings

- **WHEN** one engine publishes a replacement compile generation or a newer provider generation
- **THEN** only that engine replaces affected bindings at a safe publication point
- **AND** the other engine's current bindings and in-flight calls remain valid

#### Scenario: Test runner proves the full generated-code loop

- **WHEN** the documented StaticJIT AOT workflow is executed from a clean checkout
- **THEN** it performs a baseline Editor build, `-run=AngelscriptTestJIT -Mode=Generate`, a rebuild, `-run=AngelscriptTestJIT -Mode=Verify`, and the targeted source/cache-restored/multi-provider engine tests in that order
- **AND** each failed stage reports the command and artifact identity needed to reproduce it
