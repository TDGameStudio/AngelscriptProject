# Test_Infrastructure — 测试基础设施与 Helper

> **所属前缀**: Test_（测试架构族）
> **关注层面**: `AngelscriptTest/Shared/` 与 `Template/` 提供的 Helper 与教学样板，按职能拆解谁负责什么、彼此如何串起来（不再重述模块分层 / 主题目录 / 单条用例的实现细节）
> **关键源码**:
> `Plugins/Angelscript/Source/AngelscriptTest/Shared/AngelscriptTestEngine.{h,cpp}` (~50 / 144 行)
> · `Shared/AngelscriptTestUtilities.h` (~1100 行)
> · `Shared/AngelscriptTestEngineHelper.{h,cpp}` (~65 / 750 行)
> · `Shared/AngelscriptTestEnginePool.h` (~270 行)
> · `Shared/AngelscriptTestMacros.h` (~73 行)
> · `Shared/AngelscriptTestWorld.h` (~159 行)
> · `Shared/AngelscriptFunctionalTestUtils.h` (~155 行)
> · `Shared/AngelscriptBindings{Coverage,ModuleBuilder,Assertions,ExampleSection}.h`
> · `Shared/AngelscriptReflectiveAccess.h` (~1100 行)
> · `Shared/AngelscriptGlobalFunctionInvoker.h` (~440 行)
> · `Shared/AngelscriptDebuggerTest{Session,Client,Monitor,Context,Helpers}.h`
> · `Shared/AngelscriptLearningTrace.{h,cpp}`
> · `Shared/AngelscriptNative{ScriptTestObject,InterfaceTestHelpers,InterfaceTestTypes}.h`
> · `Shared/AngelscriptCollisionTestHelpers.h` · `Shared/AngelscriptPerformanceTestUtils.h`
> · `Template/Template_{CQTest,WorldTick,GameLifetime,GlobalFunctions,ReflectionAccess,Blueprint,BlueprintWorldTick}.cpp` (7 份)
> · `AngelscriptTest/AngelscriptTestModule.cpp` (~60 行)
> **关联文档**:
> `Documents/Knowledges/ZH/Test_Layering.md` — 模块三层骨架（本文是其 Helper 视角的延伸）
> · `Documents/Knowledges/ZH/Note_CQTest.md` — CQTest 框架使用笔记（本文不重复其原理，只引用宏与 hook 时机）
> · `Documents/Knowledges/ZH/Arch_EditorTestDumpCollaboration.md` §二 — Editor / Test / Dump 的 Helper 大类总览
> · `Documents/Knowledges/ZH/Arch_ErrorDiagnostics.md` §二 — 编译诊断收集链路（FAngelscriptCompileTraceSummary 的上游）
> · `Documents/Knowledges/ZH/RT_GlobalState.md` §五 — Engine reset 协议（本文给出 Helper 视角的调用约定）
> · `Documents/Knowledges/ZH/RT_CodeCoverage.md` §七 — Coverage Helper 的协同路径
> **外部参考**:
> [Epic CQTest 文档](https://dev.epicgames.com/documentation/zh-cn/unreal-engine/cqtest-test-framework-for-unreal-engine)
> · `Plugins/Angelscript/Source/AngelscriptTest/Shared/README_MACROS_ZH.md` — 宏速查（模块内部）

---

## 概览

本文聚焦一个核心问题：**`AngelscriptTest/Shared/` 的 40+ Helper 文件与 `Template/` 的 7 份样板，各自承担测试执行链上的哪一节，它们之间如何配合让一条 Spec 在 200 行以内就跑起一套"建引擎 → 编脚本 → 起世界 → 跑帧 → 比对断言 → 还原状态"的完整链路？**

这是 P5 Test_ 族的第二篇。它**不**重述 `AngelscriptTest` 模块的物理目录与 Build.cs 边界（去 `Test_Layering.md`）；**不**展开 CQTest 的宏定义与 `BEFORE_ALL/AFTER_ALL` 实现机制（去 `Note_CQTest.md`）；**不**逐 case 解释主题目录测什么（去 `Test_TopicClusters.md`，待写）。它只回答"Helper 层长什么样"。

```text
                 ┌──────────────────────────────────────────────────────┐
                 │  UE Automation Framework + CQTest TEST_CLASS_WITH_FLAGS │
                 │   ▼  TEST_METHOD body                                │
                 └────┬─────────────────────────────────────────────────┘
                      │ 1. 取引擎
        ┌─────────────┼──────────────────────────────────────┐
        ▼             ▼              ▼                        ▼
 ┌──────────────┐ ┌─────────────┐ ┌─────────────┐ ┌────────────────────┐
 │ FAngelscript │ │ AcquireTrans│ │ AcquirePro- │ │ asCreateScriptEng- │
 │ TestEngine:: │ │ ientFullTest│ │ ductionLike │ │ ine(ANGELSCRIPT_   │
 │ GetSharedEng │ │ Engine()    │ │ Engine()    │ │ VERSION)           │
 │ (共享 + reset)│ │ (隔离 Full) │ │ (跑时优先) │ │ (原生 SDK)         │
 └──────┬───────┘ └─────┬───────┘ └─────┬───────┘ └─────────┬──────────┘
        │ ASTEST_       │ ASTEST_       │ FResolved          │ ASTEST_
        │ CREATE/GET    │ CREATE_       │ ProductionLike     │ CREATE_
        │ _ENGINE       │ ENGINE_FULL   │ Engine             │ ENGINE_NATIVE
        ▼               ▼               ▼                    ▼
 ┌────────────────────────────────────────────────────────────────────┐
 │  2. 编脚本 → 取模块                                               │
 │   AngelscriptTestSupport::BuildModule()  /  CompileModuleFromMemory │
 │      / CompileAnnotatedModuleFromMemory  / CompileModuleWithSummary │
 │   FCoverageModuleScope (RAII，自动 DiscardModule)                  │
 └────┬───────────────────────────────────────────────────────────────┘
      │ 3. 起世界（可选）
      ▼
 ┌────────────────────────────────────────────────────────────────────┐
 │  FAngelscriptTestWorld (FActorTestSpawner + EngineScope) +         │
 │  AngelscriptFunctionalTestUtils::TickWorld / BeginPlayActor        │
 └────┬───────────────────────────────────────────────────────────────┘
      │ 4. 调脚本 / 反射读写
      ▼
 ┌────────────────────────────────────────────────────────────────────┐
 │  FFunctionInvoker          (UFUNCTION + ProcessEvent / RuntimeCall) │
 │  FASGlobalFunctionInvoker  (asIScriptContext SetArg / Execute)      │
 │  AngelscriptReflectiveAccess (GetByPath / GetStructByPath / ...)    │
 │  ExpectGlobalInt / ExpectGlobalReturnCustom / ExpectBindingCompile- │
 │     Failure  (一行一断言)                                           │
 └────┬───────────────────────────────────────────────────────────────┘
      │ 5. 收尾
      ▼
 ┌────────────────────────────────────────────────────────────────────┐
 │  FCoverageModuleScope::~  / Engine.DiscardModule                   │
 │  ASTEST_RESET_ENGINE / FAngelscriptTestEngine::ResetModules        │
 │  CleanupDetachedASTypesForGarbageCollection + CollectGarbage       │
 └────────────────────────────────────────────────────────────────────┘
```

后续章节按"Helper 大类清单 → FAngelscriptTestEngine → ScriptRoot 注入 → Spec 命名宏 → 断言扩展 → Diagnostic / Trace → 截图 / Coverage 协同 → 引擎池 → Reset 仪式 → Template 层"的顺序推进，最后用三张速查表与一棵决策树收口。

---

## 一、Helper 大类清单

`Shared/` 目录是 Helper 层的唯一物理落点（参见 `Test_Layering.md` §一）。按职能拆开，40+ 文件可以归为**九大类**，与 `Arch_EditorTestDumpCollaboration.md` §二 给出的"Test 的 Helper 大类"一一对应：

| 大类 | 关键头文件 | 一句话职能 | 主要消费方 |
|------|-----------|-----------|----------|
| **A. Engine 启动与 reset** | `AngelscriptTestEngine.{h,cpp}` / `AngelscriptTestUtilities.h` / `AngelscriptTestEnginePool.h` / `AngelscriptTestMacros.h` | 共享 / 隔离 / 完整 / 原生四档引擎 + 引擎池 + Reset 仪式 | 几乎所有 Spec |
| **B. Spec 命名宏** | `AngelscriptTestMacros.h` / `AngelscriptTestLegacyHelpers.h` | `ASTEST_CREATE_/GET_/RESET_ENGINE` 等四档 + 11 个 legacy `ASTEST_COMPILE_RUN_*` | CQTest spec / 旧 IMPLEMENT_SIMPLE 文件 |
| **C. 编译与诊断** | `AngelscriptTestEngineHelper.{h,cpp}` | `CompileModuleFromMemory` / `CompileAnnotatedModuleFromMemory` / `CompileModuleWithSummary` / `FAngelscriptCompileTraceSummary` | Compiler / Bindings / Syntax 主题 |
| **D. World 与 Actor** | `AngelscriptTestWorld.h` / `AngelscriptFunctionalTestUtils.h` / `AngelscriptCollisionTestHelpers.h` | 三档 Tick 驱动 + Spawn + BeginPlay + 碰撞箱拼装 | Functional/* / HotReload |
| **E. CQTest 绑定覆盖** | `AngelscriptBindingsCoverage.h` / `AngelscriptBindingsModuleBuilder.h` / `AngelscriptBindingsAssertions.h` / `AngelscriptBindingsExampleSection.h` | `FBindingsCoverageProfile` / `FCoverageModuleScope` / `ExpectGlobalInt` 一行断言族 | Bindings/* (90 文件主战场) |
| **F. 反射与函数调用** | `AngelscriptReflectiveAccess.h` / `AngelscriptGlobalFunctionInvoker.h` | 路径读写 + UFUNCTION 调用 + AS 全局函数调用 | 全主题 |
| **G. Native / SDK 适配** | `AngelscriptNativeScriptTestObject.h` / `AngelscriptNativeInterfaceTestHelpers.h` / `AngelscriptNativeInterfaceTestTypes.h` / `AngelscriptConstructionContextProbe.h` | 给 AngelScriptSDK 与 Native 测试用的样本 UObject / Interface | AngelScriptSDK/ / Bindings/ |
| **H. Debugger 体系** | `AngelscriptDebuggerTest{Session,Client,Monitor,Context,Helpers}.h` / `AngelscriptDebuggerScriptFixture.h` / `AngelscriptMockDebugServer.h` | 真实 socket session / mock session / 异步监视 / 脚本 fixture | Debugger/* |
| **I. 性能 / 教学** | `AngelscriptPerformanceTestUtils.h` / `AngelscriptLearningTrace.{h,cpp}` | JSON 性能产物 + 结构化 trace 输出 | Performance/ / Learning/ |

`Arch_EditorTestDumpCollaboration.md` §二.4 给出的口径"Test 的 Helper 大类已部分覆盖"指的就是这套：那篇文章关注 **Editor → Test → Dump 三方边界**，本文则把视角切到 **Test 内部的 Helper 拆分**。两文边界：哪些 Helper 写在 Test 模块、哪些必须 Editor only、哪些不能跨进 Runtime——以 `Test_Layering.md` §二（Build.cs）为准；本文只展开"已经允许在 Test 模块里写"的那部分。

---

## 二、FAngelscriptTestEngine：四档引擎的产生器

### 2.1 概念分层

`AngelscriptTest` 给 Spec 提供**四档引擎**，从重到轻：

```text
档位          | 工厂入口                                   | 何时使用
------------- | ----------------------------------------- | ------------
ProductionLike| AngelscriptTestSupport::                  | 需要复用 GameInstance 子系统
              |   AcquireProductionLikeEngine             | 拥有的真实运行时引擎
SharedClone   | FAngelscriptTestEngine::GetSharedEngine() | 默认；CQTest BEFORE_ALL 取一次
              |   + ResetModules                          | TEST_METHOD 间靠 ResetModules 复位
IsolatedFull  | AngelscriptTestSupport::                  | 引擎核心自测、bind 环境验证、
              |   AcquireTransientFullTestEngine          | hot reload 端到端
Native        | asCreateScriptEngine(ANGELSCRIPT_VERSION) | AngelScriptSDK / Native 测试，
              |                                           | 不挂 FAngelscriptEngine
```

`FAngelscriptTestEngine` 是 SharedClone 与 IsolatedFull 两档的**统一产生器**——以前曾有 `Clone` 概念，现在被裁掉，所有 test 引擎都是经 `FAngelscriptEngine::Create` 走"跳过初始编译"分支创建的 Full engine。其核心实现：

```cpp
// ============================================================================
// 文件: AngelscriptTest/Shared/AngelscriptTestEngine.cpp
// 函数: FAngelscriptTestEngine::Create / GetSharedEngine
// 角色: 把 bSkipInitialCompile=true 的 Full engine 集中到一处构造
// ============================================================================
TUniquePtr<FAngelscriptEngine> FAngelscriptTestEngine::Create(
    const FAngelscriptEngineConfig& Config,
    const FAngelscriptEngineDependencies& Dependencies)
{
    FAngelscriptEngineConfig LocalConfig = Config;
    LocalConfig.bSkipInitialCompile = true;          // ★ 不扫盘、不编 .as
    return FAngelscriptEngine::Create(LocalConfig, Dependencies);
}

FAngelscriptEngine& FAngelscriptTestEngine::GetSharedEngine()
{
    auto& SharedEngineStorage = AngelscriptTestSupport::GetSharedTestEngineStorage();
    auto& SharedScopeStorage  = AngelscriptTestSupport::GetSharedTestEngineScopeStorage();
    if (!SharedEngineStorage.IsValid())
    {
        FAngelscriptEngineDependencies Dependencies = FAngelscriptEngineDependencies::CreateDefault();
        SharedEngineStorage = FAngelscriptTestEngine::Create(FAngelscriptEngineConfig(), Dependencies);
        // ★ "持久 scope"：让共享引擎一直是 current engine，省去每条 case 自建 scope
        SharedScopeStorage = MakeUnique<FAngelscriptEngineScope>(*SharedEngineStorage);
    }
    return *SharedEngineStorage;
}
```

要点：

- `bSkipInitialCompile = true` 是 **test-only Full engine 的本质开关**——它绑定 UE/AS 类型表、把"初始编译门"标记为完成，但**不扫描** project / plugin Script root，也**不编磁盘 `.as` 文件**。Spec 想要什么脚本，自己用 `BuildModule` 喂进去。
- 共享引擎背后有一个**持久 `FAngelscriptEngineScope`**——这避免 Spec 每条 case 都得 `FAngelscriptEngineScope Scope(Engine)`。
- `ResetModules` 是配套的"清场"操作（详见 §九）。

### 2.2 与 Production 引擎的差异

`FAngelscriptEngine` 在 Production（编辑器或运行时）里由 `UAngelscriptEngineSubsystem` 拥有；测试用的同型实例与之的区别：

| 维度 | Production | Test (`FAngelscriptTestEngine::Create`) |
|------|-----------|---------------------------------------|
| `bSkipInitialCompile` | false（默认） | **true**（强制） |
| Script root 扫描 | 扫 `Script/` 与 plugin script root | **不扫**——脚本由 Spec 显式喂入 |
| 启动期 .as 编译 | 跑 cooked-style 编译 | **跳过**——首批 case 立即可用 |
| 持有方 | `UAngelscriptEngineSubsystem` 或 `GameInstanceSubsystem` | `TUniquePtr` 在 `Shared/` 命名空间存储里 |
| 当前 engine scope | subsystem owns | 共享 case 由"持久 scope"代管 |
| Debugger | 与 GameInstance 一致 | 测试自己用 `FAngelscriptDebuggerTestSession` 起独立 |

> 一句话：测试引擎是把 Production 引擎的"启动包袱"全部省掉，只保留"类型表 + VM + 编译入口"的最小可执行实例。它跟 cooked target 的运行时引擎不是同一个对象，不存在交叉污染。

### 2.3 ProductionLike：跑时优先

少量 case 必须跑在**真正的 GameInstance 引擎**上（典型如 Subsystem 的 Blueprint 节点查询、网络复制）。`AcquireProductionLikeEngine` 实现"如果当前进程已经有 production 引擎就用它，否则现取一个 Full engine"：

```cpp
// 节选自: AngelscriptTest/Shared/AngelscriptTestUtilities.h: AcquireProductionLikeEngine
inline bool AcquireProductionLikeEngine(FAutomationTestBase& Test, const TCHAR* ErrorContext, FResolvedProductionLikeEngine& OutResolved)
{
    if (FAngelscriptEngine* ProductionEngine = TryGetRunningProductionEngine())
    {
        OutResolved.Engine = ProductionEngine;
        OutResolved.EngineScope = MakeUnique<FAngelscriptEngineScope>(*ProductionEngine);
        return true;                            // ★ 直接搭车
    }
    DestroySharedTestEngine();                  // 让出 SharedClone 名额
    OutResolved.OwnedEngine = CreateFullTestEngine();
    OutResolved.Engine = OutResolved.OwnedEngine.Get();
    OutResolved.EngineScope = MakeUnique<FAngelscriptEngineScope>(*OutResolved.Engine);
    return true;
}
```

副产品 `FAngelscriptTestFixture(Test, ETestEngineMode::ProductionLike)` 把这个流程包成 RAII 对象，相当于一行代码切到"跑时模式"。

---

## 三、ScriptRoot 注入：测试用脚本怎么进编译范围

`FAngelscriptTestEngine::Create` 关闭了 script root 扫描（§二.1），那 Spec 写出的临时 `.as` 怎么进入 Engine 的视野？答案分两种路径：

### 3.1 In-memory：直接构造 ModuleDesc

绝大多数 spec 走这条路。`AngelscriptTestSupport::BuildModule` 把脚本内容写成临时文件，再喂给 Preprocessor + `Engine.CompileModules`：

```cpp
// 节选自: AngelscriptTest/Shared/AngelscriptTestUtilities.h: BuildModule
inline asIScriptModule* BuildModule(FAutomationTestBase& Test, FAngelscriptEngine& Engine, const char* ModuleName, const FString& Source)
{
    const FString UniqueFilename = FString::Printf(TEXT("%s_%s.as"), *RequestedModuleName, *FGuid::NewGuid().ToString(...));
    const FString AbsoluteFilename = FPaths::Combine(FPaths::ProjectSavedDir(), TEXT("Automation"), UniqueFilename);
    IFileManager::Get().MakeDirectory(*FPaths::GetPath(AbsoluteFilename), true);
    FFileHelper::SaveStringToFile(Source, *AbsoluteFilename);            // ★ 写盘到 Saved/Automation
    FAngelscriptEngineScope EngineScope(Engine);
    FAngelscriptPreprocessor Preprocessor;
    Preprocessor.AddFile(RelativeFilename, AbsoluteFilename);
    if (!Preprocessor.Preprocess()) { /* report diagnostics */ return nullptr; }
    TArray<TSharedRef<FAngelscriptModuleDesc>> ModulesToCompile = Preprocessor.GetModulesToCompile();
    Engine.CompileModules(ECompileType::Initial, ModulesToCompile, CompiledModules);   // ★ 复用主编译入口
    return CompiledModules[0]->ScriptModule;
}
```

要点：

- 文件落到 `Saved/Automation/<ModuleName>_<Guid>.as`——所有测试 .as 集中在一个临时目录，互不干扰。
- 走的是**与 production 完全相同的 `FAngelscriptPreprocessor` + `Engine.CompileModules` 链路**，不绕过任何编译路径；这保证 Spec 验证的是真实编译行为。
- `ModuleDesc` 的 `RelativeFilename` 一律前缀 `Automation/`——这让 Diagnostic 收集（§六）能识别哪些诊断是测试触发的。

### 3.2 On-disk：临时改写 `Engine->AllRootPaths`

少数 spec 需要测"扫盘 → 找文件 → 编译"的链路（典型如 `CompileModuleFromDiskPath`，验证某个 hot reload 行为）。Helper 用 `ON_SCOPE_EXIT` 临时替换 `AllRootPaths`：

```cpp
// 节选自: AngelscriptTest/Shared/AngelscriptTestEngineHelper.cpp: CompileModuleFromDiskPath
const FString RootPath = FPaths::GetPath(NormalizedAbsolutePath);
const TArray<FString> PreviousRoots = Engine->AllRootPaths;
ON_SCOPE_EXIT { Engine->AllRootPaths = PreviousRoots; };          // ★ 还原
Engine->AllRootPaths = { RootPath };                              // ★ 临时只指向目标目录

TArray<FAngelscriptEngine::FFilenamePair> DiskFiles;
Engine->FindAllScriptFilenames(DiskFiles);
// ...
```

关键点：

- 这条路径**复用 production 的 `FindAllScriptFilenames`**——也就是说测试可以验证"如果 root 是 X，那么 engine 看得到的文件清单是 Y"这种端到端断言。
- `ON_SCOPE_EXIT` 保证测试结束后 `AllRootPaths` 立刻还原，不会污染下一条 case。

### 3.3 测试用例内的 scan-free engine

需要避免磁盘脚本扫描时，由 CQTest fixture 自己创建 scan-free engine：

```cpp
TUniquePtr<FAngelscriptEngine> Engine = CreateScriptScanFreeFullEngineForTesting(
    FAngelscriptEngineConfig(), FAngelscriptEngineDependencies::CreateDefault());
FAngelscriptEngineScope Scope(*Engine);
```

这个 engine 属于当前测试 fixture，测试结束时由 `TUniquePtr` 和 `FAngelscriptEngineScope` 自动清理。它不会被 `UAngelscriptSubsystem` 采用，也不会影响生产引擎的启动生命周期。

---

## 四、Spec 命名宏：四档引擎的入口与历史 legacy

`Shared/AngelscriptTestMacros.h` 定义的四个宏，是 Spec 文件**唯一应该使用的引擎获取方式**。

```cpp
// ============================================================================
// 文件: AngelscriptTest/Shared/AngelscriptTestMacros.h
// 角色: 测试引擎获取宏（CQTest 标准模式）
// ============================================================================

#define ASTEST_CREATE_ENGINE() \
    ([]() -> FAngelscriptEngine& { \
        FAngelscriptEngine& Engine = FAngelscriptTestEngine::GetSharedEngine(); \
        FAngelscriptTestEngine::ResetModules(Engine);                            \
        return Engine; \
    }())                                                          // BEFORE_ALL 用

#define ASTEST_GET_ENGINE() \
    FAngelscriptTestEngine::GetSharedEngine()                     // TEST_METHOD 用，不 reset

#define ASTEST_CREATE_ENGINE_FULL() \
    AngelscriptTestSupport::AcquireTransientFullTestEngine()      // 隔离 Full

#define ASTEST_CREATE_ENGINE_NATIVE() \
    asCreateScriptEngine(ANGELSCRIPT_VERSION)                     // 原生 SDK

#define ASTEST_RESET_ENGINE(Engine) \
    FAngelscriptTestEngine::ResetModules(Engine)                  // AFTER_ALL 用
```

### 4.1 CQTest 标准模式

CQTest 与四档引擎的协同写法（已经在 `Note_CQTest.md` §三 与 README_MACROS_ZH.md 里讲过，本文只摘要）：

```cpp
TEST_CLASS_WITH_FLAGS(F<X>Test, "Angelscript.TestModule.<Theme>", flags)
{
    BEFORE_ALL() { ASTEST_CREATE_ENGINE(); }                         // 全类一次
    AFTER_ALL()  { FAngelscriptEngine& E = ASTEST_GET_ENGINE();
                    ASTEST_RESET_ENGINE(E); }                        // 全类一次
    TEST_METHOD(Foo)
    {
        FAngelscriptEngine& Engine = ASTEST_GET_ENGINE();            // 不 reset
        FAngelscriptEngineScope Scope(Engine);                       // 显式声明 current engine
        FCoverageModuleScope Mod(*TestRunner, Engine, GProfile,
            TEXT("Foo"), TEXT(R"( int F() { return 42; } )"));       // 模块 RAII
        ExpectGlobalInt(*TestRunner, Engine, Mod.GetModule(),
            GProfile, TEXT("int F()"), TEXT("returns 42"), 42);
    }
};
```

要点（对应 `Test_Layering.md` §四.2）：

- `BEFORE_ALL/AFTER_ALL` 是**静态成员**，整个类一次。
- `TEST_METHOD` 之间靠 `FCoverageModuleScope` 析构时 `DiscardModule` 实现"模块隔离"——不需要每个 case 重置整个 engine。
- 显式 `FAngelscriptEngineScope Scope(Engine)` 仍然推荐写出来——共享 engine 虽然有持久 scope（§二.1），但显式 scope 可读性更好。

### 4.2 已 archived 的"Test macro optimization"

`AGENTS.md` "Recently Completed Milestones" 里的 `Test macro optimization (BEGIN/END, SHARE_CLEAN/SHARE_FRESH, group closure)` 在历史上做了三件事，已**全部 archived**：

1. 把分散在各 spec 文件里的 `Engine.GetCurrentEngine() / Engine.DiscardModule(...)` 样板抽进 `ASTEST_GET_ENGINE / ASTEST_RESET_ENGINE` 宏。
2. 把"shared clean"与"shared fresh"两套语义合并——现在只剩 `ASTEST_CREATE_ENGINE`（reset on acquire）与 `ASTEST_GET_ENGINE`（不 reset），不再区分 SHARE_CLEAN/SHARE_FRESH。
3. 关掉 group-level `BEGIN_/END_` 宏——CQTest 的 `TEST_CLASS_WITH_FLAGS + BEFORE_ALL + AFTER_ALL` 已经覆盖了 group 闭合语义。

**新写测试不需要也不能再用 `BEGIN_/END_/SHARE_CLEAN/SHARE_FRESH`**——它们不存在了。如果在 grep 里看到这类痕迹，那是历史日志（`Documents/Guides/TestMacroStatus.md`）记录，对应文件已迁移完毕。

### 4.3 Legacy 宏：仅供 11 个旧文件

```cpp
// 节选自: AngelscriptTest/Shared/AngelscriptTestLegacyHelpers.h: ASTEST_COMPILE_RUN_INT
#define ASTEST_COMPILE_RUN_INT(Engine, ModuleName, Source, FuncDecl, OutResult) \
    do { \
        asIScriptModule* _Module = AngelscriptTestSupport::BuildModule(*this, Engine, ModuleName, Source); \
        if (_Module == nullptr) { return false; } \
        asIScriptFunction* _Function = AngelscriptTestSupport::GetFunctionByDecl(*this, *_Module, FuncDecl); \
        if (_Function == nullptr) { return false; } \
        if (!AngelscriptTestSupport::ExecuteIntFunction(*this, Engine, *_Function, OutResult)) { return false; } \
    } while (false)
```

它内部用 `return false`，**与 CQTest 的 `TEST_METHOD`（return void）不兼容**。约 11 个还没迁到 CQTest 的 `IMPLEMENT_SIMPLE_AUTOMATION_TEST` 文件保留它，新代码一律用 `FCoverageModuleScope + ExpectGlobalInt`。

---

## 五、断言扩展：相对 UE Automation 的增强

### 5.1 一行一断言：`ExpectGlobalInt` 族

`Shared/AngelscriptBindingsAssertions.h` 是相对 UE 自带 `TestEqual / TestTrue` 的关键扩展。它把"找 AS 函数 → 准备 context → 执行 → 比对返回值 → 写 case label"五步压成一行。完整族表：

| Helper | 期望返回类型 | 何时用 |
|--------|-------------|-------|
| `ExpectGlobalInt` | `int32` | 默认整型 case |
| `ExpectGlobalIntAtLeast` | `int32`（>=） | 阈值断言 |
| `ExpectGlobalBool` | `bool` | AS 把 0/1 当 bool 返回 |
| `ExpectGlobalDouble` / `ExpectGlobalReturnFloat` | `double` / `float`（带 tolerance） | 浮点比较 |
| `ExpectGlobalReturnBool` | `bool F()` | 直接返回 bool 的 AS 函数 |
| `ExpectGlobalReturnCustom<T>` | 任意 USTRUCT | Validator lambda 自由断言 |
| `ExpectGlobalInts` | 数组 | 一组同型 case 批量验证 |
| `ExpectBindingCompileFailure` | 编译期失败 | 验证某绑定面"故意不存在" |
| `ExecuteFunctionExpectingScriptException` | 异常 | 验证 AS 抛指定异常子串 |

### 5.2 AS context 信息打印

最关键的差异是**失败时的诊断信息**。普通 `TestEqual(TEXT("..."), Actual, Expected)` 只能打印两个值；`ExpectGlobalInt` 在内部多做两件事：

1. `Test.AddInfo(FormatCaseLabel(Profile, CaseLabel))`——把 `[Container] Optional Empty Get fallback` 这种**带 profile 的 case label** 写进 Automation log，所以即便整组通过，log 里也有可读的 trace。
2. 失败时把 AS 函数的**完整 declaration** 拼进失败描述：`%s (decl=%s)`。比如 `[Container] Foo (decl=int Bar(const TArray<int>&))`，定位时直接 grep declaration。

`ExecuteFunctionExpectingScriptException` 更进一步——它一次断言**五件事**：

```cpp
// 节选自: AngelscriptBindingsAssertions.h: ExecuteFunctionExpectingScriptException（精简）
const int PrepareResult  = Context->Prepare(Function);
const int ExecuteResult  = Context->Execute();
const FString ExceptionString = UTF8_TO_TCHAR(Context->GetExceptionString());
const int32 ExceptionLine     = Context->GetExceptionLineNumber();

bPassed &= Test.TestEqual(  /* 1 */ "Prepare success", PrepareResult, asSUCCESS);
bPassed &= Test.TestEqual(  /* 2 */ "asEXECUTION_EXCEPTION", ExecuteResult, asEXECUTION_EXCEPTION);
bPassed &= Test.TestFalse(  /* 3 */ "non-empty exception string", ExceptionString.IsEmpty());
bPassed &= Test.TestTrue(   /* 4 */ "contains substring",  ExceptionString.Contains(ExpectedExceptionContains));
bPassed &= Test.TestTrue(   /* 5 */ "positive exception line", ExceptionLine > 0);
Test.AddInfo(FString::Printf(TEXT("%s raised at line %d: %s"), *Label, ExceptionLine, *ExceptionString));
```

这套五元组确保任何"AS 应抛指定异常"的 case 不会因为单字段被吞而漏检。

### 5.3 `FBindingsCoverageProfile` 与 watch 自动注入

`AngelscriptBindingsCoverage.h` 定义的 `FBindingsCoverageProfile` 看似只是几个字符串字段，实际承担了**模块名 + case label + log category**三合一职责：

```cpp
struct FBindingsCoverageProfile
{
    const TCHAR* Theme = TEXT("");          // [Container] 这种主题段
    const TCHAR* Variant = TEXT("");        // [Container/ConstRef] 这种变体段
    const TCHAR* ModulePrefix = TEXT("");   // ASContainer_<SectionName>，参与构造模块名
    const TCHAR* CasePrefix = TEXT("");     // case label 前缀
    const TCHAR* LogCategory = TEXT("");    // 预留给 Learning trace
};
```

`MakeCoverageModuleName(Profile, "Optional")` → `"ASContainer_Optional"`（无 variant）或 `"ASContainer_ConstRef_Optional"`（有 variant）。这套约定在 §三.1 提到的 `Saved/Automation/<ModuleName>_<Guid>.as` 文件名里也能看到——**写盘文件名带 profile + variant 段**，多 variant 跑同一组 case 时不会互相覆盖。

---

## 六、Diagnostic 收集：FAngelscriptCompileTraceSummary

`Arch_ErrorDiagnostics.md` §二 给出了**编译诊断收集**的全链路（runtime 层的 `FAngelscriptEngine::Diagnostics` 表）。Test 这边的对偶是 `FAngelscriptCompileTraceSummary`：

```cpp
// 节选自: AngelscriptTest/Shared/AngelscriptTestEngineHelper.h
struct FAngelscriptCompileTraceDiagnosticSummary
{
    FString Section;
    int32   Row = 0;
    int32   Column = 0;
    bool    bIsError = false;
    bool    bIsInfo = false;
    FString Message;
};

struct FAngelscriptCompileTraceSummary
{
    bool    bCompileSucceeded = false;
    ECompileType   CompileType = ECompileType::SoftReloadOnly;
    ECompileResult CompileResult = ECompileResult::Error;
    bool    bUsedPreprocessor = false;
    int32   ModuleDescCount = 0;
    int32   CompiledModuleCount = 0;
    TArray<FString> ModuleNames;
    TArray<FString> AbsoluteFilenames;
    TArray<FAngelscriptCompileTraceDiagnosticSummary> Diagnostics;
};
```

调用者：`CompileModuleWithSummary` / `CompileModuleWithResult` / `AnalyzeReloadFromMemory`。这三个函数的核心实现——`CollectCompileTraceDiagnostics`：

```cpp
// 节选自: AngelscriptTest/Shared/AngelscriptTestEngineHelper.cpp: CollectCompileTraceDiagnostics
for (const FString& AbsoluteFilename : AbsoluteFilenames)
{
    if (const FAngelscriptEngine::FDiagnostics* Diagnostics = Engine.Diagnostics.Find(AbsoluteFilename))
    {
        for (const FAngelscriptEngine::FDiagnostic& Diagnostic : Diagnostics->Diagnostics)
        {
            FAngelscriptCompileTraceDiagnosticSummary& Summary = OutDiagnostics.AddDefaulted_GetRef();
            Summary.Section = AbsoluteFilename;
            Summary.Row     = Diagnostic.Row;
            Summary.Column  = Diagnostic.Column;
            Summary.bIsError = Diagnostic.bIsError;
            Summary.bIsInfo  = Diagnostic.bIsInfo;
            Summary.Message  = Diagnostic.Message;
        }
    }
}
```

也就是**把 Engine 内部的 `Diagnostics` map 按测试关心的若干 absolute filename 切出来，转成易序列化的 POD**——便于 spec 在断言里直接 `Summary.Diagnostics.ContainsByPredicate(...)`，不必再去 grep `Engine.Diagnostics`。

`ExpectBindingCompileFailure`（§五.1）正是上层消费方：它先 `Engine.Diagnostics.Empty()`，再 `CompileModuleWithSummary`，最后断言诊断列表里**包含某条 Error 子串**。

### 6.1 与 Syntax 主题的协同

`AngelscriptTest/Syntax/AngelscriptSyntaxTestHelpers.h` 是另一个消费方——它把 `FAngelscriptCompileTraceSummary` 包装成更窄的 `ExpectSyntaxAcceptance` / `ExpectSyntaxRejection` 等 helper（不在 Shared/，但同族）。这一层职责见 `Test_TopicClusters.md`（待写），本文不展开。

---

## 七、Screenshot Helper 与 CodeCoverage Helper 的协同

### 7.1 截图 Helper

当前 `Shared/` **没有专门的截图 Helper**——`Note_ScreenshotTestHelper.md`（待写）会落 UE 自带 `FAutomationScreenshotConfig` / `Take(High|Editor)Screenshot` 的接入约定。本文只点出协同点：

- AngelscriptTest **不在 Helper 头文件里依赖任何 Editor 截图 API**，因为 `AngelscriptEditor` 是 private + bBuildEditor 守卫依赖（`Test_Layering.md` §二.4）。
- 真实截图回归落在 Editor 模块自己的 `AngelscriptEditor/Tests/` 下，对应 `Angelscript.Editor.*` 前缀，和 Shared/ 没有交叉。
- 之后如果需要 Test 模块自己产出截图（例如 Widget 主题），将通过 `Functional/Widget/` 直接调 `FAutomationScreenshotConfig`，不需要新增 Shared/ Helper——保持 Helper 层"轻头"原则。

### 7.2 CodeCoverage Helper

`RT_CodeCoverage.md` §七 描述了 coverage 的 hooks 安装方式：`FAngelscriptCodeCoverage::AddTestFrameworkHooks` 在 engine init 后挂上 `FAutomationTestFramework::OnTestStart/OnTestEnd`。Shared/ 这边的协同点只有一处：

- `AngelscriptTest/Core/AngelscriptCodeCoverageTests.cpp` 是 coverage 的回归落点。它既可以用 `ASTEST_CREATE_ENGINE_FULL`（隔离 Full）启停 coverage，也可以验证 hook 在 production engine 上的行为。
- **Shared/ 不暴露专用的 coverage helper**——coverage 的入口在 Runtime 层 `FAngelscriptCodeCoverage`，Test 直接调即可，没必要再包一层。

这两块都符合"Helper 层只做 cross-theme reuse"的原则——单主题独占的 setup 留在该主题目录里。

---

## 八、ProductionLikeEngine 池：避免每个 Spec 重建 Engine

`Shared/AngelscriptTestEnginePool.h` 是性能优化层。`FAngelscriptTestModule::StartupModule` 调一次 `StartupTestEnginePool(bPrewarmEngine)`，然后整个 suite 共享池。

### 8.1 池子的核心模型

```text
FAngelscriptTestEnginePool (singleton)
   │
   ├── PrewarmSourceEngine()   ← 命令行 -AngelscriptTestPrewarmEngine
   │     创建 / 取共享 engine（GetOrCreateSharedCloneEngine）
   │
   ├── AcquireModuleCleanEngine()
   │     给模块清洁请求一个引擎（实际就是 Prewarm）
   │
   ├── CaptureSnapshot(Engine) → FAngelscriptTestEngineModuleSnapshot
   │     记录"基线模块名集合"
   │
   ├── CleanupModuleCleanEngine(Engine, Baseline)
   │     扫 ActiveModules + 原生 RawModules，对每个不在 baseline 里的模块
   │     调 DiscardModule + DeleteDiscardedModules
   │     调 CleanupDetachedASTypesForGarbageCollection
   │     每 N 次 cleanup 触发一次 CollectGarbage
   │
   └── Metrics（FAngelscriptTestEnginePoolMetrics）
         记 SourceEngineCreateCount / ModuleCleanCount / GarbageCollectCount
         + 各类 detached 类型清理计数 / 最近一次时长
```

### 8.2 `FScopedModuleCleanEngine` RAII

最常被 spec 直接使用的是这个 RAII：

```cpp
// 节选自: AngelscriptTest/Shared/AngelscriptTestEnginePool.h: FScopedModuleCleanEngine
struct FScopedModuleCleanEngine
{
    explicit FScopedModuleCleanEngine(FAngelscriptEngine& InEngine)
        : Engine(InEngine)
        , Baseline(FAngelscriptTestEnginePool::Get().CaptureSnapshot(InEngine)) {}      // ★ 进入时拍快照
    ~FScopedModuleCleanEngine()
    { FAngelscriptTestEnginePool::Get().CleanupModuleCleanEngine(Engine, Baseline); }   // ★ 退出时只擦"新增"的模块
};
```

- **基线之上的增量回滚**：先 `CaptureSnapshot` 记下当前活跃模块名 + 原生模块名，析构时只丢这之后新增的——比 `ResetModules` 一次性整盘清要轻得多。
- 适合"shared clone 上跑一组连续 case，case 之间只有少量模块差异"的场景，性能远优于"每次 reset"。
- **不**取代 `ASTEST_RESET_ENGINE`——它是 reset 的局部替代品；CQTest 的 `AFTER_ALL` 仍然推荐显式 reset。

### 8.3 性能基线

`Documents/Guides/TestPerformance.md` 给出过完整数字。结论：

- 无 prewarm：首批 spec 约 1500-2000 ms 等 engine 创建；池开起来后摊到 50-200 ms。
- `FScopedModuleCleanEngine` 的 cleanup 平均 < 5 ms（`Metrics.LastModuleCleanSeconds` 字段记录），相比 `ResetModules` 的 30-100 ms 是数量级的差距。

> 设计决策：**默认引擎池开 prewarm**，命令行 `-AngelscriptTestPrewarmEngine` 是 opt-in；headless / -nullrhi 场景倾向 opt-out 以省启动时间。具体策略见 `Documents/Guides/Test.md`。

---

## 九、Engine reset 仪式：Helper 怎么调 RT_GlobalState

`RT_GlobalState.md` §五 描述了"engine reset 协议"——它是 Runtime 层的契约，Helper 这边的实现就是 `FAngelscriptTestEngine::ResetModules`：

```cpp
// 节选自: AngelscriptTest/Shared/AngelscriptTestEngine.cpp: ResetModules
void FAngelscriptTestEngine::ResetModules(FAngelscriptEngine& Engine)
{
    const TArray<TSharedRef<FAngelscriptModuleDesc>> ActiveModules = Engine.GetActiveModules();
    for (const TSharedRef<FAngelscriptModuleDesc>& Module : ActiveModules)
        Engine.DiscardModule(*Module->ModuleName);                     // ★ 1) ModuleDesc 层

    if (asCScriptEngine* ScriptEngine = reinterpret_cast<asCScriptEngine*>(Engine.GetScriptEngine()))
    {
        // 收集 + 丢弃 raw AS modules
        for (asUINT i = 0; i < ScriptEngine->GetModuleCount(); ++i) { /* DiscardModule */ }
        ScriptEngine->DeleteDiscardedModules();                        // ★ 2) AS 内核层
    }

    // 3) 处理"detached" UASClass / UASStruct / UEnum / UDelegateFunction
    AngelscriptTestSupport::CleanupDetachedASTypesForGarbageCollection(&ActiveModules);

    CollectGarbage(RF_NoFlags, true);                                  // ★ 4) UE GC
}
```

四步顺序固定，不能乱：

1. **`Engine.DiscardModule(ModuleDesc.ModuleName)`** —— 走 production 编译入口注册的 dispatch 表，丢 ModuleDesc 与挂在它上面的 generated UClass / UStruct / UEnum 等。
2. **`asCScriptEngine::DiscardModule + DeleteDiscardedModules`** —— 还会有 ModuleDesc 没 cover 到的 raw AS module（典型如直接 `Engine->GetScriptEngine()` 创出来的）；这层兜底。
3. **`CleanupDetachedASTypesForGarbageCollection`** —— 把 `ScriptTypePtr == nullptr` 的 `UASClass` / `UASStruct` 解 `RF_Standalone` + `RemoveFromRoot`，并清 Editor 下 `FBlueprintActionDatabase` 的 cached actions。
4. **`CollectGarbage(RF_NoFlags, true)`** —— 真正回收。

### 9.1 为什么不直接 `Engine.Reset()`

- 共享 engine 全程要保留**类型表 / Bind 数据库 / VM 实例**——只换"用户代码"那一层。
- `FAngelscriptEngine::Reset` 不存在（有意为之）；外部观察者只能走 `DiscardModule` 这条公开 API。
- Editor 下 `FBlueprintActionDatabase` 会缓存 spawner 持有 generated UClass 的强引用——第 3 步专门清这部分。

### 9.2 与 `AcquireTransientFullTestEngine` 的差异

```cpp
// 节选自: AngelscriptTest/Shared/AngelscriptTestUtilities.h: AcquireTransientFullTestEngine
TUniquePtr<FAngelscriptEngine>& TransientFullEngine = GetTransientFullTestEngineStorage();
if (TransientFullEngine.IsValid())
{
    const TArray<TSharedRef<FAngelscriptModuleDesc>> ModulesBeforeReset = TransientFullEngine->GetActiveModules();
    TransientFullEngine.Reset();                                                    // ★ 整把丢
    CleanupDetachedASTypesForGarbageCollection(&ModulesBeforeReset);
    CollectGarbage(RF_NoFlags, true);
}
TransientFullEngine = CreateIsolatedFullEngine();                                   // ★ 重新造
```

差异：

- `ResetModules`：留壳，只清模块（轻，约 30-100 ms）。
- `AcquireTransientFullTestEngine`：扔旧、造新（重，约 500-1500 ms），但保证**绝对干净**。

→ 引擎 / Bind 自测必须用 ASTEST_CREATE_ENGINE_FULL；其他 90% 情况用共享 + ResetModules。

### 9.3 stray legacy global engine

测试结束时偶尔会有"主进程残留 production engine"。`DestroyStrayLegacyGlobalTestEngine` 用 `UAngelscriptGameInstanceSubsystem::HasAnyTickOwner()` 守卫——只在没活的 game instance 时才动手。这是 `RT_GlobalState.md` §六 提到的"租期不交还"故障的最后一道兜底。

---

## 十、Template 层：7 份教学样板

`Template/Template_*.cpp` 是**注册了 `Angelscript.Template.*` 入口的可执行教学样板**。它们既是文档也是回归——每条 case 都跑一次，以保证示范代码不腐烂。

| 文件 | 演示主题 | 引用的 Helper |
|------|---------|-------------|
| `Template_CQTest.cpp` | CQTest 标准模式：6 种 TEST_METHOD 形态（Compile / Multi / Struct / Args / Negative / AssertThat） | `AngelscriptTestMacros` + `Bindings*` 全家 + `GlobalFunctionInvoker` |
| `Template_WorldTick.cpp` | World.Tick 三档驱动（World.Tick / TickViaManager / DispatchActorTick） | `FAngelscriptTestWorld` + `AngelscriptFunctionalTestUtils` |
| `Template_BlueprintWorldTick.cpp` | BP-derived AS 类的 Tick 驱动 | 同上 + `AngelscriptReflectiveAccess` |
| `Template_GameLifetime.cpp` | UserConstructionScript → BeginPlay → Tick → EndPlay → Destroyed 全链路计数 + 顺序验证 | `FAngelscriptTestWorld` + `BeginPlayActor` + `DestroyAndDrain` |
| `Template_GlobalFunctions.cpp` | AS 全局函数（不 UFUNCTION）调用：bool / int / float / 引用 / 结构体 | `FASGlobalFunctionInvoker` |
| `Template_ReflectionAccess.cpp` | 11 个 case：路径读写、UFUNCTION 调用、BP library 反射、参数 / 返回类型矩阵 | `AngelscriptReflectiveAccess` 全家 |
| `Template_Blueprint.cpp` | BP-AS 互操作：临时 UBlueprint 创建 + KismetEditorUtilities 编译 | `KismetEditorUtilities` + `CompileScriptModule` |

### 10.1 Template 的边界

`Documents/Guides/TestConventions.md §1` 明确写了：

> Template/ 目录中的文件视为**夹具模板**，不是新的 Automation 测试文件落点。

也就是说，新的主题 case **不应**继续往 `Template/` 里加。新主题请去对应主题目录新建文件。如果 Template 自身需要新增（例如 GAS / Networking 模板），请走 OpenSpec 提案并注明"会扩张 Template 数量"。

### 10.2 Template_CQTest 是事实上的"AS spec 基类"

由于本仓库**没有自定义 Spec 基类**——直接用 CQTest 的 `TEST_CLASS_WITH_FLAGS`——所以 `Template_CQTest.cpp` 充当事实上的"读完就能上手"基础样板。新写测试如果不知道从何下笔，复制它的 `BEFORE_ALL/AFTER_ALL + 6 TEST_METHOD` 骨架几乎万能。

### 10.3 与 AutomationSpec 的适配

UE 自带的 `FAutomationSpec`（FAutomationSpecBase 派生）在本仓库里**几乎不用**——CQTest 表现力更高、stack trace 更友好、对静态 BEFORE_ALL/AFTER_ALL 的支持更直接。如果某条 case 必须使用 `FAutomationSpec`（例如 UI 主题需要 `LatentBeforeEach`），那是个例，不上升为模板。

---

## 附录 A：Helper API 速查

### A.1 Engine 获取（由轻到重）

| API / 宏 | 档位 | 是否 reset | 持久 scope |
|---------|------|----------|-----------|
| `ASTEST_GET_ENGINE()` | SharedClone | 否 | 是（持续） |
| `ASTEST_CREATE_ENGINE()` | SharedClone | 是（取时 reset） | 是 |
| `ASTEST_RESET_ENGINE(E)` | SharedClone | 显式 reset | — |
| `ASTEST_CREATE_ENGINE_FULL()` | IsolatedFull | 每次新造 | 否 |
| `FAngelscriptTestFixture(Test, ProductionLike)` | ProductionLike | — | 自带 RAII |
| `ASTEST_CREATE_ENGINE_NATIVE()` | Native | 不适用 | 不适用 |

### A.2 编译入口

| 函数 | 是否走 Preprocessor | 何时用 |
|------|-------------------|-------|
| `AngelscriptTestSupport::BuildModule` | 是 | 默认；最常用 |
| `CompileModuleFromMemory` | 否（仅 SoftReloadOnly） | 不带 UCLASS / USTRUCT 注解的纯函数测试 |
| `CompileAnnotatedModuleFromMemory` | 是（FullReload） | 带 `UCLASS()/USTRUCT()/UENUM()` 注解 |
| `CompileModuleWithSummary` | 可选 | 需要拿 `FAngelscriptCompileTraceSummary` |
| `CompileModuleWithResult` | 自动判断（看是否有 UCLASS 等） | 通用入口 |
| `CompileModuleFromDiskPath` | 是 | 需要走"扫盘 + 编译"完整链路 |
| `AnalyzeReloadFromMemory` | 是 | 验证 SoftReload / FullReload 决策 |

### A.3 World 与 Tick

| API | 谁负责 Tick 数控制 |
|-----|------------------|
| `FAngelscriptTestWorld(Test, Engine)` | 构造世界 + 持有 EngineScope |
| `World.Tick(Dt, N)` | World.Tick + TActorIterator 手动派发，TickCount 不可严控 |
| `World.TickViaManager(Dt, N)` | 仅 World.Tick；ReceiveTick 可能只第一帧触发 |
| `World.DispatchActorTick(Actor, Dt, N)` | 直接循环 `Actor.Tick`，TickCount==N 严格 |
| `World.DispatchComponentTick(Comp, Dt, N)` | 同上，组件级 |
| `World.BeginPlay(Actor)` / `BeginPlayAll` | 调 `DispatchBeginPlay` |
| `World.DestroyAndDrain(Actor)` | `Actor.Destroy()` + 一帧 Tick |

### A.4 反射与调用

| API | 目标 | 备注 |
|-----|------|------|
| `AngelscriptReflectiveAccess::GetByPath<P, V>` | 标量 UPROPERTY 读 | 模板：FProperty 子类 + 值类型 |
| `GetStructByPath<T>` / `VerifyStructByPath<T>` | USTRUCT 读 | 用 `TBaseStructure<T>::Get()` |
| `GetObjectByPath` / `SetObjectByPath` | UObject 引用 | TObjectPtr / 裸指针 |
| `GetEnumByPath` / `GetClassByPath` | 枚举 / UClass | |
| `GetArrayNumByPath` / `GetMapNumByPath` / `GetSetNumByPath` | 容器元素数 | |
| `GetMapValueByPath<K, P, V>` / `SetContainsByPath<E>` | TMap 单 key 查 / TSet 包含 | |
| `GetOptionalIsSetByPath` / `GetOptionalValueByPath<P, V>` | TOptional 状态 / 内值 | |
| `GetTextByPath` / `GetSoftObjectPathByPath` / `GetWeakObjectByPath` / `InspectInstancedStructByPath` | 引用类型族 | |
| `FFunctionInvoker(Test, Target, FuncName)` | UFUNCTION 调用 | `AddParam<T>` / `Call()` / `CallAndReturn<R>()` |
| `FFunctionInvoker::SetParamOptional<P, V>` / `ReadOptionalReturn<P, V>` | TOptional 入参 / 返回 | |
| `FASGlobalFunctionInvoker(Test, Engine, Module, Decl)` | AS 全局函数 | `AddArg(...)` 一组重载 + `CallAndReturn<R>()` |
| `ResolveFunctionByDecl` / `ResolveFunctionByName` | 找 asIScriptFunction | 在模块上查 |

### A.5 断言族

| API | 期望 | 副产 |
|-----|------|------|
| `ExpectGlobalInt` | int32 相等 | AddInfo case label |
| `ExpectGlobalIntAtLeast` | int32 ≥ | |
| `ExpectGlobalBool` / `ExpectGlobalReturnBool` | bool | |
| `ExpectGlobalDouble(tol=1e-6)` / `ExpectGlobalReturnFloat(tol=0.01f)` | 浮点 | |
| `ExpectGlobalReturnCustom<T>(validator)` | 任意 USTRUCT | validator 返回 bool |
| `ExpectGlobalInts(TArrayView<FExpectedGlobalInt>)` | 批量 | |
| `ExpectBindingCompileFailure` | 编译失败 + 诊断子串 | |
| `ExecuteFunctionExpectingScriptException` | 异常（5-tuple） | 同时 AddExpectedError |

### A.6 Debugger 体系

| API | 模式 |
|-----|------|
| `FAngelscriptDebuggerTestSession::Initialize(Config)` | 真实 socket |
| `Initialize(Config{MockServer=...})` | mock 模式 |
| `FAngelscriptDebuggerTestClient::Connect(IP, Port)` | 主客户端 |
| `StartDebuggerSession` / `StartDebuggerSessionWithVersionHandshake` | 一行启动 |
| `WaitForBreakpointCount` / `WaitForSpecificBreakpoint` | 断点轮询 |
| `FDebuggerTestContext::SetUp/TearDown` | BEFORE_EACH / AFTER_EACH 用 |
| `FAngelscriptDebuggerScriptFixture::Create*Fixture()` | 多套预设脚本 |
| `FAngelscriptMockDebugServer` | 不起 socket 的脚本化响应 |

### A.7 引擎池

| API | 用途 |
|-----|------|
| `StartupTestEnginePool(bPrewarm)` | `FAngelscriptTestModule::StartupModule` 调一次 |
| `ShutdownTestEnginePool()` | 反向 |
| `PrewarmTestEnginePool()` | 命令行触发 |
| `FScopedModuleCleanEngine(Engine)` | 增量回滚 RAII |
| `GetTestEnginePoolMetrics()` | 读 metrics（debugging 用） |

---

## 附录 B：编写 Spec 时"先用什么 Helper"决策树

```text
新 Spec → 它要什么类型的引擎？
   │
   ├── 主题是引擎核心 / Bind 表 / hot reload？
   │     ▼ 用 ASTEST_CREATE_ENGINE_FULL（IsolatedFull）
   │     ▼ 失败时通过 LogSharedEngineDebugState 排查
   │
   ├── 需要真实 GameInstance / Subsystem 行为？
   │     ▼ 用 FAngelscriptTestFixture(Test, ETestEngineMode::ProductionLike)
   │     ▼ 注意 cooked 测不会跑这段，记得 #if WITH_EDITOR / 端到端档位
   │
   ├── 测原生 AS SDK API？
   │     ▼ 用 ASTEST_CREATE_ENGINE_NATIVE（asCreateScriptEngine）
   │     ▼ 不挂 FAngelscriptEngine
   │
   └── 默认（90% 情况）
         ▼ 用 ASTEST_CREATE_ENGINE / ASTEST_GET_ENGINE 组合
         ▼ TEST_METHOD 内部用 FCoverageModuleScope 模块隔离

要不要起 World？
   │
   ├── 测纯函数 / 全局 AS 函数？
   │     ▼ 不起 World；用 FCoverageModuleScope + ExpectGlobalInt 系列
   │     ▼ 或 FASGlobalFunctionInvoker
   │
   ├── 测 Actor / Component / 生命周期？
   │     ▼ 起 FAngelscriptTestWorld
   │     ▼ 选 Tick 驱动方式：
   │         严格 TickCount 用 DispatchActorTick / DispatchComponentTick
   │         模拟 UE 调度路径用 TickViaManager
   │         "随便跑几帧" 用 World.Tick(Dt, N)
   │
   └── 测 BP 互操作？
         ▼ 复用 Template_Blueprint.cpp 的 CreateTransientBlueprintChild 模式
         ▼ 用 FFunctionInvoker（不是 FASGlobalFunctionInvoker）

要怎么验？
   │
   ├── AS 函数返回 int / bool / double？
   │     ▼ ExpectGlobalInt / ExpectGlobalBool / ExpectGlobalDouble
   │
   ├── AS 函数返回 USTRUCT / FString / FVector？
   │     ▼ ExpectGlobalReturnCustom<T>(validator)
   │     ▼ 或 FASGlobalFunctionInvoker::ReadReturnStruct<T>
   │
   ├── 期待 AS 抛异常？
   │     ▼ ExecuteFunctionExpectingScriptException
   │     ▼ 提前 AddExpectedErrorPlain（模块名 / decl / 异常子串三条）
   │
   ├── 期待编译失败 + 诊断子串？
   │     ▼ ExpectBindingCompileFailure
   │
   ├── 读写 UPROPERTY / 调 UFUNCTION？
   │     ▼ AngelscriptReflectiveAccess::GetByPath / FFunctionInvoker
   │
   └── 验证 Engine 内部状态（如 Diagnostics 表）？
         ▼ CompileModuleWithSummary 拿 FAngelscriptCompileTraceSummary
         ▼ 不要直接戳 Engine.Diagnostics（私有约定）

收尾：
   ├── BEFORE_ALL 用了 ASTEST_CREATE_ENGINE → AFTER_ALL 必须 ASTEST_RESET_ENGINE
   ├── 用了 FCoverageModuleScope → 析构自动 DiscardModule，无需手写
   └── 用了 IsolatedFull → 引用脱出 RAII 自动 Reset；无需手写
```

---

## 附录 C：避坑清单

1. **不要在 spec 里手写 `Engine.DiscardModule(...)`**——`FCoverageModuleScope` 析构已经做了；手写会双 free（虽然 `DiscardModule` 是 idempotent，但模块名重复 grep 时容易看错）。
2. **不要在 BEFORE_ALL 里写 `ASTEST_CREATE_ENGINE_FULL`**——这会让全类共用一个隔离 engine，然后第一条 case 之后状态被污染；隔离 Full 必须是 per TEST_METHOD 取。
3. **不要忘了 `FAngelscriptEngineScope`**——共享 engine 有持久 scope，但 IsolatedFull / ProductionLike 取出来后必须显式起 scope，否则 `FAngelscriptEngine::TryGetCurrentEngine()` 返回 null。
4. **`FAngelscriptCompileTraceSummary.Diagnostics` 只在 `bUsePreprocessor=true` 时才 cover Preprocessor 阶段诊断**——直接 `CompileModuleFromMemory` 不会经过 Preprocessor，"未声明的 UCLASS()" 之类错不会进 summary。
5. **`asEP_FLOAT_IS_FLOAT64=1`**：AS 端 `float` 实际是 8 字节 double。`ExpectGlobalReturnFloat` 内部读 `double` 再 cast 回 `float`；写 `FFunctionInvoker::AddParam<float>` 时**只在 UFUNCTION 路径上能用**，AS 全局函数还是 `AddArg(1.0f)`。
6. **不要在 Helper 头文件 include `BlueprintGraph` / `KismetEditorUtilities`**——它们是 `bBuildEditor` 守卫依赖；只能在 `.cpp` 或 `Template_Blueprint.cpp` 内部用。
7. **不要用 `BEGIN_/END_/SHARE_CLEAN/SHARE_FRESH` 宏**——已 archived（§四.2）；新代码用 CQTest + `ASTEST_CREATE_ENGINE` 四宏。
8. **Native SDK 测试的引擎一定要 `Release()`**——`ASTEST_CREATE_ENGINE_NATIVE` 返回的是 `asIScriptEngine*` 裸指针，靠 ref count 回收；现成的 spec 一律包 `ON_SCOPE_EXIT { Engine->Release(); }`。
9. **`FAngelscriptDebuggerTestSession::IsMockMode()` 下不能调 `GetDebugServer()`**——会返回 null，直接 crash；`FDebuggerTestContext` 的 `TearDown` 已经判断了，自定义 spec 跟着判。
10. **`AcquireProductionLikeEngine` 在 cooked headless 下会回退到 IsolatedFull**——这意味着断言"必须看到生产 GameInstance 子系统的某行为"在 cooked 下会失效，不要无脑用；必要时用 `RequireRunningProductionEngine` 直接报错。
11. **不要在 `Shared/` 新增 single-theme helper**——cross-theme 才进 `Shared/`，单主题独占（如 Functional/Actor 的 `EnableActorTick`）放在该主题目录。否则 `Shared/` 会膨胀到失控（参考 `Test_Layering.md` 附录 C.9）。
12. **`AngelscriptCollisionTestHelpers::AddQueryOnlyCollisionBox / AddBlockAllDynamicCollisionBox` 是因为 ODR**——以前每个 collision 测试 `.cpp` 各写一遍 `AddCollisionBox` 触发 unity build 冲突；改 helper 时不要再合回单文件。

---

## 小结

- **Helper 层九大类**（Engine / Spec 宏 / 编译诊断 / World / Bindings 覆盖 / 反射调用 / Native SDK / Debugger / 性能教学）覆盖了一条 spec 从启动到收尾的全部需要，spec 文件本身只剩"声明 case + 写 AS 源码 + 写断言"三件事。
- **`FAngelscriptTestEngine` 是统一引擎产生器**，`bSkipInitialCompile=true` 是它和 production engine 的本质差异；四档引擎（SharedClone / IsolatedFull / ProductionLike / Native）按"重 → 轻"覆盖所有场景，由四个宏 + `FAngelscriptTestFixture` RAII 提供入口。
- **Spec 命名宏只剩四个 + 一个 reset**——`BEGIN_/SHARE_CLEAN/SHARE_FRESH` 已 archived；CQTest 的 `BEFORE_ALL / AFTER_ALL` 与 `ASTEST_CREATE_ENGINE / ASTEST_GET_ENGINE / ASTEST_RESET_ENGINE` 是新代码唯一允许的组合。
- **断言扩展靠的是"AS context 可视化 + case label 自动写入 log"**：`ExpectGlobalInt` 族在失败时打 declaration、成功时也写 AddInfo；`ExecuteFunctionExpectingScriptException` 一次断言异常 5-tuple；`FBindingsCoverageProfile` 把 module 名 + case 标签 + log category 三合一。
- **`FAngelscriptCompileTraceSummary` 是 spec 视角的 Engine.Diagnostics**——`CollectCompileTraceDiagnostics` 把内部 map 切片成 POD，便于断言；上游详见 `Arch_ErrorDiagnostics.md` §二。
- **引擎池 + `FScopedModuleCleanEngine` 是性能层**——增量回滚比整把 reset 快一个数量级；启动期 prewarm 让首批 spec 不等。
- **Reset 仪式四步固定**：`Engine.DiscardModule` → 原生 `DeleteDiscardedModules` → `CleanupDetachedASTypesForGarbageCollection` → `CollectGarbage`；它是 `RT_GlobalState.md` §五 的 Helper 实现。
- **Template 层 7 份是教学样板，不是 spec 落点**——读 `Template_CQTest.cpp` 即可上手；新主题 case 不进 `Template/`，新基础 helper 不进 `Shared/`（除非跨主题）。
