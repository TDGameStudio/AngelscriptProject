## Context

`Wiki/comparison-artifacts/new_review.html` 是一次只改导出 HTML 的视觉实验。实验覆盖层在 TiddlyWiki 启动后置于运行时样式之后，验证了以下结果：

- 一级侧栏标签和 More 的 11 个原生分类保持不变；不需要修改 `tabsList`、`$:/core/macros/tabs`、`$:/core/ui/SideBar/More` 或 `$:/state/tab/moresidebar`。
- More 在桌面端扩宽至 `clamp(360px, 34vw, 460px)` 后，分类、长列表、插件卡片与树形浏览器均可读；普通侧栏仍为 264px。
- 全局 `a.tc-tiddlylink` 的粗体、底边线与 `word-break: break-all` 是 More 长列表逐字断行的直接来源，必须在 More 内容容器内收回，而不能重写全局正文链接主题。
- 正文画布、标题栏工具栏和 More 图标方向均完成了实验验证；本次只迁移 More 与它直接依赖的控制栏/slider，正文主题仍保留在实验文件中。

正式 Wiki 的左栏布局由 `left-sidebar-layout.tid` 决定，拖拽由 `left-sidebar-resizer.ts` 决定。两者目前直接读取持久化的 `$:/themes/tiddlywiki/vanilla/metrics/sidebarwidth`。More 临时扩宽若不进入同一宽度模型，story river 与 resizer 会停在旧边界；若直接写回该指标，又会把未交互的临时 More 宽度误当作用户偏好。

## Goals / Non-Goals

**Goals:**

- 将基础侧栏宽度与当前布局实际使用的有效宽度分离，并让 CSS 与 slider 共享后者。
- More 打开时以 `max(基础宽度, clamp(360px, 34vw, 460px))` 提供足够空间；退出 More 时自动回到未变更的基础宽度。
- 用户在 More 内主动拖拽或键盘调整时，slider 以当前有效宽度为起点和最小值，明确地保存该用户操作；未操作时不写入持久化宽度。
- 以组件作用域重写 More 的展示规则，保留原生数据、分类、标签颜色、弹窗和操作逻辑。
- 把 Page Actions 的控制栏图标改为真正的 overflow 图标，并让 More 打开时的首页状态不与当前面板竞争。

**Non-Goals:**

- 不修改 TiddlyWiki 核心 More macro、tabs macro、More 分类数据、标签 popup 生命周期或 WikiText 内容。
- 不迁移实验副本的正文卡片、正文排版或标题栏工具栏样式。
- 不新增第二个持久化“More 宽度”配置，也不改变移动端抽屉、滑块触屏禁用逻辑或发布流程。

## Decisions

### 使用主题级有效宽度变量，而非为 More 直接写死多个 CSS 属性

在桌面主题中引入 `--as-layout-sidebar-width`。它默认回退到 `--angelscript-sidebar-width`（拖拽期间）或 Vanilla `sidebarwidth`（持久值）；仅当 `.tc-page-container:has(.tc-more-sidebar)` 存在时，改为基础宽度和 More 最小宽度的 CSS `max()`。

左侧滚动栏、story river、resize-area 和静态模板都读取这一变量。这样正常标签的宽度路径保持不变，More 只改变一个输入值，避免将同一个条件复制到多个 `width`、`margin-left` 和 `left` 声明中。

选择该方案而不是在 More 里直接覆盖 `.tc-sidebar-scrollable`、`.tc-story-river` 和 handle 的像素值，是因为后者会绕过用户自定义宽度和 slider 的临时 CSS 变量，形成三个可能不同步的边界。

### slider 将实际边界视为当前可操作宽度

`left-sidebar-resizer.ts` 保留一个持久化的基础宽度 tiddler。它新增“More 是否激活”和“More 当前最小宽度”计算，使用与 CSS 相同的 360px、34vw、460px 规则。More 激活时：

- `aria-valuemin`、拖拽下限、Home 键和 `aria-valuenow` 使用有效的 More 最小值；拖拽手柄始终位于真实的 story 边界。
- 没有拖拽或键盘事件时，不写入基础宽度；离开 More 后立即还原之前保存的普通侧栏宽度。
- 用户主动在 More 中调整时，保存调整后的宽度。这是明确的用户偏好操作，而不是临时面板扩展的副作用。

选择这个方案而不是隐藏 More 状态下的 slider，是为了保留现有鼠标与键盘调整能力；选择它而不是新增独立 More 偏好，是为了避免一个用户无法发现且难以维护的第二宽度状态。

### More 样式集中为一个组件层

`compact-control-rail.tid` 成为桌面 More 组件的唯一视觉入口：84px 左对齐分类列、单一 1px 分隔线、可滚动内容区、内容类型特定规则和组件 token。`desktop-refinement.tid` 中旧的 More 分隔线/按钮覆盖会移除，避免两个文件竞争同一元素。

More 内容仅局部撤销全局正文链接泄漏；标签不覆盖其原生 inline 色值，插件卡片以网格显示，树形浏览器保留核心结构。由此避免为了美化 More 而影响正文、标签 popup 或其它侧栏页。

### 图标作为资源迁移，而非 CSS 伪元素

Page Actions 使用新的产品自有 `more` SVG tiddler，并在 `sidebar-icon-map.tid` 中替换原先错误的 `chevron-down` 映射。CSS 只负责图标的尺寸与状态颜色。该方式保留语义、可访问名称和 native button/menu 绑定，并避免实验用 CSS 伪元素成为生产实现。

## Risks / Trade-offs

- [More 与基础宽度在临界断点来回切换] → 仅在现有桌面断点生效；验证 960px、1440px、以及移动抽屉，且 reduced-motion 下不做过渡。
- [用户在 More 内把宽度拖到最小值以下时感到手柄不动] → slider 的最小值在 More 激活时同步提高，ARIA 值与视觉边界一致。
- [More 链接局部重置破坏标签色或 popup] → 只定位 `.tc-more-sidebar .tc-tab-content` 的链接；原生标签背景和 portal popup 不改色，并以现有标签测试回归。
- [重复 More CSS 继续产生层叠债] → 删除 `desktop-refinement.tid` 的重复 More 分隔线规则，并在测试中断言单一可见 divider 与组件宽度。

## Migration Plan

1. 在 OpenSpec 中保留本设计与实验结果，作为实验副本的正式记录。
2. 先增加会失败的 Playwright 用例，描述有效宽度、slider/ARIA、More 分类和图标语义。
3. 实现共享有效宽度变量、slider 动态下限、集中 More 样式和 icon resource mapping。
4. 运行受影响的 Playwright、TypeScript 检查、lint、source-boundary 和构建验证；检查无控制台错误与移动端抽屉。
5. 如需回滚，移除新的有效宽度变量/More 组件样式/图标映射并恢复被删的局部规则；持久化基础宽度格式保持不变，因此不需要数据迁移。

## Open Questions

无。用户已认可 More 的视觉方向并明确要求这次按共享宽度模型重构；正文整体主题留待独立迁移。
