# Verse vs Angelscript 插件:架构差异分析

> 信息来源:通过 knot MCP 检索 `UnrealEngine ue5-main` 知识库中
> `Engine/Source/Runtime/VerseCompiler/`、`Engine/Source/Runtime/CoreUObject/Private/VerseVM/`、
> `Engine/Source/Runtime/CoreUObject/Public/VerseVM/`、`Engine/Source/Programs/UnrealBuildTool/`
> 等模块的源码与文档。Verse 行为以 UE 5.7 / ue5-main 为准。
>
> 本文档**仅做客观架构差异比对**,不重复 `AS_*` 与 `Arch_*` 系列已经记录的内核细节。
> 末尾汇总几条对当前 Angelscript 插件可借鉴的设计点;具体可执行任务由 OpenSpec
> 单独立项,不在本文展开。

---

## 一、整体定位对比

| 维度 | Verse (UEFN / UE5) | Angelscript 插件 (本仓库) |
|------|--------------------|--------------------------|
| 语言根源 | Epic 自研,uLang 实现的全新函数式 + OOP 混合语言 | AngelScript 2.33,C++ 风格静态强类型 OOP 脚本语言 |
| 主要使用面 | UEFN(Fortnite Creative)、未来面向 UE 项目脚本层 | UE 项目内嵌的 Blueprint/C++ 替代物,Hazelight 风格游戏脚本 |
| 核心抽象 | **失败上下文 (`failure context`)** + **effect system** + 不可变数据 + 结构化并发 | UClass / UStruct / UFunction 反射桥 + 与 BP 等价的命令式语义 |
| 引擎集成方式 | 编译进 `CoreUObject` / 独立 VM 运行时(`VerseVM`),与 UE 反射深度共生 | 独立插件 `Plugins/Angelscript`,通过手写 Bind + UHT 桥反射进 UE |
| 运行时数量 | **双 VM**:`VerseVM`(原生独立 VM)+ `BPVM`(把 Verse 编译到蓝图字节码上跑) | **单 VM**:`asCContext` 协程式解释器,叠加 `StaticJIT` 提速 |
| 编译流水线层数 | Lex → VST → Sema(多 pass)→ uLang IR → 字节码 / BPVM 字节码 | Preprocessor → `asCParser` → `asCCompiler` → AS 字节码 →(可选)StaticJIT |
| 与 UE 反射桥 | `VClass::BindNativeClass()` 把 `VClass/VStruct` ↔ `UVerseClass/UVerseStruct` | `ClassGenerator` 动态生成 UClass + `Bind_*.cpp` 手写 + UHT 函数表 |
| GC 策略 | **独立 `VVMHeap`** 分代+并发标记清除,与 UE Native GC 协同同步 | **AS GC**(增量循环检测)+ UE GC,弱引用走 `TWeakObjectPtr` |
| 并发原语 | 语言级:`spawn / race / sync / rush / branch`、`async`、`suspends` effect | 无,完全依赖 UE 侧 Tick / 委托 / 子系统 / `FAkAsyncFunctionLibrary` 等 |
| 热重载 | 包级别 reload(`AddImport` + `bImported` 二次绑定校验) | `DirectoryWatcher` + `ClassReloadHelper` 编辑器内 reinstance `.as` |
| 工具链 | `VerseCompiler` 引擎模块 + VNI(Verse Native Interface)+ UHT 增强 | `AngelscriptUHTTool` C# UBT 插件,生成 `AS_FunctionTable_*.cpp` |
| 调试 | Verse 自有 toolchain(VS Code 扩展) | 独立 `DebugServer V2`(实现 DAP 协议) |

可以一句话总结:**Verse 是"语言-VM-编译器"三件套与 UE 引擎垂直耦合的方案;Angelscript 插件是
"通用语言 + 可拆卸适配层"的水平集成方案**。前者把约束沉在语言里,后者把约束浮在绑定层。

---

## 二、编译器与前端

### 2.1 Verse:`VerseCompiler` 模块 + uLang 命名空间

来源:`Engine/Source/Runtime/VerseCompiler/`

```
Public/uLang/Parser/VerseGrammar.h          # 词法/语法规则、Token 集合、优先级与结合性
Public/uLang/Syntax/VstNode.h               # VST(Verse Syntax Tree)— 抽象语法树
Public/uLang/SemanticAnalyzer/SemanticAnalyzer.h   # CSemanticAnalyzer 入口
Public/uLang/Semantics/Effects.h            # SEffectSet / EEffect — Effect 系统
Public/uLang/CompilerPasses/CompilerTypes.h # SBuildParams 编译参数
Private/uLang/SemanticAnalyzer/SemanticAnalyzer.cpp
```

关键流水线:

```
源代码
  ↓ (lexer / parser, VerseGrammar.h)
VST(Verse Syntax Tree, Vst::Project)
  ↓ CSemanticAnalyzer::ProcessVst(Vst, ESemanticPass)
CSemanticProgram / CExprXxx (CExprDataDefinition / CExprIterationPairDefinition / CExprSubtype …)
  ↓ Codegen (依据 SBuildParams::EWhichVM)
VerseVM 字节码  或  BPVM(蓝图)字节码
```

特点:

- **多 pass 语义分析**:`ProcessVst` 接收 `ESemanticPass` 枚举,分阶段做名字解析、类型推断、Effect 校验、迭代器/泛型展开等(见 `AnalyzeFilterExpressionAst` / `AnalyzeDefinition`)。
- **类型系统直接内置进 AST**:`CTypeBase`、`CClass`、`CArrayType`、`CMapType`、`CGeneratorType`、`CFunctionType`,类型与表达式互相引用,可在 AST 上做约束求解 (`Constrain`, `GetTypeNegativeType`)。
- **延迟任务 (`EnqueueDeferredTask`)**:类型/限定符等需要后置回填的工作进任务队列,允许跨作用域引用提前生效,这是常见类型推断系统的"扩展约束求解"做法。
- **版本兼容黑科技**:`SBuildParams::_UploadedAtFNVersion` 让编译器对历史包做行为开关(`VerseFN::UploadedAtFNVersion::EnableFirstMacro / EnableCastableSubtype / EnableGenerators` …),用以兼容已上传到 Fortnite 的旧 Verse 包。

### 2.2 Angelscript:`AngelscriptRuntime/Core` + ThirdParty

来源:`Plugins/Angelscript/Source/AngelscriptRuntime/`

```
Core/                        # 引擎核心、类型系统、编译入口
ThirdParty/                  # AngelScript 2.33 + 选择性 2.38 backport
Preprocessor/                # 自定义 #include / #if 预处理
StaticJIT/                   # 静态 JIT(把 AS 字节码静态翻成 C++ 后离线编译)
ClassGenerator/              # 把脚本类映射成 UClass、热重载、版本管理
```

关键流水线(见 `AS_Compiler.md` / `AS_Parser.md`):

```
.as 文件
  ↓ Preprocessor (#include, #if, 模块描述符)
asCParser 产出 AST(asCScriptNode)
  ↓ asCBuilder + asCCompiler 类型注册 + 编译
AS 字节码 (asBYTE 序列)
  ↓ (可选) StaticJIT — 静态 AOT
asCContext 解释器 / JIT 直接执行
```

特点:

- **AST 与类型系统分离**:AS 自身的 AST 节点 (`asCScriptNode`) 仅描述语法,类型挂在 `asCObjectType` / `asCDataType` 上,语义校验集中在 `asCCompiler` 内。
- **预处理器层做"模块/版本"编排**:`#include`、`#if` 等都是脚本预处理而非语言原语,语言本身不感知模块。
- **JIT 路径独立**:`StaticJIT` 是站在 AS 字节码外面再加一层,把字节码翻成 C++ 然后离线编译;这与 Verse 的 BPVM 后端"换一个目标 VM"是两种思路。
- **Fork 风险**:AS 2.33 已 Fork 偏离上游过远(见 `Documents/Guides/AngelscriptForkStrategy.md`),只能选择性 backport。

### 2.3 关键差异

| 主题 | Verse | AS 插件 |
|------|-------|---------|
| 类型系统位置 | 与 AST 同层,可参与约束求解 | 与 AST 解耦,在编译器内部维护 |
| Effect / 副作用建模 | `SEffectSet` 静态强约束(transacts / varies / suspends / allocates / no_rollback) | 无,副作用通过 BP / 委托运行期表达 |
| 失败语义 | `decides` / `?` / `if (x := …)` 一等公民 | 普通 `bool` 返回 + 异常,无内建失败上下文 |
| 多后端 | VerseVM 与 BPVM 双后端,一份语义两套字节码 | 单 AS 字节码 +(可选)StaticJIT |
| 兼容性策略 | 编译器内"上传版本号"灰度开关 | 通过 fork + selective 2.38 移植 + tests |

---

## 三、运行时与 VM

### 3.1 Verse 双 VM:`VerseVM` 与 `BPVM`

来源:
- `Engine/Source/Runtime/CoreUObject/Private/VerseVM/VVMClass.cpp`
- `Engine/Source/Runtime/CoreUObject/Public/VerseVM/VVMTypeInitOrValidate.h`
- `Engine/Source/Programs/UnrealBuildTool/Configuration/Rules/TargetRules.cs::bUseVerseBPVM`(默认 true)

宏开关:

```cpp
#if WITH_VERSE_BPVM
    EWhichVM _TargetVM = EWhichVM::BPVM;
#else
    EWhichVM _TargetVM = EWhichVM::VerseVM;
#endif
```

含义:

- **BPVM 路径**:把 Verse 编译为 Kismet 蓝图字节码,直接复用蓝图 VM(`KismetCompilerBackend`)。Fortnite/UEFN 默认走这条路,稳定但语言能力受 BP VM 上限。
- **VerseVM 路径**:Epic 正在替换的下一代独立 VM,自带堆 (`VVMHeap`)、帧 (`VVMFrame`)、值类型 (`VValue`/`VShape`)、原生函数桥 (`VFunction`/`MaybeCreateUFunctionForCallee`),解锁完整语言特性(并发、事务、effect)。

来源中明确写道这是个 "HACK_VMSWITCH",会随 VerseVM 完全 ready 而移除——也就是 BPVM 是过渡形态,VerseVM 才是终态。

### 3.2 Angelscript:`asCContext` 协程式解释器

- 单一 VM (`asCContext`),Hazelight Fork 在 2.33 基础上保留协程支持。
- **没有"语言后端切换"概念**:字节码就是 AS 字节码,执行要么解释要么经过 `StaticJIT` 离线生成 C++。
- 所有调度都依靠 UE 侧 (`Tick` / `FTSTicker` / `UEnhancedInputComponent` / GAS 等),AS 自身不持有调度器。

### 3.3 关键差异

| 主题 | Verse | AS 插件 |
|------|-------|---------|
| 后端可替换性 | **设计上承诺双后端**,字节码到 IR 中间层有抽象 | 只有 AS 字节码这一种目标 |
| 与 UObject 关系 | `VClass::Class.Set(Context, this)` 直接把 VM 内部类型挂到 `UVerseClass` | 通过 `ClassGenerator` 在引擎里动态合成 UClass |
| 入口控制 | `VerseVM::GetEngineEnvironment()` 单例桥,所有原生注入都走 `IEngineEnvironment` | `FAngelscriptRuntimeModule::InitializeAngelscript()` + `UAngelscriptEngineSubsystem` 同时存在,正在向子系统化收敛 |
| Tick / 调度 | 自己拥有任务系统,语言层 `spawn / race / sync` | 完全借用 UE Tick + Subsystem |

---

## 四、与 UE 反射的桥接方式

### 4.1 Verse:`BindNativeClass` 单点统一

`VClass::BindNativeClass(FAllocationContext, bool bImported)` 是核心:

1. 通过 `GetUETypeChecked<UStruct>()` 取出对应 UE 类型(`UVerseClass` / `UVerseStruct` 都是 `UClass` / `UScriptStruct` 派生)。
2. 把 `VerseClass->Class.Set(Context, this)` 让 UClass 反指 VM 类型——**双向引用,同寿同亡**。
3. 通过 `IEngineEnvironment::CreateProperty(...)` 现场为每个 Verse 字段创建 `FProperty`,挂入 `NativeStruct->ChildProperties`。
4. 对每个方法走 `MaybeCreateUFunctionForCallee()` 创建 `UFunction`,塞入 `VerseClass->FunctionMap` + `DisplayNameToUENameFunctionMap`。
5. `Bind() + StaticLink(true)`,让 UE 反射系统认识这个新类。
6. 处理 `Predicts`(网络预测变量/函数)、`Attribute`(`FClassAttribute::ApplyClassAttribute`)等元数据。
7. 最后 `CollectBytecodeAndPropertyReferencedObjectsRecursively()` + `AssembleReferenceTokenStream(true)` 重建 GC 引用流。

`bImported` 区分两种情形:

- 非 import:`UVerseClass` 完全由 Verse 编译产物动态构建。
- import:`UVerseClass` 由 UHT(VNI native)生成,Verse 端校验匹配并复用已存在的 `FProperty`。

VNI(Verse Native Interface)的角色:让 C++ 写的"native Verse 类型"既被 UHT 看见,又能被 Verse 编译器作为 `bImported` 类型链入。

### 4.2 Angelscript:`ClassGenerator` + 121 个 `Bind_*.cpp` + UHT 工具

- **`ClassGenerator`**:把 AS 类合成成新的 `UClass`/`UFunction`,与 Verse 的 `BindNativeClass` 角色相近,但更"自下而上",AS 类不像 `UVerseClass` 那样是专门的 UClass 子类。
- **`Bind_*.cpp`(121 个)**:手写 C++ 把引擎类型注册给 AS。这是与 Verse 最大的不同——Verse 的"native 类型"由 UHT + VNI 自动生成,AS 这边由人工 `Bind_*.cpp` + UHT 表 + 反射回退三层叠加。
- **`AngelscriptUHTTool`(C# UBT 插件)**:扫 UE 头里的 `UFUNCTION/UPROPERTY`,生成 `AS_FunctionTable_*.cpp` 直接调用项;未在表里命中的走运行时反射回退(`UFunction reflective fallback binding`)。
- **`UFunction` 反射回退**:对没有 native 直调的函数,运行时通过 `UFunction::Invoke` + `FFrame` 调,用通用性换性能。

### 4.3 关键差异

| 主题 | Verse | AS 插件 |
|------|-------|---------|
| 反射类承载 | 专门的 `UVerseClass / UVerseStruct / UVerseEnum / UVerseFunction` 子类 | 普通 `UClass`,信息挂在 ClassGenerator 与额外侧表 |
| native 类型来源 | UHT + VNI 自动生成,Verse 端 `bImported` 校验 | 手写 `Bind_*.cpp` + UHT 函数表 + 反射回退 |
| 单点入口 | `VClass::BindNativeClass` 一个函数贯穿 import/非 import | 多链路并存:Bind / UHT 表 / 反射回退,各司其职 |
| 元数据流转 | `FClassAttribute::ApplyClassAttribute` 把语言级 attribute 直接写到 `FProperty`/`UFunction` | UE meta 主导,部分修饰符(`UPROPERTY`/`UFUNCTION` 注解)在 AS 解析阶段透传 |

---

## 五、内存与 GC

### 5.1 Verse:独立 `VVMHeap` + 与 Native GC 协同

来自 `9.2. Package系统与垃圾回收` 文档与 `GCObject.h`:

| 特性 | Verse GC | UE Native GC |
|------|----------|-------------|
| 回收对象 | Verse 对象(`VValue` 系) | UObject |
| 算法 | 分代 + 并发标记-清除,带写屏障 | 增量式标记-清除 |
| 触发时机 | VerseVM 内部 | 引擎全局调度 |
| 内存分配 | 统一 `VVMHeap` | 多种分配器 |
| 协同机制 | **外部同步终止**——Verse GC 标记阶段会定期检查"是否应被 Native GC 强制中止",从而不阻塞主线程的预算 |

时序大致是:

```
Native GC 启动 → 标记 Native 对象
              → 请求 Verse GC 同步
Verse GC      → 标记 Verse 对象(并发, 检查终止信号)
              → 返回标记结果
Native GC     → 完成 + 收尾
```

跨界引用的关键点是 `AssembleReferenceTokenStream(true)` —— 把 Verse 字段中持有的 UObject 引用**显式写入 UE 的 GC token 流**,这样 Native GC 才能看见。

### 5.2 Angelscript:`asCGarbageCollector` + UE GC 双层

- AS 自己的 GC(`AS_GarbageCollector.md`)负责脚本对象的循环检测,常规对象用引用计数。
- 与 UE 的桥接靠:`TWeakObjectPtr` / `TObjectPtr` 路由(已在 milestones 中完成)、`UObject` 持有时由 UE GC 兜底。
- 没有"双 GC 同步终止"机制——AS GC 单独跑,因为 AS 对象不会出现在 UObject 图里,跨界只发生在脚本对象持有 UObject 这一方向上,反向不会。

### 5.3 关键差异

| 主题 | Verse | AS 插件 |
|------|-------|---------|
| 算法 | 分代 + 并发,适合高频对象创建 | 引用计数为主 + 循环检测,适合 OOP 风格 |
| 与 UE GC 关系 | 双向同步 + token stream 显式登记 | 单向边界,AS 持有 UObject 通过弱引用与 ClassGenerator 处理 |
| 主线程开销 | 标记阶段可被外部预算打断 | 增量执行,在 AS 子系统 Tick 中自调度 |

---

## 六、Effect 系统与失败上下文(Verse 独占,无对应物)

`Engine/Source/Runtime/VerseCompiler/Public/uLang/Semantics/Effects.h::SEffectSet`:

```cpp
struct SEffectSet : private SEffectSetBase {
    // 通过 VERSE_ENUM_EFFECTS(VISIT_EFFECT) 在编译期展开多组 bit:
    //   suspends  / decides / transacts / no_rollback / varies / reads / writes / allocates / converges …
    bool _Suspends : 1; bool _Decides : 1; bool _Transacts : 1; …
};
```

含义:

- **Effect 是函数签名的一等公民**:`MyFunc()<transacts><decides>:int` 这样的修饰决定函数能在哪些上下文调用。
- **失败上下文 (`<decides>`)**:函数可能"失败"——失败时所有效果回滚,这是 Verse 的事务记忆模型。
- **挂起 (`<suspends>`)**:协程式函数,可被 spawn / race / sync 调度。
- **transacts**:可作为事务一部分(可回滚)。

这一整套**在 AS 中没有对应物**:AS 函数只有 `bool` / `异常` 两种"失败"渠道,没有可回滚的事务记忆,也没有 effect 静态校验。

---

## 七、并发模型(Verse 独占,无对应物)

Verse 语言级 (`async / spawn / race / sync / branch / rush`):

| 原语 | 语义 | 引擎中可见证据 |
|------|------|---------------|
| `sync` | 等所有 sub-flow 完成或取消 | `FConcurrentControlFlowBehavior::EContinueConditions::Default` 注释:"Equivalent to Sync in verse" |
| `race` | 第一个完成/取消即结束,其它取消 | 同上注释中明列 |
| `rush` | 第一个完成/取消即结束,其它继续 | 同上注释中明列 |
| `spawn` | 不阻塞地起一个新 flow | 语言文档 |
| `branch` | 启动后立即不再等 | 语言文档 |

关键观察是 UE 内部的 `ControlFlows` 实验插件**显式把它的语义对齐到 Verse**,反向印证 Verse 在调度模型上是"被参考者"。

AS 插件这边没有任何语言级并发原语,所有"等一帧""异步加载""定时回调"都靠 UE 侧机制(委托、子系统、`FAkAsyncFunctionLibrary`、定时器),Hazelight 风格甚至显式劝退 Tick 滥用。

---

## 八、模块/包/部署模型

### 8.1 Verse

| 概念 | 说明 |
|------|------|
| Package | 编译单位,有 import / 依赖关系 (`GlobalProgram->AddImport`) |
| Digest | 类似预编译头,加速跨包引用 (`SBuildParams::_bGenerateDigests`) |
| `persistent var` | 持久化变量,数量受 `_MaxNumPersistentVars` 限制 |
| `entitlement` | 权限子类,数量受 `_MaxNumConcreteEntitlementSubclasses` 限制 |
| `UploadedAtFNVersion` | 包上传时的 Fortnite 版本号,编译器据此开关历史行为 |
| 部署 | 通过 UEFN 上传,语言/编译器服务端版本与客户端版本必须共识 |

### 8.2 Angelscript

| 概念 | 说明 |
|------|------|
| 模块 | AS 内部 `asIScriptModule`,以 Preprocessor 处理 `#include` 形成依赖 |
| 部署 | `.as` 文件 + 项目 Cook,无独立 Package 概念 |
| 持久化 | 走 UE 的 `SaveGame`,语言层不做语义保证 |
| 版本 | 通过仓库的 fork strategy + tests 保证向后兼容 |
| 热重载 | `DirectoryWatcher` 监听 `Script/` → `ClassReloadHelper` reinstance Actor |

### 8.3 关键差异

| 主题 | Verse | AS 插件 |
|------|-------|---------|
| 包是一等公民 | 是,语言本身有 import/digest/persistent | 否,模块由预处理器拼出 |
| 安全限制硬编码进编译器 | 是 (`_MaxNumPersistentVars` 等) | 否,纯靠工程约定 |
| 服务器一致性 | 编译器自带"运行时版本"开关 | 不需要,因为 AS 不上 Epic 的服务 |

---

## 九、工具链

| 项目 | Verse | AS 插件 |
|------|-------|---------|
| 编译器主体 | `Engine/Source/Runtime/VerseCompiler/`(C++ in engine) | 内嵌 AS 2.33 ThirdParty + `AngelscriptRuntime/Core` |
| Native 生成器 | UHT + VNI(`UVerseFunction`/`UVerseClass` 元数据驱动) | `AngelscriptUHTTool` C# UBT 插件 → `AS_FunctionTable_*.cpp` |
| IDE 支持 | Verse 专用 VS Code 扩展 | `AngelscriptEditor/CodeGen/`(~84 KB)输出 IDE stub + Source Navigation |
| 调试 | Verse 自有调试器 | `DebugServer V2` (DAP 协议) |
| 热重载 | 包级 `bImported` 二次绑定校验 | `HotReload/` + `BlueprintImpact/` 影响分析 + Commandlet |
| 测试 | 内嵌 cvar (`verse.UObjectLeniency` 等) + 引擎自动化 | `AngelscriptTest`(429 文件 / 417+ 自动化定义)+ 三套命名空间 |
| Cook 期影响分析 | 与引擎 cook 流程一体 | `BlueprintImpact` Commandlet — 改动→影响 BP 的最小重编集合 |

---

## 十、可借鉴的设计点(写给 AS 插件)

按改造成本排序,只列**架构层面的借鉴**,语法/编辑器细节不展开:

### 10.1 反射桥的"单点统一"思路

Verse 的 `BindNativeClass` 把 import / 非 import / native / 非 native 全部塞进同一个函数里,通过
`bImported` 分支区分。当前 AS 插件的反射链路分散在 `ClassGenerator` / `Bind_*.cpp` / UHT 表 /
反射回退四处,文档与心智成本较高。可以考虑在 OpenSpec 中提一个"绑定路径统一入口"提案——
不强求合并实现,但建立**单一查询点**(给定一个 UClass,知道它走哪条绑定路径、是否 import、
是否有 UHT 表项),受益于排错与覆盖率统计。

### 10.2 元数据 → 语言修饰符的自动桥接

`FClassAttribute::ApplyClassAttribute` 把 Verse attribute 直接落到 `FProperty`/`UFunction`。
这与 `Diff_HazelightInsightsToBorrow.md §三` 的 "UE 标准 Meta → AS Trait 自动桥接" 思路完全一致,
说明这个模式在两套独立系统里被反复验证。继续把 UE 标准 meta(`DeprecatedFunction` / `Latent` /
`WorldContext` / `BlueprintInternalUseOnly` 等)映射到 AS trait 仍然有补足空间。

### 10.3 编译器版本兼容开关

`SBuildParams::_UploadedAtFNVersion` + `VerseFN::UploadedAtFNVersion::EnableXxx` 是典型的
"用版本号灰度老行为"模式。当前 AS 插件靠 fork + tests 实现兼容,粒度很粗。如果未来要做语义级的
不兼容修复(比如修一个老 fork 里被宽松处理的语义),可以借鉴这种"在编译器内做版本开关"的做法,
而不是直接 break。

### 10.4 GC token stream 显式登记

Verse 通过 `AssembleReferenceTokenStream(true)` 把脚本对象持有的 UObject 显式登记给 UE GC,
保证跨界引用 GC 正确性。AS 插件目前依赖 `TWeakObjectPtr` 与运行时检查,在结构体或容器中
持有 UObject 强引用时容易出问题。可以在 OpenSpec 里专门评估一次:**AS 脚本类持有的 UObject
强引用是否都登记进了 UE GC 的 token stream / Reference Collector**,而不仅仅靠 `ClassGenerator` 的
属性反射兜底。

### 10.5 失败/Effect 系统不必引入,但思想可借

完整的 effect system 引入 AS 不现实(语言层不支持)。**但 Hazelight 已有的 `unsafe_during_construction`
正是一个最小化的 effect 思想**:把"何时可调用"的约束沉到 trait,编译期报错。继续沿这条路加
更多"轻量 effect trait"(如 `latent` / `editor_only` / `cooker_only`)是低成本高收益方向。

### 10.6 双后端思路(可选,长期)

Verse 的 BPVM/VerseVM 双后端启示:**AS 字节码本身可以有第二个目标**。当前的 `StaticJIT` 已经走过
"AS 字节码 → C++"的路径;未来如果有更进一步的需求(例如把 AS 编译到 BP VM 上,以方便老项目复用调试器),
这条路是有先例的。但成本极高,本条仅作长期视角记录。

---

## 十一、不建议借鉴的部分

- **独立 GC**:AS 的对象规模与 Verse 不在一个量级,引入分代 + 并发 GC 投入产出比极低。
- **结构化并发原语**:AS 语法不支持,强行硬塞会破坏与 Hazelight fork 的兼容性,直接用 UE 委托/子系统更简单。
- **强类型 effect 静态校验**:同上,语言层不支持。
- **包/digest 系统**:当前的 Preprocessor + `.as` 文件已经满足项目级编译需求,引入额外的包概念增加复杂度。

---

## 十二、网络预测:语言级支持 vs 框架级支持

### 12.1 Verse:`predicts` 修饰符 + 语言登记表

`VClass::BindNativeClass` 在创建 `FProperty` / `UFunction` 时,会按字段维度记录:

```cpp
// 字段层
if (Entry.IsPredicts())
{
    VerseClass->PredictsVarNames.Add(FAnsiString{PropName}, FieldProperty->GetFName());
}

// 函数层
if (Entry.IsPredicts())
{
    FName Name = UVerseFunction::GetUFunctionFName(Entry.Value.Get().StaticCast<Verse::VFunction>());
    VerseClass->PredictsFunctionNames.Add(Name);
}
```

含义:**Verse 用 `predicts` 这一关键字直接在语言层把"参与客户端预测"的字段和方法登记到 UClass**。
配合 UE 自身的回滚/插值基础设施(参考 `Mover` 插件的 `RollbackBlackboard` / `CachedLastSimTickTimeStep`),
预测的"哪些状态参与"由 Verse 编译期固化,运行期不需要二次注册。

这与 Verse 的 effect 系统形成闭环:`<transacts>` 函数天然是事务,失败时回滚整套字段,正好是
预测/回滚需要的语义基元。

### 12.2 Angelscript:框架级,需自行编排

AS 插件没有任何"网络预测语言修饰符"。要做预测需要:

- C++ 侧用 `GAS` 的 `FGameplayPredictionKey` / `ENetRole`,或 `Mover` / 自研复制框架。
- AS 侧只能调用 C++ 提供的 RPC / 复制变量,无法用一句 `var Health <predicts>: int` 让引擎自动处理。

这并非 AS 设计缺陷,而是**AS 把网络模型让给了 UE 框架**:`UFUNCTION(Server/Client/NetMulticast/WithValidation/Unreliable)` 这条线在
"Network RPC 编译测试"里岭线已经走通(见 milestones)。但**字段级预测列表的语言层登记是缺失的**,没有等价的
`PredictsVarNames`。

### 12.3 关键差异

| 主题 | Verse | AS 插件 |
|------|-------|---------|
| 修饰符位置 | 语言关键字 `predicts`,语义层识别 | UE Meta(`Replicated` / `RepNotify`),AS 仅透传 |
| 预测列表落地 | 编译期写到 `UVerseClass::PredictsVarNames/FunctionNames` | 无对应集合,框架手动维护 |
| 回滚单元 | 事务 effect 全包 | 每次 RPC + 自研回滚缓冲 |
| 适用粒度 | 字段级 / 函数级 | 整个 RPC 调用 |

---

## 十三、诊断系统:Glitch 流 vs 解析-编译-运行三段错误

### 13.1 Verse:`AppendGlitch` + `EDiagnostic` 错误码 + `ULANG_ENSUREF` 内部一致性

`Engine/Source/Runtime/VerseCompiler/Private/uLang/SemanticAnalyzer/SemanticAnalyzer.cpp`:

```cpp
void ReportAndAppendInternalError(const CAstNode& AstNode, CUTF8String Message)
{
    ULANG_ENSUREF(false, "%s", Message.AsCString());                    // ① 内部一致性 ensure
    AppendGlitch(AstNode, EDiagnostic::ErrSemantic_Internal, Move(Message));  // ② 用户可见诊断
}
```

特点:

- **统一术语 "Glitch"**,而不是 warning/error 两分。Glitch 携带 `EDiagnostic` 错误码 + AST 节点位置 + 文案。
- **错误码即文档**:`EDiagnostic::ErrSemantic_LhsNotDefineable / ExpectedIterationIterable / ExpectIterable / ExpectedIdentifier / IncompatibleArgument / Internal …` —— 可被 IDE 直接做"点击错误码跳到说明"。
- **错误恢复**:遇到错误优先返回 `CExprError` 包裹原始子节点(见 `AnalyzeDefinition` 处的 `TSRef<CExprError>::New(); ErrorNode->AppendChild(...)`),不直接中止编译,继续收集后续错误。
- **延迟校验**:`EnqueueDeferredTask(Deferred_ValidateType, ...)` 把类型校验推迟到所有定义都收齐之后,从而能给出更准确的"对端类型不存在"诊断。

### 13.2 Angelscript:三段诊断,各自独立

AS 的诊断分散在三处(参考 `Arch_ErrorDiagnostics.md`):

| 阶段 | 报错来源 | 形态 |
|------|---------|------|
| 预处理 | `Preprocessor` | 文本行号 + message |
| 编译 | `asCBuilder::WriteError/WriteWarning` | line/col + level (info/warning/error) |
| 运行时 | `asCContext::SetException` | 抛 AS 异常,UE 端通过 callback 捕获 |

特点:

- 没有"错误码"统一术语,文案由各处直接写串。
- 错误恢复粒度由 AS 内部决定,Hazelight Fork 内做了少量调整,但语义上仍然是"遇到第一个不可恢复错误就停"。
- 调试器 (`DebugServer V2`) 把运行期异常映射到 DAP 协议的 `stopped` 事件,但仍然不像 Verse 那样把编译期诊断也做成 IDE 一等公民。

### 13.3 关键差异

| 主题 | Verse | AS 插件 |
|------|-------|---------|
| 诊断单位 | Glitch (统一对象) | error/warning/info 三态 |
| 错误码 | `EDiagnostic::Xxx` 一族枚举 | 无,文本字符串 |
| 错误恢复 | 包成 `CExprError` 继续走 | 多数情况遇错即停 |
| 内部 ensure | `ULANG_ENSUREF` 与用户诊断同时触发 | 用 UE `ensure` / `check`,与脚本错误体系无耦合 |

---

## 十四、VM 值表示与字段写屏障

### 十四.1 Verse:`VValue` + `VShape` + 写屏障

来自 `Engine/Source/Runtime/CoreUObject/Public/VerseVM/Inline/VVMObjectInline.h`:

```cpp
template <EWriteMode WriteMode>
inline FOpResult VObject::SetField(FAllocationContext Context,
                                    const VShape& Shape,
                                    const VUniqueString& Name,
                                    void* Data,
                                    VValue Value)
{
    const VShape::VEntry* Field = Shape.GetField(Name);
    V_DIE_IF(Field == nullptr);
    return SetField<WriteMode>(Context, *Field, Data, Value);
}
```

要点:

- **`VValue`**:VerseVM 中的统一值类型,对象、原生值、UObject 引用全部统一表达。
- **`VShape`**:对象的运行时布局描述符 — 字段名 → 偏移/类型 的稀疏映射,**所有字段访问必须经过 Shape 路由**,不直接按硬编码偏移读写。
- **`EWriteMode`** 模板:把"是否事务""是否激活写屏障"在编译期确定,生成不同分支的 `SetField`。事务路径下,赋值会被记录进事务日志,失败时可整体回滚。
- **`FAllocationContext`**:GC 与分配的统一上下文,所有需要分配/写入的 API 都强制传它,从签名就能看出是否触发 GC。

### 十四.2 Angelscript:直接结构体偏移 + UObject 反射

AS 这边的字段访问基本是:

- AS 自身对象:按 `asCObjectType` 的 `properties` 偏移直接读写,字节码层 `asBC_LoadObj` / `asBC_RDS4` 等。
- UObject 引用:走 `FProperty::SetValue_InContainer` / `GetValue_InContainer`,本质是反射调用。
- **没有写屏障**,事务也不存在;运行时性能直接来自"少一层间接"。

### 十四.3 关键差异

| 主题 | Verse | AS 插件 |
|------|-------|---------|
| 值表示 | 统一 `VValue` | AS 原生类型 + `asPWORD` 句柄 |
| 字段访问 | 通过 `VShape` 路由 + 写屏障 | 直接偏移 / `FProperty` 反射 |
| 事务支持 | `EWriteMode` 模板内建 | 无 |
| 可观测性 | Shape 是运行时元数据,可被反射 | AS `asITypeInfo` 提供等价能力,但无"写屏障 hook" |

性能/能力的取舍非常清晰:**Verse 用每次写一次 hash + 写屏障的代价换取事务/失败语义/网络预测的可能性,
AS 用直接偏移换取最大化运行时速度**。

---

## 十五、序列化与 Native 重绑定模式

`Engine/Source/Runtime/CoreUObject/Private/VerseVM/VVMVerseEnum.cpp::UVerseEnum::Serialize`:

```cpp
void UVerseEnum::Serialize(FArchive& Ar)
{
    Super::Serialize(Ar);
#if WITH_VERSE_BPVM
    if (Ar.IsLoading())
    {
        // Try to bind native enums to their C++/VNI definitions.
        if (IsNativeBound())
        {
            Verse::IEngineEnvironment* Environment = Verse::VerseVM::GetEngineEnvironment();
            ensure(Environment);
            Environment->TryBindVniType(this);
        }
    }
#endif
}
```

含义:

- **加载阶段重绑 native**:cooked 包反序列化出 `UVerseEnum`/`UVerseClass`/`UVerseStruct` 后,
  如果它声明自己是 native(`IsNativeBound()`),会主动通过 `IEngineEnvironment::TryBindVniType()`
  把 C++ / VNI 的真实定义贴回去。
- **VM 切换守门**:整段逻辑被 `WITH_VERSE_BPVM` 包裹,意味着这条路径只在 BPVM 模式启用,
  VerseVM 模式下走的是另一条路径(在 VM 启动时统一从 `GlobalProgram` 拉)。

对应在 AS 插件:

- AS 自身没有"被序列化的 UClass"——脚本类是 `ClassGenerator` 编译时合成出来的,加载时已经存在。
- UObject 端的 cooked 数据走 UE 默认 Serialize,无需 AS 介入。
- 因此**没有"加载期重绑 native"的等价问题**。但反过来,AS 的设计也意味着**cooked 后的脚本类不可热重载**——
  生产构建里没有 `ClassGenerator` 路径再跑一次。

| 主题 | Verse | AS 插件 |
|------|-------|---------|
| Cooked 期 native 绑定 | `UVerseEnum::Serialize` + `TryBindVniType` 重绑 | 无,native 由 `Bind_*.cpp` 在引擎启动时一次性建好 |
| 编辑器 vs 运行时一致性 | 双 VM 路径分别处理(`WITH_VERSE_BPVM`) | 一套 AS Runtime 兼容编辑器 + 运行时 |
| 热重载窗口 | 编辑器内 Verse 编译 + 包级二次绑定 | 编辑器内 `DirectoryWatcher` + `ClassReloadHelper`,生产关闭 |

---

## 十六、关键差异速查表

把全文核心差异折叠成一张表,便于横向对照:

| # | 维度 | Verse | AS 插件 | 备注 |
|---|------|-------|---------|------|
| 1 | 语言定位 | 函数式 + OOP + 事务 + 失败上下文 | 静态强类型 OOP | 设计哲学根上不同 |
| 2 | 语言入口 | `.verse` + Package | `.as` + 预处理器 `#include` | 包模型 vs 文件模型 |
| 3 | 编译流水线 | Lex → VST → Sema(多 pass)→ IR → 字节码 | Preproc → Parser → Compiler → 字节码 →(StaticJIT) | Verse 多 pass + deferred task |
| 4 | 类型系统 | 类型与 AST 同层,可参与约束求解 | 与 AST 解耦 | 见 §2 |
| 5 | Effect 系统 | `SEffectSet` 静态强约束 | 无 | Verse 独有 |
| 6 | 失败语义 | `decides` / `?` 一等公民 | 普通 `bool` + 异常 | Verse 独有 |
| 7 | 并发原语 | `spawn / race / sync / rush / branch` | 无,借 UE 委托/Tick | Verse 独有 |
| 8 | VM 数量 | VerseVM + BPVM 双后端 | `asCContext` + StaticJIT | 双后端 vs 单后端+JIT |
| 9 | 值表示 | `VValue` + `VShape` + 写屏障 | AS 原生类型 + 直偏移 | 见 §14 |
| 10 | UE 反射桥 | `BindNativeClass` 单点统一 | `ClassGenerator` + Bind_*.cpp + UHT 表 + 反射回退 | 见 §4 / §10.1 |
| 11 | Native 类型来源 | UHT + VNI 自动 | 121 个手写 `Bind_*.cpp` + UHT 工具 | 自动化程度差异 |
| 12 | GC | VVMHeap 分代+并发 + token stream 同步 | AS GC + UE GC,弱引用边界 | 见 §5 |
| 13 | 网络预测 | `predicts` 字段/函数级 + `PredictsVarNames` 表 | 无,框架级 | 见 §12 |
| 14 | 诊断 | Glitch + `EDiagnostic` 统一码 | error/warning/info 三态 | 见 §13 |
| 15 | 序列化重绑 | `Serialize` + `TryBindVniType` | 无,加载即存在 | 见 §15 |
| 16 | 持久化变量 | `persistent var` + 编译器硬限 | UE `SaveGame` | Verse 独有 |
| 17 | 版本兼容 | `_UploadedAtFNVersion` 灰度 | Fork strategy + tests | 见 §10.3 |
| 18 | 热重载 | 包级 import 二次绑定 | DirectoryWatcher + ClassReloadHelper | 编辑器内场景一致 |
| 19 | 调试协议 | Verse 自有调试器 | DebugServer V2 (DAP) | DAP 标准更通用 |
| 20 | 元数据→修饰符 | `FClassAttribute::ApplyClassAttribute` | UE meta → AS trait 桥接(部分已落地) | 思路一致 |

---

## 十七、对 OpenSpec 立项的建议

基于 §10 借鉴点 + §12-§15 新增维度,给出未来可在 `openspec/changes/` 建立的 5 个候选 change(只列**主题与价值**,不展开任务):

1. **`as-binding-single-entry`**——给 `ClassGenerator` / Bind / UHT 表 / 反射回退建立**单点查询入口** + 路径标记(借鉴 §4.1 / §10.1)。
2. **`as-uobject-reference-token-audit`**——审计 AS 脚本类持有的 UObject 强引用是否都进入 UE GC 的 ReferenceCollector(借鉴 §10.4)。
3. **`as-meta-trait-bridge-extension`**——把 UE 的 `Latent` / `WorldContext` / `BlueprintInternalUseOnly` 映射成 AS trait,延续 `unsafe_during_construction` / `accept_temporary_this` 的模式(借鉴 §10.2 + Hazelight 已有工作)。
4. **`as-diagnostic-error-codes`**——给 AS 编译/运行期错误增加**统一错误码**(类似 `EDiagnostic::Xxx`),配合现有 `Arch_ErrorDiagnostics.md`,支持 IDE 跳转与文档化(借鉴 §13)。
5. **`as-version-gated-semantics`**——为未来 AS 语义级修复引入**版本号灰度开关**而不是 break 老脚本(借鉴 §10.3 + Verse `_UploadedAtFNVersion`)。

这 5 个 change 互相独立、风险递增、收益方向不同,可按业务优先级分批排进 OpenSpec。本文档只做架构差异结论,**不创建 OpenSpec 工件**。

---

## 十八、优劣判断与选型指南(主观)

> 本节与前面 §一-§十七 不同,**带有判断与立场**。素材来自 §一-§十七 的客观对照,
> 但取舍是一家之言,可作为团队选型讨论的起点而不是结论。

### 18.1 Verse 的强项 — 真正的"语言级创新"

1. **失败上下文是 game-changer**
   `decides` / `?` / `if (x := …)` 把"操作可能失败"做成一等公民。游戏逻辑里到处都是"找不到""超出范围""权限不足"——AS / C++ / BP 都靠 `bool` 返回 + 防御 `if`,Verse 把它沉进语言里,**配合事务回滚**,失败时所有副作用自动撤销。这条 AS 完全追不上。
2. **Effect 系统挡掉了一类 bug**
   `<transacts><suspends><varies><no_rollback>` 写在签名里,编译期就告诉你"这个函数不能在构造期调""这个函数会暂停"。Hazelight 的 `unsafe_during_construction` 已经验证过这个思路低成本高收益,Verse 是**整套铺到了语言层**而不是某几个 trait。
3. **结构化并发 + 网络预测一体化**
   `spawn / race / sync / rush` + `predicts` 字段标记,在多人在线场景下,"启动异步行为""客户端预测""失败回滚"被收敛成同一套语言模型。AS 这一侧是把这些拆给 UE 委托 / Tick / GAS / Mover 去拼。**架构性差距,而不是细节差距**(详见 §七 / §十二)。
4. **反射桥单点统一**
   `BindNativeClass` 一个函数把 import / 非 import / native / 用户类全收下;`UVerseClass` 直接派生 `UClass`(详见 §四)。AS 这边是 `ClassGenerator` + 121 个 `Bind_*.cpp` + UHT 表 + 反射回退四条腿走路,长期维护成本明显更高。

### 18.2 Verse 的弱项 — 当下还没成熟

1. **语言生态封闭,通用 UE 项目用不了(目前)**
   Verse 主要绑 UEFN。`SBuildParams::_UploadedAtFNVersion`(详见 §二.1)这种"按上传时的 Fortnite 版本灰度老语义"的 hack,本质告诉你**语言/编译器还在剧烈演进,服务端一致性是个持续负担**。自掌控的项目接进来,等于把"语言版本"这个变量交给了 Epic 节奏。
2. **双 VM 是"未完成态"**
   BPVM 是过渡形态,VerseVM 是终态——但终态的稳定时间与性能,Epic 自己也没给出明确路线图。源码里 `HACK_VMSWITCH` 注释非常醒目(详见 §三.1)。早期接入有踩坑风险。
3. **学习曲线 + UE 习惯撕裂**
   失败上下文、effect、不可变默认、函数式风格都是新概念。**UE 老兵的肌肉记忆基本要重练**——从"写一个 ATickActor 然后 Tick 里改 Health"切到"写一个 transacts 函数然后 spawn 一个 race",心智转换非常大。团队迁移代价高。
4. **写命令式逻辑啰嗦**
   纯函数 + 不可变默认在表达 ML / 数据管线很爽,但游戏 80% 是命令式状态机。在 Verse 里写"按 R 换弹"会比 AS / BP / C++ 啰嗦,语法噪音大。
5. **工具链黑盒程度高**
   编辑器 / 调试器 / IDE 扩展都是 Epic 一手把控,做不了 DAP 协议这种"标准协议接入",只能等 Epic。

### 18.3 AS 的强项 — 工程上扎实

1. **零学习成本接入 UE 团队**
   语法是 C++ 子集 + UE 风格扩展(`UPROPERTY` / `UFUNCTION` 透传 / `TArray` / `TMap`),会写 BP 和 C++ 的人**当天就能上手**。Hazelight 的样例脚本本质是"BP 替代品",团队迁移阻力极低。
2. **完全自掌控**
   Fork 在自己手里,语言演进节奏自己定;121 个 `Bind_*.cpp` 虽然多但都是自家代码,任何 UE API 演进都能跟上;`AngelscriptUHTTool` 是开源 C# UBT 插件,不是黑盒。**不依赖任何第三方服务 / 账号体系**。
3. **基础设施成熟度对当下项目友好**
   - 417+ 测试 + 27 张 CSV 状态导出 + DebugServer V2 (DAP) + StaticJIT + BlueprintImpact Commandlet —— 这套**生产级别的诊断 / 测试 / 调试基础设施已经全部 ready**,Verse 这一侧不少都还在 "Epic 内部 dogfood" 阶段。
   - 热重载在编辑器内体验顺滑(`DirectoryWatcher` + `ClassReloadHelper`)。
4. **直接对接 UE 反射,心智一致**
   AS 类被 `ClassGenerator` 合成成普通 `UClass`,在 UE 编辑器里就是个能挂 Component 的 Actor,蓝图能继承、能引用、能调函数。**和 UE 现有工作流无缝**。

### 18.4 AS 的弱项 — 是真有的,不能粉饰

1. **语言能力是 90 年代到 2010 年代的水平**
   - 没有失败上下文,`bool` 满天飞;
   - 没有 effect,`UnsafeDuringActorConstruction` 这种约束需要**逐个手写桥接**(借助 §10.2 的"meta→trait"模式);
   - 没有语言级并发,异步逻辑要靠 UE 委托 / Tick / Subsystem 编排,容易乱;
   - 没有事务 / 回滚语义,网络预测和"撤销"功能都得框架层硬写;
   - 没有现代类型系统(高阶泛型、和类型、模式匹配)。
2. **AS 上游 fork 太远,backport 越来越贵**
   AS 2.33 → 2.38 已经做了选择性吸收,但 Hazelight Fork 中间叠了不少改动,**任何来自上游的新特性都需要"看一眼合不合得进来"**——这是个长期的技术债源头。
3. **121 个手写 Bind 是甩不掉的维护包袱**
   每次 UE 引擎升大版本(5.5 → 5.6 → 5.7),都要跟着审一轮 Bind。Verse 这一侧是 UHT + VNI 自动出 native,演进成本明显低。**这是设计权衡,不是工程问题**——除非把 UHT 工具链做得像 Verse 那么自动。
4. **跨界 GC 边界依赖人工自律**
   AS 类持有 UObject 强引用要走 `TWeakObjectPtr` / `TObjectPtr` 路由,**没有 Verse 那种 token stream 显式登记的强保证**(详见 §五 / §10.4)。容器 / 嵌套结构里漏一处就是潜在 GC bug。

### 18.5 场景推荐

| 场景 | 推荐 | 理由 |
|------|------|------|
| **UEFN / Fortnite Creator** | Verse | Epic 锁定,无替代选项 |
| **未来 5 年自掌控的 UE 单机项目** | AS | 工程稳定、可控、团队迁移便宜 |
| **大型多人在线游戏,网络预测重** | GAS + C++(短期);中期再看 Verse | 现阶段 Verse 还不够稳,GAS 体系成熟 |
| **Hazelight 风格"剧情驱动 + 系统化"** | AS | 这正是它原生的甜蜜区 |
| **Epic 自家未来项目** | Verse | Epic 自己也在 dogfood,会持续演进 |
| **要在 UE 5.7 之后立刻落地的脚本层** | AS | 工具链 / 测试 / 调试已经齐了,Verse 还在路上 |

### 18.6 一句话总结

> **Verse 在语言设计上领先一代,AS 在工程交付上领先一代。**

- **选 Verse 是赌**"语言能力的红利能 cover 工具链 / 生态 / 学习曲线的代价"。
- **选 AS 是赌**"工程稳定性 + 团队效率 + 完全自掌控比语言层创新更值钱"。

对当前仓库(自掌控的 AS 插件,基础设施齐全)的判断:
**继续把 AS 做厚是更理性的选择,但应主动从 Verse 那里偷设计模式**。
具体可偷的方向已收敛在 §十.1-10.5 与 §十七 的 5 个 OpenSpec 候选 change 中:
- effect-as-trait(§10.2 / §10.5)
- 错误码统一(§13 / §17.4)
- 反射桥单点入口(§4.1 / §10.1 / §17.1)
- token stream 显式登记(§5 / §10.4 / §17.2)
- 版本号灰度(§10.3 / §17.5)

让 AS 的工程优势继续放大,同时缩小语言层的代差。

### 18.7 反直觉的看法

Verse 看起来更"现代",但它意味着**整个团队的脑子都要切换到 Epic 的语言哲学里**。
AS 的"没那么先进"在团队管理意义上反而是个特性 —— 招进来的程序员 day one 就能写,
代码评审不需要先开半小时课讲什么是 effect、什么是失败上下文、什么是 transacts。

**先进性是有运营成本的**——这一点在做技术选型时经常被忽略。
对资源紧张、团队组成偏向"懂 UE 的 C++ / BP 程序员"的项目,
"够用且稳定"通常比"先进但需要再培训"更值得选。

---

## 参考链接(均来自 knot MCP 检索结果)

- `Engine/Source/Runtime/VerseCompiler/Public/uLang/Parser/VerseGrammar.h`
- `Engine/Source/Runtime/VerseCompiler/Public/uLang/Syntax/VstNode.h`
- `Engine/Source/Runtime/VerseCompiler/Public/uLang/Semantics/Effects.h`
- `Engine/Source/Runtime/VerseCompiler/Public/uLang/SemanticAnalyzer/SemanticAnalyzer.h`
- `Engine/Source/Runtime/VerseCompiler/Public/uLang/CompilerPasses/CompilerTypes.h::SBuildParams`
- `Engine/Source/Runtime/VerseCompiler/Private/uLang/SemanticAnalyzer/SemanticAnalyzer.cpp::AnalyzeDefinition / AnalyzeFilterExpressionAst`
- `Engine/Source/Runtime/CoreUObject/Private/VerseVM/VVMClass.cpp::VClass::BindNativeClass`
- `Engine/Source/Runtime/CoreUObject/Private/VerseVM/VVMVerseEnum.cpp::UVerseEnum::Serialize`
- `Engine/Source/Runtime/CoreUObject/Public/VerseVM/VVMTypeInitOrValidate.h::GetUVerseClass`
- `Engine/Source/Programs/UnrealBuildTool/Configuration/Rules/TargetRules.cs::bUseVerseBPVM`
- `Engine/Plugins/Experimental/ControlFlows/Source/ControlFlows/Public/ControlFlowConcurrency.h::FConcurrentControlFlowBehavior`
- `Engine/Source/Runtime/CoreUObject/Public/VerseVM/Inline/VVMObjectInline.h::VObject::SetField`(VValue/VShape/写屏障)
- `Engine/Source/Runtime/CoreUObject/Private/VerseVM/VVMClass.cpp::PredictsVarNames / PredictsFunctionNames`(网络预测语言登记)
- `Engine/Source/Runtime/VerseCompiler/Private/uLang/SemanticAnalyzer/SemanticAnalyzer.cpp::ReportAndAppendInternalError`(诊断系统:Glitch + ULANG_ENSUREF)
- `9.2. Package系统与垃圾回收` 知识库章节(VVMHeap / Verse GC vs Native GC)
- `6.2. 网络预测与架构层次` 知识库章节(回滚 / 平滑 / 黑板缓存)
- 本仓库:`AGENTS.md` / `Plugins/Angelscript/` / `Documents/Knowledges/ZH/AS_*.md` / `Documents/Knowledges/ZH/Arch_ErrorDiagnostics.md`
