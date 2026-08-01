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

产品 Tag 采用一次性硬迁移，不提供 alias、双读或兼容 tiddler；`$:/ASWiki/**` 系统 tiddler 与 `AS/Docs/**`、`AS/Showcase/**` 内容标题不在迁移范围。十五个正式主题 Tag 使用 UE 风格 PascalCase：`Start`、`Language`、`UnrealLanguage`、`TypeObjectReflection`、`UnrealCore`、`CompileModulePreprocessor`、`HotReload`、`EditorIdeDebugging`、`TestingDiagnosticsRelease`、`RuntimeJitVm`、`BindingsUhtExtensions`、`ArchitectureMaintenance`、`TopicsIntegrations`、`ReferenceDifferencesVersion`、`ShowcaseLab`；kebab-case `as-topic-key` 继续作为稳定数据键，主题定义通过该字段发现。读者导航定义通过 `as-nav-key` 发现，不再用 `ReaderNav` Tag。只有有真实层级含义的 `Showcase/*` 保留产品命名空间；`ReferenceDifferencesVersion/Hazelight` 是登记过的主题子 Tag。每个被引用 Tag 必须有带 `caption`/`description` 的同名定义，多级 Tag 的父定义必须存在，定义关系不得成环。`Showcase/Detail` 与 `Showcase/LayoutExperiment` 是补充页面分类，不标记为 `Showcase` 子级稳定性层；稳定性层仍只有 Base、Pattern、Lab。

### D6. 父仓库/子模块分离提交（对齐 Agents.md §Git and Host Workflow）
Wiki 内容改动在 `Wiki/` 内完成、测试、提交并推送到 Wiki 远端；回到父仓库后用 `git diff --submodule=log` 复核，仅暂存 `Wiki` gitlink 与相关 host 文档，父仓库单独提交。禁止在父仓库 `git add .`。OpenSpec 记录只在父仓库 `openspec/`。

### D7. 源码解释实验采用不可侵入、追加式历史
`comparison-artifacts/code-explanation/` 是选型实验室，不是正式 Wiki 组件目录。编号 HTML 只允许追加；新的表达方向不得覆盖、改写或删除已经交付的实验。外部参考、模式归纳和历次判断记录在 `research/code-explanation/`，正式组件选型前不进入 `components-catalog.md` 的 `built` / `tested` 状态。

“保持源码连续”同时约束文本、DOM 和几何：源码根节点只包含按原顺序排列的代码行；note、详情和 connector 必须位于独立兄弟层或覆盖层；展开、固定、隐藏 note 或重算连线不得改变任何代码行的位置和尺寸。边注关系只表达“对应”，默认使用低对比、无箭头的细线或范围括线，不借用流程箭头暗示执行方向。

外部案例只提供设计证据，不形成运行时依赖。研究页保存直接来源、访问日期、必要的局部截图、自主归纳的优点/局限和采纳判断；不复制整篇文章或外部实现。参考画廊加载时必须离线，不主动请求第三方资源。

### D8. 依赖型源码解释实验必须可归因、可离线、可拆分
`14`–`17` 继续沿用 `13` 的“亮色代码纸 + 内嵌短 note + 兄弟覆盖层”方向，但把问题拆成三个互不混淆的职责：源码与注释的 lane 布局、源码锚点到 note 的关系线、短 note 展开后的长解释定位。实验允许引入依赖，但每个单文件 HTML 必须把选定版本的运行时代码内联，记录 `name | version | license | upstream | inlineBytes`，加载时不得发起外部请求。

依赖只替换它真正擅长的一层：
- 原生 DOM Range + SVG 仍是零依赖基线，负责精确测量源码 token/range 和低对比关系线。
- LinkerLine 只验证滚动容器内的 SVG 生命周期、重定位和正交连接；不让它决定 note 布局。
- Perfect Arrows 只提供曲线控制点；实验刻意不画箭头头部，避免把“解释对应关系”误读为执行流程。
- Floating UI 只负责长解释的 `flip` / `shift` / `autoUpdate`；短 note 的常驻位置仍由源码空白 lane 分配器决定。

生产候选不得因为“用了库”就整体移植。当前优先评估的组合是“原生源码测量与关系线 + 必要时用 Floating UI 定位长解释”；LinkerLine 和 Perfect Arrows 保留为有价值的对照证据。后续若修改 TW AngelScript 插件，必须在 `components-catalog.md` 中重新声明生产形式与依赖边界，并补最小测试 tiddler、交互测试、许可证/版本固定和清理生命周期验证；本轮只交付 OpenSpec 与独立 HTML，不改 `Wiki/`。

### D9. 原生平台能力实验分别验证“文本范围”和“详情定位”
`18`–`19` 不再继续比较同类连线库，而是在 `13`–`17` 的连续源码、兄弟覆盖层和短 note 常驻约束上，分别验证两个可独立采用的 Web Platform 能力：
- `18` 使用 CSS Custom Highlight API 管理一个或多个原生 `Range`，hover/focus/click note 时精确高亮被解释的 token/range；annotation 不得向源码根节点插入额外 wrapper。浏览器不支持 `CSS.highlights` 时，回退为基于同一 `Range.getClientRects()` 的兄弟 overlay，仍不得污染源码 DOM。关系线继续使用原生 SVG。
- `19` 使用 CSS Anchor Positioning 把 top-layer Popover 详情锚定到常驻短 note；短 note 与源码关系线仍由原生测量和 SVG 负责。浏览器缺少 anchor positioning 或 Popover API 时，回退为显式的 fixed-position 详情层，并在页面内公开当前 capability mode，不能因为兼容回退而改变代码行几何。

两页均使用仓库内真实 AS/C++ 片段，保持单文件、离线、无第三方请求；交互只在对应 note 上强化精确范围/关系线，点击固定详情，`Escape` 关闭。验收必须覆盖源码文本一致性、源码根节点结构纯净、交互前后代码行矩形稳定、纯源码复制、桌面、390px 内部横向滚动、键盘、reduced-motion、capability/fallback 审计。

### D10. Experiment 19 的交互方向进入 Wiki 原生生产组件
Experiment `19` 被选为生产交互方向，但不会把独立实验页或其中的演示实现整页复制进 Wiki。生产形式由语言通用的 `<$annotated-code>` 基座、保持既有 AngelScript 行为并固定使用 `angelscript` 高亮的 `<$angelscript-code>`，以及二者可直接包含的 `<$code-note>` 组成；不增加外部运行时依赖。

源码仍只由父组件的 `code` 属性提供，widget body 只包含 note 定义。note 用显示行号 `line`、可选的包含式结束行 `toLine` 建立范围关系，并可用精确子串 `match` 与 1-based `occurrence` 缩小到 token/子串。正式组件继续把 TiddlyWiki 官方 Highlight 管线作为唯一高亮器；note、范围标记、端口、SVG connector 和详情都是 `<pre>/<code>` 之外的兄弟层，不进入或重排源码 DOM。

桌面端只在代码表面内部保留克制的注解 lane，不形成页面级第二正文列。短注默认常显；hover/focus 只激活对应范围、微型端口、connector 和短注，click 才打开可渲染 WikiText 的完整详情。原生 DOM `Range` 负责从 Highlight 产出的文本节点测量源码范围，原生 SVG 负责关系线；详情优先采用原生 Popover 与 CSS Anchor Positioning，并为 anchor positioning 与 Popover 分别提供等价的手动定位/披露回退。

窄屏必须退化为源码后的顺序注解且不造成文档级溢出；打印必须静态展开详情并隐藏交互装饰；reduced-motion 必须关闭过渡。即使移动端视觉精修不是优先目标，多实例隔离、TiddlyWiki refresh/destroy 时的 observer/listener/RAF/详情清理仍是生产要求。P02、P03、P04 是这一生产边界的读者证据页，保留源码路径与 revision 证据。`01`–`19` 的既有编号实验继续作为不可变研究历史，生产迭代不得回写它们。

### D11. 恢复 Experiment 19 的可点击线索并扩展为专用解释组件族
生产验证确认详情披露机制本身可用，但第一版把 experiment `19` 的编号、浅色表面、阅读提示和完整点击热区削弱后，读者无法可靠判断短注可以展开。本轮把编号定义为有语义的源码阅读顺序标识：可展开短注使用至少 `44px` 的完整按钮热区、低对比边框/底色、克制的展开符号与一次性阅读提示。允许极弱表面层级，但仍禁止高饱和填充、厚重阴影、胶囊 badge 或让 note 成为比源码更强的页面卡片。

后续表达采用“源码居中、流程辅助”的单主阅读轴：源码连续显示且可纯净复制，流程紧随源码，不恢复页面级左右双栏。桌面 hover/focus 只预览关系，click/Enter/Space 固定关系并披露详情，Escape/外部点击解除；窄屏、打印和 reduced-motion 保留完整文本语义。

四个稳定 Pattern 使用专用 widget 家族而非继续扩大 `<$annotated-code>`：生命周期、状态迁移、调用序列和数据流各有独立外层/子项合同，但复用同一源码定位、关系选择和详情披露基础。AST/VM Lab 使用 `schemaVersion: 1` 的 revisioned JSON data tiddler；数据必须声明 fidelity，未验证的原始 AST/opcode 不得冒充捕获结果。第一批证据页为 P07–P10 与 L01–L02；P07–P10 可进入 mapped，L01–L02 保持 experiment。

### D12. 行范围只标记源码墨迹，关系线永久位于源码下层
未声明 `match` 的 `line` / `toLine` 仍表达完整行范围，但视觉 range mark 必须逐行裁剪到首尾非空白字符；缩进、行尾空白和范围内的空行不得生成可见背景或下划线。显式空行注解可以保留不可见的几何锚点与 connector 语义，但不得伪造源码墨迹。精确 `match` 的偏移、源码 DOM、复制和行几何保持不变。

connector 在 idle、hover、focus 和详情打开状态下都位于 Highlight 源码下层。交互只改变当前关系的线条颜色与透明度，不得再提升 connector 的 z-index；几何上穿过源码区域是允许的，但源码字形必须始终绘制在线条之上。idle range 只保留近乎不可见的浅灰蓝填充且不显示下划线，hover/focus/open 才显示对应范围的下划线和增强填充。详情不再提供独立的 `×`，通过再次激活、外部点击、`Escape` 或选择另一条关系关闭。

2026-08-01 的桌面与 390px 截图审计确认：多行范围把 note 放在范围首行却从最后一个 mark 出线、精确 match 从行中部出线、正式 flow 忽略逐 note placement、反向曲线强制右移控制点，以及 border shorthand 退化为 `currentColor`，共同造成了长线穿字、top note 错误入边和常驻深色下划线。后续布局与 connector 必须共享同一条关系的实际 placement、source mark 和端口方向；规则集中记录于 `source-annotation-layout-rules.md`。

### D13. Connector 路由使用可替换的延迟求解模块，SVG 仍由产品拥有

本轮允许正式源码注解精确依赖 `obstacle-router@0.1.2`，但只把“矩形障碍之间的批量路径求解”交给该库。源码 Range/墨迹测量、note 放置、端口选择、路径平滑、SVG DOM、交互状态和 fallback 仍由 `angelscript-tools` 拥有。库必须封装在独立的 TiddlyWiki `library` 模块中；主 widget 只在至少一条无法安全水平直连、且允许在端点包围框内求解的关系存在时执行该模块，离线单文件不得产生运行时网络请求。

同排且 note 边缘覆盖源码锚点 Y、连接通道又不穿过源码墨迹或其他 note 时，connector 直接把终点吸附到完全相同的 Y 并输出单条水平线。符合有界求解条件的其余关系把非空源码墨迹、源行选中范围两侧文本和其他 note 建成矩形障碍，在一个代码块的一次 transaction 中批量求解。正交结果只作为安全骨架；项目代码移除共线点并以有界三次贝塞尔圆滑转角。端点必须先切出小出口；返回点超出端点包围框、几何无效或求解失败时使用仍在源码下层的 fallback。top shelf 的端点组合按既有“不得 overshoot”契约直接使用 fallback，不进行注定被拒绝的求解。

路由结果以量化后的几何签名缓存；hover、focus、详情开关和重复 ResizeObserver 通知不得重新求解。普通规模同步处理，超过 16 条复杂关系或 160 个障碍时在首屏源码/note 渲染后用 idle task 求解。Router 图对象在提取路径后释放，SVG 层按 `noteId` 复用 path。性能基线和 bundle 体积记录在 `benchmarks/annotation-routing-2026-08-01.md`。

`<$code-note>` 继续只有一种作者合同：无 `detailTiddler` 的 body 是内联短详情；存在 `detailTiddler` 时，body 是缺失目标的 fallback，目标 tiddler 是主要预览与独立 Wiki 页面。后一种 note 在折叠状态显示低对比 `Wiki` 文本标记，展开面显示“Wiki 详情预览”语义和“在 Wiki 中打开完整解释”内部链接；不恢复序号、披露箭头或关闭 `×`。

## Risks / Trade-offs

- [矩阵与真实元数据漂移] → 每批推进后用只读 `grep` 重新统计并回填矩阵；把统计口径写进 `tasks.md §1`。
- [表现力过度工程/造无谓 widget] → D4 的优先级规则 + `components-catalog.md` 的“边界依据”列作为门槛，评审时对照。
- [长期 change 永不收敛] → `tasks.md` 分节 + 目标状态列使进度可量化；允许维护者随时重排，但每阶段以 `test:fast`/`test:feature` 收口。
- [子模块与父仓库提交耦合出错] → 严格按 D6 分离；本次会话完全不动子模块，先把记录立起来。
- [英文对照滞后被当作现行] → 遵循 D3 中文优先与英文 fallback 通知规则，不让 stale 英文冒充现行。
- [实验历史被后续选型覆盖] → 为既有 HTML 固定 SHA-256 基线，新验证器在交付前检查存在性和哈希。
- [边注重新变成第二正文] → 默认只常显短注，详情按 hover/focus/click 展开；视觉验收同时检查源码层级和源码行几何稳定性。
- [外部参考造成发布或版权耦合] → 截图仅保留在 OpenSpec 内部研究记录中，采用必要局部、明确来源；不进入 Wiki、插件或发布包。
- [依赖库遮蔽真实边界] → 每个实验只把一个狭窄职责交给库，并在页面审计中公开版本、许可证、来源与内联体积；生产选型按职责拆分，而非整页照搬。
- [重排后连接器持有失效锚点] → 锚点层重建前先销毁依赖库实例，再基于新端点重建；Floating UI 的 `autoUpdate` 和连接器实例都必须提供显式 cleanup。
- [超长 C++ 行把 note 推出首屏] → 源码纸张可保留内部横向滚动，桌面 note lane 则按当前可视代码纸宽度分配，并用碰撞审计保证不覆盖源码墨迹。
- [CSS Custom Highlight / Anchor Positioning 在旧内嵌 Chromium 不可用] → 两页先做能力检测并提供不污染源码 DOM 的 overlay/fixed-position 回退；只有实际 Wiki 运行环境验证通过后，原生能力才能进入生产组件边界。
- [Popover top layer 脱离代码纸裁剪与层叠上下文] → 详情仅由显式点击打开，使用 anchor/fallback 定位约束在 viewport 内，`Escape` 与切换 note 都关闭旧详情；常驻短 note 不依赖 top layer。
- [源码快照更新后显示行号或 match 锚点失效] → 锚点解析失败时必须把短注和详情保留在“未定位注解”区并显式标错，绝不猜测最近行或连接到错误源码；P02–P04 同时记录源码路径与 revision 供维护者复核。
- [同页多 widget 的 anchor name、Popover ID 或活动状态碰撞] → 每个实例生成局部唯一 ID/anchor name，查询、outside-click 和披露状态都限制在所属代码块，测试至少覆盖两个同时存在的实例。
- [长源码与约 14rem 注解 lane 争夺宽度] → lane 只在可容纳它的代码表面内启用，源码保持 `white-space: pre` 和内部横向滚动；空间不足时移除 connector/range overlay，把 note 按源码顺序放到代码后。
- [浏览器对 Anchor Positioning、Popover、Range 几何的能力不同] → 启动时分别检测能力，原生路径与手动 fixed-position/非-Popover 路径共享相同状态机、ARIA、关闭语义和源码范围解析，不让 fallback 改变读者结果。
- [TiddlyWiki refresh 后残留 observer、listener、RAF 或 top-layer 详情] → widget refresh/destroy 前关闭披露、取消 RAF、断开 observer 并移除自有 listener；重复刷新与销毁测试验证没有跨实例残留。
- [硬重命名导致外部保存的旧 Tag 链接失效] → 接受这项一次性断裂以避免长期维护冗余命名；站内数据、过滤器、生成器和测试必须同批迁移，内容契约拒绝任何 `ASWiki/*`、`Docs/*` 或 `ReaderNav` 产品 Tag 回流。

## Migration Plan

不引入运行时迁移器或兼容双读。推进节奏：先建记录 → 分批实现组件（`tasks §2`）→ 产品 Tag 源码硬迁移并完成契约验证 → 结构复核（`§3`）→ 内容分批推进（`§4`，维护者按矩阵优先级驱动）→ 每批与阶段性验证（`§5`）。回滚：仅按显式确认的路径回退，禁用 `git checkout -- .` / `git reset --hard`。

## Open Questions

- `wiki-document-expression-components` 是否与既有 `wiki-document-experience-integration` 能力有重叠需要改为 MODIFIED？（落 specs 前以 `openspec show wiki-document-experience-integration` 复核；当前判断为新增独立能力。）
- 内容分批的首批优先级（按 `nav-group` 还是按 reviewed 缺口最大 topic）留待维护者在 `doc-status-matrix.md` 指定。
