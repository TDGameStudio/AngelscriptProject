# Tasks: refactor-as-runtime-typeinfo-engine-scoped

> This change only records already-implemented facts into the OpenSpec baseline. All corresponding code had already landed in the `Plugins/Angelscript/` submodule; this change does not modify code.

## 1. Deglobalize Static TypeInfo

- [x] 1.1 <!-- Non-TDD --> Refactor `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Helper_GetTypeInfo.h` so `TGetStaticTypeInfo<T>` stores type info per engine instead of one process-wide pointer. Provide `SetForEngine` / `GetForEngine` / `IsForEngine` / `ClearForEngine`. **Verified**: `Helper_GetTypeInfo.h:62` is now `TMap<asIScriptEngine*, asITypeInfo*> TypeInfosByEngine`, with no remaining process-wide pointer.

- [x] 1.2 <!-- Non-TDD --> Add engine teardown cleanup so static TypeInfo entries for the outgoing engine are removed before the underlying AS engine is released. **Verified**: `AngelscriptEngine.cpp:1440` calls `FAngelscriptStaticTypeInfoRegistry::ClearForEngine(Engine)` on the teardown path.

- [x] 1.3 <!-- Non-TDD --> Migrate `Bind_FString.cpp` and `Bind_FText.cpp` to write/read current-engine TypeInfo via the new helper instead of `TGetStaticTypeInfo<T>::TypeInfo`. **Verified**: `Bind_FString.cpp:119,156` + `Bind_FText.cpp:77,153` all use the `IsForEngine` / `SetForEngine` API.

## 2. Audit Legacy Fallback Storage

- [x] 2.1 <!-- Non-TDD --> Audit `AngelscriptType.cpp::LegacyDatabase`, `AngelscriptBinds.cpp::LegacyBindState`, `AngelscriptBindDatabase.cpp::LegacyBindDatabase`. Confirm they hold only UE-side metadata. Migrate or guard any path that stores AS runtime objects. **Verified**: all three are pure UE metadata (FName / TArray / descriptors) with no `asITypeInfo*` / `asIScriptFunction*` fields. They can remain process-wide.

- [x] 2.2 <!-- Non-TDD --> Audit `GAngelscriptContextPool` teardown. Confirm contexts are matched by requested `asIScriptEngine` and that destroying an engine releases or invalidates that engine's pooled contexts. **Verified**: `AngelscriptEngine.cpp:1211` and `:1362` call `ReleaseContextsForScriptEngine` during teardown, releasing pooled contexts by engine.
