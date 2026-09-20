## MODIFIED Requirements

### Requirement: Shared publications never determine execution ownership

The SDK SHALL obtain execution ownership from the receiving Context or runtime object ownership and retain mutable native, adapter, auxiliary and lifetime state per Engine, even when HostProcess definitions are shared.

#### Scenario: Execute one external function with different auxiliary state

- **GIVEN** A and B inject the same host function and install local native auxiliary results 42 and 99
- **WHEN** each Engine executes that function
- **THEN** A returns 42 and B returns 99 without modifying shared definitions
- **AND** replacing or releasing A's binding does not change B's state or prematurely release an active A generation

#### Scenario: Allocate and collect objects using published type metadata

- **GIVEN** A and B admit the same host type metadata for a supported VM-managed object
- **WHEN** their Contexts allocate objects and their maintained lifetime mechanism releases them
- **THEN** every object retains its allocating owner and follows that owner's cleanup bindings
- **BUT** the common TypeId or TypeInfo pointer cannot transfer a private object's execution ownership

#### Scenario: Keep mutable type sidecars isolated

- **WHEN** A changes its adapter, type-sidecar or private template-operation state
- **THEN** B and the shared host graph remain unchanged
- **BUT** an Engine-owned mutable sidecar cannot be written into shared TypeInfo userData

#### Scenario: Retire one consumer of a shared publication

- **GIVEN** A and B use one host graph with active call/resource leases
- **WHEN** A requests shutdown, including from a native callback
- **THEN** A completes admitted cleanup while B continues executing against the unchanged shared graph
- **AND** a retained function/native lease keeps its required graph valid until release

### Requirement: Context admission validates the receiving Engine's definition set

The SDK SHALL admit HostProcess functions only when the Context's Engine has injected the exact callable and dependencies and resolves a valid retained native interface. ScriptEngine and LiveRegister callables SHALL require exact receiving-owner admission.

#### Scenario: Prepare an admitted external callable

- **GIVEN** A and B injected host Add(int,int), while C did not
- **WHEN** their Contexts prepare the same function pointer
- **THEN** A and B can execute Add(20,22) as 42
- **BUT** C returns asINVALID_ARG without executing native code

    Null GetEngine on the host function is expected, not a reason to skip directory membership, retirement or target validation.

#### Scenario: Reject a foreign private function

- **WHEN** A prepares B's ScriptEngine or LiveRegister function
- **THEN** admission fails even if names, compatible fingerprints or inspected publication facts match

## ADDED Requirements

### Requirement: Shared native interfaces retain graph and execution leases

The SDK SHALL preserve Engine-local native publication precedence and otherwise obtain an admitted HostProcess function's immutable native interface while retaining its definition graph for the complete call.

#### Scenario: Reenter another Engine and resume

- **GIVEN** A's native callback enters B using different auxiliary data
- **WHEN** B returns and A resumes
- **THEN** A's original executing owner and captured auxiliary generation are restored
- **AND** releasing the host collection during the call cannot invalidate either active interface

#### Scenario: Construct a callable wrapper from a shared host method

- **WHEN** an admitted host method is used through a supported delegate or object-call wrapper
- **THEN** reference acquisition and cleanup use the executing or explicit receiving owner
- **BUT** the wrapper cannot dereference the host function's null GetEngine as an execution owner
