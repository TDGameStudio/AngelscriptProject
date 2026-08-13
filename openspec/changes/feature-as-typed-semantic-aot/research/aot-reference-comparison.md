# Script-language AOT reference comparison

> 本文件现在作为研究入口和结论摘要。完整逐语言管线、项目取舍与参考价值排序见
> [`typed-semantic-native-pipeline-survey.md`](typed-semantic-native-pipeline-survey.md)；官方文档、
> 本地固定 SHA 和精确源码入口见
> [`typed-semantic-source-evidence.md`](typed-semantic-source-evidence.md)；针对当前 maintained compiler、
> engine capture 时序和 StaticJIT 拆分的具体改造清单见
> [`typed-semantic-staticjit-engine-impact.md`](typed-semantic-staticjit-engine-impact.md)。

## Question

Unreal AngelScript AOT generation normally has the complete `.as` source and compiles a strongly typed language whose syntax and value model are intentionally close to C++. The relevant design question is therefore not whether bytecode-native compilation can work, but whether discarding resolved source semantics before the C++ pass is the best boundary for this host.

本文中的 typed AST/HIR 路径特指 **StaticJIT/AOT**：源码编译时捕获 typed HIR，生成 C++，再由构建工具链产生 provider。Angelsea、Luau、LuaJIT 和规划中的 LLVM bytecode backend 属于 **Runtime JIT** 参考；它们解决的是 bytecode、VM exit、可执行内存和运行时安装问题，不能替代本变更的 frontend capture 设计。

## Compared approaches

| System | Native/AOT input boundary | Strength of the approach | Relevance to Unreal AngelScript |
|---|---|---|---|
| AngelScript JIT API | VM bytecode exposed through `asIScriptFunction::GetByteCode()` plus JIT entry instructions | Works for functions loaded from source or precompiled bytecode and preserves VM suspension/exception handoff | Explains the current StaticJIT design, but forces a source-known AOT build to recover types, expressions, and control flow from VM operations |
| Luau native codegen | Compiled Luau bytecode is lowered to native code with runtime/deoptimization fallback | Appropriate for a dynamic/gradually typed embedded language that treats bytecode as the deployable contract | Supports retaining a legacy bytecode path, but does not require AngelScript to use bytecode as its only AOT IR when resolved static semantics are already available |
| Dart native AOT | Source is represented by a portable Kernel binary AST/IR before architecture-specific AOT output | Keeps a semantic program representation distinct from final machine code and supports multiple backends | Direct precedent for retaining a typed semantic artifact between frontend analysis and AOT lowering |
| Cython | Source AST undergoes declaration and expression/type analysis before C code generation | Generates C from typed source semantics instead of reversing interpreter instructions | Closest source-to-C++ analogue for the initial scalar/function-body slice |
| Haxe C++ target | Statically typed Haxe source compiles to a C++ source target | Treats C++ as a backend for a typed cross-platform language | Reinforces using a typed compiler representation when the source compiler and target generator run together |
| GraalVM Truffle | Specialized AST interpreters are partially evaluated to native code | Can achieve native performance while keeping high-level guest-language semantics | Architecturally interesting but substantially more runtime/compiler machinery than this plugin needs for deterministic build-time C++ generation |

补充研究还覆盖：

- daScript typed AST → LLVM JIT/AOT 与逐函数 tree-interpreter fallback；
- Julia lowered IR → typed SSA → LLVM；
- Numba bytecode → untyped IR → typed IR → LLVM；
- LuaJIT trace IR、side exit；
- V8 Ignition/Sparkplug/Maglev/TurboFan tiering；
- Luau bytecode type analysis、native IR、fallback block 与 VM exit。

## Primary sources

- AngelScript, “How to build a JIT compiler”: <https://www.angelcode.com/angelscript/sdk/docs/manual/doc_adv_jit.html>
- AngelScript, precompiled bytecode: <https://www.angelcode.com/angelscript/sdk/docs/manual/doc_adv_precompile.html>
- Luau repository and compiler/runtime boundary: <https://github.com/luau-lang/luau>
- Roblox Luau native code generation guidance: <https://create.roblox.com/docs/luau/native-code-gen>
- Dart compile formats, including portable Kernel AST and AOT snapshots: <https://dart.dev/tools/dart-compile>
- Cython compiler internals and typed AST pipeline: <https://cython.readthedocs.io/en/latest/src/devguide/cython_internals.html>
- Haxe compiler targets: <https://haxe.org/documentation/introduction/compiler-targets.html>
- GraalVM Truffle partial-evaluation background: <https://www.graalvm.org/jdk21/community/publications/>
- daScript repository and LLVM backend: <https://github.com/GaijinEntertainment/daScript>
- Julia compiler IR documentation: <https://docs.julialang.org/en/v1/devdocs/ast/>
- Julia SSA IR: <https://docs.julialang.org/en/v1/devdocs/ssair/>
- Numba compiler architecture: <https://numba.readthedocs.io/en/stable/developer/architecture.html>
- V8 Maglev SSA JIT and deoptimization: <https://v8.dev/blog/maglev>
- LuaJIT official repository: <https://github.com/LuaJIT/LuaJIT>

## Conclusions for this change

1. The existing StaticJIT is not “wrong”; it faithfully implements AngelScript's bytecode JIT boundary and remains necessary when source semantic state is unavailable.
2. A source-known, strongly typed AOT build has a different opportunity: retain resolved compiler semantics before the parser tree is destroyed and lower that representation directly.
3. The new representation should be a typed, structured HIR rather than a second bytecode or early SSA form. Structured statements match AngelScript source, simplify C++ emission and diagnostics, and leave CFG/SSA lowering as a later independent optimization layer.
4. HIR and bytecode must coexist. Bytecode remains the VM/runtime archive and independent correctness oracle; HIR is an optional ephemeral AOT input.
5. Fallback is a normal capability boundary, not an error-hiding mechanism. Every unsupported form must have a typed reason, while claimed supported forms must pass dual differential execution.
6. UFUNCTION roots are the best first vertical slice because `UASFunction` already supplies reflected signatures, parameter layout, and the VM/raw/parameter dispatch paths. This simplifies entry ABI; it does not remove the need for typed body/control-flow lowering.
7. Raw parser AST is the wrong retained artifact in this fork: parser nodes are local-memory-stack syntax nodes and are destroyed before final StaticJIT generation. The retained representation must be an independently owned, verified typed HIR committed with the successfully compiled function.
8. Semantic analysis must include HIR-derived dependency/reference collection. Avoiding `GetByteCode()` only inside the final emitter would still leave the new backend coupled to Legacy bytecode analysis.

## Refined architecture conclusion

The expanded survey supports a three-level model:

1. structured typed semantic HIR for source fidelity, diagnostics and deterministic C++ emission;
2. an optional future backend-neutral typed CFG/SSA layer for optimization and multi-native-backend reuse;
3. backend IR/materialization such as C++, MIR, LLVM IR or architecture-specific native code.

The current change implements level 1 plus the C++ backend. It should preserve enough evaluation-order,
temporary-lifetime, call-identity, exception/suspend and merge information to permit a future lossless CFG
lowering, but it should not make LLVM SSA the first retained semantic representation.

For implementation priority, Cython is the closest direct precedent for typed semantic tree -> C/C++ static output, and daScript is the closest overall precedent for typed-tree support preflight and per-function mixed execution. Angelsea and Luau remain highest-value references for the separate bytecode Runtime JIT changes, not for this StaticJIT frontend.

## Local research snapshots

The highest-value, license-clear and size-controlled sources have been retained locally:

| Path | Snapshot | Primary use |
| --- | --- | --- |
| `Reference/daScript` | `ae21253fea2b8184f81c00013f2684c98c31174d` | typed AST, tree interpreter, LLVM JIT/AOT, semantic cache |
| `Reference/Cython` | `86b94cef002aa23aea0b390335ea3d9e9b62c19e` | typed AST → C/C++ emitter |
| `Reference/numba` | `43b83d9a0ea3c07108cb73484fcbcc5284615958` | untyped/typed IR, LLVM lowering, specialization cache |
| `Reference/luau` | `ca128af4c531310d6f5c1b354df4b79fdd782ede` | bytecode native codegen, guards, fallback and VM exit |

Dart SDK, Julia, V8 and Graal are intentionally kept as official-document/source-link references because
their full repositories are disproportionately large for the narrow compiler surfaces needed here.
