# Script-language AOT reference comparison

## Question

Unreal AngelScript AOT generation normally has the complete `.as` source and compiles a strongly typed language whose syntax and value model are intentionally close to C++. The relevant design question is therefore not whether bytecode-native compilation can work, but whether discarding resolved source semantics before the C++ pass is the best boundary for this host.

## Compared approaches

| System | Native/AOT input boundary | Strength of the approach | Relevance to Unreal AngelScript |
|---|---|---|---|
| AngelScript JIT API | VM bytecode exposed through `asIScriptFunction::GetByteCode()` plus JIT entry instructions | Works for functions loaded from source or precompiled bytecode and preserves VM suspension/exception handoff | Explains the current StaticJIT design, but forces a source-known AOT build to recover types, expressions, and control flow from VM operations |
| Luau native codegen | Compiled Luau bytecode is lowered to native code with runtime/deoptimization fallback | Appropriate for a dynamic/gradually typed embedded language that treats bytecode as the deployable contract | Supports retaining a legacy bytecode path, but does not require AngelScript to use bytecode as its only AOT IR when resolved static semantics are already available |
| Dart native AOT | Source is represented by a portable Kernel binary AST/IR before architecture-specific AOT output | Keeps a semantic program representation distinct from final machine code and supports multiple backends | Direct precedent for retaining a typed semantic artifact between frontend analysis and AOT lowering |
| Cython | Source AST undergoes declaration and expression/type analysis before C code generation | Generates C from typed source semantics instead of reversing interpreter instructions | Closest source-to-C++ analogue for the initial scalar/function-body slice |
| Haxe C++ target | Statically typed Haxe source compiles to a C++ source target | Treats C++ as a backend for a typed cross-platform language | Reinforces using a typed compiler representation when the source compiler and target generator run together |
| GraalVM Truffle | Specialized AST interpreters are partially evaluated to native code | Can achieve native performance while keeping high-level guest-language semantics | Architecturally interesting but substantially more runtime/compiler machinery than this plugin needs for deterministic build-time C++ generation |

## Primary sources

- AngelScript, “How to build a JIT compiler”: <https://www.angelcode.com/angelscript/sdk/docs/manual/doc_adv_jit.html>
- AngelScript, precompiled bytecode: <https://www.angelcode.com/angelscript/sdk/docs/manual/doc_adv_precompile.html>
- Luau repository and compiler/runtime boundary: <https://github.com/luau-lang/luau>
- Roblox Luau native code generation guidance: <https://create.roblox.com/docs/luau/native-code-gen>
- Dart compile formats, including portable Kernel AST and AOT snapshots: <https://dart.dev/tools/dart-compile>
- Cython compiler internals and typed AST pipeline: <https://cython.readthedocs.io/en/latest/src/devguide/cython_internals.html>
- Haxe compiler targets: <https://haxe.org/documentation/introduction/compiler-targets.html>
- GraalVM Truffle partial-evaluation background: <https://www.graalvm.org/jdk21/community/publications/>

## Conclusions for this change

1. The existing StaticJIT is not “wrong”; it faithfully implements AngelScript's bytecode JIT boundary and remains necessary when source semantic state is unavailable.
2. A source-known, strongly typed AOT build has a different opportunity: retain resolved compiler semantics before the parser tree is destroyed and lower that representation directly.
3. The new representation should be a typed, structured HIR rather than a second bytecode or early SSA form. Structured statements match AngelScript source, simplify C++ emission and diagnostics, and leave CFG/SSA lowering as a later independent optimization layer.
4. HIR and bytecode must coexist. Bytecode remains the VM/runtime archive and independent correctness oracle; HIR is an optional ephemeral AOT input.
5. Fallback is a normal capability boundary, not an error-hiding mechanism. Every unsupported form must have a typed reason, while claimed supported forms must pass dual differential execution.
6. UFUNCTION roots are the best first vertical slice because `UASFunction` already supplies reflected signatures, parameter layout, and the VM/raw/parameter dispatch paths. This simplifies entry ABI; it does not remove the need for typed body/control-flow lowering.
