## ADDED Requirements

### Requirement: Each AngelScript Engine owns one JIT coordinator

Each `FAngelscriptEngine` SHALL install one `FAngelscriptJITCoordinator` as its sole `asIJITCompiler`. Static AOT services and optional Runtime backends MUST attach through that coordinator and MUST NOT independently replace the Engine compiler.

#### Scenario: Static AOT and two Runtime plugins are loaded

- **WHEN** the Static AOT provider registry, MIR plugin, and LLVM plugin are present in one Editor process
- **THEN** each AngelScript Engine still exposes one installed JIT compiler
- **AND** neither Runtime plugin calls `SetJITCompiler()`
- **AND** Static AOT attachment remains available while one Runtime backend is selected

#### Scenario: One Engine shuts down

- **WHEN** an Engine releases its JIT compiler
- **THEN** only that Engine's coordinator, Runtime session, requests, and code leases retire
- **AND** another Engine's coordinator and routes remain valid

### Requirement: Execution-tier selection is explicit and deterministic

The coordinator SHALL implement `Auto`, `VMOnly`, `StaticAOTOnly`, and `RuntimeOnly` modes and SHALL select one Runtime backend by stable BackendId. Selection MUST NOT depend on registration order, UE module load order, pointer value, or display name.

#### Scenario: Auto mode has every tier available

- **WHEN** a current function has an exact Static AOT Binding and a compiled Binding from the selected Runtime backend
- **THEN** `Auto` selects the exact Static AOT Binding
- **AND** diagnostics identify AOT as the actual tier

#### Scenario: Auto mode misses AOT

- **WHEN** a current function has no exact Static AOT Binding but has a current Binding from the selected Runtime backend
- **THEN** `Auto` selects the Runtime Binding

#### Scenario: Forced modes isolate benchmark tiers

- **WHEN** a caller selects `VMOnly`, `StaticAOTOnly`, or `RuntimeOnly`
- **THEN** the coordinator considers only the requested Native tier and VM fallback
- **AND** `RuntimeOnly` does not silently execute an available AOT entry

#### Scenario: Runtime backend selection is invalid

- **WHEN** the configured BackendId is unknown or two factories claim the same BackendId
- **THEN** Runtime compilation is disabled for that Engine with a configuration diagnostic
- **AND** Static AOT/VM selection remains deterministic and safe

### Requirement: Every compile policy is operational

The coordinator SHALL implement `EagerSync`, `EagerBackground`, and `LazyFirstCall` through one request/result/publication state machine. A function revision MUST have at most one active request for the selected backend and policy generation.

#### Scenario: Eager synchronous compilation succeeds

- **WHEN** an eligible function first appears in an authoritative verified route under `EagerSync`
- **THEN** the coordinator compiles, validates, and publishes its Runtime Binding before that route-ready safe point returns
- **AND** the earlier function-ready callback does not invoke the backend before verified stable identity exists

#### Scenario: Eager background compilation succeeds

- **WHEN** an eligible function first appears in an authoritative verified route under `EagerBackground`
- **THEN** calls use VM while its immutable snapshot is compiled off-thread
- **AND** later calls use Runtime Native only after safe revision-checked publication

#### Scenario: Lazy first call is concurrent

- **WHEN** several threads call an eligible function revision for the first time under `LazyFirstCall`
- **THEN** exactly one caller claims the compile request
- **AND** every call that already holds the VM route completes through VM
- **AND** later calls may observe the published Runtime Binding

#### Scenario: Unsupported result is memoized

- **WHEN** a backend reports that a function revision is structurally unsupported
- **THEN** the coordinator retains VM for that revision
- **AND** later calls do not repeatedly compile the unchanged revision

### Requirement: Native publication is revision-safe

The coordinator SHALL publish a Runtime result only when its Engine lifetime, BackendId, stable function identity, complete content revision, Entry ABI, and cancellation generation still match the current function. Failed validation MUST leave the current route unchanged.

#### Scenario: Function changes during background compilation

- **WHEN** Hot Reload replaces a function before its background result returns
- **THEN** the result is classified as stale and its code lease is released
- **AND** the old entry is never attached to the replacement function

#### Scenario: Current result publishes

- **WHEN** every result identity and revision field still matches at an Engine safe point
- **THEN** the coordinator atomically publishes the Runtime Binding for new readers
- **AND** existing readers retain their previous immutable Binding until they exit

### Requirement: Runtime executable code uses explicit leases

Every compiled Runtime entry SHALL be owned by an Engine/backend-session code lease retained by its published Binding and any active execution reader. Backend unload, Engine shutdown, module discard, and Binding replacement MUST NOT release executable memory while an active reader can call it.

#### Scenario: Function executes during replacement

- **WHEN** a Runtime entry is active while the function is recompiled or the backend is disabled
- **THEN** replacement publishes a new route or VM for new calls
- **AND** the old code lease remains valid until the active call exits

#### Scenario: Backend session retires

- **WHEN** no current Binding, queued result, or active execution retains a backend session's code
- **THEN** the coordinator releases its executable resources and permits plugin unload

### Requirement: Runtime JIT is a whole-function VMEntry tier in the first slice

The first Runtime JIT ABI SHALL publish only a whole-function VMEntry. Any unsupported opcode, managed lifetime, call, suspend/cleanup boundary, debugger/coverage gate, or ABI mismatch MUST select VM for the complete function.

#### Scenario: Function uses an unsupported call opcode

- **WHEN** the selected backend scans a function containing a script, system, native, UFUNCTION, or interface call outside the first-slice ABI
- **THEN** no partial Native entry is published
- **AND** the complete function executes through VM with a typed fallback reason

#### Scenario: Coverage requires bytecode visibility

- **WHEN** coverage instrumentation requires the function to execute through the VM
- **THEN** the coordinator suppresses its Runtime Binding
- **AND** existing Static AOT policy is not silently redefined by the Runtime-specific gate

### Requirement: Runtime code is not an AOT artifact or cache payload

The coordinator SHALL keep Runtime results Engine-local and SHALL NOT register them as `IAngelscriptJITArtifactProvider` generations, serialize them into Cache V2, or reuse them across Engine lifetimes.

#### Scenario: Engine reloads the same bytecode

- **WHEN** a later Engine loads bytecode identical to a previously compiled Runtime function
- **THEN** it builds a new Runtime snapshot/session result or uses VM/AOT
- **AND** it cannot attach executable memory owned by the prior Engine
