## Why

`Wiki/` 子模块（TiddlyWiki 5，`TDGameStudio/AngelscriptWiki`）中的正式中文文档质量与完成度整体偏低，且长期需要分批、反复地更新与重构，而非一次性交付：

- `wiki/tiddlers/docs/zh-Hans/` 共 **90 篇正式中文文档**，状态分布为 `placeholder` 39 篇、`draft` 47 篇、`reviewed` 4 篇、`published` 0 篇——大面积未完成、未审阅。
- 文档表现单调：绝大多数是纯 Markdown 直排。项目其实已具备但正文几乎未使用的表现力工具（`<$angelscript-code>`、`<$codeblock>`、Markdown 警示块、109 个线性图标、WikiText `\procedure`/`\function`、受信任静态 HTML、允许列表内的 draw.io 图表）没有被系统性利用。
- 现有 wiki 相关 OpenSpec change 全部聚焦基础设施/主题/发布（toolchain、architecture-hardening、home-previews、notion-cover-icon、github-pages-publishing），**没有任何一个 change 拥有“文档内容质量 + 表现力 + 可复用表现组件”这一主题**。

需要一个**长期、伞形（umbrella）**的治理入口，把内容补全、结构重构、表现力增强与组件沉淀统一记录、分批推进，并允许维护者随时调整优先级与目标。

## What Changes

本 change 是**长期 record-while-implementing**（非阶段性一次性）change，覆盖四条并行工作线：

- **内容补全与重写**：按 `placeholder → draft → reviewed → published` 推进各文档，补齐 `placeholder` 六段结构，逐批把 `draft` 提升到 `reviewed`；以 `doc-status-matrix.md` 作为全部 90 篇文档的单一事实来源与优先级看板。
- **表现力增强（宏 / HTML / 图表）**：在 `Wiki/Agents.md` 表现力边界内，用 WikiText `\procedure`/`\function`、transclusion、受信任静态 HTML、允许列表内 iframe，以及既有 `<$angelscript-code>`/`<$codeblock>`/警示块/线性图标，替换单调直排。
- **结构重构**：把产品 Tag 从冗余的 `ASWiki/Docs|ReaderNav|Showcase` 收口为 UE 风格 PascalCase 主题 Tag，并让主题/导航定义分别通过 `as-topic-key` / `as-nav-key` 发现；不保留 `Docs` 或 `ReaderNav` 根，只为有真实层级含义的 `Showcase/*` 保留命名空间（无别名、无双读），同时补全 Tag 定义与完整性契约。再复核并调整 `taxonomy`（15 topics）/ `nav-group`（7 组）/ `as-depth`（L0–L5）归属，坚持“两级导航（7 组 → 具体文档）”，15 topics 仅作二级知识体系视图，不恢复已退役 tag。
- **新增可复用表现组件**：把重复出现的表现模式（能力对比表、API 签名表、可折叠“源码入口/深入”块、状态徽章、图标 callout 卡片、showcase 引用块等）沉淀为最小 `\procedure`/`\function` 或 `src/<plugin>/` widget，登记于 `components-catalog.md` 并配 `test:feature` 覆盖。

所有 Wiki 内容/组件改动落在 `Wiki/` 子模块并单独提交；本 change 的 OpenSpec 记录落在父仓库 `openspec/`。本 change 持续采用 record-while-implementing，允许记录与已确认的 Wiki 实现同批推进。

## Capabilities

### New Capabilities
- `wiki-document-expression-components`: 定义“可复用文档表现组件”的边界、注册方式、实现形式选择（`\procedure`/`\function` vs `src/<plugin>/` widget）与测试要求，把表现力增强固化为可复核契约。

### Modified Capabilities
- `wiki-content-architecture`: 增加“内容完成度分批推进”与“UE 风格产品 Tag”约束——以状态矩阵为事实来源、按 `nav-group`/topic 分批推进状态、要求状态提升具备契约所需证据，并要求所有非系统产品 Tag 是已注册的 PascalCase 主题 Tag（含已定义子 Tag）或 `Showcase/*` 分类且定义完整；主题/导航发现改用稳定字段，不改变既有 topic/nav 两级结构本身。

## Impact

- **父仓库（本 change 记录）**：`openspec/changes/docs-wiki-content-and-expression-overhaul/`（proposal、design、tasks、doc-status-matrix、components-catalog、specs）。
- **子模块 `Wiki/`（后续阶段）**：`wiki/tiddlers/docs/zh-Hans/**` 正文与元数据；`wiki/tiddlers/docs/taxonomy|navigation/**` 结构；可复用组件落在 `src/angelscript-tools/` 或 `src/angelscript-wiki-config/`；对应 `tests/playwright/product/**`。
- **约束来源**：`Wiki/Agents.md`（文档内容契约、表现力边界、Git/Host 分离提交流程、验证命令）。
- **验证**：`Wiki/` 下 `pnpm run test:fast`、`pnpm run test:feature -- document|code|i18n`，交付前 `pnpm run test:release`。
