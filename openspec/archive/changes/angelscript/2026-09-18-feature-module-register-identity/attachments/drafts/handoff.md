# Handoff: create asCModule per file at Register and restore lookup GetModule

Source: local draft `angelscript/module-identity-attach` scope `runtime-identity` `handoff.md`. Approval: R10.

## OpenSpec Handoff

- Scope: runtime-identity
- Target Change: angelscript/feature-module-register-identity

## Problem

The new frontend already projects one `FAngelscriptModuleDesc` per `.as`, but Register only binds Engine and TypeId. It does not create `asCModule`. ClassGen still reads `ModuleDesc->ScriptModule`. The 09-08 SDK cut removed lookup together with the old compile factory.

## Success

- After Register, each CompileOutput module has one `asCModule(name, engine)`.
- `Type.module`, `ModuleDesc.ScriptModule`, and `scriptModules` / `scriptModulesByName` agree.
- `asIScriptEngine::GetModule(const char* name) const` looks up only; missing returns nullptr. Also `GetModuleCount` / `GetModuleByIndex`.
- Compile still uses `asCBuilder` + `asCDefinitions`. No `AddScriptSection` / `Build` / `ALWAYS_CREATE`.
- ClassGen `GetNamespacedTypeInfoForClass` no longer crashes on a null shell. This Change proves lookup and the shell; UserData stays later.

## Evidence

- [register-module-flow.md](findings/register-module-flow.md): two-phase flow.
- [why-module-not-generated.md](findings/why-module-not-generated.md): descriptors already split per file.
- [getmodule-why-removed.md](findings/getmodule-why-removed.md): 09-08 removed the factory plus provenance.
- [engine-module-coupling.md](findings/engine-module-coupling.md): construction still needs Engine.
- NativeEngine `SDK`: `ModuleManagementAndMutableProvenanceAreAbsent` must allow lookup and still forbid the compile entry.

## Scope

Do: create shells from ModuleDesc at Register; public lookup APIs; attach types by `LogicalSourceKey`; fill `ScriptModule`.

Do not: restore `AddScriptSection` / `Build`; expose `Type.GetModule()`; engine-free `asCModule`; rewrite ClassGen; ClassGen UserData / UClass materialization.

## Constraints

- `asCModule` construction still needs Engine.
- `FAngelscriptEngine::GetModule` still returns `ModuleDesc`.
- Do not forge a compiler shell in a bind helper.

## Approach

1. After current TypeId install, `asCEngineCompileRegistration::Register` walks CompileOutput modules.
2. Each module `new asCModule` and owns Type/Function/Global for that source file.
3. Restore the three `asIScriptEngine` lookup symbols.
4. Flip SDK asserts: lookup present, compile entry still absent.

## Alternatives and flip

- Host creates the shell after Register: flip if Register cannot see ModuleDesc names.
- ClassGen reads `typesByName`: flip if setting `Type.module` breaks HotReload/JIT.
- Restore `GetModule(name, flags)`: flip if callers must take `asEGMFlags`. That enum is already gone.

## Failure

- Lookup without shells: `GetModule` is always nullptr and ClassGen still crashes.
- Restoring `ALWAYS_CREATE` brings the old compile factory back.
- One Definitions without a per-file split packs many `.as` files into one module.

## Verification

- `NativeEngine.Compile.SDK`: public lookup exists; `AddScriptSection` / `Build` stay absent.
- `CompileLifecycle`: two-file compile; after Register `GetModule(fileKey)` is non-null and each type's `module` points at the matching shell.
- Do not add `ClassGenMaterialization` UserData proof in this Change.

## Exploration Carryover

Carryover is recorded on the local draft handoff. Change files do not depend on `openspec/drafts/` paths.
