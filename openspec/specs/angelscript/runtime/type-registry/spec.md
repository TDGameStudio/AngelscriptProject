## Purpose

Assign process IDs to actual HostProcess definitions before Engine admission, share those exact pointers after InjectDefinitions, and keep ScriptEngine and LiveRegister identities private to their receiving Engine.

## Requirements

### Requirement: Host definitions have process identity before Engine admission

The SDK SHALL create actual HostProcess type and function definitions without an Engine, publish their stable keys and process numeric IDs before injection, and expose them only through explicitly admitted receiving Engine directories for execution.

#### Scenario: Freeze native Pair without an Engine

- **GIVEN** a host collection defining Pair with int X, int Y and Sum
- **WHEN** the collection freezes successfully
- **THEN** its actual type and function objects have valid fixed process IDs and null GetEngine
- **AND** the same objects remain queryable while their graph is retained
- **BUT** merely observing an ID or pointer does not admit an Engine to execute it

### Requirement: Admitted Engines share host pointers and retain private identities

The SDK SHALL return identical HostProcess pointers and IDs in every Engine admitting the same graph, while ScriptEngine and LiveRegister definitions remain private to their receiving Engine.

#### Scenario: Admit Pair into two Engines

- **WHEN** A and B inject one frozen Pair graph
- **THEN** both name, key and ID lookups return the same Pair pointer with null GetEngine
- **AND** destroying A does not remove B's admission or alter the graph's IDs

#### Scenario: Register same-named live types independently

- **WHEN** A and B independently register a live type named LocalPair
- **THEN** each obtains an independently owned LiveRegister object reporting its own Engine
- **BUT** one Engine cannot execute the other's private type or functions

### Requirement: Live registration preserves host definitions and local query semantics

The SDK SHALL support its maintained public object/member, global, interface, enum, alias, string-factory and default-array registration families, validate input before publication, and reject changes to frozen HostProcess definitions.

#### Scenario: Register and call native members

- **GIVEN** native Pair storage with X=20 and Y=22
- **WHEN** an Engine registers its layout, properties, lifecycle behaviours and Sum method
- **THEN** native queries reflect the supplied layout and an actual bound call to Sum returns 42
- **AND** invalid offsets or method signatures leave previously registered members unchanged

#### Scenario: Configure nominal types and local services

- **WHEN** an Engine registers IValue with int Value(), Color.Red=3, Count as an integer alias, a string factory and a compatible default array type
- **THEN** its signature, enum, alias and type-service queries expose those accepted declarations
- **AND** another Engine's corresponding state remains unchanged
- **BUT** a missing target type, incompatible service or invalid declaration cannot replace valid prior state

#### Scenario: Reject mutation of a shared host type

- **GIVEN** A and B have injected the same host Pair
- **WHEN** A attempts to redeclare Pair or add or replace one of its properties, behaviours or methods through live registration
- **THEN** the request fails and both Engines retain the unchanged host object
- **AND** a colliding host injection into an Engine that already owns a private Pair also fails without replacing that private object

### Requirement: Runtime numeric identity is allocated independently and never reused in-process

The SDK SHALL preserve primitive and qualified integer TypeId semantics while allocating dynamic type/function numbers through the existing process registry independently of Engine construction.

#### Scenario: Query one publication ID through multiple Engines

- **WHEN** multiple Engines inject one published host Pair graph
- **THEN** its numeric type and function IDs are identical through all admitting Engines
- **AND** the IDs were assigned before the first injection and injection never rewrites shared ID maps

#### Scenario: Reach the numeric encoding limit

- **WHEN** a publication would exceed the supported dynamic ID range
- **THEN** it fails without publishing new definitions or directory entries
- **AND** fixed primitive IDs and existing live IDs remain unchanged and issued IDs are never reused

### Requirement: Global host inspection does not grant Engine admission

The SDK SHALL separate process identity inspection from each Engine's execution admission; host pointers may be shared only after explicit injection, and private script/live pointers remain owner-bound.

#### Scenario: Inspect another Engine's private type without using it

- **GIVEN** A and B independently compile same-named ScriptThing types with different IDs
- **WHEN** a host inspects B's ScriptThing through the process registry
- **THEN** its published identity facts remain readable
- **BUT** A cannot compile against or execute B's private TypeInfo through that observation

### Requirement: Script compile transfers TypeInfo through a definition set

The SDK SHALL create script TypeInfo during engine-free compilation on asCDefinitions and transfer their unique ownership to one receiving Engine through asCEngineCompileRegistration, without transferring shared host dependencies.

#### Scenario: Install a compiled set into one Engine

- **GIVEN** Taken script asCDefinitions whose script types report null Engine and TypeId -1
- **WHEN** asCEngineCompileRegistration registers that unique list on A
- **THEN** the same script pointers report A and valid assigned IDs

    The unique list is consumed; injected HostProcess dependency pointers remain shared and report null Engine.

- **BUT** B cannot obtain A's private script objects from its queries

#### Scenario: Reject a partial batch

- **GIVEN** two private batches where the second conflicts with an existing identity or requires an uninjected host dependency
- **WHEN** Registration performs its single Install+Link operation
- **THEN** the batch fails and no submitted script function is callable

    Existing Engine types and host admission remain intact. Install and Link are not separately observable public operations.
### Requirement: Register attaches per-file asCModule identity

The SDK SHALL, when `asCEngineCompileRegistration` registers a compiled definition set together with that compile's `asCCompileOutput`, construct one `asCModule` per CompileOutput module, bind it to the receiving Engine, and attach the script types that belong to that module's logical source.

#### Scenario: Two source files become two modules

- **GIVEN** a successful Builder compile of `First.as` containing `class First {}` and `Second.as` containing `class Second {}`

    Each file is its own CompileOutput module. `ModuleName` equals the logical source key. Before Register, every `ScriptModule` is null and every script type reports null `module`.

- **WHEN** Registration registers the taken definitions together with that CompileOutput on Engine A

    > Inputs: `asCEngineCompileRegistration::Register(Sets, Output)` after TypeId install succeeds.

- **THEN** `A.GetModule("First.as")` and `A.GetModule("Second.as")` are distinct non-null modules

    `First.module` and the First ModuleDesc `ScriptModule` equal `GetModule("First.as")`.
    `Second.module` and the Second ModuleDesc `ScriptModule` equal `GetModule("Second.as")`.
    `GetModuleCount` is at least 2.

    > Observables: `asIScriptEngine::GetModule`, `GetModuleCount`, `Type.module`, `FAngelscriptModuleDesc::ScriptModule`.

    > Verification: NativeEngine CompileLifecycle two-file Register.

- **BUT** Registration that receives only definition sets, with no CompileOutput, SHALL NOT invent module shells

    Host and VM graphs that call `Register(Sets)` keep null `Type.module` and a null `GetModule` for those names.

#### Scenario: Empty Engine has no modules

- **GIVEN** a newly created Engine with no Register call
- **WHEN** a caller looks up `GetModule("Missing.as")`, `GetModuleCount()`, and `GetModuleByIndex(0)`
- **THEN** the name lookup and the index lookup return null and the count is 0

    > Verification: NativeEngine Compile SDK empty-engine lookup.

### Requirement: Engine module lookup is name-only

The maintained `asIScriptEngine` SHALL expose `GetModule(const char* name) const`, `GetModuleCount`, and `GetModuleByIndex` as table lookup, and SHALL NOT restore compile-factory module entry points.

#### Scenario: Missing name does not create a module

- **WHEN** a caller invokes `GetModule` with a name that is not in `scriptModulesByName`, or with a null name
- **THEN** the call returns nullptr and the Engine module tables are unchanged

    > Boundaries: `asEGMFlags`, `ALWAYS_CREATE`, and `ONLY_IF_EXISTS` are not part of the lookup.

    > Verification: NativeEngine Compile SDK `HasLookup` present and `HasCompile` / factory symbols absent.

#### Scenario: Compile factory stays absent

- **WHEN** C++ code attempts to call `AddScriptSection`, `Build`, `CompileFunction`, `DiscardModule`, or `GetModuleFromFuncId` on the maintained Engine or Module interfaces
- **THEN** those symbols are absent from the public SDK

    `asITypeInfo` and `asIScriptFunction` still have no `GetModule()` accessor.

    > Boundaries: Host `FAngelscriptEngine::GetModule` remains a `ModuleDesc` query and is not this Engine lookup.
