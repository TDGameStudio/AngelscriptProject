# AS_UEEmbeddedVersion — 当前版本为什么不是「原版 AngelScript」

> **所属模块**: AS_（AngelScript 引擎内核族）
> **关注层面**: 产品身份、语言方言、内核 fork、以及它如何嵌进 Unreal 的对象 / 反射 / 编辑器系统
> **本文目的**: 先给审阅用。说明当前版本的特殊之处，不替代 `AS_ForkDifferences.md` 的改动清单，也不替代 `AngelscriptForkStrategy.md` 的吸收策略
> **关键源码**:
> `Plugins/Angelscript/Source/AngelscriptRuntime/Core/UnrealAngelscriptVersion.h`
> · `Plugins/Angelscript/Source/AngelscriptRuntime/Core/angelscript.h`
> · `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/`
> · `Plugins/Angelscript/Source/AngelscriptRuntime/Preprocessor/`
> · `Plugins/Angelscript/Source/AngelscriptRuntime/ClassGenerator/`
> · `Plugins/Angelscript/Angelscript.uplugin`

---

## 一句话

当前产品不是「把官方 AngelScript 嵌进 UE、再绑一批 C++ API」的薄封装。

它是一份已经改过语言语义、改过内核 ABI、并且把脚本类型变成活的 `UClass` / `UFunction` / `UProperty` 的 **Unreal 一等脚本方案**。对外名字是 **Unreal AngelScript 1.0.0**；源码出身是 AngelScript，但运行时不再接受原版 2.33 / 2.38 头文件。

---

## 两个版本号，不要混

| 名称 | 值 | 含义 |
|------|----|------|
| 产品版本 | `Unreal AngelScript 1.0.0`，编码 `10000` | 对外身份。覆盖核心 UE 插件、内嵌运行时和 Standalone 发行面 |
| 源码 lineage | `AngelScript 2.33.0 WIP + 选择性 2.38 回移` | 只说明从哪份上游长出来，不是当前版本号 |

公共头里现在是这样绑的：

```cpp
// Core/UnrealAngelscriptVersion.h
#define UNREAL_ANGELSCRIPT_VERSION 10000
#define UNREAL_ANGELSCRIPT_UPSTREAM_BASE_VERSION 23300

// Core/angelscript.h
#define ANGELSCRIPT_VERSION        UNREAL_ANGELSCRIPT_VERSION
#define ANGELSCRIPT_VERSION_STRING UNREAL_ANGELSCRIPT_PRODUCT_VERSION_STRING
```

`asCreateScriptEngine()` 按产品 SemVer 校验：主版本必须相同，且请求版本不能高于运行时。原版 2.33 头文件会传入 `23300`，会被**明确拒绝**。接入方必须编译本插件自带的 `angelscript.h`。

1.x 允许「旧 1.x 头 + 更新的兼容 1.x 运行时」。破坏公共 C API / ABI 必须升主版本，不能假装成 1.x 补丁。

---

## 「简单嵌入」长什么样，我们不是那个

常见的脚本嵌入只有一层：

```text
原版 AS 编译器 / VM
        │
        ▼
C++ 手工 RegisterObjectType / RegisterGlobalFunction
        │
        ▼
脚本调用若干引擎函数；脚本类停留在脚本世界里
```

那种方案里：

- 语言还是 vanilla AngelScript（`@` 句柄、可变全局、`interface`、`mixin class`）
- 脚本对象不是 `UObject`，Blueprint / 序列化 / GC / 网络复制看不见它
- 热重载、UHT、编辑器属性面板、ProcessEvent 都不在语言核心里
- 换一份官方 `sdk/` 通常还能编过

当前版本已经越过这条线。脚本写出来的 Actor / Component / Subsystem 会进入 UE 反射树；预处理器认识 `UFUNCTION` / `UPROPERTY`；内核自己改了内存、模块、字节码和对象引用语义。再把它叫「2.33」或「2.38 插件」会误导后续所有决策。

---

## 特殊之处分三层

### 1. 语言层：这是一份 UE 方言，不是原版语法

词法表里一批 vanilla 关键字被关掉，另一批 UE 语境关键字被加进来。证据在 `as_tokendef.h`：

| 原版 AngelScript | 当前 fork |
|------------------|-----------|
| `@` 句柄、`is` / `!is`、`funcdef`、脚本 `interface`、`typedef` | Token 已注释掉，不能当官方语法用 |
| 可变全局变量合法 | 脚本全局必须 `const` |
| 对象用显式句柄管理生命周期 | 对象引用自动，贴近 UE 对象所有权 |
| `mixin class` 作为类型混入 | 不支持 mixin class；只保留 mixin 函数，给 UE 类型加方法 |
| 配置组 `BeginConfigGroup` 等 | 已 stub，绑定改由 UE 侧管理 |

脚本侧看起来更像「能热重载的 UE C++ / Blueprint」，而不是独立脚本语言：

- `class AMyActor : AActor` 会生成真的 `UClass`
- `UFUNCTION()` / `UPROPERTY()` 由预处理器识别，再经 ClassGenerator 落到 `UASFunction` / `FProperty`
- `default`、`DefaultComponent`、`delegate` / `event`、`access`、mixin 函数都是这条 UE 管线的一部分
- 接口走 UE `UINTERFACE`，不走 AS 脚本 `interface`

`UFUNCTION` 尤其能说明嵌入深度：AS 编译器**看不见**这个宏，它只编译普通函数；预处理器解析 specifier、必要时改名 `_Implementation` 并生成 RPC / BlueprintEvent 包装；ClassGenerator 再把它变成 `UFunction`，让 Blueprint 节点和 `ProcessEvent` 能找到。

### 2. 内核层：vendored fork，已经和上游不可整包替换

`ThirdParty/angelscript/` 不是「官方 SDK 快照」。它和 `AngelscriptRuntime` 编进同一个模块，公共头还被刻意提到 `Core/angelscript.h`，可以直接 `#include "CoreMinimal.h"`。

已经形成的结构分叉包括：

| 领域 | 当前行为 | 为什么必须这样 |
|------|----------|----------------|
| 内存 | `FMemory` / LLM，不再走标准 malloc | 纳入 UE 内存跟踪 |
| 类型标志 | `asDWORD` → `asQWORD`，保留 APV2 高位 | 给 UE 类型元信息留位 |
| 对象类型 | `shadowType`、继承属性所有权 | 脚本类型遮蔽 / 对齐 UE 类型 |
| 模块 | `ReloadState`、`PreClassData`、依赖图 | 编辑器热重载和版本链 |
| 字节码 | 额外 12 条指令（201–212） | 脚本对象构造、析构、引用跟踪、异常 |
| Context | 行回调、栈弹出、Blueprint 调用栈、线程迁移 | 调试器、BP 互调、循环检测 |
| JIT ABI | 自有 `SetJITBinding` / `OnFunctionReady` | 不是上游 `asIJITCompilerV2`，外部 provider 必须按本分支重编 |

`[UE++]` 标记是追踪这些改动的线索。策略文档的口径是：78 个源文件里约 32 个带定制标记，73+ 处显式改动。细目见 `AS_ForkDifferences.md`。

从 2.38 只选择性吸收了能适配当前结构的部分，例如 foreach 降到 `opFor*`、模块查找 API、导入函数 traits、恢复器表面。整包升级到 2.38 或更新版本**不可行**：会拆掉热重载、类生成、绑定和调试协议。

### 3. 宿主层：脚本类型是 UE 的一等公民

编译完成后，ClassGenerator 把脚本类型变成活的反射对象：

```text
.as
  → 预处理器（#include / #if / UFUNCTION / UPROPERTY / 模块描述符）
  → AS 编译器（方言内核 → 字节码）
  → ClassGenerator（UASClass / UASStruct / UEnum / UDelegateFunction）
  → 可选 StaticJIT / Cache V2
  → Blueprint、编辑器、序列化、GC、网络复制都能看见
```

这一层才是「深入嵌入 UE」的本体，内核 fork 只是它的底座：

- **绑定**：手写 `Bind_*.cpp` + UHT 生成 `AS_FunctionBinding_*.cpp` + 反射回退。RPC / Net 必须走 `BlueprintCallableReflectiveFallback`，不能 raw thunk
- **类生命周期**：热重载时 Soft / Full Reload、Reinstance、CoreRedirects 类改名
- **编辑器**：Content Browser 里的 `.as`、跳转源码、BlueprintImpact、CodeGen
- **调试**：DAP DebugServer，能看到脚本栈和 Blueprint 帧
- **运行时宿主**：`UAngelscriptEngineSubsystem` 负责主启动；GameInstance / World 子系统管理上下文
- **脚本子系统**：`ScriptWorldSubsystem` / `ScriptGameInstanceSubsystem` 等，按 UE 子系统模型写脚本
- **增量缓存 Cache V2**：稳定函数身份，不持久化进程内 FunctionId
- **Standalone**：同一份 maintained fork 的无 UE CMake 面，用来做受限原生执行和离线 UE 声明校验；它不是另一份 vanilla AS

和原版 Hazelight 还有一层产品差异：Hazelight 原方案改引擎；本仓库走**纯插件**，不改 UE 引擎核心。GameplayTags / GAS 再拆成可选插件，避免把核心插件绑死在这些模块上。

---

## 一张图看清位置

```text
                    Unreal AngelScript 1.0.0
                    （产品版本，编码 10000）
                              │
          ┌───────────────────┼───────────────────┐
          ▼                   ▼                   ▼
   语言方言              内核 fork             UE 宿主
   无 @ / 无可变全局      FMemory / APV2        ClassGenerator
   无脚本 interface       12 条 UE 字节码       UASClass / UASFunction
   UFUNCTION 预处理器     热重载模块状态         Bind + UHT + 反射回退
   mixin 函数 / default   自有 JIT binding      HotReload / DAP / Cache
          │                   │                   │
          └───────────────────┴───────────────────┘
                              │
                              ▼
              源码出身：2.33.0 WIP + 选择性 2.38
              不是产品版本，也不能整包替换回上游
```

---

## 和三份常见参照的关系

| 参照 | 关系 | 不能当成什么 |
|------|------|----------------|
| 官方 AngelScript 2.33 / 2.38 | 祖先和 cherry-pick 来源 | 当前语言、ABI、头文件、测试预期 |
| Hazelight Unreal Angelscript | 最初集成来源；本仓库继续做成纯插件并独立产品化 | 「跟官方 Hazelight 同步即可」 |
| Angelsea / Daslang / 其他脚本方案 | 研究对照 | 实现权威或构建依赖 |

写脚本、写绑定、写 JIT、写测试时，**当前 fork 行为优先于 vanilla 预期**。上游能写、但这里还没回移的语义，会以带 `#as-v238-backport` 的 Disabled 测试占位，而不是假装已经支持。

---

## 使用和开发时的硬约束

1. **不要用官方 SDK 头创建引擎。** `23300` 会被拒绝。
2. **不要按 vanilla 教程写 `@`、可变全局、脚本 `interface`、`mixin class`。** 这些不是遗漏，是分叉。
3. **不要把 ThirdParty 当可随时 rebase 的 vendor 目录。** 新改动必须带 `[UE++]`，吸收上游只能 cherry-pick。
4. **脚本类默认进入 UE 类型系统。** 改一个 `.as` 可能影响 Blueprint 子类、序列化和热重载，不只是 VM 里一个模块。
5. **Standalone 不能代替 UE 运行时。** 离线 profile 只做受限执行或声明校验，不模拟 UObject / GC / World / ClassGenerator。
6. **JIT / 绑定 provider 必须针对本分支重编。** 上游 `asIJITCompilerV2`、旧 `CompileFunction` / `ReleaseJITFunction` 都不是当前 ABI。

---

## 现有文档怎么分工

| 要查什么 | 去哪 |
|----------|------|
| 本文：这是什么版本、为什么说深度嵌入 | `AS_UEEmbeddedVersion.md` |
| `[UE++]` 改动分类 | `AS_ForkDifferences.md` |
| 脚本层和官方测试的行为差 | `Documents/Guides/ASSDK_Fork_Differences.md` |
| 以后怎么吸收上游 | `Documents/Guides/AngelscriptForkStrategy.md` |
| ThirdParty 目录边界 | `RT_ThirdPartyKernel.md` |
| `.as` → `UClass` | `Type_ClassGeneration.md`、`Type_Preprocessor.md` |
| `UFUNCTION` / `UPROPERTY` | `Syntax_UFUNCTION.md`、`Syntax_UPROPERTY.md` |
| 给脚本作者的语法对照 | `Guide_SyntaxFeatures.md`（部分段落仍按旧 `@` 心智，以本文和 fork 文档为准） |
| 插件消费者安装与 Cache / Standalone | `Plugins/Angelscript/README.md` |

---

## 审阅时建议先确认的三句话

如果下面三句成立，这份说明就可以作为「当前 AS 版本」的对外口径；有任一不准，再改本文，不要回头去说「我们是 2.33」或「我们是 2.38」。

1. 对外版本是 **Unreal AngelScript 1.0.0**，lineage 只是出身说明。
2. 语言和内核已经按 UE 对象模型改过，不是可替换的官方 VM。
3. 真正的产品能力是脚本类型进入 UE 反射树，并带上绑定、热重载、调试、缓存和可选 JIT。
