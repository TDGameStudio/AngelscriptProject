# Typed semantic native pipeline survey

## 1. 研究目标

本文回答三个问题：

1. 其他脚本语言把源程序变成本机代码时，真正交给 native backend 的输入究竟是 AST、typed HIR、SSA、bytecode、trace，还是解释器树？
2. 它们如何处理类型、控制流、调用、对象生命周期、异常、GC、回退、反优化和缓存？
3. 哪些设计值得 Unreal AngelScript 的 typed semantic Static AOT、Angelsea Runtime JIT 和 LLVM Runtime JIT 采用，哪些设计暂时不应引入？

本文是 `feature-as-typed-semantic-aot` 的研究附件。当前变更仍以结构化 `asCTypedSemanticFunction` sidecar HIR、C++ StaticJIT/AOT emitter、逐函数支持度判定和 bytecode fallback 为基线；当前 fork 的具体 capture 时序与改造清单见 [`typed-semantic-staticjit-engine-impact.md`](typed-semantic-staticjit-engine-impact.md)。

术语上，本文的 “typed AST path” 不表示长期保留 parser `asCScriptNode`。实际保留物是 semantic compiler 在类型、转换、重载和调用目标解析完成后同步构造的 function-owned typed HIR。parser AST 仍是短生命周期 syntax tree。这个路径产出静态 C++ provider，不是游戏运行期的热点 JIT。

## 2. 先给结论

最接近当前目标的不是 V8、LuaJIT 或 Graal，而是下列三类实现：

- **daScript / Cython**：编译器保留已解析、已类型化的高层语义树，直接生成 LLVM IR 或 C/C++。它们证明了“源码已知时不必先丢成 VM bytecode，再从 bytecode 反推语义”。
- **Dart Kernel**：把 frontend semantic IR 与多个执行/codegen backend 分开。它证明了高层、可诊断、可转换的语义表示可以是稳定的编译器边界，而不是最终机器 IR。
- **Julia / Numba**：在高层语义分析之后再形成 typed CFG/SSA，并在 LLVM 之前做类型相关优化。它们证明了 typed HIR 与 typed SSA 是两个不同层次，不应在第一版 HIR 中混成同一种表示。

Luau、LuaJIT、V8 和 Graal 的价值主要在 runtime JIT，而不是 typed source AOT：

- **Luau** 最值得参考 bytecode native codegen 的 VM exit、细粒度 fallback、代码内存和函数安装方式。
- **LuaJIT** 最值得参考 trace side exit 和运行时类型守卫，但它的 trace compiler 不适合当前确定性的 Static AOT。
- **V8** 最值得参考 tier coordinator、编译预算、frame state 和 deoptimization metadata；其复杂度远超当前需求。
- **Graal/Truffle** 最值得参考“语义在解释器节点里只定义一次，再由 partial evaluation 特化”的思想；不能直接移植其 Java/Graal runtime 体系。

因此，当前项目最合理的分层仍是：

```text
AngelScript source
    │
    ├── frontend semantic analysis
    │       └── structured typed semantic HIR
    │               ├── C++ Static AOT emitter (当前变更)
    │               └── future CFG/SSA lowering (未来优化层)
    │
    └── AngelScript bytecode
            ├── VM/interpreter and bytecode archive
            ├── legacy bytecode → C++ Static AOT
            ├── Angelsea bytecode → C/MIR Runtime JIT（规划）
            └── bytecode → LLVM IR Runtime JIT（规划）
```

HIR 和 bytecode 不是互斥替代关系。HIR 服务于“编译时仍拥有完整语义”的 Static AOT；bytecode 服务于 VM、预编译模块、运行时 JIT、兼容回退和独立正确性 oracle。

## 3. 横向总表

| 系统 | Native backend 的直接输入 | 类型何时可用 | CFG/SSA 时机 | Native 产物 | 回退/反优化 | 对本项目的主要价值 |
| --- | --- | --- | --- | --- | --- | --- |
| daScript LLVM JIT/AOT | 已编译的 typed `Function` / `Expression` AST | frontend 已完成类型解析 | LLVM lowering 时形成 CFG/SSA | JIT function、object、DLL、EXE、Wasm | `DisableJitVisitor` 预检；不支持函数保留 tree interpreter | typed AST 直接下沉、支持度预检、逐函数混合执行、semantic hash cache |
| Cython | 经过 declaration / expression / type analysis 的 AST | AST analysis 阶段 | 通常交由生成的 C/C++ compiler 完成 | C/C++、扩展模块 `.so/.pyd` | Python object/C-API 路径是生成代码内的语义慢路；不是 runtime deopt | 最接近 typed semantic HIR → C++ Static AOT emitter |
| Dart | Kernel 高层 IR，再转 VM flow graph/SSA | frontend/Kernel 保留声明与类型语义，backend 继续特化 | VM compiler backend | AOT snapshot、ELF/dylib、exe、JIT snapshot | JIT 有反馈和 deopt；AOT 采用闭世界/确定性约束 | frontend IR 与多 backend 解耦、可序列化 IR 的版本边界 |
| Julia | lowered IR → inferred typed SSA IR | 按 `MethodInstance` 参数类型做推断与特化 | inference/optimizer 阶段显式 SSA | JIT machine code、object/system/package image | 世界年龄、依赖失效和动态 dispatch 慢路 | typed SSA 独立层、调用特化键、失效依赖和 GC/ABI metadata |
| Numba | Python bytecode → Numba IR → typed Numba IR | 参数签名和 type inference 阶段 | bytecode 分析先建 CFG，typed IR 后下沉 LLVM | LLVM JIT machine code、object cache | nopython 失败；旧/特定模式可 object-mode 或 loop lifting | 清楚的 untyped/typed/lowering pass 分层、typed rewrite、缓存键 |
| Haxe C++ | Haxe typed expression graph，经 C++ target generator | Haxe typer 阶段 | 主要由 target-specific generator 与 C++ compiler 完成 | C++ source + hxcpp native binary/library | 通常是整目标编译错误，不是 VM fallback/deopt | typed cross-language source backend、target runtime 边界 |
| Luau native codegen | `Proto` 中的 Luau bytecode + bytecode type info | bytecode type info、bytecode dataflow analysis和 runtime guards | codegen 重建 basic blocks，再形成 Luau IR/CFG | x64/A64 executable memory | instruction fallback block、VM exit、入口类型守卫 | runtime bytecode JIT 的最近邻；不是 typed source AOT 先例 |
| LuaJIT | 正在执行的 bytecode trace | trace recorder 从实际值获得类型 | trace recorder 生成 SSA-like IR | DynASM machine code trace | guard side exit 回解释器，必要时生成 side trace | 运行时投机、side exit 和 hot trace；不适合 v1 Static AOT |
| V8 | Ignition bytecode + feedback；不同 tier 使用不同 IR | runtime feedback、对象 shape、静态可知信息 | Maglev 是传统 CFG/SSA；TurboFan/Turboshaft 更复杂 | Sparkplug/Maglev/TurboFan machine code | frame state、guard、dependency invalidation、deopt、OSR | 统一 coordinator 和分层预算；实现复杂度很高 |
| Graal/Truffle | specialized AST/bytecode interpreter，经 partial evaluation | AST specialization 和 profiling 阶段 | partial evaluation 后进入 Graal IR | Graal machine code | transfer-to-interpreter、assumption invalidation、deopt | 语义单点定义与自动特化；runtime 体系不适合直接接入 |

## 4. Closest typed-source / native pipelines

### 4.1 daScript：typed AST 同时服务 tree interpreter、LLVM JIT 和 AOT

#### daScript 实际管线

daScript 的默认执行模型不是 bytecode VM，而是 `SimNode` tree interpreter。编译完成后，程序仍保有 `Function` / `Expression` 语义树。`dasLLVM` 在 program simulate/JIT 阶段枚举已解析函数，通过 `DisableJitVisitor` 先检查支持度，再由 `generate_llvm(...)` 直接遍历函数语义树生成 LLVM IR。

同一套 AST → LLVM frontend 可以连接多种 materialization：

- 在内存中通过 LLVM execution engine 获取函数地址；
- 输出 object；
- 生成或装载 DLL；
- 输出 EXE/Wasm 等目标；
- 把入口安装到 `SimFunction::jitFunction`，未安装的函数继续使用 `code`/`SimNode`；已有 C++ AOT 函数则使用 `aotFunction`。

#### 类型与控制流

类型已经由 daScript frontend 解析并保留在 AST 中。LLVM backend 不需要从解释器节点或 bytecode 恢复表达式类型。结构化 AST 在 lowering 时转为 LLVM CFG/SSA，因此“高层语义树”和“LLVM SSA”是两层，而不是一个 IR。

#### 调用、生命周期、异常和回退

- 调用目标和函数签名来自已解析的 `Function`。
- `DisableJitVisitor` 负责拒绝 backend 不支持的 AST/类型/运行时形态。
- 支持度是逐函数的；一个函数被拒绝不要求整个程序停止使用 JIT。
- `SimFunction` 同时暴露 interpreter/AOT/JIT 入口，形成自然的 mixed-mode dispatch。
- cache 身份不仅看源码时间戳，还组合函数语义、选项、目标和 codegen 版本，避免错误复用 native artifact。

#### daScript 对本项目的参考

这是最值得参考的整体架构：

1. `asCTypedSemanticFunction` 应直接来自 AngelScript frontend 的 resolved semantics，而不是从 bytecode 反编译。
2. 第一版 structured HIR 可以保持树/arena 结构；LLVM CFG/SSA 应是后续 lowering 结果。
3. 支持度预检与 emitter 必须共享同一 capability contract，避免“预检说支持、生成到一半才失败”。
4. 每个函数都应有稳定的 fallback reason；fallback 不等于吞错。
5. 如果未来 typed HIR 也进入 LLVM backend，可以复用 semantic identity，但不能直接复用 C++ 文本输出 hash。

不应照搬的部分：daScript 的对象模型、ABI、SimNode runtime、LLVM-C FFI 和固定 `LLVM.dll` 绑定都不是 AngelScript/UE 的契约。

### 4.2 Cython：typed AST 直接生成 C/C++

#### Cython 实际管线

Cython 把 Python/Cython 源码解析成 AST，依次运行 declaration analysis、control-flow analysis、expression/type analysis、typed transforms 和最终优化，再由 `ModuleNode.generate_c_code()` / `CCodeWriter` 生成 C/C++。系统 C/C++ compiler 最终生成 Python extension module。

它没有先生成 CPython bytecode，再从 bytecode 恢复源级语义。AST node 同时携带语法结构、解析后的 symbol/type state、coercion 和 codegen 所需信息。

#### 类型与语义慢路

Cython 允许 C 类型和 Python object 混合：

- C 类型表达式可以生成直接 C 运算；
- Python object 表达式生成 Python/C API 调用；
- 引用计数、错误检查和 Python exception propagation 由 codegen 自动插入；
- unsupported 或动态语义通常不是“整个函数退回解释器”，而是在生成代码中保留 Python object 慢路。

因此，Cython 的 fallback 粒度比当前 OpenSpec 计划更细，但它依赖 CPython C API 和对象模型。AngelScript v1 不需要复制这种任意表达式级混合慢路；逐函数 fallback 更容易验证，也更符合现有 StaticJIT。

#### Cython 对本项目的参考

Cython 是 typed semantic HIR → C++ Static AOT 的最近邻：

1. 让 frontend 完成 declaration/type/call resolution，再让 emitter 消费结果。
2. HIR node 可以保留 source span、resolved type、coercion、resolved call target 和所有权/临时值信息。
3. C++ emitter 应把 ABI、错误传播、生命周期和临时值清理做成显式 lowering policy，而不是散落字符串拼接。
4. typed transforms 应在 lowering 到 C++ 之前完成；一旦降成 C++ 文本，再做 AngelScript 语义优化会很困难。

不应照搬的部分：CPython 引用计数、GIL、Python C API、extension-module import ABI 和表达式级动态 fallback。

### 4.3 Dart：Kernel 作为 frontend 与 backend 的语义边界

Dart Kernel 是从 Dart 派生的高层语言/IR，面向 whole-program analysis、transformation 和多个 codegen/execution backend。它有内存表示，也可序列化为 binary/text。`dart compile kernel` 生成包含 Kernel AST 的 portable module；`dart compile aot-snapshot` 或 `exe` 再生成 architecture-specific machine code。

Dart VM backend 还会把 Kernel 转成自己的 flow graph/SSA，并分别为 JIT 与 AOT 应用不同优化策略。Kernel 不是 LLVM IR，也不是最终 VM bytecode；它保留足够高层的程序结构和语义供后端消费。

#### Dart 对本项目的参考

1. frontend HIR 与 backend IR 应分层：`asCTypedSemanticFunction` 不应等同于未来 LLVM IR。
2. 同一 frontend artifact 可以服务 C++ AOT、分析、诊断和未来 LLVM lowering，但每个 backend 仍拥有自己的低层 IR。
3. 如果未来要持久化 HIR，必须像 Kernel 一样明确 schema/version/compatibility；当前 v1 保持 ephemeral sidecar 是更安全的选择。
4. AOT 和 JIT 可以共享 frontend 语义层，但不必共享所有优化、缓存和 materialization policy。

Dart SDK 整库超过 1.5 GiB，不适合作为本项目普通离线参考。保留官方 Kernel/compile 文档和精确源码链接即可。

### 4.4 Julia：lowered IR、typed SSA、LLVM 是三个阶段

Julia 先把 surface AST 降成显式 branch/statement 的 lowered IR；type inference 以具体参数类型和 `MethodInstance` 为特化键；优化器使用带类型的 SSA IR；codegen 最终生成 LLVM IR 和 native code。Julia 官方文档明确区分 surface AST、lowered IR、SSA IR 和 LLVM/native code。

Julia 的每个 SSA value 都维护推断类型；静态调用可表示为解析后的 `invoke`，动态调用仍保留通用 dispatch。GC root、boxed/unboxed representation、union、异常边和 ABI 都由 compiler/runtime 协同处理。JIT 还要维护 method dependency、world age、invalidation 和反序列化 relocation；AOT/system image 则需要记录可重定位对象和函数引用。

#### Julia 对本项目的参考

1. structured HIR 与 typed SSA 分开是正确的。第一版 C++ emitter 不需要为了“像现代 JIT”而提前使用 SSA。
2. HIR 必须保留足够的信息，确保未来能无损构造 CFG：显式 evaluation order、short-circuit、loop edges、exception/suspend boundary、temporary lifetime 和 merge type。
3. 调用身份不能只有函数名；未来 specialization/cache key 至少需要 function identity、resolved signature、backend/version、target 和相关 binding ABI identity。
4. GC root、value representation 和调用约定是 lowering contract，不能寄希望于 LLVM 自动推断。

不应照搬的部分：Julia 的动态多分派、世界年龄、全语言运行时失效系统和 method specialization explosion。

### 4.5 Numba：bytecode → untyped IR → typed IR → LLVM

Numba 从 CPython bytecode 构建 CFG/dataflow，再把 stack bytecode 变成 register-like Numba IR。type inference 为每个中间值、返回值和 call site 生成 `typemap`、`return_type`、`calltypes`；typed rewrite 可在 LLVM 之前做 array fusion、parallel transformation 等高层优化；`NativeLowering` 最终把 typed Numba IR 降为 LLVM 并取得 executable。

Numba 还展示了一个很实用的 pass boundary：

```text
untyped passes
    → typed passes
        → IR legalization / type annotation
            → native lowering
                → backend materialization / object cache
```

它可以按参数 signature 编译不同 specialization；cache key 组合 signature、target/codegen magic、函数字节码和 closure 内容。IR 中的显式 `del` 参与引用生命周期处理。

#### Numba 对本项目的参考

1. OpenSpec 中的 HIR capture、support analysis、typed rewrite、C++ lowering 和 native build 应保持可观察的分段结果。
2. backend support 不只由 node kind 决定，还要考虑 resolved type、call target、ABI、exception/suspend 语义和 target capability。
3. cache identity 必须覆盖输入语义、目标、backend 和 ABI，而不能只看 `.as` 时间戳或生成文件名。
4. future LLVM backend 可以消费一个从 structured HIR 降出的 typed CFG IR，不应直接复用 legacy VM bytecode decoder 的所有假设。

Numba 从 bytecode 起步是因为 CPython 的可部署/可执行输入就是 bytecode；这不能反证 AngelScript source-known Static AOT 也必须以 bytecode 为唯一输入。

### 4.6 Haxe C++：typed cross-target compiler

Haxe 是带类型推断的静态类型语言。compiler typer 产生 typed expressions，各 target generator 消费已类型化程序；C++ target 先生成 source/header/build files，再由 hxcpp 调用系统 compiler/linker 生成 native executable 或 library。

Haxe 证明“typed frontend + source backend + target runtime”是成熟路线，但 hxcpp 自己承担动态对象、反射、GC、异常和跨平台 runtime 兼容。这意味着生成 C++ 并不自动等价于零 runtime cost。

#### Haxe 对本项目的参考

- 生成 C++ 只是 materialization 策略；真正的架构边界仍是 typed semantic IR 与 runtime ABI。
- AngelScript C++ emitter 应复用 UE/AngelScript 已有对象模型和 helper，不应创造第二套 hxcpp 式 runtime。
- target-specific lowering 可以独立于 frontend HIR；Windows/MSVC、Clang、console 等差异应尽量留给 C++ toolchain 和小型 target policy。

Haxe compiler 与 hxcpp 分属不同仓库，且对我们最关键的结论已被 Cython/daScript 更直接覆盖，因此本轮不拉取本地副本。

## 5. Dynamic Runtime JIT contrast group

### 5.1 Luau：bytecode native codegen 的最近邻

Luau native codegen 明确从 `Proto` bytecode 开始：`IrBuilder::buildFunctionIr()` 读取 bytecode type info，重建 bytecode basic blocks，进行 bytecode type analysis，再逐条翻译为 Luau IR。IR 使用 `CHECK_TAG`、fallback block 和 `vmExit(pc)` 保护优化假设；x64/A64 lowering 生成代码后，把 native entry/offset metadata 安装回 `Proto`。

Luau 的 static type checker 并不是 native backend 的直接输入。类型注解可以编码进 bytecode type info，但 backend 仍以 bytecode 和运行时可验证假设为准。

#### Luau 对本项目的参考

- Angelsea/LLVM Runtime JIT 应以 bytecode PC 为共同恢复点，任何 native exit 都能恢复 VM 可见状态。
- fallback 可以分成“native 中执行通用慢路”和“退出到 VM”，而不是所有不支持 opcode 都让整个模块失败。
- 入口类型守卫、VM register synchronization、code allocation/unwind metadata、函数安装/销毁值得重点参考。
- runtime codegen 不能信任 source type information 而不验证；预编译 bytecode、热重载和动态 binding 都可能改变有效假设。

不应把这条路线反推给 typed semantic Static AOT。Luau 的 native backend 丢失 source AST 是其部署模型的选择，不是所有语言的最佳边界。

### 5.2 LuaJIT：trace recorder 与 side exit

LuaJIT 在 bytecode interpreter 执行热点循环/函数时开始 trace recording。recorder 根据实际值和执行路径构造带运行时类型的 SSA-like IR，并插入 guards。成功 trace 经优化和 register allocation 生成 machine code；guard 失败时通过 side exit 恢复解释器状态，热点 side exit 还可形成 side trace。

#### LuaJIT 对本项目的参考

- 运行时 JIT 的 correctness 核心不是“能生成机器码”，而是每个 speculative guard 都有完整恢复映射。
- trace/side-exit 的 profiling 对未来热点优化有价值。
- runtime JIT 诊断应能区分“不热”“不支持”“编译失败”“guard exit 频繁”和“已失效”。

不适合当前 v1：trace selection、speculative type lattice、side trace、OSR 和 deoptimization 会显著扩大运行时状态空间；AngelScript 已是强类型语言，第一阶段收益不足以覆盖复杂度。

### 5.3 V8：多 tier、反馈、SSA 和 deoptimization

V8 先生成 Ignition bytecode并解释执行；Sparkplug 快速把 bytecode 编成 baseline machine code；Maglev 用 bytecode和 feedback 建立传统 CFG/SSA；TurboFan/Turboshaft承担更高峰值优化。Maglev 对对象 shape、类型和常量假设插入 guards/dependencies，并在可能 deopt 的 node 上附带 interpreter frame state，使运行时能够重建未优化状态。OSR 允许正在执行的函数在 interpreter/native tier 间切换。

#### V8 对本项目的参考

- unified JIT coordinator 应把 backend selection、compile timing、budget、artifact state、fallback 和 invalidation 放在统一状态机中。
- Runtime JIT 的缓存/安装 metadata 必须含 backend、target、bytecode identity、binding/runtime ABI 和恢复点版本。
- baseline native 与 optimizing native 可以是不同 backend；不应让第一版 LLVM JIT同时承担“最快编译”和“最高峰值性能”。

暂不采用：对象 shape speculation、通用 frame-state deopt、OSR、多 optimizing tier。它们对强类型 AngelScript 和 UE 插件第一阶段不是必要条件。

### 5.4 Graal/Truffle：specialized interpreter + partial evaluation

Truffle language implementation 通常以 AST 或 bytecode interpreter 定义 guest semantics。节点根据运行数据 specialization；Graal 通过 partial evaluation 把解释器与具体 guest program 合并、消除解释器开销，再生成优化机器码。assumption 失效或 guard 失败时 transfer 回 interpreter 并可重新特化。

#### Graal/Truffle 对本项目的参考

- 语义只定义一次是很强的维护目标。我们的 HIR evaluator/test oracle、C++ emitter 和未来 LLVM emitter 应共享 operation semantics/capability descriptors，减少三套独立 switch 漂移。
- backend boundary、slow path 和不可 partial-evaluate 的 runtime call 应显式标注。

不适合直接采用：Truffle 依赖 Java、Graal compiler、partial-evaluation-friendly interpreter、assumption/deopt runtime 和成熟 safepoint/GC 体系。把它接进 UE 插件等同于引入第二套语言 VM 平台。

## 6. 对当前四条性能路径的定位

### 6.1 Legacy Static AOT：bytecode → C++

优点：

- 任何只有 bytecode 的函数仍可尝试生成；
- 与 AngelScript JIT API/VM instruction contract 接近；
- 现有实现、测试和部署链已经成熟；
- 可作为 typed semantic emitter 的独立 oracle。

限制：

- 需要恢复表达式、类型和结构化控制流；
- 诊断更接近 VM opcode 而不是源语义；
- source-known build 仍承担信息丢失后的逆向成本。

结论：保留为兼容 backend 和 oracle，不再是唯一 Static AOT frontend。

### 6.2 Typed Semantic Static AOT：typed HIR → C++

优点：

- 直接消费 compiler-resolved type/call/control-flow semantics；
- 最容易产生稳定 C++、源级诊断和逐函数支持度；
- 不需要 executable-memory、runtime compiler 或 UE 平台 JIT 权限；
- 最适合 UFUNCTION 首个 vertical slice。

结论：继续按当前 OpenSpec 实现。第一版 HIR 保持 structured，不直接变成 LLVM SSA。

### 6.3 Angelsea Runtime JIT（规划）：bytecode → C → MIR → machine code

优点：

- 直接面向 AngelScript bytecode 和 `asIJITCompilerV2`；
- MIR 比完整 LLVM 小，支持 lazy/async 和 VM fallback；
- 核心 lowering 可保持 UE-agnostic。

需要 UE 的部分不是字节码翻译本身，而是插件生命周期、Build.cs/平台开关、可执行内存策略、热重载失效、调试/stack trace、原生绑定地址、GC/safepoint 和打包/平台合规。

结论：可接入，但“改改就行”只适用于 proof of concept。产品化仍需要 coordinator、ABI、回退、失效和平台测试。

### 6.4 LLVM Runtime JIT（规划）：bytecode 或 future typed CFG → LLVM IR

优点：

- 更成熟的优化、目标后端、object emission 和 debug/unwind 生态；
- 未来既可接 bytecode frontend，也可接 structured HIR 降出的 typed CFG。

成本：

- LLVM 依赖、版本、构建体积、启动时间、线程安全和平台合规；
- runtime materialization/ORC lifecycle；
- 与 UE 自带 LLVM/Clang 版本边界；
- 仍需自行定义 AngelScript ABI、VM exit、GC root 和异常/暂停语义。

结论：把 LLVM 视为 backend，不把 LLVM IR 视为第一份语言语义 IR。

## 7. 建议吸收进设计的具体规则

### 7.1 IR 分层

建议长期明确三层，而不是只有“AST 或 LLVM IR”二选一：

1. **Structured Typed Semantic HIR**：保留源级结构、解析类型、调用目标、source span、evaluation order、temporary/lifetime 和 unsupported reason。
2. **Backend-neutral typed CFG IR（未来）**：显式 basic block、edge、phi/merge、liveness、exception/suspend edge，可供优化与多 native backend 使用。
3. **Backend IR**：C++ AST/text、MIR、LLVM IR 或 architecture-specific IR。

当前变更只需要完整实现第 1 层和 C++ backend；第 2 层作为未来扩展点，不应阻塞 v1。

### 7.2 Capability 与 fallback

- capability key 至少应包含 node kind、resolved type category、call kind、ABI kind、lifetime/GC need、exception/suspend behavior 和 target capability。
- support analyzer 与 emitter 必须共用 capability table 或同一 lowering registry。
- 每个 rejected function 都输出稳定 reason code、source span 和 backend name。
- fallback 是函数选择结果；如果 claimed-supported function 在 emit 中失败，应作为 backend defect 失败，而不是静默退回 legacy。

### 7.3 调用和对象生命周期

- call node 保存稳定 function identity、resolved declaration、calling convention、return/parameter passing mode 和 side-effect flags。
- UObject/UStruct/引用类型生命周期必须落到 helper/ABI 层；HIR 不嵌入 UE 头文件或对象地址。
- temporary construction/destruction、reference ownership、out/ref 和异常清理顺序必须显式。
- RPC/reflective fallback、latent/suspend、delegate、virtual/interface dispatch 是独立 call kind，不能都压成 raw function pointer。

### 7.4 缓存与内容身份

借鉴 daScript、Numba、Julia/Dart，native artifact key 至少应包含：

```text
source/module semantic identity
+ resolved function signature
+ relevant dependency/binding ABI identity
+ HIR/schema or bytecode version
+ backend name and backend codegen version
+ target triple / CPU feature policy
+ optimization and safety options
+ plugin/runtime compatibility version
```

当前 ephemeral HIR 不要求持久化，但任何生成 C++、object、DLL 或 runtime code cache 都必须记录上述身份。mtime 只能作为快速失效提示，不能作为唯一 correctness key。

### 7.5 验证

- Semantic backend 与 legacy backend 做相同输入的 differential execution。
- Runtime JIT 与 VM 做 bytecode-PC 对齐的 differential execution和 forced-exit 测试。
- 每个 backend 都测试 unsupported reason stability、cache invalidation、hot reload、异常/abort、GC-visible reference 和 mixed-mode call。
- benchmark 分开记录 compile latency、code size、startup、steady-state、peak、fallback ratio 和 native coverage，不只记录单一运行时间。

## 8. 哪些现在不要做

当前 typed semantic Static AOT v1 不应引入：

- speculative runtime type guards；
- interpreter frame reconstruction/deoptimization；
- OSR；
- trace selection/side trace；
- whole-program persistent HIR schema；
- 把 structured control flow 提前强制改成 SSA；
- 把 LLVM 作为唯一 frontend/backend 边界；
- 因为某个表达式不支持就静默回落、掩盖 emitter bug。

这些能力可以在真实 benchmark 和 coverage 表明必要时，由后续 Runtime JIT coordinator 或独立 typed CFG/backend OpenSpec 逐步增加；当前 StaticJIT change 不引入 runtime coordinator。

## 9. 本地参考价值排序

### 第一梯队：应长期保留源码

1. **Cython**（已拉取 `Reference/Cython`）
   - typed AST → C/C++ Static AOT emitter 的最近邻。
   - 重点看 `Cython/Compiler/Pipeline.py`、`Nodes.py`、`ExprNodes.py`、`ModuleNode.py`、`Code.py`。
2. **daScript**（已存在 `Reference/daScript`）
   - 最完整覆盖 typed AST、tree interpreter、C++ AOT、LLVM JIT、逐函数 fallback、semantic hash cache 和 mixed-mode dispatch。
   - 重点看 `modules/dasLLVM/daslib/llvm_jit*.das`、`src/builtin/module_jit.cpp`、AOT emitter 和 `SimFunction`。
3. **Numba**（已拉取 `Reference/numba`）
   - typed IR/LLVM pass 分层、specialization、object cache 和 error/fallback contract 最清楚。
   - 重点看 `numba/core/compiler.py`、`typed_passes.py`、`lowering.py`、`codegen.py`、`caching.py`。
4. **Luau**（已拉取 `Reference/luau`）
   - runtime bytecode native codegen、VM exit、guards、x64/A64 lowering 和 code lifecycle 的最近邻。
   - 重点看 `CodeGen/src/IrBuilder.cpp`、`BytecodeAnalysis.cpp`、`IrTranslation.cpp`、`IrLowering*.cpp`、`CodeGenContext.cpp`。

### 第二梯队：官方源码链接足够

- **Dart SDK**：Kernel/backend separation 很有价值，但仓库约 1.6 GiB；只保留 `pkg/kernel` 和 VM compiler 精确链接。
- **Julia**：typed SSA、specialization、GC/ABI 很有价值，但整库较大且与 AngelScript 语言模型差异明显；官方 compiler devdocs 足够日常研究。
- **Haxe/hxcpp**：可补充 typed source-to-C++ target 细节，但与 Cython/daScript 重叠较大；需要时再拉两个仓库。

### 第三梯队：不建议为本变更整库拉取

- **V8**、**Graal**：体量和运行时复杂度过高，用官方设计文档和精确源码链接即可。
- **LuaJIT**：仓库很小，若 Runtime JIT 进入 trace/guard/deopt 阶段再拉取；当前 Angelsea/Luau 已覆盖更接近的需求。

## 10. 最终判断

现有 typed semantic AOT 方向是对的，而且比“所有 native backend 都只吃 bytecode”更适合 source-known、强类型、生成 C++ 的 Unreal AngelScript 构建流程。

最重要的补强不是把第一版 HIR 换成 LLVM IR，而是：

1. 明确 structured HIR → future typed CFG → backend IR 的三层关系；
2. 把 call ABI、lifetime、exception/suspend、GC 和 fallback reason 变成 typed lowering contract；
3. 让 support analysis 与 emitter 共享 capability 定义；
4. 用 semantic/content identity 管理生成物和未来 runtime cache；
5. 只在 provider entry、artifact identity 和诊断概念确实兼容时复用公共契约；Static AOT 不接入 Runtime JIT 的 hotness、code-memory、invalidation coordinator，也不强迫两者共享输入 IR。

这既保留了当前 StaticJIT 的稳定性，也为 Angelsea MIR、LLVM Runtime JIT 和未来 typed CFG 优化留出了清晰扩展点。
