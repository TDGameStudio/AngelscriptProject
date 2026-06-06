# refactor-as-runtime-typeinfo-engine-scoped

## Why

`refactor-as-runtime-global-state` 是个杂烩 change：tasks.md 显示 0/15，但代码事实表明
TypeInfo + Legacy fallback + ContextPool 三块已经实际落地。让一条 change 同时承载"已落地"
和"未落地"的状态会让 OpenSpec 失去记录功能，需要把已经做完的部分抽出来归档为基线。

本 change 抽取的范围是已经在 runtime 中可见的事实：

- `Binds/Helper_GetTypeInfo.h` 上 `TGetStaticTypeInfo<T>` 已经从单个 process-wide
  `asITypeInfo*` 改成 engine-keyed `TMap<asIScriptEngine*, asITypeInfo*>`，并提供
  `SetForEngine` / `GetForEngine` / `IsForEngine` / `ClearForEngine` 操作。
- `Core/AngelscriptEngine.cpp` 在 engine teardown 路径调用
  `FAngelscriptStaticTypeInfoRegistry::ClearForEngine`，确保旧 engine 的 TypeInfo
  条目在 AS engine release 之前被清掉。
- `Bind_FString.cpp` / `Bind_FText.cpp` 的 format path 全部走新 API，没有遗留
  `TGetStaticTypeInfo<T>::TypeInfo` 直接访问。
- 三个 legacy fallback registry（`AngelscriptType.cpp::LegacyDatabase`、
  `AngelscriptBinds.cpp::LegacyBindState`、`AngelscriptBindDatabase.cpp::LegacyBindDatabase`）
  经审计仅保存 UE 元数据，没有 AS runtime object 跨 engine 暴露面。
- `GAngelscriptContextPool` 在 engine teardown 时调用 `ReleaseContextsForScriptEngine`
  释放消失 engine 的 context。

剩余的 enum lookup 去全局化、ToString fallback fence、多 engine format 回归测试都不
属于本 change，由后续 `refactor-as-runtime-globals-enum-and-tostring` 承接。
8 个 `FAngelscriptClassGenerator` 静态委托去全局化由独立的
`refactor-as-classgen-engine-owned-hooks` 承接。

## What Changes

本 change 不改代码——它的全部目标在历史 commit 中已经完成。本 change 的唯一作用是：

- 把已实施的事实记录为 capability `as-engine-scoped-runtime-state` 的 ADDED
  requirements
- 让基线 spec 显示去全局化"已经确立的部分"，方便后续 enum / ToString 增量在基线之
  上做 MODIFIED 增量

## Capabilities

### New Capabilities

- **as-engine-scoped-runtime-state**: 定义 runtime 中引用 AS engine-owned 对象的存储
  规则，覆盖 TypeInfo engine-keyed、teardown 清理、legacy fallback 元数据约束、context
  pool engine-keyed teardown 四类已落地的事实。

### Modified Capabilities

- None.

## Impact

- 仅 OpenSpec 文件改动。
- `Plugins/Angelscript/Source/AngelscriptRuntime/` 下相关代码已实施，本 change
  不涉及代码改动。
- 后续 `refactor-as-runtime-globals-enum-and-tostring` 在本 change 建立的基线 spec
  上做 MODIFIED 增量。
