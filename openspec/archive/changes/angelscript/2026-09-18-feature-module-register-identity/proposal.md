## Why

Register already binds Engine and TypeId on `asCDefinitions`, but it never creates `asCModule`. Each `.as` already has an `FAngelscriptModuleDesc` with `ScriptModule == nullptr`. ClassGen still reads that pointer, and the 09-08 SDK cut removed lookup together with the old compile factory.

## What Changes

- After TypeId install, Register walks CompileOutput and constructs one `asCModule(name, engine)` per ModuleDesc.
- Wire `Type.module`, `ModuleDesc.ScriptModule`, and `scriptModules` / `scriptModulesByName`.
- Restore lookup-only `asIScriptEngine::GetModule(const char* name) const`, `GetModuleCount`, and `GetModuleByIndex`.
- Keep compile on `asCBuilder` + `asCDefinitions`. Do not restore `AddScriptSection` / `Build` / `ALWAYS_CREATE`.

## Capabilities

### New Capabilities

- `angelscript/runtime/type-registry`: Register attaches per-file `asCModule` identity; Engine lookup is name-only.

### Modified Capabilities

- `angelscript/language/frontend/builder`: CompileOutput `ScriptModule` stays null until Register.

## Impact

Plugin: `asIScriptEngine` / `asCScriptEngine` lookup, `asCEngineCompileRegistration`, NativeEngine Compile SDK and CompileLifecycle tests, Builder-path `RegisterCompiledDefinitions` helper.

## Non-goals

`AddScriptSection` / `Build` / `ALWAYS_CREATE`. Public `Type.GetModule()`. Engine-free `asCModule`. Changing host `FAngelscriptEngine::GetModule` (still `ModuleDesc`). ClassGen UserData / UClass materialization. Forging a compiler shell in a bind helper.
