## MODIFIED Requirements

### Requirement: Runtime bindings can be recorded without a script engine

The system SHALL execute every registered registration callback without creating or querying a script Engine and directly construct complete HostProcess TypeInfo/functions on a retained immutable collection suitable for multiple injections.

#### Scenario: Record and seal native type declarations

- **WHEN** a host collects a value type with properties, constructors and native methods

    The collector is `FAngelscriptBindCollection`. No script Engine is created or queried. TypeInfrastructure and ReflectionBindings records are invoked in this same collection, not skipped.

- **THEN** sealing retains actual HostProcess objects, native targets, required UE facts and registration provenance with null Engine

    `GetEngine()` on those types and functions is null. Process type and function IDs are assigned before injection.

- **AND** post-seal mutation is rejected without changing the graph

    A later `ExistingClass("FString").Method(...)` on the frozen collection fails and the frozen member count is unchanged.

#### Scenario: Reuse a recorded snapshot

- **WHEN** the same frozen collection is injected into two separately owned Engines
- **THEN** callbacks do not run again, both Engines share its host pointers and each owns independent mutable binding state

    Pointers and process IDs for `FString` and `FVector` match. `GetEngine()` on those host objects stays null.

### Requirement: Application preserves type dependencies and callable behavior

The system SHALL construct complete definitions in dependency-correct phase order, run every bind phase once before freeze, and inject them without replay, preserving registered native/UE semantics and actual callable template members.

#### Scenario: Resolve dependencies declared in a different order

- **GIVEN** reflection snapshot order places a child before its base and member types
- **WHEN** shells, base relationships, layouts and members complete their required barriers
- **THEN** resulting inheritance, layouts, properties and methods resolve correctly
- **BUT** an unresolved required type or inheritance/by-value cycle fails with registration/source provenance before injection

#### Scenario: Call native members through the current VM

- **WHEN** a Context invokes an admitted constructor, method or global function
- **THEN** argument direction, const/reference/handle qualifiers, native caller selection, return values and object lifetimes follow the binding contract

    > Observables: Value returns, reference returns, out/inout writes and destructor effects are visible to the host.

#### Scenario: Materialize template instances

- **WHEN** a supported host-closed container or nested instance is collected
- **THEN** its complete immutable TypeInfo and callable members are shared across injected Engines
- **AND** instances involving ScriptEngine or LiveRegister arguments keep private specialization and mutable operation state per receiver
- **BUT** unsupported operations fail without changing earlier admitted definitions, and operation-table counts alone do not prove callable members

#### Scenario: Execute every bind phase before freeze

- **WHEN** a collection containing TypeDeclarations, TypeInfrastructure, ExplicitBindings, GeneratedBindings, ReflectionBindings, PostReflectionBindings and Finalization records is executed to host

    The seven names are the existing `EAngelscriptBindPhase` values. Host-incompatible sidecars may return early from `IsHostTarget()` after the callback starts.

- **THEN** each record's callback is invoked once and the graph freezes only after Finalization

    `GetCallbackInvocationCount` for `FString.TypeInfrastructure` and `BlueprintType.ReflectionBindings` is 1 on a collection that appended those registered records.

- **BUT** a callback failure publishes no frozen graph and leaves an earlier healthy process freeze in place

### Requirement: Production binding initialization uses collection and injection

The system SHALL route BindScriptTypes and explicit binding Engine creation through the shared collection and InjectDefinitions, account for every registered Runtime bind, and reject replay of migrated host types.

#### Scenario: Create a production binding consumer

- **WHEN** a host requests the loaded Runtime surface and creates two binding consumers

    The surface is every registered `FAngelscriptBind` record that `Append` accepts, not an eight-name whitelist. `BindScriptTypes` and no-argument `CreateForBindings()` both inject the same process freeze.

- **THEN** constructors, value/native/reflected calls and supported container members execute from shared host definitions

    `GetBindingInstallation()` is empty. This pass does not call `ExecuteRegisteredBinds`.

- **AND** every registered record has an installed, host-sidecar no-op, or evidenced excluded/no-output disposition with implicit module/source provenance
- **BUT** a capture failure, a DirectBinds replay, or a silently omitted registered source is not successful creation

    Capture failure returns false from `BindScriptTypes` and does not log-only skip.

#### Scenario: Extend an existing host declaration before freeze

- **GIVEN** a primary declaration and a later registered external-module extension
- **WHEN** the extension runs in its permitted phase before collection freezes
- **THEN** its member and native target join the same eventual host graph with the external module's provenance
- **BUT** a missing target or incompatible member fails collection without publishing a partial usable Engine

### Requirement: Every eligible Runtime provider is accounted for

The system SHALL account for every current Runtime provider as present on the frozen host graph under its active target conditions or explicitly excluded by those conditions, preserving existing manual, generated and reflection precedence.

#### Scenario: Install a full loaded Runtime snapshot

- **WHEN** a host requests the full Runtime surface for the selected build and currently loaded UE types
- **THEN** all registered declarations and finalization effects are on the frozen host graph, with no silent unsupported-provider fallback
- **AND** UE structs, classes, enums, interfaces, containers, delegates, mixins and native/reflected callers preserve their applicable binding contracts
- **BUT** modules or reflected types loaded after snapshot capture require a new snapshot and engine

#### Scenario: Exclude target-specific declarations

- **WHEN** an editor-only or development-only declaration is evaluated for an ineligible target
- **THEN** coverage identifies its condition-based exclusion and the declaration is absent from the installed surface

### Requirement: Hosts can inspect the intended AS surface before installation

The system SHALL export readable host-declaration tables from a frozen collection without creating an engine, distinguishing intended AS declarations from host-sidecar no-ops and excluded candidates.

#### Scenario: Dump sealed binding declarations

- **GIVEN** a frozen collection with types, inheritance, members and namespace globals
- **WHEN** the host requests its host-declaration inspection

    The surface is `FAngelscriptBindCollection::InspectHostDeclarations`. This Change does not require Store JSON/CSV or manifest v2.

- **THEN** output exposes intended declarations, relationships and provenance
- **AND** equivalent captured inputs produce identical semantic names independent of process addresses
- **BUT** export does not restore an executable snapshot from disk

## ADDED Requirements

### Requirement: Injected host graphs compile and call without replay

The system SHALL let an injected Engine compile and execute scripts that use admitted host types without calling `RegisterObject*` on those names and without a binding Installation.

#### Scenario: Compile and call FString FVector and TArray after inject

- **GIVEN** an Engine that received the process HostProcess freeze through InjectDefinitions
- **WHEN** it compiles and executes a script that constructs `FString`, `FVector` and `TArray<int>`, then calls `Len`, `opAdd` and `Add`

    Example body: `FString S = "abc";` `FVector V(1,2,3) + FVector(4,5,6);` `TArray<int> A; A.Add(4);` expected `S.Len()==3`, sum `(5,7,9)`, `A.Num()==1`.

- **THEN** compile succeeds, the calls return those results, and those host names are not registered again during the compile

    > Observables: `Print` / `Log` from the same bound engine write `Angelscript` log lines. Bind execution emits `AS_BIND_CALLBACK_SUMMARY`, `AS_BIND_PHASE_TOTAL`, and `AS_BIND_CALLBACK_TOP`, and `FAngelscriptBindExecutionObservation::GetLastSnapshot()` lists the admitted providers.

    > Verification: `Angelscript.UnitTest.Temp.BasicTypes` AfterBind* cases prove bind-then-call via Prepare/Execute. After inject-only, HostScheme `InjectedScriptCompilesHostTypes` plus the same Temp prefix prove `asCBuilder` compile. Host* native-pointer cases are not this scenario. Legacy `AddScriptSection` / `CompileModules` are not this path.

- **BUT** TypeInfo presence without Prepare/Execute is not successful proof

## REMOVED Requirements

### Requirement: Snapshot inspection preserves ownership and complete accounting

### Requirement: Sealed snapshots receive engine-free pre-installation validation
