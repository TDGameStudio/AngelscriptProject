# Arch_EditorTestDumpCollaboration — Editor / Test / Dump 协作边界

> **所属前缀**: Arch_（插件总体架构族）
> **关注层面**: 模块协作边界与扩展点编排（不深入单子系统实现细节）
> **关键源码**:
> `Plugins/Angelscript/Source/AngelscriptEditor/Core/AngelscriptEditorModule.cpp` (~1100 行，统一注册 5 个扩展点 + DumpExtension)
> · `AngelscriptEditor/HotReload/AngelscriptDirectoryWatcherInternal.{h,cpp}` (~107 行)
> · `AngelscriptEditor/HotReload/ClassReloadHelper.{h,cpp}` (~926 行，订阅 ClassGenerator 的 5 个 reload delegate)
> · `AngelscriptEditor/BlueprintImpact/AngelscriptBlueprintImpactScanner.{h,cpp}` (~444 行) + `AngelscriptBlueprintImpactScanCommandlet.{h,cpp}` (~230 行)
> · `AngelscriptEditor/SourceNavigation/AngelscriptSourceCodeNavigation.{h,cpp}` (~272 行)
> · `AngelscriptEditor/ContentBrowser/AngelscriptContentBrowserDataSource.{h,cpp}` (~393 行)
> · `AngelscriptEditor/CodeGen/AngelscriptEditorCodeGen.cpp` (~2813 行)
> · `AngelscriptEditor/Dump/AngelscriptEditorStateDump.cpp` (~131 行，挂入 `OnDumpExtensions`)
> · `AngelscriptRuntime/Dump/AngelscriptStateDump.{h,cpp}` (~1247 行，27 张 CSV 表的统一入口)
> · `AngelscriptRuntime/Dump/AngelscriptCSVWriter.h` (~99 行，受限的 UTF-8 CSV 输出器)
> · `AngelscriptRuntime/Dump/AngelscriptDumpCommand.cpp` (~64 行，`as.DumpEngineState` 控制台命令)
> · `AngelscriptTest/Shared/*` (~50 个 .h/.cpp，按用途归并为 7 大类 Helper)
> · `AngelscriptTest/Template/Template_*.cpp` (7 份基线测试样板)
> **关联文档**:
> `Documents/Knowledges/ZH/Arch_RuntimeLifecycle.md` — Runtime 总控与生命周期（本文 Editor 扩展点的"被服务方"）
> · `Documents/Knowledges/ZH/RT_HotReload.md` — Tick 中的热重载链路（DirectoryWatcher → ClassReloadHelper 的下游消费者）
> · `Documents/Knowledges/ZH/RT_StateDump.md` — State Dump 可观测性（27 张表的字段细节）
> · `Documents/Knowledges/ZH/Test_Infrastructure.md` — 测试基础设施 Helper 详解
> · `Documents/Knowledges/ZH/Type_ClassGeneration.md` — `FAngelscriptClassGenerator::OnClassReload` 等委托定义方

---

## 概览

本文聚焦一个核心问题：**`AngelscriptEditor` / `AngelscriptTest` / `AngelscriptRuntime/Dump` 三方在源码组织上彼此独立、但运行时高度协作；它们的"扩展点"和"消费入口"分别在哪里？哪些跨界是允许的，哪些是被明确禁止的？**

```text
┌──────────────────────────────────────────────────────────────────────┐
│                AngelscriptRuntime（运行进程都存在）                  │
│                                                                      │
│   FAngelscriptEngine  +  FAngelscriptClassGenerator                  │
│   (公开 API + 5 个 OnXXXReload 委托)                                 │
│                                                                      │
│   Dump/  ──  FAngelscriptStateDump::DumpAll()  ◀─── 27 张 CSV 表     │
│           ╲  + OnDumpExtensions (TMulticastDelegate<void(FString&)>) │
└─────────────╲──────────────────────────────▲─────────────────────────┘
              ╲                              │
               ╲ 只读公开 API                │ 注册一次，运行时被广播
                ╲                            │
   ┌─────────────╲──────────────┐  ┌─────────┴───────────────────────┐
   │ AngelscriptEditor          │  │ AngelscriptTest                 │
   │ (Editor / Commandlet)      │  │ (Editor + Headless 两栖)        │
   │                            │  │                                 │
   │ 5 个扩展点（顶向下）：     │  │  Shared/  — 60+ Helper 文件     │
   │  ① HotReload               │  │   按 7 大类组织                 │
   │  ② BlueprintImpact         │  │   (Engine 启动 / 编译 / 断言 /  │
   │  ③ SourceNavigation        │  │    World / Debugger / 性能 /    │
   │  ④ ContentBrowser          │  │    反射访问)                    │
   │  ⑤ CodeGen                 │  │                                 │
   │                            │  │  Template/  — 7 个基线样板      │
   │ Dump/  挂入 OnDumpExtensions│  │  Dump/  — as.DumpEngineState   │
   │  贡献 2 张额外 CSV 表       │  │     (消费 DumpAll)              │
   └────────────────────────────┘  └─────────────────────────────────┘
```

三方的"地理位置"对应三类边界：

```
进程边界:
  Editor 模块 -> 仅在 GIsEditor || IsRunningCommandlet() 进程加载
  Test  模块 -> 同上（"Type": "Editor"），但允许在 headless 自动化下运行
  Dump  子系统 -> AngelscriptRuntime 内，所有 Cooked / Editor / Test 进程都存在

依赖边界:
  Editor -> public 依赖 Runtime；不允许反向依赖 Test
  Test   -> public 依赖 Runtime；private 依赖 Editor（仅 bBuildEditor）
  Dump   -> 只依赖 Runtime/Core 与少数受控子系统的 public 头

知识边界（最重要的一条）:
  三方都必须把 FAngelscriptEngine / FAngelscriptClassGenerator
  的"公开 API"作为契约。任何"我先在 Runtime 里加个 hook 让我用得舒服"
  都必须通过新增 public delegate / public getter 解决，而不是私自打补丁。
```

后续章节按"三方一一展开 + 协作通道收尾 + 防御清单"的顺序推进。

---

## 一、Editor 模块的 5 个扩展点：各自的"切入点"

`AngelscriptEditor` 不是一个无形的"编辑器辅助"，它在源码上**每个职责对应一个独立目录**，每个目录有清晰的入口符号。`FAngelscriptEditorModule::StartupModule()` 一次性把这 5 个扩展点 + 1 个 Dump 钩子全部点亮：

```cpp
// ============================================================================
// 文件: AngelscriptEditor/Core/AngelscriptEditorModule.cpp
// 函数: FAngelscriptEditorModule::StartupModule（节选）
// 角色: 一处把所有 Editor 扩展点串接到 Runtime / UE 编辑器系统
// ============================================================================
void FAngelscriptEditorModule::StartupModule()
{
    // ① HotReload（订阅 ClassGenerator 的 OnXXXReload 委托）
    FClassReloadHelper::Init();

    // ③ SourceNavigation（注册 ISourceCodeNavigationHandler）
    RegisterAngelscriptSourceNavigation();

    // ⑤ Dump 扩展（挂入 FAngelscriptStateDump::OnDumpExtensions 多播）
    AngelscriptEditor::Private::RegisterStateDumpExtension(StateDumpExtensionHandle);

    // ① HotReload（注册 DirectoryWatcher 回调，监视所有 ScriptRoots）
    IDirectoryWatcher* DirectoryWatcher = ResolveDirectoryWatcher();
    for (const auto& RootPath : FAngelscriptEngine::MakeAllScriptRoots()) {
        DirectoryWatcher->RegisterDirectoryChangedCallback_Handle(
            *RootPath,
            IDirectoryWatcher::FDirectoryChanged::CreateStatic(&OnScriptFileChanges),
            WatchHandle, IDirectoryWatcher::IncludeDirectoryChanges);
    }

    // ④ ContentBrowser 在 OnPostEngineInit 中再注册（参见 OnEngineInitDone）
    GOnPostEngineInitHandle = FCoreDelegates::OnPostEngineInit.AddStatic(&OnEngineInitDone);

    // ② BlueprintImpact 不在 Startup 主动激活：
    //    - Scanner 由编辑器 UI（菜单 / 命令）按需触发
    //    - Commandlet 由 -run=AngelscriptBlueprintImpactScan 拉起
}
```

下面逐个看 5 个扩展点。

### 1.1 HotReload — DirectoryWatcher + ClassReloadHelper 双链

HotReload 由两段独立的代码组成，链路一前一后：

```text
[文件落盘] -> UE DirectoryWatcher 模块回调 OnScriptFileChanges
            -> AngelscriptEditor::Private::QueueScriptFileChanges
            -> Engine.FileChangesDetectedForReload.AddUnique(...)   // ★ 排队
            -> 等待 Runtime 在 Tick 中读取这个队列触发 SoftReload/FullReload
            (具体编译动作不在 Editor 模块；Editor 只是"通知员")

[ClassGenerator 完成新类构造] -> OnClassReload/OnStructReload/... 多播
                              -> ClassReloadHelper.cpp 的 5 个 lambda
                              -> 写入 FClassReloadHelper::ReloadState()
                              -> RefreshClassActions / InvalidateClass / 等
                              -> OnPostReload 触发 PerformReinstance + RefreshAll
```

**①-A：DirectoryWatcher 链**

```cpp
// ============================================================================
// 文件: AngelscriptEditor/HotReload/AngelscriptDirectoryWatcherInternal.cpp
// 函数: AngelscriptEditor::Private::QueueScriptFileChanges
// 角色: 把 OS 文件变更映射成 AS 引擎能消化的"待重载列表"
// ============================================================================
void QueueScriptFileChanges(const TArray<FFileChangeData>& Changes,
    const TArray<FString>& RootPaths, FAngelscriptEngine& Engine,
    IFileManager& FileManager, const FEnumerateLoadedScripts& EnumerateLoadedScripts)
{
    for (const FFileChangeData& Change : Changes) {
        const FString AbsolutePath = FPaths::ConvertRelativePathToFull(Change.Filename);
        FString RelativePath;
        if (!TryMakeRelativeScriptPath(AbsolutePath, RootPaths, RelativePath))
            continue;

        Engine.LastFileChangeDetectedTime = FPlatformTime::Seconds();   // ★ 写入公开字段
        if (AbsolutePath.EndsWith(TEXT(".as"))) {
            if (Change.Action == FFileChangeData::EFileChangeAction::FCA_Removed)
                Engine.FileDeletionsDetectedForReload.AddUnique({ AbsolutePath, RelativePath });
            else
                Engine.FileChangesDetectedForReload.AddUnique({ AbsolutePath, RelativePath });
        }
        // ...
    }
}
```

**注意边界**：Editor 模块在这里只做了一件事——**把变更写进 `FAngelscriptEngine` 的公开队列字段**（`FileChangesDetectedForReload` / `FileDeletionsDetectedForReload`）。它**不调用** `FAngelscriptEngine::CheckForHotReload()`，那是 Runtime 在 `Tick` 内部的事；详见 `Arch_RuntimeLifecycle.md` §三与 `RT_HotReload.md`。

**①-B：ClassReloadHelper 链**

`ClassReloadHelper` 不是被定时调用的；它在 `Init()` 时**订阅** `FAngelscriptClassGenerator` 暴露的 5 个公开委托：

```cpp
// ============================================================================
// 文件: AngelscriptEditor/HotReload/ClassReloadHelper.h
// 函数: FClassReloadHelper::Init（节选）
// 角色: 订阅 5 个 OnXXXReload 多播，把变更聚合到 ReloadState() 单例
// ============================================================================
static void Init()
{
    FAngelscriptClassGenerator::OnStructReload.AddLambda(...);     // 旧/新 UScriptStruct
    FAngelscriptClassGenerator::OnClassReload.AddLambda(...);      // 旧/新 UClass + 接口标记
    FAngelscriptClassGenerator::OnDelegateReload.AddLambda(...);   // 旧/新 UDelegateFunction
    FAngelscriptClassGenerator::OnLiteralAssetReload.AddLambda(...); // 旧/新 UObject 资源
    FAngelscriptClassGenerator::OnEnumChanged.AddLambda(...);      // UEnum + 旧名值表
    FAngelscriptClassGenerator::OnEnumCreated.AddLambda(...);
    FAngelscriptClassGenerator::OnFullReload.AddLambda([](){ ReloadState().PerformReinstance(); });
    FAngelscriptClassGenerator::OnPostReload.AddLambda(...);       // 编辑器侧扫尾
}
```

——5 个 `OnXXXReload` 在 Runtime/ClassGenerator 子系统里是**为了 Editor 而存在**的扩展点（参见 `Type_ClassGeneration.md`）；Editor 在这里**消费**它们，而不是反向给 Runtime 加 hook。

### 1.2 BlueprintImpact — Scanner（交互） + Commandlet（CI）共用核心扫描

`BlueprintImpact` 解答的问题是：脚本类 / 结构 / 委托发生变化时，**哪些蓝图资产受影响、需要重编译**。它故意分裂成两个"前端"，但两者**共用同一个核心扫描函数** `ScanBlueprintAssets()`：

```cpp
// ============================================================================
// 文件: AngelscriptEditor/BlueprintImpact/AngelscriptBlueprintImpactScanner.h
// 角色: 唯一的核心扫描 API；编辑器交互与 Commandlet 都直接调用它
// ============================================================================
ANGELSCRIPTEDITOR_API FBlueprintImpactScanResult ScanBlueprintAssets(
    const FAngelscriptEngine& Engine,
    IAssetRegistry& AssetRegistry,
    const FBlueprintImpactRequest& Request);

// 输入: 变更脚本路径列表（空 = FullScan）
// 输出: 受影响的 Modules / 解析得到的符号集合 / 蓝图候选 / 实际匹配项 / 失败计数
```

```cpp
// ============================================================================
// 文件: AngelscriptEditor/BlueprintImpact/AngelscriptBlueprintImpactScanCommandlet.cpp
// 函数: UAngelscriptBlueprintImpactScanCommandlet::Main
// 角色: 把命令行参数翻译成 FBlueprintImpactRequest，然后直接复用 Scanner 核心
// ============================================================================
int32 UAngelscriptBlueprintImpactScanCommandlet::Main(const FString& Params)
{
    if (!FAngelscriptEngine::Get().bDidInitialCompileSucceed)
        return static_cast<int32>(EBlueprintImpactCommandletExitCode::EngineNotReady);

    AngelscriptEditor::BlueprintImpact::FBlueprintImpactRequest Request;
    if (!TryBuildBlueprintImpactRequest(Params, Request, &ChangedScriptsFileError))
        return static_cast<int32>(EBlueprintImpactCommandletExitCode::InvalidArguments);

    FAssetRegistryModule& AssetRegistryModule = FModuleManager::LoadModuleChecked<FAssetRegistryModule>(TEXT("AssetRegistry"));
    const auto ScanResult = AngelscriptEditor::BlueprintImpact::ScanBlueprintAssets(
        FAngelscriptEngine::Get(), AssetRegistryModule.Get(), Request);

    // 以单行 JSON 输出便于 CI 系统解析
    UE_LOG(Angelscript, Display, TEXT("{ \"BlueprintImpact\": { \"FullScan\": %s, ... } }"), ...);
    return ScanResult.FailedAssetLoads > 0 ? AssetScanFailure : Success;
}
```

**协作要点**：Commandlet 路径**不应**包含任何"我自己写的扫描逻辑"——一旦 Scanner（GUI 路径）和 Commandlet（CI 路径）的扫描结果对不上，就会出现"本地通过、CI 红灯"的灾难。两条路径调同一个 `ScanBlueprintAssets` 是**强制约束**。

### 1.3 SourceNavigation — UE `FSourceCodeNavigation` 的处理器实现

```cpp
// ============================================================================
// 文件: AngelscriptEditor/SourceNavigation/AngelscriptSourceCodeNavigation.cpp
// 函数: RegisterAngelscriptSourceNavigation（注册入口）
//      + class FAngelscriptSourceCodeNavigation（实现 ISourceCodeNavigationHandler）
// 角色: 让 UE 编辑器"右键 -> Go to Definition"知道脚本类的 .as 文件路径与行号
// ============================================================================
class FAngelscriptSourceCodeNavigation : public ISourceCodeNavigationHandler
{
public:
    virtual bool NavigateToFunction(const UFunction* InFunction) override
    {
        auto* ASFunc = Cast<const UASFunction>(InFunction);
        if (ASFunc == nullptr) return false;
        FString Path = ASFunc->GetSourceFilePath();   // ★ 公开 getter
        if (Path.Len() == 0) return false;
        OpenFile(Path, ASFunc->GetSourceLineNumber());
        return true;
    };

    virtual bool NavigateToClass(const UClass* InClass) override
    {
        TSharedPtr<FAngelscriptModuleDesc> Module;
        auto ClassDesc = GetClassDesc(InClass, &Module);
        if (!ClassDesc.IsValid()) return false;
        OpenModule(Module, ClassDesc->LineNumber);    // ★ 通过 ClassDesc 拿行号
        return true;
    }
    // ... NavigateToProperty / NavigateToStruct 同理
};
```

**协作要点**：`OpenVsCode` 内部对 `UAngelscriptSettings::VSCodeWorkspacePath` 与 `FAngelscriptEngine::GetScriptRootDirectory()` 都有降级判断，且暴露了 `SetOpenLocationOverrideForTesting` 让测试用例可以拦截 `code` 命令调用——这是测试与 Editor 协作的一个典型样板：**Editor 暴露 `*ForTesting` 注入点，让 Test 模块在不真启动 VSCode 的前提下覆盖路径分支**。

### 1.4 ContentBrowser — 自定义 `UContentBrowserDataSource`

`AngelscriptContentBrowserDataSource` 让 `.as` 脚本以"虚拟资产"的形式出现在 UE 内容浏览器：

```cpp
// ============================================================================
// 文件: AngelscriptEditor/Core/AngelscriptEditorModule.cpp
// 函数: OnEngineInitDone（节选） + DataSource Initialize
// 角色: 在 PostEngineInit 时机把 DataSource 挂入 IContentBrowserDataModule
// ============================================================================
void OnEngineInitDone()
{
    auto* DataSource = NewObject<UAngelscriptContentBrowserDataSource>(
        GetTransientPackage(), "AngelscriptData", RF_MarkAsRootSet | RF_Transient);
    DataSource->Initialize();    // -> Super::Initialize(true)

    UContentBrowserDataSubsystem* ContentBrowserData = IContentBrowserDataModule::Get().GetSubsystem();
    ContentBrowserData->ActivateDataSource("AngelscriptData");
    // ...
}
```

DataSource 实现 `EnumerateItemsMatchingFilter` / `GetItemPhysicalPath` / `EditItem` 等覆盖（共 ~20 个 virtual override），让脚本资产参与过滤、缩略图、双击编辑等流程。**它读 `FAngelscriptEngine` 的资产包指针 `AssetsPackage`，但不修改其内容**——又是一次"外部观察者"模式。

### 1.5 CodeGen — IDE 桩与 API 文档生成

`CodeGen/AngelscriptEditorCodeGen.cpp` 是体积最大（~2813 行）但**最不被 Runtime 调用**的扩展点：它仅在编辑器命令（`as.GenerateBindings` 之类）下被触发，遍历 `TObjectRange<UFunction>` 与 `TObjectRange<UClass>` 输出 IDE 用的 `.as` 桩文件、API 摘要等。它**只读公开反射 API**，不参与运行时。

---

## 二、Test 模块的 Helper 大类：Shared/ 的 7 类组织

`AngelscriptTest/Shared/` 目录下有 60+ 文件，乍看混乱，实际上对应 7 个 Helper 大类。所有 28+ 个测试主题（Actor / Component / Bindings / Networking / ...）都从这里取共用基础设施：

```text
AngelscriptTest/Shared/    （按用途归并）
├── 1) Engine 启动与池化
│     - AngelscriptTestEngine.{h,cpp}        Create/GetSharedEngine/ResetModules
│     - AngelscriptTestEnginePool.h          长生命周期共享池 + 模块清理度量
│     - AngelscriptTestUtilities.h           FAngelscriptTestEngineScopeAccess 等
│     - AngelscriptTestMacros.h              ASTEST_CREATE_ENGINE / ASTEST_GET_ENGINE
│
├── 2) 编译与重载辅助
│     - AngelscriptTestEngineHelper.{h,cpp}  CompileModuleFromMemory / AnalyzeReload
│
├── 3) World / Actor 测试
│     - AngelscriptTestWorld.h               EngineScope + ActorTestSpawner 复合体
│     - AngelscriptFunctionalTestUtils.h     SpawnScriptActor / TickWorld / BeginPlayActor
│
├── 4) Bindings 断言与覆盖
│     - AngelscriptBindingsAssertions.h
│     - AngelscriptBindingsCoverage.h / ...ExampleSection.h / ...ModuleBuilder.h
│
├── 5) Debugger 测试
│     - AngelscriptDebuggerTestSession/Client/Monitor/Context.{h,cpp}
│     - AngelscriptMockDebugServer.{h,cpp} / AngelscriptDebuggerScriptFixture.{h,cpp}
│
├── 6) 反射访问与全局调用
│     - AngelscriptReflectiveAccess.h
│     - AngelscriptGlobalFunctionInvoker.h
│     - AngelscriptNativeScriptTestObject.{h,cpp}
│
└── 7) 性能 / 学习痕迹 / 探针
      - AngelscriptPerformanceTestUtils.h
      - AngelscriptLearningTrace.{h,cpp}
      - AngelscriptConstructionContextProbe.{h,cpp}
      - AngelscriptCollisionTestHelpers.h
```

最常用的两份是 `AngelscriptTestMacros.h` 与 `AngelscriptTestEngine.h`。前者把 CQTest 风格的 BEFORE_ALL / TEST_METHOD 合规化；后者**严格通过公开 API 创建/重置引擎**：

```cpp
// ============================================================================
// 文件: AngelscriptTest/Shared/AngelscriptTestEngine.h
// 角色: Test-side 引擎工厂，仅使用公开 API（无引擎内部 friend / 私有访问）
// ============================================================================
struct ANGELSCRIPTTEST_API FAngelscriptTestEngine
{
    /** 创建一个全新的、未编译的隔离 Full 测试引擎 */
    static TUniquePtr<FAngelscriptEngine> Create(
        const FAngelscriptEngineConfig& Config,
        const FAngelscriptEngineDependencies& Dependencies);

    /** Get-or-create 长生命周期的共享 Full 测试引擎单例 */
    static FAngelscriptEngine& GetSharedEngine();

    /** 销毁共享单例；下次 GetSharedEngine() 会重建 */
    static void DestroySharedEngine();

    /** 丢弃所有已编译模块、保留类型/绑定数据库 */
    static void ResetModules(FAngelscriptEngine& Engine);
};
```

注释里有句话能回答"为什么不继承 `FAngelscriptEngine`"：

> Implemented as a static-method-only struct (no inheritance) so the runtime layout of `FAngelscriptEngine` is unaffected. The previous subclass-based design was reverted because no instance methods needed protected access to `FAngelscriptEngine` internals; **all operations go through the public engine API**.

——这正是"Test 不能私下打补丁到 Runtime"的代码级证据。

`Template/` 目录提供 7 个基线测试样板（`Template_GlobalFunctions / Blueprint / BlueprintWorldTick / GameLifetime / CQTest / WorldTick / ReflectionAccess`），每个对应一个高频测试套路。新增主题测试时**优先复制对应 Template 文件再改**，而不是从零写。

---

## 三、Dump 子系统：纯外部观察者 + 27 张 CSV 表

### 3.1 设计原则：纯外部观察者

`AGENTS.md` 在 §"Build & Validation Principles" 明确写道：

> Preserve the dump architecture as a pure external observer: prefer reading existing public APIs over adding intrusive dump hooks to runtime/editor classes.

落到代码上，约束就是 `AngelscriptStateDump.h` 的**唯一公开 API** 只有一个静态函数 + 一个多播：

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Dump/AngelscriptStateDump.h
// 角色: 27 张 CSV 表的统一入口；扩展点是 OnDumpExtensions 多播
// ============================================================================
struct ANGELSCRIPTRUNTIME_API FAngelscriptStateDump
{
    struct FTableResult
    {
        FString TableName;
        int32 RowCount = 0;
        FString Status = TEXT("Success");
        FString ErrorMessage;
    };

    using FDumpExtensionsDelegate = TMulticastDelegate<void(const FString&)>;

    /** 唯一公开入口：写出全套 CSV 到 OutputDir（空字符串 = ProjectSaved/Angelscript/Dump/<时间戳>/）*/
    static FString DumpAll(FAngelscriptEngine& Engine, const FString& OutputDir = TEXT(""));

    /** 扩展点：Editor 模块在 StartupModule 中挂入；广播参数为 ResolvedOutputDir */
    static FDumpExtensionsDelegate OnDumpExtensions;

private:
    // 25 个 private 静态 DumpXXX 方法，对应每张 CSV 表
    // ...（见 §3.2 列表）
};
```

**关键点**：
- 所有 `DumpXXX` 都是 `private`，无法被外部 hack 调用——避免出现"我直接调 DumpFunctions 拼一张子表"的旁门左道。
- 全部 26 个 `Dump*` 都接收 `FAngelscriptEngine&` 的常引用 + 输出目录字符串，**无任何 friend、无任何 private 字段直读**。
- CSV 输出器 `FCSVWriter` 是受限工具：只支持"Header + Rows"，强制 UTF-8、强制 `,` 分隔、强制对包含特殊字符的字段加引号转义；这从工具层面阻断了"我自己拼一段奇怪格式塞进去"的诱惑。

### 3.2 27 张表的清单与命名约定

`DumpAll` 内部按固定顺序调用 24 个核心 `DumpXXX` + 2 个扩展表 + 1 张 `DumpSummary`：

```text
DumpAll() 输出顺序与命名（一表一职责）

Phase A — 引擎全景与配置
  EngineOverview.csv        启动状态 + 各项数量统计的"一行总览"
  RuntimeConfig.csv         FAngelscriptEngineConfig 的全量 Key/Value
  EngineSettings.csv        UAngelscriptSettings 中 UPROPERTY 的导出值

Phase B — 编译产物（模块 / 类 / 属性 / 函数 / 枚举 / 委托）
  Modules.csv               每个 FAngelscriptModuleDesc 的代码量、依赖、单测数
  Classes.csv               每个 FAngelscriptClassDesc 的类标志、父类、行号
  Properties.csv            每个属性的复制条件、Editable、SaveGame 等
  Functions.csv             每个方法的 BlueprintCallable / NetMulticast 等
  Enums.csv                 每个枚举的取值与值名
  Delegates.csv             委托签名

Phase C — 类型注册与绑定数据库
  RegisteredTypes.csv       FAngelscriptType::GetTypes()
  BindRegistrations.csv     FAngelscriptBinds::GetAllRegisteredBindNames()
  BindDatabase_Structs.csv  AngelscriptBindDatabase 中已注册的 struct
  BindDatabase_Classes.csv  同上的 class
  ToStringTypes.csv         注册了 ToString 的类型

Phase D — 诊断 / 文档 / 调试器 / JIT / 覆盖率
  Diagnostics.csv           Engine.Diagnostics（编译诊断）
  ScriptEngineState.csv     asCScriptEngine 的可见运行状态
  HotReloadState.csv        热重载相关的 bool / 队列长度
  DocumentationStats.csv    文档统计
  JITDatabase.csv           FJITDatabase::Get().Functions
  PrecompiledData.csv       Cooked / 预编译数据指标
  StaticJITState.csv        StaticJIT 模块状态
  DebugServerState.csv      DebugServer.HasAnyClients 等
  DebugBreakpoints.csv      已注册的断点
  CodeCoverage.csv          覆盖率统计（仅 WITH_AS_COVERAGE）

Phase E — 扩展（由 OnDumpExtensions 广播给注册者写出）
  EditorReloadState.csv     ★ 由 AngelscriptEditor/Dump/EditorStateDump.cpp 写
  EditorMenuExtensions.csv  ★ 由同上写

Phase F — 摘要
  DumpSummary.csv           每张表的 TableName / RowCount / Status / ErrorMessage
```

合计：24（Phase A-D）+ 2（Phase E）+ 1（Summary）= **27 张表**。

### 3.3 Editor 通过 `OnDumpExtensions` 协作贡献 2 张表

Editor 想为 dump 添加"我编辑器特有的状态"（比如当前热重载状态快照、菜单扩展注册情况），**唯一允许的做法**就是挂 `OnDumpExtensions` 多播：

```cpp
// ============================================================================
// 文件: AngelscriptEditor/Dump/AngelscriptEditorStateDump.cpp
// 函数: SaveEditorReloadState + DumpEditorState + RegisterStateDumpExtension
// 角色: Editor 在 dump 流程中贡献 2 张表，无需改 Runtime 任何代码
// ============================================================================
void SaveEditorReloadState(const FString& OutputDir)
{
    FCSVWriter Writer;
    Writer.AddHeader({ TEXT("Category"), TEXT("OldName"), TEXT("NewName") });

    FClassReloadHelper::FReloadState& ReloadState = FClassReloadHelper::ReloadState();
    for (const TPair<UClass*, UClass*>& ReloadClass : ReloadState.ReloadClasses)
        Writer.AddRow({ TEXT("ReloadClass"), GetObjectName(ReloadClass.Key), GetObjectName(ReloadClass.Value) });
    // ...遍历 NewClasses / ReloadEnums / NewEnums / ReloadStructs / ReloadDelegates

    Writer.SaveToFile(FPaths::Combine(OutputDir, TEXT("EditorReloadState.csv")), &ErrorMessage);
}

void DumpEditorState(const FString& OutputDir)   // 多播回调
{
    SaveEditorReloadState(OutputDir);
    SaveEditorMenuExtensions(OutputDir);
}

namespace AngelscriptEditor::Private
{
    void RegisterStateDumpExtension(FDelegateHandle& OutHandle)
    {
        if (!OutHandle.IsValid())
            OutHandle = FAngelscriptStateDump::OnDumpExtensions.AddStatic(&DumpEditorState);
    }
}
```

——这就是"扩展点契约"的工作样板：**Editor 用自己的 `FCSVWriter` 写自己负责的字段，写到 Runtime 给的 `OutputDir`，Runtime 在 DumpAll 末尾按文件名校验扩展表是否已生成**。Runtime 不需要 include 任何 Editor 头，Editor 也没碰任何 Runtime 私有字段。

`FAngelscriptStateDump::DumpAll` 末尾的扩展表校验代码：

```cpp
// 节选自 AngelscriptStateDump.cpp DumpAll
const bool bHadExtensionHandlers = OnDumpExtensions.IsBound();
OnDumpExtensions.Broadcast(ResolvedOutputDir);

auto AddExtensionTableResult = [&ResolvedOutputDir, &TableResults, bHadExtensionHandlers]
    (const FString& TableName)
{
    const FString Filename = FPaths::Combine(ResolvedOutputDir, TableName);
    if (!IFileManager::Get().FileExists(*Filename)) {
        if (bHadExtensionHandlers) {
            FTableResult Result;
            Result.TableName = TableName;
            Result.Status = TEXT("Error");
            Result.ErrorMessage = TEXT("Expected editor dump extension table was not generated.");
            TableResults.Add(Result);
        }
        return;
    }
    // 否则正常计 RowCount
};
AddExtensionTableResult(TEXT("EditorReloadState.csv"));
AddExtensionTableResult(TEXT("EditorMenuExtensions.csv"));
```

### 3.4 Runtime 提供 `as.DumpEngineState` 控制台命令，Test 做回归验证

Runtime 侧的正式入口是一个 64 行的小文件——它把 dump 包装成可被自动化测试 / 控制台 / CI 调用的命令：

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Dump/AngelscriptDumpCommand.cpp
// 角色: as.DumpEngineState [OutputDir] 控制台命令
// ============================================================================
void ExecuteDumpEngineState(const TArray<FString>& Args)
{
    if (!FAngelscriptEngine::IsInitialized()) {
        UE_LOG(LogAngelscriptDumpCommand, Error,
            TEXT("Cannot dump Angelscript engine state because no global engine is initialized."));
        return;
    }

    const FString RequestedOutputDir = Args.IsEmpty() ? FString() : SanitizeOutputDirArg(Args[0]);
    const FString ActualOutputDir = FAngelscriptStateDump::DumpAll(
        FAngelscriptEngine::Get(), RequestedOutputDir);
    if (ActualOutputDir.IsEmpty()) {
        UE_LOG(LogAngelscriptDumpCommand, Error, TEXT("Angelscript engine state dump failed."));
        return;
    }
    UE_LOG(LogAngelscriptDumpCommand, Log,
        TEXT("Angelscript engine state dumped to '%s'."), *ActualOutputDir);
}

FAutoConsoleCommand GAngelscriptDumpEngineStateCommand(
    TEXT("as.DumpEngineState"),
    TEXT("Dump Angelscript engine state to CSV tables. Optional: as.DumpEngineState [OutputDir]"),
    FConsoleCommandWithArgsDelegate::CreateStatic(&ExecuteDumpEngineState));
```

此外，`AngelscriptTest/Dump/AngelscriptDumpTests.cpp` 内的 `FAngelscriptStateDumpEndToEndTest` 等测试**完整列出了期望出现的 27 张表**，并验证 `as.DumpEngineState` 已注册为 console command——这是 Dump 输出契约的"机器可执行规范"，任何表名修改 / 新增 / 删除都必须同步更新这份测试。

---

## 四、协作通道速查与"什么时候不能跨界"

把前 3 节的协作汇成一张通道矩阵：

```text
                      Editor 调用       Test 调用       Dump 调用
Runtime/Engine 公开 API  ✓ 自由            ✓ 自由           ✓ 只读
Runtime 私有字段         ✗ 禁              ✗ 禁              ✗ 禁
ClassGenerator 委托      订阅 OnXXXReload  订阅+ResetForTest 不订阅
FAngelscriptStateDump    挂 OnDumpExt      调 DumpAll        ——
ContextStack             不直接 Push       通过 Scope RAII   不接触
HotReload 文件队列       Push 进队列        在测试中模拟      不读取
EditorModule public      ——              private 依赖      ✗ 禁
TestModule public        ✗ 禁              ——              ✗ 禁
```

下面这 7 条是**长期反复踩到的边界违规**，每条都用一行总结：

1. **不要在 Runtime 类里加"为了 Editor 方便"的 hook**
   正确做法：在 Runtime 加一个 public delegate（如 `OnClassReload`），Editor 订阅。已有先例：`FAngelscriptClassGenerator::OnXXXReload` 5 个委托。

2. **不要在 Runtime 类里加"为了 Test 方便"的 friend / `*ForTesting` 字段**
   `*ForTesting` 是允许的，但要走"`SetXxxOverrideForTesting` + 配套 `ClearXxxOverrideForTesting`" 这个成对的注入接口；不要直接 `friend class FXxxTest`。已有先例：`FAngelscriptRuntimeModule::SetInitializeOverrideForTesting`。

3. **不要在 Dump 子系统里"读" Runtime 的 protected/private 字段**
   一旦发现 `FAngelscriptStateDump` 想要某个数据但 `FAngelscriptEngine` 没暴露 —— **正确做法是在 `FAngelscriptEngine` 上加 const 公开 getter**，而不是 `friend struct FAngelscriptStateDump`。`friend` 一旦开了第一个口子，"纯外部观察者"原则就破了。

4. **不要在 Test 模块里 `#include` Editor 模块的 private 头**
   `AngelscriptTest` 对 `AngelscriptEditor` 是 *private* 依赖，且仅在 `bBuildEditor` 时启用。需要测试 Editor 行为时，要么用 Editor 暴露的 `*ForTesting` 公开符号（比如 `AngelscriptSourceNavigation::NavigateToFunctionForTesting`），要么把测试搬到 `AngelscriptEditor/Tests/`。

5. **不要绕过 `FCSVWriter` 自己拼 CSV 文本**
   一旦绕过，转义错误立刻出现（字段含逗号 / 引号 / 换行时）。`FCSVWriter` 是 dump 系统的"打字机"，不是建议。

6. **不要在 BlueprintImpact Commandlet 里复制 Scanner 的扫描代码**
   两条路径必须共用 `ScanBlueprintAssets`（§1.2）。Commandlet 只负责"参数解析 + 输出格式"。

7. **不要让 ContentBrowser DataSource 修改脚本资产**
   `EditItem` 必须委托给 SourceNavigation 打开 VSCode；任何"我直接覆写脚本文件内容"的实现都是错的——Editor 模块没有源代码权威，文件的真理在磁盘上的 `.as` 与 DirectoryWatcher 触发的反向链路里。

---

## 五、生命周期回顾：三方各自的"启动/关闭时机"

```
[模块装载 PostDefault]
  AngelscriptRuntime / AngelscriptEditor / AngelscriptTest 三个模块同时被加载。
  Runtime 只打日志，不创建 Engine。
  Editor / Test 也都不主动激活扩展点（除了静态注册的 FAutoConsoleCommand）。

[Bootstrap 之后]
  FAngelscriptRuntimeModule::InitializeAngelscript() 触发 PrimaryEngine.Initialize()
  -> ClassGenerator 初次 InitialCompile -> 触发 OnFirstReload 等委托
  -> 此时 Editor 还没注册委托（StartupModule 顺序问题），但首次编译里没有"reload"语义，所以无需补偿。

[Editor StartupModule]（GIsEditor 时由 UE 模块管理器调用）
  FClassReloadHelper::Init()                        // ① HotReload 订阅链
  RegisterAngelscriptSourceNavigation()             // ③ SourceNavigation 注册
  RegisterStateDumpExtension(StateDumpExtensionHandle)  // Dump 扩展挂入
  DirectoryWatcher->RegisterDirectoryChangedCallback_Handle(...)  // ① HotReload 文件链
  FCoreDelegates::OnPostEngineInit.AddStatic(&OnEngineInitDone)
    -> 在 OnEngineInitDone 中再注册 ContentBrowser DataSource

[Test 运行（自动化测试或人工）]
  ASTEST_CREATE_ENGINE() / ASTEST_GET_ENGINE() / ASTEST_CREATE_ENGINE_FULL()
    -> 走 FAngelscriptTestEngine::* 公开 API（不碰私有字段）
  测试结束: ASTEST_RESET_ENGINE(Engine)（保留绑定数据库，丢弃 modules）

[人工 / CI 触发 dump]
  控制台输入 as.DumpEngineState [OutputDir]
    -> FAngelscriptStateDump::DumpAll(...)
    -> 24 张核心表 + Broadcast(OnDumpExtensions) -> Editor 写 2 张额外表 -> DumpSummary

[Editor ShutdownModule]
  UnregisterDirectoryWatchers / UnregisterStateDumpExtension / 清理 SourceNavigation
  -> Runtime 不感知 Editor 的关闭顺序，仍然能独立 Shutdown
```

——这条流水线的关键性质是**单向通知**：Editor / Test 知道 Runtime（依赖关系如此），Runtime **不必**感知它们的存在；Dump 同时被 Editor 和 Test 消费但**不依赖**任何一方。

---

## 附录 A：协作边界速查表

| 扩展点 / 通道 | Owner（实现方） | 触发条件 | 输出形式 | 跨界禁忌 |
|---|---|---|---|---|
| ① HotReload DirectoryWatcher | Editor | OS 文件系统变更 | `Engine.FileChangesDetectedForReload` 队列 | 不直接调 `CheckForHotReload` |
| ① HotReload ClassReloadHelper | Editor | ClassGenerator 5 个 OnXXXReload 委托 | `ReloadState()` 单例 + `RefreshClassActions` | 不私自加 ClassGen private hook |
| ② BlueprintImpact Scanner | Editor | 编辑器菜单 / 命令 | 内存中 `FBlueprintImpactScanResult` | 不复制扫描逻辑到 Commandlet |
| ② BlueprintImpact Commandlet | Editor | `-run=AngelscriptBlueprintImpactScan` | stdout JSON + 退出码 | 必须复用 `ScanBlueprintAssets` |
| ③ SourceNavigation | Editor | UE 编辑器 "Go to Definition" | 调用系统 `code` 命令 | 测试用 `*ForTesting` 拦截 |
| ④ ContentBrowser DataSource | Editor | UE 内容浏览器枚举 | `FContentBrowserItemData` 流 | 不修改脚本文件 |
| ⑤ CodeGen | Editor | 编辑器手动命令 | 落盘 IDE 桩文件 | 仅读公开反射 API |
| Dump OnDumpExtensions | Runtime 提供 / Editor 注册 | `DumpAll` 末尾广播 | 写 `EditorReloadState.csv` 等 | 用 `FCSVWriter`，不拼字符串 |
| `as.DumpEngineState` | Runtime | 控制台 / 自动化测试 | 调 `DumpAll()` 落盘 | 不绕过 DumpAll 直接调 private |
| Test Shared/ | Test | 各测试 .cpp `#include` | C++ 编译期复用 | 不依赖 Editor 私有头 |
| Test Template/ | Test | 新增主题测试时拷贝改名 | 7 份基线 .cpp | 改 Template 等同改基线 |

---

## 附录 B：何时新增"协作通道"

如果你正在做的工作不属于上表任何一行，按以下决策树判定：

```
新需求来了，需要 Editor / Test / Dump 拿到某个 Runtime 状态吗？
├─ 是 -> Runtime 公开 API 已经够吗？
│       ├─ 够 -> 直接调，不要新增通道
│       └─ 不够 -> 三选一（按优先级）：
│             1) 在 Runtime 加一个 const public getter（最轻量）
│             2) 在 Runtime 加一个 public TMulticastDelegate（Editor/Test 订阅）
│             3) 在 Runtime 加 SetXxxOverrideForTesting + 配套 Clear（仅测试用）
└─ 否 -> 这不是 Editor/Test/Dump 的需求；可能属于 Runtime 自身的子系统改造
```

如果走到第三步发现需要 `friend struct FAngelscriptStateDump` —— 停下来，回到第一步。这条规则没有例外。

---

## 小结

- **三方位置**：Editor 仅在编辑器进程；Test 跨编辑器与 headless；Dump 在 Runtime 内、被 Editor 和 Test 同时消费。
- **Editor 5 个扩展点**各自有专属目录与单一切入点：HotReload 双链（DirectoryWatcher + ClassReloadHelper）、BlueprintImpact 双前端（Scanner + Commandlet 共用核心）、SourceNavigation（`ISourceCodeNavigationHandler`）、ContentBrowser（`UContentBrowserDataSource`）、CodeGen（编辑器命令触发）。
- **Test Shared/** 按 7 大类组织 60+ 文件；最关键的契约是 `FAngelscriptTestEngine` 的"static-method-only struct + 全部走公开 API"，从代码层面禁止 Test 私自访问引擎内部。
- **Dump 子系统**对外提供 `DumpAll()` + `OnDumpExtensions` + `as.DumpEngineState` 控制台命令；27 张 CSV 表（24 核心 + 2 扩展 + 1 Summary）通过统一入口写出，Editor 用扩展委托额外贡献 2 张表，Test 负责命令注册和输出契约回归。
- **跨界禁忌一句话**：所有 Editor / Test / Dump 想读 Runtime 的某个状态，正确解法都是"在 Runtime 加一个公开通道"，而不是在自己这一侧打补丁；这条原则在 `friend` / `private` / `EngineInternalAccess` / `*ForTesting` 四个层面有相应的"已有最佳实践"模板可直接复制。
