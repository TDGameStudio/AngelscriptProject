## ADDED Requirements

### Requirement: The fork exposes one non-versioned JIT compiler interface

The maintained AngelScript fork SHALL expose one `asIJITCompiler` lifecycle contract and SHALL NOT select between JIT interface versions. The public interface SHALL represent the complete VM, Raw, and reflected-parameters entry family as one `asSJITFunctionBinding`.

#### Scenario: Host installs the JIT compiler

- **WHEN** a host installs an `asIJITCompiler` on a script engine
- **THEN** the engine uses the single lifecycle contract without an interface-version property or cast
- **AND** no `asIJITCompilerV2` or compatibility adapter is required

#### Scenario: Complete Binding is inspected

- **WHEN** a script function has a published JIT Binding
- **THEN** `GetJITBinding()` returns its VM, Raw, Parms, and opaque user-data fields as one value
- **AND** the three entry kinds cannot belong to different Binding generations

### Requirement: Function readiness supports delayed Binding publication

The engine SHALL notify the installed compiler after an eligible script function has successfully compiled or restored executable bytecode. Notification MUST NOT require the compiler to publish a Binding immediately.

#### Scenario: Compiler binds immediately

- **WHEN** `OnFunctionReady()` receives an eligible function and an implementation is already available
- **THEN** the compiler may publish its complete Binding before the callback returns

#### Scenario: Compiler defers until a provider is available

- **WHEN** `OnFunctionReady()` receives an eligible function without a matching implementation
- **THEN** the function remains executable through VM
- **AND** the compiler may call `SetJITBinding()` later after complete-module analysis or provider refresh

#### Scenario: Function is restored from bytecode

- **WHEN** a function loaded from bytecode/Cache V2 contains the required JIT entry instructions
- **THEN** it receives the same readiness notification as a source-compiled function

#### Scenario: Function is ineligible for JIT entry

- **WHEN** a function is not a script function or lacks required JIT entry instructions
- **THEN** the compiler is not asked to publish a Native Binding for it
- **AND** ordinary VM behavior remains available

### Requirement: Binding replacement and function teardown release exactly once

The engine SHALL release each non-empty JIT Binding exactly once when it is replaced, cleared, or destroyed. It SHALL clear the function's active Binding before invoking the release callback.

#### Scenario: Binding is replaced

- **WHEN** `SetJITBinding()` publishes a different Binding over an existing one
- **THEN** the prior Binding is made unavailable to new calls before `ReleaseFunctionBinding()` runs
- **AND** the release callback receives the prior complete Binding exactly once

#### Scenario: Binding is cleared

- **WHEN** a function with a non-empty Binding is explicitly assigned an empty Binding
- **THEN** the prior Binding is released exactly once
- **AND** subsequent execution uses VM

#### Scenario: Script function is destroyed

- **WHEN** a script function is discarded while it owns a non-empty Binding
- **THEN** the installed compiler receives one release callback before function storage is destroyed

#### Scenario: Release callback re-enters inspection

- **WHEN** `ReleaseFunctionBinding()` inspects the function being released
- **THEN** it cannot observe the released Binding as still active
- **AND** it cannot trigger a duplicate release of that Binding

### Requirement: Replacing the compiler transfers lifecycle ownership safely

Changing or clearing the installed JIT compiler SHALL occur only at an engine-safe point. The engine SHALL release Bindings owned by the previous compiler and SHALL notify a newly installed compiler about all existing eligible functions.

#### Scenario: Compiler is replaced

- **WHEN** compiler A is replaced by compiler B while eligible functions exist
- **THEN** A receives release callbacks for its active Bindings
- **AND** B receives readiness notifications for the current eligible functions after ownership changes

#### Scenario: Compiler is cleared

- **WHEN** the installed compiler is set to null
- **THEN** all of its active Bindings are released
- **AND** current functions remain executable through VM

#### Scenario: Replacement is requested outside a safe point

- **WHEN** compiler replacement cannot safely detach active Bindings
- **THEN** the operation fails or is deferred without partially transferring ownership

### Requirement: Static source generation does not replace the live compiler

StaticJIT source generation SHALL enumerate completed functions through an explicit generator input and SHALL NOT temporarily replace the script engine's installed lifecycle compiler.

#### Scenario: Generate runs against an active Editor engine

- **WHEN** the generator reads current successfully compiled modules
- **THEN** current Runtime Bindings and route ownership remain installed
- **AND** generation cannot release or overwrite active Bindings merely to collect functions
