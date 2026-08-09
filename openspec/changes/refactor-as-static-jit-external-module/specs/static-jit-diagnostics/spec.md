## MODIFIED Requirements

### Requirement: StaticJIT diagnostics are available outside Shipping builds

The Runtime SHALL provide a StaticJIT diagnostics surface in non-Shipping builds for inspecting validated providers, provider generations/profiles, current engine route generations, full stable function/content/ABI identities, Native/VM selection, typed miss reasons, generated bucket/slice ownership, and execution counts.

#### Scenario: Diagnostics resolve provider route state

- **WHEN** a non-Shipping engine compiles functions while compatible and incompatible providers are registered
- **THEN** diagnostics resolve each target by canonical declaration or full stable-key hex
- **AND** report provider/generation, current transient FunctionId, exact Native/VM state, typed mismatch reason, and execution count

#### Scenario: Shipping excludes diagnostics

- **WHEN** the Runtime is compiled for Shipping
- **THEN** provider manifests may still support execution
- **AND** the human diagnostics API/console output for manifests, routes, generated paths, or execution counters is not exposed

### Requirement: StaticJIT cache diagnostics do not expand the Engine public API

Provider enumeration, route matching, current-function identity resolution, and execution-counter inspection SHALL be owned by the StaticJIT diagnostics/provider-route surfaces and SHALL NOT add `FAngelscriptEngine::*ForTesting` cache/provider public methods.

#### Scenario: Provider tests inspect route state

- **WHEN** AOT/provider tests resolve fixture identities, provider entries, route results, and counters
- **THEN** they use the StaticJIT diagnostics surface
- **AND** they do not add Engine `LoadPrecompiledDataForTesting`, `CompileLoadedPrecompiledDataForTesting`, FunctionId-only StaticJIT lookup, or equivalent provider test APIs

### Requirement: StaticJIT diagnostics include a console command

The Runtime SHALL keep a non-Shipping console command named `as.StaticJIT.DumpDiagnostics` and extend it to report provider and engine-owned route state using stable identities.

#### Scenario: Dump process-level StaticJIT diagnostics

- **WHEN** a developer runs `as.StaticJIT.DumpDiagnostics` without arguments
- **THEN** the command logs provider names/generations/profiles, compatible/rejected counts, current engine route generation, Native/VM counts, miss-reason counts, and current engine availability
- **AND** it handles no provider or no current engine without crashing

#### Scenario: Dump function-level StaticJIT diagnostics

- **WHEN** a developer supplies a canonical declaration or stable-key hex
- **THEN** the command resolves the current function and prints full/display identity, transient FunctionId, selected provider entry kinds, content/profile/environment/ABI comparison, route state, miss reason, generated bucket/slice, and execution count
- **AND** it reports a clear message when the identity cannot be resolved

#### Scenario: Dump output is compared across processes

- **WHEN** equivalent providers and scripts are dumped in separate processes
- **THEN** provider/function ordering and persistent identity fields are deterministic
- **AND** process addresses are not used as record keys
