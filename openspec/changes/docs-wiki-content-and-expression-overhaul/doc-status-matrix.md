# 文档状态矩阵（doc-status-matrix）

> 本 change 的**单一事实来源**与优先级看板。列出 `wiki/tiddlers/docs/zh-Hans/` 全部正式中文文档。
> 维护者可随时在此调整「目标状态」与「待办摘要」来驱动分批推进。每批推进后用只读命令回填。

## 图例

- ⬜ `placeholder`　🟡 `draft`　🔵 `reviewed`　✅ `published`

## 首轮盘点汇总（2026-07-30）

| 状态 | 数量 |
|------|------|
| ⬜ placeholder | 30 |
| 🟡 draft | 56 |
| 🔵 reviewed | 4 |
| ✅ published | 0 |
| **合计** | **90** |

> 进度：已用表现组件重写并推进 **11 篇 landing/draft**。
> 第一批（6 篇）：language/index、unreal-language/index、unreal-core/index、hot-reload/index、language/classes-inheritance-interfaces、bindings-uht-extensions/index。
> 第二批（5 篇 placeholder→draft）：runtime-jit-vm/index、type-object-reflection/index、compile-module-preprocessor/index、testing-diagnostics-release/index、reference-differences-version/index。
> topics-integrations/index 加了打包边界 callout 但保持 placeholder（其 `<$list>` 集成目录待子页补 `as-integration-kind`）；editor-ide-debugging、architecture-maintenance、showcase-lab 因无实际子文档暂留 placeholder。

统计口径（只读命令，`Wiki/wiki/tiddlers/docs/zh-Hans` 下）：
`grep -rh '^as-content-status:' . | sort | uniq -c`。

## getting-started

| as-doc-key | 状态 | depth | kind | 目标 | 待办摘要 |
|---|---|---|---|---|---|
| start/index | 🔵 | L0 | tutorial | ✅ | 复核后发布 |
| unreal-core/first-actor-blueprint | 🔵 | L1 | tutorial | ✅ | 复核后发布 |

## language-basics

| as-doc-key | 状态 | depth | kind | 目标 | 待办摘要 |
|---|---|---|---|---|---|
| language/index | 🟡 | L0 | guide | 🔵 | 已重写为卡片网格+callout（rev1）；待审阅 |
| language/basic-types-variables | 🔵 | L1 | tutorial | ✅ | 复核后发布 |
| language/functions-control-flow | 🔵 | L1 | tutorial | ✅ | 复核后发布 |
| language/classes-inheritance-interfaces | 🟡 | L2 | guide | 🔵 | 已加行号高亮代码+callout（rev1）；待审阅 |
| language/containers-enums | 🟡 | L2 | guide | 🔵 | 补示例+复核 |
| language/handles-references-casts | 🟡 | L2 | guide | 🔵 | 补示例+复核 |
| language/syntax-reference | 🟡 | L2 | reference | 🔵 | 表格化+复核 |

## script-features

| as-doc-key | 状态 | depth | kind | 目标 | 待办摘要 |
|---|---|---|---|---|---|
| unreal-language/index | 🟡 | L0 | guide | 🔵 | 已重写为卡片网格+callout（rev1）；待审阅 |
| unreal-language/first-feature-path | ⬜ | L1 | tutorial | 🟡 | 起草上手路径 |
| unreal-language/boundaries-and-differences | ⬜ | L3 | guide | 🟡 | 起草边界说明 |
| unreal-language/feature-catalog | 🟡 | L2 | reference | 🔵 | 由正式记录派生 |
| unreal-language/access-specifiers | 🟡 | L2 | reference | 🔵 | 表格化+示例 |
| unreal-language/default-component | 🟡 | L2 | reference | 🔵 | 表格化+示例 |
| unreal-language/default-statement | 🟡 | L2 | reference | 🔵 | 表格化+示例 |
| unreal-language/delegate-event | 🟡 | L2 | reference | 🔵 | 表格化+示例 |
| unreal-language/f-instanced-struct | 🟡 | L2 | reference | 🔵 | 表格化+示例 |
| unreal-language/formatted-strings | 🟡 | L2 | reference | 🔵 | 表格化+示例 |
| unreal-language/fname-literals | 🟡 | L2 | guide | 🔵 | 补示例+复核 |
| unreal-language/mixin | 🟡 | L2 | reference | 🔵 | 表格化+示例 |
| unreal-language/property-accessor | 🟡 | L2 | reference | 🔵 | 表格化+示例 |
| unreal-language/tarray | 🟡 | L2 | reference | 🔵 | 表格化+示例 |
| unreal-language/tmap | 🟡 | L2 | reference | 🔵 | 表格化+示例 |
| unreal-language/toptional | 🟡 | L2 | reference | 🔵 | 表格化+示例 |
| unreal-language/tset | 🟡 | L2 | reference | 🔵 | 表格化+示例 |
| unreal-language/tsoftobjectptr | 🟡 | L2 | reference | 🔵 | 表格化+示例 |
| unreal-language/tsubclassof | 🟡 | L2 | reference | 🔵 | 表格化+示例 |
| unreal-language/tweakobjectptr | 🟡 | L2 | reference | 🔵 | 表格化+示例 |
| unreal-language/ufunction | 🟡 | L2 | reference | 🔵 | 表格化+示例 |
| unreal-language/uproperty | 🟡 | L2 | reference | 🔵 | 表格化+示例 |

## unreal-development

| as-doc-key | 状态 | depth | kind | 目标 | 待办摘要 |
|---|---|---|---|---|---|
| unreal-core/index | 🟡 | L0 | tutorial | 🔵 | 已重写为卡片网格+callout（rev1）；待审阅 |
| unreal-core/actors-components-defaults | 🟡 | L1 | guide | 🔵 | 补示例+复核 |
| unreal-core/function-libraries | 🟡 | L1 | guide | 🔵 | 补示例+复核 |
| unreal-core/subsystems | 🟡 | L2 | guide | 🔵 | 补示例+复核 |
| unreal-language/cpp-blueprint-differences | 🟡 | L2 | explanation | 🔵 | 对比表+复核 |
| topics-integrations/index | ⬜ | L0 | reference | 🟡 | 已加打包边界 callout（rev1）；集成目录待子页补 as-integration-kind |
| topics-integrations/ai-behavior-tree | ⬜ | L0 | guide | 🟡 | 起草集成页 |
| topics-integrations/enhanced-input | ⬜ | L0 | guide | 🟡 | 起草集成页 |
| topics-integrations/gameplay-tags | ⬜ | L0 | guide | 🟡 | 起草集成页 |
| topics-integrations/gas | ⬜ | L0 | guide | 🟡 | 起草集成页 |
| topics-integrations/networking-rpc | ⬜ | L0 | guide | 🟡 | 起草集成页 |
| topics-integrations/ui-umg | ⬜ | L0 | guide | 🟡 | 起草集成页 |

## bindings-extensions

| as-doc-key | 状态 | depth | kind | 目标 | 待办摘要 |
|---|---|---|---|---|---|
| bindings-uht-extensions/index | 🟡 | L0 | guide | 🔵 | 已加 callout+修正 WikiText 加粗（rev1）；待审阅 |
| bindings-uht-extensions/automatic-bindings | 🟡 | L1 | tutorial | 🔵 | 补示例+复核 |
| bindings-uht-extensions/manual-bindings | 🟡 | L3 | guide | 🔵 | 补示例+复核 |
| bindings-uht-extensions/cpp-script-mixins | 🟡 | L2 | tutorial | 🔵 | 补示例+复核 |
| bindings-uht-extensions/exposure-metadata | 🟡 | L2 | reference | 🔵 | 表格化+复核 |
| bindings-uht-extensions/binding-diagnostics | 🟡 | L2 | guide | 🔵 | 补示例+复核 |
| bindings-uht-extensions/binding-call-paths | 🟡 | L3 | explanation | 🔵 | 补证据链 |
| bindings-uht-extensions/calling-conventions | 🟡 | L4 | internals | 🔵 | 补 internals 证据链 |
| bindings-uht-extensions/uht-plugin-overview | ⬜ | L1 | guide | 🟡 | 补齐六段 |
| bindings-uht-extensions/uht-generation-workflow | ⬜ | L2 | reference | 🟡 | 补齐六段 |
| bindings-uht-extensions/uht-plugin-internals | ⬜ | L4 | internals | 🟡 | 补齐六段+源码入口 |
| bindings-uht-extensions/uht-plugin-maintenance | ⬜ | L5 | internals | 🟡 | 补齐六段+源码入口 |

## workflow-validation

| as-doc-key | 状态 | depth | kind | 目标 | 待办摘要 |
|---|---|---|---|---|---|
| compile-module-preprocessor/editor-only-script | 🟡 | L2 | guide | 🔵 | 补示例+复核 |
| editor-ide-debugging/index | ⬜ | L0 | guide | 🟡 | 补齐 landing 六段 |
| hot-reload/index | 🟡 | L0 | guide | 🔵 | 已重写为卡片网格+callout（rev1）；待审阅 |
| hot-reload/daily-workflow | ⬜ | L1 | tutorial | 🟡 | 起草日常流程 |
| hot-reload/change-classification | ⬜ | L2 | reference | 🟡 | 起草分类表 |
| hot-reload/failures-and-recovery | ⬜ | L3 | guide | 🟡 | 起草失败恢复 |
| hot-reload/reload-pipeline-internals | ⬜ | L4 | internals | 🟡 | 补齐六段+源码入口 |
| hot-reload/source-tests-maintenance | ⬜ | L5 | internals | 🟡 | 补齐六段+源码入口 |
| testing-diagnostics-release/index | 🟡 | L0 | guide | 🔵 | 已重写为卡片网格+callout（rev1）；待审阅 |
| testing-diagnostics-release/script-tests | 🟡 | L1 | guide | 🔵 | 补示例+复核 |
| showcase-lab/index | ⬜ | L0 | guide | 🟡 | 补齐 landing 六段 |

## internals-reference

| as-doc-key | 状态 | depth | kind | 目标 | 待办摘要 |
|---|---|---|---|---|---|
| architecture-maintenance/index | ⬜ | L0 | explanation | 🟡 | 补齐 landing 六段 |
| compile-module-preprocessor/index | 🟡 | L0 | explanation | 🔵 | 已重写为卡片网格+callout（rev1）；待审阅 |
| compile-module-preprocessor/compiler | 🟡 | L4 | internals | 🔵 | 补 internals 证据链 |
| compile-module-preprocessor/parser | 🟡 | L4 | internals | 🔵 | 补 internals 证据链 |
| type-object-reflection/index | 🟡 | L0 | explanation | 🔵 | 已重写为卡片网格+callout（rev1）；待审阅 |
| type-object-reflection/type-registration | 🟡 | L4 | internals | 🔵 | 补 internals 证据链 |
| runtime-jit-vm/index | 🟡 | L0 | explanation | 🔵 | 已重写为卡片网格+callout（rev1）；待审阅 |
| runtime-jit-vm/script-engine | 🟡 | L4 | internals | 🔵 | 补 internals 证据链 |
| runtime-jit-vm/virtual-machine | 🟡 | L4 | internals | 🔵 | 补 internals 证据链 |
| runtime-jit-vm/bytecode | 🟡 | L4 | internals | 🔵 | 补 internals 证据链 |
| runtime-jit-vm/object-lifecycle | 🟡 | L4 | internals | 🔵 | 补 internals 证据链 |
| runtime-jit-vm/garbage-collector | 🟡 | L4 | internals | 🔵 | 补 internals 证据链 |
| runtime-jit-vm/string-factory | 🟡 | L4 | internals | 🔵 | 补 internals 证据链 |
| reference-differences-version/index | 🟡 | L0 | reference | 🔵 | 已重写为卡片网格+callout（rev1）；待审阅 |
| reference-differences-version/fork-differences | 🟡 | L3 | reference | 🔵 | 表格化+复核 |
| reference-differences-version/hazelight-comparison-overview | ⬜ | L0 | guide | 🟡 | 需 revision 证据 |
| reference-differences-version/hazelight-capability-matrix | ⬜ | L2 | reference | 🟡 | 需 revision 证据 |
| reference-differences-version/hazelight-architecture-differences | ⬜ | L4 | internals | 🟡 | 需 revision 证据 |
| reference-differences-version/hazelight-class-generation | ⬜ | L4 | internals | 🟡 | 需 revision 证据 |
| reference-differences-version/hazelight-function-binding | ⬜ | L4 | internals | 🟡 | 需 revision 证据 |
| reference-differences-version/hazelight-struct-generation | ⬜ | L4 | internals | 🟡 | 需 revision 证据 |
| reference-differences-version/hazelight-audit-maintenance | ⬜ | L5 | internals | 🟡 | 需 revision 证据 |
| unreal-language/feature-implementation-principles | ⬜ | L4 | internals | 🟡 | 补齐六段+源码入口 |
| unreal-language/source-tests-maintenance | ⬜ | L5 | internals | 🟡 | 补齐六段+源码入口 |

> 注：`nav-group` 归属取自各 `.tid` 当前 `as-nav-group` 字段；`§3 结构重构` 若调整归属需同步更新本表分组。
