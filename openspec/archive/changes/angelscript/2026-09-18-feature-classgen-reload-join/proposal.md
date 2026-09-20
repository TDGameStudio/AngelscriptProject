## Why

Initial compile already materializes ClassGen UserData, but `PerformHotReload` still sends new preprocessor modules through the dead Stage1–4 block. A second `Register` also collides: one Initial `asCDefinitions` and the live `asCModule` name occupy the engine index.

## What Changes

- Initial and later compiles Register one `asCDefinitions` per preprocessor `ModuleDesc`.
- `CompileModules(FullReload)` and `SoftReloadOnly` retire those compile sets and dependents, Builder+Register, and skip Stage1–4.
- Existing ClassGen Soft/Full and PIE structural downgrade stay.
- `ClassGenReload` proves reload UserData; `ClassGenMaterialization.ReloadKeepsLegacyStageError` no longer requires the Stage1 death error.

## Capabilities

### New Capabilities

None. Reload joins the existing class-generation capability.

### Modified Capabilities

- `angelscript/runtime/class-generation`: Initial Register is per file; FullReload and SoftReloadOnly rematerialize UserData after retire/Register. Failed reload keeps the last generation.

## Impact

Plugin: `FAngelscriptEngine::CompileModules` Builder join; selected-set retire next to `RetireExternalDefinitions`; NativeEngine Compile `ClassGenReload` tests and the Materialization reload case.

Parent repository: this Change's OpenSpec records only.

## Non-goals

CacheV2 function reuse. Delegate / event UserData. Frontend UObject creation. Rewriting ClassGen. Restoring `ALWAYS_CREATE` / `Build`. Full-engine retire. Replace-by-key inside one set. A shadow engine.
