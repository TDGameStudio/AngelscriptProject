# refactor-as-runtime-global-state

## Why

`FString::Format("{0}", "Hello")` 暴露的不是单个格式化问题，而是 runtime 去全局化还没收口：多个 `FAngelscriptEngine` / `asIScriptEngine` 共存时，仍有进程级静态状态保存了某个 engine 创建的 AngelScript 对象指针。

本次 OpenSpec 的主目标是继续去全局化。`TGetStaticTypeInfo<T>::TypeInfo` 是当前已复现的第一处高风险状态；`FString::Format` / `FText::Format` 是它的可见失败面。

## What Changes

- 建立 runtime 全局状态分层规则：纯元数据可以全局复用，AngelScript engine-owned 对象必须 engine-owned、engine-keyed 或随 engine teardown 清理。
- 将 `TGetStaticTypeInfo<T>` 从单个 process-wide `asITypeInfo*` 改成 engine-scoped 状态。
- 更新 `FString::Format` 和 `FText::Format`，让它们使用当前 engine 的类型身份，而不是历史 engine 留下的静态指针。
- 审计并处理同类状态：script enum lookup、ToString legacy fallback、legacy type/bind database fallback、thread-local context pool。
- 增加能证明多 engine / engine 重建顺序稳定的回归覆盖。

## Capabilities

### New Capabilities

- **as-engine-scoped-runtime-state**: Runtime 中引用 AngelScript engine-owned 对象的状态必须按 engine 分区、迁入 `FAngelscriptEngine`，或由 engine 生命周期清理。

### Modified Capabilities

- **Runtime global-state containment**: 明确哪些全局状态可保留，哪些必须去全局化，并用任务清单追踪处理顺序。
- **FString / FText formatting**: 作为第一条验收链路，格式化参数转换必须在多 engine 场景下稳定使用当前 engine 类型身份。

## Impact

- **AngelscriptRuntime**: `Binds/Helper_GetTypeInfo.h`、`Binds/Bind_FString.cpp`、`Binds/Bind_FText.cpp`、`Binds/Bind_UEnum.cpp`、`Binds/Bind_FString.cpp` 的 ToString storage、`Core/AngelscriptType.cpp`、`Core/AngelscriptBinds.cpp`、`Core/AngelscriptBindDatabase.cpp`、`Core/AngelscriptEngine.*`。
- **AngelscriptTest**: 新增或调整多 engine / engine 重建顺序下的 bindings 与 engine lifecycle 覆盖。
- **Build / test workflow**: 只使用 `Tools\RunBuild.ps1`、`Tools\RunTests.ps1`、`Tools\RunTestSuite.ps1`。