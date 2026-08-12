## MODIFIED Requirements

### Requirement: UASFunction wrapper allocation is covered by representative matrix tests

The ASFunction test suite SHALL assert the generated `UASFunction` subclass selected for representative reflected ABI shapes and execution profiles. Editor/PIE and other reloadable profiles SHALL retain the current `asIScriptFunction`/engine-local route and SHALL NOT cache a content-specific Native entry pointer. An immutable cooked profile MAY select a direct wrapper only after the complete provider artifact set has passed validation.

#### Scenario: Reloadable specialized wrapper shapes are selected

- **WHEN** script class functions are generated for no-param, single primitive argument, reference argument, primitive return, and object return shapes in Editor/PIE
- **THEN** each generated function uses the expected specialized or generic route-aware `UASFunction` wrapper for its reflected ABI
- **AND** every wrapper resolves the current ScriptFunction and its current complete JIT binding when invoked

#### Scenario: Generic boundaries stay generic

- **WHEN** a generated function is thread-safe, static, virtual/non-final, multi-argument, or otherwise unsupported by a specialized wrapper
- **THEN** it uses the appropriate route-aware generic wrapper
- **AND** the test records which dispatch constraint prevents a specialized direct call
- **AND** observable script behavior remains correct

#### Scenario: Immutable cooked wrapper is selected only after complete validation

- **WHEN** a cooked immutable provider set passes complete artifact-set, profile, environment, ABI, entry-point, and reference-slot validation
- **THEN** an eligible function may use the expected direct JIT wrapper
- **AND** any validation failure retains the generic/current-route wrapper without storing a partial or stale Native pointer

### Requirement: StaticJIT AOT verifies UASFunction-backed JIT execution

The StaticJIT AOT suite SHALL prove that exact provider entries are reached through route-aware `UASFunction` dispatch for representative reflected script methods. The suite SHALL validate the complete VM/Raw/Parms binding contract in both a current-source engine and a fresh Cache V2-restored engine, and SHALL prove per-function fallback after a mismatch.

#### Scenario: UASFunction targets expose complete current bindings

- **WHEN** a matching fixture provider and script class are loaded
- **THEN** target methods expose the VM, Raw, and Parms entry points required by their wrapper shapes
- **AND** required stable reference slots resolve against the current engine
- **AND** functions remain discoverable through current Unreal class/function metadata

#### Scenario: RuntimeCallEvent reaches the current generated entry

- **WHEN** a route-aware generated `UASFunction` is invoked through reflected parameter memory
- **THEN** a generated-code probe proves the selected current provider entry ran
- **AND** primitive returns and arguments, reference writeback, object return identity, static/world-context behavior, exception state, and cleanup match VM semantics

#### Scenario: Cache-restored UASFunction dispatch uses the fresh engine

- **WHEN** a second engine restores unchanged class/function artifacts from an isolated Cache V2 root
- **THEN** the regenerated Unreal metadata and wrapper resolve that engine's current ScriptFunction, route, and reference slots
- **AND** no function object, pointer, route snapshot, or numeric FunctionId from the first engine is reused

#### Scenario: Soft reload changes one UASFunction target

- **WHEN** one ScriptFunction is replaced and no exact provider entry exists for its new execution content
- **THEN** the existing Unreal-facing function dispatch reaches the replacement VM function
- **AND** it cannot invoke the prior VM, Raw, or Parms Native entry
- **AND** unchanged methods on the same class keep their exact Native bindings

### Requirement: JIT and non-JIT dispatch boundaries are explicit

Tests SHALL prove current override selection, reload publication, thread-safe lifetime, fallback, and immutable-profile boundaries so StaticJIT optimization cannot bypass current AngelScript or Unreal dispatch semantics.

#### Scenario: Virtual override is not bypassed by a parent binding

- **WHEN** a parent generated function is invoked on a child script object that currently overrides it
- **THEN** dispatch resolves the current child ScriptFunction before selecting a JIT binding
- **AND** a matching parent Raw, Parms, or VM entry cannot bypass the child override

#### Scenario: In-flight call survives binding refresh

- **WHEN** a thread-safe or re-entrant generated call is active while a provider or script generation is replaced
- **THEN** the active call retains a valid immutable binding/route snapshot until it exits
- **AND** later calls observe the new binding only after safe publication
- **AND** release occurs exactly once after no call can reach the retired binding

#### Scenario: Missing or partial provider uses the current VM path

- **WHEN** a function has no exact compatible provider entry or lacks any required entry point/reference slot
- **THEN** the wrapper executes through the current VM/generic context path
- **AND** results and side effects remain equivalent to execution with StaticJIT disabled

#### Scenario: Immutable cooked direct calls cannot silently become stale

- **WHEN** an immutable cooked provider set was accepted for direct dispatch
- **THEN** Runtime treats the script/provider artifact set as immutable for that process
- **AND** any detected set mismatch rejects direct dispatch before execution rather than attempting an Editor-style partial refresh
