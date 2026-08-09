# 已实现的 Wiki 文章清单

> OpenSpec change：`docs-wiki-article-gaps-and-supplements`
> 记录日期：2026-08-08
> 本文记录该 change 已实现的 200 篇中文 TiddlyWiki `.tid` 候选文章，以及各专题解决的问题。30 篇为现有页面重写，170 篇为新增文章；全部保持 `as-content-status: draft`，暂存在 `supplements/`，尚未迁入正式 `Wiki/` 子模块。

逐篇采用元数据、new/rewrite 生命周期、导航位置、来源键和 grounding path 见 [supplements/README.md](supplements/README.md)。下列标题、doc-key、文章类型和 L0–L5 深度均来自实际 `.tid` frontmatter。

## 1. Start：入门与首次接入（6 篇）

这组解决源码插件安装、脚本目录、Editor 编译循环、诊断和第一次 Blueprint 交接。

- L1 / guide《源码插件安装检查表》— `start/installation-checklist`
- L1 / guide《Script 目录与文件布局》— `start/project-script-layout`
- L1 / tutorial《Editor 中的脚本编译循环》— `start/editor-compile-loop`
- L1 / troubleshooting《阅读第一条编译诊断》— `start/read-compile-diagnostics`
- L1 / tutorial《第一次交给 Blueprint》— `start/blueprint-handoff`
- L1 / troubleshooting《首次运行排错》— `start/troubleshooting-first-run`

六篇都不是简单步骤清单：正文包含安装层级、成功证据、失败停点、最后成功编译状态、Blueprint 默认值所有权和排错决策树。

## 2. Language：基础语言与常用类型（12 篇）

这组面向日常脚本作者，解释字符串、数值、容器、对象句柄、值语义、函数参数和委托生命周期。

- L1 / guide《FString、FName、FText 与格式化》— `language/strings-names-and-formatting`
- L1 / reference《数值类型、字面量与转换》— `language/numeric-types-and-conversions`
- L1 / tutorial《TArray 与安全迭代》— `language/arrays-and-iteration`
- L2 / guide《TSet 与 TMap》— `language/sets-and-maps`
- L2 / guide《UObject 句柄、弱引用与软引用》— `language/object-handles-and-smart-pointers`
- L2 / guide《结构体与值语义》— `language/structs-and-value-types`
- L1 / guide《Enum 与 switch》— `language/enums-and-switch`
- L1 / guide《函数参数、引用与输出值》— `language/functions-arguments-and-output`
- L2 / reference《UFUNCTION Specifier 选择》— `language/function-specifiers`
- L2 / guide《Access 能力控制》— `language/access-capabilities`
- L2 / guide《Mixin 与扩展方法》— `language/mixins-and-extension-methods`
- L2 / guide《Delegate、Event 与绑定生命周期》— `language/delegates-events-and-binding`

重点内容包括 TSet/TMap 的哈希与键稳定性、UObject handle/weak/soft reference 的 GC 与加载边界、struct copy/alias/value semantics、参数方向，以及 Delegate owner/subscriber/解绑/销毁生命周期。

## 3. UnrealLanguage：Unreal 方言与反射语法（21 篇）

这组覆盖 `UPROPERTY`、`UFUNCTION`、`default`、DefaultComponent、delegate、mixin、格式化、RPC、Editor-only，以及这些语法从 parser 到 ClassGenerator、UFunction 和 Blueprint 的实现路径。

- L0 / guide《Unreal AngelScript 语言特性》— `unreal-language/index`
- L1 / tutorial《第一条 Unreal 方言功能路径》— `unreal-language/first-feature-path`
- L2 / reference《Unreal AngelScript 功能目录》— `unreal-language/feature-catalog`
- L3 / guide《Unreal 方言边界与 fork 差异》— `unreal-language/boundaries-and-differences`
- L4 / internals《Unreal 方言功能实现原理》— `unreal-language/feature-implementation-principles`
- L5 / internals《Unreal 方言源码、测试与维护》— `unreal-language/source-tests-maintenance`
- L3 / reference《UPROPERTY 指定符与生成语义》— `unreal-language/property-specifiers`
- L3 / reference《UFUNCTION 指定符与调用表面》— `unreal-language/function-specifiers`
- L3 / guide《default 语句与 CDO 默认值》— `unreal-language/default-statement`
- L3 / guide《DefaultComponent 与 OverrideComponent》— `unreal-language/default-components`
- L3 / explanation《构造、Defaults 与 Construction Script 语义》— `unreal-language/construction-script-semantics`
- L2 / guide《属性访问器已移除：字段与显式方法》— `unreal-language/property-accessors`
- L3 / reference《delegate 与 event 声明的完整执行链》— `unreal-language/delegate-event-declarations`
- L2 / guide《f-string 展开、格式说明符与边界》— `unreal-language/format-strings`
- L3 / explanation《Mixin 函数的解析、绑定与维护》— `unreal-language/mixin-functions`
- L2 / guide《全局常量、命名空间与状态所有权》— `unreal-language/global-constants-and-namespaces`
- L2 / guide《FName 字面量》— `unreal-language/fname-literals`
- L3 / reference《网络指定符、RPC 路由与复制合同》— `unreal-language/network-specifiers`
- L3 / guide《Editor-only 脚本的编译、绑定与打包边界》— `unreal-language/editor-only-script`
- L3 / reference《反射签名限制与调用路径降级》— `unreal-language/reflection-signature-limits`
- L2 / explanation《与 Unreal C++ / Blueprint 的差异》— `unreal-language/cpp-blueprint-differences`

这组建立了四层合同：parser/preprocessor 是否接受语法、语法 lowering 成什么描述、ClassGenerator/绑定层发布成什么 Unreal 表面，以及 Script/Blueprint/RPC/Editor/cooked build 如何消费。它避免把“能解析”直接等同于“后端完整支持”。

## 4. TypeObjectReflection：类型、对象与反射（10 篇）

这组深入到 ClassGenerator、FProperty、UFunction、容器属性、GC schema 和脚本结构体生命周期。

- L2 / reference《附加 Actor 按类查询》— `type-object-reflection/actor-attached-actor-query`
- L3 / internals《脚本 Class 生成生命周期》— `type-object-reflection/class-generation-lifecycle`
- L3 / internals《脚本成员到 FProperty》— `type-object-reflection/property-generation`
- L5 / internals《脚本结构体值生命周期》— `type-object-reflection/script-struct-value-lifecycle`
- L3 / reference《TOptional 与空对象句柄》— `type-object-reflection/toptional-null-handle`
- L4 / internals《UFunction 生成与脚本分派》— `type-object-reflection/function-generation-and-dispatch`
- L5 / internals《ClassGenerator 结构剖析》— `type-object-reflection/classgenerator-structure`
- L4 / internals《容器属性与元素类型》— `type-object-reflection/container-property-generation`
- L4 / internals《GC 引用 Schema 与脚本对象》— `type-object-reflection/gc-reference-schema`
- L3 / explanation《反射 Metadata 的边界》— `type-object-reflection/reflection-metadata-boundaries`

`classgenerator-structure` 与 `script-struct-value-lifecycle` 达到 L5，包含阶段文件、关键结构、对象版本链、迁移影响和维护入口，而不是宏观介绍。

## 5. UnrealCore：Unreal 日常脚本编程（14 篇）

这组面向 Actor、Component、Subsystem、World、Timer、Blueprint、网络和打包等常见项目工作。

- L0 / tutorial《Unreal 核心脚本编程》— `unreal-core/index`
- L1 / guide《Actors、Components 与默认值》— `unreal-core/actors-components-defaults`
- L1 / guide《Function Libraries》— `unreal-core/function-libraries`
- L2 / guide《Script Subsystems》— `unreal-core/subsystems`
- L1 / guide《Actor 生命周期》— `unreal-core/actor-lifecycle`
- L1 / guide《Component 生命周期与事件》— `unreal-core/component-lifecycle`
- L1 / guide《ConstructionScript 与派生数据》— `unreal-core/construction-script`
- L2 / guide《UObject 生命周期与 GC》— `unreal-core/object-lifecycle-and-gc`
- L2 / guide《World Context 与多 World》— `unreal-core/world-context`
- L1 / guide《Timer、Tick 与 World Time》— `unreal-core/timers-and-world-time`
- L1 / guide《资产、对象与 Class 引用》— `unreal-core/asset-and-class-references`
- L1 / guide《Blueprint 协作边界》— `unreal-core/blueprint-integration`
- L1 / guide《网络 Authority 与复制思维》— `unreal-core/network-authority`
- L2 / guide《Script Packaging 与 Cooking》— `unreal-core/packaging-and-cooking`

这组区分 CDO、Blueprint 默认值和实例 override，Editor/PIE/GameInstance/WorldSubsystem，authority/client，soft object/class reference，以及 Editor 中可用与 cooked 中可用的差异。

## 6. CompileModulePreprocessor：编译、模块和预处理器（13 篇）

这组从编译设置深入到 parser、compiler、预处理上下文、虚拟路径、源提供者和失败原子性。

- L2 / reference《AngelScript 编译设置》— `compile-module-preprocessor/angelscript-compile-settings`
- L5 / internals《asCCompiler 编译流程》— `compile-module-preprocessor/as-compiler-pipeline`
- L5 / internals《asCParser 解析器内部结构》— `compile-module-preprocessor/as-parser-internals`
- L4 / internals《预处理器上下文》— `compile-module-preprocessor/preprocessor-context`
- L4 / internals《预处理摘要（Preprocessing Summary）》— `compile-module-preprocessor/preprocessor-summary`
- L4 / internals《虚拟脚本路径》— `compile-module-preprocessor/virtual-script-paths`
- L4 / internals《编译事件钩子系统》— `compile-module-preprocessor/compilation-events`
- L2 / reference《可配置脚本跳过目录》— `compile-module-preprocessor/configurable-script-skip-directories`
- L4 / internals《脚本源提供者边界》— `compile-module-preprocessor/script-source-provider`
- L3 / internals《Include 依赖图与增量失效》— `compile-module-preprocessor/include-dependency-graph`
- L2 / guide《条件编译与 Editor-only 边界》— `compile-module-preprocessor/conditional-compilation`
- L3 / explanation《Source Provider 与模块身份》— `compile-module-preprocessor/source-module-identity`
- L4 / internals《编译失败原子性》— `compile-module-preprocessor/compile-failure-atomicity`

核心内容包括物理文件/逻辑路径/模块身份、include 依赖图与增量失效、candidate compilation 与 last-good module、编译失败后必须保留的状态、Preprocessing Summary 的值对象与新鲜度，以及 standalone bundle 的稳定逻辑路径合同。

## 7. HotReload：热重载与类型恢复（11 篇）

这组覆盖日常热重载、变化分类、Blueprint/CDO、属性、结构体、委托、类重命名和底层 reload pipeline。

- L1 / tutorial《热重载日常工作流》— `hot-reload/daily-workflow`
- L2 / reference《热重载变化分类矩阵》— `hot-reload/change-classification`
- L3 / reference《ClassGenerator 证据布局与重载规划器》— `hot-reload/classgenerator-test-layout`
- L3 / guide《热重载失败与恢复》— `hot-reload/failures-and-recovery`
- L3 / reference《属性热重载覆盖要求》— `hot-reload/hotreload-property-coverage`
- L3 / reference《热重载自动化测试覆盖》— `hot-reload/hotreload-test-coverage`
- L4 / internals《热重载管线实现原理》— `hot-reload/reload-pipeline-internals`
- L5 / internals《热重载源码、测试与维护》— `hot-reload/source-tests-maintenance`
- L3 / guide《Blueprint 子类、CDO 与默认值迁移》— `hot-reload/blueprint-child-and-defaults`
- L3 / guide《类重命名、删除与重定向》— `hot-reload/class-rename-and-removal`
- L4 / internals《结构体、委托与类型版本链》— `hot-reload/versioned-types-and-delegates`

这组重点区分 body-only soft reload、反射形状变化导致的 full reload、old class/new canonical class、CDO/新实例/既有实例/Blueprint override、rename/delete/CoreRedirect 和版本链清理条件。

## 8. EditorIdeDebugging：编辑器、VS Code 与调试（11 篇）

这组覆盖 VS Code 扩展、断点、DebugServer V2、LSP 协议、源码跳转、Content Browser 和调试会话生命周期。

- L0 / guide《编辑器、IDE 与调试》— `editor-ide-debugging/index`
- L1 / tutorial《VS Code 扩展配置》— `editor-ide-debugging/vscode-setup`
- L2 / guide《断点与调试会话》— `editor-ide-debugging/debugging-breakpoints`
- L2 / reference《Blueprint 父类选择器中的脚本类可见性》— `editor-ide-debugging/blueprint-parent-class-discovery`
- L4 / internals《DebugServer 协议 V2 与兼容边界》— `editor-ide-debugging/debugger-protocol-v2`
- L3 / reference《编辑器诊断自动化覆盖说明》— `editor-ide-debugging/editor-diagnostics-coverage`
- L3 / reference《VS Code LSP 协议兼容性》— `editor-ide-debugging/vscode-lsp-protocol-compat`
- L4 / internals《学习追踪事件流》— `editor-ide-debugging/learning-trace-event-stream`
- L2 / guide《Content Browser 中的 .as 脚本》— `editor-ide-debugging/content-browser-scripts`
- L2 / guide《从 Unreal 跳转到脚本源码》— `editor-ide-debugging/source-navigation`
- L3 / internals《Debug Session 生命周期》— `editor-ide-debugging/debug-session-lifecycle`

除用户操作外，还记录 DebugServer V2 wire contract、VS Code extension 与 Runtime 协议、breakpoint 与逻辑路径、session 建立/断开/重连/过期状态，以及 LSP/DebugDatabaseSettings 兼容关系。

## 9. TestingDiagnosticsRelease：测试、诊断与发布（18 篇）

这组实现的是测试与诊断文档；本 change 没有新增或运行测试。

- L4 / reference《脚本测试套件运行器》— `testing-diagnostics-release/script-test-suite-runner`
- L3 / reference《测试工具头文件布局》— `testing-diagnostics-release/test-utilities-header-layout`
- L2 / reference《单元测试编译开关》— `testing-diagnostics-release/unit-test-gates`
- L3 / reference《绑定测试执行与命名规范》— `testing-diagnostics-release/bindings-test-execute-and-naming`
- L4 / reference《代码覆盖率数据导出》— `testing-diagnostics-release/code-coverage-data-export`
- L4 / internals《代码覆盖率扩展（内部机制）》— `testing-diagnostics-release/code-coverage-extension`
- L4 / internals《Crash Snapshot 扩展生命周期》— `testing-diagnostics-release/crash-snapshot-extension`
- L3 / reference《功能运行时行为覆盖》— `testing-diagnostics-release/functional-runtime-behavior-coverage`
- L4 / reference《原生 SDK 测试覆盖》— `testing-diagnostics-release/native-sdk-test-coverage`
- L3 / reference《脚本运行时诊断导出契约》— `testing-diagnostics-release/script-runtime-diagnostics-export`
- L3 / reference《测试辅助 API 参考》— `testing-diagnostics-release/test-helper-api`
- L3 / reference《测试 Unity Build 符号卫生》— `testing-diagnostics-release/test-unity-build-symbol-hygiene`
- L3 / reference《ScriptExamples 退役与功能测试整合》— `testing-diagnostics-release/examples-functional-coverage`
- L4 / internals《测试引擎生命周期》— `testing-diagnostics-release/test-engine-lifecycle`
- L2 / reference《测试范围与数字口径》— `testing-diagnostics-release/test-scope-and-baselines`
- L2 / guide《Reflected Script Test Suite》— `testing-diagnostics-release/reflected-script-tests`
- L3 / guide《Script Test World 与清理工具》— `testing-diagnostics-release/script-test-world-tools`
- L2 / reference《发布验证矩阵》— `testing-diagnostics-release/release-verification-matrix`

这组明确区分 275/275 catalogued C++ baseline、1518+ automation definitions、691/691 native SDK prefix、2396/2396 All suite 和 19/19 Standalone CTest，避免把不同测试域直接相加或互相替代。

## 10. RuntimeJitVm：Runtime、VM、GC 与 StaticJIT（20 篇）

这是整体最深入的一组，包含大量 L4/L5 文章。

- L5 / internals《asCScriptEngine 核心架构》— `runtime-jit-vm/as-script-engine-core`
- L4 / internals《Engine 可观测状态快照》— `runtime-jit-vm/engine-reflectable-state`
- L5 / internals《执行上下文与引擎作用域》— `runtime-jit-vm/execution-context`
- L5 / internals《引擎创建工厂（Create Factory）》— `runtime-jit-vm/runtime-engine-create-factory`
- L4 / internals《StaticJIT AOT 生成与验证工作流》— `runtime-jit-vm/static-jit-aot-test`
- L5 / internals《UASFunction 派发矩阵与 JIT 路径》— `runtime-jit-vm/uasfunction-dispatch-matrix`
- L5 / internals《引擎作用域的运行时状态》— `runtime-jit-vm/engine-scoped-runtime-state`
- L5 / internals《UASFunction 运行时派发覆盖》— `runtime-jit-vm/uasfunction-runtime-dispatch-coverage`
- L5 / internals《AS 字节码指令集》— `runtime-jit-vm/as-bytecode-instruction-set`
- L4 / internals《Engine Shutdown 与资源清理》— `runtime-jit-vm/engine-shutdown-resource-cleanup`
- L4 / internals《引擎状态快照与差分》— `runtime-jit-vm/engine-state-dump-diff`
- L5 / internals《引擎共享状态扁平化》— `runtime-jit-vm/runtime-engine-shared-state-flattening`
- L4 / internals《Snippet 编译与执行》— `runtime-jit-vm/snippet-execution`
- L4 / internals《StaticJIT 诊断接口》— `runtime-jit-vm/static-jit-diagnostics`
- L4 / internals《VM 函数调用生命周期》— `runtime-jit-vm/vm-call-lifecycle`
- L4 / internals《AngelScript GC 与 Unreal GC 协作》— `runtime-jit-vm/garbage-collector`
- L3 / internals《脚本异常与调用栈》— `runtime-jit-vm/exceptions-and-stacktraces`
- L4 / internals《StaticJIT 生成与分派管线》— `runtime-jit-vm/static-jit-pipeline`
- L3 / reference《Standalone Offline Bundle 合同》— `runtime-jit-vm/offline-bundle-contract`
- L2 / reference《Standalone Native Runtime 沙箱》— `runtime-jit-vm/native-runtime-sandbox`

这组写到 `asCScriptEngine` 创建/共享状态/作用域/shutdown、execution context 生命周期、字节码解释、UASFunction/JIT dispatch、Unreal GC 与 AngelScript GC、StaticJIT 生成与 fallback、native-runtime 白名单，以及 offline bundle 不合并、不猜路径、不回退的合同。

## 11. BindingsUhtExtensions：Bindings、UHT 与扩展插件（22 篇）

这是数量最多的专题，覆盖手工绑定、生成绑定、直接绑定、反射回退、native backend、marshalling 和可选插件注册。

- L4 / reference《BlueprintCallable 直接绑定流水线》— `bindings-uht-extensions/blueprintcallable-direct-bind`
- L3 / reference《自动函数绑定的默认关闭边界》— `bindings-uht-extensions/crossmodule-default-off`
- L3 / reference《Blueprint 库命名空间与完整名称契约》— `bindings-uht-extensions/library-full-namespaces`
- L3 / reference《Target-aware 类型化绑定 DSL》— `bindings-uht-extensions/typed-bind-dsl`
- L3 / reference《GameplayTags 可选扩展的注册与重放》— `bindings-uht-extensions/gameplaytags-extension`
- L4 / internals《绑定阶段、旧顺序与执行观测》— `bindings-uht-extensions/bind-execution-timing`
- L3 / reference《绑定 Trait 链式 API》— `bindings-uht-extensions/bind-trait-fluent-api`
- L3 / reference《UHT 函数绑定诊断》— `bindings-uht-extensions/cross-module-bind-diagnostics`
- L3 / reference《跨模块生成配置解析与引擎分发约束》— `bindings-uht-extensions/cross-module-generation-profiles`
- L4 / internals《FunctionBinding 增量生成与物理分片边界》— `bindings-uht-extensions/function-table-incremental-generation`
- L4 / internals《AS-to-Unreal 生成产物边界》— `bindings-uht-extensions/generator-artifact-boundaries`
- L3 / reference《跨模块生成 allowlist 的当前语义》— `bindings-uht-extensions/cross-module-generation-allowlist`
- L4 / internals《CompileOut 语义与失效函数安全》— `bindings-uht-extensions/compileout-bind-safety`
- L4 / internals《统一属性访问：字段直访与显式方法》— `bindings-uht-extensions/property-access-uniform`
- L3 / reference《函数绑定路径选择》— `bindings-uht-extensions/binding-path-selection`
- L3 / guide《手工 Bind 的所有权与审查》— `bindings-uht-extensions/manual-bind-ownership`
- L4 / internals《UHT 生成函数表与 Shard》— `bindings-uht-extensions/generated-function-tables`
- L4 / internals《BlueprintCallable 反射回退》— `bindings-uht-extensions/reflective-fallback`
- L3 / reference《NativeRuntimeLinked 后端》— `bindings-uht-extensions/native-runtime-linked`
- L4 / internals《NativeModuleFunctionAddress 后端》— `bindings-uht-extensions/native-module-function-address`
- L4 / policy《Direct Binding 的 Marshalling 安全边界》— `bindings-uht-extensions/marshalling-safety-boundary`
- L3 / guide《可选扩展插件的绑定注册》— `bindings-uht-extensions/optional-extension-registration`

这组区分手工 Bind、UHT FunctionBinding shard、NativeRuntimeLinked、NativeModuleFunctionAddress 和 BlueprintCallableReflectiveFallback，并明确 out parameter、WorldContext、ref return、static array、容器、RPC 和 ABI layout version 等直接绑定边界。

## 12. ArchitectureMaintenance：插件架构与维护（13 篇）

这组面向维护者，说明模块所有权、依赖、全局状态、打包、扩展注册、Subsystem 和 submodule 交付。

- L0 / explanation《插件架构与维护》— `architecture-maintenance/index`
- L4 / internals《Haze 宏移除》— `architecture-maintenance/haze-macro-removal`
- L1 / reference《模块与插件所有权》— `architecture-maintenance/module-ownership`
- L3 / reference《插件与模块依赖卫生》— `architecture-maintenance/plugin-dependencies`
- L4 / internals《Subsystem 与主 Engine 访问》— `architecture-maintenance/subsystem-engine-access`
- L4 / internals《Cooked 打包运行时》— `architecture-maintenance/cooked-packaging-runtime`
- L4 / internals《引擎扩展注册表》— `architecture-maintenance/engine-extension-registry`
- L4 / internals《引擎自有钩子（Engine-Owned Hooks）》— `architecture-maintenance/engine-owned-hooks`
- L3 / reference《Subsystem 生产接口规范》— `architecture-maintenance/subsystem-production-surface`
- L3 / policy《公共 API 与兼容性纪律》— `architecture-maintenance/public-api-compatibility`
- L4 / internals《全局状态隔离与 Engine Ownership》— `architecture-maintenance/global-state-containment`
- L2 / policy《插件 Submodule 交付工作流》— `architecture-maintenance/submodule-delivery-workflow`
- L3 / internals《状态 Dump 的外部观察架构》— `architecture-maintenance/observer-dump-architecture`

这组涵盖 Runtime/Editor/Test/UHT Tool 所有权、GameplayTags/GAS 可选依赖、EngineSubsystem 与 GameInstanceSubsystem tick owner、global-state containment、extension registry 生命周期、纯观察式 Dump 和“子模块先提交、父仓库后更新 gitlink”的交付边界。

## 13. TopicsIntegrations：Gameplay 与领域集成（12 篇）

这组覆盖 GameplayTags、GAS、Enhanced Input、Networking、UMG、Behavior Tree 和常见 gameplay 工作流。

- L1 / reference《专题与领域集成》— `topics-integrations/index`
- L3 / guide《GameplayTags》— `topics-integrations/gameplay-tags`
- L3 / guide《Gameplay Ability System（GAS）》— `topics-integrations/gas`
- L2 / guide《Enhanced Input》— `topics-integrations/enhanced-input`
- L2 / guide《Networking 与 RPC》— `topics-integrations/networking-rpc`
- L2 / guide《UI 与 UMG》— `topics-integrations/ui-umg`
- L2 / guide《AI 与 BehaviorTree》— `topics-integrations/ai-behavior-tree`
- L2 / guide《Script Subsystem 生命周期》— `topics-integrations/subsystem-lifecycle`
- L1 / tutorial《脚本基类与 Blueprint 子类协作》— `topics-integrations/blueprint-subclass-workflow`
- L1 / guide《Timer 与延迟回调》— `topics-integrations/timers-and-callbacks`
- L1 / tutorial《碰撞与 Overlap 事件》— `topics-integrations/collision-and-overlap-events`
- L2 / pattern《跨类多态与 BlueprintEvent 分派》— `topics-integrations/cross-class-dispatch`

这组区分 optional-plugin 与 engine-domain：GameplayTags/GAS 有独立插件依赖；Enhanced Input、Networking、UMG、Behavior Tree 有引擎域能力但不是独立 Angelscript 集成插件。Networking、UMG、AI、Enhanced Input 均引用真实示例；GAS 则如实声明当前没有脚本示例。

## 14. ReferenceDifferencesVersion：版本、差异与证据边界（11 篇）

这组解决产品版本、底层 fork 血缘、Vanilla/Hazelight 差异、backport 和外部参考材料的使用边界。

- L0 / reference《参考、差异、版本与项目》— `reference-differences-version/index`
- L1 / reference《产品版本与源码血缘》— `reference-differences-version/product-version-and-lineage`
- L2 / reference《Fork 与 Vanilla 的语言差异》— `reference-differences-version/fork-language-differences`
- L3 / policy《选择性 Backport 策略》— `reference-differences-version/selective-backport-policy`
- L2 / policy《Hazelight 证据边界》— `reference-differences-version/hazelight-evidence-boundary`
- L1 / reference《核心与可选插件边界矩阵》— `reference-differences-version/plugin-boundary-matrix`
- L2 / reference《Standalone 与 UE Host 的能力边界》— `reference-differences-version/standalone-vs-ue`
- L2 / reference《Runtime、Editor、Commandlet 与 Headless》— `reference-differences-version/runtime-editor-commandlet`
- L1 / troubleshooting《“C++ 有”与“脚本可用”的差异》— `reference-differences-version/binding-availability`
- L1 / policy《版本、日期与基线记录策略》— `reference-differences-version/version-and-baseline-policy`
- L2 / policy《外部参考仓库使用策略》— `reference-differences-version/external-reference-policy`

这里区分产品版本 Unreal AngelScript 1.0.0、底层 AngelScript 2.33 WIP + 选择性 2.38 backport、Hazelight 对照证据、脚本绑定可用性，以及外部参考仓库与运行时依赖的边界。

## 15. ShowcaseLab：展示、Pattern 与实验毕业（6 篇）

这组把原先 landing 中过度承诺的 42 个空条目收敛成可维护的展示和实验方法。

- L0 / guide《Showcase 与实验室》— `showcase-lab/index`
- L1 / guide《Base 作者基线》— `showcase-lab/base-authoring-primitives`
- L2 / guide《Pattern 可复用组合》— `showcase-lab/pattern-composition`
- L2 / policy《Lab Recorded Fixture》— `showcase-lab/recorded-fixtures`
- L2 / policy《Lab 安全、离线与性能边界》— `showcase-lab/lab-safety-boundaries`
- L2 / checklist《实验毕业清单》— `showcase-lab/graduation-checklist`

它们定义 Base、Pattern、Lab 三层，以及实验升级为正式 Pattern/文档前需要满足的可复现、安全、离线、性能和证据条件。

## 总体覆盖

200 篇文章可以归纳为五类交付：

1. **作者入门与日常开发**：安装、目录、编译循环、诊断、Actor/Component、Blueprint、Subsystem、Timer、资源、网络、打包。
2. **Unreal AngelScript 方言**：`UPROPERTY`、`UFUNCTION`、default、DefaultComponent、delegate/event、mixin、f-string、FName、RPC、Editor-only 和反射签名限制。
3. **领域集成**：GameplayTags、GAS、Enhanced Input、Networking、UMG、Behavior Tree、碰撞、Timer、Blueprint 子类和跨类分派。
4. **编辑器、测试、诊断和发布**：VS Code、LSP、DebugServer V2、断点、源码跳转、测试运行器、CodeCoverage、CrashSnapshot、State Dump、发布矩阵和测试数字口径。
5. **底层实现和维护**：parser/compiler、preprocessor、ClassGenerator、FProperty/UFunction、热重载、VM、字节码、GC、StaticJIT、绑定后端、UHT shard、全局状态、插件架构和 submodule 交付。

因此，本 change 形成的是一套从“第一次安装”一直覆盖到“编译器、VM、ClassGenerator、UHT 和插件维护”的中文候选文档体系，而不是一批只有标题或简短摘要的 Wiki 占位页。

## 交付边界

- 文章总数：200。
- 生命周期：30 rewrite / 170 new。
- 状态：全部为 `draft`。
- 存放位置：父仓库 OpenSpec 附件 `supplements/`。
- 正式 Wiki：尚未迁入，仍需在 `Wiki/` 子模块内按 topic 完成人工审阅、采用和独立提交。
- 测试：本 change 按用户要求优先实现文章，没有新增或运行测试。
