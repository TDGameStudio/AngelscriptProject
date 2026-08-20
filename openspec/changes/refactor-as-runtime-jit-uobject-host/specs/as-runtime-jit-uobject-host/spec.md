## ADDED Requirements

### Requirement: Runtime JIT backends are UObject subclasses

`AngelscriptRuntime` SHALL define an abstract `UAngelscriptRuntimeJIT` UObject. Concrete backends SHALL be non-abstract subclasses. Each subclass SHALL expose a stable BackendId, display name, availability, factory metadata, and `CreateSession` that returns an Engine-local `IAngelscriptRuntimeJITBackendSession`. The UObject SHALL NOT own executable code, compile on a worker, or install `asIJITCompiler`.

#### Scenario: Plugin subclass becomes discoverable

- **WHEN** a loaded module contains a non-abstract `UAngelscriptRuntimeJIT` subclass whose `IsAvailable()` is true
- **THEN** `UAngelscriptSubsystem` includes one transient instance of that class in `AvailableJITs`
- **AND** the instance Outer is the subsystem
- **AND** AngelscriptRuntime does not link the plugin module

#### Scenario: Unavailable backend stays listed

- **WHEN** a subclass is loaded but `IsAvailable()` is false
- **THEN** the catalog still lists it
- **AND** warm/dispatch creation for that BackendId fails with `BackendUnavailable`
- **AND** VM and Static AOT remain usable

#### Scenario: Abstract base is not instantiated

- **WHEN** the catalog is rebuilt
- **THEN** `UAngelscriptRuntimeJIT` itself is not added to `AvailableJITs`

### Requirement: Subsystem catalog rebuilds when modules load

`UAngelscriptSubsystem` SHALL rebuild `AvailableJITs` from `GetDerivedClasses` during initialize and when a module that could contain backends loads or unloads. Duplicate BackendIds SHALL disable Runtime compilation until the catalog is unique.

#### Scenario: Two classes claim the same BackendId

- **WHEN** two non-abstract subclasses report the same BackendId
- **THEN** Runtime compilation is disabled with a duplicate-id diagnostic
- **AND** Static AOT and VM selection remain available

#### Scenario: Late plugin load

- **WHEN** a Runtime JIT plugin module loads after subsystem initialize
- **THEN** the next catalog rebuild includes its subclass
- **AND** already-running Engines do not automatically warm it unless that BackendId is already the configured dispatch, an extra warm name, or a live primary-Engine request

#### Scenario: Late load applies an already-configured name

- **WHEN** `RuntimeJITName=angelsea-mir` and that plugin loads after Engine init
- **THEN** the primary Engine warms and dispatches `angelsea-mir` at the next safe point
- **AND** editor restart is not required

### Requirement: Catalog discovery does not require the engine subsystem

Coordinator session creation SHALL discover `UAngelscriptRuntimeJIT` subclasses through a helper that uses `GetDerivedClasses` even when `UAngelscriptSubsystem` does not exist. `AvailableJITs` is a cached view of that helper.

#### Scenario: Test Engine with no subsystem

- **WHEN** a test constructs `FAngelscriptEngine` and a non-abstract test-module subclass is loaded
- **THEN** the coordinator can create a session for that BackendId
- **AND** it does not require `UAngelscriptSubsystem::Get()`

#### Scenario: Fakes are not in the Runtime module

- **WHEN** `AngelscriptRuntime` is loaded and `AngelscriptTest` is not
- **THEN** no fake-alpha or fake-beta `UCLASS` is present
- **AND** production Runtime JIT still depends only on real plugin subclasses when those plugins are loaded

### Requirement: Settings INI selects a registered Runtime JIT by name

Each backend SHALL expose a stable unique name equal to its BackendId via `GetBackendId()` (not `UObject::GetName`) and a separate display name that is not stored in ini. `UAngelscriptSettings` SHALL provide Config property `RuntimeJITName` under `[/Script/AngelscriptRuntime.AngelscriptSettings]` in the Engine config (not compile-options ini). Empty or `none` SHALL mean no Runtime JIT. When the named backend is registered and available, the primary Engine SHALL use it as dispatch and SHALL auto-include it in the warm set. When it is missing, unparsable, or unavailable, Runtime SHALL log a configuration diagnostic and SHALL continue with VM and Static AOT. Optional `RuntimeJITWarmNames` SHALL name extra warm backends; an unknown extra name SHALL NOT disable a valid `RuntimeJITName`. Isolated test Engines SHALL ignore these properties unless they opt in. Command line `-as-runtime-jit-backend=` SHALL override `RuntimeJITName` for that process after settings are applied. Optional `-as-runtime-jit-warm=` SHALL override `RuntimeJITWarmNames` the same way. The property SHALL NOT require an editor restart; changes apply to the primary Engine at the next Runtime JIT safe point. `GetBackendId`, display name, availability, and metadata SHALL be callable on the class default object.

#### Scenario: Named backend is registered

- **WHEN** `RuntimeJITName=angelsea-mir` and a loaded subclass reports name `angelsea-mir` with `IsAvailable()` true
- **THEN** the primary Engine warms and dispatches `angelsea-mir`

#### Scenario: Named backend is not registered

- **WHEN** `RuntimeJITName=angelsea-llvm` and no available subclass reports that name
- **THEN** Engine initialization succeeds
- **AND** no Runtime session is created
- **AND** a diagnostic names `angelsea-llvm`

#### Scenario: Empty name disables Runtime JIT

- **WHEN** `RuntimeJITName` is empty or `none`
- **THEN** the primary Engine does not create a Runtime session even if backends are registered

#### Scenario: INI stores BackendId not display name

- **WHEN** a backend’s display name is `Angelsea MIR` and its BackendId is `angelsea-mir`
- **THEN** `RuntimeJITName=Angelsea MIR` does not select it
- **AND** `RuntimeJITName=angelsea-mir` does

#### Scenario: Unknown extra warm name does not drop dispatch

- **WHEN** `RuntimeJITName=angelsea-mir` is registered and `RuntimeJITWarmNames` also lists `does-not-exist`
- **THEN** `angelsea-mir` is still warmed and dispatched
- **AND** a diagnostic names `does-not-exist`

#### Scenario: Command line overrides settings

- **WHEN** settings have `RuntimeJITName=angelsea-mir` and the process is launched with `-as-runtime-jit-backend=angelsea-llvm` while both are available
- **THEN** dispatch is `angelsea-llvm`



