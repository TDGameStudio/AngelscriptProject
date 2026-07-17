# `refactor-uht-binding-registry` Baseline

Captured before source migration on 2026-07-17.

## Generated function-table output

- `AS_FunctionTable_Summary.json`: `5835` total entries
- Direct entries: `3358`
- Stub entries: `2477`
- Cross-module entries: `0`
- Generated shard files: `29`
- Modules: `11`
- Cross-module generation: disabled
- Layout token: `0xA5C0DE02`
- Existing generated registration lines: `5835` calls to `FAngelscriptBinds::AddFunctionEntry`

## Source/reference inventory

The pre-migration scan over `Plugins/Angelscript/Source`, maintained Chinese knowledge documents, and active OpenSpec specs reported:

- `AddFunctionEntry`: `61` matches
- `FFuncEntry`: `90` matches
- `ClassFuncMaps`: `76` matches
- `GetClassFuncMaps`: `21` matches
- `FAngelscriptCrossModuleEntry`: `40` matches
- `FAngelscriptCrossModuleFeatureReader`: `16` matches
- `AngelscriptCrossModuleBindings`: `52` matches

Historical reports, deprecated plans, temporary notes, and archived OpenSpec records are excluded from the migration scan.
