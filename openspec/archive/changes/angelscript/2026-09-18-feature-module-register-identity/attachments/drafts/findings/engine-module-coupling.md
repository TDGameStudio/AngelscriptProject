# Engine and asCModule coupling today

Source: local draft finding `engine-module-coupling.md`. Approval: R3.

## Three layers

- **`asCModule` object**: tightly coupled. Construction needs Engine; rename/discard mutate Engine tables.
- **New compile / Register**: not coupled. `asCDefinitions` compiles offline; Register writes `Type.engine` + TypeId; it does not create Module or set `Type.module`.
- **Public SDK**: already split. `asCScriptEngine::GetModule` deleted; `asIScriptModule` has no `AddScriptSection` / `Build`; `asITypeInfo::GetModule` deleted.

## Object layer

```
asCModule
├─ [member] asCScriptEngine* engine          // required at ctor
├─ [member] asSNameSpace* defaultNamespace   // ctor reads engine->nameSpaces[0]
├─ [calls] SetName / Discard
│   └─ engine->scriptModulesByName Add/Remove
└─ [calls] Build (still on the class, gone from the public interface)
    └─ engine->RequestBuild / PrepareEngine
```

```
asCScriptEngine
├─ [member] scriptModules                    // Discard on shutdown; almost no Push in maintained code
├─ [member] scriptModulesByName              // SetName; GetModule deleted
└─ [member] definitionSets                   // new install table, parallel to scriptModules
```

`asCTypeInfo::GetEngine` / `asCScriptFunction::GetEngine` already delay: own `engine`, else `definitions->GetBoundEngine()`. `Type.module` remains an internal field.
