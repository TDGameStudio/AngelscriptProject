## Why

`Wiki/` 已经具备 Angelscript theme、browser-side AS code widget 和离线发布能力，但默认构建仍会加载 Modern.TiddlyDev 的 `src/plugin-name` 示例，站点默认值也仍引用模板 plugin。现在需要把示例保留为可选实验 fixture，同时让 AngelscriptWiki 的默认入口、工作流和展示方向自洽。

## What Changes

- 保留 `Wiki/src/plugin-name/`，但从默认开发、测试、构建和发布流程中排除。
- 增加显式 examples 开发、构建和 Playwright 验证入口。
- 将示例 Playwright fixture 与正式 AS Wiki 测试隔离。
- 将站点标题、默认首页和默认 tiddler 归属改为 AngelscriptWiki。
- 保留 theme plugin 对 Vanilla sidebar compatibility 的所有权，以及 config plugin 对站点默认值和启动行为的所有权。
- 增加中英双语、使用者/维护者双轨的 AS 状态、工作流和主题路线文档。
- 离线 plugin library 发布时排除示例 plugin，但继续发布正式 theme、tools 和 config plugins。
- 不修改 Unreal Runtime、AS 编译器、GC、StaticJIT、HotReload 或 DebugServer 实现。

## Capabilities

### New Capabilities

- `example-plugin-isolation`: 保留 Modern.TiddlyDev 示例并将其从默认产品工作流隔离。
- `angelscript-wiki-home`: 提供 AngelscriptWiki 自有的默认站点身份、首页和双轨入口。
- `bilingual-as-workflows`: 提供中英双语的 AS 状态、使用者工作流、维护者工作流和展示主题路线。

### Modified Capabilities

- `reliable-offline-publish`: 离线发布必须排除明确标记的示例 plugin，同时保留正式 source plugins 和完整 HTML 产物。

## Impact

- Wiki 子仓库：`package.json`、Playwright 配置、`src/angelscript-theme/`、`src/angelscript-tools/`、`src/angelscript-wiki-config/`、`wiki/tiddlers/` 和离线发布脚本。
- 宿主仓库：只增加本 OpenSpec 记录；不自动提交当前根仓库已有的 Unreal、Plugin、诊断或文档改动。
- 子仓库提交和宿主 gitlink 更新保持分离；本变更默认不 push 远端。
