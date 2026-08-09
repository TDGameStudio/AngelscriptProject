## ADDED Requirements

### Requirement: Script subsystem lifecycle state is coherent

The script-author subsystem bases `UScriptEngineSubsystem`, `UScriptGameInstanceSubsystem`, `UScriptWorldSubsystem`, `UScriptLocalPlayerSubsystem`, and editor-only `UScriptEditorSubsystem` SHALL preserve their corresponding UE base lifecycle calls and SHALL invoke script lifecycle callbacks only for an initialized, owner-engine-compatible instance. Every tickable base SHALL reject Tick after deinitialization.

#### Scenario: Engine subsystem stops ticking after deinitialization
- **WHEN** a collection-owned `UScriptEngineSubsystem` instance has initialized, ticked, and then deinitialized
- **THEN** its script Tick callback SHALL not run again
- **AND** its initialized state SHALL report false after deinitialization

#### Scenario: Editor subsystem preserves base lifecycle
- **WHEN** an editor-owned `UScriptEditorSubsystem` initializes and deinitializes
- **THEN** its `UEditorSubsystem` base lifecycle SHALL run exactly once for each matching transition
- **AND** its script callbacks SHALL execute only while its owning AngelScript engine is compatible

### Requirement: Script subsystems can declare initialization dependencies

A script subsystem SHALL be able to declare a dependency on a compatible subsystem class during its initialization callback. The API SHALL use the active UE subsystem collection internally and SHALL NOT expose `FSubsystemCollectionBase` as a script-visible type or persist its reference after the callback returns.

#### Scenario: Dependency initializes before dependent callback continues
- **WHEN** a script subsystem declares a compatible dependency during `Initialize`
- **THEN** UE SHALL initialize or retrieve that dependency through the current collection before the dependent initialization callback completes
- **AND** the script can retrieve the same concrete dependency instance through the supported subsystem `Get()` surface

#### Scenario: Dependency request outside initialization is rejected
- **WHEN** script code requests a subsystem dependency from Tick, an ordinary function, or after its initialization callback returns
- **THEN** the request SHALL fail with a diagnostic identifying the lifecycle restriction
- **AND** no subsystem collection state SHALL be mutated

### Requirement: Script author subsystem scopes are explicit

The supported script-author subsystem bases SHALL be Engine, GameInstance, World, LocalPlayer, and editor-only Editor scopes. Their generated `Get()` forms SHALL match the owning scope: Engine/GameInstance/World/Editor use parameterless retrieval when a valid context exists, and LocalPlayer uses a `ULocalPlayer` or `APlayerController` input.

#### Scenario: Script subsystem retrieves its collection-owned instance
- **WHEN** a script-defined subsystem is created by its corresponding UE collection
- **THEN** its generated `Get()` function SHALL return that exact instance
- **AND** it SHALL not return an instance from a different World, GameInstance, LocalPlayer, or editor context

### Requirement: Collection-owned lifecycle behavior is regression covered

Automation coverage SHALL exercise collection-owned creation, creation filtering, lifecycle callback ordering, Tick gating, generated retrieval, and scope isolation for the supported script subsystem families. Hot reload coverage SHALL continue to prove that owner-engine checks prevent dispatch through an incompatible generated class.

#### Scenario: World creation filter excludes unsupported world types
- **WHEN** a script World subsystem disables editor-world creation or game-world creation through its supported configuration and creation callback
- **THEN** the matching UE subsystem collection SHALL not create it for the excluded World type
- **AND** a supported World type SHALL still create and retrieve its instance
