## ADDED Requirements

### Requirement: Binding packages are explicitly owned and registered

The Runtime module SHALL own an `FAngelscriptBindingRegistry`, and every new manual binding provider SHALL return a move-only `FAngelscriptBind` draft with a stable PackageId and OwnerModuleId for explicit submission through that registry. The new registration path SHALL NOT discover providers through C++ static constructors or a free global registry singleton.

The registry SHALL expose `Register(FAngelscriptBind&&)` as the consume/validate/freeze boundary. Successful registration SHALL store an internal immutable `FAngelscriptBindingPackage`; the package type SHALL NOT be the public fluent construction surface.

#### Scenario: Runtime submits built-in packages

- **WHEN** `FAngelscriptRuntimeModule::StartupModule()` initializes the binding registry
- **THEN** it SHALL call and submit every `FAngelscriptBind` provider listed by the explicit core package manifest
- **AND** no new built-in provider SHALL require an `FAngelscriptBinds::FBind` static object.

#### Scenario: Optional module registers an owned package

- **WHEN** an optional module obtains the Runtime module instance and calls `Register` with a valid `FAngelscriptBind` rvalue during `StartupModule()`
- **THEN** the result SHALL contain a movable registration handle associated with that module's OwnerModuleId
- **AND** the registry SHALL expose the package to future catalog snapshots.

### Requirement: Package construction is side-effect free

`FAngelscriptBind` and its type/global/enum/node views SHALL create descriptor values without registering a type, function, behavior, property, enum, or funcdef into any AngelScript engine. Successfully registered internal packages SHALL be immutable and replayable against multiple engines.

Draft construction SHALL also avoid implicit mutation of engine-owned `FAngelscriptTypeDatabase`, ToString, or `FAngelscriptBindDatabase` stores and any process/module registry. Known type adapters, aliases, type finders, well-known type slots, ToString metadata, and bind-database contributions SHALL be replayable auxiliary descriptors. Genuine module-scoped services found by inventory SHALL remain outside Bind construction and use module-owned registration/removal handles.

#### Scenario: Creating a Bind without an engine

- **WHEN** a test constructs and fluently configures a `FAngelscriptBind` while no `FAngelscriptEngine` is current
- **THEN** draft construction SHALL succeed without resolving an ambient engine
- **AND** no `asIScriptEngine::Register*` call SHALL occur.

#### Scenario: Same package is applied to two engines

- **GIVEN** one successfully registered internal package and two fresh engines
- **WHEN** an explicit applier applies the package through separate catalog snapshots
- **THEN** both engines SHALL receive equivalent script-visible registrations
- **AND** applying Engine B SHALL NOT mutate the descriptor or reuse Engine A's AS IDs.

#### Scenario: Rebuilding a draft has no auxiliary side effect

- **WHEN** a provider constructs the same `FAngelscriptBind` draft twice for validation or isolated registries
- **THEN** construction SHALL NOT duplicate or replace engine, process, or module type, formatting, finder, or bind-database registrations
- **AND** those services SHALL be owned and initialized through their approved explicit lifetime path.

### Requirement: Registry registration consumes and freezes the Bind

`FAngelscriptBind` SHALL be move-only. The new-path Registry SHALL accept it only as an rvalue, parse and normalize every author-written complete callable declaration, validate auxiliary/expansion definitions, perform package-local identity/declaration-line-break/callable-compatibility validation, and consume it whether registration succeeds or returns a structured validation failure. Expansion definitions SHALL be frozen but not executed until snapshot materialization. Providers SHALL NOT have a second public build/finalize step.

#### Scenario: Lvalue registration is rejected by the C++ API

- **GIVEN** a named `FAngelscriptBind Bind`
- **WHEN** a caller attempts `Registry.Register(Bind)`
- **THEN** the expression SHALL fail to compile
- **AND** `Registry.Register(MoveTemp(Bind))` or registration of a returned temporary SHALL be the supported form.

#### Scenario: Valid Bind is frozen

- **WHEN** `Register` consumes a valid draft
- **THEN** the result SHALL report `Registered` or `RegisteredRequiresEngineRecreate`
- **AND** the catalog SHALL contain an immutable internal `FAngelscriptBindingPackage`
- **AND** no public `.Build()` or `.Finalize()` call SHALL be required.

#### Scenario: Invalid Bind does not mutate the catalog

- **WHEN** `Register` consumes a draft with invalid package-local identity or descriptors
- **THEN** it SHALL return `InvalidPackage` with structured diagnostics
- **AND** the catalog generation and package set SHALL remain unchanged.

#### Scenario: Declaration parsing fails during registration

- **WHEN** `Register` consumes a draft containing invalid complete-declaration syntax, an embedded line break, or a fully comparable callable mismatch
- **THEN** it SHALL return `InvalidPackage` before a package enters the catalog
- **AND** diagnostics SHALL identify the PackageId, draft node ordinal/key, declaration, provenance, parse location or mismatch, validation level, and final NodeId only if one was assigned
- **AND** no target/current AngelScript engine SHALL be required or mutated.

### Requirement: Engines consume immutable catalog snapshot leases

`FAngelscriptEngineDependencies` SHALL provide an explicit binding catalog source. Engine initialization SHALL construct its engine-owned auxiliary stores, load the existing bind database when configured, capture an explicit `FAngelscriptBindingExpansionInputs`/snapshot request, then acquire and retain an immutable materialized catalog snapshot lease until engine teardown.

#### Scenario: Engine initialization freezes one generation

- **WHEN** Engine A starts initialization from catalog generation N
- **THEN** Engine A SHALL retain exactly generation N for its lifetime
- **AND** later package additions or removals SHALL NOT change Engine A's applied package set.

#### Scenario: Test injects an isolated registry

- **WHEN** a multi-engine test constructs dependencies with an isolated `FAngelscriptBindingRegistry`
- **THEN** its engines SHALL apply only packages from that registry
- **AND** no process ambient registry or current-engine state SHALL affect the test.

#### Scenario: Loaded bind database is explicit snapshot input

- **WHEN** engine initialization loads `Binds.Cache` before snapshot acquisition
- **THEN** the snapshot request SHALL carry an immutable view of that engine's `FAngelscriptBindDatabase`
- **AND** reflection/bind-database expansions SHALL NOT call static `FAngelscriptBindDatabase::Get()` or infer a current engine.

### Requirement: Snapshot materialization expands derived descriptors deterministically

After enabled-package and dependency resolution, the registry SHALL index auxiliary metadata and run immutable expansion definitions by package order and lexical ExpansionId. Each expansion SHALL consume only the explicit read-only snapshot inputs and emit children through `FAngelscriptBindingExpansionWriter`.

The registry SHALL parse, normalize, validate, identify, collision-check, and freeze every generated child before returning the lease. Snapshot identity SHALL contain registry generation, expansion-input fingerprint, and final catalog fingerprint. Expansion definitions and native addresses SHALL remain protected by every registration handle/catalog lease that can invoke or retain their output.

#### Scenario: Package registration does not execute expansion

- **WHEN** a valid package containing an expansion definition is registered
- **THEN** Registry registration SHALL freeze the definition without querying reflection, bind database, auxiliary catalog metadata, or an AS engine
- **AND** the first applicable snapshot request SHALL execute it with the complete enabled catalog.

#### Scenario: Equivalent snapshot requests expand identically

- **WHEN** two registries contain equivalent packages and receive semantically equivalent expansion inputs
- **THEN** their ordered expansion results, generated child NodeIds, build reports, and catalog fingerprints SHALL match
- **AND** source construction/registration order and process-local addresses SHALL not affect them.

#### Scenario: Expansion preflight fails

- **WHEN** an expansion has a missing declared capability, unstable/duplicate SourceKey, invalid child declaration, callable mismatch, recursion, or child identity collision
- **THEN** snapshot acquisition SHALL fail with a structured catalog build report
- **AND** no snapshot lease SHALL be issued and no target AS/auxiliary engine state SHALL be mutated.

### Requirement: Catalog validation and ordering are deterministic

New packages SHALL use `Foundation`, `Default`, or `Late` phase plus `Requires`, `Before`, and `After` package relationships. A valid snapshot SHALL order packages by phase, dependency topology, and stable PackageId; registration time SHALL NOT order otherwise independent new packages.

Materialized apply nodes SHALL use deterministic `DeclareTypes`, `RegisterMembersAndGlobals`, `PublishAuxiliaryMetadata`, and `FinalizeAuxiliaryMetadata` bands. Inferred structural edges and explicit same-package `RequiresNode` edges SHALL be topologically sorted, with stable NodeId as the independent tie-break. Expansion definitions SHALL not be apply nodes.

#### Scenario: Independent registration order changes

- **GIVEN** the same valid packages are submitted in two different call orders
- **WHEN** two snapshots are created
- **THEN** their ordered PackageIds and catalog fingerprints SHALL be identical.

#### Scenario: Required dependency is missing

- **WHEN** a package declares `Requires("Owner.Required")` and that PackageId is absent
- **THEN** snapshot creation SHALL fail before engine registration
- **AND** diagnostics SHALL identify the requiring and missing PackageIds.

#### Scenario: Dependency graph contains a cycle

- **WHEN** package relationships create a cycle
- **THEN** snapshot creation SHALL fail before engine registration
- **AND** diagnostics SHALL include the participating PackageIds.

#### Scenario: Dependency contradicts phase order

- **WHEN** a relationship requires a `Late` package to execute before a `Foundation` package
- **THEN** validation SHALL reject the phase inversion.

#### Scenario: Auxiliary node references a type adapter

- **WHEN** a type finder, alias, or well-known type slot references a type-adapter draft node
- **THEN** Registry freeze SHALL resolve that draft-local edge to the frozen auxiliary NodeId
- **AND** snapshot ordering SHALL apply the referenced per-engine adapter before the dependent auxiliary node.

#### Scenario: Node graph is invalid

- **WHEN** same-package node relationships contain a self-edge, cycle, cross-Bind draft view, missing required node, or apply-band inversion
- **THEN** validation SHALL fail before engine application with the involved PackageId and node identities/provenance.

### Requirement: Stable semantic identities replace raw AS IDs

Every package SHALL have a deterministic PackageId derived from its explicit owner/feature identity. Each ordinary frozen descriptor node SHALL have a deterministic NodeId derived from PackageId, node kind, normalized owner/namespace, and normalized declaration. Auxiliary/expansion-definition nodes derive NodeId from PackageId, node kind, and explicit stable AuxiliaryId/ExpansionId; custom nodes require an explicit stable node name. Generated children use the ordinary declaration-based identity after materialization. Phase, dependency, trait, auxiliary metadata, ExpansionRevision/input fingerprint, generated outputs, compile-out/native metadata identity, and relevant configuration SHALL affect the catalog fingerprint but SHALL NOT unnecessarily change the NodeId of an otherwise identical node. Process addresses, telemetry, and raw AS IDs SHALL NOT participate in PackageId, NodeId, or catalog fingerprint.

#### Scenario: Equivalent catalogs receive the same fingerprint

- **WHEN** two catalogs contain semantically identical descriptors but their C++ addresses and construction order differ
- **THEN** their normalized PackageIds, frozen NodeIds, and catalog fingerprints SHALL match.

#### Scenario: Binding semantics change

- **WHEN** a declaration, trait, phase, required dependency, or stable custom-node name changes
- **THEN** a declaration or stable custom-node-name change SHALL change the affected NodeId
- **AND** a trait, phase, dependency, or relevant configuration change SHALL change the catalog fingerprint without unnecessarily changing the NodeId.

### Requirement: Application targets an explicit engine and reports every node

`FAngelscriptBindingApplier` SHALL accept an explicit `FAngelscriptEngine&` and immutable snapshot. It SHALL produce an ordered apply report containing package/node identity, owner, declaration, status, AS return code, and per-engine AS ID where applicable.

#### Scenario: Function registration succeeds

- **WHEN** the applier successfully registers a function node
- **THEN** its node result SHALL contain the exact ID returned by the target engine
- **AND** metadata observers SHALL receive that descriptor and result explicitly.

#### Scenario: Auxiliary registration succeeds

- **WHEN** the applier applies a type-adapter, type-finder, ToString, well-known-slot, or bind-database-contribution node
- **THEN** it SHALL target only the explicit selected engine store from the apply context
- **AND** its node result SHALL record the auxiliary identity/status without promoting engine-local adapter objects or `asITypeInfo*` into the catalog.

#### Scenario: Required registration fails

- **WHEN** a required node returns a negative AS registration result
- **THEN** application SHALL stop and mark the report failed
- **AND** the incomplete engine SHALL not be published for script use
- **AND** the initialization path SHALL destroy it rather than pretending to roll back individual registrations.

#### Scenario: New path has no ambient engine

- **WHEN** an architecture test scans the registry, fluent Bind API, applier, and migrated providers
- **THEN** those sources SHALL contain no implicit current-engine resolution used to choose the registration target.

### Requirement: Late registration affects only future engines

Registering a package after one or more engines have acquired snapshots SHALL add it to the next catalog generation without mutating those engines.

#### Scenario: Package registers after Engine A initialization

- **GIVEN** Engine A holds a snapshot that lacks Package P
- **WHEN** Package P registers successfully
- **THEN** the result SHALL be `RegisteredRequiresEngineRecreate` and identify Engine A
- **AND** Engine A SHALL remain unchanged
- **AND** a subsequently created Engine B SHALL include Package P.

### Requirement: Package removal is blocked while used by an engine

The registry SHALL remove a package only when no active catalog lease includes it. It SHALL NOT attempt to unregister declarations or native function addresses from a live AngelScript engine.

#### Scenario: Owner unregisters an unused package

- **WHEN** an owner calls `TryUnregisterPackage` and no active lease contains that package
- **THEN** the result SHALL be `Unregistered`
- **AND** future snapshots SHALL omit the package.

#### Scenario: Owner unregisters an in-use package

- **WHEN** an owner calls `TryUnregisterPackage` while Engine A's lease includes that package
- **THEN** the result SHALL be `InUseByEngine`
- **AND** diagnostics SHALL identify Engine A
- **AND** the catalog SHALL remain unchanged
- **AND** the module SHALL be considered unsafe to unload until Engine A is destroyed or recreated and unregistration is retried.

### Requirement: Core package membership is explicit

The Runtime SHALL maintain one authoritative manifest for built-in manual package providers. Production provider membership SHALL be reviewable without executing static initialization or scanning source filenames at build time.

Each ordinary migrated provider SHALL expose a predictable `FAngelscriptBind CreateBind_<Feature>()`-style function. The provider SHALL return the draft by value and SHALL NOT receive a registry, finalize a package, or register through RAII/destructor behavior.

#### Scenario: Manifest submits a provider result

- **WHEN** module startup expands a manifest entry for `CreateBind_FVector`
- **THEN** it SHALL pass the returned temporary directly to `FAngelscriptBindingRegistry::Register`
- **AND** package membership and submission SHALL remain explicit at module startup.

#### Scenario: A new core provider is not in the manifest

- **WHEN** a production `Bind_*.cpp` exposes a new explicit provider but the manifest omits it
- **THEN** an architecture test SHALL fail with the provider path and expected manifest entry.

#### Scenario: Manifest contains a stale or duplicate provider

- **WHEN** the manifest references no production provider or repeats a PackageId
- **THEN** validation SHALL fail before engine initialization.

### Requirement: Legacy binding support is isolated and optional

The plugin SHALL define `WITH_ANGELSCRIPT_LEGACY_BINDS` as a boolean public compile definition, defaulting to `1` only when not overridden by UBT global definitions. Legacy static registrars, PreviousBind state, implicit-engine callback scope, and old trait helpers SHALL be confined behind that definition.

#### Scenario: Default compatibility build

- **WHEN** the caller does not override `WITH_ANGELSCRIPT_LEGACY_BINDS`
- **THEN** the plugin SHALL compile with value `1`
- **AND** existing downstream legacy bind source SHALL remain buildable through the compatibility surface.

#### Scenario: Legacy-disabled build

- **WHEN** UBT defines `WITH_ANGELSCRIPT_LEGACY_BINDS=0`
- **THEN** all in-tree production manual bindings and the new binding core SHALL compile and initialize without the Legacy adapter
- **AND** no migrated provider SHALL depend on PreviousBind or static `FBind` discovery.

#### Scenario: Legacy and new provider collide accidentally

- **WHEN** a legacy callback and a new package expose the same legacy alias without an intentional replacement declaration
- **THEN** preflight SHALL fail before either duplicate is applied.

### Requirement: Generated bindings and engine extensions retain separate contracts

The manual Binding Package registry SHALL NOT change the execution, eligibility, schema, or layout contracts of UHT-generated function bindings, reflective fallback, native-module function addresses, RPC routing, or `FAngelscriptEngineExtensionRegistry`.

#### Scenario: Generated binding strategy runs with explicit manual packages

- **WHEN** an engine initializes with the new manual package applier
- **THEN** generated binding categories and their existing relative initialization stages SHALL remain unchanged
- **AND** their statistics and layout-version tests SHALL continue to pass.

#### Scenario: GameplayTags uses both lifecycle systems

- **WHEN** the GameplayTags module migrates its manual declarations
- **THEN** type/function declarations SHALL come from its owned Binding Package
- **AND** cached tag-value replay SHALL continue through the existing engine-extension registry.
