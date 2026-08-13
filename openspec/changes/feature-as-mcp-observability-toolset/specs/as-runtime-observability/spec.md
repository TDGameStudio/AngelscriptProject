## ADDED Requirements

### Requirement: Runtime observations use reflected value snapshots

The runtime SHALL expose UE-reflected value types for runtime status, module summaries, diagnostics, debug status, and source breakpoints without exposing native pointer ownership.

#### Scenario: Snapshot types are reflectable

- **WHEN** a UE consumer resolves each AngelScript observation type through `StaticStruct()`
- **THEN** every snapshot type SHALL return a valid `UScriptStruct`
- **AND** all public observation fields SHALL be enumerable through UE reflection
- **AND** no field SHALL contain a raw VM, socket, memory-address, or engine-ownership pointer

#### Scenario: Section paths remain associated

- **WHEN** a module contains multiple code sections
- **THEN** each section SHALL be represented by one reflected value containing its virtual, relative, and absolute paths and section hash
- **AND** the system SHALL NOT return separate parallel path arrays whose indices can become misaligned

#### Scenario: Hash values preserve all 64 bits

- **WHEN** a module or code-section hash is observed
- **THEN** it SHALL be returned as `0x` followed by exactly 16 lowercase hexadecimal digits
- **AND** it SHALL NOT be serialized as a JSON number that can lose integer precision

### Requirement: Observation capture is side-effect-free and deterministic

`FAngelscriptObservability` SHALL capture current state without initializing, compiling, reloading, discarding, resuming, pausing, or otherwise mutating the AngelScript engine.

#### Scenario: No active engine

- **WHEN** observations are captured without an active `FAngelscriptEngine`
- **THEN** runtime status SHALL report `bEngineAvailable=false`
- **AND** collection captures SHALL return empty arrays
- **AND** no engine SHALL be created as a side effect

#### Scenario: Off-thread C++ call

- **WHEN** a native caller invokes the observability facade away from the Game Thread
- **THEN** the call SHALL violate an explicit checked C++ precondition
- **AND** normal Toolset execution SHALL never take this path because ToolsetRegistry executes the tool on the Game Thread

#### Scenario: Repeated capture ordering

- **WHEN** two captures observe the same engine state
- **THEN** modules SHALL have identical `ModuleName` ordering
- **AND** diagnostics SHALL have identical filename, location, severity, and message ordering
- **AND** source breakpoints SHALL have identical canonical source, module, resolved line, requested line, and condition ordering

### Requirement: Runtime and module state are queryable

The observation facade SHALL report lifecycle counts and stable module metadata required for local tooling.

#### Scenario: Initialized runtime status

- **WHEN** an initialized engine is captured after initial compilation
- **THEN** status SHALL report script-engine availability and initial compile completion/result
- **AND** it SHALL report active module and diagnostic severity counts
- **AND** it SHALL report product/Unreal Engine version strings
- **AND** it SHALL return stable script-root path, source-kind, and mount-name values without source contents

#### Scenario: Module summary

- **WHEN** an active module is captured
- **THEN** the result SHALL include its module name, associated section path records, exact hexadecimal code hashes, declaration counts, imports, and compile/cache flags
- **AND** it SHALL NOT include processed source code

#### Scenario: Missing module

- **WHEN** `TryCaptureModule` receives an unknown module name
- **THEN** it SHALL return `false`
- **AND** it SHALL NOT synthesize an empty successful module

### Requirement: Diagnostics are copied with stable severity

The observation facade SHALL copy diagnostics under the engine compilation lock and classify each entry as Info, Warning, or Error.

#### Scenario: Diagnostic classification

- **WHEN** engine diagnostics contain error, info, and ordinary non-error entries
- **THEN** the snapshot SHALL classify them as Error, Info, and Warning respectively
- **AND** it SHALL preserve filename, row, column, message, and compiling state

#### Scenario: Diagnostic capture preserves owner state

- **WHEN** diagnostics are captured while the dirty flag or emitted-state bookkeeping is set
- **THEN** the owner SHALL copy current `Diagnostics` under its compilation lock
- **AND** the capture SHALL NOT read `LastEmittedDiagnostics`, emit diagnostics, clear the dirty flag, remove empty files, or change emitted-state bookkeeping

### Requirement: Debug state observations are bounded, source-aware, and address-free

The observation facade SHALL expose DebugServer availability, connection/control state, pause state, and source breakpoints without exposing data breakpoint addresses or opaque value references.

#### Scenario: Debug server disabled at compile time

- **WHEN** the runtime is built with `WITH_AS_DEBUGSERVER=0`
- **THEN** debug status SHALL report `bDebugServerCompiled=false`
- **AND** source breakpoint capture SHALL return an empty array

#### Scenario: Debug server has breakpoints

- **WHEN** the active DebugServer contains conditional and ordinary source breakpoints
- **THEN** the snapshot SHALL preserve requested source, canonical source, module, requested line, resolved line, and condition from owner-maintained metadata
- **AND** no source text, value address, or data-breakpoint address SHALL be returned
- **AND** no debugger-client-local breakpoint id SHALL be synthesized or exposed

#### Scenario: Breakpoint metadata follows authoritative lifetime

- **WHEN** a source breakpoint is rejected as invalid or as a duplicate resolved line
- **THEN** no observation metadata SHALL be created or overwrite the accepted breakpoint metadata
- **AND** clearing breakpoints SHALL clear their observation metadata with the authoritative line and condition state
- **AND** reapplying breakpoints after module replacement SHALL preserve the accepted requested/resolved identity without changing hit semantics

#### Scenario: Data breakpoints are summarized without addresses

- **WHEN** configured data breakpoints are present
- **THEN** debug status SHALL report the authoritative configured data-breakpoint count
- **AND** the observation API SHALL NOT expose an address, value reference, scope, hit count, or hardware-slot identity

#### Scenario: DebugServer V2 controller status

- **WHEN** the current DebugServer has debugging clients but no exclusive-controller protocol concept
- **THEN** debug status SHALL report client and debugging-client counts
- **AND** it SHALL NOT claim that one client owns an exclusive controller lease
