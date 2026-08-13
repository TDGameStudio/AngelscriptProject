# AS_RuntimePerformanceOptimizationResearch — AngelScript 底层性能优化难度与路线研究

> **所属前缀**：AS_（AngelScript 引擎内核）
>
> **研究范围**：本项目 AngelScript fork 的解释器、字节码优化器、脚本函数调用、AS/C++ 原生调用边界、UFunction 反射 fallback、StaticJIT 与相关缓存/调试兼容面。
>
> **分析日期**：2026-08-12
>
> **参考基线**：`Plugins/Angelscript` 已提交 HEAD `974e2811c76b5d80b0f2dc6f4c7a28955765bf80`；工作区同时存在 `refactor-as-static-jit-multi-provider` 相关未提交实现，本文会明确区分两者。
>
> **变更边界**：本文只记录研究，不实现优化、不新增 OpenSpec、不承诺具体性能倍数。用户已明确批准本次低风险文档改动跳过 OpenSpec。

---

## 一、结论摘要

“优化 AS 底层”不是单一难度，至少要分成三个量级：

1. **让本项目 UE 游戏中的 AngelScript 实际运行更快**：中等到中高难度，有现实收益空间。
2. **让纯解释器在 tight loop、小函数调用等负载上追近 Daslang Fusion**：高难度，需要改调用路径和字节码优化器，不是替换一个 dispatcher 技巧就够。
3. **把 AS 整体改造成 Daslang 的 SimNode/Fusion 或引入第二套运行时 JIT**：极高难度，会冲击 bytecode、缓存、调试器、热重载、StaticJIT 和 SDK 兼容，不建议作为当前方向。

推荐采用“外科手术式”路线：

```text
建立可信基准
  → 处理当前 JIT Binding 热路径
  → 优化 AS/C++ 调用边界
  → 加少量有数据支持的 superinstruction
  → 最后才考虑 leaf-call fast path
```

如果目标是最终 packaged/cooked 性能，应继续优先提升 StaticJIT 覆盖、路由和生成代码质量；如果目标是 Editor/PIE 解释体验或无 JIT 平台底线性能，才应把更多投入放在解释器本身。

最重要的判断是：

> **当前最现实的突破口是 JIT Binding 调用热路径和 AS → C++/UE 调用边界，而不是先重写字节码 VM。**

---

## 二、先定义“底层性能优化”的目标

同一句“AS 太慢”，可能指完全不同的成本层。优化前必须先确认时间落在哪一层：

| 性能层 | 典型成本 | 主要运行环境 | 合适的优化方向 |
| --- | --- | --- | --- |
| 字节码解释 | opcode fetch/dispatch、frame slot 读写、分支 | Editor、PIE、无 JIT 平台 | superinstruction、dispatcher、局部优化 |
| 脚本调用 | call state、frame、栈对齐、local 初始化 | VM 小函数密集负载 | leaf-call fast path、JIT binding 快路径 |
| AS → C++ | 参数提取、`void**` 组装、caller trampoline | 游戏逻辑调用 UE API | 预生成 call shape、direct native route |
| 反射调用 | `ProcessEvent`、`FFrame`、property copy | 无直接 native 地址的 UFunction | cached invoke、扩大安全 route 覆盖 |
| UObject/容器工作 | 查找、分配、复制、GC、World/RPC | 真实 UE gameplay | 算法、分配、API 使用方式、route |
| StaticJIT | bytecode → C++ lowering、provider、route | Development/Shipping/cooked | 覆盖率、生成代码、直接调用、缓存 |
| 编译/热重载 | preprocess、compile、ClassGenerator、reload | Editor | 另一套启动/编译性能课题 |

本文主要研究前六层，不把脚本编译速度、Editor 启动速度或热重载延迟混入运行时结论。

---

## 三、当前 AS VM 已经具备的优化基础

### 3.1 不是朴素栈式 VM

当前解释器入口是：

- `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_context.cpp:1671`
- `asCContext::ExecuteNext()`

它已经做了几项重要优化：

- 将 program counter、stack pointer、frame pointer 缓存在局部变量 `l_bc`、`l_sp`、`l_fp`；
- 使用按 opcode 连续排列的大型 `switch`，便于编译器生成 jump table；
- 真实解释循环有 `213` 个 `case asBC_*`；
- 值通常直接位于 frame slot，算术指令不是单纯的“push/push/add/pop”栈式序列；
- 常用值通过 value/object registers 与 frame slots 协作传递。

例如 `ADDi` 是 typed 三地址指令，概念上接近：

```cpp
case asBC_ADDi:
    *(int*)(fp - dst) = *(int*)(fp - lhs) + *(int*)(fp - rhs);
```

常量运算还有 `ADDIi`、`SUBIi`、`MULIi` 等专门形式。这说明最明显的 typed arithmetic、寄存器缓存和常量专门化并不是空白。

### 3.2 已有 peephole superinstruction

字节码局部优化入口为：

- `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_bytecode.cpp:619`
- `asCByteCode::OptimizeLocally()`

本项目在 Engine 初始化时显式打开 `asEP_OPTIMIZE_BYTECODE`：

- `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.cpp:1254`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.cpp:2318`

现有 optimizer 已覆盖多类缩短和融合：

- 常量加载 + 整数/浮点运算 → `ADDIi`、`SUBIi`、`MULIi` 等；
- `SetV4 + CMPi/CMPf/CMPu` → immediate compare；
- `PGA + RDSPtr` → `PshGPtr`；
- global load + read → `LdGRdR4`；
- `LDV + INCi/DECi` → `IncVi/DecVi`；
- `ClrHi + JZ/JNZ` → `JLowZ/JLowNZ`；
- 多种 copy、reference、push 和无用临时值消除。

所以 AS 已经采用了 superinstruction 思想。进一步收益不能主要靠继续猜测普通的二指令组合，而应来自真实 opcode sequence histogram。

### 3.3 StaticJIT 与字节码已经深度绑定

当前 opcode 最大值在：

- `Plugins/Angelscript/Source/AngelscriptRuntime/Core/angelscript.h:1817`
- `asBC_MAXBYTECODE = 212`

解释器有 213 个 opcode case（编号 0～212）。StaticJIT 在：

- `Plugins/Angelscript/Source/AngelscriptRuntime/StaticJIT/AngelscriptBytecodes.cpp`

维护 212 个 `IMPL_BYTECODE_BEGIN(asBC_*)` lowering；特殊的 `asBC_JitEntry` 不走普通 lowering。

这意味着新增一个正式 superinstruction 不能只增加一个 VM `case`，还必须考虑 StaticJIT 如何理解、生成和验证该指令。

### 3.4 易得的普遍 2× 空间已经不存在

由于已有：

- typed 三地址 opcode；
- immediate opcode；
- 局部 peephole；
- 有序 switch；
- VM registers 本地缓存；
- 模板原生 caller；
- cooked StaticJIT；

因此，依靠一个小技巧让所有解释负载普遍快 2 倍并不现实。

更合理的预期是：

- 特定 tight loop 或 leaf-call microbenchmark 可能获得明显收益；
- AS → UE API 密集负载可能从 route/caller 优化中获得更高产品收益；
- 整个游戏帧能提升多少，取决于 VM/调用桥在真实 frame profile 中的占比；
- cooked 性能上限更应通过 StaticJIT，而不是强行让解释器承担全部目标。

---

## 四、现有性能数据与证据边界

### 4.1 Runtime microbenchmark

当前工作区有三组 runtime microbenchmark。每组配置为：

- warmup：1 次；
- measurement：3 次；
- 每次 measurement：10,000 benchmark iteration；
- 下表使用 median 换算每 iteration 时间。

| 工作负载 | AS | Native C++ | AS / Native |
| --- | ---: | ---: | ---: |
| ScriptSelf.Empty | 44.98 ns | 0.12 ns | 不采用；C++ no-op 很可能被优化消除 |
| ScriptSelf.Arithmetic | 237.06 ns | 0.37 ns | 不采用；C++ helper 可被内联/常量传播 |
| NativeFunction.Scalar | 459.76 ns | 48.36 ns | 9.51× |
| NativeFunction.Container | 897.19 ns | 266.62 ns | 3.36× |
| NativeProperty.Scalar | 467.56 ns | 60.65 ns | 7.71× |
| NativeProperty.Container | 852.61 ns | 195.82 ns | 4.35× |

样本来源：

- `Saved/Automation/AngelscriptPerformance/RuntimeMicrobenchmark_ScriptSelf/Metrics/metrics.json`
- `Saved/Automation/AngelscriptPerformance/RuntimeMicrobenchmark_NativeFunction/Metrics/metrics.json`
- `Saved/Automation/AngelscriptPerformance/RuntimeMicrobenchmark_NativeProperty/Metrics/metrics.json`
- `Plugins/Angelscript/Source/AngelscriptTest/Performance/AngelscriptRuntimeMicrobenchmarkTests.cpp`

这些数据不能直接解释成“单次调用延迟”。例如 `NativeFunction.Scalar` 的一轮包含多个静态/成员函数、getter/setter、字符串和数值操作。

它们可以支持三项较稳妥的判断：

1. 越接近极小函数和标量操作，VM/调用桥固定成本越明显。
2. 容器工作变重后，AS/native 相对倍数缩小，说明宿主容器操作开始淹没固定成本。
3. C++ no-op 和简单 arithmetic baseline 受内联、常量传播、死代码消除影响，不能作为直接调用 ABI 的可靠参照。

### 4.2 Reflective fallback benchmark

现有反射 benchmark 将 ProcessEvent、FFrame+Invoke 和 Cached FFrame+Invoke 分开测量：

| 调用形状 | ProcessEvent | Cached FFrame+Invoke | Dispatch 提升 |
| --- | ---: | ---: | ---: |
| StaticNoOp | 149.61 ns | 21.47 ns | 6.97× |
| MemberNoOp | 131.89 ns | 21.76 ns | 6.06× |
| StaticAdd | 193.01 ns | 46.97 ns | 4.11× |
| GetInt32 | 142.27 ns | 24.73 ns | 5.75× |
| GetArray | 200.67 ns | 66.52 ns | 3.02× |
| SetMap | 271.43 ns | 133.70 ns | 2.03× |

来源：

- `Plugins/Angelscript/Source/AngelscriptTest/Performance/AngelscriptReflectiveFallbackBenchmarkTests.cpp`
- `Saved/Automation/AngelscriptPerformance/ReflectiveFallback_Benchmark/Metrics/metrics.json`

这组数据提供了一个比“改 dispatcher”更直接的信号：

> 扩大安全 native route 覆盖、预计算参数调用形状、减少 reflective fallback，可能比重写 opcode dispatcher 更容易产生产品级收益。

但表中的 2～7 倍只是反射 dispatch 层自身的提升，不能外推成整个脚本函数或整个游戏 frame 的提升。

### 4.3 当前 benchmark 的证据缺口

现有 `metrics.json` 没有记录：

- CPU 型号、核心 affinity、频率状态；
- Development/Shipping/Test 配置；
- 插件 commit 和 dirty 状态；
- bytecode optimization 状态；
- selected native/reflective route；
- StaticJIT VM/Raw/Parms entry 状态；
- instruction callback、debugger、coverage 状态；
- 每个 workload 的 opcode、script call、system call 数量。

因此，当前数据不能回答：

- 8 月 12 日样本对应已提交 HEAD 还是当前 dirty JIT 实现；
- 某次调用实际走 NativeRuntimeLinked、NativeModuleFunctionAddress 还是 ReflectiveFallback；
- 当前 JIT Binding lease 是否已经影响 ScriptSelf.Empty；
- 单纯 dispatcher 占总时间多少；
- StaticJIT 与 VM 在完全等价 workload 下的差距。

建立这些元数据是所有底层性能实施的 P0 前置条件。

---

## 五、当前最值得优先核实的热点

### 5.1 当前未提交 JIT Binding 生命周期锁

必须区分两份代码状态。

已提交 HEAD `974e2811...` 的 `CallScriptFunction()` 直接读取：

```cpp
auto* jitFunction = func->jitFunction;
```

当前未提交多 Provider StaticJIT 实现将入口统一成完整 `asSJITFunctionBinding`，普通调用会执行：

```text
AcquireJITBindingForExecution()
  → lock jitBindingMutex
  → active readers +1
  → copy complete binding

VMEntry == nullptr
  → ReleaseJITBindingAfterExecution()
  → lock jitBindingMutex
  → active readers -1
```

对应代码：

- `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_context.cpp:1473`
- `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_scriptfunction.cpp:1674`
- `Plugins/Angelscript/Source/AngelscriptRuntime/StaticJIT/AngelscriptJITExecutionContext.cpp:5`

结果是：即使函数没有 JIT entry、最终走普通解释器，一次小脚本调用也可能支付两次 uncontended mutex 进入/退出。

这不是可以直接删除的冗余。当前 OpenSpec 要求：

- provider generation 可替换；
- 在途调用继续持有旧 binding；
- retired binding 不得提前释放；
- release 恰好一次；
- thread-safe/re-entrant 调用刷新时不得悬空。

相关规范：

- `openspec/changes/refactor-as-static-jit-multi-provider/specs/uasfunction-dispatch-matrix-and-jit-paths/spec.md`
- `openspec/changes/refactor-as-static-jit-multi-provider/specs/as-jit-lifecycle-interface/spec.md`

正确研究方向包括：

- 从未发布过 JIT binding 的函数是否可走无锁 fast sentinel；
- 是否只有确实拥有动态 binding 的函数才获取 execution lease；
- Editor 热重载 profile 是否可使用 immutable atomic snapshot + generation/epoch；
- cooked immutable profile 完整验证后是否可直接使用稳定入口；
- binding publication 若完全限制在 Engine safe point，普通 VM 调用能否避免 refresh 生命周期成本。

这项属于 **P0、高语义风险**。应在当前多 Provider 工作合并前建立 HEAD/dirty A/B 门槛，而不是合并后再定位 leaf-call 退化。

### 5.2 普通脚本函数的完整 frame 建立

没有 JIT entry 时，`CallScriptFunction()` 还要处理：

1. recursion/stack overflow；
2. `PushCallState()`；
3. current function 和 program pointer；
4. stack block 容量；
5. 16 字节对齐；
6. 必要时 `memmove` 参数；
7. heap object locals 清零；
8. local variable space 分配；
9. `RET` 时完整恢复；
10. 异常、suspend、调试、GC、引用和 return-on-stack 语义。

入口：

- `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_context.cpp:1473`
- `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_context.cpp:1544`

这解释了为何“循环中调用成千上万个极小 helper”会放大固定成本，也说明 leaf-call fast path 的难点不是少写几条栈指令，而是保持完整语义。

### 5.3 原生调用桥的运行时参数组装

本 fork 已用模板生成的 `FunctionCaller` / `MethodCaller` 替换传统通用 native ABI 桥的主要路径：

- `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_callfunc.cpp:447`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Core/FunctionCallers.h:188`

这已经优于通用 FFI。但是每次 `CALLSYS` 仍会在 `CallFunctionCaller()` 中：

- 判断 object argument；
- 判断 metadata；
- 计算 return address；
- 遍历 `parameterOffsets` / `parameterTypes`；
- 在栈上组装 `void* FunctionArgs[32]`；
- 区分 object/reference/primitive/question；
- 切换 TLS active function；
- 最后才进入模板 trampoline。

入口：

- `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_context.cpp:5456`

这里有三层可研究优化：

1. bind/compile 阶段预计算 parameter extraction plan；
2. 为高频简单签名生成不遍历 `parameterTypes` 的 caller shape；
3. 扩大安全 direct native route 覆盖，减少 reflective fallback。

但必须保留 UE 语义边界：

- RPC/Net UFunction 必须继续走 Unreal RPC routing；
- WorldContext 需要注入和线程语义；
- out/ref return 需要正确 writeback；
- `TArray/TSet/TMap` 与非平凡结构需要构造/析构；
- interface/delegate/field path 有额外表示；
- virtual override 不能被静态父类入口绕过。

当前安全分类位于：

- `Plugins/Angelscript/Source/AngelscriptUHTTool/AngelscriptFunctionBindingPolicy.cs:54`

### 5.4 每指令可观测性留在热循环中

当前 `ExecuteNext()` 每条指令都会：

- 检查 `m_instructionCallback != nullptr`；
- 构造 `asSInstructionCallbackScope`；
- 检查 `m_status`；
- 启用时发送 before/after callback。

callback 为空时不会真正通知，但结构性分支仍存在。

可以研究：

```text
ExecuteNextFast()
ExecuteNextObserved()
```

或：

```cpp
ExecuteNextImpl<false>();
ExecuteNextImpl<true>();
```

但 `ExecuteNext()` 从约 1671 行延伸到约 4523 行，含 213 个 opcode case。复制两份可能导致：

- 二进制和链接时间增加；
- dispatcher text size 增长；
- I-cache 变差；
- 两条语义路径漂移；
- 异常、suspend 和 callback 安装/清除时机更难保持一致。

现代编译器也可能已将 callback 为空路径压缩成一个高度可预测的分支。因此，这项优化必须先看 Release 汇编和 CPU profile，不能只凭源码外观判定。

### 5.5 普通循环仍由多个 opcode 驱动

普通 `for` 的比较、条件跳转、自增和循环体仍是独立 opcode：

- `JMP`：`as_context.cpp:1888`
- `JZ`：`as_context.cpp:1896`
- `JNZ`：`as_context.cpp:1904`
- `CMPi`：`as_context.cpp:2341`
- `CMPIi`：`as_context.cpp:2354`

`OptimizeLocally()` 已留下一个准确的 TODO：

> 将变量自增、比较和跳转合并成一个 opcode，可能显著改善循环。

位置：

- `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_bytecode.cpp:634`

这是最接近 Daslang Fusion 核心收益、同时又不必整体改执行模型的候选：减少每轮 dispatcher 次数，而不是让单条 `ADD` 再快一点。

---

## 六、优化方向难度矩阵

下表难度按“可以合入产品、兼容调试/热重载/StaticJIT/缓存并有测试”评估，而不是临时 prototype 难度。

| 优化方向 | 主要解决什么 | 难度 | 风险 | 优先级 |
| --- | --- | ---: | ---: | ---: |
| 完善 benchmark 和 route 元数据 | 防止优化错层、误判收益 | 低～中 | 低 | P0 |
| 当前 JIT Binding 无绑定快路径 | 小脚本调用、UASFunction dispatch 固定成本 | 中～高 | 高，并发/生命周期 | P0 |
| 预生成 native call shape | 高频 AS → C++ 标量调用 | 中～高 | 中，ABI/参数语义 | P1 |
| 扩大安全 direct native route 覆盖 | 降低 reflective fallback 比例 | 中～高 | 中～高，UE RPC/WorldContext | P1 |
| 无观察者解释循环 | 每条 opcode 的观察分支/RAII 成本 | 中 | 中，代码体积/调试一致性 | P1，先 profile |
| 少量 measured superinstruction | tight loop、局部算术/比较/写回 | 高 | 高，bytecode/cache/JIT | P1/P2 |
| Leaf-call fast path | 大量极小脚本 helper | 高～极高 | 很高，frame/异常/GC/JIT lease | P2 |
| computed goto/threaded interpreter | opcode dispatch 本身 | 高 | 平台/维护风险高，收益不确定 | P3 |
| 结构化 loop opcode | 接近 Daslang loop node 的收益 | 极高 | 编译器/调试/异常语义 | P3 |
| SimNode/Fusion 双执行模型 | 全面追随 Daslang | 极高 | 架构级 | 不建议 |
| 运行时 LLVM JIT | 动态机器码 | 极高 | 平台、调试、部署、DLL | 不建议作为首选 |

---

## 七、三条可选路线

### 7.1 路线 A：外科手术式优化（推荐）

目标是不改变核心执行模型，优先减少真实热点：

1. 完善 benchmark 元数据和隔离 workload；
2. A/B 当前 JIT Binding lease 相对 committed HEAD 的退化；
3. 设计无 binding VM 快路径与 immutable cooked 快路径；
4. 统计实际 native/reflective route 分布；
5. 预生成高频 native caller shape；
6. 通过 sequence histogram 选择 1～3 个 superinstruction；
7. 再判断 instruction callback 快循环是否值得做。

优点：

- 不破坏现有 bytecode/StaticJIT 架构；
- 可分别改善 Editor VM 和 cooked route；
- 每一步都可以独立 A/B；
- 失败容易回退；
- 与当前多 Provider StaticJIT 方向相容。

这是当前收益/风险比最高的路线。

### 7.2 路线 B：解释器现代化

目标是明显提升纯 VM，尤其 tight loop 和 helper-heavy workload：

- loop-control superinstruction；
- leaf-call fast path；
- 无观察者 dispatcher；
- 更深入的 bytecode optimizer；
- 可能引入基本块级局部优化，不局限于相邻两条 peephole。

代价：

- compiler/runtime/debug/cache/StaticJIT 同时变更；
- 测试矩阵大；
- 每次上游 backport 更难；
- code size 和维护复杂度上升。

只有路线 A 的 profile 证明 VM 本身仍占主要时间后，才值得进入路线 B。

### 7.3 路线 C：Daslang 风格 Fusion 或动态 JIT

可能包含：

- 第二套 SimNode/typed tree IR；
- 运行时 Fusion；
- 结构化 loop node；
- LLVM ORC JIT；
- bytecode → SSA/IR → machine code。

这会形成：

```text
bytecode VM
+ node/LLVM runtime
+ 现有 StaticJIT
```

随后需要维护三套执行语义的：

- 调试和异常映射；
- hot reload；
- UObject/GC/WorldContext；
- native binding ABI；
- cache；
- provider 生命周期；
- 平台部署。

对当前成熟插件而言，收益/风险比不合理。除非未来明确把纯解释性能设为核心产品竞争力，并投入长期专职人员，否则不建议。

---

## 八、重点候选的设计边界

### 8.1 Benchmark 与低开销观测

至少补齐下列隔离负载：

```text
纯循环，无 helper
纯循环 + Empty helper
纯循环 + Arithmetic helper
range sum
array scan
AS → direct native
AS → cached reflective
AS → ProcessEvent
VM
StaticJIT
```

每份 artifact 应记录：

- commit、dirty digest；
- UE target/configuration；
- CPU、affinity、频率策略；
- bytecode optimization 状态；
- debugger/callback/coverage 状态；
- selected binding route；
- JIT VM/Raw/Parms entry 状态；
- workload 内的 script/system call 数量；
- opcode count 和 top sequence；
- median/min/max 与 checksum。

第一项关键对比应是：

```text
已提交 HEAD
vs
当前多 Provider JIT dirty implementation
```

用它直接回答 binding lease 对 empty leaf call 的影响。

### 8.2 Measured superinstruction

不建议复制 Daslang Fusion 的组合笛卡尔积。更适合本项目的流程：

1. 采集 top opcode 2-gram/3-gram；
2. 结合 retired instructions 和 branch misses；
3. 选择覆盖率最高且语义稳定的 1～3 个模式；
4. 保留旧指令路径，支持 A/B；
5. 同步 VM、optimizer、serializer/cache、StaticJIT、debugger 和测试。

首个候选：

```text
increment local
+ compare immediate/local
+ conditional backward jump
```

后续候选可包括：

```text
local load + arithmetic + local store
property load + compare + branch
array iterator advance + bounds check + branch
```

新增 opcode 会波及：

- opcode enum 与 `asBCInfo`；
- instruction type/size；
- compiler emission；
- `OptimizeLocally()`；
- `ExecuteNext()`；
- bytecode save/restore；
- function artifact stream；
- Cache V2 execution codec；
- StaticJIT lowering；
- disassembly/diagnostics；
- debugger、coverage、source/PC 映射；
- compiler/runtime/StaticJIT/cache 测试。

相关版本入口：

- `ThirdParty/angelscript/source/as_restore.cpp:324`：module bytecode stream；
- `ThirdParty/angelscript/source/as_restore.cpp:330`：function artifact stream；
- `Cache/AngelscriptFunctionArtifactCodec.h:42`：Cache execution codec。

### 8.3 Leaf-call fast path

可以借鉴 Daslang fastcall 的资格判定，但不照搬 SimNode 实现。候选条件可能包括：

- 非虚、非接口、非 imported；
- 无 object local；
- 无 try/catch；
- 不允许 suspend/yield；
- 不导出 local 地址；
- 参数和返回值为简单 ABI；
- frame 固定且很小；
- 不启用 instruction callback/debug stepping/coverage；
- binding generation 在调用期间可安全固定；
- recursion/stack overflow 仍有等价保护。

必须证明：

- 栈回溯正确；
- exception function/line 正确；
- 热重载后不调用旧函数；
- current function 和 TLS active function 正确；
- GC/析构语义不变；
- JIT provider 刷新期间不悬空；
- VM/StaticJIT 返回值和异常行为等价。

这项应放在 measured superinstruction 和 JIT lease 之后。

### 8.4 Native call shape

可以分三层推进：

1. **参数提取计划**：把 object/ref/primitive/question 等判断预计算成紧凑 descriptor。
2. **常见签名专用 stub**：例如零参数、一个 `int32`、两个浮点值、一个 UObject 指针。
3. **UHT route 扩展**：按实际热点支持更多安全 ABI，不按类型清单盲目扩张。

验收时必须分别统计：

- NativeRuntimeLinked；
- NativeModuleFunctionAddress；
- ReflectiveFallback；
- RPC/Net 强制 fallback；
- WorldContext/out/ref/container 等拒绝原因。

只有实际 route 被记录，benchmark 才能解释性能变化来自哪里。

---

## 九、粗略工程量

以下按“一名已经熟悉该 fork 的工程师”，包含设计、实现、自动化回归和基本性能验证估算，不是排期承诺：

| 阶段 | 内容 | 粗略工程量 |
| --- | --- | ---: |
| Phase 0 | benchmark 元数据、隔离基准、route/opcode 观测 | 1～2 周 |
| Phase 1A | JIT Binding 热路径 A/B、无绑定/immutable 快路径设计 | 2～5 周 |
| Phase 1B | native caller shape、route 统计与一批安全签名 | 4～8 周 |
| Phase 2A | 1～3 条 measured superinstruction | 4～8 周 |
| Phase 2B | 无观察者 dispatcher prototype 与验证 | 2～4 周 |
| Phase 3 | 严格资格的 leaf-call fast path | 1～3 个月 |
| Phase 4 | 结构化 loop/basic-block interpreter | 3～6 个月 |
| 全 VM/Fusion/动态 JIT 重构 | 第二执行模型及全套集成 | 6～12 个月以上，通常需要多人 |

路线 A 是可分阶段落地的中型优化项目；追求 Daslang Fusion 级执行模型则是长期底层工程。

---

## 十、验证矩阵

### 10.1 性能证据

| 维度 | 必须记录的内容 |
| --- | --- |
| 构建身份 | commit、dirty digest、UE target、configuration |
| 执行模式 | VM / StaticJIT VMEntry / RawEntry / ParmsEntry |
| 绑定 route | NativeRuntimeLinked / NativeModuleFunctionAddress / ReflectiveFallback |
| 可观测状态 | debugger、instruction callback、coverage、line callback |
| VM 数据 | opcode count、top opcode、top 2/3-gram、script/system call count |
| CPU 数据 | ns/op、instructions、branches、branch misses、L1I/LLC misses |
| 代码规模 | bytecode bytes、generated native bytes、dispatcher text size |
| 场景 | leaf call、range loop、array scan、native scalar、container、UObject/RPC |

每项优化至少要有：

```text
原实现结果
新实现结果
关闭优化后的回退结果
正确性 checksum
相关自动化测试
性能噪声区间
```

### 10.2 正确性与兼容性

涉及 opcode、frame 或调用 ABI 的改动至少应覆盖：

- AngelScript SDK Compiler/Runtime；
- StaticJIT；
- Cache restore；
- Debug/instruction callback；
- HotReload；
- ASFunction/UFunction dispatch；
- 异常、GC、引用和 return-on-stack；
- virtual/interface dispatch；
- thread-safe/re-entrant 调用；
- RPC/WorldContext/fallback 边界；
- VM 与 StaticJIT 行为等价。

不要以“benchmark 更快且 checksum 相同”代替这些语义验证。

---

## 十一、不建议优先做的方向

### 11.1 不先做 computed goto

原因：

- Windows/MSVC 缺少 GNU computed goto 的同等通用支持；
- 当前 switch 已按连续 opcode 排列，编译器可生成 jump table；
- 真正差距更可能来自每个源级操作需要的 dispatcher 次数，而不是单次 switch 本身；
- 平台分叉和维护成本高；
- 必须先有硬件计数器证据证明 branch dispatch 是主要瓶颈。

### 11.2 不整体替换成 SimNode/Fusion

这会同时冲击：

- bytecode cache/序列化；
- StaticJIT 输入；
- debugger、coverage、PC/source 映射；
- 热重载和函数替换；
- AngelScript SDK 兼容；
- 现有自动化测试与 fork 维护边界。

Daslang 的性能来自前端、SimNode、Fusion、fastcall、C++ interop 和运行时布局的一整套协同，不是可以单独移植的小组件。

### 11.3 不为解释器优化优先引入 LLVM

LLVM 解决的是运行时生成机器码，不会自动改善现有 bytecode dispatcher。引入 LLVM 还会增加：

- DLL/部署体积；
- 平台构建；
- 符号和调试映射；
- 热重载和失效；
- UObject/GC/WorldContext ABI；
- 与现有 StaticJIT 的职责重叠。

本项目已有 StaticJIT。除非有明确的动态代码生成需求，继续完善 StaticJIT 更符合当前架构。

---

## 十二、推荐实施优先级

如果未来正式启动性能优化，建议按以下顺序推进：

1. **测清当前多 Provider JIT Binding 的调用热路径锁成本。**
2. **为 benchmark 补齐 commit/config/route/JIT/debug 元数据。**
3. **统计 NativeRuntimeLinked、NativeModuleFunctionAddress、ReflectiveFallback 的实际命中率和热点。**
4. **为简单高频 native 签名研究预生成调用形状。**
5. **根据 opcode sequence histogram，试验一个 `increment + compare + branch` loop superinstruction。**
6. **profile 证明 callback null-check 显著后，再拆无观察者 VM loop。**
7. **只有 helper-heavy workload 仍是产品瓶颈时，才投入 leaf-call fast path。**
8. **不优先重写成 SimNode，不为了本课题优先引入 LLVM。**

最终可以概括为：

> 优化本项目 AS 的实际性能是可做且值得做的中高难项目；把 AS 解释器追成 Daslang Fusion 则是高难长期工程。现阶段应先优化生命周期和调用边界，再用真实 profile 决定是否深入改 VM。

---

## 十三、相关资料

### 本知识库

- `Documents/Knowledges/ZH/AS_VirtualMachine.md`
- `Documents/Knowledges/ZH/AS_ByteCode.md`
- `Documents/Knowledges/ZH/AS_CallingConventions.md`
- `Documents/Knowledges/ZH/Type_FunctionCaller.md`
- `Documents/Knowledges/ZH/RT_StaticJIT.md`
- `Documents/Knowledges/ZH/AS_ForkDifferences.md`
- `Documents/Knowledges/ZH/Diff_DaslangAngelScriptInterpreterPerformance.md`
- `Documents/Knowledges/ZH/Diff_DaslangAngelseaJIT.md`

### 核心源码

- `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_context.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_bytecode.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_scriptfunction.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_callfunc.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Core/FunctionCallers.h`
- `Plugins/Angelscript/Source/AngelscriptRuntime/StaticJIT/AngelscriptBytecodes.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Cache/AngelscriptFunctionArtifactCodec.h`
- `Plugins/Angelscript/Source/AngelscriptUHTTool/AngelscriptFunctionBindingPolicy.cs`

### 基准源码与产物

- `Plugins/Angelscript/Source/AngelscriptTest/Performance/AngelscriptRuntimeMicrobenchmarkTests.cpp`
- `Plugins/Angelscript/Source/AngelscriptTest/Performance/AngelscriptReflectiveFallbackBenchmarkTests.cpp`
- `Saved/Automation/AngelscriptPerformance/RuntimeMicrobenchmark_ScriptSelf/Metrics/metrics.json`
- `Saved/Automation/AngelscriptPerformance/RuntimeMicrobenchmark_NativeFunction/Metrics/metrics.json`
- `Saved/Automation/AngelscriptPerformance/RuntimeMicrobenchmark_NativeProperty/Metrics/metrics.json`
- `Saved/Automation/AngelscriptPerformance/ReflectiveFallback_Benchmark/Metrics/metrics.json`
