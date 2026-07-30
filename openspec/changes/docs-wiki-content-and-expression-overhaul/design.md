## Context

`Wiki/` 是独立的 TiddlyWiki 5 子模块（`TDGameStudio/AngelscriptWiki`），通过 `Wiki/` gitlink 被父仓库消费。当前 `wiki/tiddlers/docs/zh-Hans/` 有 90 篇正式中文文档，完成度低（39 placeholder / 47 draft / 4 reviewed / 0 published）、表现单调、缺少统一的可复用表现组件。

本 change 是**长期伞形治理入口**，把“内容 + 表现力 + 结构 + 组件”四条工作线的方法固定下来，并以活文档（`doc-status-matrix.md`、`components-catalog.md`）驱动分批推进。所有硬约束来自 `Wiki/Agents.md`（文档内容契约、表现力边界、Git/Host 流程、验证命令），本设计不重复其规范文本，只规定“如何在本 change 内组织与推进工作”。

## Goals / Non-Goals

**Goals:**
- 建立可长期复用、可随时重排的治理结构：状态矩阵 + 组件目录 + 分节 `tasks.md`。
- 明确内容状态推进（placeholder→draft→reviewed→published）的证据标准。
- 明确表现力组件的实现形式选择与测试要求，避免随意造全局宏或越界 HTML/iframe。
- 明确父仓库记录与 `Wiki/` 子模块内容的分离提交流程与验证入口。

**Non-Goals:**
- 本次会话不批量改写文档正文、不改动 `Wiki/` 子模块任何文件。
- 不引入新的导航层级（坚持两级：7 组 → 具体文档）。
- 不触碰 Wiki 基础设施/主题/发布（各由既有 change 拥有）。
- 不通过普通 `dev/test/build` 隐式触发 `generate-knowledge-pages.mjs` 或源码语料同步。

## Decisions

### D1. 单独新建 umbrella change，而非并入既有 wiki change
既有 wiki change 全是基础设施/主题/发布主题，边界与“文档内容质量”正交。合并会污染其范围与归档节奏。**选择新建**，以本 change 独占“内容 + 表现力 + 结构 + 组件”。

### D2. 用活文档矩阵作为事实来源（对齐 `test-coverage` 模式）
参照 `openspec/changes/test-coverage/coverage-matrix.md` 的“稳定 proposal + 演进 tasks + 矩阵 + 图例”模式：
- `doc-status-matrix.md`：全部 90 篇文档一行一条，含 `as-doc-key | 当前 status | depth | kind | nav-group | 目标 status | 待办摘要`，图例 ⬜placeholder / 🟡draft / 🔵reviewed / ✅published。它是“增改哪些文档”的单一看板，维护者随时在此调优先级。
- `components-catalog.md`：每个组件一行，含 名称 | 形式 | 用途 | 边界依据 | 状态(planned/built/tested) | 示例页面。
矩阵/目录随实现演进更新，`tasks.md` 只保留干净复选框，日志与盘点数据放在这两个活文档里。

### D3. 内容状态推进的证据标准（对齐内容契约）
- `placeholder` → 必须含六个非空小节：本章要解决什么 / 计划内容 / 已知资料 / 源码入口 / 依赖与相关页面 / 审阅状态。
- `draft` → `reviewed`：正文完整、示例可运行、`internals`（仅 L4/L5）需连成可复核证据链（可观察行为→管线/状态→关键数据结构→稳定源码入口→最小 trace/实验→失败模式→回归证据）；不得把计划性文字标为 `reviewed`。
- 中文为 source-of-truth：改中文即递增 `as-content-revision`，中文审阅通过后才改英文对照页（英文需 `as-translation-of`/`as-source-revision`/`as-translation-status`）。

### D4. 表现力实现形式的选择规则（对齐表现力边界）
优先级：**内容内 WikiText/transclusion > `\procedure`/`\function` > 最小 `src/<plugin>/` widget**。
- 单页可表达的表现，不建 widget、不造全局宏。
- 需跨页复用的纯渲染/控制流用 `\procedure`，纯取值/过滤用 `\function`；仅为兼容保留既有 `\define`/legacy 宏。
- HTML 仅限仓库内受信任静态内容，禁止插值外部/用户/字段数据。
- iframe/外部嵌入需允许列表 + 网络/安全说明 + 离线回退（draw.io 保存的 SVG 离线可看，编辑依赖已批准端点）。
- 代码：普通嵌入用 `<$codeblock language="angelscript">`，需行号/自定义起始/高亮/1-based 切片用 `<$angelscript-code>`；不重引入手写 tokenizer。
- 每个可复用组件都要在 `components-catalog.md` 记录“边界依据”，并在落地时补最小测试 tiddler + `test:feature` 场景。

### D5. 结构重构保持两级导航不变
`taxonomy`（15 topics）与 L0–L5 只作 `AS/Docs` 下的二级“知识体系”视图；`AS/Docs` 与左侧 `AS/Navigation` 主路径固定为两级：七个任务/学习组 → 具体正式 `.tid`。重构只调整归属与顺序，不新增第三级、不恢复退役 tag（`Home`/`Navigation`/`Status`/`Theme`/`Workflow`/`Maintainer`）。

### D6. 父仓库/子模块分离提交（对齐 Agents.md §Git and Host Workflow）
Wiki 内容改动在 `Wiki/` 内完成、测试、提交并推送到 Wiki 远端；回到父仓库后用 `git diff --submodule=log` 复核，仅暂存 `Wiki` gitlink 与相关 host 文档，父仓库单独提交。禁止在父仓库 `git add .`。OpenSpec 记录只在父仓库 `openspec/`。

## Risks / Trade-offs

- [矩阵与真实元数据漂移] → 每批推进后用只读 `grep` 重新统计并回填矩阵；把统计口径写进 `tasks.md §1`。
- [表现力过度工程/造无谓 widget] → D4 的优先级规则 + `components-catalog.md` 的“边界依据”列作为门槛，评审时对照。
- [长期 change 永不收敛] → `tasks.md` 分节 + 目标状态列使进度可量化；允许维护者随时重排，但每阶段以 `test:fast`/`test:feature` 收口。
- [子模块与父仓库提交耦合出错] → 严格按 D6 分离；本次会话完全不动子模块，先把记录立起来。
- [英文对照滞后被当作现行] → 遵循 D3 中文优先与英文 fallback 通知规则，不让 stale 英文冒充现行。

## Migration Plan

无运行时迁移。推进节奏：先建记录（本次）→ 分批实现组件（`tasks §2`）→ 结构复核（`§3`）→ 内容分批推进（`§4`，维护者按矩阵优先级驱动）→ 每批与阶段性验证（`§5`）。回滚：仅按显式确认的路径回退，禁用 `git checkout -- .` / `git reset --hard`。

## Open Questions

- `wiki-document-expression-components` 是否与既有 `wiki-document-experience-integration` 能力有重叠需要改为 MODIFIED？（落 specs 前以 `openspec show wiki-document-experience-integration` 复核；当前判断为新增独立能力。）
- 内容分批的首批优先级（按 `nav-group` 还是按 reviewed 缺口最大 topic）留待维护者在 `doc-status-matrix.md` 指定。
