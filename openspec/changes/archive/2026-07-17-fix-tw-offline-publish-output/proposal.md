## Why

`Wiki` 的 `publish:offline` 在 Windows 上会提前结束：上游 `tiddlywiki-plugin-dev` 只等待 `index.html` 被创建，不等待内容写入完成，导致发布命令成功但产物为 0 字节。主题变更已经依赖离线发布验证，因此需要在项目层保证发布结果真实可用。

## What Changes

- 将 `Wiki` 的 `publish:offline` 入口切换为项目维护的发布脚本。
- 复用 `tiddlywiki-plugin-dev` 的插件构建和 TiddlyWiki 渲染能力，但等待非空、完整且内容稳定的 HTML 后再清理临时目录。
- 为未在 `tiddlywiki.info` 中声明的离线模板显式预加载 `tiddlywiki/tiddlyweb` 插件。
- 增加离线发布 smoke test，验证命令成功时 `dist/index.html` 非空并包含完整结束标签。
- 不修改 `Wiki/node_modules` 中的第三方依赖实现。

## Capabilities

### New Capabilities

- `reliable-offline-publish`: 为 Wiki 离线发布提供完成感知的 HTML 产物保证。

### Modified Capabilities

None.

## Impact

- `Wiki/package.json` 的 `publish:offline` 脚本。
- 新增 `Wiki/scripts/publish-offline.mjs` 和回归测试。
- Wiki 发布时的临时目录生命周期与失败退出行为。
- 不改变插件打包格式、Wiki 内容或第三方依赖版本。
