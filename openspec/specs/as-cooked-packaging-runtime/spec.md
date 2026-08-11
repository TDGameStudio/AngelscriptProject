# as-cooked-packaging-runtime Specification

## Purpose
TBD - created by archiving change fix-cooked-packaging-bind-database-init. Update Purpose after archive.
## Requirements
### Requirement: Engine-Owned Bind Database Populated From Cache

In cooked builds (`AS_USE_BIND_DB`), the engine MUST construct its owned `BindDatabase` instance before loading `Binds.Cache`, so cached bind data populates the engine's real database rather than the static `LegacyBindDatabase` fallback.

#### Scenario: Cache loads into engine database

- **WHEN** `FAngelscriptEngine::Initialize_AnyThread()` runs in a cooked build with a present `Binds.Cache`
- **THEN** the engine's `BindDatabase` is constructed before `FAngelscriptBindDatabase::Get().Load(...)` is called
- **AND** subsequent `ExistingClass` lookups resolve against the populated engine database

#### Scenario: No mass type-registration failure

- **WHEN** a packaged build starts and binds engine types (e.g. `FMargin`, `UObject`, `UActorComponent`)
- **THEN** zero `"is not a data type in global namespace"` errors are emitted

### Requirement: Cooked Builds Initialize On Game Thread

When `AS_USE_BIND_DB` is active, `FAngelscriptEngine::ShouldInitializeThreaded()` SHALL return
`!bSkipThreadedInitialize` (worker-thread initialization by default), matching upstream behavior.
Cooked initialization SHALL only fall back to the game thread when `-as-skip-threaded-initialize`
(`bSkipThreadedInitialize`) is set. The previous precautionary game-thread forcing is removed once
worker-thread cooked initialization is verified end-to-end on a packaged build.

#### Scenario: Cooked init runs on a worker thread by default

- **WHEN** a cooked build initializes the AngelScript engine without `-as-skip-threaded-initialize`
- **THEN** `Initialize_AnyThread()` runs on a worker task (not the game thread)
- **AND** all engine types register correctly with no `"is not a data type"` errors

#### Scenario: Game-thread fallback remains available

- **WHEN** a cooked build is launched with `-as-skip-threaded-initialize`
- **THEN** initialization runs on the game thread

#### Scenario: Threaded cooked startup verified on a package

- **WHEN** the worker-thread default is enabled
- **THEN** a packaged run loads scripts, enters the test map, and does not crash during initialization

### Requirement: Bind Failure Does Not Crash

The `CompileOutInTest`, `CompileOutIfNoLog`, `CompileOutAsEnsure`, and `CompileOutAsCheck` helpers MUST tolerate a null function returned by `GetFunctionById` and return without dereferencing it.

#### Scenario: Null function id is a no-op

- **WHEN** a `CompileOut*` helper is invoked for a function id that resolves to null
- **THEN** the helper returns the function id without crashing

### Requirement: Plugin Compiles For Non-Editor Targets

The runtime and UHT-generated bindings MUST compile when `WITH_EDITOR` / `WITH_EDITORONLY_DATA` are `0`; editor-only metadata access MUST be guarded.

#### Scenario: Non-editor build links

- **WHEN** the plugin is built for a cooked/non-editor target
- **THEN** compilation succeeds with no references to editor-only metadata APIs in non-editor code paths

### Requirement: AngelScript Caches Are Staged

Packaging configuration MUST stage the complete project `Script` directory as loose NonUFS content resolved from `../Script` relative to `Content/`. The staged directory MUST contain `Binds.Cache` and the package-eligible `.as` source tree. It MUST NOT require or stage `PrecompiledScript.Cache` or a packaged Cache V2 baseline as the production script artifact.

#### Scenario: Loose source and bind cache are present

- **WHEN** a Development or Shipping package is produced
- **THEN** `Script/Binds.Cache` and package-eligible `.as` files are present outside Pak in the staged archive
- **AND** the runtime can discover and content-hash those loose source files

#### Scenario: Legacy or packaged script cache is absent

- **WHEN** staged package contents are inspected
- **THEN** `Script/PrecompiledScript.Cache` is absent
- **AND** no `Script/AngelscriptCache/<ProfileKey>` baseline is required
- **AND** the first process launch is responsible for creating Cache V2 under Saved

### Requirement: Game Script Parent Types Cook Without Editor Scripts

Script types required by cooked content (e.g. `AExampleActorType`, parent of `BP_AExampleActorType`) MUST live outside the editor-only `Examples/` directory so they cook without `-as-force-preprocess-editor-code`.

#### Scenario: Blueprint parent resolves in cooked build

- **WHEN** `ActorTestMap` references `BP_AExampleActorType` in a cooked build
- **THEN** its AngelScript parent type is available because the defining script lives under `Script/Game/`

### Requirement: Packaging tooling does not pre-generate script cache data

`Tools/RunPackage.ps1` MUST run the maintained BuildCookRun flow without invoking `-as-generate-precompiled-data`, without requiring StaticJIT generation, and without creating a script-cache file in the workspace. It SHALL validate loose Script staging and legacy-cache absence after packaging.

#### Scenario: Development package is built

- **WHEN** `RunPackage.ps1 -Configuration Development` completes
- **THEN** Build, cook, stage, Pak for cooked assets, and archive complete without a script-cache generation process
- **AND** loose source and `Binds.Cache` are available to the packaged executable

#### Scenario: Shipping package is built

- **WHEN** `RunPackage.ps1 -Configuration Shipping` completes
- **THEN** the package is produced without a Cache V2 baseline or old `PrecompiledScript.Cache`
- **AND** the Shipping executable retains the Runtime compiler path required for first-launch source compilation

### Requirement: Packaged runtime creates and updates Cache V2 from loose source

Development and Shipping executables SHALL use loose `.as` source as authoritative input, create the first Saved Cache V2 generation after successful startup compilation, and incrementally update that store on later launches. Non-editor Runtime startup SHALL expose an explicit initialization result through the engine subsystem. Invalid authoritative startup source in unattended packaged execution MUST request process exit with a nonzero status without depending on the legacy optional `-as-exit-on-error` flag.

#### Scenario: Shipping first launch has no cache

- **WHEN** a Shipping executable starts with valid staged source and an empty cache root
- **THEN** it compiles source, enters the requested map, and publishes a Saved Cache V2 generation
- **AND** it does not require an Editor/commandlet cache-generation step

#### Scenario: Shipping source has a structural change before launch

- **WHEN** loose class/property/signature structure changes while no packaged process is active
- **THEN** the next cold launch may compile and activate the new structure
- **AND** a matching new generation is published after successful ClassGenerator validation

#### Scenario: Shipping changed source is invalid

- **WHEN** current loose source differs from the committed generation and fails compilation
- **THEN** the Runtime initialization result is failure and the unattended packaged process exits nonzero by default
- **AND** it does not silently execute the different-source previous generation

### Requirement: Real packages receive deterministic multi-launch cache verification

The repository SHALL provide a separate heavy `CachePackage` suite that packages and launches both Development and Shipping executables. The suite MUST use disposable archive copies and isolated cache/report roots, and MUST NOT modify workspace business scripts.

#### Scenario: Cold and unchanged warm launches

- **WHEN** each packaged configuration runs once with an empty cache and again with unchanged source
- **THEN** the first launch publishes a generation
- **AND** the second launch reports an exact snapshot hit with zero preprocess, parse, and function-compiler calls

#### Scenario: One packaged function body changes

- **WHEN** the runner changes one function body in its archived loose test fixture and launches again
- **THEN** exactly that FunctionBody is a compile miss
- **AND** unchanged TypeSchema and ModuleState records remain hits

#### Scenario: Invalid source and recovery

- **WHEN** the runner introduces invalid source after a valid generation
- **THEN** that launch fails and Current does not advance
- **AND** restoring the last valid bytes permits the matching valid generation to be selected again

#### Scenario: Packaged structural edit occurs between launches

- **WHEN** the runner changes its archived fixture's type structure while the process is stopped
- **THEN** the next cold launch rebuilds the affected ModuleInterface/TypeSchema/dependency closure
- **AND** the new structure becomes active and is published atomically

