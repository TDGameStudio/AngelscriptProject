# 源码注解层级、落位与连线几何验证（2026-08-01）

## 结论

任务 2.20 已按生产 Wiki 契约落地：源码 DOM、换行、宽度与复制结果不变；不使用右侧 rail；connector 在 idle、hover、focus 和 detail open 状态都固定在 Highlight 源码下层；默认 range 不显示下划线；detail 不再提供 `×`。未新增第三方运行时依赖。

## TDD 证据

红色阶段先在 `Wiki/tests/playwright/product/code/annotation-flow.spec.ts` 增加四类契约：

- idle range 必须透明下划线 + `0.02–0.03` 的极弱填充，只有当前关系显示下划线和 source port；
- connector 打开 detail 前后都必须低于 `<pre>`，不存在 `.is-elevated`；
- P04 多行范围从实际落位行的最近 mark 出线，top shelf 连接 summary 底部中心，控制点不超出起终点包围区；
- 窄屏 detail 不存在关闭按钮，`Escape` 关闭后焦点返回原 note。

首次运行结果为 `4 failed / 8 passed`，分别暴露常驻下划线、打开时提升 connector、多行错误出线和 `×` 仍存在。实现后同文件为 `12 passed`，并继续通过整个 code 域。

首轮完成后又进行了一次独立只读代码评审。评审指出三个需要闭环的 Important：源码端仍有 `3px` 人工间隙、跨行精确 `match` 只检查首行、unresolved note 丢失 `detailTiddler`；并指出维护者规则的排序文案与规范不一致。为三个行为问题新增的定向用例首次结果为 `3 failed`；修复后为 `3/3 passed`，完整 `annotation-flow` 为 `14/14 passed`。同一评审者复核后确认 3 个 Important 与 1 个 Minor 均已正确修复，更新 verdict 为 `Ready to merge: Yes`。

## 实现边界

- `Wiki/src/angelscript-tools/index.ts`
  - flow 落位在每个 note 上保留 `line-tail | blank-line | top`、实际 source mark 和边方向；
  - 多行范围依次检查目标行，不再一律从最后 mark 出线；
  - 跨行精确 `match` 由 `startOffset` 和 `endOffset - 1` 推导实际相交行，可使用后续匹配行的安全行尾；
  - 空白行以目标范围为中心向外搜索最多 6 行；
  - source/note 端点通过最短曼哈顿距离选边，line-tail 和 top 使用稳定的右→左、上→下契约；路径起点与 mark 真实边界对齐，不依赖隐藏 port 遮盖间隙；
  - 曲线使用起终点中点，去除反向连线的强制向右弯折；
  - 移除 detail close button，`Escape` 返回触发 note。
  - resolved 与 unresolved note 共用详情来源处理；锚点失效时，现有 `detailTiddler` 仍 transclude/链接，缺失目标仍显示诊断和内联回退。
- `Wiki/src/angelscript-tools/index.css`
  - connector layer 固定 `z-index: 0`，源码 `<pre>` 为 `z-index: 1`；
  - idle range 使用 `rgba(66, 113, 174, 0.025)` 与透明 border，active 才显示下划线；
  - note port 为无尺寸精确边界点，补偿 comment 样式的 `3px` 左规则，消除连线末端空白。
- 永久规则记录在 `source-annotation-layout-rules.md`，作者向 WikiText 说明记录在 `$:/plugins/TDGameStudio/angelscript-tools/documentation/source-annotation-layout-rules`。

## 视觉复查

截图使用实际 P04 `UScriptGameInstanceSubsystem` 页面和 Wiki 主题，不是隔离的 demo：

- [desktop idle](comparison-artifacts/source-annotation-review-desktop-idle.png)：四条 note 分别使用可用行尾，不遮挡源码墨迹，默认不出现蓝色下划线。
- [desktop active](comparison-artifacts/source-annotation-review-desktop-active.png)：当前多行范围才显示下划线；蓝色 connector 只在源码末端到 note 边界的空白区显露，终点无断口。
- [desktop detail](comparison-artifacts/source-annotation-review-desktop-detail.png)：详情无 `×`，短 note 和源码几何不移动，连线不盖住 token。
- [390px idle](comparison-artifacts/source-annotation-review-mobile-idle.png)：无隐藏右 rail；四条 note 回退到顶部 shelf，长 C++ 行保留代码面内横向滚动；细线位于字形下方。
- [390px detail](comparison-artifacts/source-annotation-review-mobile-detail.png)：详情自适应近全视口，无额外关闭 chrome，源码仍保持连续。

## 验证命令

主机全局 Node 为 25，因此以 `npx --package=node@24 --package=pnpm@11.8.0` 提供仓库声明的 Node 24 / pnpm 11.8.0 工具链，`pnpm run toolchain:check` 通过。

| 命令 | 结果 |
|---|---|
| `pnpm run check` | PASS（toolchain + `tsc --noEmit --skipLibCheck`） |
| `pnpm exec eslint src/angelscript-tools/index.ts tests/playwright/product/code/{annotation-flow,annotated-code,presentation}.spec.ts` | PASS（0 errors / 0 warnings） |
| `pnpm exec playwright test tests/playwright/product/code --project=chromium` | PASS（56/56） |
| `pnpm exec playwright test tests/playwright/product/code document-content-foundation.spec.ts:348 :497 :639 :690 --project=chromium` | PASS（60/60；完整 code + Showcase 分层、七个 Pattern、AST/VM、P04 单列） |
| `node --test scripts/document-content-contract.test.mjs scripts/document-resolution.test.mjs scripts/product-sources.test.mjs` | PASS（45/45） |
| `openspec validate docs-wiki-content-and-expression-overhaul --strict --no-interactive` | PASS |

扩大到 `document-content-foundation.spec.ts` 时，与本任务相关的 Showcase 分层、七个注解 Pattern、AST/VM Lab 和 P04 单列阅读用例全部通过。该文件另有两条可稳定复现的无关基线失败：`unreal-language/index` 测试期待 `<ol>`，当前页面使用 `as-doc-cards`；`reload-pipeline-internals` 测试期待 `View pinned source`，当前跟踪的 placeholder tiddler 没有该链接。这两个文件与本轮修改文件无交集，本任务未将无关内容迁移混入实现。

## 已知边界

- 布局器不做 A* 障碍路由；先选择就近空白和真实边界，几何必须交叉时依靠永久低层保护源码可读性。
- 移动窄屏的顶部 shelf 是源码保护回退，不承诺与桌面端相同的行尾位置；语义顺序和连接关系保持不变。
