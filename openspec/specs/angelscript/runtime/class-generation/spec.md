# Class Generation

## Purpose

Define how the host engine materializes Unreal reflection objects from preprocessor module descriptors after Builder+Register. Initial compile Registers one `asCDefinitions` per file and can ProcessEvent a host-described UFUNCTION. FullReload and SoftReloadOnly rematerialize UserData after retiring those compile sets. Frontend `Resolved` descriptors stay non-materialized.

### Requirement: Initial compile materializes Unreal reflection from preprocessor descriptors

The host engine SHALL, on `CompileModules` with `ECompileType::Initial` for modules that are not precompiled and have no `ScriptModule`, compile each module's preprocessor `ProcessedCode` through its own `asCBuilder`, register that module's `asCDefinitions` onto the host Engine, attach the resulting `asCModule` shell to the same preprocessor `ModuleDesc`, skip the reconstruction Stage1–4 compile block, and then run the existing ClassGenerator.

#### Scenario: Initial compile materializes class, struct, and enum

- **GIVEN** a host `FAngelscriptEngine` with a script package and one preprocessor module that declares a code-class, a struct, and an enum

    The module name is the Builder source path. The class descriptor already has `CodeSuperClass`. Frontend `CompileDeclarations` is not this path.

- **WHEN** the host compiles that module with `ECompileType::Initial`

    > Inputs: `FAngelscriptEngine::CompileModules(Initial, InModules, OutCompiledModules)`.

- **THEN** each of those types has a non-null `ScriptModule`, and `asType.GetUserData()` is the generated `UASClass*` / `UASStruct*` / `UEnum*`

    `UASClass.ScriptTypePtr` and `UASStruct.ScriptType` point at the same asType. The enum descriptor `Enum` is non-null.

    > Observables: `FAngelscriptModuleDesc::ScriptModule`, `asITypeInfo::GetUserData()`, `UASClass::ScriptTypePtr`, `UASStruct::ScriptType`, `FAngelscriptEnumDesc::Enum`.

    > Verification: NativeEngine Compile `ClassGenMaterialization`.

- **AND** types declared in different preprocessor modules SHALL belong to different registered `asCDefinitions`

    One Builder+Register per `ModuleDesc`. Later reload can retire one file without tearing down the host graph or every script file.

    > Observables: `asCTypeInfo::GetDefinitions()` pointer identity across modules.

    > Verification: NativeEngine Compile `ClassGenReload`.

- **BUT** frontend `CompileDeclarations` SHALL NOT materialize Unreal pointers

    `CodeSuperClass`, `Class`, `Struct`, `ScriptType`, and `GetUserData()` remain null on that path.

    > Verification: existing NativeEngine ReflectionDescriptors null-materialization cases.

    > Boundaries: CacheV2 function reuse and delegate / event UserData stay outside this requirement.

#### Scenario: Frontend Resolved pointers stay null

- **WHEN** a caller finishes `CompileDeclarations` without host ClassGen
- **THEN** `CodeSuperClass`, `Class`, `Struct`, `ScriptType`, and `GetUserData()` remain null

    > Verification: existing NativeEngine ReflectionDescriptors null-materialization cases.

    > Boundaries: This capability does not change the frontend Resolved contract.

### Requirement: Hot reload rematerializes Unreal reflection from preprocessor descriptors

The host engine SHALL, on `CompileModules` with `ECompileType::FullReload` or `ECompileType::SoftReloadOnly` for modules that are not precompiled, retire the previous compile `asCDefinitions` of those modules and their compile dependents, compile the new preprocessor `ProcessedCode` through `asCBuilder`, register the new sets onto the host Engine, skip the reconstruction Stage1–4 compile block, and then run the existing ClassGenerator. A failed compile SHALL leave the last successful generation lookup-able.

#### Scenario: FullReload updates class, struct, and enum UserData

- **GIVEN** a host `FAngelscriptEngine` whose Initial compile already materialized a code-class, a struct, and an enum

    The replacement module uses the same preprocessor `ModuleName` and already-filled `CodeSuperClass`.

- **WHEN** the host compiles a new preprocessor module with `ECompileType::FullReload`

    > Inputs: `FAngelscriptEngine::CompileModules(FullReload, InModules, OutCompiledModules)`.

- **THEN** the replacement module has no `bCompileError`, a non-null `ScriptModule`, and `asType.GetUserData()` is `UASClass*` / `UASStruct*` / `UEnum*` for those types

    Reverse pointers on the generated objects match the new asTypes. ClassGen Soft/Full selection and PIE structural downgrade stay on their existing path after this compile.

    > Observables: `FAngelscriptModuleDesc::bCompileError`, `ScriptModule`, `asITypeInfo::GetUserData()`, `UASClass::ScriptTypePtr`, `UASStruct::ScriptType`, `FAngelscriptEnumDesc::Enum`.

    > Verification: NativeEngine Compile `ClassGenReload`.

    > Boundaries: The host graph is not retired. CacheV2 reuse is outside this requirement.

#### Scenario: SoftReloadOnly updates UserData without the dead Stage path

- **GIVEN** the same Initial materialization
- **WHEN** the host compiles a replacement module with `ECompileType::SoftReloadOnly`
- **THEN** the replacement compile does not report the Legacy Stage1 error, attaches a `ScriptModule`, and ClassGen UserData remains non-null for the class

    Existing PIE structural-change downgrade or reject still applies after a successful compile.

    > Verification: NativeEngine Compile `ClassGenReload`.

#### Scenario: Failed reload keeps the last generation

- **GIVEN** an Initial materialization whose class UserData is already a `UASClass*`
- **WHEN** `CompileModules(FullReload)` receives a preprocessor module with the same name whose source does not compile
- **THEN** the replacement module reports `bCompileError`, and the last successful `asCModule` for that name remains lookup-able with its class UserData still a `UASClass*`

    The host must not rename the last-good shell away unless SwapIn succeeds.

    > Observables: `FAngelscriptModuleDesc::bCompileError`, `asIScriptEngine::GetModule(name)`, `asITypeInfo::GetUserData()`.

    > Verification: NativeEngine Compile `ClassGenReload`.

### Requirement: Initial compile materializes a callable UFUNCTION

The host engine SHALL, after `CompileModules` with `ECompileType::Initial` and existing ClassGenerator, bind each host `ClassDesc` method whose `ScriptFunctionName` exists on the registered TypeInfo to a `UASFunction` whose ProcessEvent executes that script body.

    Production Methods remain preprocessor-filled. A test that skips the preprocessor MAY hand-fill the same `Methods` table.

#### Scenario: Initial ProcessEvent returns a UFUNCTION result

- **GIVEN** a host `FAngelscriptEngine` with a script package and one module whose class descriptor already has `CodeSuperClass` and one BlueprintCallable method row

    The source method is annotated `UFUNCTION()` and returns the integer 7. The class has no `UCLASS()` / `: UObject` spelling. Frontend `CompileDeclarations` is not this path.

- **WHEN** the host compiles that module with `ECompileType::Initial` and ProcessEvent is invoked on the generated function

    > Inputs: `FAngelscriptEngine::CompileModules(Initial, InModules, OutCompiledModules)`, then `UObject::ProcessEvent`.

- **THEN** the generated `UASFunction::ScriptFunction` is non-null and ProcessEvent returns 7

    > Observables: `FAngelscriptFunctionDesc::Function`, `UASFunction::ScriptFunction`, ProcessEvent return parm.

    > Verification: NativeEngine Compile `ClassGenCall`.

- **BUT** this capability SHALL NOT require a script construct, a method-body reload, Language corpus execute, or copying Builder CompileOutput Methods onto the host descriptor

    > Boundaries: CacheV2 reuse and BlueprintEvent `_Implementation` wrappers stay outside this requirement.

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
