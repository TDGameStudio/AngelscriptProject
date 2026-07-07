# RT_StaticJIT — StaticJIT 与执行性能

> **所属前缀**: RT_（运行时子系统族）
> **关注层面**: 站在"如何让 AngelScript 字节码绕过解释器，以原生 C++ 函数指针的形式被 `asCContext` 直接调用"的视角看 `StaticJIT/` 子系统——`FAngelscriptStaticJIT` 怎么在 cook 期把每个脚本函数翻译成等价 C++、`FAngelscriptPrecompiledData` 怎么序列化字节码与符号引用、`FStaticJITCompiledInfo` 怎么用 GUID 把"transpile 时的字节码"和"link 时的 .jit.cpp"绑定、`FJITDatabase` 怎么把翻译产物按 FunctionId 注册回 `asCScriptFunction::jitFunction`、以及 `asCContext::ExecuteNext` / `CallScriptFunction` 怎么走"先看 jitFunction 指针"的快路径。本文不重写传统运行期 JIT（LLVM / asmjit）原理，不重写 `FunctionCallers.h` 的 C++ → C++ trampoline 模板族（那是 `Type_FunctionCaller` 的事），不重写预处理 / 编译流水线（那是 `Arch_RuntimeLifecycle`、`RT_HotReload`、`Type_Preprocessor` 的事）；本文聚焦的是**Static JIT 这条"既不在运行期产生机器码，也不依赖 IR / asmjit / LLVM"的特殊执行加速通路**——它把"脚本函数 → 字节码 → 解释器"这条链路，**额外**生成一份"脚本函数 → 编译期翻译的 C++ → 由编译器 / 链接器固化为机器码"的旁路；运行期只剩"指针存在则走 jit、否则走 interpreter"的二选一。
> **关键源码**:
> `Plugins/Angelscript/Source/AngelscriptRuntime/StaticJIT/AngelscriptStaticJIT.{h,cpp}` (~3970 行 .cpp + ~521 行 .h，`FAngelscriptStaticJIT` / `FStaticJITContext` / `FJITDatabase` / `WriteOutputCode` / `GenerateCppCode`)
> · `Plugins/Angelscript/Source/AngelscriptRuntime/StaticJIT/PrecompiledData.{h,cpp}` (~3071 行 .cpp + ~674 行 .h，`FAngelscriptPrecompiledData` / `FAngelscriptPrecompiledModule` / `FAngelscriptPrecompiledFunction` / `Save` / `Load` / `ApplyToModule_Stage1/2/3`)
> · `Plugins/Angelscript/Source/AngelscriptRuntime/StaticJIT/AngelscriptBytecodes.{h,cpp}` (~6671 行 .cpp + ~155 行 .h，`FAngelscriptBytecode` 基类与 ~200+ 个 opcode 的 `Implement` 翻译)
> · `Plugins/Angelscript/Source/AngelscriptRuntime/StaticJIT/StaticJITHeader.{h,cpp}` (~393 行 .h + ~311 行 .cpp，`FStaticJITFunction` / `FJitRef_*` / `FStaticJITCompiledInfo`)
> · `Plugins/Angelscript/Source/AngelscriptRuntime/StaticJIT/StaticJITConfig.h` (~20 行，`AS_CAN_GENERATE_JIT` / `AS_SKIP_JITTED_CODE` / `AS_JIT_VERIFY_PROPERTY_OFFSETS` / `AS_WITH_STATIC_JIT_DIAGNOSTICS`)
> · `Plugins/Angelscript/Source/AngelscriptRuntime/StaticJIT/StaticJITBinds.{h,cpp}` (~1042 行 .cpp + ~121 行 .h，`FScriptFunctionNativeForm` 子类族：构造 / 析构 / 赋值 / 模板实例化 / TArray 迭代器 / Delegate 执行 / UObject Cast 等)
> · `Plugins/Angelscript/Source/AngelscriptRuntime/StaticJIT/StaticJITDiagnostics.{h,cpp}` (~421 行 .cpp + ~51 行 .h，`as.StaticJIT.DumpDiagnostics` 控制台命令、`FStaticJITDiagnostics::CaptureSnapshot`)
> · `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.cpp` (~1625–1830 行，`Initialize` 中 `SetJITCompiler` / `WriteOutputCode` / `bStaticJITTranspiledCodeLoaded` / `FStaticJITCompiledInfo::Get` 校验链路)
> · `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_context.cpp::ExecuteNext / CallScriptFunction` (~970–1010 / 1455–1495 行，`jitFunction != nullptr` 快路径)
> · `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_module.cpp::JITCompile` / `as_scriptfunction.cpp::JITCompile` — AS 内核唯一调用 `asIJITCompiler::CompileFunction` 的两个入口
> **关联文档**:
> `Documents/Knowledges/ZH/AS_VirtualMachine.md` — `asCContext::Execute` / `ExecuteNext` 解释器主循环（StaticJIT 在其前面插一层 jit 指针检测）
> · `Documents/Knowledges/ZH/AS_ByteCode.md` — `asEBCInstr` 指令集与 `asBCInfo` 元表（StaticJIT 按指令分发翻译）
> · `Documents/Knowledges/ZH/Type_FunctionCaller.md` — `CallFunctionCaller` / `sysFunc->caller` 路径（StaticJIT 翻译 `CALLSYS` 时直接调用同一个 caller，而不是再走解释器分发）
> · `Documents/Knowledges/ZH/Type_BindSystem.md` — `FBind` 注册时的 `SCRIPT_NATIVE_*` 宏，决定 StaticJIT 能否走 native 形式
> · `Documents/Knowledges/ZH/RT_HotReload.md` — bScriptDevelopmentMode 与 bUsePrecompiledData 互斥时的 cache 装载策略
> · `Documents/Knowledges/ZH/AS_ForkDifferences.md` — UE Fork 的 `[UE++]` 改动如何与上游 JIT v2 接口分叉
> **外部参考**:
> [AngelscriptForkStrategy](../../Guides/AngelscriptForkStrategy.md) — fork 演进策略，含 `Plan_AS238JITv2Port` 索引

---

## 概览

本文聚焦一个核心问题：**Angelscript 默认靠 `asCContext::ExecuteNext` 解释字节码运行，每条 `asEBCInstr` 都要 switch-case 派发；UE Fork 的 StaticJIT 子系统选了一条**完全不同**的路：cook 期把字节码翻译成等价 C++ 源码、跟随游戏一起编译进 .exe，运行期通过 `jitFunction` 函数指针直接跳过去执行。它既不是 LLVM/asmjit 那种运行期生成机器码的"传统 JIT"，也不是简单的 caching；它在 fork 中扮演的是"AOT 静态预编译 + 字节码归档 + 符号 GUID 校验"的复合角色。本文展开它从 `cook → link → load → run` 四阶段的全部链路。**

```text
================================================================================
  StaticJIT 全景：从 .as 源码到运行期 jitFunction(...) 的四阶段链路
================================================================================

  阶段一：Cook 期 transpile（命令行: -as-generate-precompiled-data）
  -------------------------------------------------------------------
  .as 文件                       FAngelscriptEngine::Initialize
     │                                    │
     │ Preprocessor.Preprocess            │ if (bGeneratePrecompiledData)
     │ Compiler.Build → asCModule         │   PrecompiledData = new (...)
     │ scriptFunctions[].byteCode         │   StaticJIT = new FAngelscriptStaticJIT
     │                                    │   Engine->SetJITCompiler(StaticJIT)
     │                                    │
     ▼                                    ▼
  asCModule::JITCompile()        FAngelscriptStaticJIT::CompileFunction
     │ for each scriptFunc:        ┌─ bGenerateOutputCode == true
     │   func->JITCompile()        │  → FunctionsToGenerate.Add(func, {})
     │     → jit->CompileFunction  │  → *OutJITFunction = nullptr; return 1
     │                             └─（不在这里产出代码，仅记录待生成列表）
     ▼
  Engine->WriteOutputCode()  ←  Initialize 末尾 if (bGenerateOutputCode)
     │                                    │
     │  ┌──────────────────────────────┐  │
     │  │ DetectScriptType (扫描所有  │  │
     │  │   asCObjectType 的稳定性)   │  │
     │  │ AnalyzeScriptFunction       │  │
     │  │ GenerateCppCode (按 opcode)│  │
     │  │   → File->Content (.hpp)   │  │
     │  └──────────────────────────────┘  │
     ▼                                    ▼
  AS_JITTED_CODE/                    PrecompiledScript.Cache
    AngelscriptJitCode_N.jit.cpp        (FAngelscriptPrecompiledData binary)
    XxxModule.as.jit.hpp                 ・DataGuid (FGuid)
    AngelscriptJitInfo.jit.cpp           ・Modules.Functions[].ByteCode
      └─ static FStaticJITCompiledInfo   ・TypeReferences / FunctionReferences
         Info(FGuid(...));               ・StaticNames / BuildIdentifier
                                         ・GlobalReferences / PropertyRefs

  阶段二：Link 期固化（普通 UE 构建，无任何 JIT 行为）
  -------------------------------------------------------------------
  生成的 .jit.cpp 文件被纳入 AngelscriptRuntime/AngelscriptScripts 模块
    AS_FORCE_LINK static const FStaticJITCompiledInfo JitInfo(FGuid(A,B,C,D));
    AS_FORCE_LINK static const FStaticJITFunction AS_xxx__yyy_Register(0x..u, ...);
    AS_FORCE_LINK FJitRef_Function FREF_xxx__yyy(0xRRRu);
  → 这些静态对象的构造函数把符号塞进 FJITDatabase::Get()，
    跨模块由 [[gnu::used,gnu::retain]] / pragma 防止链接器丢弃。

  阶段三：Run 期 load（普通 cooked build 启动）
  -------------------------------------------------------------------
  FAngelscriptEngine::Initialize
    bUsePrecompiledData = true (条件: !bGenerate && !bIgnore && !cmdlet
                                       && !WITH_EDITOR && !DevMode)
    PrecompiledData->Load(PrecompiledScript.Cache)
    if (CompiledInfo->PrecompiledDataGuid == PrecompiledData->DataGuid)
       → JIT 入口表保留
    else
       → FJITDatabase::Get().Clear()  (放弃所有 jitFunction)
    InitialCompile() → CompileModule_Code_Stage3 → ScriptModule->JITCompile()
       → asCScriptFunction::JITCompile()
         → engine->GetJITCompiler() == nullptr (cook build 已不再 SetJITCompiler)
         → 此调用是 no-op；jitFunction 由 FStaticJITFunction 静态对象写入

  阶段四：Run 期 dispatch（hot path）
  -------------------------------------------------------------------
  asCContext::ExecuteNext / CallScriptFunction
    if (m_currentFunction->jitFunction != nullptr) {
       FScriptExecution Execution(this);
       jitFunction(Execution, stackFramePtr, &outValue);  // ★ 直接调用 .exe 中的 C++
       if (!Execution.bExceptionThrown) return asEXECUTION_FINISHED;
       else                              return asEXECUTION_EXCEPTION;
    }
    // 否则正常进入 PushCallState() + opcode switch (保留作为 fallback)
```

后续章节按 [概念边界 → 字节码翻译机制 → 预编译数据 schema → Engine 整合点 →
            CallFunctionCaller 桥接 → 性能模型 → fork 与 2.38 演化 → 限制矩阵 →
            BlueprintImpact 协作 → 调试与诊断] 的顺序展开。

---

## 一、概念边界：StaticJIT 不是"传统 JIT"

### 1.1 一张比对表先把"我是谁 / 我不是谁"钉死

| 维度 | 传统运行期 JIT (asmjit / LLVM JIT / V8) | UE Fork 的 StaticJIT |
|------|-------------------------------------|---------------------|
| 代码生成时刻 | 运行时（首次调用 / 热点检测后） | **Cook 期，命令行 `-as-generate-precompiled-data` 一次性产出** |
| 输出形式 | 内存中的可执行机器码（mmap PROT_EXEC） | **磁盘上的 .jit.cpp / .jit.hpp 源文件**，靠 UE 后续构建链路编译进 .exe |
| 是否需要 IR | 通常需要（LLVM IR / asm DSL） | **不需要**——直接把 `asEBCInstr` 翻译成 C++ 表达式 |
| 是否需要 asmjit / LLVM | 是 | **否**——零额外依赖，运行期甚至没有任何代码生成器存在 |
| 失败 fallback | 抛弃 JIT，回退解释器 | **抛弃 JIT 入口表（`FJITDatabase::Clear`）**，回退解释器；本身没有第二次编译机会 |
| 内存占用 | JIT 缓冲区随热点增长 | **零运行期分配**——所有 JIT 函数都是普通 .text 段 |
| 与 ASLR / Code Sign 兼容 | 需要 mmap RWX 或者 W^X switch | **完全兼容**——是普通 .exe 代码段，不涉及可写代码页 |
| 平台限制 | 取决于 asmjit/LLVM 平台支持 | 受限于"能否生成 C++ 文件 + 重编译" → 对运行期目标无平台限制；**生成阶段**仅限 Windows/Linux（`AS_CAN_GENERATE_JIT`） |

`StaticJIT/StaticJITConfig.h` 把这一边界用三个宏写得很直白：

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/StaticJIT/StaticJITConfig.h
// 角色: StaticJIT 的"我能不能跑"开关族
// ============================================================================
#ifndef AS_CAN_GENERATE_JIT
#define AS_CAN_GENERATE_JIT (PLATFORM_WINDOWS || PLATFORM_LINUX)  // ★ 仅生成阶段
#endif

#if WITH_EDITOR
#ifndef AS_ENABLE_EDITOR_JITTED_CODE
#define AS_SKIP_JITTED_CODE                                       // ★ 编辑器永不用 jit
#endif
#endif

#ifndef AS_JIT_VERIFY_PROPERTY_OFFSETS
#define AS_JIT_VERIFY_PROPERTY_OFFSETS (!UE_BUILD_SHIPPING && !UE_BUILD_TEST)
#endif

#ifndef AS_WITH_STATIC_JIT_DIAGNOSTICS
#define AS_WITH_STATIC_JIT_DIAGNOSTICS (!UE_BUILD_SHIPPING)
#endif
```

`AS_SKIP_JITTED_CODE` 由 `WITH_EDITOR` 自动开启意味着：**编辑器永远走解释器**——这与热重载、调试器、Blueprint 反查等编辑器特有功能的语义需求是匹配的。Static JIT 的位置非常窄：**Shipping/Test/Development cooked build 的 `bUsePrecompiledData==true` 分支**。

### 1.2 "Static" 这个词的双重含义

- **Static-1（无运行期 codegen）**：所有翻译动作都发生在 cook 期 `WriteOutputCode`，运行期 `FAngelscriptStaticJIT::CompileFunction` 实际上是个 no-op（参见 §三）。
- **Static-2（静态注册表）**：JIT 入口由 `FStaticJITFunction Register(...)` 这种 static const 对象在程序启动期通过其构造函数把自己塞进 `FJITDatabase::Get().Functions`。这与传统 JIT 的"运行期 emit + map" 形成强对比。

这两层"static"叠在一起，让本子系统的运行期表面非常薄——只有一个 `TMap<uint32, FJITFunctions>` 加几个查找列表。

---

## 二、字节码翻译流水线：`FAngelscriptStaticJIT` 内部

### 2.1 入口：`asIJITCompiler::CompileFunction` 的"伪实现"

AS 内核里 `asCModule::JITCompile()` 会扫描 `scriptFunctions` 调用 `func->JITCompile() → jit->CompileFunction(this, &jitFunction)`。UE Fork 的实现做了关键的"延后处理"：

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/StaticJIT/AngelscriptStaticJIT.cpp
// 函数: FAngelscriptStaticJIT::CompileFunction
// ============================================================================
int FAngelscriptStaticJIT::CompileFunction(asIScriptFunction* ScriptFunction, asJITFunction* OutJITFunction)
{
#if AS_CAN_GENERATE_JIT
    if (bGenerateOutputCode)
    {
        FunctionsToGenerate.Add((asCScriptFunction*)ScriptFunction, FGenerateFunction());
        *OutJITFunction = nullptr;     // ★ 这里**不**返回函数指针
        return 1;                      // ★ 仅登记到 FunctionsToGenerate 列表
    }
#endif
    check(false);                      // ★ 未在 generate 模式下被调用是非法路径
    return 0;
}
```

也就是说，每次 `asCModule::JITCompile` 仅完成"采集本模块所有脚本函数清单"，真正翻译动作在 `Initialize` 末尾的 `WriteOutputCode()` 一次性遍历 `FunctionsToGenerate` 来做。这一点是与上游 AS 抽象 `asIJITCompiler` 接口最大的语义偏离——上游期望返回值就是 `jitFunction`，UE Fork 把它解耦为"先收集，再生成磁盘文件"。

### 2.2 `WriteOutputCode` 的三次循环

```text
WriteOutputCode(OutGeneratedFiles?):
  ── 1) DetectScriptType (扫描 asCObjectType)
  │     标记哪些类型在 cook 与 link 之间"可能尺寸不同"，
  │     对应每个 type 决定要不要写 `bCanHardcodeSize` 还是用
  │     `Func->ReferenceTypeSize(...)` 间接查找
  │
  ── 2) AnalyzeScriptFunction (统计调用图、devirtualize 候选)
  │     for each FunctionsToGenerate:
  │       决定 FunctionSymbolName / FunctionDeclaration
  │       识别 always-jit、virtual override 候选
  │
  ── 3) GenerateCppCode (真正出 C++)
        for each FunctionsToGenerate:
          构造 FStaticJITContext (per-function)
            FunctionHead: 签名 + "alignas(8) asBYTE l_stack[N]"
                         + asQWORD/asBYTE/asDWORD/float/double/void* 寄存器
                         + (debug builds) SCRIPT_DEBUG_CALLSTACK_FRAME
            遍历字节码:
              For each instruction (asEBCInstr):
                FAngelscriptBytecode::GetBytecode(Instr).Implement(ctx);
                  → 写入 FunctionContent 一行行 C++
            FunctionFoot: return / 异常清理 label
          WriteOutFunction → File->Content.Add(Head + Body + Foot)
```

`AngelscriptBytecodes.cpp` 6671 行就是 ~200+ 个 opcode 的 `Implement` 定义集合，每个 opcode 一个 `IMPL_BYTECODE_BEGIN(asBC_xxx) ... IMPL_BYTECODE_END(asBC_xxx)` 块；它们都通过 `bRegistered` static 模板成员，在静态初始化阶段把自己注册到 `FAngelscriptBytecode::GetBytecodeMap()`。

### 2.3 一段真实翻译产物（取自 `Plugins/.../AngelscriptTest/StaticJIT/AOT/Generated/`）

cook 出的 `.hpp` 内容极具说明性：

```cpp
// ============================================================================
// 文件: AngelscriptTest/StaticJIT/AOT/Generated/ASStaticJITAotFixture.as.jit.hpp
// 角色: cook 阶段产出的"AS 字节码 → C++ 等价"的真实样本
// ============================================================================
AS_FORCE_LINK FJitRef_Type TREF_UStaticJITAotFunctionCarrier(0x1f806ba3300);
AS_FORCE_LINK FJitRef_GlobalVar GREF___StaticType_UStaticJITAotFunctionCarrier(0x1f806c15060);

constexpr SIZE_T POFFSET_UStaticJITAotFunctionCarrier_StoredValue = Align(sizeof(UObject) + 0, 4);
AS_FORCE_LINK FJitVerifyPropertyOffset PVERIFY_UStaticJITAotFunctionCarrier_StoredValue(0x601000612b, POFFSET_...);

void AS_UStaticJITAotFunctionCarrier__StorePrimitiveArg(FScriptExecution& Execution, UObject* l_This, asDWORD p_Value)
{
    SCRIPT_DEBUG_CALLSTACK_FRAME_UOBJECT("void UStaticJITAotFunctionCarrier::StorePrimitiveArg(int)", 19);
    SCRIPT_ASSUME_NO_EXCEPTION()
    asQWORD l_valueRegister = 0; /* + 其它寄存器 */
    asDWORD v_TEMP_dword_1 = {};
    // SUSPEND
    // ADDIi v1, v-2, 3
    ((int32&)v_TEMP_dword_1) = ((int32&)p_Value) + value_as<int>((asDWORD)0x3u);   // ★ 字节码 → C++
    // LoadThisR +48
    l_valueRegister = ((asQWORD)l_This) + POFFSET_UStaticJITAotFunctionCarrier_StoredValue;
    // WRTV4 v1
    memcpy((void*)l_valueRegister, (void*)(&v_TEMP_dword_1), 4);
    return;
}
static void AS_..._VMEntry(FScriptExecution& Execution, asDWORD* l_fp, asQWORD* l_outValue) {
    AS_..._StorePrimitiveArg(Execution, *(UObject**)l_fp, *(asDWORD*)(l_fp + 2));
}
AS_FORCE_LINK static const FStaticJITFunction AS_..._Register(
    0x581ba130u, &AS_..._VMEntry, &AS_..._ParmsEntry, (asJITFunction_Raw)(void*)&AS_...StorePrimitiveArg);
```

可以看到几个关键模式：

- **以 BC 注释为分隔**：`// ADDIi v1, v-2, 3` 注释来自 `WriteDebugComment`，用于人类理解原字节码（参见 `FAngelscriptBytecodeImpl::WriteDebugComment`）。
- **本地变量映射成 `v_TEMP_dword_1` / `p_Value`**：`FStaticJITContext::AllocateLocalVariable` 与 `FVariableAsLocal` 体系负责把 AS 栈变量重写为 C++ 局部变量。
- **属性偏移**通过 `POFFSET_xxx = Align(sizeof(UObject) + 0, 4)` 在编译期推导 + `FJitVerifyPropertyOffset` 在运行期校验。
- **三种入口** `VMEntry`（解释器栈接入）、`ParmsEntry`（FFrame/Parms 接入）、`Raw`（C++ 直调）通过 `FStaticJITFunction` 构造函数同时注册。

### 2.4 `FStaticJITContext`：每函数一份的翻译"记账本"

`AngelscriptStaticJIT.h` 中的 `FStaticJITContext` 是字节码翻译的临时上下文，关键字段一览：

| 字段族 | 含义 |
|--------|------|
| `BC_FunctionStart / BC_End / BC` | 当前正在翻译的字节码游标 |
| `Instructions[] / CurrentInstructionIndex` | 跳转目标分析（Pre-pass 标记 label 与 conditional jump） |
| `LocalVariables / LocalNamesUsed` | AS 栈位 ↔ C++ 局部名映射 |
| `FloatingStackExpressions / LocalStackOffset / LocalStackSize` | 栈表达式延迟物化（避免每次都 store/load） |
| `StateVars` | 跨指令的 `static`/`thread_local` 持久量 |
| `ExceptionCleanupLabels` | 异常清理 goto label 池（参见 §九） |
| `ValueRegisterState` | AS `valueRegister` 是否已经物化到具体类型寄存器（`bAllowIndeterminate`） |

`PushVolatile` / `MaterializeStackVolatiles` / `MaterializeWholeStack` 这一组 API 实现的是"AS 栈惰性求值器"——只有当下一条指令真的需要"物化的栈"才回写 `l_stack[N]`，否则把表达式留在 C++ 局部里以便编译器做常量折叠。这是 StaticJIT 比解释器更快的关键来源之一。

### 2.5 跳转分析：Pre-pass 把 AS 跳转映射成 C++ `goto`

```cpp
// ============================================================================
// 文件: AngelscriptStaticJIT.h
// 角色: 跳转目标登记，决定哪些字节码偏移需要在 C++ 输出中放 label
// ============================================================================
struct FInstruction
{
    TArray<int32> JumpTargets;
    TArray<int32> ReceivedJumps;
    asDWORD* BC;
    struct FAngelscriptBytecode* Bytecode;
    FString Label;
    bool bMarked = false;
    int32 StackOffsetBeforeInstr = 0;
    bool bJumpPartOfSwitch = false;
    bool bIsConditionalJump = false;
    EValueRegisterState ValueRegisterStateFromJump = EValueRegisterState::Indeterminate;
    bool bHasMultipleValueRegisterStates = false;        // ★ 同一 label 多源 → 不能假设寄存器状态
};
```

如果某个目标 label 来自多个跳转源，且各源的 `valueRegister` 类型不一致，`bHasMultipleValueRegisterStates=true`，后续翻译会保守地强制物化值寄存器。这是为什么 cooked .jit.hpp 里偶尔能看到看似冗余的 memcpy ↔ register 来回——并非翻译质量差，而是必须保证语义正确。

---

## 三、预编译数据 schema：`FAngelscriptPrecompiledData`

JIT 翻译产物只是 StaticJIT 的"代码侧"。要让运行期把翻译好的入口正确地接到 `asCScriptFunction::jitFunction` 上，还需要"数据侧"——一份与 .jit.cpp 一一对应的字节码归档：`PrecompiledScript.Cache`。

### 3.1 顶层 schema

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/StaticJIT/PrecompiledData.h
// 节选自: FAngelscriptPrecompiledData (~550–650 行)
// ============================================================================
struct FAngelscriptPrecompiledData
{
    FMemMark AllocMark;                                    // memstack 顶端，析构次序保护

    FGuid DataGuid;                                        // ★ 与 .jit.cpp 一一对应
    TMap<FString, FAngelscriptPrecompiledModule> Modules;  // ★ 每个 .as module 一项
    TMapAsPtr<int64, FAngelscriptTypeReference> TypeReferences;
    TMap<int, int64> TypeIdReferenceToPointer;
    TMapAsPtr<int64, FAngelscriptFunctionReference> FunctionReferences;
    TMap<int, int64> FunctionIdReferenceToPointer;
    TMapAsPtr<int64, FAngelscriptGlobalReference> GlobalReferences;
    TMapAsPtr<int64, FAngelscriptPropertyReference> PropertyReferences;
    TArray<FStringInArchive> StaticNames;
    int32 BuildIdentifier = -1;                            // ★ cache schema + Debug/Dev/Test/Shipping 不互通

    TArray<uint8> LoadedData;                              // 原始字节，FStringInArchive 字符串借用其底
    bool bMinimizeMemoryUsage = false;
};
```

`FStringInArchive` 是个非常工业风的优化：所有 `FString` 字段都不持有自己的字符存储，而是指向 `LoadedData` 中的偏移；运行期只要 `LoadedData` 不释放，`FStringInArchive` 就有效。`bMinimizeMemoryUsage` 在 cooked build 启动后会被设置为 `true`，丢弃部分调试用元数据，但保留运行期必需的引用。

### 3.2 每个函数都序列化什么

```cpp
// ============================================================================
// 文件: PrecompiledData.h
// 节选自: FAngelscriptPrecompiledFunction (~80–180 行)
// ============================================================================
struct FAngelscriptPrecompiledFunction
{
    // ── Angelscript 数据 ──
    FStringInArchive FunctionName;
    FAngelscriptPrecompiledDataType ReturnType;
    TArray<FAngelscriptPrecompiledDataType, TPrecompiledAllocator<>> ParameterTypes;
    int32 FunctionTraits;
    TArray<int32, TPrecompiledAllocator<>> ByteCode;                  // ★ 字节码本体
    TArray<int32, TPrecompiledAllocator<>> ByteCodeReferences;        // ★ 字节码内的指针/类型 ID 位置
    int32 VariableSpace = -1;
    TArray<FAngelscriptPrecompiledReference, TPrecompiledAllocator<>> ObjVariableTypes;
    TArray<int32, TPrecompiledAllocator<>> ObjVariablePos;
    int32 ObjVariablesOnHeap = -1;
    int32 StackNeeded = -1;
    uint32 Id;                                                        // ★ 与 .jit.cpp 中 Register(0x..u, ...) 对应
    int32 DeclaredAt = 0;
    TArray<int32, TPrecompiledAllocator<>> LineNumbers;

    // ── 预处理器数据 ──
    bool bIsUFunction = false;
    bool bBlueprintCallable; bool bBlueprintOverride; bool bBlueprintEvent; bool bBlueprintPure;
    bool bNetMulticast; bool bNetClient; bool bNetServer; ...
};
```

关键点：

- **字节码不是按"原始 asDWORD" 直接 dump**：通过 `FAngelscriptBytecodeReferencer` 把字节码内出现的指针字段（global ptr / function id / type info / type id）替换为序列化时的"references"，加载时再反向解析回当前进程的真实指针。这是为什么 `PrecompiledScript.Cache` 在不同进程间 portable。
- **每个 `Id` 与 .jit.hpp 中 `FStaticJITFunction Register(0x..u, ...)` 是同一个值**：通过 `CreateFunctionId` 用模块名 + 类型声明 + 函数声明的 CRC 派生而来。
- **bBlueprint* 标志同时在 `FAngelscriptPrecompiledFunction` 和原始预处理器中存放**：cooked 构建跳过预处理器，直接从 cache 还原 UFunction 的修饰属性。

### 3.3 `Save / Load / IsValidForCurrentBuild` 三件套

```cpp
// ============================================================================
// 文件: PrecompiledData.cpp
// 函数: GetCurrentBuildIdentifier / IsValidForCurrentBuild / Save / Load
// ============================================================================
int32 FAngelscriptPrecompiledData::GetCurrentBuildIdentifier()
{
    constexpr int32 SchemaVersion = 10;

#if   UE_BUILD_DEBUG       return SchemaVersion * 10 + 1;
#elif UE_BUILD_DEVELOPMENT return SchemaVersion * 10 + 2;
#elif UE_BUILD_TEST        return SchemaVersion * 10 + 3;
#elif UE_BUILD_SHIPPING    return SchemaVersion * 10 + 4;
#else                      return -1;       // ★ 未知配置 → 永远视为无效
#endif
}

bool FAngelscriptPrecompiledData::IsValidForCurrentBuild()
{
    return BuildIdentifier == GetCurrentBuildIdentifier() && BuildIdentifier != -1;
}

void FAngelscriptPrecompiledData::Save(const FString& Filename)
{
    TArray<uint8> Data;
    FMemoryWriter Writer(Data, /*bIsPersistent*/ true);
    Writer.SetWantBinaryPropertySerialization(true);
    Writer << *this;
    FFileHelper::SaveArrayToFile(Data, *Filename);
}

void FAngelscriptPrecompiledData::Load(const FString& Filename)
{
    CachedPointerReferences.Reserve(32000);
    ProcessedFunctionToId.Reserve(16000);
    FFileHelper::LoadFileToArray(LoadedData, *Filename);
    FMemoryReaderWithPtr Reader(LoadedData);
    Reader.SetWantBinaryPropertySerialization(true);
    Reader << *this;
    ResetRuntimeState();   // ★ 旧的 transient 解析缓存清掉，避免上一次 Load 残留
}
```

注意 `Load` 末尾必须调用 `ResetRuntimeState`：fork 历史里曾出现"两次 `Load` 同一文件后 `CachedPointerReferences` 残留旧 engine 解析的指针，导致 use-after-free"的 bug；现在 `ExerciseRepeatedGlobalReferenceLoad` 测试专门覆盖这条路径（见 `StaticJITDiagnostics::ExerciseRepeatedGlobalReferenceLoad`）。

### 3.4 三阶段 `ApplyToModule_Stage1/2/3`

cooked build 启动期，每个 module 经过：

```text
Stage1 (CompileModule_PreClass_Stage1):
  ScriptModule->builder → 构造空 module 骨架，把类预声明
  Module->ScriptModule = ScriptModule; Module->bLoadedPrecompiledCode = true

Stage2 (CompileModule_Properties_Stage2):
  PrecompiledData->ApplyToModule_Stage2 → 创建 properties / class 内成员

Stage3 (CompileModule_Code_Stage3):
  PrecompiledData->ApplyToModule_Stage3 → 把 ByteCode 还原到 asCScriptFunction::scriptData
  ScriptModule->JITCompile()  ← 但此时 GetJITCompiler() == nullptr，所以是 no-op
```

cooked 路径下 `JITCompile()` 是空操作，因为 `bGeneratePrecompiledData==false` 时没 `SetJITCompiler`。`jitFunction` 字段是怎么填上的？由阶段二（link 期）的 `FStaticJITFunction(...)` 构造器代理写入 `FJITDatabase::Get().Functions[FuncId]`，但要把它"绑回" `asCScriptFunction::jitFunction` 还需要在 `ApplyToModule_Stage3` 末尾根据 `FuncId` 反查 `FJITDatabase` 完成最后一步赋值（参见 `FAngelscriptPrecompiledFunction::Process`，把 `Function->jitFunction = Funcs.VMEntry; Function->jitFunction_Raw = Funcs.RawFunction; ...` 写回）。

---

## 四、Engine.Initialize 中的启用 / 失败回退

`Core/AngelscriptEngine.cpp` ~1620–1830 行是 StaticJIT 与运行期联动的"全部交互面"：

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Core/AngelscriptEngine.cpp
// 节选自: Initialize（仅保留与 StaticJIT 相关的语句）
// ============================================================================
bGeneratePrecompiledData = RuntimeConfig.bGeneratePrecompiledData;
bScriptDevelopmentMode  = RuntimeConfig.bIsEditor || RuntimeConfig.bDevelopmentMode;
bUsePrecompiledData     = !bGeneratePrecompiledData && !RuntimeConfig.bIgnorePrecompiledData
                         && !RuntimeConfig.bRunningCommandlet && !WITH_EDITOR && !bScriptDevelopmentMode;

if (bGeneratePrecompiledData)                                  // ★ 分支 A: cook 期 transpile
{
    PrecompiledData = new FAngelscriptPrecompiledData(Engine);
    StaticJIT = new FAngelscriptStaticJIT();
    StaticJIT->PrecompiledData = PrecompiledData;
#if AS_CAN_GENERATE_JIT
    StaticJIT->bGenerateOutputCode = true;
#endif
    Engine->SetEngineProperty(asEP_BUILD_WITHOUT_LINE_CUES, 1); // ★ cook 期减少噪声
    Engine->SetJITCompiler(StaticJIT);
}
// ... InitialCompile() 期间 asCModule::JITCompile 会通过 StaticJIT 收集 FunctionsToGenerate

if (bUsePrecompiledData)                                       // ★ 分支 B: cooked 期 load
{
    FString Filename = ChooseFilenameByBuildConfig();          // PrecompiledScript_{Shipping/Test/Development}.Cache
    if (IFileManager::Get().FileExists(*Filename))
    {
        PrecompiledData = new FAngelscriptPrecompiledData(Engine);
        PrecompiledData->Load(Filename);
        if (!PrecompiledData->IsValidForCurrentBuild())        // ★ Build identifier 不匹配 → 整盘丢弃
        {
            delete PrecompiledData; PrecompiledData = nullptr;
            UE_LOG(Angelscript, Warning, TEXT("...Discarding all precompiled data."));
        }
        else
        {
            if (StaticJIT != nullptr) StaticJIT->PrecompiledData = PrecompiledData;
            if (!bScriptDevelopmentMode) PrecompiledData->bMinimizeMemoryUsage = true;
            const FStaticJITCompiledInfo* CompiledInfo = FStaticJITCompiledInfo::Get();
            if (CompiledInfo != nullptr && CompiledInfo->PrecompiledDataGuid != PrecompiledData->DataGuid)
            {
                UE_LOG(Angelscript, Warning, TEXT("...Transpiled code will not be used!"));
                FJITDatabase::Get().Clear();                   // ★ 双 GUID 不一致 → 单独丢 JIT，保留字节码
            }
        }
    }
}
// ...
InitialCompile();                                              // 阶段三：还原 modules
#if AS_CAN_GENERATE_JIT
if (StaticJIT != nullptr && StaticJIT->bGenerateOutputCode)
{
    StaticJIT->WriteOutputCode();                              // ★ 把 .jit.cpp/.hpp 写到 AS_JITTED_CODE/
    bForcedExit = true;
}
#endif
if (bGeneratePrecompiledData)
{
    PrecompiledData->InitFromActiveScript();
    PrecompiledData->Save(GetScriptRootDirectory() / TEXT("PrecompiledScript.Cache"));
    bForcedExit = true;                                        // ★ cook 完后立即退出进程
}

if (PrecompiledData != nullptr)
{
    bStaticJITTranspiledCodeLoaded = FJITDatabase::Get().Functions.Num() > 0;   // ★ 状态指示位
    if (!bScriptDevelopmentMode && !bGeneratePrecompiledData)
        PrecompiledData->ClearUnneededRuntimeData();
    delete PrecompiledData; PrecompiledData = nullptr;
    FJITDatabase::Clear();                                     // 已经把 jitFunction 写回 asCScriptFunction
}
```

四个核心分支：

| `bGenerateP` | `bUseP` | `WITH_EDITOR` | `bDevMode` | 行为 |
|--------------|---------|---------------|------------|------|
| true | false | 任意 | 任意 | **Cook 路径**：`SetJITCompiler` + `WriteOutputCode` + `Save` + 进程退出 |
| false | true | false | false | **Cooked 运行路径**：`Load` + 校验 GUID + `bMinimizeMemoryUsage` |
| false | false | true | 任意 | **编辑器路径**：完全不用 cache，全量解释器；`AS_SKIP_JITTED_CODE` 让 link 进来的 .jit.cpp 也变 inactive |
| false | false | false | true | **Standalone Dev 路径**：`bScriptDevelopmentMode=true`，热重载启用，cache 不用，jit 不用 |

`bStaticJITTranspiledCodeLoaded` 是个外部可观测的布尔位，可以通过 `as.DumpEngineState` 或 `as.StaticJIT.DumpDiagnostics` 查询，用来判断"我这次启动到底跑没跑 jit"。

---

## 五、与 CallFunctionCaller 的对接

StaticJIT 翻译某个调用 `Actor.GetActorLocation()` 时面临一个抉择：要不要把它内联展开成"直接 `((AActor*)l_This)->GetActorLocation()`"？答案取决于该 native 函数**是否注册了 `FScriptFunctionNativeForm`**。

### 5.1 `SCRIPT_NATIVE_*` 宏的 cook-only 注册

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/StaticJIT/StaticJITBinds.cpp
// 函数: FScriptFunctionNativeForm::BindNativeMethod
// ============================================================================
void FScriptFunctionNativeForm::BindNativeMethod(FAngelscriptBinds& Binds, const ANSICHAR* Name, bool bTrivial)
{
    if (!FAngelscriptEngine::IsGeneratingPrecompiledData())     // ★ 非 cook 期是 no-op
        return;
    GScriptNativeForms.Add(FAngelscriptBinds::GetPreviousBind(), new FScriptNativeMethod(Name, bTrivial));
}
```

`GScriptNativeForms` 是 `TMap<asIScriptFunction*, FScriptFunctionNativeForm*>`——只在 cook 进程中存在；一旦进入 `WriteOutputCode`，遍历每个调用点查 `GetNativeForm(CalledFunc)`，根据其类型选择不同的 C++ 翻译策略：

| 子类（部分） | 翻译策略 |
|--------------|---------|
| `FScriptNativeMethod` | `obj->Method(args...)` 直接调用 |
| `FScriptNativeFunction` | `Func(args...)` 全局函数直调 |
| `FScriptNativeConstructor` | `new (objAddr) Type(args...)` placement new |
| `FScriptNativeUObjectCast` | `Cast<TargetType>((UObject*)obj)`，guaranteed 时省去 IsA 检查 |
| `FScriptNativeUFunction` | 静态方法：`Class::Func(args...)`；非静态：`obj->Func(args...)` |
| `FScriptNativeTArrayIndex` / `*Iterator*` | 内联生成 `FArrayOperations::OpIndex_Template_Unchecked<T>` |
| `FScriptNativeTemplateInstantiation` | 模板特化，cook 期把 `_Template<T>` 实例化 |
| `FScriptNativePushArg` / `BindDelegateExecute` / 等 | 特殊 RPC / Delegate / 反射调用 |

### 5.2 `SCRIPT_CALL_NATIVE` 宏：jit 路径上的"通用 fallback"

如果 `GetNativeForm` 返回 `nullptr`（即调用点没注册 native form，也没明确 forbid），翻译器会退化为发出"通用 native 调用"宏：

```cpp
// ============================================================================
// 文件: StaticJIT/StaticJITHeader.h
// 角色: jit 代码内统一的 native 调用入口
// ============================================================================
#define SCRIPT_CALL_NATIVE(Function, StackPosition) \
    FStaticJITFunction::ScriptCallNative(Execution, Function, &l_stack[StackPosition], &l_valueRegister, &l_objectRegister);
```

`ScriptCallNative` 在 `StaticJITHeader.cpp` 里实现，对 `sysFunc->callConv` 做分类：

```cpp
// ============================================================================
// 文件: StaticJIT/StaticJITHeader.cpp
// 函数: FStaticJITFunction::ScriptCallNative（节选）
// ============================================================================
if (callConv == ICC_GENERIC_FUNC || callConv == ICC_GENERIC_METHOD)
{
    asCGeneric gen(SCRIPT_ENGINE, descr, currentObject, args);
    func(&gen);                                          // ★ Generic 形式，内核 fallback
    *valueRegister = gen.returnVal;
    *objectRegister = (void*)gen.objectRegister;
    return;
}

if (sysFunc->caller.IsBound())                          // ★ ★ ★ Type_FunctionCaller 路径
{
    // 拆 AS 栈、拼 void* FunctionArgs[32]
    if (sysFunc->caller.type == 1)
        sysFunc->caller.FunctionCaller(sysFunc->func,   &FunctionArgs[0], ReturnAddress);
    else
        sysFunc->caller.MethodCaller  (sysFunc->method, &FunctionArgs[0], ReturnAddress);
    return;
}
checkf(false, TEXT("Function %s had no way to call it."), ...);
```

也就是说：**StaticJIT 与 `Type_FunctionCaller` 是同一调用桥的两个调用方**。`asCContext::CallSystemFunction → CallFunctionCaller` 是**解释器**侧的入口；`FStaticJITFunction::ScriptCallNative` 是 **JIT** 侧的入口；两者在底层都最终汇合到 `sysFunc->caller.MethodCaller(...)` 这一行。这种"双入口、单实现"的设计让 StaticJIT 可以一劳永逸地承接已有的 ABI 桥而不需要重复实现 16 种 calling convention。

### 5.3 翻译策略的层级

对一次 `obj.Func(args)` 调用，StaticJIT 按下列优先级选择：

```text
1) FScriptFunctionNativeForm 注册 + CanCallCustom?
     YES → GenerateCustomCall（最优，可消除 informSystemFunction、跳过查表）
2) FScriptFunctionNativeForm 注册 + CanCallNative?
     YES → 直接 obj->Func(args) C++ 表达式（跨模块需 IS_MONOLITHIC 或 whitelist）
3) 否则
     → 发出 SCRIPT_CALL_NATIVE 宏，运行期通过 sysFunc->caller 调用
```

这是 StaticJIT 性能收益的核心：**热路径（容器、UObject Cast、Delegate Execute、TArray 索引）走层级 1，普通绑定函数走层级 2，未知函数走层级 3**。

---

## 六、性能模型：哪些 hot path 受益最大

### 6.1 解释器 vs StaticJIT 的开销分布

```text
解释器 ExecuteNext 单步开销:
  fetch:  asEBCInstr instr = *(asBYTE*)bc;
  decode: const asSBCInfo& info = asBCInfo[instr];
  switch: switch(instr) { case asBC_PSF: ...; case asBC_CALLSYS: ... }
  pcadv:  bc += asBCTypeSize[info.type];
  典型 ~10-30 cycles per instruction，分支预测 miss 占主导。

StaticJIT 翻译后:
  fetch / decode / switch / pcadv 全部消失（编译期已展开）
  CALLSYS 通过 SCRIPT_CALL_NATIVE 仍要走 caller 桥（~30-50 cycles）
  纯算术 / 局部变量 ~ 1-3 cycles per AS 指令
  典型加速 5-10x 对密集循环 / 数学运算，1.5-3x 对 UFUNCTION 调用密集的脚本
```

### 6.2 受益最大的代码模式

| 代码模式 | StaticJIT 翻译产物 | 收益 |
|---------|---------------------|------|
| 密集算术循环 `for (i; i<N; ++i) Sum += a[i]*b[i];` | 内联 `OpIndex_Template_Unchecked<float>` + 编译器 SIMD vectorize | 极高（~10x） |
| `TArray<int>` 遍历 | `FArrayIterator` 直接增量；`OpIndex_Stride_Unchecked` | 高（5-8x） |
| `Cast<AMyActor>(obj)` | `bGuaranteed` 时纯指针赋值；否则 `IsA(DestClass)` | 中（2-3x） |
| `DelegateName.Execute(args)` | 直接 invoke 委托链表 | 中（2x） |
| `BlueprintCallable` 调用 | 反射 fallback 时收益小；绑定到原生 UFunction 时收益大 | 视绑定形态而定 |
| 字符串拼接 / `TMap` 操作 | StaticJIT 不内联（容器复杂） | 低（~1.2x） |

### 6.3 不受益的场景

- **编辑器内热重载循环**：`AS_SKIP_JITTED_CODE` 强制走解释器。
- **首次加载冷启动**：JIT 入口靠 `static const FStaticJITFunction Register(...)` 在程序启动期注册，对运行期热路径无开销，但有少量初始化开销（~ms 级）。
- **GUID 不匹配的 cooked build**：`FJITDatabase::Clear()` 后等同没 JIT。
- **未在 .as 模块里的"动态构造的 asCScriptFunction"**（如 lambda fallback）——它们 cook 期不存在，运行期没有对应入口。

---

## 七、Fork 中的演化：2.33 起步、2.38 的 JIT v2 暂未吸收

### 7.1 当前 fork 的 StaticJIT 在演化层级中的位置

按 `Documents/Guides/AngelscriptForkStrategy.md` 的分类：

- **AS 2.33** 没有 StaticJIT 概念（连 asmjit-AS 也是社区贡献，主线没正式集成）。UE Fork 的 StaticJIT **是 UE 工程师独立设计的**，不是从上游 cherry-pick 来的。
- **AS 2.38** 引入了官方的 **JIT v2 接口**（`asEP_INIT_GLOBAL_VARS_AFTER_BUILD` / `asJITFunction_Raw` 风格，与 fork 这里的 `asJITFunction_Raw` 形似但语义不同）。
- 待办项 `Plan_AS238JITv2Port.md` **未开始**。

### 7.2 为什么不直接升级到 2.38 的 JIT v2

| 阻塞点 | 描述 |
|--------|------|
| **`asJITFunction` 签名分叉** | UE Fork 的 `asJITFunction` 第一个参数是 `FScriptExecution&`（其中 `tld` / `bExceptionThrown` / `debugCallStack` 都是 `[UE++]` 字段）；上游 2.38 是 `asIScriptContext*`。两套 ABI 在 cooked .jit.cpp 中已固化为常量字符串，整盘替换将让所有已 cook 的 cache 失效。 |
| **`PrecompiledData` 与 JIT 解耦** | 上游 JIT v2 没有"字节码归档 + 代码生成"分层；fork 的 `PrecompiledScript.Cache` 是预处理 / cook / hot-reload 三个子系统的**共同**前向 cache，不能为单纯升级 JIT 而拆分。 |
| **`FScriptFunctionNativeForm` 体系是 fork 原生** | 上游没有"native form 注册表"概念；它是 fork 的 cook-only 优化层。upgrade JIT v2 不会带来这部分能力。 |
| **`as_callfunc.cpp` 已被 `caller.IsBound` 接管** | 上游 2.38 的 ABI 桥仍依赖平台汇编；fork 已用 `Type_FunctionCaller` 把它绕过，JIT 也跟着绕。 |

结论按 ForkStrategy：**保留当前 StaticJIT，把 2.38 视为"改进来源"而非"升级目标"**——重点选取性能改进点（如 computed goto / 更细粒度类型 trait），而不是整体替换。

### 7.3 已落地的 2.38 吸收里与 StaticJIT 相关的项

| 能力 | 与 StaticJIT 的交集 |
|------|--------------------|
| 模块函数 / 声明查找 API | `FStaticJITDiagnostics::FindFunctionInModule` 利用 `GetFunctionByDecl` 解析参数 |
| 对象类型 / 类型信息宽标志位 | `IsTypePotentiallyDifferent` 依赖 fork 高位标志，决定 cook 期能否硬编码尺寸 |
| 恢复器表面 | 与 `PrecompiledData` 共用底层 `FStringInArchive` 序列化 + `[UE++]` 容器 |

---

## 八、限制矩阵：哪些"不会"被 StaticJIT 翻译

| 场景 | 是否 jit | 原因 |
|------|---------|------|
| 编辑器 PIE / 热重载 | ❌ | `AS_SKIP_JITTED_CODE` 强制路由解释器 |
| 任何 `asFUNC_DELEGATE` / `asFUNC_INTERFACE` | ❌ | `JITCompile` 中 `if (funcType != asFUNC_SCRIPT) return;` |
| 含 `asBC_REFCPY` 等少数 opcode 的特殊路径 | ❌（部分） | `FAngelscriptBytecode::Implement` 返回 `false` → 翻译器自动 fall through 到解释器 |
| `bScriptDevelopmentMode` 路径 | ❌ | bUsePrecompiledData 直接为 false，无 cache 也无 jit |
| GUID 不匹配的 cooked build | ❌ | `FJITDatabase::Clear()` 后 `jitFunction` 全部为 nullptr |
| Build identifier 不匹配 | ❌ | 整盘 PrecompiledData 丢弃，连字节码都重建 |
| Lambda / 匿名函数 | ❌ | 当前 fork 不支持 lambda（未吸收 2.38），自然没有 jit |
| 含 `asBC_LoadThisR` 跨模块的指针访问 | ⚠️ | 翻译时通过 `FJitVerifyPropertyOffset` 保护：cook 期假设的偏移在 link 后被 `FJitDatabase` 填实际值；不一致即触发 verify 异常 |
| 调用 `FScriptFunctionNativeForm::CanCallNative=false` 的函数 | ⚠️ | 仅退到 `SCRIPT_CALL_NATIVE` 走 caller 桥，仍 jit |

`AS_JIT_VERIFY_PROPERTY_OFFSETS` 默认在 Debug/Development 开启，Test/Shipping 关闭：cook 期的属性偏移与 link 期实际偏移不一致会 `check`-fail，提示 ABI 漂移。

---

## 九、与 BlueprintImpact / HotReload 的协作边界

### 9.1 StaticJIT 不参与热重载

```text
                ┌──── 编辑器（WITH_EDITOR=1）─────┐
                │   AS_SKIP_JITTED_CODE 开启      │
RT_HotReload ──►│   bScriptDevelopmentMode=true    │
                │   bUsePrecompiledData=false      │
                │   jitFunction == nullptr 全程     │
                │   解释器单线运行                  │
                └─────────────────────────────────┘

                ┌──── Cooked Shipping/Test/Dev ────┐
                │   bUsePrecompiledData=true       │
                │   AS_SKIP_JITTED_CODE 关闭        │
                │   jitFunction != nullptr 即走 jit │
                │   不存在热重载                    │
                └─────────────────────────────────┘
```

热重载 / 文件变更链路（参见 `RT_HotReload.md`）只在编辑器 + standalone dev 模式下激活——这两个模式 jit 都被禁。**因此 StaticJIT 与 ClassReloadHelper / DirectoryWatcher 没有直接交互**。

### 9.2 BlueprintImpact 与 StaticJIT 的关系

`BlueprintImpact` 的 Commandlet（编辑器扩展）做的是"BP 改动后，哪些 .as 受影响"的扫描。它的输出影响**下次 cook 时哪些模块需要重 transpile**：

```text
BP 改动 → BlueprintImpact 标记 affected modules
          ↓
重新 cook（RunUAT BuildCookRun -as-generate-precompiled-data）
          ↓
StaticJIT 重新生成 .jit.cpp / PrecompiledScript.Cache
DataGuid 重新分配（FGuid::NewGuid()）
          ↓
re-link 进 .exe → 新一份 cooked build 携带新的 FStaticJITCompiledInfo
```

也就是说，**StaticJIT 不需要"运行期感知 BP 变化"**——它已经把 cook 时的 BP 类型 layout 通过 `POFFSET_xxx = Align(...)` 静态嵌入翻译产物中。BP 在 PIE 期改了 layout，由 `AS_JIT_VERIFY_PROPERTY_OFFSETS` 兜底（Debug/Development 中报错），但生产环境不会修 BP layout，所以没问题。

---

## 十、调试与诊断

### 10.1 控制台命令 `as.StaticJIT.DumpDiagnostics`

```cpp
// ============================================================================
// 文件: StaticJIT/StaticJITDiagnostics.cpp
// 角色: 运行期把 JIT 状态打印到 LogStaticJITDiagnostics
// ============================================================================
FAutoConsoleCommand GStaticJITDumpDiagnosticsCommand(
    TEXT("as.StaticJIT.DumpDiagnostics"),
    TEXT("Dump StaticJIT process and optional function diagnostics. "
         "Optional: as.StaticJIT.DumpDiagnostics [FunctionNameOrDeclaration]"),
    FConsoleCommandWithArgsDelegate::CreateStatic(&FStaticJITDiagnostics::DumpDiagnostics));
```

输出示例：

```text
StaticJIT diagnostics: RegisteredFunctions=842 EntryCounters=1573 CompiledInfo=true
                       CurrentEngine=true ScriptEngine=true PrecompiledData=true
                       CompiledInfoMatchesPrecompiledData=true
StaticJIT diagnostics: PrecompiledDataGuid=A1B2C3D4-...
StaticJIT diagnostics: CompiledInfoGuid=A1B2C3D4-...
```

带函数参数时还会输出该函数的 FunctionId / 是否注册 / EntryCount：

```text
StaticJIT diagnostics function: Argument='void AMyActor::Tick(float)'
                                Declaration='void AMyActor::Tick(float DeltaTime)'
                                FunctionId=0xa1b2c3d4 Registered=true HasJitFunction=true
                                HasRawJitFunction=true HasParmsJitFunction=true EntryCount=42
```

`EntryCount` 来自 `FStaticJITDiagnosticEntryMarkers::MarkEntry`，在 `bEmitDiagnosticEntryMarkersInOutput=true` 的 cook 中每个 jit 函数入口都会 ++ 一次计数。

### 10.2 如何关闭 StaticJIT 走解释器对比性能

在 cooked build 启动命令行加：

```bat
GameBin.exe -as-ignore-precompiled-data
```

会让 `bUsePrecompiledData=false`，进入"无 cache 重新编译 .as"路径——同时也跳过 `FStaticJITCompiledInfo::Get` 校验。配合 `as.DumpEngineState` 或 `STAT Angelscript` 观察解释器单步耗时。

### 10.3 验证翻译产物：`GenerateStaticJITSourceTextForDiagnostics`

诊断 API 允许在编辑器中临时跑一遍 transpile 流程产出某个模块的 .jit.hpp 文本（无需真的 cook 整个项目），用于"我修改了 opcode `Implement` 之后，输出对吗？"这种局部验证：

```cpp
// ============================================================================
// 文件: StaticJIT/AngelscriptStaticJIT.h
// 角色: 仅 AS_WITH_STATIC_JIT_DIAGNOSTICS 暴露的诊断入口
// ============================================================================
ANGELSCRIPTRUNTIME_API bool GenerateStaticJITSourceTextForDiagnostics(
    asIScriptModule* Module,
    FString& OutSourceText,
    bool bEmitDebugMetadata,
    FString* OutError = nullptr);
```

测试集 `AngelscriptStaticJITGeneratedOutputTests.cpp` 用它把 fixture 模块的产物对比 golden 文件，确保 opcode 翻译没退化。

### 10.4 callstack 与异常调试

`AS_JIT_DEBUG_CALLSTACKS` 默认 `!UE_BUILD_SHIPPING`，开启时每个 jit 函数体首部插入：

```cpp
SCRIPT_DEBUG_CALLSTACK_FRAME_UOBJECT("void AMyActor::Tick(float)", 19);
// ... 每条 BC 翻译之间穿插
SCRIPT_DEBUG_CALLSTACK_LINE(LineNumber);
```

`FScopeJITDebugCallstack` RAII 把当前函数 + 行号挂到 `Execution.debugCallStack` 链表，异常发生时 `HandleExceptionFromJIT` 通过它生成可读 callstack。这弥补了"jit 后字节码 PC 不再可用"的可观测性缺口。

---

## 附录 A：StaticJIT 入口速查

| 符号 / 入口 | 文件 | 何时被调用 / 何时存在 |
|-------------|------|----------------------|
| `FAngelscriptStaticJIT::CompileFunction` | `AngelscriptStaticJIT.cpp` | cook 期 `asCModule::JITCompile` 内 |
| `FAngelscriptStaticJIT::WriteOutputCode` | `AngelscriptStaticJIT.cpp` | cook 期 `Initialize` 末尾、`InitialCompile` 之后 |
| `FAngelscriptPrecompiledData::Save` | `PrecompiledData.cpp` | cook 期同上，紧跟 `WriteOutputCode` |
| `FAngelscriptPrecompiledData::Load` | `PrecompiledData.cpp` | cooked 启动期，`bUsePrecompiledData==true` 分支 |
| `FAngelscriptPrecompiledData::IsValidForCurrentBuild` | `PrecompiledData.cpp` | `Load` 之后立即调用 |
| `FStaticJITCompiledInfo::FStaticJITCompiledInfo` | `StaticJITHeader.cpp` | link 期通过 `AngelscriptJitInfo.jit.cpp` 中的 static const 触发 |
| `FStaticJITFunction::FStaticJITFunction` | `StaticJITHeader.cpp` | link 期通过每函数 `Register` 触发，写入 `FJITDatabase::Get().Functions` |
| `FJitRef_Function/Type/GlobalVar/SystemFunctionPointer` 构造器 | `StaticJITHeader.cpp` | link 期，把 references 加到对应 `Lookups` 数组 |
| `FJITDatabase::Clear` | `AngelscriptStaticJIT.cpp` | GUID 不匹配 / `Initialize` 末尾 / 进程退出时 |
| `FStaticJITDiagnostics::DumpDiagnostics` | `StaticJITDiagnostics.cpp` | 控制台命令 `as.StaticJIT.DumpDiagnostics` |
| `FStaticJITFunction::ScriptCallNative` | `StaticJITHeader.cpp` | jit 代码内通过 `SCRIPT_CALL_NATIVE` 宏 |

---

## 附录 B：性能调优建议

适用于"我有一段 .as 性能不达标，想看是不是 StaticJIT 没接住"的场景。

1. **先确认 cook 用了 `-as-generate-precompiled-data` 标志**——少这个 flag，cooked build 启动期会发现 `PrecompiledScript.Cache` 不存在，走"重新解释" fallback；性能远不如预期。
2. **确认 `bStaticJITTranspiledCodeLoaded==true`**：在程序启动后用 `as.StaticJIT.DumpDiagnostics` 查 RegisteredFunctions 数量是否符合预期。如果是 0，意味着 `FJITDatabase::Get().Functions.Num()==0`，所有调用都走解释器。
3. **GUID 不匹配是常见的"灰色失败"**：交付链路里 .jit.cpp 是 cook 后产生的，必须随同 `PrecompiledScript.Cache` 一起被打包；漏掉任意一份都会让 `CompiledInfo->PrecompiledDataGuid != PrecompiledData->DataGuid`，触发 `FJITDatabase::Get().Clear()`。日志里关键字 `Transpiled code will not be used!`。
4. **热点函数没绑定 `SCRIPT_NATIVE_*`**：jit 翻译会保守走 `SCRIPT_CALL_NATIVE`，比内联 native 调用慢 5-10x。如果你写的 C++ 函数频繁被脚本调用，考虑在对应 `Bind_*.cpp` 加 `SCRIPT_NATIVE_METHOD(Binds, "Foo", true)`（`bTrivial=true` 表示无 throw）。
5. **`CanCallNative` 在非 monolithic 构建中需要 whitelist**：`/Script/<ProjectName>` 和 `/Script/Engine` 两个 package 自动允许；其他 package 的函数走 fallback。
6. **Build identifier 不要混用**：同一 cache 不能跨 Debug/Dev/Test/Shipping 复用——这是设计上的隔离，不是 bug。
7. **跨平台 cook**：Linux cook 出的 `.jit.cpp` 在 Windows link 时可能因 `alignof` 差异导致 `FJitVerifyPropertyOffset` 失败；以**目标平台**做 cook 是当前推荐做法。
8. **属性偏移漂移**：如果运行时崩在 `FJitVerifyPropertyOffset`，绝大多数情况是某个绑定 C++ 类的成员排列在 cook 与 link 之间变了——通常因 cook 用旧分支、link 用新分支。重新 cook 即可。
9. **不要试图在编辑器中验证 StaticJIT**：`AS_SKIP_JITTED_CODE` 让 jit 永远 inactive；性能验证必须用 cooked Development/Test build。
10. **诊断 marker 在 ship 中不会编译**：`AS_WITH_STATIC_JIT_DIAGNOSTICS=(!UE_BUILD_SHIPPING)`——shipping build 想看 entry count 需自行重建为 Test。

---

## 小结

- **StaticJIT 是 AOT，不是 JIT**：cook 期 `WriteOutputCode` 把字节码翻译成 C++ 文件，跟随 .exe 一起编译；运行期不存在代码生成，因此与 ASLR / Code Sign / 各平台沙箱完全兼容。
- **两份产物，一份签名**：`PrecompiledScript.Cache`（字节码归档 + symbol references）与 `AS_JITTED_CODE/*.jit.cpp/.hpp`（C++ 源码）共享 `FGuid DataGuid`，运行期由 `FStaticJITCompiledInfo::Get()->PrecompiledDataGuid` 校验；任一不一致即整盘抛弃 jit 入口表（保留字节码继续解释执行）。
- **解释器与 jit 是"双入口、单语义"**：`asCContext::ExecuteNext` / `CallScriptFunction` 仅在最外层做 `if (jitFunction != nullptr)` 检测，jit 与解释器共享异常模型 / 寄存器布局 / 栈布局；fallback 顺滑无副作用。
- **Native 调用桥共享**：`Type_FunctionCaller` 的 `sysFunc->caller.MethodCaller(...)` 同时被解释器和 StaticJIT 复用（前者经 `CallSystemFunction`，后者经 `FStaticJITFunction::ScriptCallNative`）；`SCRIPT_NATIVE_*` 宏体系是 cook-only 的额外 inline 优化层。
- **fork 中的位置**：StaticJIT 是 UE Fork 自家创新（不来自上游），与 2.38 的 JIT v2 ABI 不兼容；`Plan_AS238JITv2Port` 标 "未开始"，按 ForkStrategy 当前优先选择性吸收性能改进、不整盘升级。
- **观测面**：`as.StaticJIT.DumpDiagnostics` + `bStaticJITTranspiledCodeLoaded` + `LogStaticJITDiagnostics` + `AS_JIT_VERIFY_PROPERTY_OFFSETS` 一起构成线上故障的可定位三件套；编辑器 / standalone dev 路径下 jit 永不激活，与 `RT_HotReload` 没有直接交互。
