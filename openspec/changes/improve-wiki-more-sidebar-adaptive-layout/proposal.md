## Why

`comparison-artifacts/new_review.html` 的隔离实验验证了“More 打开时按状态扩宽”的方向：它能让原生的全部、系统、默认、探索与插件面板获得可读宽度，同时保留现有 TiddlyWiki 信息架构。但正式 Wiki 目前让侧栏、正文和左侧 resize slider 直接读取同一个持久宽度；若只迁移 CSS 扩宽规则，拖拽手柄会与实际边界脱节，并可能把临时的 More 宽度错误持久化为普通侧栏宽度。

现在将已认可的 More 视觉规则正式迁移，并把宽度计算收敛为一个主题/交互共享的“有效侧栏宽度”，避免继续叠加局部覆盖和 `!important` 补丁。

## What Changes

- 记录 `new_review.html` 实验中的视觉结论、已验证行为和未迁移边界，作为后续主题工作可复查的设计记录。
- 在桌面端为原生 More 面板引入状态感知的有效侧栏宽度：More 使用 `max(用户基础宽度, clamp(360px, 34vw, 460px))`；其它主侧栏标签继续使用用户基础宽度。
- 将左侧栏、正文 story river、resize slider、其可访问性值与拖拽边界统一到同一个有效宽度模型；More 未交互时不改变用户保存的普通侧栏偏好。
- 将 More 的分类栏、内容栏、长列表、插件卡片、标签管理入口和树形条目收敛为主题组件规则，移除现有 42px 分类列和跨文件的重复 More 分隔线规则。
- 解除全局正文链接规则在 More 内造成的粗体、下划线和 `break-all` 泄漏；保留原生 tiddler 链接、标签、插件、空态和弹窗行为。
- 将紧凑控制栏的 Page Actions 图标从“下拉”改为语义正确的“更多操作”图标，并在 More 打开时消除首页与 More 同时呈现激活态的歧义。
- 扩展 Playwright 覆盖，验证动态宽度、slider 拖拽/键盘操作、全部 11 个 More 分类、长列表、原生标签色、插件卡片、移动端抽屉和无横向溢出。

## Capabilities

### New Capabilities

- `wiki-more-sidebar-adaptive-layout`: 定义 More 面板的状态感知宽度、共享 slider 契约和组件化内容呈现。

### Modified Capabilities

- `angelscript-wiki-theme`: 扩展主题在桌面左侧栏、More 内容层级、控制栏图标状态与响应式行为上的要求。

## Impact

- Wiki 子模块：`src/angelscript-theme/`、`src/angelscript-tools/navigation/left-sidebar-resizer.ts`、控制栏图标资源/映射，以及产品级 Playwright 测试。
- 宿主仓库：本变更目录中的实验记录、设计、规格和任务清单。
- 不修改 TiddlyWiki 的 `tabsList`、`$:/core/macros/tabs`、`$:/core/ui/SideBar/More`、More 的 11 个原生分类、WikiText 内容模型或发布流程。
- 本轮不迁移 `new_review.html` 中的正文卡片、正文排版和标题栏工具栏整体主题；它们保留在实验副本中等待独立验收。
