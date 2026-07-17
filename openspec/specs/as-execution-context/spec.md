# as-execution-context Specification

## Purpose
TBD - created by archiving change refactor-as-execution-context. Update Purpose after archive.
## Requirements
### Requirement: Current AngelScript execution context is explicit
Runtime code SHALL represent the current AngelScript call-chain context through an explicit execution context instead of treating `FAngelscriptEngine` itself as the ambient global resolver.

#### Scenario: Boundary code enters an execution scope
- **WHEN** runtime, editor, commandlet, debug, or test boundary code starts work that needs a current AngelScript engine
- **THEN** it SHALL establish a scoped execution context containing the engine, optional world context, and execution phase
- **AND** nested scopes SHALL restore the previous context when they exit

#### Scenario: Code asks for current context outside a scope
- **WHEN** code requests the required current execution context and no context is active
- **THEN** the runtime SHALL report a diagnostic/check equivalent to the existing missing-engine behavior
- **AND** optional lookup SHALL be available through a non-fatal `TryCurrent` style API

### Requirement: Execution context is a non-owning view
The execution context SHALL NOT own `FAngelscriptEngine`, AS runtime objects, module registries, diagnostics stores, coverage state, debug servers, StaticJIT state, or compile/reload services.

#### Scenario: Execution context exposes core call-chain state
- **WHEN** code receives an execution context
- **THEN** it MAY access the current `FAngelscriptEngine`, `asIScriptEngine`, world context object, world, and execution phase through narrow accessors
- **AND** it SHALL NOT mutate engine-owned service lifetime through the context object

#### Scenario: Engine state needs long-lived ownership
- **WHEN** a subsystem needs state that lives with an engine instance
- **THEN** that state SHALL remain owned by the engine or an engine-attached service/extension
- **AND** the execution context SHALL only reference that engine-scoped state through explicit engine/service APIs

### Requirement: Internal helpers receive explicit dependencies
Non-boundary helper code SHALL prefer explicit dependencies over resolving the current execution context itself.

#### Scenario: Helper only needs AS script engine access
- **WHEN** a helper only needs to query or mutate `asIScriptEngine`
- **THEN** the caller SHALL pass `asIScriptEngine&` or a narrower domain context instead of requiring the helper to call a current-engine resolver

#### Scenario: Helper needs module or class lookup
- **WHEN** a helper needs module, class, enum, or delegate lookup
- **THEN** it SHALL receive a module registry, `FAngelscriptEngine&`, or other explicit domain dependency
- **AND** it SHALL NOT hide that dependency behind a new broad global accessor

### Requirement: Legacy engine access remains a compatibility bridge
`FAngelscriptEngine::Get()` and `FAngelscriptEngine::TryGetCurrentEngine()` MAY remain during migration, but they SHALL route through the execution-context resolver and SHALL NOT be the preferred API for new internal helper code.

#### Scenario: Existing call site uses engine compatibility API
- **WHEN** existing code still calls `FAngelscriptEngine::Get()` during the migration period
- **THEN** behavior SHALL remain compatible with the pre-refactor current-engine semantics
- **AND** the implementation SHALL delegate current-engine resolution to the execution-context layer

#### Scenario: New code needs current engine access
- **WHEN** new code needs current engine access
- **THEN** it SHALL either be boundary-layer code using the execution context or internal code receiving explicit dependencies
- **AND** it SHALL NOT add new direct raw-field patterns such as `FAngelscriptEngine::Get().Engine`

### Requirement: Long-lived services attach to engine lifetime
Long-lived runtime services SHALL receive engine lifetime through attach/detach or explicit ownership instead of arbitrary current-engine lookup.

#### Scenario: Service subscribes to engine hooks
- **WHEN** a coverage, crash snapshot, debug, StaticJIT, diagnostics, or reload service subscribes to engine events
- **THEN** it SHALL attach to a specific engine lifetime through `IAngelscriptExtension` or an equivalent engine-owned service boundary
- **AND** it SHALL detach or release engine-owned references before that engine shuts down

#### Scenario: Service code handles work during a request
- **WHEN** service request handling needs the active engine for a boundary operation
- **THEN** the request entry point MAY resolve the current execution context
- **AND** lower-level service helpers SHALL receive the specific engine/service/script-engine dependency they need

### Requirement: Migration guardrails prevent new god-object access
The codebase SHALL provide guardrails that prevent new direct access patterns which expand `FAngelscriptEngine` as a god object.

#### Scenario: New raw script engine access is introduced
- **WHEN** a change adds a new `FAngelscriptEngine::Get().Engine` call site outside an allowlist
- **THEN** validation SHALL flag the change
- **AND** the code SHALL use `GetScriptEngine()`, an explicit `asIScriptEngine&`, or another narrower dependency

#### Scenario: New service raw-field access is introduced
- **WHEN** a change adds new direct access to `StaticJIT`, `DebugServer`, `CodeCoverage`, or similar service fields through `FAngelscriptEngine::Get()`
- **THEN** validation or review guidance SHALL flag the change
- **AND** the code SHALL use a service accessor, engine-attached service, or explicit dependency instead

### Requirement: Execution context refactor is deferred behind subsystem-first access
The archived execution-context proposal SHALL NOT be used as the implementation plan for reducing `FAngelscriptEngine::Get()` until subsystem-first engine access has been added and evaluated.

#### Scenario: Planning current-engine access work
- **WHEN** future work targets call sites that have `WorldContextObject`, `UWorld`, or `UGameInstance`
- **THEN** the plan SHALL prefer `UAngelscriptSubsystem` lookup before introducing a general `FAngelscriptExecutionContext`
- **AND** any later execution-context proposal SHALL justify why subsystem-first and explicit dependency passing are insufficient

