## MODIFIED Requirements

### Requirement: Each AngelScript Engine owns one JIT coordinator

Each `FAngelscriptEngine` SHALL install one `FAngelscriptJITCoordinator` as its sole `asIJITCompiler`. Static AOT services and optional Runtime backends MUST attach through that coordinator and MUST NOT independently replace the Engine compiler.

#### Scenario: Static AOT and two Runtime plugins are loaded

- **WHEN** the Static AOT provider registry, MIR plugin, and LLVM plugin are present in one Editor process
- **THEN** each AngelScript Engine still exposes one installed JIT compiler
- **AND** neither Runtime plugin calls `SetJITCompiler()`
- **AND** Static AOT attachment remains available while one or more Runtime backends are warm

#### Scenario: One Engine shuts down

- **WHEN** an Engine releases its JIT compiler
- **THEN** only that Engine's coordinator, Runtime sessions, requests, and code leases retire
- **AND** another Engine's coordinator and routes remain valid

### Requirement: Execution-tier selection is explicit and deterministic

The coordinator SHALL implement `Auto`, `VMOnly`, `StaticAOTOnly`, and `RuntimeOnly` modes. Runtime SHALL use a configured warm set plus one dispatch BackendId. Selection MUST NOT depend on registration order, UE module load order, pointer value, or display name.

#### Scenario: Auto mode has every tier available

- **WHEN** a current function has an exact Static AOT Binding and a compiled Binding from the dispatch Runtime backend
- **THEN** `Auto` selects the exact Static AOT Binding
- **AND** diagnostics identify AOT as the actual tier

#### Scenario: Auto mode misses AOT

- **WHEN** a current function has no exact Static AOT Binding but has a current Binding from the dispatch Runtime backend
- **THEN** `Auto` selects the Runtime Binding

#### Scenario: Forced modes isolate benchmark tiers

- **WHEN** a caller selects `VMOnly`, `StaticAOTOnly`, or `RuntimeOnly`
- **THEN** the coordinator considers only the requested Native tier and VM fallback
- **AND** `RuntimeOnly` does not silently execute an available AOT entry

#### Scenario: Runtime backend selection is invalid

- **WHEN** the configured dispatch BackendId is unknown, not available, or two catalog entries claim the same BackendId
- **THEN** Runtime compilation is disabled for that Engine with a configuration diagnostic
- **AND** Static AOT/VM selection remains deterministic and safe

#### Scenario: Two Runtime backends are warm

- **WHEN** the warm set contains two valid BackendIds and dispatch names one of them
- **THEN** both backends may hold published code for the same function revision
- **AND** only the dispatch backend’s Binding is attached

### Requirement: Every compile policy is operational

The coordinator SHALL implement `EagerSync`, `EagerBackground`, and `LazyFirstCall` through per-backend request/result/publication state. A function revision MUST have at most one active request per warm backend and policy generation. `EagerSync` applies to the dispatch backend; additional warm backends SHALL compile with `EagerBackground` so the observing safe point is not blocked on every backend.

#### Scenario: Eager synchronous compilation succeeds

- **WHEN** an eligible function first appears in an authoritative verified route under `EagerSync`
- **THEN** the coordinator compiles, validates, and publishes its dispatch Runtime Binding before that route-ready safe point returns
- **AND** the earlier function-ready callback does not invoke the backend before verified stable identity exists

#### Scenario: Eager background compilation succeeds

- **WHEN** an eligible function first appears in an authoritative verified route under `EagerBackground`
- **THEN** calls use VM while its immutable snapshot is compiled off-thread
- **AND** later calls use Runtime Native only after safe revision-checked publication

#### Scenario: Lazy first call is concurrent

- **WHEN** several threads call an eligible function revision for the first time under `LazyFirstCall`
- **THEN** exactly one caller claims the compile request for the dispatch backend
- **AND** every call that already holds the VM route completes through VM
- **AND** later calls may observe the published Runtime Binding

#### Scenario: Unsupported result is memoized

- **WHEN** a backend reports that a function revision is structurally unsupported
- **THEN** the coordinator retains VM for that revision on that backend
- **AND** later calls do not repeatedly compile the unchanged revision on that backend

#### Scenario: Non-dispatch warm backend does not block EagerSync

- **WHEN** dispatch uses `EagerSync` and a second backend is warm
- **THEN** the second backend’s compile is queued in the background
- **AND** the safe point still publishes the dispatch result before it returns when dispatch compilation succeeded
