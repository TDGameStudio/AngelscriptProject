# 正式源码注解 Flow 验证（2026-07-31）

## 范围

- 正式 `<$annotated-code>` / `<$angelscript-code>` 不再创建、预留或覆盖右侧 note rail。
- 自动落位顺序固定为目标行尾、邻近空白行、源码上方 shelf；源码 DOM 与复制文本保持连续。
- 默认隐藏源码行号、note 序号与披露箭头；保留显式 `lineNumbers="yes"`。
- connector 默认在源码墨迹下层，打开详情时只提升当前关系；note 与 source mark 同步横向滚动。
- `noteStyle="comment|muted|ink"` 提供三种 Wiki 匹配短注视觉语气。
- `detailTiddler` 支持独立 Wiki 详情、缺失目标内联回退和 compact/reading/rich 自适应详情面。
- P02–P04 已迁移；任务 2.18 的四个旧 AnnotationPlacement Lab 保留并继续回归。

## TDD 红灯

首次运行新增 `tests/playwright/product/code/annotation-flow.spec.ts` 时，8 个场景按预期失败，分别暴露旧生产 rail、缺失 flow placement、note 序号/箭头、默认 gutter、横向滚动脱离、缺失 `detailTiddler`、缺失 fallback 和窄屏详情过小。三样式对照页在页面尚未创建时也以 `0 != 3` 按预期失败。

## 通过项

### 类型与定向规范

```powershell
& npm.cmd exec --yes --package node@24 --package pnpm@11.8.0 -- pnpm run check
& npm.cmd exec --yes --package node@24 --package pnpm@11.8.0 -- pnpm exec eslint src/angelscript-tools/index.ts tests/playwright/product/code/annotated-code.spec.ts tests/playwright/product/code/annotation-flow.spec.ts tests/playwright/product/code/annotation-layout-lab.spec.ts
```

结果：PASS。

### Code domain 与旧 Lab 回归

```powershell
& npm.cmd exec --yes --package node@24 --package pnpm@11.8.0 -- pnpm exec playwright test tests/playwright/product/code/annotated-code.spec.ts tests/playwright/product/code/annotation-layout-lab.spec.ts tests/playwright/product/code/annotation-flow.spec.ts
```

结果：`33 passed`。覆盖源码 DOM/复制不变、精确 range、行范围仅源码字符下划线、flow 三段落位、无碰撞、默认无行号、横向/纵向滚动、Popover 与 fixed fallback、详情 tiddler、窄屏 rich 详情、打印、reduced-motion，以及四个旧 Lab。

### 文档合同

```powershell
& npm.cmd exec --yes --package node@24 --package pnpm@11.8.0 -- pnpm run test:document-content
```

结果：`48 passed`。

### Wiki runtime 与离线单文件

```powershell
& npm.cmd exec --yes --package node@24 --package pnpm@11.8.0 -- pnpm run test:runtime
& npm.cmd exec --yes --package node@24 --package pnpm@11.8.0 -- pnpm run build:wiki
```

结果：runtime `1 spec, 0 failures`；离线构建生成 `Wiki/dist/index.html`（5,795,796 bytes）。

### OpenSpec

```powershell
openspec validate --type change "docs-wiki-content-and-expression-overhaul" --strict
```

结果：`Change 'docs-wiki-content-and-expression-overhaul' is valid`。

## 已知的工作区外部失败

`pnpm run test:source-boundaries` 仍有两个与本项无关的既存 dirty-worktree 失败：

1. `AS/Navigation` 已被其他未提交改动从旧的 `title="文档入口" links="zh-primary"` 合同迁移；
2. `tests/playwright/product/tools/tiddler-toolbar-hover-prototype.spec.ts` 仍直接包含字符串 `comparison-artifacts`。

本项未修改这两个文件，也没有为通过验证而覆盖维护者的并行改动。

## 人工入口

- 离线单文件：`D:\Workspace\AngelscriptProject\Wiki\dist\index.html`
- 三样式对照：`AS/Showcase/Lab/AnnotationFlowStyles`
- 正式 Pattern：`AS/Showcase/Pattern/P02-LineExplanation`、`P03-KeyPathAnnotations`、`P04-AngelScriptCppBridge`
