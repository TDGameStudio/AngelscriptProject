# Angelscript 测试框架 Review — 2026-08-13

> 范围：当前仓库的测试框架、运行器、helper/宏，以及各主题测试的完整度。
> 性质：只读审查。本文不改代码、不立 OpenSpec change。
> 对照：`TestArchitectureAudit_20260630.md`（架构切片，部分已过时）、`TestBuildPowerShellToolingReview_20260813.md`（PowerShell 入口，同日）、`openspec/changes/test-coverage/coverage-gaps.md`（Coverage 矩阵）、`TechnicalDebtInventory.md`（历史快照，后半段已过期）。

## 0. 先看结论

当前测试体系已经很大、也很能绿，但**官方“全量”并没有跑完全部已注册测试**，helper/文档仍在教已经删掉的 API，若干产品能力只有编译成功或负向边界，没有运行时闭环。

最值得先处理的三件事：

1. **把 `All` 目录补成真正的全量**，至少纳入 `Coverage`、`Testing.ScriptTestFramework`、`CppTests`，并明确 `ScriptTests` / `CachePackage` / `CrashOnly` 各自为什么不进 `All`。
2. **收敛官方入口**：`RunTestSuite.ps1`、`RunTestSuiteParallel.ps1`、`RunTestSuiteFast.ps1` 现在是三套互不完全等价的“全量”。同一天的 PowerShell review 已经把并行契约缺陷写清，本文不再重复展开。
3. **把“测试存在”和“行为被证明”分开**：Networking、脚本类执行、Subsystem Tick、`Script/Tests` 夹具、GAS tag skip 都属于后者不足。

当前 Disabled 集合本身很小，不是主要问题：

- 2 个 `#ue57-headless`
- 14 个 `#as-v238-backport`（可发现但不计入 691/691）
- 约 70 个 Syntax `#if 0`，标注的是 fork 不支持或会崩溃的引擎行为，不是漏跑的回归

---

## 1. 当前规模快照（相对 2026-06-30）

| 口径 | 2026-06-30 审计 | 2026-08-13 实测 | 说明 |
|------|-----------------|-----------------|------|
| `AngelscriptTest` `.cpp` | 约 430 测试文件 | **914** | 含 Cache 103、Coverage 90、AngelScriptSDK 273 |
| `TEST_CLASS_WITH_FLAGS` | CQTest 为主 | 885 文件 / 922 类 | 主注册形态 |
| `TEST_METHOD` | 未单独计 | 896 文件 / **3989** 方法 | 含 Coverage 1022 |
| `IMPLEMENT_*_AUTOMATION_TEST` | 417+ 定义 | 插件测试模块 **0**；宿主 `Source/AngelscriptProjectTest/Tests/` 仍有 **3** 个 live `IMPLEMENT_SIMPLE` | 插件侧已迁到 CQTest；宿主工程残留旧注册 |
| `AngelscriptEditor/Tests` | 32 | 35 | Editor 内部测试仍在这里 |
| GameplayTagsTest / GASTest | 未单列 | 7 / 26 | 可选插件有独立测试模块 |
| `Bind_*.cpp` / Bindings 测试 | 121 / 较少 | **204 / 88** | Bind 已拆 `_Functions` / `_Type`；Bindings 仍是契约烟测 |
| Catalog 基线 | 275/275 | 仍写 275/275 | 只是历史编目，不是 live 总数 |
| 最近全量快照 | 2396/2396（2026-07-28 串行 All） | 3090/3090（2026-08-12 CoarseDynamic） | 两套“全量”覆盖的前缀并不相同 |

`AngelscriptTest` 一级目录按 `.cpp` 数量：

| 目录 | `.cpp` | 角色 |
|------|--------|------|
| AngelScriptSDK | 273 | 原生核心，不经 `FAngelscriptEngine` |
| Cache | 103 | Cache V2 生成/恢复/store，单 shard 已到 17 分钟 |
| Coverage | 90 | 语义矩阵，**不在官方 `All` 里** |
| Bindings | 88 | AS 可见绑定入口契约 |
| Functional | 52 | 6 月底还是空目录，现已填实 |
| Core | 45 | 引擎、bind、snippet、coverage 基础设施 |
| Generator | 35 | 原 ClassGenerator / ScriptClass |
| Compiler | 34 | UE 集成编译管线 |
| StaticJIT | 32 | 多 provider / AOT / 诊断 |
| HotReload | 30 | 热重载行为 |
| Syntax | 19 | 语法/编译可达，大量 `#if 0` |
| FunctionLibraries | 18 | mixin / 函数库 |
| Preprocessor | 17 | 预处理 |
| Shared | 16 + 32 头 | helper + helper 自测 |
| Debugger | 15 | DAP / 会话 |
| 其余 | Template 9、Dump 8、Testing 7、FileSystem 7、Validation/Performance/Memory/GC/UHTTool/Editor/Delegate/Networking 各 1–3 | 见第 3 节 |
| Standalone | 16 个 C++ TU / 19 个 CTest | 独立 CMake 门禁，不能和 UE Automation 数字相加 |
| 宿主 `AngelscriptProjectTest` | 2 个 `.cpp` / 3 个 live `IMPLEMENT_SIMPLE` | 不在插件测试模块里 |

`AngelscriptRuntime/Tests/` **不存在**。`TestConventions.md` 仍把它写成 Runtime C++ 单测落点；实际 `CppTests` 散在 `AngelscriptTest/Core`、`Dump`、`UHTTool`。`AngelscriptRuntime/Testing/` 是产品侧 **AngelScript 脚本测试框架**，不是 C++ unit test。

---

## 2. 框架本身的问题

### 2.1 官方 `All` 不是全部已注册测试

`Tools/Shared/TestSuiteDefinitions.ps1` 的 `All` 有 36 个 UE 前缀 + Standalone Debug。下面这些**已经存在、可被 Automation 发现**的家族不在 `All` 里：

| 前缀 | 规模 | 现在怎么跑 |
|------|------|------------|
| `Angelscript.TestModule.Coverage.*` | 90 文件 / 1022 方法 | 非官方 `Tools/RunCoverageTests.ps1` |
| `Angelscript.TestModule.Testing.ScriptTestFramework.*` | 7 个 C++ 文件，覆盖 Runtime `Testing/` | 只能手写 `-TestPrefix` |
| `Angelscript.CppTests.*` | UHT / 引擎互操作等 | 只在 `RuntimeCpp` suite 和部分 group |
| `Angelscript.ScriptTests.*` | 磁盘上的 `UAngelscriptTestSuite` | 文档有命令，suite/group/ini **都没有** |
| `CachePackage` | Development/Shipping 包烟测 | 独立 suite，不进 `All` |
| `Angelscript.CrashOnly.*` | 主动崩溃 | 正确排除；必须带 `-AngelscriptRunCrashOnlyTests` |

更麻烦的是，三种“全量”集合不一致：

- 串行 `RunTestSuite.ps1 -Suite All`：只跑目录表。
- `Coarse` / 宽前缀 `Angelscript.TestModule`：会带上 Coverage 和 Testing。
- `RunTestSuiteFast.ps1` 实际走 `CoarseDynamic`，并且**固定读 `All`**，会忽略 `-Suite`。

所以“全绿”取决于你走哪条入口。2026-07-28 的 2396/2396 和 2026-08-12 的 3090/3090 不能互相替代。

`UnitTest.md` 还要求新语义矩阵写到 `Coverage/`。按这份规范写出来的测试，**官方 `All` 默认不会跑**。

### 2.2 具名 suite、group、文档入口对不齐

| 名字 | 实际内容 |
|------|----------|
| suite `Smoke` | MultiEngine / DependencyInjection / EngineSubsystem / BindConfig / SharedEngineHelper / Parity |
| group `AngelscriptSmoke` | MultiEngine + StaticJIT.PrecompiledData + 三个 Functional.Core 冒烟 |
| suite `RuntimeCpp` | `Angelscript.TestModule.Engine` + `Angelscript.TestModule.CppTests` |
| 部分 Runtime 单测 | 注册成 `Angelscript.CppTests.*`，suite 收不到 |
| `FunctionalSamples` | Actor / Component / Delegate / Interface，不含 Functional 目录下的 Objects/Operators/Handles/GAS 等 |

Agent 和人按名字选入口时，很容易以为跑过了其实没跑到。

### 2.3 官方编排器仍是串行；并行入口契约不稳

治理层（`Test.md`、`AGENTS.md`、openspec-work）把 `Tools\RunTestSuite.ps1` 写成唯一 suite 入口。它是同步 `for` 循环，每个前缀冷启动一次 Editor。

并行/Fast 已经能把 wall time 从约 42 分钟压到约 18 分钟，但同一天的工具链 review 已确认：

- `CoarseDynamic` 不遵守 `MaxParallelHeavy`
- 默认策略下 `-Suite` 可能被丢掉，实际跑 `All`
- Fast 实现与 `Test.md` 写的 5 shard / 不含 Standalone 不是一回事
- 并行 slot 绕过同 worktree 的 build/test 互斥锁
- 文档里的 Fast 全量 5–8 分钟已经不成立：单个 Cache shard 就要 17 分钟

细节见 `Documents/Guides/TestBuildPowerShellToolingReview_20260813.md`。

另外：

- suite `-TimeoutMs` 是**每条 entry**，不是整次 All 的墙钟
- `Test.md` 有一处仍写超时上限 `900000ms`，代码上限是 `3600000ms`
- `-Group` 路径没有 CrashOnly 防护；今天安全只是因为现有 group 没把它列进去

### 2.4 Helper / 宏名和真实行为脱节

当前真正还在的宏只有：

```text
ASTEST_AS / ASTEST_AS_ANSI
ASTEST_CREATE_ENGINE    → 共享 Full 引擎 + ResetModules
ASTEST_GET_ENGINE       → 同一共享引擎，不 reset
ASTEST_CREATE_ENGINE_FULL → 线程局部瞬态 Full 引擎
ASTEST_CREATE_ENGINE_NATIVE
ASTEST_RESET_ENGINE     → ResetModules
```

已经删掉、但文档还在教的：

- `ASTEST_CREATE_ENGINE_SHARE*` / `ASTEST_BEGIN_*` / `ASTEST_END_*` / `ASTEST_CREATE_ENGINE_CLONE`
- `FCoverageModuleScope`（类型已改名 `FScopedAngelscriptModule`，宏注释仍写旧名）
- `AngelscriptTestSupport::ResetSharedCloneEngine`
- `FScopedGlobalEngineOverride`（`TechnicalDebtInventory.md` 仍引用，头文件里没有）

名字会骗人的 helper：

| 名字 | 实际行为 |
|------|----------|
| `GetOrCreateSharedCloneEngine` | 共享 **Full** 单例，不是 clone |
| `CreateIsolatedCloneEngine` | scan-free Full 引擎 |
| `FAngelscriptTestEnginePool` | 不是池；`AcquireModuleCleanEngine` 就是上面那个单例 |
| `AngelscriptTestExecute.h` 里的四个 namespace 注释 | 文件里 **0 个** `namespace`，函数都在全局 |

还有两套 `ExecuteIntFunction`：一套在 `AngelscriptTestEngineHelper.h`（HotReload 用），一套在 `AngelscriptTestExecute.h`（Bindings/GAS 用）。再加 `ExpectGlobal*`、`ExecuteAndExpect*`、Bindings 本地的 `WorldCollisionExecute*`，同一件事四种调法。

`Shared/` 仍是杂物间：执行、World fixture、Debugger mock、内存探针、领域测试类型、helper 自测挤在一起。umbrella `AngelscriptTestUtilities.h` 继续制造 include 环。

样板没有收敛：`ASTEST_CREATE_ENGINE` 出现在 402 个文件 / 613 处，`BEFORE_ALL` + `AFTER_ALL` 在大量 CQTest 里字面重复。

6 月底审计里 “`ASTEST_AS` 几乎没人用” 已经翻过来：Bindings 里现在有 136+ 次 `ASTEST_AS`，SDK 大量用 `ASTEST_AS_ANSI`。规则还在，只是执行面已经铺开。

`Compiler/AngelscriptCompilerInterfaceTests.cpp` 现在是 2 行 stub（`UINTERFACE()` 已弃用后整测删除），目录里仍占一个文件名。

### 2.5 默认运行模型仍是“共享 Full 引擎 + 整表 bind”

`ASTestSuiteMemoryPeakRootCause.md`（2026-05-14）的结论仍然成立：

- 真实泄漏（未 root 的 UAS 类型、docs map、`FBlueprintEventSignature`）已经修过
- 峰值仍在约 12 GB 量级：每次 Full bind 约 800–1200 MB + mimalloc 页不还 + FName `_REPLACED_N`
- GAS Functional 已从每测 87 次 bind 收到 1 次；Debugger（约 31 次 bind）等路径没有同等记录
- `FAngelscriptTestEnginePool` 每 25 次 module-clean 做一次 GC，**不会**把 mimalloc 页还给 OS

隔离风险：

- 默认共享引擎。忘了 `FScopedAngelscriptModule` / `DiscardModule`，后面的类会脏。
- `ASTEST_CREATE_ENGINE_FULL()` 是线程局部瞬态槽，同线程第二次调用是替换不是叠加。
- `fix-automation-suite-reliability` 里的 “no-current-engine suppressor” 任务仍未勾完；只 `SnapshotAndClear()` 仍可能看到 subsystem 主引擎。
- StaticJIT AOT 仍要求 `build → generate → rebuild → test`。干净 worktree 只跑 `Angelscript.TestModule.StaticJIT` 可能因本地 cache/生成物过期失败。

### 2.6 测试模块边界仍然偏重

`AngelscriptTest.Build.cs` 现在是：

- Public 8：Core / CoreUObject / Engine / GameplayTags / Json / JsonUtilities / PropertyBindingUtils / AngelscriptRuntime
- Private 6：AIModule / EnhancedInput / InputCore / Slate / SlateCore / UMG
- Editor 8：BlueprintGraph / CQTest / LevelEditor / Networking / Sockets / UnrealEd / AngelscriptEditor / **AngelscriptTestJIT**

6 月底的 21 个依赖没有实质瘦身，还多了测试 JIT provider。`StartupModule()` 已不再改写生产 Subsystem 初始化（C2 那条已关），只按 `-AngelscriptTestPrewarmEngine` 可选预热，这一点是改进。

### 2.7 脚本测试框架和 `Script/` 没有接到回归

Runtime `Testing/` 是完整产品协议：`UAngelscriptTestSuite`、`meta=(AngelscriptTest)`、registry、runner、latent/network、commandlet。

C++ 侧已经有 Discovery / Lifecycle / Assertions / World / Commands / Automation / HotReload，前缀是 `Angelscript.TestModule.Testing.ScriptTestFramework.*`。这些测试**不在 `All` 里**。

磁盘脚本：

- `Script/Tests/Test_ReflectedScriptSuites.as` 是唯一像样的 `UAngelscriptTestSuite`
- `Test_Enums.as`、`Test_GameplayTags.as`、`Test_Handles.as` 等只返回常量，是 hot-reload / 语料夹具，不是功能测试
- `Script/Automation/` 是空目录
- 没有任何 suite / group / `*.ps1` 编目 `Angelscript.ScriptTests`

`test-as-script-corpus-and-functional-coverage` 仍是 plan-only，任务全未勾。

---

## 3. 哪些测试还不够完善

下面按“已经有目录/文件，但证明力不够”和“能力已规划、测试尚未落地”分开。

### 3.1 已有主题，但只证明到编译或负向边界

#### Networking — 最大的产品闭环缺口

- `Networking/AngelscriptNetworkRPCTests.cpp`：6 个方法，只证明 `Server` / `Client` / `NetMulticast` / `WithValidation` / `Unreliable` / Mixed **能编译，并且 `FUNC_Net*` 在生成类上**。
- Coverage 的 networking（27 个方法）自己写明没有 PIE 多端运行时，只做反射/元数据。
- Runtime 已有 `Testing/Network/FakeNetDriver` 和 `GetLifetimeScriptReplicationList()`，**Networking 主题没有用它们做投递或复制列表断言**。
- 缺：listen-server/client 投递、`Replicated` / `ReplicatedUsing` / `ReplicationCondition` 运行时、NetMulticast fan-out、relevancy / dormancy、push-model。
- `Plan_NetworkReplicationTests.md` 仍写“没有 `Networking/` 目录”，已经过时；目录在了，闭环还没有。

#### Functional 脚本类执行仍是负向边界

`TestCatalog.md` 和 `Test.md` 都把这些锁成显式边界，执行时期望 `Null pointer access`：

- `Functional/Objects`：脚本类对象执行、mutable global class variable
- `Functional/Operators`：脚本类 operator / const method / getter-setter
- `Functional/Handles`：脚本类 handle 声明、按值传参
- `Functional/Inheritance`：interface / cast-op / mixin 的当前分支限制

这不是“没写测试”，而是**用户最常见的脚本类路径还不能正向跑**。后续若 runtime 修了，应在同一文件把负向改成正向，不要另开一套前缀。

#### Subsystem — 文档和代码都偏弱

- `Functional/Subsystem/AngelscriptSubsystemTests.cpp` 现在只断言 `bCompiled`（WorldSubsystem Lifecycle / Tick / ActorAccess）。
- Catalog §12.14 还写“当前分支编译失败”，和源码相反。
- 没有 `Initialize` / `Tick` / `Get()` / 生命周期顺序的运行时断言。
- 主题化的 `WorldSubsystem` / `GameInstanceSubsystem` 前缀仍在 `All` 里，和 Functional/Subsystem 容易看成两套。

#### Syntax — 大量停在 `#if 0`

约 70 处，注释是 `DISABLED(#as-engine-behavior)` 或 `DISABLED(#preprocessor-vs-runtime-fields)`。典型：

- AS 不校验 `BlueprintReadOnly` + `BlueprintReadWrite` 冲突
- fork 不支持 `interface` / `mixin class`
- 匿名 class/enum 会 ensure-crash，所以停掉
- 预处理器 enum 的 `ValueNames` / `Meta` 在 preprocess-only 路径未填

这些应继续当能力边界清单，不要和失败回归混在一起。其中“会崩溃”的那几条如果要转成正式负向，需要独立 crash-only 或更安全的探测，不能直接打开。

#### Coverage 还剩两个刻意的 🟡

`coverage-gaps.md` 在 2026-08-01 之后整体已经很成熟（89 个带测文件 / 1022 方法，G1–G29 都有实现或 🚫）。仍可见的天花板：

- **G7**：无资产 `UWidgetAnimation` 没有可播 MovieScene；headless 下动画/焦点只能到反射层
- **G19**：foreach 中改容器只锁了编译可达，运行时失效语义还没选定，因此没有断言

其余 🚫（嵌套容器、脚本 `interface`、TArray `RemoveAll` 等未暴露 API）是 fork/绑定边界，不是漏测。

### 3.2 目录很瘦、真正覆盖在别处

| 主题目录 | 实际测了什么 | 不要误判成 |
|----------|--------------|------------|
| `Delegate/` 1 文件 | 脚本 USTRUCT 值参数走委托 | Unicast/Multicast 在 `Functional/Delegate/`；Coverage 还有 52 个方法 |
| `Editor/` 1 个测试 cpp | SourceNavigation 路径/行号；Functions 在 headless 下是 Disabled | 真 Editor 行为在 `AngelscriptEditor/Tests/`（35 文件：watcher、BlueprintImpact、reload helper、Content Browser、菜单） |
| `GC/` 2 文件 | Actor/Component 拆毁弱引用 + 引擎关机 unroot | 循环引用 / UPROPERTY 链在 Coverage |
| `Memory/` 2 文件 | bind 创建销毁残留、全局容器环有界 | 不是 AS 堆分配器测试 |
| `UHTTool/` 2 文件 | `Angelscript.CppTests.UHTToolResolver.*` | 不在 `All`；只在 `RuntimeCpp` / 部分 group |

### 3.3 Disabled / 跳过 / 软跳过

**正式 Disabled（应保留标签，不要 silently 删）：**

| 位置 | 原因 |
|------|------|
| `Shared/AngelscriptTestEngineHelperTests.cpp:1025` | `#ue57-headless`：`TryGetRunningProductionDebuggerEngine` 在无头 batch 返回 null |
| `Editor/AngelscriptSourceNavigationTests.cpp:102` | `#ue57-headless`：属性导航源码元数据无头下不填 |
| AngelScriptSDK Conformance / Language 共 14 个方法 | `#as-v238-backport`：using namespace、member init、lambda、variadic、template、bool context、特殊成员、属性形态等尚未选择性回移 |

**软跳过（测试是绿的，但环境一变就什么都没测）：**

- Bindings 里一批 `"… not available, skipping"`：`FName` / `FColor` / `FCollisionQueryParams` / `FCollisionShape` / `FHitResult` / `FInstancedStruct` / `FLatentActionInfo` / `AVolume` / `UFXSystemComponent` / `UInputSettings` / `FPlatformApplicationMisc`，以及 `ANavigationData` 抽象类正例
- GAS：`"Tag not registered, skipping"` / `"FGameplayAttribute not available, skipping"` 出现在 activation、ASC delegate、Character tag、async library、extended bindings

`TestFixSummary_20260430.md` 里的 15 个 `TODO(binding-gap)` **源码里已经没有了**。对应 Bind（`Bind_FApp`、`Bind_FBox`、`Bind_FGenericPlatformMisc` 等）在。那份 4 月清单不能再当缺口表。

### 3.4 可选插件：有测试，但偏契约、少场景

**GameplayTags（7 个 cpp）**

有：绑定架构、空契约、容器/函数库签名、Editor 模块生命周期。
缺：World/PIE 标签复制、编辑器增删 tag 后脚本消费者热更、运行时 query 矩阵。GAS 在 tag 未注册时直接 skip，两边没有共享的最小 tag 夹具。

**GAS（26 个 cpp）**

有：Ability 激活/生命周期、ASC、AttributeSet、AbilityTask、Cue/Effect utils、生成函数表。
弱：大量 `DoesNotCrash` / `ReturnsNull` / `AddExpectedError`；没有预测、GE duration/stacking、cue notify 资产、cooldown GE。Catalog 里 Functional.GAS 行仍偏“AttributeSet 能编译注册”，不是这套插件 suite。

### 3.5 新能力：规划在、测试树还没有

| 能力 | 现状 | 缺口 |
|------|------|------|
| StaticJIT 多 provider | `StaticJIT/` 32 个 cpp，registry/ABI/packaged/editor routing/AOT fixture 较完整 | 宿主 `Source/AngelscriptJIT/` 只有生成物，无宿主模块测试；typed semantic Dual fixture 未落地 |
| Typed semantic AOT | 仅 OpenSpec + research fixture | 没有 `AngelscriptNativeTypedSemanticIRTests.cpp` / `AngelscriptTypedSemanticIRTests.cpp` |
| Angelsea runtime JIT | `feature-as-angelsea-runtime-jit-plugin` 计划 | 无插件、无测试 |
| Unified JIT coordinator | `refactor-as-unified-jit-coordinator` 任务全空 | 无 `RuntimeJIT.Coordinator` 源 |
| Runtime 动态资产模型 | `refactor-as-runtime-asset-model` 有 test-plan | 计划中的 `Asset/AngelscriptDynamicAsset*` 不存在；Coverage 仍用旧 `asset MySingletonAsset of USingletonAssetCarrier` |
| `USingleton` 关键字 | `feature-as-usingleton-keyword` 有 test-plan | 无 Preprocessor.Singleton / Registry / GC / HotReload 单例测试 |
| Debug MCP / V3 | Debugger 现有测试是 V2 | `feature-as-debug-mcp-bridge` 未落地，无 MCP 20 tools / TS 协议包测试 |
| Script corpus | plan-only | 无 `Script/<Theme>/`、无 `Script/Tests/<Theme>/`、无 corpus validator、无 `ScriptCorpus` suite |
| Standalone Semantic IR | Standalone 19/19 CTest 是 compile-only / native 边界 | 不替代 UE 执行；也还没有 Semantic IR 的 Standalone 测试 |

`fix-automation-suite-reliability` 仍整表未勾（builder enum 析构、Editor Settings 注册顺序、no-engine suppressor、StaticJIT 专用预跑、Debugger 分片收包）。`All` 里的 `Generator` 前缀已经换过，但 verification.md 不存在，不能把这次 7 月失败当成已关闭。

---

## 4. 文档和数字口径在漂移

这些不是测试失败，但会让人和 Agent 用错过期入口、过期宏、过期失败清单。

| 文档说法 | 当前事实 |
|----------|----------|
| `TestCatalog.md` 275/275 | 只是历史编目；live 是 3989 `TEST_METHOD` + 多套 suite |
| `TechnicalDebtInventory.md` §17 的 7 个已知失败 | 后续 2396/2396 已覆盖；Learning 目录已不存在 |
| TDI 指向的 `Plan_TestCoverageExpansion.md` / `Plan_StaticJITUnitTests.md` / `Plan_KnownTestFailureFixes.md` | `Documents/Plans/` 里没有这些文件 |
| `TestMacroStatus.md` 仍列 `SHARE_*` / `BEGIN/END` / `CLONE`，并写 `IMPLEMENT_SIMPLE` 是注册入口 | 宏已删除；插件测试由 CQTest 注册 |
| `Test.md` CQTest 示例仍用 `ASTEST_CREATE_ENGINE_SHARE_CLEAN` 和 `FCoverageModuleScope` | 应改为 `ASTEST_CREATE_ENGINE` + `FScopedAngelscriptModule` |
| `Test.md` 仍把 CQTest 写成 “PoC” | `UnitTest.md` / `TESTING_GUIDE.md` 已要求新测试用 CQTest |
| `TestConventions.md`：`AngelscriptRuntime/Tests/` + `Learning/` | 这两个目录都不在了 |
| `Test.md` Fast = 5 shard、5–8 分钟、不含 Standalone | Fast.ps1 = CoarseDynamic + All + Standalone；Cache 单 shard 17 分钟 |
| AGENTS.md：121 个 `Bind_*.cpp`、430 测试 cpp、1518+ 定义 | 现在约 204 / 914+ / 3989 |
| Shared README / `TESTING_GUIDE` 基础设施表 | 仍列已删的 `AngelscriptTestLegacyHelpers.h`、`AngelscriptBindingsModuleBuilder.h` |
| `Plan_NetworkReplicationTests.md`：没有 Networking 目录 | 目录已有，但是编译期 flag 测试 |

Coverage 矩阵本身相对干净：`Documents/Coverage/` 已退役，权威在 `openspec/changes/test-coverage/`。不要再从旧 Coverage 文档发明缺口。

---

## 5. 建议优先级（只排序，不在本文件里开工）

### P0 — 不补测试，先让“全量”可信

1. 把 `Angelscript.TestModule.Coverage` 和 `Angelscript.TestModule.Testing.ScriptTestFramework` 写进 `All`（Coverage 应标 Heavy）。
2. 决定 `Angelscript.CppTests.*` 是并进 `All`，还是全部改挂 `Angelscript.TestModule.CppTests.*`。
3. 给 `Angelscript.ScriptTests`、`CachePackage`、`CrashOnly` 各写一句正式 disposition，避免再被当成“忘了编目”。
4. 按 `TestBuildPowerShellToolingReview_20260813.md` 把并行收进唯一官方入口；串行改成显式诊断模式。

### P1 — 补运行时证明，而不是再加编译通过

1. Networking：用已有 `FakeNetDriver` 做至少一条 Server/Client/Multicast 投递 + 一条 `ReplicatedUsing` 往返。
2. Functional：脚本类对象 / operator / handle 一旦 runtime 能跑，把负向改成正向。
3. Subsystem：`Tick` / `Get()` / 生命周期，不要停在 `bCompiled`。
4. GAS/GameplayTags：提供最小已注册 tag 夹具，消灭 `"Tag not registered, skipping"`。
5. StaticJIT：给干净 worktree 一条 `generate → rebuild → test` 预跑，不要让 `All` 依赖本地残留 cache。

### P2 — 框架可维护性

1. 改掉 Clone/Pool 这种名不副实的 helper，或在头文件第一行写明“实际是共享 Full”。
2. 删掉或改写仍教 `SHARE_*` / `FCoverageModuleScope` 的指南。
3. 合并两套 `ExecuteIntFunction`。
4. 更新 Catalog / TDI / AGENTS 的数字口径：编目基线、源码规模、串行 All、并行 All、Standalone 19/19 分开写。
5. 给 Cache 单独计时/分片策略；它已经是全量墙钟的主因。测试树本身怎么乱、该怎么拆，见 `Documents/Guides/CacheV2TestReview_20260813.md`。

### P3 — 未落地能力，等对应 OpenSpec 一起做

Typed semantic AOT、Angelsea JIT、unified coordinator、`USingleton`、动态资产、Debug MCP、Script corpus。这些不应当成“现有测试没写好”，应当成“产品还没进测试树”。

---

## 6. 和既有文档怎么分工

| 文档 | 继续用它看什么 | 不要再用它当 |
|------|----------------|--------------|
| 本文 | 2026-08-13 的框架问题 + 不完整测试总表 | 实时失败清单（没有跑新的 All） |
| `TestArchitectureAudit_20260630.md` | 抽象层 / 目录 N:M / 模块依赖的历史切片 | Functional 仍为空、4 套 namespace 仍存在、C2 仍改写 Subsystem |
| `TestBuildPowerShellToolingReview_20260813.md` | 并行/Fast/锁/超时契约 | 测试内容覆盖率 |
| `openspec/changes/test-coverage/coverage-gaps.md` | Coverage 域的 ⬜/🟡/🚫 | 全仓库缺口（它不管 Networking 主题、Script corpus、JIT 新能力） |
| `TechnicalDebtInventory.md` | helper 去全局化、历史回归证据 | §17 已知失败、Learning 路径、已删 plan 的 owner |
| `TestCatalog.md` | 已编目主题说明 | live 计数或 “全绿” 证明 |
| `Documents/UnitTest/UnitTest.md` | 新 CQTest 怎么写 | suite 会不会跑到你新写的 Coverage |

---

## 7. 修订

- 2026-08-13：基于当前测试树、suite 目录、Coverage 矩阵、OpenSpec 未落地能力和同日 PowerShell 工具链 review 写成初版。未执行新的 `All` 回归；通过/失败数字沿用已有工件和文档快照。
