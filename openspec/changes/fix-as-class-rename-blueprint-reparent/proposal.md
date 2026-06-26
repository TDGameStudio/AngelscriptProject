# Fix AS class rename Blueprint reparent

## Why

Renaming an Angelscript `UCLASS` currently behaves as “old class removed + new class added”. Existing Blueprint children keep their `ParentClass` pointing at the removed `_REPLACED_` husk, so they are no longer children of the renamed class after hot reload.

Hazelight does not provide a name-level AS class redirect layer. It only has the pointer-level reload path where `OldClass* -> NewClass*` is broadcast and the editor hot-reload helper calls `FBlueprintCompilationManager::ReparentHierarchies`. Unreal already provides the name-level mechanism through `[CoreRedirects] +ClassRedirects`, so the Angelscript generator should consume that instead of adding a parallel AS-specific setting.

## What

- During class-generator reload, query UE `FCoreRedirects` for previous names of newly generated AS classes.
- When a hot reload sees exactly one removed AS `UCLASS` and exactly one newly added AS `UCLASS`, conservatively infer the rename and generate UE's official class redirect entry.
- Persist generated entries to the project config target as `[CoreRedirects] +ClassRedirects=(OldName="/Script/Angelscript.AOld",NewName="/Script/Angelscript.ANew")`, defaulting to `Config/DefaultEngine.ini`.
- Register generated redirects with `FCoreRedirects::AddRedirectList` immediately so the current editor session can reparent live Blueprint children during the same reload.
- Resolve redirected old class names against removed AS classes from the same reload.
- Treat a resolved rename as a reload replacement by wiring `NewerVersion`, `CLASS_NewerVersionExists`, and broadcasting `OnClassReload(OldClass, NewClass)`.
- Keep the editor-side Blueprint repair on the existing `ClassReloadHelper` / `ReparentHierarchies` path.
- Align the supported user-facing configuration with UE's official C++ mechanism:
  `Config/*.ini` `[CoreRedirects] +ClassRedirects=(OldName="/Script/Angelscript.AOld",NewName="/Script/Angelscript.ANew")`.
- Treat direct `FCoreRedirects::AddRedirectList` tests as focused registry tests; keep separate coverage for official `.ini` ingestion and generated `.ini` output.

## Out Of Scope

- Struct, enum, delegate, function, or property redirects.
- Persistent asset resave or bulk Blueprint fixup commandlets.
- A new Angelscript-specific redirect settings array.

## Investigation Notes

- Detailed UE/CoreRedirects source audit is recorded in `ue-core-redirects-investigation.md`.
- Runtime hot-reload implementation, generated ini behavior, test matrix, config cleanup, verification commands, and commit IDs are recorded in `reload-implementation-record.md`.
- The key conclusion is that UE owns redirect config ingestion and load-time name redirection. AS should still use that mechanism, but the AS hot-reload generator must perform the AS-specific detection step and emit the corresponding official CoreRedirect entry when the rename is unambiguous.
- Production writes target project `Config/DefaultEngine.ini`. Tests override the target to `Saved/Automation/...` and delete it afterward so automation does not dirty user config.
