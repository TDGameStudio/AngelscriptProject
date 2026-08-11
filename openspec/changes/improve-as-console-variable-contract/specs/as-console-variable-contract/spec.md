## ADDED Requirements

### Requirement: Runtime-only console-variable surface
The plugin SHALL expose AngelScript console-variable definition, lookup, state, read, and write APIs from `AngelscriptRuntime` without requiring `AngelscriptEditor`, and SHALL retain the existing four `FConsoleVariable(Name, DefaultValue, Help)` constructors plus existing `Get*` and `Set*` declarations as source-compatible entry points.

#### Scenario: Runtime consumer uses a legacy constructor
- **WHEN** an AngelScript runtime module constructs `FConsoleVariable(Name, DefaultValue, Help)` with an `int`, `bool`, `float32`, or `FString` default
- **THEN** the script SHALL compile without an Editor module dependency and the constructor SHALL route through the same definition contract as the corresponding new Runtime API

#### Scenario: Existing getters and setters remain callable
- **WHEN** an existing script invokes `GetBool`, `GetInt`, `GetFloat`, `GetString`, `SetBool`, `SetInt`, `SetFloat`, or `SetString`
- **THEN** the declaration SHALL remain available with its existing parameter and return shape

### Requirement: Definition and lookup have separate semantics
The Runtime SHALL expose overloaded `Console::Define` functions for `int`, `bool`, `float32`, and `FString` defaults and a `Console::Find` function that takes only a name. `Define` SHALL establish module-generation ownership of a compatible declaration, while `Find` SHALL never create a console object or add a definition owner.

#### Scenario: Define creates a missing CVar
- **WHEN** `Console::Define` receives a valid name that has no registered console object and its compile transaction commits successfully
- **THEN** the Runtime SHALL register one CVar with the requested type, initial value, help, and approved persistent flags and SHALL return a valid ready handle

#### Scenario: Find returns an existing CVar
- **WHEN** `Console::Find` receives the name of an existing native or AS-created CVar
- **THEN** it SHALL return a valid ready borrowed handle without changing the value, help, flags, identity, or owner set

#### Scenario: Find does not create a missing CVar
- **WHEN** `Console::Find` receives a name with no registered console object
- **THEN** it SHALL return an invalid non-ready handle and `IConsoleManager` SHALL remain unchanged

### Requirement: One type-safe and safely copyable handle implementation
The native implementation behind the AngelScript `FConsoleVariable` value type SHALL be one non-template C++ type with explicit copy construction, assignment, and destruction semantics. It SHALL NOT placement-new, call a member function on, or destroy one `FScriptConsoleVariable<T>` specialization through another specialization's registered storage.

#### Scenario: Every default type uses the same registered native value type
- **WHEN** AngelScript constructs CVar handles using all four supported default types and invokes every conversion getter on each handle
- **THEN** each object SHALL use the same registered native type, size, alignment, copy, assignment, and destructor implementation

#### Scenario: Copied handles share resolution without sharing ownership callbacks
- **WHEN** a valid or pending handle is copied and the original is then destroyed
- **THEN** the copy SHALL preserve the same name, state, and resolved CVar behavior without duplicating a delegate, registration, unregister action, or module owner

### Requirement: Handle state is explicit and deterministic
`FConsoleVariable` SHALL expose `IsValid`, `IsReady`, `GetName`, and `GetType`. A declaration accepted for a pending compile transaction SHALL be valid but non-ready; a missing `Find`, invalid name, kind collision, type conflict, or externally incompatible replacement SHALL produce an invalid handle.

#### Scenario: Pending initial declaration reports its declared state
- **WHEN** a CVar definition is accepted during off-thread initial compilation but has not reached its game-thread commit
- **THEN** `IsValid` SHALL return true, `IsReady` SHALL return false, `GetName` and `GetType` SHALL report the declaration, and conversion getters SHALL return the declared default converted to the requested getter type

#### Scenario: Write against a pending declaration is observable
- **WHEN** `TrySet*` is called on a valid non-ready handle
- **THEN** it SHALL return `NotReady` and SHALL NOT mutate or register a UE console object

#### Scenario: Borrowed object is externally replaced incompatibly
- **WHEN** native code removes the CVar referenced by a handle and installs a console command or an incompatible CVar under the same name
- **THEN** the next handle operation SHALL re-resolve by name, mark the handle invalid, avoid dereferencing the old pointer, and report an identity/type diagnostic

### Requirement: Compatible duplicates share one definition
The registry SHALL compare AS definitions by canonical name, value type, help, and approved persistent flags. Exact duplicates SHALL share one CVar and add generation owners without resetting its live value; incompatible AS declarations SHALL fail deterministically and SHALL NOT change the committed definition.

#### Scenario: Two modules define the same compatible CVar
- **WHEN** two module generations commit definitions with the same name, type, help, and persistent flags
- **THEN** the registry SHALL retain one `IConsoleVariable`, record both owners, and preserve the value established by the first registration or subsequent writes

#### Scenario: Duplicate definition changes its default only
- **WHEN** another compatible owner supplies a different default but the same name, type, help, and flags after the CVar already exists
- **THEN** the existing current value SHALL remain unchanged and the later default SHALL NOT reset it

#### Scenario: Two AS definitions conflict
- **WHEN** an incoming AS definition uses the same name but a different value type, help, or persistent flags
- **THEN** the incoming handle SHALL be invalid, the committed CVar and owners SHALL remain unchanged, and the diagnostic SHALL identify the name, both declaration shapes, and both owner modules

### Requirement: Native CVars are borrowed and never owned by AngelScript
When `Define` or `Find` resolves a CVar that was not created by the AS registry, the handle SHALL be borrowed. The Runtime SHALL preserve its native pointer identity while it remains registered, value, help, persistent flags, and native lifetime, and SHALL never unregister or rewrite its metadata.

#### Scenario: Define encounters a compatible native CVar
- **WHEN** `Console::Define` names an existing native CVar with a compatible value type but supplies a different default, help, or flags
- **THEN** the Runtime SHALL return a valid ready borrowed handle, preserve all native metadata and the current value, and ignore the script metadata for registration purposes

#### Scenario: Define encounters an incompatible native CVar
- **WHEN** `Console::Define` names an existing native CVar whose underlying value type is incompatible with the requested default type
- **THEN** it SHALL return an invalid handle, leave the native CVar untouched, and report the expected and actual types

#### Scenario: Borrowing engine or module shuts down
- **WHEN** every AngelScript handle/owner associated with a borrowed native CVar disappears during module discard or engine detach
- **THEN** the native CVar SHALL remain registered with the same native metadata and ownership

### Requirement: Console-object kind collisions are non-destructive
The Runtime SHALL distinguish CVars from console commands before definition or replacement. A CVar definition SHALL NOT replace a command, and an `FConsoleCommand` registration SHALL NOT unregister or replace a CVar; existing script command-to-command replacement behavior SHALL remain supported.

#### Scenario: Define collides with a console command
- **WHEN** `Console::Define` or a legacy constructor receives a name already registered as a console command
- **THEN** it SHALL return an invalid handle, leave the command registered, and report a name/kind collision

#### Scenario: Command collides with a CVar
- **WHEN** `FConsoleCommand` receives a name already registered as a native or AS-created CVar
- **THEN** command construction SHALL fail with a diagnostic and the CVar SHALL retain its identity, value, flags, and ownership

#### Scenario: Command replaces a command
- **WHEN** `FConsoleCommand` receives a name already owned by another script console command
- **THEN** the existing command-to-command replacement and newest-owner cleanup behavior SHALL remain unchanged

### Requirement: Definition ownership follows engine and module generations
Each committed AS definition SHALL be owned by the current `FAngelscriptEngine` and calling `asIScriptModule` generation rather than by the lifetime of one value handle. Destroying a local handle SHALL NOT unregister the CVar; explicit module discard or engine detach SHALL release the corresponding owner exactly once.

#### Scenario: Function-local definition outlives its handle
- **WHEN** a script function calls `Define` or a legacy constructor and then returns
- **THEN** the CVar SHALL remain registered and owned by that function's module generation until that generation is discarded or its engine detaches

#### Scenario: One of multiple owners unloads
- **WHEN** one module generation owning a shared compatible CVar is discarded while another owner remains
- **THEN** the registry SHALL remove only the discarded owner and SHALL keep the same CVar registered with its current value

#### Scenario: Last AS owner unloads
- **WHEN** the final owner of an AS-created CVar is discarded outside an active replacement transaction
- **THEN** the registry SHALL unregister that console object with keep-state enabled, invalidate or make non-ready its handles as appropriate, and leave no active AS owner record

#### Scenario: Engine detaches
- **WHEN** an AngelScript engine detaches from the engine extension registry
- **THEN** all owners and pending transactions belonging to that engine SHALL be released before engine memory becomes invalid, while owners belonging to other engines remain intact

### Requirement: Compilation updates CVar definitions transactionally
The registry SHALL stage AS definitions and generation removals per engine compilation run. Successful compilation SHALL reconcile and commit the affected generation set on the game thread; failed or rejected compilation SHALL discard its staging and preserve the last-good CVar registry and UE console state.

#### Scenario: Successful reload keeps a compatible definition
- **WHEN** a module reload succeeds and the new generation defines the same compatible CVar as the old generation
- **THEN** the commit SHALL transfer ownership without unregistering or replacing the CVar and SHALL preserve its current value

#### Scenario: Successful reload removes a definition
- **WHEN** a module reload succeeds and the new generation no longer establishes ownership of a CVar owned only by the old generation
- **THEN** the successful commit SHALL unregister the AS-created CVar with keep-state enabled after the old generation owner is removed

#### Scenario: Successful reload renames a definition
- **WHEN** a module reload succeeds with an old AS-created name removed and a new valid name defined
- **THEN** one commit SHALL release the old name and register the new name without leaving the old name actively registered

#### Scenario: Failed reload introduces or removes definitions
- **WHEN** a reload stages new, removed, or conflicting CVar definitions but compilation does not produce a committable result
- **THEN** the registry SHALL discard every staged change and SHALL leave the last-good registrations, values, metadata, handles, and owners unchanged

### Requirement: Initial compilation never mutates IConsoleManager off the game thread
Definitions encountered during initial compilation SHALL be staged without calling `RegisterConsoleVariable`, `UnregisterConsoleObject`, or other mutating `IConsoleManager` APIs from the compilation thread. A successful initial transaction SHALL commit only after initial compilation finishes on the game thread.

#### Scenario: Initial compile defines a missing CVar
- **WHEN** initial script global initialization defines a CVar on a non-game compilation thread
- **THEN** no console object SHALL be registered on that thread and the declaration SHALL become ready only after the game-thread initial-compile-finished commit

#### Scenario: Pending handle is destroyed before initial commit
- **WHEN** all script handles for a staged definition are destroyed before initial compile completes but the module-generation definition remains part of the successful transaction
- **THEN** the registry SHALL commit according to module ownership without dereferencing a destroyed handle address

#### Scenario: Initial compile fails
- **WHEN** initial compilation fails after staging one or more CVar definitions
- **THEN** none of those definitions SHALL be registered and all staging for that failed run SHALL be released

### Requirement: Script creation flags are bounded and validated
`Console::Define` SHALL accept only combinations of `Default`, `Cheat`, `ReadOnly`, and `RenderThreadSafe` from `EScriptConsoleVariableFlags`. The Runtime SHALL map these values to the corresponding persistent UE flags, SHALL exclude `ECVF_SetByMask` from creation flags, and SHALL reject unknown bits.

#### Scenario: Supported flags are combined
- **WHEN** an AS-created CVar is defined with a valid combination such as `Cheat | RenderThreadSafe`
- **THEN** the registered CVar SHALL expose the corresponding persistent UE flags and SHALL retain them across compatible owners and hot reload

#### Scenario: Unknown flag bits are supplied
- **WHEN** a caller casts or constructs a flag value containing bits outside the approved set
- **THEN** `Define` SHALL fail without registering or changing a console object and SHALL report the unsupported bits

#### Scenario: Native flags differ from script request
- **WHEN** a compatible native CVar already exists with persistent flags different from an incoming `Define`
- **THEN** the native flags SHALL remain unchanged because the resulting handle is borrowed

### Requirement: Setting source and failure are observable
The Runtime SHALL provide `TrySetBool`, `TrySetInt`, `TrySetFloat`, and `TrySetString` returning `EScriptConsoleVariableSetResult`. Callers SHALL be permitted to request only the bounded `GameSetting` or `Code` source; the Runtime SHALL expose the full observed current UE source through a separate read-only `EScriptConsoleVariableSource` result.

#### Scenario: TrySet succeeds
- **WHEN** a ready writable CVar accepts a value with an allowed source whose priority is sufficient
- **THEN** `TrySet*` SHALL update the CVar, return `Succeeded`, and `GetLastSetBy` SHALL report the resulting observed UE source

#### Scenario: Higher-priority value rejects a write
- **WHEN** the CVar's current source has higher priority than the requested allowed source
- **THEN** `TrySet*` SHALL leave the value and source unchanged and return `PriorityRejected`

#### Scenario: Read-only CVar rejects a write
- **WHEN** `TrySet*` targets a CVar with the UE read-only persistent flag
- **THEN** it SHALL leave the value and source unchanged and return `ReadOnly`

#### Scenario: Invalid or pending handle rejects a write
- **WHEN** `TrySet*` targets an invalid handle or a valid non-ready handle
- **THEN** it SHALL return `InvalidHandle` or `NotReady` respectively and SHALL not mutate `IConsoleManager`

#### Scenario: Legacy setter fails
- **WHEN** a legacy `Set*` method encounters invalid, non-ready, read-only, or priority-rejected state
- **THEN** it SHALL remain non-throwing, preserve the value, and emit one rate-limited diagnostic containing the name, operation, module, and failure result

### Requirement: Diagnostics identify actionable declaration context
Every rejected definition, incompatible external replacement, invalid value operation, and legacy setter failure SHALL produce a deterministic diagnostic containing the console-object name, requested operation, relevant types/kinds or flags, and caller module when available. Identical runtime diagnostics MAY be rate-limited within one module generation but SHALL recur for a new generation.

#### Scenario: Conflicting declaration is reported
- **WHEN** an AS definition conflicts with a committed AS or native object
- **THEN** the diagnostic SHALL identify the incoming module/name/declaration and the existing kind/type/owner information needed to resolve the conflict

#### Scenario: Expected missing Find is guarded
- **WHEN** a caller invokes `Console::Find` for a missing name, checks `IsValid`, and performs no invalid value operation
- **THEN** the Runtime SHALL NOT emit an error merely because the lookup missed

#### Scenario: Invalid handle is used without a guard
- **WHEN** a caller invokes a getter or legacy setter on an invalid handle
- **THEN** the Runtime SHALL return the compatibility fallback or preserve state as applicable and SHALL emit a rate-limited invalid-handle diagnostic

