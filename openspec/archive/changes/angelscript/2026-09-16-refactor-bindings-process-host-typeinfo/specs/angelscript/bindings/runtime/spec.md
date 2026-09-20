## MODIFIED Requirements

### Requirement: Runtime bindings can be recorded without a script engine

The system SHALL execute eligible registration callbacks without creating or querying a script Engine and directly construct complete HostProcess TypeInfo/functions on a retained immutable collection suitable for multiple injections.

#### Scenario: Record and seal native type declarations

- **WHEN** a host collects a value type with properties, constructors and native methods
- **THEN** sealing retains actual HostProcess objects, native targets, required UE facts and registration provenance with null Engine
- **AND** post-seal mutation is rejected without changing the graph

#### Scenario: Reuse a recorded snapshot

- **WHEN** the same frozen collection is injected into two separately owned Engines
- **THEN** callbacks do not run again, both Engines share its host pointers and each owns independent mutable binding state

### Requirement: Application preserves type dependencies and callable behavior

The system SHALL construct complete definitions in dependency-correct phase order and inject them without replay, preserving eligible native/UE semantics and actual callable template members.

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

## ADDED Requirements

### Requirement: Production binding initialization uses collection and injection

The system SHALL route BindScriptTypes and explicit binding Engine creation through the shared collection and InjectDefinitions, account for all eligible current Runtime registrations, and preserve external extensions without activating legacy runtime startup.

#### Scenario: Create a production binding consumer

- **WHEN** a host requests the eligible loaded Runtime surface and creates two binding consumers
- **THEN** constructors, value/native/reflected calls and supported container members execute from shared host definitions
- **AND** every eligible registration has an installed or evidenced excluded/no-output disposition with implicit module/source provenance
- **BUT** a direct registration bypass, rerun during injection or silently omitted eligible source is not successful creation

#### Scenario: Extend an existing host declaration before freeze

- **GIVEN** a primary declaration and a later eligible external-module extension
- **WHEN** the extension runs in its permitted phase before collection freezes
- **THEN** its member and native target join the same eventual host graph with the external module's provenance
- **BUT** a missing target or incompatible member fails collection without publishing a partial usable Engine

### Requirement: Blueprint writes have configurable class ownership and barriers

The system SHALL permit parallel creation and own-member writes for independent Blueprint classes with explicit shell/base/member barriers, prewarmed UE reflection state and deterministic serial-equivalent results.

#### Scenario: Select write worker count

- **WHEN** collection starts with as.Bind.WriteWorkers equal to 0, 1, 2 or 4
- **THEN** 0 behaves as 1, the default is 1, and larger values run the fixed worker group claiming one UClass at a time
- **AND** as.Bind.ParallelPrepare independently controls preparation
- **BUT** different binding phases are not registered concurrently and no performance speedup is implied by this setting

#### Scenario: Resolve inherited Blueprint members

- **GIVEN** parent P declares X=7 and child C declares Y=11
- **WHEN** Blueprint own-member registration runs after shell/base barriers
- **THEN** C resolves X and Y exactly once through its own members and inherited relation
- **AND** property collection excludes inherited duplicates without changing UStruct's separate field policy

#### Scenario: Keep shared and thread-affine work safe

- **WHEN** at least two independent classes are registered with two write workers
- **THEN** their own table writes can overlap while shared indexes use bounded synchronization
- **AND** lazy reflection initialization, static globals and global duplicate scans remain serialized where required
- **BUT** failure in one worker prevents publication of the incomplete graph without damaging an earlier valid consumer
