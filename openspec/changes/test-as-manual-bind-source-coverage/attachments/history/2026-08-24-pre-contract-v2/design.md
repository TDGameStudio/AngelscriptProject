## Context

本变更最初规划时 `TestSource/` 存在但为空。当前实现已经落盘 614 个计划 `.as` 文件，但全部集中在 `Bindings`（576）和 `TestFramework`（38）。核心插件在 `AngelscriptRuntime/Binds` 中有 204 个物理 `Bind_*.cpp` 文件；按去除 `_Type` 和 `_Functions` 后缀归并后是 127 个逻辑单元。125 个逻辑主文件已有 AS-facing 使用签名表；`Bind_FunctionLibraryMixins.cpp` 通过代码注册 8 条固定补充表面；`Bind_BlueprintCallable.cpp` 是动态反射发布基础设施，不拥有固定 AS 签名。

当前测试规模已经远超这两个主题：核心 `AngelscriptTest` 有 1,020 个 `.cpp` 和 4,378 个真实 `TEST_METHOD`，GameplayTags Test 有 7 个 `.cpp` / 15 个方法，GAS Test 有 26 个 `.cpp` / 252 个方法，合计 4,645 个方法。快速文本计数得到的核心 4,379 包含 `AngelscriptJITTestModuleOwnershipTests.cpp` 用来验证生成文本的字面量 `"TEST_METHOD("`，不是方法定义。三处共包含 3,672 个带任意 raw delimiter 的 raw-string block 候选；`Script/**` 另有 37 个独立 `.as`。raw block 只是候选，不自动等于可复用 AS：Native SDK、宿主 ABI、缓存编码、JIT provider、生成器 planner 和教学文件需要分别记录为 reference-only、host-only、generated-later 或 teaching-only。

现有 `AngelscriptTest` 有大量 C++/inline-AS 证据，但其目的主要是绑定注册、回归隔离、编译或运行时行为验证，不能直接当作独立脚本源码中心。Runtime 同时向 AS 暴露 `UAngelscriptTestSuite`、断言、期望错误、World facade、fluent command builder 和 `ULatentAutomationCommand`，因此测试源码还需要对测试框架自身形成独立、由 C++ 外部 oracle 最终判定的递归验证层。

2026-08-21 初次复审确认 614/614 路径和计划符号完整，但当时 576/576 Bind 文件缺少 runner 可读 observation channel。整改后的 current recheck 显示 2,420 个 `Observe_*` 已全部改为非 void，其中 284 个接收 runner 输入；discarded-local、tautology 和 permissive-null 指标均为 0。当前剩余 5 个 `UnsafeForDefaultExecution` 文件（19 处高影响操作），571 个文件只是 `StructurallyComplete` 而非人工语义 accepted。38 个 TestFramework 文件仍需原设计中的 C++ 外部 oracle。所有原计划 `.as` 任务继续保持未勾选；本轮只更新 OpenSpec，不改写、编译或运行源码。

## Goals / Non-Goals

**Goals:**

- 对每个物理 Bind 文件、逻辑 Bind 单元、AS-facing 表面、代表性现有测试和未来 `.as` 文件建立闭环追踪。
- 把非 void 返回、void 副作用、out/inout 写回、引用别名、对象身份/null、容器内容和诊断纳入任务定义。
- 将普通 Bind 源码与框架自测源码分离。
- 把 Bindings、TestFramework 与其余缺失主题纳入同一个 TestSource 源码中心，并保持每种主题的职责边界。
- 对每个当前测试方法和脚本候选建立机械可检查的 disposition，避免把无 AS 的宿主测试伪造成语料。
- 为每个未来手写主题源码提供精确路径、原始 raw block、声明符号、C++ oracle hint、输入、预期和清理合同。
- 为未来实现者提供精确路径、符号、参考点、输入、观察值、排除项、注释重点和 runner 分类。
- 把 native-only 类型适配和注册基础设施明确排除出伪造的脚本测试。

**Non-Goals:**

- 本轮 review 直接改写任何 `TestSource/**/*.as`。
- 当前验证 AS 编译、运行或 UE Automation 发现。
- 修改手写 Bind、Runtime Testing、AngelscriptTest C++ 测试或插件 API。
- 设计或实现代码生成器、C++ 内联导出、runner、suite 配置或 release 同步。
- 本轮不实现 GameplayTags、GAS、UHT 生成绑定、任意 Blueprint 函数库全集、StaticJIT/AOT 或 Standalone；GameplayTags/GAS 只进入 Optional 主题规划。
- 清理旧 worktree、归档旧 OpenSpec 或迁移 `Script/**`。

## Decisions

### TestSource 是唯一手写源码真源

所有可复用、手写 AngelScript 测试源码最终归入根工作区的 `TestSource/`。插件 `AngelscriptTest/Fixtures`、C++ inline raw string、StaticJIT carrier 或 release 包中的副本只能是后续 runner / export OpenSpec 生成或同步的消费结果，不能形成第二套手写真源。本变更只记录源码计划，不实现复制、生成或消费。

### 一级主题同时容纳专项合同和语义主题

TestSource 一级目录固定为：`Bindings`、`TestFramework`、`Language`、`Definitions`、`Containers`、`Feature`、`World`、`Gameplay`、`Optional`、`HotReload`、`Debugger`。`Generation` 是独立工具包，不是测试主题。

`Bindings` 是 bind-contract 专项主题，因此不强迫 127 个逻辑 Bind 全部改放语义目录；它们可以通过 `RelatedTheme` 与 `Containers.TArray`、`Gameplay.FVector` 等建立关系。语义主题只有在证明行为矩阵、World story、reload 或 profile 时才规划另一份源码，而且必须拥有不同的 oracle，不能复制 Bind 的浅调用。`TestFramework` 是框架协议专项主题，不新增第九个测试问题 id。

### C++ 目录是驱动证据，不是 TestSource 分类

`Syntax` / `Compiler` / `Preprocessor` 的脚本按内容进入 Language、Definitions 或 Feature；`Coverage` 进入相应行为主题；`Functional` 只有 Actor/Component/Subsystem 本身是 oracle 时进入 World；`HotReload` / `Generator` 的脚本形状进入 HotReload、Definitions 或 Feature。Cache、StaticJIT、RuntimeJIT、Core、Dump、FileSystem、Validation、UHTTool 等没有可复用 AS 主体的测试记录为 `HostOnly`。

### Native SDK 只作参考，生成候选明确转交

`AngelScriptSDK` 保留 `native-fork` 所有权，不建立 `TestSource/AngelScriptSDK`。复杂、独特且可跨驱动复用的程序可以成为 Language 手写候选；同质 expression、literal、definition、permutation、combination 和随机程序标记 `GeneratedLater`，交由 `test-as-source-generation-rules`，本变更不重复安排手写文件。

### ReferenceId 使用 raw block 内容身份

每个候选 C++ raw-string block 使用路径、最近的 `TEST_CLASS` / `TEST_METHOD`、方法内 block ordinal、起止行和 SHA-256 建立 ReferenceId。行号用于导航，SHA-256 用于识别内容漂移；同时记录第一条有效源码、声明符号和 C++ assertion/oracle hint。所有当前测试方法即使不含 raw block，也必须有 `NoReusableAngelScript` 或其他明确 disposition。

### 根级 HotReload / World 与 TestFramework 子目录不同

`TestFramework/HotReload` 验证测试发现、会话和结果注册表跨 reload 的行为；根级 `HotReload` 验证普通脚本类型和模块的 before/after、v1/v2、good/broken 变化。`TestFramework/World` 验证测试框架 facade；根级 `World` 验证 Actor、Component、Subsystem、Blueprint 或 Widget 主体。两组可以引用相同宿主 helper，但不能共享模糊任务。

### 以当前注册源码为最高事实来源

证据顺序固定为：

1. 当前 `Bind_*.cpp` 注册和 AS-facing 使用签名表；
2. 当前相关 C++ 测试中的精确 `TEST_CLASS` / `TEST_METHOD`；
3. `openspec/changes/test-coverage/**`；
4. `Documents/Guides/TestCatalog.md`；
5. `Documents/Guides/BindGapAuditMatrix.md`，仅作历史辅助；
6. 旧 script-corpus OpenSpec，仅用于发现候选场景。

这样可以避免用旧计数、C++ 原生方法名或尚未发布的反射函数推断 AS API。

### 以逻辑 Bind 单元组织目标目录

物理文件通过去除 `_Type` 和 `_Functions` 后缀归入同一个 `BindId`。未来路径固定为：

```text
TestSource/Bindings/<LogicalBindName>/Test_<ScenarioCategory>_<Part>.as
```

`_Type.cpp`、`_Functions.cpp` 不建立独立目录。它们分别作为类型适配或 helper/thunk 证据记录在 `native-only-review.md`。

### 用语义类别加有界分片形成文件

每个逻辑单元的表面按以下顺序分类：

1. `ConstructionAndAssignment`
2. `Operators`
3. `IndexAndIteration`
4. `Queries`
5. `MutationAndLifecycle`
6. `ConversionAndFormatting`
7. `NamespaceAndGlobalFunctions`
8. `Behavior`

同一类别按源码顺序每 10 条相关表面形成一个 `.as` 文件。这个上限只控制单文件认知规模，不要求一个函数对应一个文件；同名重载自然留在同一或相邻分片中。每个分片列出确切 `SurfaceId` 和签名，避免“覆盖剩余 API”式模糊任务。

### 普通 Bind 源码保持 runner-neutral

`TestSource/Bindings/**` 不继承 `UAngelscriptTestSuite`，不直接依赖 `FAngelscriptTest`。每个文件规划唯一 namespace 和具名 observation 函数；未来 runner 可以编译、调用并从返回值、out 参数或对象状态建立 oracle。

只有 `TestSource/TestFramework/**` 可以继承 `UAngelscriptTestSuite` 或 `ULatentAutomationCommand`、调用 `FAngelscriptTest`。这避免框架 payload 与被测 Bind 的职责互相污染。

### 可观察结果优先于“成功调用”

每条任务必须按适用性处理：

- 非 void：消费并比较精确结果；
- void：比较调用前后状态、回调、诊断或生命周期；
- bool：正常情况下规划 true/false；
- out/inout：记录调用前后写回；
- 引用返回：用后续修改或身份检查证明别名；
- UObject/句柄：null、非 null、类型和身份；
- 容器：数量、元素、顺序和空结果；
- 操作符：区分返回新值和修改 receiver；
- 负向行为：错误阶段、消息语义、计数和源码位置；
- World/Actor/Component：创建、BeginPlay、Tick、销毁与清理顺序。

不适用的相邻维度写入 `ExplicitExclusions`，不能静默省略。

### Observation contract 必须先于源码整改

原计划只规定了 `Observe_*` 名称，没有规定确切 callable 签名、runner 输入和结果出口，导致实现把比较保存在局部 bool 中。当前设计补充一个逐 callable 合同，键为 `TaskId + PlannedSymbol`，至少记录：

- `CallableSignature`：runner 实际查找并调用的完整 AS 声明；
- `ObservationMode`：`ReturnedValue`、`OutRecord`、`IdentifiedFixtureState` 或 `ExpectedDiagnostic`；
- `RunnerInputs` 与 `SetupOwner`：纯值输入或由 C++ 创建的 World/Object/Component/asset/network fixture；
- `ExpectedResultOrEffect`：精确值、集合、身份、写回、顺序、计数、阶段或诊断；
- `CleanupOwner` 与 `CleanupAction`：所有成功、失败和 early-exit 路径的恢复动作；
- `ExecutionPolicy`：`DefaultSafe`、`FixtureIsolated`、`SubprocessOnly`、`DiagnosticOnly` 或 `CompileOnlyPendingHarness`；
- `ExternalOracle`：未来 C++ runner 检查的结果、状态或诊断。

允许的 runner-neutral 形态包括返回实际值/判定值、通过 out/inout 返回 observation record、接受 runner-owned fixture 并返回结果，或触发由 C++ 捕获的预期诊断。以下形态一律不算观察：只写函数局部变量、只打印日志、`void` 正常返回、`b || !b`、`x == nullptr || x != nullptr`、`x == x`，以及 required fixture 缺失时直接当作成功。

### Fixture 失败与被测行为分离

World、Actor、Component、collision、asset、subsystem、network 和平台环境不能依赖一个未声明的 ambient context。需要确定环境的测试由 runner 创建 fixture 并传入；只有被测 API 本身就是构造/Spawn 时，脚本才直接创建对象，并把身份交回 cleanup owner。

required fixture 创建失败是 setup failure，不是被测行为的 false/null 边界。只有 API 合同本身允许 null 输入/输出时，null 才能作为明确的测试向量。当前 C++ 参考中的 `FAngelscriptTestWorld`、`FActorTestSpawner`、传参式 `WorldCollisionExecuteIntFunction` 和 `VerifyByPath` 是 fixture/oracle 分工的主要参考。

### 高影响宿主行为必须分类隔离

`RequestExit`、`ServerTravel`、`LaunchURL`、clipboard 和其他进程/editor/global 状态操作不得进入默认执行集合。对应源码保留覆盖意图，但任务必须先选择执行策略：

- `DefaultSafe`：确定性且无持久宿主副作用；
- `FixtureIsolated`：runner snapshot/setup，并在 finally/teardown 恢复；
- `SubprocessOnly`：可能退出、travel 或破坏当前宿主，只允许隔离进程执行；
- `DiagnosticOnly`：只在 C++ 已设置预期错误后执行；
- `CompileOnlyPendingHarness`：当前只能保留签名/编译边界，不能计入 functional coverage。

Actor、timer、delegate、console、file、subsystem 和全局状态同样要记录 setup/cleanup owner。deferred spawn 必须 finish 或 abort；创建的 actor 必须由 runner/脚本明确销毁。

### AS 注释是知识内容而不是元数据协议

未来 `.as` 使用英文自然注释说明文件目的、被测 AS 行为、输入选择、输出或副作用、边界、所有权、World/异步/版本关系和错误意义。不要求固定 `@covers`、固定标题或一组机械字段；简单 helper 只有在顺序、所有权或非显然行为需要解释时才注释。`Observe_SurfaceNNN_*`、预期失败、out/inout、alias/identity、World、latent、network 和高影响平台行为必须在场景附近解释，不能只依赖一个重复文件头。

### 测试框架采用外部 oracle

框架任务分为 Discovery、Assertions、Lifecycle、Commands、World、Automation、HotReload 和 SelfHosted。脚本可以用简单算术、字符串或 World payload 重复普通测试内容，因为被测主体是框架协议。预期失败、自举和热重载用例的最终 pass/fail 数、诊断、源码位置、实例身份和阶段顺序必须由未来 C++ runner 检查，不能让框架只用自身断言证明自身正确。

### 代码生成完全拆分

本变更不触及 `Tools/AngelscriptCodeGen`，不设计 ASIR/AST 生成，不导出 C++ raw string/内联代码，不决定 release 同步方式。后续独立 OpenSpec 可以消费本变更的 `planned-test-sources.csv` 和覆盖规则，但不得把生成器实现反向加入当前 tasks。

## Risks / Trade-offs

- **任务数量较大（614 个现有源码 + 2,427 个缺失主题计划）** → 原 Bind 任务继续使用 SurfaceId/每文件最多 10 条表面；新增主题任务以 raw-block hash、精确 C++ method/oracle hint、主题矩阵和确定性生成区保持可审查性。
- **raw string 不一定是 AS** → inventory 同时记录所有候选和 `IsScriptCandidate`；非脚本 raw string 保留为 `DuplicateReference`，不发出源码任务。
- **自动分类可能需要逐步调优** → `ThemeId`、`LeafThemeId` 和 `QuestionId` 分开保存；修改规则后用 `-Check` 展示完整 drift，不手改生成 CSV 或任务区。
- **使用表可能与注册代码漂移** → 每条表面保留源码行，实施前同时检查注册调用；清单不把旧文档置于源码之上。
- **自动选择的代表性测试可能只覆盖相邻行为** → 引用行明确要求实施者检查 inline AS 主体；三项无匹配单元公开标记 `NoCurrentTest`。
- **当前不编译会保留拼写或环境风险** → 每条任务记录 FutureRunner 和依赖；编译/运行留在审查后的实现阶段。
- **框架自测存在循环自证风险** → 所有失败、计数、顺序和热重载结论都要求未来 C++ 外部 oracle。
- **结构完整容易被误认为测试完成** → 区分 materialized、source-semantic accepted、compiled、executed 和 externally verified 五种状态；checkbox 只表示对应任务通过全部适用 gate。
- **统一 `void Observe_*()` 很容易生成但丢失 oracle** → 先完成逐 callable observation contract，再分批改写源码；局部 bool 不计入结果消费。
- **环境缺失会诱发“null 也算通过”** → fixture setup 失败单独上报，绝不并入行为判断。
- **平台/进程操作可能破坏开发宿主** → 默认不执行，必须选择隔离策略；compile-only 不冒充 functional coverage。

## Migration Plan

1. 保留 127 单元、3,015 表面、820 个原 Bind/framework 参考和 614 路径/符号结构闭环。
2. 用全主题 inventory 对 4,645 个当前测试方法和 4,323 个脚本/源码参考建立 disposition，生成 2,427 个缺失主题任务；本步骤只更新 OpenSpec。
3. 完成逐 callable Bind observation contract 和 cross-section pilot，先验证纯值、容器、fixture、out/writeback、危险宿主行为、诊断和 framework oracle 分工。
4. 按现有 576 个 Bind 文件任务分批整改；每批运行 review audit，清除 local-only oracle、恒真式、fixture-null success 和无所有权资源。
5. 38 个 TestFramework payload 保持 provisional，直到独立 runner OpenSpec 负责的 C++ oracle 验证 discovery/result/diagnostic/order/identity/cleanup。
6. 按 Language → Definitions → Containers/Feature → full-name World overlay → Gameplay → Optional → HotReload/Debugger 的顺序分批手写并复审新主题源码；不得一次性机械铺空目录。
7. 源码语义稳定后更新 `TestSource/README.md`，再由独立 runner OpenSpec 处理编译、调用和 Automation 发现。
8. 单独的代码生成/内联导出 OpenSpec 消费稳定 TestSource 和 `GeneratedLater` reference，不把生成器职责反向加入本变更。
9. 旧 script-corpus 记录是否归档由单独清理决定处理。

## Open Questions

无。代码生成、runner 和 release 分发是明确的后续变更，不是本记录的未决项。
