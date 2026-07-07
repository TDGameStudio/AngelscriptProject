## Why

当前 IDE 重构已经把 `UAngelscriptSubsystem` 改成 engine 级 `UEngineSubsystem`，这更符合名称直觉：它应该是 Angelscript 插件的主 subsystem 和 `FAngelscriptEngine` 权威 owner。

但代码里仍然保留 `UAngelscriptGameInstanceSubsystem`，而且它仍有 `OwnedEngine`、`PrimaryEngine`、tick ownership 和 ambient current-engine fallback。这会让 AS engine 生命周期看起来同时属于 engine subsystem 和 game-instance subsystem，后续继续减少 `FAngelscriptEngine::Get()` 时会混淆权威入口。

## What Changes

- 记录当前方向：`UAngelscriptSubsystem` 是 engine 级 subsystem，替代旧 `UAngelscriptEngineSubsystem` 命名。
- 将 `UAngelscriptSubsystem` 定义为 `FAngelscriptEngine` 的唯一权威 owner / 获取入口。
- 删除 native runtime 管理类 `UAngelscriptGameInstanceSubsystem`：
  - 删除 `OwnedEngine`、`PrimaryEngine`、`bOwnsPrimaryEngine`、`ActiveTickOwners` 等 owner 状态。
  - 移除 game-instance subsystem 对 engine tick 的接管逻辑。
  - 调整 `FAngelscriptEngine::TryGetCurrentEngine()`，优先从 engine-level `UAngelscriptSubsystem` 获取当前 engine。
- 更新 subsystem 绑定和测试，区分 engine subsystem 与 game-instance subsystem 的职责。
- 明确 `UScriptGameInstanceSubsystem` 是脚本继承基类，必须保留；删除目标不是它。
- 保留旧 `refactor-as-execution-context` 为历史背景；当前不引入 `FAngelscriptExecutionContext`。

## Capabilities

### New Capabilities

- `as-subsystem-engine-access`: 定义 `UAngelscriptSubsystem` 作为 engine 级 AS engine owner 的访问模型，以及删除 native `UAngelscriptGameInstanceSubsystem` 的边界。

### Modified Capabilities

- `as-execution-context`: 记录通用 execution-context 方案继续延后，当前先统一 engine ownership。

## Impact

- Runtime core:
  - `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptSubsystem.h`
  - `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptSubsystem.cpp`
  - `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptGameInstanceSubsystem.h`
  - `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptGameInstanceSubsystem.cpp`
  - `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.cpp`
  - `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptRuntimeModule.cpp`
- Tests:
  - engine subsystem lifecycle tests
  - game-instance subsystem lifecycle/tick tests
  - subsystem binding tests
  - shared test engine acquisition helpers
- Documentation / OpenSpec:
  - 重写 `refactor-as-subsystem-engine-access`，从 game-instance-first 改为 engine-level ownership consolidation。
