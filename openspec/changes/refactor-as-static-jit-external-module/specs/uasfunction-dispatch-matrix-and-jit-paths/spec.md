## MODIFIED Requirements

### Requirement: UASFunction wrapper allocation is covered by representative matrix tests

The ASFunction test suite SHALL assert the generated `UASFunction` subclass selected for representative function shapes and profile modes. In hot-reloadable profiles, selected wrappers MUST retain the current ScriptFunction/route handle rather than caching content-specific JIT entry pointers; immutable cooked profiles MAY select direct wrappers only after complete provider-set validation.

#### Scenario: Specialized hot-reloadable wrapper shapes are selected

- **WHEN** script class functions are generated for no-param, primitive argument, reference argument, primitive return, and object return shapes in Editor/PIE
- **THEN** each function uses the expected route-aware specialized or generic wrapper
- **AND** the wrapper reads the current function/route when invoked

#### Scenario: Generic boundaries stay generic

- **WHEN** a generated function is thread-safe, static, virtual/non-final, multi-argument, or otherwise unsupported by a specialized wrapper
- **THEN** it uses the appropriate route-aware generic wrapper
- **AND** the test documents why specialized direct dispatch is not expected

#### Scenario: Immutable cooked wrapper is selected

- **WHEN** a cooked immutable provider set passes complete profile/environment/artifact-set validation
- **THEN** an eligible function may use the expected direct JIT wrapper
- **AND** provider-set failure prevents that direct wrapper from retaining a stale pointer

### Requirement: StaticJIT AOT verifies UASFunction-backed JIT execution

The StaticJIT AOT/provider tests SHALL prove exact provider entries are reached through route-aware `UASFunction` dispatch for representative reflected script methods and that a per-function mismatch falls back to the current VM implementation.

#### Scenario: UASFunction targets expose current routes

- **WHEN** a matching AOT provider and fixture module are loaded
- **THEN** target script methods expose exact engine-owned Native routes required by UASFunction dispatch
- **AND** functions remain discoverable through generated Unreal class/function metadata

#### Scenario: RuntimeCallEvent reaches current generated code

- **WHEN** a route-aware generated `UASFunction` is invoked through reflected parameter memory
- **THEN** a generated-code marker proves the current provider entry ran
- **AND** primitive returns/arguments, reference writeback, object return identity, static/world-context behavior, and exception state match the VM

#### Scenario: Soft reload changes one UASFunction target

- **WHEN** the ScriptFunction is replaced and no matching Native entry exists for its new content
- **THEN** the same UFunction dispatch reaches the new VM function
- **AND** it does not invoke the old cached Raw/Parms/VM Native entry

### Requirement: JIT and non-JIT dispatch boundaries are explicit

Tests SHALL prove current override, thread-safe, safe-publication, and profile boundaries so Native optimization cannot bypass current AS semantics.

#### Scenario: Virtual override is not bypassed

- **WHEN** a parent generated function is invoked on a child script object that currently overrides it
- **THEN** dispatch resolves the child override before route selection
- **AND** a parent Native entry does not bypass the child

#### Scenario: Thread-safe route refresh is safe

- **WHEN** a thread-safe generated function can execute while a provider refresh is prepared
- **THEN** the active call retains a valid immutable route snapshot
- **AND** new calls observe the new snapshot only after safe publication

#### Scenario: Missing provider uses generic context behavior

- **WHEN** a function has no exact compatible provider entry
- **THEN** the route-aware wrapper executes the current VM/generic context path
- **AND** observable results remain equivalent to execution without StaticJIT
