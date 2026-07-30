# Topic Content Blueprint

Captured: 2026-07-25

This is the content map behind the fifteen first-level topics. It is deliberately more specific than the navigation spec so later content changes can select a coherent batch without rediscovering audience, depth, implementation questions, or source families.

Depth is not a quota. A page should be created only when it has a distinct reader outcome.

## 1. `start` — 认识与开始

**Reader outcome:** Understand what this fork is, where it fits relative to Blueprint/C++, and get one current Actor script running.

| Depth | Planned content |
|---|---|
| L0 | Product identity, supported UE/fork baseline, when to use AS, Wiki reading map |
| L1 | Installation and first Actor, file placement, compile feedback, editor/VS Code entry |
| L2 | Project layout, common workflows, Blueprint/C++ cooperation, examples map |
| L3 | Source-engine requirements, plugin configuration, unsupported assumptions, version boundary |
| L4/L5 | Usually links to architecture/build topics rather than duplicating internals |

Primary inputs: `Guide_QuickStart.md`, Hazelight installation/introduction, `Example_MovingObject.as`, `Script/Game/Example_Actor.as`, plugin README, current build guide.

## 2. `language` — AngelScript 语言基础

**Reader outcome:** Learn ordinary AngelScript syntax and semantics before Unreal-specific extensions.

| Depth | Planned content |
|---|---|
| L0 | Syntax map and difference between language core and Unreal dialect |
| L1 | Variables, functions, classes, enums, control flow, handles/references |
| L2 | Inheritance, interfaces, overloads, conversions, operators, containers at language level |
| L3 | Unsupported/changed language behavior in the 2.33 + selective 2.38 fork |
| L4 | Tokenizer/parser/AST and semantic-analysis mechanisms |
| L5 | Vendored-source ownership, conformance tests, selective backport process |

Primary inputs: `AS_LanguageSyntax.md`, SDK language/frontend tests, `Example_Enum.as`, `Example_Functions.as`, `Test_Enums.as`, `Test_Handles.as`, `Test_Inheritance.as`.

## 3. `unreal-language` — Unreal AngelScript 语言特性

**Reader outcome:** Use and understand syntax introduced or reshaped by the Unreal integration.

Required feature families:

- `UPROPERTY` and its specifiers/metadata;
- `UFUNCTION`, Blueprint events, RPC specifiers, and Super dispatch;
- `default` statements;
- default components, root/attach/override behavior;
- delegate/event declaration, binding, broadcast, and generated shadow types;
- custom access specifications;
- `mixin` methods and the distinction from C++ `ScriptMixin`;
- f-strings/format strings and format specifiers;
- FName literals;
- Unreal containers and wrapper types as a feature map;
- editor/cooked conditions;
- removed, divergent, or fork-version behavior.

| Depth | Planned content |
|---|---|
| L0 | Feature catalog and the “ordinary AS vs Unreal AS” mental model |
| L1 | Minimal working examples for the high-frequency feature set |
| L2 | Complete combinations, specifier tables, Blueprint/editor interaction |
| L3 | Invalid combinations, compile diagnostics, runtime/packaging differences, fork deltas |
| L4 | Per-feature lowering/generation path from source syntax to AS/Unreal representation |
| L5 | Parser/preprocessor/generator/binding source ownership and regression evidence |

Primary inputs: all `Syntax_*` language-feature articles, `Guide_SyntaxFeatures.md`, relevant Hazelight scripting pages, current Core examples, preprocessor/compiler/generator sources and tests.

## 4. `type-object-reflection` — 类型、对象与反射模型

**Reader outcome:** Understand values, references, UObject/UStruct/class generation, lifetime, reflection, and wrapper types.

| Depth | Planned content |
|---|---|
| L0 | Value/reference/UObject mental model |
| L1 | Structs, handles, casts, validity, common wrapper types |
| L2 | TArray/TSet/TMap/TOptional, weak/soft/subclass references, interfaces |
| L3 | Lifetime, GC, serialization, replication, editor/reflection boundaries |
| L4 | AS type representation, script objects, UClass/UStruct generation, property/function representation |
| L5 | Type registration, generator sources, GC/object tests, compatibility contracts |

Primary inputs: `Syntax_T*`, `Type_Core.md`, `Type_ClassGeneration.md`, `Type_StructGeneration.md`, `AS_ObjectLifecycle.md`, `AS_GarbageCollector.md`.

## 5. `unreal-core` — Unreal 核心脚本编程

**Reader outcome:** Build everyday Unreal gameplay and system code using the core plugin surface.

| Depth | Planned content |
|---|---|
| L0 | Actors, components, UObject, subsystems, function libraries |
| L1 | Lifecycle, spawn, components, timers, overlaps, math, subsystem access |
| L2 | Construction, Blueprint subclassing/interoperability, function-library patterns |
| L3 | World/context ownership, editor/runtime differences, performance and lifecycle traps |
| L4/L5 | Link to object generation, runtime lifecycle, and binding internals |

Primary inputs: Hazelight actor/component/function-library/subsystem pages and Core/Extended examples.

## 6. `compile-module-preprocessor` — 编译、模块与预处理

**Reader outcome:** Understand how source files become modules and how preprocessing/dependencies affect builds and reloads.

| Depth | Planned content |
|---|---|
| L0 | Source-to-executable pipeline overview |
| L1 | Directives, includes/imports, module/file layout, common diagnostics |
| L2 | Conditions, macros, generated declarations, dependency behavior |
| L3 | Cycles, invalidation, incremental/reload boundaries, version behavior |
| L4 | Preprocessor, source provider, parser/compiler stages, compilation context/events |
| L5 | Source ownership, module-loading contracts, compiler/preprocessor tests |

Primary inputs: `Type_Preprocessor.md`, `AS_Compiler.md`, `AS_Parser.md`, `Arch_ModuleLoading.md`, preprocessor sources/tests, SDK frontend/compiler/module tests.

## 7. `hot-reload` — 热重载与实时迭代

**Reader outcome:** Predict and recover from reload behavior, then trace the full reload implementation.

| Depth | Planned content |
|---|---|
| L0 | What hot reload preserves and why it matters |
| L1 | Edit/save/compile daily workflow and feedback |
| L2 | Change classification matrix: function body, properties, components, inheritance, interfaces, rename |
| L3 | Soft/full reload, PIE exit, restart, failure recovery, Blueprint impact |
| L4 | Watcher/coalescing → preprocess/dependency → compile → reload plan → generation/reinstance → Blueprint impact |
| L5 | Runtime/editor ownership, CDO/default-component contracts, cleanup/global state, tests/diagnostics |

Primary inputs: `RT_HotReload.md`, ClassGenerator reload files, Editor `HotReload/`, BlueprintImpact, reload tests and state-dump evidence.

## 8. `editor-ide-debugging` — 编辑器、IDE 与调试

**Reader outcome:** Navigate, edit, debug, and diagnose scripts across Unreal Editor and the project-owned VS Code extension.

| Depth | Planned content |
|---|---|
| L0 | Tooling map |
| L1 | VS Code setup, source navigation, breakpoints, stack and variables |
| L2 | Content Browser, code generation, debug settings, console workflow |
| L3 | protocol/version mismatch, unavailable source, editor/headless boundaries |
| L4 | DebugServer V2, DAP messages, database/settings, navigation bridge |
| L5 | extension/runtime protocol ownership and compatibility tests |

Primary inputs: `RT_Debugger.md`, `VSCodeAngelscript.md`, DebugServer sources/tests, VS Code extension, `Example_ConsoleWorkflow.as`.

## 9. `testing-diagnostics-release` — 测试、诊断与发布

**Reader outcome:** Choose the right test layer, run it, inspect failures/state/coverage, and validate a release.

| Depth | Planned content |
|---|---|
| L0 | Test/diagnostic layer map and non-conflated baselines |
| L1 | Common Wiki/plugin test commands and first script test |
| L2 | CQTest, script tests, C++ automation, state dump, coverage, StaticJIT/release checks |
| L3 | headless limitations, isolation, flakiness, performance, artifact interpretation |
| L4 | runtime-owned AS test protocol, UE bridge, runner lifecycle, coverage hooks |
| L5 | suite ownership, macros/helpers, state containment, baseline maintenance |

Primary inputs: testing guides, Test knowledge family, CQTest note, state dump, CodeCoverage, current test sources.

## 10. `runtime-jit-vm` — 运行时、StaticJIT 与虚拟机

**Reader outcome:** Understand runtime lifecycle and how bytecode, contexts, GC, precompiled data, and StaticJIT execute.

| Depth | Planned content |
|---|---|
| L0 | Runtime components and execution choices |
| L1 | Lifecycle/configuration symptoms relevant to script authors |
| L2 | precompiled data and StaticJIT use/packaging |
| L3 | cache compatibility, fallback, performance, failure boundaries |
| L4 | bytecode, VM context, calls, objects/GC, StaticJIT translation |
| L5 | kernel fork ownership, serialization/layout/version contracts, tests |

Primary inputs: `AS_ByteCode`, `AS_VirtualMachine`, `AS_ScriptEngine`, `AS_GarbageCollector`, `RT_StaticJIT`, `RT_ThirdPartyKernel`, runtime and SDK tests.

## 11. `bindings-uht-extensions` — 绑定、UHT 与插件扩展

**Reader outcome:** Understand how Unreal C++ APIs become callable from scripts and how to extend the binding surface safely.

| Depth | Planned content |
|---|---|
| L0 | Manual/generated/reflective binding mental model |
| L1 | Exposing a supported API and reading generated availability |
| L2 | mixin libraries, UHT configuration, fallback cases |
| L3 | marshalling exclusions, RPC fallback, installed/source engine boundaries |
| L4 | Bind database, FunctionCallers, UHT models/emission, native address features |
| L5 | layout-version contract, module dependencies, generated artifact tests/audits |

Primary inputs: Hazelight C++ binding pages, binding guides/types, UHT knowledge, binding audit/optimization guides, Runtime Core/UHTTool sources and tests.

Dedicated UHT sequence:

| Logical key | Depth | Planned content |
|---|---|---|
| `bindings-uht-extensions/uht-plugin-overview` | L1 | Role of the independent C# UBT/UHT plugin, prerequisites, configuration ownership, build timing, and how to know whether it ran. |
| `bindings-uht-extensions/uht-generation-workflow` | L2 | Headers/metadata → module selection → eligibility/policy → shards/aggregators → statistics/diagnostics/cleanup → Runtime registration or fallback. |
| `bindings-uht-extensions/uht-plugin-internals` | L4 internals | C# models, configuration resolver, policy, emitters, orchestrator, native Runtime-linked output, modular-feature payload, and reflective fallback bridge. |
| `bindings-uht-extensions/uht-plugin-maintenance` | L5 internals | Layout-version file, Runtime/view/generator ABI synchronization, source-engine constraint, RPC/fallback invariants, artifact audits, and tests. |

The sequence must keep three paths distinct:

| Path | Core contract |
|---|---|
| `NativeRuntimeLinked` | Generated `AS_FunctionBinding_<Module>_*.gen.cpp` shards compile into configured Runtime dependencies. |
| `NativeModuleFunctionAddress` | Target-module shards publish versioned POD binding data through `IModularFeatures`; source engine only. |
| `BlueprintCallableReflectiveFallback` | Generic reflective bridge for supported signatures and the mandatory route for RPC/Net UFunctions; does not bypass Unreal routing. |

## 12. `architecture-maintenance` — 插件架构与维护

**Reader outcome:** Locate ownership, understand subsystem/module lifecycle, and change the plugin without violating boundaries.

| Depth | Planned content |
|---|---|
| L0 | Runtime/Editor/Test/UHT plus optional-plugin architecture |
| L1/L2 | repository navigation, build/test/change workflow |
| L3 | state ownership, dependency/load-phase constraints, compatibility surfaces |
| L4 | runtime/editor/bootstrap/global-state collaboration |
| L5 | source maps, invariants, test/dump observers, fork/backport maintenance |

Primary inputs: architecture knowledge family, global-state and fork strategy guides, AGENTS architecture, module build files.

## 13. `topics-integrations` — 专题与领域集成

**Reader outcome:** Enter optional/domain material without confusing it with the core learning spine.

Initial children:

| Child | Kind | Required boundary |
|---|---|---|
| GameplayTags | optional plugin | `AngelscriptGameplayTags` ownership and replay/editor bridge |
| GAS | optional plugin | `AngelscriptGAS` and required GameplayTags dependency |
| Enhanced Input | engine domain | UE input integration, not a separately packaged AS plugin |
| Networking/RPC | engine domain | RPC/replication behavior and reflective fallback |
| UI/UMG | engine domain | widget/UI scripting |
| AI/BehaviorTree | engine domain | behavior-tree scripting |

Each child may later have its own L0–L5 sequence; the foundation creates one nonempty L0 landing only.

## 14. `reference-differences-version` — 参考、差异、版本与项目

**Reader outcome:** Determine which behavior/version/source a claim applies to and compare this fork with Hazelight/upstream.

| Depth | Planned content |
|---|---|
| L0 | Current fork identity/status and reference map |
| L1/L2 | configuration/API/index references |
| L3 | Hazelight/upstream/fork feature differences |
| L4 | selected backport decisions and historical comparisons |
| L5 | provenance registry, source corpus revisions, migration/audit records |

Primary inputs: fork/difference guides, Hazelight reference docs, local source inventory, relevant OpenSpec records.

Initial Hazelight nested topic:

| Logical key | Depth | Planned content |
|---|---|---|
| `reference-differences-version/hazelight-comparison-overview` | L0 | Purpose, engine-fork versus standalone-plugin mental model, pinned baselines, evidence/confidence legend, and relationship labels. |
| `reference-differences-version/hazelight-capability-matrix` | L2 | Revisioned index across language, kernel, Runtime, Editor, reload, binding/UHT, debugging, testing, examples, integrations, removals, and local-only capabilities. |
| `reference-differences-version/hazelight-function-binding` | L4 internals | Hazelight engine UHT/type-erased function-pointer map and direct function-map enumeration versus local C# UHTTool backends and reflective fallback. |
| `reference-differences-version/hazelight-class-generation` | L4 internals | Hybrid Hazelight `UClass` hooks plus `UASClass` versus plugin-contained UASClass/UASFunction, defaults/CDO, dispatch, reload, and editor-only propagation. |
| `reference-differences-version/hazelight-struct-generation` | L4 internals | UASStruct creation, `ICppStructOps`/fake-vtable context, value lifetime, serialization, hot reload, and UE-version-specific interface differences. |
| `reference-differences-version/hazelight-architecture-differences` | L4 internals | Engine patches, module/package boundaries, optional plugins, upgrade/ABI consequences, and local-only subsystems. |
| `reference-differences-version/hazelight-audit-maintenance` | L5 internals | Read-only update audit, source/evidence priority, private-source boundary, stale rows, historical preservation, and separate adoption OpenSpecs. |

The initial research pins Hazelight `f459e6322f63deef8d345f1c1624734cc22747e3`, local plugin `4e2e23ca16ae9f1786258fb96b09b268259b1aad`, and the dated 2026-03-12 engine folder report. The report's thirteen visible engine leaf files are catalogued but explicitly non-exhaustive. Detailed findings and known stale historical claims live in `hazelight-comparison-audit.md` and `hazelight-engine-change-inventory.md`.

## 15. `showcase-lab` — Showcase 与实验室

**Reader outcome:** Find the approved way to express technical content and inspect experiments without mistaking them for product contracts.

| Depth | Planned content |
|---|---|
| L0 | Base/Pattern/Lab map |
| L1/L2 | stable authoring examples and reusable patterns |
| L3 | compatibility/accessibility/responsive constraints |
| L4/L5 | experimental implementation notes only when a Showcase component has real runtime behavior |

Primary inputs: current example pages, Markdown More, WikiText, AngelScript code widgets, Draw.io, `showcase-gap-matrix.md`, and `tiddlywiki-expression-showcase.md`.

The 42-entry catalog includes explicit TiddlyWiki authoring coverage:

- Base B13–B15: procedures/functions/legacy macros, trusted HTML with widgets, and embedded local/external pages;
- Pattern P15–P16: parameterized native WikiText components and embedded companions with authoritative static fallback;
- Lab L11: web-embed CSP/security/privacy/packaging experiments.

These entries teach and verify authoring surfaces; they do not authorize a heavy runtime, arbitrary external scripts, or a network dependency for ordinary Wiki operation.

## Cross-topic “实现原理” catalog

These are candidates, not mandatory foundation pages. Each later content change selects a coherent set and verifies it against a pinned source revision.

| Mechanism key | Owning topic | Core question | Primary source areas |
|---|---|---|---|
| `source-and-preprocess-pipeline` | compile/module/preprocessor | How are virtual files, directives, generated text, and dependencies constructed? | Runtime `Preprocessor/`, `Core/AngelscriptSource*`, preprocessor tests |
| `parser-and-ast` | language | How does source become syntax nodes with source ranges? | third-party `as_parser.*`, `as_scriptnode.*`, frontend tests |
| `compiler-and-bytecode` | compile/module/preprocessor | How do semantic analysis and code generation emit executable instructions? | `as_compiler.*`, `as_bytecode.*`, compiler tests |
| `vm-context-execution` | runtime/JIT/VM | How does an AS context execute, suspend, call, and recover? | `as_context.*`, VM/runtime tests |
| `script-engine-and-modules` | runtime/JIT/VM | How are registrations, modules, functions, and engine state owned? | `as_scriptengine.*`, `as_module.*`, Runtime Core |
| `object-lifetime-and-gc` | type/object/reflection | How do AS object lifetime and Unreal object validity interact? | `as_scriptobject.*`, GC sources/tests, ASClass |
| `unreal-type-representation` | type/object/reflection | How are AS types mapped to Unreal types and wrappers? | `AngelscriptType.*`, ASClass/ASStruct, bind database |
| `class-struct-generation` | type/object/reflection | How do script declarations become UClass/UStruct metadata? | ClassGenerator generation/finalize, ASClass/ASStruct |
| `default-statement-lowering` | Unreal language | How does `default` map to construction/default objects? | preprocessor/generator construction sources and tests |
| `default-component-generation` | Unreal language | How are component declarations, root/attach, overrides, and CDOs produced? | ASClass construction, ClassGenerator, component/reload tests |
| `delegate-event-representation` | Unreal language | How do declarations become callable/broadcastable types? | preprocessor/class generation, delegate-shadow notes/tests |
| `format-string-lowering` | Unreal language | How are f-string expressions parsed and expanded? | preprocessor/compiler/string binding sources and tests |
| `fname-literal-lowering` | Unreal language | How do FName literals become registered/runtime values? | preprocessor/compiler/binds and syntax tests |
| `binding-discovery-and-dispatch` | bindings/UHT/extensions | How is a function selected and called through manual/generated/fallback paths? | Binds, BindDatabase, FunctionCallers, UHTTool |
| `uht-generated-bindings` | bindings/UHT/extensions | How do headers become shards, aggregators, statistics, and runtime registration? | AngelscriptUHTTool and generated binding tests |
| `calling-conventions-and-marshalling` | bindings/UHT/extensions | How do parameters, returns, refs, containers, and fallbacks cross the boundary? | FunctionCallers, AS calling conventions, binding tests |
| `hazelight-binding-architecture` | reference/differences/version | How does Hazelight's engine-UHT pointer map differ from the local generated/fallback binding paths? | pinned private Hazelight source, local UHTTool/Runtime source, binding tests |
| `hazelight-class-struct-architecture` | reference/differences/version | Which engine hooks, generated types, lifecycle operations, and version constraints differ? | Hazelight engine/plugin source, local ClassGenerator/UASClass/UASStruct, generation/lifetime/reload tests |
| `hazelight-engine-patch-families` | reference/differences/version | Which engine patch families exist, why, and what standalone-plugin mechanisms replace or avoid them? | dated engine report, current pinned source markers, local architecture evidence |
| `hot-reload-planning` | hot reload | How are changes classified and a reload plan selected? | ClassReloadPlanner and ClassGenerator reload-planning/soft/full files |
| `hot-reload-reinstancing` | hot reload | How are types, CDOs, defaults, components, and live instances migrated? | ClassGenerator reinstancing, Editor ClassReloadHelper, reload tests |
| `blueprint-impact` | hot reload | How are affected Blueprint descendants discovered and rebuilt? | Editor BlueprintImpact and tests |
| `debugserver-v2` | editor/IDE/debugging | How do DAP requests, stack/scopes, and script contexts connect? | DebugServer, extension protocol, debugger tests |
| `staticjit-translation` | runtime/JIT/VM | How do bytecodes and precompiled data become native-form execution? | Runtime `StaticJIT/`, AOT/precompiled-data tests |
| `runtime-test-bridge` | testing/diagnostics/release | How are AS tests discovered/executed and exposed to UE Automation? | Runtime `Testing/`, Test module, CQTest/test guides |
| `coverage-and-state-observation` | testing/diagnostics/release | How do line coverage and pure-observer state dumps collect evidence? | CodeCoverage, Dump, tests |

## Content-batch dependency order

1. Foundation taxonomy, Chinese landing pages, compatibility routing, and contract tests.
2. Chinese quick start plus core language basics.
3. Chinese Unreal language-feature L1/L2 pages.
4. Chinese hot-reload L1–L3 pages.
5. First internals set: source/preprocess/parser/compiler plus hot-reload planning/reinstancing.
6. Object/reflection and binding internals.
7. Runtime/VM/StaticJIT and debugger/test internals.
8. Topic integrations in demand order.
9. English translation of only reviewed Chinese pages, batch by batch.
