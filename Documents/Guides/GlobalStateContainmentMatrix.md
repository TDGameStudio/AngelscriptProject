# 全局引擎 / WorldContext 依赖分类矩阵

> 目的：为 `Plan_TechnicalDebt.md` 的 `P5.1` / `P5.2` 提供可执行的 containment 基线，明确哪些调用点已经有 scoped wrapper，哪些仍属于低风险收口候选。

## 1. Compile / ClassGenerator 路径

| 代表文件 | 当前模式 | 已有 wrapper | 低风险收口判断 |
| --- | --- | --- | --- |
| `Plugins/Angelscript/Source/AngelscriptRuntime/ClassGenerator/AngelscriptClassGenerator.cpp` | 多处直接依赖 `FAngelscriptEngine::Get()` 访问模块、类和反射缓存 | 无统一 wrapper；由 `FAngelscriptEngine` 自身承载生命周期 | 暂不在本计划内直接改造；属于更高耦合的 compile/class-generation 核心路径 |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.cpp` | `TryGetGlobalEngine()` / `SetGlobalEngine()` / `CurrentWorldContext` 的实现与汇总入口 | `FScopedTestEngineGlobalScope` / `FScopedGlobalEngineOverride` 在测试侧可用 | 本计划只做调用点 containment，不在这里展开架构重写 |

## 2. World-context 绑定路径

| 代表文件 | 当前模式 | 已有 wrapper | 低风险收口判断 |
| --- | --- | --- | --- |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_SystemTimers.cpp` | 直接读取 `FAngelscriptEngine::CurrentWorldContext`，但每个 bind 都显式 `SetPreviousBindRequiresWorldContext(true)` | `FAngelscriptGameThreadScopeWorldContext`、`FScopedTestWorldContextScope` | 已经具备显式“需要 world context”语义，后续可在更大去全局化计划中统一参数化 |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UUserWidget.cpp` | 主要是 UMG 绑定与绘制辅助，当前未见直接 `CurrentWorldContext` 调用 | 无额外 wrapper 需求 | 暂不作为 `P5.2` 优先项 |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptGameInstanceSubsystem.cpp` | 通过 `CurrentWorldContext` 解析当前 subsystem，承接生产引擎附着 | `UAngelscriptGameInstanceSubsystem::GetCurrent()` 本身就是集中入口 | 适合作为文档分类样本，但不优先在本计划中重构 |

## 3. Test / Debug 辅助路径

| 代表文件 | 当前模式 | 已有 wrapper | 低风险收口判断 |
| --- | --- | --- | --- |
| `Plugins/Angelscript/Source/AngelscriptTest/Shared/AngelscriptTestUtilities.h` | 测试层通过 scoped helper 显式覆盖 global engine / world context | `FScopedGlobalEngineOverride`、`FScopedTestWorldContextScope` | 已 containment，作为后续 runtime containment 的样板 |
| `Plugins/Angelscript/Source/AngelscriptTest/Shared/AngelscriptTestEngineHelper.cpp` | 编译 helper 进入前显式安装 `FScopedGlobalEngineOverride` | `FScopedGlobalEngineOverride` | 已 containment |
| `Plugins/Angelscript/Source/AngelscriptTest/Shared/AngelscriptFunctionalTestUtils.h` | 功能测试 helper 在编译与 tick 时显式安装 global engine / world context scope | `FScopedGlobalEngineOverride`、`FScopedTestWorldContextScope` | 已 containment |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Debugging/AngelscriptDebugServer.cpp` | 仍直接触发 `FAngelscriptEngine::Get()` 与 `CurrentWorldContext` | 无显式 owner engine 注入 | **本计划 `P5.2` 的首要低风险 containment 候选** |

## 4. 现有 wrapper 速查

- `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.h:561`：`FScopedTestEngineGlobalScope`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.h:603`：`FScopedGlobalEngineOverride`
- `Plugins/Angelscript/Source/AngelscriptTest/Shared/AngelscriptTestUtilities.h:33`：`FScopedTestWorldContextScope`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.h`：`FAngelscriptGameThreadScopeWorldContext`

## 5. `P5.2` 优先级结论

- **优先处理**：`Debugging/AngelscriptDebugServer.cpp`
  - 原因：这是当前 runtime 里仍然显式依赖 `FAngelscriptEngine::Get()` / `CurrentWorldContext` 且不走 scoped wrapper 的代表性路径。
  - 目标：把 debug server 对 owner engine / world context 的访问从“直接读全局”收口到更显式的入口。
- **暂不直接处理**：`ClassGenerator` / `Engine core` 大面调用点
  - 原因：这些路径是引擎核心生命周期实现，不适合作为本计划里的“低风险 containment”小步快跑项。
