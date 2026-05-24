# RT_HotReload — 热重载与文件变更链路

> **所属前缀**: RT_（运行时子系统族）
> **关注层面**: 文件变更如何通过预处理 / 编译 / ClassGenerator / ClassReloadHelper 链路最终落到运行中的 UClass 与 actor 实例上（不写架构编排，那是 `Arch_RuntimeLifecycle.md` 的事；不写预处理器内部细节，那是 `Type_Preprocessor.md` 的事）
> **关键源码**:
> `Plugins/Angelscript/Source/AngelscriptEditor/HotReload/AngelscriptDirectoryWatcherInternal.{h,cpp}` (~107 行)
> · `Plugins/Angelscript/Source/AngelscriptEditor/HotReload/ClassReloadHelper.{h,cpp}` (~926 行)
> · `Plugins/Angelscript/Source/AngelscriptEditor/Core/AngelscriptEditorModule.cpp` (~1187 行，`StartupModule` 内 `RegisterDirectoryChangedCallback_Handle` + `OnScriptFileChanges`)
> · `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.h` (~46 KB，`ECompileType` / `ECompileResult` / `FFilenamePair` / `FHotReloadState`)
> · `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.cpp` (~5500 行，`Tick` / `CheckForHotReload` / `CheckForFileChanges` / `PerformHotReload` / `StartHotReloadThread`)
> · `Plugins/Angelscript/Source/AngelscriptRuntime/ClassGenerator/AngelscriptClassGenerator.{h,cpp}` (~10000+ 行，`Setup` / `PerformReload` / `ShouldFullReload` / 5 个 OnXXXReload 委托)
> · `Plugins/Angelscript/Source/AngelscriptEditor/BlueprintImpact/AngelscriptBlueprintImpactScanner.{h,cpp}` (~400 行，`AnalyzeLoadedBlueprint`)
> **关联文档**:
> `Documents/Knowledges/ZH/Arch_RuntimeLifecycle.md` — `Tick` 中 `CheckForHotReload` 调度的位置
> · `Documents/Knowledges/ZH/Arch_EditorTestDumpCollaboration.md` — Editor 双链入口（DirectoryWatcher + ClassReloadHelper）
> · `Documents/Knowledges/ZH/Type_Preprocessor.md` — §九 增量预处理（被本文反复调用）
> · `Documents/Knowledges/ZH/Type_ClassGeneration.md` — 类生成 10 步流程在 reload 时的复用
> · `Documents/Knowledges/ZH/Type_BaseClass.md` — `bWillBecomeCorrect` 安全网在 reload 中的位置

---

## 概览

本文聚焦一个核心问题：**当一个 `.as` 文件被保存到磁盘那一刻，从 OS 文件事件出发，要经过哪些代码路径，才能让运行中的 actor 实例 / Blueprint 子类 / 编辑器属性面板都"切换到新版本"？编译失败时如何安全地保留旧版？SoftReload 与 FullReload 又是按什么规则在分流？**

整个链路横跨三个 UE 模块、两次"队列穿越"、四个独立阶段，串成一张分层流水线：

```text
┌───────────────────────────────────────────────────────────────────────────┐
│ 阶段 0: 信号源（OS / 编辑器外部）                                          │
│   开发者按 Ctrl+S → VSCode / 任何文本编辑器写入 .as / 删除 .as / 改名      │
└───────────────────────────────────┬───────────────────────────────────────┘
                                    │
┌───────────────────────────────────▼───────────────────────────────────────┐
│ 阶段 1: 文件检测（两条互斥分支）                                           │
│                                                                            │
│  分支 A: Editor 模式 (bIsEditor=true)                                      │
│    AngelscriptEditor.StartupModule()                                       │
│      → IDirectoryWatcher::RegisterDirectoryChangedCallback_Handle          │
│      → OnScriptFileChanges(TArray<FFileChangeData>) (回调)                 │
│      → AngelscriptEditor::Private::QueueScriptFileChanges                  │
│      → push 到 FAngelscriptEngine::FileChangesDetectedForReload            │
│                  / FileDeletionsDetectedForReload                          │
│                                                                            │
│  分支 B: Standalone 开发模式 (bScriptDevelopmentMode && !bIsEditor)        │
│    后台线程 "AngelscriptHotReload" (TPri_Lowest)                           │
│      while (bRunning) { 若 bWaitingForHotReloadResults                     │
│                           CheckForFileChanges() → FileTime 比对            │
│                                                  → 同样填上面两个队列      │
│                         FPlatformProcess::Sleep(1ms) }                     │
└───────────────────────────────────┬───────────────────────────────────────┘
                                    │ 队列填好后等待 Tick 消费
                                    │
┌───────────────────────────────────▼───────────────────────────────────────┐
│ 阶段 2: Tick 中调度（Runtime 主线程，FAngelscriptEngine::Tick）            │
│   if (bScriptDevelopmentMode)                                              │
│     CompileType = (!GIsEditor || HasGameWorld()) ? SoftReloadOnly          │
│                                                  : FullReload              │
│     CheckForHotReload(CompileType)                                         │
│       FileList = FileChangesDetectedForReload                              │
│                + (timed) FileDeletionsDetectedForReload                    │
│                + (FullReload only) QueuedFullReloadFiles                   │
│       if (FileList.Num()) PerformHotReload(CompileType, FileList)          │
└───────────────────────────────────┬───────────────────────────────────────┘
                                    │
┌───────────────────────────────────▼───────────────────────────────────────┐
│ 阶段 3: PerformHotReload 主流程（核心）                                    │
│   ┌─────────────────────────────────────────────────────────────────┐      │
│   │ 3.1 反向依赖闭包                                                │      │
│   │     FilesToHotReload = FileList ∪                              │      │
│   │       { 所有依赖于 FileList 中模块的 module 的 Code 文件 }      │      │
│   │ 3.2 FAngelscriptPreprocessor.AddFile(...)                      │      │
│   │     bPreprocessSuccess = Preprocessor.Preprocess()             │      │
│   │     失败 → PreviouslyFailedReloadFiles += FileList; return     │      │
│   │ 3.3 CompileModules(CompileType, ...)                           │      │
│   │     → AS 编译器 → asCModule (新)                                │      │
│   │ 3.4 ClassGenerator.AddModule + Setup                           │      │
│   │     返回 EReloadRequirement                                    │      │
│   │       SoftReload / FullReloadSuggested / FullReloadRequired    │      │
│   │       / Error                                                  │      │
│   │ 3.5 按 (CompileType, ReloadRequirement) 分派：                 │      │
│   │       SoftReload → PerformSoftReload                           │      │
│   │       FullReloadRequired & SoftReloadOnly → 拒绝并 Queue       │      │
│   │       FullReloadSuggested & SoftReloadOnly → 降级 Soft + 警告  │      │
│   │       FullReload* & FullReload → PerformFullReload             │      │
│   └─────────────────────────────────────────────────────────────────┘      │
└───────────────────────────────────┬───────────────────────────────────────┘
                                    │
┌───────────────────────────────────▼───────────────────────────────────────┐
│ 阶段 4: ClassGenerator 内部 + ClassReloadHelper 反应                       │
│   PerformReload(bFullReload):                                              │
│     for module/class:                                                      │
│       if FullReload → CreateFullReloadClass / DoFullReload                 │
│       else          → LinkSoftReloadClasses / DoSoftReload                 │
│     Broadcast OnClassReload(Old, New) / OnStructReload / OnDelegateReload  │
│     Broadcast OnFullReload                                                 │
│       → ClassReloadHelper.cpp 收到, 调用 PerformReinstance:                │
│         · BP 子类替换 pin 类型                                              │
│         · ReparentHierarchies (UE 反实例化系统)                             │
│         · CompilationManager 重编 BP                                       │
│         · 重新打开受影响 asset 编辑器                                       │
│     Broadcast OnPostReload                                                 │
│       → RefreshAll / Invalidate ComponentRegistry / MAP REBUILD            │
│   FAngelscriptDebugServer::ReapplyBreakpoints (无论 Soft/Full)             │
└───────────────────────────────────────────────────────────────────────────┘
```

后续章节按"信号源 → 文件检测 → Tick 调度 → PerformHotReload → ClassGenerator 反应 → ClassReloadHelper 落地 → 失败回退 → PIE/Debugger/BP 协同 → 性能与速查"的顺序展开。

---

## 一、信号源与 DirectoryWatcher 入口

### 1.1 监听哪个目录、过滤什么文件

`AngelscriptEditorModule::StartupModule()` 在 Editor 模块加载时一次性建立 DirectoryWatcher 订阅：

```cpp
// ============================================================================
// 文件: AngelscriptEditor/Core/AngelscriptEditorModule.cpp
// 函数: FAngelscriptEditorModule::StartupModule（节选）
// ============================================================================
IDirectoryWatcher* DirectoryWatcher = ResolveDirectoryWatcher();
if (ensure(DirectoryWatcher != nullptr))
{
    UnregisterDirectoryWatchers(DirectoryWatchHandles, DirectoryWatcher);

    TArray<FString> AllRootPaths = FAngelscriptEngine::MakeAllScriptRoots();
    for (const auto& RootPath : AllRootPaths)
    {
        FDelegateHandle WatchHandle;
        if (DirectoryWatcher->RegisterDirectoryChangedCallback_Handle(
                *RootPath,
                IDirectoryWatcher::FDirectoryChanged::CreateStatic(&OnScriptFileChanges),
                WatchHandle,
                IDirectoryWatcher::IncludeDirectoryChanges) // ★
            && WatchHandle.IsValid())
        {
            DirectoryWatchHandles.Emplace(RootPath, WatchHandle);
        }
    }
}
```

要点：

- **监听对象**：`MakeAllScriptRoots()` 返回的所有 ScriptRoots（`Script/`、所有插件 `Script/` 目录、`Plugins/.../Script/` 等），不是单一目录。
- **`IncludeDirectoryChanges`**：除了文件变更，子目录的 add/remove 也要回调，因为开发者可能整目录拷贝进来。
- **句柄管理**：`DirectoryWatchHandles: TArray<TPair<FString, FDelegateHandle>>` 记录 root→handle 映射，`ShutdownModule` 时再 `UnregisterDirectoryChangedCallback_Handle` 一一注销。
- **测试钩子**：`ResolveDirectoryWatcher()` 优先查 `GDirectoryWatcherResolverForTesting`，允许测试用桩替换真 DirectoryWatcher 模块。

### 1.2 OnScriptFileChanges 与队列穿越

回调函数极薄，纯做"丢进队列"：

```cpp
// ============================================================================
// 文件: AngelscriptEditor/Core/AngelscriptEditorModule.cpp
// 函数: OnScriptFileChanges
// ============================================================================
void OnScriptFileChanges(const TArray<FFileChangeData>& Changes)
{
    // Ignore file changes before initialization finishes
    if (!FAngelscriptEngine::IsInitialized())
        return;

    FAngelscriptEngine& AngelscriptManager = FAngelscriptEngine::Get();
    AngelscriptEditor::Private::QueueScriptFileChanges(
        Changes,
        AngelscriptManager.AllRootPaths,
        AngelscriptManager,
        IFileManager::Get(),
        [&AngelscriptManager](const FString& AbsoluteFolderPath)
        {
            return AngelscriptEditor::Private::GatherLoadedScriptsForFolder(AngelscriptManager, AbsoluteFolderPath);
        });
}
```

- **第一道闸**：`!FAngelscriptEngine::IsInitialized()` 直接吞掉事件——Editor 模块比 Runtime 早注册回调，但 `FAngelscriptEngine` 在 InitialCompile 完成之前对外都是"未就绪"。这避免了启动期的伪事件污染队列。
- **`QueueScriptFileChanges`** 接受 `EnumerateLoadedScripts` 闭包作为参数：当目录被删除时需要查询当前已加载脚本中哪些落在该目录下，注入这个能力是为了让纯函数 `QueueScriptFileChanges` 能被测试单独测。
- **`AllRootPaths` 来自 Engine**：与 DirectoryWatcher 注册时的 `MakeAllScriptRoots()` 结果在生产路径上一致；`AllRootPaths` 还会被 `FindAllScriptFilenames`、`StartHotReloadThread` 复用。

### 1.3 QueueScriptFileChanges：分发 .as / 目录 / 删除

```cpp
// ============================================================================
// 文件: AngelscriptEditor/HotReload/AngelscriptDirectoryWatcherInternal.cpp
// 函数: QueueScriptFileChanges（节选）
// ============================================================================
for (const FFileChangeData& Change : Changes)
{
    const FString AbsolutePath = FPaths::ConvertRelativePathToFull(Change.Filename);
    FString RelativePath;
    if (!TryMakeRelativeScriptPath(AbsolutePath, RootPaths, RelativePath))
        continue;

    Engine.LastFileChangeDetectedTime = FPlatformTime::Seconds(); // ★ 全局时间戳

    if (AbsolutePath.EndsWith(TEXT(".as")))
    {
        if (Change.Action == FFileChangeData::FCA_Removed)
            Engine.FileDeletionsDetectedForReload.AddUnique({ AbsolutePath, RelativePath });
        else
            Engine.FileChangesDetectedForReload.AddUnique({ AbsolutePath, RelativePath });
        continue;
    }

    // 非 .as：可能是目录添加 / 删除事件
    if (Change.Action == FFileChangeData::FCA_Removed)
    {
        for (const auto& Loaded : EnumerateLoadedScripts(AbsolutePath / TEXT("")))
            Engine.FileDeletionsDetectedForReload.AddUnique(Loaded);
    }
    else if (Change.Action == FFileChangeData::FCA_Added && FileManager.DirectoryExists(*AbsolutePath))
    {
        TArray<FAngelscriptEngine::FFilenamePair> Contained;
        FAngelscriptEngine::FindScriptFiles(FileManager, RelativePath, AbsolutePath, TEXT("*.as"), Contained, false, false);
        for (const auto& File : Contained)
            Engine.FileChangesDetectedForReload.AddUnique(File);
    }
}
```

设计要点：

- **`AddUnique` 而非 `Add`**：DirectoryWatcher 在 Windows 上经常对一次保存连续触发多个 FCA_Modified 事件，去重避免下游被重复消费。
- **删除分队列**：`.as` 删除单独走 `FileDeletionsDetectedForReload`——因为删除往往是"重命名第一步"，需要等下一帧看有没有新增配对，避免误删除一个用户其实只是改名的文件。
- **目录新增递归展开**：用 `FindScriptFiles` 把新增目录里所有 `.as` 全部入队，避免漏掉拖入的整子目录。
- **`LastFileChangeDetectedTime`**：每次事件刷新该时间戳；后续 `CheckForHotReload` 用它做 200ms 的"重命名窗口"延时（详见 §三）。

### 1.4 Standalone 模式：HotReload 后台线程

非 Editor 但开启了 `bScriptDevelopmentMode` 的进程（命令行编辑器、独立测试 runner）走另一条线：

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Core/AngelscriptEngine.cpp
// 函数: FAngelscriptEngine::StartHotReloadThread
// ============================================================================
void FAngelscriptEngine::StartHotReloadThread()
{
    if (bUsedPrecompiledDataForPreprocessor) return;
    if (!bUseHotReloadCheckerThread)         return;
    if (bHotReloadThreadStarted)             return;
    bHotReloadThreadStarted = true;

    // 预热：先扫一遍把所有时间戳填进 FileHotReloadState
    CheckForFileChanges();
    FileChangesDetectedForReload.Empty(); // ★ 丢弃首扫结果

#if AS_CAN_HOTRELOAD
    struct FAngelscriptHotReloadThread : public FRunnable
    {
        bool bRunning = true;
        uint32 Run() override
        {
            auto& Manager = FAngelscriptEngine::Get();
            while(bRunning)
            {
                if (!Manager.bUseHotReloadCheckerThread) break;
                if (Manager.bWaitingForHotReloadResults)
                {
                    Manager.CheckForFileChanges();
                    Manager.bWaitingForHotReloadResults = false;
                }
                FPlatformProcess::Sleep(0.001f);
            }
            return 0;
        }
        void Stop() override { bRunning = false; }
    };
    FRunnableThread::Create(new FAngelscriptHotReloadThread(), TEXT("AngelscriptHotReload"), 0, EThreadPriority::TPri_Lowest);
#endif
}
```

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Core/AngelscriptEngine.cpp
// 函数: FAngelscriptEngine::CheckForFileChanges
// ============================================================================
TArray<FFilenamePair> Filenames;
FindAllScriptFilenames(Filenames);

for (FFilenamePair& Filename : Filenames)
{
    FDateTime FileTime = FileManager.GetTimeStamp(*Filename.AbsolutePath);
    FHotReloadState* FileState = FileHotReloadState.Find(Filename.RelativePath);
    if (FileState == nullptr)
    {
        FileChangesDetectedForReload.Add(Filename);                  // ★ 新文件
        FileHotReloadState.Add(Filename.RelativePath, { FileTime });
    }
    else if (FileTime != FileState->LastChange)
    {
        FileChangesDetectedForReload.Add(Filename);                  // ★ mtime 变化
        FileState->LastChange = FileTime;
    }
}
```

- 与 DirectoryWatcher 路径**互斥**：`bUseHotReloadCheckerThread = bScriptDevelopmentMode && !RuntimeConfig.bIsEditor`。Editor 进程绝不会启动这个线程，因为它会与 DirectoryWatcher 重复检测、且 `CheckForFileChanges` 自己就会 mutate 引擎数据结构。
- **基于 mtime 比对**：纯轮询，1ms Sleep 但只在 `bWaitingForHotReloadResults=true` 时干活——主线程 `CheckForHotReload` 会把这个 flag 翻成 true 并消费上一轮结果，循环驱动。
- **预热扫描丢弃**：`CheckForFileChanges()` + `FileChangesDetectedForReload.Empty()` 是为了把启动那一刻的 mtime baseline 建好，又不让 InitialCompile 之后立刻被同一批文件再触发一遍 reload。

---

## 二、文件检测后的队列结构

`FAngelscriptEngine` 公开三个并列字段供两条上游链路写入，被 Tick 中的 `CheckForHotReload` 唯一读取：

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Core/AngelscriptEngine.h
// 角色: HotReload 三大公共队列字段
// ============================================================================
public:
    TArray<FFilenamePair>   FileChangesDetectedForReload;     // 新增 / 修改
    TArray<FFilenamePair>   FileDeletionsDetectedForReload;   // 删除
    double                  LastFileChangeDetectedTime = -1.0;

private:
    TSet<FFilenamePair>     PreviouslyFailedReloadFiles;       // 编译失败重试
    TSet<FFilenamePair>     QueuedFullReloadFiles;             // PIE 期间挂起的 Full
    TMap<FString, FHotReloadState> FileHotReloadState;          // 后台线程的 mtime 缓存
```

字段职责一览：

| 字段 | 写入方 | 读取方 | 何时清空 |
|------|------|------|---------|
| `FileChangesDetectedForReload` | `QueueScriptFileChanges` / `CheckForFileChanges` | `CheckForHotReload`（每次都吞光） | 拷到 FileList 之后 `Empty()` |
| `FileDeletionsDetectedForReload` | 同上 | 同上，但**等 200ms 重命名窗口**才合并 | 同上 |
| `LastFileChangeDetectedTime` | `QueueScriptFileChanges` | `CheckForHotReload`（判断窗口） | 不显式清空 |
| `PreviouslyFailedReloadFiles` | `PerformHotReload`（每次失败都补） | `PerformHotReload` 入口（每次重试） | 进入 `PerformHotReload` 时合并 |
| `QueuedFullReloadFiles` | `CompileModules` 末段（PartiallyHandled / ErrorNeedFullReload） | `CheckForHotReload`（只在 `FullReload` 类型才取） | 取出后 `Empty()` |
| `FileHotReloadState` | `CheckForFileChanges` | 同上 | Shutdown |

**`FFilenamePair` 同时持有 Absolute 与 Relative 两个路径**——`AbsolutePath` 用于磁盘读 / `FileExists` 等 IO，`RelativePath` 是模块识别 key（`FAngelscriptModuleDesc::FCodeSection::RelativeFilename`），不能混用。

---

## 三、Tick 中的调度：CheckForHotReload

DirectoryWatcher 与后台线程都不直接触发编译，它们只能填队列；真正"开关"在 `FAngelscriptEngine::Tick` 里：

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Core/AngelscriptEngine.cpp
// 函数: FAngelscriptEngine::Tick（节选 HotReload 段）
// ============================================================================
#if AS_CAN_HOTRELOAD
if (bScriptDevelopmentMode)
{
    // 周期门控（仅后台线程模式生效）
    if (bUseHotReloadCheckerThread)
    {
        double CurrentTime = FPlatformTime::Seconds();
        if (NextHotReloadCheck > CurrentTime && !bWaitingForHotReloadResults)
            return;
        NextHotReloadCheck = CurrentTime + 0.1;     // ★ 100ms 节流
    }

    // PIE / 无 Editor / 有 GameWorld 一律只允许 Soft
    if (!GIsEditor || HasGameWorld())
        CheckForHotReload(ECompileType::SoftReloadOnly);
    else
        CheckForHotReload(ECompileType::FullReload);
}
#endif
```

`CheckForHotReload` 主体：

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Core/AngelscriptEngine.cpp
// 函数: FAngelscriptEngine::CheckForHotReload
// ============================================================================
TArray<FFilenamePair> FileList;
FileList.Append(FileChangesDetectedForReload);
FileChangesDetectedForReload.Empty();

// 删除事件需等 200ms「重命名窗口」
if (FileList.Num() != 0 || FPlatformTime::Seconds() - LastFileChangeDetectedTime > 0.2)
{
    for (const auto& DeletedFile : FileDeletionsDetectedForReload)
        FileList.AddUnique(DeletedFile);
    FileDeletionsDetectedForReload.Empty();
}

// 仅 FullReload 阶段才合并 PIE 期间挂起的文件
if (CompileType != ECompileType::SoftReloadOnly)
{
    for (const auto& QueuedFile : QueuedFullReloadFiles)
        FileList.AddUnique(QueuedFile);
    QueuedFullReloadFiles.Empty();
}

if (FileList.Num() != 0)
    PerformHotReload(CompileType, FileList);
```

设计要点：

- **`CompileType` 由调用方决定**：Tick 根据"GIsEditor && !HasGameWorld()" 二值得出；测试代码可以手动调 `CheckForHotReload(SoftReloadOnly)` 强制走某条路径。
- **200ms 重命名窗口**：删除事件不立即消费；只有当(a) 同时还有非删除事件，或 (b) 已超过 200ms 没有任何新事件时才把删除合并进来。这是为了让 VSCode 的"先删除旧文件再写新文件"的保存策略不会误触发"删类→新增类"的两次 reload。
- **`QueuedFullReloadFiles` 的延迟生效**：FullReload 才会消费它——这是 PIE 中"用户改了 UPROPERTY，FullReload 暂不能跑，先记账，等 PIE 退出"策略的实现。
- **节流 100ms**：仅后台线程模式生效；DirectoryWatcher 模式下每个 Tick 都直接看队列，但因为 DirectoryWatcher 自身已经做了批量合并，吞吐压力很小。

---

## 四、PerformHotReload：从文件清单到模块清单

### 4.1 反向依赖闭包

直接修改的文件未必是唯一要重编的——任何 import 它的模块都可能"被传染"：

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Core/AngelscriptEngine.cpp
// 函数: FAngelscriptEngine::PerformHotReload（节选反向依赖闭包）
// ============================================================================
TGuardValue<bool> ScopeHotReloading(bIsHotReloading, true);
FScopedSlowTask SlowTask(3.f, FText::FromString(TEXT("Angelscript Hot Reload")));
if (CompileType == ECompileType::FullReload && bIsInitialCompileFinished)
    SlowTask.MakeDialogDelayed(0.5f);
SlowTask.EnterProgressFrame(0.5f);

FAngelscriptPreprocessor Preprocessor;       // ★ 每次新建一个

TArray<FFilenamePair> FileList(InReloadFiles);
TSet<FFilenamePair>   AlreadyDeletedFiles;
for (auto& FailedFile : PreviouslyFailedReloadFiles)
{
    if (!FileManager.FileExists(*FailedFile.AbsolutePath))
        AlreadyDeletedFiles.Add(FailedFile);
    FileList.AddUnique(FailedFile);          // ★ 自动合并历史失败
}
PreviouslyFailedReloadFiles.Empty();
```

闭包扩展两种策略由 `ShouldUseAutomaticImportMethod()` 决定：

- **AutomaticImports = true**：用 AS 内核自带的 `asCModule::moduleDependencies` 反向遍历——每个模块知道自己依赖哪些其他模块，沿此链路推。
- **AutomaticImports = false**：用 `FAngelscriptModuleDesc::ImportedModules`（来自预处理器记录的显式 `import` 语句）构建反向依赖图，然后 BFS 推理。

两条路径最终都填到同一个 `TSet<FFilenamePair> FilesToHotReload`，然后整批送进 `Preprocessor.AddFile`。

### 4.2 预处理 → 编译

```cpp
for (const auto& PathPair : FilesToHotReload)
{
    const bool bTreatAsDeleted = AlreadyDeletedFiles.Num() != 0
        && AlreadyDeletedFiles.Contains(PathPair);
    Preprocessor.AddFile(PathPair.RelativePath, PathPair.AbsolutePath, bTreatAsDeleted);
}

bool bPreprocessSuccess = Preprocessor.Preprocess();
if (!bPreprocessSuccess)
{
    UE_LOG(Angelscript, Error, TEXT("Hot reload failed in preprocessing. Keeping all old angelscript code."));
    PreviouslyFailedReloadFiles.Append(FileList); // ★ 全员失败重试
    EmitDiagnostics();
    return false;
}

SlowTask.EnterProgressFrame(2.5f);

TArray<TSharedRef<FAngelscriptModuleDesc>> CompiledModules;
ECompileResult Result = CompileModules(CompileType, Preprocessor.GetModulesToCompile(), CompiledModules);
if (Result == ECompileResult::ErrorNeedFullReload) return false;
else if (Result == ECompileResult::Error)          return false;
```

注意三件事：

- **预处理器是新实例**——避免上次状态污染本次（`Type_Preprocessor.md` §九详细解释过）。
- **bTreatAsDeleted 走 Preprocessor 的「假装已删」分支**：被删的文件参与依赖闭包但不参与 module 装配，避免编译器拿到一份残缺的 module。
- **CompileModules 是核心**：调用 `CompileModule_Types_Stage1 / Functions_Stage2 / Code_Stage3 / Globals_Stage4` 四阶段（详见 `Type_ClassGeneration.md`）。在它内部还会调用 `FAngelscriptClassGenerator::Setup` 与 `PerformReload`，分支决策见下一节。

### 4.3 编译失败时的回退

`PerformHotReload` 自身的失败处理只有 "记账 + return false"；真正复杂的回退在 `CompileModules` 末段（`AngelscriptEngine.cpp` ~4407..4509 行）：

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Core/AngelscriptEngine.cpp
// 函数: FAngelscriptEngine::CompileModules（节选回退分支）
// ============================================================================
if (bShouldSwapInModules)
{
    // 走「成功」路径：discard 旧 module / 更新 ModulesByScriptModule / 重建 imports
}
else
{
    // 关键回退：把已经在新模块里替换的 reflection 数据指针「替回去」
    if (ModulesToUpdateReferences.Num() != 0)
    {
        asModuleReferenceUpdateMap ReverseUpdateMap;
        ScriptUpdateMap.BuildReverseMap(OUT ReverseUpdateMap);

        for (auto Module : ModulesToUpdateReferences)
        {
            asCModule* ScriptModule = Module->ScriptModule;
            if (ScriptModule == nullptr) continue;
            ScriptModule->UpdateReferencesInReflectionDataOnly(ReverseUpdateMap);
            UpdateScriptReferencesInUnrealData(ReverseUpdateMap, Module);
            ScriptModule->UpdateReferencesInScriptBytecode(ReverseUpdateMap);
        }
    }

    // 把没用上的新模块从 AS 引擎中拆掉
    for (auto Module : CompiledModules)
    {
        if (Module->ScriptModule != nullptr)
        {
            auto* OldScriptModule = (asCModule*)Module->ScriptModule;
            OldScriptModule->RemoveTypesAndGlobalsFromEngineAvailability();
            OldScriptModule->InternalReset();
            Engine->DiscardModule(OldScriptModule->GetName());
            Module->ScriptModule = nullptr;
        }
    }
}
```

这段是"原子失败"语义的核心：要么整批 swap-in，要么所有引用替回去——不能让一个新 module 半进半出导致脚本看到的"类型半新半旧"。

失败到底分几种？由 `CompileModules` 末段最终 result 决定：

```cpp
ECompileResult Result = ECompileResult::FullyHandled;
if (!bShouldSwapInModules || bHadCompileErrors)
    Result = bFullReloadRequired ? ECompileResult::ErrorNeedFullReload : ECompileResult::Error;
else if (!bWasFullyHandled)
    Result = ECompileResult::PartiallyHandled;

if (CompileType != ECompileType::Initial && Result != ECompileResult::FullyHandled)
{
    TArray<FFilenamePair> AllCompiledFiles = ...;
    if (Result == ECompileResult::ErrorNeedFullReload)
    {
        for (const auto& f : AllCompiledFiles) QueuedFullReloadFiles.Add(f); // ★ PIE 退出后 Full
        PreviouslyFailedReloadFiles.Append(AllCompiledFiles);                // ★ 下次重试
    }
    else if (Result == ECompileResult::Error)
    {
        PreviouslyFailedReloadFiles.Append(AllCompiledFiles);
    }
    else if (Result == ECompileResult::PartiallyHandled)
    {
        for (const auto& f : AllCompiledFiles) QueuedFullReloadFiles.Add(f); // ★ 同上
    }
}
```

| Result | 含义 | 后续动作 |
|--------|------|---------|
| `FullyHandled` | 模块全部 swap-in，UClass 全部更新 | 无需重试 |
| `PartiallyHandled` | 模块 swap-in 但只做了 Soft（FullReloadSuggested 在 PIE 中被降级） | 进 `QueuedFullReloadFiles`，PIE 退出后再 Full |
| `Error` | 编译错误或语义错误，模块未 swap-in | 进 `PreviouslyFailedReloadFiles`，下次任意 reload 自动一起重试 |
| `ErrorNeedFullReload` | 模块需要 Full，但当前是 SoftReloadOnly，被拒绝 | 同时进 `Queued` 与 `PreviouslyFailed`，PIE 后会带着重试 |

---

## 五、SoftReload vs FullReload：判定决策

### 5.1 决策枚举与三档语义

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/ClassGenerator/AngelscriptClassGenerator.h
// 函数: enum EReloadRequirement
// ============================================================================
enum EReloadRequirement
{
    SoftReload,            // 函数体改动等可热替换语义
    FullReloadSuggested,   // 类型签名变化但能容忍延后 Full
    FullReloadRequired,    // 必须立刻 Full（UPROPERTY 增减、基类变更等）
    Error,                 // 不可恢复的语义错误，整批拒绝
};
```

三档之间是**单调升序**：Analyze 阶段每检测到一个变化只能"升档"不能"降档"。例如：

```cpp
if (ClassData.ReloadReq < EReloadRequirement::FullReloadRequired)
    ClassData.ReloadReq = EReloadRequirement::FullReloadRequired;
```

### 5.2 谁触发哪一档

`AngelscriptClassGenerator.cpp` 的 `Analyze` / `PropagateReloadRequirements` 长函数里枚举了几十种条件（行 187–1991），归纳成三类：

| 触发因素 | 档位 | 直觉解释 |
|----------|------|----------|
| 函数体改动（语法树等价但字节码不同） | `SoftReload` | UFunction 实体不变，只换 bytecode 即可 |
| 仅添加 / 移除非 UFUNCTION 私有方法 | `SoftReload` | 反射对外不可见 |
| 函数签名变化（参数个数、类型） | `FullReloadRequired` | UFunction 反射结构必须重建 |
| UPROPERTY 增 / 删 / 改类型 | `FullReloadRequired` | UClass 内存布局 / GC schema 必须重建 |
| 基类变化（`super` / interface） | `FullReloadRequired` | UClass 继承链 / VTable 必须重建 |
| 添加新类 / 新枚举 / 新 delegate | `FullReloadRequired`（详见 `ShouldFullReload`） | 新增反射对象必须走 Full 才能注册到 UE 反射 |
| 类似"interface 实现列表变化" | `FullReloadRequired` | UClass.Interfaces 数组要重建 |
| 默认值改动（`default Foo = X`） | `SoftReload` 或 `FullReloadSuggested` | 视改动是否影响 CDO 序列化 |
| Module 上次 swap-in 失败 (`bModuleSwapInError`) | `FullReloadRequired` | 必须强制走 Full 重建 |
| BlueprintImpl 函数 (`UFUNCTION(BlueprintOverride)`) 增减 | `FullReloadSuggested` | 影响 BP 生成节点列表 |

Analyze 还会沿 `FReloadPropagation` 跨类型传播：如果一个 struct 升到 Full，所有引用它的 class 也跟着升。

### 5.3 PerformHotReload 中的派发表

回到 `CompileModules` ~4333 行：

```cpp
switch (ReloadReq)
{
    case FAngelscriptClassGenerator::EReloadRequirement::SoftReload:
        SwapInModules(CompiledModules, DiscardedModules);
        ClassGenerator.PerformSoftReload();                        // ★ 永远 OK
        break;

    case FAngelscriptClassGenerator::EReloadRequirement::FullReloadSuggested:
        if (CompileType == ECompileType::SoftReloadOnly)
        {
            // PIE 中：警告但降级走 Soft，标记 PartiallyHandled
            for (auto Module : CompiledModules)
                if (ClassGenerator.WantsFullReload(Module))
                    ScriptCompileError(Module, ReloadLine,
                        TEXT("Performing a Soft Reload during PIE...A Full Reload will be queued for after PIE ends."),
                        false);
            bWasFullyHandled = false;
            SwapInModules(CompiledModules, DiscardedModules);
            ClassGenerator.PerformSoftReload();
        }
        else
        {
            SwapInModules(CompiledModules, DiscardedModules);
            ClassGenerator.PerformFullReload();
        }
        break;

    case FAngelscriptClassGenerator::EReloadRequirement::FullReloadRequired:
        if (CompileType == ECompileType::SoftReloadOnly)
        {
            // PIE 中拒绝，旧代码继续跑
            ScriptCompileError(...);
            bShouldSwapInModules = false;
            bFullReloadRequired = true;
        }
        else
        {
            SwapInModules(CompiledModules, DiscardedModules);
            ClassGenerator.PerformFullReload();
        }
        break;

    case FAngelscriptClassGenerator::EReloadRequirement::Error:
        bShouldSwapInModules = false;
        bHadCompileErrors = true;
        break;
}
```

四档语义浓缩成一张决策表：

| 编译类型 \ 需求档 | SoftReload | FullReloadSuggested | FullReloadRequired | Error |
|------|------|------|------|------|
| `Initial`       | Soft | Full | Full | 失败 |
| `SoftReloadOnly` (PIE/Game) | Soft | **降级 Soft + 警告 + Queue Full** | **拒绝 + Queue Full + 旧代码继续跑** | 失败 |
| `FullReload`    | Soft | Full | Full | 失败 |

---

## 六、ClassGenerator 内部：双轨重载

`PerformReload(bFullReload)` 内部按"struct 先 / class 后"+"new 先 / 改 后"+"Full 先 / Soft 后"的多重排序处理（`AngelscriptClassGenerator.cpp` ~2247..2620）。简化骨架：

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/ClassGenerator/AngelscriptClassGenerator.cpp
// 函数: FAngelscriptClassGenerator::PerformReload（节选）
// ============================================================================
bIsDoingFullReload = bFullReload;

// 1. 创建 / 链接：决定每个 class/struct/delegate/enum 走哪条
for (auto& M : Modules) for (auto& C : M.Classes)
{
    if (ShouldFullReload(C))
    {
        if (C.NewClass->bIsStruct) CreateFullReloadStruct(M, C);
        else                       CreateFullReloadClass(M, C);
    }
    else
    {
        LinkSoftReloadClasses(M, C); // ★ 找出 OldClass，并把 NewClass 链到它
    }
}

// 2. Enum / Struct 优先 DoFullReload（被 class 引用）
for (auto& M : Modules) for (auto& E : M.Enums)
    if (ShouldFullReload(E)) DoFullReload(M, E);
for (auto& M : Modules) for (auto& C : M.Classes)
    if (ShouldFullReload(C) && C.NewClass->bIsStruct) DoFullReload(M, C);

// 3. Class 的 PrepareSoftReload 必须先于 DoFullReload(class)
for (auto& M : Modules) for (auto& C : M.Classes)
    if (!C.NewClass->bIsStruct && !ShouldFullReload(C)) PrepareSoftReload(M, C);
for (auto& M : Modules) for (auto& C : M.Classes)
    if (!C.NewClass->bIsStruct && ShouldFullReload(C))  DoFullReload(M, C);

// 4. SoftReload(class) 必须最晚 —— 它依赖前面 Full 出来的全套新结构
for (auto& M : Modules) for (auto& C : M.Classes)
    if (!C.NewClass->bIsStruct && !ShouldFullReload(C)) DoSoftReload(M, C);

// 5. Finalize
for (auto& M : Modules) for (auto& C : M.Classes)
    if (!C.NewClass->bIsStruct && ShouldFullReload(C)) FinalizeClass(M, C);
CallPostInitFunctions();
InitDefaultObjects();
```

为什么要这么严苛的顺序？因为 `DoSoftReload(class)` 内部要 patch class 的 UFunction 体到新 bytecode，patch 的过程会引用已经 Full Reload 过的 struct / enum / parent class——任何乱序都会让 patch 看到半旧半新的反射数据。

### 6.1 ShouldFullReload 的兜底规则

除了 Analyze 阶段算出来的 `ReloadReq` 外，还有几条硬规则：

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/ClassGenerator/AngelscriptClassGenerator.cpp
// 函数: ShouldFullReload(FClassData&)
// ============================================================================
if (bIsDoingFullReload && Class.ReloadReq >= EReloadRequirement::FullReloadSuggested)
    return true;
if (Class.NewClass->ImplementedInterfaces.Num() > 0) // ★ 有接口 → 必走 Full
    return true;
if (!Class.OldClass.IsValid() && !Class.NewClass->bIsStaticsClass) // ★ 全新类
    return true;
return false;
```

新增类（`!OldClass`）必须走 Full，因为 SoftReload 没有任何 OldClass 可链接，UClass 必须新建。

### 6.2 五个 Reload 委托

`FAngelscriptClassGenerator` 在 `PerformReload` 末段广播：

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/ClassGenerator/AngelscriptClassGenerator.h
// 角色: 5 个公开 reload 通知委托
// ============================================================================
static FOnAngelscriptClassReload     OnClassReload;     // (UClass* Old, UClass* New)
static FOnAngelscriptStructReload    OnStructReload;    // (UScriptStruct* Old, UScriptStruct* New)
static FOnAngelscriptDelegateReload  OnDelegateReload;  // (UDelegateFunction* Old, New)
static FOnAngelscriptEnumChanged     OnEnumChanged;     // (UEnum*, OldNames)
static FOnAngelscriptEnumCreated     OnEnumCreated;     // (UEnum*)
static FOnAngelscriptLiteralAssetReload OnLiteralAssetReload; // (UObject* Old, New)
static FOnAngelscriptFullReload      OnFullReload;      // ()
static FOnAngelscriptPostReload      OnPostReload;      // (bFullReload)
```

`OnFullReload` 的唯一订阅者是 Editor 模块的 `FClassReloadHelper`——它通过 `PerformReinstance()` 把 UE 反射系统拉进重载循环。

---

## 七、ClassReloadHelper：从新 UClass 到现有 actor 实例

### 7.1 订阅链路

`FAngelscriptEditorModule::StartupModule()` 第一行就是 `FClassReloadHelper::Init()`：

```cpp
// ============================================================================
// 文件: AngelscriptEditor/HotReload/ClassReloadHelper.h
// 函数: FClassReloadHelper::Init（节选）
// ============================================================================
FAngelscriptClassGenerator::OnClassReload.AddLambda(
[](UClass* OldClass, UClass* NewClass)
{
    if (OldClass != nullptr) ReloadState().ReloadClasses.Add(OldClass, NewClass);
    else                     ReloadState().NewClasses.Add(NewClass);

    // 触及 Interface？标记需要全量刷 BP Action 数据库
    const bool bTouchesInterface =
        (OldClass && (OldClass->HasAnyClassFlags(CLASS_Interface) || OldClass->Interfaces.Num() > 0))
     || (NewClass && (NewClass->HasAnyClassFlags(CLASS_Interface) || NewClass->Interfaces.Num() > 0));
    if (bTouchesInterface) ReloadState().bRefreshAllActions = true;

    // 即时刷该类的 BP 节点（SubComponent / 模板节点）
    if (!ReloadState().bRefreshAllActions && GEngine != nullptr)
    {
        if (OldClass) FBlueprintActionDatabase::Get().RefreshClassActions(OldClass);
        if (NewClass) FBlueprintActionDatabase::Get().RefreshClassActions(NewClass);
    }

    // ActorComponent 子类 → ComponentTypeRegistry 失效
    if (NewClass && NewClass->IsChildOf(UActorComponent::StaticClass()))
        FComponentTypeRegistry::Get().InvalidateClass(NewClass);

    // Volume 子类 → 标记需要 MAP REBUILD
    if (NewClass && NewClass->IsChildOf(AVolume::StaticClass()))
        ReloadState().bReloadedVolume = true;
});

FAngelscriptClassGenerator::OnFullReload.AddLambda(
[](){ ReloadState().PerformReinstance(); });        // ★ 真正的反实例化总入口

FAngelscriptClassGenerator::OnPostReload.AddLambda(
[](bool bFullReload){ /* RefreshAll / Invalidate / MAP REBUILD / Reset(ReloadState) */ });
```

`ReloadState()` 是函数级 static 单例，跨多次回调累积"本批 reload 涉及的所有变化"，到 `OnFullReload` 时一次性消费——避免每次回调都跑一遍极昂贵的 `PerformReinstance`。

### 7.2 PerformReinstance 主流程

`PerformReinstance` 是整个 HotReload 链路里最长、最重的一段。以下是关键骨架（细节见 `AngelscriptEditor/HotReload/ClassReloadHelper.cpp` 行 230..595）：

```cpp
// ============================================================================
// 文件: AngelscriptEditor/HotReload/ClassReloadHelper.cpp
// 函数: FClassReloadHelper::FReloadState::PerformReinstance（核心骨架）
// ============================================================================
LLM_SCOPE_BYTAG(Angelscript);                       // ★ 全部内存归到 Angelscript 桶
if (!FAngelscriptEngine::Get().bIsInitialCompileFinished) return; // 初次编译不走 reinstance

// 1. 给 ReplaceHelper 上 root，让 GC 不会先把它收掉
if (ReplaceHelper == nullptr)
{
    ReplaceHelper = NewObject<UAngelscriptReferenceReplacementHelper>(GetTransientPackage());
    ReplaceHelper->AddToRoot();
}

if (GAngelscriptUseUnrealReload == 0)              // ★ 默认走老路（更稳）
{
    // 2. 收集所有 Blueprint，对每张图替换 pin 类型与变量类型
    AngelscriptEditor::BlueprintImpact::FBlueprintImpactSymbols ImpactSymbols;
    for (const auto& [Old, New] : ReloadClasses)   ImpactSymbols.Classes.Add(Old);
    for (const auto& [Old, New] : ReloadStructs)   ImpactSymbols.Structs.Add(Old);
    // ... Enums / Delegates 同理

    TArray<UBlueprint*> DependencyBPs;
    for (TObjectIterator<UBlueprint> It; It; ++It)
    {
        TArray<EBlueprintImpactReason> Reasons;
        const bool bDep = AnalyzeLoadedBlueprint(**It, ImpactSymbols, Reasons);

        for (UK2Node* Node : 所有节点)
            ReplacePinType(Node->Pins);
        for (FBPVariableDescription& V : (*It)->NewVariables)
            ReplacePinType(V.VarType);

        if (bDep) DependencyBPs.Add(*It);
    }

    // 3. DataTable 持有 RowStruct → 同样要替换
    for (auto& [Old, New] : ReloadStructs)
        for (UDataTable* T : GetTablesDependentOnStruct(Old)) T->RowStruct = New;

    CollectGarbage(GARBAGE_COLLECTION_KEEPFLAGS, true); // ★ GC 一次

    // 4. 真正的 reinstance：UE 反实例化系统
    FBlueprintCompilationManager::ReparentHierarchies(ReloadClasses); // ★

    CollectGarbage(GARBAGE_COLLECTION_KEEPFLAGS, true); // ★ 再 GC 一次

    // 5. 受影响 BP 子类 → 重新编译
    if (DependencyBPs.Num() != 0)
    {
        for (UBlueprint* BP : DependencyBPs)
        {
            // 5.1 节点级：HasExternalDependencies 命中新结构 → ReconstructNode
            for (UK2Node* Node : 所有节点)
                if (依赖到新类型)
                    Schema->ReconstructNode(*Node, true);

            FBlueprintCompilationManager::QueueForCompilation(BP);
        }
        FBlueprintCompilationManager::FlushCompilationQueueAndReinstance();
    }

    // 6. UserDefinedStruct → BroadcastPostChange
    for (auto& [Old, New] : ReloadStructs)
        if (auto* US = Cast<UUserDefinedStruct>(New))
            FStructureEditorUtils::BroadcastPostChange(US);
}
else
{
    // 备选路径：UE 5.0+ 的标准 FReload (实验)
    // for ReloadStructs/Classes/Enums → Reload->NotifyChange / Reinstance / Finalize
}

// 7. 强制刷新属性面板
NotifyCustomizationModuleChangedForReload();

// 8. 新 Volume class → 注册 ActorFactory
for (UClass* NV : NewClasses where 是 AVolume 子类)
    foreach UActorFactoryVolume 子类 → NewObject<UActorFactory>(VolumeFactoryClass)

// 9. Enum 变化 → RefreshAssetActions
for (UEnum* E : ReloadEnums) RefreshAssetActionsForReload(E);
for (UEnum* E : NewEnums)    RefreshAssetActionsForReload(E);

// 10. 新增可放置 Actor → 更新 Place Actors 面板
if (NewClasses.Num() != 0)
{
    BroadcastAllPlaceableAssetsChangedForReload();
    BroadcastPlaceableItemFilteringChangedForReload();
}
```

要点：

- **两次 `CollectGarbage`** 围绕 `ReparentHierarchies`：保证 ReparentHierarchies 看到的是已清理的旧实例，再清一次让旧实例真正被回收。
- **`UAngelscriptReferenceReplacementHelper` AddToRoot**：自身常驻，重写 `Serialize` 来劫持 AssetEditorSubsystem 持有的资产引用，让正在编辑器中打开的 asset 也能被替换为新版本（同时关闭旧 editor、再打开新 editor）。
- **Blueprint Impact 双重使用**：`AnalyzeLoadedBlueprint` 在这里被复用做"哪些 BP 需要 recompile"判断；同样的扫描逻辑还可被 `BlueprintImpactCommandlet` 离线使用，详见 `Arch_EditorTestDumpCollaboration.md`。

### 7.3 OnPostReload 的收尾

```cpp
// ============================================================================
// 文件: AngelscriptEditor/HotReload/ClassReloadHelper.h
// 函数: OnPostReload AddLambda（节选）
// ============================================================================
if (ReloadState().bRefreshAllActions && GEngine != nullptr)
    FBlueprintActionDatabase::Get().RefreshAll();           // ★ 全量刷 BP Action

if (bFullReload && GEditor != nullptr)
    GEditor->BroadcastBlueprintCompiled();                  // ★ 让 SCS / Component Editor 等更新

if (!FAngelscriptEngine::IsInitialized() || !FAngelscriptEngine::Get().IsInitialCompileFinished())
    FComponentTypeRegistry::Get().Invalidate();             // 初次编译期：全量失效

if (ReloadState().bReloadedVolume && GEngine != nullptr)
{
    auto* World = GEditor->GetEditorWorldContext().World();
    ULevel* CurrentLevel = World->GetCurrentLevel();
    GEngine->Exec(World, TEXT("MAP REBUILD ALLVISIBLE"));   // ★ Volume 几何重建
    if (IsValid(CurrentLevel) && World->GetLevels().Contains(CurrentLevel))
        World->SetCurrentLevel(CurrentLevel);               // 5.4.1 bug workaround
}

ReloadState() = FReloadState();                             // ★ 重置累积状态
```

`MAP REBUILD ALLVISIBLE` 是一个 console 命令，在 5.4.1 上有 bug 会重置 CurrentLevel——所以下一行手工恢复。这种"保守地修复 UE 编辑器自身 bug"的代码在 ClassReloadHelper 里相当多，是 HotReload 不能直接套用 UE 标准 `FReload` 的主要原因（CVar `angelscript.UseUnrealReload` 默认 0 就是这个意思）。

---

## 八、actor 实例与 BP 子类如何保留状态

### 8.1 actor 实例的 reinstance

调用栈：

```text
ClassGenerator.PerformFullReload
    ClassGenerator.OnClassReload Broadcast (Old, New)
        ClassReloadHelper.OnClassReload Lambda → ReloadState.ReloadClasses[Old] = New
    ClassGenerator.OnFullReload Broadcast
        ClassReloadHelper.PerformReinstance
            FBlueprintCompilationManager::ReparentHierarchies(ReloadClasses)
                内部对每个 OldClass:
                    - 找到所有 instance (含 actor / component / object)
                    - 用 NewClass 重新构造
                    - FArchiveReplaceObjectRef 把所有引用替换
                    - Old Class.ClassFlags |= CLASS_NewerVersionExists
                    - 把 instance 上的 UProperty 值「按名字」转抄到新版（删掉的属性自然丢失，新增的属性取 CDO 默认值）
```

**关键："按名字 + 类型"转抄**：UE 的 reinstance 机制能保留同名同类型 UProperty 的值（即使顺序变了），但跨类型转换不会发生（int → float 也不会自动）。

### 8.2 Blueprint child class 处理

脚本类作为 BP 父类的情况（`BP_Foo : AHotReloadLifecycleTarget : AActor`）需要两步：

1. **PerformReinstance §7.2 步骤 5** 已经识别出"图中 pin / 变量类型 / 节点引用了被 reload 的脚本类"，把它们加入 `DependencyBPs` 并 `QueueForCompilation`。
2. `FlushCompilationQueueAndReinstance()` 一次性编译这批 BP——内部仍会调用一次 `ReparentHierarchies`，但这次的 OldClass→NewClass map 是 BP 自身 `*_C`。

测试覆盖在 `AngelscriptHotReloadLifecycleTests.cpp::FAngelscriptHotReloadDoesNotReplayBeginPlayOnLiveActorTest`：保证 SoftReload 不会让已经 BeginPlay 过的 actor "重播一次 BeginPlay"——这是状态保留的硬指标。

### 8.3 bWillBecomeCorrect 安全网

reinstance 不是瞬时原子的——`TSubclassOf<X>` 类型的 UProperty 在 ReparentHierarchies 中段可能短暂指向尚未替换为新 X 的旧 UClass。`Bind_TSubclassOf::SetClass` 用一个保险丝避免这一窗口期 throw 异常：

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Binds/Bind_TSubclassOf.h
// 函数: SetClass（节选保险丝）
// ============================================================================
bool bWillBecomeCorrect = false;
#if AS_CAN_HOTRELOAD
// 在 reload 中段，asset 可能尚未 reinstance 到新类
if (auto* ASTemplate = Cast<UASClass>(TemplateClass))
{
    if (UASClass* ASAsset = UASClass::GetFirstASClass(InClass))
    {
        if (ASAsset->GetMostUpToDateClass()->IsChildOf(ASTemplate))
            bWillBecomeCorrect = true; // ★ 给即将被替换的旧版放行
    }
}
#endif

if (InClass->IsChildOf(TemplateClass) || bWillBecomeCorrect)
    *Ptr = InClass;
else
    FAngelscriptEngine::Throw("Class set to TSubclassOf<> was not a child of templated class.");
```

详见 `Type_BaseClass.md` —— 它把这个安全网放在"基类 / 类型解析"那条主线里描述。

---

## 九、PIE / Debugger / BlueprintImpact 协同

### 9.1 PIE 行为

PIE 中 `HasGameWorld()` 返回 true，`Tick` 强制走 `SoftReloadOnly`：

- **SoftReload 改动 → 立即生效**：典型场景是改函数体调试 gameplay 逻辑，不破坏现存 actor 状态。
- **FullReloadSuggested → 降级 + Queue**：在 ScriptCompileError 中告诉用户"你改了 UPROPERTY，要等 PIE 退出才会真正生效"，但 module 已经 swap 进去了，只是 ClassGenerator 跑了 Soft 路径。
- **FullReloadRequired → 拒绝 + Queue**：旧 .as 代码继续运行，编译错误面板红字提示。
- **PIE 退出**：`HasGameWorld()` 重新变 false，`CheckForHotReload(FullReload)` 把 `QueuedFullReloadFiles` 收回来跑一遍，最终所有改动一次性 Full。

### 9.2 Debugger 协同

```cpp
// 节选自 PerformHotReload 末段
#if WITH_AS_DEBUGSERVER
if (DebugServer != nullptr)
    DebugServer->ReapplyBreakpoints();
#endif
```

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Debugging/AngelscriptDebugServer.cpp
// 函数: FAngelscriptDebugServer::ReapplyBreakpoints
// ============================================================================
for (auto& [ModuleName, FileBP] : Breakpoints)
{
    if (FileBP->Lines.Num() == 0) FileBP->Module = nullptr;
    else
    {
        auto ModuleDesc = Manager.GetModuleByModuleName(ModuleName);
        FileBP->Module = ModuleDesc;
        if (ModuleDesc.IsValid())
        {
            auto* ScriptModule = (asCModule*)ModuleDesc->ScriptModule;
            if (ScriptModule != nullptr) ScriptModule->hasBreakPoints = true;
        }
    }
}
```

断点表本身是 `module name → lines` 的纯数据，HotReload 之后旧 `asCModule*` 已被丢弃，必须把当前断点重新解析到新的 `ScriptModule` 上并设置 `hasBreakPoints` flag——否则 VM 在新 module 中根本不会触发断点回调。

### 9.3 与 BlueprintImpact 的协同

`PerformReinstance` 内部直接调用 `AnalyzeLoadedBlueprint`（同一份 API）扫每个内存中的 BP。这与离线 `BlueprintImpactCommandlet` 走的是完全相同的判别逻辑——只是 commandlet 走 AssetRegistry 扫磁盘 BP，编辑器 reload 路径走 `TObjectIterator<UBlueprint>` 扫已加载 BP。

判别命中后会标记 `EBlueprintImpactReason`：

| 原因 | 含义 |
|------|------|
| `ScriptParentClass` | BP 父类是被 reload 的脚本类 |
| `NodeDependency`    | K2Node 自带 `HasExternalDependencies` 命中新类型 |
| `PinType`           | Pin 上的 PinSubCategoryObject 命中 |
| `VariableType`      | NewVariables 中变量类型命中 |
| `DelegateSignature` | 委托 K2Node_Event 的签名函数命中 |
| `ReferencedAsset`   | 节点 / 变量上的默认值是被 reload 的 LiteralAsset |

---

## 十、性能：reload 各阶段大致占比

`AngelscriptHotReloadPerformanceTests.cpp` 把 reload 拆成四个性能 baseline 写到 `metrics.json`：

| 测试名 | 改动模型 | 走的路径 | metric key |
|--------|---------|----------|------------|
| `Performance.SoftReloadLatency` | 只改函数体 (`return 1` → `return 2`) | `SoftReloadOnly` | `reload.modify.soft_seconds` |
| `Performance.FullReloadLatency` | 增加一个 UPROPERTY | `FullReload` | `reload.full.seconds` |
| `Performance.RenameWindowLatency` | 删旧 + 加新（模拟改名） | `FullReload` | `reload.rename_window.full_seconds` |
| `Performance.BurstChurnLatency` | 连续 soft / full / soft 三次 | 混合 | `reload.burst_churn.seconds` |

阶段时间分布（实测经验，依硬件 / 项目而异）：

```text
Soft (单文件，10+ class):
  ┌──────────────┐
  │ Preprocess   │ 5–20 ms     (Type_Preprocessor §九)
  │ Compile      │ 10–50 ms    (CompileModule_*4 阶段)
  │ ClassGen     │ 5–20 ms     (LinkSoftReloadClasses + DoSoftReload)
  │ NotifyCustom │ <5 ms       (PropertyEditor refresh)
  └──────────────┘ 总：30–100 ms

Full (单 UPROPERTY 增删):
  ┌──────────────┐
  │ Preprocess   │ 5–20 ms
  │ Compile      │ 10–50 ms
  │ ClassGen     │ 50–200 ms   (CreateFullReloadClass + DoFullReload + Finalize)
  │ Reinstance   │ 100–500 ms  (ReparentHierarchies + GC×2)
  │ BP Recompile │ 0–N×秒      (∝ DependencyBPs.Num())
  │ MAP REBUILD  │ 仅 Volume 改动时 100 ms+
  └──────────────┘ 总：150 ms – N 秒
```

主要拖慢因素：

- **依赖闭包过宽**：被 reload 的文件有海量反向依赖时，`FilesToHotReload` 会把许多无关模块也卷进来重编。`GAngelscriptRecompileAvoidance && ShouldUseAutomaticImportMethod()` 路径下会把闭包退化成"只编实际改的文件"，把依赖处理推给 AS 编译器内部的精确依赖检查，是大型项目的常见加速开关。
- **DependencyBPs 多**：上千个 BP 引用一个常用脚本基类时 FullReload 编译队列会很长，可考虑拆分基类粒度。
- **GC 两次**：`PerformReinstance` 中 `CollectGarbage` 是 GC 全量；如果项目在 Editor 中有大量 transient UObject，这两次会比预期慢。

---

## 十一、失败回退：再过一遍

把前面散落的失败处理串起来：

```text
失败发生点                动作                           状态走向
─────────────────────────────────────────────────────────────────────
Preprocess 失败          PreviouslyFailedReloadFiles    下次任意 reload 重试
                         += FileList; return false

Compile 错误             PreviouslyFailedReloadFiles    下次任意 reload 重试
                         += AllCompiledFiles            (Result = Error)

PIE 中 FullReloadRequired QueuedFullReloadFiles          PIE 退出立即 Full
                         += AllCompiledFiles
                         + PreviouslyFailedReloadFiles
                         (Result = ErrorNeedFullReload)
                         旧代码继续跑

PIE 中 FullReloadSuggested QueuedFullReloadFiles         PIE 退出立即 Full
                         += AllCompiledFiles            （在此期间 Soft 已经 swap-in）
                         (Result = PartiallyHandled)

UClass 验证失败          bShouldSwapInModules = false  「替回去」分支
(VerifyPropertySpecifiers) bHadCompileErrors = true     旧代码继续跑

ClassGen Setup 返回 Error 不 swap，bHadCompileErrors      下次重试
```

**永远成立的不变量**：

- 一次 `PerformHotReload` 调用要么"全员新模块进来"，要么"全员退回旧模块"，永远不会留下半新半旧状态。
- 失败一次的文件**自动**进入下次 reload 的 FileList——开发者只需要"修好就保存"，不需要 retry 命令。
- `bIsHotReloading` 是 `TGuardValue` 作用域 flag——所有 reload 期间的 binding（如 `bWillBecomeCorrect`）能问出"我现在是不是在 reload"。

---

## 附录 A：HotReload 决策与字段速查

### A.1 编译类型决定表

```text
Tick 入口判定:
  bScriptDevelopmentMode == false  →  完全跳过 reload (Shipping / Test)
  bUsedPrecompiledDataForPreprocessor == true  →  完全跳过 reload (cooked)
  !GIsEditor || HasGameWorld()  →  ECompileType::SoftReloadOnly
  else                          →  ECompileType::FullReload
```

### A.2 EReloadRequirement 触发因素速查

| 改动 | 升档 | 备注 |
|------|------|------|
| 函数体（同签名） | Soft | bytecode 替换 |
| 添加 / 删除非 UFUNCTION | Soft | 反射不可见 |
| UFUNCTION 签名变化 | FullReloadRequired | UFunction 重建 |
| 添加 UFUNCTION | FullReloadSuggested | 影响 BP 节点 |
| UPROPERTY 增 / 删 / 改类型 | FullReloadRequired | UClass 内存布局 |
| UPROPERTY 元数据改动 | FullReloadSuggested | 多数情况 |
| 基类变化 | FullReloadRequired | 继承链重建 |
| Interface 实现列表变化 | FullReloadRequired | UClass.Interfaces |
| 添加 / 删除整个 class | FullReloadRequired (新增亦走 Full) | UClass 创建 |
| Enum 增 / 改值 | FullReload (Full) 或 SoftReload (无值变化) | 根据具体改动 |
| Delegate 签名改 | FullReloadRequired | UDelegateFunction 重建 |
| `default Foo = X` 改值 | Soft | CDO 重新初始化 |
| `bModuleSwapInError` 上次 | FullReloadRequired | 兜底强制 Full |

### A.3 关键字段一行速查

| 字段 | 类型 | 用途 |
|------|------|------|
| `bScriptDevelopmentMode` | bool | 总开关：editor / dev 模式才允许 HotReload |
| `bUsedPrecompiledDataForPreprocessor` | bool | Cooked 模式禁止 reload |
| `bUseHotReloadCheckerThread` | bool | 后台线程模式（!Editor 才启用） |
| `bWaitingForHotReloadResults` | volatile bool | 主线程 / 后台线程握手 |
| `bIsHotReloading` | TGuardValue | reload 期间 binding 用来识别上下文 |
| `bIsInitialCompileFinished` | bool | reinstance 仅在初次编译后才跑 |
| `LastFileChangeDetectedTime` | double | 200ms 重命名窗口 |
| `NextHotReloadCheck` | double | 100ms 节流（仅后台线程） |
| `CompilationLock` | FCriticalSection | 多线程编译保护 |

---

## 附录 B：调试与避坑清单

1. **reload 卡住不响应**：90% 是后台线程 / DirectoryWatcher 模式被搞混。检查 `bUseHotReloadCheckerThread`：Editor 进程必须是 false；headless commandlet 必须是 true（且要 `bScriptDevelopmentMode`）。
2. **保存后没反应**：先看 Output Log 的 `Queued script file change for primary engine reload` ——若有，说明 DirectoryWatcher 链路正常，问题在 Tick；若无，检查 `IsInitialized()` 是否提前 short-circuit、或者文件不在 `MakeAllScriptRoots` 集合里。
3. **PIE 中改 UPROPERTY 没生效**：是按设计——`ScriptCompileError` 有警告，并 `Queued`，PIE 退出后立即生效。如果想立即看到，停止 PIE 再保存。
4. **改完一个文件被报"必须 Full Reload"，但又拒绝**：一定是在 PIE / GameWorld 中。要么退出 PIE，要么修一个不需要 Full 的版本（去掉 UPROPERTY 改动）。
5. **reinstance 失败 / actor 字段被清空**：检查改动是否涉及 `UPROPERTY` 类型变化（如 `int → float`）——UE 反实例化不做跨类型转换。同名同类型才能保留值。
6. **BP 子类出现红色编译错误**：通常是 `ReconstructNode` 在 `PerformReinstance` 步骤 5 中没覆盖到的 K2Node 子类。临时手动右键节点 → `Refresh` 即可，长期解决要在该 K2Node 子类里实现 `HasExternalDependencies`。
7. **Volume 改动后场景空白**：MAP REBUILD ALLVISIBLE 在 5.4.x 上有 reset CurrentLevel 的 bug，本插件已经做了 workaround；如果仍然空白，检查 `World->GetLevels().Contains(CurrentLevel)` 失败的情况——多 Sublevel 工程偶发。
8. **断点失效**：`DebugServer->ReapplyBreakpoints` 紧跟在编译成功之后；如果 module 因失败没 swap-in 就不会调用，断点就指向已 discard 的旧 module。重启 Debug 客户端通常能解决。
9. **测试中模拟 reload**：用 `CompileModuleWithResult(&Engine, ECompileType::SoftReloadOnly, ...)`，不要走 DirectoryWatcher——`AngelscriptHotReloadAnalysisTests.cpp` 与 `AngelscriptHotReloadPerformanceTests.cpp` 是范本。
10. **大批文件改名后 reload 异常缓慢**：DirectoryWatcher 把改名拆成 (Removed + Added) 两个事件，200ms 重命名窗口能合并相邻的；但跨窗口的"删 1000 个 + 加 1000 个"会触发整批 FullReload。先 Stop Editor、批量改名后再启动是更快的方式。

---

## 附录 C：跨文档边界

| 主题 | 在哪里写 |
|------|---------|
| Tick 整体调度 / Engine 单例创建 | `Arch_RuntimeLifecycle.md` |
| Editor 双链入口（DirectoryWatcher + ClassReloadHelper）的所有权与边界 | `Arch_EditorTestDumpCollaboration.md` §1.1 |
| 预处理器内部 / `FAngelscriptModuleDesc` 字段 | `Type_Preprocessor.md` |
| ClassGenerator 10 步流程（首次 / FullReload 共用） | `Type_ClassGeneration.md` |
| `bWillBecomeCorrect` / `GetMostUpToDateClass` 的语义 | `Type_BaseClass.md` |
| Debugger 协议 / 断点存储结构 | `RT_Debugger.md`（待写） |
| BlueprintImpact 离线 commandlet 走的扫描路径 | `Arch_EditorTestDumpCollaboration.md` §1.2 |
| Initial compile 的失败重试模态对话框 | 本文 §四间接提到，详细在 `Arch_RuntimeLifecycle.md` §四 |

---

## 小结

- HotReload 是一条 **"OS 文件事件 → Engine 队列 → Tick 调度 → PerformHotReload → ClassGenerator → ClassReloadHelper → BP/Reinstance"** 的七级流水线，每一级都有"成功 / 失败 / 延迟"三态。
- 文件检测分两条互斥分支：Editor 进程靠 `IDirectoryWatcher`，Standalone 进程靠后台线程 `CheckForFileChanges` 轮询 mtime，最终汇入同一组公共队列字段。
- SoftReload / FullReloadSuggested / FullReloadRequired / Error 四档由 `ClassGenerator.Setup()` 的 Analyze 阶段算出，再经 `(CompileType, ReloadRequirement)` 二维派发表得出实际行为，PIE / GameWorld 一律强制只能 Soft。
- 失败永远走"原子回退 + 自动重试"——`PreviouslyFailedReloadFiles` 与 `QueuedFullReloadFiles` 双队列保证开发者只要"修好就保存"即可，不需要手动 retry。
- ClassReloadHelper 是 Editor 模块挂在 `OnFullReload` 上的唯一 Reinstance 入口，它通过 `FBlueprintCompilationManager::ReparentHierarchies` 把 UE 反射系统拉进来，配合 `AnalyzeLoadedBlueprint` 把受影响 BP 子类一并重编，断点由 `DebugServer::ReapplyBreakpoints` 在每次编译成功后重建。
