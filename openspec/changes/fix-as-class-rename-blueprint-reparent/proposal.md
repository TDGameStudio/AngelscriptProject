# Fix AS class rename Blueprint reparent

## Why

Renaming an Angelscript `UCLASS` currently behaves as “old class removed + new class added”. Existing Blueprint children keep their `ParentClass` pointing at the removed `_REPLACED_` husk, so they are no longer children of the renamed class after hot reload.

Hazelight does not provide a name-level AS class redirect layer. It only has the pointer-level reload path where `OldClass* -> NewClass*` is broadcast and the editor hot-reload helper calls `FBlueprintCompilationManager::ReparentHierarchies`. Unreal already provides the name-level mechanism through `[CoreRedirects] +ClassRedirects`, so the Angelscript generator should consume that instead of adding a parallel AS-specific setting.

## What

- During class-generator reload, query UE `FCoreRedirects` for previous names of newly generated AS classes.
- Resolve redirected old class names against removed AS classes from the same reload.
- Treat a resolved rename as a reload replacement by wiring `NewerVersion`, `CLASS_NewerVersionExists`, and broadcasting `OnClassReload(OldClass, NewClass)`.
- Keep the editor-side Blueprint repair on the existing `ClassReloadHelper` / `ReparentHierarchies` path.

## Out Of Scope

- Struct, enum, delegate, function, or property redirects.
- Automatic rename inference.
- Persistent asset resave or bulk Blueprint fixup commandlets.
- A new Angelscript-specific redirect settings array.
