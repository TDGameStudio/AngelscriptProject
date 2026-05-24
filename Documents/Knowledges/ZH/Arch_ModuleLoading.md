# Arch_ModuleLoading — 模块清单与装载关系

> **所属前缀**: Arch_（插件总体架构族）
> **关注层面**: 静态视角的模块装载——三个 UE C++ 模块 + 一个 C# UBT 工具的 LoadingPhase / Build.cs 物理依赖 / StartupModule / ShutdownModule 链路；不覆盖运行时 Bootstrap、Tick 仲裁与 Initialize 内部展开（那是 `Arch_RuntimeLifecycle` 的职责），也不覆盖 Editor / Test / Dump 的协作语义（那是 `Arch_EditorTestDumpCollaboration` 的职责）
> **关键源码**:
> `Plugins/Angelscript/Angelscript.uplugin` (~50 行，三模块 LoadingPhase 全部 `PostDefault`)
> · `Plugins/Angelscript/Source/AngelscriptRuntime/AngelscriptRuntime.Build.cs` (~92 行)
> · `Plugins/Angelscript/Source/AngelscriptEditor/AngelscriptEditor.Build.cs` (~46 行)
> · `Plugins/Angelscript/Source/AngelscriptTest/AngelscriptTest.Build.cs` (~57 行)
> · `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptRuntimeModule.h` / `.cpp` (~109 行)
> · `Plugins/Angelscript/Source/AngelscriptEditor/Core/AngelscriptEditorModule.h` / `.cpp` (~1188 行)
> · `Plugins/Angelscript/Source/AngelscriptTest/Core/AngelscriptTestModule.h` + `AngelscriptTestModule.cpp` (~61 行)
> · `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngineSubsystem.h` / `.cpp` (~205 行)
> · `Plugins/Angelscript/Source/AngelscriptUHTTool/AngelscriptUHTTool.ubtplugin.csproj` (~54 行)
> **关联文档**:
> `Documents/Knowledges/ZH/Arch_Overview.md` — 插件总体概览（顶层视角，本文是其 §三 的细化展开）
> · `Documents/Knowledges/ZH/Arch_RuntimeLifecycle.md` — Runtime 总控与生命周期（动态视角，本文是其 §一 的静态对照）
> · `Documents/Knowledges/ZH/Arch_EditorTestDumpCollaboration.md` — Editor / Test / Dump 协作边界
> · `Documents/Knowledges/ZH/Arch_UHTToolchain.md` — UHT 工具链位置与边界（细化 UBT 阶段产物）

---

## 概览

本文聚焦一个核心问题：**当 UE 启动并加载 `Angelscript.uplugin` 时，三个 C++ 模块（AngelscriptRuntime / Editor / Test）+ 一个 C# UBT 工具（AngelscriptUHTTool）的 LoadingPhase / Build.cs 物理依赖 / StartupModule / ShutdownModule 链路具体是什么？它们彼此之间在哪一帧握手、又在哪一帧解耦？**

`Arch_RuntimeLifecycle.md` 已经回答了"`FAngelscriptEngine` 这个**重对象**何时被创建、谁来 Tick 它"。本文是它的**静态搭档**：先把"模块壳子怎么被装载、彼此之间的依赖头长什么样"讲清楚，再去理解运行时的动态编排才不会迷路。

```text
                     UE 进程启动时序（节选） vs Angelscript 三模块入场点
================================================================================

EarliestPossible ─► PostConfigInit ─► PreEarlyLoadingScreen ─► Default
                                                                  │
                                          ... ─► PostEngineInit  │
                                                       ▲          │
                                                       │          ▼
              ┌────────────────────────────────────────┴─── Default ─►
              │                                                   │
              │  ┌───── ★ PostDefault（三模块 StartupModule 一并触发） ─────┐
              │  │                                                          │
              │  │  AngelscriptRuntime.StartupModule()  // 仅打 verbose 日志│
              │  │  AngelscriptEditor.StartupModule()   // ★ 12 步扩展注册 │
              │  │  AngelscriptTest.StartupModule()     // 命令行驱动两类副作用│
              │  │                                                          │
              │  │  此刻引擎尚未被创建：                                    │
              │  │    FAngelscriptEngine::IsInitialized() == false          │
              │  │    FAngelscriptEngineContextStack::IsEmpty() == true     │
              │  └──────────────────────────────────────────────────────────┘
              │                                                   │
              │  ┌──── PostDefault* 之后 / GEngine 完成构造 ────┐ │
              │  │ UEngineSubsystem 子类被实例化               │ │
              │  │ ★ UAngelscriptEngineSubsystem::Initialize  │ │
              │  │   → EnsurePrimaryEngineInitialized()       │ │
              │  │   → FAngelscriptEngine::Initialize()        │ │
              │  └──────────────────────────────────────────────┘ │
              │                                                   ▼
              │  ┌──── PostEngineInit 多播触发 ────┐
              │  │ AngelscriptEditor 在 OnEngineInitDone() 里                 │
              │  │   注册 ContentBrowser DataSource                            │
              │  └─────────────────────────────────────────────────────────────┘
              ▼
                                  业务运行帧 ─► ... ─► 进程退出 ─► ShutdownModule
================================================================================
[旁路] AngelscriptUHTTool 完全不在这条 UE 模块装载时序里
       它是 .ubtplugin.csproj 编译出的 C# DLL，UnrealBuildTool 在构建期加载它，
       产物 (AS_FunctionTable_*.cpp) 编入 AngelscriptRuntime 一同被 UE 进程消费。
```

后续章节按"装载阶段定义 → 物理依赖 → 三个模块各自的 Startup/Shutdown 链路 → UHT 工具的边界 → EngineSubsystem 与 PostDefault 的衔接 → 排错指引"的顺序展开。

---

## 一、`Angelscript.uplugin`：三模块齐心选 `PostDefault`

`.uplugin` 是 UE 模块装载子系统读取的唯一权威源——它声明了"插件包含哪些模块、每个模块在哪个 LoadingPhase 触发 StartupModule"。本插件的写法非常直白：

```json
// ============================================================================
// 文件: Plugins/Angelscript/Angelscript.uplugin
// 角色: 模块装载阶段定义；三模块齐心选 PostDefault；外部依赖三件
// ============================================================================
"Modules": [
    { "Name": "AngelscriptRuntime", "Type": "Runtime", "LoadingPhase": "PostDefault" },
    { "Name": "AngelscriptEditor",  "Type": "Editor",  "LoadingPhase": "PostDefault" },
    { "Name": "AngelscriptTest",    "Type": "Editor",  "LoadingPhase": "PostDefault" }
],
"Plugins": [
    { "Name": "StructUtils",          "Enabled": true },
    { "Name": "PropertyBindingUtils", "Enabled": true },
    { "Name": "EnhancedInput",        "Enabled": true }
]
```

### 1.1 为什么选 `PostDefault`？

UE 提供 9 个 LoadingPhase（按时序：`EarliestPossible` → `PostConfigInit` → `PostSplashScreen` → `PreEarlyLoadingScreen` → `PreLoadingScreen` → `PreDefault` → `Default` → `PostDefault` → `PostEngineInit`）。本插件齐心选 `PostDefault`，原因是:

```text
┌──────────────────────────────────────────────────────────────────────┐
│ PostDefault 窗口期的"已就绪"清单：                                   │
│   ✓ CoreUObject 反射：UClass / UStruct / UFunction / 元数据齐全      │
│   ✓ 模块管理器（FModuleManager）：可以 LoadModuleChecked 同级模块    │
│   ✓ CDO 注册：所有原生 UClass 已构造完毕，绑定可以读取它们           │
│   ✓ Subsystem 框架：UEngineSubsystem 等基类已可被发现/实例化         │
├──────────────────────────────────────────────────────────────────────┤
│ PostDefault 窗口期的"还没就绪"清单：                                 │
│   ✗ GEngine 不必然存在（Editor 的 GEngine 在更晚的 EngineInit 中）   │
│   ✗ ContentBrowser 内的 DataSource 子系统未启动（要等 PostEngineInit）│
│   ✗ FAngelscriptEngine 没人创建（要靠 UAngelscriptEngineSubsystem）  │
└──────────────────────────────────────────────────────────────────────┘
```

落到设计上变成一条很硬的约束：**StartupModule 阶段不要做任何"需要 GEngine"或"需要 ContentBrowser"的工作**。Runtime 模块完全空 Startup（只打 verbose 日志），Editor 模块凡是依赖 GEngine 的扩展点（`OnEngineInitDone` → ContentBrowser DataSource）都改为 hook 到 `FCoreDelegates::OnPostEngineInit` 多播，等待真正的就绪点。

### 1.2 为什么三模块都用同一个 LoadingPhase？

——因为它们的**依赖链是 Runtime ◄ Editor、Runtime ◄ Test**，UE 模块加载子系统读到这层依赖后会自动按拓扑顺序 (Runtime first, then Editor / Test) 调 StartupModule。统一选 PostDefault 之后：

- 三个模块的 StartupModule **在同一个 LoadingPhase 内**按依赖拓扑排序串行执行；
- `AngelscriptEditor::StartupModule` 进入时 `FModuleManager::Get().LoadModuleChecked(TEXT("AngelscriptRuntime"))` 一定是命中缓存（Runtime 已 Startup 完）；
- 不会出现"AngelscriptEditor 已经在跑，但 AngelscriptRuntime 模块对象还不存在"的局面。

### 1.3 三个外部插件依赖

`"Plugins"` 数组里的三件——`StructUtils` / `PropertyBindingUtils` / `EnhancedInput`——会被 UE 在加载 Angelscript.uplugin 时**强制启用**。这意味着消费者只要把 Angelscript 拷进自己的 `Plugins/`，这三个 UE 自带插件会自动跟着启用。它们各自的运行时模块也会比 Angelscript 更早完成 Startup（因为 Angelscript 的 Build.cs 把它们列为依赖，UE 装载子系统会先加载依赖项）。

---

## 二、Build.cs 物理依赖：每个模块的依赖头清单

`Angelscript.uplugin` 决定"何时启动"；`*.Build.cs` 决定"链接哪些模块、能 include 哪些头"。两套机制互相独立，但都被 UnrealBuildTool 统一消费。本节把三个 C++ 模块的依赖头按 `PublicDependencyModuleNames` / `PrivateDependencyModuleNames` / `bBuildEditor` 追加项三栏列出。

### 2.1 `AngelscriptRuntime.Build.cs`

```csharp
// ============================================================================
// 文件: Plugins/Angelscript/Source/AngelscriptRuntime/AngelscriptRuntime.Build.cs
// 角色: 底座模块；不依赖任何 plugin 内同级模块
// ============================================================================
PublicDependencyModuleNames.AddRange(new string[] {
    "ApplicationCore", "Core", "CoreUObject", "Engine",
    "EngineSettings", "DeveloperSettings",
    "Json", "JsonUtilities",
    "GameplayTags", "StructUtils",
});
PrivateDependencyModuleNames.AddRange(new string[] {
    "AIModule", "NavigationSystem", "NetCore", "Landscape",
    "Networking", "Sockets", "InputCore",
    "SlateCore", "Slate", "UMG", "TraceLog",
    "AssetRegistry", "Projects", "PhysicsCore", "CoreOnline",
    "EnhancedInput",
});
if (Target.bBuildEditor) {
    PublicDependencyModuleNames.AddRange(new string[] { "UnrealEd", "EditorSubsystem" });
    PrivateDependencyModuleNames.AddRange(new string[] { "UMGEditor" });   // ★ 仅 Private
}
```

**关键观察**：

- Public 依赖**没有任何 plugin 内同级模块**——这是底座模块的标志，意味着 Editor / Test 都可以 public 依赖它而不形成循环。
- `bBuildEditor` 下追加 `UnrealEd` / `EditorSubsystem` 到 **Public**——理由是 ClassGenerator 在编辑器构建里要触发 UE 的 reinstancer，且这些类型出现在 `AngelscriptRuntime` 公开头文件里被 Editor 模块跨模块 include。
- `UMGEditor` 仅 Private——只在 `.cpp` 里用到，不污染 Editor 跨模块 include 链路。

### 2.2 `AngelscriptEditor.Build.cs`

```csharp
// ============================================================================
// 文件: Plugins/Angelscript/Source/AngelscriptEditor/AngelscriptEditor.Build.cs
// 角色: 编辑器扩展模块；★ 公共依赖 AngelscriptRuntime（plugin 内）
// ============================================================================
PublicDependencyModuleNames.AddRange(new string[] {
    "Core", "CoreUObject", "Engine",
    "UnrealEd", "EditorSubsystem",
    "AngelscriptRuntime",       // ★ 唯一一个 plugin 内同级公共依赖
    "BlueprintGraph", "Kismet",
    "DirectoryWatcher", "Slate", "SlateCore",
    "AssetTools",
});
PrivateDependencyModuleNames.AddRange(new string[] {
    "Projects", "GameplayTags", "Settings",
    "LevelEditor", "PlacementMode",
    "PropertyEditor", "ContentBrowser", "ContentBrowserData",
    "ToolMenus", "ToolWidgets",
});
```

**关键观察**：

- Editor 没有 `bBuildEditor` 分支——它**整体只在 bBuildEditor 配置下编译**（`.uplugin` 中 `Type: "Editor"` 已限定），所以无需再做条件追加。
- `DirectoryWatcher` / `BlueprintGraph` / `Kismet` 必须 public——它们的类型出现在 Editor 模块的 `.h` 中（如 `FDelegateHandle DirectoryWatchHandles`、`UASClass*` 引用 BP 编译类型），跨模块 include 时需要可见。
- `ContentBrowser` / `ContentBrowserData` 走 Private——因为只有 `OnEngineInitDone()` 这个静态函数在 `.cpp` 里用到 DataSource 注册，对外不暴露。

### 2.3 `AngelscriptTest.Build.cs`

```csharp
// ============================================================================
// 文件: Plugins/Angelscript/Source/AngelscriptTest/AngelscriptTest.Build.cs
// 角色: 测试模块；★ Public 依赖 Runtime；★ bBuildEditor 时 Private 依赖 Editor
// ============================================================================
PublicDependencyModuleNames.AddRange(new string[] {
    "Core", "CoreUObject", "Engine",
    "GameplayTags", "Json", "JsonUtilities",
    "PropertyBindingUtils",
    "AngelscriptRuntime",       // ★ Public 依赖底座
});
PrivateDependencyModuleNames.AddRange(new string[] {
    "AIModule", "EnhancedInput", "UMG",
});
if (Target.bBuildEditor) {
    PrivateDependencyModuleNames.AddRange(new string[] {
        "BlueprintGraph", "CQTest",
        "Networking", "Sockets",
        "UnrealEd",
        "AngelscriptEditor",    // ★ 仅 Private + 仅 bBuildEditor
    });
}
```

**关键观察（Test 对 Editor 的依赖只在 `bBuildEditor` 下、且只在 Private）**：

- **物理意义**：Test 模块的 `.h` 里**不**能 leak `AngelscriptEditor` 的类型，否则下游 include 链会把 Editor 类型暴露给 Editor 之外的消费者。
- **逻辑意义**：headless 自动化构建（如 cooked client 测试）下 `bBuildEditor == false`，Test 模块就**编译不进**对 Editor 的引用——这一类构建里测试用例如果偷懒去 `#include "AngelscriptEditorModule.h"`，会直接编译失败而不是运行时崩溃。
- **典型用途**：`Bindings/` / `HotReload/` 等主题的测试需要校验 Editor 注册流程或 ClassReloadHelper 行为，只能在 Editor 构建里跑——bBuildEditor + Private 这两层限定恰好定义了这条边界。

### 2.4 一表汇总

| 模块 | 依赖头数（Public + Private） | plugin 内同级依赖 | `bBuildEditor` 追加 |
|------|-----|------|------|
| `AngelscriptRuntime` | 10 + 15 = 25 项 | — | Public: `UnrealEd` / `EditorSubsystem`；Private: `UMGEditor` |
| `AngelscriptEditor`  | 11 + 9 = 20 项 | Public `AngelscriptRuntime` | （无；模块整体只在 Editor 下编译） |
| `AngelscriptTest`    | 8 + 3 = 11 项  | Public `AngelscriptRuntime` | Private: `BlueprintGraph` / `CQTest` / `Networking` / `Sockets` / `UnrealEd` / **`AngelscriptEditor`** |

---

## 三、`AngelscriptRuntime` 的 StartupModule / ShutdownModule

底座模块的核心设计原则是：**Startup 极轻、Shutdown 仅清栈**。所有"重活"延迟到 Bootstrap 阶段（`UAngelscriptEngineSubsystem::Initialize` 或显式 `FAngelscriptRuntimeModule::InitializeAngelscript()`），详见 `Arch_RuntimeLifecycle.md` §二。

### 3.1 模块入口类只声明三件事

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Core/AngelscriptRuntimeModule.h
// 角色: 模块入口类；仅 Startup / Shutdown / 静态 InitializeAngelscript 三个 API
// ============================================================================
class ANGELSCRIPTRUNTIME_API FAngelscriptRuntimeModule : public FDefaultModuleImpl
{
public:
    virtual void StartupModule() override;
    virtual void ShutdownModule() override;
    static void InitializeAngelscript();   // ★ 兼容入口；详见 Arch_RuntimeLifecycle §2.1

private:
    static bool bInitializeAngelscriptCalled;            // 幂等哨兵
    static TUniquePtr<FAngelscriptEngine> OwnedPrimaryEngine;  // headless 兜底持有者
    // ... WITH_DEV_AUTOMATION_TESTS 下的 Override Hook
};
```

### 3.2 StartupModule：故意非常轻

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Core/AngelscriptRuntimeModule.cpp
// 函数: FAngelscriptRuntimeModule::StartupModule
// ★ 关键设计：StartupModule 故意不做任何重活——
//   不创建 FAngelscriptEngine / 不绑定 Bind_*.cpp / 不读 ScriptRoot
// ============================================================================
void FAngelscriptRuntimeModule::StartupModule()
{
    UE_LOG(Angelscript, Verbose, TEXT("[RuntimeStartup] StartupModule."));
}
```

**为什么这么轻**：

- PostDefault 阶段 GEngine 不必然存在；
- 真正的 Bootstrap 由 `UAngelscriptEngineSubsystem::Initialize`（Editor / Commandlet 路径）或显式 `FAngelscriptRuntimeModule::InitializeAngelscript()`（Headless 路径）发起；
- 这条规则保证模块装载阶段**绝不阻塞 UE 启动主线**——成熟期一次完整 `FAngelscriptEngine::Initialize()` 可达数秒级（含 121 个 Bind + InitialCompile），不能让它在 PostDefault 的 LoadingPhase 里同步跑完。

### 3.3 ShutdownModule：兜底清栈

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Core/AngelscriptRuntimeModule.cpp
// 函数: FAngelscriptRuntimeModule::ShutdownModule
// 角色: 仅在"InitializeAngelscript() 走了 Path C 自建 OwnedPrimaryEngine"时有事可做
// ============================================================================
void FAngelscriptRuntimeModule::ShutdownModule()
{
    UE_LOG(Angelscript, Verbose, TEXT("[RuntimeStartup] ShutdownModule ownedEngine=%s"),
        OwnedPrimaryEngine.IsValid() ? TEXT("true") : TEXT("false"));

    if (OwnedPrimaryEngine.IsValid())
    {
        FAngelscriptEngineContextStack::Pop(OwnedPrimaryEngine.Get());   // ★ 从 ContextStack Pop
        OwnedPrimaryEngine.Reset();                                       // 释放 TUniquePtr
    }
}
```

——绝大多数情况下（Editor / Commandlet / Game）`OwnedPrimaryEngine` 是 `nullptr`，因为 PrimaryEngine 由 `UAngelscriptEngineSubsystem::OwnedEngine`（USTRUCT 字段）持有，进 GC 与 Subsystem 自身的 `Deinitialize` 链路而不走 `ShutdownModule`。

---

## 四、`AngelscriptEditor` 的 StartupModule：12 步扩展点注册

Editor 模块的 StartupModule **不轻**——它要在编辑器进程的 PostDefault 窗口里完成所有的扩展点注册。但这些注册都是"挂回调"性质：把回调函数扔给 UE 各个扩展位（DirectoryWatcher / OnPostEngineInit / OnObjectPreSave / ToolMenus / SettingsModule / SourceCodeNavigation 等），等真正触发时再执行。

### 4.1 StartupModule 的 12 个步骤（骨架）

```cpp
// ============================================================================
// 文件: AngelscriptEditor/Core/AngelscriptEditorModule.cpp
// 函数: FAngelscriptEditorModule::StartupModule
// 角色: 编辑器侧 12 步扩展注册；★ 全程不直接读 FAngelscriptEngine::Get()
// ============================================================================
void FAngelscriptEditorModule::StartupModule()
{
    FClassReloadHelper::Init();                                         // ① HotReload helper
    RegisterAngelscriptSourceNavigation();                              // ② SourceCodeNavigation

    // ③ 兼容兜底：若 Engine 已就绪（Editor 模块被晚加载场景）则失效 ComponentTypeRegistry
    if (FAngelscriptEngine::IsInitialized() && FAngelscriptEngine::Get().IsInitialCompileFinished())
        FComponentTypeRegistry::Get().Invalidate();

    RegisterGameplayTagDelegates();                                     // ④ GameplayTag 多播
    if (!GOnPostEngineInitHandle.IsValid())                             // ⑤ ★ OnPostEngineInit
        GOnPostEngineInitHandle = FCoreDelegates::OnPostEngineInit.AddStatic(&OnEngineInitDone);
    UScriptEditorMenuExtension::InitializeExtensions();                 // ⑥ 菜单扩展
    AngelscriptEditor::Private::RegisterStateDumpExtension(StateDumpExtensionHandle);  // ⑦ Dump
    /* ⑧ ★ DirectoryWatcher: 遍历 MakeAllScriptRoots() 注册 OnScriptFileChanges */
    /* ⑨ Project Settings: SettingsModule->RegisterSettings("Project","Plugins","Angelscript",...) */
    /* ⑩ DebugBridge: GetDebugListAssets/GetEditorCreateBlueprint 两条 AddLambda */
    GLiteralAssetPreSaveHandle = FCoreUObjectDelegates::OnObjectPreSave.AddStatic(&OnLiteralAssetPreSave);  // ⑪
    UToolMenus::RegisterStartupCallback(FSimpleMulticastDelegate::FDelegate::CreateRaw(  // ⑫ ToolMenus
        this, &FAngelscriptEditorModule::RegisterToolsMenuEntries));
}
```

### 4.2 每一步的"挂入 UE 扩展位"对照

| 步骤 | UE 扩展位 / API | 实际 hook 的回调 | 触发时机 |
|------|----------------|-----------------|----------|
| ① | `FClassReloadHelper::Init()`（自有静态） | — | 立即同步 |
| ② | `ISourceCodeNavigationHandler` 注册器 | `FAngelscriptSourceCodeNavigation` | 立即同步 |
| ④ | `IGameplayTagsModule::OnTagSettingsChanged / OnGameplayTagTreeChanged` | `FAngelscriptEditorModule::ReloadTags` | tag 配置变更时 |
| ⑤ | `FCoreDelegates::OnPostEngineInit` | `OnEngineInitDone` → ContentBrowser DataSource 注册 | GEngine Init 完毕 |
| ⑥ | `UScriptEditorMenuExtension::InitializeExtensions()` | — | 立即同步 |
| ⑦ | `FAngelscriptStateDump::OnDumpExtensions` 多播（详见 `Arch_EditorTestDumpCollaboration` §三） | `AngelscriptEditor::Private` 内 dump 函数 | `as.DumpEngineState` 调用时 |
| ⑧ | `IDirectoryWatcher::RegisterDirectoryChangedCallback_Handle` | `OnScriptFileChanges` | OS 文件系统变更（节流） |
| ⑨ | `ISettingsModule::RegisterSettings` | UAngelscriptSettings DefaultObject | 用户打开设置面板 |
| ⑩ | `FAngelscriptEditorDebugBridge::GetDebugListAssets() / GetEditorCreateBlueprint()` | Lambda → `ShowAssetListPopup` / `ShowCreateBlueprintPopup` | DebugServer 客户端发命令 |
| ⑪ | `FCoreUObjectDelegates::OnObjectPreSave` | `OnLiteralAssetPreSave` | UE 保存任何 UObject 时（filter 为 AssetsPackage） |
| ⑫ | `UToolMenus::RegisterStartupCallback` | `RegisterToolsMenuEntries` | ToolMenus 子系统就绪 |

——上述 12 步**没有任何一处直接读 `FAngelscriptEngine::Get()`**（步骤 ③ 仅做 `IsInitialized()` 防御）。这正是"PostDefault 不能假设引擎已就绪"约束的具体体现。

### 4.3 ShutdownModule：完整逆向解绑

12 步注册都在 `ShutdownModule` 中按反向大致镜像解绑——`UnregisterGameplayTagDelegates` / `OnPostEngineInit.Remove` / 两条 DebugBridge `.Remove` / `OnObjectPreSave.Remove` / `UnregisterStateDumpExtension` / `UnregisterDirectoryWatchers` / `SettingsModule->UnregisterSettings` / `UToolMenus::UnRegisterStartupCallback + UnregisterOwner`。

注意 `OnEngineInitDone()` 注册的 ContentBrowser DataSource **不在这里反注册**——它是 GC 跟踪的 UObject (`RF_MarkAsRootSet | RF_Transient`)，与 ContentBrowserData 子系统的生命周期绑定，不属于本模块的 Shutdown 责任。

---

## 五、`AngelscriptTest` 的 StartupModule：命令行驱动的两类副作用

Test 模块的 StartupModule 比 Runtime 重、比 Editor 轻。它**完全由命令行参数驱动**——不传任何 `-Angelscript*` 开关时仅打一行日志即返回。

### 5.1 模块入口最小化

```cpp
// ============================================================================
// 文件: AngelscriptTest/Core/AngelscriptTestModule.h
// 角色: Test 模块的入口；FAngelscriptTestModule final，无对外 API
// ============================================================================
class FAngelscriptTestModule final : public IModuleInterface
{
public:
    virtual void StartupModule() override;
    virtual void ShutdownModule() override;
};
```

——与 Runtime / Editor 不同，Test 模块的入口类**没有 `ANGELSCRIPTTEST_API` 导出宏**（不需要），也没有"对外静态 API"。

### 5.2 StartupModule：两个命令行开关

```cpp
// ============================================================================
// 文件: AngelscriptTest/AngelscriptTestModule.cpp
// 函数: FAngelscriptTestModule::StartupModule
// 角色: 两个 -AngelscriptTest* 开关分别控制 Override Engine 与 Pool 预热
// ============================================================================
void FAngelscriptTestModule::StartupModule()
{
    // 开关一：用 ScanFree 引擎替换正常 Initialize（避开磁盘扫描脚本根）
    const bool bUseScanFreeStartupEngine = FParse::Param(FCommandLine::Get(),
        TEXT("AngelscriptTestUseScanFreeStartupEngine"));
    if (bUseScanFreeStartupEngine) {
        GAngelscriptTestStartupOverrideEngine = AngelscriptTestSupport::CreateScriptScanFreeFullEngineForTesting(
            CreateEditorScanFreeStartupConfig(), FAngelscriptEngineDependencies::CreateDefault());
        // ★ 把构造好的 Engine 注入 EngineSubsystem 的 Override Hook
        UAngelscriptEngineSubsystem::SetInitializeOverrideForTesting([]() -> FAngelscriptEngine* {
            return GAngelscriptTestStartupOverrideEngine.Get();
        });
    }

    // 开关二：是否预热 TestEnginePool（共享 Engine 池，加速 Test 套件运行）
    const bool bPrewarmEngine = FParse::Param(FCommandLine::Get(), TEXT("AngelscriptTestPrewarmEngine"));
    AngelscriptTestSupport::StartupTestEnginePool(bPrewarmEngine);

    UE_LOG(LogAngelscriptTest, Log, TEXT("AngelscriptTest module started."));
}
```

**关键设计点**：

- **Override Engine 必须在 `EngineSubsystem::Initialize` 之前安装**——而 PostDefault 是 `UEngineSubsystem` 实例化**之前**的窗口期，恰好满足这一时序约束。这是 Test 选 PostDefault 而不是更晚阶段的硬约束。
- **TestEnginePool** 是 Shared/ 测试基础设施的一部分，详见 `Test_Infrastructure.md`；本文不展开，只指出"pool 的 startup 时机也卡在 module loading 阶段"。

### 5.3 ShutdownModule：清理 Override Hook + Pool

```cpp
void FAngelscriptTestModule::ShutdownModule()
{
    UAngelscriptEngineSubsystem::ResetInitializeStateForTesting();   // ★ 反挂 Override Hook
    AngelscriptTestSupport::ShutdownTestEnginePool();
    GAngelscriptTestStartupOverrideEngine.Reset();
    UE_LOG(LogAngelscriptTest, Log, TEXT("AngelscriptTest module shut down."));
}
```

### 5.4 为什么 Test 在 `bBuildEditor` 下额外 Private 依赖 Editor？

`Build.cs` 的这条规则（§2.3）回到模块加载视角看是这样：

```text
┌───────────────────────────────────────────────────────────┐
│ headless 自动化进程（cooked client / 非 Editor target）  │
│   - bBuildEditor == false                                │
│   - AngelscriptEditor 模块整体不参与编译（uplugin Type=Editor）│
│   - AngelscriptTest 也不能 #include 任何 Editor 头        │
│   - 测试用例里访问 ClassReloadHelper / DirectoryWatcher 等│
│     Editor 才有的设施会编译失败                          │
├───────────────────────────────────────────────────────────┤
│ Editor 进程                                              │
│   - bBuildEditor == true                                 │
│   - AngelscriptEditor / AngelscriptTest 都参与           │
│   - Test 可以 Private 依赖 Editor，做 HotReload / Bindings│
│     等需要 Editor 设施的集成测试                         │
└───────────────────────────────────────────────────────────┘
```

**Private + bBuildEditor** 的双重限定让 Test 模块的"测试覆盖面"自适应于构建配置：headless 下少做一部分 Editor 主题测试，Editor 下做全集。

---

## 六、`AngelscriptUHTTool`：不在 UE 模块加载体系内

UHT 工具是**插件包内唯一不属于 UE Module 体系**的产物。它本质上是 `.NET 8.0` 的 C# DLL，被 `.ubtplugin.csproj` 编译并被 UnrealBuildTool 在**构建期**加载。

### 6.1 项目类型与依赖

```xml
<!-- ============================================================================ -->
<!-- 文件: AngelscriptUHTTool/AngelscriptUHTTool.ubtplugin.csproj                -->
<!-- 角色: C# 类库；TargetFramework=net8.0；UBT plugin 标识                       -->
<!-- ============================================================================ -->
<TargetFramework>net8.0</TargetFramework>
<OutputType>Library</OutputType>
<OutputPath>..\..\Binaries\DotNET\UnrealBuildTool\Plugins\AngelscriptUHTTool\</OutputPath>
<!-- ... -->
<Reference Include="EpicGames.Build">  <HintPath>$(EngineDir)/.../EpicGames.Build.dll</HintPath></Reference>
<Reference Include="EpicGames.Core">   <HintPath>$(EngineDir)/.../EpicGames.Core.dll</HintPath></Reference>
<Reference Include="EpicGames.UHT">    <HintPath>$(EngineDir)/.../EpicGames.UHT.dll</HintPath></Reference>
<Reference Include="UnrealBuildTool">  <HintPath>$(EngineDir)/.../UnrealBuildTool.dll</HintPath></Reference>
```

四个 Reference 全部指向 UE 引擎自带的 `.dll` 文件——这些是 UnrealBuildTool 与 UnrealHeaderTool 的核心程序集。**没有**任何 `Angelscript*` 自家的程序集被引用（自家根本就还没被构造）。

### 6.2 装载阶段定位

```text
┌──────────────────────────────────────────────────────────────────────┐
│  构建期（UBT 进程内）                                                │
│  ┌──────────────────────────────────────────────────────────────┐   │
│  │ UnrealBuildTool 启动                                         │   │
│  │   ├─► 扫描所有 .ubtplugin.csproj 并构建/加载 C# 程序集       │   │
│  │   ├─► 运行 UnrealHeaderTool                                  │   │
│  │   │     ├─► 调用 [UhtExporter] 标注的 AngelscriptFunctionTableExporter.Export
│  │   │     ├─► 解析所有 BlueprintCallable / BlueprintPure 函数│   │
│  │   │     └─► 写出 AS_FunctionTable_*.cpp + 跳过 CSV          │   │
│  │   └─► 编译产物（含上述 .cpp）链接进 AngelscriptRuntime.dll/lib│
│  └──────────────────────────────────────────────────────────────┘   │
│                                                                      │
│  以下 = UE 进程的世界（与 UHT 完全隔离）                            │
│  ┌──────────────────────────────────────────────────────────────┐   │
│  │ UE 进程启动 → PostDefault → AngelscriptRuntime.StartupModule │   │
│  │  ▲                                                           │   │
│  │  └── AS_FunctionTable_*.cpp 已经作为 Runtime 的一部分被编入│   │
│  │      静态注册回调在初始化时被走到（与手工 Bind_*.cpp 同等待遇）│
│  └──────────────────────────────────────────────────────────────┘   │
└──────────────────────────────────────────────────────────────────────┘
```

**结论**：

- UHT 工具**没有 LoadingPhase**——它的"装载"指 UBT 加载它的 DLL，发生在 UE 进程启动之前；
- UHT 工具**不出现在任何 `Build.cs` 的 ModuleNames 列表里**——UE Module 体系不知道它存在；
- UHT 工具的产物（`AS_FunctionTable_*.cpp`）通过 `[UhtExporter] ModuleName = "AngelscriptRuntime"` 这一行被 UBT 编入 Runtime 模块，所以**消费它的是 Runtime 模块的编译过程**，与 Runtime 的 StartupModule 没有任何运行时关联；
- 任何"我想在 StartupModule 里调 UHT 工具"的设计都是错位的——UHT 工具早在 UE 进程启动之前就完成了它的全部工作。

更细节的 UHT 工具内部（Exporter / SignatureBuilder / CodeGenerator 三类协作）见 `Arch_UHTToolchain.md`，本文不深入。

---

## 七、`UAngelscriptEngineSubsystem` 与 PostDefault 的衔接

模块装载**结束之后**，UE 才进入"`UEngineSubsystem` 子类按需实例化"的阶段。这一节回答两个问题：

1. `UAngelscriptEngineSubsystem` 是怎么被构造、何时调 `Initialize` 的？
2. 它与三个模块的 StartupModule **跨阶段衔接**的具体握手点在哪里？

### 7.1 `ShouldCreateSubsystem` 决定要不要在当前进程激活

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Core/AngelscriptEngineSubsystem.cpp
// 函数: UAngelscriptEngineSubsystem::ShouldCreateSubsystem / Initialize
// 角色: 决定是否激活 + Initialize 时立刻拉起完整 FAngelscriptEngine::Initialize()
// ============================================================================
bool UAngelscriptEngineSubsystem::ShouldCreateSubsystem(UObject* Outer) const
{
    if (IsUnreachable() || !Super::ShouldCreateSubsystem(Outer))
        return false;
    return ShouldBootstrapAngelscript();        // = GIsEditor || IsRunningCommandlet()
}

void UAngelscriptEngineSubsystem::Initialize(FSubsystemCollectionBase& Collection)
{
    Super::Initialize(Collection);
    EnsurePrimaryEngineInitialized();           // ★ 此处真正创建 OwnedEngine 并 Initialize
}
```

——`ShouldBootstrapAngelscript()` 在纯独立 Game 进程中返回 false，此时 EngineSubsystem 不被创建，PrimaryEngine 改由 `UAngelscriptGameInstanceSubsystem` 在 GameInstance 启动时接管（详见 `Arch_RuntimeLifecycle.md` §2.3）。

### 7.2 与三个模块 StartupModule 的"跨阶段握手"

```text
时序展开（仅 Editor 进程为例）：
================================================================================

[T0] PostDefault 开始 (依赖拓扑顺序)
       ├─► Runtime.StartupModule()  仅打日志
       ├─► Editor.StartupModule()    12 步扩展注册（步骤 ⑤ AddStatic 到 OnPostEngineInit、
       │                              ⑧ DirectoryWatcher 注册、⑫ ToolMenus startup callback）
       └─► Test.StartupModule()      可选 Override Hook + Pool 预热
       此时: FAngelscriptEngine::IsInitialized() == false

[T1] PostDefault 结束 → UE 继续 boot → GEngine 构造完成
       └─► UAngelscriptEngineSubsystem 实例化 → ShouldCreateSubsystem(Editor) → true
             └─► Initialize → EnsurePrimaryEngineInitialized
                   ├─► PrimaryEngine = &OwnedEngine
                   ├─► ContextStack::Push(PrimaryEngine)
                   └─► PrimaryEngine->Initialize()  ★ 含 121 Bind + InitialCompile（数秒级）
                         └─ Broadcast OnInitialCompileFinished
       此时: IsInitialized() == true, 步骤 ⑧ 注册的 OnScriptFileChanges 开始正常响应

[T2] FCoreDelegates::OnPostEngineInit 多播触发
       └─► 步骤 ⑤ 的 OnEngineInitDone() 执行 → 注册 ContentBrowser DataSource
       此时: .as 文件可见于 Content Browser

[T3] 业务运行 ... 帧循环驱动 EngineSubsystem.Tick / GameInstanceSubsystem.Tick
================================================================================
```

`AngelscriptEditor.StartupModule()` 步骤 ③ 的那一行 `if (FAngelscriptEngine::IsInitialized() && IsInitialCompileFinished())` 防御正是为这个时序而设——95% 情况下 `IsInitialized()` 在 Editor StartupModule 阶段仍是 false，`Invalidate()` 不会被调用；但在 hot-reload 编辑器模块的极端场景里，Engine 可能已就绪而 Editor 模块刚被重载，这条分支保证那种情况下 `ComponentTypeRegistry` 也被正确失效。

### 7.3 ShutdownModule 与 EngineSubsystem.Deinitialize 的反向时序

进程退出时的反向时序：[U0] UE 主循环退出 → `UAngelscriptEngineSubsystem::Deinitialize` → `ReleasePrimaryEngine` → `ContextStack::Pop` + `Engine->Shutdown()`（释放 DebugServer / StaticJIT / asCScriptEngine）；[U1] FModuleManager 反向调 `Test.ShutdownModule` → `Editor.ShutdownModule`（12 步反向解绑）→ `Runtime.ShutdownModule`（仅清 OwnedPrimaryEngine 兜底）。

——核心要点：**`PrimaryEngine` 的真正 Shutdown 发生在 `EngineSubsystem.Deinitialize`，不是任何 ShutdownModule 里**。这是为什么 Runtime 的 ShutdownModule 几乎什么都不做（OwnedPrimaryEngine 通常为空）。

---

## 八、装载阶段排错指引

凡是涉及"AngelScript 初始化失败 / 早期 crash / 扩展点不生效"的问题，按下表定位：

| 现象 | 候选原因 | 验证手段 |
|------|---------|----------|
| **A** 启动时打 "AngelScript 模块在依赖项之前加载" / 类似 ensure | LoadingPhase 配错；新模块写了 `PreDefault` / `Default` | 检查 `.uplugin` 的 `LoadingPhase`；grep `Plugins/Angelscript/` 应无 `PreDefault \| EarliestPossible` |
| **B** StartupModule 里 `FAngelscriptEngine::Get()` 触发 check 失败 | 重活放到了 StartupModule 而非 EngineSubsystem.Initialize / PostEngineInit | grep `FAngelscriptEngine::Get()`，应只在 `IsInitialized()` 守卫之后出现 |
| **C** ContentBrowser 看不到 `.as` 文件 | OnPostEngineInit 多播没触发 / DataSource 注册失败 | 启动日志 grep `AngelscriptData` 应有 `ActivateDataSource`；检查 `GOnPostEngineInitHandle.IsValid()` |
| **D** HotReload 不响应文件变更 | DirectoryWatcher 注册失败 / ScriptRoot 列表为空 | 步骤 ⑧ 的 `ensure` 是否 hit；`MakeAllScriptRoots()` 返回是否包含实际路径 |
| **E** `-AngelscriptTestUseScanFreeStartupEngine` 注入的 Engine 没生效 | 命令行参数未透传 / EngineSubsystem.Initialize 已先于 Test.StartupModule 跑 | `FCommandLine::Get()` 内确认开关存在；Override 安装链路要求 Test 模块**先于** EngineSubsystem 实例化 |
| **F** Test 编译失败 `AngelscriptEditor.h` 在 headless target 下找不到 | Test 代码 `#include` 了 Editor 头但被 cooked-client 编译 | `Test.Build.cs` 内 `AngelscriptEditor` 必须在 `if (Target.bBuildEditor)` 下追加；Test 的 `.h` 不能 include Editor 头 |
| **G** 退出时 `[RuntimeStartup] ShutdownModule ownedEngine=true` 出现 | 走了 Path C 自建 OwnedPrimaryEngine（headless / 纯 -game 兜底） | 正常路径；若意外出现在 Editor 进程，检查 `ShouldBootstrapAngelscript()` 与 `GIsEditor` |

定位"模块装载阶段是不是出问题"最快的方法是 grep 三类前缀的日志：

| 日志前缀 | 来源 | 含义 |
|---------|------|------|
| `[RuntimeStartup]` | `FAngelscriptRuntimeModule` | StartupModule / ShutdownModule / InitializeAngelscript 路由 |
| `[EngineSubsystemStartup]` | `UAngelscriptEngineSubsystem` | EnsurePrimaryEngineInitialized 内的三种路径 |
| `[EngineLifecycle]` | `FAngelscriptEngine` | Initialize / Shutdown 主流程 |

在三段日志的时间戳之间寻找异常间隙，就能快速定位"卡在哪一阶段"。

---

## 附录 A：模块装载顺序速查表

| 阶段 | 触发者 | 做的事 | 此时 Engine 状态 |
|------|--------|--------|------------------|
| **PostDefault 开始** | UE 模块加载子系统 | 按依赖拓扑加载三个 C++ 模块 | `IsInitialized() == false` |
| ↳ T0a | `AngelscriptRuntime.StartupModule()` | 仅打 verbose 日志 | `false` |
| ↳ T0b | `AngelscriptEditor.StartupModule()` | 12 步扩展注册（无引擎调用） | `false` |
| ↳ T0c | `AngelscriptTest.StartupModule()` | 可选 Override Hook + TestEnginePool 预热 | `false` |
| **PostDefault 结束** | UE | 继续 boot 主流程 | `false` |
| ↳ T1 | `UAngelscriptEngineSubsystem::Initialize` | `EnsurePrimaryEngineInitialized` → `Engine->Initialize()` | `true`（含 121 Bind + InitialCompile） |
| **PostEngineInit** 多播 | `FCoreDelegates::OnPostEngineInit` | Editor 步骤 ⑤ 的 `OnEngineInitDone()` 注册 ContentBrowser DataSource | `true` |
| **业务运行** | `EngineSubsystem.Tick` / `GameInstanceSubsystem.Tick` | 驱动 `FAngelscriptEngine::Tick` | `true` |
| **进程退出 U0** | UE | `UAngelscriptEngineSubsystem::Deinitialize` → `Engine->Shutdown()` | `false` |
| **进程退出 U1a** | `FModuleManager` | `AngelscriptTest.ShutdownModule()`（反挂 Override + Pool） | `false` |
| **进程退出 U1b** | `FModuleManager` | `AngelscriptEditor.ShutdownModule()`（12 步反向解绑） | `false` |
| **进程退出 U1c** | `FModuleManager` | `AngelscriptRuntime.ShutdownModule()`（清 OwnedPrimaryEngine 兜底） | `false` |
| **构建期（旁路）** | UnrealBuildTool | `AngelscriptUHTTool` 的 `Export` 跑一遍，产物编入 Runtime | — |

---

## 附录 B：扩展点登记速查表

下表汇总 Editor 模块在 StartupModule 里挂入 UE 的全部扩展位（以"用一行就能 grep 定位"为目标）：

| 扩展点 | grep 关键字 | 文件 | 反向解绑位置 |
|--------|------------|------|-------------|
| ClassReloadHelper | `FClassReloadHelper::Init` | `HotReload/ClassReloadHelper.cpp` | — |
| SourceCodeNavigation | `RegisterAngelscriptSourceNavigation` | `SourceNavigation/` | — |
| GameplayTag 多播 | `IGameplayTagsModule::OnTagSettingsChanged` | EditorModule.cpp | `UnregisterGameplayTagDelegates` |
| OnPostEngineInit | `FCoreDelegates::OnPostEngineInit.AddStatic` | EditorModule.cpp | `Remove(GOnPostEngineInitHandle)` |
| EditorMenuExtensions | `UScriptEditorMenuExtension::InitializeExtensions` | `EditorMenuExtensions/` | — |
| StateDumpExtension | `RegisterStateDumpExtension` | `Editor/Dump/` | `UnregisterStateDumpExtension` |
| DirectoryWatcher | `RegisterDirectoryChangedCallback_Handle` | EditorModule.cpp | `UnregisterDirectoryWatchers` |
| Project Settings | `SettingsModule->RegisterSettings` | EditorModule.cpp | `UnregisterSettings("Project", "Plugins", "Angelscript")` |
| DebugBridge | `FAngelscriptEditorDebugBridge::GetDebugListAssets().AddLambda` | `AngelscriptEditorDebugBridge.cpp` | `Remove(DebugListAssetsBridgeHandle)` |
| OnObjectPreSave | `FCoreUObjectDelegates::OnObjectPreSave.AddStatic` | EditorModule.cpp | `Remove(GLiteralAssetPreSaveHandle)` |
| ToolMenus | `UToolMenus::RegisterStartupCallback` | EditorModule.cpp | `UnRegisterStartupCallback / UnregisterOwner` |

Test 模块的"扩展点"只有两个，且都是私有 hook：

| 扩展点 | grep 关键字 | 文件 | 反向解绑位置 |
|--------|------------|------|-------------|
| EngineSubsystem Override | `UAngelscriptEngineSubsystem::SetInitializeOverrideForTesting` | TestModule.cpp | `ResetInitializeStateForTesting` |
| TestEnginePool | `AngelscriptTestSupport::StartupTestEnginePool` | `Shared/AngelscriptTestEnginePool.cpp` | `ShutdownTestEnginePool` |

Runtime 模块的 StartupModule 不挂任何扩展点（按设计——重活全部延后），故无表。

---

## 小结

- **三模块齐心 `PostDefault`** 是基线：CoreUObject 已就绪、`GEngine` 不必然存在的窗口期，正合"挂回调而不创建重对象"的策略；任何修改都不要随意改成更早或更晚的 LoadingPhase。
- **物理依赖严格分层**：`AngelscriptRuntime` 是底座（无 plugin 内同级依赖），`AngelscriptEditor` Public 依赖 Runtime，`AngelscriptTest` Public 依赖 Runtime 且 **Private + bBuildEditor** 限定下追加 Editor——这条限定让测试模块的覆盖面自适应于 headless / Editor 构建。
- **三类 StartupModule 节奏迥异**：Runtime 极轻（只打日志）、Editor 重（12 步扩展挂入）、Test 命令行驱动（两类副作用）；所有 Startup 都**不直接读 `FAngelscriptEngine::Get()`**，重活推迟到 EngineSubsystem.Initialize / PostEngineInit。
- **AngelscriptUHTTool 不在 UE 模块加载体系内**：它是构建期 UBT 进程内的 C# 旁路；产物 `AS_FunctionTable_*.cpp` 通过 `[UhtExporter] ModuleName = "AngelscriptRuntime"` 编入 Runtime 模块，与三个 C++ 模块的 StartupModule 没有运行时关联。
- **跨阶段握手点要数 PostEngineInit 多播**：Editor 步骤 ⑤ 注册到此多播的 `OnEngineInitDone()` 是 ContentBrowser DataSource 等"需要 GEngine"的扩展位的兜底装载入口；定位"启动时某扩展点不生效"的问题先 grep 这条多播。
- **排错入口三段日志**：`[RuntimeStartup]` / `[EngineSubsystemStartup]` / `[EngineLifecycle]` 三类前缀的时间戳间隙能精准回答"卡在哪个阶段"。
