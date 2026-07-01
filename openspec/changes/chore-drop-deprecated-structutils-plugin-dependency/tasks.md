# Tasks — chore-drop-deprecated-structutils-plugin-dependency

> The changed file lives in the `Plugins/Angelscript` submodule. Follow `Documents/Guides/SubmoduleWorktreeWorkflow.md` for the submodule commit and parent repository gitlink update.

## 1. Confirm Preconditions

- [x] 1.1 Confirm the engine version: check that `EngineAssociation` in `AngelscriptProject.uproject` is `5.8`.
- [x] 1.2 Confirm the only intended edit point: `Plugins/Angelscript/Angelscript.uplugin` currently has `{ "Name": "StructUtils", "Enabled": true }` around lines 35-39.
- [x] 1.3 Confirm UE 5.8 exports `FInstancedStruct` / `FStructUtils` through `CoreUObject`, so the deprecated `"StructUtils"` module dependency no longer needs to remain.
- [x] 1.4 Confirm unrelated plugins are out of scope: AngelscriptGAS, AngelscriptGameplayTags, and AngelscriptProjectEditor have no StructUtils references.

## 2. Update Dependency Declaration

- [x] 2.1 Remove the StructUtils plugin entry from `Angelscript.uplugin` and keep the JSON array syntax valid.
- [x] 2.2 Remove the `"StructUtils"` module dependency from `AngelscriptRuntime.Build.cs`.
- [x] 2.3 Confirm the relevant include path, `StructUtils/InstancedStruct.h`, is **unchanged**.

## 3. Verify

- [x] 3.1 Run `Tools\RunBuild.ps1 -NoXGE` and confirm compilation/linking succeeds with no `FInstancedStruct` binding link errors.
- [x] 3.2 Confirm the StructUtils plugin deprecation warning no longer appears.
- [x] 3.3 Confirm the UBT dependency warning about `AngelscriptRuntime` depending on `StructUtils` without a plugin dependency no longer appears.

## 4. Finish

- [ ] 4.1 Commit the change inside the `Plugins/Angelscript` submodule.
- [ ] 4.2 Update the submodule gitlink in the parent repository.
- [ ] 4.3 Optionally update the engine version in `Documents/Knowledges/ZH/Guide_QuickStart.md` from 5.7 to 5.8.
