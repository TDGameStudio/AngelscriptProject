# as-engine-reflectable-state Specification

## Purpose
TBD - created by archiving change feature-as-engine-reflectable-state. Update Purpose after archive.
## Requirements
### Requirement: Engine state is observable through a UE-reflectable value view

The runtime SHALL provide a UE-reflectable value struct for observing `FAngelscriptEngine` state without exposing the engine's non-reflectable runtime resources as `UPROPERTY` ownership.

#### Scenario: State view struct is visible to UE reflection

- **WHEN** runtime code queries the snapshot type through `FAngelscriptEngineReflectionSnapshot::StaticStruct()`
- **THEN** a valid `UScriptStruct` SHALL be returned
- **AND** the struct SHALL expose its observable fields through `FProperty` enumeration
- **AND** the struct SHALL be safe to use as a value type in UE reflection contexts

#### Scenario: Non-reflectable resources are represented by summaries

- **WHEN** the value view represents AngelScript VM pointers, thread primitives, smart-pointer-owned services, injected callbacks, module maps, diagnostics maps, or hot-reload queues
- **THEN** it SHALL expose safe observation data such as booleans, counts, names, paths, timestamps, or limited previews
- **AND** it SHALL NOT expose those underlying resources as raw reflected ownership fields

### Requirement: Engine can capture side-effect-free reflectable state

`FAngelscriptEngine` SHALL expose a const capture API that reads current engine state into the reflectable value view without changing runtime behavior.

#### Scenario: Capture does not mutate engine state

- **WHEN** `CaptureReflectionSnapshot()` is called on an existing engine
- **THEN** the call SHALL NOT initialize the engine, compile modules, discard modules, emit diagnostics, change hot-reload queues, or alter the current engine context stack
- **AND** the returned value SHALL contain a point-in-time diagnostic view of the engine

#### Scenario: Initialized engine reports core lifecycle state

- **WHEN** a state view is captured from an initialized engine
- **THEN** the value view SHALL indicate that the script engine resource is present
- **AND** it SHALL report initial compile status fields
- **AND** it SHALL report package/settings/world-context observation fields using reflected object references or stable names/paths
- **AND** it SHALL report script-root and active-module summary fields

#### Scenario: Diagnostics are summarized

- **WHEN** an engine has captured compile diagnostics
- **THEN** the value view SHALL report diagnostic file count and diagnostic message count
- **AND** it SHALL distinguish error, warning, and info counts where that information exists on the engine diagnostics
- **AND** it SHALL report whether diagnostics are dirty

### Requirement: Reflectable state field coverage prioritizes high-value engine member categories

The reflectable value view SHALL provide a representative, best-effort observation surface for high-value `FAngelscriptEngine` state categories rather than only the fields that are already `UPROPERTY`.

#### Scenario: Minimum high-value observation set is present

- **WHEN** a consumer enumerates the value view's reflected properties
- **THEN** the value view SHALL include lifecycle and core resource observations
- **AND** it SHALL include package/settings/world-context observations as object references, names, or paths
- **AND** it SHALL include script root paths, active module count, diagnostic file/message/error counts, hot reload queue counts, representative service presence flags, and selected runtime configuration flags

#### Scenario: Runtime ownership categories are observable

- **WHEN** a consumer inspects a value view
- **THEN** the consumer SHALL be able to observe whether representative runtime ownership categories are present, including the core script engine and most available service categories that have low-risk presence flags in the current build configuration
- **AND** low-value or unsafe internals are not required to appear as separate fields when their surrounding category is already represented by a safer summary

#### Scenario: Collections are observable by count and preview

- **WHEN** a consumer inspects engine collections such as active modules, root paths, diagnostics, reload file queues, and selected caches
- **THEN** the value view SHALL expose counts for the most useful collections
- **AND** it SHALL expose stable string previews for root paths, active module names, diagnostics filenames, and reload filenames when those previews can be produced without private descriptor access or side effects

#### Scenario: Configuration and mode flags are observable

- **WHEN** a consumer inspects a value view
- **THEN** the value view SHALL expose reflected values for engine mode/configuration flags such as simulated cooked mode, test-error mode, hot reload, editor script usage, automatic import usage, precompiled-data usage, development mode, and runtime config summary values

