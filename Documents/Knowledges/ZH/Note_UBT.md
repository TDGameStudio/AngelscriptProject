# Note_UBT — UBT 构建约束

> **所属前缀**: Note_（零散笔记族）
> **关注层面**: 站在"UnrealBuildTool 配置"视角看插件三个 C++ 模块 + 一个 C# UBT plugin 的非默认设置——`Build.cs` 里写了什么 / 没写什么、ThirdParty/ vendored 源是怎样进入 unity 编译的、`.ubtplugin.csproj` 怎样被 UBT 发现、`.uplugin` 的 `LoadingPhase` 与 Build.cs 的依赖头如何互锁；不写运行期模块装载顺序与 `StartupModule` 内部展开（详见 `Arch_ModuleLoading.md`），不写 UHT plugin 的代码生成 pipeline 与产物消费（详见 `Arch_UHTToolchain.md`），不写 vendored 内核的 fork 修改清单（详见 `RT_ThirdPartyKernel.md`）
> **关键源码**:
> `Plugins/Angelscript/Source/AngelscriptRuntime/AngelscriptRuntime.Build.cs` (~92 行)
> · `Plugins/Angelscript/Source/AngelscriptEditor/AngelscriptEditor.Build.cs` (~46 行)
> · `Plugins/Angelscript/Source/AngelscriptTest/AngelscriptTest.Build.cs` (~57 行)
> · `Plugins/Angelscript/Source/AngelscriptUHTTool/AngelscriptUHTTool.ubtplugin.csproj` (~54 行)
> · `Plugins/Angelscript/Source/AngelscriptUHTTool/AngelscriptUHTTool.ubtplugin.csproj.props` (~7 行，`$(EngineDir)` 兜底)
> · `Plugins/Angelscript/Angelscript.uplugin` (~50 行)
> **关联文档**:
> `Documents/Knowledges/ZH/Arch_ModuleLoading.md` — 模块清单与装载关系（本文是其 §二 Build.cs 物理依赖小节的"配置 flag"补集）
> · `Documents/Knowledges/ZH/Arch_UHTToolchain.md` — UHT 工具链位置与边界（本文聚焦 `.ubtplugin.csproj` 配置面，不重复 pipeline 细节）
> · `Documents/Knowledges/ZH/RT_ThirdPartyKernel.md` — ThirdParty 内核集成边界（本文聚焦 vendored 是怎样进入 Build.cs 的）
> · `Documents/Knowledges/ZH/Arch_Overview.md` — 插件总体概览

---

## 概览

本文聚焦一个核心问题：**插件在 UnrealBuildTool 阶段需要遵守哪些非默认约束？哪些 flag 是"刻意写"，哪些是"刻意没写"，哪些会因为漏写而踩坑？**

`Arch_ModuleLoading.md` 已经把"哪个模块依赖谁、按什么拓扑顺序加载"讲清楚；`Arch_UHTToolchain.md` 把"UHT plugin 的代码生成 pipeline"讲清楚；`RT_ThirdPartyKernel.md` 把"vendored 内核的 fork 修改清单"讲清楚。本文是这三篇的**配置面笔记**——把所有"散落在 `*.Build.cs` / `.ubtplugin.csproj` / `.uplugin` 里的非默认 flag、宏定义、目录约束"集中讲一遍。

```text
================================================================================
  UBT 阶段插件物料：四个文件 + 三类编译产物
================================================================================
                                                                                
  Plugins/Angelscript/                                                          
   │                                                                            
   ├── Angelscript.uplugin                              ← 模块清单 + LoadingPhase
   │                                                                            
   ├── Source/                                                                  
   │   ├── AngelscriptRuntime/                                                  
   │   │   ├── AngelscriptRuntime.Build.cs              ← ★ 非默认配置最多的一份
   │   │   │     PCHUsage = ExplicitOrSharedPCHs                                
   │   │   │     NumIncludedBytesPerUnityCPPOverride    (128 KB / 默认 384 KB)  
   │   │   │     PublicDefinitions += {WITH_ANGELSCRIPT, ...}                  
   │   │   │     PrivateDefinitions += {ANGELSCRIPT_EXPORT}                    
   │   │   │     OptimizeCode = Never (Debug/DebugGame only)                   
   │   │   │     PublicIncludePaths += ThirdParty/angelscript/source           
   │   │   ├── Core/                                    ← C++ 源 + 公共 SDK 头
   │   │   ├── ThirdParty/angelscript/source/           ← 88 个 vendored .cpp/.h
   │   │   └── Binds/                                   ← 121 份 Bind_*.cpp     
   │   │                                                                        
   │   ├── AngelscriptEditor/                                                   
   │   │   └── AngelscriptEditor.Build.cs               ← 极简配置，仅 PCHUsage 
   │   │                                                                        
   │   ├── AngelscriptTest/                                                     
   │   │   └── AngelscriptTest.Build.cs                 ← + AS_ENABLE_EDITOR_JITTED_CODE
   │   │                                                                        
   │   └── AngelscriptUHTTool/                          ← 旁路 C# UBT plugin    
   │       ├── AngelscriptUHTTool.ubtplugin.csproj      ← TargetFramework=net8.0
   │       └── AngelscriptUHTTool.ubtplugin.csproj.props ← $(EngineDir) 兜底    
   │                                                                            
   └── Binaries/DotNET/UnrealBuildTool/Plugins/                                 
       └── AngelscriptUHTTool/AngelscriptUHTTool.dll    ← UBT 旁路加载产物      

================================================================================
```

后续按 (一) `.uplugin` LoadingPhase → (二) Runtime Build.cs 非默认配置 → (三) Editor / Test Build.cs → (四) ThirdParty/ 怎样进 Build.cs → (五) UBT plugin csproj → (六) 平台条件 → (七) 增量约束 → 附录的顺序展开。

---

## 一、`.uplugin` 的模块清单与 LoadingPhase

```json
// ============================================================================
// 文件: Plugins/Angelscript/Angelscript.uplugin
// 角色: UBT 在配置阶段读取的模块清单；三模块齐心 PostDefault；强制启用三件外部插件
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

**UBT 视角的关键约束**：

- `Type` 决定**哪些 target 会编进该模块**：`Runtime` 进 game/editor/server 全套，`Editor` 仅在 `bBuildEditor == true` 的 target 才编。这条是 `*.Build.cs` 不需要再写 `if (Target.bBuildEditor)` 包裹整个文件的根本原因——Editor / Test 模块对 cooked client target 直接不参与编译。
- `LoadingPhase: PostDefault` 与 UBT 阶段无直接关系（这是运行期 `FModuleManager` 读取的字段），但通过它能反推 `*.Build.cs` 的设计取舍："可以 `LoadModuleChecked` 到的所有同 phase 模块" = 同一拓扑层内的兄弟。详见 `Arch_ModuleLoading.md` §一.2。
- `Plugins` 数组里三件——`StructUtils` / `PropertyBindingUtils` / `EnhancedInput`——**会被 UBT 在 Resolve 阶段强制启用**。这意味着：消费工程的 `<Project>.uproject` 即便没列这三件，UBT 也会自动拉它们的 `Build.cs` 进图，否则配置阶段直接报"unresolved module dependency"。

`AngelscriptRuntime.Build.cs` 显式列了 `PublicDependencyModuleNames` += `StructUtils` 与 `PrivateDependencyModuleNames` += `EnhancedInput`，这两条是**对内**消费；`PropertyBindingUtils` 仅在 `AngelscriptTest.Build.cs` 中作为 Public 依赖出现。三件外部插件的 `Enabled: true` 与三个 `Build.cs` 的 `DependencyModuleNames` 必须一致——任何只出现在一边的写法都会让 UBT 配置阶段报错或运行期 `LoadModuleChecked` 失败。

---

## 二、`AngelscriptRuntime.Build.cs`：所有非默认配置都集中在这

底座模块是配置面最重的一份。逐项解释：

```csharp
// ============================================================================
// 文件: Plugins/Angelscript/Source/AngelscriptRuntime/AngelscriptRuntime.Build.cs
// 角色: 五条非默认配置 + 三条 Definition + 一条 Debug 优化覆写 + ThirdParty 接入
// ============================================================================
public AngelscriptRuntime(ReadOnlyTargetRules Target) : base(Target)
{
    PCHUsage = PCHUsageMode.UseExplicitOrSharedPCHs;             // ① PCH 策略
    NumIncludedBytesPerUnityCPPOverride = 131072;                // ② Unity 块上限收窄
    PrivateDefinitions.Add("ANGELSCRIPT_EXPORT=1");              // ③ vendored 导出宏
    PublicDefinitions.Add("WITH_ANGELSCRIPT=1");                 // ④ 全局开关
    PublicDefinitions.Add("ANGELSCRIPT_DLL_LIBRARY_IMPORT=1");   // ⑤ DLL 导入兼容

    PublicIncludePaths.Add(ModuleDirectory);
    PrivateIncludePaths.Add(ModuleDirectory);
    PublicIncludePaths.Add(Path.Combine(ModuleDirectory, "Core"));
    PrivateIncludePaths.Add(Path.Combine(ModuleDirectory, "Core"));
    PublicIncludePaths.Add(Path.Combine(ModuleDirectory, "Core", "Commandlets"));
    PrivateIncludePaths.Add(Path.Combine(ModuleDirectory, "Core", "Commandlets"));

    var AngelscriptThirdPartyPath = Path.Combine(ModuleDirectory, "ThirdParty", "angelscript");
    PublicIncludePaths.Add(Path.Combine(AngelscriptThirdPartyPath, "source"));   // ★ vendored
    PublicIncludePaths.Add(AngelscriptThirdPartyPath);

    if (Target.Configuration == UnrealTargetConfiguration.Debug ||
        Target.Configuration == UnrealTargetConfiguration.DebugGame)
    {
        OptimizeCode = CodeOptimization.Never;                   // ⑥ Debug 全关优化
    }

    /* PublicDependencyModuleNames / PrivateDependencyModuleNames 略 */
}
```

### 2.1 ① PCH 策略：`UseExplicitOrSharedPCHs`

UE5 默认值依赖具体引擎版本，但社区惯用的"懒人"模式 `UseSharedPCHs` 会让本模块吃下 Engine 共享 PCH——对 121 份 `Bind_*.cpp` + 30 份 UHT 生成分片 + 88 份 vendored `as_*.cpp` 这种"include 模式高度异构"的源文件集是**反优化**。`UseExplicitOrSharedPCHs` 让 UBT 优先选模块内的 explicit PCH（`*.PrivatePCH.h` 形式），找不到再退回共享 PCH。

实际效果：vendored `as_*.cpp` 全部走 IWYU 风格自带 include；`Bind_*.cpp` 也是显式 include；UHT 分片带 `PRAGMA_DISABLE_DEPRECATION_WARNINGS` 包裹的自包含 include 列表（详见 `Arch_UHTToolchain.md` §三.3）。三类文件相互不污染对方的 PCH，热路径变更时增量编译范围最小。

### 2.2 ② Unity 块上限：`NumIncludedBytesPerUnityCPPOverride = 131072`

UE 默认 unity 块上限约 384 KB（`BuildConfiguration.NumIncludedBytesPerUnityCPP`），允许把多个小 .cpp 拼成一个大 .cpp 编译。本模块**主动收窄到 128 KB**——因为：

- 121 份 `Bind_*.cpp` 大多体积小但 include 链很重（每份都拉若干 `Engine/`、`UMG/`、`AIModule/` 头）；默认 384 KB 上限会把十几份 Bind 拼成一个 unity，预处理器输入到达数 MB，编译器单 TU 内存峰值过高、增量编译时一改一片小 Bind 就要重编整个 unity。
- vendored `as_*.cpp` 的 include 链相对独立，但单文件如 `as_compiler.cpp` / `as_scriptengine.cpp` 已逼近 5000 行；它们与小 .cpp 拼 unity 时反而拖慢编译。
- UHT 生成的 `AS_FunctionTable_*.cpp` 单分片本身就接近 256 entries × `AddFunctionEntry(...)` 一行（`MaxEntriesPerShard = 256`，详见 `Arch_UHTToolchain.md` §三.3）；拼 unity 没有收益。

128 KB 是社区经验值——足以让 2-3 份小 Bind 凑成一个 unity（保留 unity 提速优势），又能避免十几份 Bind 凑成大块（控制单 TU 重编代价）。

### 2.3 ③④⑤ 三条编译宏

- `ANGELSCRIPT_EXPORT=1`（**Private**）：vendored 头里的 `AS_API` / 相关导出宏在编译本模块时按"导出"语义解析（`__declspec(dllexport)`），下游模块编进时按"导入"语义解析（`__declspec(dllimport)`）。这是 UE 标准 `MODULENAME_API` 模式的一种 vendored 兼容形态，详见 `RT_ThirdPartyKernel.md` §二的"导出宏统一"分类。
- `WITH_ANGELSCRIPT=1`（**Public**）：全局 feature 开关——任何下游 / 工程代码可写 `#if WITH_ANGELSCRIPT` 做条件编译。本宏一旦改成 0 整个插件等价于不存在；当前没有"关闭 Angelscript 但保留头"的发布形态。
- `ANGELSCRIPT_DLL_LIBRARY_IMPORT=1`（**Public**）：与 `ANGELSCRIPT_EXPORT` 配对——本宏告知下游"我们走 DLL import 路径"，避免 vendored 头在静态库 target 下走错分支。这条是 UE 模块 ABI 与 vanilla AS 静态库二选一兼容的硬要求。

### 2.4 ⑥ Debug 配置全关优化

```csharp
if (Target.Configuration == UnrealTargetConfiguration.Debug ||
    Target.Configuration == UnrealTargetConfiguration.DebugGame)
{
    OptimizeCode = CodeOptimization.Never;
}
```

`OptimizeCode.Default` 在 UE 标准下表现为"按 target 全局优化级别走"——`DebugGame` target 默认其它模块仍优化，仅本模块的源会被优化。本插件**显式关掉**——动机是 vendored AS 内核的解释器主循环 (`asCContext::ExecuteNext`) 与编译器主循环 (`asCCompiler::CompileStatement`) 在 `O2` 下大量内联展开，调试时几乎不能 step into。`Never` 让这两段在 Debug / DebugGame 配置里保留完整源行映射，方便 LLM scope / asBC_ 字节码追踪。Development / Shipping 配置走 UE 默认优化级别（`Default`）。

### 2.5 IncludePath 三件：Core / ThirdParty / Commandlets

`PublicIncludePaths` 与 `PrivateIncludePaths` **同时**追加 `ModuleDirectory` / `Core` / `Core/Commandlets`——同时追加是因为这三个目录都既被本模块自己 include（Private），又被下游 Editor / Test / 消费工程 include（Public）。`ThirdParty/angelscript/source` **只放在 PublicIncludePaths**——同样的原因（Editor / Test 与 Bind_*.cpp 都需要 `as_scriptengine.h` 等头）。详见 §四对 vendored 接入的展开。

---

## 三、`AngelscriptEditor.Build.cs` / `AngelscriptTest.Build.cs`：减法配置

### 3.1 Editor 模块：除了 PCH 几乎是默认

```csharp
// ============================================================================
// 文件: Plugins/Angelscript/Source/AngelscriptEditor/AngelscriptEditor.Build.cs
// 角色: 编辑器扩展模块；除 PCHUsage 外没有任何 BuildConfiguration 覆写
// ============================================================================
PCHUsage = PCHUsageMode.UseExplicitOrSharedPCHs;
PublicIncludePaths.Add(ModuleDirectory);
PrivateIncludePaths.Add(ModuleDirectory);

// 仅 DependencyModuleNames，无 Definitions / Override / 平台条件
```

——除了 `PCHUsage` 与本模块根目录的 include 路径之外，**完全用 UE 默认值**。意义：

- 没有 `NumIncludedBytesPerUnityCPPOverride`：Editor 模块的 `.cpp` 都是 1k-3k 行的"扩展点注册器"，与 Runtime 的 121 份小 Bind 形态完全不同，UE 默认 unity 上限对它已经合适。
- 没有 `Definitions`：Editor 模块不引入任何编译宏——所有需要条件编译的扩展点都在 Runtime / Engine 已有宏（`WITH_EDITOR` / `WITH_DEV_AUTOMATION_TESTS` 等）下分支。
- 没有 `OptimizeCode` 覆写：Editor 主线代码不参与解释器热路径调试，跟随 UE 默认。
- 没有 `bBuildEditor` 包裹：因为 `.uplugin` 已声明 `Type: "Editor"`，整个模块在 cooked client target 下不参与编译——再做条件追加是多余的。

### 3.2 Test 模块：唯一非默认是一条 Definition

```csharp
// ============================================================================
// 文件: Plugins/Angelscript/Source/AngelscriptTest/AngelscriptTest.Build.cs
// 角色: 测试模块；仅追加 AS_ENABLE_EDITOR_JITTED_CODE=1 一条 Definition
// ============================================================================
PCHUsage = PCHUsageMode.UseExplicitOrSharedPCHs;
PrivateDefinitions.Add("AS_ENABLE_EDITOR_JITTED_CODE=1");        // ★

PublicIncludePaths.Add(ModuleDirectory);
PrivateIncludePaths.Add(ModuleDirectory);
PrivateIncludePaths.Add(Path.Combine(ModuleDirectory, "Core"));
PrivateIncludePaths.Add(Path.Combine(ModuleDirectory, "Debugger"));
PrivateIncludePaths.Add(Path.Combine(ModuleDirectory, "Dump"));
PrivateIncludePaths.Add(Path.Combine(ModuleDirectory, "AngelScriptSDK"));
PrivateIncludePaths.Add(Path.Combine(ModuleDirectory, "Preprocessor"));
PrivateIncludePaths.Add(Path.Combine(ModuleDirectory, "ClassGenerator"));
```

`AS_ENABLE_EDITOR_JITTED_CODE=1` 是 `PrivateDefinitions`（不传染下游）——它启用 Test 模块内对 StaticJIT 透明性的额外断言（详见 `RT_StaticJIT.md` 测试章节）。本宏只在 Test 模块 `.cpp` 里引用，不出现在任何 `.h`，所以走 Private。

注意 Test 模块用了 6 个 `PrivateIncludePaths.Add` 暴露内部子目录——这是因为 Test 套件内部源文件层级较深，又不希望让下游/同级 Editor 模块 include 这些路径。Public/Private 一边倒地选 Private 是测试模块的常见信号。

### 3.3 一表汇总三模块的非默认配置

| 配置项 | Runtime | Editor | Test |
|--------|---------|--------|------|
| `PCHUsage` | `UseExplicitOrSharedPCHs` | `UseExplicitOrSharedPCHs` | `UseExplicitOrSharedPCHs` |
| `NumIncludedBytesPerUnityCPPOverride` | `131072`（128 KB） | 默认 | 默认 |
| `PublicDefinitions` | `WITH_ANGELSCRIPT=1` / `ANGELSCRIPT_DLL_LIBRARY_IMPORT=1` | — | — |
| `PrivateDefinitions` | `ANGELSCRIPT_EXPORT=1` | — | `AS_ENABLE_EDITOR_JITTED_CODE=1` |
| `OptimizeCode` 覆写 | Debug/DebugGame → `Never` | — | — |
| `bUseUnity` / `bEnforceIWYU` / `bUseRTTI` / `bEnableExceptions` | **未覆写**（全部走 UE 默认） | 未覆写 | 未覆写 |
| ThirdParty include | `PublicIncludePaths += ThirdParty/angelscript/source` | — | — |

——**三个模块都没有显式覆写 `bUseRTTI` / `bEnableExceptions`**：vendored AS 内核已经被 fork 改造成不依赖 C++ 异常（详见 `Arch_ErrorDiagnostics.md` 与 `RT_ThirdPartyKernel.md` §二的析构期补丁），可以直接跑在 UE 默认的"无 RTTI / 无异常"配置下。

---

## 四、ThirdParty/ 是怎么进 `Build.cs` 的

vendored AS 内核的物理位置是 `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/`，88 个 `as_*.cpp/h` + 平台 callfunc 实现。它进 Build.cs 的方式**与 UE 标准 `ThirdParty` 模式完全不同**：

```csharp
// ============================================================================
// 文件: AngelscriptRuntime.Build.cs
// 节选自: ThirdParty 接入（约 23-25 行）
// ============================================================================
var AngelscriptThirdPartyPath = Path.Combine(ModuleDirectory, "ThirdParty", "angelscript");
PublicIncludePaths.Add(Path.Combine(AngelscriptThirdPartyPath, "source"));   // ★
PublicIncludePaths.Add(AngelscriptThirdPartyPath);
```

——只是**加一条 PublicIncludePaths**。没有 `PublicAdditionalLibraries`（不链接预编译 .lib），没有 `RuntimeDependencies`（不带 .dll），没有独立的 `ThirdParty.Build.cs`。所有 `as_*.cpp` 与 plugin core 的 `.cpp` **一起被 UBT 的同一个 unity 编译器编进 `AngelscriptRuntime.dll/lib`**。

这背后的设计取舍是：

- **传统 `ThirdParty` 模式**（如 zlib、libcurl）：vendored 是一份**独立 .Build.cs**，编出 `.lib` 后由消费模块链接；vendored 与消费模块的 ABI 边界明确。
- **本插件的 vendored 模式**：vendored 与 plugin core **共享同一份 unity 编译**，没有 ABI 边界。这是因为 fork 已经把 vendored 改造到深度依赖插件层头（`as_builder.cpp` `#include "AngelscriptEngine.h"`，详见 `RT_ThirdPartyKernel.md` §六.1），强行做 `.lib` 边界会让循环依赖无法解开。

具体效果：

1. **任何 vendored `as_*.cpp` 改动 = 整个 `AngelscriptRuntime` 模块 unity rebuild**——没有独立链接边界做局部替换。
2. **vendored 头与 plugin 头双向 include**：`Bind_*.cpp` 可以 `#include "as_scriptengine.h"`，反向 `as_builder.cpp` 也能 `#include "AngelscriptEngine.h"`——后者在 vanilla AS 中永远不会出现。
3. **没有"vendored only" 的 RTTI / 异常 / 优化设置**：因为 vendored 与 plugin core 共编一个目标，所有 BuildConfiguration 覆写（`PCHUsage` / `OptimizeCode` / Definitions）一并生效。

注意 `PrivateIncludePaths` **没有**追加 ThirdParty 路径——只有 `PublicIncludePaths`。原因：Editor / Test / 消费工程的 `.cpp` 也可能 `#include "as_scriptengine.h"`（如调试器面板），所以走 Public。Private 路径在该模块 .cpp 内已通过 Public 路径解析，不需要重复。

---

## 五、`AngelscriptUHTTool.ubtplugin.csproj`：UBT 怎么发现这套 C# 工具

UHT plugin 是**插件包内唯一不属于 UE Module 体系**的产物——`.NET 8.0` 的 C# DLL，不出现在任何 `Build.cs` 的 `DependencyModuleNames`，也不出现在 `.uplugin` 的 `Modules` 数组。它通过**文件扩展名**被 UBT 自动发现：

```xml
<!-- ============================================================================ -->
<!-- 文件: Plugins/Angelscript/Source/AngelscriptUHTTool/AngelscriptUHTTool.ubtplugin.csproj
       角色: C# 类库；UBT 在配置阶段扫描 *.ubtplugin.csproj 自动 build/load   -->
<!-- ============================================================================ -->
<TargetFramework>net8.0</TargetFramework>
<OutputType>Library</OutputType>
<OutputPath>..\..\Binaries\DotNET\UnrealBuildTool\Plugins\AngelscriptUHTTool\</OutputPath>
<TreatWarningsAsErrors>true</TreatWarningsAsErrors>            <!-- ★ 警告即错误 -->
<Nullable>enable</Nullable>                                    <!-- ★ 强制 nullable 检查 -->

<Reference Include="EpicGames.Build">  <HintPath>$(EngineDir)/.../EpicGames.Build.dll</HintPath></Reference>
<Reference Include="EpicGames.Core">   <HintPath>$(EngineDir)/.../EpicGames.Core.dll</HintPath></Reference>
<Reference Include="EpicGames.UHT">    <HintPath>$(EngineDir)/.../EpicGames.UHT.dll</HintPath></Reference>
<Reference Include="UnrealBuildTool">  <HintPath>$(EngineDir)/.../UnrealBuildTool.dll</HintPath></Reference>
```

**UBT 的发现机制**：UBT 在配置阶段递归扫描所有 `Plugins/*/Source/` 下的 `*.ubtplugin.csproj`，对每份做 `dotnet build` 并加载产物 `.dll`。`.dll` 内的 `[UnrealHeaderTool]` + `[UhtExporter]` 标注被 UnrealHeaderTool 拾取并执行（详见 `Arch_UHTToolchain.md` §一.2）。

**配套的 props 文件**：

```xml
<!-- 文件: AngelscriptUHTTool.ubtplugin.csproj.props -->
<PropertyGroup>
    <EngineDir Condition="'$(EngineDir)' == ''">C:\UnrealEngine\UE_5.7\Engine</EngineDir>
</PropertyGroup>
```

`$(EngineDir)` 是四条 `<Reference>` 中 `HintPath` 的根。优先取 UBT 注入的环境变量；若该变量为空（如手动 IDE 打开 csproj、`dotnet build` 单独跑），fallback 到硬编码的 `C:\UnrealEngine\UE_5.7\Engine`。**这条 fallback 是开发者机器 specific**——CI 环境通过 UBT 自动注入正确路径，不会走到 fallback；开发者机器若引擎装在别的路径，需要本地修改这一行（不要 commit）或导出 `EngineDir` 环境变量。

`TreatWarningsAsErrors=true` + `Nullable=enable` 是 UE 引擎自带 UBT 工具的统一规范——禁止任何 C# 编译警告（包括 nullable 风险），保证构建期"零容忍"。

`AngelscriptUHTTool.cs` 文件本身只有一行 `internal static class AngelscriptUHTToolModule {}` —— 真正的入口在 `AngelscriptFunctionTableExporter.cs`，通过 `[UhtExporter]` 标注向 UHT 自我注册。

---

## 六、平台条件：本插件几乎不写

UE 标准 Build.cs 常见的平台分支（`Target.Platform == UnrealTargetPlatform.Win64 / Mac / Linux / Android / IOS`）**在本插件三个 Build.cs 中完全不出现**。原因：

- vendored AS 内核自带平台抽象：`as_callfunc_x86.cpp` / `as_callfunc_x64_msvc.cpp` / `as_callfunc_arm64*.{cpp,asm,S}` / `as_callfunc_ppc.cpp` 等通过 `as_config.h` 内的预处理器 `#if defined(_M_X64) || ...` 自我筛选，UBT 只需把所有文件加进编译图，编译器层面会在每个 `.cpp` 内 `#if 0`-out 不适用平台。
- 没有 Console / Mobile **排除**条件：意味着本插件原则上能编进所有 UE 支持的平台。但实际跑通的目标主要是 Win64 + Mac + Linux 编辑器；Console / Mobile 主机平台未做端到端验证。
- `Target.bBuildEditor` 是唯一的条件分支，且只出现在 Runtime（追加 `UnrealEd` / `EditorSubsystem` / `UMGEditor`）与 Test（追加 Editor 主题测试依赖）中。详见 `Arch_ModuleLoading.md` §二。

**潜在踩坑**：如果未来某个 vendored 平台 callfunc 在 UE 5.x 升级到新工具链后编译失败（如 ARM64 macOS），最快的修复路径是在 vendored 内的 `as_config.h` 增加平台条件 `#if !defined(__APPLE__) || ...` 屏蔽——**不**要在 Runtime Build.cs 里写 `if (Target.Platform != UnrealTargetPlatform.Mac)` 把整文件踢掉，那会破坏其它平台的 ABI 一致性。

---

## 七、UBT 增量约束：哪些改动会触发全量重编

```text
改动类型                                         增量代价
================================================================================
Bind_<Topic>.cpp 单文件改动                       仅该 .cpp + 所属 unity 块（< 5 文件）重编
                                                  + Runtime.dll 重链接

ThirdParty/angelscript/source/as_<file>.cpp      全 Runtime.dll unity rebuild
                                                  （vendored 与 plugin core 同 unity 池）

Core/AngelscriptEngine.h（公共头改动）            全 Runtime.dll + 所有依赖 Editor/Test 文件重编
                                                  （header 改动通过 Public include 链传染）

AngelscriptRuntime.Build.cs（任何字段改动）       UBT 重生成 makefile + 全 Runtime 重编
                                                  + UHT 重跑（详见 Arch_UHTToolchain §七）

.uplugin Modules / Plugins 改动                   UBT 重 Resolve + 受影响模块全编

UHT plugin .cs 改动                              UBT 重 build .ubtplugin.dll → 重跑 UHT
                                                  → AS_FunctionTable_*.cpp 内容若变 → Runtime 全编

UCLASS/UFUNCTION 头改动（任意 UE 模块）           UHT 重跑 → 受影响 AS_FunctionTable_<Module>_*.cpp
                                                  → Runtime 该分片重编（UBT 内容 hash 比对）
```

### 7.1 一致性 `Bind_*.cpp` vs `Runtime API` 改动的差异

- **`Bind_*.cpp` 改动**：121 份手写 Bind 中改一份，触发的是该 .cpp 所在 unity 块（`NumIncludedBytesPerUnityCPPOverride = 131072` 限制下通常 2-3 份）的重编 + `AngelscriptRuntime.dll` 重链接。耗时通常 < 30 秒。
- **`AngelscriptEngine.h` / `Core/*.h` 改动**：通过 Public include 链传染，所有 include 该头的 .cpp 都会重编——这包括 121 份 Bind + 30 份 UHT 分片 + 88 份 vendored `as_*.cpp`（如果该头被 vendored 反向 include） + Editor / Test 模块所有引用本头的源。冷启动可能数分钟。

### 7.2 UBT 增量依赖

UBT 通过三类机制实现增量：

- **C++ 头文件 mtime + content hash**：标准 Make 依赖图。
- **Build.cs 改动 → UBT 重生成 makefile**：本插件的 `AngelscriptRuntime.Build.cs` 还被 UHT plugin **声明为外部依赖**（`factory.AddExternalDependency(buildCsPath)`，详见 `Arch_UHTToolchain.md` §二.2）——这意味着 Build.cs 改了 UHT 也一定重跑。
- **UHT plugin .cs 改动 → UBT 重 build C# DLL → UHT 自动重新加载**：通过 `*.ubtplugin.csproj` 自身的 `.cs` 列表与依赖。

### 7.3 不会触发重编的改动

- `.as` 脚本文件改动：与 UBT 完全脱钩，由 `DirectoryWatcher + ClassReloadHelper` 在运行期处理（详见 `RT_HotReload.md`）。
- `Documents/` 文档改动：不参与 UBT 任何阶段。
- `Plugins/Angelscript/Intermediate/` 改动：本身就是 UBT 产出目录，改动会被下次构建覆盖。
- `Reference/angelscript-v2.38.0/` vanilla 镜像改动：仅作为查阅参考，不参与编译。

---

## 附录 A：关键 flag 速查

| flag | 文件 | 值 | 含义 |
|------|------|-----|------|
| `PCHUsage` | 三个 Build.cs | `UseExplicitOrSharedPCHs` | 优先 explicit PCH，避免本模块吃下不合适的共享 PCH |
| `NumIncludedBytesPerUnityCPPOverride` | Runtime.Build.cs | `131072` (128 KB) | 收窄 unity 块上限，避免小 Bind 与大 vendored 拼成超大 TU |
| `OptimizeCode` | Runtime.Build.cs | `Never`（仅 Debug/DebugGame） | 保留 vendored 主循环可调试性 |
| `WITH_ANGELSCRIPT` | Runtime.Build.cs（Public） | `1` | 全局 feature 开关 |
| `ANGELSCRIPT_EXPORT` | Runtime.Build.cs（Private） | `1` | vendored 头按导出语义解析 |
| `ANGELSCRIPT_DLL_LIBRARY_IMPORT` | Runtime.Build.cs（Public） | `1` | 下游按 DLL 导入解析 |
| `AS_ENABLE_EDITOR_JITTED_CODE` | Test.Build.cs（Private） | `1` | Test 内 StaticJIT 透明性断言 |
| `TargetFramework` | UHTTool.csproj | `net8.0` | C# 运行时版本，与 UE 5.7 UBT 对齐 |
| `TreatWarningsAsErrors` | UHTTool.csproj | `true` | UBT plugin 零警告强制 |
| `Nullable` | UHTTool.csproj | `enable` | C# nullable 检查强制 |
| `LoadingPhase` | .uplugin 三模块 | `PostDefault` | 见 `Arch_ModuleLoading` §一.1 |

——所有"未列出"的 flag（`bUseUnity` / `bEnforceIWYU` / `bUseRTTI` / `bEnableExceptions` / `CppStandard` / `IWYUSupport` 等）均**走 UE 默认值**。如果未来发现需要覆写，先读 `Arch_ModuleLoading.md` §二评估传染面再下笔。

---

## 附录 B：常见构建错误诊断

| 现象 | 候选原因 | 验证手段 |
|------|---------|---------|
| **A** 配置阶段报 "unresolved module dependency: StructUtils / EnhancedInput / PropertyBindingUtils" | 消费工程 `.uproject` 没启用相应插件，且 UE 自动启用链路被打破 | 检查 `.uplugin` 的 `Plugins` 数组是否完整；必要时在 `.uproject` 显式启用 |
| **B** Runtime 编译报 vendored 头里的符号 redefined | `ANGELSCRIPT_EXPORT` 与 `ANGELSCRIPT_DLL_LIBRARY_IMPORT` 都设为 1 / 都设为 0 | 二者必须互补：本模块编译时 `EXPORT=1` + 默认 `IMPORT` 由头里再判定 |
| **C** UHT 阶段找不到 `EpicGames.UHT.dll` | `$(EngineDir)` 解析失败 / 引擎路径硬编码不对 | 检查 `*.ubtplugin.csproj.props` 的 fallback；导出 `EngineDir` 环境变量到 IDE |
| **D** Debug 配置下 step into vendored 进 disassembly | 忘了 `OptimizeCode = Never` 的条件 / 修改成 Default | 复查 Runtime.Build.cs 第 27-30 行 |
| **E** unity 块编译耗时数分钟 | `NumIncludedBytesPerUnityCPPOverride` 被改大 / 被删除 | 复查 `131072`；若需要调，每次按 64 KB 步长加减 |
| **F** Editor 模块在 cooked client 报"找不到 UnrealEd" | `.uplugin` 中 Editor 模块 `Type` 写错（写成 `Runtime`） | 必须保留 `Type: "Editor"`；UBT 据此自动剔除 cooked target |
| **G** `*.Build.cs` 改完 UHT 没重跑 | UBT 缓存或 IDE 没重 Resolve | 删 `Plugins/Angelscript/Intermediate/Build/`；`AddExternalDependency(buildCsPath)` 应保证 UHT 重跑（详见 `Arch_UHTToolchain.md` §二.2） |
| **H** ThirdParty 改动只编一份 .cpp 后链接报符号缺失 | unity 池没正确重 unity（极少见 UBT bug） | clean rebuild Runtime；该问题在 UE 5.6+ 已基本绝迹 |
| **I** 平台编译报 ARM64 callfunc 汇编错 | vendored 平台 callfunc 文件未参与编译，或 `as_config.h` 未识别 | 在 vendored `as_config.h` 内加平台分支；不要在 Build.cs 排除文件 |
| **J** UHT plugin C# 编译失败 "warning treated as error" | `Nullable=enable` 触发 / 新写的 .cs 未处理 nullable | 修代码而非改 csproj；`TreatWarningsAsErrors=true` 是 UE 规范 |

---

## 小结

- **三个 C++ 模块的 Build.cs 配置是"减法"风格**：除 Runtime 的六条非默认配置（PCHUsage / Unity 块上限 / 三条 Definition / Debug 优化覆写）外，几乎全部走 UE 默认；Editor 极简、Test 仅多一条 `AS_ENABLE_EDITOR_JITTED_CODE`。
- **三条编译宏构成 vendored 与 plugin core 的 ABI 桥**：`ANGELSCRIPT_EXPORT`（Private 编译时） + `ANGELSCRIPT_DLL_LIBRARY_IMPORT`（Public 下游） + `WITH_ANGELSCRIPT`（全局 feature 开关），缺一不可。
- **vendored ThirdParty 不走 UE 标准 ThirdParty 模式**：仅 `PublicIncludePaths.Add(source/)`，与 plugin core 共享同一份 unity 编译，无独立 .lib 边界——这是 fork 反向引用插件层头的必然结果。
- **UHT plugin 通过 `*.ubtplugin.csproj` 文件名被 UBT 自动发现**，与 `.uplugin` / `Build.cs` 完全脱钩；`net8.0` + `TreatWarningsAsErrors` + `Nullable=enable` 三条与 UE 引擎自带 UBT 工具的规范一致。
- **没有显式平台条件**：vendored 自带平台抽象（10+ 份 `as_callfunc_*` 由 `as_config.h` 自筛），三个 Build.cs 唯一的条件分支是 `Target.bBuildEditor`，详见 `Arch_ModuleLoading.md` §二。
- **增量约束三类**：单 `Bind_*.cpp` 改动代价最小（< 5 文件 unity 重编）；vendored 改动等于全 Runtime rebuild；公共头与 Build.cs 改动会通过 Public include 链或 UBT 依赖图传染至全部下游。
- **不能踩的坑**：不要在 Runtime Build.cs 里加平台排除（破坏 vendored 平台抽象）；不要把 `OptimizeCode = Never` 扩到 Development（拖慢真实测试）；不要在消费工程的 `.uproject` 里关掉 `StructUtils` / `EnhancedInput` / `PropertyBindingUtils`（链路直接断）。
