## Why

正文 tiddler 的工具栏按钮虽然声明了 32px 的最小尺寸，却继续继承标题的 39.48px 行高。鼠标悬浮时，背景因此成为窄而高的色块；在约 150% 显示比例下约为 48×59px，和相邻的轻线框图标不成比例。独立原型已完成视觉审阅，现将获批准的紧凑方形方案限定应用到生产桌面主题。

## What Changes

- 新增一个零依赖的单文件 HTML，对比当前继承标题行高的工具栏与已选定的紧凑方形工具栏。
- 记录当前的 32×39.48px / 24px 图标 / 0px 间距基准，以及候选的 32×32px / 20px 图标 / 2px 间距规则。
- 提供 hover、pressed、键盘焦点和窄屏堆叠的可审阅状态，而不模拟或替换任何 TiddlyWiki 动作。
- 为原型添加浏览器回归契约，并记录视觉批准后的生产主题任务。
- 在 `desktop-refinement.tid` 中仅为桌面正文标题栏的直接工具按钮应用 32×32px、20px 图标、2px 间距、5px 圆角与 140ms 色彩反馈。
- 为实时 Wiki 添加回归契约，确保 More 下拉菜单行的布局和线框图标对齐不受影响。

## Capabilities

### New Capabilities

- `wiki-tiddler-toolbar-hover-prototype`: 提供独立的正文工具栏 hover 几何对比原型与可复核的状态契约。

### Modified Capabilities

- `wiki-tiddler-toolbar-hover-prototype`: 在原型获批准后，桌面正文标题栏的直接操作采用已审阅的紧凑方形组；移动端与 More 菜单保持原有行为和布局。

## Impact

- Host repository: the new OpenSpec record and its standalone comparison artifact.
- Wiki submodule: one desktop theme refinement and its Playwright coverage; no action tiddler, menu markup, generated icon asset, vendor, or publication source changes.
- No AngelScript public API, WikiText syntax, runtime dependency, or packaged Wiki output changes.
