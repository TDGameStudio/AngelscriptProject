# 可复用表现组件目录（components-catalog）

> 登记本 change 拟建/已建的可复用文档表现组件。约束见 `design.md` D4 与 `specs/wiki-document-expression-components/spec.md`。
> **形式选择优先级**：内容内 WikiText/transclusion ＞ `\procedure`/`\function` ＞ 最小 `src/<plugin>/` widget。
> **状态**：`planned`（规划）/ `built`（已实现）/ `tested`（含 `test:feature` 场景）。

## 已有可复用件（复用，不重造）

| 名称 | 形式 | 用途 | 边界依据 | 状态 |
|---|---|---|---|---|
| `<$angelscript-code>` | widget（`src/angelscript-tools`） | 行号/自定义起始/高亮/1-based 切片的 AS 代码 | Agents.md 代码高亮唯一运行时 | tested |
| `<$codeblock language="angelscript">` | 核心 widget | 普通嵌入 AS 代码块 | 同上 | tested |
| Markdown 警示块（note/warning/tip） | Markdown More | 提示/警告/要点 | product-sources 已选，pastel admonitions | tested |
| 线性图标（109） | `line-icon-registry` | 图标 | `wiki-unified-line-icons` | tested |
| `<<as-doc-link "logical/key" "caption">>` | procedure | 语言无关文档链接 | Agents.md 文档链接规范 | tested |
| `as-doc-status-label` | procedure | 状态徽章渲染 | 既有 | tested |

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
