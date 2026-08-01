# 可复用表现组件目录（components-catalog）

> 登记本 change 拟建/已建的可复用文档表现组件。约束见 `design.md` D4 与 `specs/wiki-document-expression-components/spec.md`。
> **形式选择优先级**：内容内 WikiText/transclusion ＞ `\procedure`/`\function` ＞ 最小 `src/<plugin>/` widget。
> **状态**：`planned`（规划）/ `built`（已实现）/ `tested`（含 `test:feature` 场景）。

## 已有可复用件（复用，不重造）

| 名称 | 形式 | 用途 | 边界依据 | 状态 | 示例页面 |
|---|---|---|---|---|---|
| `<$angelscript-code>` | widget（`src/angelscript-tools`） | 保持固定 AngelScript 高亮、自定义起始/高亮/1-based 切片/复制与显式行号能力，并接收直系 `<$code-note>` 注解；行号默认隐藏 | 既有 API 的兼容入口；仍复用官方 Highlight，交互层才需要最小 widget | tested | `AS/Showcase/Pattern/P02-LineExplanation`、`P03-KeyPathAnnotations`、`P04-AngelScriptCppBridge` |
| `<$annotated-code>` | language-generic widget（`src/angelscript-tools`） | 以 `code` 属性承载任意语言源码，提供无右轨的行尾/空白行/上方 shelf 自动贴注与按需详情 | C++ 等非 AS 源码需要共享生产行为；官方 Highlight 继续拥有 token 渲染，组件只拥有注解交互 | tested | `AS/Showcase/Pattern/P04-AngelScriptCppBridge`（`language="cpp"`） |
| `<$code-note>` | direct-child widget（`src/angelscript-tools`） | 用显示行/范围与可选精确子串/occurrence 定义常显短注；详情可来自内联 WikiText 或独立 `detailTiddler`，无效锚点保留为未定位注解 | note 是父代码面的结构化定义，不能用全局宏安全拥有 Range、ARIA、Popover、transclusion refresh 与 teardown 生命周期 | tested | `AS/Showcase/Pattern/P02-LineExplanation`、`P03-KeyPathAnnotations`、`P04-AngelScriptCppBridge` |
| `<$lifecycle-flow>` + `<$lifecycle-event>` | typed source-flow widget family（`src/angelscript-tools`） | 连续源码后的生命周期事件轴，标注 owner/phase/condition/re-entry 并与源码 note 联动 | 有跨源码与流程的选择/ARIA/披露生命周期，纯 WikiText 无法安全复用 | tested | `AS/Showcase/Pattern/P07-LifecycleTimeline` |
| `<$state-flow>` + node/transition | typed source-flow widget family（`src/angelscript-tools`） | 状态、合法迁移、trigger/guard/outcome 与源码证据 | 需要结构引用校验、键盘选择和无效关系回退 | tested | `AS/Showcase/Pattern/P08-HotReloadStateTransition` |
| `<$call-sequence>` + participant/message | typed source-flow widget family（`src/angelscript-tools`） | 跨 AS/Unreal/C++ 边界的有序调用与 return/alternate/failure | 需要稳定参与者引用和源码关系同步 | tested | `AS/Showcase/Pattern/P09-RpcCallSequence` |
| `<$data-flow>` + node/edge | typed source-flow widget family（`src/angelscript-tools`） | 输入、产物、owner、transform/route/fallback 数据流 | 需要可验证节点/边、文本回退和源码联动 | tested | `AS/Showcase/Pattern/P10-CompilationDataFlow` |
| `<$source-ast>` / `<$vm-trace>` | revisioned JSON-backed Lab widgets（`src/angelscript-tools`） | 简化 AST 双向定位与 source-level VM 执行记录 | 复杂夹具需 schema/fidelity/revision 校验，页面正文不内联巨型 JSON | tested | `AS/Showcase/Lab/L01-SourceAstLinkage`、`L02-VmExecutionTrace` |
| `<$codeblock language="angelscript">` | 核心 widget | 普通嵌入 AS 代码块 | 同上 | tested | — |
| Markdown 警示块（note/warning/tip） | Markdown More | 提示/警告/要点 | product-sources 已选，pastel admonitions | tested | — |
| 线性图标（109） | `line-icon-registry` | 图标 | `wiki-unified-line-icons` | tested | — |
| `<<as-doc-link "logical/key" "caption">>` | procedure | 语言无关文档链接 | Agents.md 文档链接规范 | tested | — |
| `as-doc-status-label` | procedure | 状态徽章渲染 | 既有 | tested | — |

> 生产源码注解与结构解释组件族只增加一个受限运行时依赖：精确锁定的 `obstacle-router@0.1.2` 被预打包为独立 TiddlyWiki `library` 模块，仅在存在无法安全水平直连的关系时执行矩形路径求解。原生 DOM `Range` 继续测量源码墨迹与可用空白，组件自身拥有 note 落位、端口、路径圆滑化、SVG、缓存、idle 延迟和安全 fallback；原生 Popover 配合自适应 fixed positioning 与非 Popover fallback。typed flow/AST/VM 组件继续复用这一源码面。短 note 可选 `comment` / `muted` / `ink`；内联详情适合短解释，`detailTiddler` 带低强调 `Wiki` 标记、展开预览和独立入口。connector 在所有交互状态下永久位于 Highlight 源码下层，idle 范围无下划线，交互只增强当前关系。2026-07-31 的 flow 重构与验证记录见任务 2.19；2026-08-01 的层级与几何修正见任务 2.20，批量避障与双详情形态见任务 2.21。

## 已建组件（本 change 首批）

| 名称 | 形式 | tid（`src/angelscript-tools/documentation/`） | 用途 | 状态 | 示例页面 |
|---|---|---|---|---|---|
| `as-callout` | `\procedure`（`$:/tags/Global`） | `callout.tid` | 图标风格的 note/tip/warning/danger 提示块 | built | language/index、classes-inheritance-interfaces |
| `as-doc-cards` + `as-doc-card` | `\procedure`（`$:/tags/Global`） | `doc-cards.tid` | landing 页文档卡片网格，自动读取目标页 caption/description/depth/status | built | language/index |

> CSS 追加在 `src/angelscript-tools/index.css`（经 `index.ts` 打包）。颜色取自 `currentColor` 与主题 `--as-control-focus`，对齐 Notion light 调色板。`built → tested` 待补 `test:feature -- document` 场景（见 §5，受 Node 24 工具链限制本机未跑）。

## 拟沉淀组件（planned，按需分批实现）

| 名称（暂定） | 形式 | 用途 | 边界依据 | 状态 | 示例页面 |
|---|---|---|---|---|---|
| 能力对比表 | `\procedure` | 特性/分叉能力对比（如 cpp-blueprint-differences、hazelight-capability-matrix） | 纯渲染、可 transclude 数据；HTML 仅受信任静态 | planned | unreal-language/cpp-blueprint-differences |
| API 签名表模板 | `\procedure` | 统一 reference 类文档的签名/参数/返回表 | 减少直排、跨页复用 | planned | unreal-language/uproperty 等 reference 页 |
| 可折叠“源码入口/深入”块 | `\procedure` | internals 页折叠源码入口与证据链 | WikiText details/reveal，非新全局宏 | planned | runtime-jit-vm/* internals |
| 状态/深度徽章行 | `\procedure`/`\function` | landing 页展示 depth/status 概览 | 复用既有 status-label | planned | 各 topic index |
| 图标 callout 卡片 | `\procedure` | 图标+标题+说明的引导卡片 | 复用线性图标；受信任静态内容 | planned | getting-started landing |
| showcase 引用块 | `\procedure` | 从 `AS/Showcase/Data/Catalog` 引用条目 | 引用既有目录，不复制正文 | planned | showcase-lab/index |
| draw.io 图表嵌入约定 | 内容 + 允许列表 | 架构/管线图 | 允许列表 + 离线 SVG 回退 | planned | architecture-maintenance/index |

> 每个组件在标 `built`/`tested` 前须在 `components-catalog` 补：实际形式、示例页面、测试 tiddler + `test:feature -- <domain>` 场景。
