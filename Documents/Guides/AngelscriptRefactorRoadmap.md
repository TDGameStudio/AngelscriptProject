# AngelScript 插件架构重构路线图

> 状态：规划中  
> 更新日期：2026-07-17  
> 适用范围：`Plugins/Angelscript` 及其宿主工程、测试和开发工具链

## 1. 目标

AngelScript 插件已经具备较完整的运行时、编辑器集成、调试、热重载、StaticJIT、绑定生成和自动化测试能力。当前主要问题不是继续堆叠功能，而是既有能力之间的边界逐渐模糊，导致修改成本、测试成本和排查成本持续上升。

本路线图的目标是逐步建立以下结构：

- `AngelscriptRuntime` 的运行时能力、编辑器桥接、测试集成和扩展面具有明确的所有权。
- `AngelscriptEditor` 负责编辑器专属实现、源代码导航、热重载和编辑器工具。
- `AngelscriptTest` 负责自动化测试实现、Fixture、测试运行器和测试专用配置；它可以作为源插件验证面随插件分发。
- Engine 生命周期和 World Context 通过明确的对象关系传递，减少隐式全局访问。
- 大型实现文件按职责拆分，而不是只按文件长度机械切割。
- 测试目录、Fixture、宏和运行环境具有稳定、可预测的规则。
- 文档、OpenSpec 和源码统计使用清晰的基线口径。

## 2. 当前审计基线

以下数据来自 2026-07-17 的源码扫描，属于结构统计，不代表当天已经重新执行 UE 全量测试：

- Runtime 非 ThirdParty 目录约有 `193` 个 `.cpp`，其中 `AngelscriptEngine.cpp` 为 `5731` 行，`AngelscriptPreprocessor.cpp` 为 `4336` 行。
- `FAngelscriptEngine::Get()` 与 `CurrentWorldContext` 直接访问约 `303` 处，分布在 `57` 个 Runtime 文件中。
- Runtime 内的 `Testing/` 目录有 `24` 个源码文件，且 Runtime 仍包含文档、Commandlet、Editor Bridge 等开发期职责。
- Test 模块约有 `555` 个 `.cpp`、`2834` 个 `TEST_METHOD`；`383` 个测试文件创建 Engine，`313` 个测试文件包含生命周期宏样板。
- 当前 `test-coverage` OpenSpec 完成 `24/49`，剩余大多为低/中优先级覆盖扩展；不应让这些扩展阻塞架构收口。
- 当前工作区存在用户已有的未提交修改，特别是 DebugServer 与 Debugger Database 测试相关文件。开始重构前必须先将其独立收口或明确保护范围。

## 3. 重构原则

### 3.1 增量迁移

不进行一次性 Runtime 重写，不同时改动模块边界、Engine 生命周期和所有大文件。每个阶段都应保持可构建、可回归，并留下兼容入口供下一阶段迁移。

### 3.2 先处理结构根因

优先处理模块边界和全局 Engine 访问，再拆分大型实现文件。单纯把 God File 拆成多个文件，无法解决隐式状态和跨层依赖问题。

### 3.3 行为保持优先

第一轮重构以职责移动、依赖收口和调用路径显式化为主，不同时引入新的脚本语义或大规模 API 变化。行为变化应单独建立 OpenSpec 和回归测试。

### 3.4 每阶段都有退出条件

每个阶段必须同时记录：变更范围、受影响模块、验证命令、已知限制和未迁移调用点。不能只以“文件已经拆开”作为完成标准。

## 4. 阶段依赖

```text
Phase 0 事实基线与工作区收口
   │
   ▼
Phase 1 Runtime 职责与依赖边界收口
   │
   ▼
Phase 2 Engine Context 与全局访问收口
   │
   ├───────────────┐
   ▼               ▼
Phase 3           Phase 4
大型文件拆分       测试 Fixture 与运行模型整理
   │               │
   └───────┬───────┘
           ▼
Phase 5 配置、ThirdParty Fork 与长期维护卫生
```

Phase 3 依赖 Phase 2，因为大型文件中的职责拆分需要先明确 Engine、编译上下文和服务边界。Phase 4 可以在 Phase 1 完成后分批开始，但完整收益依赖 Phase 2 的 Context 收口。Phase 5 可提前做低风险盘点，但最终拆分应建立在前面几个阶段的边界稳定之后。

## 5. 分阶段计划

### Phase 0：事实基线与工作区收口

**建议状态：首先执行**

**目标**：让后续重构建立在同一套源码、测试和文档口径上。

**主要工作**：

- 独立处理当前 DebugServer/LSP 相关未提交修改，不与架构重构混合。
- 归档已经完成但仍显示 active 的 OpenSpec 变更。
- 更新 Runtime、Test、Coverage 的当前统计，并标注“源码扫描”和“实际测试运行”两种口径。
- 暂停非阻塞性的 Coverage 扩展，保留已经完成的覆盖记录。
- 记录一次可复用的构建、Focused Test 和 Full Test 基线。
- 为后续每个阶段记录新增、迁移、删除的调用点数量。

**交付物**：

- 清晰的仓库与 OpenSpec 状态。
- 一份当前构建和测试基线记录。
- 不与架构变更混合的既有本地修改。

**退出条件**：

- 能明确回答当前代码来自哪个提交、哪些修改尚未提交。
- 文档不再把历史测试数字当作当前实时数字。
- 至少有一组可重复的 focused verification 命令。

### Phase 1：Runtime 职责与依赖边界收口

**建议 OpenSpec 名称**：`refactor-as-runtime-boundaries`  
**优先级：P0**

**目标**：让 Runtime、Editor、Test 和开发期工具的职责重新可见，同时保留现有插件扩展面。

**主要工作**：

- 保留 `ModuleDirectory`、`Core`、`Core/Commandlets` 和 ThirdParty Source 的现有公共 Include Path；它们是外部扩展兼容面，不作为本阶段的清理目标。
- 不引入标准 UE `Public/Private` 对等目录重构；以现有目录和 Include 约定为准，单独记录哪些头是稳定扩展接口、哪些头是内部实现。
- 评估 Runtime 内 `Testing/` 的所有权，区分“编译开关开启时的 Runtime 测试集成”和“只属于 Test 的实现”，不整体搬迁目录。
- 将文档生成、Editor Debug Bridge、Editor 状态 Dump 等职责按实际调用关系分类；只迁移确实属于 Editor/Tool 的实现，不移动 Runtime 必需的注册接口。
- 解除不必要的 CodeCoverage 对 `AngelscriptTest` 配置的硬耦合；如果测试集成是设计的一部分，则通过明确的配置/适配接口表达，而不是假设 Runtime 必须完全独立于 Test。
- 区分脚本运行时能力、编辑器能力和测试辅助能力，同时保留插件当前允许的跨模块扩展方式。

**交付物**：

- Runtime/Editor/Test 依赖关系图。
- Runtime 扩展接口、内部实现和兼容 Include 的分类清单。
- 迁移后的模块依赖与构建验证记录。

**退出条件**：

- 现有公共 Include Path 的保留理由和稳定性等级已记录。
- Coverage、Docs、Commandlet、Testing 的所有权和编译条件明确。
- 新增 Runtime 代码不会无理由扩大对 Test 实现或 Editor 内部实现的耦合；必要的扩展依赖必须有明确接口或说明。

### Phase 2：Engine Context 与全局访问收口

**建议 OpenSpec 名称**：`refactor-as-engine-context-access`  
**优先级：P0**

**目标**：把 Engine、World、编译和调试上下文从隐式静态访问逐步变成显式关系。

**主要工作**：

- 已完成前置清理 `cleanup-as-subsystem-test-hooks`：`UAngelscriptSubsystem` 已移除生产类中的自动化测试 override；scan-free engine 只在 CQTest fixture 内按用例创建，不再接管生产 Subsystem 启动。
- 为编译、类生成、绑定、调试和 World 运行路径定义明确的 Context/Service 边界。
- 先从 ClassGenerator、AngelscriptBinds、DebugServer、Preprocessor 等高频热点迁移。
- 保留现有全局入口作为过渡兼容层，但禁止新增直接 `FAngelscriptEngine::Get()` 调用。
- 统一 Engine 的创建、销毁、当前上下文和测试注入语义。
- 消除通过静态计数器或跨 Subsystem 隐式握手传递所有权的情况。
- 把生产代码中的 `ForTesting` 状态和接口移到测试适配层，或用受控的注入接口替代。

**交付物**：

- Engine Context 责任图和生命周期说明。
- 全局访问迁移清单，包含保留原因和计划删除时间。
- 关键路径的 Context 注入测试。

**退出条件**：

- 关键编译、类生成、调试路径不再依赖隐式当前 Engine。
- Engine 生命周期可以被测试显式控制，不依赖前序测试残留状态。
- 全局访问数量持续下降，且不再出现新的调用点。

### Phase 3：大型实现文件按职责拆分

**优先级：P1，依赖 Phase 2**

**目标**：降低单文件认知负担，并让每个子系统有清晰的内部接口。

**建议拆分方向**：

- `AngelscriptEngine`：生命周期、编译编排、模块注册、绑定编排、诊断状态。
- `AngelscriptPreprocessor`：文件发现、模块解析、Import、宏和注释处理。
- `AngelscriptDebugServer`：传输层、DAP 协议、断点状态、Engine 调试桥接。
- `AngelscriptStaticJIT`：字节码降低、运行时 Dispatch、预编译数据、诊断统计。
- `Bind_BlueprintType`：类型注册、Property、Function、Blueprint Event 和 Specifier 处理。
- ClassGenerator 剩余热点：分析、计划、构造、Finalize、Reload 之间只通过明确的数据结构协作。

**交付物**：

- 每个子领域的职责说明和内部 API。
- 每次拆分对应的 focused regression。
- 旧入口到新实现的迁移记录。

**退出条件**：

- 拆分后的文件不依赖未声明的全局状态。
- 子模块可以独立定位编译、测试和诊断问题。
- 不因为文件拆分引入脚本行为变化或 API 兼容回归。

### Phase 4：测试 Fixture 与运行模型整理

**优先级：P1，Phase 1 后即可分批执行**

**目标**：降低测试样板、Engine 创建成本和测试之间的状态污染。

**主要工作**：

- 将 `Shared/` 按 Execution、Engine、Reflection、Fixture、Mock、Probe 和 Domain Types 分组。
- 统一 Engine Fixture 生命周期，减少重复的 `ASTEST_CREATE_ENGINE`、`BEFORE_ALL` 和 `AFTER_ALL` 样板。
- 收敛 `AngelscriptTestSupport`、`AngelscriptTest`、`AngelscriptReflectiveAccess` 等并行抽象。
- 明确 `Angelscript.TestModule.*`、`Angelscript.CppTests.*` 和 `Angelscript.Editor.*` 的边界。
- 为测试声明 Editor、PIE、Headless、World Context 和资源依赖，避免能力约束只存在于注释中。
- 继续降低重复完整 Engine 创建造成的内存峰值，但不牺牲必要的隔离性。

**交付物**：

- 测试 Fixture 使用规范。
- 测试主题、Prefix 和环境能力矩阵。
- Engine 生命周期和内存峰值对比记录。

**退出条件**：

- 新测试只需要一种主流 Fixture 入口。
- 测试 Prefix 与目录主题具有确定性映射。
- 全量测试不依赖前序用例留下的共享全局状态。

### Phase 5：配置、ThirdParty Fork 与长期维护卫生

**优先级：P2**

**目标**：减少版本升级、配置变更和 Fork 同步时的隐性风险。

**主要工作**：

- 拆分 `UAngelscriptSettings` 中的语言、兼容性、Editor、VS Code 和 Debugger 配置。
- 将硬编码的 UE 函数黑名单、Skip Bind 表和版本相关例外集中管理并补充原因。
- 建立 AngelScript 2.33 Fork 的本地 Patch/Backport 清单。
- 为选择性吸收 2.38 改动记录来源版本、修改文件、兼容性原因和回归测试。
- 统一 CVar、Console Command 和 Dump 扩展的命名与注册位置。
- 将残留的 `TODO`、`WILL-EDIT` 和 `#if 0` 分为有效技术债、版本兼容项和历史残留。

**交付物**：

- 配置职责矩阵。
- ThirdParty Fork 差异和 Backport 记录。
- 可定期执行的源码卫生扫描。

**退出条件**：

- 配置项可以按职责定位，不需要阅读多个模块才能理解行为。
- 每个 Fork 修改都有来源和验证依据。
- 版本升级时能够快速判断哪些本地修改不能直接覆盖。

## 6. 优先级与暂缓事项

### 必须优先处理

- Runtime 公共边界和 Editor/Test 反向依赖。
- Engine Context 与全局访问。
- 当前未提交协议兼容修改的独立收口。
- 构建、Focused Test 和 Full Test 的基线记录。

### 可以暂缓

- 继续扩大低优先级 Coverage 矩阵。
- 单个小型 Bind 的机械式重排。
- 只改善文件名或目录名、但不改变职责边界的整理。
- 在没有 Context 设计之前继续大规模拆 `AngelscriptEngine.cpp`。

## 7. 不采用的方案

- 不进行一次性 Runtime/Editor/Test 模块重写。
- 不通过增加更多全局单例或静态状态来解决 Engine 生命周期问题。
- 不把所有测试都改成共享 Engine，以换取表面上的运行速度；隔离性和可复现性仍然优先。
- 不在同一个变更中同时引入新脚本语义、重写绑定系统和移动模块边界。

## 8. 参考资料

- [Runtime 架构问题盘点](RuntimeArchitectureAudit_20260630.md)
- [Test 架构问题盘点](TestArchitectureAudit_20260630.md)
- [技术债实时盘点](TechnicalDebtInventory.md)
- [全局状态收口矩阵](GlobalStateContainmentMatrix.md)
- [测试覆盖 OpenSpec](../../openspec/changes/test-coverage/tasks.md)
- [Git 提交规范](../Rules/GitCommitRule.md)

## 9. 下一步

本路线图记录的是整体方向，不等于已经启动全部阶段。下一项建议单独建立 `refactor-as-runtime-boundaries` OpenSpec，先完成 Phase 0 的基线收口，再实施 Phase 1。每个阶段完成后更新本文件的状态、验证结果和剩余迁移点。
