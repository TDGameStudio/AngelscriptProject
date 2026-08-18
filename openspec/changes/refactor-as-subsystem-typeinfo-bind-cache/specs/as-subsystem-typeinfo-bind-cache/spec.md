## ADDED Requirements

### Requirement: FAngelscriptTypeBindInfo records exactly one type

The runtime SHALL provide `FAngelscriptTypeBindInfo` as the process-level snapshot of one AngelScript-visible type. One instance SHALL correspond to one type name and one `EAngelscriptTypeBindKind` (`Value`, `ObjectHandle`, `Enum`, `Interface`, `Template`, or `Namespace`). The struct SHALL store declarations, members, traits, bind-surface conditions, and optional native/C++ recipes. It SHALL NOT store `asITypeInfo*`, `asIScriptFunction*`, `asIScriptObject*`, or `asCContext*`.

#### Scenario: Value type occupies one TypeInfo

- **WHEN** expansion records `FVector`
- **THEN** the store contains exactly one `FAngelscriptTypeBindInfo` whose `AngelscriptTypeName` is `FVector` and whose kind is `Value`
- **AND** that instance holds `FVector` constructors, methods, and properties recorded for the expanded surfaces
- **AND** it does not also hold `FRotator` members

#### Scenario: Namespace functions live on a namespace TypeInfo

- **WHEN** expansion records `Hash::` global functions
- **THEN** those functions are stored on a `Kind=Namespace` TypeInfo named `Hash`
- **AND** the subsystem does not require a second top-level array for globals

#### Scenario: TypeInfo rejects engine-owned pointers

- **WHEN** a recorder or test attempts to assign an `asITypeInfo*` onto `FAngelscriptTypeBindInfo`
- **THEN** the TypeInfo type has no such field
- **AND** engine teardown of Engine A cannot leave an `asITypeInfo*` inside the subsystem array

### Requirement: UAngelscriptSubsystem owns the TypeInfo array

`UAngelscriptSubsystem` SHALL own a native `TArray<FAngelscriptTypeBindInfo>` (and a name-to-index map) after bind-callback collection finalization. The array SHALL NOT be a `UPROPERTY`. `UAngelscriptGameInstanceSubsystem` SHALL NOT own this array.

#### Scenario: Subsystem holds the sealed array

- **WHEN** TypeInfo expansion succeeds
- **THEN** `UAngelscriptSubsystem` exposes the sealed `TArray<FAngelscriptTypeBindInfo>`
- **AND** lookup by Angelscript type name returns the matching index
- **AND** the sealed callback collection of `FAngelscriptBind` records still exists separately

#### Scenario: Game-instance subsystem is not the owner

- **WHEN** a world creates `UAngelscriptGameInstanceSubsystem`
- **THEN** that subsystem does not store the process TypeInfo array
- **AND** engine bind still reads TypeInfo from `UAngelscriptSubsystem` or the adopted process store

#### Scenario: Expansion completes before primary bind

- **WHEN** the subsystem initializes the primary `FAngelscriptEngine`
- **THEN** TypeInfo state is `Sealed` or initialization fails
- **AND** the primary engine does not register from a partially merged array

### Requirement: TypeInfo rows are created at expansion, not as finished static objects

File-static discovery SHALL register `FAngelscriptBind` records only (named Register function or equivalent non-capturing callback plus `RegisterKind` or legacy phase). Finished `FAngelscriptTypeBindInfo` rows SHALL be written into the subsystem array during the recording Expand. Explicit types MAY use a named local Register function. Reflected Blueprint/`UClass` sets and BindDB walks SHALL use expand-time generators that iterate live UE types and `FindOrAdd` many complete rows.

#### Scenario: Explicit type uses a named Register function

- **WHEN** `Bind_FColor` is discovered as an Explicit provider pointing at `RegisterFColor`
- **THEN** C++ static initialization does not insert a completed `FColor` row into the subsystem array
- **AND** expansion calls `RegisterFColor` and then the array contains one `FColor` TypeInfo

#### Scenario: Blueprint classes are not a closed static list

- **WHEN** expansion runs the Reflection generator
- **THEN** it iterates native `UClass` values or BindDB class records available at that time
- **AND** it creates or updates one TypeInfo row per bound class
- **AND** a Blueprint-generated class that exists only after module load can still receive a row
- **AND** the generator is not required to name every reflected class as a file-static `FAngelscriptTypeBindInfo` object

#### Scenario: Reflection generator writes a complete class row

- **WHEN** expansion runs `RegisterBlueprintTypes` for an Actor subclass
- **THEN** that class TypeInfo row receives declaration, reflected members, and `Spawn` in the same callback
- **AND** a separate PostReflection `FAngelscriptBind` is not required for Actor `Spawn`

### Requirement: Bind lambdas expand into TypeInfo through a recorder

After the sealed `FAngelscriptBind` collection is finalized, the subsystem SHALL run those same bind callbacks once against a recording backend that upserts `FAngelscriptTypeBindInfo` members instead of calling `asIScriptEngine::Register*` on a live bind target. The runtime SHALL NOT introduce a parallel `FAngelscriptTypeBindInfoProvider` type; `FAngelscriptBind` remains the discovery object. A migrated named fill SHALL record a type's declaration, adapter, and methods in one callback. Each member SHALL carry `EApplySlot` (`Type`, `Infrastructure`, or `Members`). Migrated `FAngelscriptBind` records SHALL use `RegisterKind` (`Explicit`, `Generated`, `Reflection`, `PostReflection`) and SHALL NOT take `EAngelscriptBindPhase`. Unmigrated `FAngelscriptBind` lambdas MAY still carry the original phase until that file migrates.

#### Scenario: Explicit bind records a method without a live script engine

- **WHEN** `Bind_FVector` expands in recording mode
- **THEN** `FVector`'s TypeInfo gains the method declaration and callable identity
- **AND** no `asIScriptEngine::RegisterObjectMethod` is required for that expansion step

#### Scenario: One Register function records type and methods

- **WHEN** a migrated `RegisterFVector` runs
- **THEN** the `FVector` row receives a `Type` slot declaration and `Members` slot methods in that same callback
- **AND** expansion does not require a second TypeDeclarations provider for `FVector`

#### Scenario: Discovery stays FAngelscriptBind

- **WHEN** a migrated bind file registers `RegisterFVector`
- **THEN** the file-static object is `FAngelscriptBind`
- **AND** the runtime does not require a `FAngelscriptTypeBindInfoProvider` type

#### Scenario: Json enum is not a separate phase callback

- **WHEN** a migrated `RegisterJson` runs
- **THEN** `EJsonType`, `FJsonValue`, and `GetType()` are recorded in that same callback
- **AND** the provider does not take `EAngelscriptBindPhase`
- **AND** Apply still registers the enum before methods that mention `EJsonType` because those members carry `EApplySlot`

#### Scenario: Later pass can query recorded types

- **WHEN** a `PostReflection` provider calls `ExistingClassForTarget` / `HasMethod` during expansion
- **THEN** the recorder answers from the in-progress TypeInfo array
- **AND** it does not read `asITypeInfo*` from a throwaway engine

#### Scenario: Unhandled bind API fails closed or replays

- **WHEN** a provider calls a `FAngelscriptBinds` API the recorder does not implement
- **THEN** expansion either fails the seal with a diagnostic naming the provider or marks that provider `ReplayOnly`
- **AND** the system SHALL NOT drop the registration silently

### Requirement: Surface conditions are stored on types and members

Each `FAngelscriptTypeBindInfo` and each member SHALL carry bind-surface conditions sufficient to apply Editor versus cooked/generation engines. Conditions SHALL include editor-script visibility, simulate-cooked / Shipping compile-out policy, and `.EditorOnly()` equivalence. `AS_USE_BIND_DB` SHALL remain a compile-time expansion path, not a runtime condition bit.

#### Scenario: Editor-only member is skipped on a cooked surface

- **WHEN** a member is recorded `.EditorOnly()` or `EditorScripts=Required`
- **AND** an engine with `ShouldUseEditorScripts()==false` applies TypeInfo
- **THEN** that member is not registered into that engine
- **AND** an EditorScripts engine does register it

#### Scenario: Compile-out policy is not pre-applied as Shipping

- **WHEN** expansion runs with `bSimulateCooked==false`
- **AND** a bind uses `CompileOutInTest` / Shipping compile-out
- **THEN** TypeInfo stores the compile-out policy
- **AND** a later simulate-cooked / Shipping engine apply still honors that policy

#### Scenario: Unexpanded surface is not guessed

- **WHEN** an engine requests apply for a bind surface that was never expanded
- **THEN** apply fails or falls back to provider replay for that surface
- **AND** the system SHALL NOT use EditorDevelopment TypeInfo as if it were GameShipping

### Requirement: Eligible providers MAY expand in parallel; reflection stays on the Game Thread

Within a single record pass, providers classified as UObject-free and `asIScriptEngine`-free MAY expand on worker threads into private shards that merge by type name. Providers that iterate `UClass` / `UStruct` / `UEnum`, read BindDB as the reflection source, or otherwise require the Game Thread SHALL expand sequentially on the Game Thread.

#### Scenario: POD explicit bind expands on a worker

- **WHEN** an allowlisted `Explicit` provider such as `FVector` is classified parallel-safe
- **THEN** its recording callback MAY run on a worker
- **AND** merge produces the same `FVector` TypeInfo members as sequential expansion

#### Scenario: BlueprintType stays on the Game Thread

- **WHEN** `Bind_BlueprintType` / `Bind_UStruct` / `Bind_UEnum` expand
- **THEN** those callbacks run on the Game Thread
- **AND** they do not use `TObjectIterator` on a worker

#### Scenario: Merge conflict is fatal

- **WHEN** two shards record the same type name with conflicting `EAngelscriptTypeBindKind`
- **THEN** expansion fails with a diagnostic naming both providers
- **AND** TypeInfo is not sealed

### Requirement: Engines register from TypeInfo instead of replaying recorded providers

When TypeInfo is sealed for an engine's bind surface, `FAngelscriptEngine` bind SHALL apply matching `FAngelscriptTypeBindInfo` entries sequentially via `Register*` into that engine's `asIScriptEngine`. Apply SHALL honor `EApplySlot` so type declarations register before methods (`Type`, then `Infrastructure`, then `Members`). Providers that fully recorded for that surface SHALL NOT be executed again for that engine. `ReplayOnly` providers SHALL still execute against that engine.

#### Scenario: Isolation engine applies without replaying FVector

- **GIVEN** TypeInfo is sealed including `FVector`
- **WHEN** a second full `FAngelscriptEngine` of the same surface initializes
- **THEN** `FVector` methods are registered from TypeInfo
- **AND** the `Bind_FVector` provider callback is not invoked for that engine

#### Scenario: Apply registers type before methods

- **WHEN** an engine applies a TypeInfo row that has both a `Type` slot and `Members` slot entries
- **THEN** `RegisterObjectType` / value-class registration for that name happens before `RegisterObjectMethod` for that name
- **AND** `TArray` methods tagged `Infrastructure` register before other types' `Members` slot methods

#### Scenario: Apply is sequential in this change

- **WHEN** an engine applies the TypeInfo array
- **THEN** `Register*` calls for that engine run on one thread
- **AND** the change does not concurrently register two types into the same `asIScriptEngine`

#### Scenario: Script-visible parity with lambda replay

- **WHEN** apply-from-TypeInfo is compared with today's `ExecuteRegisteredBinds` for the same surface
- **THEN** object type count, per-type method/property counts, and callable behavior on Bindings/BindingArchitecture tests match
