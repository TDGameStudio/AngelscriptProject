# Diff_DaslangAngelseaJIT — Daslang LLVM JIT 原理、LLVM 接入方式与 Angelsea 对比

> **所属前缀**：Diff_（外部参考实现差异分析）
>
> **研究范围**：Daslang（原 daScript）的树解释器、LLVM JIT、LLVM-C 动态绑定、运行时安装与回退机制，以及 Angelsea 的 AngelScript 字节码 JIT。
>
> **结论用途**：为 AngelscriptProject 的运行期 JIT / StaticJIT 演进提供架构参考；本文只记录原理和可借鉴点，不表示已决定引入任何第三方 JIT。
>
> **分析日期**：2026-08-12
>
> **参考版本**：
> - `Reference/daScript`：`ae21253fea2b8184f81c00013f2684c98c31174d`
> - `Reference/angelsea`：`1d367d431cdfd7e5e51b2341312078fd40cc10a4`

---

## 一、结论摘要

1. **Daslang 和 daScript 是同一个项目。** 项目已经从 daScript 更名为 Daslang，但仓库名、C++ API、命名空间和大量文件仍保留旧名称。
2. **Daslang 的基础解释器不是字节码 VM，而是 SimNode 树解释器。** 编译后的函数由 `SimNode` 执行树表示，解释器递归/分派执行节点的 `eval()`。
3. **Daslang 的 LLVM JIT 不是从字节码生成机器码。** 当前主路径是：

   ```text
   Typed AST（Function / Expression）
       → LlvmJitVisitor
       → LLVM IR
       → LLVM 优化与机器码生成
       → 本机函数地址
   ```

4. **正常 LLVM IR 生成也不是从 SimNode 翻译。** SimNode 用于解释执行、运行时上下文、部分语义哈希、JIT 入口覆盖和解释器回退；LLVM emitter 直接访问保留下来的 typed AST。
5. **Daslang JIT 确实在运行时执行，但更准确地说是 load/simulate-time whole-function JIT。** 它在 `simulate()` 创建运行时上下文后由 `jit_llvm` simulate macro 触发，通常编译所有符合条件的已使用函数，而不是运行一段时间后按热点编译。
6. **Daslang 主运行库不直接链接 LLVM。** `dasLLVM` 通过自动生成的 `.das` LLVM-C FFI 声明和内置 `dasbind`，在运行时加载固定名 `LLVM.dll` 并解析函数地址。
7. **Angelsea 才是典型的 AngelScript 字节码 JIT。** 它读取 `asBC_*` 字节码，经 `bytecode2c → C → c2mir → MIR → native` 生成机器码，并通过 AngelScript JIT 接口安装。
8. **对 AngelscriptProject 而言，Angelsea 的字节码入口更容易接入现有 AngelScript VM；Daslang 更值得借鉴的是 AST 级代码生成、函数粒度混合执行、内容寻址 DLL 缓存和 JIT 安装/恢复模型。**

---

## 二、先澄清名称：Daslang 与 daScript 不是两个 JIT

Daslang 是 daScript 更名后的名称。当前源码仍存在这些旧名称：

- 仓库目录仍为 `daScript`；
- C++ 命名空间和 include 路径仍使用 `daScript`；
- C++ runtime 类型仍大量使用 `das` 前缀；
- 命令、构建变量和模块路径混合使用 `daslang`、`dasLLVM`、`daScript`。

因此，本文所说的“Daslang JIT”和旧资料里的“daScript JIT”指的是同一条 LLVM 后端演进线，不应理解为两套语言或两个并列 JIT。

证据：

- `Reference/daScript/skills/project_overview.md`
- `Reference/daScript/AGENTS.md`

---

## 三、Daslang 的三种执行层

Daslang 当前可以从三个层面理解执行方式。

### 3.1 SimNode 树解释器

基础执行模式是：

```text
.das 源码
    ↓
解析、类型推导、宏展开、语义检查、优化
    ↓
Typed AST
    ↓ simulate
SimFunction + SimNode 执行树
    ↓
SimNode::eval(Context&)
```

每个操作由一个或多个 SimNode 表示。函数、表达式、循环和调用不会被统一编码成一段线性 bytecode 再由 opcode switch 执行。

参考：

- `Reference/daScript/doc/source/reference/embedding/quickstart.rst:19`
- `Reference/daScript/skills/design_philosophy.md:21`

### 3.2 C++ AOT

Daslang 还支持把脚本生成 C++，再交给普通 C++ 工具链编译和链接。它属于离线 AOT，不是本文重点。

### 3.3 LLVM JIT / LLVM artifact emission

LLVM 后端直接遍历 typed AST 生成 LLVM IR。相同后端随后可以走多种物化路径：

- LLVM execution engine 内存 JIT；
- 目标文件输出；
- 缓存动态库输出；
- 可执行文件输出；
- WebAssembly 交叉编译；
- LLVM-AOT object 输出。

这些路径共享 AST → LLVM IR 前端，只在后面的优化、目标代码发射、链接和安装方式上不同。

---

## 四、Daslang LLVM JIT 的完整流水线

### 4.1 总体流程

```text
┌──────────────────────────────────────────────────────────────────────┐
│ Daslang 编译前端                                                     │
│ source → parse → infer → macro expansion → semantic check → optimize │
└──────────────────────────────┬───────────────────────────────────────┘
                               │
                               ▼
                    Typed AST / Program / FunctionPtr
                               │
                               ▼
                    simulate(program, context)
                               │
                    ┌──────────┴───────────┐
                    │                      │
                    ▼                      ▼
          SimFunction + SimNode       jit_llvm simulate macro
          解释器基础执行表示                 │
                                           ▼
                                     run_jit(prog, ctx)
                                           │
                              收集可 JIT 的 FunctionPtr
                                           │
                              DisableJitVisitor 预检查
                                  ┌────────┴────────┐
                                  │                 │
                             支持该函数          不支持该函数
                                  │                 │
                                  ▼                 └──→ 保留 SimNode 解释
                         LlvmJitVisitor 遍历 AST
                                  │
                                  ▼
                               LLVM IR
                                  │
                          verify / optimize
                                  │
                      ┌───────────┴────────────┐
                      │                        │
                MCJIT 内存机器码       object → linker → DLL
                      │                        │
                      └───────────┬────────────┘
                                  ▼
                          取得本机函数地址
                                  │
                                  ▼
                   instrument_jit(SimFunction, address)
                                  │
                                  ▼
                       SimNode_Jit / jitFunction
```

### 4.2 JIT 触发时机

LLVM JIT 不是 compile front-end 的固定输出步骤，而是一个 simulate macro：

```das
[simulate_macro(name="jit_llvm")]
class JIT_LLVM : AstSimulateMacro {
    def override simulate(prog : Program?; var ctx : Context?) : bool {
        return run_jit(prog, ctx)
    }
}
```

参考：`Reference/daScript/modules/dasLLVM/daslib/llvm_macro.das:46`

C++ 侧 `Program::simulate()` 的关键时序是：

1. 为已使用函数构造 `SimFunction`；
2. 调用函数的 `simulate(context)` 建立 SimNode 树；
3. 计算与函数语义相关的哈希；
4. 执行已注册的 simulate macros；
5. `jit_llvm` 在这个阶段取得 `Program` 和 `Context`，运行 LLVM 后端。

参考：

- `Reference/daScript/src/ast/ast_simulate.cpp:3830`
- `Reference/daScript/src/ast/ast_simulate.cpp:4074`
- `Reference/daScript/src/ast/ast_simulate.cpp:4089`

因此它是“运行时 JIT”，但不是通常意义上的热点 JIT：

```text
热点 JIT：
bytecode 先执行 → 累计调用/循环热度 → 编译热点函数或 trace

Daslang 默认 LLVM JIT：
compile 完成 → simulate/load → 编译符合条件的已使用函数
```

### 4.3 JIT 的输入是 typed AST

核心 emitter 定义为：

```das
class LlvmJitVisitor : AstVisitor
```

它直接处理：

- `FunctionPtr`
- `Expression`
- `Variable`
- `TypeDecl`
- `ExprBlock`
- `ExprCall`
- `ExprAt`
- `ExprOp2`
- `ExprWhile`
- `ExprFor`
- 其他 typed expression 节点

`generate_llvm(...)` 创建 `LlvmJitVisitor` 后，直接对 `FunctionPtr` 调用 AST `visit()`：

```text
FunctionPtr
    ↓ visit
LlvmJitVisitor
    ↓ LLVMBuild* C API
LLVM IR
```

参考：

- `Reference/daScript/modules/dasLLVM/daslib/llvm_jit.das:247`
- `Reference/daScript/modules/dasLLVM/daslib/llvm_jit.das:7731`
- `Reference/daScript/modules/dasLLVM/daslib/llvm_jit_run.das:410`

### 4.4 SimNode 不是 LLVM IR 的主输入

SimNode 在 JIT 路径中仍然重要，但职责不同：

- 提供解释器基础实现；
- 已 simulate 函数在 `Context` 中的运行时表示；
- 参与函数语义哈希和缓存身份；
- 作为 JIT 安装和移除的覆盖点；
- JIT 不支持或安装失败时作为 fallback；
- 为少量 interop 场景提供桥接。

因此准确关系是：

```text
Typed AST ───────────────→ LLVM IR
    │
    └─ simulate ─────────→ SimNode tree
                              │
                              ├─ interpreter fallback
                              └─ 被 SimNode_Jit 覆盖入口
```

不应描述成：

```text
SimNode → LLVM IR       // 对正常函数生成而言不准确
bytecode → LLVM IR      // Daslang 没有这层传统 bytecode
```

---

## 五、Daslang 是怎么接入 LLVM 的

这一部分是 Daslang LLVM 设计最有辨识度的地方：**libDaScript 不直接链接 LLVM，LLVM-C API 通过 Daslang 自己的动态 FFI 系统暴露给 `.das` 后端。**

### 5.1 分层结构

```text
┌──────────────────────────────────────────────────────────────┐
│ CMake / 发布层                                               │
│ 定位或下载 LLVM 22.1.5，统一放到 <das-root>/lib/LLVM.dll      │
│ Windows 另准备 lld-link.exe                                  │
└──────────────────────────┬───────────────────────────────────┘
                           │
                           ▼
┌──────────────────────────────────────────────────────────────┐
│ LLVM-C FFI 声明层（.das，自动生成）                          │
│ llvm_struct.das / llvm_enum.das / llvm_const.das             │
│ llvm_func.das                                                │
│ [extern(cdecl, name="LLVM...", library="LLVM.dll")]         │
└──────────────────────────┬───────────────────────────────────┘
                           │
                           ▼
┌──────────────────────────────────────────────────────────────┐
│ dasbind（C++ 内置模块）                                      │
│ loadDynamicLibrary("LLVM.dll")                              │
│ getFunctionAddress(handle, "LLVM...")                       │
│ 生成/选择 ABI wrapper，并把函数作为 BuiltInFunction 暴露      │
└──────────────────────────┬───────────────────────────────────┘
                           │
                           ▼
┌──────────────────────────────────────────────────────────────┐
│ Daslang LLVM helper 层                                      │
│ llvm_boost.das / llvm_targets.das / llvm_dsl.das             │
│ 封装 LLVMContext、Module、Builder、TargetMachine、类型等       │
└──────────────────────────┬───────────────────────────────────┘
                           │
                           ▼
┌──────────────────────────────────────────────────────────────┐
│ Daslang JIT 后端                                            │
│ llvm_jit.das / llvm_jit_common.das / llvm_jit_run.das        │
│ AST visitor → LLVM IR → optimize → emit/install              │
└──────────────────────────┬───────────────────────────────────┘
                           │
                           ▼
┌──────────────────────────────────────────────────────────────┐
│ Daslang runtime 回接层（C++ jit 模块）                       │
│ runtime helper 地址映射、JitFunction ABI、instrument_jit      │
│ SimFunction::jitFunction / SimNode_Jit                       │
└──────────────────────────────────────────────────────────────┘
```

### 5.2 构建和分发 LLVM 动态库

`modules/dasLLVM/CMakeLists.txt` 当前目标版本为 LLVM `22.1.5`：

1. 优先查找系统 LLVM；
2. 如果系统包布局不符合要求，则下载项目发布的预构建包；
3. 将跨平台 LLVM shared library 统一复制/命名为：

   ```text
   <das-root>/lib/LLVM.dll
   ```

4. Windows 额外安装 `lld-link.exe`，用于 JIT 目标文件链接为 DLL/EXE；
5. CMake 只负责准备运行时库和安装 `.das` 模块，不把 LLVM 静态链接进 libDaScript。

顶层选项为：

```cmake
option(DAS_LLVM_DISABLED "Disable dasLLVM (llvm bindings)" ON)
```

需要 LLVM 后端的构建显式使用：

```text
-DDAS_LLVM_DISABLED=OFF
```

参考：

- `Reference/daScript/CMakeLists.txt:31`
- `Reference/daScript/modules/dasLLVM/CMakeLists.txt`
- `Reference/daScript/modules/dasLLVM/README.md`

### 5.3 `.das_module` 注册脚本模块路径

`modules/dasLLVM/.das_module` 的 `initialize(project_path)` 不注册一个大型 C++ LLVM module，而是注册一批 `.das` 模块路径：

```text
llvm/daslib/llvm_boost
llvm/daslib/llvm_targets
llvm/daslib/llvm_jit
llvm/daslib/llvm_jit_common
llvm/daslib/llvm_jit_run
llvm/daslib/llvm_macro
llvm/bindings/llvm_func
llvm/bindings/llvm_struct
llvm/bindings/llvm_enum
llvm/bindings/llvm_const
...
```

这些路径通过 `register_native_path()` 注册。用户脚本执行：

```das
require llvm/daslib/llvm_macro
```

时，Daslang module resolver 就能找到对应 `.das` 文件。

参考：`Reference/daScript/modules/dasLLVM/.das_module`

### 5.4 LLVM-C API 绑定是自动生成的 `.das` 声明

`bindings/llvm_func.das` 的典型内容是：

```das
[extern(cdecl, name="LLVMContextCreate", library="LLVM.dll")]
def LLVMContextCreate() : LLVMOpaqueContext? {}

[extern(cdecl, name="LLVMModuleCreateWithNameInContext", library="LLVM.dll")]
def LLVMModuleCreateWithNameInContext(
    ModuleID : string implicit;
    C : LLVMOpaqueContext? implicit
) : LLVMOpaqueModule? {}

[extern(cdecl, name="LLVMGetFunctionAddress", library="LLVM.dll")]
def LLVMGetFunctionAddress(
    EE : LLVMOpaqueExecutionEngine? implicit;
    Name : string implicit
) : uint64 {}
```

对应 opaque handles、枚举和常量分别位于：

- `llvm_struct.das`
- `llvm_enum.das`
- `llvm_const.das`

这批绑定由 `modules/dasClangBind/bind/bind_llvm.das` 使用 libclang 从 `llvm-c/` 头文件生成，而不是手工逐个维护。

参考：

- `Reference/daScript/modules/dasLLVM/bindings/llvm_func.das:1`
- `Reference/daScript/modules/dasLLVM/bindings/llvm_struct.das`
- `Reference/daScript/modules/dasLLVM/README.md` 的 “Regenerating bindings”

### 5.5 `dasbind` 负责动态装载和符号解析

`[extern(...)]` 注解由 C++ 内置模块 `dasbind` 实现。

它的处理过程是：

```text
解析 extern 注解
    │ name="LLVMContextCreate"
    │ library="LLVM.dll"
    │ calling convention=cdecl
    ▼
bindDynamicLibrary("LLVM.dll")
    │
    ├─ 检查已经加载的 library handle
    ├─ 尝试系统动态库搜索
    ├─ 尝试 Program policies.dll_search_paths
    └─ 尝试 <das-root>/lib/LLVM.dll
    ▼
getFunctionAddress(handle, "LLVMContextCreate")
    ▼
按 Daslang 函数签名选择 ABI wrapper
    ▼
创建 DasBindFunction / BuiltInFunction proxy
    ▼
.das 代码像普通函数一样调用 LLVMContextCreate()
```

关键实现：

- `bindDynamicLibrary()`：`Reference/daScript/src/builtin/module_builtin_dasbind.cpp:166`
- `getDllAddress()`：`Reference/daScript/src/builtin/module_builtin_dasbind.cpp:198`
- `ExternFunctionAnnotation`：`Reference/daScript/src/builtin/module_builtin_dasbind.cpp:380`
- annotation apply 和 proxy 构造：`Reference/daScript/src/builtin/module_builtin_dasbind.cpp:446`

这意味着 LLVM 接入点并非：

```text
libDaScript --link--> libLLVM
```

而是：

```text
Daslang .das backend
    --extern FFI / dasbind-->
LLVM.dll 的 LLVM-C API
```

项目源码中的注释也明确说明：`libDaScript never links LLVM`。

### 5.6 `llvm_boost.das` 把原始 C API 封装成后端工具层

直接使用生成的 LLVM-C 声明比较繁琐，因此 `llvm_boost.das` 等模块继续提供：

- `PrimitiveTypes`：缓存当前 `LLVMContext` 中常用类型；
- `LLVMCreateJITCompilerForModule` 等带错误处理的包装；
- function type / struct type 构造辅助；
- attribute、target、debug metadata、pass builder 辅助；
- Daslang 类型到 LLVM 类型的转换。

JIT 后端通过：

```das
require llvm/daslib/llvm_boost
require llvm/daslib/llvm_jit_common
require llvm/daslib/llvm_jit_intrin
```

使用这些高级封装。

### 5.7 初始化 LLVM context、module 和 execution engine

`init_jit_state()` 负责初始化一次 emitter state：

```das
LLVMLinkInMCJIT()
LLVMInitializeAllTargetInfos()
LLVMInitializeAllTargets()
LLVMInitializeAllTargetMCs()
LLVMInitializeAllAsmPrinters()

g_ctx = LLVMContextCreate()
g_prim_t = new PrimitiveTypes(g_ctx)
g_mod = LLVMModuleCreateWithNameInContext(module_name, g_ctx)
LLVMCreateJITCompilerForModule(g_engine, g_mod, cg_opt_level)
```

如果是交叉编译目标，还会在构建 IR 之前设置 target triple 和 data layout，避免 pointer size 等目标属性在常量折叠时使用宿主值。

参考：`Reference/daScript/modules/dasLLVM/daslib/llvm_jit_common.das:671`

### 5.8 Daslang runtime helper 如何暴露给生成的机器码

生成的 JIT 代码不能只执行纯算术。它还需要调用 Daslang runtime helper，例如：

- iterator 操作；
- debug/line info；
- exception/panic；
- heap/GC/runtime context；
- 外部函数解析；
- SimNode interop；
- 字符串、数组、table 等运行时操作。

内存 MCJIT 路径为这些 helper 在 LLVM module 中建立 declaration，再通过：

```das
LLVMAddGlobalMapping(g_engine, llvmFunction, nativeFunctionAddress)
```

把 LLVM 符号映射到 C++ runtime 的真实地址。

通用辅助是：

```das
def jit_add_extern(name, typ, fnAddr, attrs) {
    var f = LLVMAddFunctionWithType(g_mod, name, typ)
    LLVMAddGlobalMapping(g_engine, f, fnAddr)
    LLVMAddAttributesToFunction(f, attrs)
    return f
}
```

参考：`Reference/daScript/modules/dasLLVM/daslib/llvm_jit_common.das:553`

所以 LLVM 接入是双向的：

```text
方向一：Daslang 后端调用 LLVM
Daslang .das → dasbind → LLVM-C API → LLVM

方向二：LLVM 生成代码调用 Daslang runtime
LLVM declaration → LLVMAddGlobalMapping → C++ runtime helper address
```

DLL 模式不能依赖当前进程中 MCJIT 的临时 global mapping，因此会生成/初始化外部函数地址表，由 runtime 在 DLL 加载时解析并填充。`jit_init_extern_function()` 会按 module 和 mangled name 查找内置函数；对于 `dasbind` 外部函数还会转到 `__dasbind_resolve`。

参考：

- `Reference/daScript/src/builtin/module_jit.cpp:441`
- `Reference/daScript/modules/dasLLVM/daslib/llvm_exe.das:165`
- `Reference/daScript/modules/dasLLVM/daslib/llvm_jit_run.das:997`

### 5.9 生成函数必须服从 Daslang JIT ABI

Daslang 的本机 JIT 函数类型定义为：

```cpp
typedef vec4f (*JitFunction)(Context *, vec4f *, void *);
```

三个参数分别承载：

- 当前 `Context*`；
- 参数区 `vec4f*`；
- 复杂返回值位置 `CMRES`。

参考：`Reference/daScript/include/daScript/misc/arraytype.h:40`

LLVM emitter 为每个脚本函数生成符合该 ABI 的入口。因此从 MCJIT 或 DLL 取回的地址可以被强制转换为 `JitFunction` 并装入运行时。

### 5.10 本机地址如何装回 Daslang

地址来源有两种：

```text
DLL 模式：dll.get_function_address(exportedName)
内存模式：LLVMGetFunctionAddress(g_engine, exportedName)
```

参考：`Reference/daScript/modules/dasLLVM/daslib/llvm_jit.das:7899`

之后 `run_jit()` 找到对应 `SimFunction`，调用：

```das
instrument_jit(nativeAddress, simFunction, sourceLocation, context)
```

参考：`Reference/daScript/modules/dasLLVM/daslib/llvm_jit_run.das:1006`

C++ 侧 `das_instrument_jit()`：

1. 保存原始 `simfn->code` 和 AOT 状态；
2. 创建 `SimNode_Jit`；
3. 把本机地址转换为 `JitFunction`；
4. 用 `SimNode_Jit` 覆盖函数执行入口；
5. 同时维护 `simfn->jitFunction` 供 JIT-to-JIT 快速调用。

参考：`Reference/daScript/src/builtin/module_jit.cpp:184`

执行时：

```cpp
vec4f SimNode_Jit::eval(Context & context) {
    return func(&context, nullptr, nullptr);
}
```

如果安装失败或函数不再适用，则 `remove_jit()` 恢复原始 SimNode。

---

## 六、缓存 DLL 与内存 JIT 不是两套前端

Daslang LLVM 后端有两种常见的运行期物化方式。

### 6.1 内存 MCJIT

```text
Typed AST
    → LLVM IR
    → MCJIT
    → LLVMGetFunctionAddress
    → instrument_jit
```

特点：

- 本次进程直接取得机器码地址；
- runtime helpers 可用 `LLVMAddGlobalMapping` 映射；
- 进程退出后机器码通常不保留。

### 6.2 内容寻址 DLL 缓存

```text
Typed AST + codegen version + flags + target
    ↓ semantic/content hash
.jitted_scripts/<namespace>/<hash>.dll
    ├─ 已存在且符号完整 → 直接加载
    └─ 未命中 → LLVM IR → object → linker → DLL → 加载
```

特点：

- 第一次启动执行 LLVM codegen 和链接；
- 后续相同输入可直接加载缓存 DLL；
- DLL 名包含 AST/函数语义、代码生成版本和关键选项形成的哈希；
- 可进一步按 Daslang module 分区生成和缓存 object；
- DLL runtime externs 需要加载时解析，不能依赖 MCJIT global mapping。

主流程位于：`Reference/daScript/modules/dasLLVM/daslib/llvm_jit_run.das:843`

这两条路径共享相同的 AST lowering，因此不应描述为“两个 JIT 编译器”。

---

## 七、函数选择、fallback 与混合执行

### 7.1 不是热点计数驱动

`run_jit()` 收集 `FunctionPtr`，根据 policy、`[jit]`、`[no_jit]` 和 visitor 支持情况决定函数集合。默认策略更接近“JIT 所有符合条件的已使用函数”。

它没有以调用次数为核心的默认热点 tier，也不是 tracing JIT。

### 7.2 `DisableJitVisitor` 做完整性预检

在生成 LLVM IR 前，`DisableJitVisitor` 检查函数 AST 是否包含后端尚未实现或不安全的结构。

```text
完整支持 → 进入 LLVM codegen
不支持   → 不安装 JIT，继续使用 SimNode interpreter
```

这避免把“部分已生成但语义不完整”的函数装入运行时。

### 7.3 混合调用

运行时可以同时存在：

```text
JIT function A
    ├─ 直接调用 JIT function B
    └─ 通过 Context 调用 interpreted function C
```

`SimFunction` 中同时存在 `code`、`aotFunction` 和 `jitFunction` 概念，dispatch 可在 AOT、JIT 和 interpreter 之间选择。

参考：

- `Reference/daScript/include/daScript/simulate/simulate.h:79`
- `Reference/daScript/include/daScript/simulate/aot.h:2817`
- `Reference/daScript/src/builtin/module_jit.cpp:212`

---

## 八、Angelsea：AngelScript 字节码 JIT

如果比较的是前面引入的 Angelsea 和 Daslang，两者的入口层完全不同。

### 8.1 Angelsea 流水线

```text
AngelScript source
    ↓
AngelScript compiler
    ↓
asBC_* bytecode
    ↓
asBC_JitEntry / 调用次数计数
    ↓ 达到阈值或 eager
bytecode2c
    ↓
C source
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

关键证据：

- `asIJITCompilerV2` 实现：`Reference/angelsea/include/angelsea/jit.hpp:17`
- `GetByteCode()` 和大小检查：`Reference/angelsea/src/angelsea/detail/mirjit.cpp:225`
- 字节码遍历与 C 代码生成：`Reference/angelsea/src/angelsea/detail/bytecode2c.cpp:64`
- c2mir/MIR 机器码生成：`Reference/angelsea/src/angelsea/detail/mirjit.cpp:308`
- 安装本机函数：`Reference/angelsea/src/angelsea/detail/mirjit.cpp:441`

### 8.2 惰性触发

Angelsea 会为函数安装 JIT entry counter：

```text
调用函数
    ↓
hits--
    ├─ hits > 0 → 继续 VM
    └─ hits == 0 → 启动 bytecode → native 转换
```

默认不是立即编译全部函数；配置可以选择 eager，也支持异步编译和等待入口。

参考：

- `Reference/angelsea/src/angelsea/detail/mirjit.cpp:52`
- `Reference/angelsea/src/angelsea/detail/mirjit.cpp:98`
- `Reference/angelsea/include/angelsea/config.hpp:105`

### 8.3 fallback 粒度

Angelsea 翻译字节码时：

- 可直接转换的 bytecode 生成 C/MIR；
- 某些调用可以直接走 JIT-to-JIT；
- 不支持或无法直接转换的路径可回到 AngelScript VM/helper；
- JIT 编译失败时函数继续解释执行。

因此它与 AngelScript VM 的耦合点是 bytecode ABI、寄存器/栈布局和 JIT entry protocol。

---

## 九、Daslang 与 Angelsea 对比

| 维度 | Daslang / daScript LLVM JIT | Angelsea |
|---|---|---|
| 语言执行底座 | SimNode 树解释器 | AngelScript 字节码 VM |
| JIT 主输入 | Typed AST | `asBC_*` bytecode |
| 是否从 SimNode 转 LLVM | 正常路径不是 | 不适用 |
| 代码生成器实现语言 | 大量 backend/orchestration 用 Daslang 编写 | C++ |
| LLVM/MIR 接入 | `.das` LLVM-C FFI → `LLVM.dll` | C 生成后交给 c2mir/MIR |
| 触发时机 | `simulate/load` 阶段 | 调用计数阈值或 eager |
| 热点机制 | 默认无热点 tier | 有函数调用计数 |
| IR | LLVM IR | C 作为过渡表示，再转 MIR |
| 本机代码物化 | MCJIT、object、DLL、EXE、Wasm | MIR native code generator |
| 持久缓存 | 内容寻址 DLL / 可选分区 object cache | 以运行期函数 JIT 为主 |
| 不支持语义 | 函数级回退 SimNode | VM/helper 回退 |
| 运行时安装 | `instrument_jit` / `SimNode_Jit` / `jitFunction` | AngelScript `SetJITFunction` |
| 与语言前端耦合 | 高，需要稳定 typed AST | 较低，依赖 bytecode/JIT API |
| 接入 AngelscriptProject 难度 | 需要暴露和长期维护 AS typed AST 后端 | 更贴合 AS 现有 JIT 接口 |

---

## 十、对 AngelscriptProject 的启示

### 10.1 Angelsea 更接近可直接接入的运行期 JIT

现有 AngelScript VM 已提供基于函数 bytecode 和 JIT function pointer 的扩展边界。Angelsea 的架构天然沿用该边界：

```text
asCScriptFunction bytecode
    ↓
外部 JIT provider
    ↓
asJITFunction / JIT binding
```

不过实际引入仍需审查：

- 当前项目 fork 是 AngelScript 2.33 WIP lineage + selective 2.38 backports；
- Angelsea 使用的 JIT V2/API 和目标 upstream 版本是否与本 fork 一致；
- UE 平台、构建配置、shipping/cook、安全策略和第三方许可证；
- UObject handle、异常、GC、调试器、CodeCoverage、HotReload 和 StaticJIT provider 生命周期；
- 现有统一 JIT binding 的 VM/Raw/Parms 多入口协议。

### 10.2 Daslang AST JIT 不适合直接移植

直接复制 Daslang AST JIT 需要 AngelScript：

- 暴露稳定 typed AST；
- AST 生命周期延伸到 runtime JIT 阶段；
- 为全部 AngelScript 表达式和类型维护 LLVM lowering；
- 重建 VM 栈、对象 handle、GC、异常和调试语义；
- 让 Unreal 绑定、反射调用和 RPC 等路径进入同一 AST backend；
- 让 JIT backend 与当前 fork 编译器内部 AST 长期同步。

这比从 AngelScript 已有 bytecode/JIT 接口接入一个 provider 成本更高、侵入更深。

### 10.3 Daslang 值得借鉴的设计

即使不采用 typed-AST LLVM backend，以下机制仍有参考价值：

1. **JIT 完整性 visitor**：先验证整函数能力，再生成和安装。
2. **混合执行**：JIT-to-JIT 快路径，必要时回到通用 Context/VM。
3. **入口可恢复**：保存原解释入口，使 provider 可卸载或热重载。
4. **内容寻址本机缓存**：函数语义、codegen 版本、target 和优化配置共同构成 cache key。
5. **DLL extern 初始化表**：本机产物加载时由宿主统一解析 runtime helper。
6. **后端与 runtime 解耦**：宿主不强制静态链接 LLVM，通过窄接口提供能力。
7. **同一 IR 后端多产物**：内存 JIT、DLL、object、EXE 和 cross-target 共享 lowering。
8. **分区 object cache**：按脚本 module 分区，让局部变化只重编部分目标文件。
9. **明确的 JIT ABI**：机器码入口统一接收 Context、参数区和复杂返回值位置。

### 10.4 需要避免的错误类比

不要把下列概念混在一起：

```text
Daslang SimNode tree interpreter
    ≠ AngelScript bytecode VM

Daslang typed-AST LLVM JIT
    ≠ AngelScript bytecode JIT

Daslang load-time JIT
    ≠ hot tracing JIT

Daslang cached DLL
    ≠ 独立于 LLVM JIT 的另一套编译前端

AngelscriptProject StaticJIT
    ≠ 传统运行期 JIT
```

---

## 十一、LLVM.dll 体积、文件组成与部署依赖

本节记录当前参考版本使用的 LLVM 22.1.5 Win64 预构建包的实际体积，以及不同 JIT 模式下是否真的只需要一个 `LLVM.dll`。

### 11.1 实测版本与方法

当前 `Reference/daScript/modules/dasLLVM/CMakeLists.txt` 锁定：

```cmake
SET(DAS_LLVM_TARGET_VERSION "22.1.5")
SET(DAS_LLVM_SENTINEL_VERSION "${DAS_LLVM_TARGET_VERSION}-r4")
```

Win64 包来自 Daslang 官方 release：

- Release：<https://github.com/GaijinEntertainment/daScript/releases/tag/llvm-v22.1.5>
- Asset：<https://github.com/GaijinEntertainment/daScript/releases/download/llvm-v22.1.5/win64_llvm.tar.gz>
- CMake 中记录的 SHA-256：`7f67cbfa1b8196d13b020f8fea721c4c586204b3d0f9f0c73b289514a888c899`

本次实测方法：

1. 下载官方 `win64_llvm.tar.gz`；
2. 使用 `tar -tvzf` 读取归档内文件及未压缩大小；
3. 使用 `llvm-readobj --coff-imports LLVM.dll` 检查 PE 动态依赖；
4. 对照 Daslang CMake、`write_dll()`、`create_shared_library()` 和 `run_jit()` 确认各运行模式的真实需求。

### 11.2 官方 Win64 包实际大小

| 文件 | 字节数 | 约合 MiB | 主要用途 |
|---|---:|---:|---|
| `LLVM.dll` | `54,090,752` | `51.58 MiB` | LLVM-C API、IR、优化、目标代码生成和 MCJIT |
| `lld-link.exe` | `54,540,800` | `52.01 MiB` | Windows MSVC 路径下把 LLVM `.obj` 链接成缓存 DLL 或 EXE |
| `clang-cl.exe` | `88,396,288` | `84.30 MiB` | 工具链/预检备用，不是正常 Daslang JIT 必需项 |
| `win64_llvm.tar.gz` | `81,124,261` | `77.37 MiB` | 上述三个文件的压缩下载包 |

这里的 `77.37 MiB` 是压缩包大小，不是安装后的占用。三项完全解压后合计约 `187.9 MiB`，但普通 Daslang 安装不会把三项全部作为 JIT runtime 工具复制到最终 `bin/lib` 布局。

当前 CMake 的主要安装动作是：

```text
LLVM.dll     → <das-root>/lib/LLVM.dll
lld-link.exe → <das-root>/bin/lld-link.exe       // Windows
```

`clang-cl.exe` 虽包含在官方预构建归档中，但当前正常 JIT 路径不依赖它；CMake 注释只把它视为 FetchContent 源目录中的部分预检/后备场景工具。

因此，从“正常可重新生成缓存 DLL 的 Windows JIT 工具”角度看，主要新增体积是：

```text
LLVM.dll       51.58 MiB
lld-link.exe   52.01 MiB
────────────────────────
合计          103.59 MiB
```

这还不包括 Daslang runtime、import library、`.das` backend 模块和生成的 JIT cache。

### 11.3 只使用内存 JIT 时，LLVM 侧基本只需要一个 DLL

关闭 DLL cache、走内存 MCJIT 时：

```text
Typed AST
    → LLVM IR
    → LLVM MCJIT
    → LLVMGetFunctionAddress
    → instrument_jit
```

这条路径不产生需要外部链接的 `.jitted_scripts/*.dll`，因此 LLVM 侧的最小额外文件是：

```text
<das-root>/lib/LLVM.dll
```

不需要：

- `lld-link.exe`；
- `clang-cl.exe`；
- JIT cache 的 `.obj/.dll/.map` 文件。

代价是：

- 机器码只存在于当前进程；
- 下次启动需要重新生成；
- 不能利用内容寻址 DLL cache 缩短二次启动时间。

“只需要 `LLVM.dll`”只表示 LLVM 工具链侧最小为一个核心 shared library，并不表示整个程序只带这一个文件。宿主仍需要：

- `daslang.exe` 或嵌入式 `libDaScript`；
- `dasLLVM` 的 `.das` backend/bindings；
- 脚本和其他 Daslang modules；
- Windows 系统组件与 MSVC runtime。

在当前命令行实现中，关闭 DLL cache 的运行方式对应 `-jit-no-cache` 一类入口；普通 `-jit` 会沿 policy 选择默认 DLL cache 路径。

### 11.4 默认 DLL cache JIT 不只需要 LLVM.dll

动态 Daslang build 的默认缓存路径是：

```text
Typed AST
    → LLVM IR
    → LLVMTargetMachineEmitToFile
    → <hash>.obj
    → lld-link.exe
    → .jitted_scripts/<namespace>/<hash>.dll
    → LoadLibrary
    → instrument_jit
```

Windows MSVC 路径至少涉及：

```text
LLVM.dll
lld-link.exe
libDaScriptDyn_runtime.lib
对应的 Daslang runtime DLL
```

职责分别是：

- `LLVM.dll`：构造和优化 LLVM IR，发射 COFF object；
- `lld-link.exe`：将 object 链接成 JIT cache DLL；
- `libDaScriptDyn_runtime.lib`：为 JIT DLL 提供 Daslang runtime helper 的 import symbols；
- Daslang runtime DLL：JIT cache DLL 实际加载和执行时的符号提供者。

默认路径解析位于 `get_real_lib_linker_paths()`：

```text
linker:
    <das-root>/bin/lld-link.exe
    或 PATH 中的 lld-link

runtime import library:
    <das-root>/lib/<config>/libDaScriptDyn_runtime.lib
```

当 `linkWholeLib` 启用时，还可能加入：

```text
libDaScriptDyn.lib
```

参考：

- `Reference/daScript/src/builtin/module_jit.cpp:1064`
- `Reference/daScript/src/builtin/module_jit.cpp:1176`
- `Reference/daScript/modules/dasLLVM/daslib/llvm_jit_common.das:1046`

因此，如果目标机器需要在 source/config 变化后现场重新生成缓存 DLL，不能只复制 `LLVM.dll`。

### 11.5 MinGW 路径与 clang-cl.exe

Win64 预构建包中的 `LLVM.dll` 使用 MSVC `clang-cl` 构建，它报告的默认 target triple 是：

```text
x86_64-pc-windows-msvc
```

但如果宿主 Daslang 使用 MinGW 构建，JIT object 必须与 MinGW ABI/runtime 保持一致。当前代码会改用 `*-w64-windows-gnu` target triple，并使用：

```text
clang on PATH
libDaScriptDyn_runtime.dll.a
```

包内的 `clang-cl.exe` 是 MSVC-flavor，不能直接读取 MinGW `.dll.a` import libraries，所以当前代码明确不把它当 MinGW linker driver。

也就是说：

```text
MSVC Daslang build：lld-link.exe + .lib
MinGW Daslang build：clang on PATH + .dll.a
```

不能因为官方压缩包里有 `clang-cl.exe`，就认为所有 Windows 构建都只依赖这个工具。

### 11.6 缓存命中后能否移除 LLVM 和 linker

缓存命中时不会重新发射 object 或调用 linker，因此本次运行可能完全不执行 `lld-link.exe`。

但当前 `run_jit()` 的顺序是：

```text
计算 hash
    ↓
init_jit()
    ↓
创建 LLVM context/module/engine
    ↓
检查缓存 DLL
```

即 `init_jit()` 发生在 cache probe 之前。当前实现即使命中已有 DLL，仍会先调用 LLVM-C API，因此：

- `LLVM.dll` 仍需可加载；
- `lld-link.exe` 在纯 cache hit 时可以不被调用；
- 一旦 source、codegen version、target 或选项变化导致 cache miss，仍需要 linker；
- 不能安全地以“当前已经有缓存”为理由，从可能发生重编译的部署中删除 linker。

参考：`Reference/daScript/modules/dasLLVM/daslib/llvm_jit_run.das:843`

### 11.7 离线 object/EXE/AOT 模式可让最终用户完全不带 LLVM

如果 LLVM 只在构建机或 Cook 机上使用：

```text
构建机 / Cook 机：
Daslang AST → LLVM IR → object / DLL / EXE

最终用户：
只加载预生成本机产物和必要 runtime
```

那么最终用户可以不部署：

- `LLVM.dll`；
- `lld-link.exe`；
- `clang-cl.exe`；
- `.das` LLVM emitter/bindings。

代价是失去目标机器上修改脚本后重新 JIT 的能力。它更接近 offline LLVM-AOT/artifact generation，而不是 runtime JIT。

这也是 Unreal shipping 更容易接受的形态：开发机或 Cook 机承担 LLVM 体积和动态代码生成成本，最终包只包含已经验证和签名的目标产物。

### 11.8 LLVM.dll 本身仍依赖 MSVC Runtime

官方 `LLVM.dll` 并不是完全静态自包含的 PE。实际 import table 包含：

```text
VCRUNTIME140.dll
VCRUNTIME140_1.dll
MSVCP140.dll
api-ms-win-crt-runtime-l1-1-0.dll
api-ms-win-crt-heap-l1-1-0.dll
api-ms-win-crt-string-l1-1-0.dll
api-ms-win-crt-stdio-l1-1-0.dll
api-ms-win-crt-utility-l1-1-0.dll
api-ms-win-crt-convert-l1-1-0.dll
api-ms-win-crt-environment-l1-1-0.dll
api-ms-win-crt-math-l1-1-0.dll
api-ms-win-crt-time-l1-1-0.dll
KERNEL32.dll
ADVAPI32.dll
ntdll.dll
SHELL32.dll                 // delay import
ole32.dll                   // delay import
```

Windows 系统 DLL 和 Universal CRT 通常由系统提供；MSVC 构建的目标机器仍应满足 Microsoft Visual C++ 2015–2022 x64 Runtime。部署策略可以是：

- 安装对应 VC++ Redistributable；或
- 按微软允许的方式 app-local 部署所需 runtime DLL。

所以准确表述是：

> 内存 JIT 的 LLVM 主体可以只增加一个 `LLVM.dll`，但该 DLL 仍有 Windows/MSVC runtime 动态依赖。

### 11.9 为什么单个 LLVM.dll 仍有 51.58 MiB

Daslang 使用的不是轻量机器码 assembler，而是单体 LLVM shared library。当前 backend 使用的能力覆盖：

- LLVM Core 和 IR Builder；
- IR verifier；
- PassBuilder 和优化 pipeline；
- ExecutionEngine / MCJIT；
- Target、TargetMachine 和 data layout；
- object emission；
- debug metadata；
- host native targets；
- WebAssembly cross-target；
- 动态库、EXE 和 offline object 路径；
- 大量 LLVM-C API。

初始化路径还会调用：

```das
LLVMLinkInMCJIT()
LLVMInitializeAllTargetInfos()
LLVMInitializeAllTargets()
LLVMInitializeAllTargetMCs()
LLVMInitializeAllAsmPrinters()
```

因此它不是“只把几种 bytecode 编码成 x64 指令”的窄 JIT，而是一套可以验证、优化、跨目标发射并链接多种产物的编译器后端。

### 11.10 能否自己裁剪 LLVM.dll

可以构建一个更窄的 LLVM shared library，理论上的裁剪方向包括：

- 只保留实际目标，例如 X86 或 AArch64；
- 如果不需要 Wasm，移除 WebAssembly target；
- 只保留 Core/IR/PassBuilder/ExecutionEngine/TargetMachine/Object 等必需组件；
- 移除不使用的 disassembler、bitcode、debug 或 cross-target 能力；
- 对发布库执行 strip/LTO/section GC 等常规尺寸优化。

但不能只看 `bindings/llvm_func.das` 中声明了哪些函数。Daslang 的 `[extern]` 可以按调用/编译路径解析，真正需要保留的是所有可能执行路径会使用的 exported LLVM-C symbols。

风险包括：

- 某个少见 JIT option 才会触发缺失符号；
- debug info、DLL emission、Wasm 和普通 MCJIT 使用的符号集合不同；
- target registry 裁剪后 `LLVMInitializeAllTargets()` 的可用面改变；
- 预构建库版本必须与 bindings 和 backend 假设一致；
- 当前绑定固定使用 `library="LLVM.dll"`，替代库仍需采用该名字，或重新生成/修改 bindings。

因此，裁剪应配套覆盖：

```text
内存 JIT
DLL cache miss + hit
object emission
EXE emission
debug info on/off
所有需要支持的 CPU/target
```

### 11.11 面向 AngelscriptProject 的体积判断

| 目标形态 | LLVM/工具部署 | 体积判断 | 适用性 |
|---|---|---:|---|
| UE Editor 内存 JIT | `LLVM.dll` + VC runtime | 约 `51.58 MiB` 起 | 开发工具通常可以接受；每次启动重新编译 |
| UE Editor 缓存 JIT | `LLVM.dll` + linker + runtime import libs | 约 `103.59 MiB` 起 | 启动缓存更好，但部署和链接环境更复杂 |
| Cook 时 LLVM、Shipping 只带产物 | LLVM/linker 只在构建机 | 最终包不增加 LLVM | 最符合 UE 发布和平台签名习惯 |
| Shipping 内运行期 LLVM JIT | LLVM + linker/缓存视模式而定 | 约 `51.58–103.59 MiB` 起 | 需评估平台政策、动态代码执行、安全和符号部署 |
| Angelsea/c2mir 类轻量 JIT | MIR/c2mir runtime | 待对目标构建实测 | 通常比完整 LLVM 窄，但能力和优化面也更窄 |

对 AngelscriptProject，体积之外还需要考虑：

- Console/移动平台是否允许运行时生成可执行内存或动态库；
- Shipping 包签名和平台认证是否允许现场链接；
- Unreal Build Tool 是否允许携带 linker/import libraries；
- 崩溃符号、PDB/map 和生成代码的可诊断性；
- JIT cache 的版本、清理、热重载和安全边界；
- ThirdParty license 和重新分发 VC++ Runtime 的要求；
- 当前 StaticJIT 已有的 Cook/AOT 路径是否已经覆盖主要性能目标。

### 11.12 部署结论速查

```text
内存 JIT：
    LLVM.dll                         ≈ 51.58 MiB
    + VC++ Runtime
    + 正常 Daslang runtime/modules
    不需要 linker

默认 Windows 缓存 JIT：
    LLVM.dll                         ≈ 51.58 MiB
    lld-link.exe                     ≈ 52.01 MiB
    libDaScriptDyn_runtime.lib
    对应 Daslang runtime DLL
    + VC++ Runtime
    + 生成的 cache artifacts
    LLVM/linker 工具合计             ≈ 103.59 MiB

离线 LLVM-AOT / 预生成产物：
    LLVM.dll 和 linker 只放在构建机
    最终用户不需要 LLVM
```

最终回答“是否只引入一个 DLL”时应使用这个限定：

> 只做内存 MCJIT 时，LLVM 主体可以只引入约 51.58 MiB 的 `LLVM.dll`，外加系统/VC runtime 和正常 Daslang runtime；当前默认缓存 JIT 首次生成 DLL 时还需要 `lld-link.exe`、Daslang runtime import library 和对应 runtime DLL，因此不能只部署一个 `LLVM.dll`。

---

## 十二、关键源码导航

### Daslang / daScript

| 主题 | 文件 |
|---|---|
| 项目更名和执行层概览 | `Reference/daScript/skills/project_overview.md` |
| SimNode 树解释模型 | `Reference/daScript/doc/source/reference/embedding/quickstart.rst` |
| simulate 时序 | `Reference/daScript/src/ast/ast_simulate.cpp` |
| JIT simulate macro | `Reference/daScript/modules/dasLLVM/daslib/llvm_macro.das` |
| JIT 总驱动 | `Reference/daScript/modules/dasLLVM/daslib/llvm_jit_run.das` |
| AST → LLVM emitter | `Reference/daScript/modules/dasLLVM/daslib/llvm_jit.das` |
| LLVM state/runtime helpers | `Reference/daScript/modules/dasLLVM/daslib/llvm_jit_common.das` |
| LLVM-C 函数声明 | `Reference/daScript/modules/dasLLVM/bindings/llvm_func.das` |
| LLVM opaque types | `Reference/daScript/modules/dasLLVM/bindings/llvm_struct.das` |
| LLVM module path 注册 | `Reference/daScript/modules/dasLLVM/.das_module` |
| LLVM 获取/安装 | `Reference/daScript/modules/dasLLVM/CMakeLists.txt` |
| dasbind 动态 FFI | `Reference/daScript/src/builtin/module_builtin_dasbind.cpp` |
| JIT 安装和运行时桥 | `Reference/daScript/src/builtin/module_jit.cpp` |
| JitFunction ABI | `Reference/daScript/include/daScript/misc/arraytype.h` |
| LLVM pipeline 总览 | `Reference/daScript/modules/dasLLVM/ARCHITECTURE.md` |
| 最小 LLVM 示例 | `Reference/daScript/modules/dasLLVM/examples/hello_llvm_jit.das` |
| 自动 JIT 示例 | `Reference/daScript/modules/dasLLVM/examples/hello_jit.das` |

### Angelsea

| 主题 | 文件 |
|---|---|
| AngelScript JIT provider 接口 | `Reference/angelsea/include/angelsea/jit.hpp` |
| JIT 配置与热度阈值 | `Reference/angelsea/include/angelsea/config.hpp` |
| JIT 触发、c2mir、MIR 和安装 | `Reference/angelsea/src/angelsea/detail/mirjit.cpp` |
| AngelScript bytecode → C | `Reference/angelsea/src/angelsea/detail/bytecode2c.cpp` |
| 接入和配置说明 | `Reference/angelsea/README.md` |

---

## 十三、最终判断

Daslang/daScript 的 LLVM JIT 可以准确概括为：

> Daslang 在前端完成解析、类型推导、宏展开和优化后保留 typed AST；`simulate()` 先创建 Context 和 SimNode 解释树，再触发用 Daslang 编写的 `jit_llvm` simulate macro。该后端通过 `dasbind` 动态调用 `LLVM.dll` 的 LLVM-C API，由 `LlvmJitVisitor` 直接把函数 AST 降低为 LLVM IR，经 MCJIT 或 object/DLL 路径生成本机代码，最后以统一 `JitFunction` ABI 覆盖 `SimFunction` 执行入口。不支持的函数继续由 SimNode 解释器执行。

Angelsea 则可以概括为：

> Angelsea 通过 AngelScript JIT 接口取得函数 bytecode，以调用次数或 eager 策略触发编译，将 `asBC_*` 翻译成 C，经 c2mir 转换为 MIR 并生成机器码，再把 `asJITFunction` 安装回 AngelScript；无法转换的路径保留 VM fallback。

二者最大的区别不是 LLVM 与 MIR，而是 **JIT 接入层级**：

```text
Daslang：Typed AST 级 JIT
Angelsea：AngelScript bytecode 级 JIT
```
