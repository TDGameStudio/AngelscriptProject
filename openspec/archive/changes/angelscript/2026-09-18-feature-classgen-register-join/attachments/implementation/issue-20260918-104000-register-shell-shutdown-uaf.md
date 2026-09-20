---
issue_schema: openspec-material-issue-v2
issue_id: issue-20260918-104000-register-shell-shutdown-uaf
status: resolved
source: implementation
source_ref: task 1.1
affected_tasks: ["1.1"]
created_at: 2026-09-18T10:40:00+08:00
resolved_at: 2026-09-18T10:47:00+08:00
resolution_ref: ue.test Angelscript.UnitTest.NativeEngine.Compile.ClassGenMaterialization Fast c2495efd85ad4112a36d9d244c754893
---

# Register Shell Types Die Before Module Reset

## Symptom

`ClassGenMaterialization.InitialMaterializesClassStructEnum` reaches ClassGen FullReload (UserData is written) then the host `FAngelscriptEngine` destructor crashes. First crash was `asCModule::InternalReset` `DestroyInternal` on a freed type (`0x0000006600000001`). Skipping `DestroyInternal` for `GetDefinitions()` types still crashed with `EXCEPTION_ACCESS_VIOLATION 0x0000000000000000` at the same teardown window.

## Investigation Log

- Run `7cf7a8b60dd74ae8aeaf5e1ba82dd550`: ClassGen lifecycle completed, then `ShutDownAndRelease` → `GarbageCollect` → `DeleteDiscardedModules` → `~asCModule` → `InternalReset` line 1093 `type->DestroyInternal()`. First frame was a garbage vtable.
- `asCObjectType::DestroyInternal` returns immediately when `definitions` is set and `!IsDestroying()`. A crash at the virtual call means the type pointer itself was already dead.
- `ShutDownAndRelease` calls `RetireExternalDefinitions` first. That `asDELETE`s every type in `definitionSets`, then later discards `asCModule` shells that still hold those pointers in `classTypes`.
- Host attach plus Register attach put definition-owned class/struct/enum types on the shell so ClassGen `GetType` works. CompileLifecycle shells often have empty `classTypes` because unattributed Output records skip attach, so those tests did not hit this teardown.
- Skip-`DestroyInternal` still `ReleaseInternal`d the freed pointer (run `b3f203c7b7694b6aa26c9c588ee63fdb`).

## Root Cause

`asCDefinitions` owns type memory. Register/host attach only names types on the `asCModule` shell. `RetireExternalDefinitions` destroys that memory before `InternalReset` walks the shell lists.

## Disposition

Unlink definition-owned types from every module while the objects are still alive, then let `definitionSets` delete them. Module reset must not `DestroyInternal` or `ReleaseInternal` types the set owns. Attach does not `AddRefInternal` those types.

## Evidence

### Failure Evidence (RED)

- `ue.test` TestPrefix `Angelscript.UnitTest.NativeEngine.Compile.ClassGenMaterialization` Fast run `7cf7a8b60dd74ae8aeaf5e1ba82dd550` — exit 3; `InternalReset` UAF after ClassGen completed.
- `ue.test` TestPrefix `Angelscript.UnitTest.NativeEngine.Compile.ClassGenMaterialization` Fast run `b3f203c7b7694b6aa26c9c588ee63fdb` — exit 3; skip-`DestroyInternal` still AVd at `0x0` during the same destructor.

### Resolution Evidence (GREEN)

- `ue.build` AngelscriptProjectEditor run `20af04076b8b446991e8443f18087de8` Succeeded.
- `ue.test` TestPrefix `Angelscript.UnitTest.NativeEngine.Compile.ClassGenMaterialization` Fast run `c2495efd85ad4112a36d9d244c754893` — Succeeded, 2/2; report `Saved/Harness/Unreal/Runs/c2495efd85ad4112a36d9d244c754893/AutomationReport/index.json`. Engine destructor no longer AVs.

### What This Proves

Initial ClassGen materialization is not the crash site. The crash is shutdown ownership between `definitionSets` and Register shells.

### What This Does Not Prove

Reload skip, CacheV2 reuse, and delegate/event UserData remain out of this Change.

## Links

- `tasks.md` task 1.1
- `Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_scriptengine.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_scriptengine_registration.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_module.cpp`
