## ADDED Requirements

### Requirement: SoftReload updates a callable UFUNCTION body

After an Initial compile that materializes a preprocessor-filled `UCLASS` with a BlueprintCallable method, the host engine SHALL, on `CompileModules` with `ECompileType::SoftReloadOnly` and a body-only source change, keep the same generated `UClass` instance and execute the new script body through ProcessEvent on a live object created before the reload.

    Source stays inline `UCLASS()` / `UFUNCTION()` text. Descriptors come from the preprocessor. Language folder corpus execute is outside this requirement.

#### Scenario: SoftReload ProcessEvent returns the new body

- **GIVEN** a host `FAngelscriptEngine` with a script package and one preprocessed module whose class is `ClassGenUClassReloadSoftActor` with `UPROPERTY int Version` default 1 and `UFUNCTION int GetVersion` returning `Version`

- **WHEN** `CompileModules(SoftReloadOnly)` receives the same class whose `GetVersion` returns `Version + 1` and ProcessEvent is invoked on the object created before reload

    > Inputs: `FAngelscriptEngine::CompileModules(SoftReloadOnly, …)`, then `UObject::ProcessEvent`.

- **THEN** the generated `UClass` pointer is unchanged and ProcessEvent returns 2

    > Observables: `UClass*`, ProcessEvent return parm.

    > Verification: NativeEngine Compile `ClassGenUClassReload`.

- **BUT** this capability SHALL NOT require `PerformHotReload`, file-watch Tick, PIE, or Language corpus files

    > Boundaries: CacheV2 reuse stays outside this requirement.

#### Scenario: SoftReload Blueprint child ProcessEvents the new parent body

- **GIVEN** the same Initial parent class and a transient Blueprint created with `FKismetEditorUtilities::CreateBlueprint` whose generated class is a child of that parent

- **WHEN** SoftReload changes `GetVersion` to return `Version + 1` and ProcessEvent is invoked on a Blueprint instance created before reload

- **THEN** the Blueprint class remains a child of the same parent `UClass` and ProcessEvent returns the new value

    > Verification: NativeEngine Compile `ClassGenUClassReload`.

    > Boundaries: Level Blueprint, rename redirect, and PIE stay outside this requirement.

### Requirement: FullReload and failed reload keep ProcessEvent

After the same Initial materialization, the host engine SHALL keep ProcessEvent working across a successful FullReload that adds a property, and SHALL keep the last successful ProcessEvent result when a replacement compile fails.

#### Scenario: FullReload adds a property and stays callable

- **GIVEN** an Initial `UCLASS` with `GetVersion` returning 1

- **WHEN** `CompileModules(FullReload)` adds `UPROPERTY int Extra` and ProcessEvent is invoked on `GetVersion`

- **THEN** the new property is present on the generated class and ProcessEvent still returns an integer from the reloaded `GetVersion`

    > Verification: NativeEngine Compile `ClassGenUClassReload`.

#### Scenario: Failed reload keeps the old ProcessEvent result

- **GIVEN** a live object whose `GetVersion` already returned 1

- **WHEN** `CompileModules` receives a broken replacement for that module

- **THEN** the compile reports error, the last-good class remains lookup-able, and ProcessEvent on the live object still returns 1

    > Verification: NativeEngine Compile `ClassGenUClassReload`.
