## MODIFIED Requirements

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

## ADDED Requirements

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
