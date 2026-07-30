# Authoring Contract Examples

Captured: 2026-07-25

These examples are design fixtures for the later implementation. They use TiddlyWiki 5 `.tid` field syntax and WikiText bodies. The implementation must run them through the source-contract parser and the locked TiddlyWiki 5.4.1 runtime before treating them as canonical templates.

## Naming and identity

```text
File:        Wiki/wiki/tiddlers/docs/<locale>/<topic>/<slug>.tid
Title:       AS/Docs/<locale>/<topic>/<slug>
Logical key: <topic>/<slug>
```

The filename is source organization. The `title` field is TiddlyWiki identity. Chinese and English have different titles but the same `as-doc-key`.

## Chinese reviewed document

```text
title: AS/Docs/zh-Hans/unreal-language/default-statement
type: text/vnd.tiddlywiki
tags: ASWiki/Docs/unreal-language
caption: default 语句
description: 说明 default 语句的用途、边界以及它与 Unreal 默认对象构造的关系。
as-sdk-document: yes
as-doc-key: unreal-language/default-statement
as-locale: zh-Hans
as-depth: L2
as-doc-kind: guide
as-content-status: reviewed
as-order: 30
as-content-revision: 3
as-sources: as-knowledge.syntax-default-statement as-example.core-construction-script

! 你会学到什么

...
```

Rules:

- exactly one primary documentation topic tag;
- `as-content-revision` is incremented when reviewed meaning changes;
- `as-sources` contains registered stable keys, not absolute paths;
- secondary topic tags are added only for real navigation value.

## Chinese placeholder

```text
title: AS/Docs/zh-Hans/hot-reload/reload-pipeline-internals
type: text/vnd.tiddlywiki
tags: ASWiki/Docs/hot-reload
caption: 热重载管线实现原理
description: 规划从文件变化到类重实例化和 Blueprint 影响处理的完整机制说明。
as-sdk-document: yes
as-doc-key: hot-reload/reload-pipeline-internals
as-locale: zh-Hans
as-depth: L4
as-doc-kind: internals
as-content-status: placeholder
as-order: 50
as-content-revision: 0
as-sources: as-knowledge.rt-hot-reload as-source.runtime-class-reload-planner as-source.editor-class-reload-helper

! 本章要解决什么

解释一次脚本文件变化如何经过聚合、依赖分析、编译、reload plan、类生成、CDO/default component 处理、实例迁移和 Blueprint 影响分析。

! 计划内容

# 文件监听与变化聚合
# 依赖与软/完整重载分类
# ClassGenerator 与 ClassReloadHelper 分工
# CDO、默认组件和实例迁移
# BlueprintImpact、失败恢复与清理

! 已知资料

* `RT_HotReload.md`
* 当前 HotReload、ClassGenerator 与 BlueprintImpact 测试

! 源码入口

* `AngelscriptClassReloadPlanner`
* `AngelscriptClassGenerator_ReloadPlanning.cpp`
* `ClassReloadHelper.cpp`

! 依赖与相关页面

* <<as-doc-link "hot-reload/change-classification" "变化分类">>
* <<as-doc-link "type-object-reflection/class-generation" "类生成">>

! 审阅状态

本页只记录已确认的范围和证据入口，正文尚未完成技术审阅，不能作为行为保证或完成度依据。
```

Placeholder rules:

- `as-content-revision: 0` is allowed only for `placeholder` or `draft`;
- every required section contains topic-specific information;
- placeholder text is never copied into an English page solely to fill the locale tree;
- completion statistics exclude it.

## English reviewed translation

```text
title: AS/Docs/en-GB/unreal-language/default-statement
type: text/vnd.tiddlywiki
tags: ASWiki/Docs/unreal-language
caption: default statements
description: Explains default statements, their limits, and their relationship to Unreal default-object construction.
as-sdk-document: yes
as-doc-key: unreal-language/default-statement
as-locale: en-GB
as-depth: L2
as-doc-kind: guide
as-content-status: reviewed
as-order: 30
as-content-revision: 1
as-sources: as-knowledge.syntax-default-statement as-example.core-construction-script
as-translation-of: AS/Docs/zh-Hans/unreal-language/default-statement
as-translation-revision: 3
as-translation-status: reviewed

! What you will learn

...
```

English rules:

- the Chinese page exists and is `reviewed` or `published`;
- `as-translation-revision` equals the Chinese `as-content-revision` when reviewed;
- English has its own `as-content-revision` for English editorial history;
- after Chinese revision 4, this page remains readable but becomes `stale` until re-reviewed.

## Internals document

```text
title: AS/Docs/zh-Hans/compile-module-preprocessor/parser-and-ast
type: text/vnd.tiddlywiki
tags: ASWiki/Docs/compile-module-preprocessor
caption: 解析器与 AST 实现原理
description: 从源码 token 到语法节点、源范围和后续编译阶段的可验证路径。
as-sdk-document: yes
as-doc-key: compile-module-preprocessor/parser-and-ast
as-locale: zh-Hans
as-depth: L4
as-doc-kind: internals
as-content-status: reviewed
as-order: 40
as-content-revision: 1
as-sources: as-source.kernel-parser as-source.kernel-scriptnode as-test.frontend-parser-shape

! 可观察行为与边界

...

! 管线与状态模型

...

! 关键数据结构

...

! 稳定源码入口

...

! 最小跟踪实验

...

! 失败模式与诊断

...

! 回归证据

...
```

Internals rules:

- `internals` normally uses L4/L5;
- source and test evidence is mandatory for `reviewed`/`published`;
- inferred behavior is labeled as inference;
- a diagram complements but does not replace the text/source/test trail;
- an interactive experiment belongs to Showcase Lab until it graduates.

## Hazelight comparison page and catalog row

The page records its shared baselines and consumes relationship rows from one machine-readable catalog:

```text
title: AS/Docs/zh-Hans/reference-differences-version/hazelight-function-binding
type: text/vnd.tiddlywiki
tags: [[ASWiki/Docs/reference-differences-version]] [[ASWiki/Docs/reference-differences-version/hazelight]]
caption: Hazelight 函数绑定架构对比
description: 对比 Hazelight 引擎 UHT 指针映射与本地独立 UHTTool/反射回退路径。
as-sdk-document: yes
as-doc-key: reference-differences-version/hazelight-function-binding
as-locale: zh-Hans
as-depth: L4
as-doc-kind: internals
as-content-status: placeholder
as-order: 30
as-content-revision: 0
as-sources: as-hazelight-source.uht-function-pointers as-hazelight-source.plugin-blueprint-callable as-source.uht-binding-generator as-source.uht-binding-policy
as-hazelight-revision: f459e6322f63deef8d345f1c1624734cc22747e3
as-local-revision: 4e2e23ca16ae9f1786258fb96b09b268259b1aad
as-comparison-date: 2026-07-25

! 本章要解决什么

...
```

The shared `AS/Docs/Data/HazelightComparisonCatalog` is an `application/json` tiddler. A row has this shape:

```json
{
  "id": "binding.generated-native-function-pointers",
  "family": "function-binding",
  "title": "原生 UFunction 指针生成与注册",
  "relationship": "reimplemented",
  "confidence": "verified",
  "hazelightRevision": "f459e6322f63deef8d345f1c1624734cc22747e3",
  "localRevision": "4e2e23ca16ae9f1786258fb96b09b268259b1aad",
  "comparedOn": "2026-07-25",
  "unrealVersion": "Hazelight current branch vs local UE 5.7 baseline",
  "hazelightEvidence": [
    "as-hazelight-source.uht-function-pointers",
    "as-hazelight-source.plugin-blueprint-callable"
  ],
  "localEvidence": [
    "as-source.uht-binding-generator",
    "as-source.uht-binding-policy"
  ],
  "userConsequence": "多数受支持原生调用均有直接路径，但两边的不可绑定/回退集合不同。",
  "maintenanceConsequence": "Hazelight 维护引擎 UHT/CoreUObject 补丁；本地维护独立 UHTTool、生成分片和版本化桥接。",
  "disposition": "document-current-design",
  "benchmarkEvidence": [],
  "detailDocKey": "reference-differences-version/hazelight-function-binding"
}
```

Comparison rules:

- detailed pages and the matrix render the same catalog record;
- both revisions are full 40-hex identities for a source-level comparison;
- restricted `as-hazelight-source.*` keys expose metadata/purpose but no private excerpt;
- `benchmarkEvidence` is required when a reviewed row claims relative speed or equal cost;
- changing either baseline marks affected rows stale until re-audited;
- `future-candidate` is documentation status, not permission to modify plugin or engine code.

## Compatibility entry

```text
title: AS/Workflow/AuthoringAndHotReload
type: text/vnd.tiddlywiki
caption: 编译与热重载
description: 旧入口；内容将按新的热重载章节逐步迁移。
as-sdk-document: yes
as-page-role: compatibility

! 此页面已映射到新目录

请从 <<as-doc-link "hot-reload/index" "热重载与实时迭代">> 进入新的章节结构。以下旧内容在迁移完成前保留，且不计入已审阅文档数量。

...
```

Compatibility rules:

- only exact pre-foundation titles on the allowlist may use the role;
- it carries none of the six retired tags;
- it preserves the old canonical title and useful body until a later migration records coverage;
- new articles cannot use the role.

## Home and navigation shells

```text
title: AngelscriptWikiHome
type: text/vnd.tiddlywiki
caption: AngelscriptWiki
description: Unreal Engine AngelScript 文档入口。
as-sdk-document: yes
as-page-role: home

...
```

Home has no `ASWiki/Home` tag. Navigation uses `as-page-role: navigation`; its lists are derived from topic metadata rather than represented as a content category tag.

## Showcase page

```text
title: Markdown 基础示例
type: text/markdown
tags: ASWiki/Showcase/Base ASWiki/Docs/showcase-lab
caption: Markdown 基础示例
description: 检查 Markdown 常用元素的稳定渲染与响应式边界。
as-sdk-document: yes
as-doc-key: showcase-lab/markdown-basic
as-locale: zh-Hans
as-depth: L1
as-doc-kind: showcase
as-content-status: reviewed
as-order: 10
as-content-revision: 1
as-sources: as-wiki.markdown-basic-showcase
as-showcase-id: B01
as-showcase-tier: Base
as-showcase-purpose: 主题和文档布局变化时的 Markdown 基础渲染回归目标。

# Markdown 基础示例

...
```

Showcase rules:

- exactly one tier tag;
- one primary docs topic tag may coexist with the tier tag;
- `as-showcase-tier` exactly matches the tag suffix;
- `as-showcase-purpose` states the documentation expression or regression purpose;
- catalog-only items do not receive empty page files.

The first catalog also contains B13–B15, P15–P16, and L11 from `tiddlywiki-expression-showcase.md`. Those records stay `gap`/`experiment` until their native TiddlyWiki, trusted HTML, iframe fallback, security, offline, and browser acceptance behavior has an implemented page. Catalog presence alone is not feature completion.

## Logical link authoring

Static titles may use ordinary TiddlyWiki links:

```text
[[文档目录|AS/Docs]]
```

Locale-aware document links use the global procedure:

```text
<<as-doc-link "unreal-language/default-statement" "default 语句">>
```

Dynamic targets must render through `<$link>` inside the procedure. Do not attempt variable expansion inside `[[label|target]]` shortcut syntax.

## Source reference rendering

A page records source semantics through stable keys:

```text
as-sources: as-source.kernel-parser as-test.frontend-parser-shape
```

A future source component may render a selected excerpt:

```text
<<as-source-excerpt "as-source.kernel-parser">>
```

The component contract is not implemented in the first taxonomy tranche. When implemented, it must show pinned repository/revision/path/license metadata, link to the exact GitHub commit, use only generated bounded excerpts, and present stale/broken status explicitly.

## Content revision rules

| State | `as-content-revision` |
|---|---|
| `placeholder` | `0` |
| `draft` | `0` or a positive working revision |
| `reviewed` | positive integer |
| `published` | positive integer |

Increment the Chinese revision for a reviewed semantic change: behavior, supported versions, requirements, examples, warnings, or conclusions. Typographic fixes that cannot alter meaning may retain the revision, but the reviewer should favor incrementing when English synchronization could reasonably be affected.
