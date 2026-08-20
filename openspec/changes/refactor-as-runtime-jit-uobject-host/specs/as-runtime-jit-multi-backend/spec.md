## ADDED Requirements

### Requirement: Warm set is independent of dispatch

Each `FAngelscriptEngine` SHALL track a warm set of Runtime BackendIds and exactly one dispatch BackendId. Every dispatch BackendId MUST be in the warm set. Each warm BackendId SHALL own a distinct Engine-local session and request state. The coordinator SHALL publish a Runtime `SetJITBinding` only from the dispatch backend’s current published result.

#### Scenario: Two backends stay warm

- **WHEN** an Engine warms `fake-alpha` and `fake-beta` and dispatches `fake-alpha`
- **THEN** both sessions compile eligible function revisions
- **AND** only `fake-alpha` Bindings are attached
- **AND** `fake-beta` leases remain valid

#### Scenario: Dispatch must be warm

- **WHEN** a caller sets dispatch to a BackendId that is not in the warm set and is not auto-included
- **THEN** the call fails
- **AND** the previous dispatch Binding remains

#### Scenario: Load order does not pick dispatch

- **WHEN** two available backends are loaded in either module order
- **THEN** dispatch equals the configured DispatchBackendId
- **AND** it does not equal “first GetDerivedClasses result”

#### Scenario: Default is no Runtime JIT

- **WHEN** an Engine starts with empty warm set and empty dispatch, and no `-as-runtime-jit-backend=` flag
- **THEN** no Runtime session is created
- **AND** execution uses VM and Static AOT only

#### Scenario: CLI backend flag is dispatch

- **WHEN** the process is launched with `-as-runtime-jit-backend=fake-alpha`
- **THEN** dispatch is `fake-alpha`
- **AND** `fake-alpha` is in the warm set

#### Scenario: Unsupported dispatch function stays VM

- **WHEN** dispatch is `fake-alpha`, `fake-beta` is warm, and `fake-alpha` returns `Unsupported` for one function
- **THEN** that function is not given the `fake-beta` Binding
- **AND** it executes through VM until dispatch changes

### Requirement: Dispatch switch does not cancel the other backend

Changing dispatch SHALL advance only `DispatchGeneration`. It SHALL NOT cancel in-flight compiles or drop published results of backends that remain warm.

#### Scenario: Switch to an already-published backend

- **WHEN** `fake-beta` has a published result for the current function revision and the caller switches dispatch from `fake-alpha` to `fake-beta` at a safe point
- **THEN** the function’s new Runtime Binding is `fake-beta`
- **AND** `fake-alpha` code leases stay alive
- **AND** no cancellation generation advances on either session

#### Scenario: Switch before the target has compiled

- **WHEN** dispatch switches to a warm backend that has no current published result
- **THEN** new calls use VM until that backend publishes at a later safe point
- **AND** the previous dispatch backend’s unpublished work is not cancelled if it is still warm

### Requirement: Disable of the dispatch backend is refused

Removing a backend from the warm set SHALL destroy only that backend’s session after its leases drain. Removing the current dispatch backend SHALL fail until dispatch is switched to another warm backend or Runtime dispatch is cleared.

#### Scenario: Remove a non-dispatch warm backend

- **WHEN** dispatch is `fake-alpha` and `fake-beta` is removed from the warm set
- **THEN** `fake-beta` in-flight work is cancelled
- **AND** `fake-alpha` Bindings stay attached

#### Scenario: Remove dispatch without switching

- **WHEN** a caller removes the dispatch BackendId from the warm set
- **THEN** the warm set is unchanged
- **AND** a configuration diagnostic names the dispatch BackendId

### Requirement: Compare runs one Binding at a time

A compare request SHALL require `RuntimeOnly`, two or more BackendIds, and a function set. For each function it SHALL compile or reuse each backend’s current revision, switch dispatch to that backend, execute a warmup then a measured batch, and record outcome, compile latency, code size, and steady-state ns/op. It SHALL NOT attach two VMEntries to one function during a measured call. It SHALL restore the previous warm set and dispatch when the pass ends.

#### Scenario: Compare two fakes

- **WHEN** a `RuntimeOnly` Engine compares `fake-alpha` and `fake-beta` on a scalar fixture that both compile
- **THEN** each row contains that backend’s compile latency, code size, and measured ns/op
- **AND** return values match the VM oracle
- **AND** after the pass, dispatch equals the pre-compare dispatch

#### Scenario: Compare is refused in Auto

- **WHEN** an Engine in `Auto` mode is asked to compare
- **THEN** the request fails without changing Bindings
- **AND** the failure names that compare requires `RuntimeOnly`

#### Scenario: One backend unsupported

- **WHEN** `fake-alpha` compiles and `fake-beta` returns `Unsupported` for the same function
- **THEN** the compare report includes a compiled row and an unsupported row
- **AND** the pass still completes

#### Scenario: Primary Editor compare is isolated

- **WHEN** compare is requested on the primary Engine owned by `UAngelscriptSubsystem`
- **THEN** the pass runs on a temporary isolated `RuntimeOnly` Engine
- **AND** the primary Engine’s warm set, dispatch, and Bindings are unchanged when the pass ends

#### Scenario: RuntimeOnly test Engine may compare in place

- **WHEN** a test-constructed `RuntimeOnly` Engine is asked to compare
- **THEN** the pass may use that Engine
- **AND** it restores that Engine’s dispatch and warm set when the pass ends

#### Scenario: PIE copies live primary dispatch

- **WHEN** PIE starts while the Editor primary Engine has dispatch `fake-alpha` and extra warm `fake-beta`
- **THEN** the PIE Engine warms those same BackendIds and dispatches `fake-alpha`
- **AND** it does not share sessions or code leases with the Editor Engine
- **AND** later Editor console changes do not mutate the already-started PIE Engine
