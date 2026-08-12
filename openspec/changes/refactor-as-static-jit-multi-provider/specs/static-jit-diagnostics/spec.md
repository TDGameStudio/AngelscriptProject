## MODIFIED Requirements

### Requirement: StaticJIT diagnostics are available outside Shipping builds

The Runtime SHALL provide a read-only StaticJIT diagnostics surface in non-Shipping builds for inspecting every registered ProviderId/module/generation, complete artifact identities, unified JIT bindings, stable reference slots, engine-local routes, Native/VM selection, typed miss reasons including cross-Provider ambiguity, generated ownership, and execution counters. Numeric FunctionId SHALL be displayed only as transient current-engine context and SHALL NOT be used as persistent identity.

#### Scenario: Diagnostics resolve an exact current binding

- **WHEN** a non-Shipping engine compiles or restores a function that exactly matches a provider entry
- **THEN** diagnostics resolve it by canonical declaration or full stable-key hex
- **AND** report provider/generation/profile/ABI, transient FunctionId, available VM/Raw/Parms entry points, stable reference-slot resolution, current route generation, exact Native selection, and execution count

#### Scenario: Diagnostics explain a rejected binding

- **WHEN** a provider entry is rejected because function identity, execution content, profile, environment, ABI, entry-point completeness, or reference resolution differs
- **THEN** diagnostics report a typed miss reason and the expected/current values required to explain the rejection
- **AND** they report that the current VM route remains authoritative

#### Scenario: Multiple Provider modules coexist

- **WHEN** test, project, and plugin Providers are registered concurrently
- **THEN** diagnostics group entries by stable ProviderId, diagnostic UE module name, ProviderGeneration, profile, and AS StableModuleKey
- **AND** distinguish one Provider containing several AS modules from several UE modules registering Providers

#### Scenario: Different Providers conflict on one function

- **WHEN** different ProviderIds both exactly claim one complete current function identity
- **THEN** diagnostics report `AmbiguousExactProvider`, every candidate ProviderId/generation, and VM selection for that function
- **AND** unrelated functions and Providers retain their selected routes

#### Scenario: Diagnostics distinguish execution and debug-only changes

- **WHEN** two current functions have the same execution-content identity but different source/debug identities
- **THEN** diagnostics report that the Native execution artifact remains eligible
- **AND** independently report the changed debug/source identity so stale line mapping is visible

#### Scenario: Shipping excludes human diagnostics

- **WHEN** Runtime is compiled for Shipping
- **THEN** provider metadata and current bindings required for execution may remain present
- **AND** the human diagnostics API, console output, generated paths, and execution counters are not exposed

### Requirement: StaticJIT cache diagnostics do not expand the Engine public API

Provider enumeration, stable-identity lookup, Cache V2 restoration evidence, current binding inspection, route matching, reference-slot resolution, and execution-counter inspection SHALL be owned by diagnostics and artifact-routing components. They SHALL NOT add `FAngelscriptEngine::*ForTesting` cache/JIT methods or make test-only state part of the Engine public API.

#### Scenario: AOT tests inspect source and Cache V2 engines

- **WHEN** AOT tests inspect a source-compiled engine and a fresh Cache V2-restored engine
- **THEN** they use public production lifecycle/diagnostics surfaces plus test-owned fixtures and isolated paths
- **AND** they do not add or call `LoadPrecompiledDataForTesting`, `CompileLoadedPrecompiledDataForTesting`, FunctionId-only JIT lookup, or equivalent test-only Engine APIs

#### Scenario: Test probes remain outside Engine ownership

- **WHEN** tests need deterministic generated-entry counters or failure injection
- **THEN** those probes live in `AngelscriptTestJIT`, `AngelscriptTest`, or a replaceable provider/diagnostics seam
- **AND** production Engine objects do not retain test-module types or callbacks

### Requirement: StaticJIT diagnostics include a console command

The Runtime SHALL keep a non-Shipping `as.StaticJIT.DumpDiagnostics` console command and SHALL emit deterministic process/provider and current-engine reports using stable identities and the unified binding model.

#### Scenario: Dump process-level StaticJIT diagnostics

- **WHEN** a developer runs `as.StaticJIT.DumpDiagnostics` without arguments
- **THEN** the command logs every ProviderId, UE module/name, generation, profile, ABI revision, included AS-module count, compatible/rejected/conflicting entry counts, current engine route generation, Native/VM counts, unresolved reference-slot counts, miss-reason counts, and current engine availability
- **AND** it handles no provider, no current engine, and no restored cache without crashing

#### Scenario: Dump function-level StaticJIT diagnostics

- **WHEN** a developer supplies a canonical declaration or full stable-key hex
- **THEN** the command prints full and display identity, transient FunctionId, execution/debug/profile/environment/ABI comparisons, VM/Raw/Parms binding state, stable reference slots, selected or conflicting ProviderIds/generations, route state, miss reason, bucket/slice ownership, and execution count
- **AND** it reports a clear message when the identity cannot be resolved

#### Scenario: Dump output is compared across processes

- **WHEN** equivalent providers and script artifacts are dumped in separate processes
- **THEN** deterministic records use stable identities and sorted provider/function/reference entries
- **AND** process addresses, function pointers, and numeric FunctionIds are excluded from record keys

#### Scenario: Machine-readable dump supports offline inspection

- **WHEN** a developer requests the supported machine-readable diagnostics form
- **THEN** Runtime writes a schema-revisioned deterministic document containing the same provider, identity, binding, route, reference-slot, and miss-reason information
- **AND** a later Python inspection tool can consume that document without parsing human log text or loading Unreal objects
