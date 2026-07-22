## ADDED Requirements

### Requirement: Target-module binding lifecycle is safe

The Runtime FunctionBinding registry SHALL associate every target-module binding with the modular-feature instance that owns its descriptor storage. When that feature unregisters, the registry MUST remove pending work and all `ClassFunctionBindings` entries whose user data belongs to the feature before the source module can be unloaded.

#### Scenario: Registered target module unloads

- **WHEN** a target module unregisters its FunctionBinding feature after its descriptors have been injected
- **THEN** no Runtime binding retains a descriptor pointer or thunk ownership associated with the unloaded module

#### Scenario: Feature unregisters before deferred injection

- **WHEN** a worker-thread registration queues GameThread injection and the feature unregisters before the queued task runs
- **THEN** the queued task exits without reading the feature payload or mutating the Runtime registry

### Requirement: Target-module registration tolerates class timing

The Runtime bridge SHALL retain unresolved descriptors and retry class resolution after the relevant UObject class-registration event. A class lookup miss MUST NOT permanently discard an otherwise valid target-module descriptor.

#### Scenario: Feature arrives before UClass registration

- **WHEN** a valid feature is registered before one of its UClasses is available
- **THEN** the descriptor remains pending and is injected after the UClass becomes available

#### Scenario: Descriptor remains invalid

- **WHEN** a pending descriptor has malformed names, a null thunk, or an invalid layout version
- **THEN** the descriptor is rejected with a diagnostic and is never added to `ClassFunctionBindings`

### Requirement: Configuration has one effective meaning

Editor, UBT, and UHT SHALL resolve the same `FunctionBindingMethod`, selected module array, UE array operations, and engine distribution classification. NativeModuleFunctionAddress MUST fail closed for installed or unknown engines.

#### Scenario: Same project configuration reaches all stages

- **WHEN** a project selects a binding method and configures module arrays through UE INI syntax
- **THEN** Editor validation, Build.cs dependencies/wrappers, and UHT generated outputs use the same effective method and module set

#### Scenario: Configuration contains unsupported array operations

- **WHEN** a configuration uses an array operation that the resolver cannot interpret safely
- **THEN** the build reports a configuration error instead of silently generating a partial module set

#### Scenario: Target method uses a non-source engine

- **WHEN** NativeModuleFunctionAddress is selected for an installed or unknown engine
- **THEN** Editor, UBT, and UHT reject the selection with an actionable source-engine error

### Requirement: Native analysis fails closed

The UHT analyzer SHALL use typed UHT flags and active declaration context to classify eligible functions. It MUST NOT emit a native binding when visibility, overload identity, preprocessor state, declaration structure, or signature safety is uncertain.

#### Scenario: Declaration is ambiguous or inactive

- **WHEN** header inspection finds multiple possible declarations, an inactive preprocessor branch, or an unrecognized declaration shape
- **THEN** Runtime-linked mode emits ReflectiveFallback and target-module mode emits a skipped diagnostic with a stable failure reason

#### Scenario: Function has an unsupported target signature

- **WHEN** a target-module function uses an unsupported container, delegate, interface, out parameter, world-context, static array, or reference-return shape
- **THEN** no target-module thunk is emitted and the diagnostic identifies the required marshalling policy

#### Scenario: Callable event is owned by the event binder

- **WHEN** a UFunction is a Blueprint event handled by the dedicated event-binding path
- **THEN** the FunctionBinding generator does not emit a competing native registration for that function

### Requirement: Analysis diagnostics reconcile with output

The UHT pipeline SHALL produce one typed analysis result for every eligible function. Statistics, generated diagnostics, skipped diagnostics, and shard assignments MUST be derived from those results and reconcile without silent omissions.

#### Scenario: Runtime-linked fallback is analyzed

- **WHEN** a Runtime-linked function cannot receive a native pointer
- **THEN** diagnostics record `ReflectiveFallback`, the exact failure reason, and the generated fallback registration

#### Scenario: Target interface function is excluded

- **WHEN** a target-module interface function is not eligible for a target thunk
- **THEN** it is counted as skipped with a reason rather than counted as analyzed with no output

### Requirement: Generated output is owned and cleaned

The UHT exporter SHALL delete stale current and migration-era FunctionBinding outputs only within UHT-owned module output directories. Cleanup MUST include target-module shards, bridge probes, statistics, and retired FunctionTable artifacts.

#### Scenario: Switch from target-module to Runtime-linked mode

- **WHEN** the selected method changes from NativeModuleFunctionAddress to NativeRuntimeLinked or None
- **THEN** target-module shards and the Engine bridge probe are removed before the new output is consumed

#### Scenario: Module leaves the current UHT session

- **WHEN** a previously configured module is absent from the current session
- **THEN** the exporter reports the missing module and does not claim that its stale output has been reconciled silently

### Requirement: Runtime-linked output uses one named module source

The build integration SHALL compile one guarded aggregator per configured Runtime-linked module and UHT SHALL emit at most one `AS_FunctionBinding_<Module>.gen.cpp` source for that module. The generated callback SHALL use the stable name `UHT.FunctionBinding.<Module>` and SHALL not emit registration timing or logs. The source may contain private bounded helper functions to satisfy compiler function-size limits. Target-module thunk shards remain a distinct source-engine-only output family.

#### Scenario: Module has no Runtime-linked registrations

- **WHEN** a configured Runtime-linked module has no registrations
- **THEN** its guarded aggregator compiles without a missing generated-include error

#### Scenario: Large Runtime-linked module

- **WHEN** a Runtime-linked module exceeds the compiler-safe helper function size
- **THEN** UHT keeps one module source and one named callback while splitting registrations only into private functions inside that source

### Requirement: Target-module behavior has source-engine coverage

The project SHALL verify NativeModuleFunctionAddress on a source-built engine using the real UHT exporter, generated target-module sources, Runtime injection, late module registration, module unload, and reload. Installed-engine tests SHALL continue to verify the rejection path.

#### Scenario: Source-engine target-module build

- **WHEN** a source engine builds a project with explicit target modules
- **THEN** UHT emits target-module shards, the target modules compile them, and Runtime registers safe functions with the expected diagnostics

#### Scenario: Installed-engine rejection

- **WHEN** an installed engine is asked to build NativeModuleFunctionAddress
- **THEN** the build fails before target-module output is accepted

#### Scenario: Reload after target-module unload

- **WHEN** a target module is unloaded and loaded again
- **THEN** old descriptors are invalidated, new descriptors are registered once, and script calls do not use old module addresses

### Requirement: UHT responsibilities are independently testable

The implementation SHALL separate configuration resolution, function analysis, declaration resolution, Runtime-linked emission, target-module emission, artifact writing, and stale-output cleanup into independently testable responsibilities.

#### Scenario: Configuration parser is tested independently

- **WHEN** parser tests run against valid, layered, cleared, removed, and malformed UE INI cases
- **THEN** they verify the same normalized effective settings consumed by Build.cs and UHT

#### Scenario: Emitter receives an analysis result

- **WHEN** an emitter is tested with a fixed analysis result
- **THEN** output and diagnostics are deterministic without re-reading UHT types or reclassifying the function
