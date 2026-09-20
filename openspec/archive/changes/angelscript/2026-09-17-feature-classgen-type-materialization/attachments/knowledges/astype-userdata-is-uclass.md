# asType UserData is the UClass pointer

Disposition: candidate (not promoted; ClassGen UserData was withdrawn from this Change)

## Reusable Insight

After ClassGen, `asITypeInfo::GetUserData()` holds the generated Unreal reflection object (`UASClass*`, `UASStruct*`, or `UEnum*`). The reverse pointer is `UASClass::ScriptTypePtr` or `UASStruct::ScriptType`. Frontend `Resolved` output must keep both sides null.

## Evidence

- `AngelscriptClassGenerator_FullReload.cpp` sets `ScriptType->SetUserData(NewClass)` and `NewClass->ScriptTypePtr = ScriptType`.
- `AngelscriptBinds.cpp` uses the same `SetUserData(UnrealClass)` for host types.
- `FAngelscriptEngine::CanCastScriptObjectToUnrealInterface` reads `GetUserData()` as `UClass*`.
- NativeEngine `ResolvedDescriptorsRetainSemanticKeysAndNullMaterializationPointers` locks the pre-materialization nulls.

## Boundaries

Does not authorize the frontend to create UObject. Delegate / event UserData is out of this Change. `CodeSuperClass` is a native super lookup, not asType UserData.

## Application

Assert UserData and reverse pointers only after `asCEngineCompileRegistration` and ClassGenerator Setup. Keep `CompileDeclarations` tests on the null contract.

## Sources

[astype-uclass-link](../drafts/findings/astype-uclass-link.md), [design](../drafts/design.md).
