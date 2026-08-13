# Typed semantic native pipeline source evidence

## 1. 证据规则

- 核查日期：2026-08-12。
- 优先级：官方文档、官方仓库源码、本地固定快照；不使用二手博客作为架构事实依据。
- “直接证据”表示文档或源码明确展示的事实；“项目推论”表示基于这些事实对 Unreal AngelScript 的设计判断。
- 本地 `Reference/` 仓库只是研究快照，不是 Runtime、Build 或发布依赖。

## 2. 本地固定快照

| 系统 | 本地路径 | SHA | 分支 | 许可证 | 拉取形态 |
| --- | --- | --- | --- | --- | --- |
| daScript | `Reference/daScript` | `ae21253fea2b8184f81c00013f2684c98c31174d` | `master` | BSD-3-Clause | 既有完整参考副本 |
| Cython | `Reference/Cython` | `86b94cef002aa23aea0b390335ea3d9e9b62c19e` | `master` | Apache-2.0 | `--depth 1 --recurse-submodules` |
| Numba | `Reference/numba` | `43b83d9a0ea3c07108cb73484fcbcc5284615958` | `main` | BSD-2-Clause | `--depth 1 --recurse-submodules` |
| Luau | `Reference/luau` | `ca128af4c531310d6f5c1b354df4b79fdd782ede` | `master` | MIT | `--depth 1 --recurse-submodules` |

## 3. daScript

### daScript 官方/本地来源

- 官方仓库：<https://github.com/GaijinEntertainment/daScript>
- 本地架构记录：`Documents/Knowledges/ZH/Diff_DaslangAngelseaJIT.md`
- JIT driver：`Reference/daScript/modules/dasLLVM/daslib/llvm_jit_run.das`
- AST → LLVM：`Reference/daScript/modules/dasLLVM/daslib/llvm_jit.das`
- simulate macro：`Reference/daScript/modules/dasLLVM/daslib/llvm_macro.das`
- JIT install/remove：`Reference/daScript/src/builtin/module_jit.cpp`
- mixed-mode function record：`Reference/daScript/include/daScript/simulate/simulate.h`
- AOT/JIT invoke path：`Reference/daScript/include/daScript/simulate/aot.h`

### daScript 直接证据

- `run_jit(prog, ctx)` 枚举 compiled program 的 `FunctionPtr`，使用 `DisableJitVisitor` 检查能否 JIT。
- `generate_llvm(..., fun, ...)` 以 `FunctionPtr` 为入口生成 LLVM IR，而不是读取 bytecode。
- `generate_llvm_code()` 可通过 `LLVMGetFunctionAddress` materialize JIT entry。
- `SimFunction` 同时持有 interpreter `code`、`aotFunction` 和 `jitFunction`；调用路径可混合选择。
- driver 支持 compile-only、object、DLL/EXE/Wasm 等不同输出策略，并实现 content-addressed cache。

### daScript 项目推论

- AngelScript typed semantic sidecar 应与 bytecode 并行保留。
- structured typed HIR 和 LLVM CFG/SSA 应分层。
- 支持度预检、逐函数 fallback、mixed-mode dispatch 和 semantic identity 值得直接吸收。

## 4. Cython

### Cython 官方/本地来源

- 官方 internals：<https://cython.readthedocs.io/en/latest/src/devguide/cython_internals.html>
- 官方基础教程：<https://cython.readthedocs.io/en/latest/src/tutorial/cython_tutorial.html>
- 官方编译说明：<https://cython.readthedocs.io/en/latest/src/userguide/source_files_and_compilation.html>
- 官方语言/异常说明：<https://cython.readthedocs.io/en/latest/src/userguide/language_basics.html>
- pipeline：`Reference/Cython/Cython/Compiler/Pipeline.py`
- statement AST：`Reference/Cython/Cython/Compiler/Nodes.py`
- expression AST：`Reference/Cython/Cython/Compiler/ExprNodes.py`
- module/C codegen：`Reference/Cython/Cython/Compiler/ModuleNode.py`
- C writer：`Reference/Cython/Cython/Compiler/Code.py`

### Cython 直接证据

- 官方 internals 明确说明源码先进入 AST；declaration analysis 和 expression/type analysis 直接遍历、修改 tree。
- `Pipeline.py` 的顺序包含 `AnalyseDeclarationsTransform`、`ControlFlowAnalysis`、`AnalyseExpressionsTransform`、typed/optimization transforms，最后进入 `generate_pyx_code_stage_factory`。
- `ModuleNode.generate_c_code()` 使用 `CCodeWriter` 生成 C/C++。
- 官方教程说明 Python values 和 C values 可混合，引用计数、错误检查、异常传播由 Cython codegen 自动生成。

### Cython 项目推论

- Cython 是 `asCTypedSemanticFunction` → C++ emitter 最接近的对照。
- 我们应借鉴 typed node、coercion、temporary 和 cleanup lowering；不照搬 Python C API、GIL 或表达式级 object-mode slow path。

## 5. Numba

### Numba 官方/本地来源

- 官方 compiler architecture：<https://numba.readthedocs.io/en/stable/developer/architecture.html>
- 官方 rewrite 说明：<https://numba.readthedocs.io/en/stable/developer/rewrites.html>
- compiler pipeline：`Reference/numba/numba/core/compiler.py`
- untyped passes：`Reference/numba/numba/core/untyped_passes.py`
- typed passes：`Reference/numba/numba/core/typed_passes.py`
- LLVM lowering：`Reference/numba/numba/core/lowering.py`
- materialization：`Reference/numba/numba/core/codegen.py`
- object cache：`Reference/numba/numba/core/caching.py`

### Numba 直接证据

- 官方 architecture 明确给出 CPython bytecode → CFG/dataflow → Numba IR → type inference → typed rewrite → LLVM lowering。
- `DefaultPassBuilder` 把 nopython pipeline 组合为 untyped、typed、lowering 三部分。
- type inference 产生 `typemap`、`return_type`、`calltypes`。
- `NativeLowering` 使用 specialized function descriptor 和 typed IR 下沉，随后由 target context 得到 executable。
- cache 以 function signature、codegen target magic、函数 bytecode 和 closure 内容构造 key，并能序列化 object code。

### Numba 项目推论

- 未来可在 structured HIR 后增加 backend-neutral typed CFG；当前不必提前实现。
- support/capability、typed rewrite、IR legalization、lowering、materialization 和 cache 应保持独立可观察阶段。

## 6. Luau

### Luau 官方/本地来源

- 官方仓库：<https://github.com/luau-lang/luau>
- IR builder：`Reference/luau/CodeGen/src/IrBuilder.cpp`
- bytecode analysis：`Reference/luau/CodeGen/src/BytecodeAnalysis.cpp`
- bytecode → IR：`Reference/luau/CodeGen/src/IrTranslation.cpp`
- x64/A64 lowering：`Reference/luau/CodeGen/src/IrLoweringX64.cpp`、`IrLoweringA64.cpp`
- native install/lifecycle：`Reference/luau/CodeGen/src/CodeGenContext.cpp`
- IR definitions：`Reference/luau/CodeGen/include/Luau/IrData.h`

### Luau 直接证据

- `IrBuilder::buildFunctionIr(Proto*)` 直接接收 VM `Proto`。
- 它先 `loadBytecodeTypeInfo`，再 `rebuildBytecodeBasicBlocks`、`analyzeBytecodeTypes`，最后翻译 bytecode instruction。
- IR translation 大量使用 `CHECK_TAG`、fallback block 和 `vmExit(pcpos)`。
- `CodeGenContext` 调用 `lowerFunction`，把 native metadata/entry 安装到 `Proto::execdata` / `exectarget`，销毁时释放 native module。

### Luau 项目推论

- Luau 是规划中的 Runtime JIT 的核心参考，不是 typed source AOT 的前端参考。
- VM exit 必须以 bytecode PC 和同步 metadata 为一等契约。

## 7. Dart

### Dart 官方来源

- Dart compile 输出格式：<https://dart.dev/tools/dart-compile>
- Dart Kernel README：<https://github.com/dart-lang/sdk/blob/main/pkg/kernel/README.md>
- Kernel in-memory AST：<https://github.com/dart-lang/sdk/blob/main/pkg/kernel/lib/ast.dart>
- Kernel binary format：<https://github.com/dart-lang/sdk/blob/main/pkg/kernel/binary.md>
- AOT snapshot entry：<https://github.com/dart-lang/sdk/blob/main/runtime/bin/gen_snapshot.cc>
- Dart SDK：<https://github.com/dart-lang/sdk>

### Dart 直接证据

- Kernel README 将 Kernel 定义为供 whole-program analysis、transformation、codegen 和 execution backend 消费的高层语言/IR。
- Kernel 同时有内存表示和 binary/text serialization。
- `dart compile kernel` 生成 portable binary AST；`aot-snapshot`/`exe` 生成 architecture-specific native artifact。
- `gen_snapshot` 接收 Dart Kernel file，可输出 AOT assembly、ELF 或平台动态库。

### Dart 项目推论

- frontend semantic IR 和 backend IR 应分离。
- 当前 HIR 保持 ephemeral；只有出现明确跨进程/分布式编译需求时才承担 Kernel 式 schema 兼容成本。

## 8. Julia

### Julia 官方来源

- AST/lowered IR：<https://docs.julialang.org/en/v1/devdocs/ast/>
- inference：<https://docs.julialang.org/en/v1/devdocs/inference/>
- SSA IR：<https://docs.julialang.org/en/v1/devdocs/ssair/>
- native codegen：<https://docs.julialang.org/en/v1/devdocs/compiler/>
- JIT：<https://docs.julialang.org/en/v1/devdocs/jit/>
- AOT：<https://docs.julialang.org/en/v1/devdocs/aot/>
- LLVM passes：<https://docs.julialang.org/en/v1/devdocs/llvm-passes/>

### Julia 直接证据

- Julia 官方文档区分 surface AST 与用于 type inference/codegen 的 lowered IR；lowered IR 已把控制流转为显式 branches/statements。
- `CodeInfo` 可保存 slot/SSA types、inferred return type、debug/source info、dependency edges 和 world-age validity。
- SSA IR 为每个 SSA value 维护类型，并有 Phi/Pi/PhiC/Upsilon 等节点处理 merge、type refinement 和异常控制流。
- native codegen 文档明确描述 GC roots、boxed/unboxed/union representation、calling convention、relocation 和 object deserialization。

### Julia 项目推论

- 我们需要保留未来构建 CFG/SSA 所需的 evaluation/lifetime/exception edge 信息，但第一版 structured HIR 不需要直接采用 SSA。

## 9. Haxe / hxcpp

### Haxe/hxcpp 官方来源

- 语言概述：<https://haxe.org/documentation/introduction/language-introduction.html>
- compiler targets：<https://haxe.org/manual/compiler-usage.html>
- C++ target：<https://haxe.org/manual/target-cpp-getting-started.html>
- Haxe C++ generator：<https://github.com/HaxeFoundation/haxe/blob/development/src/generators/gencpp.ml>
- hxcpp runtime/toolchain：<https://github.com/HaxeFoundation/hxcpp>

### Haxe/hxcpp 直接证据

- Haxe 官方描述其为带 type inference 的 strongly typed compiled language。
- C++ target 分两步：Haxe compiler 生成 source/header/build files，hxcpp 调用系统 compiler/linker。
- `gencpp.ml` 位于官方 compiler 的 target generators，并消费 compiler typed structures。

### Haxe/hxcpp 项目推论

- C++ 只是 backend output；language/runtime ABI 仍必须单独设计。
- Haxe/hxcpp 的组合证明 source backend 可跨平台，但不意味着可以忽略 runtime、GC、reflection 和 exception support。

## 10. LuaJIT

### LuaJIT 官方来源

- 官方运行/JIT选项：<https://luajit.org/running.html>
- 官方 JIT API：<https://luajit.org/ext_jit.html>
- trace recorder：<https://github.com/LuaJIT/LuaJIT/blob/v2.1/src/lj_record.c>
- trace state：<https://github.com/LuaJIT/LuaJIT/blob/v2.1/src/lj_trace.c>
- IR optimizer：<https://github.com/LuaJIT/LuaJIT/blob/v2.1/src/lj_opt_fold.c>
- assembler/backend：<https://github.com/LuaJIT/LuaJIT/blob/v2.1/src/lj_asm.c>

### LuaJIT 直接证据

- LuaJIT 是 trace JIT；recorder 从正在执行的 bytecode/path 构造 IR。
- recorder/trace state 维护 guards、snapshots、side exits 和 machine-code trace。

### LuaJIT 项目推论

- 对 Runtime JIT 最有价值的是 guard → snapshot → side exit 的恢复契约。
- typed Static AOT v1 不需要 trace selection、side trace 或 speculative deoptimization。

## 11. V8

### V8 官方来源

- Ignition/TurboFan：<https://v8.dev/blog/launching-ignition-and-turbofan>
- Sparkplug：<https://v8.dev/blog/sparkplug>
- Maglev：<https://v8.dev/blog/maglev>
- Ignition docs：<https://v8.dev/docs/ignition>

### V8 直接证据

- JavaScript 先进入 Ignition bytecode并解释执行，runtime 收集 shape/type feedback。
- Sparkplug 是快速、非优化 bytecode compiler。
- Maglev 是传统 CFG/SSA optimizing JIT；它消费 bytecode + feedback，插入 guards/dependencies。
- Maglev 为可能 deopt 的 node 附带 interpreter frame state，用于重建解释器状态。
- Sparkplug/V8 支持 OSR/tier transitions。

### V8 项目推论

- 多 backend 的共同部分应该是 coordinator、artifact state、budget、diagnostics、invalidation 和 dispatch，而不是强迫共享同一种 IR。

## 12. Graal/Truffle

### Graal/Truffle 官方来源

- Truffle language implementation framework：<https://www.graalvm.org/latest/graalvm-as-a-platform/language-implementation-framework/>
- host/guest partial evaluation：<https://www.graalvm.org/22.2/graalvm-as-a-platform/language-implementation-framework/HostOptimization/>
- 官方 publications：<https://www.graalvm.org/jdk17/community/publications/>
- deoptimization pattern：<https://www.graalvm.org/jdk21/graalvm-as-a-platform/language-implementation-framework/DeoptCyclePatterns/>

### Graal/Truffle 直接证据

- guest compilation 对 AST/bytecode interpreter 应用 partial evaluation。
- Truffle AST 在解释过程中 specialization；assumption/guard 失效可 transfer 到 interpreter 并 invalidation/recompile。

### Graal/Truffle 项目推论

- 可以借鉴“语义只在 interpreter/HIR operation 定义一次”的目标。
- 不能把 Truffle 的 Java/Graal runtime 当作 UE 插件可直接接入的轻量 backend。

## 13. AngelScript / 当前项目对照

### 官方和本地来源

- AngelScript JIT API：<https://www.angelcode.com/angelscript/sdk/docs/manual/doc_adv_jit.html>
- AngelScript precompiled bytecode：<https://www.angelcode.com/angelscript/sdk/docs/manual/doc_adv_precompile.html>
- 当前 typed semantic AOT design：`openspec/changes/feature-as-typed-semantic-aot/design.md`
- 当前 compiler/engine/StaticJIT 改造面：`openspec/changes/feature-as-typed-semantic-aot/research/typed-semantic-staticjit-engine-impact.md`
- typed HIR spec：`openspec/changes/feature-as-typed-semantic-aot/specs/as-typed-semantic-ir/spec.md`
- TypedASTJIT backend spec：`openspec/changes/feature-as-typed-semantic-aot/specs/as-typed-ast-jit-backend/spec.md`
- Angelsea 研究：`Documents/Knowledges/ZH/Diff_AngelseaJIT.md`
- daScript/Angelsea 对比：`Documents/Knowledges/ZH/Diff_DaslangAngelseaJIT.md`

### AngelScript/当前项目直接证据

- AngelScript JIT contract 以 function bytecode 为输入，并要求处理 VM/JIT entry、suspend/exception handoff。
- 当前 `asCCompiler::CompileFunction()` 在局部 `asCParser` 生命周期内执行 `ParseStatementBlock()` 和 `CompileStatementBlock()`；`asCParser::CreateNode()` 从 parser 自有 `FMemStackBase` 分配 `asCScriptNode`，所以 raw parser tree 不是 final StaticJIT 可延迟读取的 artifact。
- `asCExprContext` 已有 `Clear()`、`Copy()`、`Merge()` 和带精确 `asCDataType` 的 `asCExprValue`，适合携带 optional HIR expression ID；该 identity 必须覆盖 context rewrite，不能只在最外层 statement hook 重建。
- `asCCompiler::FinalizeFunction()` finalize bytecode 并把 bytecode/VM metadata 写入 `asCScriptFunction::ScriptFunctionData`；typed HIR 应作为 provisional transaction 在这之后验证并提交，失败时保留正常 bytecode 而不发布 partial HIR。
- UE `FAngelscriptEngine::CompileModule_Code_Stage3()` 先删除 `ScriptModule->builder` 再调用 `JITCompile()`，证明到 `OnFunctionReady()`/`WriteOutputCode()` 才决定 capture 已经太晚。
- 当前实现中的 `FAngelscriptStaticJIT::WriteOutputCode()` 先对 `FunctionsToGenerate` 调用 `AnalyzeScriptFunction()`，再调用 `GenerateCppCode()`；后者明确读取 `GetByteCode()`，当前 reference resolver 也扫描 bytecode。重构后这些职责归 `FAngelscriptBytecodeJIT`。TypedASTJIT 必须同时提供 HIR-based analyzer/reference collection 和 HIR emitter，不能只替换最后一个 body-emission 函数。
- 当前 OpenSpec 已定义 optional function-owned sidecar HIR、Static BackendId `"bytecode"`/`"typed-ast"`、逐函数 TypedASTJIT → BytecodeJIT → VM fallback，以及隔离的三路 differential verification；不再定义生产 `Dual` backend。

### 最终推论

- bytecode Runtime JIT 与 typed semantic Static AOT 都合理，但服务不同输入生命周期。
- typed HIR 不替代 bytecode；LLVM/MIR 也不替代 typed HIR。
- typed semantic StaticJIT 不需要修改 Unreal Engine 源码，也不实现 Runtime JIT backend；其 UE-specific 工作集中在无脚本反射物化的 generation-only Engine、UFUNCTION root/route eligibility、entry plan 和 provider packaging，最终 provider 路由复用统一 coordinator。
- 当前 OpenSpec 的核心方向成立，应按 survey 中的 capability、ABI、cache identity、capture timing、backend-specific analysis 和 future CFG layering 建议补强实现细节。
