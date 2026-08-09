# Tasks — docs-wiki-article-gaps-and-supplements

> 交付物为父仓库 OpenSpec 附件：当前不足总结、200 篇 `.tid` draft、双向采用目录和只读一致性审计。**不改动 `Wiki/` 子模块**；正式采用属于后续独立的 Wiki 提交。按用户要求，本轮不创建或运行测试。

## 1. 当前契约与基线

- [x] 1.1 只读扫描 96 篇正式 zh-Hans 文档的状态、nav-group、depth、组件和 i18n 基线，并据此重写 `deficiency-summary.md`（未运行 Wiki 测试脚本）
- [x] 1.2 审计现有 81 篇附件：必填字段、来源键、唯一性、重写 frontmatter、body 基线与旧 Tag 使用情况
- [x] 1.3 更新 proposal/design/spec：固定 200 篇完成口径、15-topic 配额、当前 PascalCase Tag 与采用校验合同

## 2. 现有 81 篇语料迁移

- [x] 2.1 将早期附件的 `ASWiki/Docs/*` Tag 迁移到对应 PascalCase topic Tag，并用 revision 记录后续质量返工
- [x] 2.2 建立 `supplements/README.md`，逐篇登记 doc-key、topic、new/rewrite、导航、来源键和现存 grounding 路径
- [x] 2.3 按 topic 审阅现有草稿，修正与当前源码不符的事实、失效路径、旧相关链接和错误深度标记

## 3. 11 篇锚点草稿验收

- [x] 3.1 验收 topics-integrations/index、gameplay-tags、gas、enhanced-input 与 ui-umg 的源码依据、示例和打包边界
- [x] 3.2 验收 editor-ide-debugging/index、vscode-setup 与 debugging-breakpoints 的指南和 DebugServer 依据
- [x] 3.3 验收 showcase-lab/index、architecture-maintenance/index 与 module-ownership，并把锚点稿及其后续扩展映射回 `deficiency-summary.md`

## 4. 200 篇主题配额

- [x] 4.1 补齐 Start 至 6 篇、Language 至 12 篇、UnrealLanguage 至 21 篇
- [x] 4.2 补齐 TypeObjectReflection 至 10 篇、UnrealCore 至 14 篇、CompileModulePreprocessor 至 13 篇
- [x] 4.3 补齐 HotReload 至 11 篇、EditorIdeDebugging 至 11 篇、TestingDiagnosticsRelease 至 18 篇
- [x] 4.4 补齐 RuntimeJitVm 至 20 篇、BindingsUhtExtensions 至 22 篇、ArchitectureMaintenance 至 13 篇
- [x] 4.5 补齐 TopicsIntegrations 至 12 篇、ReferenceDifferencesVersion 至 11 篇、ShowcaseLab 至 6 篇
- [x] 4.6 对 15 个 topic 分别审阅：读者问题、grounding 路径、事实边界、WikiText 语法、相关链接和导航均已纳入只读审计
- [x] 4.7 按 D9 逐篇复核 L0-L5 正文合同，返工异常薄页并校正深度；最终正文体量按层形成梯度，但只作为异常信号、不作为质量替代物

## 5. 最终采用目录与验证

- [x] 5.1 证明 `supplements/README.md` 与 200 个 `.tid` 文件双向一一对应，并记录最终 topic/nav/source 分布
- [x] 5.2 用只读元数据/正文解析复核必填字段、当前 Tag、来源键、唯一性、链接、导航、topic 配额和 200 篇总量
- [ ] 5.3 运行 `openspec validate docs-wiki-article-gaps-and-supplements --strict`（按用户“不要搞测试”的要求，本轮不执行命令式验证）
- [x] 5.4 对照 Git 状态确认本 change 只写入自身 OpenSpec 目录；`Wiki/` gitlink 仍为 `6ebec23`，其四个 worktree 修改及其它父仓库脏文件均为既有/无关改动，未被本 change 触碰
- [x] 5.5 将 15 个 topic、200 篇已实现文章及其深度、doc-key、内容范围和交付边界记录为中文附件 `implemented-articles-zh.md`，并从采用目录建立入口
