## Why

`Wiki/` 子模块(TiddlyWiki 5,`TDGameStudio/AngelscriptWiki`)的正式中文文档在**内容完成度**上仍有系统性缺口,需要一次集中的“定性盘点 + 可采用草稿”交付,而不是只更新状态计数:

- `wiki/tiddlers/docs/zh-Hans/` 现有约 **96 篇**正式中文文档,状态分布 `placeholder` 30 / `draft` 53 / `reviewed` 13 / `published` **0**——大量占位与薄弱草稿,尚无一篇发布。
- 多个专题**只有占位 landing、零子页**:`editor-ide-debugging`(缺 VS Code 配置、断点调试等实战页)、`showcase-lab`、`architecture-maintenance`;`topics-integrations` 六篇集成页(GameplayTags/GAS/EnhancedInput/Networking-RPC/UI-UMG/AI-BehaviorTree)全部为 `placeholder`。
- 已有 umbrella change `docs-wiki-content-and-expression-overhaul` 维护的是**状态看板 + 表现力/组件治理方法**(`doc-status-matrix.md`),它并不产出“对不足的定性总结”,也不产出“可直接评审、可迁移的成篇草稿”。
- 缺少一个把“**当前文章有哪些不足**”讲清楚、并把“**先补哪些文章、补成什么样**”落成可评审附件的入口。

本 change 就是这个入口:产出一份《文章不足总结》,并把一批**基于真实插件与示例源码写成**的补充文章草稿,作为 OpenSpec **附件**暂存,供维护者评审后再按子模块流程迁移进 `Wiki/`。

## What Changes

- **不足总结(附件)**:`deficiency-summary.md` —— 对全部 zh-Hans 正式文档做定性盘点,按七类不足(完成度 / 可运行示例 / 表现力单调 / 结构与导航 / internals 证据链 / i18n 英文对照 / 交叉引用)给出量化证据、按 `nav-group` 汇总、并列出覆盖缺口清单。
- **补充文章草稿(附件)**:`supplements/**.tid` —— 交付总计 **200 篇** Wiki 原生 `.tid` 草稿（含 11 篇高质量锚点、覆盖全部 15 个正式 topic，并带完整 frontmatter），优先覆盖三条最高价值缺口线:
  - **集成专题**:`topics-integrations/index`(重写)、`gameplay-tags`、`gas`、`enhanced-input`,以及 `ui-umg` 作为“无专用插件、但有引擎域示例”的**边界页样板**(networking-rpc / ai-behavior-tree 同类边界沿用该样板)。
  - **编辑器 / IDE / 调试**:`editor-ide-debugging/index`(重写)、新增 `vscode-setup`、`debugging-breakpoints`。
  - **Showcase / 架构维护**:`showcase-lab/index`(重写)、`architecture-maintenance/index`(重写)、新增 `architecture-maintenance/module-ownership`。
- **采用指引(附件)**:`supplements/README.md` —— 逐篇登记真实依据、`as-doc-key`、topic 与迁移导航字段，供维护者按主题评审和采用。

所有草稿都严格遵循 `Wiki/AGENTS_ZH.md` / `Wiki/AGENTS.md` 的当前文档内容契约（PascalCase topic Tag、frontmatter、表现组件、注册 `as-sources`），并只陈述在被引用源码中核实过的 API；未核实处用 `as-callout note` 标注。**本 change 只暂存 OpenSpec 附件，不改动 `Wiki/` 子模块任何文件**——迁移是后续、单独的子模块提交。

## Capabilities

### New Capabilities
- `wiki-content-gap-supplements`: 定义“内容缺口的定性记录 + 200 篇候选补充文章草稿以 OpenSpec 附件形式暂存”的契约——不足总结须量化且可追溯，草稿须源码可核实、符合当前内容契约、明确标注 `draft`，并在采用进 `Wiki/` 前保持为父仓库附件。

### Modified Capabilities
<!-- 无。刻意不修改 wiki-content-architecture,避免与在进行中的 umbrella change 冲突;本 change 以新增独立能力承载缺口盘点与草稿暂存契约。 -->

## Impact

- **父仓库(本 change)**:`openspec/changes/docs-wiki-article-gaps-and-supplements/`(proposal、design、tasks、`deficiency-summary.md`、`supplements/**`、`specs/wiki-content-gap-supplements/spec.md`)。
- **不触碰**:`Wiki/` 子模块(草稿为附件,采用是后续单独提交)、既有 umbrella change 的 `doc-status-matrix.md` / `components-catalog.md`。
- **约束来源**:`Wiki/AGENTS_ZH.md` / `Wiki/AGENTS.md`(文档内容契约、表现力边界、`as-sources` 注册表)、`AS/Docs/Data/SourceRegistry`。
- **事实依据**:`Plugins/AngelscriptGAS`、`Plugins/AngelscriptGameplayTags`、`Script/Examples/EnhancedInput`、`Extensions/AngelscriptVSCode`、`Documents/Guides/VSCodeAngelscript.md`、各 `Source/` 模块结构。
