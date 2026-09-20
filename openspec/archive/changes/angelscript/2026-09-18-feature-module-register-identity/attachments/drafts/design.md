# asCModule as a late-born runtime identity

Source: local draft `angelscript/module-identity-attach` scope `runtime-identity` `design.md`. Approval: R10.

Compile still uses `asCDefinitions`. The Engine appears late, then splits modules per `.as` and offers lookup. Flow: [register-module-flow.md](findings/register-module-flow.md).

## Settled

- The compile unit remains `asCDefinitions`. Do not move Frozen/Attach back onto `asCModule`.
- Do not fully separate Engine and Module. `asCModule` still requires Engine at construction.
- Each `.as` / fragment `FAngelscriptModuleDesc` becomes `new asCModule(name, engine)` at Register. Wire `Type.module`, `ScriptModule`, and `scriptModules`.
- Do not restore `AddScriptSection` / `Build` / `ALWAYS_CREATE`.
- Do not expose `Type.GetModule()`.
- Do not forge a compiler shell in a bind helper.
- ClassGen still reads `ModuleDesc->ScriptModule`.
- Restore lookup on `asIScriptEngine`: `GetModule(const char* name) const`, `GetModuleCount`, `GetModuleByIndex`. Missing name returns nullptr.
- Host `FAngelscriptEngine::GetModule` still returns `ModuleDesc` only.
- Target Change: `angelscript/feature-module-register-identity`.

## Call chains

```
asCBuilder.RunThrough(ByteCodeEmitted)
→ TakeDefinitions()                         // private TypeInfo, Engine = null
→ TakeCompileOutput()                       // N ModuleDesc, ScriptModule = null
→ asCEngineCompileRegistration.Register
   ├─ RegisterExternalDefinitions           // Type.engine + TypeId
   └─ each ModuleDesc
        new asCModule(name, engine)
        Type.module / ScriptModule / scriptModules
→ asIScriptEngine.GetModule(name)           // lookup only
→ ClassGen GetNamespacedTypeInfoForClass    // ModuleDesc->ScriptModule
```

## Open

None. R10 handed this Change off.
