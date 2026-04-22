# 全局变量与 Console Variable 对齐计划

## 背景与目标

Hazelight 基线在全局变量与控制台变量（`cvar`）这条线上，既依赖 AngelScript 原生的 global variable / `RegisterGlobalProperty` 能力，也提供了脚本可直接使用的 `FConsoleVariable` / `FConsoleCommand` 表面。当前插件已经具备大部分底座，并且本分支已补上 `FConsoleVariable` 的 `bool` / `FString` 表面与首批 `Bindings` 专项测试，但这部分能力仍缺少一份独立的、可执行的计划文档来收口“哪些已经对齐、哪些仍待补齐、后续测试和文档怎么继续推进”。

本计划的目标是把“全局变量 + `cvar`”从 `Plan_HazelightCapabilityGap.md` 中拆成独立执行面：一方面固定当前插件已经具备的 global variable / `BindGlobalVariable` / `FConsoleVariable` 能力边界，避免继续把它们误记成“整体缺失”；另一方面把剩余未闭环项（尤其是 `FConsoleCommand`、更完整的矩阵测试与文档入口）拆成可以逐项完成和验证的任务。

该主题对应 `Documents/Plans/Plan_HazelightCapabilityGap.md` 中的 `P2.4`，后续 parity 文档只保留摘要与导航，不再在总计划内继续展开执行细节。

## 当前事实状态快照

- 原生 AngelScript global variable 与 `RegisterGlobalProperty` 路径已存在；当前仓库已有 `Native.Compile.GlobalVariables`、`Native.Register.GlobalProperty`、`Native.ASSDK.GlobalVar.*`、`Angelscript.Misc.GlobalVar`、`Angelscript.Misc.Namespace` 等覆盖。
- 插件绑定层的命名空间全局变量已经存在实际使用点，例如 `CollisionProfile::BlockAllDynamic`、`FComponentQueryParams::DefaultComponentQueryParams`、`FGameplayTag::EmptyTag`、`FGameplayTagContainer::EmptyContainer`、`FGameplayTagQuery::EmptyQuery`。
- 当前分支已对齐 `FConsoleVariable` 的 `int` / `float` / `bool` / `FString` 四种构造，以及 `GetBool` / `GetFloat` / `GetInt` / `GetString`、`SetBool` / `SetFloat` / `SetInt` / `SetString`。
- 当前分支已新增 `Bindings.ConsoleVariableCompat`、`Bindings.ConsoleVariableExistingCompat`、`Bindings.GlobalVariableCompat` 三条专项测试，并修复了 testing engine 下 `bIsInitialCompileFinished` 未置位导致的假失败路径。
- 当前分支已新增 `Bindings.ConsoleCommandCompat`、`Bindings.ConsoleCommandReplacementCompat`、`Bindings.ConsoleCommandSignatureCompat` 三条 `FConsoleCommand` 专项测试，并把这条能力域拆成独立计划入口；剩余风险主要收敛到 worktree 自动化启动链路的验证稳定性，以及是否继续补更深的 command execution workflow。
- 2026-04-22 `Plan_FunctionalGapClosure.md` Phase 1.3 确认：`FConsoleCommand` 绑定完整（`Bind_Console.cpp` 第66-138行），4个测试文件9个测试用例全覆盖，Shipping 下不注册是刻意安全策略。**FConsoleCommand 不再是功能缺口，降级为文档/可见性改进项。** 遗留项：Help 字符串注册为空 `TEXT("")`。

## 影响范围

本计划涉及以下操作（按需组合）：

- **运行时表面对齐**：补齐 `Bind_Console.*` 中 `FConsoleVariable` / `FConsoleCommand` 的脚本可见 API。
- **测试引擎语义修正**：确保 testing engine 与 runtime 对“初始编译完成”状态的假设一致，避免测试环境专属假阴性。
- **Bindings 专项测试补齐**：在 `Source/AngelscriptTest/Bindings/` 下新增或扩展 `ConsoleVariable` / `GlobalVariable` 回归。
- **文档与计划同步**：更新 `TestCatalog`、机会索引与 Hazelight 总计划中的挂接关系。

涉及文件（按目录分组）：

Runtime/Binds/（2 个核心文件，必要时加 1 个命令链路文件）：
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_Console.h` — `FConsoleVariable` / `FConsoleCommand` 表面、late-init 生命周期
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_Console.cpp` — 构造、方法注册、`no_discard`、命令绑定表面

Runtime/Core/（1 个核心文件）：
- `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.cpp` — testing engine 的 initial compile 状态与相关测试语义

Bindings Tests/（2-4 个文件）：
- `Plugins/Angelscript/Source/AngelscriptTest/Bindings/AngelscriptConsoleBindingsTests.cpp` — `FConsoleVariable` / 后续 `FConsoleCommand` 专项测试
- `Plugins/Angelscript/Source/AngelscriptTest/Bindings/AngelscriptGlobalBindingsTests.cpp` — 命名空间全局变量与默认值矩阵
- 如需扩展：复用 `AngelscriptContainerBindingsTests.cpp`、`AngelscriptFileAndDelegateBindingsTests.cpp` 的 clean-engine 测试模式

Docs/Plans/（3 个文件）：
- `Documents/Guides/TestCatalog.md` — 目录与测试项说明
- `Documents/Plans/Plan_HazelightCapabilityGap.md` — 总计划保留摘要并引用本独立计划
- `Documents/Plans/Plan_OpportunityIndex.md` — 为本计划建立独立入口

## 分阶段执行计划

### Phase 1：固定独立边界与文档入口

> 目标：把这一能力域从 Hazelight 总计划中拆出来，形成独立的追踪入口和明确的 current-state 边界。

- [x] **P1.1** 在 `Plan_HazelightCapabilityGap.md` 中把全局变量 / `cvar` 条目降级为摘要，并显式引用本计划作为后续实施入口
  - 当前总计划已经识别出这条能力域，但细节越来越多，继续留在总计划中会稀释其他 Hazelight 差距条目
  - 把总计划保留为“能力域摘要 + 为什么单独拆 plan”，避免出现两份文档同时维护完整细节
  - 只保留与 Hazelight 总盘点直接相关的事实，具体执行与补测动作统一下沉到本计划
- [ ] **P1.1** 📦 Git 提交：`[P6] Docs: split global variable and cvar parity into standalone plan`

- [x] **P1.2** 在 `Plan_OpportunityIndex.md` 中登记 `Plan_GlobalVariableAndCVarParity.md`
  - 这份计划同时属于“测试增强”和“Hazelight parity 收口”，但索引里只保留一个主入口，避免重复维护
  - 建议把它归到“测试增强”已有 plan 区，状态写成“部分完成”，并说明 `FConsoleVariable` 与首批 `Bindings` 测试已落地、`FConsoleCommand` / 剩余矩阵待补
  - 不要顺手改动索引顶层统计数字，除非顺带完成了全量 active-plan 重新盘点
- [ ] **P1.2** 📦 Git 提交：`[P6] Docs: register standalone global variable and cvar plan`

### Phase 2：收口 Console Variable / Command 能力面

> 目标：把 Hazelight 风格 `FConsoleVariable` / `FConsoleCommand` 从“局部可用”推进到“边界清晰、测试可验证”。

- [x] **P2.1** 固化 `FConsoleVariable` 当前已对齐能力，并补上 testing engine 相关回归
  - 当前分支已落地 `bool` / `FString` 构造、`GetString` / `SetString`、late-init delegate 自移除，以及 testing engine 的 `bIsInitialCompileFinished = true` 修复
  - 后续这里不再重复改 API 形状，除非 Hazelight 基线确认还有缺失的公开表面；主要任务是补一条 regression，防止 testing engine 再次回到“永远 deferred”的假路径
  - 若新增 regression test，优先放在 `Plugins/Angelscript/Source/AngelscriptRuntime/Tests/` 或与 `Bindings` 同层的现有测试族中，避免把 runtime 内部语义全挤进脚本行为测试
- [ ] **P2.1** 📦 Git 提交：`[P1] Test: lock testing-engine cvar initialization semantics`

- [ ] **P2.2** 为 `FConsoleCommand` 建立专项测试并明确支持边界
  - 当前 `Bind_Console.cpp` 已暴露 `FConsoleCommand(const FString& Name, const FName& FunctionName)`，但没有专门测试命令注册、重复注册替换、签名不匹配报错、析构卸载等行为
  - 先决定测试入口：优先验证“脚本构造后，底层 `IConsoleManager` 能找到命令对象”，再决定是否补 `ProcessUserConsoleInput` / delegate 触发链路；避免一步把命令执行世界上下文也拉进来
  - 如果 `FConsoleCommand` 的生命周期在脚本栈对象与 console 注册之间存在明显差异，应把这种“确定性的行为变化”写进本计划的风险章节，而不是只体现在测试断言里
  - 当前分支已在 `Plugins/Angelscript/Source/AngelscriptTest/Bindings/AngelscriptConsoleBindingsTests.cpp` 中补上命令注册/执行/模块卸载、重复注册替换、错误签名拒绝三类用例；剩余待收口的是 worktree 自动化 runner 的稳定验证证据
- [ ] **P2.2** 📦 Git 提交：`[P1] Test: add console command binding coverage`

### Phase 3：扩展全局变量与 cvar 测试矩阵

> 目标：从“有首批 smoke test”扩展到“按能力边界分层”的稳定矩阵，避免未来再把已支持项误判为缺口。

- [ ] **P3.1** 扩展插件绑定层 global variable 矩阵
  - 当前 `Bindings.GlobalVariableCompat` 已覆盖 `CollisionProfile`、`FComponentQueryParams`、`FGameplayTag`、`FGameplayTagContainer`、`FGameplayTagQuery` 这些典型命名空间全局变量
  - 后续应至少补一种“已有 native global property 被脚本读取”的案例，以及一种“命名空间下值类型默认对象/常量”的扩展案例，确保测试不只绑定到 GameplayTag / Collision 两个家族
  - 保持测试放在 `Bindings/`，不要把插件绑定层用例塞回 `Native/`，也不要重新发明一套新的 Automation 前缀
- [ ] **P3.1** 📦 Git 提交：`[P1] Test: expand global variable binding matrix`

- [ ] **P3.2** 扩展 `FConsoleVariable` 负例与边界测试
  - 当前已有 happy path（新建变量）和 existing-value path（复用已有 native cvar）两条正向测试，仍缺少签名不匹配、重名复用跨类型、空帮助字符串、重复构造等边界行为覆盖
  - 优先选“仓库里最稳定、最不依赖外部环境”的断言，不要为了覆盖而引入对全局 editor 状态、用户 config 或其它异步系统的隐式依赖
  - 如果某些跨类型 `Get*` / `Set*` 行为在 UE `IConsoleVariable` 语义上本来就不稳定，应在测试中显式避开，并在文档中说明“只保证同类型读写路径”
- [ ] **P3.2** 📦 Git 提交：`[P1] Test: expand console variable edge coverage`

### Phase 4：验证、文档收口与归档条件

> 目标：让这条能力域具备清晰的“完成”判定，而不是长期挂在总计划里模糊存在。

- [ ] **P4.1** 固定最小验证命令集
  - 构建统一使用 `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -TimeoutMs 300000 -Label globals-cvar`
  - `cvar` 测试统一使用 `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Bindings.ConsoleVariable" -TimeoutMs 300000 -Label console-variable`
  - `console command` 测试统一使用 `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Bindings.ConsoleCommand" -TimeoutMs 300000 -Label console-command`
  - 全局变量测试统一使用 `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Bindings.GlobalVariableCompat" -TimeoutMs 300000 -Label global-variable`
  - 如果后续补了 `FConsoleCommand`，新增单独的 `-TestPrefix`，不要把命令链路和 `ConsoleVariable` 混成一个 bucket
- [ ] **P4.1** 📦 Git 提交：`[P6] Docs: lock validation commands for global variable and cvar parity`

- [ ] **P4.2** 达到归档条件后从总计划移出细节维护责任
  - 本计划可以归档的判断标准是：`FConsoleVariable` / `FConsoleCommand` / plugin global variable 的目标矩阵测试都已存在且稳定，`TestCatalog` 和索引文档都能直接找到入口，Hazelight 总计划只保留摘要引用
  - 归档前需要在文档顶部补齐归档状态、归档日期、完成判断与结果摘要，并同步更新 `Documents/Plans/Archives/README.md`
  - 若仍存在明确 backlog（例如“支持 console command 实际执行链路，但不阻塞当前 parity 结论”），必须在归档说明中写清“不阻塞归档”的理由
- [ ] **P4.2** 📦 Git 提交：`[P6] Docs: archive global variable and cvar parity plan`

## 验收标准

1. 仓库内存在一份独立的 `Plan_GlobalVariableAndCVarParity.md`，并被 `Plan_OpportunityIndex.md` 与 `Plan_HazelightCapabilityGap.md` 正确引用。
2. 文档明确区分三类边界：原生 AngelScript global variable、插件 `BindGlobalVariable` / 命名空间全局变量、`FConsoleVariable` / `FConsoleCommand`。
3. `FConsoleVariable` 的最小支持面和 testing engine 相关根因都有对应的验证证据，不再出现“测试环境永远 deferred”导致的假失败。
4. `Bindings` 层至少具备：global variable 正向用例、`ConsoleVariable` 新建用例、`ConsoleVariable` 复用已有 native cvar 用例；如扩展到 `FConsoleCommand`，则命令注册也必须有独立测试入口。
5. 后续再做 Hazelight parity 盘点时，不需要重新讨论“当前插件到底有没有全局变量 / cvar 支持”，只需要沿本计划继续推进剩余闭环项。

## 风险与注意事项

### 风险

#### 风险 1：把“测试环境特例”误当成运行时真实缺陷

本分支已经暴露出一个典型例子：testing engine 如果不把 `bIsInitialCompileFinished` 置为 true，会让 `FConsoleVariable` 在测试里永远走 deferred 分支，但这并不等于 runtime 正常初始化路径本身有同样缺陷。后续补测试时必须先分清“runtime 真实行为”和“testing harness 语义”。

#### 风险 2：把原生 global variable 与插件绑定层混成一个能力项

`RegisterGlobalProperty` / `Native.ASSDK.GlobalVar.*` / `Angelscript.Misc.GlobalVar` 与 `CollisionProfile::BlockAllDynamic`、`FGameplayTag::EmptyTag` 这类插件命名空间全局变量不是同一层。若继续混在一起统计，后续很容易重复补测试，或者得出错误的“完全缺失”结论。

#### 风险 3：把 Console Variable 的 happy path 覆盖误判成完整对齐

`FConsoleVariable` 当前已经能跑通最小 happy path，但 `FConsoleCommand`、命令触发链路、跨类型边界以及文档入口都还没完全收口。后续不应因为 `ConsoleVariableCompat` 绿了，就直接把整个 console workflow 判定为完成。

#### 风险 4：工作树里存在其他进行中的改动

当前仓库存在与本计划无关的其他已修改 / 未跟踪文件。后续执行本计划时，提交和归档必须只围绕本计划列出的目标文件，避免把其它并行工作的变更误打包进来。

### 已知行为变化

1. **testing engine 的 cvar 初始化语义已与正常运行时对齐**：`InitializeForTesting()` 现在会把 `bIsInitialCompileFinished` 置为 true，因此测试环境里新建 `FConsoleVariable` 不再永远走 deferred 路径。
   - 影响文件：`Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.cpp`、`Plugins/Angelscript/Source/AngelscriptTest/Bindings/AngelscriptConsoleBindingsTests.cpp`
2. **`Bindings` 层相关专项测试统一偏向 clean-engine 模式**：当前 `ConsoleVariable` / `GlobalVariable` 新测试已经切到 `AcquireCleanSharedCloneEngine()`，后续新增同域测试应延续这一模式，避免与共享 clone 状态发生隐式耦合。
   - 影响文件：`Plugins/Angelscript/Source/AngelscriptTest/Bindings/AngelscriptConsoleBindingsTests.cpp`、`Plugins/Angelscript/Source/AngelscriptTest/Bindings/AngelscriptGlobalBindingsTests.cpp`
