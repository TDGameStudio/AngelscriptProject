# 源码注解有界避障与 Wiki 详情验证（2026-08-01）

## 结论

任务 2.21 已落地。正式 `<$annotated-code>` / `<$angelscript-code>` 继续保持连续 Highlight 源码、无右侧 rail、默认无行号、note 无序号/展开箭头、connector 永久位于源码下层；本轮只扩展 connector 几何和详情表达：

- 安全同排关系输出严格的 `M x y L x y` 水平线；
- 符合有界条件的 displaced/blank-line 关系才按需执行 `obstacle-router@0.1.2`，同一代码块一次 transaction 批量求解，移除共线点后用 7px 有界三次贝塞尔圆滑直角；
- 源码与 note 障碍在端点处切出出口；无解、无效、超出端点包围框和 top-shelf 关系使用既有低层 fallback，避免主线程病态搜索或视觉 overshoot；
- 路径以半像素量化几何签名缓存，SVG path 按 note ID 原位更新；超过 16 条复杂关系或 160 个障碍时先显示 fallback，再在 idle task 求解；
- 内联 body 展开为 compact/reading/rich 说明；现存 `detailTiddler` 在折叠 note 上显示低强调 `Wiki` 文本，展开面显示“Wiki 详情预览”，transclude 完整内容并提供“在 Wiki 中打开完整解释”内部链接；
- P04 同时验证纯内联详情与 `AS/Showcase/Detail/P04-CurrentVmGuard` 独立详情，面板不提供 `×`。

## 依赖、离线与许可证

- `Wiki/package.json` / `pnpm-lock.yaml` 精确锁定 `obstacle-router@0.1.2`；生成器使用精确 `esbuild@0.28.0`。
- `Wiki/scripts/bundle-annotation-router.mjs` 只导入正式求解需要的符号，生成独立 `$:/plugins/TDGameStudio/angelscript-tools/obstacle-router.js` TiddlyWiki `library` 模块。主 widget 没有静态 import，只在有 eligible complex route 时通过 `$tw.modules.execute` 执行。
- 生成 bundle 为 139,034 bytes，SHA-256 `7096AFA76B69C02B2A9604EA9F96C2667194F198EF03C35FE13F0F17491386BA`；连续两次生成一致。
- LGPL-2.1 上游 notice 同时保存在 `Wiki/THIRD_PARTY_NOTICES.md` 和离线 tiddler `$:/plugins/TDGameStudio/angelscript-tools/licenses/obstacle-router`。
- 最终单文件 `Wiki/dist/index.html` 为 5,959,372 bytes；相对 5,795,796 bytes 基线增加 163,576 bytes。decoded budget 调整为 6,000,000 bytes，只保留 40,628 bytes（约 0.68%）余量。
- artifact 测试断言产物仍只有 `index.html`，并直接检查 library module、`module-type: library`、禁止二次 minify 的 metadata 与许可证 tiddler。

详细同步基线、阈值和最终体积见 `benchmarks/annotation-routing-2026-08-01.md`。

## TDD 与视觉证据

先在 `Wiki/tests/playwright/product/code/annotation-flow.spec.ts` 增加失败断言并确认 RED：严格水平线缺少 `data-route-kind="straight"`、layout 后 path DOM 被重建、缺少 `Wiki` marker/预览/新链接、P04 双详情形态缺失。实现后该文件 18/18 通过，并增加一条实际 `data-route-kind="obstacle"` 的 displaced-route 回归。

Playwright 截图人工复核：

- P04 默认态：AS/C++ 仍为一列连续源码，短 note 与源码近似同高，无隐形右栏，connector 低于语法 token；
- P04 Wiki detail：无 `×`，标题/表格/额外代码/返回链接和独立 Wiki 入口按内容自适应；
- blank-line route：实际路径为横/竖骨架加轻量圆角，没有斜线，active range 只在 hover 时出现下划线。

本地审阅图保存在忽略目录 `Wiki/test-results/p04-routing-collapsed.png`、`p04-wiki-detail-open.png` 与 `annotation-obstacle-route-review.png`，不作为产品资产提交。

## 验证结果

| 命令 / 检查 | 结果 |
|---|---|
| `pnpm run check` | PASS（Node 24.18.1 / pnpm 11.8.0；TypeScript） |
| 本轮文件 targeted ESLint | PASS（`index.ts`、bundle generator、annotation-flow、publish-offline test；0 errors / 0 warnings） |
| `pnpm run generate:annotation-router` 两次 + SHA-256 | PASS（哈希一致，139,034 bytes） |
| `pnpm run test:feature -- code` | PASS，60/60 |
| `pnpm run test:runtime` | PASS，1/1 |
| `pnpm run test:artifact-server` | PASS，2/2 |
| `pnpm run build:wiki` | PASS，单文件 5,959,372 bytes |
| `pnpm run test:artifact` | PASS，1/1 |
| 分拆合同：product sources / source bridge / multilingual / document content / product-test infrastructure | PASS，4/4、3/3、3/3、48/48、19/19 |
| `pnpm run test:ui:full` | 127/135 PASS；全部 60 项 code 测试通过，其余 8 项为当前工作区既有 document/i18n/sidebar/缺失 toolbar 实验资产失败，与本轮文件无交集 |

## 非本轮阻塞项

完整 `pnpm run test:release` 仍会在既有工作区问题处提前失败，本轮未越权修改：

1. 全仓 lint：`tests/playwright/product/tools/tiddler-toolbar-hover-prototype.spec.ts` 有 9 个 unnecessary assertion errors，另有既有换行/生成表格式警告；
2. `test:toolchain`：显式传 `userAgent: undefined` 被默认参数替换为真实环境值，旧测试期望 `false`；
3. source-boundaries/core-contract 为 34/36，失败项是已重构导航仍被旧 `文档入口` 断言约束，以及已有 code 测试文本提到 `comparison-artifacts`；
4. full UI 的 8 项失败来自文档目录/固定源码链接、i18n 文案/对比度、More tag popup 几何，以及缺少 `improve-wiki-tiddler-toolbar-hover-layout` 独立 HTML。

这些失败在任务 2.21 开始前已由其他未完成工作产生；本轮保持用户的并行改动不变，并用范围内绿灯、离线 artifact 断言和视觉审阅完成收口。
