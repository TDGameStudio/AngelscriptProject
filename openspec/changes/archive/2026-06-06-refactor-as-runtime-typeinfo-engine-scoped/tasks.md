# Tasks: refactor-as-runtime-typeinfo-engine-scoped

> 本 change 只是把已实施事实记录到 OpenSpec 基线。所有任务对应的代码都已经在
> 子模块 `Plugins/Angelscript/` 落地，本 change 不修改代码。

## 1. Deglobalize Static TypeInfo

- [x] 1.1 <!-- Non-TDD --> Refactor `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Helper_GetTypeInfo.h` so `TGetStaticTypeInfo<T>` stores type info per engine instead of one process-wide pointer. Provide `SetForEngine` / `GetForEngine` / `IsForEngine` / `ClearForEngine`. **Verified**: `Helper_GetTypeInfo.h:62` 现在是 `TMap<asIScriptEngine*, asITypeInfo*> TypeInfosByEngine`，无遗留 process-wide pointer。

- [x] 1.2 <!-- Non-TDD --> Add engine teardown cleanup so static TypeInfo entries for the outgoing engine are removed before the underlying AS engine is released. **Verified**: `AngelscriptEngine.cpp:1440` 调用 `FAngelscriptStaticTypeInfoRegistry::ClearForEngine(Engine)` 在 teardown 路径。

- [x] 1.3 <!-- Non-TDD --> Migrate `Bind_FString.cpp` and `Bind_FText.cpp` to write/read current-engine TypeInfo via the new helper instead of `TGetStaticTypeInfo<T>::TypeInfo`. **Verified**: `Bind_FString.cpp:119,156` + `Bind_FText.cpp:77,153` 全部走 `IsForEngine` / `SetForEngine` API。

## 2. Audit Legacy Fallback Storage

- [x] 2.1 <!-- Non-TDD --> Audit `AngelscriptType.cpp::LegacyDatabase`, `AngelscriptBinds.cpp::LegacyBindState`, `AngelscriptBindDatabase.cpp::LegacyBindDatabase`. Confirm they hold only UE-side metadata. Migrate or guard any path that stores AS runtime objects. **Verified**: 三处均为纯 UE 元数据（FName / TArray / 描述符），无 `asITypeInfo*` / `asIScriptFunction*` 字段。可继续保留为 process-wide。

- [x] 2.2 <!-- Non-TDD --> Audit `GAngelscriptContextPool` teardown. Confirm contexts are matched by requested `asIScriptEngine` and that destroying an engine releases or invalidates that engine's pooled contexts. **Verified**: `AngelscriptEngine.cpp:1211` 和 `:1362` 在 teardown 调用 `ReleaseContextsForScriptEngine`，按 engine 释放池内 context。
