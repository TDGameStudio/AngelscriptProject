# RT_ThirdPartyKernel — ThirdParty 内核集成边界

> **所属前缀**: RT_（运行时子系统族）
> **关注层面**: 站在"`ThirdParty/angelscript/source/` 这份 vendored AS 内核如何被组织、与上游 vanilla AS 如何 fork divergence、哪些 2.38 特性已经 selective backport、哪些刻意不 backport、哪些边界不能跨"的角度，把 fork 策略、源码修改边界、升级与维护流程、上游 bug 处置方式串成一篇可查的索引。本文不写 `asCScriptEngine` / `asCContext` / `asCCompiler` 等具体子系统的内部实现（那是 `AS_ScriptEngine.md` / `AS_VirtualMachine.md` / `AS_Compiler.md` 的事），不写 fork 修改的详细分类汇总（那是 `AS_ForkDifferences.md` 的事），不写"如何把脚本类型映射到 UE 反射"（那是 `Type_ClassGeneration.md` 的事），不写 cook 期 transpile 的代码生成细节（那是 `RT_StaticJIT.md` 的事）；本文聚焦的是 **ThirdParty 内核作为一份 vendored 源码模块在工程中的边界**：vendored 位置、`[UE++]` 标记的语义、selective backport 清单、不该 patch 的边界、上游升级的可行性评估、和与 plugin core 协作的接缝。
> **关键源码**:
> `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/` (~88 个 .cpp/.h 文件 + ~10 个平台相关 callfunc 实现，唯一目录结构)
> · `Plugins/Angelscript/Source/AngelscriptRuntime/Core/angelscript.h` (~46 KB，公共 SDK 头，`ANGELSCRIPT_VERSION = 23300` / `"2.33.0 WIP"` 标识)
> · `Plugins/Angelscript/Source/AngelscriptRuntime/AngelscriptRuntime.Build.cs` (`PublicIncludePaths.Add(ThirdParty/angelscript/source)` + `PrivateDefinitions.Add("ANGELSCRIPT_EXPORT=1")`)
> · `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_config.h` (~1300+ 行，所有编译期 feature flag / 平台选择)
> · `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_memory.{h,cpp}` (~200 行，AS-internal 分配走 `AngelscriptSDK::SDKAlloc` / `FMemory::Malloc`)
> · `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_module.{h,cpp}` (`PreClassData` / `baseModuleName` / `ReloadState` / 2.38 backport 入口集中地)
> · `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_parser.cpp` / `as_compiler.cpp` (`ParseForeach` / `CompileForeachStatement` 等已落地 2.38 特性)
> · `Documents/Guides/AngelscriptForkStrategy.md` (~118 行，fork 策略权威文档)
> · `Documents/Guides/ASSDK_Fork_Differences.md` (~335 行，fork 与 vanilla 在脚本层的客观差异列表)
> **关联文档**:
> `Documents/Knowledges/ZH/AS_ForkDifferences.md` — `[UE++]/[UE--]` 标记的修改分类汇总（本文不重复其细目，仅给出摘要 + 跳转）
> · `Documents/Knowledges/ZH/AS_ScriptEngine.md` — `asCScriptEngine` 的内部架构（本文聚焦其外层"vendored 源" 的边界）
> · `Documents/Knowledges/ZH/AS_Compiler.md` / `AS_Parser.md` / `AS_VirtualMachine.md` — 各子系统内部实现（本文不重复其细节）
> · `Documents/Knowledges/ZH/RT_StaticJIT.md` — JIT v1 当前实现 + JIT v2 为何暂未 backport
> · `Documents/Knowledges/ZH/RT_HotReload.md` — `asCModule::ReloadState` / `PreClassData` 与热重载链路如何耦合
> · `Documents/Knowledges/ZH/RT_HashMetadata.md` — `CombinedDependencyHash` 在 fork 中如何挂到 `asIScriptModule::SetUserData`
> **外部参考**:
> [AngelScript 官网](https://www.angelcode.com/angelscript/) — 上游 2.38 changelog 与 BNF / API 文档
> · `Reference/angelscript-v2.38.0/sdk/` — 本仓库镜像的 2.38 参考源码（通过 `Tools\PullReference\PullReference.bat angelscript` 拉取）

---

## 概览

本文聚焦一个核心问题：**`ThirdParty/angelscript/` 这份 vendored 源码在仓库里到底是"AS 2.33 的某个版本快照"，还是"已经走得太远、再也回不去 vanilla 的一份独立 fork"？回答这个问题决定了今后每一次"上游有改动，要不要拉过来"的决策——到底是 cherry-pick、wrap、还是直接放弃。本文从五个角度同时回答：(1) vendored 在哪、组织形式是什么；(2) `[UE++]` 标记的语义与覆盖面；(3) 已 backport 的 2.38 能力清单 + 落地形态；(4) 故意不 backport 的清单 + 拒绝原因；(5) 与 plugin core / cook / hot reload 的接缝是什么。**

```text
================================================================================
  ThirdParty/angelscript/ 在工程中的位置（不是黑盒，但也不是普通源码）
================================================================================

  Plugins/Angelscript/Source/AngelscriptRuntime/
   │
   ├── Core/                       ← 插件层（自由编辑）
   │     angelscript.h             ← 公共 SDK 头。fork 在此扩展了 12 条
   │                                  字节码（asBC_FinConstruct..asBC_ThrowException）
   │                                  和 18+ 条 engine property，但版本号仍是
   │                                  ANGELSCRIPT_VERSION = 23300, "2.33.0 WIP"
   │     AngelscriptEngine.{h,cpp} ← FAngelscriptEngine（plugin core 入口）
   │     ...
   │
   ├── ThirdParty/angelscript/     ← vendored 内核（受 [UE++]/[UE--] 边界保护）
   │   └── source/                 ← 唯一目录，无 include / VERSION / CHANGELOG
   │       as_config.h             ← 平台选择 + ANGELSCRIPTRUNTIME_API 定义
   │       as_memory.{h,cpp}       ← FMemory + LLM_SCOPE_BYTAG(Angelscript)
   │       as_scriptengine.{h,cpp} ← asCScriptEngine
   │       as_module.{h,cpp}       ← APV2 模块系统 + 2.38 lookup API
   │       as_parser.cpp           ← + ParseForeach / lambda 半移植
   │       as_compiler.cpp         ← + CompileForeachStatement
   │       as_restore.cpp          ← 2.38 恢复器表面 + 2.33 字节码桥接
   │       as_typeinfo.{h,cpp}     ← flags 拓宽到 asQWORD（保留 APV2 私有高位）
   │       as_objecttype.{h,cpp}   ← shadowType + AddPropertyToClass(isInherited)
   │       as_callfunc_*           ← 平台相关 native 调用约定（基本未改）
   │       ...                    （88 个文件，其中 32 个含 [UE++] 标记，
   │                                累计 98 处 [UE++] / 76 处 [UE--]）
   │
   └── Build.cs
         PublicIncludePaths.Add(ThirdParty/angelscript/source)
         PrivateDefinitions.Add("ANGELSCRIPT_EXPORT=1")
         PublicDefinitions.Add("WITH_ANGELSCRIPT=1")

  ┌──────────────────────────────────────────────────────────────────────┐
  │ 关键事实                                                             │
  │   1. vendored 树**没有**单独的 .Build.cs、Library/、include/，         │
  │      它和 Core/ 一起被 AngelscriptRuntime 模块整体编译为 .dll。       │
  │   2. 公共 SDK 头 angelscript.h 不在 ThirdParty/，被刻意"提"到 Core/，  │
  │      插件可以在头里直接 #include "CoreMinimal.h"、"FunctionCallers.h"。│
  │   3. 没有 VERSION / CHANGELOG 文件——仅靠 angelscript.h 内的           │
  │      ANGELSCRIPT_VERSION 23300 + "2.33.0 WIP" 标识基线，              │
  │      具体改动量靠 [UE++] / [UE--] 注释定位与统计。                   │
  └──────────────────────────────────────────────────────────────────────┘
```

后续按 (一) vendored 现状 → (二) 标记体系 → (三) 已吸收 2.38 → (四) 拒绝吸收 → (五) JIT v2 案例 → (六) 边界守则 → (七) 升级流程 → 附录的顺序展开。

---

## 一、Vendored 现状：一份 fork，不是某个版本

### 1.1 基线版本声明

公共 SDK 头依然把版本号留在 2.33：

```cpp
// ============================================================================
// 文件: Plugins/Angelscript/Source/AngelscriptRuntime/Core/angelscript.h
// 节选自: 版本号宏（约 67-69 行）
// ============================================================================
// AngelScript version

#define ANGELSCRIPT_VERSION        23300
#define ANGELSCRIPT_VERSION_STRING "2.33.0 WIP"
```

但只看版本号是会被骗的——按 `AGENTS.md` 的 baseline 表述，当前内核是 **`2.33 + selective 2.38 compatibility`**，并且：

- 内核 88 个文件中有 32 个带 `[UE++]` 标记，累计 98 处 `[UE++]` / 76 处 `[UE--]`
- 已经从 2.38 吸收了 foreach 解析 / 模块 lookup API / 导入函数 traits / 恢复器表面 / 类型 flags 拓宽 / 内存池清理逻辑 / context API 扩展
- 同时把 12 条新字节码（`asBC_FinConstruct` (201) … `asBC_ThrowException` (212)）扩到了上游永远不会出现的指令空间
- 把 18+ 条 engine property（`asEP_INIT_STACK_SIZE` … `asEP_FOREACH_SUPPORT`，再后面是 fork 自己的 `asEP_AUTOMATIC_IMPORTS` 等）填进了 `asEEngineProp`

`AngelscriptForkStrategy.md` 把这件事讲得最直白：

> **当前 ThirdParty/angelscript 已经是一个深度定制的 fork，不是、也不再可能是 vanilla AngelScript 的某个版本。**
> 当前 fork 基于 2.33 WIP 起步，经过大量 `[UE++]` 改造（78 个源文件中 32 个包含定制标记，累计 73+ 处显式改动），已经在内存管理、模块系统、对象类型、编译器、解析器、恢复器、类型系统等核心面形成了与上游不可调和的结构分叉。

也就是说 vendored 树今天的角色 **不是** "vanilla 2.33 的快照"，而是 **"以 2.33 为起点、长期偏离上游、但保留 [UE++] 标记便于 3-way merge 的独立 fork"**。任何"整包替换为 2.38"的设想必须放弃；唯一路径是 selective absorption。

### 1.2 vendored 目录结构

vendored 树在物理上极简：

```text
Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/
└── angelscript/
    └── source/                  ← 唯一目录
        as_array.h
        as_atomic.{h,cpp}
        as_builder.{h,cpp}
        as_bytecode.{h,cpp}
        as_callfunc*.{cpp,h,asm,S}    ← x86 / x64 / ARM / ARM64 / MIPS / PPC / 
                                         RISC-V / Xenon / SH4 / E2K 平台 native 调用
        as_compiler.{h,cpp}
        as_config.h
        as_configgroup.{h,cpp}
        as_context.{h,cpp}
        as_datatype.{h,cpp}
        as_gc.{h,cpp}
        as_generic.{h,cpp}
        as_globalproperty.cpp
        as_memory.{h,cpp}
        as_module.{h,cpp}
        as_namespace.h
        as_objecttype.{h,cpp}
        as_outputbuffer.{h,cpp}
        as_parser.{h,cpp}
        as_property.h
        as_restore.{h,cpp}
        as_scriptcode.{h,cpp}
        as_scriptengine.{h,cpp}
        as_scriptfunction.{h,cpp}
        as_scriptnode.{h,cpp}
        as_scriptobject.{h,cpp}
        as_string.{h,cpp}
        as_string_util.{h,cpp}
        as_symboltable.h
        as_texts.h
        as_thread.{h,cpp}
        as_tokendef.h
        as_tokenizer.{h,cpp}
        as_typeinfo.{h,cpp}
        as_variablescope.{h,cpp}
```

**值得注意的**：

- 没有 `include/` 子目录：上游 SDK 把公共头 `angelscript.h` 放在 `sdk/angelscript/include/`，但本仓库把它**直接拉到 `Core/angelscript.h`**，因为 fork 已经在头里 `#include "CoreMinimal.h"` 与 `"FunctionCallers.h"`，不再可能保持"纯 C 兼容公共接口"形态。
- 没有 `VERSION` / `CHANGELOG` / `README` / `LICENSE`：唯一的版权标识在每个源文件文件头注释（`Copyright (c) 2003-2018 Andreas Jonsson` 等）和 `angelscript.h` 顶部 zlib 协议条款。
- 没有 `.Build.cs`：vendored 与 plugin core 一起被 `AngelscriptRuntime.Build.cs` 整体编译，没有"作为独立 ThirdParty 库"的边界。
- 平台 callfunc：`as_callfunc_x86.cpp` / `as_callfunc_x64_msvc.cpp` / `as_callfunc_arm64*.{cpp,asm,S}` 等十余份平台相关 native 调用约定文件**基本未改**——它们是与 ABI 强耦合的最稳定层。

### 1.3 编译进 plugin 的方式

`AngelscriptRuntime.Build.cs` 里，vendored 树用 `PublicIncludePaths.Add` 暴露给整模块，所有 `as_*.cpp` 都参与同一个 unity 编译：

```csharp
// ============================================================================
// 文件: Plugins/Angelscript/Source/AngelscriptRuntime/AngelscriptRuntime.Build.cs
// 节选自: ThirdParty 接入（约 14-26 行）
// ============================================================================
PCHUsage = PCHUsageMode.UseExplicitOrSharedPCHs;
NumIncludedBytesPerUnityCPPOverride = 131072;
PrivateDefinitions.Add("ANGELSCRIPT_EXPORT=1");
PublicDefinitions.Add("WITH_ANGELSCRIPT=1");
PublicDefinitions.Add("ANGELSCRIPT_DLL_LIBRARY_IMPORT=1");

PublicIncludePaths.Add(ModuleDirectory);                              // ★ Core/
PublicIncludePaths.Add(Path.Combine(ModuleDirectory, "Core"));
var AngelscriptThirdPartyPath = Path.Combine(ModuleDirectory, "ThirdParty", "angelscript");
PublicIncludePaths.Add(Path.Combine(AngelscriptThirdPartyPath, "source"));   // ★
PublicIncludePaths.Add(AngelscriptThirdPartyPath);
```

这意味着：

1. **AS 内核没有独立 DLL 边界**——它的所有符号通过 `ANGELSCRIPTRUNTIME_API` 宏暴露（fork 把上游的 `AS_API` / `angelscript_API` 全部统一改成了这个宏，详见 §二、`AS_ForkDifferences.md` "导出宏重命名"分类）。
2. **vendored 源可以反向 include 插件层头**——比如 `as_builder.cpp` 与 `as_scriptfunction.cpp` 已经 `#include "AngelscriptEngine.h"` / `"AngelscriptSettings.h"`（详见 §五"接缝"小节）。这是 vanilla AS 永远不会出现的 dependency，是 fork 的非对称设计选择。
3. **没有"AS 内核重编译开关"**——任何对 vendored 源的改动都会触发完整 `AngelscriptRuntime` 模块的 unity rebuild，而不是局部链接替换。

---

## 二、`[UE++]` / `[UE--]` 标记体系

### 2.1 标记的基本形态

所有对 vendored 源的修改 **必须** 用一对 `[UE++]` / `[UE--]` 注释括起来。这是 `AngelscriptForkStrategy.md` 中明文的硬规则：

> 这些标记是后续追踪 fork 分叉点的唯一可靠线索，**不可省略**。

最简形态 ——同一行注释括号 + 简短动机：

```cpp
// ============================================================================
// 文件: ThirdParty/angelscript/source/as_config.h
// 节选自: 导出宏重命名（约 1255-1261 行）
// ============================================================================
//[UE++]: Rename export macro to match the runtime module rename.
#ifndef ANGELSCRIPTRUNTIME_API
//[UE--]
//[UE++]: Rename export macro to match the runtime module rename.
#define ANGELSCRIPTRUNTIME_API 
//[UE--]
#endif
```

跨多行的复合注释 + 操作动机说明：

```cpp
// ============================================================================
// 文件: ThirdParty/angelscript/source/as_memory.cpp
// 节选自: AS 分配钩子接入 UE LLM tag（约 168-184 行）
// ============================================================================
// interface
void *asAllocMem(size_t size)
{
    //[UE++]: Tag every script object / generic SDK byte buffer that flows through
    //[UE++]: the public asAllocMem hook so LLM reports attribute it under
    //[UE++]: "Angelscript" rather than the unspecified default bucket.
    LLM_SCOPE_BYTAG(Angelscript);
    //[UE--]
    return FMemory::Malloc(size, alignof(asBYTE));   // ★ 用 FMemory 替换 stdlib malloc
}
```

### 2.2 标记的语义维度

逐文件 grep 后，整个 vendored 树的标记分布如下（截至本文撰写时）：

| 维度 | 数量 | 来源 |
|------|------|------|
| 含 `[UE++]` 的文件 | 32 / 88 | grep `\[UE\+\+\]` 计数 |
| `[UE++]` 总出现 | 98 处 | 同上 |
| `[UE--]` 总出现 | 76 处 | 注释 closure 数 |
| 平均"块"大小 | ~1-15 行 | 取决于改动种类 |
| 最高密度文件 | `as_memory.cpp` (21) / `as_string.h` (11) / `as_memory.h` (10) | grep -c 排序 |

数字不完全相等是正常的：**有些 `[UE++]` 是单行的"作用域开启"标记**，紧接的几行都是新增内容，到下一个无关代码块直接以 `[UE--]` 收口；**有些 `[UE++]` 是连续多行**，都属于同一段动机说明，共用一个 `[UE--]`。

### 2.3 修改的语义分类

不重复 `AS_ForkDifferences.md` 的全部细目，本文按"动机 + 边界含义"做高阶汇总（更详细的逐表条目请去那篇）：

| 类别 | 典型文件 | 边界含义 |
|------|---------|---------|
| 导出宏统一 | `as_*.h` 全部类声明 | `AS_API` → `ANGELSCRIPTRUNTIME_API`，与 UE 模块 ABI 对齐；上游升级时**一律忽略**这部分差异 |
| 内存分配桥接 | `as_memory.{h,cpp}` | `asNEW` / `asNEWARRAY` / `userAlloc` → `FMemory::Malloc` + `LLM_SCOPE_BYTAG`；任何上游改动若涉及 `userAlloc` API **整体跳过** |
| 类型 flags 拓宽 | `as_typeinfo.{h,cpp}` / `as_scriptengine.{h,cpp}` / `as_objecttype.h` | `asDWORD flags` → `asQWORD flags`，APV2 高位私有标志的存储面；上游升级时**必须重做** |
| 字节码扩展 | `Core/angelscript.h` (201-212) | 12 条 fork 私有指令；vanilla 的指令编号空间永远不会复用这些值 |
| 模块/热重载支持 | `as_module.{h,cpp}` (`PreClassData` / `baseModuleName` / `ReloadState`) | 与 `RT_HotReload` 的 ClassReloadHelper 链路耦合；上游模块系统重构**整体不吸收** |
| Context 扩展 | `as_context.{h,cpp}` (`MovedToNewThread` / `SetReturnIntoValue` / `SetLoopDetectionCallback` / `SetStackPopCallback` / `GetBlueprintCallstackFrame` / `DebugFramePtr`) | 调试器 / 蓝图回调 / 多线程托管面；上游 V2 接口重构需要重新评审 |
| 语法扩展 | `as_tokendef.h` / `as_parser.cpp` / `as_compiler.cpp` (foreach / 部分 lambda / `default` / `access` / `mixin` 修饰符) | 选择性吸收的 2.38 语言能力 + fork 自创修饰符；详见 §三 |
| 安全性补丁 | `as_scriptengine.cpp` (`DestroyInternal` 后空指针保护) / `as_builder.cpp` (`ConfigSettings` 条件访问) | 在上游崩溃复现路径上加防御；与 `Plan_AS238BugfixCherryPick` 关联 |
| 配置组 stub | `as_scriptengine.cpp` (`BeginConfigGroup` / `EndConfigGroup` / `RemoveConfigGroup` 全部返回 0) | 整个配置组机制被 fork 的 `Bind_*.cpp` 显式注册架构取代；上游对此面的任何改动**整体忽略** |

### 2.4 标记的两种形式分歧

历史上有些 `[UE++]` 标记是单行 `//[UE++]:` 注释紧贴一行新增代码，再以 `//[UE--]` 收口：这是**显式块标记**，3-way merge 时最容易识别。

也有些标记是单行注释直接挂在某个**配套修改**前：

```cpp
//[UE++]: Bridge the current APV2 member naming to the stock restore implementation without widening unrelated surfaces.
#define m_scriptFunctions scriptFunctions
#define m_scriptGlobals scriptGlobals
#define m_classTypes classTypes
```

这种"无 `[UE--]`"的形式 **仅限于宏 / typedef 的别名定义** 中——它们没有"区间"概念，标记本身就是定义。新增代码时**一律使用闭区间 `[UE++] / [UE--]`**，避免增加 grep 噪声。

---

## 三、已 backport 的 2.38 能力

### 3.1 已落地清单

`AngelscriptForkStrategy.md` 把已落地清单列得很清晰：

| 能力 | 落点文件 | 落地形态 |
|------|---------|---------|
| `foreach` 语法解析 | `as_parser.cpp::ParseForeach/ParseForeachVariable` | 2.38 风格 AST 节点已成形，但 lowering 路径仍是 fork 自创（详见 3.2） |
| `foreach` 编译器 | `as_compiler.cpp::CompileForeachStatement` | **lowering 到 `opFor*` 方法**——把 `foreach (X X : Y)` 重写成 `for (...) { Y.opForBegin(); ... }` 字符串再二次 parse |
| 模块 `GlobalVar` lookup | `as_module.cpp::GetGlobalVarIndexByName` / `GetGlobalVarIndexByDecl` | 复用上游 2.38 `asCBuilder::ParseDataType` 解析路径，但符号命中走 fork 的 APV2 容器 |
| 导入函数 traits | `as_module.cpp::AddImportedFunction` | `asSFunctionTraits` 字段写入 `asCScriptFunction::traits`；上游 traits 字段可直接复用 |
| 恢复器表面 | `as_restore.cpp` (大段 `[UE++]:` 注释) | 提供 stock 2.38 风格 `asCReader` 接口，但内部 `GetCalledFunctionOrNull` 等辅助函数走 2.33 字节码布局 |
| 对象类型/类型信息 flags 宽位 | `as_typeinfo.{h,cpp}` / `as_objecttype.{h,cpp}` / `as_scriptengine.{h,cpp}` | `asDWORD` → `asQWORD`；保留 APV2 私有高位 |
| 内存池清理逻辑 | `as_memory.cpp::FreeUnusedMemory` / `AllocScriptNode` / `AllocByteInstruction` | 镜像 stock pool 清理逻辑，但 backend 是 `FMemory` 而非 `userAlloc/userFree` |
| `asEP_*` engine property 命名 | `Core/angelscript.h` 29-40 号 | 占用上游 2.38 已定义的 ID 槽（`INIT_STACK_SIZE` 等），fork 自有 property 退到 41+ |

### 3.2 一个典型的"半 backport"案例：foreach

`Plan_AS238ForeachPort.md` 详细对比过 fork foreach 与 vanilla 2.38 的差异：

| 维度 | 当前 fork | 2.38 vanilla |
|------|----------|--------------|
| 令牌名 | `ttForeach`（小写 e） | `ttForEach`（大写 E） |
| 解析器 | `ParseForeach` + `ParseForeachVariable`，range 用 `ParseCondition()` | `ParseForEach`，range 用 `ParseAssignment()` |
| 编译器 | 字符串重写 `for` + `opFor*`，再 `ParseStatementBlock` 二次编译 | `CompileForEachStatement` 直接发字节码 |
| Tokenizer | 静态关键字表，`asEP_FOREACH_SUPPORT` 不联动 | `InitJumpTable()` 机制，property 关闭时把 foreach 从关键字表剔除 |
| 多变量 | 仅 `opForKey`（key + value） | `opForValue0..N`（任意元数解包） |
| 错误信息 | UE 自定义 `TXT_FOREACH_VARIABLE_DECLARATION` | 官方 `TXT_s_NOT_A_FOREACH_TYPE` |

落地的 lowering 路径在 `as_compiler.cpp::CompileForeachStatement`：

```cpp
// ============================================================================
// 文件: ThirdParty/angelscript/source/as_compiler.cpp
// 函数: asCCompiler::CompileForeachStatement (~5614 行起)
// ============================================================================
//[UE++]: Lower stock foreach(...) syntax into regular script using opFor* methods.
void asCCompiler::CompileForeachStatement(asCScriptNode *fnode, asCByteCode *bc)
{
    struct FTempScriptNode : asCScriptNode
    // ... 把 foreach 节点改写成等价的 for(opForBegin; !opForEnd; opForNext) {}
    //     字符串，再调用 ParseStatementBlock 二次解析
}
```

**这是 fork "selective absorption" 的标志性形态**：拿到了上游的语法（`foreach` 关键字 + 解析路径），但**没有**搬上游的字节码生成路径——因为 fork 的 TArray / TMap / TSet bind 已经在 `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/` 注册了 `opForBegin/End/Next/Value/Key`，重写到 `for + opFor*` 方法成本最低。`Plan_AS238ForeachPort.md` 给出了"方案 A（对齐 2.38 直接发字节码）" vs "方案 B（保留 lowering 仅补 tokenizer）"的二选一决策框架，**目前默认走方案 B**。

### 3.3 已 backport 的语义边界

每条"已落地"项都附带一条"边界注释"：

- `as_module.cpp` 的全局 lookup：`//[UE++]: Provide the stock 2.38 lookup API while keeping the APV2 symbol storage and hot-reload state intact.`
- `as_module.cpp` 的导入函数 traits：`//[UE++]: Preserve stock 2.38 imported-function traits on the APV2 import path.`
- `as_restore.cpp` 的恢复器：`//[UE++]: Bridge the current APV2 member naming to the stock restore implementation without widening unrelated surfaces.`
- `as_module.cpp` 的结构变化检测：`//[UE++]: Widen structural flag comparisons to preserve APV2 private high bits on the stock 2.38 layout.`

**通用模式**：每段都在标记里写明 "**preserve / keep / widen** APV2 X" + "**expose / provide** stock 2.38 Y"——这是 `AngelscriptForkStrategy.md` 强烈鼓励的标记规范，便于后续 reviewer 快速判断"哪些是 fork 私有约束、哪些是上游可对齐部分"。

---

## 四、刻意不 backport 的清单

### 4.1 `Documents/Plans/` 中的 AS238 对齐计划

仓库 `Documents/Plans/` 下保留了 10+ 份与 2.38 相关的 Plan 文档，记录"考虑过、但目前不 backport"的清单：

```text
Documents/Plans/
├── Plan_AS238BoolConversionPort.md      // 上下文 bool 转换
├── Plan_AS238BugfixCherryPick.md        // 关键 Bug 修复回移
├── Plan_AS238ComputedGotoPort.md        // computed goto 解释器优化
├── Plan_AS238DefaultCopyPort.md         // 默认拷贝语义
├── Plan_AS238ForeachPort.md             // foreach 端到端闭环（部分已落地）
├── Plan_AS238JITv2Port.md               // JIT v2 接口（详见 §五）
├── Plan_AS238LambdaPort.md              // Lambda / 匿名函数
├── Plan_AS238MemberInitPort.md          // 成员初始化模式
├── Plan_AS238NonLambdaPort.md           // 非 Lambda 类型系统
└── Plan_AS238UsingNamespacePort.md      // using namespace
```

每份都遵循同一个三段式框架：

1. **背景与目标**：为什么这件事值得做、当前与 2.38 的差距
2. **范围与边界**：哪些条目"在范围内 / 不在范围内"
3. **分阶段执行**：Phase 0（评估）→ Phase 1+（实施）

但**截至目前 10 份计划全部"未开始"或仅有 Phase 0 评估文字**——这是有意的设计：先记录决策面，再按需挑出最高 ROI 项。

### 4.2 与 fork 分叉点冲突的不吸收

`AngelscriptForkStrategy.md` 把"什么不适合吸收"列得最清楚。下表是这个清单按 fork 五大分叉点分组的视图：

| 上游特性 / 修复 | 涉及 fork 分叉点 | 不吸收原因 |
|----------------|----------------|---------|
| `@` 句柄相关修复 | 对象引用语义（fork 用自动引用，无 `@`） | 修复路径在 fork 中不存在 |
| 可变全局变量增强 | fork 强制 `const` 全局 | 修复目标功能在 fork 中已被禁用 |
| 脚本层 `interface` 改进 | fork 仅原生注册 interface | 同上 |
| `mixin class` 改进 | fork 仅 mixin 全局函数 | 同上 |
| `?&` unsafe ref 修复 | fork 不暴露此特性 | 同上 |
| 显式句柄工厂 | fork `RegisterObjectBehaviour(BEHAVE_FACTORY, "T@ f()")` 已返回 -10 | 工厂模型不同 |
| 模块系统大重构 | APV2 有自己的模块存储 + 热重载状态机 | 整体替换会破坏热重载 |
| 字节码序列化 schema 变化 | fork 保留 2.33 字节码布局 + APV2 容器 | 与现有 PrecompiledData 二进制不兼容 |
| 全局 `userAlloc/userFree` 钩子改造 | fork 已经走 `FMemory::Malloc` + `LLM_SCOPE_BYTAG` | 钩子在 fork 中已被替换 |

### 4.3 标记意图：等还是不等？

每条 Plan_AS238*.md 在 fork strategy 索引里都对应一句"做不做"的官方判断（来自 `AngelscriptForkStrategy.md` 末尾表）：

| 方向 | 状态 | 言下之意 |
|------|------|---------|
| foreach 端到端闭环 | 未开始 | 已经有 lowering，能用；端到端对齐是锦上添花 |
| Lambda | 未开始 | parser 已半移植，但 closure capture 与 funcdef 闭环未做 |
| 函数模板 | 未开始 | 与 fork 的 `RegisterTemplate*` 模板系统冲突点多 |
| 上下文 bool 转换 | 未开始 | 用户面影响小，决策可延后 |
| 默认拷贝语义 | 未开始 | 与现有 `asOBJ_VALUE` 类型注册流程兼容性需评估 |
| using namespace | 未开始 | 与 fork 的 namespace 解析路径耦合 |
| 成员初始化模式 | 未开始 | 与 fork 自创的 `default` 语句相互作用待理清 |
| 关键 Bug 修复回移 | 未开始 | 需先建立 cherry-pick 候选清单 |
| **JIT v2 接口** | **未开始** | **见 §五的详细案例** |
| Computed goto | 未开始 | 与 fork 的解释器主循环 dispatcher 兼容性需评估 |
| 非 Lambda 类型系统 | 未开始 | Lambda 的前置依赖 |

**总计：10 份独立 Plan，0 份已完成**——这反映了 fork 当前的策略偏好："先把已有能力打磨稳固，新能力 backport 在 ROI 明确前不动手"。

---

## 五、JIT v2 案例：为何"暂不 backport"是合理决策

### 5.1 V1 vs V2 接口差异

`Plan_AS238JITv2Port.md` 中列出的对比表：

| 方面 | V1 (`asIJITCompiler`) | V2 (`asIJITCompilerV2`) |
|------|-----------------------|---------------------------|
| 编译时机 | `CompileFunction` 同步调用，`Build()` 末尾阻塞 | `NewFunction` 通知，可异步挂载 |
| 清理 | `ReleaseJITFunction(jit)` | `CleanFunction(scriptFunc, jit)` |
| 全模块可见性 | 单函数视角 | 可见所有函数，做全局 inline / 布局 |
| `SetJITFunction` | 返回 `asNOT_SUPPORTED` | 可用，支持延后挂载 |
| 热重载语义 | 替换需 `Release` 旧的 | 自动 `CleanFunction` 旧的，原地 `SetJITFunction` 新的 |

### 5.2 当前 fork 的 JIT 形态

`RT_StaticJIT.md` 详细描述了 StaticJIT 怎样把字节码 transpile 成 C++ 在 cook 期固化。关键事实是：

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/StaticJIT/AngelscriptStaticJIT.h
// 节选自: FAngelscriptStaticJIT 继承关系（约 90 行起）
// ============================================================================
class FAngelscriptStaticJIT : public asIJITCompiler   // ★ 只继承 V1
{
    virtual int  CompileFunction(asIScriptFunction*, asJITFunction* outJit) override;
    virtual void ReleaseJITFunction(asJITFunction jit) override;
    // ...
};
```

`as_scriptengine.cpp` 已经在 `SetEngineProperty` 接受 `asEP_JIT_INTERFACE_VERSION = 1 / 2`，但**只有 V1 路径在跑**——把它设为 2 不会触发任何新行为。

### 5.3 不 backport 的理由

`Plan_AS238JITv2Port.md` 列了三条："为什么 V2 看起来更好但目前不做"：

1. **当前路径已经满足 fork 主诉求**：StaticJIT 是 cook-time AOT，不是 run-time JIT；V2 的"延迟绑定 / 异步挂载"在 cook 模型下没有实际收益。FunctionsToGenerate 列表已经是"延后处理"模型，区别只是接口形状。
2. **V2 改动面比看起来大**：`as_scriptengine.h` 中 `jitCompiler` 成员需要双类型存储（`asIJITCompiler*` vs `asIJITCompilerV2*`），`as_module.cpp::JITCompile` / `as_scriptfunction.cpp::JITCompile` 需要按 property 分支，所有 `[UE++]` 安全检查需要对 V1/V2 双面验证。
3. **没有用户面证据**：当前用户场景（cook + StaticJIT）没有任何 bottleneck 指向"V1 的同步阻塞"。Plan 自身的 ROI 论证段是空的。

**结论**：JIT v2 是"接口看起来更好、但移植成本与潜在收益不匹配"的典型案例。fork 选择**保留 V1 + 等待真实需求出现** 而不是预先吸收。这正是 `AngelscriptForkStrategy.md` 所说的"把上游视为'改进来源'而非'升级目标'"的实际操作示范。

---

## 六、不该 patch 的边界 + 与 plugin core 的接缝

### 6.1 ThirdParty 内不应引用 UE 类型——这条是软约束

理想模型下，"vendored 第三方源不引用宿主类型"是常见原则。但本 fork **已经主动违反了这条原则**——出于深度集成需要：

```cpp
// ============================================================================
// 文件: ThirdParty/angelscript/source/as_builder.cpp
// 节选自: 反向引用 plugin core（约 47-52 行）
// ============================================================================
#include "as_scriptobject.h"
#include "as_debug.h"
#include <functional>
//[UE++]: Rename engine header include to match the engine type rename.
#include "AngelscriptEngine.h"        // ★ ThirdParty 反向 include 插件层
//[UE--]
#include "AngelscriptSettings.h"      // ★ 同上
```

```cpp
// ============================================================================
// 文件: ThirdParty/angelscript/source/as_memory.cpp
// 节选自: 拉入 LLM tag（约 45-50 行）
// ============================================================================
//[UE++]: Pull in the AngelscriptRuntime LLM tag declaration so the SDK
//[UE++]: allocation gateways below can attribute bytes to the Angelscript tag.
//[UE++]: Build.cs exposes ModuleDirectory/Core via PublicIncludePaths so the
//[UE++]: bare include path resolves the same way the rest of the runtime does.
#include "AngelscriptMemoryTags.h"
//[UE--]
```

```cpp
// ============================================================================
// 文件: ThirdParty/angelscript/source/as_context.h
// 节选自: 反向引用（约 49-58 行）
// ============================================================================
//[UE++]: Pull in plugin engine for callback type aliases.
#include "AngelscriptEngine.h"
//[UE--]
using asLineCallback = void(*)(asCContext*);
using asStackPopCallback = void(*)(asCContext*, void* oldStackFrameStart, void* oldStackFrameEnd);
```

**实际边界**：

- **允许**：ThirdParty include `Core/AngelscriptEngine.h` / `AngelscriptSettings.h` / `AngelscriptMemoryTags.h` / `FunctionCallers.h`（已有先例，且都在 `[UE++]` 标记中）。
- **不允许**：在 ThirdParty 中直接引用 `Bind_*.cpp` 的具体注册实现 / `ClassGenerator/` 内部类（这是 plugin core 的更上层架构，越过这条线意味着"vendored 与 plugin 互相循环依赖"）。
- **不允许**：在 ThirdParty 中直接引用 `UObject` / `AActor` / Blueprint 元素（违反 `Type_ClassGeneration` 的方向：plugin core 通过 `FAngelscriptType` 抽象桥接，ThirdParty 始终面对的是 `asCScriptObject`）。

### 6.2 上游 bug 处置策略

`AngelscriptForkStrategy.md` 给出二选一：

> 1. **直接修改 vendored 源 + `[UE++]` 标记**：当 bug 在 ThirdParty 内、与 fork 分叉点无冲突
> 2. **在 plugin 层 wrapping**：当 bug 修复需要 fork 不支持的特性（如 `@` 句柄修复）

**推荐流程**：

```text
发现 bug
  │
  ├─ 是否仅 vanilla 路径？
  │    └─ 是 → 跳过（fork 不会跑到该路径）
  │
  ├─ 修复目标特性是否在 fork 分叉点冲突清单上？
  │    └─ 是 → wrapping in plugin core or skip
  │
  └─ 否 → 在 vendored 源加 [UE++] 修复 + 写 failing test 暴露之前的行为
```

实际示例（`as_scriptengine.cpp::~asCScriptEngine` 的级联释放保护）：

```cpp
// ============================================================================
// 文件: ThirdParty/angelscript/source/as_scriptengine.cpp
// 节选自: 析构期空指针保护（约 953-969 行）
// ============================================================================
scriptTypeBehaviours.ReleaseAllFunctions();
functionBehaviours.ReleaseAllFunctions();

//[UE++]: Guard against cascade-freed functions during DestroyInternal.
// DestroyInternal may release references that cascade-free THIS function,
// setting scriptFunctions[n] to null. Re-check before writing engine = 0.
for( asUINT n = 0; n < scriptFunctions.GetLength(); n++ )
{
    if( scriptFunctions[n] == 0 ) continue;   // ★ 必要的二次检查
    scriptFunctions[n]->DestroyInternal();
    if( scriptFunctions[n] != 0 )             // ★ DestroyInternal 可能让指针变 null
        scriptFunctions[n]->engine = 0;
}
//[UE--]
```

这是上游也存在的潜在隐患，fork 直接在 ThirdParty 加了一道防御 + 注释说明动机。这种小补丁是"最值得直接改 vendored 源"的形态。

### 6.3 与 plugin core 的协作接缝

**接缝 1：内存分配**

```text
脚本对象 / SDK 内存
   │
   ▼
asNEW(x) / asAllocMem(size)        ← ThirdParty 公共入口
   │
   ▼
::AngelscriptSDK::SDKAlloc / asAllocMem
   │
   ▼
LLM_SCOPE_BYTAG(Angelscript)        ← UE 内存追踪挂钩
FMemory::Malloc(size, alignof(...))
```

`AngelscriptMemoryTags.h` 是 plugin core 的浅层头，仅声明 `LLM_DECLARE_TAG(Angelscript)`，零依赖于 `asCScriptEngine` 等。这种"窄接缝"是 ThirdParty 反向引用的合理形式。

**接缝 2：调试器回调**

```cpp
// as_context.h
using asLineCallback = void(*)(asCContext*);                    // ThirdParty 定义类型别名
using asStackPopCallback = void(*)(asCContext*, void*, void*);  // 同上
class asCContext final : public asIScriptContext
{
    void  SetLoopDetectionCallback(...);                         // [UE++] 新增 API
    void  SetStackPopCallback(asStackPopCallback callback);
    int   GetBlueprintCallstackFrame() const;
    void* DebugFramePtr;                                         // [UE++] 调试器帧指针
};
```

`RT_Debugger.md` 描述了这些 hook 怎样被 DAP V2 协议消费。**接缝形态**：ThirdParty 暴露**钩子点**，plugin core 注册**回调实现**——这是单向依赖，plugin core 知道 `asCContext`，但 `asCContext` 不知道具体回调里发生了什么。

**接缝 3：模块状态与热重载**

```cpp
// as_module.h（节选）
//[UE++]: APV2 hot-reload state.
TMap<FString, FAngelscriptPreClassData> PreClassData;     // 旧版类元数据，供 reload 比较
asCString baseModuleName;                                  // 模块继承链
enum ReloadState { Initial, Reloading, Done, ... };
ReloadState reloadState;
asModuleReferenceUpdateMap referenceUpdateMap;             // 引用更新表
```

`RT_HotReload.md` 阶段 4 的 `ClassReloadHelper.PerformReload` 直接读 `PreClassData` / `baseModuleName` / `reloadState`——**接缝形态**：ThirdParty 提供**状态容器**，plugin core 写入与读取都是显式的。

**接缝 4：HashMetadata**

```cpp
// AngelscriptEngine.cpp::CompileModule_Types_Stage1
ScriptModule->SetUserData((void*)(size_t)Module->CombinedDependencyHash, 0);
// ★ ThirdParty 的 asIScriptModule::SetUserData(value, type=0) 把 hash 挂到模块上
//   后续 transpile 期可以通过 GetUserData(0) 读回，避免再跑一遍 XOR 聚合
```

这是 vanilla AS 的 generic API，被 fork 借用来塞 fork 自有 hash，不需要任何 `[UE++]` 改动——**最优雅的接缝形态**。

---

## 七、升级与维护流程

### 7.1 selective absorption 的官方流程

`AngelscriptForkStrategy.md` 给的六步：

```text
1. 识别目标改进
   ↓ 从 changelog / diff / issue tracker 确定候选项
2. 适用性评审
   ↓ 对照 ASSDK_Fork_Differences.md 和当前 [UE++] 标记点，判断是否可移植
3. 影响面分析
   ↓ 确定涉及的 ThirdParty 源文件和依赖的 Runtime/Binds 文件
4. 先补 failing test
   ↓ 在 AngelscriptTest 中建立能暴露当前行为不正确或能力缺失的测试
5. 最小实现
   ↓ 只改必要的代码，新增的 [UE++] 改动必须加注释标记
6. 回归验证
   ↓ 全量 AngelscriptFast + 受影响主题的 AngelscriptFunctional
```

每一步都有具体支撑：

| 步骤 | 工具 / 文档 |
|------|----|
| 识别 | `Reference/angelscript-v2.38.0/sdk/docs/articles/changes2.html`、上游 GitHub commit log |
| 评审 | `ASSDK_Fork_Differences.md`、`AS_ForkDifferences.md`、grep `[UE++]` |
| 影响面 | grep `as_<file>.cpp` 涉及的 plugin core / Bind 调用点 |
| failing test | `AngelscriptTest/AngelScriptSDK/` (~301 个 SDK 兼容测试) / `AngelscriptFast/` |
| 实现 | 直接编辑 `ThirdParty/angelscript/source/*.{h,cpp}` |
| 回归 | `Tools/RunTests.ps1` + `Tools/RunTestSuite.ps1` |

### 7.2 不该走的四种"反模式"

1. **"整体升级到 2.38"**：`AngelscriptForkStrategy.md` 明确禁止——改动规模和语义差异太大，强行替换会破坏所有现有 UE 集成。
2. **"删 `[UE++]` 改回 vanilla"**：每条 `[UE++]` 都附带具体动机；删除标记意味着丢失"为什么这么改"的唯一线索，未来 reviewer 无法判断是 fork 私有约束还是上游可对齐部分。
3. **"vendored 不加 `[UE++]` 直接修改"**：在 vendored 源做任何无标记改动 = 给后续 3-way merge 制造永久成本，这是最严重的反模式。
4. **"在 plugin core wrap 一层来避免改 vendored"**：当修改性质本身在 ThirdParty 内最自然（如析构期空指针保护、AS 内部循环优化），强行 wrap 反而让代码路径分裂、可读性下降。**判断准则**：动机若是"AS 内部状态正确性"，改 ThirdParty；动机若是"UE 反射 / Blueprint / 资源"层语义，改 plugin core。

### 7.3 vendored 变化与下游联动

vendored 源任一处改动，潜在影响如下：

| 改动类型 | 影响面 | 必跑测试 |
|---------|-------|---------|
| `as_config.h` feature flag | 编译开关变化，整模块 rebuild | `AngelscriptFast` 全量 |
| `Core/angelscript.h` 新指令/property | 字节码 / engine state 不兼容老 cache | `Plan_AS238*` 所属主题 + 全量 |
| `as_scriptengine.cpp` 注册路径 | 影响所有 Bind | `Bindings.*` 主题 |
| `as_compiler.cpp` 编译器逻辑 | 影响编译诊断 + 字节码 | `Compiler.*` 主题 |
| `as_restore.cpp` 序列化 | 影响 PrecompiledData 加载 | `StaticJIT.*` 主题 |
| `as_module.cpp` PreClassData / ReloadState | 影响热重载 | `HotReload.*` 主题 |
| `as_memory.cpp` allocator 路径 | 影响 LLM 报告 | `Memory.*` 主题（如有） |

**特别注意**：vendored 源的改动 **不会** 自动触发 BlueprintImpact Commandlet 重扫——那是 plugin core `BlueprintImpact/AngelscriptBlueprintImpactScanner` 的职责，针对 `.as` 源文件变化。但如果改动了字节码 schema（如 `as_restore.cpp` 序列化布局），**老的 `PrecompiledScript.Cache` 必须人为删除**，否则 cooked build 启动时 `FAngelscriptPrecompiledData::Load` 会因 `BuildIdentifier` / `DataGuid` 不匹配把整盘字节码丢弃（详见 `RT_StaticJIT.md` 阶段三）。

---

## 附录 A：Vendored 源关键文件速查

| 文件 | 角色 | `[UE++]` 数 | 主要改动类型 |
|------|------|-----|------|
| `as_config.h` | 平台 feature flag + `ANGELSCRIPTRUNTIME_API` | 2 | 导出宏统一 |
| `as_memory.{h,cpp}` | 分配钩子 | 31 | FMemory + LLM tag + 池清理 |
| `as_string.h` | `asCString` | 11 | 导出宏统一 |
| `as_scriptengine.{h,cpp}` | `asCScriptEngine` | 4 | 析构保护 + flags 拓宽 + 配置组 stub |
| `as_module.{h,cpp}` | `asCModule` | 9 | PreClassData + ReloadState + 2.38 lookup API |
| `as_objecttype.{h,cpp}` | `asCObjectType` | 5 | shadowType + 2.38 method lookup overload |
| `as_typeinfo.{h,cpp}` | `asCTypeInfo` | 4 | flags 拓宽到 asQWORD |
| `as_context.{h,cpp}` | `asCContext` | 1 | 调试器 hook + 帧指针 |
| `as_compiler.{h,cpp}` | `asCCompiler` | 2 | foreach lowering + 修饰符识别 |
| `as_parser.{h,cpp}` | `asCParser` | 2 | foreach + lambda 半移植 |
| `as_restore.{h,cpp}` | 字节码序列化 | 5 | 2.38 表面 + 2.33 字节码桥接 |
| `as_builder.{h,cpp}` | `asCBuilder` | 7 | UE 编辑器条件访问 + 纯脚本类放行 |
| `as_scriptfunction.{h,cpp}` | `asCScriptFunction` | 6 | onHeap + 签名 ID 辅助 + traits |
| `as_bytecode.{h,cpp}` | `asCByteCode` | 1 | 测试模块导出 |
| `as_tokendef.h` | Token 定义 | 1 | foreach / fallthrough / struct / access 等关键字 |

（其余 17 个含标记文件多为单纯的导出宏统一，不在此列。完整逐表见 `AS_ForkDifferences.md`。）

---

## 附录 B：升级 / 移植 checklist

下表是从 `AngelscriptForkStrategy.md` 抽出的 backport candidate 评估单：

| # | 检查项 | 通过条件 |
|---|-------|--------|
| 1 | 候选改动是否在 `ASSDK_Fork_Differences.md` 列出的分叉点冲突清单上？ | 否 → 继续；是 → 跳过 |
| 2 | 是否依赖 fork 不支持的语法（`@` / `mixin class` / 脚本 `interface` / `?&`）？ | 否 → 继续 |
| 3 | 是否触及 fork 自创结构（`PreClassData` / `ReloadState` / `shadowType` / 12 条字节码扩展）？ | 是 → 至少需要 wrapping，不可直贴 |
| 4 | 是否在 fork 已扩宽到 `asQWORD` 的 flags 路径上？ | 是 → 检查上游 `asDWORD` 的所有访问点 |
| 5 | 是否要求新的 `userAlloc/userFree` hook？ | 是 → 跳过；fork 路径已是 `FMemory + LLM tag` |
| 6 | 是否更改字节码 schema？ | 是 → 必须 bump `BuildIdentifier`（`PrecompiledData.{h,cpp}`） |
| 7 | 改动后是否能保证现有 `PrecompiledScript.Cache` 仍可加载？ | 否 → 必须发布 cache 失效说明 |
| 8 | 改动是否需要 plugin core 同步修改？ | 是 → ThirdParty + Core 同次 commit，不要 split |
| 9 | 是否补了 failing test？ | 是 → 进入 PR；否 → 退回 Step 4 |
| 10 | `[UE++] / [UE--]` 标记是否齐全 + 有动机说明？ | 是 → 通过；否 → 退回 Step 5 |

---

## 附录 C：fork divergence 时间线（高阶视图）

```text
═══════════════════════════════════════════════════════════════════════════════
  时间                    上游 vanilla 主线           本 fork
═══════════════════════════════════════════════════════════════════════════════
  ~2018 (2.33.0 WIP)      2.33 release point          fork point ──┐
                                                                   │
  ──────────────────────  上游持续演进  ──────────────────────────│
                                                                   │
  2.34 / 2.35             多个 bug fix                              │
  2.36                    新增引擎属性                              │
  2.37                    JIT v2 接口（asIJITCompilerV2）            │
  2.38                    foreach 直接字节码 / lambda /             │
                          using namespace / member init mode /      │
                          bool conversion / default copy /          │
                          computed goto                             │
                                                                   │
                                                                   ▼
  ─────────────────  fork 长期独立演进 ───────────────────────  fork
                                                                   │
                                                  + ANGELSCRIPTRUNTIME_API 统一
                                                  + FMemory + LLM tag (asNEW)
                                                  + asCObjectType.shadowType
                                                  + asCModule.PreClassData / ReloadState
                                                  + 12 条 fork 字节码 (201-212)
                                                  + asCContext debugger hook
                                                  + 配置组 stub
                                                  + 自创修饰符 (default / access / mixin)
                                                  + foreach lowering (非 2.38 字节码路径)
                                                  + asCCompiler safety guard
                                                  + 类型 flags 拓宽到 asQWORD

  2026-04 (本文撰写)      2.38 stable                fork
                                                       ├── 已 selective backport:
                                                       │     foreach parser, module lookup,
                                                       │     imported function traits,
                                                       │     restore surface,
                                                       │     type flags widening,
                                                       │     memory pool cleanup logic
                                                       │
                                                       └── 暂未 backport:
                                                             JIT v2, lambda 端到端,
                                                             foreach 直接字节码,
                                                             using namespace, computed goto,
                                                             bool conversion, default copy,
                                                             member init mode,
                                                             AS238 bugfix cherry-pick
                                                             (10 份 Plan 全部 status=未开始)

═══════════════════════════════════════════════════════════════════════════════
  关键决策：上游永远不会回流到 fork；fork 也永远不会"升级到"上游。
           只能逐项 cherry-pick + [UE++] 标记。
═══════════════════════════════════════════════════════════════════════════════
```

---

## 小结

- **vendored 源不是"AS 2.33 快照"**，而是基于 2.33 持续偏离的独立 fork：唯一目录 `ThirdParty/angelscript/source/` 88 个文件中 32 个含 `[UE++]` 标记，累计 98 处 / 76 处闭区间标记，物理上无 `include/` / `VERSION` / `CHANGELOG`。
- **`[UE++] / [UE--]` 标记是 fork 演进的唯一可靠线索**，每条都必须附带"为什么改 + 与上游分叉点的关系"动机说明；这是 3-way merge 的硬要求，不可省略。
- **已 backport 的 2.38 能力 = 7 项**：foreach 解析 / 模块 lookup / 导入函数 traits / 恢复器表面 / 类型 flags 宽位 / 内存池清理 / asEP_* property 命名占位；其中 foreach 是"半 backport"——拿了语法没拿字节码生成。
- **暂不 backport 的清单 = 10+ 份 Plan**，包括 JIT v2 / lambda / 上下文 bool / 默认拷贝 / using namespace / computed goto / 关键 Bug 修复回移；每份都有 Phase 0 评估文字但全部 status=未开始。
- **不该 patch 的边界**：与 fork 五大分叉点（自动引用 / `const` 全局 / 无脚本 interface / 无 mixin class / APV2 模块系统）冲突的上游改动全部跳过；删 `[UE++]` 改回 vanilla 是最严重反模式。
- **与 plugin core 的接缝**有四道：内存分配（`AngelscriptMemoryTags.h`）、调试器回调（`asCContext::SetXxxCallback`）、热重载状态（`PreClassData`/`ReloadState`）、HashMetadata（`SetUserData(0)`）；所有反向 include 都在 `[UE++]` 标记下。
- **升级流程**：识别 → 适用性评审 → 影响面分析 → 先补 failing test → 最小实现 → 全量回归；任何字节码 schema 变化都必须 bump `BuildIdentifier` 让老 cache 失效，否则 cooked build 启动时整盘丢字节码。
