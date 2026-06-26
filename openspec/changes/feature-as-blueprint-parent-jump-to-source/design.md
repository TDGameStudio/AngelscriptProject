# Design — feature-as-blueprint-parent-jump-to-source

## 背景与根因

蓝图编辑器右上角"打开父类源码"按钮，引擎实现（`SBlueprintEditorToolbar`/`FBlueprintEditorToolbar`，未 vendored）通常对父类做 native 门控：仅当 `ParentClass->HasAnyClassFlags(CLASS_Native)` 才显示/启用，执行时调 `FSourceCodeNavigation::NavigateToClass(ParentClass)`。

AS 生成类被标记为 `CLASS_CompiledFromBlueprint`（`AngelscriptClassGenerator.cpp:3319`），不是 `CLASS_Native`。因此引擎对 AS 父类要么隐藏按钮、要么当作普通蓝图父类处理（打开蓝图而非 IDE），**从不调用** `NavigateToClass` → 已注册的 AS handler 永远没机会响应。

## 已具备的能力（复用，不重建）

1. **源码位置数据**：`UASFunction::GetSourceFilePath()`/`GetSourceLineNumber()`（`ASClass.h:193-194`）；`FAngelscriptClassDesc::LineNumber`（`AngelscriptEngine.h:1343`）；通过 `FAngelscriptEngine::Get().GetClass(prefix+name, &OutModule)` 由 `UASClass`/`UASStruct` 反查 desc + module。
2. **VS Code 打开**：`AngelscriptSourceCodeNavigation.cpp` 的 `OpenVsCode()` → `FPlatformMisc::OsExecute(nullptr, "code", *Params)`，`code --goto "<path>:<line>"`；受 `UAngelscriptSettings::VSCodeWorkspacePath`/`bOpenFolderOnVSCodeSourceLinks` 控制。
3. **已注册 handler**：`FAngelscriptSourceCodeNavigation : ISourceCodeNavigationHandler` 实现 `CanNavigateToClass`/`NavigateToClass`，在 `FAngelscriptEditorModule::StartupModule()`（`AngelscriptEditorModule.cpp:815`）经 `FSourceCodeNavigation::AddNavigationHandler` 注册。
4. **现成范式**：`ScriptEditorMenuExtension.cpp:68` 已用 `FSourceCodeNavigation::NavigateToClass(Class)` 实现右键"Go to source"，证明该路径在编辑器内可用。

## 方案

在 AngelscriptEditor 模块新增一个**自有的蓝图编辑器入口**（不依赖引擎按钮的 native 门控）：

- 通过 `UToolMenus` 扩展蓝图编辑器工具栏/菜单（模块已依赖 `ToolMenus`，见 `AngelscriptEditor.Build.cs:45`，并已有扩展先例 `ScriptEditorMenuExtension.cpp`）。
- 入口可见性：`Cast<UASClass>(Blueprint->ParentClass) != nullptr`（镜像 handler 的 `CanNavigateToClass` 判定）。
- 执行：调用现有 `FAngelscriptSourceCodeNavigation::NavigateToClass(ParentClass)`（或 `FSourceCodeNavigation::NavigateToClass`，二者都会落到我们的 handler）。

为什么用自有入口而非"修复引擎按钮"：引擎工具栏的 native 门控在引擎源内，本仓库无法直接改；新增自有入口绕开门控、稳健且可控。

## 待实现时确认的点

1. **引擎门控的确切形态**：是"对非 native 父类隐藏按钮"(则必须新增自有入口) 还是"显示但调用前短路"(可能复用引擎按钮)。实现时通过实际操作 AS 父类蓝图观察按钮状态来确定 —— 无论哪种，新增自有入口都成立，故不阻塞。
2. **headless 行号填充**：`#ue57-headless` 下类/属性行号可能未填充；测试用 production-like fixture 或针对确实填充的 function/class 导航。
3. **`code` 不在 PATH**：`OsExecute` 失败是静默的（既有行为，非本 change 回归），在文档/日志中提示即可。

## 测试策略

- 复用 `AngelscriptSourceCodeNavigation.h` 的测试接缝（`SetOpenLocationOverrideForTesting` / `NavigateToClassForTesting` 类）断言"AS 父类 → 正确 path:line"，不真正拉起 VS Code。
- 测试层：Editor（`AngelscriptEditor/Tests/`），文件名以 `Angelscript` 前缀开头。
- 参考既有 `AngelscriptSourceNavigationTests.cpp`（已断言 path + 行号）。

## 关键文件

| 文件 | 角色 |
|---|---|
| `AngelscriptEditor/EditorMenuExtensions/ScriptEditorMenuExtension.cpp` | 新增工具栏入口（复用现有 UToolMenus 范式 + NavigateToClass） |
| `AngelscriptEditor/SourceNavigation/AngelscriptSourceCodeNavigation.cpp/.h` | 复用导航 handler + VSCode 打开 + 测试接缝 |
| `AngelscriptEditor/Core/AngelscriptEditorModule.cpp` | handler 注册点（参考，通常无需改） |
| `AngelscriptEditor/Tests/Angelscript*Tests.cpp`（新增） | 回归测试 |
