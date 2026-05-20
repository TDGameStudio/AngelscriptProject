# AS 编译可观测 Hook 实施计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development（推荐）或 superpowers:executing-plans 按任务执行本计划。步骤使用 checkbox（`- [ ]`）语法跟踪。

**Goal:** 建立一套正式、默认安静、可复用的 Angelscript 编译 / 预处理 / VM 执行可观测 Hook 体系，让 LearningGuide、调试器、StaticJIT/LLVM JIT 调试和未来诊断工具都能观察 AS 内部状态变化，而不是依赖 Learning 专用 hack。

**Architecture:** Runtime 层只提供通用 observer API 与结构化事件，不出现 `LearningGuide` / `LearningTrace` 等教学命名；LearningGuide 测试和文档层作为普通 consumer 订阅这些事件并输出 key/value。优先复用现有 preprocessor delegate、runtime compile delegate、ClassGenerator reload delegate、line/stack/instruction callback；只有 `CompileModules()` 四阶段与阶段间半步缺少正式观察面时，才在 `FAngelscriptEngine` 内补最小 observer 发射点。所有 observer 默认不注册、不输出，重数据采集和导出仅在开发 / 测试消费端开启。

**Tech Stack:** `FAngelscriptEngine`、`FAngelscriptPreprocessor`、`FAngelscriptRuntimeModule` delegates、`FAngelscriptClassGenerator` delegates、`asIScriptEngine/asIScriptContext/asIJITCompiler`、`asSVMInstructionInfo`、UE `DECLARE_MULTICAST_DELEGATE` / RAII handle、UE Automation、`FAngelscriptLearningTraceSession` / LearningGuide 输出层。

---

## 背景与目标

这轮讨论的核心诉求不是“多打印一些日志”，而是让 LearningGuide 能真正解释 AS 引擎内部如何工作：脚本如何被预处理、如何生成 module、类和函数如何进入编译阶段、bytecode 何时生成、VM 执行时 program pointer / stack pointer / frame pointer / callstack / locals 如何变化。

现有 Learning 测试已经能展示一部分 API 输入输出，但仍有两个问题：

1. 很多输出只是在测试里手工拼装，不是来自稳定的 Runtime 观察面。
2. 早期 `WITH_AS_LEARNING_GUIDE_VM_OBSERVER` 这类命名会把“教学案例”概念泄漏到 Runtime 或 ThirdParty API，既不够正式，也不利于后续把同一机制用于调试器、JIT 或诊断工具。

本计划要把这条线改成正式 hook 体系：

- Runtime API 叫 `CompilationObserver` / `ExecutionObserver` / `JITObserver` 一类通用名称。
- LearningGuide 只是消费端，用这些 hook 输出结构化 key/value 和阶段步骤。
- VM 观察以 AS VM 状态为准，不误称为 CPU 寄存器；可观察 program pointer、stack pointer、stack frame pointer、当前指令、函数、行号、callstack、参数、局部变量、`this`、返回槽和必要的 raw stack words。
- 尽量不改 ThirdParty AS；已有正式 `asIScriptContext::SetInstructionCallback()` 可以继续作为 VM 指令级入口。
- 私有成员访问 hack 只作为最后手段，且必须隔离在测试 / 诊断 helper 内，不能成为主设计。

## 范围与边界

### 纳入范围

- 盘点并固化当前 AS Engine 已有 callback / delegate 能力。
- 新增正式 compile-stage observer 数据模型，覆盖 `CompileModules()` 总线、四个 stage 以及阶段间 parse / type generation / layout / JIT / globals 半步。
- 用现有 `FAngelscriptPreprocessor::OnProcessChunks` / `OnPostProcessCode` 适配预处理观察。
- 让 LearningGuide 的编译 / VM 案例输出稳定 key/value，而不是散乱日志。
- 保持 observer 默认关闭、无订阅时低开销、无无条件日志噪声。
- 补齐自动化测试，证明事件顺序、禁用状态、失败路径和 LearningGuide 输出结构。

### 不纳入范围

- 不把 Runtime API 命名为 `LearningGuide`、`LearningTrace` 或任何教学专用名。
- 不无条件开启逐指令 VM 观察；逐指令回调只能在明确注册 observer 的 context 上运行。
- 不重写 DebugServer 或 CodeCoverage；本计划只把它们能复用的观察面纳入路径。
- 不在第一阶段实现完整 bytecode disassembler；先输出 opcode 名称、bytecode 长度、指针/栈快照和函数/行号摘要。
- 不为了读取私有字段大面积修改 AS 内核；需要私有状态时先评估 public/internal API、现有 friend/test helper，再考虑受控 hack。

## 当前事实状态快照

### 已有 hook 盘点

- `Plugins/Angelscript/Source/AngelscriptRuntime/Preprocessor/AngelscriptPreprocessor.h`
  - `FOnAngelscriptPreprocessHook`
  - `FAngelscriptPreprocessor::OnProcessChunks`
  - `FAngelscriptPreprocessor::OnPostProcessCode`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Preprocessor/AngelscriptPreprocessor.cpp`
  - `OnProcessChunks.Broadcast(*this)` 当前位于 chunk/import/class/macro/delegate 分析后。
  - `OnPostProcessCode.Broadcast(*this)` 当前位于 condense/post-process 后、加入 module 前。
  - `FAngelscriptRuntimeModule::GetClassAnalyze()` 是单 delegate，偏 extension point，可修改 `GeneratedStatics` / `bHasStatics`，不应当被当作纯观察点滥用。
- `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptRuntimeModule.h/.cpp`
  - `GetPreCompile()` / `GetPostCompile()`：粗粒度编译前后。
  - `GetOnInitialCompileFinished()`：首编译完成。
  - `GetPreGenerateClasses()`：类生成前，能看到待生成 module 集合。
  - `GetPostCompileClassCollection()`：编译后 class collection。
- `Plugins/Angelscript/Source/AngelscriptRuntime/ClassGenerator/AngelscriptClassGenerator.h/.cpp`
  - `OnClassReload`、`OnStructReload`、`OnDelegateReload`、`OnEnumCreated`、`OnEnumChanged`、`OnFullReload`、`OnPostReload`、`OnLiteralAssetReload`。
  - 这些适合观察 UE 反射实体 materialize / reload，不适合解释 AS 编译内部半步。
- `Plugins/Angelscript/Source/AngelscriptRuntime/Core/angelscript.h`
  - `asIScriptEngine::SetMessageCallback()`：编译错误 / warning 诊断。
  - `asIScriptEngine::SetContextCallbacks()`：context request/return，当前引擎用于 context pooling。
  - `asIScriptEngine::SetJITCompiler()`：StaticJIT / 未来 LLVM JIT 入口。
  - `asIScriptContext::SetInstructionCallback()` / `ClearInstructionCallback()`：当前已经 formalized 的 VM 指令观察入口。
- `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_context.h/.cpp`
  - `SetLineCallback()`、`SetLoopDetectionCallback()`、`SetStackPopCallback()`、`SetInstructionCallback()`。
  - `asSVMInstructionInfo` 已能携带 phase、opcode、instruction name、program pointer、stack pointer、stack frame pointer。
- `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.cpp`
  - `CreateConfiguredContext()` 已设置 line / stack pop / loop detection callback。
  - `CompileModules()` 是首编译、热重载和恢复路径的编译总线。
  - `CompileModule_Types_Stage1()`、`CompileModule_Functions_Stage2()`、`CompileModule_Code_Stage3()`、`CompileModule_Globals_Stage4()` 是正式四阶段落点。

### 关键缺口

- 预处理已有两个 hook，但没有统一的 structured observer adapter，LearningGuide 需要自己知道 `FAngelscriptPreprocessor` 内部字段怎么读。
- `CompileModules()` 只有 pre/post 粗粒度 delegate，无法稳定观察 stage 1-4、parse、generate types、layout、JIT handoff、global initialization 的顺序和中间状态。
- AS 原生 message/context/JIT callback 是单 callback 风格，不能让 LearningGuide 或诊断工具直接替换，否则会破坏当前 logging、context pool 或 StaticJIT。
- VM 指令 callback 已经存在，但 Runtime 创建的 context 还缺少统一的 observer bridge；Native LearningGuide 可以手动 set callback，Runtime scenario 需要正式接入点。
- 当前 `LearningTrace` 作为测试 helper 已存在，但用户面向的教学概念应统一为 `LearningGuide`；Runtime API 不能跟着使用这个名字。

## 命名与 API 原则

1. **Runtime 通用命名**
   - 使用 `AngelscriptCompilationObserver`、`AngelscriptExecutionObserver`、`AngelscriptJITObserver` 这类正式名称。
   - 不新增 `WITH_AS_LEARNING_GUIDE_*`、`LearningTraceObserver`、`LearningGuideObserver` 这类 Runtime/ThirdParty 宏或类型。
2. **LearningGuide 只在 Test/Docs 层出现**
   - 新增或调整 Learning 输出时，用 `LearningGuide` 表达“教学指南”。
   - 现有 `Shared/AngelscriptLearningTrace.*` 可继续作为测试 formatter/helper，若要整体 rename，应单独做低风险迁移，不和 Runtime hook 混在一起。
3. **Shipping 策略**
   - Observer 类型和 no-op 注册入口可以作为正式 Runtime API 存在，但默认无订阅、无输出。
   - 重量级快照、文件导出、逐指令日志和 LearningGuide 测试 consumer 必须仅在开发 / 测试路径启用。
   - 若后续需要强隔离，可使用 `WITH_ANGELSCRIPT_OBSERVABILITY` 一类通用宏，不使用 Learning 专用宏。
4. **Hook 形态**
   - 优先 multicast / observer registry，不替换已有 single callback。
   - 对 AS 原生 single callback 使用 wrapper/chaining：例如 JIT observer 包装当前 `asIJITCompiler`，而不是让 consumer 直接 `SetJITCompiler()`。
   - 所有事件结构必须可被测试断言，不只服务日志阅读。

## 文件结构与职责

### Runtime 新增或修改

- `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptCompilationObserver.h`
  - 新增编译观察事件的 enum / struct / delegate 声明，例如 `EAngelscriptCompilationObserverPhase`、`FAngelscriptCompilationObserverEvent`。
  - 事件只携带摘要和值语义字段，不暴露可被外部长期持有的危险内部引用。
- `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptCompilationObserver.cpp`
  - 实现 observer registry、RAII subscription handle、no-op fast path、事件辅助构造函数。
- `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.h/.cpp`
  - 在 `CompileModules()`、四个 stage 函数和阶段间关键半步发射 compile observer event。
  - 保持无 observer 时只做一次 cheap branch。
- `Plugins/Angelscript/Source/AngelscriptRuntime/Preprocessor/AngelscriptPreprocessor.h/.cpp`
  - 不优先新增第二套 hook；先把现有 `OnProcessChunks` / `OnPostProcessCode` 适配到 compilation observer。
  - 如字段访问不足，再补最小 const summary API，而不是让 consumer 直接依赖内部数组布局。
- `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptExecutionObserver.h/.cpp`（可选，P4 决定是否需要）
  - 如果 Runtime scenario 需要统一观察 `CreateConfiguredContext()` 产生的 context，则在这里提供 execution observer registry 和 callback bridge。
  - Native SDK LearningGuide 仍可直接使用 `asIScriptContext::SetInstructionCallback()`。
- `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptJITObserver.h/.cpp`（可选，P5 决定是否需要）
  - 为 StaticJIT / 未来 LLVM JIT 提供 `CompileFunction` / `ReleaseJITFunction` 观察包装。

### Test / Guide 修改

- `Plugins/Angelscript/Source/AngelscriptTest/Learning/Runtime/AngelscriptLearningGuideCompilationObserverTests.cpp`
  - 新增 LearningGuide 编译总线案例，展示 preprocess、module assembly、stage 1-4、bytecode/JIT、global initialization 的结构化输出。
- `Plugins/Angelscript/Source/AngelscriptTest/Learning/Native/AngelscriptLearningGuideBytecodeVmTests.cpp`
  - 保留 VM 逐指令案例，改进 key/value 输出和命名一致性，确保使用正式 `SetInstructionCallback()` API。
- `Plugins/Angelscript/Source/AngelscriptTest/Shared/AngelscriptLearningTrace.h/.cpp`
  - 继续作为结构化输出 helper；必要时增加 LearningGuide display name / key-value pretty printer，而不是把 Runtime observer 命名迁进测试 helper。
- `Documents/Guides/LearningTrace.md`
  - 更新为 LearningGuide 阅读指南，解释每个事件阶段能学到的 AS 内部原理。
- `Documents/Guides/TestCatalog.md` / `Documents/Guides/Test.md`
  - 增加新 LearningGuide 编译可观测测试入口和推荐运行命令。

## 分阶段执行计划

### Phase 0：冻结现状与 RED 测试

- [ ] **P0.1** 固化当前 hook 盘点与命名边界
  - 在本 Plan 和相关指南中明确：预处理、粗粒度编译、ClassGenerator、AS message/context/JIT、line/stack/instruction callback 分别能观察什么，不能观察什么。
  - 把 `LearningGuide` 限定在 `AngelscriptTest` / `Documents` 层；Runtime 新 API 只能使用通用 observer 命名。
  - 执行前先用 `rg` 确认没有新增 `WITH_AS_LEARNING_GUIDE_*` 或 Runtime 层 `LearningGuide` 类型，避免把旧方案继续扩散。
- [ ] **P0.1** 📦 Git 提交：`[Angelscript] Docs: freeze observability hook boundaries`

- [ ] **P0.2** 添加编译 observer 的 RED 自动化测试
  - 新建 `Plugins/Angelscript/Source/AngelscriptTest/Learning/Runtime/AngelscriptLearningGuideCompilationObserverTests.cpp`，先写测试期望：注册 observer 后，编译一个最小脚本类应按顺序看到 preprocess、compile begin、stage 1、parse/type generation、stage 2、stage 3、stage 4、pre-generate classes、compile end。
  - 测试要断言事件是 key/value 结构，而不是只断言日志字符串；至少检查 `Phase`、`CompileType`、`ModuleName`、`ClassCount`、`FunctionCount`、`Result`。
  - RED 阶段旧接口不存在时应编译失败或测试失败，用来锁定要补的正式 API 形状。
- [ ] **P0.2** 📦 Git 提交：`[Test/Learning] Test: define compile observer guide expectations`

### Phase 1：正式 compile observer 数据模型

- [ ] **P1.1** 创建 `AngelscriptCompilationObserver` 事件模型
  - 在 Runtime Core 新增 `AngelscriptCompilationObserver.h/.cpp`，定义 `EAngelscriptCompilationObserverPhase` 和 `FAngelscriptCompilationObserverEvent`。
  - 第一版事件字段聚焦稳定摘要：`Phase`、`CompileType`、`ModuleName`、`FileName`、`ScriptSectionCount`、`ClassCount`、`FunctionCount`、`EnumCount`、`DelegateCount`、`BytecodeWordCount`、`bJITEnabled`、`Result`、`Message`。
  - 不把 `asCModule*`、builder、preprocessor mutable arrays 直接暴露给外部；需要内部对象时只传弱摘要或瞬时 pointer label。
- [ ] **P1.1** 📦 Git 提交：`[Angelscript] Feat: add compilation observer event model`

- [ ] **P1.2** 实现 no-op observer registry 与 RAII subscription
  - 提供 `FAngelscriptCompilationObserver::AddObserver()` / `RemoveObserver()` 或等价 RAII handle，内部用 multicast delegate 或线程安全 observer list。
  - 无订阅时 `Broadcast()` 必须是 fast path，不能构造重型快照或格式化字符串。
  - 明确 observer 回调只读，不允许修改 compile pipeline 状态；需要扩展行为仍使用现有 extension point，而不是混用 observer。
- [ ] **P1.2** 📦 Git 提交：`[Angelscript] Feat: add compilation observer registry`

- [ ] **P1.3** 补 no-observer 行为测试
  - 增加一个 runtime unit 或 LearningGuide helper 测试，确认不注册 observer 时编译结果、diagnostics、现有 `GetPreCompile()` / `GetPostCompile()` 行为不变。
  - 测试不依赖日志文本，只验证编译成功、observer 计数为 0、现有 coarse delegate 仍能触发。
- [ ] **P1.3** 📦 Git 提交：`[Angelscript] Test: verify compilation observer no-op behavior`

### Phase 2：预处理 observer 适配

- [ ] **P2.1** 把现有 preprocessor hook 适配为 compile observer 事件
  - 复用 `FAngelscriptPreprocessor::OnProcessChunks` 和 `OnPostProcessCode`，不要新建平行 hook。
  - `ProcessChunks` 事件输出 chunk/module/import/class/function/property/enum/delegate 的数量摘要；`PostProcessCode` 事件输出 processed code 长度、generated code 数量、module list 摘要。
  - 如果当前字段无法 const 读取，优先给 `FAngelscriptPreprocessor` 补只读 summary 方法，而不是让 observer 直接访问可变内部结构。
- [ ] **P2.1** 📦 Git 提交：`[Angelscript] Feat: adapt preprocessor hooks to compilation observer`

- [ ] **P2.2** 添加预处理顺序与摘要测试
  - LearningGuide 测试脚本包含 `import`、一个 class、一个 property、一个 method 和一个 enum/funcdef 中的最小代表项。
  - 断言事件顺序为 `PreprocessProcessChunks -> PreprocessPostProcessCode`，并断言至少一个 module/class/function/property 计数非零。
  - 输出示例必须是 key/value：`phase=Preprocess.ProcessChunks module=... classCount=... generatedCodeCount=...`。
- [ ] **P2.2** 📦 Git 提交：`[Test/Learning] Test: guide preprocessor observer event order`

### Phase 3：编译四阶段与阶段间半步 observer

- [ ] **P3.1** 在 `CompileModules()` 发射总线级 begin/end 事件
  - `CompileBegin` 记录 `CompileType`、输入 module 数、候选文件数、是否 initial/hot reload/restore。
  - `CompileEnd` 记录 `ECompileResult`、成功编译 module 数、diagnostics 摘要、是否触发 class generation 或 full reload 分支。
  - 使用 scope guard 或等价结构保证失败早退路径也能发出 end/failure 事件。
- [ ] **P3.1** 📦 Git 提交：`[Angelscript] Feat: observe CompileModules begin and end`

- [ ] **P3.2** 在 Stage 1 输出 module assembly 与 type 输入状态
  - `CompileModule_Types_Stage1()` 前后记录 module name、imported module 数、script section 数、precompiled data 是否存在、delegate tags 数、`AddScriptSection` 后状态。
  - 事件要能解释“脚本源码何时进入 AS module”，这是用户理解 module generation 的第一步。
- [ ] **P3.2** 📦 Git 提交：`[Angelscript] Feat: observe type-stage module assembly`

- [ ] **P3.3** 观察 parse / generate types / layout / reload analysis 半步
  - 在 `BuildParallelParseScripts()`、`BuildGenerateTypes()`、`CollectUpdatedTypeReferences()`、`DiffForReferenceUpdate()`、`BuildLayoutClasses()`、`BuildAllocateGlobalVariables()`、`BuildLayoutFunctions()` 周围补 summary event。
  - 这些不是四个 stage 函数名本身，但它们解释了“类如何变成可见类型、热重载为何需要 full reload、layout 何时固定”。
  - 并行 parse 的事件必须考虑线程安全：worker 线程只收集摘要，最终在 game/main compile flow 中广播稳定事件。
- [ ] **P3.3** 📦 Git 提交：`[Angelscript] Feat: observe parser typegen and layout half-steps`

- [ ] **P3.4** 观察 Stage 2 函数生成与 Stage 3 bytecode/JIT handoff
  - `CompileModule_Functions_Stage2()` 输出函数生成前后数量和失败状态。
  - `CompileModule_Code_Stage3()` 输出 code compile 开始/结束、函数 bytecode words 摘要、是否调用 `ScriptModule->JITCompile()`、StaticJIT 是否启用。
  - 第一版不要求完整 disassembler，但要能让 LearningGuide 展示“这里开始有 bytecode，随后交给 JIT”。
- [ ] **P3.4** 📦 Git 提交：`[Angelscript] Feat: observe function codegen bytecode and jit handoff`

- [ ] **P3.5** 观察 Stage 4 globals 与 class generation 前后
  - `CompileModule_Globals_Stage4()` 输出 global var 初始化/reset 状态、code coverage executable line mapping 摘要。
  - `GetPreGenerateClasses()` 附近输出待生成 class/struct/enum/delegate 数量；ClassGenerator 现有 reload delegate 继续负责 materialize/reload 事件。
  - 这一阶段要让 LearningGuide 能解释“bytecode 已经可执行”和“UE 反射实体随后生成”的边界。
- [ ] **P3.5** 📦 Git 提交：`[Angelscript] Feat: observe globals and class-generation handoff`

- [ ] **P3.6** 补完整编译事件顺序测试
  - LearningGuide compile observer 测试断言至少覆盖：`CompileBegin -> ModuleStage1Begin/End -> ParseEnd -> GenerateTypesEnd -> ModuleStage2End -> ModuleStage3End -> ModuleStage4End -> PreGenerateClasses -> CompileEnd`。
  - 失败路径另写一个最小语法错误脚本，断言能看到 failure result 和 message summary，但不会留下未配对 begin/end。
- [ ] **P3.6** 📦 Git 提交：`[Test/Learning] Test: verify compile observer stage sequence`

### Phase 4：VM 执行观察与 LearningGuide 输出收口

- [ ] **P4.1** 复核正式 VM instruction callback API 形状
  - 确认 `asIScriptContext::SetInstructionCallback()` / `ClearInstructionCallback()`、`asSVMInstructionInfo`、`asEVMInstructionPhase`、`asVMInstructionCallback` 是当前唯一正式 VM 指令观察入口。
  - 删除或迁移旧的 `SetInstructionObserver`、`asSVMInstructionObserverState`、`asVM_BEFORE_INSTRUCTION` 旧形状引用，避免测试和文档继续指向临时接口。
  - 保持 `Plugins/Angelscript/Source/AngelscriptRuntime/Core/angelscript.h` 与 ThirdParty 实现签名一致。
- [ ] **P4.1** 📦 Git 提交：`[Angelscript] Refactor: normalize VM instruction callback API references`

- [ ] **P4.2** 定义 VM 快照 key/value 结构
  - LearningGuide VM 输出字段至少包括 `phase`、`opcode`、`instructionName`、`function`、`line`、`programOffset`、`stackOffset`、`frameOffset`、`callstackDepth`、`args`、`locals`、`this`、`returnValue`、`rawStackWords`。
  - 文档中明确这些是 AS VM 状态，不是 CPU register dump；如果未来 LLVM JIT 需要 CPU/IR 级信息，归入 JIT observer。
  - 对 raw stack words 做数量上限，避免逐指令输出巨大日志。
- [ ] **P4.2** 📦 Git 提交：`[Test/Learning] Feat: define VM execution snapshot guide fields`

- [ ] **P4.3** 让 LearningGuide Bytecode/VM 案例使用结构化输出
  - 更新 `AngelscriptLearningGuideBytecodeVmTests.cpp`，将当前逐指令记录整理为稳定 key/value 表达。
  - 至少展示一次 CALL 深度变化、一次局部变量从 uninitialized 到具体值的变化、一次 RET 返回顶层的变化。
  - 测试断言仍基于事件数组，不基于格式化文本。
- [ ] **P4.3** 📦 Git 提交：`[Test/Learning] Feat: emit structured VM guide snapshots`

- [ ] **P4.4** 评估是否需要 Runtime context execution observer bridge
  - 如果 LearningGuide 仅观察 Native SDK context，则已有 `SetInstructionCallback()` 足够；如果要观察 `FAngelscriptEngine::CreateConfiguredContext()` 创建的真实 Runtime context，则新增 `AngelscriptExecutionObserver` bridge。
  - bridge 不能替换现有 line/stackpop/loop detection callback；它只在 context 配置时额外安装 instruction callback，且必须支持无订阅 no-op。
  - 这一步完成后要跑 Debugger / CodeCoverage 相关 smoke，确认没有破坏现有 line callback 语义。
- [ ] **P4.4** 📦 Git 提交：`[Angelscript] Feat: add runtime execution observer bridge`

### Phase 5：JIT 与调试工具扩展点

- [ ] **P5.1** 设计 `asIJITCompiler` wrapper/chaining 方案
  - 当前引擎通过 `Engine->SetJITCompiler(StaticJIT)` 接入 StaticJIT；不能让 observer consumer 直接替换这个 single callback。
  - 若需要观察 JIT，新增 wrapper：外层记录 `CompileFunction` / `ReleaseJITFunction` 事件，再委托给真实 StaticJIT 或未来 LLVM JIT。
  - 事件摘要包括 function declaration、bytecode words、JIT backend name、compile success/failure、generated function pointer label。
- [ ] **P5.1** 📦 Git 提交：`[Angelscript] Feat: add JIT observer wrapper design`

- [ ] **P5.2** 接通 StaticJIT 首批 observer 测试
  - 在 StaticJIT 可用配置下，编译一个最小函数并断言看到 `JITCompileFunctionBegin/End`。
  - 在 StaticJIT 不可用配置下，测试应跳过或断言 `bJITEnabled=false`，不能产生假失败。
  - 这一步为后续 LLVM JIT 调试打底，不要求实现 LLVM JIT。
- [ ] **P5.2** 📦 Git 提交：`[Angelscript] Test: verify static jit observer events`

- [ ] **P5.3** 对齐 DebugServer / CodeCoverage 的消费边界
  - 确认 DebugServer、CodeCoverage 是否只需要继续使用 line callback，还是也能消费 compile/execution observer 摘要。
  - 若接入，只做只读消费，不改变 breakpoint、coverage hit 或 callstack 现有行为。
  - 补一个 smoke 测试确认 LearningGuide observer 开启时 Debugger/coverage 原有路径仍能工作。
- [ ] **P5.3** 📦 Git 提交：`[Angelscript] Test: validate observer coexistence with debugger and coverage`

### Phase 6：文档、验证与收口

- [ ] **P6.1** 更新 LearningGuide 阅读文档
  - 更新 `Documents/Guides/LearningTrace.md` 或新增更准确的 LearningGuide 章节，说明编译、预处理、VM 执行每个 phase 的含义。
  - 给出示例 key/value 输出，并解释这些输出能学到的 AS 内部原理：module 何时生成、类型何时可见、函数何时变成 bytecode、VM 栈何时变化。
  - 明确 `LearningTrace` 如果仍作为 helper 名存在，只是测试基础设施，不是 Runtime API 名称。
- [ ] **P6.1** 📦 Git 提交：`[Docs] Docs: document LearningGuide observability phases`

- [ ] **P6.2** 更新测试目录和 Plan 索引
  - 更新 `Documents/Guides/Test.md`、`Documents/Guides/TestCatalog.md` 和 `Documents/Plans/Plan_OpportunityIndex.md`，加入新 LearningGuide 编译可观测测试入口。
  - 推荐运行命令使用标准工具：`Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Learning"`，需要单项时使用更窄前缀。
- [ ] **P6.2** 📦 Git 提交：`[Docs] Docs: index LearningGuide observability tests`

- [ ] **P6.3** 完成构建和测试验证
  - 运行标准构建：`powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label as-observability-hooks -TimeoutMs 600000 -NoXGE`。
  - 运行 LearningGuide 编译/VM 相关测试：`Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Learning" -Label learning-guide-observability -TimeoutMs 600000`。
  - 至少补跑 `Angelscript.TestModule.Shared.LearningTrace`、Debugger/CodeCoverage smoke，验证 observer 不破坏现有执行回调。
- [ ] **P6.3** 📦 Git 提交：`[Angelscript] Test: validate observability hook suite`

## 验收标准

1. Runtime 层不存在新的 `LearningGuide` / `LearningTrace` 命名 API，也不存在 `WITH_AS_LEARNING_GUIDE_*` 这类宏。
2. Observer 默认关闭；不注册 observer 时不输出日志、不导出文件、不改变现有编译结果。
3. 预处理事件能按顺序输出 `ProcessChunks` 与 `PostProcessCode`，并包含 module/class/function/property/import/generated-code 等摘要。
4. 编译事件能稳定展示 `CompileModules()` 总线、stage 1-4、parse/type generation/layout/JIT/global/class-generation handoff 的关键顺序。
5. VM LearningGuide 能输出逐指令 key/value，至少包含 opcode、函数、行号、program/stack/frame 指针偏移、callstack、参数、局部变量和返回变化。
6. AS single callback 不被外部 consumer 直接替换；message/context/JIT 相关扩展通过 wrapper/chaining 或已有引擎入口完成。
7. LearningGuide 输出可读，能解释 AS 内部过程，而不仅仅是“测试通过”。
8. 构建通过，LearningGuide、Shared LearningTrace、相关 Debugger/CodeCoverage smoke 测试通过。
9. Shipping / Development 策略明确：正式 API 可以存在，但重型 consumer、逐指令日志和文件导出不在 Shipping 默认启用。

## 风险与注意事项

### 风险

1. **AS single callback 被误用**
   - `SetMessageCallback()`、`SetContextCallbacks()`、`SetJITCompiler()` 都是单 callback 风格，直接替换会破坏现有 logging、context pooling 或 StaticJIT。
   - 缓解：只允许 Runtime 内部 wrapper/chaining；Plan 和测试明确禁止 consumer 直接替换。

2. **编译阶段并行路径导致事件顺序不稳定**
   - `BuildParallelParseScripts()` 可能涉及并行 parse，直接在 worker 中广播会让测试顺序不稳定。
   - 缓解：worker 只采集 summary，统一在主编译路径按 module / phase 归并后广播。

3. **逐指令 VM 观察开销很高**
   - instruction callback 会在每条 VM 指令触发，默认开启会显著影响执行性能和日志量。
   - 缓解：默认 no-op；LearningGuide 限制最大事件数和 raw stack words；性能敏感路径不注册 observer。

4. **私有成员 hack 侵入扩散**
   - 为了看 VM 栈或内部 builder 状态，容易诱导直接读 AS 私有字段。
   - 缓解：先用正式 `asSVMInstructionInfo`、context public API 和 summary API；若必须 hack，隔离在测试 helper，写明原因和移除条件。

5. **Shipping API 暴露边界不清**
   - 用户既希望正式对外 hook，又担心 LearningGuide 风格接口进入正式发布。
   - 缓解：正式 Runtime API 是通用 observer，默认安静；LearningGuide consumer、重型输出和测试入口不进入 Shipping 默认行为。

### 已知行为变化

1. **LearningGuide 输出名称会从“trace”口径转向“guide”口径**
   - 用户可见测试 display name / 文档描述应使用 `LearningGuide`。
   - 现有 `Shared/AngelscriptLearningTrace.*` 可作为内部 helper 暂留，避免无意义大改名；若后续 rename，需要单独计划。

2. **编译 observer 可能让部分内部阶段名称稳定化**
   - 一旦测试断言 phase 顺序，`CompileModules()` 内部阶段名会变成半公开诊断契约。
   - 执行实现时要选择语义稳定的 phase 名，避免把临时局部变量名暴露成长期 API。

3. **VM “寄存器”表述需要修正为 VM 状态**
   - AS 解释器观察到的是 VM program/stack/frame 指针、栈槽、locals/callstack 等，不是 CPU register。
   - 文档和输出中必须避免误导；LLVM JIT 未来的 CPU/IR 级调试另走 JIT observer。
