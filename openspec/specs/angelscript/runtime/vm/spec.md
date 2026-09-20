## Purpose

Define complete maintained AngelScript SDK interpreter execution against receiving-Engine admission and Engine-local mutable state, including shared HostProcess callables whose GetEngine remains null.

## Requirements

### Requirement: The maintained interpreter executes through explicit SDK runtime bindings

The SDK SHALL execute validated bytecode through the actual maintained interpreter and a minimal owning Engine without requiring Builder, source modules, ambient UE engines or legacy startup services.

#### Scenario: Execute hand-authored primitive and control-flow code

- **WHEN** a caller prepares a registered function with typed arguments and executes it
- **THEN** the interpreter provides the maintained primitive widths, arithmetic/conversion semantics, branching, loops, script calls, recursion and return values
- **AND** invalid arithmetic, null access or stack limits report the specified runtime failure rather than host corruption
- **BUT** successful bytecode generation or type lookup alone is not execution success

#### Scenario: Keep UE services dormant during SDK execution

- **WHEN** an explicitly owned SDK Engine executes a registered function in replacement tests
- **THEN** it requires no UClass/UObject registry, World, legacy engine pool, source compiler, Blueprint policy, DebugServer or JIT startup
- **AND** the project subsystem continues to publish no ambient engine

### Requirement: Native calls use authenticated explicit host contracts

The SDK SHALL execute supported Generic and typed caller bindings using complete checked argument, return, object-adjustment and lifetime contracts rather than persisted native pointers or legacy registration tables.

#### Scenario: Call ordinary C++ through a linked function

- **GIVEN** registered C++ storage and supported native global/member call bindings
- **WHEN** bytecode invokes the binding with primitive, reference, value or handle arguments
- **THEN** the native callback receives the correct values, receiver adjustment and out/inout storage, and its result reaches the VM caller

    > Supported call shapes include the maintained Generic/typed-caller forms of global, member, object-first and object-last calls. Native ownership follows registered behaviours, not pointer guesses.

#### Scenario: Reject unsupported native calling contracts

- **WHEN** the binding requests an unsupported platform ABI, wrong calling convention, incompatible signature or absent caller
- **THEN** preparation/linking reports an explicit unsupported or incompatible binding and exposes no callable body
- **BUT** dormant architecture-specific assembly backends are not silently reactivated or counted as passed coverage

#### Scenario: Replace a live native binding

- **GIVEN** a live Engine with an installed native binding and unchanged frozen callable declarations
- **WHEN** the host replaces that binding, including from inside its active callback
- **THEN** the complete replacement becomes available atomically and an active call retains its original callback and cleanup contract through return

    > Subsequent calls may use the replacement. Concurrent acquisition observes a complete generation; replacing a binding does not change the declaration's signature or runtime-independent metadata.

- **AND** the replaced generation remains readable while a call or explicit binding lease owns it and is reclaimed after its final owner releases it
- **BUT** an invalid replacement or retired Engine cannot publish new work or discard a previously installed binding needed for remaining cleanup

    > Retirement stops new execution admission. The Engine may retain its last installed native bindings while existing Contexts and objects finish cleanup; this does not keep historical replaced generations indefinitely.

### Requirement: SDK objects preserve dynamic type and complete lifetime semantics

The SDK SHALL own AS object identity, payload storage, reference/weak state and construction lifecycle independently of Unreal object registries while preserving native caller ownership.

#### Scenario: Construct and destroy an AS object with fields

- **WHEN** executable code allocates, constructs, copies, assigns and destroys an AS object
- **THEN** its dynamic ObjectType, field values, constructor/destructor effects and reference ownership are correct
- **AND** public object pointers and metadata field offsets address the payload rather than a hidden runtime header

    > Inline by-value instances have payload layout without an independent heap-reference header. Ordinary C++ objects keep their original storage and are managed only through their declared behaviours.

#### Scenario: Unwind partial construction

- **GIVEN** a compound object whose later member constructor raises a VM exception
- **WHEN** construction aborts
- **THEN** only already initialized members are destroyed, in reverse order, exactly once
- **AND** temporary references and allocated storage are released without accessing a retired callable or type

#### Scenario: Dispatch and cast through the actual dynamic type

- **WHEN** code invokes virtual/interface methods, casts base/derived values, or invokes funcdefs, delegates and stable bound-call slots
- **THEN** dispatch selects the correct target and receiver and rejects invalid or null targets explicitly
- **BUT** bound-call slots do not reintroduce the removed source `import` keyword

### Requirement: SDK cycle collection and weak references honor live roots

The SDK SHALL reclaim unreachable AS cycles and invalidate weak references while preserving externally retained and actively executing objects.

#### Scenario: Collect cycles without losing live objects

- **GIVEN** self-cycles, two-object cycles and delegate captures together with an externally or Context-rooted object
- **WHEN** incremental or full collection runs
- **THEN** unreachable objects finalize exactly once and live roots remain usable
- **AND** weak references become invalid only when their target lifetime ends

    > Type/function metadata leases and runtime object references are distinct roots with distinct ownership; neither is inferred from a cached ID.

### Requirement: Context control and shutdown retain valid cleanup bindings

The SDK SHALL support suspension, resumption, abort, reuse, nesting, exceptions and independent contexts with explicit code/runtime leases and cleanup-safe shutdown.

#### Scenario: Suspend and resume a linked call

- **WHEN** execution suspends and later resumes without changing its function's runtime bytecode
- **THEN** its arguments, locals, object roots and next instruction remain valid and final results match uninterrupted execution
- **BUT** suspension is not normal completion and abort never resumes the abandoned body

#### Scenario: Restore nested context state after failure

- **GIVEN** a native callback that enters another SDK Context
- **WHEN** the inner call returns, raises an exception or aborts
- **THEN** active-context/TLS state returns to the outer call and cleanup is balanced
- **AND** subsequent valid Prepare/Execute operations do not inherit stale exception or stack state

#### Scenario: Shut down with active execution and retained metadata

- **WHEN** Engine shutdown begins while contexts or runtime objects still own executable resources
- **THEN** new admissions stop and active calls/objects are cleaned before bindings and IDs retire

    | Operation after the shutdown request | Observable behavior |
    |---|---|
    | New public Prepare, Execute, definition registration or native/global binding | Rejected without replacing retained cleanup bindings |
    | An already executing call | Keeps the code, IDs and native contracts required for its continuation |
    | Destruction of an already owned object | Can invoke script or native destructors and release temporary objects through owned cleanup services |

- **AND** a shutdown request from inside an active callback defers final destruction until the callback exits

    > Unreachable object cycles are eligible for collection after the outer execution returns; the application does not need an otherwise unused Engine owner solely to trigger that drain.

- **BUT** a retained metadata pointer alone cannot prepare or execute after retirement

#### Scenario: Release the last runtime object after its host owners

- **GIVEN** an SDK object whose producer, caller-held function runtime bytecode and host Engine owners have been released
- **WHEN** its last external runtime reference is released
- **THEN** its native or script destructor completes exactly once with its required type, code and native bindings still valid

    > A script destructor may call a helper from a separately registered function. Ownership covers the complete cleanup dependency path, not only the destructor declaration.

- **AND** object, collector and Engine ownership is released after cleanup without a permanent reference cycle
- **BUT** internal cleanup authority does not reopen public execution or reattach retired definitions

    Releasing a function after Engine destruction cannot call its former Engine.

#### Scenario: Handle maintained marker and observer instructions

- **WHEN** execution reaches `JitEntry`, `SaveReturnValue`, object-resolution or reference-debug instructions
- **THEN** VM markers advance without a JIT backend and optional SDK hooks follow their explicit enabled/disabled contract
- **AND** `DestructScript` performs its destruction contract and advances, while `ThrowException` reports a real VM exception

    > No optional observer requires UE startup. Disabled observers still advance; a commented handler that makes no progress is not valid no-op behaviour.

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

### Requirement: Prepare reads Function runtime bytecode

The SDK SHALL admit a script callable only when that `asCScriptFunction` already holds Registration-written runtime bytecode on the receiving Engine.

#### Scenario: Prepare after Registration

- **WHEN** a Context prepares a script function whose TypeInfo is owned by its own Engine and whose runtime bytecode was written by Registration.Link
- **THEN** Prepare succeeds
- **BUT** a TypeInfo pointer from another Engine is rejected even when names match

#### Scenario: Prepare before runtime bytecode exists

- **WHEN** a Context prepares a script function that has stable bytecode but no runtime bytecode
- **THEN** Prepare returns `asNO_FUNCTION`

    First Prepare does not Emit and does not Link.
