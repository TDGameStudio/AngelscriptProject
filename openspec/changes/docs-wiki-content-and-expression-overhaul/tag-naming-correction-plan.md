# Wiki Tag 命名收口实施计划

> 日期：2026-08-01
> 范围：修正 3.1 的最终产品 Tag 模型；不改变 `$:/ASWiki/**` 系统 tiddler、`AS/Docs/**` / `AS/Showcase/**` 内容标题，也不处理本工作区其他未提交改动。

## 目标

- 正式文档继续使用 TiddlyWiki 原生 `tags` 字段分类，但主题 Tag 采用 UE 风格 PascalCase，不再增加 `ASWiki/` 或 `Docs/` 根。
- 主题键字段 `as-topic-key` 保持稳定的 kebab-case 数据键；Tag 标题由主题定义 tiddler 提供，例如 `hot-reload` → `HotReload`、`bindings-uht-extensions` → `BindingsUhtExtensions`。
- 读者导航定义仅由 `as-nav-key` 发现，不再使用没有分类价值的 `ReaderNav` Tag。
- 保留真正表达层级分类的 `Showcase/*`，包括 `Showcase/Base`、`Showcase/Pattern`、`Showcase/Lab`、`Showcase/Detail` 和 `Showcase/LayoutExperiment`。
- 不提供旧 `ASWiki/*`、`Docs/*` 或 `ReaderNav` 的 alias/双读兼容；契约直接拒绝旧值和未注册产品 Tag。

## 精确映射

| `as-topic-key` | 最终 Tag |
|---|---|
| `start` | `Start` |
| `language` | `Language` |
| `unreal-language` | `UnrealLanguage` |
| `type-object-reflection` | `TypeObjectReflection` |
| `unreal-core` | `UnrealCore` |
| `compile-module-preprocessor` | `CompileModulePreprocessor` |
| `hot-reload` | `HotReload` |
| `editor-ide-debugging` | `EditorIdeDebugging` |
| `testing-diagnostics-release` | `TestingDiagnosticsRelease` |
| `runtime-jit-vm` | `RuntimeJitVm` |
| `bindings-uht-extensions` | `BindingsUhtExtensions` |
| `architecture-maintenance` | `ArchitectureMaintenance` |
| `topics-integrations` | `TopicsIntegrations` |
| `reference-differences-version` | `ReferenceDifferencesVersion` |
| `showcase-lab` | `ShowcaseLab` |
| `reference-differences-version/hazelight` | `ReferenceDifferencesVersion/Hazelight` |

`IDE`、`JIT`、`VM`、`UHT` 在组合标识符中按 UE 常见 PascalCase 单词风格写作 `Ide`、`Jit`、`Vm`、`Uht`，避免全大写缩写破坏统一的标识符形态。

## TDD 与实现步骤

1. 在 `Wiki/scripts/document-content-contract.test.mjs` 先增加一个契约测试：`Start` 是合法主主题 Tag，`Docs/start` 被拒绝；运行定向 Node 测试并确认当前实现因仍要求 `Docs/start` 而失败。
2. 重构 `Wiki/scripts/document-content-contract.mjs`：
   - 从带 `as-topic-key` 的主题定义建立 `topicKey → Tag title` 映射；测试夹具缺少定义时使用确定性的 UE PascalCase 转换。
   - 合法产品 Tag 仅为已注册主题 Tag、这些主题的已定义子 Tag，以及 `Showcase` / `Showcase/*`。
   - 主主题校验按映射后的 Tag 工作；完整仓库模式继续校验定义元数据、父定义与无环关系。
3. 更新 `Wiki/scripts/generate-knowledge-pages.mjs`，生成的 `tags` 使用同一 UE PascalCase 转换；更新生成器测试期望。
4. 迁移 `Wiki/wiki/tiddlers/**` 和 `Wiki/tests/**` 中所有产品主题 Tag；删除 `docs/taxonomy/root.tid` 与 `docs/navigation/root.tid`，并移除主题定义上的 `tags: Docs`、导航定义上的 `tags: ReaderNav`。
5. 将 `AS/Navigation`、`AS/Docs/DocumentationDirectory`、`AS/Docs/InternalsDirectory` 的定义发现过滤器改成 `[has[as-nav-key]...]` / `[has[as-topic-key]...]`，同步浏览器测试断言。
6. 先更新 `AGENTS_ZH.md`，再更新 `AGENTS.md`；同步当前 OpenSpec proposal/design/spec/tasks，明确最终模型并清除中间 `Docs|ReaderNav` 方案。

## 验证命令

在 `Wiki/` 下运行：

```powershell
node --test scripts/document-content-contract.test.mjs
node scripts/generate-knowledge-pages.mjs --project-root .. --wiki-root .
pnpm exec eslint --quiet scripts/document-content-contract.mjs scripts/document-content-contract.test.mjs scripts/generate-knowledge-pages.mjs
pnpm run test:feature -- sidebar
pnpm run test:feature -- document
pnpm run test:feature -- i18n
pnpm run test:fast
```

在父仓库运行静态审计，要求：

- 产品 Tag 中不存在 `ASWiki/*`、`Docs`、`Docs/*`、`ReaderNav` 或 `ReaderNav/*`。
- 所有主题定义标题均与上表完全一致，且 Tag 引用都有定义、带 `caption`/`description`。
- `ReferenceDifferencesVersion/Hazelight` 的父定义存在；`Showcase/*` 的父定义存在；定义关系无环。
- `git diff --check` 通过；若完整测试仍受既有非本轮错误阻塞，验证记录必须列出精确失败，不宣称 release 全绿。
