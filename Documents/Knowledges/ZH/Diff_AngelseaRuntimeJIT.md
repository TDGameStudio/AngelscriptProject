# Angelsea Runtime JIT 可接入性与 AngelscriptProject 分层方案

> **记录类型**：外部实现研究 / 可行性分析 / 架构讨论记录
>
> **文档属性**：独立研究记录，不属于任何 OpenSpec change
>
> **分析日期**：2026-08-12
>
> **Angelsea 参考版本**：`Reference/angelsea` @ `1d367d431cdfd7e5e51b2341312078fd40cc10a4`
>
> **当前结论状态**：接入方向和三份 OpenSpec 已于 2026-08-12 确认；本文仍是独立研究记录，不表示 Runtime JIT 已实现或插件依赖已经引入
>
> **StaticJIT 现状补记（2026-08-13）**：本文对项目 StaticJIT 的“当前实现”判断冻结在研究当日早期。其后 `refactor-as-static-jit-multi-provider` 已完成 ABI Revision 2 Registry/Matcher/Router、Engine/Cache/Editor 接入、严格 per-AS-module `.jit.cpp`、多 Provider 和旧 `FJITDatabase`/FunctionId/DataGuid 删除。文中仍称这些能力只在测试或尚未接入的段落属于历史调查快照；当前事实以 `RT_StaticJIT.md` 与该 OpenSpec 为准。Angelsea Runtime JIT 本身仍未作为依赖引入。
>
> **本文范围**：记录 Angelsea 的 JIT 原理、与当前 StaticJIT 的差异、接入可行性、不可直接复用的边界、可选方案、推荐分层架构和最小 PoC 验收条件

---

## 一、结论摘要

### 1.1 可以接入，但不能把 Angelsea 原样安装进来

AngelscriptProject **可以拥有真正的运行期 JIT**。当前维护分支已经具备几个关键基础：

- 一个非版本化的 `asIJITCompiler` 生命周期；
- `OnFunctionReady()` 后延迟发布 Binding 的能力；
- VM / Raw / Parms / UserData 组成的完整 `asSJITFunctionBinding`；
- Binding 替换、清空、函数销毁和 compiler 替换时的 exactly-once retirement；
- engine-local execution context、稳定函数身份、provider generation 和 reference slot 基础；
- Native miss 时继续使用 VM 的正确性基线。

因此，阻塞点不是“AngelScript 没有安装运行期机器码的接口”，而是：

1. Angelsea 面向 upstream `asIJITCompilerV2`，本 fork 已经删除该接口；
2. Angelsea 的入口 ABI 是 `(asSVMRegisters*, entryLabel)`，本 fork 的 VM 入口 ABI 是 `FScriptExecution& + frame + outValue`；
3. 当前本 fork 把一次非异常 `VMEntry` 返回解释为“整个函数已经执行完成”，尚不支持 Angelsea 的“保存 PC/SP 后回到解释器继续执行”；
4. Angelsea 的 direct native/generic call 依赖 AngelScript 内部布局和手工 C++ ABI 模拟，不能绕过本项目已有的 UE binding、RPC、反射和 GC 语义；
5. MIR module 当前不能按函数卸载，Editor 热重载会产生本机代码生命周期和内存累积问题；
6. 运行期机器码生成需要平台允许可写后可执行内存，不适合作为默认 Shipping 路径。

准确的接入方式应当是：

> 把 Angelsea 的 `BytecodeToC + c2mir + MIR` 当作参考后端，移植成维护分支自己的、engine-local 的可选 Runtime JIT backend；由 Runtime 中唯一的 JIT coordinator 负责 Static AOT provider、Runtime JIT 和 VM 三者的选择、发布与退休。

### 1.2 推荐的产品分层

```text
                         当前脚本函数
                              │
                              ▼
                   Engine-local JIT Coordinator
                              │
             ┌────────────────┼────────────────┐
             │                │                │
             ▼                ▼                ▼
       AngelScript VM     Runtime JIT      StaticJIT AOT
       永远可用基线       Editor/Dev 可选   Cook/Shipping
       正确性兜底         热点或显式触发     C++/UBT 编译
                          MIR 机器码         VM/Raw/Parms
                          首期 VMEntry       完整 UE ABI
```

推荐优先级为：

```text
完全匹配的 StaticJIT AOT Provider
    > 已完成且仍匹配当前函数的 Runtime JIT Binding
    > 当前 AngelScript VM
```

StaticJIT AOT 继续承担稳定、可重现、适合 Shipping 的最终产物；Runtime JIT 主要解决 Editor/Development 中“修改脚本后不重新构建 C++ 也能获得 Native 性能”的问题。

当前已经确认的完整性能路径不是简单的“VM / JIT”二分，而是五条可独立选择和比较的路径：

| 路径 | 输入 | 机器码生成时机 | 第一职责 | 对应记录 |
|---|---|---|---|---|
| AngelScript VM | Bytecode | 不生成 | 永远可用的正确性基线 | 现有 Runtime |
| Legacy Static AOT | Bytecode | 离线 | Bytecode → C++，可重现交付 | 现有 StaticJIT |
| Semantic Static AOT | compiler-owned typed semantic HIR | 离线 | 直接保留类型/语义后生成 C++ | `feature-as-typed-semantic-aot` |
| Angelsea MIR Runtime JIT | Bytecode | 运行期 | Bytecode → C → c2mir/MIR → Native | `feature-as-angelsea-runtime-jit-plugin` |
| Angelsea LLVM Runtime JIT | Bytecode | 运行期 | Bytecode → LLVM IR → ORC → Native | `feature-as-angelsea-llvm-jit-plugin` |

这里的 Semantic Static AOT 准确输入是编译器拥有的 typed semantic HIR sidecar，不是让后端重新解释一棵未经语义解析的 parser AST。两个 Runtime JIT 则都必须能只面对已经加载的 bytecode；它们不依赖 source-only HIR。

五条路径的变更依赖关系已经固定为：

```text
refactor-as-static-jit-multi-provider                [已有]
├── feature-as-typed-semantic-aot                   [已有]
│   └── Typed Semantic HIR → C++ Static AOT
│
└── refactor-as-unified-jit-coordinator             [新建前置]
    ├── feature-as-angelsea-runtime-jit-plugin      [MIR Runtime JIT]
    └── feature-as-angelsea-llvm-jit-plugin         [LLVM Runtime JIT]
```

### 1.3 推荐从“整函数 Runtime JIT”PoC 开始

第一版不应同时挑战所有问题。推荐的最小 PoC 是：

- Windows x64 Editor/Development only；
- 配置 `EagerSync`、`EagerBackground` 或 `LazyFirstCall`；默认以 `EagerSync` 建立确定性 PoC，同时把另外两种策略纳入同一 coordinator 状态机；
- 只接受 bytecode 全覆盖的函数；
- 任一不支持指令导致该函数保持 VM，不做函数内分段 fallback；
- 只发布 `VMEntry`；
- Raw/Parms 缺失时继续走当前 generic/VM/UASFunction route；
- Native/system call 只通过本项目现有 caller/binding bridge，不启用 Angelsea 的 ABI hack；
- 一 engine 一 backend session 和串行编译队列；首版每个成功函数 revision 使用由 code lease 独占的 disposable MIR context/code arena，旧 Binding 的最后 reader 退出后整体销毁；
- 用执行结果一致性、脚本重载、两 engine 隔离、Binding retirement、编译时延、运行性能和内存增长验证价值。

只有 PoC 证明有足够收益后，才考虑扩展 JIT ABI，恢复 Angelsea 最有价值的“函数内 Native ↔ VM 分段执行”。

### 1.4 难度判断：验证版不难，产品版不是只改接口

Angelsea 的核心实现规模并不夸张：当前参考提交中的 `bytecode2c.cpp` 约 2484 行、`mirjit.cpp` 约 498 行、`runtime.cpp` 约 192 行、`config.hpp` 约 226 行。若目标只是证明“维护分支的纯计算 bytecode 可以在 Windows Editor 中经 MIR 运行”，工作量是可控的。

建议把难度分成三档：

| 目标 | 难度判断 | 主要工作 |
|---|---|---|
| Smoke PoC | 低到中 | 编译 MIR/c2mir、支持少量纯计算 bytecode、三种策略可配置、发布整函数 VMEntry |
| 可日常使用的 Editor Runtime JIT | 中到高 | 异步编译、stale result、HotReload、调用桥、调试/coverage 排除、内存预算、两 engine 隔离 |
| 完整 Angelsea 式分段 JIT 或 Shipping | 高 | 扩展 Context continuation ABI、PC/SP/FP 恢复、多 entry、suspend/exception、平台安全和 code-signing |

Smoke PoC 可以把范围严格限制为：

```text
测试 engine
    + Windows x64 Editor
    + pure int/float/branch/local/return
    + whole-function support scan
    + unsupported => 整函数 VM
    + VMEntry only
    + configurable eager-sync/eager-background/lazy-first-call
```

这个范围不需要修改当前 `asCContext` 的“VMEntry 返回即完成”语义，也不需要先支持 UObject、Raw/Parms、脚本调用、native call、热点计数或函数内 fallback。

产品版之所以不能概括为“改几个接口”主要有两个直接证据：

1. 当前 `as_context.cpp` 在 VMEntry 非异常返回后会设置 `asEXECUTION_FINISHED` 或直接完成 `CallScriptFunction()`；Angelsea 却依赖 JIT 函数返回后由 VM 从保存的 PC/SP 继续，所以完整 fallback 必须增加明确的 `ResumeVM` 协议。
2. 当前 `asBC_JitEntry` interpreter handler 只是把它当作 NOP 跳过；Angelsea 的 dummy JIT counter 在本 fork 中返回后会被误认为函数执行完毕，所以热点触发也需要新 hook、调用计数或可恢复返回状态。

因此更准确的结论是：

> 接入一个有价值的 Runtime JIT PoC 不难；把 Angelsea 的全部运行模型正确接入 UE fork，则是中等以上的架构工作，难点在语义和生命周期验证，不在 MIR API 本身。

### 1.5 为什么 bytecode backend 相对容易接入

“Angelsea 只是做 bytecode 转换”是一个重要且基本正确的判断。它接收的不是 AngelScript 源码或 AST，而是已经通过前端的可执行 bytecode 和函数元数据。因此下列编译前端工作都不在 Runtime JIT 范围内：

- 词法和语法分析；
- include/preprocessor；
- 名字查找和 namespace；
- overload resolution；
- 模板/泛型实例化选择；
- 类型推导与隐式转换选择；
- operator/constructor/destructor 解析；
- 控制流合法性检查；
- UFUNCTION/脚本声明语义构建。

Runtime backend 取得的函数已经包含：

- `asBC_*` 指令序列；
- 参数、local 和返回值的已确定类型；
- local stack slot 和 frame size；
- branch target；
- 被调 script/system function identity；
- object/reference 操作指令；
- 已完成的 virtual/interface/import lowering 信息；
- JIT entry 和 VM 恢复候选位置。

所以它更像一个后端：

```text
已解析、已类型化、已降低的 AS bytecode
    → C 表达式、local、label 和 runtime helper
    → c2mir/MIR
    → 当前平台机器码
```

而不是重新实现 AngelScript 编译器。

### 1.6 bytecode 指令的难度分层

很多 bytecode 可以机械转换：

| 指令类别 | 典型内容 | Runtime lowering |
|---|---|---|
| Primitive constants | int/float/double 常量 | C 常量或 local |
| Arithmetic | add/sub/mul/div/mod | C primitive expression + AS 异常检查 |
| Comparison | equal/less/greater | C comparison |
| Local load/store | frame slot 读写 | C local 或 frame access |
| Cast | primitive numeric cast | C cast/bit conversion |
| Branch | jump/conditional jump | label + `goto`/`if` |
| Return | primitive return | 写 `OutValue` 后完成 |

这些足以覆盖有代表性的热循环和纯计算函数，例如：

```angelscript
int Sum(int Count)
{
    int Result = 0;
    for (int i = 0; i < Count; ++i)
        Result += i;
    return Result;
}
```

中等复杂度指令主要要求正确复现 AS frame/stack 和对象 helper：

- stack push/pop/materialization；
- reference copy；
- handle retain/release；
- object construction/destruction；
- script call frame；
- recursion；
- imported/current function resolution。

高复杂度指令或路径通常不是“某条机器指令不会生成”，而是涉及外部语义：

- `CALLSYS` 和平台/UE calling convention；
- virtual/interface/current override；
- indirect function pointer；
- UObject/GC/reference lifetime；
- object/value 按值返回；
- exception 和 cleanup；
- suspend/latent；
- Debugger、CodeCoverage 和 Context inspection；
- 函数内退出 Native 后从 PC/SP/FP 恢复 VM。

因此 bytecode backend 的实现策略可以渐进：先覆盖机械指令，让不支持的整个函数继续 VM，再按测试逐类增加 helper 和语义覆盖。

### 1.7 与现有 StaticJIT bytecode lowering 的关系

本项目已有 StaticJIT，同样从 `asBC_*` bytecode 出发，因此不需要重新发现全部指令语义。可复用或借鉴的部分包括：

- bytecode 枚举和 handler coverage；
- stack-size/data-flow pre-pass；
- branch target 和 label 分析；
- frame/local 映射；
- exception cleanup 规则；
- native form 和 runtime caller 选择；
- 对维护分支新增/修改 bytecode 的知识；
- 已有 AOT fixture 和 VM parity 测试思路。

但不能直接把当前 StaticJIT 生成的源码字符串交给 c2mir，因为当前输出是深度 UE-aware 的 C++：

- 使用 C++ 类型、构造/析构和模板；
- 直接引用 Unreal 类型和函数；
- 使用 `FScriptExecution`、RAII 和项目宏；
- 生成 Raw/Parms wrappers；
- 依赖 MSVC/Clang 的 C++ ABI。

c2mir 前端处理的是 C。因此现实选择是：

1. 以 Angelsea `BytecodeToC` 为 Runtime emitter 基线，按本 fork 修正 opcode、frame、helper 和 Binding ABI；
2. 将当前 StaticJIT 的 bytecode 分析与 lowering 语义逐步抽成宿主无关描述，再分别由 C/MIR emitter 和 C++ AOT emitter 消费；
3. PoC 阶段优先选 1，产品化后再评估是否值得做 2，避免先重构整个 StaticJIT。

### 1.8 最小 Runtime JIT 改动面

受限 PoC 的改动分为公共前置和可选插件两部分：

```text
AngelscriptRuntime（公共前置）
├── 唯一 FAngelscriptJITCoordinator
├── immutable bytecode compile snapshot
├── Runtime backend factory/session contract
├── revision/code lease publication
└── AOT / selected Runtime / VM route policy

AngelseaRuntimeJIT optional plugin
├── MIR/c2mir ThirdParty build integration
├── Runtime bytecode support scanner
├── BytecodeToC emitter（受限 opcode）
├── MIR compile/link/codegen wrapper
├── per-result disposable MIR context/code arena
└── focused VM parity/performance tests

AngelseaLLVMJIT optional plugin
├── external LLVM 21.1.8 SDK contract
├── direct bytecode → LLVM IR emitter
├── ORC LLJIT/resource tracker
└── 与 MIR 共用的 VM parity/performance corpus
```

核心 fork 首期需要重构 compiler ownership 和 Runtime backend contract，但仍不必修改：

- parser/compiler AST；
- `asBC_JitEntry` interpreter handler；
- `asCContext` continuation；
- StaticJIT AOT VM/Raw/Parms ABI；
- UASFunction optimized wrappers；
- ClassGenerator；
- provider artifact format；
- Shipping/package route。

首期数据流可以保持：

```text
OnFunctionReady → FAngelscriptJITCoordinator
    → 构造 immutable bytecode/frame/control-flow snapshot
    → whole-function support scan
        ├─ unsupported：coordinator 保持 VM
        └─ supported：selected backend compile
                        ├─ BytecodeToC → c2mir/MIR
                        └─ direct bytecode → LLVM IR → ORC
                                  ↓
                    coordinator revision validation
                                  ↓
                    publish Runtime Binding + code lease
                    VMEntry = generated code
                    RawEntry = null
                    ParmsEntry = null
```

触发策略由 coordinator 配置为 `EagerSync`、`EagerBackground` 或 `LazyFirstCall`，暂不复用 Angelsea dummy JIT counter，也不在第一版引入可调热点阈值。system/native/script call 暂不支持，或者只走本项目现有 runtime helper，不生成直接 C++ ABI 调用。

### 1.9 建议的渐进覆盖顺序

```text
第一阶段：primitive/local/branch/return
    ↓
第二阶段：异步编译、stale result、HotReload retirement
    ↓
第三阶段：script call 和现有 FunctionCaller/system helper
    ↓
第四阶段：handle/reference/UObject 和异常 cleanup
    ↓
第五阶段：热点策略与编译/代码内存预算
    ↓
第六阶段：实测后决定是否扩展 ResumeVM/multiple JitEntry
```

每一阶段未覆盖的函数都保持 VM，不需要等待“全部 bytecode 100% 支持”才交付前一阶段。

### 1.10 UE 解耦边界：Core 不需要 UE，Host Adapter 需要

面向 bytecode 的 Runtime JIT 核心应当尽量做到 **零 UE 依赖**。这意味着 bytecode decoder、支持性扫描、BytecodeToC、MIR compile/codegen 和机器码缓存不需要理解 `UObject`、`UFunction`、ClassGenerator、Blueprint 或 Editor。

推荐边界：

```text
Runtime JIT Backend Core（无 UE）
├── AngelScript bytecode decoder
├── whole-function support analyzer
├── bytecode → neutral C emitter
├── c2mir/MIR backend
├── neutral entry ABI
├── runtime helper imports
└── compiled-code lifetime primitive
            │
            │ narrow POD/function-pointer contract
            ▼
Runtime JIT Host Adapter（维护分支/UE adapter）
├── FScriptExecution trampoline
├── current engine/function/binding
├── function/type/global/helper slot resolution
├── FunctionCaller/system binding bridge
├── UObject/GC helper registration
├── HotReload/generation validation
├── Debugger/CodeCoverage/suspend policy
└── VM/Raw/Parms Binding publication/retirement
```

Core 可以依赖：

- 维护分支 AngelScript bytecode 定义和必要内部布局；
- 标准 C/C++ runtime；
- MIR/c2mir；
- 一个窄的宿主 helper ABI。

Core 不应依赖：

- `CoreMinimal.h`；
- UObject/UFunction 头文件；
- `FAngelscriptEngine`；
- ClassGenerator；
- Editor/HotReload module；
- Blueprint/GAS/GameplayTags；
- 任何具体 `Bind_*.cpp`；
- 项目模块或游戏类型。

这里需要区分“生成代码不知道 UE”和“生成代码不能调用 UE”。生成代码仍然可以通过宿主 helper 调用最终落到 UE 的 system function，只是 Core 不直接理解或生成具体 UE C++ 调用：

```text
asBC_CALLSYS FunctionSlot
    ↓
生成代码调用 HostApi.CallSystem(FunctionSlot, VMState)
    ↓
UE Host Adapter 解析当前 engine-local function
    ↓
Type_FunctionCaller / reflective fallback / RPC route
    ↓
实际 UObject/UFunction/C++ 调用
```

Angelsea 自己已经采用类似外部符号模式：MIR 通过 `MIR_load_external()` 绑定 `asea_call_script_function`、`asea_call_system_function`、`memcpy`、`fmod` 等 helper。项目适配时应把这些零散 external symbol 收敛为版本化 helper table 或 engine-local reference slots，而不是让 emitter include UE 头文件。

### 1.11 推荐的 neutral entry/helper ABI

当前公开 VMEntry 使用 `FScriptExecution&`，这是维护分支/UE 集成 ABI。为了保持 Runtime JIT Core 独立，可以由一个很薄的宿主 trampoline 把它转换为 neutral state：

```text
asCContext
    ↓ 当前 asSJITFunctionBinding::VMEntry
UE/Fork trampoline(FScriptExecution&, Frame, OutValue)
    ↓
NeutralCompiledEntry(NeutralVMState*, EntryLabel)
```

概念上的 neutral state 可以只包含 POD 字段：

```cpp
struct FASRuntimeJITState
{
    void* HostContext;
    uint32_t* ProgramPointer;
    uint32_t* StackPointer;
    uint32_t* StackFramePointer;
    uint64_t ValueRegister;
    void* ObjectRegister;
    const FASRuntimeJITHostApi* HostApi;
    const void* const* ReferenceSlots;
};
```

这只是研究阶段的边界示例，不是已决定的 ABI。正式设计需要明确字段大小、对齐、版本、平台指针宽度和 continuation 语义。

宿主 helper table 可以表达：

- call current script function；
- call system/native function；
- resolve virtual/interface/import target；
- set AS exception；
- addref/release/construct/destruct；
- allocation/free；
- cast/type check；
- global/string/runtime helper lookup；
- debugger/coverage/suspend probe；
- request VM continuation。

这样 Runtime JIT Core 生成的 C/MIR 只知道稳定 slot index 和 helper signature，不知道 slot 最终指向普通 AngelScript object、UObject、UFunction 还是项目 native binding。

### 1.12 UE 类型、属性和函数为何不要求 UE-aware lowering

对 bytecode backend 而言：

- UObject handle 仍然是一个指针/handle value；
- property access 已经降低成 offset/reference 操作；
- system function 已经是 function id/reference；
- virtual/interface call 已经携带 dispatch 所需元数据；
- constructor/destructor/addref/release 已经表现为 bytecode 或 helper call；
- JIT 不需要重新解析 `UCLASS`、`UPROPERTY` 或 `UFUNCTION`。

真正需要 UE Host Adapter 处理的是这些值是否仍然对当前 engine generation 有效：

| 内容 | Core 所见 | Host 责任 |
|---|---|---|
| UObject handle | opaque pointer/handle | GC/lifetime/cast/helper 语义 |
| UFunction/system call | function slot | 当前 binding、RPC、reflective route |
| Property offset | immediate/layout slot | HotReload/layout ABI 验证和失效 |
| Script function | stable/current function slot | current override、generation、VM/Native route |
| Type info | type slot | 当前 engine-local type resolution |
| Global/string | reference slot | 当前地址、lifetime 和 ABI resolution |

在 immutable cooked profile 中，完整 artifact/environment/layout 验证后可以把某些 offset 或地址固化为 direct path。在 Editor/reloadable profile 中，应优先使用 engine-local slot/helper，或者在 layout/function generation 改变时使旧 Runtime Binding 立即失效。这个差别属于 Host route policy，不需要污染 primitive bytecode emitter。

### 1.13 可选 UE fast path 不应污染 Core

完全通过 helper 调用 system function 会增加一次间接调用，但：

- 纯计算热点不经过 UE helper，性能不受影响；
- 很多 UObject/UFunction 调用本身远比一次函数指针间接调用昂贵；
- 第一阶段优先正确性和可移植性；
- 当前项目已经有 `FunctionCaller`，无需在 MIR backend 重做 C++ ABI。

如果基准证明 native-call-heavy 函数需要进一步优化，可以由 Host 注册经过验证的 fast stub：

```text
Core emits CallSlot(N)
    ↓
Host slot N
    ├── generic FunctionCaller stub
    ├── reflective UFunction stub
    └── verified direct native stub
```

Core 仍只看到统一 ABI 的函数指针。UE-specific fast path 被限制在 adapter/stub 注册侧，可单独按 platform/profile/ABI 开关和测试。

### 1.14 这种拆分带来的附加价值

将 Runtime JIT Core 保持为无 UE 的标准 C/C++ library，可以：

- 在 `Plugins/Angelscript/Standalone/` 或纯 AngelScript test host 中独立测试；
- 用小型进程跑 bytecode parity、fuzz、compile-time 和 code-memory benchmark；
- 减少启动 UE Editor 才能调试 lowering 的成本；
- 让 MIR/c2mir patch 和升级与 UE module 生命周期分离；
- 为将来替换 MIR backend 保留接口；
- 避免 `AngelscriptRuntime` 在不启用 JIT 的平台承担 MIR 依赖；
- 更清楚地区分 AngelScript VM 语义问题与 UE Host route 问题。

因此，进一步修正后的结论是：

> Runtime JIT 的 bytecode-to-MIR 核心不需要 UE-aware code generation，也不应依赖 UE；但把生成代码安全地接到当前 UE AngelScript engine、system bindings、HotReload 和调试生命周期，仍需要一个窄而明确的 UE Host Adapter。UE 是宿主边界，不是 JIT lowering 的输入语言。

---

## 二、概念边界

### 2.1 本文中的 Runtime JIT

Runtime JIT 指：

```text
当前进程中的 AngelScript bytecode
    → 当前进程内生成中间代码
    → 当前进程内生成目标机器码
    → 不重新启动、不重新链接 UE 模块
    → 将函数入口发布给当前 asIScriptEngine
```

它通常具有以下特征：

- 首次调用、热点阈值或显式请求后编译；
- 机器码只对当前平台和进程有效；
- 需要运行期代码内存分配、权限切换和缓存管理；
- 脚本修改后可重新编译并替换 Binding；
- 编译开销发生在运行期。

### 2.2 本文中的 StaticJIT AOT

当前 AngelscriptProject StaticJIT 实际是：

```text
AngelScript bytecode
    → UE-aware C++ source
    → UBT + MSVC/Clang
    → UE module / executable 中的普通 .text
```

它名为 StaticJIT，但属于离线 AOT 转译。运行时只匹配、发布和调用已经由 C++ 工具链生成的入口，不在目标进程里生成机器码。

### 2.3 JIT Provider 与 Runtime Backend 不是同一个概念

当前 `IAngelscriptJITArtifactProvider` 面向进程可发现的、已经编译进 UE 模块的不可变 AOT artifact。Provider view 包含：

- `ProviderId`；
- `ProviderGeneration`；
- artifact-set digest；
- profile/environment/ABI；
- 稳定 module/function key；
- execution/debug hash；
- VM/Raw/Parms entries；
- stable reference slots。

Runtime JIT 则是：

- 由某一个 `FAngelscriptEngine` 触发；
- 根据该 engine 当前 bytecode 生成机器码；
- 通常捕获或依赖该 engine 的 runtime helper/reference 环境；
- 生命周期首先属于 engine，而不是一个可跨 engine 共享的 UE module artifact。

因此第一版 Runtime JIT 不应伪装成普通的进程级静态 Provider。两者可以共享稳定身份、Binding 和 route 规则，但 ownership 不同。

---

## 三、Angelsea 的 JIT 实现

### 3.1 总体流水线

Angelsea 是真正的 AngelScript 字节码 Runtime JIT：

```text
AngelScript source
    ↓
AngelScript compiler
    ↓
asBC_* bytecode
    ↓
asBC_JitEntry / 热度计数
    ↓ 达到阈值或 eager
BytecodeToC
    ↓
内存 C source
    ↓
c2mir
    ↓
MIR IR
    ↓
MIR native code generator
    ↓
asJITFunction
    ↓
SetJITFunction
```

关键源码：

- `Reference/angelsea/include/angelsea/jit.hpp`：`Jit : asIJITCompilerV2`；
- `Reference/angelsea/include/angelsea/config.hpp`：热点阈值、MIR 优化等级、函数大小上限和实验开关；
- `Reference/angelsea/src/angelsea/detail/mirjit.cpp`：函数注册、惰性触发、c2mir、MIR codegen、安装和清理；
- `Reference/angelsea/src/angelsea/detail/bytecode2c.cpp`：AngelScript bytecode 到 C；
- `Reference/angelsea/src/angelsea/detail/runtime.cpp`：VM、脚本调用和 system call helper。

### 3.2 为什么先生成 C，而不是直接生成 MIR

Angelsea 没有为每个 `asBC_*` 直接构造 MIR 指令，而是先把函数写成 C，再交给 c2mir。这样可以：

- 用 C 表达 VM 栈、寄存器、指针运算和控制流；
- 让 c2mir 处理类型 lowering、基本优化和 ABI 细节；
- 生成较可读的中间产物，方便调试；
- 为未来 AOT C 编译器或代码注入留下可能性。

代价是：

- 多一层 C parser/frontend；
- 编译时间和内存高于直接发 MIR；
- 对 C/MIR 的错误和优化限制同时敏感；
- 生成器仍需理解 AngelScript VM 内部布局。

### 3.3 惰性触发

默认配置为：

```cpp
hits_before_func_compile = 15000;
eager = false;
```

这里的计数对象是 JIT entry 命中，不严格等同于函数调用次数。函数内可能存在多个 `asBC_JitEntry`，热点函数一次调用可能命中多个 entry。

注册阶段先安装计数入口：

```text
命中 JIT entry
    ↓
hits--
    ├─ hits > 0：跳过 entry，继续 VM
    └─ hits == 0：启动 BytecodeToC/MIR 编译
```

Angelsea 支持宿主提供异步 compile callback。c2mir/MIR 工作可以由宿主任务执行，但共享 MIR context 的 module 转移、link 和最终 codegen 使用 mutex 串行化；README 也明确说明 JIT compiler 本身尚非完整线程安全。

### 3.4 多 JIT entry 与函数内 fallback

这是 Angelsea 最关键的能力。

生成函数的 ABI 类似：

```cpp
void Generated(asSVMRegisters* Regs, asPWORD EntryLabel);
```

函数开头按照 `EntryLabel` 跳转：

```cpp
switch (EntryLabel)
{
case 1: goto bc0;
case 2: goto bc47;
case 3: goto bc92;
}
```

遇到不支持的 bytecode 时，生成代码保存 VM 恢复位置并返回：

```cpp
Regs->pc = BasePc + InstructionOffset;
Regs->sp = Sp;
return;
```

随后：

```text
Native 执行前半段
    ↓
不支持的 bytecode
    ↓ 保存 PC/SP，返回 VM
VM 从该 bytecode 继续
    ↓
到达后续 asBC_JitEntry
    ↓
使用新 EntryLabel 重新进入 Native
```

因此它不是单纯的“整函数 JIT 成功/失败”，而是允许一个函数在 Native 和解释器之间分段执行。

### 3.5 脚本调用

Angelsea 对脚本调用的目标是：

```text
JIT caller
    ├─ callee 已有 JIT：JIT-to-JIT
    ├─ 递归且入口已知：直接调用当前生成函数
    └─ callee 未 JIT：准备 AS call stack，回到 VM
```

该策略可以减少 Context/VM 的完整调用开销，但需要准确维护：

- current function；
- frame/stack layout；
- object/value registers；
- virtual/interface dispatch；
- 返回位置和后续 JIT entry；
- 异常和 suspend 状态。

### 3.6 system/native 调用

Angelsea 会尝试直接生成 generic/native C 调用。默认启用的实验路径包括：

- fast script call；
- direct generic call；
- direct native call。

它为此直接依赖：

- `asCContext`；
- `asCScriptFunction`；
- `asCScriptEngine`；
- `asCGeneric` 内部布局和 vtable；
- Windows/Linux x64、部分 ARM64 ABI；
- AngelScript 内部 calling convention 数据。

复杂按值类型、部分返回类型、可变参数、auto handle、辅助函数和未覆盖 ABI 会回到 runtime helper 或 VM。

这套实现适合通用 AngelScript 嵌入研究，但不应直接绕过本项目的：

- `Type_FunctionCaller`；
- `FScriptFunctionNativeForm`；
- UHT/manual/generated binding；
- NativeModuleFunctionAddress；
- reflective fallback；
- RPC routing；
- WorldContext/out-param/container 限制。

### 3.7 默认性能开关的语义代价

Angelsea 默认包含几项偏性能的开关：

- 忽略部分 `SUSPEND` 检查；
- 直接 native call 时忽略 C++ exception 捕获；
- 部分直接调用前不更新 PC/SP/FP；
- direct generic call 会构造/复用 `asCGeneric` 内部状态；
- direct native call 会模拟 C++ ABI。

这可能影响：

- DebugServer；
- CodeCoverage；
- 调试器读取当前脚本位置；
- 异常 callstack；
- latent/suspend；
- 线程安全 Context inspection；
- HotReload 后的内部布局兼容。

移植时应默认关闭这些 hack，再逐项以项目测试证明后启用；不能照搬默认值。

### 3.8 MIR 边界

当前默认：

- MIR optimization level `2`；
- 最大函数 bytecode 大小 `25000` bytes；
- MIR level `3` 被明确标记为可能错误和导致内存破坏；
- 最终共享 MIR codegen 需要锁；
- MIR module 当前不能按函数卸载；
- Angelsea README 明确标记项目为 alpha quality。

支持矩阵以 Win/Linux x64 为主，ARM64 Linux/macOS 属于实验性范围。运行期 JIT 还要求平台允许可执行内存，不能仅依据 MIR 声称支持的平台决定 UE Shipping 支持范围。

### 3.9 依赖与许可证

Angelsea 当前硬依赖：

- AngelScript 2.37.0+；
- fmt；
- Angelsea 自己维护的 MIR downstream fork。

本地许可证：

- Angelsea：BSD-2-Clause；
- MIR：MIT；
- fmt 仍需按最终导入版本保留其许可证和 notice。

`Reference/angelsea` 只是研究参考，不是 Runtime 依赖。真正引入时必须把固定版本源码、patch、许可证和升级策略纳入正式第三方目录，正常构建不能从 `Reference/` 链接。

---

## 四、当前 AngelscriptProject StaticJIT

### 4.1 当前执行链路

```text
AngelScript source
    ↓
AngelScript compiler
    ↓
asBC_* bytecode
    ↓
FAngelscriptStaticJIT::GenerateCppCode
    ↓
UE-aware C++ source
    ├─ *.as.jit.hpp
    ├─ *.jit.cpp
    └─ AngelscriptJitInfo.jit.cpp
    ↓
UBT + MSVC/Clang
    ↓
UE module / executable 中的普通 Native function
    ↓
Runtime 匹配并发布完整 Binding
```

测试工作流目前也是：

```text
Baseline Build
    → Generate AOT artifacts
    → Rebuild generated C++
    → Run StaticJIT tests
```

所以当前 StaticJIT 是 AOT，不是 Runtime JIT。

### 4.2 完整 Binding 是本项目的重要优势

维护分支当前公开：

```cpp
struct asSJITFunctionBinding
{
    asJITFunction VMEntry;
    asJITFunction_Raw RawEntry;
    asJITFunction_ParmsEntry ParmsEntry;
    void* UserData;
};
```

入口用途：

- `VMEntry`：`asCContext`/VM 路径执行生成函数；
- `RawEntry`：已知 C++ 签名的直接调用；
- `ParmsEntry`：Unreal reflected parameter buffer / `UASFunction` 调用；
- `UserData`：保存 provider/binding 的不可变生命周期上下文。

完整 Binding 让同一函数 generation 的三个入口不会相互错配，并允许 function/engine 对旧 generation 进行安全退休。

### 4.3 当前是整函数模型

当前 StaticJIT 明确不支持 sharded JIT：

```cpp
check(BC == BC_FunctionStart); // We no longer support sharded JIT functions
```

生成阶段要求全部 bytecode handler 实现成功：

```cpp
bool bImplemented = Bytecode.Implement(Context);
check(bImplemented);
```

因此当前 fallback 主要是：

```text
完整 Native Binding 可用
    → 整函数 Native

Binding 缺失、过期或不兼容
    → 整函数 VM
```

生成函数内部对某个 C++ 调用使用 dynamic/native helper 属于调用点 ABI fallback，不等于脚本函数回到 bytecode PC 继续解释。

### 4.4 UE-aware lowering

当前转译器理解：

- Unreal C++ 类型；
- UObject、UClass、property offset；
- 反射参数布局；
- `FScriptExecution`；
- native form；
- `Type_FunctionCaller`；
- `UASFunction` specialized/generic wrapper；
- current virtual override；
- ClassGenerator；
- 异常、对象返回和引用写回。

因此对 UE binding-heavy 代码，正式 C++ AOT 可以直接使用真实 C++ 类型和已有 ABI 桥，而不必重复模拟平台 C++ ABI。

### 4.5 Multi-provider 重构的当前状态

`refactor-as-static-jit-multi-provider` 当前为 `19/63` tasks 完成。已经落地：

- 单一非版本化 JIT lifecycle；
- delayed full-binding publication；
- exactly-once retirement；
- stable identity 和 neutral route 基础；
- multi-provider Registry；
- provider matcher；
- stable reference descriptors/resolver；
- engine-local VM/Raw/Parms execution context；
- reloadable current-callee route 的一部分。

尚未完成：

- safe per-ProviderId generation publication/retirement；
- 生产 route builder 端到端连接；
- 完整 UASFunction dispatch matrix；
- 32-bucket generator；
- `AngelscriptTestJIT`；
- project `AngelscriptJIT` module；
- Editor/PIE Native route；
- Live Coding refresh；
- 删除 `FJITDatabase`、FunctionId 和 whole-cache DataGuid 旧路径。

目前 Runtime 已启动 provider modular-feature discovery，但 `FAngelscriptJITProviderMatcher::Match()` 和 `PublishProviderSelection()` 的实际调用仍集中在测试；旧 `OnFunctionReady()` 仍保留按 FunctionId 查询 `FJITDatabase` 的兼容路径。

Runtime JIT 不应绕过这项重构另建一套不兼容的函数指针生命周期。

---

## 五、Angelsea 与当前 StaticJIT 的核心差异

| 维度 | Angelsea | 当前 AngelscriptProject StaticJIT |
|---|---|---|
| 实质 | Runtime JIT | C++ AOT transpiler |
| 输入 | AngelScript bytecode | AngelScript bytecode |
| 中间层 | C → MIR | UE-aware C++ |
| 机器码生成 | MIR runtime | UBT + MSVC/Clang |
| 时机 | 热点/eager，当前进程 | Commandlet 后重新 Build |
| 冷函数 | 默认不编译 | 进入生成集合后由工具链编译 |
| fallback 粒度 | 函数内 Native ↔ VM | 整函数 Native 或 VM |
| JIT entry | 多 entry label | 当前只支持函数起点 |
| Script call | JIT-to-JIT 或 VM | current route / AOT Native / VM |
| Native call | 自己模拟 generic/native ABI | 复用 UE binding/native form/caller |
| 入口 ABI | 一个 VM 风格入口 | VM / Raw / Parms / UserData |
| UE 反射 | 无专门支持 | 原生设计目标 |
| UObject/GC | 需额外适配 | 已纳入现有语义 |
| HotReload | 可换逻辑入口，MIR code 难卸载 | provider generation/route 正在重构 |
| 运行期成本 | 编译 CPU、内存、机器码页 | 无运行期代码生成 |
| 峰值优化 | MIR O2 | 正式 C++ 编译器/LTO 潜力 |
| Shipping | 受 executable-memory/platform 限制 | 可重现的普通 Native artifact |
| 成熟度 | alpha | 旧 AOT 深度集成；新 provider 尚在进行 |

两者应当互补，而不是互相替换。

---

## 六、为什么不能原样接入 Angelsea

### 6.1 AngelScript 版本和接口不兼容

Angelsea 依赖 AngelScript 2.37.0+ 的 `asIJITCompilerV2`：

```cpp
class Jit : public asIJITCompilerV2
{
    void NewFunction(asIScriptFunction*) override;
    void CleanFunction(asIScriptFunction*, asJITFunction) override;
};
```

维护分支已经删除：

- `asIJITCompilerV2`；
- v1/v2 abstract base；
- JIT interface version engine property；
- 旧同步 Compile/Release API。

当前接口为：

```cpp
class asIJITCompiler
{
    virtual void OnFunctionReady(asIScriptFunction*) = 0;
    virtual void ReleaseFunctionBinding(
        asIScriptFunction*,
        const asSJITFunctionBinding&) = 0;
};
```

生命周期思想兼容，但源码/API 不兼容。应移植后端，而不是恢复 upstream V2 适配层。

### 6.2 VMEntry ABI 不兼容

Angelsea：

```cpp
void(asSVMRegisters*, asPWORD EntryLabel)
```

维护分支：

```cpp
void(FScriptExecution&, asDWORD* Frame, asQWORD* OutValue)
```

本 fork 的 `FScriptExecution` 还包含：

- current JIT engine/function/binding；
- binding UserData；
- exception state；
- UE 增强的 debug/callstack/thread-local 语义。

所以不能只写一个轻量 typedef adapter。

### 6.3 当前 VMEntry 返回协议不支持 ResumeVM

这是可行性分析中最重要的新发现。

当前 `asCContext` 调用 `Binding.VMEntry` 后：

```text
VMEntry 返回
    ├─ Execution.bExceptionThrown == true
    │    → asEXECUTION_EXCEPTION
    └─ false
         → 复制返回值
         → 把函数视为执行完成
```

直接执行入口位于：

- `ThirdParty/angelscript/source/as_context.cpp:975-1016`；
- `ThirdParty/angelscript/source/as_context.cpp:1473-1518`。

当前没有 `Completed / ResumeVM / Suspended / Exception` 返回状态，也没有 entry label 参数。于是 Angelsea 的：

```cpp
Regs->pc = ...;
Regs->sp = ...;
return; // 期望 VM 继续
```

在本 fork 中会被误判为“函数正常完成”。

因此：

- **整函数 Runtime JIT 可以接入**；
- **Angelsea 原版函数内 fallback 不能直接接入**；
- 若要完整保留该能力，必须扩展维护分支的 JIT execution result/continuation 协议。

### 6.4 Angelsea 的 dummy JIT counter 不能直接复用

Angelsea 通过安装一个“只计数然后返回”的假 JIT 函数统计热点。维护分支当前会把非异常 VMEntry 返回当作整个函数完成，因此相同技巧会跳过脚本函数本体。

可选替代：

1. 第一版使用显式/eager 编译，不做热点计数；
2. 在 VM 函数调用分发处记录 function invocation；
3. 在 `asBC_JitEntry` handler 增加可选观察 hook；
4. 扩展 JIT 返回协议，使 dummy entry 能明确返回 `ResumeVM`。

推荐 PoC 先采用 1，产品化阶段再在 2/3/4 中选择。

### 6.5 不能复用 direct native ABI hack

本项目的 Native 调用必须遵守：

- RPC/Net UFunction 继续走 reflective routing；
- WorldContext/out-param/ref return/container 等安全限制；
- manual/UHT-generated/native-module-address binding 的现有选择；
- UObject handle、GC 和对象返回规则；
- `Type_FunctionCaller` 和 `FScriptFunctionNativeForm`。

因此 Runtime JIT 的 call lowering 应生成对本项目 runtime helper/reference slot 的调用，不能直接采用 Angelsea 的 `asCGeneric` vtable 和平台 ABI 模拟。

### 6.6 Debugger、Coverage、Suspend 和异常不能默认牺牲

Runtime JIT 开启时必须明确：

- 是否保留 line/statement entry；
- breakpoint 如何使函数退回 VM 或进入 debug-aware code；
- CodeCoverage 如何记录执行；
- latent/suspend 如何恢复；
- C++ exception 如何转换为 AS exception；
- debug context inspection 需要哪些 PC/SP/FP 状态。

首期建议：

- Debugger attached、breakpoint、coverage enabled、latent function 等情况强制 VM；
- 不启用 Angelsea `hack_ignore_*`；
- 先证明普通同步函数正确，再扩大范围。

### 6.7 MIR code 生命周期不能等同于 Binding 生命周期

Binding 可以安全退休，不代表 MIR 机器码内存立即可释放。

第一版已经选择：

- 每 engine 一个 MIR backend session 和串行 compile queue；
- 每个成功函数 revision 使用独立、可销毁的 MIR context/code arena；
- code lease 同时拥有该 context、机器码和 runtime state；
- 函数修改后立即清除/替换 Binding，但旧 reader 继续持有旧 lease；
- 最后 reader 退出后销毁旧 revision 的 MIR context，而不是把全部旧代码保留到 engine shutdown；
- 记录累计 code size、live/retired lease、stale result 和 context 创建/销毁数量。

这个选择利用了首版不支持 JIT-to-JIT 调用的边界：函数之间不需要共享链接 context。后续若增加 JIT-to-JIT 或共享优化，应另行设计 context generation/arena、reader drain、内存预算和整代滚动替换，不能把共享 context 的按函数卸载问题隐藏在 Binding retirement 之后。

---

## 七、三种接入方案

### 7.1 方案 A：直接 fork Angelsea 并替换现有 compiler

做法：

- 将 Angelsea/MIR/fmt 编入插件；
- 恢复或适配 `asIJITCompilerV2`；
- 用 Angelsea `Jit` 替换 `FAngelscriptStaticJIT`；
- 直接使用其 `asSVMRegisters + entryLabel` 模型。

优点：

- 最快看到 MIR 执行简单 bytecode 的 demo；
- 可以最大程度保留 Angelsea 上游实现。

缺点：

- 与当前非版本化 lifecycle 冲突；
- 破坏 VM/Raw/Parms Binding；
- 与 multi-provider 方向冲突；
- 需要改回 upstream context ABI；
- direct native ABI 不符合 UE binding 规则；
- HotReload、UASFunction、GC、Debugger 风险最高。

结论：**不推荐作为产品方案，也不建议作为主分支 PoC。**

### 7.2 方案 B：移植 BytecodeToC/MIR，先做整函数 Runtime JIT

做法：

- 保留当前 `asIJITCompiler` 和 Binding；
- 抽取/移植 Angelsea bytecode lowering 与 MIR backend；
- 生成维护分支自己的 VMEntry ABI；
- 编译前做整函数支持性扫描；
- 全部支持才生成 Native，否则保持 VM；
- system/native call 进入本项目 helper/reference slot；
- 首期只发布 VMEntry；
- runtime backend 属于 engine，由 coordinator 管理。

优点：

- 最小化 AS fork/context 改动；
- 能较快回答 MIR 在真实 UE 工程中的收益；
- 不破坏 VM/Raw/Parms 生命周期；
- 可安全限制到 Editor/Development；
- 与未来可恢复 ABI 不冲突。

缺点：

- 暂时失去 Angelsea 最有价值的函数内 fallback；
- bytecode 覆盖不足会造成较多整函数 VM miss；
- 仍需维护一套 Runtime lowering；
- 每个函数 revision 独占 MIR context/code arena 会增加创建成本和峰值内存，必须通过 benchmark 判断是否可接受。

结论：**推荐的 PoC 和第一阶段产品路线。**

### 7.3 方案 C：扩展可恢复 JIT ABI，完整支持分段执行

做法：

为 VMEntry 增加类似协议：

```cpp
enum class EAngelscriptJITExecutionResult
{
    Completed,
    ResumeVM,
    Suspended,
    Exception,
};
```

并让执行上下文携带或返回：

- resume bytecode PC；
- stack pointer/frame pointer；
- entry label；
- value/object registers；
- current function/call state；
- suspend/exception 状态。

执行链路：

```text
Native
    ├─ Completed → 正常返回调用者
    ├─ Exception → AS exception
    ├─ Suspended → Context suspend
    └─ ResumeVM → VM 从指定 PC 继续
                         ↓
                  后续 JitEntry 再进 Native
```

优点：

- 完整保留 Angelsea 的细粒度 fallback；
- backend 可以从少量 opcode 覆盖开始逐步扩展；
- latent/call/interface 等复杂语义可以保守交给 VM；
- 更适合作为长期 tiered execution architecture。

缺点：

- 会改变核心 JIT ABI 和 `asCContext`；
- VM/Raw/Parms 的“完整 Binding”定义需要进一步明确；
- 需要新增大量状态机、嵌套调用、异常、递归、suspend 和线程测试；
- 可能影响已生成 StaticJIT AOT VMEntry ABI；
- 必须决定旧 AOT provider ABI revision 如何升级。

结论：**长期价值最高，但应在方案 B 的收益得到实测后再做。**

---

## 八、推荐架构

### 8.1 唯一 coordinator，多个实现来源

当前一个 `asIScriptEngine` 只能安装一个 `asIJITCompiler`。不应让 StaticJIT compiler 和 Runtime JIT plugin 争抢 `SetJITCompiler()`。

推荐由 Runtime 拥有唯一 coordinator：

```text
asIScriptEngine
    ↓ SetJITCompiler
FAngelscriptJITCoordinator
    ├─ Static artifact provider matcher
    ├─ Engine-local Runtime JIT backend
    ├─ VM/current function route
    ├─ Binding publication/retirement
    └─ Diagnostics/counters
```

概念接口可以类似：

```cpp
class IAngelscriptRuntimeJITBackend
{
public:
    virtual bool Supports(const FAngelscriptJITCompileRequest&) const = 0;
    virtual void RequestCompile(const FAngelscriptJITCompileRequest&) = 0;
    virtual void Cancel(const FAngelscriptStableFunctionKey&) = 0;
};
```

该接口不是最终 API 建议，只表达 ownership：

- coordinator 是唯一 Binding publisher；
- backend 只准备 engine-local 编译结果；
- 编译结果必须带完整 stable identity/execution/profile/ABI；
- coordinator 在 safe point 再发布；
- stale result 直接丢弃，不能覆盖当前函数。

### 8.2 选择顺序

函数 ready 或 provider/backend 刷新时：

```text
1. 计算当前稳定身份、execution hash、profile、ABI
2. 查找完全匹配的 Static AOT provider
   ├─ 命中：发布 AOT Binding
   └─ 未命中：继续
3. 查找当前 engine 的 Runtime JIT compiled record
   ├─ 完全匹配且 Ready：发布 Runtime Binding
   └─ 未命中/Compiling：继续
4. 保持空 Native Binding，执行 VM
5. 若策略允许，排队 Runtime compile
6. 编译完成后重新验证当前身份
7. safe point 发布 Runtime Binding
```

AOT 优先的原因：

- 产物已由正式 C++ 工具链编译；
- 可能包含 Raw/Parms 和 UE-aware native forms；
- 不产生运行期编译和 code-memory 成本；
- artifact identity 已通过完整 provider validation。

### 8.3 编译请求必须是不可变快照

worker thread 不能长期持有会被 HotReload 替换的可变 AS/UE 对象。请求应包含：

- StableModuleKey；
- StableFunctionKey；
- ExecutionContentHash；
- DebugContentHash；
- profile/environment/ABI；
- 拷贝后的 bytecode；
- 拷贝后的函数签名和 frame metadata；
- stable reference descriptors；
- compile generation；
- backend config/version hash。

可变对象地址只能在 Game Thread/safe point 解析成当前 engine-local reference slots。

### 8.4 编译完成后的发布条件

编译结果必须再次核对：

- function key 未变化；
- execution hash 未变化；
- compile generation 仍是当前 generation；
- engine 未销毁；
- backend/module 未停止；
- required references 仍可唯一解析；
- Entry ABI/profile/environment 仍匹配；
- 当前没有优先级更高的 AOT provider；
- Binding publication 发生在 engine safe point。

任一失败：

```text
丢弃或保留为不可达 stale compiled record
    → 当前函数继续 VM/AOT
    → 不发布过期指针
```

### 8.5 Runtime Binding 的首期形状

第一版建议：

```text
VMEntry    = MIR generated trampoline/function
RawEntry   = null
ParmsEntry = null
UserData   = engine-owned immutable compiled-function record
```

影响：

- `asCContext` 可执行 Runtime JIT；
- 需要 Raw 的 optimized caller 不会误用错误 ABI；
- `UASFunction`/reflected call 继续通过现有 generic/current route；
- 后续可以为安全签名逐步生成 Raw/Parms；
- provider matcher/diagnostics 必须把“只有 VMEntry”视为明确的 Runtime profile 能力，而不能冒充完整 AOT provider。

### 8.6 Runtime JIT 与 Editor HotReload

脚本修改流程应保持 AS compile authoritative：

```text
保存 .as
    ↓
正常 AS preprocess/compile
    ├─ 失败：旧 module/binding 保持
    └─ 成功：接受新 function generation
              ↓
         立即使旧 Runtime Binding 对新调用不可达
              ↓
         新函数先走 VM
              ↓
         显式/热点触发 Runtime compile
              ↓
         safe point 发布新 Binding
```

旧 in-flight call 通过现有 binding/code lease 执行完，最后 reader 退出后发生逻辑 retirement。MIR 首版同时销毁该 revision 独占的 context/code arena；LLVM 首版移除对应 ORC resource tracker。若未来引入共享 generation，再以独立设计修改这个 ownership 规则。

---

## 九、模块与依赖边界

### 9.1 不建议把 MIR 直接塞进 AngelscriptRuntime

直接放入 `AngelscriptRuntime` 会导致：

- 所有目标承担 MIR/c2mir/fmt 构建成本；
- 不支持运行期 JIT 的平台也编译无用代码；
- core plugin 的第三方依赖和许可证表面扩大；
- Shipping/package 策略更难隔离；
- MIR backend 升级与核心 Runtime 发布绑定。

### 9.2 推荐可选扩展插件

推荐形状：

```text
Plugins/AngelseaRuntimeJIT/
├── AngelseaRuntimeJIT.uplugin
└── Source/
    ├── AngelseaRuntimeJIT/              # MIR backend / coordinator adapter
    ├── AngelseaRuntimeJITTest/
    └── ThirdParty/
        ├── AngelseaDerived/             # 固定、审计后的 lowering/runtime 部分
        ├── MIR/                          # 固定 downstream fork
        └── Licenses/

Plugins/AngelseaLLVMJIT/
├── AngelseaLLVMJIT.uplugin
└── Source/
    ├── AngelseaLLVMJIT/                 # direct bytecode → LLVM IR / ORC
    ├── AngelseaLLVMJITTest/
    └── ThirdParty/LLVM/                  # SDK contract/license，不提交 SDK payload
```

依赖方向：

```text
             AngelscriptRuntime
                ▲         ▲
 public dependency│         │public dependency
                │         │
AngelseaRuntimeJIT      AngelseaLLVMJIT
   (optional MIR)         (optional LLVM)
```

核心 Runtime 只暴露窄的 backend registration/request/result 接口，不依赖可选插件。

如果后续决定 Runtime JIT 是核心产品默认能力，也可以重新评估模块归属；但 PoC 阶段两个独立同级插件更利于：

- 平台 allowlist；
- Editor/Development 开关；
- 依赖和许可证隔离；
- 二进制体积比较；
- 完全关闭后验证 VM/AOT 不受影响。

### 9.3 初始平台和配置

建议首期硬限制：

```text
Platform: Windows x64
Target:   Editor
Config:   Development/DebugGame
Shipping: disabled
Test:     disabled，除非专门启用
```

随后再评估：

- Linux x64 Editor/Development；
- Game Development；
- ARM64；
- 是否永远不支持 Shipping；
- console/mobile 平台的 executable-memory/code-signing 约束。

---

## 十、推荐实施阶段

### 阶段 0：完成当前 JIT 生命周期/route 基础

Runtime JIT PoC 不必等待 multi-provider 全部 `63/63`，但至少建议先完成：

- task 3.6：provider generation 安全发布/退休；
- task 4.1：Native/VM/current call parity；
- task 4.5：in-flight call 与 replacement；
- 明确 coordinator/engine ownership；
- 生产 `Match → Binding publication` 路径不再只存在于测试。

否则 Runtime JIT 会被迫自己实现第二套不完整的 publication 生命周期。

### 阶段 1：MIR 构建探针

目标：只证明 UE Build.cs 能稳定编译和链接固定版本 MIR/c2mir。

范围：

- optional module/plugin；
- Windows x64 Editor；
- 创建/销毁一次 disposable MIR context/code arena；
- 编译一段固定 C 字符串；
- 调用生成函数；
- 记录编译时间、代码大小和卸载行为；
- 不读取 AngelScript bytecode；
- 不安装 JIT Binding。

该阶段回答：

- MIR 与 UE 编译选项/PCH/unity/exceptions 是否冲突；
- CRT、allocator、threading、LTO/optimization 是否有问题；
- executable memory 在 UE 进程中是否工作；
- 第三方源码是否需要 patch。

### 阶段 2：整函数纯计算 PoC

支持最小 bytecode 子集：

- 常量；
- int/float arithmetic；
- local load/store；
- comparison；
- branch/goto；
- return；
- 可选简单参数和返回值。

禁止：

- UObject；
- system/native calls；
- script calls；
- handles/references；
- exceptions；
- suspend；
- interface/virtual dispatch；
- GC；
- Raw/Parms。

触发方式覆盖 `EagerSync`、`EagerBackground` 和 `LazyFirstCall`，但不先引入可调热点阈值或 Angelsea dummy JIT counter。

### 阶段 2B：LLVM SDK 与 constant ORC probe

LLVM 插件与 MIR lowering 并行但不互相依赖。进入完整 opcode lowering 前先完成：

- 配置并严格校验外部 LLVM 21.1.8 Developer SDK；
- 通过 LLVM C API 构造/verify constant-return IR；
- 显式验证 Win64 x64 triple、data layout 和 VMEntry calling convention；
- 通过 ORC LLJIT materialize/lookup 入口；
- 用 resource tracker/code lease 销毁该 entry；
- 证明插件禁用时不探测、不链接、不 stage LLVM。

### 阶段 3：Engine-local Runtime Binding

目标：

- coordinator 接收编译结果；
- identity 二次验证；
- 发布 VMEntry/UserData；
- `Context->Execute()` 到达 MIR code；
- Binding replacement/clear/function destroy exactly once；
- 两 engine 使用独立 backend session、function records 和 per-result MIR context/ORC resource tracker；
- 关闭 backend 后完全回到 VM。

### 阶段 4：HotReload 与异步编译

目标：

- worker 编译不可变请求；
- Game Thread/safe point 发布；
- 函数 body 修改后旧 Binding 立即对新调用不可达；
- stale async result 不得覆盖新函数；
- unchanged functions 保持现有 AOT/Runtime route；
- 记录 compile queue、cancel、stale、failure reason。

### 阶段 5：调用桥

优先级：

1. runtime helper；
2. 当前 route 的 script-to-script call；
3. 本项目 `FunctionCaller`；
4. 安全、明确验证后的直接调用。

不采用 Angelsea 的 generic vtable/native ABI hack 作为第一实现。

### 阶段 6：热点和策略

在三种方案中基准选择：

- 函数 invocation count；
- `asBC_JitEntry` hook；
- 显式 `as.RuntimeJIT.Compile`；
- 全模块 eager；
- profile-guided/历史热点列表。

策略至少包含：

- minimum hits；
- max function bytecode size；
- max pending tasks；
- max code memory；
- per-function disable；
- debugger/coverage/suspend exclusion；
- compile timeout/failure backoff。

### 阶段 7：可恢复 ABI 评估

只有整函数 PoC 的收益、覆盖率和维护成本得到认可后，再决定是否引入：

- `Completed/ResumeVM/Suspended/Exception`；
- PC/SP/FP continuation；
- multiple entry labels；
- VM 重新进入 Native；
- 分段 coverage/debug mapping。

这应是独立 OpenSpec change，而不是悄悄扩进 AOT provider 重构。

### 阶段 8：Raw/Parms 与产品化

后续可选择：

- 继续只提供 VMEntry，把 Runtime JIT 定位为 VM 加速器；
- 为简单、稳定 ABI 生成 RawEntry；
- 为反射安全签名生成 ParmsEntry；
- 或保持 Raw/Parms 只由 AOT provider 提供。

是否支持 Shipping 必须基于平台、安全、包体、code signing 和性能数据单独决策。

---

## 十一、最小 PoC 验收条件

### 11.1 正确性

- Runtime JIT 关闭时，所有 fixture 走 VM 且结果不变；
- Runtime JIT 开启后，目标纯计算函数按显式 BackendId 到达 MIR 或 LLVM 入口；
- 参数、返回值、branch 和 local 与 VM 一致；
- 不支持 bytecode 的函数保持完整 VM；
- 编译失败不影响当前函数执行；
- stale 编译结果不发布；
- 函数 body 修改后旧入口不可被新调用触达；
- engine shutdown 前所有 Binding 逻辑退休 exactly once；
- 两 engine 不共享 function pointer ownership、reference table 或 counters。

### 11.2 生命周期

- 编译任务取消不会 use-after-free；
- function/module discard 时后台任务不能访问已销毁对象；
- Binding reader 与 replacement 并发时旧 UserData 保持有效；
- backend/plugin stop 后不再接收新 compile；
- engine shutdown 等待或安全丢弃 pending compile；
- per-result MIR context/code arena 或 LLVM ORC resource tracker 的物理销毁发生在没有入口可执行之后。

### 11.3 性能与资源

至少记录：

- bytecode size；
- MIR 的 BytecodeToC、c2mir 和 link/codegen 时间；
- LLVM 的 IR emission、verify、ORC materialize/lookup 时间；
- publish latency；
- 首次可用时间；
- VM ns/op；
- Runtime JIT ns/op；
- StaticJIT AOT ns/op；
- break-even invocation count；
- generated code bytes；
- MIR/LLVM backend working-set 峰值；
- 多次 HotReload 后 live/retired code lease、MIR context 和 ORC tracker 增长/回收。

没有这些数据，不能仅凭微型算术函数宣布 Runtime JIT 值得产品化。

### 11.4 功能隔离

- optional plugin 未启用时，核心 Runtime 不依赖 MIR/fmt；
- unsupported platform 不编译 Runtime JIT module；
- Shipping 默认不包含/不启用 Runtime JIT；
- StaticJIT AOT provider 仍可独立工作；
- AOT exact match 优先于 Runtime compile；
- Debugger/coverage 模式按策略回退 VM。

### 11.5 建议测试层

- MIR 构建/纯函数 backend：Native Core 或 Runtime Integration；
- Binding publication/retirement：`AngelscriptTest/StaticJIT/`；
- 两 engine/stale generation：Runtime Integration；
- Editor HotReload：Editor/HotReload test；
- UASFunction route：Generator/ASFunction matrix；
- 真实 Editor 性能/内存：独立 smoke/benchmark 记录。

所有验证继续使用：

- `Tools\RunBuild.ps1`；
- `Tools\RunTests.ps1`；
- `Tools\RunTestSuite.ps1`。

---

## 十二、风险矩阵

| 风险 | 严重度 | 首期处理 |
|---|---:|---|
| VMEntry 返回被误判为函数完成 | 高 | 首期只做整函数；分段执行需新 ABI |
| stale async result 覆盖新脚本 | 高 | 完整 stable identity + generation 二次验证 |
| Binding 退休后机器码仍被调用 | 高 | reader/code lease + safe-point publication + backend-owned resource |
| MIR 共享 context 无法可靠按函数卸载 | 高 | 首期每函数 revision 独占 disposable context/code arena，不做 JIT-to-JIT |
| direct native ABI 绕过 UE 语义 | 高 | 禁用 Angelsea ABI hack，统一走现有 caller/helper |
| Debugger/Coverage 失真 | 高 | 调试/coverage 状态强制 VM，后续单独支持 |
| UObject/GC 生命周期错误 | 高 | PoC 不支持 UObject，后续 stable reference slot + 专项测试 |
| Runtime JIT 与 AOT provider 争抢 compiler | 高 | Runtime 唯一 coordinator，不允许可选插件直接替换 compiler |
| MIR/c2mir 与 UE 构建冲突 | 中 | 阶段 1 独立 build probe |
| 热点计数自身增加 VM 开销 | 中 | 首版只做三种明确触发策略；热点阈值后续单独基准 |
| 长 Editor 会话内存持续增长 | 中/高 | code lease 资源计数、per-result context/tracker 回收、后续 generation budget |
| 平台 executable-memory/code-signing 不允许 | 高 | 初始 Windows Editor allowlist，Shipping 默认关闭 |
| 第三方升级导致内部布局漂移 | 中/高 | 固定版本、patch 清单、内部 ABI tests |
| MIR 峰值代码质量低于 AOT | 中 | 以 break-even 和真实 workload benchmark 决策 |
| 可选插件扩大交付维护面 | 中 | 保持窄接口和可完全关闭边界 |

---

## 十三、明确不建议的做法

1. 不恢复 upstream JIT v1/v2 engine property。
2. 不让可选 Runtime JIT plugin 直接调用 `SetJITCompiler()` 替换 coordinator。
3. 不把 Runtime 生成函数登记进旧 `FJITDatabase` FunctionId map。
4. 不把当前 `asIScriptFunction*`、type pointer 或 UObject pointer 当成持久 code identity。
5. 不从 `Reference/angelsea` 直接编译产品依赖。
6. 不默认启用 Angelsea 的 `hack_ignore_suspend/exceptions/context_inspect`。
7. 不在第一版自己模拟全部平台 C++ ABI。
8. 不把只有 VMEntry 的 Runtime 结果冒充完整 AOT Provider entry。
9. 不在 script save 时同步阻塞 Game Thread 编译大型 MIR 函数。
10. 不在没有内存统计和 generation retirement 的情况下允许无限次 Editor 重编译。
11. 不因为简单 benchmark 变快就默认启用 Shipping Runtime JIT。
12. 不在当前 provider production route 尚未接通时并行维护第二套 Binding ownership。

---

## 十四、推荐决策

### 14.1 是否可以接入

**可以。** 当前维护分支的 delayed Binding 和安全 retirement 已经为 Runtime JIT 提供了比 upstream V2 更完整的宿主生命周期。

### 14.2 是否应该直接引入 Angelsea

**不应该原样引入。** 应以固定提交为研究/移植基线，复用算法和测试思想，重新实现与本 fork ABI、UE binding 和 engine-local route 相容的 backend。

### 14.3 是否应该替换 StaticJIT AOT

**不应该。** Runtime JIT 解决 Editor/Development 的即时性能和迭代；StaticJIT AOT 解决最终交付、完整 UE ABI、可重现和平台合规。两者应分层共存。

### 14.4 推荐的第一目标

```text
Windows Editor Development
    + optional AngelseaRuntimeJIT and AngelseaLLVMJIT plugins
    + explicit BackendId per engine: none / angelsea-mir / angelsea-llvm
    + configurable EagerSync / EagerBackground / LazyFirstCall
    + whole-function support scan
    + VMEntry only
    + unified coordinator and current Binding lifecycle
    + no native ABI hacks
    + no Shipping
```

该目标用两个不同的 Runtime backend 回答两个互补问题：

1. MIR/c2mir 在真实 UE AngelScript workload 中，是否能以较小依赖和可接受的编译/内存成本恢复 Native 性能；
2. 直接 bytecode → LLVM IR → ORC 是否能以更高依赖成本换来足够显著的优化收益。

两个后端都使用相同的 immutable bytecode snapshot、支持性分类、VM differential fixtures 和 coordinator 生命周期，但不会互相依赖，也不会在一个 engine 内形成 MIR → LLVM 的逐函数 fallback 链。若 PoC 收益不足，就不继续侵入核心 `asCContext`；若收益成立，再以独立变更评估调用桥、可恢复 VM continuation 和函数内分段 JIT。

---

## 十五、已确认的产品范围与配置

2026-08-12 已确认第一批实现范围为 **Win64 Editor/Development PoC**。Cook/Shipping 继续使用 Static AOT 或 VM，本批 OpenSpec 不包含 Game Development/Shipping 动态机器码交付。

### 15.1 一个 coordinator，每个 engine 显式单选 Runtime backend

同一进程可同时加载 MIR 与 LLVM factory，便于测试；每个 AngelScript engine 仍只选择一个 Runtime BackendId：

```text
none | angelsea-mir | angelsea-llvm
```

默认执行顺序和强制测试模式为：

```text
Auto          = exact Static AOT > selected Runtime JIT > VM
VMOnly        = VM
StaticAOTOnly = exact Static AOT > VM
RuntimeOnly   = selected Runtime JIT > VM
```

### 15.2 三种编译时机都是真实能力

```text
EagerSync       = function-ready 时同步编译，首个确定性基线
EagerBackground = function-ready 时复制 snapshot 并后台编译，完成前使用 VM
LazyFirstCall   = 第一次调用只触发一次编译，该次保持 VM，后续调用命中 Native
```

后台编译和首次调用不能把 `asIScriptFunction*` 交给 worker；coordinator 必须先生成拥有完整 bytecode、frame、control-flow、stable identity 和 revision 的不可变 snapshot。Hot Reload 后到达的旧结果必须因 revision 不匹配而丢弃，并释放对应 code lease。

### 15.3 LLVM 插件使用外部固定 SDK

`AngelseaLLVMJIT` 采用直接 bytecode → LLVM IR → ORC，不经过 C、Clang、MIR 或 typed HIR。PoC 固定 LLVM 21.1.8 Developer SDK，通过本机 `AgentConfig.ini` 的 `Paths.LLVMRoot` 提供，并通过 LLVM C API/ORC 边界降低 C++ ABI 耦合。

当前本机 LLVM 21.1.8 的 `LLVM-C.dll` 已确认导出 `LLVMOrcCreateLLJIT`、`LLVMOrcLLJITAddLLVMIRModule` 和 `LLVMOrcLLJITLookup`，但现有 Scoop 包缺少完整 Core/ORC 开发头，因此不能直接视为满足 SDK 合同。插件禁用时 SDK 缺失不影响主工程；插件启用而 SDK 不完整时必须明确构建失败，不能回退到 UE、PATH 或其他 LLVM 版本。

### 15.4 UE 边界

两个 lowering core 都不需要理解 UE。它们只处理 bytecode snapshot 和 neutral helper ABI。UE 相关工作仍然存在，但集中在很薄的 Host Adapter：engine/session 生命周期、`FScriptExecution` VMEntry、Binding/route 发布、reference slot、Hot Reload、Debugger/CodeCoverage gate 和诊断。第一版遇到 UObject、UFunction、RPC、GC、script/system/native call、suspend 或 Raw/Parms 需求时，整函数回退 VM。

---

## 十六、源码证据导航

### Angelsea

| 主题 | 路径 |
|---|---|
| 项目说明、平台、依赖、原理 | `Reference/angelsea/README.md` |
| upstream V2 JIT wrapper | `Reference/angelsea/include/angelsea/jit.hpp` |
| 热点、MIR、实验开关 | `Reference/angelsea/include/angelsea/config.hpp` |
| lazy/async/c2mir/MIR/安装 | `Reference/angelsea/src/angelsea/detail/mirjit.cpp` |
| bytecode → C、entry/fallback | `Reference/angelsea/src/angelsea/detail/bytecode2c.cpp` |
| VM/script/system helper | `Reference/angelsea/src/angelsea/detail/runtime.cpp` |
| Build 和第三方源文件清单 | `Reference/angelsea/CMakeLists.txt` |
| Angelsea 许可证 | `Reference/angelsea/LICENSE` |
| MIR 许可证 | `Reference/angelsea/vendor/mir/LICENSE` |

### AngelscriptProject

| 主题 | 路径 |
|---|---|
| 统一 JIT 接口和 Binding | `Plugins/Angelscript/Source/AngelscriptRuntime/Core/angelscript.h` |
| Binding 替换/retirement | `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_scriptfunction.cpp` |
| VMEntry 调用/完成语义 | `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_context.cpp` |
| JitEntry 发射和 VM opcode | `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_bytecode.cpp` |
| StaticJIT 生成/旧 runtime attach | `Plugins/Angelscript/Source/AngelscriptRuntime/StaticJIT/AngelscriptStaticJIT.cpp` |
| StaticJIT bytecode lowering | `Plugins/Angelscript/Source/AngelscriptRuntime/StaticJIT/AngelscriptBytecodes.cpp` |
| StaticJIT runtime helpers | `Plugins/Angelscript/Source/AngelscriptRuntime/StaticJIT/StaticJITHeader.cpp` |
| Provider ABI | `Plugins/Angelscript/Source/AngelscriptRuntime/StaticJIT/AngelscriptJITProvider.h` |
| Provider Registry | `Plugins/Angelscript/Source/AngelscriptRuntime/StaticJIT/AngelscriptJITProviderRegistry.cpp` |
| Provider Matcher | `Plugins/Angelscript/Source/AngelscriptRuntime/StaticJIT/AngelscriptJITProviderMatcher.cpp` |
| 当前 multi-provider 设计 | `openspec/changes/refactor-as-static-jit-multi-provider/design.md` |
| 当前 multi-provider 任务 | `openspec/changes/refactor-as-static-jit-multi-provider/tasks.md` |
| 统一 Static AOT / Runtime JIT coordinator | `openspec/changes/refactor-as-unified-jit-coordinator/` |
| Angelsea MIR Runtime JIT 插件 | `openspec/changes/feature-as-angelsea-runtime-jit-plugin/` |
| Angelsea LLVM Runtime JIT 插件 | `openspec/changes/feature-as-angelsea-llvm-jit-plugin/` |
| Typed Semantic HIR → C++ Static AOT | `openspec/changes/feature-as-typed-semantic-aot/` |
| StaticJIT 知识文档 | `Documents/Knowledges/ZH/RT_StaticJIT.md` |
| Daslang/Angelsea 对比 | `Documents/Knowledges/ZH/Diff_DaslangAngelseaJIT.md` |

---

## 十七、最终判断

Angelsea 证明了 AngelScript bytecode 可以通过轻量 C/MIR 后端在运行期生成有效机器码，也提供了很有价值的热点、异步、JIT-to-JIT 和多 entry fallback 设计。

AngelscriptProject 已经拥有接入 Runtime JIT 所需的函数就绪通知、延迟 Binding 发布、完整入口族、稳定身份和安全 retirement 基础，但当前执行 ABI仍是整函数完成模型，不能直接接受 Angelsea 的 PC/SP continuation。项目还拥有 Angelsea 不具备的 UE-aware binding、UASFunction、反射、RPC、GC、HotReload 和 provider generation 约束。

因此推荐路线不是“把 Angelsea 装进去”，而是：

```text
完成/复用 multi-provider 的 Binding、stable identity、route 和 retirement 基础
    ↓
建立每 engine 唯一的 FAngelscriptJITCoordinator
    ├── exact Static AOT provider
    ├── selected Runtime backend
    │   ├── Angelsea BytecodeToC + c2mir/MIR
    │   └── direct bytecode → LLVM IR → ORC
    └── VM fallback
    ↓
先做整函数、VMEntry-only、Win64 Editor/Development PoC
    ↓
用同一 VM differential corpus 和真实 workload 比较正确性、编译时延、稳态性能、代码大小与内存
    ↓
再以独立变更决定调用桥、ResumeVM/多 entry、平台扩展和 Shipping
```

这是技术上可行、与现有 multi-provider 重构兼容、同时最能控制 UE 集成风险的方向。
