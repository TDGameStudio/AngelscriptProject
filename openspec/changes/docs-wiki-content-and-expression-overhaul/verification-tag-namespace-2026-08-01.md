# 产品 Tag UE 风格命名收口验证（2026-08-01）

## 结果

- 本记录取代同日早先把 `Docs|ReaderNav|Showcase` 作为最终根的中间验证结论。
- 正式文档主题 Tag 已收口为 UE 风格 PascalCase：`Start`、`Language`、`UnrealLanguage`、`TypeObjectReflection`、`UnrealCore`、`CompileModulePreprocessor`、`HotReload`、`EditorIdeDebugging`、`TestingDiagnosticsRelease`、`RuntimeJitVm`、`BindingsUhtExtensions`、`ArchitectureMaintenance`、`TopicsIntegrations`、`ReferenceDifferencesVersion`、`ShowcaseLab`。
- `as-topic-key` 继续保存 kebab-case 稳定键；主题目录通过 `[has[as-topic-key]sortan[as-order]]` 发现定义。读者导航通过 `[has[as-nav-key]sortan[as-order]]` 发现定义，不再需要 `ReaderNav` Tag。
- 删除冗余的 `Docs` / `ReaderNav` 根定义和相应根 Tag 赋值；保留确实表达层级分类的 `Showcase/*`，以及主题子 Tag `ReferenceDifferencesVersion/Hazelight`。
- 未增加 alias、双读或兼容 tiddler；`$:/ASWiki/**` 系统 tiddler、`AS/Docs/**` 与 `AS/Showcase/**` 内容标题保持原语义。
- 内容契约拒绝旧 `ASWiki/*`、`Docs/*`、`ReaderNav` 和所有未注册非系统 Tag，并继续校验同名定义、`caption` / `description`、层级父定义、无环关系和 Showcase 补充分类边界。

## 静态审计

对 Wiki 子模块提交快照中契约收集到的 306 个 `.tid` 记录进行审计：

- 产品 Tag 赋值：146 次。
- 不同产品 Tag：22 个；全部满足 `^[A-Z][A-Za-z0-9]*(/[A-Z][A-Za-z0-9]*)*$`。
- 旧 `ASWiki/*`、`Docs`、`Docs/*`、`ReaderNav`、`ReaderNav/*` 引用：0。
- 缺失同名定义：0；缺少 `caption` / `description`：0；缺失父定义：0；契约错误：0。
- 22 个 Tag 为：
  - 主题：`ArchitectureMaintenance`、`BindingsUhtExtensions`、`CompileModulePreprocessor`、`EditorIdeDebugging`、`HotReload`、`Language`、`ReferenceDifferencesVersion`、`RuntimeJitVm`、`ShowcaseLab`、`Start`、`TestingDiagnosticsRelease`、`TopicsIntegrations`、`TypeObjectReflection`、`UnrealCore`、`UnrealLanguage`。
  - 主题子 Tag：`ReferenceDifferencesVersion/Hazelight`。
  - Showcase：`Showcase`、`Showcase/Base`、`Showcase/Detail`、`Showcase/Lab`、`Showcase/LayoutExperiment`、`Showcase/Pattern`。
- 仓库搜索中，旧产品 Tag 只存在于内容契约的刻意失败夹具和本 OpenSpec 的迁移说明，不存在于实际 tiddler、过滤器、选择器或生成器输出。

## 自动化验证

- TDD 红灯：新增 PascalCase 主主题用例后，旧实现按预期报 `invalid-product-tag-root` 与 `missing-primary-topic`。
- `node --test scripts/document-content-contract.test.mjs scripts/document-resolution.test.mjs scripts/knowledge-content-migration.test.mjs scripts/multilingual-compatibility.test.mjs`：59/59 PASS。
- `generateKnowledgePages({ write: false })`：dry-run 渲染 29 页，全部输出 PascalCase 主题 Tag，未写文件。
- 本次涉及的 6 个 JS/TS 文件定向 ESLint `--quiet`：0 error。
- `node node_modules/typescript/bin/tsc --noEmit --skipLibCheck`：PASS。
- `node scripts/run-product-tests.mjs feature sidebar`：33/33 PASS；覆盖原生 TagTemplate、More/TagManager、portal、窄屏、颜色字段、PascalCase Tag 与点击弹层。
- `node scripts/run-product-tests.mjs feature document`：22/24 PASS；主题目录、读者目录、Showcase Tag/层级相关用例通过。两个失败来自当前工作区既有的正文/断言不一致：L0 页面已使用卡片而测试仍查找 `<ol>`；三篇 bounded-source 页面未提供测试期待的 `View pinned source` 链接。
- `node scripts/run-product-tests.mjs feature i18n`：0/2；Tag 可见性、Tag 对比度和键盘焦点断言已执行通过，失败点分别是当前工作区既有导航标题断言（期待“文档入口”，实际为“全部文档”）和首页选中控件 4.23:1 对比度。
- `node --test scripts/core-contract.test.mjs`：13/14 PASS；唯一失败仍是既有 `zh-primary` 导航结构断言与当前字段驱动的直读导航不一致。
- Wiki 子模块和父仓库 `git diff --check`：PASS（仅报告现有 CRLF 转换提示，无 whitespace error）。

## 全量门禁状态

当前 shell 的工具链为 Node 25.5.0，且无法发现 pnpm；`node scripts/assert-toolchain.mjs` 正确拒绝该环境，因为 Wiki 要求 Node 24.x + pnpm 11.8.0。因此本轮没有在不受支持的工具链上宣称 `pnpm run test:fast` / `test:release` 通过。

在已安装依赖上直接执行的 TypeScript 检查通过；全仓 ESLint `--quiet` 仍报告 9 个既有 error，全部位于本次未修改的 `tests/playwright/product/tools/tiddler-toolbar-hover-prototype.spec.ts`（不必要的类型断言）。这些错误与上面的工具链阻塞共同说明完整 release 门禁仍未全绿；本轮 Tag 迁移的契约、生成器、定向 lint 和 Sidebar 回归没有失败。
