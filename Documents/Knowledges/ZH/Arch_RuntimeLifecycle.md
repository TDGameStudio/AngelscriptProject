# Arch_RuntimeLifecycle — Runtime 总控与生命周期

> **所属前缀**: Arch_（插件总体架构族）
> **关注层面**: 架构总控与生命周期编排（不深入单子系统实现细节）
> **关键源码**:
> `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptRuntimeModule.h` / `.cpp` (~206 行)
> · `Core/AngelscriptEngineSubsystem.h` / `.cpp` (~205 行，Editor / Commandlet 的 Bootstrap 主控)
> · `Core/AngelscriptGameInstanceSubsystem.h` / `.cpp` (~120 行，Game 世界的引擎所有者)
> · `Core/AngelscriptEngine.h` (~46 KB，`FAngelscriptEngine` / `FAngelscriptEngineContextStack` / `FAngelscriptEngineScope`)
> · `Core/AngelscriptEngine.cpp` (~3000+ 行，`Initialize` / `Initialize_AnyThread` / `Tick` / `Shutdown` 主流程)
> · `Plugins/Angelscript/Angelscript.uplugin`（模块装载阶段定义，所有模块均为 `PostDefault`）
> **关联文档**:
> `Documents/Knowledges/ZH/Arch_Overview.md` — 插件总体概览（待写）
> · `Documents/Knowledges/ZH/Arch_ModuleLoading.md` — 模块清单与装载关系（待写）
> · `Documents/Knowledges/ZH/RT_GlobalState.md` — 全局状态治理（细化 Context Stack / Ambient World）
> · `Documents/Knowledges/ZH/RT_HotReload.md` — Tick 中的热重载链路
> · `Documents/Knowledges/ZH/RT_Debugger.md` — Tick 中的 DebugServer 驱动

---

## 概览

本文聚焦一个核心问题：**`FAngelscriptEngine` 这个核心运行时对象，从被谁创建、何时初始化、谁来驱动 Tick、到何时销毁，这条总控链路是怎么编排的？**

```text
"AngelScript Runtime" 的核心矛盾
================================

矛盾一：UE 运行环境差异极大
    Editor / Commandlet / 独立游戏进程 / PIE / DevAutomationTest
    每种场景下"何时第一次需要 AS 引擎"的时机完全不同

矛盾二：FAngelscriptEngine 是有状态的重对象
    Initialize 内部要做：
      AS Engine 创建 -> 144+ Bind_*.cpp 全量绑定 -> ScriptRoots 扫描
      -> InitialCompile（含 Preprocessor / Compiler / ClassGenerator）
      -> 可选启动 DebugServer / StaticJIT / CodeCoverage
    一次完整启动可达数秒级，必须懒加载且只能一次

矛盾三：必须支持"多上下文 / 多 Engine 实例"
    生产场景：Editor 进程内同时有 Editor 主引擎 + 多个 PIE 克隆引擎
    Test 场景：每个 Spec 可能创建独立 FAngelscriptEngine
    所有 AS 调用都要能问出"当前我属于哪个 Engine"
```

为应对上述矛盾，插件采用"**引擎对象（FAngelscriptEngine）+ 编排者（Module / Subsystem）+ 上下文栈（ContextStack）**"三层结构：

```text
┌──────────────────────────────────────────────────────────────────────┐
│  Layer 1: FAngelscriptEngine （USTRUCT，重对象，有状态）            │
│           - 提供 Initialize / Shutdown / Tick / ShouldTick           │
│           - 不知道"谁要用我"，只负责"被用"                           │
└────────────────────────┬─────────────────────────────────────────────┘
                         │ 谁来 new 它 / 谁来调 Initialize
                         │
┌────────────────────────┴─────────────────────────────────────────────┐
│  Layer 2: 编排者（按场景分工）                                       │
│  ┌──────────────────────┬──────────────────────┬──────────────────┐  │
│  │ FAngelscriptRuntime- │ UAngelscriptEngine-  │ UAngelscriptGame-│  │
│  │ Module               │ Subsystem            │ InstanceSubsystem│  │
│  │ (兼容 API 入口)      │ (Editor/Commandlet   │ (Game 世界引擎   │  │
│  │ InitializeAngelscript│  的 Bootstrap)       │  与 Tick 所有者) │  │
│  └──────────────────────┴──────────────────────┴──────────────────┘  │
└────────────────────────┬─────────────────────────────────────────────┘
                         │ 创建出来的 Engine 通过下面这层暴露给业务代码
                         │
┌────────────────────────┴─────────────────────────────────────────────┐
│  Layer 3: FAngelscriptEngineContextStack （进程级 TArray<Engine*>）  │
│           - Push / Pop / Peek                                        │
│           - 任何 AS 业务代码: TryGetCurrentEngine() = Stack.Last()   │
└──────────────────────────────────────────────────────────────────────┘
```

后续章节按这三层依次展开。

---

## 一、模块装载阶段：只点亮模块，不创建引擎

`Angelscript.uplugin` 中三个 UE 模块（`AngelscriptRuntime` / `AngelscriptEditor` / `AngelscriptTest`）的 `LoadingPhase` 全部为 `PostDefault`：

```json
// 文件: Plugins/Angelscript/Angelscript.uplugin
{
    "Modules": [
        { "Name": "AngelscriptRuntime", "Type": "Runtime", "LoadingPhase": "PostDefault" },
        { "Name": "AngelscriptEditor",  "Type": "Editor",  "LoadingPhase": "PostDefault" },
        { "Name": "AngelscriptTest",    "Type": "Editor",  "LoadingPhase": "PostDefault" }
    ]
}
```

为什么是 `PostDefault`？— 这一阶段已经能拿到完整 UE 反射元数据（CoreUObject 已完成 boot），但 `GEngine` 尚未必然存在。这正好是"想做绑定准备但**还不能实际跑**"的窗口期。

`FAngelscriptRuntimeModule::StartupModule()` 在这一阶段被调用，**它故意非常轻**：

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Core/AngelscriptRuntimeModule.cpp
// 函数: FAngelscriptRuntimeModule::StartupModule
// ============================================================================
void FAngelscriptRuntimeModule::StartupModule()
{
    UE_LOG(Angelscript, Verbose, TEXT("[RuntimeStartup] StartupModule."));
    // 注意：这里不创建 FAngelscriptEngine，不调 Initialize
    // 只是登记一句日志，所有重活推迟到 InitializeAngelscript() 显式触发
}
```

**关键点**：模块装载结束后，**进程里还没有任何 `FAngelscriptEngine` 实例**。也就是说：

- `FAngelscriptEngine::IsInitialized()` → `false`
- `FAngelscriptEngineContextStack::IsEmpty()` → `true`
- `FAngelscriptEngine::TryGetCurrentEngine()` → `nullptr`

真正的 Engine 创建被延后到下一阶段。

---

## 二、Bootstrap：谁来发起第一次 Initialize？

这一节回答："`FAngelscriptEngine::Initialize()` 是被谁拉起的？"。答案分三条路径，**互斥且自动衔接**——业务代码只要老老实实调 `FAngelscriptRuntimeModule::InitializeAngelscript()`，剩下的由编排者按当前进程环境自动选路。

```text
进程环境判定（全部走 InitializeAngelscript() 这个统一入口）

[Path A]  GIsEditor || IsRunningCommandlet()
          → UAngelscriptEngineSubsystem::Initialize 接管
          → 创建 OwnedEngine 并 Push 到 ContextStack
          → 此后该 Subsystem 是 PrimaryEngine 的所有者

[Path B]  GameInstance 启动 (PIE / 独立游戏)
          → UAngelscriptGameInstanceSubsystem::Initialize 接管
          → 优先 adopt Path A 创建的现有 PrimaryEngine
          → 若没有则自己 new 一个 OwnedEngine
          → 同时 ++ActiveTickOwners 抢占 Tick 主导权

[Path C]  无 GEngine / 无 GameInstance / Headless 测试场景
          → InitializeAngelscript() 直接 new OwnedPrimaryEngine
          → Push 到 ContextStack，由 RuntimeModule 持有 TUniquePtr
```

下面分别看每条路径。

### 2.1 `FAngelscriptRuntimeModule::InitializeAngelscript` — 统一入口（含哨兵 + 路由）

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Core/AngelscriptRuntimeModule.cpp
// 函数: FAngelscriptRuntimeModule::InitializeAngelscript
// 角色: 所有外部代码（含 Editor 模块、单元测试 base 类）的统一入口
// ============================================================================
void FAngelscriptRuntimeModule::InitializeAngelscript()
{
    // ==================== 步骤1：幂等哨兵 ====================
    // 同一进程内只允许"一次完整 Initialize 路由"，重复调用直接返回。
    // 这是为了防御 Editor 模块 + 测试 base 类同时调入。
    if (bInitializeAngelscriptCalled)
    {
        UE_LOG(Angelscript, Verbose, TEXT("[RuntimeStartup] InitializeAngelscript skipped because initialization already ran."));
        return;
    }
    bInitializeAngelscriptCalled = true;

    // ==================== 步骤2：自动化测试 Override ====================
    // WITH_DEV_AUTOMATION_TESTS 下允许测试用例注入一个伪 Engine 工厂，
    // 这样可以在不跑完整 Initialize 的前提下测试编排逻辑本身（见 §6）。
    #if WITH_DEV_AUTOMATION_TESTS
    if (InitializeOverrideForTesting) {
        if (FAngelscriptEngine* OverrideEngine = InitializeOverrideForTesting()) {
            FAngelscriptEngineContextStack::Push(OverrideEngine);
            InitializedOverrideEngineForTesting = OverrideEngine;
        }
        return;
    }
    #endif

    // ==================== 步骤3：路由到 EngineSubsystem（首选路径）====================
    // ★ 关键设计：只要 GEngine 存在，就把 Bootstrap 委托给 EngineSubsystem。
    // 这样 Engine 的"所有权"清晰落在一个 UEngineSubsystem 上，受 GC 与生命周期保护。
    FModuleManager::Get().LoadModuleChecked(TEXT("AngelscriptRuntime"));
    if (UAngelscriptEngineSubsystem* EngineSubsystem = UAngelscriptEngineSubsystem::Get()) {
        EngineSubsystem->EnsurePrimaryEngineInitialized();
        return;
    }

    // ==================== 步骤4：Headless / 早期阶段兜底 ====================
    // 没有 GEngine 时（极早期或纯 headless 测试场景），自己 new 一个 owned 引擎。
    // 注意 OwnedPrimaryEngine 是 RuntimeModule 的 static，进程级单实例。
    if (FAngelscriptEngine* CurrentEngine = FAngelscriptEngine::TryGetCurrentEngine()) {
        // 已经有 ambient 引擎（多见于测试环境通过 EngineScope 推入），adopt 它。
        if (CurrentEngine->GetScriptEngine() == nullptr)
            CurrentEngine->Initialize();   // 仅是被推入但还没初始化
    } else {
        OwnedPrimaryEngine = MakeUnique<FAngelscriptEngine>();
        FAngelscriptEngineContextStack::Push(OwnedPrimaryEngine.Get());
        OwnedPrimaryEngine->Initialize();   // ★ 走完整 Initialize 流程
    }
}
```

三条路径在**实际部署形态**下的覆盖率：

| 部署形态 | GEngine 状态 | 走哪条路径 | PrimaryEngine 所有者 |
|----------|---|---|---|
| Editor 启动 | 有 | Path A（EngineSubsystem 自身的 `Initialize`）| `UAngelscriptEngineSubsystem::OwnedEngine` |
| 独立 Cooked Game | 有 | 先 A、然后 B adopt | A 拥有；B 仅 adopt 不重新 init |
| Commandlet | 有 | Path A | `UAngelscriptEngineSubsystem::OwnedEngine` |
| Headless Automation Test | 通常无 / 测试期注入 | Path C 或 Override | `OwnedPrimaryEngine` (Module) |

### 2.2 `UAngelscriptEngineSubsystem` — Editor / Commandlet 的实际所有者

`UEngineSubsystem` 由 `GEngine` 在自身 `Init` 末尾自动构造。该子系统通过 `ShouldCreateSubsystem` 决定要不要在当前进程激活：

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Core/AngelscriptEngineSubsystem.cpp
// 函数: UAngelscriptEngineSubsystem::ShouldCreateSubsystem / Initialize
// 角色: Editor / Commandlet 进程的 Bootstrap 主控
// ============================================================================
bool UAngelscriptEngineSubsystem::ShouldCreateSubsystem(UObject* Outer) const
{
    if (IsUnreachable() || !Super::ShouldCreateSubsystem(Outer))
        return false;
    // 只在 Editor 或 Commandlet 进程激活；纯独立 Game 进程不创建。
    // Game 进程的 Bootstrap 让 GameInstanceSubsystem 接管（见 §2.3）。
    return ShouldBootstrapAngelscript();   // 内部 = GIsEditor || IsRunningCommandlet()
}

void UAngelscriptEngineSubsystem::Initialize(FSubsystemCollectionBase& Collection)
{
    Super::Initialize(Collection);
    EnsurePrimaryEngineInitialized();      // ★ 立刻拉起一次完整 Initialize
}
```

`EnsurePrimaryEngineInitialized()` 自身是**幂等**的（带 `bInitializedPrimaryEngine` 标志）。它处理三种情况：已初始化 / 已有 ambient 引擎 / 全新创建。最关键的是它**把 `OwnedEngine` 这个 USTRUCT 字段（嵌入到 UObject 里、受 UE GC 保护）作为 PrimaryEngine 持有**：

```cpp
// 节选自 EnsurePrimaryEngineInitialized 的兜底分支
PrimaryEngine = &OwnedEngine;          // ★ 不是 new，而是嵌入式 USTRUCT 成员
bOwnsPrimaryEngine = true;
bInitializedPrimaryEngine = true;
FAngelscriptEngineContextStack::Push(PrimaryEngine);
bPushedPrimaryEngineContext = true;
PrimaryEngine->Initialize();           // ★ 走完整 4 阶段 Initialize（见 §3）
```

**为什么不是 `TUniquePtr`**？— 因为 `FAngelscriptEngine` 是 USTRUCT，其内含若干 `UPROPERTY()` 指针（`AngelscriptPackage` / `AssetsPackage`）需要 GC 可见。把它作为 `UEngineSubsystem` 的 `UPROPERTY()` 成员，整条引用链对 GC 透明。

### 2.3 `UAngelscriptGameInstanceSubsystem` — Game 世界的 Tick 所有者

`UGameInstanceSubsystem` 在每个 GameInstance（PIE 或独立游戏）启动时被创建。它**不会重复跑 Initialize**，而是先尝试 adopt 已有引擎：

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Core/AngelscriptGameInstanceSubsystem.cpp
// 函数: UAngelscriptGameInstanceSubsystem::Initialize
// 角色: 在 Game 世界中扮演"实际驱动 Tick 的引擎所有者"
// ============================================================================
void UAngelscriptGameInstanceSubsystem::Initialize(FSubsystemCollectionBase& Collection)
{
    Super::Initialize(Collection);

    bInitialized = true;
    PrimaryEngine = FAngelscriptEngine::TryGetCurrentEngine();   // 优先 adopt 已存在的
    if (PrimaryEngine == nullptr) {
        // 仅在没人初始化过时（极少见，纯 -game 启动且 EngineSubsystem 缺席）才自建
        PrimaryEngine = &OwnedEngine;
        FAngelscriptEngineContextStack::Push(PrimaryEngine);
        OwnedEngine.Initialize();
        bOwnsPrimaryEngine = true;
    }

    // ★ 关键：每存在一个 GameInstance，就把全局 Tick Owner 计数 +1
    // 该计数被 EngineSubsystem 的 Tick 用来做"让位"决策，避免 Tick 被两次
    if (PrimaryEngine != nullptr)
        ++ActiveTickOwners;
}
```

——这条 `++ActiveTickOwners` 是整个 Tick 仲裁的核心信号，下一节展开。

---

## 三、Tick 仲裁：到底谁在驱动 `FAngelscriptEngine::Tick`？

`FAngelscriptEngine::ShouldTick()` 与 `Tick(float DeltaTime)` 本身不知道"谁该来调我"，调用权由两个 Subsystem 协商。两个 Subsystem 都实现 `FTickableGameObject` 接口，但它们用一套**计数仲裁**机制相互让位：

```text
仲裁规则（实现位于 UAngelscriptEngineSubsystem::Tick）

EngineSubsystem.Tick(dt) {
    if (PrimaryEngine == nullptr || GameInstanceSubsystem::HasAnyTickOwner())
        return;                          // ★ 让位：有 GameInstance 在场就闭嘴
    if (PrimaryEngine->ShouldTick())
        PrimaryEngine->Tick(dt);
}

GameInstanceSubsystem.Tick(dt) {
    if (PrimaryEngine && PrimaryEngine->ShouldTick())
        PrimaryEngine->Tick(dt);         // 无条件驱动
}
```

`HasAnyTickOwner()` 读取的就是 `ActiveTickOwners` 计数器。流程如下：

```
[场景 A：纯 Editor，无 PIE]
  EngineSubsystem.Tick    : ActiveTickOwners == 0 -> 自己驱动 Tick
  GameInstanceSubsystem   : 不存在
  结论: EngineSubsystem 是唯一 Ticker

[场景 B：Editor 内开 PIE]
  EngineSubsystem.Tick    : HasAnyTickOwner() == true -> return （让位）
  GameInstanceSubsystem.Tick : ★ 实际驱动 Tick
  结论: PIE 期间 GameInstance 接管，避免双驱

[场景 C：独立 Game 进程]
  EngineSubsystem         : 仍然存在（GIsEditor 在 -game 时为 false 但 GIsClient 为 true）
                            实际上 ShouldBootstrapAngelscript() 会返回 false，
                            该 Subsystem 不被创建
  GameInstanceSubsystem   : 唯一 Ticker
```

所以"**让位计数**"这个看似简单的设计，正确解决了"Editor 主引擎 + PIE 多个 GameInstance"共享同一个 `FAngelscriptEngine` 时的双驱重复 Tick 问题。

`FAngelscriptEngine::Tick` 自身做三件事（按出现顺序）：

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Core/AngelscriptEngine.cpp
// 函数: FAngelscriptEngine::Tick
// ============================================================================
void FAngelscriptEngine::Tick(float DeltaTime)
{
#if AS_CAN_HOTRELOAD
    if (bScriptDevelopmentMode) {
        // ===== ① Hot Reload Test Runner（开发模式独有）=====
        if (GEngine != nullptr && HotReloadTestRunner != nullptr) { ... }

        // ===== ② 节流的热重载文件检测（每 0.1 秒一次）=====
        if (bUseHotReloadCheckerThread) {
            double CurrentTime = FPlatformTime::Seconds();
            if (NextHotReloadCheck > CurrentTime && !bWaitingForHotReloadResults)
                return;
            NextHotReloadCheck = CurrentTime + 0.1;
        }

        // 区分 PIE / 编辑器模式：PIE 只允许 SoftReload；编辑器允许 FullReload
        if (!GIsEditor || HasGameWorld())
            CheckForHotReload(ECompileType::SoftReloadOnly);
        else
            CheckForHotReload(ECompileType::FullReload);
    }
#endif

#if WITH_AS_DEBUGSERVER
    // ===== ③ 推动 DebugServer 处理网络消息 =====
    if (DebugServer != nullptr)
        DebugServer->Tick();
#endif

    // ★ 防御断言：上一次进入业务代码前 Push 的 ambient world context 必须被清空
    UE_CLOG(GAmbientWorldContext != nullptr, Angelscript, Fatal,
        TEXT("Angelscript world context was improperly restored after use!"));
}
```

---

## 四、Initialize 主流程：四阶段全景

`FAngelscriptEngine::Initialize()` 是整个生命周期最重的一次调用。本节给一份**纯架构视角**的全景骨架，子系统级别的细节（绑定如何执行、初始编译如何选模块）属于其它专题文档。

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Core/AngelscriptEngine.cpp
// 函数: FAngelscriptEngine::Initialize
// 性质: 整个 Runtime 启动的"心脏"，可能耗时数秒
// ============================================================================
void FAngelscriptEngine::Initialize()
{
    // 把"正在 init 的 this"压入 ContextStack；析构时自动 Pop。
    // 这一行保证 PreInitialize_GameThread / Initialize_AnyThread 内部
    // 任何 TryGetCurrentEngine() 调用都能找到自己。
    FAngelscriptEngineScope ScopedInitializingEngine(*this);

    // ==================== 步骤1：游戏线程预初始化 ====================
    PreInitialize_GameThread();
    //  - 安装 AS 对象分配器（asSetAllocScriptObjectFunction）
    //  - 清空线程本地 free-context 池（防止前一 Engine 残留）
    //  - 读取 UAngelscriptSettings (UDeveloperSettings)
    //  - 创建 asCScriptEngine（this->Engine）

    // ==================== 步骤2：可线程化的繁重初始化 ====================
    if (ShouldInitializeThreaded()) {
        // 在高优 Task 上跑 Initialize_AnyThread，
        // 同时 GameThread 自旋 ProcessThreadUntilIdle，让异步加载等回调依然推进。
        AsyncTask(ENamedThreads::AnyHiPriThreadHiPriTask, [&] {
            FGCScopeGuard GCLock;
            Initialize_AnyThread();
        });
        while (!bInitializationDone) { ... }
    } else {
        Initialize_AnyThread();
    }

    // ==================== 步骤3：游戏线程后置 ====================
    PostInitialize_GameThread();
    //  - Broadcast OnInitialCompileFinished 多播委托

    // ==================== 步骤4：注册 SharedState ====================
    InitializeOwnedSharedState();
    //  - 给 Clone 引擎共享底层 asCScriptEngine 提供锚点
}
```

`Initialize_AnyThread`（~270 行）按顺序完成的清单（不是函数调用图，是**值得一记的关键里程碑**）：

```
Initialize_AnyThread 关键里程碑
==============================
[M1] AS Engine 属性集（asEP_*，~20 个开关，控制 unsafe ref / 字符字面量 / GC 策略 ...）
[M2] SetMessageCallback / SetContextCallbacks（错误回调、Context 池接入）
[M3] 启动 DebugServer（仅 bScriptDevelopmentMode 且非 cooked + HasProjectName）
[M4] 启动 CodeCoverage（仅 WITH_AS_COVERAGE 且 CoverageEnabled）
[M5] 加载 BindModules.Cache（动态发现外部 Bind 模块）
[M6] BindScriptTypes() ★ ——144+ Bind_*.cpp 全量绑定
[M7] PrecompiledData 加载（Cooked 路径）/ ReserveStaticNames(7000)（未 Cooked）
[M8] GameThreadTLD->primaryContext = CreateContext()
[M9] InitialCompile() ★ ——预处理 + 解析 + 编译 + ClassGenerator 生成 UClass
[M10] 启动 HotReloadCheckerThread（仅 bScriptDevelopmentMode 且非 Editor）
[M11] OnGetOnScreenMessages 钩子（非 shipping）
[M12] UpdateLineCallbackState（决定 AS VM 是否要触发 line callback）
```

四个里程碑里只有 **M6（BindScriptTypes）** 与 **M9（InitialCompile）** 是真正耗时大头。其余都是配置 / 注册。

---

## 五、生命周期图

把前 4 节合起来，得到 PrimaryEngine 的标准生命周期：

```
FAngelscriptEngine (PrimaryEngine) Lifecycle
│
├─ [1] Module Load                                        // PostDefault 阶段
│   ├─ Trigger: UE 模块装载子系统加载 AngelscriptRuntime
│   ├─ Action : FAngelscriptRuntimeModule::StartupModule  // 仅打 verbose 日志
│   ├─ State  : Engine == nullptr (未创建)
│   └─ Owner  : —
│
├─ [2] Bootstrap (Lazy Create)                            // 取决于环境，三条路径互斥
│   ├─ Trigger: UAngelscriptEngineSubsystem::Initialize   // Editor / Commandlet
│   │           或 UAngelscriptGameInstanceSubsystem::Initialize  // PIE / Game
│   │           或 FAngelscriptRuntimeModule::InitializeAngelscript（Headless）
│   ├─ Action : 选定 OwnedEngine 字段，Push 到 ContextStack
│   ├─ State  : 对象存在，但 Engine->ScriptEngine == nullptr
│   └─ Owner  : 对应 Subsystem 的 UPROPERTY 字段（GC 可见）
│
├─ [3] Initialize (Heavy)                                 // 一次性、可能数秒级
│   ├─ Trigger: 上一步立即调用 Engine->Initialize()
│   ├─ ★ PreInitialize_GameThread + Initialize_AnyThread + PostInitialize_GameThread
│   │   12 个里程碑（见 §4）
│   ├─ State  : Initialized & Ready，bIsInitialCompileFinished = true
│   └─ Side   : Broadcast OnInitialCompileFinished 多播委托
│
├─ [4] Active (Per-frame Tick)                            // 由 Subsystem.Tick 驱动
│   ├─ Driver : EngineSubsystem.Tick（无 GameInstance 时）
│   │           或 GameInstanceSubsystem.Tick（有 GameInstance 时）
│   ├─ Inside : Hot Reload 节流检测 + DebugServer.Tick + AmbientWorldContext 防御
│   └─ State  : Steady（贯穿整个进程主循环）
│
├─ [5] Shutdown                                           // Subsystem.Deinitialize 触发
│   ├─ Trigger: UAngelscriptEngineSubsystem::Deinitialize
│   │           或 UAngelscriptGameInstanceSubsystem::Deinitialize
│   ├─ Order  : 先 Pop ContextStack -> 再 Engine->Shutdown()
│   ├─ ★ Engine->Shutdown 内部:
│   │      释放 DebugServer / StaticJIT / PrecompiledData
│   │      释放 PrimaryContext / GlobalContextPool
│   │      清理 UASClass 上的 ScriptTypePtr / OwnerScriptEngine
│   │      若有 SharedState 则按引用计数延后释放
│   │      asCScriptEngine::ShutDownAndRelease()
│   └─ State  : Engine == nullptr，与新建状态等价
│
└─ [6] Module Unload                                      // 进程退出时
    ├─ Trigger: FAngelscriptRuntimeModule::ShutdownModule
    ├─ Action : 若 OwnedPrimaryEngine 仍存在则 Pop + Reset
    └─ State  : ContextStack 应为空（否则触发 ensure）
```

---

## 六、可观测性与可测试性约定

自动化测试入口按所有权分成两类：`FAngelscriptRuntimeModule` 仍保留模块路由测试 hook；`UAngelscriptSubsystem` 只暴露生产生命周期，测试引擎通过 Test 模块持有的 scope 进入正常 ambient-engine 路径：

```text
RuntimeModule 暴露
  - SetInitializeOverrideForTesting(TFunction<FAngelscriptEngine*()>)
  - ResetInitializeStateForTesting()        // 清空 bInitializeAngelscriptCalled

EngineSubsystem 不暴露测试 API
  - Test 创建 FAngelscriptEngine
  - Test 用 FAngelscriptEngineScope 声明 ambient engine
  - UAngelscriptSubsystem::EnsurePrimaryEngineInitialized()
      通过 TryGetCurrentEngine() 采用它，但不取得所有权

ContextStack 暴露
  - SnapshotAndClear() / RestoreFromSnapshot()
                                            // 测试用例可临时清空全局栈再恢复
```

**含义**：需要测试 RuntimeModule 路由时可以使用它自己的 stub 工厂；需要测试 Subsystem 时则激活真实或 scan-free test engine 的 `FAngelscriptEngineScope`，通过生产入口验证采用、幂等和 fallback 行为。Subsystem 不再接受测试 locator、初始化 callback 或启动环境覆盖。

日志方面，三层启动流程都会打 `[RuntimeStartup]` / `[EngineSubsystemStartup]` / `[EngineLifecycle]` 前缀的日志：

```
[RuntimeStartup] StartupModule.
[RuntimeStartup] InitializeAngelscript begin.
[EngineSubsystemStartup] Created owned primary engine=0x....
[EngineLifecycle] Shutdown engine=0x... id='...' owns=true ...
```

定位"Engine 是被谁、何时创建/释放"的问题，先 grep 这三个前缀。

---

## 七、几条容易踩的坑

1. **`FAngelscriptEngine::Get()` 在 Bootstrap 之前会 check 失败**
   - 触发条件：在 PostDefault 模块装载阶段就直接拿 Engine，但当时 Bootstrap 还没跑。
   - 错误日志：`[EngineResolve] Get() failed: no engine available. ... Likely missing FAngelscriptEngineScope in the calling context.`
   - 正确做法：要么 `TryGetCurrentEngine()` 容忍 nullptr；要么调 `FAngelscriptRuntimeModule::InitializeAngelscript()` 显式拉起。

2. **不要用 `new FAngelscriptEngine` 自建实例并 Push 到 ContextStack**
   - 该结构体内部成员是 USTRUCT 的 `UPROPERTY()`，必须有 UObject Outer 才能被 GC 正确扫到。Subsystem 把它作为 UProperty 字段就是出于这个原因。
   - 测试场景下确需自建时，使用 `FAngelscriptEngineScope`（RAII），它会在析构时正确 Pop。

3. **PIE 期间 Editor 的 EngineSubsystem 看似"不再 Tick"**
   - 这不是 bug，是 `HasAnyTickOwner()` 的让位机制（§3）。如果你想在 PIE 期间观察 Editor 主引擎的 Tick 行为，要么先确认 `ActiveTickOwners > 0`，要么 hook `GameInstanceSubsystem.Tick`。

4. **`GAmbientWorldContext` 在 Tick 末尾必须为 null**
   - `Tick` 末尾的 `UE_CLOG(... Fatal, ...)` 会直接 crash 整个进程。
   - 真凶通常是某段业务代码 `AssignWorldContext(world)` 后没有走 `FAngelscriptEngineScope` RAII 而是直接遗忘。所有"切换世界上下文"的代码都应该用 RAII Scope。

5. **`InitializeAngelscript()` 是幂等的，但只防"完整入口"重复**
   - `Subsystem.EnsurePrimaryEngineInitialized()` 也是幂等的，但它们的 sentinel 各自独立。极少数情况下手动同时驱动两个 sentinel 时要意识到这点。

---

## 小结

- **三层架构**：`FAngelscriptEngine`（重对象）/ Editor 与 GameInstance 两个 Subsystem（编排者）/ `FAngelscriptEngineContextStack`（全局当前指针），各司其职。
- **统一入口 + 自动路由**：业务代码只需调 `FAngelscriptRuntimeModule::InitializeAngelscript()`，Module 内部依据 `GEngine` / `GIsEditor` / `IsRunningCommandlet` 自动选 Bootstrap 路径，并把所有权交给最合适的 Subsystem。
- **Tick 让位**：`UAngelscriptGameInstanceSubsystem::ActiveTickOwners` 计数让 EngineSubsystem 在 PIE / Game 期间自觉闭嘴，避免重复驱动。
- **生命周期 RAII 化**：`FAngelscriptEngineScope` 接管"谁是当前 Engine"和"当前 World 上下文"两件事的成对 Push/Pop，是所有正确性的基础。
- **可测试性是设计目标**：三层都暴露 `*ForTesting` API，用以模拟 Editor/Commandlet 环境、注入 stub Engine、清空全局栈。详见 `Test_RuntimeInternal.md`。
