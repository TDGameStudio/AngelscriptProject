# Diff_DaslangAngelScriptInterpreterPerformance — Daslang 解释器性能原理与本项目 AngelScript 对比

> **所属前缀**：Diff_（外部参考实现差异分析）
>
> **研究范围**：Daslang（原 daScript）Release 解释器的 SimNode、Fusion、结构化循环、fastcall、C++ interop，以及本项目 AngelScript fork 的字节码 VM、脚本调用、原生调用和 StaticJIT。
>
> **分析日期**：2026-08-12
>
> **参考版本**：
> - `Reference/daScript`：`ae21253fea2b8184f81c00013f2684c98c31174d`
> - `Plugins/Angelscript`：`974e2811c76b5d80b0f2dc6f4c7a28955765bf80`（工作区另有未提交改动，本文只读取相关实现）
>
> **结论边界**：本文已经完成源码级架构对比，但尚未在同一台机器上用语义等价负载执行 Daslang 与本项目 AS 的横向基准。因此，“哪类负载大概率更快”属于有实现依据的架构判断，不是最终倍数结论。

---

## 一、结论摘要

Daslang 的解释器性能强，**不是因为“AST 解释天然比字节码快”**，而是因为它把普通树解释器做成了一个高度专门化的执行系统：

1. 控制流不是完全拆碎的。`for range`、数组遍历等由专门的 C++ SimNode 执行，循环条件、自增和指针推进留在宿主 C++ 循环中。
2. Release 默认启用 Fusion。它把“运算 + 操作数来源 + 部分写回/调用”融合成类型和形状都固定的 super-node，显著减少虚调用、子节点遍历和中间值搬运。
3. 小型叶子函数可走 `fastcall`，不建立完整脚本栈帧。
4. 节点在创建时已经知道类型、局部变量偏移、参数序号和字段偏移，运行时不再反复解码通用 opcode 和操作数格式。
5. C++ extern 绑定使用模板实例化的调用节点，参数按静态签名直接求值并调用函数指针；常见路径不经过通用 FFI。
6. `vec4f`、typed `evalInt/evalFloat/...` 和可用时的 `vectorcall` 提供统一的 128 位 workhorse ABI；这有利于标量、指针和向量值共享调用通道，但不代表所有标量代码都会自动 SIMD 化。
7. 构建完成后会重新 relocate SimNode，把代码节点复制到新的线性分配器中，改善执行结构的紧凑性。

本项目 AS 解释器也不是“最朴素的栈 VM”：

- 它使用紧凑线性 bytecode 和中心 `switch`；
- 算术指令已经是带目标、左值、右值的 typed 三地址操作；
- 编译器会把常见指令序列替换成 `ADDIi`、`PshGPtr`、`LdGRdR4` 等专用 opcode；
- Hazelight fork 的 `FunctionCaller` 已经用模板桥替换传统平台汇编/通用原生调用器；
- packaged/cooked 性能目标还可以交给现有 StaticJIT，而不必始终依赖解释器。

但是，纯解释执行时，本项目 AS 仍有三个明显差距：

1. 普通循环每轮仍要分派比较、条件跳转、自增和循环体 bytecode；Daslang 的结构化循环节点把其中大部分留在一个 C++ 循环内。
2. AS 的 superinstruction 是固定 opcode 集合和局部 peephole；Daslang Fusion 覆盖运算、源位置、字段/数组/表访问、条件、写回和调用等更广的组合。
3. AS 的解释型脚本调用要切换完整 VM 调用状态，并且当前 JIT Binding 生命周期实现会在每次脚本调用的 acquire/release 上进入互斥锁；Daslang 满足条件的小函数可直接 fastcall。

因此，**在纯标量循环、数组扫描、很多小叶子函数和理想的静态 C++ extern 调用上，Daslang 解释器很可能领先本项目 AS 解释器**。但在 UE 游戏逻辑中，如果时间主要消耗在 UObject、反射、容器分配、World/RPC 或引擎功能本身，解释器分派差距会被宿主工作淹没；而 cooked 构建启用 StaticJIT 后，也不再是“Daslang 解释器 vs AS 解释器”的同层比较。

---

## 二、先区分三条 Daslang 执行路径

Daslang 当前至少要区分：

```text
Typed AST
   ├─ simulate → SimNode 树 → Fusion → 解释执行
   ├─ LLVM emitter → LLVM IR → 运行期 JIT 机器码
   └─ C++ AOT emitter → C++ → 普通 C++ 工具链
```

本文讨论的是第一条 **SimNode 解释执行**。如果基准命令启用了 `-jit`，或者测试本身走 AOT，就不能把结果归因于解释器。

Daslang 自己的 benchmark 索引也明确区分 `INTERP` 与 `JIT` lane。部分高层查询基准的巨大收益还来自宏在编译期完成的查询融合、字段裁剪和单遍扫描；那是“语言前端/宏系统 + 解释器”共同取得的结果，不能全部算作 SimNode dispatcher 的性能。

参考：

- `Reference/daScript/README.md:24`
- `Reference/daScript/benchmarks/README.md`
- `Documents/Knowledges/ZH/Diff_DaslangAngelseaJIT.md`

---

## 三、Daslang 的解释器为什么快

### 3.1 它解释的是类型化执行节点，不是通用字节码

每个 `SimNode` 有通用 `eval(Context&)`，也有 `evalBool`、`evalInt`、`evalInt64`、`evalFloat`、`evalDouble` 等 typed evaluator。调用者在编译期知道结果类型时，可以直接进入对应 evaluator。

```text
普通字节码思路：
fetch opcode → decode format → decode operands → switch/jump → execute

Daslang SimNode 思路：
virtual call to exact node class → fields already contain offsets/constants/children → execute
```

“不解码 bytecode”本身并不保证更快，因为虚调用、指针追逐和较大的节点也会付出代价。Daslang 真正的优势来自：类型专门化、结构化节点和后续 Fusion 把这些成本压缩了。

参考：

- `Reference/daScript/include/daScript/simulate/simulate.h:108`
- `Reference/daScript/include/daScript/simulate/simulate.h:114`
- `Reference/daScript/include/daScript/simulate/simulate.h:135`

### 3.2 循环是宿主 C++ 循环，不是一串循环控制 opcode

`SimNode_ForRange<TRange>::eval()` 直接执行 C++ `for`：

```cpp
for (baseType i = r.from; i != r_to; ++i)
{
    *pi = i;
    for (SimNode** body = list; body != tail; ++body)
        (*body)->eval(context);
}
```

它还针对以下形状继续专门化：

- 循环体只有一个节点的 `ForRange1`；
- 已知无需处理 break/continue/return flag 的 `ForRangeNF`；
- 同时满足二者的 `ForRangeNF1`；
- 普通数组、固定数组、单数组、多数组、debug、keep-alive 等不同节点族。

这意味着一个简单 range loop 每轮不需要重新解释“比较 → 条件跳转 → 自增 → 回跳”。数组节点还会在进入循环前取得 data、size、stride，并在宿主循环中直接推进元素指针。

这是 Daslang 解释器对线性 bytecode VM 最重要的结构性优势之一。

参考：

- `Reference/daScript/include/daScript/simulate/runtime_range.h:167`
- `Reference/daScript/include/daScript/simulate/runtime_range.h:207`
- `Reference/daScript/include/daScript/simulate/runtime_range.h:239`
- `Reference/daScript/include/daScript/simulate/runtime_range.h:269`
- `Reference/daScript/include/daScript/simulate/runtime_array.h:271`
- `Reference/daScript/include/daScript/simulate/runtime_array.h:348`
- `Reference/daScript/include/daScript/simulate/runtime_array.h:954`

### 3.3 Fusion 把执行树改写成类型化 super-node

Release 和 RelWithDebInfo 默认定义 `DAS_FUSION=2`；MinSizeRel 使用 `DAS_FUSION=1`。Fusion 在 SimNode 创建后遍历函数和全局初始化树，反复替换匹配模式，直到本轮不再产生新融合。

当前注册的融合族包括：

- copy/reference；
- 一元、二元、布尔、位运算；
- return、if；
- 指针/字段读取；
- 运算后写回；
- 标量与向量运算；
- 数组访问；
- table index / hashed table；
- 一参数、二参数调用。

融合节点里的 `SimSource` 可以直接表示：

- 常量；
- local stack offset；
- argument index；
- local/argument reference + field offset；
- global/shared offset；
- 无法融合时才保留普通子 SimNode。

例如，普通树可能是：

```text
SetLocal(dst)
  └─ Add<int>
       ├─ GetLocal(a)
       └─ Const(3)
```

Fusion 后可以变成近似：

```text
SetOp2<int, Local, Const>(dstOffset, aOffset, 3)
```

这样一次节点分派即可直接从栈偏移取值、做运算并写回；不再为 `GetLocal`、`Const`、`Add`、`SetLocal` 分别走虚调用。实际能融合到哪一层取决于具体节点形状和已注册规则。

参考：

- `Reference/daScript/CMakeCommon.txt:111`
- `Reference/daScript/src/ast/ast_simulate.cpp:3889`
- `Reference/daScript/src/simulate/simulate_fusion.cpp:140`
- `Reference/daScript/src/simulate/simulate_fusion.cpp:191`
- `Reference/daScript/include/daScript/simulate/simulate_nodes.h:15`
- `Reference/daScript/include/daScript/simulate/simulate_fusion_op2_impl.h`
- `Reference/daScript/include/daScript/simulate/simulate_fusion_op2_set_impl.h`

#### 3.3.1 “Fusion 解释器”不是第二套解释器

“Fusion 解释器”只是对“执行过 Fusion pass 的 SimNode 解释器”的简称。它没有另一套 VM loop，也不会在运行期生成 x64/ARM 指令：

```text
Typed AST
    ↓ simulate
普通 SimNode 树
    ↓ collect 节点名称、结果类型、子节点形状
Fusion 规则匹配与节点替换
    ↓ 重复到没有新匹配
融合后的 SimNode 树
    ↓ relocate，只复制仍可达的节点
同一套 SimNode::eval(Context&) 执行
```

LLVM JIT 的本质是“在运行时产生新的机器码”。Fusion 的专用节点类则早已由 C++ 编译器编进 Daslang runtime；运行时只是在这些预编译类中选择一种，创建对象并填入 offset、constant、function pointer 等字段。因此它更接近：

- AST/tree superinstruction；
- 模板专门化解释器；
- 执行树 peephole optimizer；
- 有限规则的 partial evaluation。

它不是 LLVM JIT，也不是把 SimNode 临时编译成机器码。

#### 3.3.2 一条 Fusion 规则实际如何工作

Fusion pass 先用 `SimNodeCollector` 访问执行树。每个节点通过 visitor 报告自己的逻辑名称和类型，例如：

```text
Add<int>
GetLocalR2V<int>
GetArgument<int>
ConstValue<int>
SetAdd<int>
FastCall
```

`FusionEngine` 是从“根节点名称 + 类型”到若干 `FusionPoint` 的映射。以 `Add<int>` 为例，匹配器继续检查左右孩子的名称，从而区分：

```text
Local + Local
Local + Const
Argument + Argument
Argument + Local
LocalRefOff + Argument
Const + LocalRefOff
……
```

命中后，它从 context 的 code allocator 创建对应的 C++ 节点类，如概念上的：

```text
SimNode_Add_Local_Local<int>
SimNode_Add_Local_Const<int>
SimNode_Add_Argument_Local<int>
```

新节点不会继续保存两个 `GetLocal` 子树，而是把孩子节点中已经确定的信息拷进两个 `SimSource`：

```text
left.type     = Local
left.stackTop = <A 的栈偏移>

right.type    = Const
right.value   = 3
```

执行 `Add_Local_Const<int>::evalInt()` 时，`computeLocal()` 只是：

```cpp
context.stack.sp() + stackTop
```

`computeConst()` 只是取得节点内嵌常量的地址。随后节点直接调用已按 `int` 实例化的 `SimPolicy<int>::Add(...)`。

未融合时，概念路径是：

```text
virtual Add::evalInt
    → virtual GetLocal::evalInt
    → virtual Const::evalInt
    → add
```

命中 exact Fusion 后，概念路径变成：

```text
virtual Add_Local_Const::evalInt
    → stack.sp + offset
    → embedded constant
    → add
```

也就是把多个虚调用和节点指针追逐压成一个专用节点调用。

参考：

- `Reference/daScript/include/daScript/simulate/simulate_fusion.h`
- `Reference/daScript/include/daScript/simulate/simulate_fusion_op2.h`
- `Reference/daScript/include/daScript/simulate/simulate_fusion_op2_impl.h`
- `Reference/daScript/include/daScript/simulate/simulate_nodes.h:141`
- `Reference/daScript/src/simulate/simulate_fusion.cpp:172`

#### 3.3.3 为什么要反复执行 Fusion

一次替换可能为父节点制造新的可匹配形状。例如：

```text
第一轮：GetLocal + Const → Add_Local_Const
第二轮：SetLocal(Add_Local_Const) → Set/Add/Local/Const 的更大融合节点
第三轮：带该表达式的 return、if 或 call 又可能继续命中
```

所以 `fusionContext()` 使用 `while (anyFusion)`，每轮重新收集仍可达节点的信息，并遍历所有函数和 global initializer，直到不再替换。

新节点在原 code allocator 中创建，旧节点暂时还占内存，但已经从执行树断开。Fusion 结束后的 `relocateCode()` 只从当前函数根和 global initializer 递归复制可达节点到新 allocator；旧 allocator 被整体替换。因此它不需要在每条规则命中时逐节点释放旧树。

参考：

- `Reference/daScript/src/simulate/simulate_fusion.cpp:191`
- `Reference/daScript/src/runtime/context.cpp:458`
- `Reference/daScript/src/ast/ast_simulate.cpp:3889`

#### 3.3.4 `DAS_FUSION=1` 与 `DAS_FUSION=2`

从当前二元运算规则看：

- level 1 主要生成“已知一侧来源、另一侧仍为 Any 子节点”的融合类；
- level 2 进一步生成 `Local+Local`、`Local+Const`、`Argument+Argument` 等双侧来源都确定的 exact combination，同时保留单侧融合 fallback。

Release/RelWithDebInfo 默认是 level 2，所以常见标量表达式会换取更多预编译模板类和更大的 runtime binary，以减少执行期的子节点求值。

Fusion 能否运行还受两层控制：

1. 构建时 `DAS_FUSION` 是否把规则编入 runtime；
2. simulate 时 `fusion` option / policy 是否允许对当前 program 执行 pass。

#### 3.3.5 Fusion 不只融合四则运算

当前规则还会对更高层的执行形状做类似处理：

- `if`：把 condition 的 local/argument/const 读取并入条件节点；
- `SetAdd` / `SetMul`：把目标地址、源地址和复合赋值并入一个节点；
- field/pointer dereference：把 reference 和固定字段 offset 并入读取节点；
- array/table access：把容器、index/hash 的常见来源形状固化；
- call1/call2：把一个或两个参数的 local/argument/const 提取并入 call node；
- fastcall1/fastcall2：参数提取后直接切换 `abiArg` 并进入目标函数根节点。

因此 Fusion 的真实目标不是“让一条 add 快一点”，而是尽量把**解释器经常遇到的短路径**变成一个已经知道类型和数据来源的 C++ super-node。

#### 3.3.6 它仍然有解释器成本和边界

Fusion 不是魔法，仍有以下限制：

- 每个融合节点入口通常仍是一次虚调用；
- 规则没有覆盖的树形会回退到普通 SimNode；
- `Any` fallback 只消除一部分孩子调用；
- 大量专用 C++ 类型增加编译时间、二进制体积和 I-cache 压力；
- simulate 阶段要做多轮 collect/match/replace/relocate，增加加载成本；
- 复杂动态结构、间接调用和宿主 API 的真实工作不会因为节点融合而消失；
- debugger/profiler 等可观测语义会限制 fastcall 等激进快路。

所以 Fusion 最适合的是“同一种短小、类型稳定的表达式在循环里执行很多次”。它用一次加载期树重写，摊薄后续数百万次解释分派成本。

### 3.4 小叶子函数走 fastcall

Daslang 的栈分配阶段会识别 fastcall。当前条件包括：

- 未启用 debugger 和 profiler；
- 未设置 `no_fast_call`；
- 函数不是 export，也没有取地址；
- 函数总栈空间只有 `Prologue`，即没有普通 local frame；
- 参数不超过 32 个；
- 函数体和返回形状满足约束，结果是 workhorse type，且不涉及不兼容的 move return。

fastcall 调用时只需要：

1. 检查/递增 fast-call depth；
2. 在固定数组中求值参数；
3. 临时替换 `context.abiArg`；
4. 直接调用 `fnPtr->code->eval(context)`；
5. 恢复 ABI 参数和 depth。

它不执行普通 `stack.push`、完整 `Prologue` 填充、栈帧分配和 `stack.pop`。对于数学 helper、getter 和小型纯函数，这会显著降低解释型函数边界成本。

参考：

- `Reference/daScript/src/ast/ast_allocate_stack.cpp:390`
- `Reference/daScript/include/daScript/simulate/simulate_nodes.h:1317`
- `Reference/daScript/include/daScript/simulate/simulate.h:576`
- `Reference/daScript/include/daScript/simulate/simulate.h:605`

### 3.5 C++ extern 是静态签名的模板调用节点

常规构建未启用 `DAS_SLOW_CALL_INTEROP` 时，`addExtern` 会把 C++ 函数地址作为模板参数实例化 `SimNode_ExtFuncCall<FuncT, fn>`。运行时通过 `index_sequence` 展开参数：

```cpp
return fn(cast_arg<Args>::to(ctx, args[I])...);
```

`cast_arg<T>` 再用对应的 typed evaluator 求值。其关键点不是“完全零成本”，而是：

- 不需要运行时解析 C++ 签名；
- 不需要 libffi 一类通用 ABI 桥；
- 参数个数和 C++ 类型已经由模板固定；
- 常见 workhorse 返回值可以直接进入 typed result path；
- call1/call2 还可以参与 Fusion。

这比每次调用都遍历参数描述符并组装通用参数数组更适合高频细粒度 extern。

参考：

- `Reference/daScript/include/daScript/ast/ast_interop.h:293`
- `Reference/daScript/include/daScript/simulate/interop.h:14`
- `Reference/daScript/include/daScript/simulate/interop.h:61`
- `Reference/daScript/include/daScript/simulate/interop.h:327`

### 3.6 统一 workhorse ABI 与代码 relocate

Daslang 常用值以 128 位 `vec4f` 作为 workhorse carrier，并针对类型提供 typed evaluator。在支持的平台上，节点 evaluator 使用 `vectorcall`。这减少了“通用 variant 对象”的需求，并天然容纳常见向量值。

这项设计也有代价：很多值槽和参数槽按 16 字节计，节点类型数量和模板实例数量很大；它更偏向吞吐、C++/向量互操作，而不是最小内存占用。

Fusion 完成后，`Context::relocateCode()` 会把函数、全局描述和 SimNode 复制到新 `NodeAllocator`。实现意图是重新打包执行代码并按已知大小分配，而不是让节点永久保留在构建期的零散分配状态。源码里“所有代码应在一页”的断言当前已禁用，因此只能确认它会重打包，不能宣称所有程序最终都落在单一内存页。

参考：

- `Reference/daScript/include/daScript/misc/platform.h:101`
- `Reference/daScript/include/daScript/simulate/simulate.h:79`
- `Reference/daScript/src/runtime/context.cpp:458`
- `Reference/daScript/src/ast/ast_simulate.cpp:3893`

---

## 四、本项目 AS 解释器实际上做得怎样

### 4.1 优点：紧凑、线性、typed 三地址 bytecode

`asCContext::ExecuteNext()` 把 program pointer、stack pointer、frame pointer 缓存在局部变量中，并在一个连续 opcode `switch` 内执行。源码特意要求 case 顺序连续，让编译器更容易生成单次 jump-table lookup。

算术不是“push lhs → push rhs → add → pop dst”的纯栈机形式。例如：

```cpp
case asBC_ADDi:
    *(int*)(fp - dst) = *(int*)(fp - lhs) + *(int*)(fp - rhs);
```

这是一条 typed 三地址指令。常量运算还有 `ADDIi`、`SUBIi`、`MULIi` 等专门版本。

线性 bytecode 的优势是：

- 指令流紧凑，顺序 fetch 的 I-cache/预取友好；
- 不需要为每个语句保存一个带 vptr 的对象；
- bytecode 便于缓存、序列化、调试定位和 StaticJIT 消费；
- 大型、低局部性的脚本不一定会输给体积更大的节点树。

参考：

- `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_context.cpp:1671`
- `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_context.cpp:1740`
- `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_context.cpp:3095`
- `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_context.cpp:3288`

### 4.2 已有 peephole superinstruction，但覆盖范围比 Fusion 固定

本项目显式启用 `asEP_OPTIMIZE_BYTECODE`。`asCByteCode::OptimizeLocally()` 会将常见序列替换为专用指令，例如：

- 常量加载 + 整数/浮点运算 → `ADDIi`、`SUBIi`、`MULIi` 等；
- `PGA + RDSPtr` → `PshGPtr`；
- global load + read → `LdGRdR4`；
- 多种 copy、reference、test、increment 组合。

所以 AS 已经有 superinstruction 思想。与 Daslang 的差别主要是：

```text
AS：固定 opcode 集 + 编译期局部序列重写 + 每个 opcode 回到中心 dispatcher

Daslang：大量 C++ 节点类 + 运行时树模式匹配 + 类型/来源形状组合 + 结构化控制流节点
```

Daslang 的组合空间更大，也更容易为“一种热点 AST 形状”做专门节点；代价是实现体积、编译时间和节点内存更大。

参考：

- `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.cpp:1254`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.cpp:2318`
- `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_bytecode.cpp:437`
- `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_bytecode.cpp:619`
- `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_bytecode.cpp:721`
- `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_bytecode.cpp:891`

### 4.3 主要差距：普通循环仍由多个 opcode 驱动

AS 的 `JMP`、`JZ`、`JNZ`、`IncVi`、`CMPi`、`CMPIi` 都是独立 VM case。一个普通 `for` 即使经过局部优化，通常仍需要每轮执行若干循环控制 opcode，再执行循环体 opcode。

Daslang 的 `ForRangeNF1` 可以把“无复杂控制流 + 单节点循环体”压缩为一个宿主 C++ `for`，每轮只调用一次 body node。两者在 tight loop 上的 dispatcher 次数不是同一个量级。

参考：

- `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_context.cpp:1888`
- `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_context.cpp:2192`
- `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_context.cpp:2341`

### 4.4 主要差距：脚本调用要建立完整 VM 状态

解释执行的 `CallScriptFunction()` 在没有 JIT entry 时会：

1. 获取当前 JIT Binding；
2. 检查递归深度；
3. `PushCallState()`；
4. 切换 current function 和 program pointer；
5. 检查/扩展栈空间；
6. 做 16 字节对齐，必要时 `memmove` 参数；
7. 清零 heap object locals；
8. 分配 local variable space。

当前统一 JIT Binding 支持并发读取、运行期替换和延迟释放。为保证 binding provider 生命周期安全，`AcquireJITBindingForExecution()` 和 `ReleaseJITBindingAfterExecution()` 都会进入 `std::mutex` 保护区；即使该函数最终没有 JIT entry，解释调用也会 acquire 后再 release。

这项成本不是无意义代码：它换来了 StaticJIT provider 热替换、并发执行租约和 retired binding 安全释放。但它对“一个循环里调用成千上万个极小解释函数”的负载不友好，正好是 Daslang fastcall 擅长的场景。

参考：

- `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_context.cpp:1473`
- `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_context.cpp:1529`
- `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_scriptfunction.cpp:1583`
- `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_scriptfunction.cpp:1674`

### 4.5 原生调用已经是模板桥，但解释路径仍做运行时参数组装

本 fork 不再使用上游平台汇编桥作为主要 native dispatch。注册函数带有 `asFunctionCaller`，实际调用由模板生成的 `FunctionCaller` / `MethodCaller` 完成。

这比通用 FFI 好，但 `asCContext::CallFunctionCaller()` 每次仍会：

- 根据函数描述处理 object argument、metadata 和 return address；
- 遍历 `parameterOffsets` / `parameterTypes`；
- 在栈上组装最多 32 项的 `void* FunctionArgs[]`；
- 处理 object/reference/primitive/question 类型；
- 做 WorldContext/editor 安全检查；
- 切换 thread-local active function；
- 最后才进入已模板化的 native caller。

Daslang 的 ideal `addExtern` 节点把参数个数、C++ 类型和函数地址都固化在节点模板中，解释器只需求值对应参数并直接调用。因此，在简单、高频、静态 extern 上，Daslang 的桥更短。

UE 绑定不能全部照搬这一路径：RPC 必须保持 Unreal 路由，WorldContext、反射 fallback、out 参数、容器和 UObject 生命周期都有额外语义。本项目已存在 NativeRuntimeLinked、NativeModuleFunctionAddress 和 reflective fallback 等不同路线；比较原生调用性能时必须标明实际选中了哪条 route。

参考：

- `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_callfunc.cpp:447`
- `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_context.cpp:5456`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Core/FunctionCallers.h:188`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Core/angelscript.h:786`

### 4.6 每指令可观测性目前也留在热循环中

`ExecuteNext()` 每轮都会判断是否安装 `m_instructionCallback`，构造 `asSInstructionCallbackScope`，并在启用时发送 before/after 通知。callback 为空时不会真正通知，但判断和 scope 生命周期仍存在于 dispatcher 热循环。

这给调试、测试和逐指令观测提供了统一入口，但 Release 普通执行可以考虑拆成“无观察者快循环”和“有观察者循环”，避免让完全不调试的执行持续支付结构性分支/RAII 成本。是否值得做必须先用 CPU profile 验证，不能只凭源码外观判定收益。

参考：

- `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_context.cpp:1671`
- `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_context.cpp:1718`

---

## 五、执行模型对比

| 维度 | Daslang 解释器 | 本项目 AS 解释器 | 性能含义 |
| --- | --- | --- | --- |
| 执行 IR | 类型化 SimNode 对象树 | 紧凑线性 bytecode | Daslang 少 decode；AS 代码密度更好 |
| 分派 | 节点虚调用 | 中心 opcode `switch` | 单次成本不能孤立判断，要看每个源级操作需要几次分派 |
| 普通算术 | typed node；可与 source/store 融合 | typed 三地址 opcode | 两者都不是朴素 stack VM；Fusion 组合更广 |
| range/array loop | 专用 C++ loop node | compare/jump/inc/body bytecode | tight loop 通常有利于 Daslang |
| superinstruction | 反复树 Fusion，覆盖源形状、运算、写回、访问、调用 | 固定 opcode + peephole | Daslang 更激进；AS 更简单稳定 |
| 小脚本函数 | 满足严格条件可 fastcall | 完整 call state/frame；JIT Binding acquire/release | 很多 leaf calls 时 Daslang 更有利 |
| C++ extern | 模板节点直接按静态签名调用 | 模板 caller，但前面有运行时参数描述遍历/组装 | 理想细粒度 extern 有利于 Daslang |
| 常用值 ABI | 128-bit `vec4f` + typed eval + 可选 vectorcall | 4-byte VM cell + value/object registers | Daslang 偏向统一/向量吞吐；AS 栈更紧凑 |
| 代码内存 | 大量节点对象和模板代码 | 紧凑 bytecode + 一个大 dispatcher | 大代码/内存敏感场景 AS 有优势 |
| 构建成本 | AST → SimNode → Fusion → relocate | AST → bytecode → peephole | Daslang simulate/load 期工作更多 |
| 调试/观察 | debugger/profiler 会关闭 fastcall | VM 天然按 opcode/PC 定位，另有逐指令 callback | AS 的调试映射和热重载资产更成熟 |
| cooked 高性能路径 | LLVM JIT 或 C++ AOT | StaticJIT 生成/编译 C++ | cooked 时不应只比较解释器 |

---

## 六、按实际负载判断谁更占优

### 6.1 纯算术 tight loop

**倾向 Daslang 解释器。**

理由不是单条 `add` 一定更快，而是结构化 loop + Fusion 可以显著减少每轮 dispatcher 数量。本项目 AS 的 typed `ADDi` 本身很紧凑，但循环控制仍是多条 opcode。

### 6.2 顺序数组扫描、多个数组 zip、字段累加

**倾向 Daslang 解释器，尤其是形状命中专用数组节点和 Fusion 时。**

它会提前取得 data/size/stride，并在 C++ 循环中推进指针；本项目 AS 更依赖容器 binding、索引检查、迭代器和 bytecode 序列的具体质量。

### 6.3 大量小型脚本 helper

**倾向 Daslang fastcall。**

本项目当前每个解释型脚本调用要切换 VM frame，并进入两次 JIT Binding 生命周期锁。函数越小，这个固定成本占比越高。

### 6.4 高频简单 C++ extern

**Daslang 的理想静态 extern 路径更短；本项目实际结果取决于绑定 route。**

本项目的模板 `FunctionCaller` 已避免传统通用 FFI，但解释器仍会组装 `FunctionArgs`。若落到 reflective fallback，成本还会明显增加；若 cooked StaticJIT 能直接进入生成的 native route，结论会不同。

### 6.5 UObject、RPC、反射、字符串和容器分配占主导

**解释器差距可能退居次要。**

一次昂贵的 UObject 查询、ProcessEvent、RPC 路由、TArray/TMap 分配或字符串复制，可能远大于几次 dispatcher。此时应先优化调用 route、分配和算法，而不是先重写 VM。

### 6.6 大型、冷代码或内存敏感环境

**AS 的紧凑 bytecode 可能更有优势。**

Daslang 用更多节点对象、vptr、模板专门化和 16 字节 workhorse 槽换吞吐。大规模脚本的代码/数据 cache 行为必须实测，不能根据小循环直接外推。

### 6.7 packaged/cooked 构建

**优先比较 Daslang LLVM JIT/AOT 与本项目 StaticJIT，而不是继续拿两个解释器比较。**

本项目已经有 StaticJIT。若目标是最终游戏运行性能，提升 StaticJIT 覆盖、native binding route 和生成代码质量，通常比把 bytecode VM 重构成 SimNode tree 更符合现有架构。

---

## 七、本项目当前已有的内部微基准

工作区在 2026-08-12 留有三组 runtime microbenchmark 的 `metrics.json`。每组为 1 次 warmup、3 次 measurement、每次 10,000 个 benchmark iteration。以下使用 median 换算：

| 本项目基准 | AS median / 10k | AS 每 iteration | Native C++ median / 10k | 工作负载比值 |
| --- | ---: | ---: | ---: | ---: |
| ScriptSelf.Empty | 0.449799 ms | 44.98 ns | 0.001200 ms | 不采用；native no-op/loop 很可能被优化 |
| ScriptSelf.Arithmetic | 2.370600 ms | 237.06 ns | 0.003703 ms | 不采用；每轮包含 4 个脚本 helper，C++ 可内联/折叠 |
| NativeProperty.Scalar | 4.675601 ms | 467.56 ns | 0.606500 ms | 7.71× |
| NativeProperty.Container | 8.526102 ms | 852.61 ns | 1.958199 ms | 4.35× |
| NativeFunction.Scalar | 4.597601 ms | 459.76 ns | 0.483602 ms | 9.51× |
| NativeFunction.Container | 8.971900 ms | 897.19 ns | 2.666198 ms | 3.36× |

这些数字可以说明：

- 当前 AS 解释/绑定路径并非完全不可用；10,000 次 empty helper loop 的总量约为 0.45 ms；
- 越接近纯小函数/标量调用，解释调度和调用桥固定成本越显眼；
- 容器操作本身变重后，AS/native 的相对倍数反而下降，说明宿主工作开始占主导。

但它们**不能**回答“Daslang 比本项目 AS 快几倍”，原因包括：

1. 没有同一份 Daslang 等价实现和同机横向结果；
2. 当前 metrics 未记录 CPU、编译配置、selected execution route、StaticJIT 状态和 debugger/callback 状态；
3. Native C++ 版本可能被内联、常量传播或消除，尤其 no-op 基准；
4. 每个 iteration 包含的调用数、容器工作和检查不同，不能把表中每项直接解释成单次函数调用延迟。

样本来源：

- `Saved/Automation/AngelscriptPerformance/RuntimeMicrobenchmark_ScriptSelf/Metrics/metrics.json`
- `Saved/Automation/AngelscriptPerformance/RuntimeMicrobenchmark_NativeProperty/Metrics/metrics.json`
- `Saved/Automation/AngelscriptPerformance/RuntimeMicrobenchmark_NativeFunction/Metrics/metrics.json`
- `Plugins/Angelscript/Source/AngelscriptTest/Performance/AngelscriptRuntimeMicrobenchmarkTests.cpp`

---

## 八、最值得借鉴什么

### 8.1 不建议：把现有 AS bytecode VM 整体替换成 SimNode tree

这样做会同时冲击：

- bytecode cache/序列化；
- StaticJIT 输入；
- debugger、coverage 和 PC/source 映射；
- 热重载和函数替换；
- AngelScript SDK 兼容；
- 现有大量自动化测试和第三方 fork 维护边界。

Daslang 的性能来自一整套语言和 runtime 协同，不是一种可以单独移植的小 dispatcher 技巧。对本项目而言，整体替换的收益/风险比不合理。

### 8.2 建议优先级 P0：先做同机、同语义、分执行层 benchmark

至少准备五类等价负载：

1. empty leaf call；
2. 四则运算 leaf call；
3. range sum；
4. array read/write/field accumulation；
5. 静态 native add/get/set。

建议 lane：

```text
Daslang interpreter + Fusion
Daslang interpreter - Fusion
Daslang LLVM JIT
AS interpreter + optimize bytecode
AS StaticJIT
Native C++
```

统一要求：Release、同一 CPU、固定 affinity/频率策略、关闭 debugger/profiler/coverage、相同边界检查和溢出语义、足够 warmup、记录 median/min/max。除 ns/op 外，还应采：

- retired instructions；
- branches / branch misses；
- L1I / LLC misses；
- code/IR memory；
- compile/simulate/load 时间；
- 实际 selected execution/binding route。

### 8.3 建议优先级 P1：拆分无观察者 VM 快循环

当没有 instruction callback、debugger、coverage 或单步需求时，进入不构造 `asSInstructionCallbackScope` 的 `ExecuteNextFast()`；有观察者时继续走当前可观测版本。

这是局部、可 A/B 测量的优化。必须验证：异常、suspend、调用切换、callback 安装/移除时机和所有 opcode 行为保持一致。

### 8.4 建议优先级 P1：设计 AS leaf-call fast path

借鉴的是 Daslang 的**资格判定思想**，不是照抄节点实现。候选条件可包括：

- 无 object local 初始化；
- 无异常处理区、suspend、debugger/coverage hook；
- 栈空间和返回布局满足严格上限；
- 不导出地址、不跨需要完整上下文的边界；
- JIT Binding generation 在调用期间可安全固定；
- recursion/stack overflow 仍有等价保护。

最大难点不是栈帧代码，而是现有 JIT Binding 并发替换契约。不能为了几十纳秒绕开 provider 生命周期安全；应先 profile 锁占比，再决定采用 immutable atomic binding snapshot、generation/epoch/RCU，还是只对“明确永不安装 JIT binding”的函数开放解释 fastcall。

### 8.5 建议优先级 P1/P2：扩展有数据支持的 superinstruction

不建议枚举 Daslang 的全部 Fusion 笛卡尔积。更适合 AS 的路线是：

- 从 bytecode execution histogram 找 top sequence；
- 优先覆盖 loop condition/inc、local arithmetic + store、property load + compare、array iterator 等高频模式；
- 保持 source mapping、异常 PC 和 StaticJIT lowering 一致；
- 每加入一个 opcode，同步 VM、bytecode optimizer、disassembler、serializer/cache、StaticJIT、debugger 和测试。

如果“结构化 range loop opcode”能以稳定 bytecode 形式表达，它可能比继续增加零散二指令 peephole 更接近 Daslang 的核心收益，但影响面也更大，必须走独立设计和基准验证。

### 8.6 建议优先级 P1/P2：为高频 native route 预生成调用形状

本项目已经有 UHT codegen 和模板 FunctionCaller，可以继续研究：

- 在 bind/compile 时预计算 parameter extraction plan；
- 对安全标量签名生成不遍历 `parameterTypes` 的专用 caller stub；
- 让解释 CALLSYS 直接进入已选定的 immutable route；
- 保持 RPC、WorldContext、out/ref/container 和 reflective fallback 的现有边界。

这比引入 LLVM 更直接地解决 UE 游戏脚本中常见的“解释器频繁调用引擎 API”成本。

### 8.7 cooked 方向：继续优先 StaticJIT 覆盖和生成代码质量

Daslang 解释器值得借鉴，主要是为了改善 editor/dev 模式的脚本体验和无 JIT 平台的底线性能。最终 packaged 性能应继续依赖：

- StaticJIT 覆盖率；
- bytecode → C++ lowering 质量；
- 生成代码的直接 native route；
- cache/precompiled data 稳定性；
- 未覆盖函数的明确 fallback 诊断。

没有必要仅因为 Daslang 的解释器跑分优秀，就把 LLVM DLL 或第二套运行期 IR 引入本项目。

---

## 九、最终判断

可以把两者概括为：

```text
Daslang：
用更重的编译/模拟阶段和更大的类型化节点体系，
换取“源级结构仍留在 C++ 节点中”的高吞吐解释执行。

本项目 AS：
用紧凑、稳定、可缓存的线性 bytecode 和成熟 UE 集成，
换取更简单的执行/调试模型，再由 StaticJIT 负责 cooked 性能上限。
```

Daslang 最值得本项目吸收的不是“不要 bytecode”，而是三件更具体的事：

1. **结构化 loop / measured superinstruction，减少每个源级操作的 dispatcher 次数；**
2. **严格资格判定的 leaf-call fast path，降低小脚本函数边界成本；**
3. **预生成 native call shape，避免解释热路径反复遍历参数元数据。**

在拿到同机基准和硬件计数器证据前，不应宣称 Daslang 对本项目 AS 有固定的“几倍”优势；但从当前源码结构看，Daslang 在 tight loop 与 leaf-call 解释负载上占优是合理且可验证的预期。
