# UE 脚本宿主边界与 AngelScript Target-Independent AOT 调研附件

## 1. 目的与当前判断

本附件记录 2026-08-22 围绕以下问题进行的讨论和源码调研：

1. Unreal Python 是否只能用于编辑器；
2. UE 自带 Editor Utility 以及本地 `Reference/` 中 Lua、JavaScript、C#、Cling、daScript、Luau 等方案如何隔离 Editor、Development 和 Runtime；
3. AngelScript 如果禁止 `#if EDITOR`、`#if TEST`、`#if RELEASE` 等目标条件预处理，编辑器工具和不发布的开发代码应当如何组织；
4. 当前 AST AOT 为 EditorDevelopment、GameDevelopment、GameShipping 生成三套代码的问题能否收敛。

当前研究判断（不是实施决策）：

> UE 脚本方案经常使用宿主/模块隔离，但 Hazelight 商业项目也大量在普通 Runtime Actor/Component 内使用局部 `#if EDITOR`、`#if TEST` 和 `#if EDITORONLY_DATA`。本轮最新方向不要求 `Editor/Dev` 目录承担编译语义：让 ED/GD/GS 分别产生可信的 sealed Canonical Typed AST，以稳定语义锚点直接对齐模块、类型、初始化和函数子树，再只为实际不同的语义/原生变体生成 Guarded C++ Body。三个 UE Target 的原生二进制、Profile Catalog、Native Environment 和 ABI 身份仍需精确区分。

本附件早期章节曾把“禁止全部用户 Target Conditional”列为候选边界；对本机 `Reference/myas` 中双人成行和双影奇境脚本进行实证审计后，该候选已被否定。第 14～16 节保留了讨论如何从目录/Source Scope 逐步转向 Profile Variant Group 的过程；第 17 节记录查看新 Canonical AST worktree 后的最新修正，并覆盖其中关于强制目录划分的建议。当前 OpenSpec 不批准或实施任何变化。

## 2. Knot 中 UE 原生宿主模型

按照 `Documents/Guides/UE_Search_Guide.md`，本次首先通过 Knot 查询 UE5-main 知识库：

- knowledge UUID：`d890d83194b04c8aad24d0e904cdb762`
- code domain：`UnrealEngine@UnrealEngine-ue5-main`

### 2.1 `EHostType` 是 UE 的正式隔离层

Knot 返回 `Engine/Source/Runtime/Projects/Public/ModuleDescriptor.h::EHostType::Type` 和 `Engine/Source/Runtime/Projects/Private/ModuleDescriptor.cpp::FModuleDescriptor::IsLoadedInCurrentConfiguration`。相关宿主类型包括：

- `Runtime`：除 Program 外的普通目标；
- `RuntimeNoCommandlet`：不在 Editor Commandlet 中加载；
- `CookedOnly`：只在 Cooked Game 中加载；
- `UncookedOnly`：只在未 Cook 环境加载；
- `DeveloperTool`：在启用 Developer Tools 的目标中加载；
- `Editor`：只在编辑器启动时加载；
- `EditorNoCommandlet`：编辑器可用，但 Commandlet 不加载；
- `EditorAndProgram`、`Program`；
- `ServerOnly`、`ClientOnly`、`ClientOnlyNoCommandlet`。

UE 源码注释还说明旧 `Developer` 类型因为语义模糊而不推荐继续使用：

- 未 Cook 功能使用 `UncookedOnly`；
- 可以存在于开发目标但不应发布的调试工具使用 `DeveloperTool`。

这说明 UE 自己没有把 Editor/Developer 视为普通运行时布尔条件，而是把它们作为模块的宿主能力和加载范围。

### 2.2 Unreal Python 是 Editor Scripting，而不是游戏 Runtime 语言

Epic 官方文档明确说明 Python 环境只能用于 Unreal Editor，不能在 PIE、Standalone Game 或 Cook 后的可执行程序中使用：

- <https://dev.epicgames.com/documentation/en-us/unreal-engine/scripting-the-unreal-editor-using-python>

Knot 查询 `PythonScriptPlugin` 还返回：

- `Engine/Plugins/Experimental/PythonScriptPlugin/Source/PythonScriptPlugin/Private/PythonScriptPlugin.cpp::FPythonScriptPlugin::StartupModule`
- Editor Python 执行入口通过 `FEditorPythonExecuter::OnStartupModule()` 等 Editor 条件注册。

因此 Python 的“简单”来自它完全不进入游戏 Runtime/Cook/AOT，而不是它解决了一个脚本同时服务三个静态目标的问题。

### 2.3 Editor Utility Blueprint 同样采用 Editor 宿主边界

Knot 查询 `Blutility`、`EditorUtilitySubsystem`、`EditorUtilityWidget` 返回：

- `Engine/Source/Editor/Blutility/Private/BlutilityModule.cpp::StartupModule`
- `Engine/Source/Editor/Blutility/Private/EditorUtilitySubsystem.cpp`
- `Engine/Source/Editor/Blutility/Private/EditorUtilityWidgetBlueprint.cpp`

这些实现依赖 Level Editor、Editor World、Tab Manager、编辑器菜单和内容浏览器，并由 Editor 模块注册。Editor Utility Widget 创建的是编辑器 Tab，不是普通游戏 Widget。

官方入口：

- <https://dev.epicgames.com/documentation/en-us/unreal-engine/scripting-the-unreal-editor-using-blueprints>
- <https://dev.epicgames.com/documentation/en-us/unreal-engine/scripted-actions-in-unreal-engine>

`CallInEditor` 只提供编辑器调用入口。它不会使函数自动变成 Editor-only，也不会从 Shipping 中剥离函数。

## 3. 本地 Reference 脚本插件对比

### 3.1 UE Module 清单

| 方案 | Runtime 模块 | Editor/Tool/Program 模块 | 观察 |
|---|---|---|---|
| UnLua | `UnLua` Runtime | `UnLuaEditor` Editor；`UnLuaDefaultParamCollector` Program | Lua 执行与模板/智能提示导出分开 |
| slua_unreal | `slua_unreal` Runtime | `slua_profile` Editor | Profiler 是单独 Editor 模块 |
| Puerts | `WasmCore`、`JsEnv`、`Puerts` Runtime | `DeclarationGenerator`、`PuertsEditor` Editor；`ParamDefaultValueMetas` Program | JS VM、声明生成和离线工具分开 |
| UnrealCSharp | `UnrealCSharp`、`UnrealCSharpCore`、`CrossVersion` Runtime | `UnrealCSharpEditor`、`ScriptCodeGenerator`、`Compiler` Editor；`SourceCodeGenerator` Program | Managed Runtime 与 Editor 编译/生成工具分开 |
| UECling | `ClingRuntime`、`ClingScript` Runtime | `ClingEditor`/`ClingLoadModule` Editor；`ClingKismet` UncookedOnly；`ClingSourceAccess` DeveloperTool | 最接近完整 UE Host Scope 模型 |

证据文件：

- `Reference/UnLua/Plugins/UnLua/UnLua.uplugin`
- `Reference/sluaunreal/Plugins/slua_unreal/slua_unreal.uplugin`
- `Reference/puerts/unreal/Puerts/Puerts.uplugin`
- `Reference/UnrealCSharp/UnrealCSharp.uplugin`
- `Reference/UECling/UECling.uplugin`

### 3.2 Module 分离不等于用户脚本自动不进包

UnLua 文档说明普通 Lua Module 位于项目 `Content/Script`：

- `Reference/UnLua/Docs/CN/UnLua_Programming_Guide.md`

FAQ 又要求把 Script 目录加入 `Additional Non-Asset Directories to Package`：

- `Reference/UnLua/Docs/CN/FAQ.md`

因此 UnLua 的 C++ Runtime/Editor 模块边界不会自动替用户脚本决定 Shipping 打包集合。Lua/JS 动态语言通常把源码/字节码打包交给项目配置，并在运行时 VM 中加载。AngelScript 不能只复制这种做法，否则 Editor/Dev `.as` 仍可能被物理发布，只是在运行时不编译。

本次还观察到多个参考插件的 Runtime `Build.cs` 会在 `Target.bBuildEditor` 时条件加入 `UnrealEd`。这能工作，但属于宿主边界泄漏，不适合作为 Static AOT 的理想模型。AS 应在 Source Scope/Sema 层阻止 Runtime 模块引用 Editor 能力。

### 3.3 普通 Lua/JS 用户源码没有 UE 目标预处理模型

在 UnLua、slua 和 Puerts 的普通用户 Lua/JS 示例中，没有发现一套与 UE `#if WITH_EDITOR` 对等的通用用户语言机制。Puerts 工具脚本中出现的 `#if` 主要是生成 C/C++ 适配源码的字符串，并不是游戏 JS 的目标条件语义。

这进一步说明：这些语言靠 VM、Host API 和 Packaging 分层，不靠用户脚本预处理器形成三套 AST。

## 4. daScript 与 Luau 的边界

### 4.1 daScript `static_if` 是编译期语义，不是 UE Host Scope

daScript 大量使用：

```das
static_if (typeinfo can_copy(...))
static_if (typeinfo sizeof(...) == 4)
static_if (typeinfo builtin_module_exists(...))
```

典型位置：

- `Reference/daScript/daslib/builtin.das`
- `Reference/daScript/daslib/ast.das`
- `Reference/daScript/tests/language/static_if.das`

它适合类型能力、泛型实例和可选模块选择，但如果用 `static_if (EDITOR)` 或 `static_if (SHIPPING)`，仍会产生不同的语义树。它只是把文本预处理升级为语言级静态分支，没有消除多目标 AST。

daScript 还允许：

```das
options no_aot
```

编译器反射、调试器或无法稳定链接的模块可以退回解释执行。这说明 Editor 工具可以拥有 VM-only 逃生口，但不能用它替代 Runtime AOT 的正确作用域。

### 4.2 Luau 通过运行时 VM/Native CodeGen 避开预生成矩阵

Luau 主要交付字节码 VM，并可在运行时生成原生代码；宿主通过 environment/sandbox 决定可见 API。它没有提前为 UE EditorDevelopment、GameDevelopment、GameShipping 保存三棵静态 C++ 代码树，因此没有当前 AS Static AOT 的同类文件复制问题。

这种简化来自把代码生成推迟到运行时，不能直接套到必须由 UBT 编译和链接的 AS Static AOT Provider 上。

## 5. 当前 AngelScript 证据

### 5.1 预处理上下文使源语义依赖目标

`Plugins/Angelscript/Source/AngelscriptRuntime/Preprocessor/AngelscriptPreprocessor.cpp` 中的 `CreateFromCurrentEngineContext()`建立：

- `EDITOR`
- `EDITORONLY_DATA`
- `COOK_COMMANDLET`
- `RELEASE`
- `TEST`
- `WITH_SERVER_CODE`

同文件后部解析 `#ifdef/#ifndef/#if/#elif/#else/#endif`，并把 `#if EDITOR` 区域转成 Editor-only line range。`Macro.bEditorOnly` 又给 UFUNCTION/UPROPERTY 描述符加入 `EditorOnly` Metadata。

因此当前 `#if` 不只是删除普通语句，还会改变：

- 类型和成员是否存在；
- UClass/UFunction/UProperty 反射形状；
- 模块 Import 和依赖；
- 生成函数内容；
- Cache/StaticJIT execution/debug/ABI identity。

### 5.2 当前 `Dev` 不是 GameDevelopment Scope

`Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptSourceProvider.cpp` 会在 `bSkipDevelopmentScripts` 时跳过 `Examples` 和 `Dev`，在 `bSkipEditorScripts` 时跳过 `Editor`。

但 `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.cpp` 当前设置：

```cpp
const bool bSkipDevelopmentScripts = !ShouldUseEditorScripts();
const bool bSkipEditorScripts = bSkipDevelopmentScripts;
```

所以 `Dev` 的实际范围是 EditorDevelopment，而不是：

```text
EditorDevelopment + GameDevelopment - GameShipping
```

这正是新 Source Scope 必须修正的行为。

### 5.3 已有 Editor-only Sema 基础

`AngelscriptEngine.cpp` 根据模块名 `Editor.*` 或 `.Editor.` 设置 `isEditorOnlyModule`。维护 fork 的 `as_builder.cpp` 将 Editor-only 属性传播到类型、全局、属性和函数，并阻止非 Editor-only 代码引用它们。

因此新方案不是从零开始，而是把：

```text
bool isEditorOnlyModule + #if 行范围
```

扩展为：

```text
SourceScope + HostCapability + 稳定依赖检查
```

### 5.4 `CallInEditor` 与 Editor-only 是不同概念

`AngelscriptPreprocessor.cpp` 已解析 `CallInEditor` UFUNCTION Specifier，但该 Specifier只控制反射入口，不控制：

- 源码是否进入 Game/Shipping；
- 函数能否调用 Editor API；
- AOT 是否生成；
- Cook 是否剥离。

因此 Runtime-safe 且允许留在 Shipping 的按钮函数可以继续位于 Runtime；真正调用 Editor API 或必须不发布的实现必须移到 Editor Source Scope。

### 5.5 `EDITORONLY_DATA` 需要声明级替代品

普通 Editor 行为可以移动到 Editor companion module，但 Runtime UObject 上的 Editor-only data 可能必须保留同一类型所有权。当前实现主要从 `#if EDITORONLY_DATA`/Editor-only block 推导 metadata，没有完整的显式 `UPROPERTY(EditorOnlyData)` 用户契约。

新方案将它定义为 Canonical AST 中存在、只在 Editor-only-data UE 布局中 materialize 的声明，而不是预处理前被删除的节点。

## 6. 三套 Static AOT 的实际差异

当前 Profile 定义位于：

- `Plugins/Angelscript/Source/AngelscriptRuntime/StaticJIT/AngelscriptJITGeneration.h`
- `Plugins/Angelscript/Source/AngelscriptRuntime/StaticJIT/AngelscriptJITGeneration.cpp`

精确编译 Guard：

```text
EditorDevelopment = WITH_EDITOR && UE_BUILD_DEVELOPMENT
GameDevelopment   = !WITH_EDITOR && UE_BUILD_DEVELOPMENT
GameShipping      = !WITH_EDITOR && UE_BUILD_SHIPPING
```

Traits：

| Profile | Editor | EditorOnlyData | Test | Release | Cooked Binds | Dev Scripts | Editor Scripts |
|---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| EditorDevelopment | yes | yes | yes | no | no | yes | yes |
| GameDevelopment | no | no | yes | no | yes | intended yes | no |
| GameShipping | no | no | no | yes | yes | no | no |

实际比较同一 `Test_Enums` 模块的 GameDevelopment 与 GameShipping 生成源码发现：

- Profile metadata、Native Environment fingerprint、Execution/Debug/Entry ABI Hash 不同；
- 生成符号携带 Execution Hash，因此不同；
- Development 包含 safe-point/SUSPEND 路径，Shipping 省略；
- 核心算术/控制函数体其余部分相同。

这说明能够合并的是“语义 Body”，不能合并的是“原生 Profile 身份和最终机器码策略”。

## 7. 讨论过的三个方案

### 方案 A：保留条件预处理和三套完整生成

优点：与当前行为兼容，目标正确性最直接。

缺点：

- 三次预处理/类型检查；
- 三种声明和反射世界；
- 三套 Generated Source；
- Cache V2、Hot Reload、Debugger、Coverage、StaticJIT 都要理解三种语义图；
- 条件宏会继续扩散。

结论：不采用。

### 方案 B：改成运行时 `if (IsEditor())`

优点：表面只有一份 AST。

缺点：

- Editor-only 类型和符号仍进入 Runtime 链接；
- Editor-only 数据仍可能序列化/Cook；
- Dead Code Elimination 不能替代 UClass/reflection/package 边界；
- 无法静态阻止 Shipping 资产引用 Editor 类型。

结论：不采用。

### 方案 C：Source Scope + Canonical AST + Thin Profile

优点：

- 用户脚本没有目标条件分支；
- Runtime/Development/Editor 依赖可以静态验证；
- Runtime Semantic Body 一次生成，Development Body 被两个开发 Profile 复用；
- Editor/Dev 源码可以从不拥有它们的包中物理排除；
- Profile ABI/Native Environment/Provider Route 仍然精确；
- 将来可以在同一 capability 模型上扩展 Server/Client。

结论：作为后续研究的候选方向，尚未定案。

## 8. 候选用户源码组织

```text
Script/
├── Gameplay/
│   ├── InventoryComponent.as          # Runtime
│   └── InventoryService.as            # Runtime
├── Dev/
│   ├── InventoryDebugCommands.as      # Development
│   └── ReplicationDiagnostics.as      # Development
└── Editor/
    ├── InventoryAssetTools.as         # Editor
    └── InventoryAuditSubsystem.as     # Editor
```

依赖方向：

```text
Editor -> Development -> Runtime
Editor ----------------> Runtime
```

禁止：

```text
Runtime -> Development
Runtime -> Editor
Development -> Editor
```

Runtime 对象需要编辑器功能时，使用 Editor Subsystem、Editor Utility、Mixin/Extension、Asset Action 或 companion function 接收 Runtime 对象，不在 Runtime 类内条件增加成员。

## 9. 候选 AOT/Cache 身份分层

```text
AS Source
  -> Scope-aware canonical Parser/Sema/AST
  -> SemanticBodyHash（Target-independent）
  -> 共享 module body source
  -> EditorDevelopment / GameDevelopment / GameShipping profile shell
  -> 各自 Native Environment / ABI / Execution Hash / Provider catalog
```

语义层：

```text
SemanticBodyHash
= Canonical AST
+ SourceScope
+ stable semantic dependencies
+ backend semantic version
```

可执行 Profile 层：

```text
ProfileBindingHash
= SemanticBodyHash
+ ArtifactProfileKey
+ NativeEnvironmentFingerprint
+ EntryAbiRevision
+ ProfilePolicyDigest
+ stable reference ABI digests
```

Cache V2 不得跨 Profile 恢复 bytecode/native executable payload。只有完全相同的 target-independent semantic record/AST sidecar 可以按完整 Hash 去重或复用。

## 10. 若采用候选方向时的迁移映射

| 旧写法 | 新写法 |
|---|---|
| `#if EDITOR` 包围整个类/函数 | 移入 `Script/Editor` companion module |
| `#if TEST` 包围开发诊断 | 移入 `Script/Dev` 或测试专属 source scope |
| `#if RELEASE` 改变 Gameplay 行为 | 保持一个 Runtime 语义，通过运行时配置表达；仅非发布工具移入 Dev |
| `#if EDITORONLY_DATA` 属性 | `UPROPERTY(EditorOnlyData)` |
| Runtime 类函数调用 Editor API | Editor companion/subsystem 接收 Runtime 对象 |
| `CallInEditor` 被当作 Editor-only | 只保留为调用入口；实现仍必须满足所在 Source Scope |
| `EditorContext` 被当作编译 Guard | 只用于 Automation 执行选择；Editor 类型放 Editor 源文件 |
| 三套完整 `.jit.cpp` | 一套 scoped body + 三套薄 Profile catalog/wrapper |

## 11. 讨论中的 V1 候选边界（未定案）

- 禁止：`#if/#ifdef/#ifndef/#elif/#else/#endif`。
- 保留：`#include`、自动 Import、UE Reflection Descriptor Processing。
- Source Scope：Runtime、Development、Editor。
- `Dev`：EditorDevelopment + GameDevelopment，不进入 GameShipping。
- `Editor`：只进入 EditorDevelopment。
- 同一 Runtime 类型的唯一 V1 Editor 声明例外：显式 `EditorOnlyData` 属性。
- 仍然生成三个 UE Target 二进制和精确 Profile Catalog。
- 不生成三份 AS Semantic AST/Body。
- ServerOnly、ClientOnly、UncookedOnly、Program 属于后续独立扩展。

## 12. daScript `static_if` 的实现与 AOT 影响

### 12.1 一句话结论

`static_if` 与 daScript AOT 是直接兼容的，而且它会影响 AOT：编译器在语义推导早期只保留被选中的分支，AOT C++ 只看到这个最终分支，未选分支不会生成代码，也不会作为函数依赖进入 AOT Hash。

但它并不会自动消除多目标 AOT。如果条件取决于平台、构建参数、环境变量、可用原生模块或 Editor/Shipping Profile，那么同一源码在不同编译环境中仍会得到不同的最终 AST、函数依赖、Semantic/AOT Hash 和 C++ 产物。换句话说，daScript 支持的是“对当前编译环境做静态特化”，不是“一份 AOT 同时包含所有环境”。

### 12.2 Parser：普通 `if` 节点加一个 `isStatic` 位

daScript V2 Grammar 在以下位置声明和解析 `static_if` / `static_elif`：

- `Reference/daScript/src/parser/ds2_parser.ypp:180`
- `Reference/daScript/src/parser/ds2_parser.ypp:193`
- `Reference/daScript/src/parser/ds2_parser.ypp:901`
- `Reference/daScript/src/parser/ds2_parser.ypp:916`
- `Reference/daScript/src/parser/ds2_parser.ypp:930`
- `Reference/daScript/src/parser/ds2_parser.ypp:1004`

Parser 不创建单独的 StaticIf AST 类型，而是创建普通 `ExprIfThenElse`，再设置：

```cpp
auto eite = new ExprIfThenElse(...);
eite->isStatic = true;
```

AST 定义位于 `Reference/daScript/include/daScript/ast/ast_expressions.h:1353` 附近：

```cpp
struct ExprIfThenElse : Expression {
    ExpressionPtr cond, if_true, if_false;
    union {
        struct {
            bool isStatic : 1;
            bool doNotFold : 1;
        };
        uint32_t ifFlags = 0;
    };
};
```

因此两个分支都会先通过 Grammar，未选分支至少必须是语法合法的 daScript；这不同于文本预处理器可以在 Parser 之前完全隐藏一段文本。

### 12.3 Infer：先推导条件，暂时不访问两个分支

`ExprIfThenElse::visit()` 位于 `Reference/daScript/src/ast/ast.cpp:2412`。它的顺序是：

1. 调用 `preVisit(this)`；
2. 访问 `cond`；
3. 仅在 `canVisitIfSubexpr(this)` 返回 true 时访问 `if_true` 和 `if_false`；
4. 调用最终 `visit(this)`。

`InferTypes::canVisitIfSubexpr()` 位于 `Reference/daScript/src/ast/ast_infer_type.cpp:4730`：

```cpp
return !expr->isStatic;
```

所以 `static_if` 第一次推导时只解析条件的语义，两个分支都不会进入正常的名称解析和类型推导。`preVisit()` 又会为 `static_if` 强制打开 infer-time folding，即使 lint policy 或源码选项关闭了一般折叠也一样。

这不是“先检查两个分支，再做 dead-code elimination”。daScript 的测试直接固定了该语义：

- `Reference/daScript/tests/language/optional_require.das:31`
- `Reference/daScript/tests/language/optional_require.das:34`

测试在恒假分支中调用一个不存在的符号，并注明该分支会在 name resolution 之前被删除。

### 12.4 Fold：条件必须是编译期常量，节点被替换成单个分支

`InferTypes::visit(ExprIfThenElse*)` 位于 `Reference/daScript/src/ast/ast_infer_type.cpp:4764`。核心逻辑是：

```cpp
if ((enableInferTimeFolding && !expr->doNotFold) || expr->isStatic) {
    if (auto constCond = getConstExpr(expr->cond)) {
        reportAstChanged();
        auto condR = static_cast<ExprConstBool *>(constCond)->getValue();
        return condR ? expr->if_true : expr->if_false;
    } else if (expr->isStatic) {
        error("static_if must resolve to constant", ...,
              CompilationError::invalid_static_if_condition);
    }
}
```

结果不是在 AST 中留下一个带常量条件的 `if`，而是用所选分支替换整个 `ExprIfThenElse`。`reportAstChanged()` 促使后续推导轮次继续分析刚刚选中的分支；未选分支从最终语义树中消失。

这让它可以安全表达两类常见特化：

- 类型/泛型特化：`static_if (typeinfo can_copy(T))`；
- 能力/模块特化：`static_if (typeinfo builtin_module_exists(foo))`。

无法折叠成布尔常量的运行时条件会产生 `invalid_static_if_condition`，不能退化成普通 `if`。

### 12.5 AOT：没有 `if constexpr`，因为静态分支此前已经消失

daScript 的 C++ AOT 生成器本身写在 `Reference/daScript/daslib/aot_cpp.das` 中：

- `compile_and_simulate()`：`aot_cpp.das:4386`；
- `run_aot()`：`aot_cpp.das:4426`；
- `aot()`：`aot_cpp.das:4596`。

流程是先 `compile_file()`，再 `simulate()`，最后让 `CppAot` Visitor 访问已经完成推导/折叠的 `Program`。AOT Visitor 对仍然存在的 `ExprIfThenElse` 只会输出普通 C++ `if`：

- `preVisitExprIfThenElse()`：`aot_cpp.das:2847`；
- `visitExprIfThenElse()`：`aot_cpp.das:2875`。

这里没有检查 `isStatic`，也没有输出 C++ `if constexpr`。原因是合法 `static_if` 在 Infer 阶段就已经被替换掉；抵达 AOT Visitor 的通常是运行时 `if`。

最终效果：

```text
源代码 static_if
  -> Parser: ExprIfThenElse(isStatic=true)，暂存两个语法分支
  -> Infer: 只分析 condition
  -> Const fold: 整个节点替换为 true 或 false 分支
  -> 再次 Infer: 只分析所选分支
  -> Simulation / AOT: 只存在所选分支
```

### 12.6 对 Semantic/AOT Hash 的影响

daScript 在链接 AOT 时先根据最终 `SimNode` 计算 `Function::hash`，再调用 `getFunctionAotHash()`：

- `Reference/daScript/src/ast/ast_simulate.cpp:4162`
- `Reference/daScript/src/ast/ast_simulate.cpp:4168`
- `Reference/daScript/src/simulate/simulate_fn_hash.cpp:229`

`getFunctionAotHash()` 将当前函数 Hash 和稳定收集到的非 Builtin 函数依赖 Hash 合成最终 AOT Hash。因为未选分支已经不在最终 AST/SimNode 中：

- 未选分支的代码不会进入当前函数的最终 Simulation Hash；
- 未选分支独有的函数调用不会进入 DependencyCollector；
- 如果两个编译环境选择了不同且语义不同的分支，函数 Hash、依赖集合或两者通常会改变，AOT Hash 随之改变；
- 如果两个分支折叠后碰巧产生完全相同的最终语义和依赖，则不能仅凭“选择过不同分支”断言 Hash 必然不同。

运行时 AOT Library 用这个 Hash 查找已注册实现；找不到时的诊断会明确提示 AOT artifact 已过期，需要重新生成。因此 `static_if` 的选支结果属于 AOT 有效性的一部分，而不是链接后的运行时开关。

### 12.7 平台和构建环境会被明确烘焙

daScript 对“编译时平台”和“运行时平台”做了有意区分：

- `get_platform_name()` 注册为 `SideEffects::none`，允许编译期折叠；
- `get_cross_platform_name()` 同样允许折叠，用于交叉编译目标；
- `get_running_platform_name()` 注册为 `SideEffects::accessExternal`，故意禁止折叠；
- `cpu_supports()` 也禁止折叠，避免把构建机器 CPU 能力写入跨机器 AOT。

证据位于 `Reference/daScript/src/builtin/module_builtin_runtime.cpp:2846-2870`。源码注释直接给出 `static_if` 根据 Emscripten 目标删除 Desktop-only OpenGL 符号分支的例子。

更直接的证据在：

- `Reference/daScript/daslib/build_const.das:7-17`
- `Reference/daScript/tests/daslib/build_const_test.das:2`

`build_const` 将 daslang 进程的命令行和环境变量在编译时变成字面量，文档明确说明 `-exe` 会在构建时烘焙常量。对应测试使用 `options no_aot`，注释说明 AOT artifact 会按设计烘焙 Builder Environment，换环境运行可能不同步。

`daslang -aot` 设置 `tune_frozen = true`，用于避免把每台构建机器的 `[tune]` 调优 stamp 写进跨机器产物；这只冻结性能调优输入，不会把平台/构建常量驱动的 `static_if` 重新变成目标无关代码。

### 12.8 与 AngelScript `#if` 的本质对比

| 维度 | AngelScript 当前 `#if` | daScript `static_if` |
|---|---|---|
| 发生阶段 | Parser/Sema 之前的 Host 预处理 | Parser 之后、分支 Sema 之前 |
| AST 表示 | 未选文本通常不进入 AST | 先建 `ExprIfThenElse(isStatic)`，随后替换为单分支 |
| 未选分支要求 | 取决于预处理器，通常可完全不参与语法解析 | 必须语法合法，但不做正常名称/类型解析 |
| 条件能力 | 预处理 Flag / 简单表达式 | 常量表达式、`typeinfo`、类型能力、模块存在性、Build Const |
| 未选符号 | 被文本裁掉 | 在名称解析前被语义裁掉 |
| AOT 结果 | 预处理后的 AST 对应一个目标产物 | 折叠后的 AST 对应一个特化产物 |
| 多目标影响 | Target Flag 不同时形成多种 AST/AOT | 静态条件环境不同时仍形成多种 AST/AOT |

所以 daScript 值得借鉴的不是“用 `static_if` 消灭三套 AOT”，而是以下编译器结构：

1. 把静态选择变成 AST 中有明确语义的节点，而不是不可见的文本删除；
2. 在未选分支名称/类型解析之前完成裁剪，从而支持能力检测和泛型特化；
3. 让最终 AST、依赖和 AOT Hash 自然反映选支结果；
4. 明确区分可折叠的编译时环境查询与必须保留到运行时的环境查询。

如果 AngelScript 只是把：

```text
#if EDITOR
```

改写成：

```text
static_if (EDITOR)
```

那么编译器可观察性和诊断会更好，但 `EditorDevelopment`、`GameDevelopment`、`GameShipping` 仍可能拥有不同的最终语义树和 AOT Hash，当前“三套完整代码”的根因并未消失。

### 12.9 对当前 AngelScript 研究方向的含义

当前可以把问题拆成两类，而不是期待一个 `static_if` 同时解决：

1. **类型/能力静态特化**：可以研究 daScript 风格的语义级 `static_if`。这类分支通常属于同一语言语义中的模板/泛型实例化，AOT 为每个有效实例生成特化实现是合理的。
2. **UE Host/Package 可用性**：Editor、Development、Runtime 更适合由 Source Scope、模块依赖和打包集合表达。若用 `static_if(EDITOR)` 表达，它仍会制造 Profile-specific AST，并可能让同一 Runtime 类型拥有不同反射形状。

因此本轮研究结论是：daScript 证明了“静态分支可以很好地进入 AOT”，但也证明“构建环境驱动的静态分支会被 AOT 烘焙”。它可以作为 AngelScript 未来语言级特化功能的参考，不能单独作为三套 UE Target AOT 合并方案。

## 13. 对 AngelScript 的具体建议：Scope 隔离，共享 Body，薄 Profile

本节记录 2026-08-22 后续讨论形成的当前建议，仍属于研究判断，不是已批准实施规格。

### 13.1 推荐结论

建议采用以下组合，而不是单独依赖 `static_if`：

1. Editor AngelScript 统一放入 Editor Source Scope，默认目录为 `Script/Editor/**`；
2. Development-only AngelScript 统一放入 Development Source Scope，默认目录为 `Script/Dev/**`；
3. 其他正式游戏脚本属于 Runtime Source Scope；
4. Runtime AS 不允许引用 Editor 或 Development AS 模块，也不允许引用 Editor-only / Development-only C++ Binding；
5. Editor 和 Development AOT 可以在生成的 C++ 层按整个模块/Translation Unit 做编译 Guard；
6. Runtime Semantic Body 只生成一份，Editor/Development 模块也各自只生成一份 scoped body；
7. EditorDevelopment、GameDevelopment、GameShipping 仍保留各自的薄 Provider Catalog、Artifact Profile、Native Environment 和 ABI 身份；
8. 语言级 `static_if` 只用于类型、泛型和稳定能力特化，不用于 `EDITOR`、`SHIPPING` 等 UE Target 选择。

目标源码集合矩阵是：

| Source Scope | EditorDevelopment | GameDevelopment | GameShipping |
|---|:---:|:---:|:---:|
| Runtime | yes | yes | yes |
| Development | yes | yes | no |
| Editor | yes | no | no |

目录是默认分类入口，不应是唯一语义来源。Memory Source、插件 Source 和生成 Source 仍需要显式 Scope；同一个逻辑 AS Module 不允许跨多个 Scope 拼接。

### 13.2 Editor AOT 可以使用 `#if WITH_EDITOR`，但只应出现在生成 C++ 边界

Editor AS 模块的 AOT 可以整体生成到 Editor-scoped C++ 文件，并在文件内容、包含的 Editor Headers、函数实现和注册表外层统一包裹：

```cpp
#if WITH_EDITOR
// Editor module AOT includes
// Editor module AOT functions
// Editor module provider entries
#endif
```

更理想的工程边界是把它编入 Editor-only AOT Carrier/UE Module；若为了维持一个生成源码树而仍放在同一 Carrier 中，则必须守卫整个 Translation Unit 的 Editor 内容，而不是给每个函数零散添加宏。

这里的 `#if WITH_EDITOR` 是 Backend 生成的 Native Build Guard，不是用户 AngelScript 的条件语义。它不会制造多棵用户 AST：Editor AS Module 本来就只属于 Editor Source Scope，Game/Shipping 的源码集合中不存在该模块。

建议由生成器使用自己的精确宏，例如：

```cpp
AS_WITH_EDITOR_SCRIPTS
AS_WITH_DEVELOPMENT_SCRIPTS
```

再由 Target/Profile 配置集中映射到 UE 宏。这样生成器和 Provider 不需要在多处重新解释 `WITH_EDITOR`、`UE_BUILD_SHIPPING`，也便于以后扩展 Test、Server 或 Client Scope。

### 13.3 Development 不应使用 Target-based `static_if`

如果把 Development 代码继续写在 Runtime AS 中：

```text
static_if (DEVELOPMENT) {
    ...
}
```

那么 GameDevelopment 和 GameShipping 仍会选择不同分支，产生不同的最终 AST、依赖和 AOT Hash。这最多把三种语义世界收敛成两种，不会得到一份目标无关 Runtime Semantic Body。

因此 Development-only 功能应优先直接移动到 `Script/Dev/**`：

```text
Script/Gameplay/**      Runtime
Script/Dev/**           Development
Script/Editor/**        Editor
```

对应 Development AOT 由生成的 C++ Scope Guard 整体控制：

```cpp
#if AS_WITH_DEVELOPMENT_SCRIPTS
// Development module AOT and registration
#endif
```

Runtime AS 需要给 Development 工具提供数据或操作时，应在 Runtime 定义稳定、可发布的基础能力；Development companion module 调用这些 Runtime 能力。不要让 Runtime 反向调用 Development 模块。

语言级 `static_if` 仍然值得研究，但建议限制在不会代表 UE 发布 Target 的语义中，例如：

```text
static_if (type supports copy)
static_if (generic argument has method X)
static_if (stable optional language package is available)
```

### 13.4 “C++ 里面怎么实现与 AS 无关”成立的必要条件

该判断只在 **AS 可见表面稳定** 时成立。

可以与 AS/AOT 解耦的写法是：

```cpp
// 这个 Binding 的 AS 名称、签名、调用 ABI 在所有 Target 中都存在并保持相同。
void RuntimeDiagnostics_Emit(const FRuntimeDiagnostic& Value)
{
#if !UE_BUILD_SHIPPING
    EmitDevelopmentDiagnostic(Value);
#else
    // no-op，或调用 Shipping-safe 实现
#endif
}
```

此时 AngelScript 始终看到同一个函数声明和调用 ABI，C++ 只在稳定 Thunk/Facade 后面切换实现。Runtime AS 的 AST 可以保持一致。

以下变化仍然直接影响 AS/AOT，不能认为“只是 C++ 内部宏”：

- 用宏让某个 AS Binding 在部分 Target 完全不存在；
- 改变 AS 可见函数的参数、返回值、Calling Convention 或 Entry ABI；
- 改变 AS 可见类型的大小、对齐、字段布局或生命周期约定；
- 让同一个 AS 调用在不同 Target 解析到不同 Native Function Address/Binding Kind；
- 删除 Runtime AS 依赖的 UClass、UFunction、UProperty 或反射 Metadata；
- 改变 Cooked/Editor Binding 集合而没有稳定的 Facade 契约。

这些变化都会反映到 Native Environment、Artifact Profile、Entry ABI、稳定引用或 Execution Hash，当前 Provider Matcher 也会因 Profile/Environment 不匹配而拒绝复用。

Editor API 不建议为了共享 AST 而全部伪装成 Shipping no-op Binding。这样虽然技术上可以保持签名稳定，却会把 Editor 能力暴露到 Runtime AS，弱化静态边界，并可能把不应发布的接口名称、注册信息和依赖带入游戏。Editor API 应由 Editor AS 直接调用 Editor C++ Binding；稳定 Facade 主要用于确实属于 Runtime 公共契约、但内部实现允许因构建类型优化的功能。

### 13.5 “只生成一套 AOT”的准确含义

可以做到的“一套”是：

```text
一份 Runtime Canonical AST / Semantic Body
+ 一份 Development scoped body
+ 一份 Editor scoped body
+ 一个统一的 Generated Source Tree
```

在具体 UE Target 编译时：

```text
EditorDevelopment = Runtime Body + Development Body + Editor Body
GameDevelopment   = Runtime Body + Development Body
GameShipping      = Runtime Body
```

不能合并成一个跨所有 Target 通用的最终 AOT Provider 二进制。当前 StaticJIT 已精确区分并校验：

- `ArtifactProfile`；
- `NativeEnvironmentFingerprint`；
- `EntryAbiHash`；
- `ExecutionHash` / `DebugHash`；
- Provider Artifact Set 和稳定引用。

因此仍需要按最终 Target 编译并发布不同的 Native Binary 和薄 Provider Catalog。可以减少的是 AS Parser/Sema/AOT Body Generation 的重复，以及三份几乎相同的 `.jit.cpp` Body；不能取消 UE Target 自身的 C++ 编译、链接和 Provider 身份。

一个候选生成布局是：

```text
Generated/
├── Bodies/
│   ├── Runtime/<StableModuleKey>.jit.cpp
│   ├── Development/<StableModuleKey>.jit.cpp
│   └── Editor/<StableModuleKey>.jit.cpp
└── Profiles/
    └── ProviderCatalog.cpp
```

`ProviderCatalog.cpp` 根据当前 Target 只注册该 Target 拥有的 scoped bodies，并发布当前 Target 精确的 Artifact Profile 和 Native Environment。也可以物理生成三个很薄的 Catalog；关键是不要再复制 Runtime 函数的完整实现。

### 13.6 推荐的依赖和调用方式

```text
Editor AS ───────► Editor C++ Binding
    │
    ├────────────► Development AS / Binding
    │
    └────────────► Runtime AS / Binding

Development AS ─► Development C++ Binding
    │
    └────────────► Runtime AS / Binding

Runtime AS ──────► Runtime-stable C++ Binding / Facade
```

禁止反向依赖：

```text
Runtime AS      -X-> Development AS / Binding
Runtime AS      -X-> Editor AS / Binding
Development AS  -X-> Editor AS / Binding
```

Runtime 对象需要 Editor 操作时，由 Editor companion function、Editor Subsystem、Asset Action 或 Mixin 接收 Runtime 对象，而不是在 Runtime AS 类型中增加条件成员。

### 13.7 灵活性损失与收益

确实会损失一些目标条件编程的灵活性：

- Runtime AS 不能在同一个函数里写 Editor/Shipping 静态分支；
- Runtime 类型不能随 Target 增减任意成员、方法和依赖；
- Editor/Development 逻辑需要拆成 companion module；
- 需要跨 Target 保持的调用必须经过稳定 C++ Facade，或改为 Runtime 配置；
- 真正不发布的功能必须移动到窄 Scope，不能只依赖 Dead Code Elimination。

换来的收益是：

- Runtime 只有一套 Canonical AST 和 Semantic Body；
- Cache V2、Hot Reload、Debugger、Coverage 和 AOT 不再理解多份 Runtime 声明世界；
- Shipping 不可能从 Runtime AS 静态引用 Editor/Development API；
- Editor/Development 源码和 AOT 可以从不拥有它们的包中物理排除；
- C++ 宏被限制在可审计的 Host/Backend 边界；
- Provider Profile/ABI 继续精确，正确性不会为了减少生成文件而放松。

当前推荐的取舍是接受这部分灵活性下降。对于 UE 插件化交付和 Static AOT，这种限制更接近 UE 自身的 Runtime/Editor Module 边界，也比允许 Runtime AS 随 Target 改变声明和反射形状更容易长期维护。

### 13.8 三种候选方案对比

| 方案 | Runtime AST 数量 | Shipping 剥离 | 灵活性 | 评价 |
|---|---:|---:|---:|---|
| 继续 AS `#if` + 三套完整生成 | 多套 | 强 | 最高 | 当前成本最高，不推荐 |
| Editor 目录 + Dev `static_if(DEVELOPMENT)` | Runtime 至少两套 | 强 | 较高 | 改善但没有解决目标无关 Body |
| Runtime/Development/Editor Scope + Stable C++ Facade + Thin Profile | Runtime 一套 | 强 | 中等 | 当前推荐 |

因此，对本轮问题的直接回答是：Editor 统一目录和生成 C++ Guard 是对的；Dev 不建议通过 Target-based `static_if` 处理，而应作为独立 Development Source Scope；正式 Runtime AS 只调用 Runtime-stable C++ 表面；C++ 内部可以使用宏，但不得改变 AS 可见 ABI。这样可以只维护/生成一套 Runtime AOT Body，但仍然会为不同 UE Target 编译不同的原生二进制并发布薄 Profile Catalog。

## 14. Hazelight 商业脚本实证：局部 `if editor` 不能被目录完全替代

### 14.1 审计来源和结论修正

本机存在独立 Git 仓库：

```text
Reference/myas
├── It Takes Two Script
└── Split Fiction Script
```

本次读取的本地仓库提交为：

```text
8e4e071bddd0effef8e8c3a151b70a1aa20a9ba0
```

审计结论明确否定了“把所有 Editor AS 移入 `Script/Editor`，然后禁止 Runtime AS 中的所有 `#if EDITOR`”这一强约束。两套商业项目大量在普通 Gameplay Actor、Component、Capability、ConstructionScript 和 Tick 中插入局部 Editor 条件；很多条件还会改变 Runtime 类型的成员、默认组件和 Editor-only data。

因此，第 13 节是审计前的候选方案；本节是基于真实项目语料的最新修正，优先级更高。

### 14.2 数量统计

统计匹配 `.as` 中的条件指令行，并按唯一文件去重。`deeply indented` 只是“至少两个 Tab 或八个空格”的函数体候选启发式，不是完整 Parser 分类。

| 项目 | `.as` 文件 | Editor 条件指令 | 涉及唯一文件 | 位于 `Editor/` 目录 | 位于 `Editor/` 目录外 | 前 5 行出现 Editor 条件的文件 | 深缩进条件指令 | TEST/RELEASE 指令 | TEST/RELEASE 唯一文件 | EDITORONLY_DATA |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| It Takes Two | 5,356 | 331 | 193 | 1 | 192 | 14 | 35 | 322 | 120 | 0 |
| Split Fiction | 15,741 | 2,815 | 1,812 | 27 | 1,785 | 132 | 189 | 1,437 | 460 | 17 条 / 10 文件 |

最关键的数据是：

```text
It Takes Two: 193 个相关文件中，192 个不在 Editor 目录
Split Fiction: 1,812 个相关文件中，1,785 个不在 Editor 目录
```

所以统一 Editor 目录只能覆盖“整文件/整模块 Editor-only”，无法覆盖绝大多数实际用法。

### 14.3 真实用法一：Runtime Tick 中的 Editor Preview 分支

`Reference/myas/It Takes Two Script/Cake/Environment/BreakableComponent.as:667-678`：

```angelscript
UFUNCTION(BlueprintOverride)
void Tick(float DeltaTime)
{
#if EDITOR
    if (!GetWorld().IsGameWorld())
    {
        DoPreview(DeltaTime);
        return;
    }
#endif

    // Runtime breakable behavior
}
```

这是最直接的反例：`Tick` 同时承担 Editor Preview 和 Runtime Gameplay。强行把 Preview 拆到 Editor companion 会改变 UObject 生命周期函数的组织方式、Tick 所有权和状态访问方式，成本并不总是合理。

Split Fiction 的 `GameShowArenaAnnouncer.as:447-458` 也在普通 Runtime `Tick` 中用 `#if EDITOR` 输出 `TEMPORAL_LOG`，随后继续执行 Runtime 逻辑。

结论：函数体内部的局部 Target Conditional 是真实且高频的需求。

### 14.4 真实用法二：ConstructionScript 中的 Editor World 操作

`GameplayUnwitherSphere.as:637-650`：

```angelscript
UFUNCTION(BlueprintOverride)
void ConstructionScript()
{
    Super::ConstructionScript();

#if EDITOR
    if (!Editor::IsCooking() && Level.IsVisible())
    {
        auto FilteredActors = GetWitherableActorsInSphere();
        CopyActors(FilteredActors, true);
        CopyActors(HandPickedActors, false);
    }
#endif
}
```

ConstructionScript 属于同一 Runtime Actor 的生命周期，但其中部分工作只对编辑器世界有效。这类逻辑也不适合一律拆成独立 Editor Module。

同文件还包含：

- `:45-47`：只在 Editor 设置组件默认值；
- `:370-382`：Editor-only `CallInEditor` 函数，调用 `EditorLevel::SetActorSelectionState`。

一个文件内同时存在 Runtime 类型、条件默认值、Editor Utility 方法和局部生命周期分支。

### 14.5 真实用法三：同一 Runtime 类型的条件成员和默认组件

Split Fiction 的 `GameShowArenaAnnouncer.as:136-140`：

```angelscript
#if EDITOR
UPROPERTY(DefaultComponent)
UHazeLevelSequenceResponseComponent SequenceResponseComponent;
default SequenceResponseComponent.OnSequenceUpdate.AddUFunction(this, n"OnSequenceUpdate");
#endif
```

注释明确说明该组件只用于 Editor 中预览表情，Gameplay 由另一个 Capability 处理。这会改变类的成员/默认组件集合，不能通过单纯把辅助函数移到 Editor 目录解决。

同类型在 `:252` 后还有 Editor Preview 状态和 `CallInEditor` 方法，在 `:450` 的 Runtime Tick 中又包含局部 Editor Temporal Log。

`GameplayUnwitherSphere.as:45-47` 则只在 Editor 修改一个 Runtime 默认组件的 Editor Scaling 默认值。这是一种粒度很细的条件声明语句。

### 14.6 真实用法四：`#if !EDITOR` 改变 Runtime 行为

`SpinningCogWheel.as:108-127`：

```angelscript
void BeginPlay()
{
    if (bAboutToBeConverted)
    {
#if !EDITOR
        DestroyActor();
        return;
#endif
    }

    ...

#if !EDITOR
    DestroyActor();
#endif
}
```

这里不是“Editor 工具代码”，而是同一 Runtime Actor 在 Editor 和非 Editor 环境下本来就需要不同生命周期行为。Source Directory 无法表达这种差异。

同文件还在开头定义 Editor-only 批量转换函数，并在类内定义 `CallInEditor` 转换方法，再次体现一个普通 Gameplay 文件同时承载多种可用性粒度。

### 14.7 真实用法五：`EDITORONLY_DATA` 改变类型布局和 Cook 数据

Split Fiction 的 `Gameplay/KineticActors/KineticRotatingActor.as:407-425` 和 `KineticMovingActor.as:361-379` 使用 `#if EDITORONLY_DATA` 声明迁移/原型字段，并在 ConstructionScript 中读取、转换和清理这些字段。

`Core/Props/PropLine.as` 更大规模地用 `EDITORONLY_DATA` 包围：

- 默认组件；
- 编辑状态字段；
- Editor-only helper 函数；
- Editor-only spline component 类型实现；
- scoped update helper struct。

`Core/Prefab/PrefabRoot.as`、`PrefabEditing.as`、`PrefabAsset.as` 也对 Prefab 编辑状态和数据结构做条件声明。

这些并非单纯的函数体 dead branch，而是 UE 本身 `WITH_EDITORONLY_DATA` 语义在 AS 类型/反射/序列化层的映射。它们天然要求 Profile-aware layout/materialization；不应伪装成一套完全相同的 Runtime 类型布局。

### 14.8 真实用法六：`CallInEditor` 函数内部仍使用 `#if EDITOR`

Split Fiction 的 `VillageOgreGroupModifierActor.as:33-78` 包含：

- `CallInEditor` 方法，其函数体内部用 `#if EDITOR`；
- 只在 Editor 存在的 `GetOgresInRange()` helper；
- 对 `Editor::GetAllEditorWorldActorsOfClass` 的引用。

这说明 `CallInEditor` 本身不能替代 Editor availability：函数签名可能保留在类型上，但真正的 Editor API 引用仍需条件保护。反过来，把所有这些方法拆出类型，也可能破坏当前 Details Panel 的按钮入口和作者体验。

### 14.9 修正后的语言/源码边界

最新建议不再是“Source Scope 替代所有 Target Conditional”，而是二者分工：

| 粒度 | 推荐机制 | 例子 |
|---|---|---|
| 整文件/整模块只在 Editor 存在 | Editor Source Scope / `Script/Editor` | Editor Subsystem、Asset Tool、Visualizer |
| 整文件/整模块不进 Shipping | Development Source Scope / `Script/Dev` | Debug Menu、Cheat、Profiling Tool |
| Runtime 函数内局部行为不同 | 保留 Target Conditional | Tick Preview、ConstructionScript、Temporal Log、`#if !EDITOR` Destroy |
| Runtime 类型上的 Editor-only 方法/组件 | 显式 availability 或兼容 `#if EDITOR` | `CallInEditor` helper、Preview Component |
| Editor-only serialized data/layout | 显式 `EditorOnlyData` 或兼容 `#if EDITORONLY_DATA` | Prefab 编辑状态、迁移字段、编辑 spline |
| 类型/泛型能力特化 | 语言级 `static_if` | `typeinfo`、generic capability |

因此：

```text
Source Scope = 粗粒度宿主/打包边界
Target Conditional = Runtime 类型和函数内部的细粒度 UE 配置差异
static_if = 类型/泛型的语言级静态特化
```

三者不是互斥替代关系。

### 14.10 对 Canonical AST 和 AOT 的现实修正

只要允许 Target Conditional 改变成员、默认组件、函数体或依赖，就不能声称三个 Profile 永远拥有同一棵完全 materialized AST。更准确的模型是：

```text
Raw Source / Conditional Source Graph       目标无关
Conditional AST（若未来实现）                目标无关，保留 Predicate 和两侧节点
Materialized Semantic View                 Profile-specific
Execution/Debug/ABI Identity               Profile-specific
AOT Native Binary                          Profile-specific
```

当前预处理器可以继续为每个 Profile 产生 Materialized View。未来若引入 Conditional AST，则节点可以表示：

```text
TargetConditionalNode
  Predicate = Editor | EditorOnlyData | Test | Release | ...
  ThenNodes
  ElseNodes
```

这会改善 IDE、Source Map、诊断和统一源码身份，但不会魔法般消除最终 Profile 语义差异。

AOT 的优化目标也应从“强制只有一个 Body”修改为“按实际相等性合并”：

1. 仍为 EditorDevelopment、GameDevelopment、GameShipping 构建/恢复精确 Materialized View；
2. 对每个函数计算 Profile-specific Semantic/Execution Hash；
3. 将相同 Hash 的 Profile 归入同一个 Variant Group；
4. 完全相同的函数实现只输出一次；
5. 只有不同的实现才输出 C++ Profile Guard；
6. Editor-only Includes、类型、函数和注册表放在完整 `#if WITH_EDITOR` Guard 内；
7. 三个薄 Provider Catalog 继续携带各自精确 Profile、Environment 和 ABI。

候选输出形式：

```cpp
// 三个 Profile 完全相同：只发一份
static void SharedRuntimeFunction(...)
{
    ...
}

// Development 相同，Shipping 不同：只发两个变体
#if !UE_BUILD_SHIPPING
static void ProfileSensitiveFunction(...) { /* development */ }
#else
static void ProfileSensitiveFunction(...) { /* shipping */ }
#endif

// Editor-only declaration/implementation
#if WITH_EDITOR
static void EditorPreviewFunction(...) { ... }
#endif
```

这仍可得到一个合并后的 Generated Source Tree，但它不是一个不区分 Target 的 Semantic View，也不是一个跨 Target 通用的 Native Provider。

### 14.11 最新推荐

基于真实 Hazelight 语料，当前推荐调整为：

1. 不禁止现有 `#if EDITOR`、`#if EDITORONLY_DATA`、`#if TEST`、`#if RELEASE`；
2. 新增/强化 Source Scope，但只用于整文件和整模块的粗粒度隔离；
3. 鼓励纯 Editor/Dev 工具迁移到对应目录，不强迫局部 Preview/Construction/Tick 逻辑拆分；
4. 长期可以把 Target Conditional 升级成 Compiler 可见的 Conditional AST，而不是简单文本删除；
5. Cache V2 用 Raw Source Identity 加 `PreprocessorContextDigest`/Profile Variant Identity 表达不同 Materialized View；
6. AOT 以 Function/Module Variant Group 做相等性合并，生成一棵合并源码树和薄 Profile Catalog；
7. 接受真正依赖 Target 的函数、类型布局和绑定必然有 Profile-specific 语义及原生实现；
8. 不再以“所有 Runtime AS 必须只有一棵 materialized AST”作为目标，因为它与现有商业项目的实际语言使用方式冲突。

一句话总结：

> 目录隔离能消除粗粒度重复，不能替代局部 `if editor`。正确优化对象不是“强迫所有 Target 语义相同”，而是“保留必要变体，只对实际相同的 AST/函数/AOT Body 去重”。

## 15. AOT Variant Group：公共函数一份，差异函数按实际变体数生成

### 15.1 对方案理解的确认

本节确认后续讨论中的核心理解：目标不是继续保存三棵完整的 Generated AOT Source Tree，而是为同一个 Stable Function 比较三个 Profile 的最终 Lowered AOT Body，只为真正不同的 Body 生成不同实现。

需要区分当前状态和候选目标：

- **当前实现**：`EditorDevelopment`、`GameDevelopment`、`GameShipping` 各自生成完整模块 `.jit.cpp`，因此公共函数也会重复出现在三套输出中；
- **候选目标**：三个 Profile 仍有精确 Materialized Semantic View，但生成器将相同的函数 Native Body 合并成一个 Variant Group，只输出一次；Provider Catalog 保持 Profile-specific。

因此“使用 `#if xx` 的函数生成三份”只是最坏情况。正确规则是按实际相等性生成一、二或三个变体。

### 15.2 典型 Profile 分组

设三个 Profile 为：

```text
ED = EditorDevelopment
GD = GameDevelopment
GS = GameShipping
```

| 最终函数语义 | Variant Group | 实现数量 |
|---|---|---:|
| ED = GD = GS | `{ED, GD, GS}` | 1 |
| ED ≠ GD = GS | `{ED}`, `{GD, GS}` | 2 |
| ED = GD ≠ GS | `{ED, GD}`, `{GS}` | 2 |
| ED = GS ≠ GD | `{ED, GS}`, `{GD}` | 2 |
| ED、GD、GS 全部不同 | `{ED}`, `{GD}`, `{GS}` | 3 |
| 函数只在 Editor 存在 | `{ED}` | 1 个 Editor Guard 实现 |
| 函数只在 Development 存在 | `{ED, GD}` | 1 个 Development Guard 实现 |

常见条件的自然结果：

- `#if EDITOR` 的局部函数体通常产生 `{ED}` 和 `{GD, GS}` 两个变体，而不是三份；
- `#if TEST` 在当前 Profile 定义下通常产生 `{ED, GD}` 和 `{GS}` 两个变体；
- `#if RELEASE` 通常同样是 Development 与 Shipping 两个变体；
- 同时受 Editor、Test、Release、Cooked Binding 或条件类型布局影响的函数，才可能得到三个不同变体；
- 即使源码包含条件，如果不同分支最终 Lower 后完全相同，仍可归为一个 Variant Group。

### 15.3 不能只扫描函数文本中是否出现 `#if`

一个函数即使没有直接写条件，也可能因为以下依赖产生 Profile Variant：

- 调用了某个 Profile-specific 函数；
- 访问了条件存在的成员、全局或 Property；
- 使用了 `EDITORONLY_DATA` 导致布局不同的类型；
- Native Binding Kind、函数地址、Calling Convention 或 Entry ABI 不同；
- Safe Point、异常、调试、Coverage 或 Shipping Policy 改变了实际生成指令；
- Imported Module 或稳定引用 ABI 在 Profile 间不同。

相反，一个包含 `#if` 的函数也可能在 Fold/Lower 后得到相同结果。

所以 Variant Group 必须比较最终可生成 Native Code 的规范化表示，而不是依赖：

```text
SourceContainsIfDef == true
```

候选 Variant Key 应至少覆盖：

```text
NativeBodyVariantKey
= Canonical Lowered AOT IR / emitted body semantics
+ referenced field/global/import ABI digests
+ required native binding ABI
+ code-affecting execution policy
+ backend/codegen version
```

Profile 名称、Catalog Metadata 和仅用于路由的 Provider Identity 不应无条件进入共享 Body Key，否则所有函数都会被人为拆成三份。它们继续属于 Profile Catalog/Entry Identity。

### 15.4 候选生成流程

```text
Raw AS Source
  -> ED / GD / GS Materialized Semantic Views
  -> 每个 Stable Function 分别 Lower 为规范化 AOT IR
  -> 计算 NativeBodyVariantKey
  -> 按 Key 对 Profile 分组
  -> 每个唯一 Key 只生成一个 C++ Body
  -> 为 Body 计算 Profile Mask / C++ Guard
  -> 生成 ED / GD / GS 薄 Provider Catalog
```

例如：

```text
UpdateGameplay
  ED hash = A
  GD hash = A
  GS hash = A
  => 生成 1 份 Body，三个 Catalog 都指向它

TickPreview
  ED hash = B
  GD hash = C
  GS hash = C
  => 生成 2 份 Body：Editor、Game

ProfileSensitiveDiagnostics
  ED hash = D
  GD hash = E
  GS hash = F
  => 只有该函数生成 3 份 Body
```

### 15.5 候选 C++ 输出

```cpp
// ED/GD/GS 完全相同，只输出一次。
static void ASBody_UpdateGameplay(...)
{
    ...
}

// Editor 与 Game 不同，只输出两个变体。
#if WITH_EDITOR
static void ASBody_TickPreview(...)
{
    // Editor Preview + shared runtime behavior
}
#else
static void ASBody_TickPreview(...)
{
    // Game behavior
}
#endif

// 只有真正三种语义都不同才输出三个分支。
#if WITH_EDITOR && UE_BUILD_DEVELOPMENT
static void ASBody_ProfileSensitiveDiagnostics(...) { /* ED */ }
#elif !WITH_EDITOR && UE_BUILD_DEVELOPMENT
static void ASBody_ProfileSensitiveDiagnostics(...) { /* GD */ }
#elif !WITH_EDITOR && UE_BUILD_SHIPPING
static void ASBody_ProfileSensitiveDiagnostics(...) { /* GS */ }
#endif
```

生成器也可以为每个 Variant 使用不同内部符号，再由薄 Catalog 映射；两种形式的关键不变量都是“每个唯一 Native Body 只 materialize 一次”。

### 15.6 类型布局条件会提升到结构/模块变体

函数级去重不是无条件安全的。如果 `#if EDITOR` 或 `#if EDITORONLY_DATA` 改变：

- UClass/UStruct 成员；
- 默认组件集合；
- Property offset；
- 类型大小或对齐；
- Reflection/ClassGenerator ABI；
- Global layout 或初始化顺序；

则相关类型描述、初始化器、字段访问函数和 Provider Entry ABI 必须保持 Profile-specific。此时可以继续共享不依赖这些布局差异的其他函数，但不能仅因函数源码文本相同就复用访问错误 offset 的 Native Body。

实现上需要从结构差异建立 Variant Dependency Closure：只有 Body、所有稳定引用 ABI 和所需执行策略均相同的函数才进入共享组。无法证明相同则保守生成 Profile-specific 变体或回退 VM。

### 15.7 与当前 StaticJIT 精确匹配并不冲突

Body 去重不意味着放松现有 Provider Matcher。以下身份继续按 Profile 精确发布和匹配：

- `ArtifactProfile`；
- `NativeEnvironmentFingerprint`；
- `ExecutionHash` / `DebugHash`；
- `EntryAbiHash`；
- Artifact Set、Stable References 和执行能力。

三个 Catalog 可以指向同一个已编译 Body Address，但每个 Catalog 仍声明自己的 Profile Identity，并且只有在当前 Profile 的完整匹配通过时才发布 Binding。

共享的是函数实现存储/生成结果，不是跨 Profile 冒用身份。

### 15.8 预期效果

若实际工程中大多数 Runtime 函数不依赖 Target Conditional，则输出规模将从：

```text
3 × 全量函数 Body
```

收敛为：

```text
1 × 公共 Runtime Body
+ 少量 2-variant 函数
+ 更少量 3-variant 函数
+ Editor/Development-only Body
+ 3 个薄 Catalog
```

真实节省比例需要以后对 `Reference/myas` 两套语料执行 Profile 编译与函数 Hash 分组才能量化；不能仅根据 `#if` 指令数量推断，因为一个条件可能影响多个函数/类型，也可能只影响一个很小的局部块。

### 15.9 当前确认的研究方向

当前对该候选方向的共同理解是：

> 保留 AS 的 Target Conditional 和精确 Profile 语义；不再为每个 Profile 无条件复制全部 AOT。生成器按 Stable Function 的最终 Lowered Body 和依赖 ABI 做 Variant Group，相同函数只生成一份，只有真正不同的函数才生成两份或三份；类型/模块结构差异保守提升变体范围，三个薄 Provider Catalog 继续精确匹配。

这既保留 Hazelight 商业项目需要的 `if editor/test/release` 灵活性，也直接针对当前“三套完整 AOT 输出”的空间、生成时间和维护成本。

## 16. 一棵 AOT 源码树：模块级、类型级、函数级合并设计

### 16.1 “只生成一份 AOT”在这里的准确含义

本研究把目标明确为：

> 对一组明确支持的 AS Target Profiles，只生成一棵 Generated AOT C++ Source Tree；相同实现只出现一次，差异实现以最小必要范围的 C++ Guard 共存于这棵树中。每个 UE Target 仍分别编译这棵树，并且运行时仍只发布与当前 Target 精确匹配的 Provider Catalog。

它不表示：

- Editor、Game Development、Game Shipping 共用一个已经编译好的 DLL；
- 把三个 Profile 冒充成一个 Artifact Profile；
- 只编译一次 AS 就要求编译器同时理解所有互斥的类型布局；
- 任意用户宏组合都无需重新生成；
- 所有有条件的函数都只能有一份 Native Body。

因此需要区分三个数量：

| 对象 | 候选数量 |
|---|---:|
| Generated AOT 源码树 | 1 |
| UE Target 编译产物 | 每个实际 UE Target 1 个 |
| 某个 Stable Function 的 Native Body | 按最终语义实际为 1、2 或 3 个 Variant |

### 16.2 当前实现给出的直接证据

当前实现仍是严格的单 Profile 生成：

- `FAngelscriptJITGenerationRequest::TargetProfile` 只接受一个具体 Profile；
- `BuildModuleSourceRelativePaths()` 生成 `<SourceStem>.<ModuleKeyPrefix>.<TargetProfile>.jit.cpp`；
- `Generate()` 用 `ProfileGuard(Request.TargetProfile)` 包住整个模块文件；
- Project Scaffold 从 `EditorDevelopment/`、`GameDevelopment/`、`GameShipping/` 三个目录选择一个 `Provider.generated.inl`；
- Owned File Inventory 也以单一 `TargetProfile + ProviderId` 判断所有权。

另一方面，最终生成前的 `FAngelscriptStaticJITGenerationSnapshot` 已经冻结了：

- `Modules`：`ModuleKey`、Canonical Module Name、Virtual Source Path；
- `Types`：`TypeKey`、Canonical Declaration、是否 materialize Script Reflection；
- `Globals`：`GlobalKey`、Canonical Declaration；
- `Functions`：`FunctionKey`、Execution/Debug/Entry ABI Hash、Bytecode、Verified Typed HIR；
- `Descriptors`：Class/Struct/Enum/Delegate/Property/Function 描述；
- `Dependencies`、`SemanticDependencies`、Native Call Targets 和 Native Call Inventory。

这意味着不必先把现有文本预处理器重写成“多分支 AST”。最稳妥的候选架构是：

```text
同一 Raw AS Source Set
  -> ED 独立 Source Compile -> Frozen Semantic Snapshot + Backend Candidates
  -> GD 独立 Source Compile -> Frozen Semantic Snapshot + Backend Candidates
  -> GS 独立 Source Compile -> Frozen Semantic Snapshot + Backend Candidates
  -> Multi-Profile Semantic Merger
  -> 一棵 Guarded Generated AOT Source Tree
```

这里生成阶段仍做三次隔离的 AS 语义编译，以保证每个 Profile 的名称解析、类型布局、反射描述和 HIR 都是可信的；被消除的是三棵几乎重复的 **C++ 输出树**，不是一开始就冒险消除 Profile 语义编译。

### 16.3 合并器必须位于什么位置

当前 `FAngelscriptJITGenerationRequest` 只携带最终 Modules 和 Functions，已经丢失了大量类型结构信息。类级安全合并不能只对三个 `.jit.cpp` 做文本 diff。

候选位置应位于：

```text
FAngelscriptStaticJITGenerationSnapshot
  + 每个 Backend 的函数级 Implementation Candidate
  -> FAngelscriptMultiProfileGenerationBundle
  -> Variant Group / Presence Mask / Dependency Closure
  -> 最终 FAngelscriptJITGeneration 输出
```

Bundle 至少需要保留：

```text
Profile
ArtifactProfile
NativeEnvironmentFingerprint
PreprocessorConfiguration
Modules / Types / Globals / Functions / Descriptors
References / SemanticDependencies / NativeCallSites
Entry Plan / Execution Capability Profile
BackendId / Canonical Implementation Template
```

稳定 Key 应作为首选匹配坐标，但跨 Profile 合并不能假定所有结构变化后 Key 一定不变。还需要不含 Body、布局和 Profile 的逻辑锚点：

```text
LogicalModuleAnchor
  = Logical Mount + Virtual Path + Canonical Module Name

LogicalTypeAnchor
  = LogicalModuleAnchor + Namespace + Entity Kind + Canonical Type Name

LogicalFunctionAnchor
  = Logical Owner Anchor + Function Kind + Canonical Signature

LogicalGlobalAnchor
  = LogicalModuleAnchor + Namespace + Name + Canonical Type
```

逻辑锚点只用于把“同一个源码概念在不同 Profile 的结果”对齐；现有 Stable Key、Execution Hash、Entry ABI Hash 和 Artifact Profile 仍然是发布与匹配的权威身份。

### 16.4 共同模型：Presence Mask、Shape Key、Body Variant Key

三个 Profile 先形成一个固定矩阵：

```text
ED = EditorDevelopment
GD = GameDevelopment
GS = GameShipping
```

每个语义实体都有 `ProfilePresenceMask`：

```text
{ED, GD, GS}  三者都存在
{ED}          仅 Editor
{ED, GD}      Development/Test 存在，Shipping 不存在
...
```

然后按层级计算不同 Key：

```text
ModuleSurfaceKey   // 模块导入和公开符号集合
TypeShapeKey       // 继承、成员、反射、布局等类型结构
InitializationKey // 全局/Defaults/组件/初始化顺序
FunctionEntryKey  // 签名与 VM/Raw/Parms Entry ABI
NativeBodyKey     // 最终可生成 C++ Body 的规范化语义
```

Presence 决定“代码是否应该出现在当前 Target”；Shape 决定“结构是否相容”；Body Key 决定“函数实现能否物理共享”。不能用一个 Hash 同时承担这三个职责。

### 16.5 模块/文件级：最容易先落地

> 2026-08-22 后续修正：本节关于当前 `Editor/Dev` 目录过滤的内容仍是有效的现状证据，但目录不再是候选新架构的语义入口。最新方案见第 17 节：所有逻辑源码按同一 Source Inventory 建模，整模块是否存在也由 Profile AST Presence 得出；目录只保留组织用途。

当前磁盘 Source Provider 实际上已经提供整目录 Source Scope：

- 跳过 Development Scripts 时忽略名为 `Examples` 和 `Dev` 的目录；
- 跳过 Editor Scripts 时忽略名为 `Editor` 的目录；
- 当前 Profile Traits 中只有 `EditorDevelopment` 把 `bIncludeDevelopmentScripts` 和 `bIncludeEditorScripts` 设为 `true`；
- `GameDevelopment` 与 `GameShipping` 当前都会排除 `Dev/` 和 `Editor/`。

因此当前 `Dev/` 的真实语义是“Editor Development 可见”，并不是“Game Development 可见、Shipping 不可见”。普通 Runtime 文件里 `#if TEST` 才是当前覆盖 ED + GD、排除 GS 的条件。以后如果希望 `Dev/` 表示真正的 Development Scope，需要显式修改 Profile Traits 和依赖规则，不能只靠目录命名推断。

模块级候选规则如下：

| 情况 | 语义结果 | 单树输出 |
|---|---|---|
| `Editor/` 中的整文件模块 | 通常 `{ED}` | 整个模块 `.jit.cpp` 用 ED Guard 包裹，Catalog Rows 同 Guard |
| 当前 `Dev/` 中的整文件模块 | 当前通常 `{ED}` | 与 Editor-only Module 相同；若以后改 Scope 语义再变成 `{ED,GD}` |
| 普通模块三个 Profile 都存在且 Surface 相同 | `{ED,GD,GS}` | 一个无模块级 Guard 的 `.jit.cpp`，内部函数按需分组 |
| 顶层 `#if` 导致某个函数/类型/全局只在部分 Profile 存在 | Module 存在，但 Surface 分裂 | 保留一个模块文件；只 Guard 对应声明的 Body、Reference Rows 和 Catalog Rows |
| 顶层 `#if` 改变 import/dependency graph | Module Dependency Variant | 依赖记录按 Profile Mask 发布；校验调用者 Mask 不超出被依赖项 Mask |
| 模块只在部分 Profile 有可 AOT 函数 | Partial Module | 整个 TU 或其所有内容使用该 Presence Mask；其他 Target 编译为空 |

候选文件名从：

```text
Foo.<ModuleKey>.EditorDevelopment.jit.cpp
Foo.<ModuleKey>.GameDevelopment.jit.cpp
Foo.<ModuleKey>.GameShipping.jit.cpp
```

收敛为：

```text
Foo.<ModuleKey>.jit.cpp
```

模块级还必须处理 Include：Editor-only Native Call 可能要求 Editor Module Header。如果把所有 Include 无条件放到文件顶部，Game Target 仍会因为找不到 Editor Header 而失败。因此 Include 本身也要按使用它的 Body Variant 做并集和 Guard：

```cpp
#include "CommonRuntimeHeader.h"

#if AS_AOT_PROFILE_ED
#include "EditorOnlyHeader.h"
#endif
```

模块依赖的基本约束是：

```text
CallerPresenceMask ⊆ CalleePresenceMask
```

若一个 GD/GS 函数无条件依赖 `{ED}` 模块，说明该 Profile 的 AS 语义图本身不完整，生成必须失败；不能靠 C++ Link Error 才暴露。若依赖只在 ED 函数变体中存在，则它只属于 ED Variant 的 Dependency Set。

### 16.6 类型/类级：拆成结构、成员和初始化三类

当前 StaticJIT 生成的是函数 Native Body 和 Provider 数据，并不会把 AS `class` 直接翻译成一个拥有独立 C++ 对象布局的原生类；实际 UClass/UStruct 和 Script Type 仍由 Runtime/ClassGenerator 权威 materialize。因此“类级合并”主要控制：

- 哪些方法、属性引用、描述符和 Catalog Row 在当前 Profile 存在；
- 哪些函数因为类型布局/反射 ABI 不同而不能共享；
- 哪些初始化函数必须分成不同 Variant。

#### 16.6.1 整个类型有条件存在

例如：

```angelscript
#if EDITOR
class UEditorPreviewTool : UObject
{
    ...
}
#endif
```

合并结果：

- Type Presence Mask 为 `{ED}`；
- 该类型拥有的方法、Property/Function Descriptor、Defaults/构造初始化器继承 `{ED}`；
- 引用该类型的其他实体必须至少具有同样窄的 Mask；
- 生成树中不需要复制其他 Runtime 类型，只 Guard 这个类型关联的 Body、数据和 Catalog Rows。

#### 16.6.2 条件 Property 或默认组件改变布局

这类情况需要 `TypeShapeKey`，至少包含：

```text
Type kind
Base type and implemented interfaces
Ordered properties: stable identity, type, flags, metadata
EditorOnly / reflected property state
Type layout ABI: size, alignment, ordered offsets or authoritative layout hash
Reflected descriptor surface
```

如果 `EDITORONLY_DATA`、`#if EDITOR` 或自定义构建宏改变 Property 集合，则：

- Type Shape 分成多个 Profile Group；
- 直接读取/写入差异 Property 的函数一定分裂；
- 内嵌 Property Offset、类型大小、拷贝/销毁计划的函数一定分裂；
- 通过该类型/属性的 Semantic Dependency Closure 传播到消费者；
- 与布局完全无关、依赖证明完整的其他方法仍可继续共享。

若 Backend 或 Snapshot 不能证明一个函数没有依赖变化布局，保守策略不是复制整个工程，而是：

1. 先把该类型拥有的所有实例方法提升为 Type-Shape Variant；
2. 把显式依赖该类型布局的外部函数加入闭包；
3. 对仍缺失依赖证明的函数生成 Profile-specific Body 或回退 VM。

#### 16.6.3 条件方法/UFUNCTION 只改变函数集合

类中整个方法声明位于条件块内时，首先是 `Function Presence Variant`：

- 方法仅在对应 Profile 的 Catalog/Descriptor 中出现；
- 它的 Body 只生成一次并加 Presence Guard；
- 其他不引用它的方法不应因此全部复制；
- 如果 UFUNCTION 集合变化影响 Reflection Surface，则 Type Descriptor/Interface ABI 是 Profile-specific，但这不自动等于所有 Native Body 都 Profile-specific。

现有 Preprocessor 对 UPROPERTY/UFUNCTION 已有特殊规则：`EDITOR`、`EDITORONLY_DATA` 以及配置中启用的预处理 Flag 可以包住它们；Editor 条件还会写入 EditorOnly Metadata。未来合并器不能只保留 `bEditorOnly` 一个布尔值，而应保留一般化的 `ProfilePresenceMask`/Predicate。

#### 16.6.4 Base Class 或 Interface 有条件变化

这是比增加一个字段更强的结构变化：

- Type Identity/Shape、方法查找、虚调用、对象转换和可能的 Entry ABI 都可能变化；
- 初版应把该类型的全部实例方法、构造/析构/Defaults 以及依赖该类型的消费者纳入 Profile Variant Closure；
- 只有以后有更细粒度的虚表/转换/布局证明，才能继续缩小范围。

#### 16.6.5 Defaults、默认组件和初始化逻辑不同

默认值或默认组件差异不必把整类所有方法复制：

- 把 `InitDefaults`、Generated Default Constructor、Global/Module Initializer 等现有函数角色纳入 `InitializationKey`；
- 只让初始化函数按 Profile 分组；
- 若默认组件集合同时改变反射 Property/Layout，再升级为 Type Shape Variant；
- 普通 Tick/Gameplay 方法仍按自身 Body 和依赖决定是否共享。

#### 16.6.6 Enum/Delegate/Funcdef

它们也属于类型结构而不是普通函数体：

- 条件 Enum Value 会改变常量值语义；使用并折叠该值的函数必须通过 `ExpectedContentOrValue` 之类的 Semantic Dependency 分裂；
- Delegate/Funcdef 签名变化会改变 Entry ABI，不能把两个签名映射到同一个 Body；
- 仅新增一个当前函数未引用的 Enum Value，不应强制复制所有模块函数。

### 16.7 函数级：声明 Presence 与 Body Variant 必须分开

#### 16.7.1 整个函数有条件存在

例如类外或类内的完整声明被 `#if EDITOR` 包住：

```angelscript
#if EDITOR
void RebuildPreview()
{
    ...
}
#endif
```

结果是一个 `Function Presence Mask = {ED}`。单树只生成一个 Guarded Body 和一个 Guarded Catalog Row，不存在“给 GD/GS 再生成空实现”的必要。

#### 16.7.2 签名稳定，函数体内部有条件分支

这是最适合函数级 Variant Group 的情况：

```angelscript
void Tick(float DeltaSeconds)
{
#if EDITOR
    UpdateEditorPreview();
#endif
    UpdateGameplay(DeltaSeconds);
}
```

三个 Profile 分别 Lower 后比较：

```text
ED Body = A
GD Body = B
GS Body = B
=> 一个 ED Variant + 一个 GD/GS Shared Variant
```

如果 Shipping 还去掉了 Test/Diagnostics：

```text
ED Body = A
GD Body = B
GS Body = C
=> 只有这个函数出现三个 Variant
```

#### 16.7.3 函数签名或 Overload 集有条件变化

如果条件切在返回类型、参数列表、`const`、访问控制或整个 Overload 上，不能把它当成同一个 Entry 的 Body Variant：

- 每个最终签名形成独立的 Logical Function/Stable Function；
- 每个签名有自己的 Presence Mask 和 Entry ABI；
- Caller 在各 Profile 的最终 HIR/Bytecode 会解析到对应函数；
- 只有签名和 Entry ABI 相同，才允许继续比较 Body。

#### 16.7.4 Native Body 的安全合并条件

安全基线不是只比较 `ExecutionHash`，也不是只比较生成 C++ 文本。至少应比较：

```text
Canonical backend implementation semantics
Function Entry Plan and EntryAbiHash
Ordered reference slots and expected ABI
Semantic dependencies and expected content/value
Native call routes, callees and native ABI
Execution capability profile and code-affecting policy
Required guarded includes/helpers
Backend/codegen schema version
```

初版可以采用非常保守的规则：只有 `ExecutionHash + EntryAbiHash + Dependencies + Native Call Plan + Canonical Implementation Template` 全部相同才共享。以后 Backend 若能提供经过验证的 Canonical AOT IR Hash，才允许在 Execution Hash 不同但最终 Native 语义被证明相同的情况下进一步合并。

`DebugHash`、Profile 名称和 Catalog 身份若不改变实际指令，可以留在 Profile-specific Catalog 中，不必强迫 Body 分裂；若 Source Position、Coverage、Timeout 或 Debug Frame 确实改变 emitted instructions，它们应进入 Code-Affecting Policy/Body Key。

#### 16.7.5 Caller/Callee 闭包

函数没有直接写 `#if` 也可能分裂：

- 它直接调用了 Profile-specific Callee；
- 它内嵌了条件 Property/Global 的 ABI 或值；
- Native Binding Route 在 Editor 与 Cooked Target 不同；
- 它的 Entry Plan 或 Execution Capability 不同。

当前生产态跨 Translation Unit 的 Script-to-Script Direct Call 仍关闭，这减少了 Native Body 直接地址传播的复杂度，但不能取消依赖校验。Reference Slots、Semantic Dependencies 和 Provider Matcher 仍需按 Profile 精确成立。

### 16.8 `#if` 在函数内还是函数外：不要靠缩进判断

当前 `ParseIntoChunks()` 已跟踪 `ScopeCount`、`ClassExitScope`、`ChunkType`、`IfDefStack`、`ClassIfDefs`、Namespace 和括号层级，它足以支持诊断与源码定位，但目前没有持久化一个权威的 `ConditionalRegion -> Semantic Owner` 图。

更重要的是，现有文本预处理允许条件出现在很细的 Token 位置，例如参数列表、函数调用参数、初始化表达式中。单纯按：

```text
缩进深 = 函数内
缩进浅 = 函数外
```

会误判 Namespace、Class、Defaults、Lambda、数组/初始化列表和多行表达式。

本候选设计采用两层判断：

1. **语义权威层**：比较 ED/GD/GS 的最终 Frozen Snapshots，把差异归到 Module Surface、Type Shape、Initialization、Function Entry 或 Function Body；
2. **源码诊断层**：Preprocessor 额外记录 `FConditionalRegion`，用于解释“哪个 `#if` 导致哪个实体分裂”，但不作为共享安全性的唯一依据。

候选记录：

```text
FConditionalRegion
  SourceRange
  NormalizedPredicate
  LexicalScopeHint
  OwningModuleAnchor
  OwningTypeAnchor?
  OwningFunctionAnchor?
  BranchSourceRanges
```

最终归类规则是：

| 文本位置 | 最终语义归类 |
|---|---|
| 条件决定整文件是否进入 Source Set | Module Presence |
| 顶层 import/type/global/function 集变化 | Module Surface |
| Class 内 Property/Base/Interface/Descriptor 变化 | Type Shape |
| Defaults/组件/全局初始化变化 | Initialization |
| 整个函数或签名变化 | Function Presence/Entry |
| 稳定签名下 Statement/Expression 变化 | Function Body |
| Token 级条件同时改变多个实体 | 分别归入各实体；必要时提升到最近共同所有者 |

因此“函数内/函数外”是第一层直觉，但真正实现应至少有上述五类，而不是只有一个布尔值 `bInsideFunction`。

### 16.9 自定义 Preprocessor Flags 的现状

当前 `UAngelscriptSettings::PreprocessorFlags` 是一个 `TArray<FString>`：

```ini
+PreprocessorFlags="FOO"
+PreprocessorFlags="BAR"
```

每个列出的自定义 Flag 都以 `true` 加入 `FAngelscriptPreprocessorContext::PreprocessorFlags`。当前脚本内没有 `#define`；它是 Host/Project Configuration 输入。`#if` 表达式也只支持单一 Flag 或前置 `!`，不支持 `&&`、`||`、数值或比较表达式。

现有 Cache V2 已经做对了一件重要事情：`BuildAngelscriptCacheEnvironmentProfile()` 会把完整的 Preprocessor Flag Name/Bool Map 排序后作为 Preprocessor Compile Options 写入 Context/Profile Identity。因此自定义 Flag 改变时，Cache Artifact Profile 会改变，不应复用旧语义产物。

但当前三个 JIT Target 只显式 Override：

```text
EDITOR
EDITORONLY_DATA
RELEASE
TEST
```

项目自定义 Flags 在三个隔离 Engine 中通常保持同一份 Settings 值；`WITH_SERVER_CODE` 与 `COOK_COMMANDLET` 也不属于当前 ED/GD/GS 显式覆盖矩阵。

### 16.10 自定义宏在“一棵树”中的建议分类

| Flag 类别 | 例子 | 单树策略 |
|---|---|---|
| Built-in Profile Axis | `EDITOR`、`EDITORONLY_DATA`、`TEST`、`RELEASE` | 对 ED/GD/GS 求值并生成 Presence Mask/Variant Group |
| Build-Invariant Project Feature | `GAME_WITH_FOO`，三个 Profile 必须同值 | 在本次生成配置中冻结；改变后重新生成整棵 AOT 树 |
| Explicit Profile-Mapped Feature（未来可选） | 项目明确声明 ED=true、GD=true、GS=false | 只对声明的三个 Profile Row 求值，进入现有 Variant Group；不枚举理论上的全部组合 |
| Runtime Feature Toggle | 用户设置、实验开关、在线配置 | 不应使用预处理 Flag；使用普通 Runtime `if`/配置对象 |
| 未建模 Target Axis | Client/Server、Cook Commandlet 等 | 冻结为构建不变量，或显式扩展 Supported Target Matrix；禁止静默假定三 Profile 已覆盖 |

核心约束：

> 一棵 AOT 树适配的是一个“明确声明的 Target Matrix + 一份冻结的 Build Feature Set”，不是所有自定义宏的 `2^N` 任意组合。

否则任意新增一个布尔宏都会使理论组合翻倍，最终重新回到不可控制的多份 AOT。

候选配置模型：

```text
FAngelscriptPreprocessorFlagDefinition
  Name
  Kind = BuiltInProfileAxis | BuildInvariant | ProfileMapped
  DefaultValue
  Optional ProfileOverrides
  Origin = Engine | ProjectSettings | CommandLine | Tool
```

向后兼容规则：

- 现有 `TArray<FString> PreprocessorFlags` 中的每个名字规范化为 `BuildInvariant=true`；
- 未声明名字继续不应被当成一个可以任意选择的构建轴；
- 若以后需要显式 `false` 的已声明自定义 Flag 或 Profile Mapping，新增结构化配置，不能继续只依赖“启用名字列表”。

生成时应计算：

```text
BuildFeatureSetDigest
  = sorted(Name, Kind, resolved invariant value, origin/schema)

TargetMatrixDigest
  = supported profile rows
  + every profile-axis value per row
  + matrix schema

AOTSourceTreeIdentity
  = source inventory/content
  + BuildFeatureSetDigest
  + TargetMatrixDigest
  + backend/codegen versions
```

现有每个 Profile 的 `ArtifactProfile` 继续保留，并且在三个 Profile 合并前应验证自定义 Build-Invariant 子集完全相同。若项目配置在三个隔离编译间不一致，应 Fail Closed，而不是把它意外当成新的 Profile Variant。

Flag 配置改变后的行为：

1. Generated Manifest/Inventory 检测 `BuildFeatureSetDigest` 不匹配；
2. 要求重新生成 AOT Source Tree；
3. 运行时 Provider Matcher 仍以 Artifact Profile 精确拒绝旧 Provider；
4. 不以“静默 VM Fallback”作为正常配置更新流程，只把它作为安全兜底。

### 16.11 `WITH_SERVER_CODE` 与 `COOK_COMMANDLET` 是一个必须显式处理的边界

当前三 Profile 只描述 Editor/Game 与 Development/Shipping，不完整描述 Client/Server/Commandlet。若 AS 源码使用：

```angelscript
#if WITH_SERVER_CODE
...
#endif
```

并希望同一 Generated Tree 同时服务带 Server Code 和不带 Server Code 的 Target，就必须二选一：

1. 把 Server/NoServer 加入 Supported Target Matrix，并为实际支持的 Target Row 编译语义快照；
2. 明确本次树只支持一个冻结的 Server-Code 值，并让不匹配 Target 拒绝该 Provider。

不能仅在生成 C++ 中添加 `#if WITH_SERVER_CODE`，却只生成了其中一个 AS 分支的 Body；那会产生一个看似可适配、实际缺少另一分支语义的伪单树。

`COOK_COMMANDLET` 更接近执行上下文而不是普通游戏 Target。如果需要持久 AOT 支持 Cook-only AS 逻辑，应给它独立、明确的 Tool/Commandlet Profile 或把整模块放入 Tool Scope；不应让运行生成命令的 Host 状态偶然烘焙进常规 Game AOT。

### 16.12 候选单树输出布局

```text
AngelscriptJIT/Generated/
  AOTProfile.generated.h
  Provider.generated.inl
  ProviderManifest.generated.json
  OwnedFiles.generated.json
  Modules/
    Gameplay/Foo.<ModuleKey>.jit.cpp
    Editor/PreviewTool.<ModuleKey>.jit.cpp
    ...
```

`AOTProfile.generated.h` 集中把 UE Target 宏规范化成互斥选择：

```cpp
#define AS_AOT_PROFILE_ED (WITH_EDITOR && UE_BUILD_DEVELOPMENT)
#define AS_AOT_PROFILE_GD (!WITH_EDITOR && UE_BUILD_DEVELOPMENT)
#define AS_AOT_PROFILE_GS (!WITH_EDITOR && UE_BUILD_SHIPPING)

static_assert(
    AS_AOT_PROFILE_ED + AS_AOT_PROFILE_GD + AS_AOT_PROFILE_GS == 1,
    "Generated AngelScript AOT tree does not support this UE target profile");
```

实际实现需要避免宏在 C++ 表达式中的兼容问题，并覆盖项目决定支持的 DebugGame/Test/Server Rows；上例只表达核心思想。

一个模块文件可能是：

```cpp
#include "AOTProfile.generated.h"
#include "CommonRuntimeHeader.h"

#if AS_AOT_PROFILE_ED
#include "EditorOnlyHeader.h"
#endif

// 三 Profile 完全相同。
static void ASBody_UpdateGameplay(...)
{
    ...
}

// ED 与 Game 不同。
#if AS_AOT_PROFILE_ED
static void ASBody_Tick_Editor(...)
{
    ...
}
#else
static void ASBody_Tick_Game(...)
{
    ...
}
#endif

// 仅 Editor 存在的完整函数。
#if AS_AOT_PROFILE_ED
static void ASBody_RebuildPreview(...)
{
    ...
}
#endif
```

`Provider.generated.inl` 也只存一份源码，但每个编译 Target 只 materialize 当前 Catalog：

```cpp
#if AS_AOT_PROFILE_ED
// ED ArtifactProfile / NativeEnvironment / Entries
#elif AS_AOT_PROFILE_GD
// GD ArtifactProfile / NativeEnvironment / Entries
#elif AS_AOT_PROFILE_GS
// GS ArtifactProfile / NativeEnvironment / Entries
#endif
```

所以依然有三个精确的 Catalog **语义视图**，但不再有三个物理目录和三份公共 Body。

### 16.13 依赖闭包与 Fail-Closed 规则

合并算法可以概括为：

```text
1. 校验三个 Profile 属于同一 Source Inventory 和 Build Feature Set。
2. 按 Logical Anchor 建立 Module/Type/Global/Function Union。
3. 计算每个实体的 Presence Mask。
4. 比较 Module Surface、Type Shape、Initialization 和 Function Entry。
5. Backend 为每个 Profile 输出 Canonical Body Candidate。
6. 计算 NativeBodyKey 并形成函数 Variant Groups。
7. 从 References/SemanticDependencies/Native Call ABI 建立变体依赖闭包。
8. 为 Module、Include、Body、Reference Row、Catalog Row 计算最小 Guard。
9. 校验每个支持的 Profile 只选择一套完整、精确匹配的 Entry。
10. 生成一个 Matrix Manifest 和一个 Owned File Inventory。
```

以下情况应 Fail Closed 或对单个函数回退 VM：

- 同一逻辑实体在 Profile 间无法无歧义对齐；
- 函数 Entry ABI 不同却被要求共享 Body；
- Type Layout 已变化但依赖证明不完整；
- Caller Presence 超出 Callee/Module Presence；
- Reference Slot 顺序或 Expected ABI 不同；
- Native Binding Route/ABI 不同但 Body Key 未分裂；
- 自定义 Build-Invariant Flags 在三个编译间不同；
- 当前 UE Target 不属于 Manifest 声明的 Supported Matrix；
- 只捕获了某个未建模宏的一侧，却试图声称 Generated Tree 支持两侧。

### 16.14 推荐的渐进研究顺序

这仍然是轻量研究，不是当前实施任务。若以后进入实现，建议按风险从低到高验证：

1. **Report-only Multi-Profile Diff**：不改生成结果，只把 ED/GD/GS Snapshot 对齐，报告 Module Presence、Type Shape、Function Presence 和 Body Hash 分组；
2. **模块 Presence 合并**：按 Stable Module Key 合并整模块 Presence 和三 Profile 公共模块，不依赖它们位于哪个目录；
3. **函数 Body Variant Group**：只在 Entry ABI、依赖和 Backend Template 完全一致时共享；
4. **条件函数声明/Catalog 合并**：用 Guarded Rows 表达函数只在部分 Profile 存在；
5. **Type Shape Dependency Closure**：利用 Cache V2 Type Schema/Layout Hash 与 Semantic Dependencies 缩小类级分裂范围；
6. **结构化自定义 Flag Schema**：仅在确有 Profile-Mapped 项目 Flag 需求时增加；
7. **扩展 Target Matrix**：Server/Client/Test/Commandlet 由真实产品需求驱动，不预先枚举所有组合。

第一步应优先对 `Reference/myas` 的 It Takes Two 与 Split Fiction 全量语料运行。只有得到“公共 Body、两变体、三变体、仅单 Profile 存在、因 Type Shape 被提升”的实际比例后，才值得决定类型级闭包要做到多细。

### 16.15 当前分层建议

当前建议可以压缩为：

> 模块级用 Presence Mask 包整 TU 或模块内实体，是最先可做的部分；类级不复制整类/整模块，而是把类型结构差异变成 Type Shape Variant，并通过稳定引用与 Semantic Dependency 只提升受影响函数；函数级把“函数是否存在、Entry ABI 是否相同、Body 是否相同”分开判断。三个 Profile 继续独立产生可信语义快照，最终由 Multi-Profile Merger 输出一棵 Guarded AOT C++ Source Tree。自定义宏默认是冻结的 Build Feature Set，修改即重新生成；只有显式声明的 Profile Axis 才参与三行 Target Matrix，绝不枚举任意 `2^N` 组合。

## 17. 新 Canonical Typed AST 方案：不做目录语义，直接比较 Profile AST

本节记录 2026-08-22 查看以下只读 worktree 后形成的最新判断：

```text
.worktrees/refactor-as-canonical-typed-ast-compiler
```

这次查看没有修改该 worktree。它包含大量尚未提交的 Canonical AST/Sema/CodeGen 工作，且其自己的研究记录明确要求不要把当前绿色测试解释为生产切换完成。因此，本节只讨论它为多 Profile AOT 提供的架构机会，不把未完成能力写成既成事实。

### 17.1 对“不要做目录划分”的确认

最新建议是：

> 不要求项目把 AngelScript 强制拆到 `Script/Editor`、`Script/Dev`、`Script/Runtime`，也不让目录名决定编译 Profile。目录只服务于人类组织、IDE 浏览和可选打包规则；编译语义由明确的 Preprocessor Context、Target Matrix 和最终 sealed Canonical AST 决定。

这比前面讨论的 Source Scope 更适合 Hazelight 现有脚本风格，原因是：

- 普通 Gameplay 文件中本来就有大量局部 `#if EDITOR`、`#if !EDITOR`、`#if TEST`；
- 条件不只包函数体，还会包 Property、默认组件、方法、Base/Interface 和初始化语句；
- 强行按目录拆分会破坏类型所有权、`CallInEditor` 作者体验和 Construction/Preview 代码的局部性；
- 新 AST 已经能够表达 Decl、Stmt、Expr、Exact Type、Resolved Decl、Control Target 和 Dependency，真正的差异可以在语义树上看出来，不必让文件路径先替编译器做粗略分类。

因此，旧建议中的 `Editor/Dev` 目录可以作为可选风格保留，但不进入下列任何稳定身份：

```text
DeclAnchorKey
SemanticSubtreeHash
NativeAOTVariantKey
ProfilePresenceMask
```

当前磁盘 Source Provider 对 `Editor/Dev` 的跳过行为仍是兼容现状。若以后实施本方案，Multi-Profile AOT 模式需要先捕获一份统一的逻辑 Source Inventory，不能在 AST 比较之前仅因目录名就让某个 Profile 看不到源文件。一个文件被顶层 `#if EDITOR` 完全裁空时，Source Inventory 仍应保留其 Stable Module Anchor，AST 合并器再把它识别成 `{ED}` Presence；不应靠 `Editor/` 路径推断。

### 17.2 新 AST 为什么正好适合这个问题

worktree 中的目标数据流是：

```text
SourceManager
  -> Parser dedicated Sema actions
  -> sealed interned Canonical Typed AST
  -> Bytecode CodeGen / TypedASTJIT / Cache DTO / public snapshot
```

核心节点已经具备多 Profile 对比需要的形状：

- `asCDecl`：`kind`、`parent`、exact `type`、`stableKey`、`children`、`body`、`traits`、`dependencies`、`bases`；
- `asCStmt`：`kind`、`owner`、`target`、`expr`、`decl`、`children`；
- `asCExpr`：`kind`、exact type/qualifiers、value category、`resolvedDecl`、literal bits 和有序 children；
- `asCASTContext`：Module-owned 节点创建、类型 Intern、Stable Key、Seal，以及 Seal 后只读约束；
- StaticJIT Generation Snapshot：每个函数已经可以携带 `SealedAST` 与 `CanonicalFunctionDeclValue`，把 Runtime Function 映射到 Canonical AST Decl。

对应源码入口：

```text
Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/
  as_ast_context.h/.cpp
  as_decl.h
  as_stmt.h
  as_expr.h
  as_sema.cpp
  as_ast_dump.cpp
  as_ast_sidecar.cpp

Plugins/Angelscript/Source/AngelscriptRuntime/StaticJIT/
  AngelscriptStaticJITGenerationSnapshot.h/.cpp

Plugins/Angelscript/Source/AngelscriptEditor/StaticJIT/
  AngelscriptJITProjectGeneration.cpp
```

这意味着新的合并流程不必从预处理文本猜“这个 `#if` 在函数内还是函数外”，而可以直接观察最终结果：

```text
相同 Raw Source Inventory
  -> EditorDevelopment sealed AST
  -> GameDevelopment sealed AST
  -> GameShipping sealed AST
  -> Canonical Profile AST Diff/Merge
  -> Profiled Variant Overlay
  -> 一棵 Guarded AOT C++ Source Tree
```

Preprocessor 仍负责为每个 Profile materialize 合法输入；Canonical AST 负责告诉合并器最终声明、类型、绑定和执行语义究竟有什么差异。

### 17.3 不能直接复用当前 `asCASTShadowDiff`

“直接比较 AST Tree”这个方向成立，但不能理解成直接比较当前 dump 文本或节点数字 ID。

当前 `asCASTShadowDiff()`：

- 先比较 Decl 数量；
- 以 `1..DeclCount` 的数组下标逐项比较；
- 直接比较 snapshot-local `parent` ID、type ID、traits、source offset 和 dependency 数组；
- 没有对齐 Stable Decl Key；
- 没有递归比较 Stmt/Expr Body。

如果 ED 在第 10 个位置多出一个 Editor-only Property，后续 GD/GS 节点 ID 全部平移，即使许多函数语义完全相同，当前 Shadow Diff 也会报告大量无意义差异。

当前 AST sidecar 也还不能作为这项工作的语义 Hash：

- `asCASTEncodeSidecar()` 保存完整文本 dump，但恢复阶段只重建 Decl 骨架；
- `asCASTCollectFunctionRecords()` 的 `contentHash` 当前只覆盖 Function Key、返回类型/qualifiers、traits、origin、default argument 和 dependencies；
- 该 Function Record Hash 没有包含函数 Stmt/Expr Body；
- Sidecar 自己的设计记录也把它称为 envelope，而不是完整生产 DTO。

因此应新增专门的 Cross-Profile Canonical Diff/Hash，而不是扩张 Shadow Diff 的测试用途或把文本 dump 当稳定格式。

### 17.4 三种身份必须分开

#### 17.4.1 `DeclAnchorKey`：回答“是不是同一个逻辑实体”

它只用于跨 ED/GD/GS Snapshot 对齐，不判断实现是否相同。

建议来源：

```text
Module      = StableModuleKey
Named Type  = StableModuleKey + fully-qualified semantic type key
Function    = StableFunctionKey / owner + name + canonical parameter signature + qualifiers
Property    = owner Type Anchor + property name + declared semantic role
Global      = Module Anchor + namespace + global name
```

worktree 的 `asCSema::FinishDecl()` 已经为命名声明构造了一个有用基础：Owner Path、名称、函数 canonical parameter types、参数方向/ref/handle、const method，Lambda 还附加 source offset。StaticJIT Snapshot 又已有 Cache V2 风格的 Stable Module/Function/Type Keys。正式实现应优先复用这些稳定身份，而不是另造第三套互不相容的符号键。

仍需补强的边界：

- Snapshot-local Decl/Stmt/Expr ID 绝不能进入跨 Profile Anchor；
- 当前 Runtime Function 到 AST 的 bridge key 主要使用 owner/name/parameter type name，不能视为完整的跨 Profile Stable Function Contract；
- Local Decl、匿名 block、Lambda、临时量没有天然全局 Stable Key；
- Lambda 当前使用 source offset 和按源码顺序匹配，适合同一批 Raw Source 的过渡映射，但不是通用 ABI Identity；
- 同名局部变量和条件分支导致 ordinal 平移时，需要 lexical binder identity。

Local/anonymous 节点可采用：

```text
Owning Stable Function Key
+ normalized lexical path / binder path
+ semantic role
+ authored source anchor（只在匿名身份消歧时使用）
```

同一轮三 Profile 比较的原始源码完全相同，预处理又通常保留行/offset 对应关系，因此 authored source anchor 可以帮助消歧；但 source range 不应进入“语义是否相同”的 Hash。

#### 17.4.2 `SemanticSubtreeHash`：回答“语言语义是否相同”

它应递归覆盖：

```text
Node Kind
Exact canonical type stable key + qualifiers
Value category
Operator / conversion / call / construction kind
Literal bits（不是格式化字符串）
Resolved Decl Anchor
Children in semantic/evaluation order
Normalized lexical binder references
Normalized break/continue/switch targets
Semantic dependencies and expected values
Cleanup/materialization/lifetime nodes
```

它应明确排除：

```text
Snapshot-local Decl/Stmt/Expr/Type IDs
节点在 arena/数组中的插入顺序
Profile 名称本身
原始指针
纯诊断 source range
不会改变执行的 dump/debug 文本
```

注意：不能因为加法或比较看似可交换就擅自重排 children。Hash 规范化只移除 Snapshot 偶然性，不改变 AngelScript 的求值顺序、重载解析、临时量和副作用语义。

#### 17.4.3 `NativeAOTVariantKey`：回答“最终 C++ 实现是否可以共享”

AST 相同是强证据，但不总是充分条件。最终 Key 还应叠加：

```text
SemanticSubtreeHash
Type Schema / Native Layout ABI used by the function
Entry Plan + EntryAbiHash
Ordered Reference Slots + expected ABI/content
Native Binding Route and callee ABI
Artifact/Execution capability that changes emitted code
safe-point / timeout / coverage / debug-frame code-affecting policy
required includes/helpers and their guards
Backend + CodeGen schema/version
```

原因包括：

- ED 与 Cooked Game 可能为同一个 C++ Binding 选择不同调用路线；
- Development/Shipping 即使 AST 完全相同，也可能因 safe-point 或 instrumentation 生成不同 Native Body；
- 条件 Property 会改变对象布局，访问该 Property 的 AST 形状未必携带最终 UE offset/size；
- 同一 AS 声明在不同 Native Environment 下可能拥有不同 Entry ABI 或外部链接能力。

所以准确结论是：

> Canonical AST 是 Profile 差异分类的第一权威，但不是跨 UE Native Target 共享 C++ Body 的唯一证明。AST 后面还必须有 ABI/Native Environment 覆盖层。

初版应保守：`NativeAOTVariantKey` 完全相同才共享。未来若生成器把 Entry Wrapper 与纯 Implementation Body 分开，才可以在 Entry ABI 不同的情况下进一步共享内部实现。

### 17.5 不合并可变 AST，而是建立只读 Profile Overlay

每个 `asCASTContext` Seal 后应保持不可变，也不应该为了得到“一棵树”而复制、删改或重新编号节点。更安全的候选结构是：

```text
FProfiledASTSet
  SourceInventoryDigest
  BuildFeatureSetDigest
  TargetMatrixDigest
  ProfileSnapshots[ED, GD, GS]       // 持有 snapshot/engine lease
  LogicalModules[]

FLogicalASTEntityGroup
  DeclAnchorKey
  PresenceMask
  Variants[]

FASTSemanticVariant
  SemanticSubtreeHash
  ProfileMask
  NodeRefs[]                         // (Profile, SnapshotLease, NodeId)
  NativeVariants[]

FNativeAOTVariant
  NativeAOTVariantKey
  ProfileMask
  BackendCandidate
```

这里的“一棵 AOT 树”是 Profile Overlay/Variant Forest 与最终 Generated Source Tree，不是强行把三个 sealed AST 变成一个新的 `asCASTContext`。

这样有几个好处：

- 保留每个 Profile 已经验证过的 Sema 事实；
- 不破坏 Snapshot-local ID 和现有消费者；
- 一个逻辑函数可以自然形成 1、2 或 3 个 Variant Group；
- Error/diagnostic 可以同时指出 ED/GD/GS 各自的原节点；
- Hot Reload/异步生成只需延长 Snapshot Lease，不需要共享可变 Compiler 内存；
- 后端可以从每组选择一个代表节点生成，也可以在调试模式交叉验证组内节点的规范化 dump。

### 17.6 模块、类和函数差异如何从 AST 直接得出

| AST 对比结果 | 分类 | AOT 处理 |
|---|---|---|
| Stable Module Anchor 只在部分 Profile 有非空 TU | Module Presence | 一个模块文件/区域，按 Presence Mask Guard |
| TU child key 集或 import/dependency 不同 | Module Surface | 只 Guard 差异实体和依赖行；必要时提升整个 TU |
| Type Decl 只在部分 Profile 存在 | Type Presence | Type descriptor、相关函数和 Catalog Row 按 Mask 存在 |
| Type 的 bases/interfaces/properties/member signatures 不同 | Type Shape | 计算 TypeShape Variant 与依赖闭包；不自动复制无关模块 |
| Defaults、默认组件、Global initializer body 不同 | Initialization | Init/Defaults 函数单独分组；布局也变时升级 Type Shape |
| Function Decl Anchor 只在部分 Profile 存在 | Function Presence | 只生成一个 Guarded Entry/Body，不生成空桩 |
| Function Stable Key 相同，Body Subtree Hash 不同 | Function Body Variant | 为每个唯一 Body Hash 组生成一次 |
| Function signature/qualifiers 不同 | Function Entry Variant | 视为不同 Stable Function/Entry，不仅是 Body Variant |
| AST Body 相同但 NativeAOTVariantKey 不同 | Native Policy/ABI Variant | 仍生成多个 Native Variant 或让单函数回退 VM |

这也回答了“`#if` 在函数内还是函数外如何确认”：

- 不再把文本位置作为最终分类依据；
- 顶层条件造成 TU child set 差异，自然落到 Module Surface/Decl Presence；
- 类内条件造成 Type Decl child/base/property 差异，自然落到 Type Shape；
- 稳定 Function Decl 的 body root 不同，自然落到 Function Body；
- 同一个条件同时影响多个实体时，各实体分别归类，依赖闭包再决定是否向上提升。

Preprocessor 的 Conditional Region 仍值得保留，但只用于把 AST Diff 解释回源码，例如“这个 Property Presence 差异来自 `#if EDITORONLY_DATA`”，不再决定优化安全性。

### 17.7 示例：没有目录划分也能生成一棵 C++ 树

源码可以全部留在原来的 Gameplay 文件：

```angelscript
class UPreviewComponent : UActorComponent
{
#if EDITORONLY_DATA
    UPROPERTY()
    FVector PreviewOffset;
#endif

    void Tick(float DeltaSeconds)
    {
#if EDITOR
        UpdatePreview();
#endif
        UpdateGameplay(DeltaSeconds);
    }

#if EDITOR
    UFUNCTION(CallInEditor)
    void RebuildPreview()
    {
        Editor::Rebuild(this);
    }
#endif
}
```

Profile AST Diff 得到：

```text
UPreviewComponent Presence       = {ED,GD,GS}
PreviewOffset Presence           = {ED}
TypeShape                        = ED shape A / GD+GS shape B
Tick Body                        = ED body A / GD+GS body B
RebuildPreview Presence          = {ED}
```

候选 Generated C++ 仍只有一个模块文件：

```cpp
// UPreviewComponent.<ModuleKey>.jit.cpp

#if AS_AOT_PROFILE_ED
static void ASBody_Tick_Editor(...)
{
    // UpdatePreview + UpdateGameplay
}
#else
static void ASBody_Tick_Game(...)
{
    // UpdateGameplay
}
#endif

#if AS_AOT_PROFILE_ED
static void ASBody_RebuildPreview(...)
{
    // Editor binding route
}
#endif
```

Provider Catalog 仍在同一源码树中按 Profile 选择精确的 Artifact Profile、Entry ABI、Native Environment 和函数地址。最终 UBT 会分别编译 Editor、Game Development、Game Shipping 原生二进制，但仓库里不再保存三个 Profile 目录和三份重复公共 Body。

### 17.8 当前多 Profile 生成入口正好可以被改造成分阶段流程

worktree 的 `FAngelscriptJITProjectGeneration::GenerateProfilesSequential()` 已经会顺序处理多个 Profile：

```text
匹配当前 Engine 的 Profile -> GenerateMatchingProfile
其他 Profile              -> GenerateContainedProfile
```

但现在它仍然为每个 Profile 立即构造并发布独立 Artifact/Output。因此候选改造点不是再增加第四种 Source Scope，而是把流程拆成两阶段：

```text
阶段 A：Compile/Capture
  Freeze Hot Reload application
  Capture common Source Inventory + Build Feature Set
  Compile ED -> retain sealed AST + Generation Snapshot lease
  Compile GD -> retain sealed AST + Generation Snapshot lease
  Compile GS -> retain sealed AST + Generation Snapshot lease

阶段 B：Diff/Merge/Emit
  Validate same Source Inventory and invariant feature set
  Build Profiled AST Overlay
  Group SemanticSubtreeHash
  Ask backend for Native candidates
  Group NativeAOTVariantKey
  Emit one Guarded Source Tree + one matrix manifest/inventory
  Release leases
```

当前 `FAngelscriptStaticJITGenerationFunction` 已有：

```cpp
const asCASTContext* SealedAST;
asUINT CanonicalFunctionDeclValue;
```

这证明函数级接入点已经出现。后续需要的是让 Project Generation 在 Callback 返回后仍安全持有 Snapshot Lease，并一次看到三组 Snapshot，而不是让每个 `BuildProjectArtifacts()` 立即降成互不关联的最终 C++ 文件。

### 17.9 这套方案仍然不自动解决任意自定义宏组合

Canonical AST Diff 只能比较实际编译出来的 Profile Row，不能证明没有捕获的宏另一侧。

现有 `PreprocessorFlags` 继续按以下方式处理最稳妥：

- 旧 `TArray<FString>` 中的 true-only 项目 Flag 默认是本次生成冻结的 Build Feature Set；
- ED/GD/GS 三次编译必须验证这组 invariant flags 完全相同；
- Flag 改变后重新生成整棵 AOT Source Tree；
- 只有显式声明为 Profile-Mapped 的 Flag 才在有限 Target Matrix 中给每个 Row 一个值；
- `WITH_SERVER_CODE`、`COOK_COMMANDLET` 等未建模轴，要么冻结，要么新增真实 Row，不能仅用生成 C++ `#if` 假装另一侧 AST 已经存在；
- 不枚举任意项目 Flag 的 `2^N` 理论组合。

换言之，AST 方案消除的是“已支持 Profile 之间重复保存和重复生成相同 Body”，不是把所有可能的编译配置变成一个万能 Provider。

### 17.10 新 AST worktree 的当前真实成熟度

该 worktree 的记录给出的目标架构非常契合本方案，但截至 2026-08-22，必须保留以下事实：

- 默认生产 Compiler Pipeline 仍是 `LEGACY`；
- 当前是 migration platform + opt-in `CANONICAL` subset CodeGen；
- Parser 仍产生 `asCScriptNode` recovery tree，部分 `FromNode`/WalkOne 路径仍在迁移；
- `SemaAuthority 176/176`、`ProductionCodeGen 25/25`、`CanonicalAST 216/216` 是当前回归证据，不代表完整语言 Sema/CodeGen Authority；
- Public Snapshot、完整 Cache AST Body DTO、SourceManager、默认 CANONICAL cutover 仍未完成；
- review 状态仍是 `Request changes`，该 change 明确要求不要 archive；
- 当前 Canonical TypedASTJIT consumer 证明“后端可以读 sealed AST”，但支持面仍是有限子集。

因此，本 OpenSpec 的结论是架构兼容性判断：

> 等 Canonical AST 成为完整、可信的生产语义来源后，它应当直接承担 Multi-Profile Diff 的输入；在此之前可以先做只报告、不改变生成结果的子集实验，但不能用当前 AST sidecar/hash 宣称已经安全合并生产 AOT。

### 17.11 建议的渐进验证顺序（仍非实施任务）

1. **Canonical Hash 单元测试**：为 Decl/Stmt/Expr 写规范化 Hash；证明不同 Snapshot-local ID、插入顺序和纯 source range 不改变 Hash，resolved callee/type/control target 改变一定改变 Hash。
2. **Report-only Profile Overlay**：捕获 ED/GD/GS sealed AST，输出 Module/Type/Function Presence 和 1/2/3 Semantic Variant 分组，不改现有 `.jit.cpp`。
3. **`Reference/myas` 语料统计**：统计公共函数、一对二分组、三变体、只在一个 Profile 存在、Type Shape 提升和无法对齐的比例。
4. **函数级 Guarded Emit 实验**：只对 Stable Function、Entry ABI、依赖和 Native Route 都完全一致的标量子集共享 Body。
5. **Module/Function Presence**：支持顶层 `#if` 造成的 Decl Presence，不依赖目录；验证 Game Profile 不包含 Editor API 引用。
6. **Type Shape + Cache V2 ABI Overlay**：把 AST property/base/interface diff 与现有 Type Schema/Layout/Artifact Reference 结合，建立保守依赖闭包。
7. **单树 Provider/Inventory**：最后才把三份物理 Profile 输出迁移成一棵 Guarded Generated Source Tree；Provider Matcher 继续精确匹配每个 Target。

建议至少加入以下反例测试：

- ED 多一个顶层 Decl，后续所有 local ID 平移，但不相关函数仍应判定相同；
- 函数签名相同、ED 函数体多一个 Editor call，形成 `{ED}` + `{GD,GS}` 两组；
- 函数 AST 完全相同，但 Development safe-point policy 不同，Native Key 必须分裂；
- 条件 Property 改变布局，直接/间接读取它的函数被依赖闭包提升，无关纯函数继续共享；
- 条件 Method 只改变 Reflection Surface，不自动复制不引用它的所有方法；
- Lambda/同名 Local 在条件分支中出现，不能因数字 ID/ordinal 平移错误对齐；
- Profile-Mapped custom Flag 的每一 Row 都被捕获，未声明自定义 Flag 只作为 invariant；
- 某 Target Row 未生成 AST 时，生成器 Fail Closed，不能只发一个 C++ Guard。

### 17.12 最新结论

本轮建议可以压缩成：

> 不做强制目录划分，也不禁止现有 AS `#if`。让每个受支持 Target Profile 独立完成 Preprocess + Sema，得到 sealed Canonical Typed AST；以 Stable Module/Decl/Function Anchor 对齐三棵树，以规范化 Semantic Subtree Hash 找出真正相同的语义，再叠加 Type Layout、Entry ABI、Native Call Route 和 CodeGen Policy 得到最终 Native AOT Variant。只为唯一 Variant 生成一次 C++，并在同一 Generated Source Tree 中用精确 Profile Guard 选择。目录与文本缩进都不是共享安全性的权威。

这会得到用户期望的效果：

- 工程只维护一棵 Generated AOT C++ Source Tree；
- 大多数三 Profile 相同的函数只有一份 Body；
- 只有受条件语义、传递依赖、布局或原生策略影响的函数才有 2～3 个 Variant；
- 整模块/类/函数只在部分 Profile 存在也由同一套 Presence Mask 表达；
- Editor AS 可以继续写在最自然的 Gameplay 文件和函数位置；
- 三个 UE Target 仍各自编译原生二进制并使用精确 Catalog/ABI，不把安全性换成表面上的“一份代码”。
