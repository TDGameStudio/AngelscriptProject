# Note_InternalsEngineFactory — Internals 引擎工厂分析

> **所属前缀**: Note_（零散笔记族）
> **关注层面**: 站在"工厂角色"视角盘点插件里"谁在生产 `FAngelscriptEngine` 实例"——把分散在 Runtime / Subsystem / RuntimeModule / Test 模块四处的创建路径串成一条链，说明每条路径产出什么档位的引擎、构造参数从哪里来、与 `UAngelscriptEngineSubsystem` 如何接合；不重写 `Arch_RuntimeLifecycle.md` 的三层架构总览，不重写 `RT_GlobalState.md` 的 ContextStack 与 ambient world 细节，不重写 `Test_Infrastructure.md` 的 Helper 矩阵
> **关键源码**:
> `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.h` (~62-100 行 `FAngelscriptEngineConfig` / `FAngelscriptEngineDependencies` / `Create`)
> · `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.cpp` (~563-657 行 `FromCurrentProcess` / `CreateDefault` / 默认 ctor / `Create`、~849-938 行 `InitializeWithoutInitialCompile`)
> · `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngineSubsystem.{h,cpp}` (~63 / ~205 行 `EnsurePrimaryEngineInitialized` 与 `*ForTesting` 注入点)
> · `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptRuntimeModule.cpp` (~108 行 `InitializeAngelscript` / `OwnedPrimaryEngine`)
> · `Plugins/Angelscript/Source/AngelscriptTest/Shared/AngelscriptTestEngine.{h,cpp}` (~50 / 144 行 `FAngelscriptTestEngine::Create`)
> · `Plugins/Angelscript/Source/AngelscriptTest/AngelscriptTestModule.cpp` (~60 行 `bUseScanFreeStartupEngine` 注入路径)
> · `Plugins/Angelscript/Source/AngelscriptTest/Core/AngelscriptEngineDependencyInjectionTests.cpp` (~261 行 `Create` 的 D8 契约用例)
> **关联文档**:
> `Documents/Knowledges/ZH/Arch_RuntimeLifecycle.md` — 三层架构与三条 Bootstrap 路径（本文是其"工厂面"补集）
> · `Documents/Knowledges/ZH/RT_GlobalState.md` §四 — 多 Engine 并存的隔离矩阵（本文给出"创建一侧"的对应实现）
> · `Documents/Knowledges/ZH/Test_Infrastructure.md` §二 — 四档引擎的 Test 视角（本文从 Runtime 视角验证它实际只有两条 Initialize 分支）
> · `Documents/Knowledges/ZH/Note_InterfaceBinding.md` — 同族笔记格式参考

---

## 概览

本文聚焦一个核心问题：**`Plugins/Angelscript` 里到底有没有一个叫 `AngelscriptEngineFactory` 的类？如果没有，"创建一个 `FAngelscriptEngine`"这件事是被谁、用什么参数、走哪条分支完成的？多个调用方（Subsystem / RuntimeModule / Test 模块）共享同一组工厂代码吗？**

答案先剧透：**整个 codebase 里没有 `*EngineFactory*` 这种命名的文件或类**——`Glob "**/*EngineFactory*"` 与 `grep "EngineFactory"` 在 `Plugins/Angelscript/` 下零命中。"工厂角色"由四件分散的代码合力承担：`FAngelscriptEngine::Create` 是真正的统一入口；`FAngelscriptEngineConfig::FromCurrentProcess` + `FAngelscriptEngineDependencies::CreateDefault` 提供默认参数；`FAngelscriptTestEngine::Create` 在 Test 模块里加一层薄壳翻一个旗子；最后 `UAngelscriptEngineSubsystem` 在生产路径上**绕开** `Create`、直接持有一份 USTRUCT 字段做 owner。

```text
=========================================================================
   "AngelScript Engine 工厂"的真实构成（按调用方→实现的 4 件套）
=========================================================================

  调用方                       工厂入口                  实际产出
  ──────                       ────────                  ─────────

 ┌───────────────────────┐    ┌──────────────────────┐  ┌───────────┐
 │ UAngelscriptEngine-   │───►│ &OwnedEngine          │─►│ Production│
 │ Subsystem::Initialize │    │ (USTRUCT 字段)        │  │ Full      │
 │ (Editor / Commandlet) │    │ + Initialize()        │  │ Engine    │
 └───────────────────────┘    └──────────────────────┘  │ (full     │
                                                          │  scan +   │
 ┌───────────────────────┐    ┌──────────────────────┐  │  initial  │
 │ FAngelscriptRuntime-  │───►│ MakeUnique<F...>()   │─►│  compile) │
 │ Module::InitializeAS  │    │ + Initialize()        │  │           │
 │ (Headless 兜底)       │    │  (走默认 ctor →        │  └───────────┘
 └───────────────────────┘    │   FromCurrentProcess  │
                              │   + CreateDefault)     │  ┌───────────┐
 ┌───────────────────────┐    └──────────────────────┘  │ Test Full │
 │ FAngelscriptTest-     │    ┌──────────────────────┐  │ Engine    │
 │ Engine::Create        │───►│ FAngelscriptEngine:: │─►│ (no scan, │
 │ (Spec / Helper / Pool)│    │   Create(LocalCfg,   │  │  no .as   │
 └───────────────────────┘    │   Deps)               │  │  compile) │
                              │   ★ bSkipInitial-     │  └───────────┘
                              │     Compile=true      │
                              │   → InitializeWithout │
                              │     InitialCompile()  │
                              └──────────────────────┘
                                         ▲
                                         │ 共用同一个 Create
 ┌───────────────────────┐               │
 │ AngelscriptEditor 测  │───────────────┘
 │ 试 (DI 验证)          │   FAngelscriptEngine::Create(Config, Deps) 直调
 │                       │   常显式设置 Config.bIsEditor = true
 └───────────────────────┘

 ┌───────────────────────┐    ┌──────────────────────┐  ┌───────────┐
 │ AngelScriptSDK 测试    │───►│ asCreateScriptEngine │─►│ Bare AS   │
 │ (绕开整个插件)         │    │   (ANGELSCRIPT_      │  │ engine    │
 │                       │    │    VERSION)          │  │ (无 UE 绑定)│
 └───────────────────────┘    └──────────────────────┘  └───────────┘
```

**四个观察**：

- **唯一的"运行时分发器"是 `FAngelscriptEngine::Create`**——只有它会按 `Config.bSkipInitialCompile` 在 `Initialize()` / `InitializeWithoutInitialCompile()` 之间二选一。
- Subsystem 的"主用 Engine"路径**不**走 `Create`，而是直接对 USTRUCT 字段 `OwnedEngine` 调 `Initialize()`——绕过 `Create` 的目的就是让 GC 跟着 `UEngineSubsystem` 走，**不引入额外的所有权层**。
- Test 模块没有自己的"独立工厂"，`FAngelscriptTestEngine::Create` 是 12 行的薄壳，唯一职责是把 `bSkipInitialCompile` 默认设为 `true`，再委托给 `FAngelscriptEngine::Create`。
- "Test 四档引擎"（`Test_Infrastructure.md` §二）是 Test 视角的概念分层，**Runtime 层只看到两条 Initialize 分支**——这是后文 §三 / §四的关键。

后续按 (一) 现状清单 → (二) `FAngelscriptEngine::Create` 与两条 Initialize 分支 → (三) `FAngelscriptEngineConfig` 与 `Dependencies` 的默认体系 → (四) Subsystem 的"绕开 Create"路径 → (五) 多 Engine 并存场景下谁来 new → (六) 限制与设计取舍 → 附录速查表。

---

## 一、现状清单：codebase 里"创建 Engine"的入口一共多少个

`Plugins/Angelscript/` 下"产生一个 `FAngelscriptEngine` 实例"的代码点共 4 类：

| 入口 | 文件 | 触发场景 | 经过 `Create` 吗 |
|------|------|---------|-----------------|
| `&UAngelscriptEngineSubsystem::OwnedEngine` + `Initialize()` | `AngelscriptEngineSubsystem.cpp:128-135` | Editor / Commandlet bootstrap | ✗（直接调 `Initialize`） |
| `MakeUnique<FAngelscriptEngine>()` + `Initialize()` | `AngelscriptRuntimeModule.cpp:79-82` | Headless / 早期阶段兜底 | ✗（默认 ctor + `Initialize`） |
| `FAngelscriptEngine::Create(Config, Deps)` 直调 | `AngelscriptEditor/Tests/*.cpp` (~18 处) / `AngelscriptTest/Core/*Tests.cpp` (~5 处) | DI / 配置变体 / 编辑器 helper 单测 | ✓ |
| `FAngelscriptTestEngine::Create(Config, Deps)` | 几乎所有 CQTest spec / `AngelscriptTestEnginePool` / `AngelscriptTestModule.cpp` | Test Full engine 与 shared engine | ✓（薄壳→ `Create`） |
| `asCreateScriptEngine(ANGELSCRIPT_VERSION)` | `AngelscriptTestSupport::CreateBareScriptEngine` | AngelScriptSDK / Native 测试 | — 完全绕开 |

**最容易被忽略的一点**：生产路径（Subsystem 与 Module 兜底）**不**经过 `FAngelscriptEngine::Create`——它们用嵌入字段或 `MakeUnique<FAngelscriptEngine>()`，相当于走默认构造函数：

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Core/AngelscriptEngine.cpp:619-622
// 角色: 默认构造 = "用 FromCurrentProcess + CreateDefault 拼出生产配置"
// ============================================================================
FAngelscriptEngine::FAngelscriptEngine()
    : FAngelscriptEngine(FAngelscriptEngineConfig::FromCurrentProcess(),
                         FAngelscriptEngineDependencies::CreateDefault())
{
}
```

因此 Subsystem 与 Module 不需要重复"读 CommandLine 标志"——默认 ctor 内部委托给 `FromCurrentProcess()`，生产配置只在一个地方维护。

---

## 二、`FAngelscriptEngine::Create`：唯一的"运行时分发器"

整张工厂图唯一的"分发"决策在 `Create`：

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Core/AngelscriptEngine.cpp:642-657
// 函数: FAngelscriptEngine::Create
// 角色: 唯一的"按配置选 Initialize 分支"入口（OpenSpec D8 契约点）
// ============================================================================
TUniquePtr<FAngelscriptEngine> FAngelscriptEngine::Create(
    const FAngelscriptEngineConfig& InConfig,
    const FAngelscriptEngineDependencies& InDependencies)
{
    TUniquePtr<FAngelscriptEngine> EngineInstance =
        MakeUnique<FAngelscriptEngine>(InConfig, InDependencies);
    UE_LOG(Angelscript, Verbose, TEXT("[EngineLifecycle] Create -> %p (bSkipInitialCompile=%d)"),
        EngineInstance.Get(), InConfig.bSkipInitialCompile ? 1 : 0);

    if (InConfig.bSkipInitialCompile)                  // ★ 唯一的分发条件
        EngineInstance->InitializeWithoutInitialCompile();
    else
        EngineInstance->Initialize();
    return EngineInstance;
}
```

两条分支的差异（来自 `AngelscriptEngine.h` 注释 + 实现观察）：

| 行为 | `Initialize()` | `InitializeWithoutInitialCompile()` |
|------|---------------|------------------------------------|
| 创建 `asCScriptEngine` + 设 properties | ✓ | ✓ |
| `BindScriptTypes()`（144+ Bind_*.cpp） | ✓ | ✓ |
| `AcquireProcessPackages()` | ✓ | ✗（不持有 `/Script/Angelscript` 包引用） |
| 扫描 `ProjectDir/Script/`、`Plugin/*/Script/` | ✓ | ✗ |
| `InitialCompile()`（编译磁盘 .as） | ✓ | ✗ |
| `bIsInitialCompileFinished = true` | 编完后置位 | 立刻置位（绕过编译门） |
| 启动 DebugServer（受 `WITH_AS_DEBUGSERVER`） | 视 `bUsePrecompiledData` 与 `FApp::HasProjectName` | 仅看 `DebugServerPort > 0` |
| 启动 StaticJIT / CodeCoverage | ✓（生产典型路径） | ✗ |

`bSkipInitialCompile` 的意义是**"我要一个绑定齐全、能跑反射，但不背磁盘脚本的引擎"**——典型用例：Test 想用一个干净的 Full engine 跑 in-memory module；Editor helper 单测想验证某段绑定逻辑而不必等 5 秒钟扫盘。

**契约约束**（`AngelscriptEngineDependencyInjectionTests.cpp:220-269`）：当 `bSkipInitialCompile=true` 时，`Dependencies.MakeDirectory` 必须**没被调用过**（生产路径在 `Initialize` 内会 ensure `ProjectDir/Script/` 存在）。这条契约挡住了"测试引擎不小心写盘"。

---

## 三、`FAngelscriptEngineConfig` 与 `Dependencies`：参数与默认体系

### 3.1 Config：一坨布尔旗 + 一个端口号

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Core/AngelscriptEngine.h:62-89
// 类型: FAngelscriptEngineConfig
// 角色: 所有"工厂构造参数"的集中点（一份 POD-like struct）
// ============================================================================
struct ANGELSCRIPTRUNTIME_API FAngelscriptEngineConfig
{
    bool bForceThreadedInitialize    = false;
    bool bSkipThreadedInitialize     = false;
    bool bSkipInitialCompile         = false;   // ★ Create 的唯一分发条件
    bool bSimulateCooked             = false;
    bool bTestErrors                 = false;
    bool bForcePreprocessEditorCode  = false;
    bool bGeneratePrecompiledData    = false;
    bool bDevelopmentMode            = false;
    bool bIgnorePrecompiledData      = false;
    bool bSkipWriteBindDB            = false;
    bool bWriteBindDB                = false;
    bool bExitOnError                = false;
    bool bDumpDocumentation          = false;
    int32 DebugServerPort            = 27099;   // 默认端口；0 表示禁用
    bool bIsEditor                   = false;
    bool bRunningCommandlet          = false;
    TSet<FName> DisabledBindNames;

    static FAngelscriptEngineConfig FromCurrentProcess();
};
```

**没有**像题面提到的"`bEnableDebugServer` / `bEnableStaticJIT` / `bEnableCodeCoverage`"——这些"开关"在 codebase 里其实长这样：

- **DebugServer**：编译期受 `WITH_AS_DEBUGSERVER = (!UE_BUILD_TEST && !UE_BUILD_SHIPPING)` 决定能否编进来；运行期受 `RuntimeConfig.DebugServerPort > 0`（设 0 即禁用）+ `bUsePrecompiledData/bScriptDevelopmentMode` 业务条件 + `FApp::HasProjectName()` 三重 gating。配置面只暴露**端口号**而非布尔。
- **StaticJIT**：编译期受 `WITH_AS_STATIC_JIT` 决定；运行期由 `bUsePrecompiledData` 与 `bGeneratePrecompiledData` 隐式驱动，**Config 里没有专门的 `bEnableStaticJIT` 字段**。
- **CodeCoverage**：编译期 `WITH_AS_COVERAGE = WITH_AS_DEBUGSERVER`；运行期 `FAngelscriptCodeCoverage::CoverageEnabled()` 读控制台 CVar / 命令行——同样**不在 Config 里**。

也就是说，`FAngelscriptEngineConfig` 的实际语义是**"命令行 + 进程环境的快照"**，不是"功能开关清单"。功能模块（DebugServer / StaticJIT / Coverage）有各自独立的开关源（编译宏 / CVar / CommandLine），Config 只暴露其中"启动期必须知道"的少数旗子。

### 3.2 `FromCurrentProcess`：生产路径的默认构造器

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Core/AngelscriptEngine.cpp:563-586
// 函数: FAngelscriptEngineConfig::FromCurrentProcess
// 角色: 把命令行 + 进程环境捕成一份 Config
// ============================================================================
FAngelscriptEngineConfig FAngelscriptEngineConfig::FromCurrentProcess()
{
    FAngelscriptEngineConfig Config;
    Config.bForceThreadedInitialize  = FParse::Param(FCommandLine::Get(), TEXT("as-force-threaded-initialize"));
    Config.bSkipThreadedInitialize   = FParse::Param(FCommandLine::Get(), TEXT("as-skip-threaded-initialize"));
    Config.bSimulateCooked           = FParse::Param(FCommandLine::Get(), TEXT("as-simulate-cooked"));
    /* ... 其余 9 个旗子皆通过 FParse::Param 读 -as-XX 命令行 ... */
    FParse::Value(FCommandLine::Get(), TEXT("-asdebugport="), Config.DebugServerPort);
#if WITH_EDITOR
    Config.bIsEditor = GIsEditor;
#else
    Config.bIsEditor = false;
#endif
    Config.bRunningCommandlet = IsRunningCommandlet();
    return Config;
}
```

读法：**所有 `bXxxx` 旗子都是 `-as-xxxx` 命令行参数的镜像**，外加 `bIsEditor` / `bRunningCommandlet` 由进程环境决定。**`bSkipInitialCompile` 不在 `FromCurrentProcess` 里**——这是生产路径绝不能跳过初始编译的硬约束，旗子只能由 `FAngelscriptTestEngine::Create` 这类显式 wrapper 拨亮。

### 3.3 `Dependencies`：可注入的 I/O Edge

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Core/AngelscriptEngine.h:91-100
// 类型: FAngelscriptEngineDependencies
// 角色: 让单测可以替换文件系统/插件枚举等"外部依赖"
// ============================================================================
struct ANGELSCRIPTRUNTIME_API FAngelscriptEngineDependencies
{
    TFunction<FString()> GetProjectDir;
    TFunction<FString(const FString&)> ConvertRelativePathToFull;
    TFunction<bool(const FString&)> DirectoryExists;
    TFunction<bool(const FString&, bool)> MakeDirectory;
    TFunction<TArray<FString>()> GetEnabledPluginScriptRoots;

    static FAngelscriptEngineDependencies CreateDefault();
};
```

`CreateDefault` 把这些函数指针绑到 `FPaths::ProjectDir` / `IFileManager::Get()` / `IPluginManager::Get().GetEnabledPluginsWithContent()`。Test 用例（如 `RunCreateWithSkipInitialCompileSkipsProductionDirectorySetup`）会**只替换** `MakeDirectory`、`GetEnabledPluginScriptRoots` 几个 lambda，验证生产路径在 `bSkipInitialCompile=true` 时确实不调它们。

---

## 四、Subsystem 的"绕开 Create"路径：为什么 Production 不走分发器

`UAngelscriptEngineSubsystem::EnsurePrimaryEngineInitialized` 是生产路径的核心，它有 **4 个分支**——前三个都是**已存在引擎的 adopt**，只有第四个真正"创建"：

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Core/AngelscriptEngineSubsystem.cpp:79-136
// 函数: UAngelscriptEngineSubsystem::EnsurePrimaryEngineInitialized
// 角色: Editor / Commandlet 的"产生 PrimaryEngine"路径（共 4 分支）
// ============================================================================
void UAngelscriptEngineSubsystem::EnsurePrimaryEngineInitialized()
{
    // 分支 1：已经初始化过 → 仅恢复 ContextStack 上下文
    if (bInitializedPrimaryEngine && PrimaryEngine != nullptr) { /* ★ Push 兜底 */ return; }

#if WITH_DEV_AUTOMATION_TESTS
    // 分支 2：测试注入 → 用 InitializeOverrideForTesting 取一个外部 engine
    if (InitializeOverrideForTesting) {
        if (FAngelscriptEngine* OverrideEngine = InitializeOverrideForTesting()) {
            PrimaryEngine = OverrideEngine;
            bUsesOverridePrimaryEngine = true;
            FAngelscriptEngineContextStack::Push(PrimaryEngine);
        }
        return;
    }
#endif

    // 分支 3：进程里已经有 ambient engine（多见于 Test scope 提前 Push）→ adopt
    if (FAngelscriptEngine* CurrentEngine = FAngelscriptEngine::TryGetCurrentEngine()) {
        PrimaryEngine = CurrentEngine;
        bOwnsPrimaryEngine = false;
        if (PrimaryEngine->GetScriptEngine() == nullptr)
            PrimaryEngine->Initialize();      // ambient engine 还没跑过 Initialize 的话补跑一次
        return;
    }

    // 分支 4：真"创建"——直接对 USTRUCT 字段 OwnedEngine 调 Initialize
    PrimaryEngine = &OwnedEngine;            // ★ 不是 new，不是 Create
    bOwnsPrimaryEngine = true;
    FAngelscriptEngineContextStack::Push(PrimaryEngine);
    PrimaryEngine->Initialize();             // 默认 ctor 已经跑完（USTRUCT 字段构造时）
}
```

**为什么不调 `Create`？** 三层原因：

1. **GC 守护**：`OwnedEngine` 是 `UPROPERTY()`-able 的 USTRUCT 字段，托管在 `UEngineSubsystem` 这个 UObject 内。这样 `FAngelscriptEngine` 内部的 `UPROPERTY` 字段（`AngelscriptPackage` / `AssetsPackage` / `WorldContextObject`）受 UE GC 直接保护，无需额外 root。如果走 `Create` 拿 `TUniquePtr` 就脱离了 UObject 生命周期。
2. **生产路径必须走 `Initialize()`**：`bSkipInitialCompile` 在生产路径上**不允许**为 `true`——生产引擎必须扫盘并完整初始编译。绕开 `Create` 同时也绕开了"分发"逻辑，避免误用。
3. **配置来源单一**：`OwnedEngine` 是默认构造，自动走 `FromCurrentProcess + CreateDefault`，配置面只在一处维护。

**测试注入点**：分支 2 的 `InitializeOverrideForTesting` 让 `AngelscriptTestModule.cpp` 可以在 `-AngelscriptTestUseScanFreeStartupEngine` 命令行下提前 `FAngelscriptTestEngine::Create` 一个 scan-free engine 并注入：

```cpp
// 文件: AngelscriptTest/AngelscriptTestModule.cpp:36-47（节选）
if (FParse::Param(..., TEXT("AngelscriptTestUseScanFreeStartupEngine"))) {
    GAngelscriptTestStartupOverrideEngine =
        AngelscriptTestSupport::CreateScriptScanFreeFullEngineForTesting(
            CreateEditorScanFreeStartupConfig(), FAngelscriptEngineDependencies::CreateDefault());
    UAngelscriptEngineSubsystem::SetInitializeOverrideForTesting(
        []() -> FAngelscriptEngine* { return GAngelscriptTestStartupOverrideEngine.Get(); });
}
```

这条路径让自动化测试不必等 Editor 启动时跑完整 `InitialCompile`。

---

## 五、多 Engine 并存场景下：谁来 new 第二个

回到题面：哪些场景会创建第二个 Engine？盘 codebase 后只剩 3 类：

| 场景 | 创建路径 | 第二个 Engine 的所有者 |
|------|---------|----------------------|
| **PIE** | **不创建** | 复用 Editor 主 Engine（`UAngelscriptGameInstanceSubsystem::Initialize` adopt 现有 engine，只 ++ActiveTickOwners 抢 Tick 主导权） |
| **Test 隔离 Full Engine** | `FAngelscriptTestEngine::Create(...)` | 测试 Spec 的局部 `TUniquePtr<FAngelscriptEngine>`（`AcquireTransientFullTestEngine` / `CreateIsolatedFullEngine`） |
| **Test 共享 Engine** | 同上一行 | `AngelscriptTestSupport::GetSharedTestEngineStorage()` 静态变量持有的单例 |
| **Test Engine Pool** | 同上一行 | `FAngelscriptTestEnginePool::Get()` 内部复用 GetSharedEngine（仍然是单例，`SourceEngineCreateCount` 只计数，没有真正"池化多实例"） |
| **Headless Commandlet 兜底** | `MakeUnique<FAngelscriptEngine>()` | `FAngelscriptRuntimeModule::OwnedPrimaryEngine` static |
| **AngelscriptEditor 单测** | `FAngelscriptEngine::Create` 直调 | 测试函数局部 `TUniquePtr` |

**结论**：**生产部署里始终只有一个 `FAngelscriptEngine`**——PIE 不开第二个。多 Engine 是 Test-only 现象。这与 `RT_GlobalState.md` §四的隔离矩阵一致：那张表里"两类多 Engine 并存场景"分别是"Editor 主 + PIE"（实际是 1 个）与"Test 多 Engine"（真有 N 个）。

---

## 六、当前限制与设计取舍

### 6.1 工厂分散是历史选择，不是技术债

观察现状会想问"为什么不把这 4 件套塞进一个 `AngelscriptEngineFactory` 类"？答案是**没有必要**：

- `Create` + `FromCurrentProcess` + `CreateDefault` 已经构成**单一逻辑入口**（即使分散在两个 struct 的静态方法上）。
- 生产路径绕开 `Create` 是**有意为之**——为的是 GC 守护与所有权一致，不是"还没来得及统一"。
- Test 模块的 `FAngelscriptTestEngine::Create` 是**意图标签**而非另一套实现，本质上是 12 行委托。

把这些塞进一个名为 `AngelscriptEngineFactory` 的类反而会引入额外的命名空间与所有权语义，且会模糊"生产路径不走 Create"这一关键不变量。

### 6.2 D8 契约：`bSkipInitialCompile` 是新增的硬约束

OpenSpec `refactor-as-engine-clone-removal` 的 D8 节专门为 `Create` 引入了 `bSkipInitialCompile` 旗子。在此之前，"测试用 Full engine"是通过现已删除的 `Clone` 机制构造的——克隆一份 binding state 但不重新扫盘。Clone 移除后，"既要 Full 又不扫盘"的语义转写成了一个 Config 旗子。

实际可见的契约残痕：

- `FAngelscriptTestEngine::Create` 的注释明确点名 OpenSpec D8（`AngelscriptTestEngine.cpp:24`）。
- `RunCreateWithSkipInitialCompileSkipsProductionDirectorySetup` 是对该契约的回归断言（`AngelscriptEngineDependencyInjectionTests.cpp:220-269`）。
- `AngelscriptEngine.h:66-71` 注释写明"D8 契约 + 测试 wrapper 边界"。

如果未来加新的 Initialize 分支，最该改的就是 `Create` 的 `if/else`——只有这一个地方分发。

### 6.3 半实现 / 可改进点

- **没有"Cooked-only" Config preset**：`bSimulateCooked` 是命令行旗子，需要测试代码自己设；codebase 内没有 `FromCookedProcess()` 这种命名工厂方法，目前靠测试 helper 自己组合 Config。
- **`InitializeOverrideForTesting` 只覆盖 Subsystem**：Module 兜底路径（Path C，`OwnedPrimaryEngine`）也有同名 hook，但两者**不会同时生效**——Module 路径检测到 `EngineSubsystem` 存在就 return（见 `RuntimeModule.cpp:57-62`）。Test 想覆盖 Module 路径必须先把 Subsystem 干掉。
- **没有"DebugServer-disabled" Config preset**：要禁用 DebugServer 必须显式 `Config.DebugServerPort = 0`。如果忘了写，端口默认是 27099——多个并发 Test engine 会抢同一端口（实测会让第 N+1 个 Engine 的 listen 失败但不致命）。

---

## 附录 A：Engine 变体速查

| 变体名（约定俗成） | 创建入口 | Config 关键字段 | Initialize 分支 | DebugServer | 产出对象类型 |
|----|----|----|----|----|----|
| Production Full（Editor 主引擎） | Subsystem 分支 4 / `OwnedEngine` | 默认 ctor → `FromCurrentProcess` | `Initialize()` | 视配置 | USTRUCT 字段（embedded） |
| Production Full（Headless 兜底） | `RuntimeModule.cpp:79` `MakeUnique<>` | 同上 | `Initialize()` | 视配置 | `TUniquePtr` (Module static) |
| **Test Full（Scan-Free）** | `FAngelscriptTestEngine::Create` | **`bSkipInitialCompile=true`** | `InitializeWithoutInitialCompile()` | 视配置（默认仍开） | `TUniquePtr` (caller-owned) |
| Test Shared Singleton | 同上，但走 `GetSharedEngine` | 同上 | 同上 | 同上 | static `TUniquePtr` (TestSupport) |
| AngelscriptEditor Helper Test | `FAngelscriptEngine::Create` 直调 | 视用例（常 `bIsEditor=true`） | 任意分支 | 视配置 | `TUniquePtr` |
| Override-injected | `SetInitializeOverrideForTesting` 注入 | 由 lambda 决定 | 任意（已构造完毕） | 由 lambda 决定 | 由 lambda 持有 |
| **Bare AS engine（绕开插件）** | `asCreateScriptEngine` | — | 不适用 | 无 | `asCScriptEngine*`（非 `FAngelscriptEngine`） |

**注意 1**："Test 四档"（`Test_Infrastructure.md` §二.1：`SharedClone` / `IsolatedFull` / `ProductionLike` / `Native`）是 Test 视角；本表对应关系是 SharedClone+IsolatedFull → "Test Full（Scan-Free）"两行；ProductionLike → 复用 Production Full；Native → Bare AS engine。

**注意 2**：表里没有"Cooked-only Engine"作为独立变体——Cooked 由命令行 `-as-simulate-cooked` 或编译宏 `UE_BUILD_SHIPPING` 决定，不属于"另一档引擎"，只是同一个 `Initialize()` 路径上的几条 if 分支。

---

## 附录 B：`FAngelscriptEngineConfig` 字段速查

下表列出 16 个 Config 字段、命令行映射、默认值与"在哪条分支被读"。

| 字段 | 命令行 | 默认值 | 影响位置 |
|------|--------|-------|---------|
| `bForceThreadedInitialize` | `-as-force-threaded-initialize` | `false` | `Initialize()` 的 `ShouldInitializeThreaded` |
| `bSkipThreadedInitialize` | `-as-skip-threaded-initialize` | `false` | 同上 |
| `bSkipInitialCompile` | （无）| `false` | **`Create` 分发** |
| `bSimulateCooked` | `-as-simulate-cooked` | `false` | `bUseEditorScripts` 计算 |
| `bTestErrors` | `-as-test-errors` | `false` | 错误注入 |
| `bForcePreprocessEditorCode` | `-as-force-preprocess-editor-code` | `false` | `bUseEditorScripts` 计算 |
| `bGeneratePrecompiledData` | `-as-generate-precompiled-data` | `false` | StaticJIT / 预编译产出 |
| `bDevelopmentMode` | `-as-development-mode` | `false` | `bScriptDevelopmentMode` |
| `bIgnorePrecompiledData` | `-as-ignore-precompiled-data` | `false` | 不加载 .ascomp |
| `bSkipWriteBindDB` | `-as-skip-write-bind-db` | `false` | BindDB 写盘 |
| `bWriteBindDB` | `-as-write-bind-db` | `false` | 同上反向 |
| `bExitOnError` | `-as-exit-on-error` | `false` | 编译错误时退出 |
| `bDumpDocumentation` | `-dump-as-doc` | `false` | DumpDocumentation hook |
| `DebugServerPort` | `-asdebugport=N` | `27099` | DebugServer 监听 |
| `bIsEditor` | （进程环境）| `GIsEditor` (WITH_EDITOR) | `bUseEditorScripts` / `bScriptDevelopmentMode` |
| `bRunningCommandlet` | （进程环境）| `IsRunningCommandlet()` | 同上 |
| `DisabledBindNames` | （编程方式）| 空集 | `CollectDisabledBindNames` |

**没有的字段**（题面提到但实际不存在，记一笔以免误用）：

- `bEnableDebugServer`：用 `DebugServerPort = 0` 来禁用。
- `bEnableStaticJIT`：由 `bGeneratePrecompiledData` + 预编译数据存在性 + 编译宏共同决定。
- `bEnableCodeCoverage`：由 `FAngelscriptCodeCoverage::CoverageEnabled()` 读 CVar，不在 Config 里。

---

## 附录 C：决策树——我应该用哪个入口建 Engine？

```text
我要建一个 FAngelscriptEngine
        │
        ├─ 是 Production 代码（runtime / editor 模块、不属于测试）？
        │       │
        │       ├─ Editor / Commandlet：交给 UAngelscriptEngineSubsystem
        │       │       └─ 直接调 FAngelscriptRuntimeModule::InitializeAngelscript()
        │       │          剩下的它会路由到 EnsurePrimaryEngineInitialized
        │       └─ Headless / 极早期：同上，会走 Path C 兜底
        │
        ├─ 是 AutomationTest / CQTest spec？
        │       │
        │       ├─ 共享 + reset modules：FAngelscriptTestEngine::GetSharedEngine
        │       ├─ 隔离 Full：AcquireTransientFullTestEngine / CreateIsolatedFullEngine
        │       │             （内部都走 FAngelscriptTestEngine::Create）
        │       └─ ProductionLike：AcquireProductionLikeEngine（复用真生产 engine）
        │
        ├─ 是 AngelscriptEditor Helper 单测 / DI 验证？
        │       └─ FAngelscriptEngine::Create(Config, Deps) 直调
        │          常见组合：Config.bIsEditor = true; bSkipInitialCompile 视用途
        │
        └─ 是 AngelscriptSDK / Native 测试，**不需要 UE 反射**？
                └─ asCreateScriptEngine(ANGELSCRIPT_VERSION)
                   返回的是 asCScriptEngine*，不挂 FAngelscriptEngine
```

---

## 小结

- 整个 codebase **没有** `AngelscriptEngineFactory` 这个类——"工厂角色"由 `FAngelscriptEngine::Create` + `FAngelscriptEngineConfig::FromCurrentProcess` + `FAngelscriptEngineDependencies::CreateDefault` + `FAngelscriptTestEngine::Create` 四件分散代码联合承担。
- **真正的"分发器"只有 `FAngelscriptEngine::Create`**，唯一分发条件是 `Config.bSkipInitialCompile`。Initialize 分支只有两条：完整 `Initialize()` 与 `InitializeWithoutInitialCompile()`。
- **生产路径绕开 `Create`**——`UAngelscriptEngineSubsystem` 与 `FAngelscriptRuntimeModule` 通过默认构造 + 直接 `Initialize()` 拿 USTRUCT 字段或 `TUniquePtr` 所有权，这是为了 GC 守护与禁止 `bSkipInitialCompile` 在生产路径开启的双重约束。
- **多 Engine 并存只发生在 Test 场景**——PIE 复用 Editor 主引擎，不创建新 engine。Subsystem 的 `InitializeOverrideForTesting` 是唯一允许"在 production-shaped 路径上注入预构造引擎"的口子。
- "Test 四档引擎"是 Test 视角的概念分层，Runtime 层只看到两条 Initialize 分支与一个共享单例。
- Config 字段是**命令行旗子的镜像**而非"功能开关清单"——DebugServer / StaticJIT / Coverage 各有自己的开关源（编译宏 / CVar / `DebugServerPort`），Config 只暴露启动期必需的几枚旗子。
