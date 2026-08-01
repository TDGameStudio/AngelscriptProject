## MODIFIED Requirements

### Requirement: Legacy fallbacks cannot hide engine-owned state

No-current-engine fallback registries SHALL NOT become hidden cross-engine owners for AngelScript runtime objects, type adapters/finders, ToString entries, bind-database contributions, or per-engine registration IDs. The new Binding Package catalog MAY retain replayable UE/C++ descriptors, complete declarations, expansion definitions/explicit input fingerprints, auxiliary adapter factories/metadata, plugin-owned parsed declaration values, and native callable adapters, but it SHALL NOT cache `asITypeInfo*`, `asIScriptFunction*`, `asIScriptObject*`, `asCScriptNode*`, `asCDataType`, `asCContext*`, per-engine `FAngelscriptType` instances, function IDs, or global-property IDs.

PreviousBind state and legacy fallback bind storage SHALL exist only when `WITH_ANGELSCRIPT_LEGACY_BINDS=1`, inside the isolated Legacy adapter, and only for the duration/engine scope required to execute an opaque legacy callback.

#### Scenario: Binding catalog stores replayable descriptors

- **WHEN** a module registers a `FAngelscriptBind` and the registry freezes it as an internal Binding Package
- **THEN** the registry MAY retain names, original/normalized complete declarations, plugin-owned parsed type/parameter/attribute values, stable UE reflection references/paths, expansion definitions, auxiliary factories/metadata, function pointers/call adapters, traits, documentation, dependencies, and configuration
- **AND** it SHALL NOT promote any applied engine's AS object pointer or registration ID into the package or catalog identity.

#### Scenario: Apply report stores engine-owned IDs

- **WHEN** a descriptor is applied to Engine A
- **THEN** its function/property/type ID SHALL be stored only in Engine A's apply result/lifecycle
- **AND** replaying the descriptor to Engine B SHALL produce and store Engine B's result separately.

#### Scenario: Legacy callback uses PreviousBind

- **GIVEN** a compatibility build with an explicit target engine
- **WHEN** the Legacy adapter invokes an opaque callback that uses PreviousBind
- **THEN** the adapter SHALL scope that state to the selected engine and legacy invocation
- **AND** a new descriptor node SHALL neither read nor write it.

#### Scenario: Legacy-disabled build

- **WHEN** the plugin compiles with `WITH_ANGELSCRIPT_LEGACY_BINDS=0`
- **THEN** the Binding Package registry, fluent Bind types, applier, and migrated providers SHALL compile without `LegacyBindState`, `PreviouslyBoundFunction`, or `PreviouslyBoundGlobalProperty`.

### Requirement: Auxiliary binding state is applied to explicit engine-owned stores

The new binding path SHALL use explicit instance references for `FAngelscriptTypeDatabase`, `FAngelscriptToStringRegistry`, and `FAngelscriptBindDatabase`. Migrated providers and new binding-core code SHALL NOT use `FAngelscriptType` static registration/lookup to select a target, `FToStringHelper` ambient registration, or static `FAngelscriptBindDatabase::Get()`.

Static ambient forwarding and no-current-engine fallback storage MAY remain only inside the Legacy compatibility surface while `WITH_ANGELSCRIPT_LEGACY_BINDS=1`. The legacy-disabled build SHALL contain no production dependency on those fallbacks.

#### Scenario: Same auxiliary package applies to two engines

- **GIVEN** one snapshot containing type-adapter, finder, and ToString descriptors
- **WHEN** it is applied independently to Engine A and Engine B
- **THEN** each engine SHALL receive fresh adapter instances, finder closures resolving that engine's adapters, and independent ToString entries
- **AND** neither engine SHALL observe or mutate the other's stores or resolved `asITypeInfo*`.

#### Scenario: Bind database participates explicitly

- **WHEN** Engine A loads its bind database and requests a materialized snapshot
- **THEN** the expansion context SHALL receive only an immutable view of Engine A's database
- **AND** bind-database contribution nodes SHALL write only to Engine A through the explicit apply context
- **AND** the existing serialized `Structs`/`Classes` schema SHALL remain separate from catalog identity.

#### Scenario: Draft construction has no fallback write

- **WHEN** a provider constructs or moves a `FAngelscriptBind` while no engine is current
- **THEN** no Legacy type, ToString, or bind-database fallback SHALL be created or mutated by the new path
- **AND** all auxiliary work SHALL remain replayable descriptor data until explicit engine application.

#### Scenario: Engine teardown clears auxiliary state

- **WHEN** an engine using auxiliary descriptors is destroyed
- **THEN** its resolved type adapters/finders, ToString entries/type infos, bind-database runtime contributions, and auxiliary node results SHALL be released before its snapshot lease
- **AND** package metadata SHALL remain reusable for a future engine without retaining the destroyed engine's objects.

#### Scenario: Context pool stores AS contexts

- **WHEN** a context pool stores `asCContext*`
- **THEN** taking a context SHALL match the requested script engine
- **AND** destroying an engine SHALL release or invalidate contexts owned by that engine.
