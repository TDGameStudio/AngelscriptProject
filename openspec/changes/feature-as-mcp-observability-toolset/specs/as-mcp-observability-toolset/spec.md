## ADDED Requirements

### Requirement: UE registers an optional AngelScript observation Toolset

The `AngelscriptToolset` Editor plugin SHALL register `UAngelscriptToolset`, a single `UToolsetDefinition` subclass, with UE 5.8 `ToolsetRegistry` when enabled and SHALL unregister it during subsystem shutdown.

#### Scenario: Toolset enabled

- **WHEN** the plugin is enabled and `as.Toolset.Enable` is nonzero during Editor subsystem initialization
- **THEN** `UAngelscriptToolset` SHALL be registered exactly once
- **AND** its UE 5.8 ToolsetRegistry name SHALL be `AngelscriptToolset.AngelscriptToolset`
- **AND** UE ToolsetRegistry SHALL generate a valid JSON schema for it

#### Scenario: Toolset disabled

- **WHEN** `as.Toolset.Enable` is zero
- **THEN** the AngelScript Toolset SHALL not remain registered

#### Scenario: Runtime cvar toggle

- **WHEN** `as.Toolset.Enable` changes after subsystem initialization
- **THEN** the subsystem SHALL reconcile against `UToolsetRegistry::IsToolsetClassRegistered`
- **AND** repeated enable or disable requests SHALL be idempotent

#### Scenario: Plugin dependency boundary

- **WHEN** the Toolset plugin is built
- **THEN** it SHALL depend on `AngelscriptRuntime` and `ToolsetRegistry`
- **AND** it SHALL NOT depend directly on `ModelContextProtocolEditor`
- **AND** its descriptor SHALL be Editor-only, disabled by default, and marked `NoRedist`

### Requirement: Toolset exposes exactly six read-only tools

The Toolset SHALL expose `GetRuntimeStatus`, `ListModules`, `GetModule`, `GetDiagnostics`, `GetDebugStatus`, and `ListBreakpoints` as static `AICallable` UFunctions returning reflected values rather than hand-authored JSON strings.

#### Scenario: Tool enumeration

- **WHEN** ToolsetRegistry enumerates `UAngelscriptToolset`
- **THEN** all six named tools SHALL be present
- **AND** no source-edit, snippet, compile, reload, coverage, asset, Blueprint, native-break, continue, pause, or step tool SHALL be present

#### Scenario: Typed output serialization

- **WHEN** ToolsetRegistry executes any AngelScript observation tool
- **THEN** it SHALL serialize the reflected return value beneath the standard `returnValue` output field
- **AND** nested structs and arrays SHALL appear in the generated output schema

### Requirement: List tools are paged and bounded

`ListModules`, `GetDiagnostics`, and `ListBreakpoints` SHALL return stable page structs containing `Items`, `Total`, `Offset`, and `Limit`.

#### Scenario: Default page

- **WHEN** a caller omits paging values
- **THEN** modules SHALL use limit 50
- **AND** diagnostics and breakpoints SHALL use limit 100
- **AND** results SHALL preserve the facade's stable ordering

#### Scenario: Invalid page

- **WHEN** offset is negative or limit is outside `1..200`
- **THEN** the tool SHALL raise a script error prefixed with `[InvalidArgument]`
- **AND** it SHALL not silently clamp the request

#### Scenario: Offset beyond total

- **WHEN** offset is greater than or equal to the current snapshot total and all paging arguments are otherwise valid
- **THEN** the tool SHALL return an empty `Items` array
- **AND** it SHALL preserve the current `Total` and requested `Offset` and `Limit`

#### Scenario: Runtime changes between pages

- **WHEN** runtime state changes between two page calls
- **THEN** each page SHALL describe its own point-in-time `Total`
- **AND** the Toolset SHALL NOT claim transactional consistency or reuse a stale cached snapshot

### Requirement: Tool failures are explicit

The Toolset SHALL distinguish a missing module from a valid empty result and SHALL return status snapshots even when the engine or DebugServer is unavailable.

#### Scenario: Unknown module

- **WHEN** `GetModule` receives a module name that is not active
- **THEN** the tool SHALL raise `[NotFound] active AngelScript module '<name>' was not found.`

#### Scenario: Empty module name

- **WHEN** `GetModule` receives an empty or whitespace-only module name
- **THEN** the tool SHALL raise `[InvalidArgument] moduleName must not be empty.`

#### Scenario: Runtime unavailable

- **WHEN** `GetRuntimeStatus` or `GetDebugStatus` runs without an AngelScript engine
- **THEN** the tool SHALL return a successful snapshot that explicitly reports unavailability
