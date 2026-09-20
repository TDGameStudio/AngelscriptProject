# Register per-file asCModule identity

Seeded from [attachments/drafts/design.md](attachments/drafts/design.md). Approval R10.

Compile stays on `asCDefinitions`. Engine arrives late, then splits modules per `.as` and offers lookup. Flow: [attachments/drafts/findings/register-module-flow.md](attachments/drafts/findings/register-module-flow.md).

## Goals / Non-Goals

**Goals:** after Register with CompileOutput, each ModuleDesc has one `asCModule`; `Type.module`, `ScriptModule`, and Engine tables agree; public lookup exists; compile factory stays gone.

**Non-Goals:** `AddScriptSection` / `Build` / `ALWAYS_CREATE`; `Type.GetModule()`; engine-free `asCModule`; host `FAngelscriptEngine::GetModule` returning `asCModule`; ClassGen UserData.

## Decisions

- Compile unit remains `asCDefinitions`. Do not move Frozen/Attach onto `asCModule`.
- `asCModule` still requires Engine at construction (`as_module.cpp:169`).
- New Register overload takes `asCCompileOutput&`. Existing `Register(Sets)` does not invent shells (host/VM graphs).
- Module name is `FAngelscriptModuleDesc::ModuleName`, already the fragment `LogicalSourceKey` (`as_descriptor_consumer.cpp:348`).
- Attach types whose Class/Enum/Delegate `Semantic.SourceAnchor.LogicalSourceKey` or `StableDeclarationKey` matches that ModuleDesc; set `Type.module` and `asCModule::AddClassType` / `AddEnumType` / `AddCallableType`.
- Insert the shell into `scriptModules` and `scriptModulesByName` (ctor does not; `SetName` only maintains the name map).
- `RegisterCompiledDefinitions(Engine, Builder)` passes `GetCompileOutput()` into the new overload before `TakeDefinitions()`.
- Lookup: missing name or null name returns nullptr. `GetModuleByIndex` out of range returns nullptr.
- Host `FAngelscriptEngine::GetModule` remains `ModuleDesc`.

## Call chains

```
asCBuilder.RunThrough(ByteCodeEmitted)
→ TakeDefinitions()                         // private TypeInfo, Engine = null
→ GetCompileOutput()                        // N ModuleDesc, ScriptModule = null
→ asCEngineCompileRegistration.Register(Sets, Output)
   ├─ RegisterExternalDefinitions           // Type.engine + TypeId
   └─ each ModuleDesc
        asNEW asCModule(ModuleName, engine)
        scriptModules / scriptModulesByName
        Type.module / ScriptModule
        AddClassType / AddEnumType / AddCallableType
→ asIScriptEngine.GetModule(name)           // lookup only
→ ClassGen GetNamespacedTypeInfoForClass    // ModuleDesc->ScriptModule
```

Measured at: `38e1b7a4fe9bbc540106f28d7858ccd5d899868f`

dirty: yes; parent tree already has Language fixtures, container authors, and other in-flight Changes. This Change owns only the Register identity + lookup files listed in `tasks.md`.
