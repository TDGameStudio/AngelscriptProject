# as-runtime-jit-backend Specification

## Purpose
TBD - created by archiving change refactor-as-unified-jit-coordinator. Update Purpose after archive.
## Requirements
### Requirement: Runtime backends register current-revision factories

`AngelscriptRuntime` SHALL expose a current-revision `IAngelscriptRuntimeJITBackendFactory` modular feature. Runtime SHALL copy and validate stable BackendId, ABI revision, platform/configuration support, and compile-concurrency metadata before it creates an Engine-local session.

#### Scenario: Compatible backend is selected

- **WHEN** one registered factory exactly matches the configured BackendId, current ABI revision, platform, and configuration
- **THEN** the coordinator creates one backend session for that Engine
- **AND** it does not retain a transient factory metadata view after validation

#### Scenario: Backend ABI is incompatible

- **WHEN** the selected factory reports an unknown ABI revision or invalid capability metadata
- **THEN** Runtime rejects it before requesting compilation
- **AND** execution remains available through Static AOT or VM

### Requirement: Backend sessions are Engine-local

Each selected factory SHALL create an `IAngelscriptRuntimeJITBackendSession` whose compiler contexts, queues, symbol tables, and executable resources belong to one AngelScript Engine. A backend MUST NOT resolve work through a process-current Engine.

#### Scenario: Two Engines use the same backend

- **WHEN** two Engines select the same BackendId
- **THEN** each owns a distinct session and request namespace
- **AND** helper slots, machine code, cancellation, or teardown in one Engine cannot affect the other

#### Scenario: Backend requires serialized compilation

- **WHEN** a factory declares that one session is not concurrently compilable
- **THEN** the coordinator serializes requests for that session
- **AND** a separate Engine session may continue independently

### Requirement: Workers receive owned immutable snapshots

Every Runtime compile request SHALL carry an owned immutable snapshot containing stable function identity/revision, target/Entry ABI, scalar frame metadata, a backend-neutral invocation/effective-receiver/function profile, verified bytecode/control flow, and stable helper/reference tokens. A worker MUST NOT retain or query live `asIScriptFunction`, module, UObject, or UFunction pointers, and a backend MUST NOT interpret source syntax or maintained-fork `asEFuncTrait` bit values.

#### Scenario: Module is discarded after queueing

- **WHEN** a background request is queued and its source module is immediately discarded
- **THEN** the worker can finish or cancel using only snapshot/session-owned data
- **AND** it does not dereference released AngelScript or UE objects

#### Scenario: Snapshot bytecode is malformed

- **WHEN** instruction boundaries, control-flow targets, stack layout, or Entry ABI fail validation
- **THEN** the request returns `InvalidInput`
- **AND** no executable entry is published

#### Scenario: External implicit receiver is normalized before queueing

- **WHEN** a global function declares parameter zero with `external_implicit_this`
- **THEN** the coordinator retains parameter zero in the frame and records a declared-parameter receiver alias with no native object slot
- **AND** the first scalar profile selects whole-function VM fallback with `UnsupportedReceiver` before a concrete backend is invoked

#### Scenario: Neutral function profile is unknown

- **WHEN** a snapshot or direct backend-conformance view contains an unknown invocation, receiver, or function-profile value
- **THEN** validation fails closed as `InvalidInput` or typed `Unsupported`
- **AND** no backend guesses from raw trait bits or declaration text

### Requirement: Backend results have typed outcomes and code ownership

A backend session SHALL return `Compiled`, `Unsupported`, `Cancelled`, `Stale`, `BackendFailure`, or `InvalidInput`. A compiled result MUST include one VMEntry, an executable-code lease, code-size/latency metrics, and the exact snapshot revision it implements.

#### Scenario: Function subset is unsupported

- **WHEN** a valid snapshot contains semantics outside the backend's advertised first-slice subset
- **THEN** the backend returns `Unsupported` with a stable reason and optional bytecode offset
- **AND** it does not return a callable entry

#### Scenario: Compilation succeeds

- **WHEN** a backend creates valid native code for the complete function
- **THEN** its code lease owns every executable allocation and backend resource needed by the entry
- **AND** releasing an unpublished result reclaims those resources

### Requirement: Backend lowering remains host-neutral

Runtime lowering cores SHALL consume the snapshot/helper ABI without including or interpreting UObject, UFunction, Blueprint, ClassGenerator, World, GC, or Editor models. UE-specific lifecycle and Binding translation SHALL remain in the host adapter.

#### Scenario: Pure scalar function compiles

- **WHEN** a snapshot contains only the supported scalar/control-flow subset
- **THEN** the lowering core produces code without UE type information
- **AND** the host adapter publishes the resulting VMEntry through the current Binding contract

#### Scenario: Future host operation is required

- **WHEN** a later feature needs an object or function operation
- **THEN** it extends the versioned helper/reference ABI or marks the function unsupported
- **AND** it does not add UE includes or raw host addresses to backend IR generation
