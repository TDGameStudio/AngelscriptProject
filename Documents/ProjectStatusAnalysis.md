# Angelscript 插件项目现状分析

**编制日期**：2026-04-21  
**基于**：`main` 分支 `06cbdea` 快照

---

## 一、项目概述

本仓库（`AngelscriptProject`）是一个面向 Unreal Engine 的 **AngelScript 脚本语言插件**开发项目。项目目标不是构建游戏，而是将 `Plugins/Angelscript/` 整理、验证并沉淀为**可独立交付的 UE 脚本插件**。当前仓库是插件开发与验证的宿主工程，真正的产物是 `Angelscript` 插件本身。

**GitHub 远端**：`git@github.com:UnrealEngine-Angelscript-ZH/AngelscriptProject.git`

---

## 二、仓库规模与结构

### 2.1 整体规模

| 维度 | 数值 |
|------|------|
| 总文件数 | ~1,200 |
| C++ 源文件（.cpp） | 689 |
| C++ 头文件（.h） | 200 |
| 文档文件（.md） | 133 |
| 工具脚本（.bat + .ps1） | 129 |
| AngelScript 脚本（.as） | 9 |
| C# 文件（.cs） | 12 |

### 2.2 目录结构

```
AngelscriptProject/
├── Plugins/Angelscript/          ← 核心交付物（915 个文件）
│   ├── Source/
│   │   ├── AngelscriptRuntime/   ← 运行时核心
│   │   │   ├── Core/             ← 引擎核心、绑定管理器、类型系统
│   │   │   ├── ClassGenerator/   ← 动态类生成、热重载、版本链
│   │   │   ├── Binds/            ← 123 个 Bind_*.cpp（引擎 API 绑定）
│   │   │   ├── Debugging/        ← DebugServer V2 协议
│   │   │   ├── StaticJIT/        ← 静态 JIT 编译
│   │   │   ├── Dump/             ← 27+ 张 CSV 状态导出表
│   │   │   ├── CodeCoverage/     ← 代码覆盖率追踪
│   │   │   ├── FunctionLibraries/← 21+ 个脚本辅助函数库
│   │   │   ├── Preprocessor/     ← 脚本预处理器
│   │   │   ├── Testing/          ← 运行时测试支持
│   │   │   └── ThirdParty/       ← AngelScript 引擎源码 (2.33 fork)
│   │   ├── AngelscriptEditor/    ← 编辑器集成
│   │   ├── AngelscriptTest/      ← 插件自动化测试模块
│   │   └── AngelscriptUHTTool/   ← UHT 代码生成工具链
│   └── Angelscript.uplugin
├── Source/                        ← 宿主工程（最小化，8 个文件）
├── Script/                        ← AngelScript 示例与测试脚本（9 个 .as）
├── Documents/                     ← 项目文档体系（119 个文件）
│   ├── Plans/                     ← 执行计划（52 份）
│   │   └── Archives/              ← 已归档计划（7 份）
│   ├── Knowledges/                ← 架构知识库（36 份）
│   ├── Guides/                    ← 构建/测试/查询指南（14 份）
│   └── Rules/                     ← Git/评审规则（4 份）
├── Tools/                         ← 构建/测试/自动化辅助脚本
├── Config/                        ← UE 工程配置（4 个 .ini）
└── AGENTS.md / AGENTS_ZH.md      ← AI Agent 工作指引
```

---

## 三、项目阶段判断

**当前阶段**：插件已进入**成熟期**，核心运行时、编辑器集成、测试基础设施均已成型，但对外交付入口和若干关键能力闭环仍需收口。

### 3.1 已经具备的能力

| 能力域 | 现状 |
|--------|------|
| **三模块架构** | `AngelscriptRuntime` / `AngelscriptEditor` / `AngelscriptTest` 稳定运行 |
| **引擎 API 绑定** | 123 个 `Bind_*.cpp`，覆盖面广泛 |
| **调试协议** | DebugServer V2，支持断点、单步、变量查看、数据断点等 |
| **代码覆盖率** | CodeCoverage 模块已就绪 |
| **静态 JIT** | StaticJIT 编译支持已落地 |
| **状态导出** | 27+ 张 CSV 状态导出表，纯外部观察者架构 |
| **热重载** | ClassReloadHelper、版本链、增量编译支持 |
| **UHT 工具** | 编译期函数表生成、legacy shard 已清除 |
| **BlueprintImpact** | Commandlet 与编辑器集成已合入 main |
| **脚本辅助库** | 21+ 个 FunctionLibrary 头文件 |
| **自动化测试** | 452+ 个测试定义，按主题组织 |
| **构建/测试 Runner** | 统一脚本入口（RunBuild/RunTests/RunTestSuite） |

### 3.2 明确缺失/未闭环的能力

| 缺口 | 严重程度 | 说明 |
|------|----------|------|
| **根 README.md** | 🔴 高 | 当前内容为 `NULL`，完全缺失项目介绍 |
| **CI/CD** | 🔴 高 | 无 `.github/workflows/` |
| **插件元数据** | 🔴 高 | `.uplugin` 中 `DocsURL` / `SupportURL` 为空 |
| **Script Subsystem 闭环** | 🔴 高 | WorldSubsystem / GameInstanceSubsystem 仍处于编译失败负例阶段 |
| **脚本示例** | 🟡 中 | 仅 9 个 .as 文件 vs Hazelight 的 26 个分组示例 |
| **VS Code/IDE 工作流** | 🟡 中 | 底座在但缺少面向用户的接入文档 |
| **脚本 API 文档** | 🟡 中 | 123 个 Bind 文件无面向脚本开发者的参考文档 |
| **GAS/EnhancedInput 验证** | 🟡 中 | 底层已接入但零个 GAS 专项测试 |

---

## 四、测试现状

### 4.1 三套并行数字基线

| 口径 | 数值 | 含义 |
|------|------|------|
| 已编目基线 | **275/275 PASS** | `TestCatalog.md` 中整理并验证的 C++ 基线 |
| 源码定义规模 | **452+** | 源码中自动化测试入口扫描总量 |
| Live Full-Suite | **706 完成 / 705 通过 / 1 失败** | UE 运行时发现 935 个 `Angelscript` 前缀测试（截至最新快照） |

### 4.2 Disabled 测试治理（2026-04-21 已关闭）

| 类别 | 原始数 | 已恢复 | 仍 Disabled |
|------|--------|--------|-------------|
| A 类（Debugger headless） | 30 | 29 | 1 |
| B 类（UE 5.7 迁移） | ~16 | 3 | 13 |
| C 类（前置崩溃/接口） | 4 | 2 | 2 |
| D 类（其他） | ~4 | 4 | 0 |
| **合计** | **~54** | **38** | **16** |

核心修复：在 `InitializeForTesting()` 中按 `RuntimeConfig.DebugServerPort > 0` 条件创建 `FAngelscriptDebugServer`，解决了 headless 模式下 DebugServer 缺失问题，一次性恢复了 28 个 Debugger 测试。

### 4.3 测试组织结构

测试按主题拆分，目录化管理：

- `Actor/` — Actor 生命周期
- `Bindings/` — 绑定验证
- `Blueprint/` — 蓝图交互
- `Component/` — 组件系统
- `Debugger/` — 调试器功能
- `HotReload/` — 热重载
- `Subsystem/` — 子系统
- `Core/` / `Compiler/` / `Shared/` 等

---

## 五、AngelScript 版本策略

- **当前基线**：AS 2.33 + 选择性 2.38 兼容
- **策略**：fork 已深度分叉，整体升级不可行，采用**选择性吸收**策略
- **已规划的 2.38 迁移方向**：

| 方向 | Plan 文档 | 优先级 |
|------|-----------|--------|
| foreach 语法 | `Plan_AS238ForeachPort.md` | P1 |
| 非 Lambda 类型系统 | `Plan_AS238NonLambdaPort.md` | P2 |
| 关键 Bug 修复回移 | `Plan_AS238BugfixCherryPick.md` | P2 |
| Lambda / 匿名函数 | `Plan_AS238LambdaPort.md` | P3 |
| using namespace | `Plan_AS238UsingNamespacePort.md` | P3 |
| 上下文 bool 转换 | `Plan_AS238BoolConversionPort.md` | P3 |
| 默认拷贝语义 | `Plan_AS238DefaultCopyPort.md` | P3 |
| JIT v2 接口 | `Plan_AS238JITv2Port.md` | P3 |
| 成员初始化模式 | `Plan_AS238MemberInitPort.md` | P4 |
| Computed goto 优化 | `Plan_AS238ComputedGotoPort.md` | P4 |

---

## 六、与 Hazelight 基线的差距分层

Hazelight 的 AngelScript 实现是"引擎分支 + 插件 + 配套工作流"的完整生态。差距需要分层认识：

### 6.1 引擎侧差距（插件内无法弥补）

涉及 UHT、Blueprint 编译链、`CoreUObject` 反射链路等引擎补丁能力，需单独承认边界。

### 6.2 插件侧功能差距

- Script Subsystem 未闭环（最直接的 blocker）
- 网络复制与 RPC 验证不足
- GAS / EnhancedInput helper surface 偏薄
- Console / 全局变量工作流可见性不足

### 6.3 工具链与上手差距

- README / CI / 兼容矩阵 / 发布入口缺失
- 脚本示例数量和组织不足（9 vs 26）
- VS Code / Debug / API 工作流无用户入口

### 6.4 不再构成差距的项目

- CodeCoverage / Commandlet / 编辑器菜单 / UINTERFACE 支持 — 已具备
- 测试基础设施 — 当前已强于 Hazelight 的公开标准

---

## 七、性能现状

### BlueprintType 绑定性能基线（2026-04-17 采集）

| 阶段 | 耗时 | 占比 |
|------|------|------|
| 类收集 + 拓扑排序 | 6.0 ms | 0.02% |
| **函数枚举 + Callable/Event 绑定** | **36,220.0 ms** | **99.72%** |
| GetterSetter 绑定 | 4.1 ms | 0.01% |
| Inherit + BindProperties + DB 写入 | 92.7 ms | 0.26% |
| **合计** | **36,322.7 ms** | |

处理 7,853 个 UClass，实际绑定 6,312 个函数，每函数平均 5.74ms。已规划 5 个优化方向（方向 B+C 组合可压缩至 ~15s，方向 D Editor 缓存可降至 <1s）。

---

## 八、文档与知识体系

### 8.1 文档体系概览

| 类别 | 数量 | 核心内容 |
|------|------|---------|
| 执行计划（Plans） | 52 份活跃 | 涵盖 AS 2.38 迁移、测试增强、重构、功能增强、工具链、架构演进六大类 |
| 已归档计划（Archives） | 7 份 | 技术债、构建脚本、测试宏、状态导出等已完成项 |
| 架构知识库（Knowledges） | 36 份 | 编号体系，覆盖模块职责、编译流程、类型系统、热重载等 |
| 操作指南（Guides） | 14 份 | 构建、测试、Fork 策略、绑定审计等 |
| 规则文档（Rules） | 4 份 | Git 提交规范等 |

### 8.2 关键导航入口

| 入口 | 用途 |
|------|------|
| `Plan_StatusPriorityRoadmap.md` | 当前完成现状、差距与优先级总览（最核心） |
| `Plan_OpportunityIndex.md` | 所有可执行方向全景索引 |
| `TechnicalDebtInventory.md` | 技术债 live inventory |
| `TestCatalog.md` | 已编目测试基线 |
| `AngelscriptForkStrategy.md` | AS Fork 演进策略 |
| `BindGapAuditMatrix.md` | 绑定差距审计矩阵 |

---

## 九、工具链现状

| 工具 | 路径 | 用途 |
|------|------|------|
| `RunBuild.ps1` | Tools/ | 统一构建入口 |
| `RunTests.ps1` | Tools/ | 统一测试运行 |
| `RunTestSuite.ps1` | Tools/ | 测试套件调度 |
| `RunAutomationTests.ps1/.bat` | Tools/ | 自动化测试执行 |
| `BootstrapWorktree.bat` | Tools/Bootstrap/ | Git worktree 初始化 |
| `PullReference.bat` | Tools/PullReference/ | 拉取外部参考仓库 |
| `ReferenceComparison/` | Tools/ | 与参考实现对照 |
| `Review/` | Tools/ | 代码评审辅助 |
| `Diagnostics/` | Tools/ | 诊断工具 |

### 外部参考仓库

| 名称 | 用途 |
|------|------|
| AngelScript v2.38.0 | AS 2.38 能力对照与选择性回移 |
| Hazelight Angelscript | 功能 parity 基线对照 |
| UnrealCSharp | 架构参考（C# 脚本方案） |
| Tencent UnLua / puerts / sluaunreal | 其他脚本方案参考 |

---

## 十、近期已完成里程碑

| 里程碑 | 状态 |
|--------|------|
| 测试执行基础设施（统一 runner、group taxonomy、结构化摘要） | ✅ 已归档 |
| 构建/测试脚本标准化（共享执行层） | ✅ 已归档 |
| Callfunc 死代码清理 | ✅ 已归档 |
| 引擎状态导出体系（27 张 CSV 表） | ✅ 已归档 |
| 测试宏优化（BEGIN/END、SHARE_CLEAN/SHARE_FRESH） | ✅ 已归档 |
| 技术债 Phase 0-6 收口 | ✅ 已归档 |
| UFunction 反射回退绑定 | ✅ 已归档 |
| UHT 工具插件生成函数表与 legacy shard 移除 | ✅ main 已合入 |
| BlueprintImpact Commandlet 与编辑器集成 | ✅ main 已合入 |
| UE 5.7 绑定与调试器适配 | ✅ main 已合入 |
| Disabled 测试重新启用（38/54 恢复） | ✅ 已关闭 |
| BlueprintType Bindings 性能分析与优化方向规划 | ✅ 已完成 |

---

## 十一、当前优先级路线图

按 `Plan_StatusPriorityRoadmap.md` 确定的执行顺序：

```
Phase 0：口径校准 & owner 路由
  → Phase 1：已知阻塞项 + 交付基线
    → Phase 2：上手资产 + 工作流入口
      → Phase 3：功能 parity 与验证闭环
        → Phase 4：AS 2.38 选择性迁移 + 长期架构
```

### 近期 P1 优先事项

1. **清理 live full-suite 失败**，稳定 negative-test 边界
2. **Script Subsystem 闭环**（WorldSubsystem / GameInstanceSubsystem）
3. **补齐插件对外交付基线**（README、CI、兼容矩阵、发布入口）
4. **C++ UInterface 绑定补齐**
5. **foreach 语法支持**（AS 2.38 最高优先迁移项）

---

## 十二、风险与关注点

| 风险 | 描述 | 缓解措施 |
|------|------|---------|
| 优先级漂移 | 容易被"更多 bind / 更多 2.38 特性"吸走，忽略交付基线 | 坚持先过 P1/P2 闸门 |
| 测试数字混淆 | 三套并行数字口径容易混写 | 文档中强制标注数字来源 |
| 引擎侧差距误判 | Hazelight 引擎补丁项被当成普通插件待办 | 回 HazelightCapabilityGap 判断归属 |
| 结构差异误判 | 模块拆分差异被当成功能缺失 | 先证明 bundled 方案不可用再升级 |
| 绑定性能瓶颈 | Editor 模式下 36s 启动开销 | 已规划优化方向，D 方案可降至 <1s |
| UE 5.7 适配残余 | 16 个 Disabled 测试仍需 UE 5.7 binding 适配 | 已拆分至 KnownTestFailureFixes |

---

## 十三、总结

本项目已从"原型搭建"阶段成功进入"能力收口与交付准备"阶段。核心运行时、编辑器集成、测试框架、调试协议、状态导出等基础设施均已成熟，123 个 Bind 文件构建了广泛的引擎 API 绑定面，452+ 个自动化测试提供了强健的验证保障。

当前最关键的不是继续扩展底层能力，而是：

1. **收口对外交付入口**（README、CI、文档、示例）
2. **闭环已暴露但未完成的功能**（Script Subsystem、Network RPC）
3. **维持测试健康度**（消灭 known failures、保持 negative-test 边界清晰）
4. **按需推进 AS 2.38 选择性迁移**（foreach > bugfix > lambda > 其他）

项目已建立了完善的文档体系（133 份 MD 文档）、知识库（36 份架构知识）和计划管理流程（52 份活跃计划 + 7 份已归档），为后续的系统性推进奠定了坚实基础。
