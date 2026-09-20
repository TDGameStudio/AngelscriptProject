## Purpose

Define complete maintained AngelScript SDK interpreter execution against explicit Engine-owned runtime services without requiring source compilation or dormant Unreal integration.

## ADDED Requirements

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

## MODIFIED Requirements

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

### Requirement: Context admission validates the receiving Engine's definition set

The SDK SHALL admit a callable only when its TypeInfo and required executable/native binding belong to the receiving Engine, without requiring Image or TypeInfo to return a BoundEngine from a shared object.

#### Scenario: Prepare an admitted external callable

- **WHEN** a Context prepares a callable TypeInfo owned by its own Engine
- **THEN** Prepare succeeds
- **BUT** a TypeInfo pointer from another Engine is rejected even when the publication ID matches
