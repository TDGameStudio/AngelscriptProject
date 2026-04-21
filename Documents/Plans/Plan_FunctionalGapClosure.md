# 功能未闭环差距收口计划

## 背景与目标

### 背景

2026-04-21 差距分析确认了三个"接口已存在但功能未闭环"的核心缺口。这三个缺口共同构成了当前插件与 Hazelight 基线之间**最直接影响脚本开发者日常使用**的功能性差距。

| 缺口 | 现状 | 影响 |
|------|------|------|
| Script Subsystem | 基类存在，预处理器/类生成器有路径，但自动化测试仍锁在"应编译失败" | 阻塞 WorldSubsystem / GameInstanceSubsystem 架构模式 |
| Network RPC 声明 | 预处理器已解析 `Server`/`Client`/`NetMulticast`，类生成器写入 `FUNC_Net*`，但缺少端到端验证和示例 | 多人游戏脚本不可行（或可行但无证据） |
| FConsoleCommand | 绑定已存在且测试覆盖较全，Shipping 下刻意禁用 | **实际差距远小于预期，主要是文档/可见性** |

### 目标

将上述三项从"接口在、能力没闭环"推进到"有正例测试、有可运行示例、有明确能力边界"的状态。

### 与现有计划的关系

- 承接 `Plan_HazelightCapabilityGap.md` 中 P2.1（Subsystem）、P2.2（Network）
- 承接 `Plan_StatusPriorityRoadmap.md` 中 Phase 1.2（Subsystem）、Phase 3.1（Network）
- 与 `Plan_NetworkReplicationTests.md` 互补：该计划聚焦测试验证闭环，本计划聚焦功能本身的闭合
- 与 `Plan_GlobalVariableAndCVarParity.md` 共享 FConsoleCommand 条目，本计划仅做状态确认和遗留项收口

## 范围与边界

**纳入范围**：
- Script Subsystem（World / GameInstance / LocalPlayer / Engine）的脚本子类化支持
- Network RPC 声明（Server / Client / NetMulticast）在默认构建下的端到端验证
- 属性复制（Replicated / ReplicatedUsing / ReplicationCondition）的示例与验证
- FConsoleCommand 的状态确认与遗留项评估

**排除范围**：
- `WITH_ANGELSCRIPT_HAZE` 专属路径（NetFunction / CrumbFunction / DevFunction）
- 引擎侧补丁依赖项（Push Model Replication、UHT 改造等）
- 完整多人网络栈测试（跨进程 client/server、真实 packet 流）
- FConsoleCommand 在 Shipping 构建下的启用（属产品安全策略，非功能缺口）

## 当前事实状态快照

### Gap 1：Script Subsystem

**已有**：
- C++ 基类：`ScriptWorldSubsystem.h`（`UWorldSubsystem` + `FTickableGameObject` + `IStreamingWorldSubsystemInterface`）、`ScriptGameInstanceSubsystem.h`、`ScriptLocalPlayerSubsystem.h`、`ScriptEngineSubsystem.h`
- 预处理器：为继承 `UGameInstanceSubsystem` / `UWorldSubsystem` 的脚本类生成 `Get()` 静态方法（`AngelscriptPreprocessor.cpp` ~1401-1425）
- 类生成器：热重载时 `UWorldSubsystem` 子类有 `DeactivateExternalSubsystem` 等重新注册处理（`AngelscriptClassGenerator.cpp` ~2767-2780）
- `Bind_Subsystems.cpp`：对原生子系统类提供 `ClassName Get()` 全局函数

**未闭环**：
- `AngelscriptSubsystemScenarioTests.cpp`：World 生命周期（~104-109）、Tick（~146-151）、Actor 访问（~194-199）、GameInstance 生命周期（~241-246）四个场景均显式断言 `TestFalse(...bCompiled)`，将编译失败视为当前分支预期行为
- `LocalPlayer` / `Engine` 子系统无场景测试
- 脚本示例（`Example_SubsystemLifecycle.as`）被迫使用 `UActorComponent` 代替真实子系统模式

**关键问题**：脚本继承 `UScriptWorldSubsystem` / `UScriptGameInstanceSubsystem` 时**具体失败在哪一步**需要运行时诊断确认。可能涉及：
1. 类生成器在子系统子类上的校验逻辑
2. `BlueprintImplementableEvent` 的 `BP_*` 方法与脚本覆盖的对齐
3. 子系统注册时序与 World/GameInstance 生命周期的耦合

### Gap 2：Network RPC 声明

**已有（默认 `WITH_ANGELSCRIPT_HAZE=0` 构建）**：
- 预处理器解析：`Server`、`Client`、`NetMulticast`、`WithValidation`、`Unreliable`（`AngelscriptPreprocessor.cpp` ~1721-1791）
- 属性复制：`Replicated`、`ReplicationCondition`、`ReplicatedUsing`（`AngelscriptPreprocessor.cpp` ~2684-2753）
- 类生成器：`FUNC_NetServer` / `FUNC_NetClient` / `FUNC_NetMulticast` / `FUNC_Net` / `FUNC_NetReliable`（`AngelscriptClassGenerator.cpp` ~3734-3753）
- 属性生成：`CPF_Net`、`CPF_RepNotify`、`ReplicationCondition`（`AngelscriptClassGenerator.cpp` ~3200-3211）
- Validate 路径：`AngelscriptComponent.cpp` 中 `FUNC_NetValidate` 调用脚本 `_Validate`
- `FakeNetDriver`：最小 `UNetDriver` 子类用于测试

**未闭环**：
- 无 `Plugins/Angelscript/Source/AngelscriptTest/Networking/` 主题测试目录
- 无端到端 RPC 声明 → 编译 → 调用的自动化测试
- 之前移植示例时使用了错误的 specifier 名称（`NetServer` 而非 `Server`），导致误判为"功能缺失"
- Push Model Replication 未对齐（依赖引擎侧，归入排除范围）

**关键发现**：预处理器中 RPC specifier 的名称是 `Server`/`Client`/`NetMulticast`（**不是** `NetServer`/`NetClient`）。之前示例编译失败很可能是 specifier 名称写错，而非功能缺失。需要验证。

### Gap 3：FConsoleCommand

**已有**：
- `Bind_Console.cpp`（~66-157）：`FScriptConsoleCommand` 绑定为脚本类型 `FConsoleCommand`
- 通过 `IConsoleManager::Get().RegisterConsoleCommand` + `FConsoleCommandWithWorldAndArgsDelegate` 注册
- 自动化测试全覆盖：`AngelscriptConsoleBindingsTests.cpp`（compat）、`AngelscriptConsoleCommandArgumentBindingsTests.cpp`（参数）、`AngelscriptConsoleCommandLifecycleBindingsTests.cpp`（生命周期）、`AngelscriptConsoleCommandErrorBindingsTests.cpp`（错误路径）

**实际状态**：**这不是功能缺口，而是文档/可见性缺口**。FConsoleCommand 绑定已完整存在且测试覆盖充分。Shipping 下不注册是刻意的安全策略。

**遗留项**：Help 字符串注册为空（`TEXT("")`）；脚本类型名 `FConsoleCommand` 与 C++ 内部 `FScriptConsoleCommand` 命名映射缺少文档说明。

## 分阶段执行计划

### Phase 1：诊断与验证（先搞清楚真实状态）

> 目标：在不改功能代码的情况下，先确认每个缺口的**真实失败原因**，避免基于猜测实施修复。

#### P1.1 诊断 Script Subsystem 编译失败的根因

- [ ] 在测试环境中尝试编译一个最小的 `UScriptWorldSubsystem` 脚本子类，捕获完整的编译错误文案
- [ ] 根据错误文案定位失败点（预处理器？类生成器校验？BlueprintEvent 对齐？）
- [ ] 对 `UScriptGameInstanceSubsystem` 重复同样的诊断
- [ ] 记录诊断结果到本计划的"诊断结论"章节

涉及文件（只读）：
- `Plugins/Angelscript/Source/AngelscriptTest/Subsystem/AngelscriptSubsystemScenarioTests.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/BaseClasses/ScriptWorldSubsystem.h`
- `Plugins/Angelscript/Source/AngelscriptRuntime/ClassGenerator/AngelscriptClassGenerator.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Preprocessor/AngelscriptPreprocessor.cpp`

📦 产出：诊断结论文档（更新本 Plan 的"诊断结论"章节）

#### P1.2 验证 RPC 声明在正确 specifier 名称下是否可编译

- [ ] 创建测试脚本，使用正确的 specifier 名称（`Server`/`Client`/`NetMulticast` 而非 `NetServer`/`NetClient`）
- [ ] 验证 `Replicated`、`ReplicatedUsing` 在脚本中是否正常工作
- [ ] 验证 `WithValidation` 是否正常工作
- [ ] 如果编译通过，确认是否能生成正确的 `FUNC_Net*` 标记
- [ ] 记录验证结果

涉及文件（只读/新建测试脚本）：
- `Plugins/Angelscript/Source/AngelscriptRuntime/Preprocessor/AngelscriptPreprocessor.cpp`（确认 specifier 名称）
- 新建：`Script/Tests/Test_NetworkRPC.as`（最小验证脚本）

📦 产出：RPC 验证结论（更新本 Plan）

#### P1.3 确认 FConsoleCommand 状态并降级

- [ ] 运行现有 `AngelscriptConsoleCommand*` 测试套件，确认全部通过
- [ ] 将 FConsoleCommand 从"功能缺口"重新分类为"文档/可见性改进项"
- [ ] 评估 Help 字符串支持是否值得作为后续增强

📦 产出：状态确认（本 Plan 更新）

### Phase 2：修复 Script Subsystem（基于 P1.1 诊断结论）

> 目标：使脚本可以继承 `UScriptWorldSubsystem` / `UScriptGameInstanceSubsystem` 并覆盖生命周期方法。

#### P2.1 修复编译路径

- [ ] 根据 P1.1 诊断结论，在类生成器/预处理器/校验逻辑中修复阻塞点
- [ ] 确保 `Initialize()`、`Deinitialize()`、`ShouldCreateSubsystem()`、`Tick()` 等 `BP_*` 事件可被脚本覆盖
- [ ] 验证 `Get()` 静态方法在脚本中可正常使用

涉及文件（可能需要修改）：
- `Plugins/Angelscript/Source/AngelscriptRuntime/ClassGenerator/AngelscriptClassGenerator.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Preprocessor/AngelscriptPreprocessor.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/BaseClasses/ScriptWorldSubsystem.h`
- `Plugins/Angelscript/Source/AngelscriptRuntime/BaseClasses/ScriptGameInstanceSubsystem.h`

📦 Git 提交：`[AngelscriptRuntime] Fix: enable script subclassing of ScriptWorldSubsystem and ScriptGameInstanceSubsystem`

#### P2.2 将负例测试转为正例 + 补充场景验证

- [ ] 修改 `AngelscriptSubsystemScenarioTests.cpp`：将四个 `TestFalse(...bCompiled)` 改为 `TestTrue`
- [ ] 补充运行时场景测试：World 生命周期（Initialize/Deinitialize 被调用）、Tick 递增、Actor 可访问
- [ ] 补充 `UScriptGameInstanceSubsystem` 对等场景测试
- [ ] 评估 `UScriptLocalPlayerSubsystem` 和 `UScriptEngineSubsystem` 是否需要同样处理

涉及文件：
- `Plugins/Angelscript/Source/AngelscriptTest/Subsystem/AngelscriptSubsystemScenarioTests.cpp`

📦 Git 提交：`[AngelscriptTest] Test: convert subsystem negative tests to positive and add runtime scenarios`

#### P2.3 更新示例脚本

- [ ] 将 `Script/Examples/Extended/Example_SubsystemLifecycle.as` 从 ActorComponent 模式改回真实子系统模式
- [ ] 添加 WorldSubsystem 和 GameInstanceSubsystem 的完整生命周期演示

📦 Git 提交：`[Examples] Feat: update subsystem example to use real script subsystem classes`

### Phase 3：验证并修复 Network RPC（基于 P1.2 验证结论）

> 目标：确认 RPC 声明端到端可用，或修复发现的问题，并建立最小验证闭环。

#### P3.1 修复 RPC 编译路径（如需要）

- [ ] 根据 P1.2 验证结果，修复 specifier 解析或类生成中的问题（如果有）
- [ ] 确保 `Server`/`Client`/`NetMulticast` + `Reliable`/`Unreliable` 组合可正确编译
- [ ] 确保 `WithValidation` 生成的 `_Validate` 函数被正确调用

涉及文件（可能需要修改）：
- `Plugins/Angelscript/Source/AngelscriptRuntime/Preprocessor/AngelscriptPreprocessor.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/ClassGenerator/AngelscriptClassGenerator.cpp`

📦 Git 提交：`[AngelscriptRuntime] Fix: RPC specifier compilation and code generation`（仅在需要时）

#### P3.2 建立网络专题测试

- [ ] 在 `Plugins/Angelscript/Source/AngelscriptTest/` 下新建 `Networking/` 目录
- [ ] 添加 RPC 声明编译测试：Server / Client / NetMulticast 各一个正例
- [ ] 添加属性复制编译测试：Replicated / ReplicatedUsing / ReplicationCondition
- [ ] 添加 WithValidation 编译测试
- [ ] 使用 `FakeNetDriver` 添加最小运行时复制验证（可选）

涉及文件（新建）：
- `Plugins/Angelscript/Source/AngelscriptTest/Networking/AngelscriptNetworkRPCTests.cpp`
- `Plugins/Angelscript/Source/AngelscriptTest/Networking/AngelscriptNetworkReplicationTests.cpp`

📦 Git 提交：`[AngelscriptTest] Test: add networking RPC and replication compilation tests`

#### P3.3 修复网络示例

- [ ] 更新 `Script/Examples/Extended/Example_NetworkReplication.as`：使用正确的 specifier 名称
- [ ] 添加 RPC 声明示例（Server/Client/NetMulticast）
- [ ] 验证示例可编译通过

📦 Git 提交：`[Examples] Fix: update network replication example with correct specifier names`

### Phase 4：收口与文档

#### P4.1 更新能力边界文档

- [ ] 更新 `Plan_HazelightCapabilityGap.md`：将 Subsystem 和 RPC 对应条目从"明显差距"改为"已闭环"或"部分闭环"
- [ ] 更新 `Plan_StatusPriorityRoadmap.md`：标记 P1.2 和 P3.1 的完成状态
- [ ] 将 FConsoleCommand 在 `Plan_GlobalVariableAndCVarParity.md` 中标记为"已对齐"

📦 Git 提交：`[Docs] Docs: update capability gap status after functional closure`

#### P4.2 明确引擎侧边界

- [ ] 在本计划的"引擎侧边界"章节记录哪些能力确认依赖引擎补丁
- [ ] 确认列表：Push Model Replication、`NetFunction`/`CrumbFunction`/`DevFunction`、`FUNC_NetFunction` 标记

📦 产出：更新本 Plan 的"引擎侧边界"章节

## 诊断结论

> 本章节在 Phase 1 执行后填写。

### P1.1 Script Subsystem 诊断

_待填写：具体编译错误文案、失败代码路径、修复方向_

### P1.2 Network RPC 验证

_待填写：正确 specifier 名称下的编译结果、FUNC_Net* 标记确认、遗留问题_

### P1.3 FConsoleCommand 确认

_待填写：测试运行结果、降级确认_

## 引擎侧边界

> 以下能力确认依赖 Hazelight 引擎分支（`WITH_ANGELSCRIPT_HAZE=1`），不在本计划收口范围内。

| 能力 | 引擎侧依据 | 插件侧现状 |
|------|------------|------------|
| Push Model Replication | Hazelight 在 `ASClass.cpp` 中维护 `PushModelReplicatedProperties`，写入 `REPNOTIFY_OnChanged` + push-model 标记 | 当前 `ASClass.cpp` 只把 `CPF_Net` 属性加入标准 `FLifetimeProperty` |
| `NetFunction` / `CrumbFunction` / `DevFunction` | 仅在 `#if WITH_ANGELSCRIPT_HAZE` 分支（Preprocessor ~1677-1714，ClassGenerator ~3755-3765） | 默认构建不可用 |
| `FUNC_NetFunction` 标记 | Hazelight 自定义 `EFunctionFlags` 扩展 | 当前使用标准 UE `FUNC_NetServer` / `FUNC_NetClient` / `FUNC_NetMulticast` |
| 大量属性/函数的反射自动暴露 | 引擎源码添加了 `BlueprintReadOnly` / `BlueprintReadWrite` 等修饰符 | 需手动 `Bind_*.cpp` 补齐（AActor/AController/APawn 已在 2026-04-21 完成） |

## 风险与注意事项

### 风险 1：Subsystem 失败可能涉及深层类生成器问题

诊断后可能发现 Subsystem 编译失败不是简单的配置问题，而是类生成器在处理 `UWorldSubsystem` 子类时存在根本性的路径缺失。如果是这种情况，修复工作量会显著增大。

**缓解**：Phase 1 先诊断，Phase 2 根据诊断结论调整预期和工期。

### 风险 2：RPC specifier 名称验证后仍可能失败

即使使用正确的 specifier 名称（`Server` 而非 `NetServer`），RPC 链路仍可能在类生成、运行时调度、与 `UNetDriver` 交互等环节存在问题。

**缓解**：Phase 1.2 只做编译验证，不急于做完整的运行时 RPC 调度测试。

### 风险 3：`#if WITH_ANGELSCRIPT_HAZE` 条件编译矩阵复杂

Preprocessor 和 ClassGenerator 中的条件编译路径高度交织，修改时需同时保证 Haze=0 和 Haze=1 两种配置正确。

**缓解**：所有修改只针对默认（Haze=0）路径，不触碰 Haze=1 分支。

### 风险 4：把 FConsoleCommand 的 Shipping 限制误判为功能缺口

`Bind_Console.cpp` 中 `#if !UE_BUILD_SHIPPING` 是刻意的安全策略，不应作为"功能缺口"处理。

**缓解**：Phase 1.3 明确确认并降级。

## 验收标准

1. **Script Subsystem**：脚本可继承 `UScriptWorldSubsystem`，覆盖 `Initialize`/`Deinitialize`/`Tick` 等方法，且有自动化正例测试通过
2. **Network RPC**：脚本可声明 `Server`/`Client`/`NetMulticast` 函数且编译通过，有自动化编译测试
3. **属性复制**：`Replicated`/`ReplicatedUsing` 在脚本中可编译通过且有测试
4. **FConsoleCommand**：确认已对齐，从"功能缺口"列表中移除
5. **示例脚本**：`Example_SubsystemLifecycle.as` 和 `Example_NetworkReplication.as` 使用真实 API 且可编译
6. **引擎侧边界**：Push Model、NetFunction 等明确标记为引擎侧差距，不再混入插件 backlog
7. **文档同步**：`Plan_HazelightCapabilityGap.md` 和 `Plan_StatusPriorityRoadmap.md` 相应条目状态已更新

## 阶段依赖

```
Phase 1（诊断与验证）
  ├── P1.1 Subsystem 诊断 ──→ Phase 2（修复 Subsystem）
  ├── P1.2 RPC 验证 ────────→ Phase 3（修复 Network）
  └── P1.3 Console 确认 ───→ Phase 4（收口）
                                  ↑
Phase 2 ─────────────────────────┘
Phase 3 ─────────────────────────┘
```

- Phase 2 和 Phase 3 可并行执行，互不依赖
- Phase 4 依赖 Phase 2 和 Phase 3 完成
- Phase 1 的三个子任务可并行诊断
