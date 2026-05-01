# Angelscript 测试体系规范化计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 把 Angelscript 插件当前分散、漂移的测试体系整理为一套可维护的层级、命名、执行与文档规范，并给出可分阶段落地的解决方案。

**Architecture:** 方案以“先固化规则与入口，再做低风险样本修正，最后推进历史包袱迁移”为主线。先统一 `CppTests / Editor / TestModule` 三层边界，再收敛文件命名与 Automation 前缀，最后分批处理 `Examples`、`Subsystem`、历史前缀与分组配置，避免一次性大范围改名带来的回归风险。

**Tech Stack:** Unreal Engine Automation Tests、PowerShell、`Tools/RunTests.ps1`、`Tools/RunTestSuite.ps1`、`Plugins/Angelscript/Source/*/Tests`、`Documents/Guides/Test*.md`

---

## 背景与目标

当前项目已经积累了较大规模的 Angelscript 自动化测试，但从“插件级长期维护”和“后来者可以按规范继续补测”的角度看，测试体系仍存在七类明显问题：

1. **测试层级边界分散**
   - `Plugins/Angelscript/Source/AngelscriptRuntime/Tests/`、`Plugins/Angelscript/Source/AngelscriptEditor/Tests/`、`Plugins/Angelscript/Source/AngelscriptTest/` 已形成事实上的三层测试体系，但这套边界此前没有在单一文档中被完整固定。
   - 结果是新增测试时经常先想“放哪”，而不是先按层级判断“它属于哪类测试”。
2. **文件命名存在历史漂移**
   - 部分 Native / ASSDK 测试文件没有显式体现 `ASSDK`；部分文件缺少统一的 `Angelscript` 前缀，搜索和归类成本偏高。
   - 典型问题包括 `AngelscriptSmokeTest.cpp`、`AngelscriptEngineTests.cpp`、`AngelscriptExecuteTests.cpp`、`AngelscriptGlobalVarTests.cpp` 与 `PreprocessorTests.cpp` 这类名字与目录意图不完全对齐的样本。
3. **Automation 前缀不完全稳定**
   - 现有代码实际同时使用 `Angelscript.TestModule.CppTests.*`、`Angelscript.Editor.*`、`Angelscript.TestModule.*` 三层前缀，但个别文档、suite、历史计划中的前缀仍有漂移。
   - 例如 `Parity` 相关 smoke 入口曾同时出现 `Angelscript.TestModule.Parity` 与 `Angelscript.TestModule.Core.Parity` 两种写法。
4. **执行流程入口不够标准化**
   - `Tools/RunTests.ps1` 已经能稳定运行单个前缀，但常用 `Smoke / Native / Learning / Scenario` 波次仍然依赖人工记忆和手工拼命令。
   - 缺少标准 suite 时，同样一轮冒烟在不同人手里可能跑出不同前缀组合。
5. **目录归属仍有历史模糊桶**
   - `Examples/`、`Template/`、部分场景目录与 `ScriptExamples.*` / `WorldSubsystem.*` / `GameInstanceSubsystem.*` 等对外前缀之间，仍存在“历史沿用但不够理想”的口径。
   - 这些问题不一定需要一次性推倒重做，但必须在计划层面明确是“兼容保留”还是“后续迁移”。
6. **目录文档与源码现状存在漂移**
   - `Documents/Guides/TestCatalog.md` 之前对 Native 层没有首层目录入口，导致已经存在的 Native / ASSDK 体系不够直观可见。
   - 个别 smoke 前缀与实际注册前缀也曾不一致，降低了文档作为执行入口的可信度。
7. **后续批量治理缺少统一 backlog**
   - 当前已经能识别出若干应继续整理的主题：`ScriptExamples`、`WorldSubsystem`、`GameInstanceSubsystem`、suite 继续扩展、Automation group 配置等。
   - 如果没有一份完整计划，这些问题会继续分散在临时讨论和零散改动中。

本计划的目标不是“一次性把所有历史前缀重命名完”，而是：

- 固定当前测试体系的**层级、命名、执行入口、文档导航**；
- 先修复几类**低风险但收益高**的命名与流程问题；
- 把剩余历史包袱整理成明确 backlog，并给出后续解决方案。

## 范围与边界

- **范围内**
  - `Plugins/Angelscript/Source/AngelscriptRuntime/Tests/`
  - `Plugins/Angelscript/Source/AngelscriptEditor/Tests/`
  - `Plugins/Angelscript/Source/AngelscriptTest/`
  - `Plugins/Angelscript/AGENTS.md`
  - `Documents/Guides/Test.md`
  - `Documents/Guides/TestCatalog.md`
  - `Documents/Guides/TestConventions.md`
  - `Documents/Tools/Tool.md`
  - `Tools/RunTests.ps1`
  - `Tools/RunTestSuite.ps1`
- **范围外**
  - `Source/AngelscriptProject/` 宿主工程逻辑
  - 与测试规范化无直接关系的运行时功能修复
  - 图形测试 / 截图测试体系扩张
  - 任何需要大规模批量改动 50+ 测试前缀的“重命名即正义”式改造
- **边界约束**
  - 中文文档优先更新；路径、符号与测试前缀保留英文。
  - 新增规范必须以**兼容现有主要前缀**为前提，不因为“更整洁”就打断既有入口。
  - 每一轮测试规范改动都要同步更新至少一处“执行入口文档”，不能只改源码或只改计划。

## 影响范围

本次规范化涉及以下操作（按需组合）：

- **层级边界固化**：把 Runtime / Editor / TestModule 三层测试边界写入 Guide 与 AGENTS。
- **前缀规则对齐**：修正文档、suite、目录说明中与实际测试注册不一致的前缀。
- **文件命名规范化**：把低风险样本文件名统一为 `Angelscript*` / `AngelscriptASSDK*` 形式。
- **目录编目补齐**：把 Native、Smoke、样本场景等内容补入目录文档，让后续执行者无需重新扫源码。
- **执行入口标准化**：通过 `RunTestSuite.ps1` 把推荐 suite 固化为标准命令入口。
- **历史 backlog 分流**：把不适合在本轮一次性迁完的目录/前缀问题记录成后续 Phase。

按目录分组的影响范围如下：

Documents/Guides/（3 个主文件 + 后续可能扩展）：
- `Documents/Guides/Test.md` — 层级入口、标准流程、suite 入口、推荐命令
- `Documents/Guides/TestCatalog.md` — 目录索引、Native 层编目、Smoke / 回归矩阵
- `Documents/Guides/TestConventions.md` — 命名规则、层级矩阵、典型样本、兼容保留项

Documents/Tools/（1 个）：
- `Documents/Tools/Tool.md` — `RunTests.ps1` / `RunTestSuite.ps1` 使用说明与参数

Plugins/Angelscript/（1 个 guide 文件 + 多个测试目录）：
- `Plugins/Angelscript/AGENTS.md` — 新增测试时的放置、命名、前缀规则
- `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/*` — Native / ASSDK 文件名规范化
- `Plugins/Angelscript/Source/AngelscriptTest/Preprocessor/*` — 缺失项目前缀的历史文件名修正
- `Plugins/Angelscript/Source/AngelscriptTest/Examples/*` — 后续是否迁回主题目录的 backlog
- `Plugins/Angelscript/Source/AngelscriptTest/Subsystem/*` — 历史前缀保留或迁移方案

Tools/（2 个）：
- `Tools/RunTests.ps1` — 保持单前缀执行入口
- `Tools/RunTestSuite.ps1` — 提供具名 suite 的标准回归入口

## 当前事实状态

### 已确认的事实

1. `AngelscriptRuntime/Tests` 已经是纯 Runtime 内部 C++ 测试层，前缀实际为 `Angelscript.TestModule.CppTests.*`。
2. `AngelscriptEditor/Tests` 已经是 Editor 内部测试层，前缀实际为 `Angelscript.Editor.*`。
3. `AngelscriptTest` 模块已经承载 Native、运行时集成、UE 场景、Learning、Examples 等多层测试，但此前没有单一文档统一解释这些层的边界。
4. Native 层的两条事实子层已经存在：
   - `Angelscript.TestModule.AngelScriptSDK.*`：纯原生 AngelScript 公共 API 路径
   - `Angelscript.TestModule.AngelScriptSDK.ASSDK.*`：ASSDK 适配层 / 包装层回归
5. `Tools/RunTests.ps1` 能可靠执行单前缀回归，但在“固定一轮标准 smoke / scenario 样本”这类需求下，不够直接。
6. `Examples/`、`ScriptExamples.*`、`WorldSubsystem.*`、`GameInstanceSubsystem.*` 等历史前缀并不一定错误，但它们确实已经被识别为“需要评估是否继续保留”的对象。

### 当前问题 → 对应解决方向

| 问题 | 当前症状 | 解决方向 |
| --- | --- | --- |
| 测试层级不清 | 新增测试时难以判断属于 Runtime / Editor / TestModule 哪层 | 在 Guide + AGENTS 中固定三层边界与放置规则 |
| 文件命名漂移 | Native / ASSDK 文件名不够直观，Preprocessor 缺少统一前缀 | 先修复代表性样本，后续新增统一遵循新规则 |
| 前缀漂移 | 文档 / suite / 实际注册前缀有时不一致 | 以源码实际注册为准反推文档与 suite |
| 执行流程分散 | smoke / native / scenario 波次靠人工记忆 | 新增 `RunTestSuite.ps1` 固化具名 suite |
| 编目不完整 | Native 层在 TestCatalog 中不够可见 | 为 Native 建立首层目录条目与代表前缀表 |
| 历史目录模糊 | `Examples/`、`Template/` 角色边界不够稳定 | 先写兼容规则，再分批迁移真正应回主题目录的 case |
| backlog 零散 | 后续迁移没有统一清单 | 在本计划中单列后续 Phase 和验收口径 |

## 分阶段执行计划

### Phase 0：固定规则与问题基线

- [ ] **P0.1** 统一测试层级与放置规则
  - 先把 `AngelscriptRuntime/Tests`、`AngelscriptEditor/Tests`、`AngelscriptTest` 三层测试体系写成一份明确的层级矩阵，而不是继续依赖口头共识或零散历史计划。
  - 让后续新增测试时，第一步不是“这个文件名起什么”，而是先判断它属于 `CppTests`、`Editor`、`Native`、运行时集成还是 UE 场景层。
  - 这一阶段只固化边界，不做大规模迁移；原则是先减少“继续变乱”的入口。
- [ ] **P0.1** 📦 Git 提交：`[Docs/Test] Docs: define test layer boundaries and placement rules`

- [ ] **P0.2** 固定文件命名与 Automation 前缀约定
  - 把“测试源文件统一以 `Angelscript` 开头”“ASSDK 文件显式带 `ASSDK`”“`Angelscript.TestModule.CppTests.*` / `Angelscript.Editor.*` / `Angelscript.TestModule.*` 三层不混用”写成正式规则。
  - 同时明确“目录已经表达场景层时，不在 Automation 路径中重复追加 `Scenario`”这一约束，避免今后再出现目录名、类名前缀、Automation 前缀三处重复表达同一语义的情况。
  - 对 `ScriptExamples.*`、`WorldSubsystem.*`、`GameInstanceSubsystem.*` 这类已广泛存在的历史前缀，暂列为兼容保留项，不在 Phase 0 强推整体改名。
- [ ] **P0.2** 📦 Git 提交：`[Docs/Test] Docs: define naming and automation prefix conventions`

### Phase 1：标准执行入口与目录编目

- [ ] **P1.1** 把常用回归波次固化成 suite 入口
  - 在保留 `RunTests.ps1` 作为单前缀入口的同时，通过 `RunTestSuite.ps1` 提供 `Smoke`、`NativeCore`、`ScenarioSamples` 等具名 suite，让“先跑哪一组”从经验问题变成标准命令。
  - `Smoke` 只收最稳定、最短、最有代表性的前缀；不要把长时压力层、环境敏感项、重脚本语料层直接混进第一版 suite。
  - 每个 suite 必须能通过 `-ListSuites` 与 `-DryRun` 自解释，避免脚本再次成为“只有写的人知道”的入口。
- [ ] **P1.1** 📦 Git 提交：`[Tools/Test] Feat: add named test suite runner`

- [ ] **P1.2** 补齐目录文档中的 Native / Smoke 入口
  - 在 `TestCatalog.md` 中让 Native 层成为首层可见目录，并列出 `Native.*` 与 `Native.ASSDK.*` 的代表前缀与代表源文件。
  - 同步修正 Smoke 矩阵与真实注册前缀的漂移，确保后续执行者从文档复制的命令就是可运行命令，而不是“接近正确”的旧写法。
  - 这一阶段不追求把所有测试都重新编目，但必须先把最容易被拿来当入口的层级写对。
- [ ] **P1.2** 📦 Git 提交：`[Docs/Test] Docs: catalog native layer and align smoke prefixes`

### Phase 2：首轮低风险命名规范化样本

- [ ] **P2.1** 修复 Native / ASSDK 代表性文件名
  - 先处理最清晰、最不容易引发语义争议的一组历史文件名：Smoke、Engine、Execute、GlobalVar 这些 ASSDK 文件统一显式带 `ASSDK`。
  - 目标不是“批量全部重命名”，而是先把最典型、最常见的误导性名字修到位，为后续新增文件建立清晰样板。
  - 同步确保引用这些文件名的计划和目录文档跟着更新，避免“源码已改名，文档还指向旧文件”的二次漂移。
- [ ] **P2.1** 📦 Git 提交：`[Test/Native] Chore: normalize ASSDK test filenames`

- [ ] **P2.2** 修复缺少项目前缀的历史文件名
  - `PreprocessorTests.cpp` 这类文件名不利于全仓搜索和长期维护，应统一迁为 `AngelscriptPreprocessorTests.cpp` 这一类显式项目前缀形式。
  - 这一阶段只处理明确缺少项目语义前缀的样本，不把“所有风格不完美”的文件都拉进来一起动。
  - 同步更新目录文档与相关 Plan 引用，确保计划、文档、源码保持同一口径。
- [ ] **P2.2** 📦 Git 提交：`[Test] Chore: normalize preprocessor test filename`

### Phase 3：历史包袱迁移 backlog

- [ ] **P3.1** 评估 `Examples/` 与 `ScriptExamples.*` 的长期定位
  - 当前 `Examples/` 既承担示例脚本验证，又混入了一部分本质上属于具体主题能力的 case；这会继续诱导后来者把“任何不好分类的东西”都扔进示例目录。
  - 需要按文件逐项判断：哪些是真正的“示例仍能编译/运行”回归，哪些应迁回 `Bindings/`、`Actor/`、`Delegate/`、`Component/` 等主题目录。
  - 本阶段先产出迁移清单和判断标准，不强制一次性全部迁完。
- [ ] **P3.1** 📦 Git 提交：`[Docs/Test] Docs: classify example tests and migration candidates`

- [ ] **P3.2** 评估 `WorldSubsystem.*` / `GameInstanceSubsystem.*` 的前缀策略
  - 这两组前缀当前已经有历史使用和目录含义，不适合在没有完整迁移窗口时直接推平到新主题前缀。
  - 需要给出明确结论：继续作为兼容保留项，还是分阶段迁入更统一的主题命名体系；同时记录它们为何被保留，以及什么条件下才值得迁。
  - 如果迁移成本过高，应明确写成“兼容保留，不阻塞本计划 closeout”，防止长期悬而未决。
- [ ] **P3.2** 📦 Git 提交：`[Docs/Test] Docs: decide subsystem prefix migration strategy`

- [ ] **P3.3** 扩展 suite 与 Automation groups 的长期规划
  - 当前第一版 `RunTestSuite.ps1` 先覆盖 `Smoke / Native / Learning / HotReload / ScenarioSamples`，但后续仍可能需要 `Performance`、`EditorUnit`、`BindingsFast`、`Examples` 等更细粒度 suite。
  - 同时要评估是否需要在 `DefaultEngine.ini` 中补充长期稳定的 `AutomationTestSettings` groups，把“回归波次”从脚本层进一步固化到引擎分组层。
  - 这一阶段先做规划和优先级，不急着同时改脚本和分组配置，避免过早把尚未稳定的目录规则写死。
- [ ] **P3.3** 📦 Git 提交：`[Docs/Test] Docs: outline suite and automation group roadmap`

### Phase 4：验证与收口

- [ ] **P4.1** 以“文档入口可执行 + 样本命名已收敛 + backlog 已有明确去向”为标准做 closeout
  - 回归验证重点不是全量跑完所有测试，而是确认：文档中的推荐前缀与 suite 实际能展开、样本重命名没有留下旧路径悬挂、Native / Smoke / 典型场景入口在目录中都可被直接发现。
  - 如果仍有历史目录或前缀不够理想，但已经被明确列为兼容保留项或下一阶段 backlog，则不应阻塞本计划 closeout。
  - closeout 时要同步更新相关 Guide / Plan 的口径，避免“Plan 已说整理完，但入口文档还是旧的”。
- [ ] **P4.1** 📦 Git 提交：`[Docs/Test] Docs: close out test system normalization phase one`

## 验收标准

1. 新增测试时，执行者只看 `Test.md`、`TestConventions.md`、`Plugins/Angelscript/AGENTS.md` 就能判断测试属于哪一层、该放哪里、Automation 前缀怎么起。
2. `Tools/RunTestSuite.ps1` 至少提供 `Smoke`、`NativeCore`、`ScenarioSamples` 这些标准入口，并能通过 `-ListSuites` / `-DryRun` 自解释。
3. `TestCatalog.md` 对 Native 层和 Smoke 入口的编目不再缺位，文档中的关键前缀与实际测试注册一致。
4. 最典型的历史命名异常（ASSDK 文件名与缺少 `Angelscript` 前缀的 Preprocessor 文件）已经收敛到新规则。
5. `Examples`、`WorldSubsystem`、`GameInstanceSubsystem`、suite 扩展、Automation groups 这些仍未整体迁完的问题，都已经写入 backlog 并附带明确解决方向。

## 风险与注意事项

### 风险

1. **历史前缀兼容成本高于预期**
   - `ScriptExamples.*`、`WorldSubsystem.*`、`GameInstanceSubsystem.*` 可能已经被文档、脚本或外部使用者拿来当稳定入口。
   - **缓解**：本计划只要求先明确“保留还是迁移”，不要求一次性全量改名。

2. **文档先行但代码未完全迁完**
   - 如果规范文档写得过于理想化，而实际代码仍保留较多历史结构，执行者会把“目标状态”误读成“当前已全部完成状态”。
   - **缓解**：在文档中显式区分“当前规范”“兼容保留项”“后续 backlog”，不要把未来工作伪装成现状。

3. **suite 入口膨胀回到混乱状态**
   - 如果每出现一个需求就加一个 suite，`RunTestSuite.ps1` 很快会从“标准入口”退化成“另一份杂乱前缀清单”。
   - **缓解**：只为复用率高、语义稳定、可长期维护的波次建立 suite；其余仍通过 `RunTests.ps1` 单前缀执行。

### 已知行为变化

1. **Smoke 入口会更严格对齐实际前缀**
   - 影响位置：`Documents/Guides/Test.md`、`Documents/Guides/TestCatalog.md`、`Tools/RunTestSuite.ps1`
   - 说明：之前如果有人直接沿用旧的 `Core.Parity` 写法，后续应统一改为与实际测试注册一致的 `Angelscript.TestModule.Parity`。

2. **ASSDK / Preprocessor 文件名会发生一次性规范化**
   - 影响位置：`Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/`、`Plugins/Angelscript/Source/AngelscriptTest/Preprocessor/`
   - 说明：后续引用这些文件名的计划、目录文档和评审讨论都必须跟随新文件名，否则会继续制造“源码已改、文档未改”的漂移。

## 依赖关系

```text
Phase 0 固定层级/命名规则
  ↓
Phase 1 固化 suite 与目录入口
  ↓
Phase 2 修复低风险代表性命名样本
  ↓
Phase 3 处理历史目录与前缀 backlog
  ↓
Phase 4 统一验证与 closeout
```

## 参考文档

| 文档 | 用途 |
| --- | --- |
| `Documents/Guides/Test.md` | 测试入口、运行方式、推荐命令 |
| `Documents/Guides/TestCatalog.md` | 测试目录编目与回归矩阵 |
| `Documents/Guides/TestConventions.md` | 测试层级、命名和典型样本规范 |
| `Documents/Tools/Tool.md` | `RunTests.ps1` / `RunTestSuite.ps1` 工具说明 |
| `Plugins/Angelscript/AGENTS.md` | 插件范围测试放置与命名规则 |
| `Documents/Plans/Plan_TestModuleStandardization.md` | 本主题的首轮简版整理记录，可作为本计划的前置快照 |


