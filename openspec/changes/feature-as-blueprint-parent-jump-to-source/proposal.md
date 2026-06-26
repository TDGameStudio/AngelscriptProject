## Why

蓝图编辑器右上角的"在 IDE 中打开父类源码"按钮，对 C++ 父类可跳转到 IDE，但当蓝图的父类是 Angelscript 类时点击无效。根因：引擎只对 `CLASS_Native` 父类启用该按钮，而 AS 生成类标记为 `CLASS_CompiledFromBlueprint`，引擎因此从不调用我们已注册的 `ISourceCodeNavigationHandler`。能力其实已齐备（源文件路径+行号数据、VSCode 打开逻辑、navigation handler 均已存在），缺的只是 UI 接入。

## What Changes

- 在 AngelscriptEditor 模块中，为蓝图编辑器工具栏增加一个自有入口（通过 `UToolMenus`），当当前蓝图的 `ParentClass` 是 `UASClass`/`UASStruct` 时可见/启用。
- 点击时复用已有的 `FAngelscriptSourceCodeNavigation::NavigateToClass`（或 `FSourceCodeNavigation::NavigateToClass(ParentClass)`），将 AS 父类解析到 `path:line` 并在 VS Code 中打开。
- 不新增源码定位管线，不改 AS 编译流程 —— 仅接线现有能力。

### 与已有 change 的区别

`fix-as-blueprint-parent-picker-hidden-script-class` 处理的是父类**选择器/下拉**中 AS 类的可发现性（创建时能否选为父类）。本 change 处理的是**已设定 AS 父类后的跳转到源码**（右上角 IDE 按钮）。两者 UI 面不同、引擎接缝不同，互相独立。

## Capabilities

### New Capabilities
- `as-blueprint-parent-source-navigation`: 从蓝图编辑器将 Angelscript 父类导航到其 `.as` 源文件对应行号，并在外部编辑器（VS Code）中打开。

### Modified Capabilities
（无既有规格被修改。）

## Impact

- 主要改动模块：`Plugins/Angelscript/Source/AngelscriptEditor`（submodule 内）。
- 复用文件：
  - `AngelscriptEditor/SourceNavigation/AngelscriptSourceCodeNavigation.cpp/.h`（已实现 handler + `OpenVsCode`/`OpenModule`）
  - `AngelscriptEditor/EditorMenuExtensions/ScriptEditorMenuExtension.cpp`（已有 UToolMenus 扩展 + `NavigateToClass` 用法范式）
  - `AngelscriptEditor/Core/AngelscriptEditorModule.cpp:815`（handler 注册点）
- 数据来源（只读引用）：`ASClass.h:193-194`（`GetSourceFilePath`/`GetSourceLineNumber`）、`AngelscriptEngine.h`（`FAngelscriptClassDesc::LineNumber`）。
- 风险/不确定：引擎工具栏对 native 父类的精确门控逻辑无法读到（引擎源未 vendored），需在实现时确认是"按钮隐藏"还是"调用前短路"，以决定是新增自有入口（推荐，稳健）还是复用引擎按钮。headless 模式下类/属性行号可能未填充（`#ue57-headless`），测试应针对在编辑器内确实填充的 function/class 导航或用 production-like fixture。
