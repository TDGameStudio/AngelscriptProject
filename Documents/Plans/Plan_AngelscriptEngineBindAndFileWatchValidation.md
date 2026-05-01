# Angelscript 启动 Bind 与目录监视验证计划

## 背景与目标

当前 `Plugins/Angelscript` 已经同时具备启动期静态 bind、Editor 目录监视、Runtime 热重载轮询、Full/Clone 多引擎创建模式和一批 HotReload 场景测试，但这几块能力还没有被组织成一组围绕“启动绑定正确性 + 目录实时变化反馈 + 性能记录 + 类生成一致性”的统一验证矩阵。用户当前关注的不是继续扩功能，而是确认以下链路是否被系统化验证：

- `FAngelscriptRuntimeModule::StartupModule()` / `InitializeAngelscript()` / `FAngelscriptEngine::Initialize()` 进入 `BindScriptTypes()` 时，针对不同引擎类型与创建模式，bind 是否按预期执行、过滤和保持状态稳定；
- AS 引擎监视某个目录时，对 `.as` 文件的新增、删除、修改、目录级新增/删除以及 rename 窗口内“旧文件移除 + 新文件加入”的组合行为，反馈队列与后续 reload 链路是否正确；
- 热重载后的 generated class / struct / delegate 是否保持正确，尤其是类名变化、旧类清理、`StaticClass()` 对应全局变量回填、旧对象/旧元数据隐藏与回收是否完整；
- 启动 bind 和目录变化处理是否有可重复采集、可留痕、可比较的性能基线，而不是只看一次人工日志。

本计划的目标是把这些验证需求拆成可执行的阶段性任务，优先复用现有 `Core`、`HotReload`、`AngelscriptRuntime/Tests`、`AngelscriptEditor/Tests` 等落点，最终形成一套“能测、能记、能回归”的插件级验证基线。

## 范围与边界

- 本计划覆盖的“引擎类型”统一拆成两条轴：
  - `EAngelscriptEngineCreationMode::Full / Clone`、`CreateForTesting()` 的默认/回退路径；
  - Editor 启动入口、Commandlet 启动入口、Subsystem 持有主引擎与 Runtime fallback tick 的差异。
- 本计划覆盖的“目录监视”以当前仓内已存在的实现为准：
  - Editor 侧通过 `IDirectoryWatcher` + `OnScriptFileChanges()`；
  - Runtime/非 Editor 开发模式通过 `CheckForFileChanges()` 轮询时间戳；
  - rename 现状按“旧文件 removed + 新文件 added + 0.2 秒删除延迟窗口”建模，而不是先假设 UE 会给显式 rename 事件。
- 本计划优先补 deterministic unit/integration tests，再补 scenario 级真实类切换/生成类校验；不直接把第一批工作膨胀成跨平台 watcher 适配或 packaged/cooked 全矩阵。
- 本计划允许新增少量测试 seam、性能记录 helper 和文档条目，但不把 `Core/AngelscriptEngine.cpp` 重构成全新的可观测架构；只做本计划所需的最小观测面。

## 当前事实状态快照

- 启动 bind 主链路：`Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptRuntimeModule.cpp` 中 `StartupModule()` 会进入 `InitializeAngelscript()`，后者调用 `FAngelscriptEngine::GetOrCreate().Initialize()`；`Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.cpp` 在初始化期调用 `BindScriptTypes()`，最终进入 `FAngelscriptBinds::CallBinds(CollectDisabledBindNames())`。
- bind 注册与执行信息目前由 `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptBinds.h` / `AngelscriptBinds.cpp` 管理，已具备 `GetAllRegisteredBindNames()`、`GetBindInfoList()`、按 `BindOrder` 排序执行和禁用指定 bind name 的能力。
- 引擎创建模式与脚本根发现已有单元测试基础：`Plugins/Angelscript/Source/AngelscriptRuntime/Tests/AngelscriptMultiEngineTests.cpp`、`Plugins/Angelscript/Source/AngelscriptRuntime/Tests/AngelscriptDependencyInjectionTests.cpp`、`Plugins/Angelscript/Source/AngelscriptRuntime/Tests/AngelscriptSubsystemTests.cpp`。
- Bind 配置已有基础测试：`Plugins/Angelscript/Source/AngelscriptTest/Core/AngelscriptBindConfigTests.cpp` 已覆盖全局禁用、engine-level 禁用和 unnamed bind 行为，但尚未形成“启动路径 + 创建模式 + 执行顺序 + 统计观测”的闭环。
- 目录监视与热重载队列主链路：`Plugins/Angelscript/Source/AngelscriptEditor/Core/AngelscriptEditorModule.cpp` 的 `OnScriptFileChanges()` 会把变更推入 `FileChangesDetectedForReload` / `FileDeletionsDetectedForReload`；`Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.cpp` 的 `CheckForHotReload()` / `PerformHotReload()` 负责消费队列；`Tick()` 根据 PIE/Editor 决定 soft/full reload。
- 类生成与 reload 修复主链路：`Plugins/Angelscript/Source/AngelscriptRuntime/ClassGenerator/AngelscriptClassGenerator.cpp`、`Plugins/Angelscript/Source/AngelscriptEditor/HotReload/ClassReloadHelper.cpp` 已处理 full reload 下的新旧类替换、旧类重命名/隐藏、Subsystem reinstance、Blueprint 重新挂接等。
- HotReload 现有测试基础已经存在，并且目录组织与本计划目标高度贴合：
  - `Plugins/Angelscript/Source/AngelscriptTest/HotReload/AngelscriptHotReloadFunctionTests.cpp`
  - `Plugins/Angelscript/Source/AngelscriptTest/HotReload/AngelscriptHotReloadPropertyTests.cpp`
  - `Plugins/Angelscript/Source/AngelscriptTest/HotReload/AngelscriptHotReloadAnalysisTests.cpp`
  - `Plugins/Angelscript/Source/AngelscriptTest/HotReload/AngelscriptHotReloadScenarioTests.cpp`
- 磁盘脚本发现、模块文件名映射与 skip 规则已有基础：`Plugins/Angelscript/Source/AngelscriptTest/FileSystem/AngelscriptFileSystemTests.cpp` 已覆盖 `GetModuleByFilename()`、compile-from-disk、partial failure preserves good modules、脚本发现与 skip rules；这些正是 watcher 测试向“真实磁盘状态变化”延展时最值得复用的落点。
- 共享测试引擎、全局引擎作用域与 world context 隔离已有回归：`Plugins/Angelscript/Source/AngelscriptTest/Shared/AngelscriptTestEngineHelperTests.cpp` 已覆盖 failed annotated compile 不污染后续编译、global engine scope restore、world context restore、production subsystem 不劫持 isolated test engine；这类隔离用例应被正式纳入本计划的支撑矩阵，而不是只作为 helper 自测存在。
- 生产引擎上的真实 bind 可见性已有 parity 基础：`Plugins/Angelscript/Source/AngelscriptTest/Core/AngelscriptEngineParityTests.cpp` 通过真实 `FAngelscriptEngine::Get()` 验证脚本类型和 compile snippet 能力，适合作为启动 bind 回归的“生产引擎烟雾层”。
- 仓内脚本语料的热重载已有初始批次：`Plugins/Angelscript/Source/AngelscriptTest/Angelscript/AngelscriptNativeScriptHotReloadTests.cpp` 已对 `Script/Tests/*.as` 语料做 compile + soft reload 处理路径验证，后续更全面的用例应优先在这条语料回归上扩展，而不是重新造一套脱离真实脚本资产的 corpus。
- 性能与记录能力方面，仓内已有三类可复用基础：
  - `FPlatformTime::Seconds()` 风格的低成本时长记录（`AngelscriptRuntime/Testing/UnitTest.cpp`）；
  - `-ABSLOG`、`-ReportExportPath` 的自动化报告导出路径（`Documents/Guides/Test.md`、现有计划文档）；
  - 外部参考建议优先评估 `AddTestTelemetryData`、`FCsvProfiler` / `CsvProfile Start/Stop`、`UAutomationPerformanceHelper`，但应先落最小可用版本，不要第一步就引入重量级 FunctionalTest 依赖。
- 结果产物与离线报告生成已有邻近模式：`Plugins/Angelscript/Source/AngelscriptRuntime/Tests/AngelscriptCodeCoverageTests.cpp` 已验证向 `AutomationTransientDir()` 写出 HTML 报告并回收；`Plugins/Angelscript/Source/AngelscriptRuntime/Tests/AngelscriptPrecompiledDataTests.cpp` 已覆盖 precompiled/static-jit 邻域的 round-trip 与 diff regressions。这说明本计划完全可以补“性能/测试产物真的落盘且结构正确”的回归，而不必停留在只看控制台日志。

## 分阶段执行计划

### Phase 0：冻结测试矩阵、结果口径与最小观测面

> 目标：先把“要测什么、怎么算通过、记录落哪儿”固定住，避免后面写了测试却仍然对引擎类型、rename 语义和性能记录格式各说各话。

- [ ] **P0.1** 冻结启动 bind 与目录监视验证矩阵
  - 先把本计划里的验证对象拆成明确的矩阵，而不是笼统写“测启动 bind / 测目录监视”。至少要区分：`Full / Clone / CreateForTesting`、`StartupModule` 路径 vs `Subsystem` 主引擎路径、`.as` 文件 add / modify / remove / 文件夹 add / remove / rename-window 组合、soft reload vs full reload、generated class / struct / delegate / diagnostics 四类观测输出。
  - 这一步要把当前仓内已有测试映射到矩阵上，明确哪些能力已有基础覆盖、哪些仍是空白。例如 `MultiEngine` 已覆盖创建模式、`BindConfig` 已覆盖禁用项、`HotReload` 已覆盖 body/property 变化，但“文件系统回调 → 队列 → 反馈 → 性能留痕”的整条链路还没有成文。
  - 产出中要显式写清 rename 现状按 remove+add 建模，暂不把“显式 rename 事件”当成既有能力基线；否则后续测试会基于错误假设设计。
- [ ] **P0.1** 📦 Git 提交：`[Test/Plan] Docs: freeze startup bind and watcher validation matrix`

- [ ] **P0.2** 固化性能记录格式与原始产物落点
  - 明确性能测试的三层输出：自动化测试通过/失败结果走 `-ReportExportPath`；每次执行的详细原始日志走 `-ABSLOG`；面向人类复核的基线摘要写入仓内文档，不把“看 Saved/Logs 里某一行”当成长期记录方案。
  - 建议统一使用 `<Project>/Saved/Automation/AngelscriptPerformance/<RunId>/` 保存 JSON/HTML/CSV/日志等原始产物，仓内只登记命令、指标定义、最近一轮基线摘要与注意事项，避免把易波动的大文件直接纳入版本库。
  - 这一项还要决定首批指标口径至少包含：启动总时长、`BindScriptTypes()` 时长、`CallBinds()` 时长、一次 modify/rename reload 的处理时长、热重载后类可见性/诊断状态。若当前 UE 版本的 telemetry API 可直接用于 `FAutomationTestBase`，优先接进去；否则先用统一格式的日志行 + 报告导出兜底。
- [ ] **P0.2** 📦 Git 提交：`[Test/Perf] Docs: define performance artifact layout and metric schema`

- [ ] **P0.3** 扩大基线矩阵，把邻近但高价值的回归面正式纳入范围
  - 把当前计划从“启动 bind + watcher + generated class + 性能”进一步扩成一张更完整的测试矩阵，至少补入五类现成但尚未显式纳管的邻近维度：磁盘脚本发现/skip 规则、module filename lookup、共享测试引擎与 world context 隔离、生产引擎 parity compile smoke、真实脚本语料热重载回归。
  - 这一步要明确这些维度不是另起炉灶的新功能，而是对现有主目标的支撑：如果 filename lookup、context isolation 或 production parity 没被锁住，后续 rename / bind / watcher 结果就容易出现“功能本身没坏，但验证环境或映射关系漂了”的假阳性。
  - 还要在矩阵里补上“报告产物正确写出”这一条验证面，避免性能采样和结果记录只有命令、没有产物结构回归。
- [ ] **P0.3** 📦 Git 提交：`[Test/Plan] Docs: expand validation matrix with filesystem isolation and parity axes`

### Phase 1：补最小测试 seam，先把不可观测点变成可测点

> 目标：只新增本计划真正需要的最小访问面，让后续测试能不靠脆弱反射或复制业务代码去验证启动 bind 和 watcher 队列语义。

- [ ] **P1.1** 为启动 bind 生命周期补可复用的观测 helper
  - 优先在现有测试基础最贴近的位置扩展，而不是新造一套 helper 体系。`Plugins/Angelscript/Source/AngelscriptRuntime/Tests/AngelscriptMultiEngineTests.cpp` 已经能访问创建模式与共享状态，`Plugins/Angelscript/Source/AngelscriptTest/Core/AngelscriptBindConfigTests.cpp` 已经能访问 `CollectDisabledBindNames()` 和 bind 信息查询；需要补的是“某次启动实际执行了哪些 bind、顺序是否稳定、Clone 是否重复执行”的最小观测能力。
  - 实现上优先考虑新增一个专用 test access/helper 文件，而不是把更多测试友元继续塞进生产头文件。若必须加友元，也要把范围压在 startup bind 相关最小字段，避免把 `FAngelscriptEngine` 整体变成随处可探测的开放对象。
  - 这一步还要确定测试命名与目录落点：创建模式与启动链路优先放 `AngelscriptRuntime/Tests/` 与 `AngelscriptTest/Core/`，不要把它们误放到 `Native/` 或 `HotReload/`。
- [ ] **P1.1** 📦 Git 提交：`[Runtime/Test] Chore: add startup bind observation seam`

- [ ] **P1.2** 为 Editor 目录回调与热重载队列补 deterministic seam
  - `OnScriptFileChanges()` 当前在 `Plugins/Angelscript/Source/AngelscriptEditor/Core/AngelscriptEditorModule.cpp` 中是静态函数，已经包含路径归一化、root 匹配、文件夹 add/remove 特殊分支。后续测试不应复制整段逻辑去断言结果，而是要提供一个最小测试入口，让 synthetic `FFileChangeData` 能进入真实处理路径。
  - 测试 seam 优先落在 `Plugins/Angelscript/Source/AngelscriptEditor/Tests/` 或 editor 模块内部 helper，专门验证“回调输入 → 队列输出”；`Plugins/Angelscript/Source/AngelscriptTest/HotReload/` 则继续负责引擎消费队列、编译与 generated class 行为，避免一个文件既测 editor callback 又测 scenario reload，导致失败时定位困难。
  - 这一步要把 folder add / folder remove / non-`.as` 文件忽略 / rename-window 的输入构造方式固定下来，并明确哪些场景只需要 synthetic callback，哪些必须落到临时目录真实文件操作。
- [ ] **P1.2** 📦 Git 提交：`[Editor/Test] Chore: add directory watcher callback seam`

### Phase 2：补齐启动 bind 正确性矩阵

> 目标：把“引擎类型启动时的 bind”从当前零散的 MultiEngine / BindConfig 覆盖，升级成围绕创建模式、模块入口和 bind 过滤语义的完整验证集。

- [ ] **P2.1** 扩展 `MultiEngine` 测试，锁住 Full / Clone / CreateForTesting 的 bind 语义
  - 基于 `Plugins/Angelscript/Source/AngelscriptRuntime/Tests/AngelscriptMultiEngineTests.cpp`，新增针对 startup bind 的测试：Full 创建应执行 bind 初始化；Clone 创建应复用共享状态而不重复跑完整 bind；`CreateForTesting()` 在有无现成 source engine 时，bind 行为要和选择出来的 mode 保持一致；二次 Full 创建被拒绝时，既有 type metadata 和 bind 状态不能被破坏。
  - 这组测试不只看 `GetCreationMode()`，还要看 `GetScriptEngine()`、type metadata 数量、bind 计数/顺序观测值、共享状态存活、`ActiveParticipants` / `ActiveCloneCount` 变化，以及“先 Full 再多个 Clone”时 bind 是否只执行一次，以免只验证模式标签不验证真实副作用。
  - 如果当前初始化支持 threaded path，还要补 `bForceThreadedInitialize` 相关回归，验证 threaded init 下 bind 顺序、去重和共享状态不会出现竞态或双重执行。
  - 若在实现过程中发现“Clone 是否允许某些 late bind 再执行一次”存在真实设计歧义，要先把当前代码事实写进断言说明，禁止测试先发明一套未落地的语义。
- [ ] **P2.1** 📦 Git 提交：`[Runtime/Test] Test: lock startup bind semantics across engine creation modes`

- [ ] **P2.2** 扩展 `Core` 层 bind 配置覆盖，锁住启动期过滤与顺序信息
  - 基于 `Plugins/Angelscript/Source/AngelscriptTest/Core/AngelscriptBindConfigTests.cpp`，把验证范围从“禁用某个 bind name 是否生效”扩展到“启动阶段可观测的 bind 信息是否和配置一致”。至少要覆盖：`GetBindInfoList()` 顺序与 `BindOrder` 一致、全局设置与 engine config 合并后在启动阶段真实命中、unnamed bind 在启动路径中仍保持向后兼容。
  - 如果当前 `BindConfig` 测试只能在 `CallBinds()` 级别直接调用 helper，就补出最小启动期包装，而不是继续让每个测试都自己手动拼 disabled set；这样后续性能测试也能复用同一套启动期观测入口。
  - 这一步完成后，`Angelscript.TestModule.Engine.BindConfig` 应能成为“启动 bind 主回归”的最小锚点之一，而不是只验证配置数据结构。
- [ ] **P2.2** 📦 Git 提交：`[Test/Core] Test: expand startup bind config and ordering coverage`

- [ ] **P2.3** 为模块入口与主引擎附着补最小 smoke matrix
  - 在 `Plugins/Angelscript/Source/AngelscriptRuntime/Tests/AngelscriptSubsystemTests.cpp`、`Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptRuntimeModule.cpp` 附近现有模式上补 smoke 用例，确认 `StartupModule()`、Subsystem 主引擎附着、fallback tick 三条入口至少都能把“已有主引擎 / 无主引擎 / clone 测试引擎”这几类场景走通。
  - 目标不是在这一步测完整文件系统与 reload，而是锁住“启动时谁拥有主引擎、谁负责 tick、何时允许检查热重载”的最小事实，为后续性能与 watcher 测试提供稳定起点。
  - 若某条入口只适合 runtime CppTests，不要勉强挪进 `AngelscriptTest` 模块；优先遵循当前测试分层。
- [ ] **P2.3** 📦 Git 提交：`[Runtime/Test] Test: add startup entrypoint smoke matrix`

- [ ] **P2.4** 引入生产引擎 parity 与 bind 面烟雾回归
  - 扩展 `Plugins/Angelscript/Source/AngelscriptTest/Core/AngelscriptEngineParityTests.cpp`，把它从“若干类型 compile smoke”提升成启动 bind 回归的生产引擎烟雾层。至少要覆盖：真实生产引擎已经初始化时，代表性 bind family 在脚本类型系统中可见；关键 compile snippet 可通过；被标记为 deprecation/metadata 的 bind 在生产引擎路径上仍能正确暴露。
  - 这一步不追求把所有 bind 都做一遍 parity，而是挑选能代表不同 family 的高频类型和边界类型，把“生产引擎真的完成了我们以为完成的启动 bind”锁成最小真值层。若计划后续新增或迁移 bind family，也应优先把 smoke 落到这里。
  - 如果某类 parity 用例本质更像 `Bindings/` 测试，应在本项里写清楚分界：`EngineParity` 只负责生产引擎是否暴露出可编译/可解析表面，具体调用语义仍由对应主题测试承接。
- [ ] **P2.4** 📦 Git 提交：`[Test/Core] Test: expand production-engine parity smoke for startup binds`

- [ ] **P2.5** 补引擎状态重置、全局作用域恢复与测试隔离回归
  - 基于 `Plugins/Angelscript/Source/AngelscriptTest/Shared/AngelscriptTestEngineHelperTests.cpp` 和 `Plugins/Angelscript/Source/AngelscriptTest/Core/AngelscriptEngineCoreTests.cpp`，把当前只是 helper 自测的隔离能力正式纳入本计划：测试失败编译不污染后续模块、nested global engine scope 能恢复前一个引擎、world context scope 能恢复、production subsystem 不劫持 isolated engine、重复 create/destroy 不残留脏状态。
  - 这组回归还应显式覆盖 bind/type 状态 reset 与幂等语义：最后一个 Full 引擎销毁后再次创建 Full，引擎应能干净重新初始化；中途失败或提前销毁不会让后续 `BindScriptTypes()` 落入半初始化状态。
  - 这组测试的价值在于为 Phase 3~5 的压力、rename、burst change 场景兜底。如果上下文隔离本身不稳定，任何“更多、更全面”的场景测试都会先被共享状态污染拖垮。
  - 若需要补 `DestroyGlobal()` / recreate / attach-detach 的专门用例，应优先放在 runtime/core 层，不要把这类状态机测试塞进 `Bindings/` 或 `HotReload/`。
- [ ] **P2.5** 📦 Git 提交：`[Shared/Test] Test: lock engine scope restore and isolation semantics`

### Phase 3：建立启动 bind 与热重载的性能测试与记录闭环

> 目标：先把性能数据“稳定采出来并记录下来”，再考虑是否引入硬预算门槛；第一批不要把所有测试都变成脆弱的毫秒级红线。

- [ ] **P3.1** 新建启动 bind 性能测试文件并固定测量方法
  - 建议新建 `Plugins/Angelscript/Source/AngelscriptTest/Core/AngelscriptEnginePerformanceTests.cpp`，围绕 `Full / Clone / CreateForTesting` 三种启动路径测量总初始化时长、`BindScriptTypes()` 时长、`FAngelscriptBinds::CallBinds()` 时长。若为了保持层级一致更适合拆到 `AngelscriptRuntime/Tests/`，也要保证最终测试名前缀清晰，例如 `Angelscript.TestModule.CppTests.Engine.Performance.*` 或 `Angelscript.TestModule.Core.Performance.*`，不要混成普通功能测试。
  - 采样方法优先采用仓内现成的 `FPlatformTime::Seconds()` 模式，并加上固定 warmup 次数与 measurement 次数，避免第一次初始化、文件缓存、延迟加载把数据完全污染。当前阶段以“记录基线 + 检查没有数量级回退”为主，不建议直接写死过细预算。
  - 若当前 UE 版本可在自动化测试中安全调用 telemetry API，则同步把关键数字写入 test telemetry；否则至少输出统一格式日志行，并确保 `-ReportExportPath`、`-ABSLOG` 的原始产物可以一一对应到本测试。
- [ ] **P3.1** 📦 Git 提交：`[Test/Perf] Test: add startup bind performance baselines`

- [ ] **P3.2** 为目录变化处理建立热重载性能采样
  - 在 `Plugins/Angelscript/Source/AngelscriptTest/HotReload/` 新增或扩展性能测试，测量至少两类链路：一类是 body-only modify 走 soft reload，另一类是 property/class 变化或 rename 走 full reload/建议 full reload。关注点不是只测编译时间，还要覆盖从队列入列到 `CheckForHotReload()` / `PerformHotReload()` 完成的端到端时长。
  - 对 rename 场景，要显式把“旧文件删除延迟窗口 0.2 秒内，新文件加入后产生的处理耗时”单独记录，避免和普通 modify 混成一个数字，后续无法判断 rename 特有回退。
  - 如果直接接 `FCsvProfiler` / `CsvProfile Start/Stop` 的成本可控，可以在这一阶段作为附加采样层引入；如果会显著放大依赖或让执行入口复杂化，就先保留为可选增强，不阻塞首批性能基线落地。
- [ ] **P3.2** 📦 Git 提交：`[HotReload/Perf] Test: add watcher and reload latency baselines`

- [ ] **P3.3** 固化性能摘要文档与执行命令模板
  - 更新 `Documents/Guides/Test.md`，新增“启动 bind / 热重载性能采样”章节，明确推荐命令模板、`-ReportExportPath` / `-ABSLOG` 组合方式、建议的运行环境（`-NullRHI`、独立日志目录、避免并行干扰）以及如何解析结果。
  - 若需要仓内持久化一份简洁的人工可读基线摘要，优先新增一个紧贴测试主题的文档（例如 `Documents/Guides/TestPerformance.md`），记录最近一次基线、指标定义、采样方法、误差注意事项；不要把大量原始 CSV/JSON 直接提交进仓库。
  - 这一步还要把“记录”与“门槛”拆开写清楚：首批先记录并建立比较面，只有当数据稳定后，才考虑把某些数量级回退升级成 hard assert。
- [ ] **P3.3** 📦 Git 提交：`[Docs/Test] Docs: document Angelscript performance capture workflow`

- [ ] **P3.4** 补突发流量、长时运行与结果产物回归
  - 在性能阶段额外补一组 stress/soak 场景，而不是只记录单次启动或单次 reload：至少覆盖 repeated startup loops、burst file changes、重复 rename churn、delete-add-modify 连续队列、失败后修复再失败的循环，观察队列去重、时延抖动、context pool 峰值和状态清理是否稳定。
  - 这一步还要把“结果产物真的写出来且结构可读”变成测试对象，参考 `Plugins/Angelscript/Source/AngelscriptRuntime/Tests/AngelscriptCodeCoverageTests.cpp` 的模式，对性能摘要/日志/报告目录做最小落盘验证；不要让 Phase 3 最终只剩一组人肉查看的输出。
  - 若某些 soak 场景执行太慢，应把它们拆成单独的回归前缀或长耗时组，在文档中明确“快速回归”和“长时压力回归”边界，而不是让所有人默认每次都跑最重的一波；同时为长时用例补内存增长、对象数增长或 context pool 泄漏的失败判据。
- [ ] **P3.4** 📦 Git 提交：`[Test/Perf] Test: add burst churn and artifact-generation regressions`

### Phase 4：补齐目录监视回调与队列级行为测试

> 目标：先把 watcher 输入到 reload 队列输出的 deterministic 语义锁住，再谈真实 scenario 下的类切换与反馈消息。

- [ ] **P4.1** 在 Editor 模块内新增目录回调到队列的单元测试
  - 若 `Plugins/Angelscript/Source/AngelscriptEditor/Tests/` 尚不存在，本项先创建该目录，并在同一提交内把最小测试 bootstrap 与所需 `Build.cs` 依赖补齐，避免后续测试文件落地时再临时扩范围。
  - 新增 `Plugins/Angelscript/Source/AngelscriptEditor/Tests/AngelscriptDirectoryWatcherTests.cpp`，只验证 `OnScriptFileChanges()` 与相关 helper：`.as` 文件新增/修改应进入 `FileChangesDetectedForReload`，`.as` 文件删除应进入 `FileDeletionsDetectedForReload`，非 `.as` 文件应被忽略，新增目录应递归扫描其中脚本文件，删除目录应把已加载脚本映射成删除项。
  - 这组测试应显式覆盖 root path 匹配、relative path 推导、路径标准化和重复入列去重，不要只测一条“Happy Path added file”。
  - 若当前 editor 模块还没有内部测试入口，需要在本项中一次性补齐最小 `Build.cs` 与测试 bootstrap；但范围只限 watcher callback 测试需要的依赖，不要顺手引入大量与本计划无关的 editor 测试设施。
- [ ] **P4.1** 📦 Git 提交：`[Editor/HotReload] Test: add directory callback queue coverage`

- [ ] **P4.2** 把 rename-window 和 folder 变更语义写成明确测试
  - 在同一批 editor/internal tests 中专门补 rename-window 用例：模拟旧脚本文件先 removed、同一窗口内新脚本文件 added，验证当前实现按 remove+add 组合处理，并确认 0.2 秒删除延迟不会过早把“可能是 rename 的删除”单独消费掉。
  - 同时补 folder add/remove 的边界路径，尤其是 Windows 下目录删除不一定为每个文件发通知的现状，这正是当前实现中对目录移除做额外扫描的原因；测试必须锁住这条兼容分支，防止后续重构误删。
  - 除了基本 rename-window，还要补 rapid successive save / duplicate change storm / add-delete-add 同路径抖动等 IDE 常见写盘模式，确认 callback 层去重与 debounce 假设不会被真实事件风暴击穿。
  - 若实现后发现 rename 场景在 editor callback 层仍不可稳定构造，就把 rename 的 deterministic 部分留在 callback 层，端到端 rename 正确性留给 Phase 5 的 HotReload scenario 测试，不强行把所有语义都堆到一个粒度里。
- [ ] **P4.2** 📦 Git 提交：`[Editor/HotReload] Test: lock rename-window and folder watcher behavior`

- [ ] **P4.3** 把磁盘发现、文件名映射与 skip 规则接入 watcher 主矩阵
  - 扩展 `Plugins/Angelscript/Source/AngelscriptTest/FileSystem/AngelscriptFileSystemTests.cpp`，把它从“独立的文件系统能力”正式并到 watcher/rename 验证主线中。至少要补：rename 后 `GetModuleByFilename()` / `GetModuleByFilenameOrModuleName()` 是否切到新路径、旧路径是否失效；目录 skip 规则和 watcher root 组合时是否会错误吞掉应监视脚本；路径分隔符/绝对相对路径标准化是否导致重复模块或漏发现。
  - 这一步特别适合承接 callback 层不方便表达、但又不值得上完整 scenario world 的“磁盘真实状态 + 映射关系”问题，例如 delete-then-recreate 同名文件、非脚本文件同目录共存、root 目录外路径应被忽略、深层嵌套目录、特殊字符/空格路径、多 root 下相同相对路径冲突等。
  - `FileSystem` 目录已经有临时目录写文件与清理模式，后续新增 watcher 相关磁盘用例优先放这里或与 `HotReload` 明确分工，不要同时在两个目录维护重复的 disk harness。
- [ ] **P4.3** 📦 Git 提交：`[FileSystem/HotReload] Test: expand filename mapping and discovery regressions`

### Phase 5：补齐 `.as` 文件增删改查、反馈路径与 generated class 正确性测试

> 目标：把“目录监视到了变化”推进到“引擎给了什么反馈、类生成是否正确、旧类是否被清理”这一层，形成用户最关心的闭环。

- [ ] **P5.1** 在 `HotReload/` 目录补 `.as` 文件增删改查 回归集
  - 新增 `Plugins/Angelscript/Source/AngelscriptTest/HotReload/AngelscriptHotReloadWatcherTests.cpp` 或按主题扩展现有 `FunctionTests.cpp` / `ScenarioTests.cpp`，围绕真实模块记录与查找能力补四类场景：新增脚本后 module/class 可见；修改脚本后函数/默认值更新；删除脚本后 module record 与 generated class 被移除或隐藏；查询路径（`GetModuleByModuleName`、`FindGeneratedClass`、`FindGeneratedFunction` 等）能准确反映最新状态。
  - “查”不要理解成单独的文件系统 API，而要落到 Angelscript 引擎内部对 module/class/function 的查询接口上，否则用户最关心的“改完文件后引擎看到的是什么”没有被直接验证。
  - 这组测试应优先复用现有 `FAngelscriptHotReloadTestAccess`、`CompileModuleWithResult()`、`CompileAnnotatedModuleFromMemory()` 和 scenario helper，不要再平行造一套 compile/lookup 工具。
- [ ] **P5.1** 📦 Git 提交：`[HotReload] Test: cover add remove modify and lookup flows`

- [ ] **P5.2** 为 generated class / struct / delegate 正确性补 rename 与类切换测试
  - 在 `Plugins/Angelscript/Source/AngelscriptTest/ClassGenerator/AngelscriptScriptClassCreationTests.cpp` 与 `HotReload` 主题下补一组围绕 rename/class switch 的测试，至少覆盖：脚本文件重命名但类名不变时旧模块记录清理、新模块/新文件路径接管是否正确；脚本类名重命名时旧 `UASClass` 是否被标记隐藏并清理脚本指针，新类是否可通过 `FindGeneratedClass` 找到，`StaticClass()` 对应全局变量是否回填到新类。
  - 对 struct/delegate 至少补最小 smoke，确认 `CreateFullReloadStruct()`、`FullReloadRemoveClass()`、`CleanupRemovedClass()` 路径不会只修 class 不修 struct/delegate，避免“类 rename 正常，struct/delegate 残留”的半收口；同时补 Blueprint 依赖刷新、pin type replacement、volume actor factory 注册这类 editor-side reinstance 副作用回归。
  - 若 rename 实际表现为“旧类保留但隐藏 + 新类创建”，测试说明必须写清楚这是当前设计事实，不要把断言写成“旧对象物理不存在”这种超出当前实现的目标。
- [ ] **P5.2** 📦 Git 提交：`[ClassGenerator/HotReload] Test: verify rename and class switch correctness`

- [ ] **P5.3** 补反馈功能测试：诊断、失败保留旧代码、屏幕/日志提示
  - 新增一批失败路径测试，验证当 watcher 触发的 reload 失败时，`Diagnostics`、`PreviouslyFailedReloadFiles`、旧代码保留语义和屏幕/日志提示是否符合现有实现。重点锚点是 `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.cpp` 中的 `GetOnScreenMessages()` 与 hot reload 失败路径，而不是只断言“Compile 失败返回 false”。
  - 这组测试至少覆盖：语法错误或结构错误导致 reload 失败后，旧函数/旧类仍可执行；diagnostic 行列号与文件名可读；`PreviouslyFailedReloadFiles` 会在修复后被移出；`QueuedFullReloadFiles` 会在允许 full reload 时被消费；discard/shutdown 后不会残留旧 diagnostics 或 stale queue state。
  - 如果屏幕提示不适合直接在自动化测试里抓 UI，就至少锁住对应数据源和日志行为，并在文档中注明“on-screen message 已由底层状态断言覆盖”。
- [ ] **P5.3** 📦 Git 提交：`[HotReload] Test: cover diagnostics and stale-code fallback feedback`

- [ ] **P5.4** 扩大真实脚本语料热重载回归
  - 以 `Plugins/Angelscript/Source/AngelscriptTest/Angelscript/AngelscriptNativeScriptHotReloadTests.cpp` 为起点，把当前仅验证“compile wrapper 走 handled path”的脚本语料回归扩成更强断言：热重载前后的关键函数仍能执行、模块记录不丢失、不产生意外 full reload、重复 reload 同一批脚本不会残留脏状态。
  - 脚本语料优先从现有或补建的 `Script/Tests/*.as` 挑代表性主题扩批，例如 enum、inheritance、handles、gameplay tags、system utils、actor lifecycle、math namespace，再按负载和稳定性决定是否继续吸收更多样本。若当前仓内语料不足以覆盖这些主题，本项先补一小批稳定 fixture，再把它们接入热重载回归，避免测试说明依赖不存在的脚本资产。
  - 若某些语料本质是在验证某个语言/绑定专题而非 watcher 本身，应在说明中标出它们扮演的是“真实脚本回归探针”，避免后续误把这批用例当成热重载实现细节测试来重构。
- [ ] **P5.4** 📦 Git 提交：`[HotReload] Test: expand native script corpus reload regression`

- [ ] **P5.5** 补 module 映射、部分失败与恢复链路的跨场景回归
  - 结合 `Plugins/Angelscript/Source/AngelscriptTest/FileSystem/AngelscriptFileSystemTests.cpp` 和现有 `HotReload` 测试，新增跨场景用例验证：某个模块 rename / modify 失败后，不相关好模块仍可查询和执行；旧路径、旧 module name、旧 generated symbol 不会长时间悬挂；修复后重新编译可以恢复到正确映射。
  - 这一步建议显式覆盖“一好一坏”与“多模块批量修改”两类案例，因为真正使用 watcher 时最容易出现的不是单模块孤立失败，而是改动一批脚本时其中一个坏了、其他不该被拖死；还要补跨模块依赖链、循环依赖防御和 import resolution 在 reload 后保持一致的回归。
  - 如果实现时发现某些恢复语义跨越了 watcher、builder、class generator 三层，就优先把断言落在外部可观察结果上：lookup、execute、diagnostics、module count，而不是把内部细节耦合进测试。
- [ ] **P5.5** 📦 Git 提交：`[HotReload/FileSystem] Test: verify mixed-success failure recovery and remapping`

### Phase 6：同步执行手册、回归矩阵与基线记录

> 目标：把新增测试真正纳入可执行、可复查、可对比的插件测试体系，而不是只在源码里留下若干新文件。

- [ ] **P6.1** 更新测试文档与目录登记
  - 更新 `Documents/Guides/Test.md`，补充 startup bind、watcher、rename、性能采样的推荐执行命令，以及何时使用 `-NullRHI`、何时需要 editor/internal tests、何时必须指定独立 `-ABSLOG` / `-ReportExportPath`。
  - 按需更新 `Documents/Guides/TestCatalog.md`，登记新增 `Core / HotReload / Editor/Tests` 测试文件、代表性测试点和推荐前缀，不让后续执行者再次从源码里手工搜“有没有 rename 测试”。
  - 如果本计划新增了专门的性能基线摘要文档或运行记录文档，也要在这里同步加导航说明，避免形成“有文档但没人知道在哪”的新债务。
- [ ] **P6.1** 📦 Git 提交：`[Docs/Test] Docs: register bind watcher and performance validation entrypoints`

- [ ] **P6.2** 执行分层回归并记录首轮基线
  - 完成实现后，至少按以下顺序执行回归：先编译目标，再跑 `Angelscript.TestModule.CppTests.MultiEngine` / `Angelscript.TestModule.CppTests.Engine.DependencyInjection` / `Angelscript.TestModule.CppTests.Subsystem`，再跑 `Angelscript.TestModule.Engine.BindConfig`、`Angelscript.TestModule.HotReload`、必要的 editor/internal watcher tests，最后跑性能子集并收集 `-ABSLOG` / `-ReportExportPath` 产物。
  - 这一轮回归必须把首轮性能基线、命令模板、拆分策略和任何已知不稳定项写成文档记录。若 rename 场景因 UE watcher 平台差异需要拆成 deterministic callback tests + end-to-end scenario tests 两层，也要在记录中明确写清。
  - 不允许只说“测试都过了”；要留下哪几组命令执行过、结果写到哪里、下一次比较应看哪些指标的明确线索。
- [ ] **P6.2** 📦 Git 提交：`[Test/Perf] Test: run regression matrix and record first baseline`

- [ ] **P6.3** 扩大最终回归矩阵，纳入邻近高价值主题
  - 最终回归不应只包含 `MultiEngine / BindConfig / HotReload` 三块，还要把本次新增吸收的高价值邻近主题纳入显式矩阵：`FileSystem.*`、`Shared.EngineHelper.*`、`Parity.*`、`Angelscript.NativeScriptHotReload.*`、必要时的 `StaticJIT.PrecompiledData.*` 与 `AngelscriptCodeCoverage.*` 产物测试。
  - 这一步的核心不是“跑得越多越好”，而是把快速烟雾层、功能正确性层、真实脚本语料层、长时压力层和产物生成层拆成清晰的执行模板，让后续维护者能按成本选择，而不是每次都重新决定要跑哪些测试；必要时再单独列出 threaded init / PIE-active / long-soak 的非默认波次。
  - 更新文档时应为每层至少给一个推荐命令前缀，并标注哪些适合 PR 前快速验证，哪些适合阶段性收口或夜间回归。
- [ ] **P6.3** 📦 Git 提交：`[Docs/Test] Docs: widen final regression matrix and execution tiers`

## 验收标准

1. 已形成一份明确的启动 bind 验证矩阵，至少覆盖 `Full / Clone / CreateForTesting`、模块启动入口、bind 配置过滤与顺序观测，不再只靠零散的 MultiEngine / BindConfig 测试拼凑结论。
2. 已存在一组围绕 `.as` 文件新增、删除、修改、folder add/remove 与 rename-window 的 watcher 测试，其中 editor callback 阶段与 hot reload/scenario 阶段的职责边界清晰，不混在一类大测试里。
3. 热重载后的 generated class / struct / delegate 正确性有明确回归，至少能回答“类重命名后旧类如何收口、新类如何可见、查询接口看到的是什么、失败时旧代码是否保留”。
4. 启动 bind 与目录变化处理都有可复用的性能采样入口，且至少一轮基线结果已通过 `-ABSLOG`、`-ReportExportPath` 和仓内摘要文档完成留痕。
5. 与主目标直接相关的邻近高价值回归也已纳入：至少包括磁盘发现/filename mapping、共享测试引擎隔离、生产引擎 parity smoke、真实脚本语料热重载，以及结果产物落盘验证。
6. `Documents/Guides/Test.md` 与 `Documents/Guides/TestCatalog.md` 已同步说明新增测试主题、执行命令和结果记录方式，后续维护者无需重新全仓搜索才能复现本计划验证流程。

## 风险与注意事项

- **风险 1：把“引擎类型”理解得过窄或过宽**
  - 风险：只测 `Full / Clone` 会漏掉模块入口与 Subsystem 主引擎附着；反过来如果一口气把 packaged/cooked/PIE/editor 全部塞进首批，又会让计划失控。
  - 应对：本计划先固定 `CreationMode + Startup Entrypoint` 两条主轴，其他环境差异只在与当前代码事实直接相关时补 smoke。

- **风险 2：rename 行为在不同平台/Watcher 后端上并不显式**
  - 风险：如果测试先假设 UE 会上报独立 rename 事件，结论会和当前实现严重偏离。
  - 应对：统一按“removed + added + 0.2s deletion delay”建模，并把平台差异记录进执行文档；若未来真要支持显式 rename，再开 sibling plan。

- **风险 3：性能数字噪声过大，导致测试脆弱**
  - 风险：直接把毫秒值写成 hard assert，容易因为机器、缓存、首次初始化和并发干扰频繁误报。
  - 应对：首轮只记录基线、建立 warmup/measurement 规则、输出分层产物；待数据稳定后再考虑预算门槛。

- **风险 4：HotReload/Watcher 测试共享引擎状态，互相污染**
  - 风险：如果测试不严格 `DiscardModule()`、重置 shared engine、隔离临时文件路径，就会出现“单测独立跑过，全量回归失败”的情况。
  - 应对：优先复用 `GetResetSharedTestEngine()`、`ResetSharedInitializedTestEngine()`、`ON_SCOPE_EXIT` 清理模式，并为性能/目录测试使用独立临时路径与独立日志目录。

- **风险 5：Editor 内部测试依赖膨胀**
  - 风险：为测一个 directory callback 把一大批 editor 模块依赖一起引入，会放大构建面并拖慢验证。
  - 应对：把 editor/internal tests 严格限制在 watcher callback 与最小 helper 需要的依赖上，generated class 行为继续优先放在 `AngelscriptTest/HotReload` / `ClassGenerator` 体系内验证。

- **风险 6：新增覆盖过多但缺少层次，导致执行成本失控**
  - 风险：把磁盘发现、parity、真实脚本语料、压力回归和产物验证全部塞成一个大命令，会让“更多测试”迅速退化成“没人愿意跑的测试”。
  - 应对：从计划阶段就把它们拆成快速烟雾、功能正确性、语料回归、长时压力、产物验证五层，在 `Test.md` 中给出分层执行模板。

- **风险 7：真实脚本语料回归与专题功能测试边界混乱**
  - 风险：当 `Script/Tests/*.as` 被当作 watcher/hot reload 的通用大杂烩探针时，后续某个语言专题改动可能会让回归变得难以解释。
  - 应对：在新增语料回归时，为每组脚本写清楚它们承担的是“真实脚本探针”还是“专题语义断言”，并把重语义断言继续留在原专题测试目录。


