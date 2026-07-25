# 隐藏侧边栏“最近”标签实施记录

## 决定

全局隐藏 `$:/core/ui/SideBar/Recent`，但保留其 WikiText、样式和历史数据渲染实现。实现方式是移除该 tiddler 的 `$:/tags/SideBar` 标签，而不是使用 CSS `display: none` 或删除 tiddler。

这使核心侧边栏不再收集、渲染或聚焦“最近”标签；源码仍可由后续需求重新注册。默认可见顺序为：目录、开启、工具、更多。

## 影响面

- `Wiki/src/angelscript-tools/navigation/sidebar-recent.tid`：取消侧边栏注册，保留内容。
- `Wiki/src/angelscript-tools/navigation/sidebar-open.tid`：移除对不可见“最近”的空状态引导。
- `Wiki/tests/playwright/product/sidebar/`：更新标签数量、顺序和交互样式断言；移除只服务于已隐藏入口的“最近”面板场景。
- `Wiki/Agents_ZH.md`、`Wiki/Agents.md`：记录当前的产品侧边栏构成。

## 验证

1. 先运行收紧后的单个侧边栏测试，确认旧产品会因仍显示“最近”而失败。
2. 实施 tiddler 和文案调整后，运行 `node scripts/run-product-tests.mjs feature sidebar`。
3. 运行本次改动涉及的 TypeScript 检查和 ESLint。按照维护规则，不运行完整 integration、release 或 verify。
