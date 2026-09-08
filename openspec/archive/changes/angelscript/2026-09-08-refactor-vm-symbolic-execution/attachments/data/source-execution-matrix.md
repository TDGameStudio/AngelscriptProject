# Detached Metadata and Source Execution Matrix

This matrix was the planning acceptance list. 4.2 reconciled executed versus unclaimed rows in [implementation-verification.md](implementation-verification.md) against NativeEngine RunId `6f4ed80cd8fa46369d45f2e6bf6f4049`. tasks.md alone owns task state.

## Proof layers and runtime dependency

| Layer | Inputs and observations | AS Engine | Owner |
|---|---|---|---|
| Actual detached metadata | Canonical context, real factory types/functions, members/signatures, layout/hash and leases | None | 1.1-1.3 |
| Direct bytecode production | Explicit declarations, instructions, operands, verifier, codec/dump | None | 2.1-2.2 |
| Canonical source production | Current Builder/session, typed sealed AST, frozen definitions, emitter | None | 5.1-5.4 |
| Direct VM execution | Hand-built image, explicit registered definitions/native/global bindings | Minimal SDK owner | 2.3-4.1 |
| Source VM/cache execution | Source-built image through the identical verifier/linker/interpreter | Minimal SDK owner | 5.1-5.5 |
| Completion regression | Exact cases from both producers, metadata and dormancy | Per-scenario ownership | 4.2 |

CQTest remains in the UE host even for an AS-Engine-free test. This plan neither creates a new test framework nor promises removal of the UE process startup cost. Do not create fake object/function classes, fake Engine IDs, an Engine subclass with placeholder services, or a test-only miniature interpreter.

## Planned source oracles

All source groups assert actual Prepare/Execute status and results. Complete case paths and proving RunIds are filled into task evidence during implementation, not invented here.

| Owner | Bounded cases | Independent execution oracle |
|---|---|---|
| 5.1 | Integer/enum/bool/configured float values, conversions, unary/binary operators, assignments, locals | 1+2*3=7; 8-3-1=4; AS 2**3**2=64; AS 1\|2==3=true; 1+2.5=3.5. Runtime-parameter versions prevent constant-only proof; width/signedness follow the tested VM ABI. |
| 5.2 | if/else, while/do/for, break/continue, switch/fallthrough | Sum 1..10=55; skip i=2 and break i=5 in 0..5 gives 8; while-zero versus do-once; nested else returns 1/2/3; trace distinguishes continue increment and nearest break. |
| 5.2 | &&, \|\|, ?: with runtime conditions | Only selected local mutation occurs; skipped dynamic division by zero is safe, selected division raises a VM exception. |
| 5.3 | Ordinary/forward/cross-section/recursive calls | Caller returns 7; factorial 0/1/5 returns 1/1/120; configured overflow and Context recovery are proved in 5.4 after 3.6. |
| 5.3 | Overload, named/default arguments, native calls | Distinct overload markers; Combine(B:4,A:3) and default B=4 both yield 34. Pack(Mark(1),Mark(2)) and Pack(b:Mark(2),a:Mark(1)) both trace [2,1] and return 12. Typed defaults execute at each call site. |
| 5.3 | &in, &out, &inout and failure | Fill writes 41, Bump yields 42; input remains readonly; native callback sees exact arguments/count; native exception has correct status; image owns source observations, with Context reporting checked in 5.4. |
| 5.4 | AS object constructor, fields, const methods | Value Local(7).Read() yields 7; mutation changes later read. Pair(b:Mark(2),a:Mark(1)) traces [2,1] but stores a=1,b=2. |
| 5.4 | Default/value/copy construction, nested scopes and exits | Normal/return/break/continue clean exactly the live values in reverse order. for initializer survives continue; body local does not. |
| 5.4 | Dynamic exception and partial construction | Stack-overflow/division/native/constructor failure reports its source/call site and cleans only initialized values; no whole destructor for failed construction; handles/temporaries released, live count zero; reprepare function returns 97. |
| 5.5 | Source-produced cache and independent destination | Run/encode/release source session and Engine A; manually define equivalent metadata in B; decode/link/execute same result and callback trace through B's live bindings, without recompiling in B. |
| 5.5 | Cache mismatch and mixed integration | Missing type/free function/native binding, changed schema/layout/signature, foreign image or body conflict rejects atomically; no fabricated declaration/body replacement or sentinel mutation. |

A fixed receiver in initial method fixtures avoids accidentally defining receiver-versus-argument evaluation order from a C++ assumption. Before admitting side-effectful receiver cases, establish the maintained AS rule from source plus an explicit trace; never silently choose Clang's order.

## Admission and excluded source forms

Every group includes relevant rejection controls: invalid lvalues/const mutation, invalid bool conditions, incompatible return/ref/out argument, unknown named arguments and missing constructor. Existing frontend errors may already be GREEN. The additional end-to-end assertion is no usable image, no executable publication and no native call.

Unverified/recovery AST, unmatched frozen definitions, missing typed external defaults, corrupt target data and valid-but-unsupported nodes return distinct producer failures. An error before bytecode generation need not manufacture an instruction position; preserve the actual failing source stage/range.

The first source-emission surface excludes capturing/escaping lambdas, funcdef/delegate generation, user-defined operator/conversion lowering, foreach, list initializers, generic instantiation, complex global initialization and reflection-annotation generation. Native property source access requires a host semantic member view not added here: use explicit native Get/Set calls. Direct-bytecode native-property, dispatch/delegate, GC and all maintained opcode acceptance remains intact. Source try/catch, removed import/asset, legacy modules, UE reflection/World and JIT remain excluded.

## Actual detached metadata fixture

Use FDetachedDefinitionFixture owning asCTypeContext plus std::shared_ptr<asCMetadataImage>. Thin helpers generate canonical keys via the existing identity registry and create real objects through CreateObjectType/CreateFunction/DefineFunction/AddProperty. FinalizeAndFreeze creates no Engine. Runtime registration is a separate visible call in a runtime test.

Test owner/member/signature queries by stable key, name/index and structured type use; GetMethodByDecl/GetFactoryByDecl string parsing is not reintroduced. Keep constructor access private. A supplied nonzero shell key can establish ownership tests but cannot authenticate a persisted identity.

External AddRef/Release leases retain the whole image/dependency graph. Keep a valid lease while sharing a pointer; a last Release can destroy that object and must be the last access. Frozen immutable reads and serialized draft factory mutations are distinct concurrency contracts. Real runtime delegate instances are not declaration-factory outputs.

## Compiler handoffs and known prerequisites

- asCBuilder::RunThrough already reaches DefinitionsFrozen without an Engine; do not rewrite that pipeline or claim it already emits bytecode.
- Body work items expose Function, StableFunctionKey and range; fragments expose body plus lifetime plan. Frozen definition consumption creates actual functions with matching stable keys.
- Typed call operands carry resolved target and formal placement. Current local default parameter initializers are analyzed/converted before bodies, so DefaultArgumentExpr can consume typed AST rather than metadata text.
- Current constructor resolution computes source ordinals but discards them. 5.4 preserves them in the existing node, projection, codec and verifier, including versioned payload evolution from the inspected codec version 7; execution remains reverse-formal regardless of authored named order.
- asCBodyLifetimePlan is not a finished frame/unwind plan: nominal locals and selected explicit exits do not cover normal scope ends, handles, temporaries, initialized-state or runtime exception paths. 5.4 owns the missing lowering state and its emitted records.
- Successful image production owns all required strings/source observations. Definitions remain separate; neither AST pointers nor an Engine is retained by the encoded artifact.

## Source evidence and reference priority

Paths below are relative to the workspace unless absolute. Line numbers identify the inspected snapshot and may move during implementation.

| Source | Inspected fact |
|---|---|
| Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Definitions/MetadataImageTests.cpp:35,61,83,263,371,511 | ActualTypesAndMethodsNeedNoEngineOrNumericIds; real metadata/signatures and image leases; factory/lease concurrency controls already exist. |
| Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Registration/EngineRegistrationTests.cpp:21,261 | Authenticated FDefinition pattern; legacy Context/module creation explicitly dormant. |
| Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_builder.h:21 | Engine-free Builder and DefinitionsFrozen default endpoint. |
| Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_body_fragment.h:9 | Stable function/body/lifetime handoff. |
| Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_definition_consumer.cpp:198 | Metadata callable uses canonical AST identity. |
| Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_compilation_session.cpp:610,633,814 | Typed deferred initializers/default expansion checks precede verified/sealed AST. |
| Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_frontend_sema_postfix.cpp:653 | Constructor arguments resolved into formal order; local source Ordinals not retained. |
| Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_body_lifetime.cpp | Current lexical nominal-local/explicit-transfer obligations, not complete VM unwind. |
| Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Bodies/BodySemanticTests.cpp:256,274,290,302,429,508,590,846,861,946 | Current expression, control/call and lifetime semantic expectations; no execution proof. |
| Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Builder/BuilderStageTests.cpp:335 | Existing Value constructor/member fixture reaches definitions; new oracle executes Read=7. |
| Plugins/Angelscript/Source/AngelscriptRuntime/Legacy/angelscript/source/as_compiler.cpp:2522,2727,13073 | Maintained AS argument authority: named/default mapping then reverse-formal PrepareFunctionCall for ordinary and constructor calls. |
| Plugins/Angelscript/Source/AngelscriptTest/Legacy/AngelScriptSDK/Language/Constructors/AngelscriptNativeConstructorParameterTests.cpp:998 | Positional constructor reverse evaluation and formal consumption oracle. |
| D:/LLVM/llvm-project-22.1.8.src/clang/lib/CodeGen/CGExprScalar.cpp:5356,5499,5665 | Typed expression visitors, conditional RHS blocks, join values. |
| D:/LLVM/llvm-project-22.1.8.src/clang/lib/CodeGen/CGStmt.cpp:1294,1756,1769 | Distinct loop targets and branch-through-cleanup for break/continue. |
| D:/LLVM/llvm-project-22.1.8.src/clang/lib/CodeGen/CodeGenFunction.h:653 | Function-local cleanup stack and scoped emission ownership. |

The local LLVM source is the pinned source referenced by Reference/README.md. Its Reference/llvm-project junction is currently absent; the absolute source above exists and was inspected without changing workspace links. It is architecture-only evidence, not an imported library or authority for AS grammar/precedence.

Legacy lazy-expression, recursion and control-flow lifetime tests provide execution-oracle ideas only. Their compile helpers remain quarantined. The older canonical CONSTRUCT emitter traverses forward argument records and is not a safe substitute for the maintained compiler's reverse-formal rule; code shape and final push order alone cannot prove side-effect order.

## Verification evidence boundary

Planning verification is strict OpenSpec validation, scoped authoring-owner tests and candidate DAG/coverage checks only. Product implementation must map each row to complete observed case paths, actual managed RunIds and frozen source/binary identities. Missing behavior gets grouped RED/GREEN; already implemented controls retain baseline GREEN honestly.

NativeEngine final regression is deliberately broader than one feature prefix because shared metadata, registration, Context and constructor AST codec/verifier contracts are affected. The separate Baseline dormancy selector remains required. Full UE suites, Standalone, JIT, UE bindings and unrelated Harness aggregate profiles are not default gates.
