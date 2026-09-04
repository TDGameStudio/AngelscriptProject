# AGENTS_ZH.md

> **本文件是 `AGENTS.md` 的中文翻译版本，内容应与英文版保持同步。**

> 当前项目仍处于重构阶段；用户已于 2026-09-04 明确解除临时 Skill 禁令。项目 Skill 已恢复使用，但仍须遵守本文件的 workspace、OpenSpec、UE 真实验证与 Git 边界。

## 项目概览

- 本文件用于指导在 `AngelscriptProject` 中工作的 AI Agent。
- 当前第一目标不是继续扩展一个普通游戏工程，而是把 `Plugins/Angelscript` 整理、验证并沉淀为可独立使用的 Angelscript 插件。当前仓库是插件开发与验证的承载工程；真正的主产物是 `Angelscript` 插件本身。
- 插件已经**不处于原型或底座搭建阶段**，而是进入了"核心运行时、编辑器集成、测试基础设施都已成型，但对外交付入口和若干关键能力闭环仍需收口"的成熟期。
- 当前基线：`AngelscriptRuntime` / `AngelscriptEditor` / `AngelscriptTestJIT` / `AngelscriptTest` 四个 UE 模块已稳定，其中 `AngelscriptTestJIT` 是 Editor-only 固定 StaticJIT 测试载体；另有 `121` 个 `Bind_*.cpp`、`27+` 张 CSV 状态导出表、`1518+` 个自动化测试定义分布在 `430` 个测试 `.cpp` 文件中、`DebugServer V2` 协议、`CodeCoverage`、Provider 化 `StaticJIT`、`BlueprintImpact Commandlet` 均已落地。`GameplayTags` 支持现在拆到可选的 `AngelscriptGameplayTags` 插件里，而 `AngelscriptGAS` 依赖它做 GAS 侧集成。仅余 `2` 个测试保持 Disabled（均为 `#ue57-headless` 已知限制）。
- 当前产品版本为 `Unreal AngelScript 1.0.0`；源码 lineage 为 `AngelScript 2.33.0 WIP + 选择性 2.38 回移`。产品版本独立演进，fork 策略仍是从高版本选择性吸收改进。详见 `Documents/Guides/AngelscriptForkStrategy.md`。
- `Plugins/Angelscript/` 是核心工作区，绝大多数实现、修复、清理和测试都应优先落在这里。`Source/AngelscriptProject/` 仅保留宿主工程必须的最小内容，除非任务明确需要，不要把插件逻辑塞回项目模块。

## 项目目录结构

```
AngelscriptProject/
├── AGENTS.md                                # AI 指引（英文）
├── AGENTS_ZH.md                             # AI 指引（中文）— 本文件
├── CLAUDE.md                                # 重定向 → AGENTS.md
│
├── Plugins/Angelscript/                     # ★ 核心交付物（1619 个文件）
│   ├── README.md                            # 插件对外 README
│   ├── Angelscript.uplugin
│   └── Source/
│       ├── AngelscriptRuntime/              # 运行时模块（209 .cpp）
│       │   ├── Core/                        # 引擎核心、类型系统、编译流程
│       │   ├── Binds/                       # 121 个 Bind_*.cpp（引擎 API 绑定）
│       │   ├── ClassGenerator/              # 动态类生成、热重载、版本链
│       │   ├── Debugging/                   # DebugServer V2（DAP 协议）
│       │   ├── StaticJIT/                   # 静态 JIT 编译
│       │   ├── Preprocessor/                # 脚本预处理器（#include、#if）
│       │   ├── FunctionLibraries/           # 21 个 mixin 辅助函数库
│       │   ├── Subsystem/                   # 脚本子系统基类
│       │   ├── Dump/                        # 27+ 张 CSV 状态导出表
│       │   ├── Extension/CodeCoverage/      # 逐行覆盖率追踪（engine extension）
│       │   ├── Testing/                     # Runtime-owned AngelScript 测试框架
│       │   └── ThirdParty/                  # 2.33 WIP lineage 的内嵌 fork 源码
│       ├── AngelscriptEditor/               # 编辑器模块（49 .cpp）
│       │   ├── HotReload/                   # 文件监控与类重建实例
│       │   ├── CodeGen/                     # 编辑器时代码生成
│       │   ├── BlueprintImpact/             # BP 变更扫描与 Commandlet
│       │   ├── SourceNavigation/            # 跳转到源码支持
│       │   └── ContentBrowser/              # .as 文件在内容浏览器中显示
│       ├── AngelscriptTestJIT/              # Editor-only 固定 StaticJIT 测试 Provider
│       ├── AngelscriptTest/                 # 测试模块（430 .cpp，28+ 个主题）
│       └── AngelscriptUHTTool/              # UHT C# 代码生成工具链
│
├── Plugins/AngelscriptGameplayTags/         # 可选 GameplayTags 扩展插件
│   ├── Source/
│   │   ├── AngelscriptGameplayTags/         # GameplayTag 运行时绑定与 replay
│   │   ├── AngelscriptGameplayTagsEditor/   # GameplayTag 变更监听与 reload
│   │   └── AngelscriptGameplayTagsTest/     # GameplayTags 专项自动化测试
│
├── Source/                                  # 宿主工程（最小化，8 个文件）
├── Script/                                  # AngelScript 示例（37 个 .as）
│   ├── Examples/                            # Core / EnhancedInput / Extended
│   ├── Automation/                          # 脚本自动化入口
│   └── Tests/                               # 脚本级测试
│
├── Extensions/                              # 项目维护的外部开发工具
│   └── AngelscriptVSCode/                   # VS Code Language Server / Debug Adapter
│
├── Reference/
│   └── README.md                            # 参考仓库索引、拉取命令、优先级
│
├── .agents/skills/
│   └── README.md                            # OpenSpec 工作流与技能适配说明
│
├── openspec/                                # ★ 活跃变更生命周期（48 个文件）
│   ├── changes/                             # 进行中与已归档的变更
│   └── specs/                               # 共享规格文档
│
├── Documents/
│   ├── Guides/
│   │   ├── Build.md                         # 构建命令与执行
│   │   ├── Test.md                          # 测试运行器与 Suite 用法
│   │   ├── TestCatalog.md                   # 已编目测试基线（275/275）
│   │   ├── TestConventions.md               # 测试命名与组织约定
│   │   ├── TestPerformance.md               # 性能基准
│   │   ├── TestMacroStatus.md               # 宏迁移状态
│   │   ├── TestFixSummary_20260430.md       # 修复快照 2026-04-30
│   │   ├── TechnicalDebtInventory.md        # 技术债与 live suite 状态
│   │   ├── OpenSpecSystemRefactor.md        # OpenSpec Rust/Web/Skill 重构边界
│   │   ├── AngelscriptForkStrategy.md       # Fork 策略（选择性吸收）
│   │   ├── ASSDK_Fork_Differences.md        # ASSDK fork 差异分析
│   │   ├── GlobalStateContainmentMatrix.md  # 全局状态收容分析
│   │   ├── BindGapAuditMatrix.md            # 绑定差距审计
│   │   ├── BlueprintTypeBindingsOptimization.md # BP 类型绑定优化
│   │   ├── VSCodeAngelscript.md              # 项目内 VS Code 扩展工作流
│   │   └── UE_Search_Guide.md               # UE 知识查询
│   ├── Rules/
│   │   ├── GitCommitRule.md                 # 提交规范（英文）
│   │   └── ASInlineFormattingRule.md        # C++ 测试中内联 AS 格式规则
│   ├── Plans/                               # ⚠ 仅历史参考 — 新工作用 openspec/
│   │   ├── Plan_StatusPriorityRoadmap.md    # 历史状态快照
│   │   ├── Plan_OpportunityIndex.md         # 历史机会索引
│   │   ├── Archives/                        # 已归档 Plan
│   │   └── ...                              # 84 份历史 Plan_*.md
│   ├── Knowledges/ZH/
│   │   ├── Index.md                         # 知识库索引（32 篇）
│   │   └── ...                              # AS 内核、语法、类型系统等
│   ├── Reports/                             # 生成的审查报告（505 份）
│   ├── Hazelight/                           # Hazelight 参考笔记（3 份）
│   └── Tools/
│       └── Tool.md                          # 内部工具说明
│
├── Tools/                                   # 旧 wrapper、诊断脚本与 OpenSpec 源码
│   ├── RunBuild.ps1                         # 待删除旧 wrapper；不是活动入口
│   ├── RunTests.ps1                         # 待删除旧 wrapper；不是活动入口
│   ├── RunTestSuite.ps1                     # 待删除旧 wrapper；不是活动入口
│   ├── openspec/                            # 便携 Rust OpenSpec CLI（git 子模块）
│   ├── Bootstrap/                           # 首次配置
│   ├── Shared/                              # 共享工具模块
│   ├── Diagnostics/                         # 健康检查与调试
│   └── PullReference/                       # 参考仓库拉取
│
└── Config/                                  # UE 工程配置（4 个 .ini）
```

## 架构概览

本项目是一个 **Unreal Engine 5.8 插件**，将 AngelScript 脚本语言集成为 Blueprint 和 C++ 的一等替代方案。当前产品身份为 `Unreal AngelScript 1.0.0`。该插件最初由 Hazelight Games 创建；底层源码保留 AngelScript 2.33 WIP lineage，并选择性回移 2.38 改进，但这些上游数字不再作为产品版本。

### 模块依赖关系

```
AngelscriptRuntime  (Runtime 模块，无插件内依赖)
       │
       ├──► AngelscriptEditor  (Editor 模块，公开依赖 Runtime)
       │
       ├──► AngelscriptTestJIT (Editor-only 固定 StaticJIT Provider，公开依赖 Runtime)
       │           │
       │           └──► AngelscriptTest (Editor 模块，测试侧依赖 TestJIT)
       └──► AngelscriptTest    (公开依赖 Runtime，bBuildEditor 时私有依赖 Editor)

AngelscriptGameplayTags  (Runtime 模块，公开依赖 Runtime；可选)
       │
       ├──► AngelscriptGameplayTagsEditor  (Editor 模块，GameplayTags 监听 / reload 桥接)
       └──► AngelscriptGameplayTagsTest    (Editor 模块，GameplayTags 专项测试)

AngelscriptGAS  (Runtime 模块，公开依赖 Runtime + AngelscriptGameplayTags)

AngelscriptUHTTool  (C# UBT 插件，独立 — 接入 Unreal Header Tool 管线)
```

四个插件 UE 模块均在 `PostDefault` 阶段加载。`AngelscriptRuntime` 通过 `UAngelscriptEngineSubsystem` 负责 Editor/Commandlet 主启动初始化，`FAngelscriptRuntimeModule::InitializeAngelscript()` 保留为兼容 API 并在 `GEngine` 可用时路由到该 Subsystem。`UAngelscriptGameInstanceSubsystem` 管理 World/GameInstance 上下文，当存在活跃 GameInstance tick owner 时会抑制 EngineSubsystem 的回退 tick。宿主工程模块 `AngelscriptProject` 有意保持最小化；可选项目 `AngelscriptJIT` Runtime/PreDefault 模块只承载生成的 StaticJIT Provider，不把插件逻辑推回宿主业务模块。

### 编辑器子系统 (AngelscriptEditor)

- **热重载** (`HotReload/`)：`DirectoryWatcher` 监控 `.as` 文件；`ClassReloadHelper` 处理编辑器中已修改脚本类的实时重建实例。
- **代码生成** (`CodeGen/`)：编辑器时代码生成（~84 KB），用于 IDE 支持和 API 桩。
- **Blueprint 影响分析** (`BlueprintImpact/`)：扫描器和 Commandlet，分析哪些 Blueprint 受脚本变更影响，实现定向重编译。
- **源码导航** (`SourceNavigation/`)：允许从 UE 编辑器元素直接跳转到对应 `.as` 源文件和行号。
- **内容浏览器** (`ContentBrowser/`)：自定义数据源，使 `.as` 脚本出现在 UE Content Browser 中。

### UHT 工具 (AngelscriptUHTTool)

C# 项目（`.ubtplugin.csproj`），接入 Unreal Build Tool 管线。读取 C++ 头文件，提取 `UFUNCTION`/`UPROPERTY` 元数据，按 `FunctionBindingMethod` 生成 `AS_FunctionBinding_*.cpp` 分片。构建产物包括 `AS_FunctionBindingStatistics.json` 和逐模块 CSV 细分。

### Runtime AngelScript 测试框架 (`AngelscriptRuntime/Testing`)

`AngelscriptRuntime/Testing/` 负责 AngelScript 语言级测试协议：测试发现、注册、执行、latent/network 支持，以及将 AS 测试暴露给宿主运行器的 UE Automation bridge。`UnitTest.*` 和 `IntegrationTest.*` 描述的是 AS 测试函数和执行器，不是 `AngelscriptRuntime` 内的 C++ 单元测试。

### 测试模块 (AngelscriptTest)

430 个测试 `.cpp` 文件，组织在 28+ 个主题目录中（Actor、AngelScriptSDK、Bindings、Blueprint、Component、Debugger、Delegate、GC、HotReload、Inheritance、Interface、Networking、Preprocessor、StaticJIT、Subsystem 等）。这个模块负责 C++ 自动化测试、CQTest、AngelScript SDK 测试和测试 Fixture。测试使用自动化前缀约定：`Angelscript.TestModule.<Theme>.*` 用于集成测试，`Angelscript.CppTests.*` 用于运行时 C++ 单元测试，`Angelscript.Editor.*` 用于编辑器测试。Native AngelScript SDK 已按 Engine、Frontend、Compiler、Runtime、Module、TypeSystem、Language、Embedding、Conformance 九个主题组织；2026-07-31 最新完整前缀验证为 `691/691 PASS`，另有 14 个可发现且带 `#as-v238-backport` 的 Disabled 2.38 预留方法。分层规则参见根目录测试指南。

### 脚本示例 (`Script/`)

Angelscript `.as` 示例脚本，演示核心模式（Actor 生命周期、子系统、输入绑定、GAS Ability）。组织在 `Script/Examples/Core/`、`Script/Examples/EnhancedInput/` 和 `Script/Examples/Extended/` 下。

### 关键数据流

1. **编译**：`.as` 文件 → 预处理器 → AS 编译器 → 字节码 → （可选）StaticJIT → 可执行模块
2. **类注册**：AS 类定义 → 类生成器 → 带 UProperty 和 UFunction 的活跃 UClass/UStruct → Blueprint 和 C++ 可见
3. **绑定**：C++ 类型 → `Bind_*.cpp` 手动绑定 + UHT 生成函数表 + 跨模块 direct-bind feature 表 + 反射回退 → AS 脚本可调用
4. **热重载**：文件监控器检测变更 → 重编译受影响模块 → ClassReloadHelper 在编辑器中重建实例

### StaticJIT Provider 数据流

- StaticJIT 严格按“一个非空 AS 模块对应一个 `<StableModuleKey>.<TargetProfile>.jit.cpp`”生成；同一模块的全局函数和类方法进入同一个翻译单元，不再生成每函数 slice 或固定 bucket。
- 项目 `AngelscriptJIT` 与 Editor-only `AngelscriptTestJIT` 都通过 `IAngelscriptJITArtifactProvider` 发布 ABI Revision 2 的稳定 entry 表；`FAngelscriptJITProviderRegistry` 校验并复制为不可变多 Provider 快照。
- Engine 先以源码编译或 Cache V2 恢复结果建立权威函数状态，再由 `FAngelscriptJITProviderRouter` 按稳定模块/函数键、内容、Profile、环境、ABI 和稳定引用逐函数匹配。exact 才发布完整 VM/Raw/Parms binding，失配只让对应函数回退 VM。
- 普通 `.as` 保存不会自动生成 C++ 或触发 Live Coding。Editor 显式 Generate/Refresh 在源文件集合不变时可 patch；新增/删除 AS 模块需要普通完整构建。
- UE ModuleManager 负责 Provider DLL 加载/卸载；Registry owner 退注册阻止未来选择，已发布 binding 通过代码镜像 lease 保活到最后一个执行者退出。禁止重新引入 `FJITDatabase`、FunctionId/DataGuid 或 whole-cache 配对路径。
- 当前生产生成器未启用 content-specific script-to-script direct-call emission；Native binding 已可用，但跨模块直接调用仍是独立的后续优化。
- TypedASTJIT（`typed-ast`）补充而不是删除 BytecodeJIT/VM，也不是 Runtime JIT。它要求在同一次 generation 源码编译前打开 HIR capture，只消费内存中的 verified HIR。普通调用实参按反向形式参数顺序物化；变异目标只求值一次；循环/switch 保留显式阶段和转移目标。位置帧不是 debugger/coverage/timeout 对等能力。直接递归需要 native frame 预算。`bExceptionThrown` 不是完整公共异常 payload。cleanup plan 必须显式、反向、只覆盖当时存活的槽。当前源级 `try`/`catch` 仍被拒绝。可变全局和 import 槽需要生命周期路由。native-form 显示名本身不能证明跨 DLL 可链接。生产没有 `dual` backend。

### Standalone 编译与离线 UE 分析

- `Plugins/Angelscript/Standalone/` 通过 CMake 直接编译同一份 maintained fork，并把自身私有的标准 C++ frontend 编译进 `AngelscriptStandaloneHost`；它不包含或链接 Unreal Engine，也不要求 UE Runtime 提供共享 `Language/` 层。UE 继续以原有 `FAngelscriptPreprocessor` 与 descriptor graph 为权威实现，两侧只通过完整离线 JSON Bundle 交换最终声明事实。
- `native-runtime` profile 可编译并执行受限的原生 AngelScript；标准库只提供 UTF-8 string、array、dictionary、math、print 与 assert，并设默认时间/内存限制，不开放文件、网络、进程、动态库或任意 FFI。
- `ue-validation` profile 只做编译与分析。它读取一个完整的 `default-engine` 或显式 project JSON Bundle，以不可执行 trap 注册 UE 声明；产物不是 UE-loadable 字节码，任何 UE 运行、UObject/GC/World/ClassGenerator 模拟都被禁止。
- UE 端 `AngelscriptOfflineExport` Commandlet 观察最终完成注册的引擎表面。手写 `Bind_*.cpp`、UHT 生成 Binding、反射回退和 ClassGenerator 不添加 standalone 分支或导出宏。
- 显式 project Bundle 会完整替换发行包中的默认 Bundle；v1 不合并、不搜索缓存，显式 Bundle 无效时也不回退。详细边界见 `Documents/Guides/AngelscriptStandaloneOfflineBundle.md`。
- UE-validation 的 `--script-root` 表示项目 `Script/` 根；其相对逻辑路径按 `/Angelscript/Game/<logical-path>` 生成离线稳定模块身份，以便当前源码精确替换同一项目导出的 script baseline。v1 不把任意目录猜测为插件或 memory mount。

### 绑定路径维护说明

- `NativeRuntimeLinked` 通过 UHT 在 `AngelscriptRuntime` 的动态模块依赖中生成 `AS_FunctionBinding_<Module>_*.gen.cpp`；`NativeModuleFunctionAddress` 则在显式配置的目标模块 OutputDirectory 生成 `AS_FunctionBinding_<Module>_NativeModuleFunctionAddress_*.cpp`，经 Core `IModularFeatures` 发布 POD payload，并且只允许源码版引擎。
- 跨模块 emit 当前只覆盖 safe signatures。out-param、WorldContext 注入、ref return、static array，以及 `TArray` / `TSet` / `TMap` 容器继续走 fallback 或后续 OpenSpec 扩展。
- RPC/Net UFunction 必须继续走 `BlueprintCallableReflectiveFallback`；raw thunk 直调会绕过 Unreal RPC 路由。
- 任何修改 `FAngelscriptNativeModuleFunctionBinding` 或 `FAngelscriptNativeModuleFunctionBindingView` layout 的变更，都必须 bump `Plugins/Angelscript/Source/AngelscriptUHTTool/native-module-function-binding-layout-version.txt`，并同步 Runtime bridge、generator emit 与测试。

## 外部参考仓库

- 完整索引、拉取命令、用途边界与优先级说明见 `Reference/README.md`。
- AngelscriptWiki 的主题与 document 插件迁移参考固定在 `Reference\tiddlywiki-*`：itonnote theme/plugin、TiddlySeq、command palette、preview-glass source 与 CodeMirror 6。它们通过 `Tools\PullReference\PullReference.bat` 的同名 key 按 SSH 和审计 SHA 手工拉取；`Wiki/vendor/` 才是运行时固定子模块，日常构建不会联网更新。
- Kookma 的 TW5 插件与扩展源码参考固定在 `Reference\kookma\`：每个可访问上游均保留独立 SSH Git 克隆，`TW-PluginLibrary` 同时保留完整插件目录的封装快照。它们只用于 WikiText、宏、组件、样式和作者工作流的二次开发研究，不是 `Wiki/` 的运行时依赖或自动构建输入。调整 AngelScript Wiki 的原生表达组件前优先本地核查；实际产品代码必须在 `Wiki/src/` 的 TDGameStudio 命名空间中自行整合，并先核对许可与全局模板影响。
- AngelScript 代码生成器调研参考固定在 `Reference\fuzzilli`、`Reference\grammarinator`、`Reference\csmith`、`Reference\yarpgen` 与 `Reference\creduce`。其中 Fuzzilli 是 ASIR / ProgramBuilder 架构的首要参考；Grammarinator 仅用于 parser fuzz；Csmith 与 YARPGen 用于受控正例和行为 oracle；C-Reduce 用于失败样本缩减。它们只供离线分析与设计复核，不属于运行时依赖或自动拉取项。
- Angelsea 固定在 `Reference\angelsea`，来源为 `https://github.com/asumagic/angelsea.git`，并递归保留其上游锁定的 MIR、AngelScript、fmt、Catch2 与 nanobench 子模块。它只作为 `asIJITCompilerV2`、AngelScript bytecode-to-C、MIR、lazy/async JIT 和解释器回退策略的次级研究参考；当前插件的 StaticJIT、UE 集成和 maintained AngelScript fork 始终拥有更高优先级，Angelsea 不是运行时或构建依赖。
- Daslang（仓库名 `daScript`）固定在 `Reference\daScript`，来源为 `https://github.com/GaijinEntertainment/daScript.git`。它只作为游戏脚本语言的 C++ 零拷贝互操作、tree interpreter、AOT-to-C++、LLVM JIT、hot reload、semantic hashing、宏系统和 compiler-backed MCP 的横向架构参考；不是 AngelScript 语义、ABI 或本项目 StaticJIT 的权威源，也不是构建依赖。
- Typed/native 编译器研究快照固定在 `Reference\Cython`、`Reference\numba`、`Reference\luau` 与 `Reference\llvm-project`，分别来源于 `cython/cython`、`numba/numba`、`luau-lang/luau` 与 `llvm/llvm-project`。Cython 优先用于 typed AST → C/C++ Static AOT emitter；Numba 优先用于 bytecode → untyped/typed IR → LLVM、specialization 与 object cache；Luau 优先用于 bytecode native codegen、type guard、fallback block、VM exit 和 x64/A64 code lifecycle；LLVM 22.1.8 优先用于 IR/IRBuilder、Clang AST/CodeGen 和 ORC JIT。它们只供离线研究，不是插件依赖；完整版本、许可证、拉取/junction 命令和源码入口见 `Reference/README.md` 与 `openspec/changes/feature-as-typed-semantic-aot/research/`。本机源码为 `D:\LLVM\llvm-project-22.1.8.src`，junction 到 `Reference\llvm-project`，并与 `Paths.LLVMRoot` 对齐。
- GenericMessagePlugin 固定在 `Reference\GenericMessagePlugin`，来源为 `https://github.com/wangjieest/GenericMessagePlugin.git`。它用于研究 UE 中跨 C++、Blueprint、AngelScript 与其他脚本后端的 key-based message bus、签名收集、类型校验、AS 声明 codegen、K2 节点、request/response、sticky message 和调用追踪；属于消息/脚本互操作的专项次级参考，不直接并入插件。
- GenericStorages 固定在 `Reference\GenericStorages`，来源为 `https://github.com/UnrealBytes/GenericStorages.git`。它仅作为 UE registry/storage/singleton/subsystem 模板、编辑器 picker、平台持久化、权限/deep-link 与 S3 helper 的低优先级工具类参考；不是 AngelScript 插件架构基准或运行时依赖。
- UECling 固定在 `Reference\UECling`，来源为 `https://github.com/Evianaive/UECling.git`。它只作为在 Unreal 中嵌入 Cling/CppInterOp、运行时 C++ 解释、REPL/notebook、Blueprint 节点与脚本生成类的低优先级横向参考；不是当前插件的运行时或构建依赖。上游未提供仓库级 LICENSE，且直接携带 LLVM/Clang 头文件，因此借鉴或分发任何实现前必须单独完成来源与许可证审查。
- 官方 OpenSpec（Node CLI）固定在 `Reference\openspec`，来源为 `https://github.com/Fission-AI/OpenSpec.git`，跟随 `main`。2026-08-26 快照为 `6926ccb18afa4ff621112813e9968334576ee11a`（`@fission-ai/openspec` 1.10.0）。它是便携 OpenSpec 继续开发时对照最新 CLI 行为、schema、skill 布局和 Vitest 的参考源，不是插件运行时或构建依赖。不要和 `Reference\openspec2`（内部 fork）混淆。
- OpenSpec-rs 固定在 `Reference\OpenSpec-rs`，来源为 `https://github.com/oonid/OpenSpec-rs.git`，跟随 `master`。2026-08-26 快照为 `36efb88d552fe91a8a6e69f2a742abf47d9a1b6c`（v0.3.0，跟踪上游 OpenSpec v1.4.1）。它是便携单二进制 Rust 移植的继续开发起点；拉取命令、SHA 以及上游未提交的 `vendor/OpenSpec` gitlink 见 `Reference/README.md`。

## 本地配置

- 每个 workspace 根目录的 `AgentConfig.ini` 保存本机路径及由 Harness 管理的 workspace 身份，并已被 `.gitignore` 忽略。
- 使用 Harness `workspace.bootstrap` 初始化或修复配置，再通过 `workspace.config.set` 设置非托管键。Harness 从 canonical primary checkout 复制共享本机设置，并始终把 `Paths.ProjectFile` 重新绑定到当前 workspace。
- 构建、测试入口从 `Paths.EngineRoot` 读取引擎路径；若受管 workspace 身份或当前 PowerShell 会话选择与目标根目录不匹配，则拒绝执行。
- 过时的 `References.HazelightAngelscriptEngineRoot` 键无效；bootstrap 必须移除它，配置写入不得恢复它，执行入口遇到残留键时必须拒绝继续。
- `AgentConfig.ini`、Git 注册、workspace/engine 锁与 `Saved/Harness` 证据始终使用真实物理路径。Windows 下 UE 子进程统一使用 Harness 自动分配的临时短盘符执行视图；该盘符不会写回配置，`PlanOnly` 不创建映射或分配记录，真实运行只清理经过精确目标和所有权验证的映射。

## 构建与验证原则

- UE 5.8 的发现、构建、Automation、suite、commandlet、进程、进度与取消统一使用 Harness `ue.*` 路由；根 `Tools` PowerShell wrapper 是待删除的旧入口，不是回退入口。
- 当前 Harness suite catalog 只承载 UE Automation。Standalone Debug/Release、打包、coverage、release 编排、CachePackage、external smoke 与完整 StaticJIT pipeline 继续作为显式 deferred capability，直到独立 Change 提供验证过的路由。
- Standalone CTest 与 UE Automation、NativeCore、catalogued C++ baseline 是相互独立的统计范围；Debug 与 Release 是同一批测试的不同配置，不得把两者计数相加。
- 状态导出入口：`FAngelscriptStateDump::DumpAll()`（`Plugins/Angelscript/Source/AngelscriptRuntime/Dump/AngelscriptStateDump.h`），控制台命令 `as.DumpEngineState`（`Plugins/Angelscript/Source/AngelscriptRuntime/Dump/`）。Dump API 还提供 `CaptureSnapshot`、`DiffSnapshots`、`DumpSnapshot` 和 `DumpDiff`；`DumpAll()` 会写出 `EngineStateSnapshot.csv` 与分类 snapshot 表，diff helper 会写出 `StateDiff.csv` 和 `StateDiffSummary.csv`。
- 保持 dump 架构为纯外部观察者：优先通过已有 public/runtime API 读取，不要为 dump 侵入原有业务类型。
- 若文档与当前插件化目标不一致，应先更新文档，再继续扩展实现。

## 测试数字基线

- 当前测试数字需区分以下独立口径，后续文档与 roadmap 不能混写：
  - `275/275 PASS`：已编目 C++ 基线（`TestCatalog.md`）。
  - `1518+` 个自动化测试定义分布在 `430` 个测试 `.cpp` 文件中：`test-as-native-sdk-coverage` 后的源码扫描规模。
  - `691/691 PASS`：2026-07-31 最新 native AngelScript SDK 活跃前缀（`Angelscript.TestModule.AngelScriptSDK`）；另有 14 个可发现且 Disabled 的 `#as-v238-backport` 脚本语义预留方法。
  - `2396/2396 PASS`：2026-07-28 最终配置 `All` 套件的 35 个前缀汇总；35 份报告均为零失败、零跳过、零超时。
  - `19/19 PASS`：Standalone 独立 CMake/CTest 口径；Debug 与 Release 是同一组测试的不同配置，不相加，也不替换任何 UE Automation 数字。
  - live full-suite 运行结果：以 `TechnicalDebtInventory.md` 中的实际数字为准。
  - 仅余 `2` 个测试保持 Disabled（`#ue57-headless`）：`TestEngineHelperTests.cpp:106` 和 `SourceNavigationTests.cpp:125`。

## 文档维护原则

- 当插件边界、模块职责、构建方式、测试入口发生变化时，相关文档要同步更新。
- 中文说明优先更新到 `Agents_ZH.md` 或对应中文指南，避免只更新英文版。
- 若某个旧工程信息仍然重要，应总结为迁移规则或结构说明，而不是保留为零散背景备注。
- 如果新增了新的外部参考仓库或本机参考路径，应在本文件中补充"用途 + 路径 + 优先级"，避免后续检索成本持续上升。

## Git 与提交

- Git 提交格式与示例统一参考 `Documents/Rules/GitCommitRule.md`。
- 格式：`[<Scope>] <Type>: <description>` — Scope 可选（模块/功能区域），Type 必填（`Fix`、`Feat`、`Refactor`、`Docs`、`Test`、`Chore`），description 为精炼的面向结果摘要。示例：`[Angelscript] Feat: add FTransform mixin bindings for script access`。
- 不要追加工具生成的提交尾部标记（例如 `Made-with: Cursor`），除非用户明确要求。
- 默认发布分支为 `main`；如果本地仓库仍停留在 `master`，首次推送前先创建或切换到 `main`。
- 首次配置 GitHub 远端时，优先使用 `git remote add origin <your-remote-url>`，然后执行 `git push -u origin main` 建立 upstream 跟踪关系。
- 如果 `origin` 已存在但指向了其他仓库，应使用 `git remote set-url origin <your-remote-url>` 更新地址，而不是再添加一个重复远端。
- 除非用户明确要求，否则不要对 `main` 执行 force push。

## Harness、子模块与 Worktree

- 当前项目仍处于全面重构期，但项目 Skill 已由用户明确恢复使用。所有调用继续受本节的 Harness、workspace、子模块、显式 Review 与收口契约约束。
- 默认编辑位置仍是 main checkout。只有用户明确要求时才创建或选择另一个 Git 已注册的 worktree；新 worktree 默认使用用户明确请求的名称作为分支。Codex `/goal` 只是同一工作的外部无人值守续跑机制，不是仓库模式、分支规范或 workspace 选择器。
- `.agents/skills/harness/SKILL.md` 是项目 Skill 入口。Harness 只是轻量静态路由，不是 daemon、数据库、Event Store 或自定义 Agent loop；当前公开 `workspace.*`、`git.*`、`openspec.*`、`task.status`、`harness.*`、`openspec.maintenance.status` 与已验证的 `ue.*` 路由。
- `Plugins/Angelscript`、`Plugins/AngelscriptGameplayTags`、`Plugins/AngelscriptGAS` 与 `Tools/openspec` 都是 **git 子模块**。父 worktree 必须初始化 gitlink 记录的精确 OID；远端不再提供该对象时，只允许从已验证的本机对象库回退。
- 先提交并标记 `Tools/openspec`。每个 release 在父仓库历史中只允许一次最终 accepted package 更新，其中包含 gitlink、manifest/docs 与 bundled `openspec.exe`；候选 EXE 不得进入父仓库提交。
- 使用 Harness `workspace.new` / `workspace.bootstrap` 初始化，并用 `workspace.activate` 将所选 workspace 绑定到当前 PowerShell 进程。普通 Harness 路由直接在这个 PowerShell 7 进程中执行；只有隔离测试、Git hook/native fixture 或 Harness 管理的 UE worker 才有意启动受限的子 `pwsh` 进程。仅在确认忽略后复制 `AgentConfig.ini`；绝不丢弃 dirty 子模块；worktree 创建本身不生成 OpenSpec change 骨架。
- 成功工作应达到 committed、verified、closure-ready；只有用户或外部 agent 明确请求 Review 时，才额外要求对应 Review resolved 或 superseded。`git.commit` 负责带明确 scope 的 Git 收口；`git.integrate`、非 force 的 `git.push` 与 `workspace.remove` 是相互独立且仅在用户明确要求时执行的操作，清理时保留源分支。
- 目标代码位于子模块时，先提交子模块，再提交父仓库 gitlink。完整工作流、回退策略、scope guard 和故障排查参见 **`Documents/Guides/SubmoduleWorktreeWorkflow.md`**。

## OpenSpec 与 TODO

### 2026-08-27 全面重构期说明

- AngelscriptProject 当前处于**全面重构期**。现有 `openspec/specs/` 与活动 change 源自不同时期，存在粒度不一、能力边界重叠、历史目标与当前实现混杂、以及“未来目标看起来像已实现事实”等问题。不得将整个 spec 集合无差别视为权威现状；作出实现判断时必须交叉核对当前代码、测试、最新有效 change 和相关文档。
- 重构 spec 体系时先做可信度分类：当前权威、部分有效、未来目标、重叠/冲突、纯历史记录。优先通过标记、迁移或归档澄清状态，不要未经专项 change 就批量重写、删除或将旧 spec 编译进新 Skill。
- `Tools/openspec` 是项目跟踪的 Rust 便携版子模块。产品收敛为两个主要交付面：无 Node/npm 运行时依赖的 change/spec 生命周期与验证内核，以及复用同一 Rust 解析/校验模型的本地 Web 预览工具。Web V1 默认只读、离线，不建立第二套事实来源。
- 项目 OpenSpec Skill 与 Rust 工具解耦，由项目或用户独立版本化、下发和维护；Rust CLI 不生成、刷新或覆盖 Skill，也不写入 `.agents/`、`.claude/`、`.cursor/` 等 Agent 配置目录。AngelscriptProject 的 Skill 继续承载 AS 插件边界、测试层、验证入口、记录约定和重构期 spec 可信度规则。
- spec 扩展优先选择性吸收社区机制：项目 context/rules、可替换 schema、research/review/test-plan/retrospective 等 artifact、requirements-to-tasks trace 和必要的 hook/check。每项吸收必须记录来源、采用部分、拒绝部分与验证方式；不整包复制社区 schema。
- 稳定的架构边界见 `Documents/Guides/OpenSpecSystemRefactor.md`。

- `Documents/Plans/` **已废弃** — 仅保留作历史参考。所有新的计划、设计、任务跟踪与归档生命周期使用 `openspec/changes/<change>/` 下的 OpenSpec 产物。
- 只有用户或已接受工作明确选择 OpenSpec Change 时才启用 OpenSpec。便携 Rust CLI 只提供确定性记录原语；生命周期策略拆分到 `openspec-explore`、`openspec-continue-change`、`openspec-update-change`、`openspec-apply-change`、`openspec-verify-change`、`openspec-sync-specs` 与 `openspec-archive-change`。
- `tasks.md` 是唯一当前 Task DAG：文件顶部 YAML `task_graph.depends_on` 为稳定 `X.Y` ID 保存依赖边，OpenSpec 派生 `after` 与 `ready`。每个任务继续保留精确 `Files` 与验证；不要维护第二份 DAG、GraphRevision、snapshot tree 或 resume 状态。
- 在已授权目标内自主调查、Replan、实现和验证；如果存在明确登记的 Review，则同时处理 finding 与必要的 re-review。只有 requirement、design、验收、Task 边界、依赖边或完成证据失效时才 Replan。
- Change 附件固定放在 `attachments/`，默认只从 `attachments/INDEX.md` 渐进加载。Review、implementation、talk、replan、knowledge、script 和 data 记录都不能复制任务状态。
- Archive 是明确 closure gate。`completed` 要求任务完成、证据齐全、处理 spec sync，并关闭或 supersede 所有已明确登记的 Review；它不要求自动创建 Review 或写 `not required` 占位。`abandoned` / `superseded` 必须提供原因和每个未完成任务的 disposition。CLI archive 始终是纯确定性 move，不合并 specs。
- Plan-only 仍是一等模式：产出可直接执行的 proposal/spec/design/Task DAG 后停止；记录深度与风险相称。
- TODO 应围绕插件目标拆解。涉及重命名、模块迁移、对外 API 调整时，同步梳理受影响文件和文档。

## 最近完成里程碑

- ✅ 移除 inactive `WITH_ANGELSCRIPT_HAZE` 分支、清理 Haze-only RPC 语法、移除 debugger Haze flag，并恢复 UE 原生 actor instigator 命名 — 已在 `refactor-as-audit-remove-with-angelscript-haze` 实施
- ✅ 引入项目自有 VS Code Angelscript 扩展，并补齐 `DebugDatabaseSettings` 线协议兼容测试 — 已在 `fix-vscode-lsp-protocol-compat` 实施
