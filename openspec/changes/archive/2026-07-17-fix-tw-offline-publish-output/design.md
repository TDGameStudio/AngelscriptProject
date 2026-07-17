## Context

`tiddlywiki-plugin-dev@0.5.12` 的离线发布函数启动 TiddlyWiki 渲染后，使用仅检查 `fs.existsSync` 的等待器。Windows 文件系统会先创建目标文件再异步写入内容，等待器因此立即返回，发布函数随后删除临时 Wiki，留下空的 `dist/index.html`。此外，当前 Wiki 的 `tiddlywiki.info` 没有列出 `tiddlywiki/tiddlyweb`，而上游离线模板正是该插件提供的；未预加载模板时渲染结果本身也为空。直接修改 `node_modules` 不可维护，也会在重新安装依赖后丢失。

## Goals / Non-Goals

**Goals:**

- 保持现有 `publish:offline` 参数和输出路径兼容。
- 复用上游插件收集、构建库和 TiddlyWiki 渲染逻辑。
- 显式预加载离线渲染所需的 `tiddlywiki/tiddlyweb` 模板插件。
- 只有在目标 HTML 非空、包含完整 `</html>` 且连续检查内容稳定后才清理临时目录并返回成功。
- 在发布失败或超时后返回非零退出码，并保留可诊断错误。

**Non-Goals:**

- 不修改 `Wiki/node_modules` 或 fork 第三方包。
- 不重写在线发布流程。
- 不改变主题、配置插件或 Wiki tiddler 内容。
- 不引入新的运行时依赖。

## Decisions

### 1. 项目层包装而非依赖补丁

`Wiki/scripts/publish-offline.mjs` 复制上游离线发布所需的最小编排，并从 `tiddlywiki-plugin-dev` 复用 `buildLibrary` 和 TiddlyWiki 工具。脚本把 `tiddlywiki/tiddlyweb` 作为预加载插件传给独立渲染实例。这样锁定修复范围，同时允许依赖升级而不修改安装产物。直接 patch `node_modules` 会被安装流程覆盖；只在命令后轮询文件也无法阻止上游过早删除临时目录。

### 2. 基于内容的完成条件

发布脚本轮询目标文件的 `stat.size`、读取内容并检查 `</html>`，随后等待一个短稳定窗口确认大小和内容不再变化。轮询设置有限超时，超时抛错而不是静默成功。这个条件覆盖“文件存在但仍在写入”的 Windows 行为，也能识别渲染异常产生的空或截断文件。

### 3. 保持命令兼容

`package.json` 继续暴露 `npm run publish:offline`，仅将命令实现替换为 `npm run clean && node scripts/publish-offline.mjs`。脚本默认使用 `wiki`、`dist`、`index.html`、`src`，并保留上游的 `- [is[draft]]` 发布过滤器和插件库生成行为。

## Risks / Trade-offs

- [上游内部 API 变动] 包装脚本依赖 `tiddlywiki-plugin-dev` 当前导出和内部路径 → 在脚本中集中导入并由 smoke test 尽早发现升级不兼容。
- [内容稳定窗口增加等待时间] 发布会比单纯存在检查稍慢 → 仅在 HTML 已完整后再等待短窗口，并设置有限超时。
- [异常渲染留下部分输出] 失败时可能保留 `dist/index.html` 便于诊断 → 命令开头仍由 `clean` 清理，后续发布会重建输出。

## Migration Plan

1. 添加 smoke test 并确认当前上游命令生成 0 字节文件。
2. 添加项目层发布脚本并切换 `package.json` 入口。
3. 运行 Wiki check/build、离线发布 smoke test 和 OpenSpec 严格校验。

回滚只需恢复 `publish:offline` 脚本指向上游命令并删除包装脚本；不涉及持久化数据迁移。

## Open Questions

无。
