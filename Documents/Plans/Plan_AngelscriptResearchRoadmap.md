# Angelscript 插件调研结论整合执行计划

## 背景与目标

本计划用于把本轮 Angelscript 插件调研结果收敛成一条可执行主路线，避免并行过多、重复开工和范围漂移。

当前已有大量子计划（AS2.38、测试扩展、Interface、UHT、去全局化等），但缺少统一的执行顺序与闸门。该文档的目标是：

1. 把现有计划拆分为 `Active Now / Gated Next / Deferred` 三层，先做能形成稳定回归闭环的工作。
2. 以“测试底座 + 稳定性切片”作为前置，之后再推进 AS2.38 与功能增强。
3. 明确每个阶段的依赖、验收边界与提交粒度，确保后续可由多名执行者并行推进且可控收口。

## 范围与边界

- **范围内**
  - `Plugins/Angelscript/Source/AngelscriptRuntime/`
  - `Plugins/Angelscript/Source/AngelscriptEditor/`
  - `Plugins/Angelscript/Source/AngelscriptTest/`
  - `Documents/Plans/`
  - `Documents/Guides/`
  - `Reference/angelscript-v2.38.0/`
- **范围外**
  - `Source/AngelscriptProject/` 宿主工程功能扩展
  - 与插件稳定交付无关的“样例工程功能”优先级前置
  - 未被测试或审计明确暴露的问题的顺手重构
- **执行边界**
  - 先收敛已有 Plan，不新开大而全总重构。
  - 修缺陷遵循最小修复原则，不混入额外架构重写。
  - 非必要不扩大 ThirdParty 改动面。

## 当前事实状态（调研快照）

1. 插件三模块结构已稳定：`AngelscriptRuntime`、`AngelscriptEditor`、`AngelscriptTest`。
2. 现有计划文档较多，存在主题重叠；测试、AS2.38、功能增强可执行，但缺统一依赖顺序。
3. 核心风险集中在：全局状态依赖、测试分层不稳、部分高风险能力面缺窄范围回归。
4. AS2.38 相关计划已拆为 Lambda / Non-Lambda 两轨，具备继续推进基础。
5. AS2.38 官方变更调研已完成，确认高价值候选集中在：`Template Functions`、`Foreach`、`Variadic Arguments`、`Bool Conversion Mode`、`Member Init Mode`。
6. AS2.38 官方新增引擎属性需纳入范围冻结：`asEP_MEMBER_INIT_MODE(38)`、`asEP_BOOL_CONVERSION_MODE(39)`、`asEP_FOREACH_SUPPORT(40)`。
7. 必要稳定性修复候选已识别（context shutdown crash、try/catch stack pointer、variadic stack pointer、context 复用内存风险、隐式转换崩溃），应优先并入“先测后改”的缺陷切片。

## 优先级分层（本计划基准）

### Active Now（立即执行）

- 测试分层与分组基线收敛（以 `Plan_AngelscriptUnitTestExpansion.md` 为主）
- 稳定性切片：内部类 / Bind+Watcher / Debugger 低风险高价值回归
- 缺陷最小修复切片（仅处理已有证据可复现问题）

### Gated Next（满足前置后执行）

- AS2.38 Non-Lambda 审计范围内能力迁移
- AS2.38 Lambda（匿名函数范围）
- C++ UInterface 绑定主路径
- UHT 自动函数表能力（先小覆盖闭环，再扩面）

### Deferred（延后）

- 大面去全局化主工程（`Plan_FullDeGlobalization.md` 全量实施）
- 广谱 Hazelight 风格能力对齐
- 大规模工作流美化类增强（仅在核心稳定后插入）

## 分阶段执行计划

### Phase 0：冻结边界与闸门

> 目标：先把“做什么、不做什么、什么条件下才开工”写死，避免后续并行冲突。

- [ ] **P0.1** 补齐 AS2.38 官方差异回填并冻结迁移边界
  - 以官方变更清单冻结本轮高价值项优先级：`Template Functions`、`Foreach`、`Variadic Arguments`（主能力），`Bool Conversion`、`Member Init Mode`（低风险增益）。
  - 把官方新增引擎属性 `asEP_MEMBER_INIT_MODE(38)`、`asEP_BOOL_CONVERSION_MODE(39)`、`asEP_FOREACH_SUPPORT(40)` 映射到现有计划的“纳入/排除”列表。
  - 对每个 AS2.38 候选项标注 `立即执行 / 前置依赖 / 本轮排除`，禁止口头范围扩张。
  - 若某项需要跨入未审计的编译器核心改写，立即拆为独立后续任务，不与当前任务混提交流。
- [ ] **P0.1** 📦 Git 提交：`[Docs/AS238] Chore: freeze AS238 migration boundaries from latest research`

- [ ] **P0.2** 生成统一决策闸门清单并与现有计划做一对一映射
  - 固定四个闸门：`G1 Interface 路径`、`G2 UHT 启动时机`、`G3 去全局化范围`、`G4 Debugger 测试深度`。
  - 在本计划中为每个闸门给出“当前选择 + 延后选项”，并指向对应 Plan 文档，避免多文档重复决策。
  - 所有后续 Phase 条目必须显式引用所依赖的闸门状态，防止跳闸开工。
- [ ] **P0.2** 📦 Git 提交：`[Docs/Roadmap] Feat: add decision gates and plan mapping matrix`

### Phase 1：测试与稳定性底座（优先批次）

> 目标：先建立可靠回归网，再推进语义迁移和能力扩展。

- [ ] **P1.1** 落地测试分层与分组基线（先文档与入口，再扩测试）
  - 以 `Plan_AngelscriptUnitTestExpansion.md` 为主，先完成目录归属、分组口径、live inventory 统计规则统一。
  - 把 `TestCatalog` 的文档基线与源码统计口径对齐，明确 `Smoke/Fast/Scenario/Editor/RuntimeUnit` 的执行入口。
  - 仅在分组稳定后再允许批量新增测试，避免“新增越多越难管理”。
- [ ] **P1.1** 📦 Git 提交：`[Test/Infra] Chore: align test taxonomy grouping and live inventory baseline`

- [ ] **P1.2** 执行三波窄范围高价值回归补齐
  - 第 1 波：`Plan_ASInternalClassUnitTests.md`，先覆盖内部类与编译/执行基础机制。
  - 第 2 波：Bind 注册与目录监视稳定性验证方向已从本轮计划集中移除；如需恢复，重新立项后再执行。
  - 第 3 波：`Plan_ASDebuggerUnitTest.md` 的协议与基础行为层，不先追求平台特性全覆盖。
- [ ] **P1.2** 📦 Git 提交：`[Test/Core] Test: add phased internal bind watcher and debugger focused regressions`

- [ ] **P1.3** 缺陷最小修复切片（每个缺陷都先测试复现）
  - 仅处理“已有证据 + 可被 focused test 锁住”的问题，避免把修复任务变成清理工程。
  - 优先并入 AS2.38 官方已识别的稳定性修复候选（context shutdown crash、try/catch stack pointer、variadic stack pointer、context 复用内存风险、隐式转换崩溃）。
  - 优先选择会阻塞后续计划的稳定性问题（例如热重载边界、命名冲突、线程安全边界）。
  - 每个修复切片独立提交，配套一个最小回归测试，禁止跨问题合并提交。
- [ ] **P1.3** 📦 Git 提交：`[Runtime/Stability] Fix: resolve blocker defects with isolated regression coverage`

### Phase 2：AS2.38 合入（双轨）

> 目标：在测试底座已稳定的前提下，按风险分轨推进，不做一口吃全量升级。

- [ ] **P2.1** 执行 Non-Lambda 审计范围迁移
  - 按 `Plan_AS238NonLambdaPort.md` 既有边界推进 `Bind_TOptional`、`Bind_UStruct`、`Bind_BlueprintType` 的最小可验证闭环。
  - 任何触发 Interface 语义迁移或大面积 ThirdParty 变更的条目立即停下并转交对应 sibling plan。
  - 每一小项遵循“先 failing test，再最小实现，再 focused regression”。
- [ ] **P2.1** 📦 Git 提交：`[ThirdParty/AS238] Feat: close audited non-lambda parity slices with focused tests`

- [ ] **P2.2** 执行 Lambda（匿名函数范围）迁移
  - 按 `Plan_AS238LambdaPort.md` 只覆盖匿名函数目标，不在同批引入模板函数等额外语义。
  - 启动前必须满足函数句柄基线与 parser/compiler 回归入口可用；不满足则回退到 Phase 1 强化基础。
  - 保留官方负向边界测试，确保“该失败的仍失败”。
- [ ] **P2.2** 📦 Git 提交：`[ThirdParty/AS238] Feat: enable anonymous lambda pipeline with gated scope`

### Phase 3：能力增强（闸门后批次）

> 目标：在语言与测试基础可控后，再扩展接口和自动化生成能力。

- [ ] **P3.1** 启动 C++ UInterface 绑定主路线
  - 执行 `Plan_CppInterfaceBinding.md` 作为落地主计划，`Plan_InterfaceBinding.md` 保持总设计与 backlog 容器。
  - 第一批只证明“可见性 + 调用链 + 类型行为”主闭环，不提前混入 `FInterfaceProperty` 扩展。
  - 若出现跨模块语义冲突，先补验证案例再决定是限域实现还是新增子计划。
- [ ] **P3.1** 📦 Git 提交：`[Runtime/Interface] Feat: deliver first stable C++ UInterface binding path`

- [ ] **P3.2** 启动 UHT 自动函数表小覆盖闭环
  - 以 `Plan_UhtPlugin.md` 为蓝本，先做可验证最小子集（导出、生成、加载、回归）而不是全量自动化。
  - 明确手写 Bind 的优先级和冲突策略，防止生成结果覆盖既有行为。
  - 通过一组代表性类型验证生成结果可编译、可注册、可调用。
- [ ] **P3.2** 📦 Git 提交：`[Plugin/UHT] Feat: add minimal verified UHT export and function table pipeline`

- [ ] **P3.3** 可选能力项按“2/3 主线完成”原则插入
  - 包括 `Plan_DebugAdapter.md`、`Plan_ScriptFileSystemRefactor.md`、`Plan_AngelscriptLearningTraceTests.md`、`Plan_ASSDKTestIntegration.md` 等。
  - 只有当 `P2.1/P2.2/P3.1/P3.2` 中至少两项完成并稳定后，才允许启动本项。
  - 新开工前先在本计划补一条“为什么现在做、为什么不是更高优先项”的判定说明。
- [ ] **P3.3** 📦 Git 提交：`[Roadmap/Optional] Chore: activate optional tracks after core gates pass`

### Phase 4：回归收口与交付同步

> 目标：把阶段成果沉淀为可持续交付状态，而不是只停留在“局部已完成”。

- [ ] **P4.1** 执行分层回归与已知例外登记
  - 先跑每个 workstream 的 focused regression，再跑插件级 broader regression，避免只靠全量慢测定位问题。
  - 对未通过项区分“本次引入回归”与“历史已知例外”，并形成可追踪清单。
  - 回归结果必须回写到对应 Plan 与 Guide，而不是只留在临时日志。
- [ ] **P4.1** 📦 Git 提交：`[Test/Validation] Test: record focused and broad regression outcomes by workstream`

- [ ] **P4.2** 文档与索引同步收口
  - 更新 `Documents/Guides/TestCatalog.md`、`Documents/Guides/TechnicalDebtInventory.md`、`Documents/Plans/Plan_OpportunityIndex.md` 中受影响条目。
  - 对已完成项标注状态，对延后项标注下一次触发条件，避免下轮调研重复盘点同一问题。
  - 输出“下一迭代起点列表”（最多 5 项）作为后续执行入口。
- [ ] **P4.2** 📦 Git 提交：`[Docs/Roadmap] Chore: sync roadmap statuses and next-iteration entry points`

## 阶段依赖关系（执行顺序）

```text
Phase 0（边界/闸门）
  -> Phase 1（测试与稳定性底座）
    -> Phase 2（AS2.38 双轨）
      -> Phase 3（Interface/UHT/可选增强）
        -> Phase 4（回归收口与文档同步）
```

补充依赖：

- `P2.2` 依赖 `P1.1` 与 `P2.1` 的最小前置能力达标。
- `P3.1` 依赖 `G1`（Interface 路径）决策冻结。
- `P3.2` 依赖 `G2`（UHT 启动时机）决策冻结。
- `P3.3` 依赖“核心主线至少完成两项”这一执行门槛。

## 验收标准

1. 本计划中的每个 `Active Now` 条目均有对应执行计划与回归入口，不再停留在口头优先级。
2. AS2.38 迁移按双轨推进，且每轨都有明确“纳入/排除”边界与测试证据。
3. 功能增强项（Interface/UHT）有闸门控制，不在基础未稳时提前铺开。
4. 文档状态与源码/测试现状保持同步，`Plan_OpportunityIndex` 不再与主执行路线冲突。
5. 任一阶段结束时均可回答：做了什么、证据在哪、下一阶段为何可启动。

## 风险与注意事项

- **并行过载风险**：同一时期不应同时推进多个高耦合大项，优先保证底座质量。
- **范围膨胀风险**：AS2.38 与 UHT 项容易扩散；必须坚持“最小闭环 + 测试证据”推进。
- **文档漂移风险**：若只改代码不回写计划与指南，下一轮会重复探索并误判优先级。
- **回归定位风险**：禁止用全量测试替代 focused regression；每个切片必须有窄范围定位入口。
- **插件目标偏移风险**：始终以 `Plugins/Angelscript` 可复用交付为中心，不把宿主工程需求前置。
