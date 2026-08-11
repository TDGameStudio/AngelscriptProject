## MODIFIED Requirements

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

## REMOVED Requirements

### Requirement: Packaging Tooling With Precompiled Pre-Step

**Reason**: End-user first-launch generation from authoritative loose source replaces the dedicated `-as-generate-precompiled-data` process, forced exit, and packaged read-only baseline model.

**Migration**: Remove the `GeneratePrecompiledData` pre-step and parameter from `Tools/RunPackage.ps1`. Package loose `Script` source and allow the executable to create `Saved/Angelscript/CacheV2` during its first successful launch.

## ADDED Requirements

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
