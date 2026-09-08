## Purpose

Define complete maintained AngelScript SDK interpreter execution against explicit Engine-owned runtime services without requiring source compilation or dormant Unreal integration.

## Requirements

### Requirement: The maintained interpreter executes through explicit SDK runtime bindings

The SDK SHALL execute validated bytecode through the actual maintained interpreter and a minimal owning Engine without requiring Builder, source modules, ambient UE engines or legacy startup services.

#### Scenario: Execute hand-authored primitive and control-flow code

- **WHEN** a caller prepares a linked function with typed arguments and executes it
- **THEN** the interpreter provides the maintained primitive widths, arithmetic/conversion semantics, branching, loops, script calls, recursion and return values
- **AND** invalid arithmetic, null access or stack limits report the specified runtime failure rather than host corruption
- **BUT** successful bytecode generation or type lookup alone is not execution success

#### Scenario: Keep UE services dormant during SDK execution

- **WHEN** an explicitly owned SDK Engine executes a linked image in replacement tests
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

- **WHEN** execution suspends and later resumes without changing its owning snapshot
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
  | New public Prepare, Execute, image link, definition registration or native/global binding | Rejected without replacing retained cleanup bindings |
  | An already executing call | Keeps the code, IDs and native contracts required for its continuation |
  | Destruction of an already owned object | Can invoke script or native destructors and release temporary objects through owned cleanup services |

- **AND** a shutdown request from inside an active callback defers final destruction until the callback exits

  > Unreachable object cycles are eligible for collection after the outer execution returns; the application does not need an otherwise unused Engine owner solely to trigger that drain.

- **BUT** a retained metadata pointer alone cannot prepare or execute after retirement

#### Scenario: Release the last runtime object after its host owners

- **GIVEN** an SDK object whose producer, caller-held executable snapshot and host Engine owners have been released
- **WHEN** its last external runtime reference is released
- **THEN** its native or script destructor completes exactly once with its required type, code and native bindings still valid

  > A script destructor may call a helper from a separately linked executable image. Ownership covers the complete cleanup dependency path, not only the destructor declaration.

- **AND** object, collector and Engine ownership is released after cleanup without a permanent reference cycle
- **BUT** internal cleanup authority does not reopen public execution or reattach retired definitions

  > A separately retained executable snapshot may remain readable after the Engine is destroyed; releasing that snapshot cannot call its former Engine.

#### Scenario: Handle maintained marker and observer instructions

- **WHEN** execution reaches `JitEntry`, `SaveReturnValue`, object-resolution or reference-debug instructions
- **THEN** VM markers advance without a JIT backend and optional SDK hooks follow their explicit enabled/disabled contract
- **AND** `DestructScript` performs its destruction contract and advances, while `ThrowException` reports a real VM exception

  > No optional observer requires UE startup. Disabled observers still advance; a commented handler that makes no progress is not valid no-op behaviour.
