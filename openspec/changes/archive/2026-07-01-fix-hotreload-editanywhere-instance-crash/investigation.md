## Crash Summary

- Scenario: an Angelscript actor has an existing Blueprint child / placed instance, then the script parent is hot reloaded after changing a property edit specifier to `EditAnywhere`.
- Reported stack: `FAngelscriptClassGenerator::DoSoftReload::<lambda_1>::operator()` at `AngelscriptClassGenerator.cpp:4311`.
- Fault: `EXCEPTION_ACCESS_VIOLATION` reading address `0x00000000000002b8`.

## Root Cause

`DoSoftReload` iterates `UBlueprintGeneratedClass` objects to refresh derived Blueprint classes after reloading an AS parent:

```cpp
UASClass* asClass = Cast<UASClass>(CheckClass);
...
ensure(asClass->ScriptTypePtr == OldScriptType);
asClass->ScriptTypePtr = Class->ScriptTypePtr;
```

For a normal Blueprint child generated from an AS parent, `CheckClass` is a `UBlueprintGeneratedClass`, not a `UASClass`. `Cast<UASClass>(CheckClass)` therefore returns `nullptr`. The code still dereferences `asClass`, producing the null + member-offset read seen as `0x2b8`.

The valid relationship for Blueprint children is already represented by `UASClass::GetFirstASClass(CheckClass)`, which walks the superclass chain and returns the AS parent. At this point in `DoSoftReload`, the AS parent has already had `ScriptTypePtr` / `OwnerScriptEngine` updated to the new script type. Blueprint generated classes therefore only need their serialization schema and reference token stream refreshed.

## Fix Direction

- Do not dereference `Cast<UASClass>(CheckClass)` for `UBlueprintGeneratedClass`.
- Resolve `UASClass* ASClass = UASClass::GetFirstASClass(CheckClass)` first.
- Only process classes whose first AS class is the currently reloaded AS class.
- Keep `DestroyAngelscriptUnversionedSchema(CheckClass)` and `CheckClass->AssembleReferenceTokenStream(true)` on the Blueprint generated class.
