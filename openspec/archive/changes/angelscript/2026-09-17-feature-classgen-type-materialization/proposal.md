## Why

The new frontend already compiles private TypeInfo and Resolved descriptors. ClassGen still needs an old `asCModule` compile-unit shell that this Engine no longer builds. Editor ClassGen runs crashed on that missing join. This Change records authored SuperClass and keeps Project as CompileOutput. It does not attach Unreal UserData.

## What Changes

- `DescriptorConsumer.Project` fills `SuperClass` (first non-interface object base) and `ImplementedInterfaces` from `GetResolvedBases`.
- `RefreshCompileOutput` keeps `DescriptorConsumer.Project` as the CompileOutput authority after DefinitionsBuilt. It must not replace Projected modules with a TypeInfo name-only scan.
- ClassGen UserData, host-forged `asCModule` shells, and `ClassGenMaterialization` tests are withdrawn. A later Change owns module materialization.

## Capabilities

### New Capabilities

None. `angelscript/runtime/class-generation` is not introduced by this Change.

### Modified Capabilities

- `angelscript/language/frontend/builder`: CompileOutput after DefinitionsFrozen or later still comes from Project; ScriptType stays null.
- `angelscript/language/frontend/reflection-dependencies`: Resolved class descriptors record authored SuperClass and implemented interfaces; CodeSuperClass and UObject pointers stay null.

## Impact

Plugin submodule `Plugins/Angelscript`: `as_descriptor_consumer.cpp`, `as_builder.cpp`, NativeEngine Compile tests (`ReflectionDescriptors`, `CompileLifecycle`). ClassGen bind-helper and `ClassGenMaterialization` sources added during the withdrawn attempt are removed.

Parent repository: this Change's OpenSpec records only.

## Non-goals

ClassGen UserData attach or verify. Restoring `asCScriptEngine::GetModule`. Forging `asCModule` shells in a bind helper. Delegate / event materialization verification or redesign. A new publisher type. Frontend UObject creation. Rewriting `FAngelscriptClassGenerator`. Language `.as` generators. A new `NativeEngine.ClassGen` test layer.
