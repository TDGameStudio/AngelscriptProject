## MODIFIED Requirements

### Requirement: Runtime bindings can be recorded without a script engine

The system SHALL expose two main operations, Record and Install. Record SHALL collect complete eligible Runtime binding descriptions without creating or querying a script engine or engine-associated runtime type/function objects, and SHALL return a sealed immutable binding database for repeated installation.

#### Scenario: Record and seal native type declarations

- **WHEN** a host records a value type with properties, constructors and native methods and seals the database

    A primary provider can also describe its destructor, adapter factory, property finder and ToString behavior in the same callback. References may name types whose providers have not executed yet.

- **THEN** the database retains complete semantic descriptions, native target references, UE adaptation recipes and source provenance

    Semantic descriptions contain no engine-bound types, functions or mutable adapter instances. Process-local executable targets and retained reflection have an explicit separate ownership component.

- **AND** attempted mutation after sealing is rejected without changing the database
- **BUT** unresolved required type references prevent a successful database result

#### Scenario: Reuse a recorded snapshot

- **GIVEN** one sealed database produced by a provider invocation count of one
- **WHEN** that database is installed into two separately owned engines
- **THEN** the provider invocation count remains one and each engine receives independently owned mutable binding state
- **AND** neither installation repeats UE reflection discovery

#### Scenario: Record serially or from independent parallel fragments

- **GIVEN** identical captured inputs and eligible providers that use only the permitted read-only input snapshot
- **WHEN** a host records them in Serial and Parallel modes with different completion orders
- **THEN** both results expose equal canonical declarations, source dispositions, dependencies and selected native transports
- **AND** equivalent invalid inputs expose the same ordered symbol/source diagnostics
- **BUT** a provider requiring live UE access is executed on GameThread even when Parallel mode is selected

### Requirement: Application preserves type dependencies and callable behavior

The system SHALL install complete definitions and executable native bindings with deterministic dependency-correct results. Serial and Parallel preparation SHALL preserve the same eligible Runtime surface and UE semantics, with complete metadata validated before engine publication.

#### Scenario: Resolve dependencies declared in a different order

- **GIVEN** a derived type, its base and member types appear in a different provider order from their dependencies
- **WHEN** the database is installed
- **THEN** the resulting types expose the correct inheritance, layouts, properties and methods

    All nominal identities are available to resolve signatures. Source order and worker completion order do not choose dependencies or overload winners.

- **BUT** an unresolved required type or inheritance/by-value layout cycle produces a provenance-bearing failure

    Handle/reference cycles remain legal. Failed preparation publishes no usable engine.

#### Scenario: Materialize template instances

- **WHEN** an engine requests a supported container instance, including a nested instance
- **THEN** it obtains a complete concrete type with typed layout, lifecycle, callable members and native targets, reusing that instance identity on repeated requests within the engine

    For TArray<FString>, construction, Add, Num and index access must be invocable through installed VM functions. Direct host calls to an operations helper alone do not establish callable member support.

- **AND** member parameter/return type uses and qualifiers reflect the concrete template arguments
- **AND** a compatible prebuilt external instance is shared by definition, while a newly materialized private instance belongs to the requesting Engine; mutable operation state remains per Engine
- **BUT** unsupported element operations or missing concrete member targets fail without modifying previously installed definitions or publishing an incomplete cache entry

#### Scenario: Prepare metadata concurrently before attaching an engine

- **WHEN** equivalent databases are installed through Serial and Parallel preparation
- **THEN** the engines expose equivalent stable type/member identities, layouts, call transports and runtime results
- **AND** attachment observes only completed definitions and native readiness
- **AND** one shared immutable preparation may attach its external publication to multiple Engines without repeated metadata construction
- **BUT** mutable execution state remains per Engine and private source-generated images cannot be adopted by another Engine

### Requirement: Sealed snapshots receive engine-free pre-installation validation

The system SHALL validate sealed binding records and actual executable-target readiness before native engine creation. Validation SHALL be read-only, deterministic and provenance-bearing and SHALL distinguish sealing, descriptive metadata and installation readiness.

#### Scenario: Reject a sealed but invalid binding surface

- **GIVEN** a sealed database contains an unresolved required type, illegal inheritance/layout, incompatible duplicate member, inconsistent policy/provenance or a missing required native target
- **WHEN** the host validates it for installation
- **THEN** validation fails with internal step, symbol and provider/source diagnostics without creating an engine
- **AND** the database remains unchanged and inspectable
- **BUT** successful sealing alone cannot be reported as successful installation validation

#### Scenario: Descriptive recipes do not satisfy an executable target

- **GIVEN** a required callable has a textual or JIT recipe but no executable native target or supported concrete target builder
- **WHEN** the host validates or prepares its database
- **THEN** both operations reject it as missing an executable target before native engine allocation
- **BUT** explicitly categorized interface declarations, generic template definitions and compiler-only non-callable entries are not misclassified as required native calls

    A required concrete template member must have a resolvable executable target even when its generic definition is metadata-only.

#### Scenario: Preparation and connection agree on target admission

- **WHEN** the installer prepares a valid database and connects its resolved targets
- **THEN** the connector consumes the target selection and signature facts accepted during preparation
- **AND** connection does not substitute an unresolved descriptive recipe for that executable target

    Runtime ABI/call execution still requires execution tests; later resource or engine-state failures return no published owner.

## ADDED Requirements

### Requirement: Runtime migration preserves complete primary descriptions

The system SHALL provide one complete primary registration callback for each built-in type and account for every eligible Runtime declaration and explicit extension after migration.

#### Scenario: Primary registration includes infrastructure and members

- **WHEN** a built-in type is recorded with its lifecycle, methods, property adaptation and ToString description
- **THEN** one primary callback supplies all of those facts without a declaration-phase callback or later provider replay
- **AND** independent extension contributions remain associated with their own sources
- **BUT** a reflection generator producing several types is not incorrectly counted as several manually duplicated callbacks

#### Scenario: Reconcile the complete migrated Runtime surface

- **WHEN** a host requests the full loaded Runtime surface under an effective target policy
- **THEN** independently expected types, members, transports and effects are present or have explicit condition-based exclusions
- **BUT** matching aggregate counts do not excuse a missing expected symbol, unsupported eligible provider or duplicate primary definition
