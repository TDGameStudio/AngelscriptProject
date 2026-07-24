# Wiki 工具链与插件架构审查（2026-07-25）

## 审查范围与证据

- 盘点了 `Wiki/product-sources.json`、本地三插件、选中的 vendor 源、构建/预览/发布脚本、package scripts、CI、Playwright 配置与产品级测试。
- 运行并通过：`npm run test`、`npm run test:product-sources`、`npm run check`、`npm run lint:all`、`npm run test:source-boundaries`。
- 直接运行 `npm run test:artifact` 时，测试因裸 `pnpm` 不在 PATH 而失败；使用仓库文档规定的 `npm exec --yes pnpm@11.8.0 -- run test:artifact` 后，离线产物构建和校验通过。
- 当前机器是 Node 25.5.0/npm 11.10.1；项目基线是 Node `>=24 <25` 和 pnpm `11.8.0`，所以本机成功运行的结果只作为探索证据，不替代基线验证。

## 健康边界：保留

| 边界 | 现状 | 审查结论 |
|---|---|---|
| 产品源 | 8 个 manifest 管理的本地/vendor 入口；vendor 记录 baseline/tree hash | 保留一个权威清单，不再引入第二套列表。 |
| 本地插件 | theme 管样式/模板；tools 管浏览器交互；config 管持久默认值/窄策略 | 不合并插件；该分层比“按文件类型合并”更可维护。 |
| Vendor | 来源、运行时策略和允许外部行为受 manifest 验证；Draw.io 是唯一用户动作触发的外部 iframe | 不改来源、hash 或外部行为政策。 |
| 运行时覆写 | PageTemplate、侧栏、More 等关键表面有静态契约与产品 Playwright 测试 | 不做全局替换；后续 core 升级仍需逐覆写审查。 |
| Comparison artifacts | 根目录被忽略；一个左侧栏 HTML 被意外保留为 Git 追踪的独立测试资产 | 仅删除获批的追踪 HTML 和专属测试，保留其余本地实验。 |
| 多语言 | 默认 `zh-Hans`，显式加载 zh-Hans 插件并使用 TiddlyWiki core 的 `en-GB`；正文按 `$:/language` 分支，主题经 `<<lingo>>` 取词 | 将其视为产品兼容契约，不以临时英文字符串绕过。 |

## 确认实施项

1. 严格落实 Node 24/pnpm 11.8.0 的开发与验证契约，并消除 npm/pnpm 混用。
2. 将离线产物测试与全局 package-manager PATH 解耦。
3. 将开发源桥接收敛为按插件的完整同步，并建立可重复单元测试。
4. 默认让 Playwright 构建并托管唯一、隔离的离线产物，而不是开发预览；只有显式设置 `PLAYWRIGHT_BASE_URL` 才可选择外部服务器。
5. 删除 `comparison-artifacts/left-sidebar/03-compact-control-rail.html` 及其独立 mockup 测试套件。
6. 记录并测试 zh-Hans/en-GB、English fallback、lingo 双路径兼容与双语导航选择；将本地主题残留的 TidGi/“太记预置主题”身份修正为 AngelScriptWiki 身份。

## 明确延期或不做

- 不统一 plugin.info 的 TiddlyWiki compatibility 字段；该项不影响当前严格依赖锁定。
- 不在无性能 trace 的情况下优化 `tag-color-variants.ts` 的 MutationObserver。
- 不继续推进 `refactor-wiki-architecture-hardening` 的主题拆分、SDK 元数据、多浏览器 smoke 和未完成任务。
- 不处理 `refactor-wiki-unified-line-icons` 的图标目录、生成器或其当前未提交文件。
- 不全面重写顶层 `openspec/specs/` 的历史规格。已发现若干旧规格仍描述 MkDocs、插件库和旧 tokenizer；本记录只在设计中交叉引用，完整收敛继续由 `refactor-wiki-architecture-hardening` 处理。
- 不新增第三语言、翻译服务或自动机器翻译；新增产品可见文本仍必须同时兼容本次记录的两种语言。

## 测试执行架构审查

### 观察到的结构问题

- 当前测试规模为 **48 个 Node 测试**和 **69 个 Playwright 产品测试**。数量本身仍可控；真正的问题是它们没有正式的执行层级。
- `pnpm run verify` 将 typecheck、两类 lint、工具链/源边界/manifest/多语言契约、TiddlyWiki 运行时测试、离线构建、artifact 测试和完整 Chromium 套件串成一个顺序链路。普通功能开发没有被文档化的快速或按表面定向入口。
- CI 仅有一个 `verify` job，35 分钟超时。它不能区分快速静态失败、浏览器产品回归和离线产物失败，也不能通过并行化降低等待时间。
- Git 仓库没有项目自有的 pre-commit 测试策略；当前 `.husky/` 只有框架生成的支持文件。因此不能假设每个本地提交都已运行适当的验证。
- `build:wiki` 与 `test:artifact` 都会触发离线发布路径，完整链路存在重复构建成本；实现前必须先测量，而不是凭感觉删除任何一个检查。
- 本机探索复现了共享生成目录竞争：已有预览持有 `.generated/plugin-sources` 时，第二个准备动作在 Windows 上可因 `rmSync()` 的 `ENOTEMPTY` 失败。仅让 Playwright 使用新端口不能解决该问题，后续必须按预览实例隔离生成根目录。

### 结论：按门槛必跑，不以“可选测试”命名

测试不应被粗暴划成“可选”与“非可选”。正确的规则是每项检查都有最早的必须运行门槛：普通开发跑廉价且相关的组合，PR 自动运行快速契约，完整产品回归仅在维护者明确要求或发布前执行，发布特有检查在交付门槛执行。这样既不降低发布质量，也不会让每一次普通文案或局部功能编辑被全量浏览器和离线构建阻塞。

| 层级 | 职责 | 普通开发 | PR CI | main/release |
|---|---|---|---|---|
| `guard` | Node/pnpm 工具链前置校验 | 自动 | 必跑 | 必跑 |
| `fast` | typecheck、本地 lint、确定性 Node/源契约；目标 30 秒 | 必跑 | 必跑 | 必跑 |
| `affected` | `shell`、`sidebar`、`document`、`code`、`tools`、`i18n` 等显式功能域 | 改到该域时必跑 | 维护者确认 | 必跑 |
| `integration` | 完整 TiddlyWiki 运行时与 Chromium 产品回归 | 明确要求时 | 明确 dispatch 时 | 发布前 |
| `release` | 离线发布、artifact 结构、完整 vendor 审计 | 非默认本地循环 | 手动 dispatch 时 | 必跑 |

### 新功能的回归测试准入规则

| 变更类型 | 最低测试层 | 是否新增 Playwright |
|---|---|---|
| 普通正文、双语文案、链接、静态 WikiText | `fast` 加 content/i18n 契约 | 否，除非改变读者可见布局或交互 |
| 默认配置/数据形状 | `fast` 的源契约或运行时单元测试 | 仅在启动后行为或可见默认值改变时 |
| TypeScript widget、侧栏/More、工具栏、主题交互、响应式样式 | `fast` 加对应 `affected` 套件 | 是，复用该产品表面的真实场景 |
| 跨插件用户流程、核心覆写、产品源桥接 | `affected`；必要时显式运行 `integration` | 是，完整回归由维护者/发布门槛触发 |
| bug 修复 | 可复现问题的最低层 | 只有无法在更低层复现时才新增 |

新测试先并入已有的产品表面套件；只有不同的 fixture 生命周期或独立产品边界才创建新 spec。不能以某次历史任务名、临时实验或截图需求作为单独测试套件的理由。视觉检查尤其应并回 theme/sidebar/document/i18n 的真实场景，避免每次视觉任务增加一个泛化 spec。

### 后续实施边界

本次实现将引入明确的 `test:fast`、`test:feature -- <domain>`、`test:smoke`、`test:ui:full`、`test:integration`、`test:release` 命令，并以仓库维护的 suite registry 选择测试；不得以 `git diff` 文件路径猜测影响范围。CI 将保留自动快速作业，并把集成浏览器和发布/artifact 验证作为手动 dispatch 作业。实现会测量命令耗时、迁移现有测试、隔离生成目录，并在 Node 24/pnpm 11.8.0 环境中完成最终验证。

## 视觉验证审查

### 已有优势

- 产品 Playwright 已覆盖真实运行时的 sidebar/More/slider/tag popup/toolbar/code surface：DOM 结构、计算颜色、字体权重、边框圆角、阴影、尺寸、对齐、滚动、焦点、ARIA、narrow viewport 和 `prefers-reduced-motion` 都有针对性断言。
- `core-contract.test.mjs` 保护关键 stylesheet 与核心覆写边界；历史 OpenSpec 保留了人工截图复查证据。
- 因此不以独立 mockup 或静态 HTML 替代产品本身的视觉测试；获批删除的 03 fixture 不再是回归来源。

### 应补齐的稳定自动化层

1. **双语布局矩阵**：当前没有在 zh-Hans/en-GB 各自的桌面与窄屏状态下验证内容长度、tabs、工具栏、More、正文边界和横向溢出。
2. **关键可访问视觉状态**：当前焦点存在性检查很好，但关键正文、控制栏与标签组合缺少明确的对比度门槛测试。
3. **真实产品状态集合**：以首页、长正文/代码、More 侧栏和窄屏抽屉为最小稳定场景，复用真实 tiddler 与真实主题，不创建第二套视觉 mockup。

### 明确不在本轮引入的像素 golden

当前没有 `toHaveScreenshot` 基线。它可能捕获组合性微小漂移，但在未锁定 CI 浏览器/字体、稳定 fixture、动态区域 masks、容差与审查流程前会产生跨环境噪声。本变更只记录其准入条件；后续独立视觉回归变更才能引入少量受控 golden。

## 多语言兼容清单

- 支持语言：`zh-Hans`（默认）与 `en-GB`（回退）。
- 状态来源：`$:/language`；正文/导航按该 tiddler 的语言代码选择内容。
- 界面词条：优先使用 `$:/language/...`、`<<lingo>>` 或现有双语 WikiText 分支；不要在 TypeScript 中直接加入未本地化的可见标签。
- lingo 补丁：`wiki/tiddlers/patches/lingo.tid` 同时保留 legacy `<base><title>` 与 `<base><language-code>/<title>` 回退，升级锁定 TiddlyWiki 前必须验证两者。
- 主题翻译：`src/angelscript-theme/language/{zh-Hans,en-GB}/Translations.multids` 的键集合必须对齐，且项目自有文案不得保留 `TidGi`、`太记` 或上游主题身份。
- 后续实现：任何新增按钮、弹窗、配置描述、导航项或测试可见反馈，都应在同一改动中添加 zh-Hans/en-GB 词条或复用核心已翻译 tiddler，并扩展 multilingual contract 测试。
- 视觉后续实现：任何影响布局、状态颜色、字体层级、交互反馈或图标的改动，都应扩展实际产品的 locale/viewport 矩阵和相关状态断言；只有通过稳定场景评审后才可新增像素 golden。

## Review correction validation — 2026-07-25

- 已将执行层级目标改为：`fast` 是自动的 pull-request CI 门槛；完整产品集成仅在维护者显式手动请求或预发布验证时运行；`release` 验证仍是交付前的必经门槛。
- 已强化测试预览契约：每个默认浏览器测试预览必须从自身唯一的生成产品源根目录构建并托管唯一、隔离的离线产物，绝不复用开发预览；`PLAYWRIGHT_BASE_URL` 是唯一允许测试外部服务器的显式 opt-in。
- 已运行：`openspec validate refactor-wiki-toolchain-reliability --strict --no-interactive`
- 结果：通过（`Change 'refactor-wiki-toolchain-reliability' is valid`）。

## 已实施的测试执行架构 — 2026-07-25

- `test:fast` 只组合 typecheck、本地 lint 和确定性 Node/源码契约；`test:feature -- <domain>` 通过显式域名运行浏览器回归，域名固定为 `shell`、`sidebar`、`document`、`code`、`tools`、`i18n`。`test:smoke`、`test:ui:full`、`test:integration`、`test:release` 依次提高范围；`verify` 是发布级 `test:release` 的别名，不再是每次编辑后的默认命令。
- 正式 Playwright spec 已从平铺目录收口到上述六个功能域。纯色彩对比算法已从浏览器 spec 移至 Node 契约；`comparison-artifacts/` 仍不能成为正式测试依赖。浏览器 test registry 校验未知域、去重并以 registry 顺序稳定执行。
- 默认 Playwright 服务器在固定 `127.0.0.1:4173` 下，从唯一 `.generated/playwright-*` 源根目录构建唯一离线 HTML，再仅服务该产物；它不复用 `pnpm dev`、8080 或 `.generated/plugin-sources`。端口占用明确失败，进程正常退出/信号中断会同步清理临时目录；`PLAYWRIGHT_BASE_URL` 保留为唯一的外部预览 opt-in。
- 运行时集成命令同样使用唯一 `.generated/wiki-runtime-*` 源根目录。PR/push CI 自动运行 `fast`；`integration` 与 `release` 只可通过 workflow dispatch 选择，发布前必须执行 release。
- 当前 Node 25 工作站上的直接 Node 契约、类型检查、一个显式 `shell` 功能域、全部 `@smoke` 场景以及改动过的 `code` clipboard 场景均已通过。完整证据和耗时记录在 `benchmarks/test-execution-20260725.md`。Node 24/pnpm 11.8.0 下的真实 `test:fast` 30 秒预算和发布级完整验证仍待受支持工具链/明确发布请求完成。
