# Guide_EditorExtension — 编辑器菜单扩展与函数分类管理

> **所属前缀**: Guide_（实践指南族）
> **关注层面**: AS 端可用的编辑器扩展手段、Toolbar/Menu 注册、函数分类机制；不涉及 Editor 模块内部协作机理（那是 `Arch_EditorTestDumpCollaboration.md`）。
> **关键源码**:
> `Plugins/Angelscript/Source/AngelscriptEditor/EditorMenuExtensions/ScriptEditorMenuExtension.{h,cpp}` (~770 行)
> · `EditorMenuExtensions/ScriptActorMenuExtension.{h,cpp}`
> · `EditorMenuExtensions/ScriptAssetMenuExtension.{h,cpp}`
> · `EditorMenuExtensions/ScriptEditorMenuExtensionRegistration.cpp`
> · `BaseClasses/ScriptEditorSubsystem.h`
> · `FunctionLibraries/ScriptableFactory.{h,cpp}`
> · `BlueprintImpact/AngelscriptBlueprintImpactScanCommandlet.cpp`
> · `AngelscriptRuntime/Preprocessor/AngelscriptPreprocessor.cpp`（`#if EDITOR` 处理）
> **关联文档**:
> `Documents/Knowledges/ZH/Arch_EditorTestDumpCollaboration.md` — Editor 5 个扩展点的协作边界与维护视角
> · `Documents/Knowledges/ZH/Arch_ModuleLoading.md` — `EditorModule.StartupModule` 中扩展点的注册顺序
> · `Documents/Knowledges/ZH/Type_Preprocessor.md` — `#if EDITOR` / `EditorOnlyBlockLines` 的预处理实现
> · `Documents/Knowledges/ZH/Guide_QuickStart.md` — 快速入门，声明 UPROPERTY/UFUNCTION 的基础语法
> · `Documents/Knowledges/ZH/Guide_ClassBinding.md` — C++ 类暴露给 AS 的整体策略（本文不重复）

---

## 概览

本文聚焦一个核心问题：**我手头有一段 AngelScript 脚本，想在 UE 编辑器里添加一个菜单按钮 / Toolbar 项 / 资产右键菜单条目，让美术或策划点一下就能跑我这段逻辑。AS 端目前能做到什么程度？哪些是写一行 default 就能 work 的，哪些根本没接通？**

这是 AngelScript 插件相对成熟但**最容易被误以为不存在**的一个能力面。Hazelight 在原版插件里把 `UToolMenus` / `IExtender` 全套机制裸接到了 AS 反射层，再用 `UFUNCTION(CallInEditor)` + `Category` / `EditorIcon` / `ActionCanExecute` 等元数据当成"声明式 UI 描述符"。继承 `UScriptEditorMenuExtension` 写几个 method、给类加上 `default ExtensionPoint = n"..."`，编辑器启动后就能在指定位置看到入口——**不用注册命令、不用写 C++、不用重启编辑器**。

```text
                         AS 端编辑器扩展能力地图

  ┌──────────────────────────────────────────────────────────────────────┐
  │  .as 文件                                                            │
  │                                                                      │
  │  #if EDITOR                                  // 预处理标志           │
  │                                                                      │
  │  class UMyExt : UScriptEditorMenuExtension {                         │
  │      default ExtensionPoint = n"...";        ┐                       │
  │      default ExtensionMenu  = ...;           │ 注册元数据            │
  │      default SupportedClasses.Add(...);      ┘                       │
  │                                                                      │
  │      UFUNCTION(CallInEditor, Category="A|B", │ 函数即"按钮"           │
  │          Meta=(EditorIcon="...",             │ Icon / 分类 /         │
  │                ActionCanExecute="CanRun"))   │ 启用条件 / 类型        │
  │      void DoStuff() { ... }                  │                       │
  │                                                                      │
  │      UFUNCTION() bool CanRun() { ... }       │ 元数据回调函数        │
  │  };                                                                  │
  │  #endif                                                              │
  └──────┬───────────────────────────────────────────────────────────────┘
         │ ClassGenerator OnPostReload(bFullReload=true)
         ▼
  ┌──────────────────────────────────────────────────────────────────────┐
  │  UScriptEditorMenuExtension::RegisterExtensions()                    │
  │   遍历 TObjectIterator<UASClass>，CDO 是子类时挂入：                 │
  │     · LevelEditor 的 14 个 ExtensionMenu 入口                        │
  │     · ContentBrowser 的 6 个 ExtensionMenu 入口                      │
  │     · UToolMenus::ExtendMenu(<ExtensionPoint>)                       │
  └──────┬───────────────────────────────────────────────────────────────┘
         │
         ▼
  ┌──────────────────────────────────────────────────────────────────────┐
  │  编辑器菜单 / 工具栏 / 资产右键 渲染层                                │
  │   按 Category 拆分子菜单，按 SortOrder 排序，                        │
  │   按 ActionCanExecute / IsVisible / IsChecked 决定启用与勾选         │
  └──────────────────────────────────────────────────────────────────────┘
```

后续章节按"能力总览 → 三类基类 → 元数据手册 → 函数分类 → 周边扩展（Subsystem/Factory/Commandlet）→ 限制与诊断 → 与 Guide_ClassBinding 的边界"的顺序展开。

---

## 一、AS 端能做什么、不能做什么

把"我想在 UE 编辑器加点东西"这件事**先按可行性分桶**——这能避免你写半天才发现 AS 里没有这个 API。

### 1.1 已经接通、用 .as 直接 work（推荐做法）

| 能力 | AS 端做法 |
|------|----------|
| 顶部菜单（Tools / File / Window）新增条目 | `UScriptEditorMenuExtension` + `default ExtensionPoint = n"MainFrame.MainMenu.Tools"` |
| 关卡编辑器 Toolbar 按钮 | `UScriptEditorMenuExtension` + `default ExtensionPoint = n"LevelEditor.LevelEditorToolBar.User"` |
| Level 视口右键菜单（选中 Actor） | `UScriptActorMenuExtension`（继承前者） |
| Level 视口 View / Build / Play / Blueprints 等下拉菜单 | `UScriptEditorMenuExtension` + `ExtensionMenu = LevelViewport_*Menu` |
| Content Browser 资产右键菜单 | `UScriptAssetMenuExtension` |
| Content Browser 路径 / 集合 / 视图菜单 | `UScriptEditorMenuExtension` + `ExtensionMenu = ContentBrowser_*` |
| 编辑器 Subsystem（编辑器开启即 active） | `UScriptEditorSubsystem`（继承自 `UEditorSubsystem` + `FTickableGameObject`） |
| 自定义 Asset 工厂（New 资产） | `UScriptableFactory`（继承 `UFactory`） |
| Editor-only 代码区域 | `#if EDITOR ... #endif` 预处理 |
| BlueprintImpact 扫描（CI 触发） | `UnrealEditor-Cmd.exe -run=AngelscriptBlueprintImpactScan ...` |

### 1.2 没有专门 AS 包装，但 AS 端能用现有 UFunction 间接做到

- **EditorUtilityWidget**：AS 可以**继承** `UEditorUtilityWidget`（C++ / Blueprint 已注册的类），在 .as 里写一个常规 `UCLASS()` Widget。但目前 AS 端**没有**像 `UScriptEditorMenuExtension` 这样把"打开这个 EditorUtilityWidget 窗口"当成一行 default 就能注册的语法糖；通常做法是搭配 `UScriptEditorMenuExtension::ExtensionPoint` 给 Toolbar 加按钮，按钮里调用 `EditorUtility::OpenWidget(<class>)` 之类。
- **资产命名 / 删除 / 重命名**：通过 `EditorAsset::*` 全局函数（在 `Bind_*.cpp` 里手工绑定）调用现成 C++ 接口；不属于本文范畴的"扩展"，但常常和菜单条目一起出现（参见附录 B）。

### 1.3 当前 AS 端**还没有**或**不建议**走 AS 实现的扩展

- **自定义 ViewportToolBar 完整布局**（带嵌套 Combo / 自定义 Slate widget）——`FToolMenuEntry::InitWidget` 之类暂未在 AS 端开放；只能用 `InitToolBarButton` / `InitComboButton` 的"按钮 + 下拉菜单"组合。
- **Slate 窗口 / SDockTab 自定义控件**——`SCompoundWidget` 这条 Slate 线没有 AS 绑定；AS 想做"自定义工具窗口"的正确路线是 `UEditorUtilityWidget`（UMG）。
- **PIE 主线程之外的编辑器命令调度**——AS 脚本调用都受 `FEditorScriptExecutionGuard` 保护，不要在 commandlet（无 Slate / 无 GEditor）下指望菜单回调被触发。
- **Blueprint Asset Editor 内部的工具栏 / Detail Panel 扩展**（`Persona`、`UMGEditor` 等子编辑器）——AS 端没有桩。

> **诚实声明**：本文涉及到的"未支持"项不代表"做不到，只是没人写"——`UScriptEditorMenuExtension` 已经把整套 `UToolMenus` 桥过来了，加更多 EXT 类是工程量问题。需要时按 `Arch_EditorTestDumpCollaboration.md` §四的"协作通道决策树"评估增加 public API。

---

## 二、UScriptEditorMenuExtension：核心抽象

`UScriptEditorMenuExtension` 是顶部菜单 / 工具栏 / 各类下拉菜单的**通用扩展类**。理解它的工作模型 = 理解 AS 编辑器扩展能力的 80%。

### 2.1 最小可运行的扩展

```angelscript
// ============================================================================
// 文件: Script/Editor/Example_TopMenuExtension.as
// 角色: 在编辑器顶部菜单 Tools 下加一条 "Print Hello" 命令
// ============================================================================
#if EDITOR

class UMyTopMenuExtension : UScriptEditorMenuExtension
{
    // ★ 等价于 UToolMenus::ExtendMenu(n"MainFrame.MainMenu.Tools")
    default ExtensionPoint = n"MainFrame.MainMenu.Tools";

    // 任意 UFUNCTION(CallInEditor) 都会被收集为菜单项
    UFUNCTION(CallInEditor)
    void PrintHello()
    {
        Print("Hello from AS!", Duration = 5.0);
    }
}

#endif
```

**保存即生效**（参见 §六的诊断章节）：`UScriptEditorMenuExtension::InitializeExtensions()` 订阅了 `FAngelscriptClassGenerator::OnPostReload`，每次 FullReload 都会 `UnregisterExtensions() + RegisterExtensions()` 一遍——AS 文件改动后菜单内容会自动刷新。

### 2.2 默认扩展位置（ExtensionMenu）枚举

`EScriptEditorMenuExtensionLocation` 包含 20 个值，对应 14 个 LevelEditor 钩子 + 6 个 ContentBrowser 钩子，外加最常用的 `ToolMenu`：

```text
ToolMenu                              => UToolMenus::ExtendMenu(<ExtensionPoint>)
                                         默认值，最灵活；ExtensionPoint 任意 UToolMenus 名称

LevelViewport_ContextMenu             => 选中 Actor 后右键菜单
LevelViewport_DragDropContextMenu     => 拖拽 Actor 上下文菜单
LevelViewport_OptionsMenu             => 视口右上角"齿轮"
LevelViewport_ShowMenu                => 视口"Show"
LevelViewport_ViewMenu / BuildMenu / CompileMenu / SourceControlMenu
LevelViewport_CreateMenu / PlayMenu / BlueprintsMenu / CinematicsMenu / LevelMenu
                                      => 主工具栏各下拉

ContentBrowser_AssetContextMenu       => 通过路径触发的资产菜单
ContentBrowser_PathViewContextMenu    => 文件夹右键
ContentBrowser_CollectionListContextMenu / CollectionViewContextMenu
ContentBrowser_AssetViewContextMenu   => 选中资产后右键
ContentBrowser_AssetViewViewMenu      => 资产面板右上"View Options"
```

**两条最常用路径**：

```angelscript
// 路径 A：顶部菜单 / 工具栏（用 ExtensionMenu = ToolMenu，按 ExtensionPoint 定位）
class UMyToolbarExt : UScriptEditorMenuExtension
{
    default ExtensionPoint = n"LevelEditor.LevelEditorToolBar.User";
    // ExtensionMenu 默认就是 ToolMenu，无需写
}

// 路径 B：选中 Actor 后右键菜单（用 ExtensionMenu = LevelViewport_ContextMenu）
class UMySelectedActorExt : UScriptActorMenuExtension
{
    default ExtensionMenu = EScriptEditorMenuExtensionLocation::LevelViewport_ContextMenu;
    // 这是 UScriptActorMenuExtension 的默认值，写不写都行
}
```

### 2.3 注册—编译—展开链路

```text
[编辑器启动]
  FAngelscriptEditorModule::StartupModule()
    -> UScriptEditorMenuExtension::InitializeExtensions()
       订阅 OnPostReload + OnEnginePreExit
       如果首次编译已完成，立刻 RegisterExtensions()

[首次 / 每次 FullReload]
  RegisterExtensions()  ◀──────────  OnPostReload(bFullReload=true)
    for ScriptClass in TObjectIterator<UASClass>
      if 继承自 UScriptEditorMenuExtension
        把 CDO 的 ExtensionMenu / ExtensionPoint 翻译成对应 UE API
        Add 到对应的 GetAll...Extenders() 数组 或 UToolMenus::ExtendMenu()
        记录 DelegateHandle 以便下次 Unregister

[菜单要呈现时]
  UE 调用 CDO->Extend(CommandList, FExtenderSelection)
    -> CDO->ShouldExtend()                     // BlueprintNativeEvent，可重写
    -> CDO->GatherExtensionFunctions()         // 收集所有 CallInEditor UFUNCTION
    -> CDO->BuildMenu(MenuBuilder, Functions)
       (按 Category 分组、按 SortOrder 排序，每个函数生成一个菜单项)
```

**关键：CDO 模式而非实例模式**。所有元数据（ExtensionPoint / SupportedClasses / 等）都从 `GetDefaultObject<UScriptEditorMenuExtension>()` 读出。点击菜单项时引擎才 `NewObject<UScriptEditorMenuExtension>` 创建一个临时实例执行回调，执行完即销毁。**不要把"会话状态"挂在扩展类的成员变量上**——下次点同一个按钮时这个状态已经丢了。

如需保留状态，请用 `UScriptEditorSubsystem`（§四）。

---

## 三、UScriptActorMenuExtension / UScriptAssetMenuExtension：选区敏感的扩展

这两个子类在父类基础上**增加了"对当前选中对象的过滤"**，是右键菜单场景的标准用法。

### 3.1 Actor 右键菜单：UScriptActorMenuExtension

```angelscript
// ============================================================================
// 文件: Script/Editor/Example_ActorContextExtension.as
// 角色: 在选中 AStaticMeshActor 时弹出 "Replace With Drawable" 菜单
// ============================================================================
#if EDITOR

class UMeshReplaceMenuExtension : UScriptActorMenuExtension
{
    // 限定只在选中这些类（或子类）时显示
    default SupportedClasses.Add(AStaticMeshActor::StaticClass());

    // 命中策略：父类默认 SupportsActor 返回 true；可覆盖
    UFUNCTION(BlueprintOverride)
    bool SupportsActor(AActor Actor) const
    {
        AStaticMeshActor SMA = Cast<AStaticMeshActor>(Actor);
        return SMA != nullptr && SMA.StaticMeshComponent.StaticMesh != nullptr;
    }

    // 模式 A：第一个参数为 AActor（或子类）—— 引擎为每个选中 actor 调用一次
    UFUNCTION(CallInEditor, Category = "Mesh Tools")
    void HighlightActor(AActor SelectedActor)
    {
        Print(f"Highlight: {SelectedActor.Name}");
    }

    // 模式 B：无 Actor 参数 / 多个参数 —— 弹出对话框收集参数后调用一次
    UFUNCTION(CallInEditor, Category = "Mesh Tools",
              Meta = (EditorIcon = "Icons.Replace"))
    void ReplaceActorMaterial(AActor Target, UMaterialInterface NewMaterial)
    {
        // 引擎弹出 NewMaterial 选择框，用户点 OK 后才进入这里
    }
}

#endif
```

**两种参数模式**对应 `ScriptActorMenuExtension.cpp` 里的判定：

- 函数的**第一个参数是 `FObjectProperty`**（即 `UObject` 子类指针）→ 按当前选区里能 Cast 到该参数类型的 actor 列表，**逐个调用**。
- 函数没有第一个对象参数，或还有其他参数 → 走 `FScriptEditorPrompts::ShowPromptToCallFunction`，弹出对话框收集参数，再**一次性**调用。

### 3.2 Asset 右键菜单：UScriptAssetMenuExtension

```angelscript
// ============================================================================
// 文件: Script/Editor/Example_AssetContextExtension.as
// 角色: 在选中 UTexture2D 时新增 "Adjust LOD Bias" 资产菜单
// ============================================================================
#if EDITOR

class UTextureToolsExtension : UScriptAssetMenuExtension
{
    default SupportedClasses.Add(UTexture2D::StaticClass());

    // 接受 FAssetData：扩展会传选中资产的 AssetData（不强制加载）
    UFUNCTION(CallInEditor, Category = "Texture Tools")
    void ShowTextureInfo(FAssetData Asset)
    {
        Print(f"Texture: {Asset.AssetName}, package = {Asset.PackageName}");
    }

    // 第一个参数是 SupportedClasses 之一时，引擎自动 LoadAsset 并传入
    UFUNCTION(CallInEditor, Category = "Texture Tools")
    void DoubleLODBias(UTexture2D Texture)
    {
        Texture.Modify();
        Texture.LODBias = Texture.LODBias + 1;
    }

    // 多参数 → 弹对话框
    UFUNCTION(CallInEditor, Category = "Texture Tools")
    void SetLODBiasTo(UTexture2D Texture, int NewBias = 0)
    {
        Texture.Modify();
        Texture.LODBias = NewBias;
    }
}

#endif
```

`SupportsAsset(FAssetData)` 同样可重写，例如基于资产 Tag 进一步过滤。

### 3.3 何时不该用这两个子类

如果你的命令**不依赖当前选区**（例如"打开我的工具窗口"、"导入项目级资源"），用基类 `UScriptEditorMenuExtension` 即可——`SupportedClasses` / `SupportsActor` / `SupportsAsset` 都是父类不存在的概念。

---

## 四、函数分类、Icon、动作类型：元数据手册

`UFUNCTION(CallInEditor, ...)` 的元数据决定了菜单项**长什么样、怎么响应**。下面是当前 AS 端识别的全部元数据。

### 4.1 菜单分组：Category 与 SortOrder

```angelscript
class UMyExt : UScriptEditorMenuExtension
{
    default ExtensionPoint = n"MainFrame.MainMenu.Tools";

    // 顶层（无子菜单）
    UFUNCTION(CallInEditor, Meta = (SortOrder = "5"))
    void TopLevelCommand() { }

    // 一级子菜单 "Audit"
    UFUNCTION(CallInEditor, Category = "Audit", Meta = (SortOrder = "10"))
    void AuditEverything() { }

    // 二级子菜单 "Tools / Bake"，SortOrder 决定同 Category 内的顺序
    UFUNCTION(CallInEditor, Category = "Tools|Bake", Meta = (SortOrder = "20"))
    void BakeLater() { }

    UFUNCTION(CallInEditor, Category = "Tools|Bake", Meta = (SortOrder = "10"))
    void BakeSooner() { }
}
```

**展开效果**（参见 `ScriptEditorMenuExtension.cpp::SortFunctionsByCategory`）：

```text
Tools 主菜单
├── TopLevelCommand          // SortOrder=5，无 Category，落在顶层
├── Audit (子菜单)
│   └── AuditEverything      // SortOrder=10
└── Tools (子菜单)
    └── Bake (子菜单)
        ├── BakeSooner       // SortOrder=10（先显示）
        └── BakeLater        // SortOrder=20
```

要点：

- `Category` 用 `|` 分隔嵌套层级；空白会被 `TrimStartAndEnd`。
- `SortOrder` 是字符串形式的整数（解析时 `LexFromString`）；缺省 0。
- 同 `SortOrder` 时按函数名字母序排（`SortedFunction::operator<`）。
- 顶层（无 Category）函数与 Category 函数**混在同一菜单**显示。

### 4.2 显示与图标：DisplayName / EditorIcon / ToolbarLabel

```angelscript
UFUNCTION(CallInEditor, DisplayName = "Open My Window",
          Meta = (EditorIcon = "Icons.Edit",
                  ToolbarLabel = "Open"))
void OpenWindow_Internal() { }
```

| 元数据 | 作用 | 备注 |
|--------|------|------|
| `DisplayName` | 菜单文字（覆盖函数名） | UFunction 标准元数据 |
| `Meta = (ToolbarLabel = "...")` | 仅 Toolbar 路径下覆盖 DisplayName | 用于"工具栏文字 vs 菜单文字不一致"的场景 |
| `Meta = (EditorIcon = "...")` | `FAppStyle` 中的图标名 | 默认 `GraphEditor.Event_16x` |
| `Meta = (EditorButtonStyle = "...")` | Toolbar 按钮样式 | 例：`"CalloutToolbar"` 让按钮文字+图标横排显示 |

**图标名查找**：`Icons.Edit` / `Icons.Plus` / `GenericCommands.Paste` 这些来自 `FAppStyle::GetAppStyleSetName()`。在编辑器 `Widget Reflector` 里挑节点能看到当前 SlateIcon 名。找不到合适图标时直接省略 `EditorIcon`。

### 4.3 动作类型：ActionType

```angelscript
UFUNCTION(CallInEditor, Meta = (ActionType = "ToggleButton",
                                ActionIsChecked = "IsFooEnabled"))
void ToggleFoo() { }

UFUNCTION()
bool IsFooEnabled() const { return GetMutableDefault<UMySettings>().bFoo; }
```

`ActionType` 取值（来自 `GetExtensionActionType`）：

| 值 | 对应 `EUserInterfaceActionType` | 用途 |
|----|-----|------|
| `Button`（默认） | `Button` | 普通按钮 |
| `ToggleButton` | `ToggleButton` | 配合 `ActionIsChecked` 显示勾选状态 |
| `RadioButton` | `RadioButton` | 单选按钮 |
| `Check` | `Check` | 复选框 |
| `CollapsedButton` | `CollapsedButton` | 折叠按钮 |
| `None` | `None` | 不显示 UI（仅占位） |

### 4.4 启用 / 可见 / 勾选回调：ActionCanExecute / ActionIsVisible / ActionIsChecked

这是元数据机制最强大的一段——**通过命名引用同类内的判定函数**。

```angelscript
class UCleanupExt : UScriptActorMenuExtension
{
    default SupportedClasses.Add(AActor::StaticClass());

    // 按钮在没有勾选 actor 时灰显，selected actor 全是同名时不可见
    UFUNCTION(CallInEditor, Category = "Cleanup",
              Meta = (ActionCanExecute = "HasSelection",
                      ActionIsVisible  = "HasMixedSelection"))
    void DeleteAll() { }

    // 必须返回 bool，必须无入参（FindFunction(FuncName)）
    UFUNCTION()
    bool HasSelection() const
    {
        // CurrentSelection 字段可以用，但要在 Extend()/CallFunction 调用栈内才被填充
        return true; // 简化示例
    }

    UFUNCTION()
    bool HasMixedSelection() const
    {
        return false;
    }
}
```

`CreateUIAction` / `CreateToolUIAction` 内部对这三个回调的约束：

- 必须是 UFunction（用 `FindFunction(FuncName)` 找）。
- 返回 `bool`（`CastField<FBoolProperty>(GetReturnProperty())`），无返回值或非 bool 时被忽略并返回 `false`。
- 通过 `ProcessEvent` 反射调用，因此**不能加参数**（参数槽全是 0 字节调用）。

`ActionIsChecked` 的返回 `bool` 会被映射成 `ECheckBoxState::Checked / Unchecked`（无 `Undetermined`）。

### 4.5 ToolMenu 章节的位置与对齐

当 `ExtensionMenu = ToolMenu` 时，可以进一步控制 Section 摆放：

```angelscript
class UMyToolbarSection : UScriptEditorMenuExtension
{
    default ExtensionPoint = n"LevelEditor.LevelEditorToolBar.User";
    default MenuSectionHeader = FText::FromString("My Tools");

    // 在 PIE 段之后插入
    default ToolMenuInsertType = EToolMenuInsertType::After;
    default ToolMenuInsertPosition = n"PlayInEditor";

    default ToolMenuSectionAlign = EToolMenuSectionAlign::Default;

    default bAddSeparatorBeforeOptions = true;
    default bAddSeparatorAfterOptions  = false;
}
```

含义（参见 `RegisterExtensions` 中的 `ToolMenu` 分支）：

- `MenuSectionHeader`：未填则用类的 `DisplayNameText`。
- `ToolMenuInsertType / ToolMenuInsertPosition`：控制 Section 在目标 Menu 中的位置（`Before / After / First / Default`）。
- `ToolMenuSectionAlign`：影响 Section 在 Toolbar 中的左右对齐。
- `bAddSeparator*`：在生成的 Section 前/后插入分隔线。

### 4.6 Shift 点击 → 跳转源代码

`CreateUIAction` / `CreateToolUIAction` 会检查 Shift 键：**按住 Shift 点菜单项不会执行函数，而是跳到 .as 源码定义处**。底层走 `FSourceCodeNavigation::NavigateToFunction`，在 `Documents/Knowledges/ZH/Arch_EditorTestDumpCollaboration.md §1.3` 有 SourceNavigation 的处理器实现细节。这条特性对调试自己写的扩展非常有用。

---

## 五、相关编辑器扩展类（Subsystem / Factory / Commandlet）

### 5.1 UScriptEditorSubsystem：编辑器开启即 active 的"全局对象"

需要在编辑器整生命周期内保留状态（缓存数据、监听 Asset 改动、Tick 检查等）时，用 `UScriptEditorSubsystem`：

```angelscript
// ============================================================================
// 文件: Script/Editor/MyEditorSubsystem.as
// 角色: 编辑器开启时 Initialize、关闭时 Deinitialize、每帧 Tick
// ============================================================================
#if EDITOR

class UMyEditorSubsystem : UScriptEditorSubsystem
{
    int TickCount = 0;

    UFUNCTION(BlueprintOverride)
    void BP_Initialize()
    {
        Print("MyEditorSubsystem: started");
    }

    UFUNCTION(BlueprintOverride)
    void BP_Deinitialize()
    {
        Print("MyEditorSubsystem: ended");
    }

    UFUNCTION(BlueprintOverride)
    void BP_Tick(float DeltaTime)
    {
        TickCount += 1;
        if (TickCount % 600 == 0) // ~10 秒打印一次（按 60fps 估算）
            Print(f"Editor tick: {TickCount}");
    }

    // 可选：返回 false 阻止子系统创建
    UFUNCTION(BlueprintOverride)
    bool BP_ShouldCreateSubsystem(UObject Outer) const
    {
        return true;
    }
}

#endif
```

要点（来自 `ScriptEditorSubsystem.h`）：

- **基类已是 abstract**，AS 子类直接 `: UScriptEditorSubsystem` 即可。
- **必须 `BP_Initialize` / `BP_Deinitialize` / `BP_Tick`**（带 `BP_` 前缀）；不要写 `Initialize` / `Tick`，那是父类 C++ 接管的入口，`CanCallScriptFunctions()` 决定何时回调到 AS。
- `IsTickableInEditor() = true`：编辑器未 PIE 时也 Tick。
- 与 `UScriptEditorMenuExtension` 配合：菜单按钮可以通过 `GEditor->GetEditorSubsystem<UMyEditorSubsystem>()` 拿到 subsystem 实例，然后改其内部状态。

### 5.2 UScriptableFactory：自定义资产类型

```angelscript
// ============================================================================
// 文件: Script/Editor/MyTextFactory.as
// 角色: Content Browser "Create Advanced Asset" 里出现一个新条目
// ============================================================================
#if EDITOR

class UMyTextAssetFactory : UScriptableFactory
{
    UFUNCTION(BlueprintOverride)
    UObject CreateFromText(UClass InClass, UObject InParent, FName InName,
                           int InFlags, UObject Context, const FString& Buffer)
    {
        // 返回创建好的资产
        return CreateOrOverwriteAsset(InClass, InParent, InName, InFlags);
    }
}

#endif
```

`UScriptableFactory` 派生自 `UFactory`，把 `FactoryCreateText / FactoryCreateBinary` 路由到 `BlueprintImplementableEvent` 钩子上。**注意**：要让这个 factory 真的注册进 UE 的 Asset Type 系统、出现在 New 菜单，仍需 C++ / 资产类配置（`SupportedClass` / `Formats` 等）；纯 .as 端通常做不到完整的"新类型 + 编辑器图标 + 缩略图渲染器"全套，所以 `UScriptableFactory` 多用于**已有资产类型的二次创建**而非全新类型。

### 5.3 BlueprintImpact Commandlet：CI 触发的"被脚本改动影响的蓝图扫描"

不是用户每天用的扩展，但属于"AS 工具链可被外部触发"的范畴：

```bash
# 全量扫描（无 ChangedScripts）
UnrealEditor-Cmd.exe <Project>.uproject \
    -run=AngelscriptBlueprintImpactScan

# 增量扫描：只扫这几个改动的 .as 文件
UnrealEditor-Cmd.exe <Project>.uproject \
    -run=AngelscriptBlueprintImpactScan \
    -ChangedScripts=Script/Foo.as,Script/Bar.as

# 从文件读取列表
UnrealEditor-Cmd.exe <Project>.uproject \
    -run=AngelscriptBlueprintImpactScan \
    -ChangedScriptsFile=ChangedScripts.txt
```

输出（stdout 里一行 JSON，便于 CI 解析）：

```text
LogAngelscript: Display: { "BlueprintImpact": { "FullScan": false,
    "ChangedScriptCount": 2, "ResolvedSymbolCount": 5,
    "BlueprintCandidates": 17, "ImpactedBlueprints": 3,
    "FailedAssetLoads": 0 } }
```

退出码（`EBlueprintImpactCommandletExitCode`）：

| 码 | 含义 |
|----|------|
| 0 | Success |
| 1 | InvalidArguments（参数解析失败） |
| 2 | EngineNotReady（AS 引擎首次编译失败，无法扫描） |
| 3 | AssetScanFailure（部分蓝图无法加载） |

详见 `Documents/Knowledges/ZH/Arch_EditorTestDumpCollaboration.md §1.2` 与 `Documents/Knowledges/ZH/Arch_UHTToolchain.md`。**用户向用法**：CI 中作为 PR 检查步骤（`if 退出码 != 0 then 标红`），开发者本地排查时也能通过 commandlet 复现。

---

## 六、限制与诊断：扩展不生效的常见原因

### 6.1 编辑器扩展运行的隐含约束

- **必须有 `GEditor` / Slate**：commandlet（headless）不会渲染菜单；BlueprintImpact commandlet 之类自身是 commandlet，但**它们不依赖菜单扩展**——你的扩展函数在 commandlet 下不会被触发。
- **必须在 `FEditorScriptExecutionGuard` 范围内**：扩展回调内部已经包了一层 guard，但如果你在扩展函数里再创建 PIE / 切关卡等动作，要确保这些动作允许在编辑器世界（非 PIE）下进行。
- **CDO 模式**：扩展类的成员变量在不同点击之间不持久。要持久化用 `UScriptEditorSubsystem` 或写到 `UAngelscriptSettings` / `UDeveloperSettings` 里。
- **HotReload 重启**：每次 FullReload 都会 `Unregister + Register`，意味着 **AS 改完后你旧的菜单 handle 都失效**——这是设计目的（菜单与最新代码保持同步），但也意味着你不能"手动 RegisterExtension 一次然后期望它一直在"。

### 6.2 编辑器扩展不生效——决策树

```text
菜单 / 按钮看不到？
├── 类是否在 #if EDITOR ... #endif 内？
│   └─ 不在 → cook / shipping 构建会编译出未注册的"裸类"，
│             没问题但增加包体；建议加上。
├── 类是否标记 abstract？
│   └─ 是  → RegisterExtensions 会跳过 CLASS_Abstract 的子类，
│             去掉 UCLASS(Abstract) 或派生一个具体子类。
├── 类是否被首次编译？
│   └─ 否  → 看 Output Log 是否有 AS 编译错误；
│             ASLog Verbose 日志能看到 ClassGenerator 跳过该类的原因。
├── ExtensionPoint 是否拼写正确？
│   └─ 在 UE 里用 "Tools.DebugTools.MenuExtension" 控制台命令
│      或代码 UToolMenus::Get()->GetMenuNames() 罗列所有可用名称。
├── 函数是否带 UFUNCTION(CallInEditor)？
│   └─ 缺 CallInEditor 的函数不会被收集（GatherExtensionFunctions 跳过）。
├── 函数是否有返回值？
│   └─ 有返回值 (GetReturnProperty != nullptr) 的也会被跳过——
│      改成 void 或新写一个 wrapper。
├── ShouldExtend() 是否返回 false？
│   └─ 重写了 BlueprintOverride bool ShouldExtend() 但忘了返回 true？
└── ActionIsVisible 回调返回 false？
    └─ 隐藏函数不会显示——改回调或临时移除元数据排查。
```

### 6.3 用 dump 系统验证注册结果

`Arch_EditorTestDumpCollaboration.md §3` 列出的扩展表 `EditorMenuExtensions.csv` 由 Editor 模块写入：

```text
控制台中输入：
  as.DumpEngineState

输出目录（默认 ProjectSaved/Angelscript/Dump/<时间戳>/）下检查：
  EditorMenuExtensions.csv

每行对应一个已注册的 RegisteredExtender，包含 Location / ExtensionPoint /
SectionName。如果你写的扩展类没出现在这张表，注册阶段就有问题（多半
是 CLASS_Abstract / OnPostReload 时序 / 类没编译进当前模块）。
```

### 6.4 Shift 跳源代码不生效

按住 Shift 点菜单项不会执行函数，而是跳到 .as 源码定义处（走 `FSourceCodeNavigation::NavigateToFunction`）。如果不生效：检查 `UAngelscriptSettings::VSCodeWorkspacePath`、PATH 中能否运行 `code`，详情见 `Arch_EditorTestDumpCollaboration.md §1.3`。

---

## 七、与 Guide_ClassBinding 的边界：别在这里写 binding

本文不重复 `Documents/Knowledges/ZH/Guide_ClassBinding.md` 的内容。两者关系：

| 主题 | 归属 |
|------|------|
| "C++ 类怎么 expose 给 AS" | `Guide_ClassBinding.md` |
| "C++ 函数怎么变成 AS 可调用 API" | `Guide_ClassBinding.md` |
| "AS 怎么接管 UEditorSubsystem 行为" | 本文 §5.1 |
| "AS 怎么在 UE 编辑器里加 UI 入口" | 本文 §2 / §3 / §4 |
| "AS 怎么参与 BlueprintImpact CI" | 本文 §5.3 |
| "AS class 派生 C++ class 的语法" | `Guide_ClassBinding.md` 与 `Guide_QuickStart.md` |

**判断规则**：你的需求如果是"我要把现有 C++ API 让 AS 能调用"——读 ClassBinding；如果是"我要在编辑器加个按钮跑我已经写好的 .as 函数"——读本文。

---

## 附录 A：可用 Editor 扩展能力速查表

**基类与默认值速查**：

| 扩展类型 | AS 基类 | 关键 default | 入口元数据 |
|---------|---------|--------------|-----------|
| 顶部菜单 / 工具栏 | `UScriptEditorMenuExtension` | `ExtensionPoint = n"..."` | `CallInEditor` + `Category` |
| 选中 Actor 右键 | `UScriptActorMenuExtension` | `SupportedClasses.Add(AClass::StaticClass())` | `CallInEditor` + AActor 第一参数 |
| 资产右键 | `UScriptAssetMenuExtension` | `SupportedClasses.Add(UClass::StaticClass())` | `CallInEditor` + FAssetData / UClass 第一参数 |
| 编辑器 Subsystem | `UScriptEditorSubsystem` | — | `BlueprintOverride` `BP_Initialize` / `BP_Tick` |
| 资产工厂 | `UScriptableFactory` | — | `BlueprintOverride` `CreateFromText` / `CreateFromBinary` |

**元数据速查**：

| 元数据 | 出现位置 | 作用 |
|---------------|---------|------|
| `Category = "A\|B"` | UFUNCTION Meta | 嵌套子菜单（`\|` 分级） |
| `SortOrder = "10"` | UFUNCTION Meta | 同级排序键（字符串整数） |
| `EditorIcon = "Icons.Edit"` | UFUNCTION Meta | FAppStyle 图标 |
| `EditorButtonStyle = "CalloutToolbar"` | UFUNCTION Meta | Toolbar 按钮样式 |
| `ToolbarLabel = "..."` | UFUNCTION Meta | Toolbar 路径下显示文字 |
| `ActionType = "ToggleButton"` | UFUNCTION Meta | 按钮类型（Button / ToggleButton / RadioButton / Check / CollapsedButton / None） |
| `ActionCanExecute / ActionIsVisible / ActionIsChecked` | UFUNCTION Meta | 命名引用同类内 UFUNCTION → bool |
| `DisplayName = "..."` | UFUNCTION 标准 | 菜单文字 |
| `SupportedClasses` | default 字段 | 限定生效的 Actor/Asset 类 |
| `MenuSectionHeader` | default 字段 | ToolMenu 分节标题 |
| `ToolMenuInsertType` / `ToolMenuInsertPosition` | default 字段 | Section 插入位置 |
| `bAddSeparatorBeforeOptions` / `bAddSeparatorAfterOptions` | default 字段 | 周围分隔线 |

---

## 附录 B：当前**不支持**的能力（诚实清单）

| 能力 | 现状 | 替代方案 |
|------|------|----------|
| 自定义 Slate Widget（`SCompoundWidget` 子类） | AS 端无桩 | 用 `UEditorUtilityWidget`（UMG）做工具窗口 |
| 直接打开 EditorUtilityWidget 的"一行声明" | 需 Toolbar 按钮 + 调用 EditorUtility 全局函数 | §1.2 / §5.1 配合 |
| Blueprint 编辑器、Persona、Niagara 等子编辑器内部 ToolBar 扩展 | 暂未接通 | 用 C++ 写本地扩展，再用 AS 调用 |
| 自定义 ContentBrowser DataSource | C++ 已有 `UAngelscriptContentBrowserDataSource`（让 .as 出现在浏览器），但**用户**不能再加新的 DataSource | 用现有资产类型 + Asset 菜单扩展 |
| 自定义 Asset 类型（带缩略图渲染器、AssetTypeActions） | 部分能力（`UScriptableFactory`）；缩略图 / 编辑器自定义 Detail Panel 仍需 C++ | C++ 注册 AssetTypeActions，AS 实现资产 UClass |
| 编辑器命令绑定快捷键 | 暂未接通 `FUICommandList::Map`，只能通过菜单 / Toolbar 触发 | UE Project Settings → Keyboard Shortcuts 不会列出 AS 扩展项 |
| Modal Slate Window（不是 MessageDialog） | 暂未接通 | 用 EditorUtilityWidget |
| ContextMenu 子菜单（非 ToolMenu 路径）的 InsertType 控制 | 仅 `ToolMenu` 走 `UToolMenus::ExtendMenu`；`LevelViewport_*` 走老 IExtender API，无 InsertType | 在子菜单内部用 `Category` 自组织 |

**追加说明**：以上"不支持"不是设计上的拒绝，多数是"还没人在 AS 端开桩"。如果你需要补齐其中某条，参考 `Documents/Knowledges/ZH/Arch_EditorTestDumpCollaboration.md §四" 协作通道矩阵"——优先在 Runtime / Editor 加 public delegate 或 const getter，避免破坏"AS 端只读公开 API"的边界约束。

---

## 附录 C：综合骨架（Toolbar + Actor 右键 + 状态回调）

```angelscript
// ============================================================================
// 文件: Script/Editor/Example_FullEditorExtension.as
// 角色: Toolbar 按钮 + 选中 Actor 右键，配合 ShouldExtend 与 ActionCanExecute
// ============================================================================
#if EDITOR

class UDevTools_Toolbar : UScriptEditorMenuExtension
{
    default ExtensionPoint = n"LevelEditor.LevelEditorToolBar.User";
    default MenuSectionHeader = FText::FromString("Dev Tools");

    UFUNCTION(BlueprintOverride)
    bool ShouldExtend() const  // 只在 DevMap 显示
    {
        UWorld World = GetWorld();
        return World != nullptr && World.Name.ToString().Contains("DevMap");
    }

    UFUNCTION(CallInEditor,
              Meta = (EditorIcon = "Icons.Audit", EditorButtonStyle = "CalloutToolbar"))
    void RunAudit() { Print("Audit started"); }
}

class UDevTools_ActorContext : UScriptActorMenuExtension
{
    default SupportedClasses.Add(AStaticMeshActor::StaticClass());

    UFUNCTION(CallInEditor, Category = "Dev Tools|Mesh",
              Meta = (SortOrder = "10", ActionCanExecute = "HasStaticMesh"))
    void DumpMeshInfo(AStaticMeshActor Mesh)  // 第一参数 = 自动逐个调用
    {
        Print(f"{Mesh.Name}: bounds = {Mesh.GetActorBounds(false)}");
    }

    UFUNCTION()
    bool HasStaticMesh() const  // ActionCanExecute 回调
    {
        for (UObject Object : CurrentSelection.SelectedObjects)
        {
            AStaticMeshActor SMA = Cast<AStaticMeshActor>(Object);
            if (SMA != nullptr && SMA.StaticMeshComponent.StaticMesh != nullptr)
                return true;
        }
        return false;
    }
}

#endif
```

---

## 小结

- **核心抽象只有三个 AS 基类**：`UScriptEditorMenuExtension`（万用基类）、`UScriptActorMenuExtension`（按选中 Actor 过滤）、`UScriptAssetMenuExtension`（按选中资产过滤）；都用 `UFUNCTION(CallInEditor)` 把成员函数变成菜单项。
- **元数据驱动 UI**：`Category` / `SortOrder` 决定菜单层次与顺序，`EditorIcon` / `DisplayName` / `ActionType` 决定外观，`ActionCanExecute` / `ActionIsVisible` / `ActionIsChecked` 决定动态状态——全部通过命名引用同类内的辅助 UFunction 实现。
- **CDO 模式 + HotReload 重注册**：扩展类的成员变量不持久；FullReload 会自动 `Unregister + Register` 整套扩展，保证菜单与最新 AS 代码同步。需要持久状态时用 `UScriptEditorSubsystem`。
- **Editor-only 代码用 `#if EDITOR`**：等价于 C++ 的 `#if WITH_EDITOR`；预处理器把这段代码标记成 `EditorOnlyBlockLines`，cook / shipping 构建里默认不参与编译。
- **诚实边界**：自定义 Slate widget、子编辑器 ToolBar、快捷键绑定、自定义 Asset Type 完整流程目前 AS 端**未开放**——可在 Toolbar 按钮里调用 `EditorUtility::OpenWidget(...)` 之类的全局 API 间接达成；需要补齐请走 `Arch_EditorTestDumpCollaboration.md §四` 的协作通道。
- **下一步导航**：维护视角看扩展点的"内部协作图"读 `Arch_EditorTestDumpCollaboration.md`；想了解 `#if EDITOR` 的预处理实现读 `Type_Preprocessor.md`；想了解 `EditorModule.StartupModule` 如何把扩展点串接到 UE 系统读 `Arch_ModuleLoading.md`。
