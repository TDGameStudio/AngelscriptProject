# Plan: Angelscript 插件全量体检 (2026 Q2)

> **目标**：对 `Plugins/Angelscript` 插件各模块进行全面诊断，识别不足、缺口和改进方向。
> **基准日期**：2026-05-10
> **数据来源**：源码扫描 + 现有 Plan/Guide 文档 + 测试基线

---

## 一、总体健康度评估

| 维度 | 评分 | 说明 |
|------|------|------|
| 核心运行时 | ★★★★☆ | 编译流水线、类型系统、ClassGenerator 成熟稳定 |
| 绑定覆盖 | ★★★★☆ | 117 个 Bind 文件 + 反射回退，主要 UE API 已覆盖 |
| 测试基础设施 | ★★★★☆ | 429 文件 / 417+ 定义，仅 2 Disabled、7 live failure |
| 编辑器集成 | ★★★☆☆ | HotReload/ContentBrowser/SourceNav 可用，但缺 IDE 客户端 |
| 调试能力 | ★★☆☆☆ | Server V2 完整但无客户端，开发者无法实际使用 |
| 对外交付 | ★☆☆☆☆ | 无 README、无 CI、无 Release 流程 |
| 文档与上手 | ★★☆☆☆ | 内部知识库丰富，但外部用户入口为零 |
| GAS 集成 | ★★☆☆☆ | 独立子模块存在但默认禁用，验证不足 |

---

## 二、逐模块详细诊断

### 2.1 AngelscriptRuntime（核心运行时）

**文件规模**：207 cpp + 147 h = 354 文件

#### 2.1.1 Core（引擎核心）
| 项目 | 状态 | 问题 |
|------|------|------|
| AngelscriptEngine 编译流水线 | ✅ 成熟 | 4 阶段流水线稳定运行 |
| UAngelscriptEngineSubsystem | ✅ 稳定 | Editor/Commandlet 启动路径已统一 |
| UAngelscriptGameInstanceSubsystem | ✅ 稳定 | 世界/游戏实例上下文管理正常 |
| 类型注册 (AngelscriptType) | ✅ 稳定 | AS↔UE 类型映射完整 |
| 全局状态隔离 | ⚠️ 待改进 | 去全局化仍在 Deferred 阶段 |

**不足**：
- 全局状态边界未完全收敛（`GlobalStateContainmentMatrix.md` 记录了残留全局依赖）
- `InitializeAngelscript()` 兼容 API 仍存在，增加理解成本

#### 2.1.2 Binds（绑定层）
| 项目 | 状态 | 问题 |
|------|------|------|
| 手动绑定文件 | 117 个 | 覆盖面广 |
| UHT 生成函数表 | ✅ 已落地 | 自动生成补充手动绑定 |
| 反射回退 (BlueprintCallableReflectiveFallback) | ✅ 已落地 | 兜底未绑定的 UFunction |
| 绑定缺口审计 | ⚠️ 有记录 | `BindGapAuditMatrix.md` 列出残余缺口 |

**不足**：
- **Animation 绑定薄弱**：无 `Bind_UAnimInstance.cpp`、无 Montage/Notify 绑定
- **AI 绑定缺失**：无 BehaviorTree/AIController 专用绑定（仅靠反射回退）
- **Physics 绑定不完整**：无 Chaos Physics 专用绑定、无 PhysicsConstraint
- **Audio 绑定为零**：无 `Bind_UAudioComponent.cpp`、无 SoundCue/MetaSound
- **Niagara/VFX 绑定为零**：仅有 `Bind_UFXSystemComponent.cpp`（基类）
- **Camera 绑定缺失**：无 CameraComponent/PlayerCameraManager 专用绑定
- **Navigation 绑定缺失**：无 NavMesh/PathFollowing 绑定
- **Material/Rendering 绑定缺失**：无 DynamicMaterialInstance 绑定

#### 2.1.3 ClassGenerator（类生成器）
| 项目 | 状态 | 问题 |
|------|------|------|
| UClass/UStruct 生成 | ✅ 成熟 | 运行时动态生成正常 |
| 热重载版本链 | ✅ 稳定 | 编辑器内重载正常 |
| Blueprint 可见性 | ✅ 正常 | 脚本类对 BP 可见 |

**不足**：
- 无 UInterface 从脚本侧定义的能力（只能实现 C++ 定义的接口）
- 热重载在 PIE 下的行为未充分验证

#### 2.1.4 Preprocessor（预处理器）
| 项目 | 状态 | 问题 |
|------|------|------|
| #include / #if | ✅ 正常 | 条件编译工作正常 |
| 文档提取 | ✅ 正常 | 注释格式文档提取可用 |

**不足**：
- 仅 3 个文件，功能集中但扩展性未知
- 无宏定义能力（`#define` 不支持参数化宏）

#### 2.1.5 StaticJIT（静态 JIT）
| 项目 | 状态 | 问题 |
|------|------|------|
| 字节码分析 | ✅ 已实现 | 13 文件完整实现 |
| 预编译序列化 | ✅ 已实现 | PrecompiledData 可用 |
| 性能验证 | ⚠️ 不足 | 无系统性 benchmark |

**不足**：
- 缺少 JIT vs 解释器的性能对比基准测试
- 缺少 JIT 编译失败的回退路径文档
- 与 AS 2.38 JIT v2 的差距未评估

#### 2.1.6 Debugging（调试服务器）
| 项目 | 状态 | 问题 |
|------|------|------|
| TCP Debug Server V2 | ✅ 完整 | 30+ 消息类型，端口 27099 |
| 断点/单步/变量检查 | ✅ 服务端完整 | 支持条件断点、数据断点 |
| DAP 客户端 | ❌ 不存在 | **最大缺口** |
| VS Code 扩展 | ❌ 不存在 | 有 Plan 但未实施 |

**不足**：
- **调试能力完全不可用**：服务端完整但无任何客户端可连接
- Plan_DebugAdapter.md 已规划 4 阶段但未启动
- 自定义二进制协议（非标准 DAP），增加客户端实现难度
- 无协议文档（仅靠读 .h 文件理解消息格式）

#### 2.1.7 CodeCoverage（代码覆盖率）
| 项目 | 状态 | 问题 |
|------|------|------|
| 行级覆盖追踪 | ✅ 已实现 | 5 文件实现 |
| HTML/JSON 报告 | ✅ 已实现 | 可生成报告 |

**不足**：
- 无 CI 集成（无法自动生成覆盖率报告）
- 无覆盖率阈值门控

#### 2.1.8 FunctionLibraries（函数库）
| 项目 | 状态 | 问题 |
|------|------|------|
| Runtime 函数库 | 21 个 | 覆盖 Math/Actor/Component/Tag/Widget 等 |
| Editor 函数库 | 6 个 | AssetTools/Blueprint/Editor 等 |
| ScriptMixin 恢复 | ✅ 6/8 已启用 | Math 8 个因命名空间回归延迟 |

**不足**：
- **Math ScriptMixin 未启用**：8 个 Math Mixin 类因 ~80 处调用点需迁移而阻塞
- 缺少 String 操作扩展库（正则、格式化等）
- 缺少 Async/Coroutine 辅助库

#### 2.1.9 Dump（状态导出）
| 项目 | 状态 | 问题 |
|------|------|------|
| 27+ CSV 表导出 | ✅ 完整 | 纯外部观察者架构 |
| 控制台命令 | ✅ 可用 | `as.DumpEngineState` |

**不足**：无明显不足，架构清晰。

#### 2.1.10 ThirdParty/angelscript（AS 引擎）
| 项目 | 状态 | 问题 |
|------|------|------|
| AS 2.33 + 选择性 2.38 | ⚠️ 分叉 | 32/78 源文件有 [UE++] 标记 |
| foreach 语法 | ✅ 已吸收 | 从 2.38 回移 |
| Lambda | ❌ 未吸收 | 评估中 |
| 函数模板 | ❌ 未吸收 | 评估中 |

**不足**：
- Lambda 支持缺失是脚本表达力的重大限制
- 函数模板缺失限制泛型编程能力
- `using namespace` 缺失影响代码组织
- 与上游 2.38 的差距在扩大（上游已到更高版本）

---

### 2.2 AngelscriptEditor（编辑器模块）

**文件规模**：49 cpp + 19 h = 68 文件

| 子系统 | 状态 | 问题 |
|--------|------|------|
| HotReload | ✅ 可用 | DirectoryWatcher + ClassReloadHelper |
| ContentBrowser | ✅ 可用 | .as 文件在内容浏览器可见 |
| SourceNavigation | ✅ 可用 | 编辑器元素→源码跳转 |
| BlueprintImpact | ✅ 已落地 | Commandlet + 编辑器集成 |
| CodeGen | ✅ 可用 | IDE 支持和 API 存根生成 |
| 菜单扩展 | ✅ 可用 | Script/Actor/Asset 右键菜单 |

**不足**：
- **无脚本创建向导**：新建 .as 文件无模板引导
- **无内联错误显示**：编译错误仅在 Output Log，无编辑器内高亮
- **无自动补全集成**：编辑器内无 IntelliSense 等价物
- **BlueprintImpact 无增量模式**：每次全量扫描
- HotReload × PIE 交互未充分测试

---

### 2.3 AngelscriptTest（测试模块）

**文件规模**：434 cpp + 43 h = 477 文件，22 个主题目录

| 维度 | 数值 | 说明 |
|------|------|------|
| 测试定义 | 417+ | 自动化测试 |
| 编目基线 | 275/275 PASS | 文档化 |
| Live 全量 | 443/436/7 | 7 个失败 |
| Disabled | 2 | #ue57-headless 已知限制 |
| 主题目录 | 22 | 覆盖面广 |

**不足**：
- **7 个 live test failure 未修**：阻塞新测试的可信度
- **PIE 测试几乎为零**：运行时行为（网络复制、多客户端、地图切换）未验证
- **性能测试缺失**：无编译时间/JIT 时间/绑定调用开销的回归基准
- **Fuzzing 测试缺失**：无随机输入/边界条件的模糊测试
- **GAS 测试覆盖不足**：GAS 子模块测试独立且默认禁用
- **脚本侧测试 (`.as`) 仅 8 个**：C++ 测试多但脚本侧验证少
- 缺少多线程/并发场景测试

---

### 2.4 AngelscriptUHTTool（UHT 代码生成工具）

**文件规模**：C# 项目，5 个核心文件

| 项目 | 状态 | 问题 |
|------|------|------|
| 函数签名构建 | ✅ 可用 | AngelscriptFunctionSignatureBuilder.cs |
| 函数表导出 | ✅ 可用 | AngelscriptFunctionTableExporter.cs |
| 头文件解析 | ✅ 可用 | AngelscriptHeaderSignatureResolver.cs |
| 代码生成 | ✅ 可用 | AngelscriptFunctionTableCodeGenerator.cs |

**不足**：
- 无增量生成（每次全量重新生成）
- 无生成结果的自动化验证（依赖人工检查 Summary.json）
- 缺少对新 UE 5.7 元数据特性的适配文档

---

### 2.5 AngelscriptGAS（GAS 扩展插件）

**状态**：独立子模块，默认禁用

| 项目 | 状态 | 问题 |
|------|------|------|
| 插件结构 | ✅ 存在 | Runtime + Test 双模块 |
| 依赖声明 | ✅ 正确 | 依赖 Angelscript + GameplayAbilities |
| 默认状态 | ⚠️ 禁用 | 需手动启用 |

**不足**：
- **默认禁用**：用户不知道它存在
- **验证不足**：测试模块存在但覆盖度未知
- **无使用文档**：如何启用、配置、使用均无说明
- **与主插件的集成点不清晰**：边界模糊
- 快照导入，缺少持续维护迹象

---

### 2.6 Script Examples（脚本示例）

**文件规模**：37 个 .as 文件（14 Core + 5 Extended + 3 EnhancedInput + 8 Tests + 7 其他）

| 项目 | 状态 | 问题 |
|------|------|------|
| 核心模式覆盖 | ✅ 基本 | Actor/Array/Struct/Delegate/Math/Timer |
| 扩展示例 | ✅ 有 | Blueprint/Console/Interface/Network/Subsystem |
| EnhancedInput | ✅ 有 | 3 个示例 |

**不足**：
- **无 README/索引**：37 个文件无导航入口
- **无难度分级**：初学者不知从何开始
- **缺少常见游戏模式示例**：无 Inventory/SaveLoad/UI 绑定/状态机
- **缺少 GAS 示例**：GAS 子模块无对应脚本示例
- **无运行说明**：如何在编辑器中运行这些示例未说明

---

## 三、跨模块问题

### 3.1 对外交付基线（P0 阻塞）

| 缺失项 | 影响 | 工时估算 |
|--------|------|----------|
| README.md（根 + 插件根） | 仓库不可理解 | 1d |
| .github/workflows/ CI | 无自动验证 | 2d |
| .uplugin 元数据（DocsURL/SupportURL） | 插件不可发现 | 0.5d |
| CHANGELOG / Release Notes | 无版本历史 | 1d |
| LICENSE 文件 | 法律风险 | 0.5d |
| 兼容性矩阵（UE 版本 × 平台） | 用户不知能否用 | 0.5d |

### 3.2 开发者工作流缺口

| 缺失项 | 影响 | 工时估算 |
|--------|------|----------|
| VS Code 调试扩展 | 无法断点调试 | 10d |
| 脚本项目模板 | 新用户无起点 | 2d |
| API 参考文档生成 | 无法查阅可用 API | 5d |
| 错误消息改进 | 编译错误难以定位 | 3d |

### 3.3 文档数字基线过期

| 文档 | 声称 | 实际 | 偏差 |
|------|------|------|------|
| AGENTS.md "28+ 主题目录" | 28 | 22 | -6 |
| AGENTS.md "429 test cpp" | 429 | 434 cpp | +5 |
| AGENTS.md "124 Bind 文件" | 124 | 117 | -7 |
| AGENTS.md "27 .as 示例" | 已更新为 37 | 37 | ✅ |

---

## 四、按模块优先级排序的改进建议

### 第一梯队：阻塞交付（本月内）

| # | 模块 | 任务 | 优先级 |
|---|------|------|--------|
| 1 | 全局 | 修复 7 个 live test failure | P0 |
| 2 | 全局 | 刷新 AGENTS.md 数字基线 | P0 |
| 3 | 全局 | 编写 README.md（根 + 插件根） | P0 |
| 4 | 全局 | 建立 CI workflow（build + test） | P1 |
| 5 | 全局 | 补充 .uplugin 元数据 + LICENSE | P1 |

### 第二梯队：开发者体验（本季度）

| # | 模块 | 任务 | 优先级 |
|---|------|------|--------|
| 6 | Debugging | 启动 VS Code DAP 适配器开发 | P1 |
| 7 | Runtime | 完成 Math ScriptMixin 迁移（~80 调用点） | P1 |
| 8 | Examples | 编写示例 README + 分级索引 | P1 |
| 9 | Editor | 添加脚本创建模板/向导 | P2 |
| 10 | Test | 建立 PIE 测试基线（4+ 张地图） | P2 |

### 第三梯队：功能完善（Q3）

| # | 模块 | 任务 | 优先级 |
|---|------|------|--------|
| 11 | Binds | 补充 Animation 绑定（AnimInstance/Montage） | P2 |
| 12 | Binds | 补充 AI 绑定（BehaviorTree/AIController） | P2 |
| 13 | Binds | 补充 Audio 绑定（AudioComponent/SoundCue） | P3 |
| 14 | ThirdParty | 评估并吸收 AS 2.38 Lambda 支持 | P2 |
| 15 | ThirdParty | 评估并吸收 AS 2.38 函数模板 | P3 |
| 16 | GAS | 启用 + 文档化 + 验证 AngelscriptGAS 子模块 | P2 |
| 17 | Test | 添加性能回归基准测试 | P3 |
| 18 | UHTTool | 增量生成支持 | P3 |

### 第四梯队：长期架构（Q4+）

| # | 模块 | 任务 | 优先级 |
|---|------|------|--------|
| 19 | Runtime | 全局状态去全局化 | P3 |
| 20 | StaticJIT | JIT v2 评估与性能基准 | P3 |
| 21 | Editor | 编辑器内错误高亮 + 自动补全 | P3 |
| 22 | Binds | Niagara/Camera/Navigation 绑定 | P3 |
| 23 | 全局 | API 参考文档自动生成管线 | P3 |

---

## 五、风险与依赖

| 风险 | 影响 | 缓解措施 |
|------|------|----------|
| Debug Server 使用自定义协议而非标准 DAP | 客户端开发成本高 | Plan_DebugAdapter 已规划协议转换层 |
| AS 2.33 与上游差距持续扩大 | 新语言特性缺失 | 选择性吸收策略，优先 Lambda |
| GAS 子模块默认禁用 | 用户不知其存在 | 文档 + 启用指南 |
| 7 个 live failure 未修 | 新测试可信度受损 | 优先修复，建立 zero-failure 基线 |
| 无 CI | 回归无法自动捕获 | 建立 GitHub Actions workflow |
| PIE 测试为零 | 运行时行为未验证 | 建立 PIE 测试模板地图 |

---

## 六、总结

**插件核心能力成熟度高**（编译、绑定、类生成、热重载），但**对外可用性几乎为零**（无 README、无 CI、无调试客户端、无上手引导）。

**最关键的三件事**：
1. **交付基线**：README + CI + LICENSE → 让仓库从"内部研发"变为"可分享"
2. **调试能力**：VS Code DAP 适配器 → 让开发者能实际调试脚本
3. **稳定性闭环**：修 7 个 failure + PIE 测试 → 建立可信的质量基线

当前阶段的核心矛盾是：**内部能力已经很强，但外部入口完全缺失**。优先级应从"做更多功能"转向"让已有功能可被外部使用"。

---

## 七、第二轮深度探索补充（2026-05-10）

### 7.1 Wiki 文档站点现状

**位置**：`Wiki/` 目录，基于 Material for MkDocs

| 维度 | 状态 | 说明 |
|------|------|------|
| 双语支持 | ✅ 完整 | 中文（默认）+ 英文，i18n 插件 |
| 页面数量 | 40+ | 6 大章节（首页/指南/脚本/绑定/架构/对比/内部） |
| 快速入门 | ✅ 优秀 | `Documents/Knowledges/ZH/Guide_QuickStart.md` 1000+ 行，16 个实例 |
| 构建系统 | ✅ 可用 | `mkdocs serve` 本地预览，`mkdocs build` 静态生成 |
| VS Code 工作流 | ⚠️ 不完整 | 承认缺口：无 workspace 示例、调试端口文档、完整工作流 |

**优势**：
- 双语文档维护良好（中英对照）
- 结构清晰（用户路径 vs 维护者路径）
- 内部知识库丰富（100+ 文档，按前缀分类）
- 快速入门质量高（16 个实战示例）

**缺口**：
- VS Code 扩展配置示例缺失
- 调试端口和连接生命周期文档不完整
- 脚本 API 参考未从绑定数据自动生成
- 完整的保存/诊断/导航/调试工作流指南缺失

---

### 7.2 测试基线数字修正

**重要发现**：`TechnicalDebtInventory.md` 中的 "443/436/7" 数字已过期。

| 来源 | 数值 | 日期 | 状态 |
|------|------|------|------|
| TechnicalDebtInventory.md | 443/436/7 | 历史快照 | ⚠️ 过期 |
| TestFixSummary_20260430.md | 689/689 PASS | 2026-04-30 | ✅ 最新 |
| ProjectStatusAnalysis.md | 706/705/1 | 2026-04-21 | ⚠️ 略旧 |

**实际状态**（2026-04-30）：
- ✅ **689 个测试全部通过**（100% pass rate）
- ✅ Phase 6.3 的 4 个失败已修复（HotReload x2 + SourceNavigation + ScriptExamples）
- ✅ Phase 4 的 7 个失败已修复（Engine 元数据 x3 + Restore x1 + Preprocessor x3）
- ⚠️ 仅 2 个 Disabled 测试（均为 `#ue57-headless` 已知限制）

**Disabled 测试详情**：
1. `Angelscript.TestModule.Shared.EngineHelper.ProductionDebuggerHelperPrefersDebuggableEngineOverScopedTestEngine`
   - 位置：`AngelscriptTestEngineHelperTests.cpp:113`
   - 原因：UE 5.7 headless 模式下 `TryGetRunningProductionDebuggerEngine()` 返回 null
2. `Angelscript.TestModule.Editor.SourceNavigation.NavigateToFunctionUsesStoredSourceLocation`
   - 位置：`AngelscriptSourceNavigationTests.cpp:154`
   - 原因：headless 模式下属性导航源元数据未填充

**结论**：第一轮报告中的"7 个 live failure"已不存在，应更新为"689/689 全通过 + 2 Disabled"。

---

### 7.3 绑定层质量深度评估

#### 7.3.1 优秀绑定（9/10 分）

| 文件 | 评分 | 亮点 |
|------|------|------|
| Bind_TArray.cpp | 9/10 | 40+ 方法，迭代器支持，调试能力，协变子类型 |
| Bind_Delegates.cpp | 9/10 | 单播/多播/稀疏委托，签名兼容检查，调试器集成 |
| Bind_AActor.cpp | 8/10 | 生命周期/变换/组件/输入/生成，错误处理完善 |

#### 7.3.2 存根绑定（40 个文件 < 50 行）

**极简实现（9-18 行）**：
- `Bind_UFXSystemComponent.cpp` (9 行) — 仅 `DeactivateImmediate()`
- `Bind_UPackage.cpp` (10 行) — 仅 `IsDirty()`
- `Bind_USkeletalMeshComponent.cpp` (11 行) — 仅 3 个方法
- `Bind_USkinnedMeshComponent.cpp` (11 行) — 存根
- `Bind_ULocalPlayer.cpp` (12 行) — 存根
- `Bind_FBodyInstance.cpp` (13 行) — 存根
- `Bind_FCpuProfilerTraceScoped.cpp` (14 行) — 存根
- `Bind_FApp.cpp` (17 行) — 存根
- `Bind_FCommandLine.cpp` (18 行) — 存根

**部分实现（19-48 行）**：31 个文件

#### 7.3.3 关键缺口确认

| 领域 | 状态 | 影响 |
|------|------|------|
| **Animation** | 完全缺失 | 无 UAnimInstance、无 Montage、无状态机 |
| **AI** | 完全缺失 | 无 UAIController、无 BehaviorTree、无感知系统 |
| **Audio** | 完全缺失 | 无 UAudioComponent、无 SoundCue、无参数控制 |
| **Collision** | 缺失 | 无 LineTrace/Sweep/Overlap 绑定（仅靠反射回退） |
| **Level Streaming** | 缺失 | 无关卡流送控制 |
| **Gameplay Timers** | 缺失 | 无 FTimerManager 绑定 |

**TODO 注释**：仅 3 处（JSON 扩展 x2 + UStruct 反射 x1），非关键路径。

---

### 7.4 AngelscriptGAS 子模块深度分析

#### 7.4.1 模块结构

**Runtime 模块**（24 文件）：
- **脚本基类**（7 个）：AngelscriptGASAbility, AngelscriptGASCharacter/Pawn/Actor, AngelscriptAbilitySystemComponent, AngelscriptAttributeSet, AngelscriptAbilityTask
- **绑定层**（5 个）：Bind_AngelscriptGASLibrary, Bind_FGameplayAbilitySpec, Bind_FGameplayAttribute, Bind_FGameplayEffectSpec, Bind_FGameplayTagBlueprintPropertyMap
- **工具库**（2 个）：AngelscriptGameplayCueUtils, AngelscriptGameplayEffectUtils

**Test 模块**（6 文件，约 342 行）：
- AngelscriptGASExtendedBindingsTests.cpp
- AngelscriptGASValueBindingsTests.cpp
- AngelscriptGASGeneratedFunctionTableTests.cpp
- AngelscriptGASScriptAttributeSetTests.cpp

#### 7.4.2 测试覆盖度对比

| 维度 | 主插件 | GAS 子模块 | 差距 |
|------|--------|-----------|------|
| 测试定义 | 417+ | **1** | 416x |
| 测试文件 | 429 | 6 | 71x |
| 代码行数 | 数万行 | 约 342 行 | 100+x |

**结论**：GAS 子模块的测试覆盖度**严重不足**，仅有 1 个自动化测试定义。

#### 7.4.3 Aura GAS 移植计划

Plan_AuraGAS_AngelscriptPort.md 规划 8 阶段（22-30 天）：
- Phase 1.3：Enhanced Input 签名（2026-05-06 完成）
- Phase 2-8：战斗/属性/技能/AI/UI/进度/存档（待启动）

---

### 7.5 ThirdParty AngelScript 引擎状态

#### 7.5.1 UE++ 修改规模

| 维度 | 数值 | 说明 |
|------|------|------|
| 修改标记 | 74 处 | `[UE++]...[UE--]` 对 |
| 修改文件 | 32 个 | 占 78 个源文件的 41% |
| 核心修改 | 6 类 | foreach 语法、引擎访问、导出 API、纯脚本类、内存管理、序列化 |

**关键修改**：
- `as_parser.cpp` + `as_compiler.cpp`：foreach(...) 语法支持（APV2）
- `as_builder.cpp`：引擎头重命名、编辑器代码检查、纯脚本类处理
- `as_memory.cpp`：内存管理定制
- 多个头文件：导出内部 API 供 AngelscriptTest 使用

#### 7.5.2 Lambda 实现状态

**发现**：Lambda **已部分实现**（解析 + 编译），但**不是闭包**。

| 组件 | 状态 | 说明 |
|------|------|------|
| 解析器 | 存在 | `ParseLambda()` 实现 BNF 语法 |
| 编译器 | 存在 | `ImplicitConvLambdaToFunc()` 转换为 funcdef |
| 闭包捕获 | 缺失 | 无变量捕获机制 |
| 类型 | 匿名函数 | 转换为 funcdef 类型 |

**BNF 语法**：`'function' '(' [[TYPE TYPEMOD] IDENTIFIER {',' ...}] ')' STATBLOCK`

**结论**：当前 Lambda 是**匿名函数**而非 C++ 风格的闭包（无捕获列表）。要实现真正的闭包需要从 2.38 吸收捕获机制。

#### 7.5.3 Fork 约束

| 特性 | 原版 AS 2.38 | 本 Fork | 影响 |
|------|--------------|---------|------|
| 可变全局变量 | 支持 | 必须 const | 所有全局变量必须 `const` |
| `@` 句柄语法 | 支持 | 自动引用 | 无显式句柄声明 |
| 脚本 `interface` | 支持 | 仅原生 | 接口只能通过 C++ 注册 |
| `mixin class` | 支持 | 仅 mixin 函数 | 无类 mixin，仅函数 mixin |
| 脚本类实例化 | 支持 | 隔离不稳定 | 非 UE 上下文有风险 |

---

### 7.6 UHT 工具架构

**C# 项目结构**（.NET 8.0）：

| 文件 | 职责 |
|------|------|
| AngelscriptFunctionTableExporter.cs | UHT 导出器入口（`[UhtExporter]` 特性） |
| AngelscriptFunctionSignatureBuilder.cs | 从 UHT 元数据重建函数签名 |
| AngelscriptHeaderSignatureResolver.cs | 从 C++ 头文件解析签名 |
| AngelscriptFunctionTableCodeGenerator.cs | 生成 C++ 代码 |
| AngelscriptUHTTool.ubtplugin.csproj | 项目配置（net8.0, Warnings as Errors） |

**导出流程**：
1. 遍历所有 UHT 模块
2. 统计 BlueprintCallable/BlueprintPure 函数
3. 尝试头文件签名解析 -> 回退到 UHT 元数据重建
4. 生成 `ERASE_FUNCTION_PTR`/`ERASE_METHOD_PTR` 宏
5. 输出 `AS_FunctionTable_*.cpp` 分片 + `AS_FunctionTable_Summary.json`
6. 跳过条目写入 CSV

---

### 7.7 子系统层与 Commandlet

#### 7.7.1 脚本子系统（4 个）

| 子系统 | 文件 | 特性 |
|--------|------|------|
| Engine | ScriptEngineSubsystem.h | Tickable + BP 事件（Initialize/Deinitialize/Tick） |
| World | ScriptWorldSubsystem.h | 流送接口 + 世界生命周期 |
| GameInstance | ScriptGameInstanceSubsystem.h | 游戏实例级 |
| LocalPlayer | ScriptLocalPlayerSubsystem.h | 本地玩家级 |

**模式**：继承 UE 子系统基类 + `FTickableGameObject`，通过 `FAngelscriptEngine::TryGetCurrentEngine()` 检查引擎可用性。

#### 7.7.2 Commandlet（2 个）

| Commandlet | 功能 |
|-----------|------|
| AngelscriptTestCommandlet | 运行 AS 单元测试 |
| AngelscriptAllScriptRootsCommandlet | 列出所有脚本根目录 |

**不足**：Commandlet 数量少，缺少常见工具类入口（如：脚本验证 Commandlet、绑定审计 Commandlet、API 文档生成 Commandlet）。

---

### 7.8 活跃 Plan 文档统计

**总数**：73 个活跃 Plan（未归档）

| 分类 | 数量 | 代表性 Plan |
|------|------|------------|
| AS 2.38 迁移 | 10 | foreach/Lambda/using namespace/JIT v2 等 |
| 测试与覆盖 | 12 | 覆盖扩展/PIE 地图/CQTest 迁移/全量失败分流 |
| GAS 与输入 | 2 | Aura GAS 移植/全局变量与 CVar 对齐 |
| 插件交付 | 5 | 工程加固/仓库分离/Hazelight 能力差距 |
| 架构重构 | 10+ | 去全局化 V1/V2/测试引擎隔离/Unity 构建冲突 |
| 其他 | 34 | 脚本示例/Mod 支持/调试适配器/接口绑定等 |

**Plan 管理问题**：
- 73 个活跃 Plan 中预计 20+ 个已完成但未归档
- Plan_StatusPriorityRoadmap.md 中 P1.1（live failure）已过期（实际已全通过）
- 部分 Plan 之间存在重叠（如去全局化 V1/V2、接口绑定/C++ 接口绑定）

---

### 7.9 关键发现总结

#### 7.9.1 数字基线修正

| 项目 | 第一轮 | 第二轮修正 | 偏差 |
|------|--------|-----------|------|
| Live 测试失败 | 7 个 | **0 个**（689/689 通过） | -7 |
| Disabled 测试 | 2 个 | 2 个（#ue57-headless） | 一致 |
| GAS 测试定义 | 未知 | **1 个**（严重不足） | 新发现 |
| 存根绑定 | 未知 | **40 个**（< 50 行） | 新发现 |
| UE++ 标记 | 32 文件 | **74 处标记** | 更精确 |
| Lambda 状态 | 未吸收 | **已部分实现**（匿名函数） | 修正 |
| Wiki 页面 | 未知 | **40+ 页面**，双语 | 新发现 |
| 活跃 Plan | 未知 | **73 个**（20+ 可归档） | 新发现 |

#### 7.9.2 新识别的问题

1. **GAS 测试覆盖度危机**：仅 1 个测试定义 vs 主插件 417+，差距 416 倍
2. **40 个存根绑定**：大量 < 50 行的绑定文件，功能不完整
3. **Animation/AI/Audio 三大领域完全缺失**：无法编写动画逻辑、AI 行为、音频控制
4. **73 个活跃 Plan 管理混乱**：大量已完成但未归档，造成决策噪音
5. **Wiki 工作流文档不完整**：VS Code 配置和调试流程未完成
6. **Commandlet 工具不足**：仅 2 个，缺少验证/审计/文档生成入口
7. **Collision 查询缺失**：LineTrace/Sweep/Overlap 无专用绑定

#### 7.9.3 积极发现

1. **测试基线已达 100%**：689/689 通过，比第一轮预期好得多
2. **Wiki 文档质量高**：双语支持、40+ 页面、16 个快速入门示例
3. **容器/委托绑定优秀**：TArray/Delegates 实现质量 9/10 分
4. **UHT 工具架构清晰**：C# 项目结构合理，导出流程完善
5. **Lambda 已部分实现**：解析和编译存在，虽非闭包但匿名函数可用
6. **子系统层完整**：4 个脚本子系统覆盖 Engine/World/GameInstance/LocalPlayer

---

### 7.10 更新后的优先级建议

#### 第零梯队：数字基线校准（本周）

| # | 任务 | 工时 | 说明 |
|---|------|------|------|
| 0.1 | 更新 TechnicalDebtInventory.md 测试数字 | 0.2d | 689/689 通过，非 443/436/7 |
| 0.2 | 审计 73 个活跃 Plan，归档已完成项 | 1d | 预计 20+ 个可归档 |
| 0.3 | 刷新 AGENTS.md 所有数字基线 | 0.3d | 测试数/Bind 数/示例数 |
| 0.4 | 更新 Plan_StatusPriorityRoadmap P1.1 状态 | 0.1d | 标记为已完成 |

#### 第一梯队：阻塞交付（本月内）— 修正版

| # | 任务 | 工时 | 优先级 | 备注 |
|---|------|------|--------|------|
| 1 | ~~修复 7 个 live test failure~~ | - | ~~P0~~ | 已完成，删除 |
| 2 | 编写 README.md（根 + 插件根） | 1d | P0 | 不变 |
| 3 | 建立 CI workflow（build + test） | 2d | P1 | 不变 |
| 4 | 补充 .uplugin 元数据 + LICENSE | 0.5d | P1 | 不变 |
| **5** | **GAS 测试覆盖扩展（至少 20 个测试）** | **3d** | **P1** | **新增** |

#### 第二梯队：开发者体验（本季度）— 修正版

| # | 任务 | 工时 | 优先级 | 备注 |
|---|------|------|--------|------|
| 6 | 启动 VS Code DAP 适配器开发 | 10d | P1 | 不变 |
| 7 | 完成 Math ScriptMixin 迁移（约 80 调用点） | 1d | P1 | 不变 |
| 8 | 编写示例 README + 分级索引 | 1d | P1 | 不变 |
| **9** | **补充 Wiki VS Code 工作流文档** | **2d** | **P1** | **新增** |
| 10 | 添加脚本创建模板/向导 | 2d | P2 | 不变 |
| 11 | 建立 PIE 测试基线（4+ 张地图） | 3d | P2 | 不变 |

#### 第三梯队：功能完善（Q3）— 修正版

| # | 任务 | 工时 | 优先级 | 备注 |
|---|------|------|--------|------|
| **12** | **补充 Animation 绑定（AnimInstance/Montage/StateMachine）** | **5d** | **P1** | **提升优先级** |
| 13 | 补充 AI 绑定（BehaviorTree/AIController） | 3d | P2 | 不变 |
| 14 | 补充 Audio 绑定（AudioComponent/SoundCue） | 2d | P2 | 不变 |
| **15** | **完善 40 个存根绑定或文档化原因** | **5d** | **P2** | **新增** |
| **16** | **补充 Collision 查询绑定（LineTrace/Sweep/Overlap）** | **2d** | **P2** | **新增** |
| 17 | 评估并完善 AS Lambda 闭包捕获支持 | 5d | P2 | 修正（已有匿名函数基础） |
| 18 | 评估并吸收 AS 2.38 函数模板 | 3d | P3 | 不变 |
| 19 | 启用 + 文档化 + 验证 AngelscriptGAS 子模块 | 2d | P2 | 不变 |
| 20 | 添加性能回归基准测试 | 3d | P3 | 不变 |
| 21 | UHTTool 增量生成支持 | 3d | P3 | 不变 |
| **22** | **添加工具 Commandlet（验证/审计/文档生成）** | **3d** | **P3** | **新增** |

---

### 7.11 第二轮探索结论

**核心矛盾未变**：内部能力强，外部入口缺失。

**关键修正**：
- 测试基线比预期好（689/689 全通过），P0 中"修 7 个 failure"可删除
- Lambda 已有匿名函数基础，闭包捕获是增量工作而非从零开始
- Wiki 文档站已有良好基础，补充工作流文档即可

**新增关键发现**：
- GAS 子模块测试覆盖度是定时炸弹（1 个测试 vs 417+）
- 40 个存根绑定 + Animation/AI/Audio 三大黑洞 = 绑定层完整性问题
- 73 个活跃 Plan 需要清理归档，减少决策噪音
- Collision 查询（LineTrace/Sweep）缺失影响基础游戏开发

**最终优先级排序**：
1. 数字基线校准（0.2 周）
2. 交付基线（README/CI/LICENSE）（1 周）
3. Animation 绑定 + GAS 测试扩展（2 周）
4. VS Code DAP 适配器（2-3 周）
5. 存根绑定完善 + Collision 查询（2 周）

---

## 八、第三轮深度探索补充（2026-05-10）

### 8.1 脚本示例质量评估

对 `Script/Examples/` 中的示例逐一评估：

| 示例文件 | 评分 | 亮点 | 缺陷 |
|----------|------|------|------|
| Example_Actor.as | 8/10 | UPROPERTY/UFUNCTION/BlueprintOverride 模式清晰 | 无错误处理示例 |
| Example_Delegates.as | 8/10 | 单播/多播/事件区分明确，BindUFunction 用法 | 无无效绑定处理 |
| Example_NetworkReplication.as | 9/10 | Server/Client/NetMulticast/WithValidation/Unreliable 全覆盖 | 无网络错误场景 |
| Example_SubsystemLifecycle.as | 9/10 | 4 种子系统类型全覆盖，生命周期文档优秀 | 无初始化失败处理 |
| Example_FormatString.as | 9/10 | f-string 格式化最全面，对齐/填充/进制/枚举 | 无格式错误处理 |
| Example_InterfaceDispatch.as | 9/10 | 多态分发模式清晰，null 检查 | 无无效转换场景 |
| Example_BlueprintSubclass.as | 9/10 | 脚本基类 + BP 子类化 + 组件设置 | 无缺失组件处理 |
| Example_Array.as | 7/10 | 基本操作覆盖，展示 Throw() | 有限的错误恢复 |
| Example_Struct.as | 7/10 | 结构体声明和使用，全重载说明 | 无序列化模式 |
| Example_Timers.as | 7/10 | SetTimer/Pause/Clear 生命周期 | 无无效计时器处理 |
| Example_ConsoleWorkflow.as | 7/10 | const 全局变量限制说明清晰 | 无验证模式 |

**EnhancedInput 示例**（3 个，均为 9/10）：
- `Example_EI_Component.as`：Pawn 级绑定，ETriggerEvent 用法
- `Example_EI_PlayerController.as`：PlayerController 级绑定，最常见模式
- `Example_EI_InterfaceCall.as`：子系统接口访问，高级模式，115 行

**示例层面的系统性缺陷**：
- 无错误处理/异常模式示例（无 try/catch 或 Throw() 最佳实践）
- 无输入验证模式
- 无日志/调试模式
- 无 null 安全最佳实践（仅 InterfaceDispatch 展示了 null 检查）
- 缺少 `Example_ErrorHandling.as`

---

### 8.2 错误处理与诊断基础设施

#### 8.2.1 编译时错误报告

**位置**：`AngelscriptEngine.cpp:5293-5366`

| 能力 | 状态 | 说明 |
|------|------|------|
| 消息分类 | ✅ 完整 | INFORMATION/ERROR/WARNING 三级 |
| 行列号报告 | ✅ 完整 | `(row:col): message` 格式 |
| 文件分组 | ✅ 完整 | 按文件/模块名分组 |
| 诊断捕获 | ✅ 完整 | `FAngelscriptEngine::Diagnostics` map |
| 线程安全 | ✅ 完整 | `FScopeLock MessageLock` |
| 去重 | ✅ 完整 | 重复 section header 去重 |

**诊断结构**：
```cpp
struct FDiagnostic { FString Message; int32 Row, Col; bool bIsError, bIsInformation; };
```

#### 8.2.2 运行时异常处理

**位置**：`AngelscriptEngine.cpp:5523-5593`

| 能力 | 状态 | 说明 |
|------|------|------|
| 完整栈追踪 | ✅ | 最多 64 帧，含函数名/行号/模块名 |
| 屏幕错误显示 | ✅ | `UKismetSystemLibrary::PrintString()` |
| UE_LOG 集成 | ✅ | Error 级别 |
| 调试器集成 | ✅ | WITH_AS_DEBUGSERVER 条件编译 |
| JIT 异常处理 | ✅ | `HandleExceptionFromJIT` |
| 死循环检测 | ✅ | Loop detection callback |

#### 8.2.3 错误恢复机制

| 能力 | 状态 | 说明 |
|------|------|------|
| 启动编译失败对话框 | ✅ | 带重试选项 |
| Slate 未初始化回退 | ✅ | 非桌面平台处理 |
| 级联错误抑制 | ✅ | `bIgnoreCompileErrorDiagnostics` |
| 失败历史追踪 | ✅ | 避免无限循环 |
| 诊断格式化 | ✅ | `FormatDiagnostics()` 人类可读输出 |

**结论**：错误处理基础设施**非常完善**，是插件的强项之一。

---

### 8.3 网络/RPC 实现评估

**状态**：生产就绪，全 specifier 覆盖

| RPC 类型 | 支持 | 测试覆盖 |
|----------|------|----------|
| Server（FUNC_NetServer） | ✅ | ✅ ServerRPCCompileTest |
| Client（FUNC_NetClient） | ✅ | ✅ ClientRPCCompileTest |
| NetMulticast（FUNC_NetMulticast） | ✅ | ✅ MulticastRPCCompileTest |
| WithValidation（FUNC_NetValidate） | ✅ | ✅ ValidationRPCCompileTest |
| Unreliable（去除 FUNC_NetReliable） | ✅ | ✅ UnreliableRPCCompileTest |
| 混合 RPC + 复制属性 | ✅ | ✅ MixedRPCCompileTest |

**复制支持**：
- `UPROPERTY(Replicated)` → CPF_Net 标志
- `UPROPERTY(ReplicatedUsing=FunctionName)` → CPF_Net + CPF_RepNotify
- OnRep 回调签名验证

**不足**：
- 测试仅验证编译正确性（标志设置），未验证运行时 RPC 实际执行
- 无多客户端场景测试
- 无网络延迟/丢包模拟测试

---

### 8.4 EnhancedInput 集成评估

**状态**：完整集成，API 覆盖广泛

**绑定方法覆盖**：

| 类别 | 方法数 | 说明 |
|------|--------|------|
| UEnhancedInputComponent | 15+ | BindAction/BindActionValue/BindDebugKey/Remove/Clear |
| UInputMappingContext | 7 | MapKey/UnmapKey/UnmapAll/HasMapping/GetMapping |
| FEnhancedActionKeyMapping | 8 | Action/Key/Modifier/Trigger 管理 |
| UInputAction | 4 | ValueType/AccumulationBehavior |
| 绑定句柄结构 | 4 种 | Handle/EventBinding/ValueBinding/DebugKeyBinding |

**示例质量**：3 个示例均为 9/10 分，覆盖 Pawn/PlayerController/Subsystem 三个层级。

**不足**：
- 无 InputAction 资产创建的脚本侧支持
- 无 PlayerMappableInputConfig 绑定
- 无输入调试可视化

---

### 8.5 ClassGenerator 与 HotReload 深度分析

#### 8.5.1 版本链系统

```
OldClass → NewerVersion → NewerVersion → ... → CurrentClass
         (CLASS_NewerVersionExists flag)
```

- `GetMostUpToDateClass()` 遍历链找到最新版本
- 旧版本保留供现有实例引用
- 支持渐进式迁移

#### 8.5.2 重载级别（4 级）

| 级别 | 触发条件 | 影响 |
|------|----------|------|
| SoftReload | 函数/属性变更，结构未变 | 原地更新，保留类指针 |
| FullReloadSuggested | 推荐全重载但非必须 | 可选择性执行 |
| FullReloadRequired | 接口变更/新类/结构变更 | 必须重建 UClass |
| Error | 重载失败 | 回退处理 |

**依赖传播**：如果类 A 需要 FullReload，依赖 A 的类 B 也会被升级为 FullReload。

#### 8.5.3 接口支持

- 通过 `CallInterfaceMethod` 泛型分发机制实现
- 使用反射查找并调用实际 UFunction
- 声明 `ImplementedInterfaces` 的类**始终触发 FullReload**
- 递归解析父接口

#### 8.5.4 编辑器集成（ClassReloadHelper）

重载后执行的编辑器操作：
- 刷新 Blueprint Action 数据库
- 失效组件注册表
- 重编译依赖 Blueprint
- 重建 Volume 类几何体
- 刷新枚举资产操作
- 更新 Actor 工厂

**结论**：ClassGenerator + HotReload 是插件最成熟的子系统之一，架构设计精良。

---

### 8.6 性能基础设施评估

#### 8.6.1 性能追踪（14 个 Scope）

| 阶段 | Scope 名称 | 追踪内容 |
|------|-----------|----------|
| 启动 | StartupBindDatabase | 数据库绑定初始化 |
| 启动 | StartupBindScriptTypes | 脚本类型绑定 |
| 编译 | CompileInitial | 初始编译 |
| 编译 | CompileModules | 模块编译 |
| 绑定 | BindsCallBinds | 绑定函数调用 |
| 运行时 | RuntimeCallBPVMJIT | Blueprint VM JIT 调用 |
| 运行时 | RuntimeCallParmsContext | 参数上下文设置 |
| 重载 | ReloadHotReload | 热重载操作 |
| 生成 | ClassGeneratorSetup | 类生成器初始化 |
| 生成 | ClassGeneratorReload | 类生成器重载 |
| JIT | StaticJITPrecompiledData | 预编译数据加载 |
| 调试 | DebugServerTick | 调试服务器 Tick |
| 导出 | DumpAll | 全量导出 |
| 工具 | CommandletBlueprintImpact | Blueprint 影响分析 |

**集成方式**：`ANGELSCRIPT_PERF_SCOPE()` 宏同时触发：
- `TRACE_CPUPROFILER_EVENT_SCOPE_STR` — CPU Profiler
- `SCOPE_CYCLE_COUNTER` — Cycle Counter
- `CSV_SCOPED_TIMING_STAT` — CSV Profiling

#### 8.6.2 微基准测试基础设施

**位置**：`AngelscriptTest/Performance/`

| 文件 | 内容 |
|------|------|
| AngelscriptPerformanceTestTypes.h/cpp | 测试 fixture（标量/容器属性 + 函数） |
| AngelscriptRuntimeMicrobenchmarkTests.cpp | 运行时微基准（属性访问/函数调用） |
| AngelscriptReflectiveFallbackBenchmarkTests.cpp | 反射回退性能 |

**配置**：Warmup 1 次 → 测量 3 次 → 每次 10,000 迭代 → 输出 JSON

**不足**：
- 无编译时间基准（大型项目编译耗时未追踪）
- 无 JIT vs 解释器对比基准
- 无内存占用基准
- 无热重载时间基准
- 基准测试未集成到 CI（无回归检测）

---

### 8.7 配置系统评估

**AngelscriptSettings.h**：30+ 可配置属性

| 类别 | 设置数 | 代表性设置 |
|------|--------|-----------|
| 编译与绑定 | 5 | PreprocessorFlags, bAutomaticImports, DisabledBindNames |
| 类型系统 | 4 | MathNamespace, bScriptFloatIsFloat64, bDeprecateDoubleType |
| Blueprint 集成 | 7 | bDefaultFunctionBlueprintCallable, DefaultPropertyEditSpecifier |
| 安全与验证 | 5 | bMarkNonUpropertyPropertiesAsTransient, EditorMaximumScriptExecutionTime |
| 警告与错误 | 14 | bWarnOnUnusedReturnValue, bWarnOnImplicitSignedUnsignedConversion |
| 调试器 | 3 | DebuggerBlacklistAutomaticFunctionEvaluation |
| 编辑器 | 2 | bOpenFolderOnVSCodeSourceLinks, VSCodeWorkspacePath |

**亮点**：
- 死循环保护：`EditorMaximumScriptExecutionTime`（默认 1.0s，仅编辑器）
- 精度控制：`bScriptFloatIsFloat64`（默认 true，float 解析为 float64）
- 命名空间：`MathNamespace`（默认 `Math::`，可切换为 `FMath::`）
- VS Code 集成：`VSCodeWorkspacePath` 自定义工作区路径

**不足**：
- 所有设置需要编辑器重启才能生效
- 无运行时可调设置（如调试级别、日志详细度）
- 无设置验证（无效组合不会报错）
- 无设置迁移机制（版本升级时旧设置可能失效）

---

### 8.8 StaticJIT 深度评估

#### 8.8.1 架构

| 组件 | 职责 | 大小 |
|------|------|------|
| AngelscriptStaticJIT | JIT 编译器接口，C++ 代码生成 | 约 117KB |
| AngelscriptBytecodes | 字节码分析 | 约 200KB |
| PrecompiledData | 序列化预编译模块 | 约 93KB（600+ 行头文件） |
| StaticJITConfig | 平台配置 | 小文件 |

#### 8.8.2 平台限制

| 平台 | JIT 生成 | 预编译数据 |
|------|----------|-----------|
| Windows | ✅ | ✅ |
| Linux | ✅ | ✅ |
| Mac | ❌ | ✅（仅加载） |
| 主机平台 | ❌ | ✅（仅加载） |

#### 8.8.3 工作流

```
编辑器/开发模式：
  .as → 编译 → 字节码 → 解释执行

生成预编译数据（-as-generate-precompiled-data）：
  .as → 编译 → 字节码 → JIT 分析 → C++ 代码生成 → 序列化

打包/发布模式：
  加载预编译数据 → 直接执行（跳过编译）
```

#### 8.8.4 验证机制

- `AS_JIT_VERIFY_PROPERTY_OFFSETS`：非 Shipping 构建中验证属性偏移
- 8 个测试文件覆盖：归档序列化、JIT 生成、异常处理、原生桥接、原始类型转换

**不足**：
- 无 JIT 编译失败的优雅回退文档
- 无性能对比数据（JIT vs 解释器的实际加速比）
- Mac/主机平台无法生成 JIT，仅能使用预编译数据
- 无增量 JIT（修改一个函数需要重新生成整个模块）

---

### 8.9 CodeCoverage 深度评估

#### 8.9.1 工作流

```
1. MapExecutableLines(module) → 注册可执行行
2. StartRecording() → 开始追踪
3. [脚本执行] → HitLine() 被调用
4. StopRecordingAndWriteReport() → 生成报告
```

#### 8.9.2 报告输出

| 输出 | 格式 | 内容 |
|------|------|------|
| 文件级报告 | HTML | 逐行覆盖率，命中次数高亮 |
| 目录级汇总 | HTML | 目录树聚合覆盖率 |
| 顶层汇总 | JSON | 机器可读覆盖率数据 |

**输出路径**：`Saved/CodeCoverage/`

#### 8.9.3 测试框架集成

- `AddTestFrameworkHooks()`（仅编辑器）自动：
  - 测试刷新时开始录制
  - 测试完成时停止录制并生成报告
  - 无需手动 start/stop

**不足**：
- 无覆盖率阈值门控（无法设置"低于 X% 则失败"）
- 无增量覆盖率（无法只看本次变更的覆盖率）
- 无 CI 集成（报告仅本地生成）
- 无分支覆盖率（仅行覆盖率）
- 无覆盖率趋势追踪

---

### 8.10 构建配置分析

#### 8.10.1 模块依赖图（完整版）

```
AngelscriptRuntime (Public):
  Core, CoreUObject, Engine, EngineSettings, DeveloperSettings,
  Json, JsonUtilities, GameplayTags, StructUtils

AngelscriptRuntime (Private):
  AIModule, NavigationSystem, NetCore, Landscape, Networking,
  Sockets, InputCore, Slate, UMG, TraceLog, AssetRegistry,
  Projects, PhysicsCore, CoreOnline, EnhancedInput

AngelscriptRuntime (Editor-only):
  UnrealEd, EditorSubsystem

AngelscriptEditor (Public):
  Core, CoreUObject, Engine, UnrealEd, EditorSubsystem,
  AngelscriptRuntime, BlueprintGraph, Kismet, DirectoryWatcher,
  Slate, SlateCore, AssetTools

AngelscriptEditor (Private):
  Projects, GameplayTags, Settings, LevelEditor, PlacementMode,
  PropertyEditor, ContentBrowser, ContentBrowserData, ToolMenus, ToolWidgets

AngelscriptTest (Public):
  Core, CoreUObject, Engine, GameplayTags, Json, JsonUtilities,
  PropertyBindingUtils, AngelscriptRuntime

AngelscriptTest (Private):
  AIModule, EnhancedInput, UMG
  Editor-only: BlueprintGraph, CQTest, Networking, Sockets,
  UnrealEd, AngelscriptEditor
```

#### 8.10.2 构建优化设置

| 设置 | 值 | 影响 |
|------|-----|------|
| Debug/DebugGame 优化 | Never | 调试时完全不优化 |
| Unity Build 阈值 | 128KB | 超过 128KB 的 cpp 不合并 |
| PCH 模式 | UseExplicitOrSharedPCHs | 显式或共享预编译头 |

**不足**：
- 无 LTO（Link Time Optimization）配置
- 无模块级编译时间追踪
- Unity Build 阈值可能导致大文件（如 AngelscriptEngine.cpp 184KB）独立编译，增加构建时间

---

### 8.11 第三轮新发现总结

#### 8.11.1 强项确认

| 子系统 | 评分 | 说明 |
|--------|------|------|
| 错误处理/诊断 | 9/10 | 编译时+运行时+恢复机制全覆盖 |
| ClassGenerator/HotReload | 9/10 | 版本链+依赖传播+4级重载策略 |
| 网络/RPC | 8/10 | 全 specifier 支持+编译测试 |
| EnhancedInput | 9/10 | 完整 API+3 个优秀示例 |
| 性能追踪 | 7/10 | 14 个 scope+微基准，但缺 CI 集成 |
| 配置系统 | 7/10 | 30+ 设置，但需重启且无验证 |
| CodeCoverage | 7/10 | 完整工作流，但无阈值/CI/分支覆盖 |
| StaticJIT | 7/10 | 架构完整，但平台受限且无性能数据 |

#### 8.11.2 新识别的改进机会

| # | 领域 | 问题 | 优先级 |
|---|------|------|--------|
| 1 | Examples | 缺少 Example_ErrorHandling.as | P2 |
| 2 | Networking | RPC 测试仅验证编译，未验证运行时执行 | P2 |
| 3 | Performance | 无编译时间/JIT 加速比/内存占用基准 | P3 |
| 4 | CodeCoverage | 无覆盖率阈值门控和 CI 集成 | P2 |
| 5 | StaticJIT | 无 JIT vs 解释器性能对比数据 | P3 |
| 6 | Settings | 所有设置需重启，无运行时可调项 | P3 |
| 7 | Build | 无模块级编译时间追踪 | P3 |
| 8 | HotReload | 接口变更始终触发 FullReload（可能过于保守） | P3 |

---

### 8.12 综合健康度评分（三轮探索后最终版）

| 模块 | 评分 | 关键强项 | 关键弱项 |
|------|------|----------|----------|
| Core Engine | 9/10 | 编译流水线成熟，错误处理优秀 | 全局状态未完全隔离 |
| ClassGenerator | 9/10 | 版本链精良，依赖传播完整 | 接口变更过于保守 |
| HotReload | 9/10 | 4 级策略，编辑器集成完善 | PIE 下未充分验证 |
| Binds（核心类型） | 8/10 | TArray/Delegates/Actor 优秀 | 40 个存根，Animation/AI/Audio 缺失 |
| Networking/RPC | 8/10 | 全 specifier，编译验证 | 无运行时执行测试 |
| EnhancedInput | 9/10 | API 完整，示例优秀 | 无 PlayerMappableInputConfig |
| Debug Server | 8/10 | 30+ 消息类型，功能完整 | 无客户端（不可用） |
| StaticJIT | 7/10 | 架构完整，预编译可用 | 平台受限，无性能数据 |
| CodeCoverage | 7/10 | 行级追踪，HTML 报告 | 无阈值/CI/分支覆盖 |
| Preprocessor | 7/10 | #include/#if 正常 | 无参数化宏 |
| FunctionLibraries | 7/10 | 21 个库，6/8 Mixin 启用 | Math Mixin 阻塞 |
| Editor | 7/10 | HotReload/ContentBrowser/SourceNav | 无创建向导/内联错误 |
| Test | 8/10 | 689/689 通过，22 主题 | PIE 为零，GAS 覆盖不足 |
| UHT Tool | 7/10 | 架构清晰，导出完善 | 无增量生成 |
| GAS | 4/10 | 结构存在，基类完整 | 1 个测试，默认禁用，无文档 |
| Examples | 7/10 | 37 个，质量好 | 无索引/分级/错误处理示例 |
| Wiki/Docs | 7/10 | 双语 40+ 页，快速入门优秀 | VS Code 工作流不完整 |
| 对外交付 | 2/10 | Wiki 站存在 | 无 README/CI/LICENSE/Release |
| **综合** | **7.2/10** | **内部能力成熟** | **外部入口缺失** |

---

## 九、第四轮深度探索补充（2026-05-10）

### 9.1 工具脚本与 CI 就绪度

#### 9.1.1 本地 CI 基础设施

**位置**：`Tools/` 目录

| 脚本 | 大小 | 职责 |
|------|------|------|
| RunBuild.ps1 | 12.3 KB | 构建编排（互斥锁+超时+退出码） |
| RunTests.ps1 | 13 KB | 测试执行（前缀/分组双模式） |
| RunTestSuite.ps1 | 5.6 KB | 命名套件分发器 |
| RunAutomationTests.ps1 | 12.1 KB | 自动化测试运行器 |
| GetAutomationReportSummary.ps1 | 15.3 KB | 报告聚合 |
| Shared/UnrealCommandUtils.ps1 | 1,418 行 | 共享工具库 |

**质量评估**：

| 维度 | 评分 | 说明 |
|------|------|------|
| 错误处理 | 9/10 | Strict Mode + $ErrorActionPreference = 'Stop' |
| 并发控制 | 9/10 | Mutex 互斥锁（worktree + engine 双锁） |
| 超时管理 | 9/10 | Deadline-based，非简单 sleep |
| 退出码 | 9/10 | 6 级退出码（Success/BuildFailed/TimedOut/ConfigError/WorktreeBusy/EngineBusy） |
| 可配置性 | 8/10 | AgentConfig.ini 驱动，支持 -NoXGE/-SerializeByEngine |
| 输出管理 | 8/10 | `Saved/Build/<Label>/<RunId>/` 结构化输出 |

**内置测试套件**：
- `Smoke` — MultiEngine/DependencyInjection/Subsystem/BindConfig/SharedEngineHelper/Parity
- `NativeCore` — AngelScriptSDK
- `RuntimeCpp` — CppTests
- `Bindings` — Bindings tests
- `LearningNative` — Learning.Native tests

#### 9.1.2 云端 CI 缺口

| 缺失项 | 影响 |
|--------|------|
| GitHub Actions workflow | 无自动构建/测试 |
| Docker 容器化 | 无可复现环境 |
| 构建缓存 | 无增量 CI 构建 |
| 测试报告发布 | 无 PR 级测试结果 |
| 覆盖率报告发布 | 无覆盖率趋势 |

**结论**：本地 CI 脚本质量**极高**（9/10），是项目的隐藏强项。但完全缺少云端 CI，无法实现自动化回归检测。迁移到 GitHub Actions 时可直接复用现有脚本逻辑。

---

### 9.2 绑定注册架构

#### 9.2.1 注册 API 设计

**模式**：Fluent 模板 API + Lambda 注册

```
FAngelscriptBinds::FBind Bind_XXX(EOrder::Normal, [] {
    auto Type = FAngelscriptBinds::ValueClass<FVector>("FVector", ...);
    Type.Method("float Length() const", &FVector::Size);
    Type.Property("float X", offsetof(FVector, X));
});
```

**三阶段执行顺序**：
- `EOrder::Early` (-100) — 原始类型、基础设施
- `EOrder::Normal` (0) — 大部分绑定
- `EOrder::Late` (+100) — 依赖其他绑定的后期注册

**注册方法**：
| 方法 | 用途 |
|------|------|
| `ReferenceClass(Name, UClass*)` | UObject 派生类型 |
| `ValueClass<T>(Name, Flags)` | 值类型（结构体/POD） |
| `ExistingClass(Name)` | 向已注册类型追加方法 |
| `.Method(Sig, FuncPtr)` | 绑定成员方法 |
| `.Property(Sig, Offset)` | 绑定成员属性 |
| `.Constructor/Destructor/Factory` | 特殊行为 |
| `.GenericMethod(Sig, Callback)` | 反射回退分发 |
| `BindGlobalFunction(Sig, FuncPtr)` | 全局函数 |
| `BindGlobalVariable(Sig, Addr)` | 全局常量 |

#### 9.2.2 反射回退机制

**位置**：`BlueprintCallableReflectiveFallback.h/cpp`

| 组件 | 职责 |
|------|------|
| `EvaluateReflectionFallback()` | 检查 UFunction 是否适合回退（最多 16 参数，无自定义 thunk） |
| `InvokeReflectionFallbackFromGenericCall()` | 泛型回调入口 |
| `FReflectiveParamCache` | 预计算参数元数据（偏移/大小/拷贝策略） |
| CVar `as.ReflectiveFallback.UseCache` | 切换缓存/遗留路径（默认开启） |

**性能**：缓存路径比遗留路径快 3-6 倍。

#### 9.2.3 GC 集成

| 机制 | 说明 |
|------|------|
| 引用计数 | `AddRef`/`Release` 内部方法 |
| 循环检测 | 两阶段：clearCounters → buildMap → countReferences → detectGarbage → breakCircles |
| 新旧对象列表 | 增量收集支持 |
| GC 测试 | `AngelscriptGCTests.cpp` 验证引用链和回收行为 |

---

### 9.3 Dump 系统详细评估

#### 9.3.1 导出表清单

**18+ 私有导出方法**，生成的 CSV 表包括：

| CSV 表 | 列内容 |
|--------|--------|
| Classes.csv | Module, ClassName, SuperClass, Flags(Abstract/Transient/Placeable...), PropertyCount, MethodCount, LineNumber, Namespace |
| Properties.csv | Module, Class, PropertyName, LiteralType, BP Flags(Readable/Writable), Edit Flags, Replication, Config, Access, LineNumber |
| Functions.csv | Module, Class, FunctionName, ReturnType, Arguments, BP Flags(Callable/Event/Pure), Network Flags, Static, Const, Access, LineNumber |

**扩展性**：`OnDumpExtensions` 委托允许外部模块注册自定义导出。

#### 9.3.2 Blueprint 集成深度

**三层绑定机制**：

| 层 | 文件 | 职责 |
|----|------|------|
| BlueprintType | Bind_BlueprintType.cpp | UObject 派生类自动注册，元数据门控 |
| BlueprintCallable | Bind_BlueprintCallable.cpp | 函数绑定（直接指针 + 反射回退） |
| BlueprintEvent | Bind_BlueprintEvent.cpp | 可覆写事件（最多 16 参数） |

**Prepare/Commit 模式**：
1. Phase 2A（Prepare）— 只读元数据门控 + 签名构建（可并行）
2. Phase 2B（Commit）— 实际绑定注册（单线程）

**CDO 生命周期管理**：
- `InitDefaultObjects()` — 预处理 tick 设置，然后为所有类创建 CDO
- 软重载时使用 `CDONoDefaults` 临时 CDO 进行属性差异比较
- 组件附着和可见性标志在重载期间保留

---

### 9.4 测试框架与模式

#### 9.4.1 测试宏体系

**基于 CQTest 框架**：

| 宏 | 用途 |
|----|------|
| `TEST_CLASS_WITH_FLAGS` | 定义测试类 |
| `BEFORE_ALL` / `AFTER_ALL` | 共享引擎生命周期 |
| `TEST_METHOD` | 单个测试方法 |
| `ASTEST_CREATE_ENGINE()` | 共享引擎，重置为干净状态 |
| `ASTEST_CREATE_ENGINE_FULL()` | 隔离的完整引擎（核心/绑定测试） |
| `ASTEST_CREATE_ENGINE_NATIVE()` | 原始 asIScriptEngine*（SDK 测试） |

#### 9.4.2 功能测试工具

| 工具 | 用途 |
|------|------|
| `CompileScriptModule()` | 从内存编译 AS，验证类生成 |
| `TickWorld()` | 模拟世界/Actor/组件 Tick |
| `BeginPlayActor()` | 分发 BeginPlay |
| `SpawnScriptActor()` | 生成测试 Actor |
| `FAngelscriptTestWorld` | 管理测试世界生命周期 |
| `VerifyByPath<T>()` | 反射属性验证 |

#### 9.4.3 绑定测试断言

| 工具 | 用途 |
|------|------|
| `FBindingsCoverageProfile` | 标准化测试元数据 |
| `FCoverageModuleScope` | 每测试模块隔离 + 自动清理 |
| `ExpectGlobalInt()` | 调用全局函数并比较返回值 |
| `ExecuteFunctionExpectingScriptException()` | 验证脚本异常（模式匹配） |
| `FASGlobalFunctionInvoker` | 反射函数调用 + 诊断 |

**结论**：测试框架设计**优秀**（9/10），提供了从 SDK 级到功能级的完整测试工具链。

---

### 9.5 GAS 插件代码质量

#### 9.5.1 设计模式

| 模式 | 实现 | 说明 |
|------|------|------|
| 防御性包装 | FAngelscriptAttributeChangedData | 快照易失指针，防止 use-after-free |
| 双 API 变体 | Try*/Unsafe | 安全/不安全函数明确区分 |
| K2_ 前缀 | AngelscriptGASAbility | Blueprint 暴露函数统一命名 |
| Mixin 库 | AttributeChangedDataMixinLibrary | 结构体访问器 |
| 手写绑定 | Bind_AngelscriptGASLibrary | 复杂异步操作（非反射回退） |

#### 9.5.2 异步绑定覆盖

**已绑定**（4 个）：
- `WaitForAttributeChanged`
- `WaitGameplayEventToActor`
- `WaitGameplayTagAddToActor`
- `WaitGameplayTagRemoveFromActor`

**未绑定的常见 GAS 异步任务**：
- WaitAbilityActivate / WaitAbilityCommit / WaitAbilityEnd
- WaitGameplayEffectApplied / WaitGameplayEffectRemoved
- WaitTargetData / WaitConfirmCancel
- WaitInputPress / WaitInputRelease
- WaitOverlap / WaitVelocityChange

**结论**：GAS 代码质量**良好**（防御性设计、清晰命名），但**覆盖面窄**（仅 4 个异步任务，缺少大量常用 GAS 异步操作）。

---

### 9.6 编辑器子系统深度评估

#### 9.6.1 CodeGen 系统

| 能力 | 状态 | 说明 |
|------|------|------|
| 头文件路径处理 | ✅ | 去除 Public/Private/Classes 前缀 |
| Build.cs 生成 | ✅ | 模块依赖自动配置 |
| 源文件生成 V2 | ✅ | C++ 绑定代码生成 |
| 函数条目提取 | ✅ | 从 UClass 提取函数绑定 |

#### 9.6.2 ContentBrowser 集成

| 能力 | 状态 | 说明 |
|------|------|------|
| 项目枚举 | ✅ | .as 文件在内容浏览器可见 |
| 过滤器 | ✅ | 包含/排除类列表 |
| 资产操作 | ✅ | 编辑/批量编辑/物理路径解析 |
| 缩略图 | ✅ | 缩略图更新支持 |
| 遗留兼容 | ✅ | 虚拟路径 ↔ 资产数据格式转换 |

#### 9.6.3 菜单扩展系统

**支持的菜单位置**（6+）：
- ContentBrowser_AssetContextMenu
- ContentBrowser_PathViewContextMenu
- ContentBrowser_AssetViewContextMenu
- LevelViewport_ContextMenu
- LevelViewport_CreateMenu
- ToolMenu（主编辑器菜单）

**特性**：
- 脚本驱动的菜单扩展（BlueprintImplementableEvent）
- 排序支持（Before/After/First）
- 类过滤（Asset 菜单按类型过滤）
- 动态收集扩展函数

#### 9.6.4 Blueprint Impact Scanner

| 能力 | 状态 | 说明 |
|------|------|------|
| 影响原因追踪 | ✅ | ScriptParentClass/NodeDependency/PinType/VariableType/DelegateSignature/ReferencedAsset |
| 符号映射 | ✅ | Classes/Structs/Enums/Delegates |
| 增量扫描 | ✅ | 仅扫描变更的脚本 |
| 全量扫描 | ✅ | 扫描所有 Blueprint 资产 |

#### 9.6.5 ScriptableFactory

| 能力 | 状态 | 说明 |
|------|------|------|
| UFactory 实现 | ✅ | 文本/二进制资产创建 |
| Blueprint 钩子 | ✅ | CreateFromText()/CreateFromBinary() |
| 创建/覆写 | ✅ | CreateOrOverwriteAsset() |
| Blueprint 弹窗 | ✅ | ShowCreateBlueprintPopup() |

**结论**：编辑器子系统**功能完整**（8/10），ContentBrowser/菜单/BlueprintImpact/SourceNav/Factory 全部可用。主要缺口是**无脚本创建向导**（用户需手动创建 .as 文件）和**无内联错误显示**。

---

### 9.7 第四轮新发现总结

#### 9.7.1 隐藏强项

| 发现 | 评分 | 说明 |
|------|------|------|
| 本地 CI 脚本 | 9/10 | 互斥锁+超时+退出码+结构化输出，质量极高 |
| 绑定注册架构 | 9/10 | Fluent API + 三阶段排序 + JIT 支持 |
| 反射回退缓存 | 8/10 | 3-6x 性能提升，CVar 可控 |
| 测试框架 | 9/10 | 三层引擎生命周期 + 功能测试工具 + 绑定断言 |
| 编辑器集成 | 8/10 | ContentBrowser/菜单/Impact/SourceNav/Factory 全覆盖 |
| GAS 防御性设计 | 8/10 | 易失指针快照，双 API 变体 |

#### 9.7.2 新识别的改进机会

| # | 领域 | 问题 | 优先级 |
|---|------|------|--------|
| 1 | CI | 本地脚本优秀但无云端 CI，迁移成本低 | P1 |
| 2 | GAS | 仅 4 个异步任务绑定，缺少 10+ 常用操作 | P2 |
| 3 | Editor | 无脚本创建向导（ScriptableFactory 存在但未暴露为向导） | P2 |
| 4 | Binds | Prepare/Commit 模式可并行化但当前单线程 Commit | P3 |
| 5 | Dump | CSV 导出完整但无可视化/仪表板 | P3 |

---

### 9.8 最终综合评分（四轮探索后）

| 模块 | 评分 | 变化 | 关键发现 |
|------|------|------|----------|
| Core Engine | 9/10 | - | 绑定注册架构精良 |
| ClassGenerator | 9/10 | - | CDO 生命周期管理完善 |
| HotReload | 9/10 | - | Prepare/Commit 模式 |
| Binds（架构） | 9/10 | +1 | Fluent API + 反射回退缓存 3-6x |
| Binds（覆盖面） | 6/10 | - | 40 存根 + Animation/AI/Audio 缺失 |
| Networking/RPC | 8/10 | - | 编译验证完整 |
| EnhancedInput | 9/10 | - | API + 示例优秀 |
| Debug Server | 8/10 | - | 无客户端 |
| StaticJIT | 7/10 | - | 平台受限 |
| CodeCoverage | 7/10 | - | 无 CI 集成 |
| FunctionLibraries | 7/10 | - | Math Mixin 阻塞 |
| Editor 集成 | 8/10 | +1 | ContentBrowser/菜单/Impact/Factory 全覆盖 |
| Test 框架 | 9/10 | +1 | CQTest + 三层引擎 + 功能工具 |
| Test 覆盖 | 8/10 | - | 689/689 但 PIE/GAS 不足 |
| UHT Tool | 7/10 | - | 无增量生成 |
| GAS（代码质量） | 7/10 | +3 | 防御性设计好，但异步覆盖窄 |
| GAS（测试/文档） | 3/10 | - | 1 个测试，无文档 |
| Examples | 7/10 | - | 无错误处理示例 |
| Wiki/Docs | 7/10 | - | VS Code 工作流不完整 |
| 本地 CI 脚本 | 9/10 | 新增 | 互斥锁+超时+退出码 |
| 云端 CI | 1/10 | 新增 | 完全缺失 |
| 对外交付 | 2/10 | - | 无 README/LICENSE/Release |
| **综合** | **7.3/10** | **+0.1** | **内部工程质量极高，外部入口缺失** |

---

### 9.9 四轮探索最终结论

经过四轮系统性探索，对插件的认知已经非常完整。

**核心判断**：这是一个**工程质量极高的内部项目**，但**完全不具备对外交付条件**。

**最被低估的强项**：
1. 本地 CI 脚本（互斥锁/超时/退出码，可直接迁移到 GitHub Actions）
2. 绑定注册架构（Fluent API + 三阶段排序 + 反射回退缓存）
3. 测试框架（CQTest + 三层引擎生命周期 + 功能测试工具链）
4. 编辑器集成（ContentBrowser/菜单扩展/BlueprintImpact/ScriptableFactory）

**最需要关注的弱项**：
1. 对外交付基线（README/CI/LICENSE）— 阻塞一切外部使用
2. 调试客户端（VS Code DAP）— 阻塞开发者日常工作流
3. 绑定覆盖面（Animation/AI/Audio + 40 存根）— 限制脚本能力边界
4. GAS 测试/文档（1 个测试 + 无文档）— 子模块质量风险

**推荐执行路径**：
```
Week 1: 数字基线校准 + Plan 归档清理
Week 2-3: README + CI（复用现有脚本）+ LICENSE
Week 4-5: Animation 绑定 + GAS 测试扩展
Week 6-8: VS Code DAP 适配器 Phase 1-2
Week 9-10: 存根绑定完善 + Collision 查询 + Wiki 工作流
```

**总工时估算**：约 45-55 人日可完成从"内部研发"到"可对外分享"的转变。

---

## 十、第五轮深度探索补充（2026-05-10）

### 10.1 重要修正：Collision 查询绑定实际完整

**此前评估错误**：第二轮报告中将 "Collision 查询缺失" 列为 P2 问题。

**实际状态**：`Bind_WorldCollision.cpp` 提供了**极其完整**的碰撞查询绑定：

| 类别 | 变体数 | 说明 |
|------|--------|------|
| LineTrace | 9 | Test/Single/Multi x ByChannel/ByObjectType/ByProfile |
| Sweep | 9 | Test/Single/Multi x ByChannel/ByObjectType/ByProfile |
| Overlap | 8 | BlockingTest/AnyTest/Multi x ByChannel/ByObjectType/ByProfile |
| ComponentQuery | 6 | ComponentSweepMulti/ComponentOverlapMulti（FQuat/FRotator 重载） |
| AsyncTrace | 9 | Async 版本 + QueryTraceData/QueryOverlapData/IsTraceHandleValid |
| **总计** | **41** | 覆盖所有 UE 碰撞查询 API |

**支持类型**：FTraceHandle, FTraceDatum, FOverlapDatum, EAsyncTraceType

**结论**：Collision 查询绑定**完全不是缺口**，应从改进列表中移除。这是绑定层的又一个强项。

---

### 10.2 Wiki 内容质量深度评估

#### 10.2.1 页面内容厚度

| 类别 | 状态 | 说明 |
|------|------|------|
| 架构页面 | 良好 | runtime-core/module-layout/compilation-pipeline 简洁完整 |
| 对比页面 | 良好 | hazelight-baseline 诚实标注差异 |
| 脚本页面 | **薄弱** | 大部分仅 30-40 行，指向示例但无内联代码 |
| 指南页面 | 中等 | setup 清晰，debugging 承认缺口 |

#### 10.2.2 核心问题

1. **脚本页面是指针而非教程**：列出示例文件路径但不解释如何使用或为什么
2. **缺少工作流叙事**：无"第一个脚本"完整流程（编辑→保存→重载→调试）
3. **无内联代码片段**：读者必须跳转到外部文件才能理解语法
4. **部分主题标注"基础存在但指南缺失"**：EnhancedInput/Console/EditorOnly 脚本

#### 10.2.3 积极面

- 双语语义对等（非机器翻译存根）
- 诚实标注覆盖状态（"存在"/"缺失"/"引擎侧"）
- 维护者路径文档质量高
- 结构清晰，扩展容易

---

### 10.3 知识库质量分析

#### 10.3.1 按家族评估

| 家族 | 文件数 | >400 行 | <250 行 | 质量 |
|------|--------|---------|---------|------|
| Syntax_ | 10 | 10 | 0 | 优秀（全部充实） |
| Type_ | 2 | 2 | 0 | 优秀 |
| Arch_ | 1 | 1 | 0 | 优秀（560 行） |
| Guide_ | 1 | 1 | 0 | 优秀（1084 行） |
| Note_ | 1 | 1 | 0 | 优秀（785 行） |
| AS_ | 9 | 1 | 8 | **薄弱**（大部分存根） |
| Diff_ | 2 | 0 | 2 | **薄弱**（均为存根） |
| Rule | 1 | 0 | 1 | **空文件** |

**总体**：31 个文件中 18 个（58%）充实，13 个（42%）为存根或薄弱。

#### 10.3.2 代表性文档质量

| 文档 | 行数 | 评分 | 亮点 |
|------|------|------|------|
| Syntax_UPROPERTY.md | 1608 | 10/10 | 最全面的属性文档 |
| Syntax_DefaultStatement.md | 1491 | 10/10 | 默认语句完整覆盖 |
| Syntax_DelegateEvent.md | 1313 | 9/10 | 委托/事件双路径 |
| Syntax_Mixin.md | 471 | 9/10 | AS 层 + C++ 反射层双路径，测试矩阵 |
| Arch_RuntimeLifecycle.md | 560 | 9/10 | 三层架构 + 6 阶段生命周期 + 陷阱 |
| Guide_QuickStart.md | 1084 | 8/10 | 16 个实战示例 |
| AS_Compiler.md | 239 | 6/10 | 架构清晰但深度不足 |
| AS_VirtualMachine.md | 90 | 3/10 | 存根 |

---

### 10.4 UnrealMCP 工具评估

**位置**：`Tools/UnrealMCP/`

**架构**：基于 FastMCP 的 Python 服务器，通过 UE 5.7 Remote Execution Protocol 控制编辑器

**12 个 MCP 工具**：

| 工具 | 用途 |
|------|------|
| ue_exec_python | 在 UE 中执行 Python 脚本 |
| ue_eval_python | 评估 Python 表达式 |
| ue_status | 获取绑定/隧道/引擎健康状态 |
| ue_bind_project | 绑定 .uproject |
| ue_unbind_project | 解除绑定 |
| ue_start_project | 启动 UE 编辑器 |
| ue_close_project | 关闭编辑器 |
| ue_search_python_api | 搜索 UE Python API（smart/exact/regex） |
| ue_read_python_api_symbol | 读取符号详细定义 |
| ue_check_project_setup | 验证 PythonScriptPlugin/远程执行/存根/开发者模式 |
| ue_list_windows | 列出所有可见 UE 窗口 |
| ue_screenshot | 捕获 UE 窗口截图（支持遮挡） |

**协议**：UDP 多播发现 + TCP 命令通道 + 后台心跳

**评估**：这是一个**高质量的开发工具**，可用于自动化测试、CI 集成、远程控制编辑器。但当前未与主插件工作流集成。

---

### 10.5 RalphLoop 代理编排框架

**位置**：`Tools/RalphLoop/`

**用途**：Windows-first PowerShell 循环引擎，重复调用 AI CLI（codex/opencode）

**核心参数**：
- `-Prompt` — 主输入
- `-MaxIterations` — 默认 5
- `-Agent` — 提供者选择（codex/opencode）
- `-VerifyCommand` — 可选验证步骤
- `-MaxConsecutiveFailures` — 连续失败上限（默认 3）

**设计原则**：
- 循环引擎保持精简，通过 profiles 注入提供者行为
- 退出契约代理无关（0=停止, 1=继续, >1=错误）
- 默认紧凑输出，原始流式为可选

**评估**：成熟的代理编排工具，有完整的测试套件（mock + 真实代理）。

---

### 10.6 测试命名规范遵守度

**评估结果**：**优秀**

| 维度 | 状态 | 说明 |
|------|------|------|
| 文件命名 | ✅ | `Angelscript` 前缀 + `*Tests.cpp`/`*Test.cpp` |
| 自动化前缀 | ✅ | `Angelscript.TestModule.*` / `Angelscript.Editor.*` |
| CQTest 使用 | ✅ | `TEST_CLASS_WITH_FLAGS` + 路径参数 |
| 层级分离 | ✅ | 8 层明确定义（Runtime/Editor/Native/Integration/...） |
| 文档化 | ✅ | `TestConventions.md` 提供完整决策树 |

**自动化测试分组**（DefaultEngine.ini）：
- AngelscriptSmoke, AngelscriptNative, AngelscriptRuntimeUnit
- AngelscriptFast, AngelscriptFunctional, AngelscriptEditor
- AngelscriptExamples, AngelscriptDebugger, AngelscriptPerformance

---

### 10.7 宿主项目极简性确认

**Source/AngelscriptProject/**：仅 2 个文件

| 文件 | 内容 |
|------|------|
| AngelscriptProject.cpp | `IMPLEMENT_PRIMARY_GAME_MODULE(FDefaultGameModuleImpl, ...)` |
| AngelscriptProject.h | `#pragma once` + `#include "CoreMinimal.h"` |

**Build.cs 依赖**：仅 Core, CoreUObject, Engine

**结论**：宿主模块**最大程度极简**，零自定义逻辑。所有插件逻辑在子模块中。

---

### 10.8 技术债标记

**Core 运行时中仅 1 个 TODO**：
- `AngelscriptType.cpp:330` — `// TODO: Default values`（类型系统默认参数处理）

**结论**：代码库**极其干净**，几乎无技术债标记。

---

### 10.9 FunctionLibraries 实际覆盖面

**此前评估不完整**。实际 Math 库覆盖：

| 子库 | 内容 |
|------|------|
| 基础数学 | SinCos(32/64), Modf, Wrap, WrapIndex |
| 旋转插值 | LerpShortestPath, RInterpShortestPathTo, RInterpConstantShortestPathTo |
| 变换插值 | TInterpTo |
| 几何 | LineBoxIntersection |
| 8 个类型 Mixin | FVector/FVector3f/FRotator/FRotator3f/FQuat/FQuat4f/FTransform/FTransform3f |
| 3 个 Static 库 | FQuat/FRotator/FTransform（delta/relative 变换） |

**Actor 库**：6 个 FQuat 旋转重载 + SetActorLocationAdvanced + 编辑器专用方法 + GetAttachedActors

**Component 库**：相对/世界位置/旋转/缩放/变换 + 四元数变体 + 附着 + 边界查询

---

### 10.10 第五轮修正与新发现总结

#### 10.10.1 重要修正

| 项目 | 此前评估 | 修正后 | 影响 |
|------|----------|--------|------|
| Collision 查询 | "缺失，P2" | **41 个变体，完全覆盖** | 从改进列表移除 |
| FunctionLibraries | "7/10" | **8/10**（Math 8 子库 + 3 Static） | 评分上调 |
| 技术债标记 | 未知 | **仅 1 个 TODO** | 代码极干净 |
| 知识库 | 未知 | **58% 充实 / 42% 存根** | AS_ 家族需补充 |

#### 10.10.2 新发现的强项

| 发现 | 评分 | 说明 |
|------|------|------|
| UnrealMCP | 8/10 | 12 个 MCP 工具，可远程控制 UE 编辑器 |
| RalphLoop | 8/10 | 成熟的代理编排框架，有测试套件 |
| Review Tools | 7/10 | 证据驱动的自动化审计框架 |
| 测试命名规范 | 9/10 | 8 层分离 + 9 个自动化分组 + 完整文档 |
| 宿主极简性 | 10/10 | 2 文件，零逻辑，纯壳 |
| 代码洁净度 | 9/10 | 仅 1 个 TODO，无 FIXME/HACK |

#### 10.10.3 新识别的改进机会

| # | 领域 | 问题 | 优先级 |
|---|------|------|--------|
| 1 | Wiki | 脚本页面过薄（30-40 行），需内联代码和工作流叙事 | P2 |
| 2 | Knowledge | AS_ 家族 8 个存根需补充（VM/StringFactory/CallingConventions 等） | P3 |
| 3 | UnrealMCP | 未与主插件工作流集成（可用于自动化测试/CI） | P3 |
| 4 | Wiki | 缺少"第一个脚本"完整教程 | P2 |
| 5 | Knowledge | Rule.md 为空文件，需删除或填充 | P3 |

---

### 10.11 最终综合评分（五轮探索后）

| 模块 | 评分 | 变化 | 说明 |
|------|------|------|------|
| Core Engine | 9/10 | - | 仅 1 个 TODO，极干净 |
| ClassGenerator | 9/10 | - | - |
| HotReload | 9/10 | - | - |
| Binds（架构） | 9/10 | - | - |
| Binds（覆盖面） | **7/10** | **+1** | Collision 41 变体完整，仅 Animation/AI/Audio 缺失 |
| Networking/RPC | 8/10 | - | - |
| EnhancedInput | 9/10 | - | - |
| Debug Server | 8/10 | - | - |
| StaticJIT | 7/10 | - | - |
| CodeCoverage | 7/10 | - | - |
| FunctionLibraries | **8/10** | **+1** | Math 8 子库 + 3 Static + Actor/Component 完整 |
| Editor 集成 | 8/10 | - | - |
| Test 框架 | 9/10 | - | - |
| Test 覆盖 | 8/10 | - | - |
| UHT Tool | 7/10 | - | - |
| GAS（代码） | 7/10 | - | - |
| GAS（测试/文档） | 3/10 | - | - |
| Examples | 7/10 | - | - |
| Wiki/Docs（结构） | 8/10 | - | 双语 40+ 页 |
| Wiki/Docs（内容） | **5/10** | **新增** | 脚本页面薄弱 |
| Knowledge（Syntax/Type/Arch） | **9/10** | **新增** | 58% 充实，质量高 |
| Knowledge（AS 内部） | **4/10** | **新增** | 42% 存根 |
| 本地 CI 脚本 | 9/10 | - | - |
| 云端 CI | 1/10 | - | - |
| 开发工具（MCP/RalphLoop） | **8/10** | **新增** | 成熟但未集成 |
| 对外交付 | 2/10 | - | - |
| 代码洁净度 | **9/10** | **新增** | 1 TODO，无 FIXME/HACK |
| **综合** | **7.5/10** | **+0.2** | **Collision 修正 + 工具链加分** |

---

### 10.12 五轮探索最终结论

经过五轮系统性探索（覆盖 18+ 子模块、1200+ 文件、73 个 Plan、40+ Wiki 页面、31 个知识库文档），对插件的认知已**完全饱和**。

**最终核心判断**：

这是一个**工程质量 9/10 的内部项目**（代码洁净、架构精良、测试完善、工具链成熟），但**对外可用性仅 2/10**（无 README、无 CI、无调试客户端、Wiki 内容薄弱）。

**修正后的执行路径**：
```
Week 1: 数字基线校准 + Plan 归档清理
Week 2-3: README + CI（复用现有脚本）+ LICENSE
Week 4-5: Animation 绑定 + GAS 测试扩展
Week 6-8: VS Code DAP 适配器 Phase 1-2
Week 9-10: Wiki 脚本页面充实 + 存根绑定完善
```

**从改进列表移除的项目**：
- ~~Collision 查询绑定~~（实际 41 个变体，完全覆盖）
- ~~FunctionLibraries 不足~~（实际 Math 8 子库 + 3 Static，覆盖面好）

**总工时估算修正**：约 40-50 人日（因 Collision 不需要补充，减少 2 天）。
