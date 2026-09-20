## ADDED Requirements

### Requirement: Initial compile materializes Unreal reflection from preprocessor descriptors

The host engine SHALL, on `CompileModules` with `ECompileType::Initial` for modules that are not precompiled and have no `ScriptModule`, compile those modules' preprocessor `ProcessedCode` through `asCBuilder`, register the result onto the host Engine, attach the resulting `asCModule` shells to the same preprocessor `ModuleDesc` values, skip the reconstruction Stage1–4 compile block, and then run the existing ClassGenerator.

#### Scenario: Initial compile materializes class, struct, and enum

- **GIVEN** a host `FAngelscriptEngine` with a script package and one preprocessor module that declares a code-class, a struct, and an enum

    The module name is the Builder source path. The class descriptor already has `CodeSuperClass`. Frontend `CompileDeclarations` is not this path.

- **WHEN** the host compiles that module with `ECompileType::Initial`

    > Inputs: `FAngelscriptEngine::CompileModules(Initial, InModules, OutCompiledModules)`.

- **THEN** each of those types has a non-null `ScriptModule`, and `asType.GetUserData()` is the generated `UASClass*` / `UASStruct*` / `UEnum*`

    `UASClass.ScriptTypePtr` and `UASStruct.ScriptType` point at the same asType. The enum descriptor `Enum` is non-null.

    > Observables: `FAngelscriptModuleDesc::ScriptModule`, `asITypeInfo::GetUserData()`, `UASClass::ScriptTypePtr`, `UASStruct::ScriptType`, `FAngelscriptEnumDesc::Enum`.

    > Verification: NativeEngine Compile `ClassGenMaterialization`.

- **BUT** FullReload and SoftReloadOnly SHALL NOT gain this Builder skip in this capability

    Those compile types keep the existing reconstruction Stage1–4 path.

    > Boundaries: CacheV2 function reuse and delegate / event UserData are outside this requirement.

#### Scenario: Frontend Resolved pointers stay null

- **WHEN** a caller finishes `CompileDeclarations` without host ClassGen
- **THEN** `CodeSuperClass`, `Class`, `Struct`, `ScriptType`, and `GetUserData()` remain null

    > Verification: existing NativeEngine ReflectionDescriptors null-materialization cases.

    > Boundaries: This capability does not change the frontend Resolved contract.
