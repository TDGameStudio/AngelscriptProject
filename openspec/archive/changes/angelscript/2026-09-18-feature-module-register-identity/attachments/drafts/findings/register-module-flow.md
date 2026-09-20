# Split modules at Register

Source: local draft finding `register-module-flow.md`. Approval: R9–R10.

Engine injects late. Once present, it owns module management. Lookup is `GetModule(name)`.

## Two phases, no back edge

```
─────────────  No Engine: compile  ─────────────

    SourceReady → … → DefinitionsFrozen → ByteCodeEmitted
      asCBuilder.RunThrough
      ├─ 1 × asCDefinitions              // Type/Function/Global for the batch, Engine=null
      └─ N × FAngelscriptModuleDesc      // one per .as, ScriptModule=null

─────────────  Engine present: install + split  ─────────────

    asCEngineCompileRegistration.Register(Sets, CompileOutput)
      1. Existing: Type.engine + TypeId + typesByName
      2. New: each ModuleDesc
         new asCModule(name, engine)
         attach types for that LogicalSourceKey; Type.module = shell
         ScriptModule = shell
         scriptModules / scriptModulesByName
      3. Lookup: Engine.GetModule(name) → existing shell or nullptr
```

## Split inside Register

```
asCEngineCompileRegistration.Register
├─1─ RegisterExternalDefinitions(Set)     // first time the graph sees Engine
│     Type.engine / TypeId
│
├─2─ each CompileOutput.Module
│     ├─ asNEW asCModule(ModuleName, Engine)
│     ├─ take Type/Function/Global for that LogicalSourceKey
│     ├─ Type.module = Module
│     ├─ ModuleDesc.ScriptModule = Module
│     └─ scriptModules + scriptModulesByName
│
└─3─ asIScriptEngine::GetModule(name)      // table lookup, no compile, no CREATE
```

Ownership uses `ClassDesc.Semantic.SourceAnchor.LogicalSourceKey` against `asCTypeInfo` stable key / name. One Definitions graph may feed N modules.

## Who looks up what

```
asIScriptEngine.GetModule(name)           // asCModule*, only after Register
FAngelscriptEngine.GetModule(name)        // FAngelscriptModuleDesc
ClassGen
└─ ModuleDesc->ScriptModule               // shell filled in step 2
```

Do not restore `AddScriptSection` / `Build` / `ALWAYS_CREATE`. Do not expose `Type.GetModule()`.
