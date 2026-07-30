## Context

`Wiki/` 是 `TDGameStudio/AngelscriptWiki` 的独立 TiddlyWiki 子仓库。它基于 Modern.TiddlyDev，构建工具会自动扫描 `src/` 下的一级 plugin 目录，因此上游 `src/plugin-name` 会被默认 dev、test、build 和 publish 流程加载。该示例仍被双语 Modern.TiddlyDev 教程引用，也可能继续被维护者用于实验，不能直接删除。

当前未提交批次已经提供 Angelscript theme、wiki config plugin、browser-only `as-code` widget、Playwright 场景和离线发布等待逻辑。现有归档规格要求 theme 自己携带 Vanilla sidebar compatibility tiddlers，config plugin 负责站点默认值和启动动作；本设计遵守这个边界。

## Goals / Non-Goals

**Goals:**

- 让默认 Wiki 和发布产物只体现 AngelscriptWiki 的产品内容。
- 保留并显式启用 `src/plugin-name` 示例实验路径。
- 建立可自动验证的正式测试与 examples 测试边界。
- 提供中英双语、使用者/维护者双轨的 AS 工作流入口。
- 继续以现有 `angelscript-theme` 和 `angelscript-tools` 为展示基础。

**Non-Goals:**

- 不删除、重命名或重写 `src/plugin-name` 的教学实现。
- 不把 Unreal Runtime 文档全文复制到 Wiki。
- 不修改 AS Runtime 性能、编译器、绑定、GC、StaticJIT、HotReload 或 DebugServer。
- 不引入 React、Vue、Tailwind 或大型浏览器运行时依赖。

## Decisions

### 默认过滤、显式 examples

标准命令使用 `tiddlywiki-plugin-dev` 原生 filter：

```text
[prefix[$:/plugins/your-name/plugin-name]]
```

`dev`、`test` 和 `build` 使用 `--exclude`；`publish` 使用 `--exclude-plugin`；自定义 offline publisher 将该 filter 传给 `buildLibrary`。示例 source 保持在 `src/plugin-name/`，通过 `dev:examples`、`test:examples` 和 `build:examples` 使用未过滤流程。

备选方案是移动到 `examples/` 或直接删除。移动会改写 Modern.TiddlyDev 教程路径，删除会损失实验入口，因此不采用。

### 正式测试与示例测试分离

正式 Playwright test directory 保持 `wiki/tiddlers/tests/playwright`，只包含 AngelscriptWiki 产品回归。示例 tiddler 和 spec 移到 `wiki/tiddlers/examples/`，由独立 `playwright.examples.config.ts` 和 `test:examples` 执行。这样默认 server 排除示例时不会留下必然失败的测试。

### 配置所有权

- `src/angelscript-theme/` 继续拥有 `$:/themes/angelscript`、palette、stylesheet、Vanilla metrics/options/settings compatibility tiddlers。
- `src/angelscript-wiki-config/` 拥有 `$:/theme`、`$:/view`、site title/subtitle、default tiddlers、CPL default 和 browser startup action。
- `wiki/tiddlers/system/` 只保留 runtime state、外部 plugin data、favicon 和 filesystem bootstrap。

### 文档结构

AS 文档使用 `wiki/tiddlers/as/` 下的用户内容 tiddlers，不新增运行时代码 plugin。每个 tiddler 使用现有 `$:/language` 条件分支提供中文和英文内容，并复用 `LanguageSwitcher`。首页提供 AS 使用者和插件维护者两条入口；宿主 `Documents/` 文件仍是 UE 命令和 Runtime 事实的 source of truth。

### 提交边界

Wiki 子仓库按示例隔离、默认归属/展示基础、AS 工作流文档三个可回滚主题提交。宿主仓库只记录 OpenSpec；需要集成时再单独提交 `Wiki` gitlink。实现过程中不使用 `git add .`，不重置无关工作区。

## Risks / Trade-offs

- [风险] 教程用户直接运行底层 `tiddlywiki-plugin-dev` 命令时仍可能加载示例 → [缓解] 标准 `pnpm` scripts 统一过滤，并在中英教程中说明 `dev:examples` / `build:examples`。
- [风险] 教程正文仍会出现 `plugin-name` 文本 → [缓解] 发布验收检查 plugin library 清单，不对完整 HTML 做字符串不存在断言。
- [风险] 现有根仓库有大量脏改动 → [缓解] 只在 `Wiki/` 和新 OpenSpec 路径操作，提交前检查两层 `git status` 和 submodule diff。
- [风险] 主题或 config tiddler 重复加载 → [缓解] 通过 Playwright 检查 shadow tiddler、默认 theme、palette、site identity 和旧 startup 缺失。

## Migration Plan

1. 在 Wiki 子仓库中先添加失败的默认隔离/运行时断言，再实现 package filters 和 examples config。
2. 完成 theme/config 迁移和首页默认值，运行 focused Playwright。
3. 整理现有 AS widget、theme 和 offline publisher，运行 build/library/offline 验证。
4. 添加双语工作流 tiddlers 和导航，运行完整 Wiki 验证。
5. 在 Wiki 子仓库内按计划提交；暂不更新宿主 gitlink，除非用户另行要求。

## Open Questions

无。首期读者、语言、示例策略和展示范围已确定。
