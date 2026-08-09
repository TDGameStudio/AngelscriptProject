## Context

`Wiki/` 是独立 TiddlyWiki 5 子模块。父仓库通过 `Wiki/` gitlink 消费它。正式中文文档在 `wiki/tiddlers/docs/zh-Hans/`(约 96 篇),`published` 为 0,且若干专题只有占位 landing。既有 umbrella change `docs-wiki-content-and-expression-overhaul` 已经承载“状态看板 + 表现力/组件治理”,但没有产出“定性不足总结”与“可评审的成篇补充草稿”。

本 change 是一次**聚焦交付**：把不足讲清楚（`deficiency-summary.md`），并把 **200 篇源码可核实**的补充文章以 OpenSpec 附件形式暂存（`supplements/**.tid`），供维护者评审后再迁移。所有硬约束来自 `Wiki/AGENTS_ZH.md` / `Wiki/AGENTS.md`；本设计只规定“如何在本 change 内组织盘点与草稿暂存”，不重复其规范文本。

## Goals / Non-Goals

**Goals:**
- 用可追溯、量化的方式记录当前正式文档的不足(不只是状态计数)。
- 交付总计 200 篇可直接评审、迁移前可机械校验的 `.tid` 草稿，覆盖全部 15 个正式 topic，并回应最高价值的覆盖缺口。
- 保证草稿的准确性:只写在真实插件/示例/指南中核实过的 API 与行为。
- 明确“附件暂存 → 子模块采用”的分离边界,避免误改 `Wiki/`。

**Non-Goals:**
- 不修改 `Wiki/` 子模块任何文件(草稿是父仓库附件)。
- 不接管 umbrella change 的状态看板/组件目录,不与其 `wiki-content-architecture` MODIFIED 交叠(本 change 用新能力承载)。
- 不新增导航层级、不恢复退役 tag、不改主题/发布/工具链。
- 不把 engine-domain 集成写成并不存在的专用插件，也不为真正没有示例的主题编造示例；Networking、UI/UMG、AI/BehaviorTree 应引用仓库已有示例，同时如实声明其没有独立集成插件。

## Decisions

### D1. 独立新增能力 `wiki-content-gap-supplements`,不改 `wiki-content-architecture`
umbrella change 已对 `wiki-content-architecture` 挂 MODIFIED delta。若本 change 也改同一能力,两个进行中的 change 会在同一 spec 上产生冲突增量。**选择新增独立能力**,承载“缺口定性记录 + 草稿附件暂存”契约,与 umbrella 的状态看板/组件治理正交。

### D2. 草稿以 OpenSpec 附件暂存,采用是后续单独的子模块提交(对齐 `AGENTS.md §Git and Host Workflow`)
用户要求“补充在 OpenSpec 的附件中”。草稿写入 `openspec/changes/.../supplements/`,标题仍用 `AS/Docs/zh-Hans/<key>` 但不落在 `Wiki/`,因此不会被 Wiki 运行时加载。迁移时在 `Wiki/` 内完成、测试、单独提交并推送 Wiki 远端,再回父仓库暂存 gitlink;本 change 不做这一步。

### D3. 准确性优先：源码可核实，未核实即显式标注
每篇草稿绑定明确的事实依据文件（见 `supplements/README.md` 映射）。draft 只陈述在这些文件中核实过的类型、方法和流程；无法核实处用 `<<as-callout note>>` 标注“待对照源码核实”，不编造示例脚本或 API 签名。维护者按主题抽查正文是否忠实表达证据。

### D4. frontmatter 保真并跟随当前 Tag 契约
对既有占位页的重写，保留其稳定身份、排序、导航、集成和 feature frontmatter（`as-doc-key` / `as-order` / `as-nav-*` / `as-integration-*` / `as-feature-key` 等），把 `as-content-status` 提为 `draft`、把 `as-content-revision` +1，并允许为新正文追加已注册的 `as-sources` 证据键。所有附件使用 `Wiki/wiki/tiddlers/docs/taxonomy/` 当前定义的 UE 风格 PascalCase topic Tag，禁止恢复 `ASWiki/`、`Docs/` 或 `ReaderNav` 根。新页显式给定完整 frontmatter，`as-sources` 只用 `AS/Docs/Data/SourceRegistry` 注册键。

### D5. 边界主题用“证据边界页”而非伪造专用集成
`ui-umg` 作为 engine-domain 边界页样板：如实说明当前无专用集成插件，引用 `Script/Examples/Core/Example_Widget_UMG.as` 已验证的作者路径，并把超出示例/绑定证据的能力留在核实边界内。`networking-rpc` 与 `ai-behavior-tree` 分别引用 `Example_NetworkReplication.as` 与 `Example_BehaviorTreeNodes.as`，同时保持同样的插件/打包边界。集成页一律声明打包语义（`optional-plugin` 记 `as-integration-plugin` + 依赖；`engine-domain` 记 `as-integration-system` + 依赖）。GAS 等当前没有脚本示例的主题只能引用真实插件/验证资产，禁止虚构示例。

### D6. 深度定位为 `draft`,不越级标 `reviewed`
本批交付目标是把 placeholder/缺失页提升到**完整 draft**(六段/可运行示例/表现组件),而非 `reviewed`。`reviewed` 需要中文审阅 + internals 证据链,超出本次附件暂存范围,留给采用后的评审。

### D7. 以 200 篇精确总量和主题配额作为完成口径
“约 200 篇”在执行时固定为 **200 篇**，避免无法证明完成。主题配额为：Start 6、Language 12、UnrealLanguage 21、TypeObjectReflection 10、UnrealCore 14、CompileModulePreprocessor 13、HotReload 11、EditorIdeDebugging 11、TestingDiagnosticsRelease 18、RuntimeJitVm 20、BindingsUhtExtensions 22、ArchitectureMaintenance 13、TopicsIntegrations 12、ReferenceDifferencesVersion 11、ShowcaseLab 6。`supplements/README.md` 是逐篇采用目录，最终以目录与文件双向一一对应、总数和各主题配额准确作为收口证据。

### D8. 初始 81 篇先完成契约迁移，再扩展到 200 篇
执行开始时已有 81 篇附件满足基本字段、来源键和唯一 doc-key，但仍使用已退役的 `ASWiki/Docs/*` Tag。先完成契约迁移与结构校验，再按主题补齐剩余 119 篇；随后所有 200 篇都按 D9 重新进行内容返工，不能把最初“字段合格”解释成最终“正文合格”。

### D9. 深度标签是正文合同，篇数配额不能替代成文质量
`as-depth` 不只是导航标签，而是草稿必须兑现的证据深度。文件字节数只作为发现异常薄页的信号，不作为单独验收标准；逐篇验收按以下正文合同进行：

| 深度 | 最低正文合同 |
|---|---|
| L0 | 说明分支定位、读者路线、适用/不适用边界、来源与状态；不能只是卡片或链接目录。 |
| L1 | 提供至少一条由当前示例或源码核实的可操作路径，解释步骤、预期结果、最常见失败和下一步。 |
| L2 | 在 L1 基础上补概念/生命周期模型、API 或场景矩阵、组合限制、故障定位和具体 grounding 入口。 |
| L3 | 补模块/对象所有权、跨 Runtime/Editor/Commandlet/PIE 边界、状态流与维护者可追踪的真实文件或符号。 |
| L4 | 给出符号级执行/生成管线、关键数据结构、不变量、失败原子性、旧新状态关系和分层证据入口。 |
| L5 | 在 L4 基础上提供完整维护地图、改动影响面、兼容/迁移策略、清理顺序与证据分层。 |

每篇仍须围绕一个独立读者问题，但“问题唯一”不能用来合理化只写摘要。简单主题可以短，前提是完整兑现对应深度；复杂 internals 页即使字段和来源合法，只要缺少 symbol trace、状态不变量或失败模式，就仍是不合格草稿。执行中先扩写所有未满足深度合同的既有附件，再创建剩余标题；总数 200 只在逐篇质量合同满足后才构成完成。

## Initial Anchor Set（11 篇）

下表记录最初选择的 11 篇锚点，而不是最终交付全集。最终 200 篇及其 current depth、new/rewrite 生命周期、导航、来源与 grounding path 以 `supplements/README.md` 为唯一逐篇目录；锚点在质量返工后允许提升 depth。

| # | as-doc-key | 类型 | 处理 | 事实依据 |
|---|---|---|---|---|
| 1 | topics-integrations/index | reference(L1) | 重写 landing | 现有页 + Plugins/ 结构 + Script/Examples |
| 2 | topics-integrations/gameplay-tags | guide(L3) | 重写 | AngelscriptGameplayTags/Source/**/Public |
| 3 | topics-integrations/gas | guide(L3) | 重写 | AngelscriptGAS/Source/**/Public + GASTest |
| 4 | topics-integrations/enhanced-input | guide(L2) | 重写 | Script/Examples/EnhancedInput/*.as |
| 5 | topics-integrations/ui-umg | guide(L2) | engine-domain 边界页 | Script/Examples/Core/Example_Widget_UMG.as + 当前绑定表面 |
| 6 | editor-ide-debugging/index | guide(L0) | 重写 landing | VSCodeAngelscript.md |
| 7 | editor-ide-debugging/vscode-setup | tutorial(L1) | 新增 | VSCodeAngelscript.md + Extensions/AngelscriptVSCode |
| 8 | editor-ide-debugging/debugging-breakpoints | guide(L2) | 新增 | VSCodeAngelscript.md + Runtime/Debugging |
| 9 | showcase-lab/index | guide(L0) | 重写 landing | Wiki/AGENTS.md 表现力边界 |
| 10 | architecture-maintenance/index | explanation(L0) | 重写 landing | Plugins/Angelscript/AGENTS.md |
| 11 | architecture-maintenance/module-ownership | reference(L1) | 新增 | 三插件 Source/ 结构 + AGENTS.md |

## Risks / Trade-offs

- [草稿被误当已审现行内容] → 一律标 `draft`；`supplements/README.md` 明示“附件、待评审、未迁移”。
- [无示例主题被写成虚构指南] → D5 边界页;drafting 明确禁止编造 API,未核实处 callout 标注。
- [新页 `as-doc-key` 迁移时缺导航登记] → README 列出新页需在 `Wiki/` 登记的 `as-nav-group`/`as-nav-order`/`as-nav-parent`。
- [误改 `Wiki/` 子模块] → D2 严格分离;本 change 完全不写 `Wiki/`。
- [与 umbrella change 状态漂移] → 本 change 以定性总结 + 草稿为主,不复制其状态计数为事实来源,只引用其 matrix 作为交叉参照。
- [frontmatter 字段漂移或旧 Tag 导致 Wiki 校验失败] → D4 保真，并在收口时用现有 Wiki 内容契约读取器对照当前 taxonomy、SourceRegistry 和同 key 正式页。
- [200 篇数量目标造成薄弱重复内容] → 每篇必须有唯一 doc-key、独立读者问题、明确 grounding 路径；主题配额只控制覆盖，不豁免逐篇质量抽查。
- [用短摘要冒充高深度文章] → D9 将 L0-L5 绑定到明确正文合同；字节统计只负责发现异常，最终按示例/模型/符号/不变量/失败模式和证据链逐篇审阅。

## Migration Plan

无运行时迁移。后续采用路径(不在本 change):维护者评审 `supplements/**.tid` → 在 `Wiki/` 内落位对应 `wiki/tiddlers/docs/zh-Hans/**` → 补/校导航登记 → `pnpm run test:fast` 与 `test:feature -- document` → Wiki 单独提交并推送 → 父仓库暂存 gitlink 单独提交。回滚仅按显式确认路径,禁用 `git checkout -- .` / `git reset --hard`。

## Open Questions

- `editor-ide-debugging` 新子页（vscode-setup / debugging-breakpoints）的 `as-nav-order` 最终值以采用时的组内排序为准，本附件给出建议值。
- `networking-rpc` 与 `ai-behavior-tree` 已纳入 200 篇附件范围，并沿 `ui-umg` 的 engine-domain 边界页合同撰写；采用时仍需由维护者决定与当前正式 placeholder 的合并顺序。
