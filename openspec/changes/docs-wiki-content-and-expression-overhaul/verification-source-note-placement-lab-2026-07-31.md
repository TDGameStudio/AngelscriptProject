# Source Note Placement Lab 验证记录（2026-07-31）

## 范围

本轮只新增四个可移除的 P04 源码注解位置实验与一个临时索引，通过 `experimentalLayout="auto|top|reserved|after"` 显式启用。未给出有效实验属性的生产组件继续使用原有 DOM、编号、rail/after-code 选择与交互。

四页统一读取：

- tiddler：`AS/Showcase/Source/P04-ScriptGameInstanceSubsystem`
- 路径：`Plugins/Angelscript/Source/AngelscriptRuntime/Subsystem/ScriptGameInstanceSubsystem.h`
- revision：`dc99986febf1f0911a3ebfdc6d987cc3c0594907`
- 显示范围：17–56

## TDD 证据

### RED

```powershell
& npm.cmd exec --yes --package node@24 --package pnpm@11.8.0 -- pnpm exec playwright test tests/playwright/product/code/annotation-layout-lab.spec.ts
```

结果：`6 failed`。六项都在等待 `.angelscript-code--layout-lab` 时得到 0 个元素，原因是实验 tiddler 和 opt-in 组件分支尚不存在；属于预期功能缺失，不是测试语法或环境错误。

```powershell
& npm.cmd exec --yes --package node@24 --package pnpm@11.8.0 -- pnpm exec playwright test tests/playwright/product/document/document-content-foundation.spec.ts --grep "keeps Showcase tiers discoverable"
```

结果：`1 failed`。失败点是 `.as-annotation-placement-lab-entry` 不存在，符合预期。

### GREEN

```powershell
& npm.cmd exec --yes --package node@24 --package pnpm@11.8.0 -- pnpm exec playwright test tests/playwright/product/code/annotation-layout-lab.spec.ts
```

结果：`6 passed`。覆盖无视觉/无障碍序号、Auto 的长行 Top 选择、Top gutter 与源码几何、Reserved 独立滚动与 terminal 终点、After Code、四种 390px 回退。

```powershell
& npm.cmd exec --yes --package node@24 --package pnpm@11.8.0 -- pnpm exec playwright test tests/playwright/product/document/document-content-foundation.spec.ts --grep "keeps Showcase tiers discoverable"
```

结果：`1 passed`。Lab catalog 仍是 11 行，并可从独立临时入口打开索引和四页。

## 回归与静态检查

```powershell
& npm.cmd exec --yes --package node@24 --package pnpm@11.8.0 -- pnpm run check
```

结果：PASS。

```powershell
& npm.cmd exec --yes --package node@24 --package pnpm@11.8.0 -- pnpm exec eslint src/angelscript-tools/index.ts tests/playwright/product/code/annotation-layout-lab.spec.ts tests/playwright/product/document/document-content-foundation.spec.ts
```

结果：PASS，0 error / 0 warning。首次运行的 17 个 dprint warning 已由精确文件范围的 `eslint --fix` 机械格式化后清零。

```powershell
& npm.cmd exec --yes --package node@24 --package pnpm@11.8.0 -- pnpm run test:feature code
```

结果：`42 passed`。其中既有 annotated-code 默认编号、rail、after-code、Popover/fallback、refresh/destroy、print 与 reduced-motion 回归全部通过，新 Lab 为 6 项。

```powershell
& npm.cmd exec --yes --package node@24 --package pnpm@11.8.0 -- pnpm run test:document-content
```

结果：`48 passed`。精确 42 项 Showcase taxonomy/catalog、映射页面、正式文档内容契约和 source registry 全部通过；临时页面没有新增 Showcase ID 或正式文档条目。

```powershell
& npm.cmd exec --yes --package node@24 --package pnpm@11.8.0 -- pnpm run test:feature document
```

结果：`22 passed / 2 failed`。本轮新增 Lab 导航用例通过。两项失败都可独立重现，且目标为本轮未修改的正式文档内容：

1. `orders emphasized chapter routes before internals...` 仍按旧 `<ol>` 断言五个链接，而当前 `unreal-language/index` 已呈现现有卡片式入口，查询结果为空。
2. `renders only the three registered bounded source excerpts...` 在 `reload-pipeline-internals` 找不到既有 `View pinned source` 链接。

这两个既有断言/内容漂移不属于源码注解位置实验；没有为使本轮变绿而改写正式文档或放宽其断言。

## 构建与产物

```powershell
& npm.cmd exec --yes --package node@24 --package pnpm@11.8.0 -- pnpm run build:wiki
```

结果：PASS，输出 `Wiki/dist/index.html`。

```powershell
& npm.cmd exec --yes --package node@24 --package pnpm@11.8.0 -- pnpm run test:artifact
```

结果：`1 passed`，离线产物完整且构建过程没有修改交互源码。

## 几何与视觉检查

Playwright 从 `file:///D:/Workspace/AngelscriptProject/Wiki/dist/index.html` 打开构建产物并记录实际 placement：

- E01 Auto Dock：`top`
- E02 Top Notes：`top`
- E03 Reserved Rail：`reserved`
- E04 After Code：`after`

截图：

- `Wiki/test-results/e01-auto-desktop.png`
- `Wiki/test-results/e02-top-desktop.png`
- `Wiki/test-results/e03-reserved-desktop.png`
- `Wiki/test-results/e03-reserved-active.png`
- `Wiki/test-results/e04-after-desktop.png`
- `Wiki/test-results/e01-auto-narrow.png`

检查结论：

- E01/E02 的四条无序号 note 位于源码上方，P04 第 31 行长调用使用完整代码宽度且未被 note 背景覆盖。
- E03 的源码视口和 14rem note 轨无几何重叠；横向滚动只移动源码。terminal path 终点到 note port 中心误差小于 `1px`，点击后 terminal 隐藏、当前完整 connector 提升。
- E04 源码在前、note 在后，Idle 没有常驻 connector，note 背景和边框均为透明。
- 四种布局的 note 默认使用低对比灰蓝文字；active/focus 才出现边框、白色表面和清晰详情。
- 390px 下 Auto 截图实际为 After Code，源码内部横向滚动，note 顺序位于源码之后，文档宽度不超过 viewport。
- 点击详情前后 Top 的 `<pre>/<code>` 几何完全相等；`Escape` 恢复关闭状态。

## 已知实验取舍

- Auto 在当前 P04 长源码上与固定 Top 得到相同 placement；二者的比较价值在于前者保留对短源码自动进入 Right 的能力。
- Reserved Rail 有意缩小源码可视宽度，长行通过源码内部横向滚动查看；它解决“note 覆盖源码”，但是否优于 Top/After 仍由维护者视觉选型。
- 本轮没有把实验属性写入稳定作者文档，也没有迁移正式 P04。
- 未新增外部依赖，未提交或推送 Wiki 子模块及父仓库。
