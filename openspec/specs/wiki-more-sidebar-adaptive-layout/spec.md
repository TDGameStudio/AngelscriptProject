# wiki-more-sidebar-adaptive-layout Specification

## Purpose
TBD - created by archiving change improve-wiki-more-sidebar-adaptive-layout. Update Purpose after archive.
## Requirements
### Requirement: More 使用状态感知的有效侧栏宽度

桌面 Wiki SHALL 将普通侧栏的持久化基础宽度与当前布局的有效侧栏宽度区分开。More 面板激活时，有效宽度 SHALL 为基础宽度与 `clamp(360px, 34vw, 460px)` 中的较大值；其它主侧栏标签 SHALL 继续使用基础宽度。侧栏、story river 与 resize slider SHALL 使用相同的有效宽度边界。

#### Scenario: More 扩宽而普通标签恢复基础宽度
- **WHEN** 用户在 1440px 宽桌面打开 More，且基础侧栏宽度为 264px
- **THEN** 侧栏右边界与 story river 左边界 SHALL 对齐在 460px 左右
- **AND** 用户切换回目录后，两者 SHALL 恢复到 264px 左右
- **AND** 未发生 slider 交互时持久化 `sidebarwidth` SHALL 保持 264px

#### Scenario: 用户宽侧栏优先于 More 最小宽度
- **WHEN** 用户基础侧栏宽度为 520px 并打开 More
- **THEN** 有效侧栏宽度 SHALL 保持 520px
- **AND** More 内容 SHALL 不产生横向溢出

### Requirement: More 状态下的 slider 与真实边界一致

桌面 resize slider SHALL 使用当前有效侧栏宽度更新位置、`aria-valuenow` 和最小可调宽度。More 激活时 slider 的最小值 SHALL 不低于当前 More 最小宽度；正常侧栏时 SHALL 恢复既有 240px 最小值。仅用户主动 pointer 或 keyboard 调整 SHALL 写回持久化基础宽度。

#### Scenario: More slider 的键盘状态与边界一致
- **WHEN** 用户以 264px 基础宽度打开 More 并聚焦 resize slider
- **THEN** slider 的 `aria-valuemin` 与 `aria-valuenow` SHALL 均不低于当前 More 最小宽度
- **AND** ArrowLeft 与 Home SHALL 不把视觉边界移动到 More 最小宽度之内
- **AND** 用户离开 More 且未调整 slider 时，普通侧栏 SHALL 恢复 264px

### Requirement: More 保留原生信息架构并使用组件化阅读样式

More SHALL 保留 11 个原生分类及其顺序、tabs 行为、标签 tiddler 字段、tag popup 生命周期和插件动作。桌面主题 SHALL 以左对齐分类列、单一分隔线、可滚动内容区和局部链接规则呈现 More，不得让全局正文链接的粗体、底边线或 `break-all` 泄漏到 More 长列表。More 标签及原生 `$:/TagManager` 表格标签 SHALL 使用与正文一致的 4px 方角组件；有效的 tag `color` 字段 SHALL 生成低饱和色彩变体，无效或缺失字段 SHALL 使用中性基线。探索树 SHALL 仅通过样式成为紧凑目录行，不得更改原生 reveal 展开状态或分类数据。

#### Scenario: 所有 More 分类仍可使用
- **WHEN** 用户打开 More
- **THEN** 全部、最近、标签、缺失、草稿、孤立、类型、系统、默认、探索和插件 SHALL 以原顺序存在且可切换
- **AND** 默认长列表 SHALL 可以纵向滚动且没有横向页面溢出

#### Scenario: 配置标签色、探索树和插件卡片保持可读
- **WHEN** 标签具有有效颜色字段并在 More 标签面板中显示
- **THEN** 标签 SHALL 使用统一方角几何和由该字段导出的低饱和变体
- **AND** 未设置颜色的标签 SHALL 使用中性基线
- **AND** 探索树的图标、名称与计数 SHALL 以紧凑行呈现，并保持原生展开行为
- **AND** 插件列表 SHALL 以可读的两列卡片布局显示而不溢出

### Requirement: 控制栏 Page Actions 使用更多操作语义

紧凑控制栏的 `$:/core/ui/Buttons/more-page-actions` SHALL 使用产品自有的 overflow 图标，而不是下拉箭头。More 面板激活时，首页图标 SHALL 不得因当前 tiddler 是首页而与 More 同时呈现激活态；原生 Page Actions 按钮及其菜单行为 SHALL 保持不变。

#### Scenario: Page Actions 图标与 More 状态清晰
- **WHEN** 首页条目打开并激活 More
- **THEN** 控制栏 Page Actions SHALL 渲染 overflow 图标
- **AND** More 主标签的激活态 SHALL 是唯一的侧栏模式激活指示
- **AND** 点击 Page Actions 后 SHALL 仍打开原生更多操作菜单
