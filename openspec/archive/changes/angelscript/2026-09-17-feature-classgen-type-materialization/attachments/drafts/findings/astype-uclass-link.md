# Target: generated asType holds a UClass pointer, and that is verified

Date: 2026-09-17. User: generate the types and verify them; for example asType should hold a UClass pointer. Provenance: draft finding `astype-uclass-link.md`.

This is not a frontend `Resolved` job. The live ClassGen path already installs this bidirectional link. The new AS pipeline has not reached that step.

## Existing attach (after ClassGen materializes)

```
asITypeInfo / asCObjectType
├─ SetUserData(UASClass*)              // asType -> UClass
│  or SetUserData(UASStruct*)
│  or SetUserData(UEnum*)
│  or SetUserData(UDelegateFunction*)
│
UASClass
├─ ScriptTypePtr = asITypeInfo*        // UClass -> asType
└─ CodeSuperClass = native UClass*

UASStruct
└─ ScriptType = asITypeInfo*
```

Evidence:

- `AngelscriptClassGenerator_FullReload.cpp`: `ScriptType->SetUserData(NewClass)`, `NewClass->ScriptTypePtr = ScriptType`
- `AngelscriptClassGenerator_SoftReload.cpp`: the same pair; structs use `Struct->ScriptType`
- `AngelscriptBinds.cpp`: host binds also `ScriptType->SetUserData(UnrealClass)`
- `FAngelscriptEngine::CanCastScriptObjectToUnrealInterface`: `GetUserData()` as `UClass*`

`GetNamespacedTypeInfoForClass` reads **already registered** `ModuleDesc->ScriptModule` by name. The new Builder's Taken `asCDefinitions` has no `asCModule` and no TypeId yet.

## Relation to the new pipeline

```
Resolved (new frontend already here)
  ClassDesc.ScriptType == null
  ClassDesc.Class / Struct == null
  asCObjectType.GetUserData() == null
  asCObjectType.GetEngine() == null
        │
        ▼  missing: Registration + existing ClassGenerator
Materialized (user verification target)
  asType.GetUserData() == generated UASClass / UASStruct / UEnum
  UASClass.ScriptTypePtr == the same asType
  SuperClass / CodeSuperClass resolved
```

`ResolvedDescriptorsRetainSemanticKeysAndNullMaterializationPointers` locks the frontend from filling those pointers early. Verification belongs after ClassGen, not inside `CompileDeclarations`.

## Relation to the first cut

Filling `SuperClass` / `CodeSuperClass` and stopping the DefinitionsBuilt overwrite remains the first implementation slice. Without SuperClass, ClassGen Analyze cannot run. Without authoritative Project, UCLASS / USTRUCT disappear after definitions. `asType.GetUserData()==UClass` is the later acceptance, not a frontend field.
