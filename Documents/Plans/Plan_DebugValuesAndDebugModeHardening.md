# Angelscript 插件 Debug 模式能力收口与 Per-Object DebugValues 清理计划

## 背景与目标

### 触发问题

`Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptDebugValue.h` 顶部声明了两个互相叠加的构建宏：

```cpp
#define WITH_PEROBJECT_DEBUGVALUES (!UE_BUILD_TEST && !UE_BUILD_SHIPPING)
#define WITH_AS_DEBUGVALUES WITH_PEROBJECT_DEBUGVALUES && UE_BUILD_DEBUG
```

这两个宏和 `AngelscriptEngine.h` 中的两兄弟宏一起，构成了 AS 插件的"调试/观测构建矩阵"：

```cpp
#define WITH_AS_DEBUGSERVER (!UE_BUILD_TEST && !UE_BUILD_SHIPPING)
#define WITH_AS_COVERAGE    WITH_AS_DEBUGSERVER
```

### 当前事实状态（通过源码扫描确认）

1. **`WITH_PEROBJECT_DEBUGVALUES` 实际是一个未接入的宏。**
   - 全仓搜索 `WITH_PEROBJECT_DEBUGVALUES` 只在 `AngelscriptDebugValue.h` 定义处出现 1 次，**所有使用点均 0 次**。该宏要么是历史残留，要么是"计划引入但从未接入"的开关。

2. **`WITH_AS_DEBUGVALUES` 本体是一条"半死"的数据路径，不是正在工作的特性。**
   - `FDebugValuePrototype` 的非占位实现（第 44–133 行）是**一整段被 `//` 注释掉的代码块**；当前启用分支是第 136–146 行的占位版本，`Create` 直接返回 `nullptr`、`Reset` 空实现。
   - `Helper_Reification.h` 自身的 `#if WITH_AS_DEBUGVALUES` 在文件顶部被注释，转而用展开后的原始条件 `#if ((!UE_BUILD_TEST && !UE_BUILD_SHIPPING) && UE_BUILD_DEBUG)`（见 L5–L6），等价于手写宏但绕过了 `AngelscriptDebugValue.h` 的符号路径——已经是两次偏离。
   - `ASClass.cpp` 在 `WITH_AS_DEBUGVALUES` 包裹下引用 `Object->Debug` 成员（L972/L1392/L1459/L1489），但 **`UObject` 基类在本仓库里并没有 `Debug` 字段**（全仓搜索确认）。这些代码只有在 `UE_BUILD_DEBUG=1 && !UE_BUILD_TEST && !UE_BUILD_SHIPPING` 时才参与编译；而 UE 官方工作流几乎从不启用 `UE_BUILD_DEBUG`，所以这条路径**在实际 CI/本地构建里永远不走编译器前端**，问题被静默掩盖。
   - `AngelscriptEngine.cpp::UpdateLineCallbackState()`（L5732）仍把 `WITH_AS_DEBUGVALUES` 当作"强制 always-run line callback"的触发源之一；线回调内部（L5755–5810）则会按照 `FAngelscriptDebugStack` 逐帧物化 `FDebugValues* Variables`，而 `Prototype->Instantiate` 始终 `nullptr`——行回调会做一大堆空操作仅为了证明"曾经想做 per-frame watch 快照"。
   - `Binds/Bind_TArray.cpp`、`Binds/Helper_PODType.h`、`Binds/Helper_CppType.h`、`Binds/Bind_UEnum.cpp` 等还在为 `CreateDebugValue` 提供非默认实现（接入 `ReifyDebugValueTemplate`）。如果 `WITH_AS_DEBUGVALUES=0`（默认），这些实现要么产出 nullptr，要么等价于 virtual 基类的 no-op 版本。**生产态下 per-object debug value 是 "dead data"**。

3. **当前真正工作的"AS Debug 能力"来自两条其它路径，不是 `WITH_AS_DEBUGVALUES`。**
   - `WITH_AS_DEBUGSERVER`：DAP 兼容调试服务器（`Debugging/AngelscriptDebugServer.*`），`DebugAdapterVersion=2`，支持 `Diagnostics / CallStack / Pause / GoToDefinition / SetDataBreakpoints / BreakOptions` 等，已是真正主线。
   - `WITH_AS_COVERAGE`：基于 line callback 的行级覆盖率（`CodeCoverage/AngelscriptCodeCoverage.*`）。
   - 两者默认在 `!UE_BUILD_TEST && !UE_BUILD_SHIPPING` 开启，也就是 Development/Editor 全量开启，不受 `UE_BUILD_DEBUG` 限制。

4. **脚本侧运行时"断言/断点/栈取"能力已较完整，但缺乏一张"调试能力地图"。**
   - `Bind_Debugging.cpp` 暴露 `DebugBreak()` / `ensure(...)` / `ensureAlways(...)` / `check(...)` / `throw(...)` / `GetAngelscriptCallstack()` / `FormatAngelscriptCallstack()`。
   - `FAngelscriptEngine::AngelscriptLoopDetectionCallback` 结合 `EditorMaximumScriptExecutionTime` 形成死循环保护；`FAngelscriptExcludeScopeFromLoopTimeout` 提供 RAII 豁免。
   - 这些能力散落在 Runtime 各处，`Documents/Guides/` 下**不存在**一份"AS Debug 模式能力清单 / 构建矩阵解读"文档。对外协作者无从快速理解"Debug 构建下多了哪些能力、要不要开、怎么开"。

5. **调试配置当前不在 Project Settings 面上。**
   - `DebugServer` 端口/启停、`CodeCoverage` 开关部分在 `UAngelscriptTestSettings`，但"运行时调试服务器"本身的开关是硬编码 `WITH_AS_DEBUGSERVER` + 启动逻辑。
   - `EditorMaximumScriptExecutionTime` 在 `UAngelscriptSettings` 中是唯一可见的调试相关字段（且 `Plan_SettingsCoverageAndDX.md` 已登记为待补测项）。
   - "DebugValue / Watch 快照 / per-object 诊断" 类能力在设置面完全不可见。

### 目标

本计划不是"再做一套 debugger"，而是把当前"构建矩阵 × 实际可用能力 × 死代码 × 设置面可见性"这一纵面做一次**收口 + 去死枝 + 方向探索**：

1. **收口事实**：用一份明确文档说明 `WITH_PEROBJECT_DEBUGVALUES / WITH_AS_DEBUGVALUES / WITH_AS_DEBUGSERVER / WITH_AS_COVERAGE / DO_CHECK / UE_BUILD_DEBUG` 的含义、默认值、在当前仓库中的真实接通状态。
2. **清理死枝**：`WITH_PEROBJECT_DEBUGVALUES` 未接入、`FDebugValuePrototype` 的完整实现被注释、`Object->Debug` 字段不存在——必须三选一做出决定：**删除、修复、或显式 "保留但标为实验性并加守护"**，而不是让代码继续以"未编译就是正确"的方式存在。
3. **探索能力方向**：给出一组面向未来的 Debug 模式增强方向（Watch / Timeline / 内存探针 / Hot Attach / 编辑器覆盖层等），并按"现状可达性、对架构影响、与 DebugServer V2 的关系"排序。
4. **推动设置面可见**：把可开关的调试能力（port、enable、verbose 级别、loop 阈值组、watch 采样率等）沉淀到 `UAngelscriptSettings` 或专用 `DeveloperSettings`，与 `Plan_SettingsCoverageAndDX.md` 的候选池合流。

### 非目标

- 不在本计划落地一个"重写 per-object debug value 系统"的大改——只做死枝处置 + 方向评估。
- 不修改 DAP 协议字段或 DebugServer 协议版本（由 `Plan_ASDebuggerUnitTest.md` / `Plan_DebugAdapter.md` 主线承接）。
- 不引入新的 ThirdParty AngelScript 补丁；AS 引擎侧的 `#if WITH_AS_DEBUGSERVER` 分支只做"读代码、验证路径"，不动手。
- 不替代 `Plan_SettingsCoverageAndDX.md`；本计划只向其 **P5.3 候选池** 贡献具体字段建议。

### 与既有计划的关系

- `Plan_StatusPriorityRoadmap.md`：补充 "当前事实状态快照" 中未登记的死代码条目；对齐优先级为"交付基线 / 插件化硬化"下面的一项工程债。
- `Plan_SettingsCoverageAndDX.md`：向其 P5.3 "建议性新增字段" 追加 debug 侧候选。
- `Plan_ASDebuggerUnitTest.md` / `Plan_DebugAdapter.md`：DebugServer 协议测试与 DAP 实现不在本计划范围，只在"Debug 能力地图"文档里引用其进度作为快照。
- `Plan_PluginEngineeringHardening.md`：死代码清理属于工程硬化。
- `Plan_StaticJITOfflineGeneration.md` / `Plan_StaticJITUnitTests.md`：JIT 与 Debug 存在相互影响（`AS_SKIP_JITTED_CODE`、`AS_JIT_VERIFY_PROPERTY_OFFSETS`），本计划会把这部分宏也纳入"Debug 构建矩阵"文档，但不动 JIT 实现。

## 范围与边界

### 在范围内

- `AngelscriptRuntime/Core/AngelscriptDebugValue.h`（宏定义与 prototype 占位）
- `AngelscriptRuntime/Core/Helper_Reification.h`（REIFIED_TYPES / 条件判断与宏路径统一）
- `AngelscriptRuntime/ClassGenerator/ASClass.cpp` 中 `#if WITH_AS_DEBUGVALUES` 的 4 处使用
- `AngelscriptRuntime/ClassGenerator/AngelscriptClassGenerator.cpp` 中 `CreateDebugValuePrototype` 的 2 处调用与本体实现
- `AngelscriptRuntime/Core/AngelscriptEngine.cpp` 中 `UpdateLineCallbackState` / `AngelscriptLineCallback` / `FAngelscriptDebugFrame::~FAngelscriptDebugFrame` 与 `WITH_AS_DEBUGVALUES` 相关的 7 处
- `AngelscriptRuntime/Binds/{Bind_TArray, Helper_PODType, Helper_CppType, Bind_UEnum}` 中 `CreateDebugValue` 提供方一端
- `AngelscriptRuntime/Binds/Bind_Debugging.cpp`（能力地图文档需引用，不改代码）
- 新增 `Documents/Guides/DebugMode.md`（能力地图 + 构建矩阵）
- 新增 `Documents/Knowledges/ZH/Note_DebugValuesFindings.md`（死枝评估记录，供后续回溯）
- 新增 `AngelscriptTest/Core/AngelscriptDebugBuildMatrixTests.cpp`（把宏状态固化到自动化）

### 不在范围内

- DebugServer 协议字段扩展；DAP 客户端（VSCode 扩展侧）
- JIT 指令/验证逻辑；AS ThirdParty 代码修改
- CodeCoverage 的覆盖维度扩展
- 运行时 Profiling（Unreal Insights / trace）接入——这属于独立方向，不与 debug 模式混
- 远程调试中转/多客户端广播（已有计划或无计划都不在此处开新战线）

## 当前事实对照表

> 本表作为 Phase 1 产出 `Documents/Guides/DebugMode.md` 的正文源数据，不是装饰。

### 构建宏矩阵

| 宏 | 定义位置 | 默认值 | 真实控制的能力 | 实际接通状态 |
|---|---|---|---|---|
| `WITH_AS_DEBUGSERVER` | `AngelscriptEngine.h:16` | `!UE_BUILD_TEST && !UE_BUILD_SHIPPING` | DAP 调试服务器 / 数据断点 / CallStack 协议 | ✅ 正常接通；Dev 全量 |
| `WITH_AS_COVERAGE` | `AngelscriptEngine.h:20` | 同 `WITH_AS_DEBUGSERVER` | 行级覆盖率、`CoverageExcludePatterns` 过滤 | ✅ 正常接通 |
| `WITH_AS_DEBUGVALUES` | `AngelscriptDebugValue.h:6` | `(!UE_BUILD_TEST && !UE_BUILD_SHIPPING) && UE_BUILD_DEBUG` | Per-object 变量快照 / per-frame 局部变量物化 | ❌ **Prototype 本体被注释**；`Object->Debug` 字段不存在；实际路径未被编译器验证 |
| `WITH_PEROBJECT_DEBUGVALUES` | `AngelscriptDebugValue.h:5` | `!UE_BUILD_TEST && !UE_BUILD_SHIPPING` | —— | ❌ **全仓 0 处使用**，纯死宏 |
| `AS_CAN_GENERATE_JIT` | `StaticJITConfig.h` | Win/Linux 默认 on | JIT 生成能力 | ✅ |
| `AS_SKIP_JITTED_CODE` | `StaticJITConfig.h` | `WITH_EDITOR` | 编辑器绕过 JIT 走解释器（便于调试） | ✅ |
| `AS_JIT_VERIFY_PROPERTY_OFFSETS` | `StaticJITConfig.h` | `!UE_BUILD_SHIPPING && !UE_BUILD_TEST` | JIT 生成代码的属性偏移校验 | ✅ |
| `DO_CHECK` | UE 引擎 | 非 Shipping 默认 on | `check()` / `ensure()` bind 的内部开关 | ✅ |

### 脚本侧 Debug API

| 绑定 | 位置 | 控制宏 | 现有测试 |
|---|---|---|---|
| `void DebugBreak()` | `Bind_Debugging.cpp:81` | `DO_CHECK` + `WITH_AS_DEBUGSERVER`（watch 过滤） | 🟡 间接（ensure 系列） |
| `bool ensure / ensureAlways` | 同上 | `DO_CHECK` | ✅ 已有 |
| `void check` | 同上 | `DO_CHECK` | ✅ 已有 |
| `void throw(FString)` | `Bind_Debugging.cpp:206` | — | ❌ 未专项测试 |
| `TArray<FString> GetAngelscriptCallstack()` | `Bind_Debugging.cpp:212` | — | ❌ 未专项测试 |
| `FString FormatAngelscriptCallstack()` | `Bind_Debugging.cpp:218` | — | ❌ 未专项测试 |
| `AngelscriptDisableDebugBreaks/Enable` | `Bind_Debugging.cpp:33/38` | — | ❌ 未专项测试（`AreAngelscriptDebugBreaksEnabledForTesting` hook 已备好） |

### Per-Object DebugValue 死枝清单（待处置）

| 文件 | 行 | 问题 |
|---|---|---|
| `Core/AngelscriptDebugValue.h` | 5 | `WITH_PEROBJECT_DEBUGVALUES` 定义但 0 处使用 |
| `Core/AngelscriptDebugValue.h` | 43–133 | `FDebugValuePrototype` 完整实现被整块注释；对照的占位版是 nullptr-return |
| `Core/Helper_Reification.h` | 5–6 | `#if WITH_AS_DEBUGVALUES` 被注释，用展开后的原始宏代替，偏离符号路径 |
| `ClassGenerator/ASClass.cpp` | 972 | 引用不存在的 `Object->Debug` 字段（仅在 `UE_BUILD_DEBUG` 下才编译，被静默跳过） |
| `ClassGenerator/ASClass.cpp` | 1392/1459/1489 | 同上，写入 `Object->Debug` |
| `ClassGenerator/AngelscriptClassGenerator.cpp` | 3701/4310 | `CreateDebugValuePrototype` 被 `#if WITH_AS_DEBUGVALUES` 包住调用；本体实现写入 `Class->DebugValues` 成员——`DebugValues` 成员存在但被静默填空 |
| `Core/AngelscriptEngine.cpp` | 5732–5735 | `WITH_AS_DEBUGVALUES` 强制行回调 always-run，但下游数据结构是空的 |
| `Core/AngelscriptEngine.cpp` | 5755–5810 | 行回调中 per-frame 变量物化全为 `Instantiate(...) == nullptr`，做了无效工作 |
| `Core/AngelscriptEngine.h` | 493–510 | `FAngelscriptDebugFrame / FAngelscriptDebugStack` 结构继续持有 `Variables / Prototype`，但全链路产不出值 |
| `Binds/Bind_TArray.cpp` / `Helper_PODType.h` / `Helper_CppType.h` / `Bind_UEnum.cpp` | `CreateDebugValue` | 实现存在，生产态下调用路径未真正走到 |
| `AngelscriptTest/AngelScriptSDK/AngelscriptDebugReificationTests.cpp` | 42–92 | 是唯一一个分裂成 `#if WITH_AS_DEBUGVALUES` 两支的测试；当前 CI 走的是 **else 分支**——测试本身是对的，但在 CI 里只验证了 "fallback 全部回 Unknown" 这一侧 |

## 分阶段执行计划

### Phase 1 — 能力地图与构建矩阵文档（前置、纯文档）

> 目标：让任何新同学 / 外部协作者都能用 10 分钟读懂 "当前 AS debug 模式下真的有什么、没什么"。

- [ ] **P1.1** 新增 `Documents/Guides/DebugMode.md`
  - 小节：构建矩阵（宏表，直接引入本计划对照表）、DebugServer/CodeCoverage/LoopDetection 能力摘要、脚本侧 `Bind_Debugging` API 清单、常见构建组合（Editor/Dev/Shipping/Test/UE_BUILD_DEBUG）下**可用能力差异矩阵**。
  - 显式声明 `WITH_PEROBJECT_DEBUGVALUES` / `WITH_AS_DEBUGVALUES` 在 2026 Q2 的状态是 "死枝待处置"，并链到 P2 的决定。
  - 链接 `Plan_ASDebuggerUnitTest.md` / `Plan_DebugAdapter.md` / `Plan_SettingsCoverageAndDX.md`。
- [ ] **P1.2** 新增 `Documents/Knowledges/ZH/Note_DebugValuesFindings.md`
  - 把本计划"Per-Object DebugValue 死枝清单"固化成可追溯记录，便于未来回顾"当时做出 drop/fix/gate 决定的依据"。
- [ ] **P1.3** 新增 `AngelscriptTest/Core/AngelscriptDebugBuildMatrixTests.cpp`
  - 一组"构建宏状态固化"的轻测试：用 `#if WITH_AS_DEBUGSERVER` / `WITH_AS_COVERAGE` / `WITH_AS_DEBUGVALUES` 直接 `TestTrue/False` 编译期常量；断言预期矩阵（例如默认构建下 DebugServer=on, DebugValues=off）。一旦有人误开/误关宏 CI 立刻报。
  - 用法类比 `AngelscriptEditorModuleProjectSettingsLifecycleTest` 的防回归思路。

### Phase 2 — Per-Object DebugValues 死枝处置（三选一 + 一条主线）

> 目标：在**不破坏当前行为**前提下，把"半死"状态明确收口。决策在 P2.0 做；后续子项根据决策走。

- [ ] **P2.0** 在 `Note_DebugValuesFindings.md` 中写入最终决定，三选一：
  - **选项 A — Drop（推荐默认）**：删除 `WITH_PEROBJECT_DEBUGVALUES`、收紧 `WITH_AS_DEBUGVALUES` 使用点到 0，删除 `FDebugValuePrototype` 占位、`Helper_Reification.h` 相关模板、`ASClass.cpp` 对 `Object->Debug` 的 4 处引用、`AngelscriptEngine.cpp` 的 3 处包裹块、各 Bind 侧 `CreateDebugValue` override。
    - 优点：一次清零，后续 debug 增强从 DebugServer/DAP 主线走；减少认知负担。
    - 代价：失去一套"per-object 变量快照"的基础设施骨架；未来真要做时需要重建（但当前骨架本身也已不可用，代价真实上不高）。
  - **选项 B — Fix**：按注释掉的 `FDebugValuePrototype::Instantiate` 重新激活实现；给 `UObject` 加 `FDebugValues* Debug` 字段**仅在 UE_BUILD_DEBUG 下**（引擎侧补丁，**不推荐**，与项目"不改引擎"边界冲突）。
  - **选项 C — Gate + Experimental**：保留代码但加显式 `#error "WITH_AS_DEBUGVALUES requires per-object Debug field — currently unsupported, see DebugMode.md"` 守护，防止有人误开；同时不清理死代码。
    - 优点：保留未来重建的基础 sketches。
    - 代价：持续技术债，`AngelscriptDebugReificationTests` 的 `#if` 分支仍然半挂。

- **若选 A（Drop）** — 以下为推荐落地步骤：
  - [ ] **P2A.1** 删除 `AngelscriptDebugValue.h` 中 `WITH_PEROBJECT_DEBUGVALUES` 宏定义；保留 `FASDebugValue / TDebug / FDebugValueHandle / FDebugValuePrototype` 类型声明但不再被 `#if` 守护（它们无害，且 `FDebugValuePrototype::Create` 已是 nullptr-op）。
  - [ ] **P2A.2** 删除 `WITH_AS_DEBUGVALUES` 宏定义，以及所有 `#if WITH_AS_DEBUGVALUES` 使用点（共 **15+ 处**，见死枝清单）。
  - [ ] **P2A.3** 清理 `FAngelscriptEngine::FAngelscriptDebugFrame` 中 `Variables / Prototype` 字段；`AngelscriptLineCallback` 内对应的 per-frame 物化块直接删除。
  - [ ] **P2A.4** 清理 Bind 侧 `CreateDebugValue` virtual 接口（`AngelscriptType.h:286/550` 的默认 no-op override 与 4 个 Bind 文件的实现）。
  - [ ] **P2A.5** 改写 `AngelscriptDebugReificationTests.cpp`：删除 `#if WITH_AS_DEBUGVALUES` 分支，改为只验证"所有类型都收敛到 Unknown 且 `ReifyDebugValueTemplate` 安全可调用" —— 保留测试作为"reification API 契约守护"。
  - [ ] **P2A.6** 更新 `Plan_StatusPriorityRoadmap.md` 的"当前事实状态快照"追加一条："per-object debug value dead branch 已移除（2026-QN）"。
  - [ ] **P2A.7** 在 `DebugMode.md` 同步更新构建矩阵表。

- **若选 C（Gate）** — 最小化工作量：
  - [ ] **P2C.1** 在 `AngelscriptDebugValue.h` 的 `WITH_AS_DEBUGVALUES` 定义后加 `#if WITH_AS_DEBUGVALUES` → `#error "..."`。
  - [ ] **P2C.2** `DebugMode.md` 显式标 "Experimental / 不支持启用"。
  - [ ] **P2C.3** 不做任何代码清理。

- **选 B（Fix）不推荐** — 若真要做，须单独开 `Plan_DebugValuesRevival.md`，本计划不展开。

### Phase 3 — 现有 Debug 能力的测试补齐

> 目标：把 `Bind_Debugging` 暴露的 API、LoopDetection 与 `FAngelscriptExcludeScopeFromLoopTimeout` 纳入测试网。与 `Plan_SettingsCoverageAndDX.md` P3.3 有重叠，本 Phase 专注 API 契约侧，Settings 侧归那边。

- [ ] **P3.1** 新增 `AngelscriptTest/Debugger/AngelscriptDebugApiTests.cpp`
  - `GetAngelscriptCallstack()`：构造有意的 3 层脚本调用栈，断言返回的 TArray 行数、每行包含函数名。
  - `FormatAngelscriptCallstack()`：断言其输出格式稳定（或断言关键字段）。
  - `throw(FString)`：在脚本里调用 `throw`，捕获 `FAngelscriptException` 或断言 `Context->GetExceptionString()` 包含预期内容。
  - `AngelscriptDisableDebugBreaks / AngelscriptEnableDebugBreaks` + `AreAngelscriptDebugBreaksEnabledForTesting`：往返断言 + 确保 `ensure(false)` 在 disable 下不触发 debug break。
  - `ensure(false)` 的去重行为：`ASShouldBreakEnsure` 在同一 frame 内对相同位置只 pop 一次；`GEndPlayMapCount` 递增后重新 pop。
- [ ] **P3.2** 新增 `AngelscriptTest/Core/AngelscriptLoopDetectionTests.cpp`
  - 触发 `AngelscriptLoopDetectionCallback`：用 `EditorMaximumScriptExecutionTime = 0.05f` + 脚本 busy-loop，断言 `Context->SetException("Script function took too long...")`。
  - `FAngelscriptExcludeScopeFromLoopTimeout` RAII：在长 C++ scope 内执行短脚本，断言不触发超时；退出后阈值恢复。
  - `m_loopDetectionExclusionCounter` 嵌套正确性：嵌套 2 层后 counter 能正确回到 0。
- [ ] **P3.3** 复核 `AngelscriptDebuggerDatabaseTests` 中对 `UseAngelscriptHaze` 与 `bDeprecateStaticClass` 等 mirror 断言，看是否需要补 `WITH_AS_DEBUGSERVER` 关闭态下的 null-safe 断言（Phase 1 的构建矩阵测试会成为守护前置，这里只做增量）。

### Phase 4 — Debug 方向性增强探索（只评估、不实现）

> 目标：在 P2 死枝清理之后，明确"我们要不要在未来补这些能力，优先级怎么排"。每条只出一个 1–2 页的评估，进入 `Documents/Plans/Plan_OpportunityIndex.md`。

#### 4.1 脚本内 Watch / Frozen Snapshot（对标被注释掉的 per-object DebugValues 初衷）

- 目标：在脚本"断点命中"时，除了 DAP 客户端请求 `Variables`，也能在引擎侧持久化一份轻量 watch 快照，可在日志中 dump。
- 可达性：需要 `FDebugValuePrototype::Instantiate` 真正可用 + 一个附着点。可选的附着点不一定是 `UObject::Debug`，而可以是 `FAngelscriptEngine::FAngelscriptDebugStack::Frames[i].Variables`（已有结构体）。
- 对架构影响：中；需在 `AngelscriptLineCallback` 热路径做额外分配，`asEP_BUILD_WITHOUT_LINE_CUES` 不能再设置。
- 与 DebugServer V2 关系：`Variables` 协议消息已存在；Watch 快照是"断线也能用"的离线形态。
- 建议优先级：**P2 (中)**，前置是 P2 选项 A 完成（确保现有死枝已清，避免双实现并存）。

#### 4.2 Verbose Debug Logging 分级 CVar

- 目标：把当前"散落在 Debugging/ClassGenerator/HotReload 的零散 `UE_LOG(Angelscript, Verbose, ...)`"归类到若干可控开关：`as.Log.ClassGenerator` / `as.Log.HotReload` / `as.Log.DebugServer` / `as.Log.JIT`。
- 可达性：低代价，纯 CVar + 日志类别注册。
- 对架构影响：低。
- 建议优先级：**P1 (高)**，可与 Phase 3 并行。

#### 4.3 脚本异常 → Unreal Insights trace 事件

- 目标：`LogAngelscriptException` 同步打一条 trace event（Channel: `AngelscriptException`），便于 Insights 时间线上定位脚本抛出。
- 可达性：中；需引入 `TRACE_BOOKMARK` / 自定义 channel。UE 5.7 已支持。
- 与 DebugServer 关系：正交。
- 建议优先级：**P2 (中)**。

#### 4.4 Editor Overlay：在运行态可视化脚本 Actor 的 `DebugBreak()` 命中源

- 目标：在 PIE 运行态，脚本中 `DebugBreak()` / `ensure(false)` 命中时，HUD 角落弹 toast 附带 source link（复用 `SourceNavigation`）。
- 可达性：中；对非调试流程要能一键关。
- 建议优先级：**P3 (低)**；偏编辑器体感而非硬需求。

#### 4.5 Hot Attach：对正在跑的独立游戏进程从 VSCode 附加 DebugServer

- 目标：当前 DebugServer 在 `bIsDebugging=false` 时完全不跑 line callback（见 `UpdateLineCallbackState`）；要支持 hot attach，需允许 "connect 之后再动态打开 always-run"，目前已经成立（协议有 `BreakOptions`）。
- 需要评估：Shipping 是否允许开（当前 `WITH_AS_DEBUGSERVER=!Shipping && !Test`，Shipping 直接无 DebugServer——这是明确选择）。
- 可达性：中偏低（已有大部分基础）。
- 建议优先级：**P2 (中)**，与 `Plan_DebugAdapter.md` 合并评估。

#### 4.6 脚本内存探针：`as.Debug.DumpLiveObjects` 控制台命令

- 目标：一次性 dump 当前所有 `UASClass` 实例数 + per-class counter，辅助排查脚本对象泄漏。`FAngelscriptStateDump` 已覆盖类结构，缺"活对象清点"。
- 可达性：低；用 `TObjectIterator<UObject>` + `GetFirstASClass` 组合即可。
- 建议优先级：**P1 (高)**。

#### 4.7 JIT 调试模式：命中脚本断点时自动 fallback 到解释器

- 目标：`AS_SKIP_JITTED_CODE` 目前 Editor 下自动启用；非 Editor + JIT on 时若想命中断点会跳过。可引入一个 per-function `bForceInterpretInDebug` 覆盖。
- 可达性：中偏高，涉及 AngelScript 引擎侧参与。
- 建议优先级：**P3 (低)**，先等 JIT V2 迁移稳定（`Plan_AS238JITv2Port.md`）。

#### 4.8 建议进入 `UAngelscriptSettings` / 新 `DeveloperSettings` 的调试字段（向 `Plan_SettingsCoverageAndDX.md` P5.3 贡献）

- `bEnableDebugServer`（运行时总开关，默认 `true`，可代替纯宏硬编码语义的一部分）
- `DebugServerPort`（当前写死）
- `bEnableDebugServerOnlyInEditor`（当前 Shipping 已硬断，Dev 游戏端可选）
- `LoopDetectionCooperativeMode`（配合 `FAngelscriptExcludeScopeFromLoopTimeout`）
- `DebugVerboseChannelsMask`（对应 4.2）
- `bDumpLiveObjectsOnEndPIE`（对应 4.6）
- `ScriptExceptionTraceChannel`（对应 4.3）

### Phase 5 — 收束与看板同步

- [ ] **P5.1** 更新 `Plan_StatusPriorityRoadmap.md`："当前事实状态快照"新增 1 条，说明 `WITH_PEROBJECT_DEBUGVALUES/WITH_AS_DEBUGVALUES` 已按 P2 决定处置。
- [ ] **P5.2** 把 P4 里 `P1 (高)` 的两项（4.2 Verbose CVar、4.6 DumpLiveObjects）写进 `Plan_OpportunityIndex.md`，注明是本计划衍生。
- [ ] **P5.3** 在 `Plan_SettingsCoverageAndDX.md` P5.3 候选池合并 P4.8 列出的字段。
- [ ] **P5.4** `Documents/Guides/TestCatalog.md` 登记 Phase 1 / Phase 3 新增测试。

## 验收标准

- `Documents/Guides/DebugMode.md` 存在，构建宏矩阵与 `Bind_Debugging` API 清单完整。
- `AngelscriptDebugBuildMatrixTests.cpp` 通过；任何误动构建宏的 PR 都会被 CI 拦下。
- P2 完成后：全仓搜索 `WITH_PEROBJECT_DEBUGVALUES` 要么 0 命中（选 A），要么只在 1 处 `#error` 守护下命中（选 C）。
- 若选 A，全仓 `WITH_AS_DEBUGVALUES` 0 命中；`Object->Debug` 引用 0 处。
- `AngelscriptDebugApiTests.cpp` 与 `AngelscriptLoopDetectionTests.cpp` 全绿；覆盖 `throw / GetAngelscriptCallstack / FormatAngelscriptCallstack / Disable-Enable-DebugBreaks / ensure 去重 / 超时保护 / exclusion RAII`。
- `Plan_OpportunityIndex.md` 与 `Plan_SettingsCoverageAndDX.md` 按 P5.2/P5.3 合并。

## 风险与对策

| 风险 | 影响 | 对策 |
|---|---|---|
| 选 A 后某人在 `UE_BUILD_DEBUG` 本地构建上依赖 `Object->Debug` | 罕见场景失效 | 事实上当前就是失效的（`Object->Debug` 本来就不存在）；Phase 1 的构建矩阵测试 + DebugMode.md 公告足以对齐预期 |
| 选 C 之后死代码继续朽化 | 复利的技术债 | 在 P5.1 的状态快照里强制登记"Technical Debt 计时器"；建议 2 个迭代内重估 |
| Phase 3 触发 `DebugBreak()` 导致 CI 中断 | 测试 flake / 挂起 | 所有断点类测试都用 `AngelscriptDisableDebugBreaks()` 包起来；断言 `AreAngelscriptDebugBreaksEnabledForTesting()` 的开关状态作为副产物 |
| LoopDetection 测试对时间敏感 | flake | 使用足够短的阈值（0.02–0.05s）+ 足够重的 busy loop；在 teardown 还原阈值；参考 `Plan_SettingsCoverageAndDX.md` P3.3 的同类做法 |
| `AngelscriptDebugReificationTests` 重写后覆盖面缩减 | 回归盲区 | 即使改成单分支测试，也保留每种 Reified 类型至少一条"可调用不崩"断言，防止 `ReifyDebugValueTemplate` 的 switch/default 路径被误删 |
| Phase 4 被当成本计划必做项 | 范围漂移 | 每条 4.x 的标题都加 "（只评估、不实现）"；Plan 文档与 `Plan_OpportunityIndex.md` 边界清晰化 |

## 执行顺序建议

1. **Phase 1** — 构建矩阵文档 + 守护测试（**前置**，~1 个小周期）。
2. **Phase 2** — 死枝处置（建议选 A；**与 Phase 3 不冲突，可并行但先出决定**）。
3. **Phase 3** — 已有 Debug API 的测试补齐（可与 Phase 2 并行）。
4. **Phase 4** — 方向性评估（Phase 2 决定之后再启动；否则 4.1 的评估前提不清）。
5. **Phase 5** — 看板同步 + 外部计划对接。

## 附录 A：新增/修改文件清单预估

- 新增
  - `Documents/Guides/DebugMode.md`
  - `Documents/Knowledges/ZH/Note_DebugValuesFindings.md`
  - `Plugins/Angelscript/Source/AngelscriptTest/Core/AngelscriptDebugBuildMatrixTests.cpp`
  - `Plugins/Angelscript/Source/AngelscriptTest/Debugger/AngelscriptDebugApiTests.cpp`
  - `Plugins/Angelscript/Source/AngelscriptTest/Core/AngelscriptLoopDetectionTests.cpp`
- 修改（若选 A，Phase 2 涉及）
  - `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptDebugValue.h`
  - `Plugins/Angelscript/Source/AngelscriptRuntime/Core/Helper_Reification.h`
  - `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.cpp`（7 处）
  - `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.h`（`FAngelscriptDebugFrame` 字段）
  - `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptType.h`（`CreateDebugValue` virtual）
  - `Plugins/Angelscript/Source/AngelscriptRuntime/ClassGenerator/ASClass.cpp`（4 处）
  - `Plugins/Angelscript/Source/AngelscriptRuntime/ClassGenerator/AngelscriptClassGenerator.cpp`（2 处 + `CreateDebugValuePrototype` 本体）
  - `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/{Bind_TArray.cpp, Bind_TArray.h, Helper_PODType.h, Helper_CppType.h, Bind_UEnum.cpp}`
  - `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/AngelscriptDebugReificationTests.cpp`
  - `Documents/Plans/Plan_StatusPriorityRoadmap.md`
  - `Documents/Plans/Plan_OpportunityIndex.md`
  - `Documents/Plans/Plan_SettingsCoverageAndDX.md`
  - `Documents/Guides/TestCatalog.md`
