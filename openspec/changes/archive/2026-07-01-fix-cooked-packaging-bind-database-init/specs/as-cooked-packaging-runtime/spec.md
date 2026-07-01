## ADDED Requirements

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

When `AS_USE_BIND_DB` is active, `FAngelscriptEngine::ShouldInitializeThreaded()` MUST return `false` unless `bForceThreadedInitialize` is set, so `FindObject<>` type resolution runs reliably on the game thread.

#### Scenario: Cooked init is game-thread bound

- **WHEN** a cooked build initializes the AngelScript engine without `bForceThreadedInitialize`
- **THEN** initialization runs on the game thread and type resolution does not race with object registration

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

Packaging configuration MUST stage the `Script` directory (and its `Binds.Cache` / `PrecompiledScript.Cache`) so the packaged runtime can locate them; `DirectoriesToAlwaysStageAsUFS` MUST resolve to `../Script` relative to `Content/`.

#### Scenario: Caches present in packaged build

- **WHEN** a packaged build is produced
- **THEN** `Script/Binds.Cache` and `Script/PrecompiledScript.Cache` are present in the staged output and loaded at runtime

### Requirement: Packaging Tooling With Precompiled Pre-Step

`Tools\RunPackage.ps1` MUST generate precompiled AngelScript data before `BuildCookRun`, using `-as-generate-precompiled-data -as-skip-static-jit-codegen`, where `-as-skip-static-jit-codegen` (backed by `bSkipStaticJITCodeGen`) prevents the StaticJIT codegen assertion during generation.

#### Scenario: Precompiled data generated without StaticJIT crash

- **WHEN** `Tools\RunPackage.ps1` runs its precompiled-data pre-step
- **THEN** `PrecompiledScript.Cache` is produced and the generation process exits without a StaticJIT assertion

#### Scenario: Packaged exe enters test map

- **WHEN** the resulting packaged `AngelscriptProject.exe` is launched
- **THEN** it loads precompiled scripts and enters `ActorTestMap` without crashing

### Requirement: Game Script Parent Types Cook Without Editor Scripts

Script types required by cooked content (e.g. `AExampleActorType`, parent of `BP_AExampleActorType`) MUST live outside the editor-only `Examples/` directory so they cook without `-as-force-preprocess-editor-code`.

#### Scenario: Blueprint parent resolves in cooked build

- **WHEN** `ActorTestMap` references `BP_AExampleActorType` in a cooked build
- **THEN** its AngelScript parent type is available because the defining script lives under `Script/Game/`
