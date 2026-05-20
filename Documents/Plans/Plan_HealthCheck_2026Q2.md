# AS 插件全量体检报告（2026-05-10）

> **定位**：本文是对 `Plugins/Angelscript` 插件当前状态的一次系统性全量体检，覆盖六大维度：
> 交付基线、测试健康、功能完整性、语言能力、工具链、架构质量。
> 每个维度给出事实现状、不足点和建议优先级。
> 本文不引入新 roadmap 主线，而是作为 `Plan_StatusPriorityRoadmap.md` 和 `Plan_OpportunityIndex.md` 的最新事实补充。
>
> **读法**：
> - 要了解"整体健康度" → 读 §1 总评
> - 要找"最紧迫的问题" → 读 §7 优先级汇总
> - 要找"某个维度的细节" → 直接跳对应章节

---

## §1 总体健康度评估

| 维度 | 健康度 | 主要问题 |
|------|--------|---------|
| 交付基线 | 🔴 **薄弱** | README 有内容但 CI/uplugin 元数据/BuildPlugin 仍缺 |
| 测试健康 | 🟡 **中等** | 1401/1407 通过，6 个已知失败未修，Smoke suite 定义过期，ASTEST_CREATE_ENGINE 被滥用 ~1101 次 |
| 功能完整性 | 🟡 **中等** | C++ UInterface 绑定缺口、GAS helper surface 薄、Debug 模式死代码路径 |
| 语言能力 | 🟡 **中等** | foreach 已有但实现策略与 2.38 不对齐，函数模板/Lambda 未移植 |
| 工具链 | 🟠 **偏弱** | 无 DAP 客户端、无 VS Code 扩展、无 BuildPlugin 脚本 |
| 架构质量 | 🟡 **中等** | 325 处全局状态依赖、Unity Build 490 个冲突待清、Math ScriptMixin 未启用、6 处 WILL-EDIT 标记 |

**一句话总结**：插件核心运行时已成熟，测试基础设施扎实，但对外交付入口、工具链可见性、测试引擎生命周期滥用和若干功能闭环仍是主要短板。

> **深度探索修正（2026-05-10）**：
> - "预处理器 import 未实现"→ **已完整实现**（`AngelscriptPreprocessor.cpp:537`），测试失败是断言问题
> - "Enhanced Input 零测试覆盖"→ **已有 3 个测试文件**，覆盖可能不充分
> - "Script 示例 37 个"→ **实际 28 个**（Core 20 + EnhancedInput 3 + Extended 5）
> - "Settings 28 个字段"→ **实际 33 个字段**（`AngelscriptSettings.h` 实测）

---

## §2 交付基线维度

### 2.1 当前事实

| 项目 | 状态 | 证据 |
|------|------|------|
| `README.md` | ⚠️ 有内容但不完整 | 有基本说明，缺构建/测试/兼容/贡献导航 |
| `Angelscript.uplugin` | 🔴 元数据空白 | `DocsURL/MarketplaceURL/SupportURL` 全空，`VersionName="1.0"` 无版本策略 |
| `.github/workflows/` | 🔴 不存在 | 无 CI 守门，PR/push 无自动化验证 |
| `Tools/BuildPlugin.ps1` | 🔴 不存在 | 无标准化打包入口 |
| `SECURITY.md` | 🔴 不存在 | 无漏洞披露路径 |
| `CONTRIBUTING.md` | 🔴 不存在 | 无外部贡献入口 |
| `CHANGELOG.md` | 🔴 不存在 | 无版本变更记录 |
| `Documents/Guides/Compatibility.md` | 🔴 不存在 | 无兼容矩阵 |
| `Documents/Guides/Release.md` | 🔴 不存在 | 无发布流程 |
| 插件仓库拆分 | 📋 已规划 | `Plan_PluginRepositorySeparation.md` 已有方案，未执行 |

### 2.2 不足点

1. **对外消费入口缺失**：外部用户进入仓库无法快速理解"怎么装、怎么用、怎么贡献"
2. **CI 守门为零**：任何 PR 都没有自动化验证，质量依赖人工
3. **版本策略不存在**：`1.0` 版本号无对应 changelog、无发布纪律
4. **插件元数据空白**：`DocsURL/SupportURL` 空白，无法对外声明支持边界

### 2.3 对应 Plan

- `Plan_PluginEngineeringHardening.md`（P1 优先级，5 个 Phase 全部未启动）
- `Plan_PluginRepositorySeparation.md`（规划完成，执行待启动）

---

## §3 测试健康维度

### 3.1 当前数字基线（三套口径）

| 口径 | 数字 | 来源 |
|------|------|------|
| 已编目基线 | `275/275 PASS` | `TestCatalog.md` |
| Live full-suite（2026-05-02） | `1401/1407`，6 失败 | `Plan_FullSuiteFailureTriage_20260502.md` |
| 源码扫描规模 | `405 cpp / 417+ 定义` | 实时扫描 |

### 3.2 当前 6 个已知失败

| # | 测试 | 根因 | 对应 Phase |
|---|------|------|-----------|
| 1 | `Syntax.TypeDeclaration.Class_Negative` | Negative 用例缺 `AddExpectedError` | Phase 1 |
| 2 | `Syntax.TypeDeclaration.Struct_Negative` | 同上 | Phase 1 |
| 3 | `Syntax.UFunction.Specifiers_Negative` | 同上 | Phase 1 |
| 4 | `Syntax.UProperty.Specifiers_Negative` | 同上 | Phase 1 |
| 5 | `Engine.BindConfig.UnnamedBindBackwardCompatibility` | 测试与新 bind 命名约定不一致 | Phase 2 |
| 6 | `FunctionLibraries.Widget.RenderTransformNullGuard` | 跨测试共享引擎状态污染 | Phase 3 |

### 3.3 其他测试健康问题

| 问题 | 严重度 | 说明 |
|------|--------|------|
| `Smoke` suite 定义过期 | 🟡 中 | `Angelscript.CppTests.MultiEngine` 前缀已不存在，suite 整体失败 |
| `All` suite 超时 | 🟡 中 | 全量 > 900s，无法在单波内完成，需拆分为 4 波子 suite |
| PIE 地图测试几乎为零 | 🔴 高 | 仅 1 张测试地图 + 1 个用例，运行时行为完全未验证 |
| 预处理器 import 测试失败 | 🟡 中 | `ImportParsing` / `Learning.Runtime.Preprocessor` 失败，**功能已实现**，是测试断言问题 |
| Engine Core 生命周期测试 3 个失败 | 🟡 中 | `FAngelscriptEngineScope` 缺失导致类型查找失败（`AngelscriptEngineCoreTests.cpp`） |
| Enhanced Input 测试覆盖不充分 | 🟠 偏弱 | 有 3 个测试文件，但 `AngelscriptEnhancedInputBindingsTests.cpp` 中有 8 处冗余 CREATE |
| StaticJIT 专项测试薄弱 | 🟠 偏弱 | 仅 8 个测试文件 |
| Networking 测试极薄 | 🔴 高 | 仅 1 个 `.cpp`（`AngelscriptNetworkRPCTests.cpp`，17KB），多客户端运行时测试为零 |
| Editor 测试极薄 | 🔴 高 | 仅 1 个 `.cpp`（`AngelscriptSourceNavigationTests.cpp`，11.5KB） |
| **ASTEST_CREATE_ENGINE 滥用** | 🔴 高 | 被调用 ~1101 次，正确用法应仅 ~120 次（BEFORE_ALL 各一次）；112 个文件 470 处 TEST_METHOD 中冗余 reset，严重影响测试性能 |
| Settings 字段测试覆盖极低 | 🟡 中 | 33 个 `UAngelscriptSettings` 字段中仅 ~7 个有行为断言，`UAngelscriptTestSettings` / `UAngelscriptTestUserSettings` 零直接测试 |
| Examples 测试目录未融合 | 🟠 偏弱 | `AngelscriptTest/Examples/` 22 个文件未融合进功能测试体系，Timer/BehaviorTree 等覆盖率 0% |

### 3.4 对应 Plan

- `Plan_FullSuiteFailureTriage_20260502.md`（6 个失败，预计半天可全绿）
- `Plan_KnownTestFailureFixes.md`（Engine Core + Preprocessor import 断言，7 个失败）
- `Plan_PIEMapBasedTestExpansion.md`（PIE 地图测试，规划完整未执行）
- `Plan_MapBasedPIETestExpansion.md`（与上一个可能重复，需确认分工）
- `Plan_NetworkReplicationTests.md`（网络专项测试）
- `Plan_StaticJITUnitTests.md`（未启动）
- `Plan_TestEngineLifecycleClosure.md`（ASTEST_CREATE_ENGINE 滥用修复，3 个 Phase）
- `Plan_SettingsCoverageAndDX.md`（Settings 字段测试闭环）
- `Plan_ExamplesTestConsolidation.md`（Examples 测试融合，4 个阶段）

---

## §4 功能完整性维度

### 4.1 已闭环的功能

| 功能 | 状态 |
|------|------|
| Script Subsystem（World/GameInstance） | ✅ 已闭环（2026-04-22） |
| Network RPC 编译正例 | ✅ 已闭环 |
| FConsoleVariable bool/string | ✅ 已落地 |
| Script Examples（37 个 .as） | ✅ 超过 Hazelight 基线 |
| BlueprintImpact Commandlet | ✅ 已落地 |
| UHT 函数表生成 | ✅ 已落地 |

### 4.2 功能缺口

| 功能 | 严重度 | 代码证据 | 说明 |
|------|--------|---------|------|
| **C++ UInterface 自动绑定** | 🔴 P1 | `Bind_BlueprintType.cpp:1694-1699`（Phase 5 注释）；`BlueprintCallableReflectiveFallback.cpp:946-948` | `Bind_BlueprintType.cpp` 不遍历接口方法；反射回退显式拒绝 `CLASS_Interface` |
| **预处理器 import 测试断言** | 🟡 P2 | `AngelscriptPreprocessor.cpp:537-549`（功能已实现） | import 功能已完整实现，测试失败是断言问题，需重新诊断 |
| **FConsoleCommand workflow** | 🟡 P2 | `Plan_GlobalVariableAndCVarParity.md` | `FConsoleVariable` 已有，`FConsoleCommand` 仍缺 |
| **GAS helper surface** | 🟡 P2 | `Plugins/AngelscriptGAS/`（独立插件，默认禁用） | 相比 Hazelight 的 17 个 mixin + 4 个 function library，当前偏薄 |
| **LocalPlayer/Engine Subsystem 场景验证** | 🟡 P2 | `Plan_FunctionalGapClosure.md` 剩余部分 | WorldSubsystem/GameInstanceSubsystem 已闭环，LocalPlayer/Engine 待补 |
| **FInterfaceProperty 绑定** | 🟡 P2 | `Plan_CppInterfaceBinding.md` §缺口 2 | `TScriptInterface<T>` 属性不可读写 |
| **Math ScriptMixin 启用** | 🟡 P2 | `AngelscriptMathLibrary.h:329/415/489/539/589/659/728/804` | 8 处 mixin 因 namespace 调用形式冲突未启用，需迁移 ~80 个调用点 |
| **Debug 模式死代码路径** | 🟡 P2 | `AngelscriptDebugValue.h`；`ASClass.cpp:972/1392/1459/1489` | `WITH_PEROBJECT_DEBUGVALUES` 全仓 0 次使用；`FDebugValuePrototype` 完整实现被注释；`Object->Debug` 字段不存在 |
| **default 语句 AS 安全 trait** | 🟡 P2 | `Plan_DefaultStatementHazelightParity.md` | `unsafe_during_construction` / `defaults` 两个 AS 内核 trait 缺失 |
| **多客户端网络运行时测试** | 🟠 P3 | `AngelscriptNetworkRPCTests.cpp`（仅 1 个文件） | 编译正例有，运行时调度测试为零 |

### 4.3 对应 Plan

- `Plan_CppInterfaceBinding.md`（P1，未启动）
- `Plan_KnownTestFailureFixes.md` Phase 3（预处理器 import 断言修复）
- `Plan_GlobalVariableAndCVarParity.md`（FConsoleCommand 收尾）
- `Plan_FunctionalGapClosure.md`（LocalPlayer/Engine Subsystem）
- `Plan_MathScriptMixinReenablement.md`（Math mixin，5 个 Phase 详细规划）
- `Plan_AuraGAS_AngelscriptPort.md`（GAS 集成验证）
- `Plan_DebugValuesAndDebugModeHardening.md`（Debug 死代码清理 + 能力收口）
- `Plan_DefaultStatementHazelightParity.md`（default 语句 AS 安全 trait）

---

## §5 语言能力维度（AS 2.38 对齐）

### 5.1 当前语言能力状态

| 特性 | 状态 | 说明 |
|------|------|------|
| foreach | ⚠️ 有但不对齐 | 当前用 source-level lowering，2.38 用直接字节码；令牌名 `ttForeach` vs `ttForEach` 不一致 |
| 函数模板 | 🔴 未实现 | `asFUNC_TEMPLATE` 未移植 |
| Lambda / 匿名函数 | 🔴 未实现 | AS 2.38 新增，未移植 |
| using namespace | 🔴 未实现 | AS 2.38 新增 |
| 上下文 bool 转换 | 🔴 未实现 | `asEP_BOOL_CONVERSION_MODE` |
| 默认拷贝语义 | 🔴 未实现 | `asEP_DEFAULT_COPY_SEMANTICS` |
| 成员初始化模式 | 🔴 未实现 | `asEP_MEMBER_INIT_MODE` |
| JIT v2 接口 | 🔴 未实现 | AS 2.38 新 JIT API |
| Computed goto 优化 | 🔴 未实现 | 运行时性能优化 |
| 关键 Bug 修复回移 | 🔴 未执行 | context shutdown crash / try-catch stack pointer 等 |

### 5.2 ThirdParty 修改追踪

- 当前靠 `//[UE++]` 注释和 `AngelscriptChange.md` 手动追踪
- 无自动化 diff 工具，每次合入 2.38 功能时存在遗漏风险
- `Plan_ThirdPartyModificationTracking`（建议新建，P2）

### 5.3 对应 Plan

- `Plan_AS238ForeachPort.md`（P1，foreach 对齐）
- `Plan_AS238BugfixCherryPick.md`（P2，关键 Bug 修复）
- `Plan_FunctionTemplate.md`（P2）
- `Plan_AS238NonLambdaPort.md`（P2，TOptional/UStruct/BlueprintType）
- `Plan_AS238LambdaPort.md`（P3）
- `Plan_AS238UsingNamespacePort.md`（P3）
- `Plan_AS238BoolConversionPort.md`（P3）

---

## §6 工具链与开发体验维度

### 6.1 调试工具链

| 工具 | 状态 | 说明 |
|------|------|------|
| DebugServer V2（服务端） | ✅ 完整 | 30 种消息类型，TCP 监听，DAP 兼容协议 |
| DAP 客户端 / VS Code 扩展 | 🔴 不存在 | 调试服务器在运行但无任何客户端能连接 |
| Source Navigation | ✅ 有 | 从 UE 编辑器跳转到 .as 源文件 |
| Code Coverage | ✅ 有 | 逐行覆盖率 + HTML/JSON 报告 |

### 6.2 IDE 集成

| 工具 | 状态 | 说明 |
|------|------|------|
| VS Code 语言服务器 | 🔴 不存在 | 无自动补全、无悬停提示、无诊断 |
| IntelliSense 数据导出 | 🔴 不存在 | 注册的类型/函数/属性未导出为 LSP 格式 |
| 脚本 API 文档 | 🔴 不存在 | 148 个 Bind 文件暴露的 API 无面向脚本开发者的参考文档 |

### 6.3 构建与打包

| 工具 | 状态 | 说明 |
|------|------|------|
| `RunBuild.ps1` | ✅ 完整 | 标准化构建入口 |
| `RunTests.ps1` | ✅ 完整 | 标准化测试入口 |
| `BuildPlugin.ps1` | 🔴 不存在 | 无插件打包入口 |
| CI workflow | 🔴 不存在 | 无 `.github/workflows/` |

### 6.4 性能分析

| 工具 | 状态 | 说明 |
|------|------|------|
| Bind 注册耗时分析 | 🔴 不存在 | 无法知道哪个 Bind 最慢 |
| 性能基准框架 | 🔴 不存在 | 无可重复执行的基准测试 |
| 启动时间追踪 | ⚠️ 部分 | `AngelscriptEnumTableBaselineProbe` 已有雏形（working tree） |

### 6.5 对应 Plan

- `Plan_DebugAdapter.md`（P2，DAP 客户端 + VS Code 扩展）
- `Plan_PluginEngineeringHardening.md` Phase 2（BuildPlugin + CI）
- `Plan_ScriptAPIDocGeneration`（建议新建，P2）
- `Plan_PerformanceBenchmarkFramework`（建议新建，P2）
- `Plan_UhtArtifactExpansion.md`（P2，UHT 产物扩展）

---

## §7 架构质量维度

### 7.1 全局状态依赖

- `FAngelscriptEngine::Get()` + `CurrentWorldContext` 共 **325 处**命中，覆盖 57 个文件
- 热点：`AngelscriptClassGenerator.cpp`（81 处）、`AngelscriptBinds.cpp`（32 处）、`AngelscriptDebugServer.cpp`（23 处）
- 对应 Plan：`Plan_DeGlobalizationV2.md`（P3，长期）

### 7.2 Unity Build 冲突

- `bUseUnity = false` 已从 Build.cs 移除，但两个 Build.cs 均**未显式设置** `bUseUnity`，使用 UBT 隐性默认值
- Unity ON 状态下仍有 **490 个编译错误**（2026-04-30 快照）
- 主要来源：`_Private` namespace 同名 helper、CQTest 裸调 `TestNotNull` 等
- 对应 Plan：`Plan_UnityBuildConflictResolution.md`（P1，部分完成）

### 7.3 大文件问题

**Binds 目录超过 1000 行的文件（7 个）**：

| 文件 | 行数 | 备注 |
|------|------|------|
| `Bind_BlueprintType.cpp` | **2861** | 最大，含 5 处 WILL-EDIT 标记 |
| `Bind_TArray.cpp` | 1830 | |
| `Bind_Delegates.cpp` | 1442 | |
| `Bind_UStruct.cpp` | 1434 | 含 TODO:1417 |
| `Bind_FString.cpp` | 1421 | |
| `Bind_TMap.cpp` | 1350 | |
| `BlueprintCallableReflectiveFallback.cpp` | 1094 | |

**AngelscriptTest 目录超过 1000 行的文件（10 个）**：

| 文件 | 行数 |
|------|------|
| `AngelscriptFStringBindingsTests.cpp` | 2912 |
| `AngelscriptUObjectBindingsTests.cpp` | 2423 |
| `Template_ReflectionAccess.cpp` | 2178 |
| `AngelscriptTArrayBindingsTests.cpp` | 2159 |
| `AngelscriptTArraySyntaxCompatBindingsTests.cpp` | 1952 |
| `AngelscriptDebuggerSteppingTests.cpp` | 1260 |
| `AngelscriptClassBindingsTests.cpp` | 1187 |
| `AngelscriptMapBindingsTests.cpp` | 1126 |
| `AngelscriptDebuggerTestClient.cpp` | 1073 |
| `AngelscriptEngineIsolationTests.cpp` | 1071 |

**Runtime 核心大文件**：`AngelscriptEngine.cpp`（**6173 行**，最大单文件）

### 7.4 WILL-EDIT 标记（新发现）

**严重度**：🟡 中等

| 文件 | 行号 | 上下文 | 含义 |
|------|------|--------|------|
| `Bind_BlueprintType.cpp` | 1023 | UASClass 检查 | 运行时生成类型检查待优化 |
| `Bind_BlueprintType.cpp` | 1047 | NameArray 声明 | 函数列表初始化待重构 |
| `Bind_BlueprintType.cpp` | 1052 | GenerateFunctionList | 生成函数列表待优化 |
| `Bind_BlueprintType.cpp` | 1057 | FindFunctionByName | 按名称查找待优化 |
| `Bind_BlueprintType.cpp` | 1078 | TObjectRange 循环 | **并行化候选**（`WILL-EDIT?`，注释"Could this be parallel for?"） |
| `Bind_ConfigEnums.cpp` | 13 | 注释掉的 for 循环 | 未完成的代码段 |

### 7.5 Bind 层问题

| 问题 | 严重度 | 代码证据 | 说明 |
|------|--------|---------|------|
| Bind 注册 API 不统一 | 🟡 P3 | 多种风格并存 | `RegisterObjectMethod`/`METHODPR_TRIVIAL`/手写 lambda 等 |
| Bind 逐文件对齐审计未做 | 🟡 P2 | — | 124 个 Bind 文件与 Hazelight 的内容漂移未系统化盘点 |
| Bind Hack 未清理 | 🟠 P4 | `Bind_BlueprintEvent.cpp:908`；`Bind_FName.cpp:84`；`Bind_USceneComponent.cpp:172` | 3 处 HACK 标记 |
| `Bind_BlueprintType.cpp:156` | 🟡 P2 | `Bind_BlueprintType.cpp:156` | `CPF_TObjectPtr` 判断仍注释状态 |
| WILL-EDIT 标记 | 🟡 P3 | 见 §7.4 | 6 处未完成编辑标记，含并行化候选 |

### 7.6 废弃 API

| 文件 | 行号 | 废弃 API | 说明 |
|------|------|---------|------|
| `PrecompiledData.cpp` | 2713/2719/2721 | `FCrc::StrCrc_DEPRECATED` | StaticJIT 函数 ID 生成，为保持向后兼容 |
| `Bind_UInputSettings.cpp` | 13/19 | `PRAGMA_DISABLE_DEPRECATION_WARNINGS` | 正确配对包装，不产生警告 |

### 7.7 Debug 模式死代码（新发现）

**严重度**：🟡 中等

| 问题 | 代码证据 |
|------|---------|
| `WITH_PEROBJECT_DEBUGVALUES` 全仓 0 次使用 | `AngelscriptDebugValue.h` 定义处仅 1 次 |
| `FDebugValuePrototype` 完整实现被注释 | `AngelscriptDebugValue.h:44-133`（整段 `//` 注释） |
| `Object->Debug` 字段不存在 | `ASClass.cpp:972/1392/1459/1489`，`UObject` 无此字段 |
| `Helper_Reification.h` 绕过宏符号路径 | 手写展开条件而非使用 `WITH_AS_DEBUGVALUES` 符号 |
| 行回调做大量空操作 | `AngelscriptEngine.cpp:5732`，`Prototype->Instantiate` 始终 nullptr |

**对应 Plan**：`Plan_DebugValuesAndDebugModeHardening.md`（P2，三选一：删除/修复/显式标为实验性）

### 7.8 Plan 文档治理

| 状态 | 数量 | 说明 |
|------|------|------|
| 根目录 Plan 总数 | **78 份** | 含执行 Plan + 状态总览 + 索引 |
| 可立即归档 | ~5 份 | `Plan_DisabledTestReenablement`、`Plan_FunctionLibrariesCleanup` 等 |
| 近收尾 | ~4 份 | `Plan_FunctionalGapClosure`、`Plan_GlobalVariableAndCVarParity` 等 |
| 主题重叠 | ~4 份 | `Plan_AngelscriptUnitTestExpansion` 与 `Plan_TestCoverageExpansion`；`Plan_MapBasedPIETestExpansion` 与 `Plan_PIEMapBasedTestExpansion` |
| `Plan_OpportunityIndex.md` 数字过期 | ⚠️ | 自报 62 份，实际 78 份 |

---

## §8 优先级汇总与建议执行顺序

### 🔴 P0（本周，阻塞后续）

| # | 任务 | 工时 | 对应 Plan |
|---|------|------|-----------|
| 1 | **修复 6 个 live test failure**（Syntax Negative × 4 + BindConfig + Widget） | 0.5d | `Plan_FullSuiteFailureTriage_20260502.md` |
| 2 | **修复 Smoke suite 定义过期**（`CppTests.MultiEngine` 前缀替换） | 0.5h | `Plan_FullSuiteFailureTriage_20260502.md` P5.1 |
| 3 | **刷新 `Plan_OpportunityIndex.md` 数字基线**（62 → 78） | 0.5h | `Plan_TechnicalDebtRefresh.md` |
| 4 | **确认 PIE Plan 重复性**（`Plan_MapBasedPIETestExpansion` vs `Plan_PIEMapBasedTestExpansion`） | 0.5h | 手动核对 |

### 🟠 P1（本月，交付基线）

| # | 任务 | 工时 | 对应 Plan |
|---|------|------|-----------|
| 5 | **修复 Engine Core 生命周期测试**（3 个 `FAngelscriptEngineScope` 缺失） | 1d | `Plan_KnownTestFailureFixes.md` Phase 1 |
| 6 | **修复预处理器 import 测试断言**（功能已实现，断言需重新诊断） | 1d | `Plan_KnownTestFailureFixes.md` Phase 3 |
| 7 | **补齐插件交付基线**（README 完善 + `.uplugin` 元数据 + CI workflow 最小集） | 3d | `Plan_PluginEngineeringHardening.md` Phase 1-2 |
| 8 | **Unity Build 冲突清理**（490 个错误，按批次推进） | 5d | `Plan_UnityBuildConflictResolution.md` |
| 9 | **C++ UInterface 自动绑定**（`Bind_BlueprintType.cpp` 接口方法遍历） | 3d | `Plan_CppInterfaceBinding.md` |
| 10 | **ASTEST_CREATE_ENGINE 滥用修复 Phase 1**（AFTER_ALL double-reset，~124 个文件） | 1d | `Plan_TestEngineLifecycleClosure.md` Phase 1 |

### 🟡 P2（Q2 剩余，功能闭环）

| # | 任务 | 工时 | 对应 Plan |
|---|------|------|-----------|
| 11 | **foreach 实现对齐 2.38**（令牌名 + 编译策略） | 3d | `Plan_AS238ForeachPort.md` |
| 12 | **Math ScriptMixin 启用**（~80 个调用点迁移） | 3d | `Plan_MathScriptMixinReenablement.md` |
| 13 | **PIE 地图测试 M1**（4 张模板地图 + helper） | 3d | `Plan_PIEMapBasedTestExpansion.md` |
| 14 | **FConsoleCommand workflow 收尾** | 1d | `Plan_GlobalVariableAndCVarParity.md` |
| 15 | **LocalPlayer/Engine Subsystem 场景验证** | 1d | `Plan_FunctionalGapClosure.md` |
| 16 | **关键 Bug 修复回移**（context shutdown crash 等） | 2d | `Plan_AS238BugfixCherryPick.md` |
| 17 | **BuildPlugin.ps1 打包入口** | 1d | `Plan_PluginEngineeringHardening.md` Phase 2 |
| 18 | **Bind 逐文件对齐审计**（124 个文件 vs Hazelight） | 3d | `Plan_BindFileAlignmentAudit`（建议新建） |
| 19 | **Debug 死代码清理**（`WITH_PEROBJECT_DEBUGVALUES` 三选一处置） | 1d | `Plan_DebugValuesAndDebugModeHardening.md` |
| 20 | **Settings 字段测试闭环**（33 个字段，~15 个零覆盖） | 2d | `Plan_SettingsCoverageAndDX.md` |
| 21 | **ASTEST_CREATE_ENGINE 滥用修复 Phase 2**（TEST_METHOD 冗余 CREATE，112 个文件） | 2d | `Plan_TestEngineLifecycleClosure.md` Phase 2 |

### ⚪ P3（Q3，背景推进）

| # | 任务 | 对应 Plan |
|---|------|-----------|
| 22 | DAP 客户端 + VS Code 扩展 | `Plan_DebugAdapter.md` |
| 23 | 脚本 API 文档自动生成 | `Plan_ScriptAPIDocGeneration`（建议新建） |
| 24 | 性能基准框架 | `Plan_PerformanceBenchmarkFramework`（建议新建） |
| 25 | GAS / EnhancedInput helper surface 扩展 | `Plan_AuraGAS_AngelscriptPort.md` |
| 26 | 函数模板移植 | `Plan_FunctionTemplate.md` |
| 27 | 去全局化 V2 | `Plan_DeGlobalizationV2.md` |
| 28 | 插件仓库拆分执行 | `Plan_PluginRepositorySeparation.md` |
| 29 | WILL-EDIT 标记清理（含并行化评估） | `Plan_BindWillEditCleanup`（建议新建） |
| 30 | Examples 测试融合（22 个文件 → 功能测试矩阵） | `Plan_ExamplesTestConsolidation.md` |
| 31 | default 语句 AS 安全 trait 补足 | `Plan_DefaultStatementHazelightParity.md` |
| 32 | 大文件拆分（`Bind_BlueprintType.cpp` 2861 行等） | `Plan_LargeFileSplit`（建议新建） |

---

## §9 新发现的缺口（本次体检新增）

以下问题在现有 Plan 中未被明确覆盖，建议立项或归入现有 Plan：

| # | 问题 | 建议处理 | 优先级 |
|---|------|---------|--------|
| A | `ASTEST_CREATE_ENGINE()` 被滥用 ~1101 次，112 个文件 470 处 TEST_METHOD 冗余 reset，严重影响测试性能 | `Plan_TestEngineLifecycleClosure.md`（已有，未启动） | P1 |
| B | `All` suite 超时（> 900s），需拆分为 4 波子 suite | `Plan_FullSuiteFailureTriage_20260502.md` P5.2 | P2 |
| C | `WITH_PEROBJECT_DEBUGVALUES` 全仓 0 次使用，`FDebugValuePrototype` 完整实现被注释，`Object->Debug` 字段不存在 | `Plan_DebugValuesAndDebugModeHardening.md`（已有，未启动） | P2 |
| D | `Bind_BlueprintType.cpp:1078` 标注并行化候选（`WILL-EDIT?`），含 5 处 WILL-EDIT 标记 | 归入 `Plan_BindParallelization.md` 或新建 `Plan_BindWillEditCleanup` | P3 |
| E | `AngelscriptEngine.cpp` 达 **6173 行**，是最大单文件 | 归入 `Plan_LargeFileSplit`（建议新建） | P3 |
| F | `UAngelscriptSettings` 实际 **33 个字段**（非 28），`Plan_SettingsCoverageAndDX.md` 基线数字需更新 | 更新 `Plan_SettingsCoverageAndDX.md` 基线 | P2 |
| G | `Plan_MapBasedPIETestExpansion.md` 与 `Plan_PIEMapBasedTestExpansion.md` 可能重复 | 核对分工，合并或明确边界 | P0 |
| H | `AngelscriptPreprocessor.cpp:2509` 诊断文案缺介词（`"only allowed structs"` 应为 `"only allowed in structs"`） | 顺手修，无需独立 Plan | P3 |
| I | `UAssetManagerMixinLibrary` 中 3 个裸 `UFUNCTION()` dead code（`GetPrimaryAssetTypeInfo` 等） | 归入 `Plan_TechnicalDebtRefresh.md` | P3 |
| J | `Plan_ExamplesTestConsolidation.md` 中 Timer/BehaviorTree 等 22 个 Example 覆盖率 0% | `Plan_ExamplesTestConsolidation.md`（已有，未启动） | P3 |
| K | `default` 语句 `unsafe_during_construction` / `defaults` AS 内核 trait 缺失 | `Plan_DefaultStatementHazelightParity.md`（已有，未启动） | P3 |
| L | `AngelscriptGAS` 插件默认禁用（`EnabledByDefault: false`），GAS 功能对新用户不可见 | 评估是否应改为默认启用，或在 README 中明确说明 | P2 |

---

## §12 脚本特性对齐状态（Hazelight Parity）

> 来源：`Plan_HazelightScriptFeatureParity.md` 深度探索（2026-05-10）

### 12.1 已支持特性（实现完整）

| 特性 | 实现入口 | 测试覆盖 | 与 Hazelight delta |
|------|---------|---------|-------------------|
| `default` 语句 | `AngelscriptPreprocessor.cpp:3638` | 专用 10 + 顺带 22 = 32 个 | 无功能差距；缺 FName/枚举/结构体嵌套负例 |
| `asset` 字面量声明 | `AngelscriptPreprocessor.cpp:4187` | 专用 5 + 关联 1 = 6 个 | 无功能差距；缺多 asset 共存、非法语法负例；**无示例** |
| `DefaultComponent` / `RootComponent` / `Attach` | `AngelscriptPreprocessor.cpp:2237` | 专用 8 + 顺带 6 = 14 个 | 无功能差距；缺多层继承 OverrideComponent 专项 |
| UFUNCTION Specifier | `AngelscriptPreprocessor.cpp:1275` | ~8 个 | 支持 BlueprintCallable/Event/RPC 等；Haze 分支用 NetFunction/CrumbFunction |
| 网络 RPC（Server/Client/NetMulticast） | 预处理器 + ClassGenerator | 编译正例已有 | 运行时多客户端测试为零 |
| `foreach` (range-based for) | `AngelscriptPreprocessor.cpp` | 有测试 | 实现策略与 2.38 不对齐（source-level lowering vs 直接字节码） |

### 12.2 测试覆盖缺口汇总

| 特性 | 缺失测试类型 |
|------|------------|
| `default` | FName/枚举/结构体嵌套 default；非法属性名负例；类型不匹配负例 |
| `asset` | 多 asset 共存；跨模块引用；非法语法负例；**无任何示例脚本** |
| `DefaultComponent` | 多层继承 OverrideComponent；ShowOnActor + EditorOnly；深层 Attach 链（3+ 层） |
| UFUNCTION | `CallInEditor`/`Exec` 专项；`Meta(...)` 复杂组合 |
| 网络 RPC | 运行时多客户端调度；WithValidation 运行时验证 |

### 12.3 对应 Plan

- `Plan_HazelightScriptFeatureParity.md`（盘点文档，持续维护）
- `Plan_NetworkReplicationTests.md`（网络运行时测试）
- `Plan_AS238ForeachPort.md`（foreach 实现对齐）

---

## §13 CQTest 迁移状态

> 来源：`Plan_CQTestFullMigration.md` 探索（2026-05-10）

### 13.1 当前迁移进度（2026-04-30 快照）

| 类别 | 文件数 | 说明 |
|------|--------|------|
| 旧式 `IMPLEMENT_SIMPLE/COMPLEX` | **324** | 822 个宏实例，待迁移 |
| CQTest `TEST_CLASS_WITH_FLAGS` | **170** | 已转换 |
| 混合（两种共存） | **33** | 主要在 Bindings/ |
| `return false;` 行 | ~3013 | 需改为 `return;` |
| `*this,` 传参行 | ~1169 | 需改为 `*TestRunner,` |

### 13.2 宏兼容性问题

| 宏 | CQTest 不兼容点 | 使用文件数 |
|----|----------------|-----------|
| `ASTEST_BEGIN_NATIVE` | `AddError(...)` 裸调 + `return false;` | 少量 |
| `ASTEST_COMPILE_RUN_INT` | `*this` + `return false;` | ~10 |
| `ASTEST_BEGIN_SHARE_CLEAN` 等 | 无不兼容 | 131 |

### 13.3 影响评估

- 324 个旧式文件未迁移，与 `Plan_TestEngineLifecycleClosure.md` 的 ASTEST_CREATE_ENGINE 滥用问题相互叠加
- 旧式文件中的 `return false;` 模式在 CQTest 中语义不同，迁移时需逐一确认
- 混合文件（33 个）是最高风险区，两种风格共存容易引入隐性 bug

### 13.4 对应 Plan

- `Plan_CQTestFullMigration.md`（3 个 Phase，未启动）
- `Plan_TestEngineLifecycleClosure.md`（与迁移协同推进）

---

## §14 Static JIT 状态

> 来源：`Plan_StaticJITOfflineGeneration.md` 探索（2026-05-10）

### 14.1 当前状态

**Static JIT 已实现但实际未被使用**，根本原因是两遍编译流程：

1. Pass 1（生成）：`-as-generate-precompiled-data` 启动 → 生成 `.jit.cpp` → 强制退出
2. Pass 2（编译）：开发者手动把 `.jit.cpp` 纳入 C++ 模块重新编译
3. Pass 3（运行）：`AS_FORCE_LINK` 触发静态初始化器注册 JIT 指针

**没人愿意走这个流程，所以 JIT 长期空转。**

### 14.2 已有基础设施

| 组件 | 位置 | 状态 |
|------|------|------|
| 字节码→C++ 翻译器 | `AngelscriptBytecodes.cpp`（6500+ 行） | ✅ 完整 |
| `WriteOutputCode()` 内存模式 | `AngelscriptStaticJIT.cpp:3478` | ✅ 可复用 |
| `GenerateStaticJITSourceTextForTesting` | `AngelscriptStaticJIT.cpp:3743` | ✅ 可作 Commandlet 样板 |
| GUID 校验 | `AngelscriptEngine.cpp:1588-1594` | ✅ 有但仅单层 |
| ABI 偏移校验 | `AS_JIT_VERIFY_PROPERTY_OFFSETS` | ⚠️ Shipping 下关闭 |

### 14.3 主要缺口

| 缺口 | 影响 |
|------|------|
| 无 `UAngelscriptGenerateStaticJITCommandlet` | 开发者必须靠游戏闪退拿产物 |
| 无 ABI 指纹导出器 | C++ 结构体变化导致静默崩溃 |
| 无模块级精准作废 | JIT 命中率"全或无"，无法按文件/模块精准失效 |
| `AS_SKIP_JITTED_CODE` 在 Editor 下硬关 | Editor 无法使用 JIT |
| 无 Live Coding 钩子 | Live Coding 后 JIT 指针可能 ABI 失配 |

### 14.4 对应 Plan

- `Plan_StaticJITOfflineGeneration.md`（P2，详细规划，未启动）
- `Plan_AS238JITv2Port.md`（P3，2.38 JIT v2 接口）
- `Plan_StaticJITUnitTests.md`（P2，专项测试）

---

## §15 AngelscriptGAS 插件状态

> 来源：代码探索（2026-05-10）

### 15.1 插件基本信息

| 项目 | 值 |
|------|-----|
| 位置 | `Plugins/AngelscriptGAS/` |
| 版本 | 1.0 |
| 默认状态 | **禁用**（`EnabledByDefault: false`） |
| 依赖 | `Angelscript` + `GameplayAbilities` |
| 模块 | `AngelscriptGAS`（Runtime）+ `AngelscriptGASTest`（Editor） |

### 15.2 Public API 表面（11 个头文件）

| 文件 | 功能 |
|------|------|
| `AngelscriptGASAbility.h` | AS 可继承的 GameplayAbility 基类（含 K2_ExecuteGameplayCue_Actor 等 9 个 UFUNCTION） |
| `AngelscriptAbilitySystemComponent.h` | AS 可继承的 ASC |
| `AngelscriptGASCharacter.h` | AS 可继承的 GAS Character 基类 |
| `AngelscriptGASPawn.h` | AS 可继承的 GAS Pawn |
| `AngelscriptGASActor.h` | AS 可继承的 GAS Actor |
| `AngelscriptAttributeSet.h` | AS 可继承的 AttributeSet |
| `AngelscriptAbilityTask.h` | AS 可继承的 AbilityTask |
| `AngelscriptAbilityTaskLibrary.h` | AbilityTask 工具库 |
| `AngelscriptAbilityAsyncLibrary.h` | 异步 Ability 工具库 |
| `AngelscriptGameplayCueUtils.h` | GameplayCue 工具 |
| `AngelscriptGameplayEffectUtils.h` | GameplayEffect 工具 |

### 15.3 测试覆盖

- 测试文件：仅 1 个（`AngelscriptGASTestModule.cpp`）
- 覆盖范围：极薄，无 Ability/Attribute/Effect/Task 专项测试

### 15.4 不足点

1. **默认禁用**：新用户不会自动获得 GAS 能力，需要手动启用
2. **测试极薄**：11 个 Public API 仅 1 个测试文件
3. **无示例脚本**：`Script/Examples/` 中无 GAS 相关示例
4. **helper surface 薄**：相比 Hazelight 的 17 个 mixin + 4 个 function library，当前偏薄

### 15.5 对应 Plan

- `Plan_AuraGAS_AngelscriptPort.md`（GAS 集成验证，P3）
- `Plan_GASIntegrationTests`（建议新建，P1）

---

## §16 Wiki 文档体系状态

> 来源：代码探索（2026-05-10）

### 16.1 Wiki 结构

```
Wiki/
├── docs/
│   ├── en/（英文）
│   │   ├── architecture/（class-struct-generation、hot-reload-debugging、module-layout、runtime-core、uht-function-tables）
│   │   ├── comparison/（fork-strategy、hazelight-baseline、known-gaps）
│   │   ├── cpp-bindings/（automatic-bindings、mixin-libraries、overview、precompiled-data）
│   │   ├── guides/（build-test、setup、vscode-debugging、workflow）
│   │   ├── internals/（binding-surface、compilation-pipeline）
│   │   └── scripting/
│   └── zh/（中文，结构同 en）
```

### 16.2 不足点

1. **Wiki 目录被 `.gitignore` 排除**，不在版本控制中
2. **vscode-debugging 指南存在**但 DAP 客户端尚未实现，内容可能超前
3. **known-gaps 文档**与 `Plan_HazelightCapabilityGap.md` 可能重复，需确认分工
4. **无 CI 自动发布**：Wiki 内容更新无自动化流程

### 16.3 对应 Plan

- `Plan_PluginRepositorySeparation.md`（Wiki 独立为 `AngelscriptWiki` 仓库）
- `Plan_PluginEngineeringHardening.md`（文档入口补全）

---

## §17 Documents/Guides 体系状态

> 来源：代码探索（2026-05-10）

### 17.1 当前 16 个 Guides 文件

| 文件 | 用途 | 状态 |
|------|------|------|
| `Build.md` | 构建指南 | ✅ 完整 |
| `Test.md` | 测试指南 | ✅ 完整 |
| `TestCatalog.md` | 测试目录（275/275 基线） | ✅ 完整 |
| `TestConventions.md` | 测试规范（分层、命名、宏） | ✅ 完整 |
| `TechnicalDebtInventory.md` | 技术债实时盘点 | ✅ 持续维护 |
| `BindGapAuditMatrix.md` | Bind 差距审计矩阵（9 个文件） | ✅ 有内容 |
| `GlobalStateContainmentMatrix.md` | 全局状态包含矩阵 | ✅ 有内容 |
| `AngelscriptForkStrategy.md` | AS 分叉策略 | ✅ 完整 |
| `UE_Search_Guide.md` | UE 搜索指南 | ✅ 完整 |
| `ASSDK_Fork_Differences.md` | ASSDK 分叉差异 | ✅ 有内容 |
| `LearningTrace.md` | 学习追踪 | ✅ 有内容 |
| `TestFixSummary_20260430.md` | 测试修复总结 | ✅ 历史快照 |
| `TestMacroStatus.md` | 测试宏状态 | ✅ 有内容 |
| `TestPerformance.md` | 测试性能 | ✅ 有内容 |
| `BlueprintTypeBindingsOptimization.md` | 蓝图类型绑定优化 | ✅ 有内容 |
| `Test_Screenshot.md` | 测试截图指南 | ✅ 有内容 |

### 17.2 缺失的 Guides

| 缺失文件 | 说明 | 对应 Plan |
|---------|------|-----------|
| `Compatibility.md` | 兼容矩阵（UE 版本/平台） | `Plan_PluginEngineeringHardening.md` Phase 1 |
| `Release.md` | 发布流程 | 同上 |
| `Licensing.md` | 许可与第三方来源 | 同上 Phase 4 |
| `Settings.md` | Settings 字段清单 | `Plan_SettingsCoverageAndDX.md` |
| `GAS.md` | GAS 集成使用指南 | 建议新建 |
| `Debugging.md` | 调试能力地图（构建矩阵解读） | `Plan_DebugValuesAndDebugModeHardening.md` |

---

## §10 本快照的后续维护

| 条件 | 动作 |
|------|------|
| 每月第一周 | 重跑 §3.1 数字实测表，更新 live full-suite 数字 |
| 有 Plan 完成 | 更新对应维度的状态标记 |
| 新增 Plan | 先填 §8 优先级表，避免 Plan 数量继续膨胀 |
| 每季度 | 刷新本快照为 `Plan_HealthCheck_<YYYY>Q<N>.md` |

---

## §11 与现有文档的关系

| 文档 | 关系 |
|------|------|
| `Plan_StatusPriorityRoadmap.md` | 本文是其事实补充，不替代其 Phase 结构 |
| `Plan_StatusSnapshot_2026Q2.md` | 本文是其 2026-05-10 更新版，数字更新 |
| `Plan_OpportunityIndex.md` | 本文发现的新缺口应回写到该索引 |
| `TechnicalDebtInventory.md` | 本文 §7 架构质量维度与其保持一致 |
| `Plan_HealthCheck_2026Q2_DeepDive.md` | 本文的深度代码探索补充，含具体文件路径和行号证据 |
| `Plan_HazelightScriptFeatureParity.md` | 本文 §12 脚本特性对齐状态的来源文档 |
| `Plan_CQTestFullMigration.md` | 本文 §13 CQTest 迁移状态的来源文档 |
| `Plan_StaticJITOfflineGeneration.md` | 本文 §14 Static JIT 状态的来源文档 |
