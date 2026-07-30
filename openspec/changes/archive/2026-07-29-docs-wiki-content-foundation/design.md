## Context

AngelscriptWiki is an integrated TiddlyWiki 5.4.1 product in the `Wiki/` submodule. It already owns a polished document shell, Chinese and English product language resources, a trailing AS navigation tab, SDK document metadata, UE AngelScript highlighting, line-controlled code cards, Markdown More, Draw.io support, restrained tag-color variants, and product-level browser tests. Those capabilities are sufficient to host a serious knowledge system, but the current reader content remains a small workflow/maintainer outline rather than a complete documentation architecture.

The source material is much larger and comes from different viewpoints:

- `Reference/Docs-UnrealEngine-Angelscript` is the source of the Hazelight website and is checked out at the current remote `master` revision. Its 29 Markdown source files comprise one repository README and 28 site-content pages; they provide a concise user-facing reference, but the repository does not declare a separate documentation-content license.
- `Documents/Knowledges/ZH` contains 73 long Chinese articles. Its own writing rules describe a plugin-maintainer knowledge base, not a reader manual, so most articles need to be split, rewritten, and layered rather than copied.
- `Script/` contains 36 executable or test-oriented `.as` examples.
- The plugin has stable Runtime, Editor, Test, and UHT boundaries plus optional GameplayTags and GAS plugins. The implementation has capabilities that do not exist in the smaller Hazelight website, while some historical knowledge text can be stale against the current fork.
- Several Wiki OpenSpecs are active or completed. Theme, tag presentation, tooling, publishing, line icons, and repository hardening remain outside this content change.

The user wants the Wiki to become the primary documentation surface over time, with Chinese written and reviewed before English, a reading path that works for beginners and deep developers, prominent language-feature and hot-reload explanations, dedicated domain topics, extensive authoring showcases, and durable research notes that future implementation sessions can consult.

## Goals / Non-Goals

**Goals:**

- Define one topic-based information architecture whose chapters progress from orientation to source maintenance.
- Make Unreal AngelScript language features and hot reload/live iteration first-level topics rather than subordinate bullets.
- Give selected chapters an explicit internal-implementation track that explains how AngelScript and the Unreal bridge work, not only how their APIs are used.
- Keep the core learning spine free from optional-plugin and domain-specific integrations while retaining dedicated topic coverage for them.
- Define a paired-document model that supports Chinese-first authoring, independent English review, locale-aware navigation, and stale translation detection.
- Use native TiddlyWiki tags for topic hierarchy while using fields for orthogonal metadata.
- Define a reproducible, license-aware plugin-source corpus for stable citations and generated excerpts without loading the full repository into the initial Wiki page.
- Define useful placeholders that expose intended outcomes and evidence instead of publishing empty pages.
- Turn the current small syntax showcase into a documented Base/Pattern/Lab authoring and experimentation system.
- Preserve a complete, revisioned research record and a source-to-topic migration crosswalk.
- Produce an implementation plan that can be applied later without rediscovering the architecture.

**Non-Goals:**

- Do not edit Wiki product source, current tiddlers, themes, tools, vendor sources, tests, or generated output in this plan-only session.
- Do not migrate, delete, or deprecate `Documents/Knowledges/ZH` in bulk.
- Do not translate articles to English before the corresponding Chinese article is reviewed.
- Do not import Hazelight prose or images wholesale.
- Do not copy the current dirty `Plugins/Angelscript` worktree into the Wiki or fetch a floating branch during ordinary Wiki development, test, or build commands.
- Do not replace TiddlyWiki search, introduce a documentation database, add a runtime translation service, or add a third locale.
- Do not choose a final tag color palette before a later review against actual Wiki pages.
- Do not implement AST, bytecode, VM, coverage, or other experimental visualizations in the foundation change.
- Do not absorb work owned by active Wiki toolchain, visual, icon, publishing, or architecture changes.

## Decisions

### 1. Organize by topic, then progress from shallow to deep

The Wiki will use 15 ordered topics:

1. `start` — 认识与开始
2. `language` — AngelScript 语言基础
3. `unreal-language` — Unreal AngelScript 语言特性
4. `type-object-reflection` — 类型、对象与反射模型
5. `unreal-core` — Unreal 核心脚本编程
6. `compile-module-preprocessor` — 编译、模块与预处理
7. `hot-reload` — 热重载与实时迭代
8. `editor-ide-debugging` — 编辑器、IDE 与调试
9. `testing-diagnostics-release` — 测试、诊断与发布
10. `runtime-jit-vm` — 运行时、StaticJIT 与虚拟机
11. `bindings-uht-extensions` — 绑定、UHT 与插件扩展
12. `architecture-maintenance` — 插件架构与维护
13. `topics-integrations` — 专题与领域集成
14. `reference-differences-version` — 参考、差异、版本与项目
15. `showcase-lab` — Showcase 与实验室

Every topic may contain the same progressive depth vocabulary:

- `L0`: orientation and mental model
- `L1`: first working path
- `L2`: complete use and combinations
- `L3`: boundaries, failures, compatibility, and version differences
- `L4`: implementation mechanisms and data flow
- `L5`: source ownership, tests, diagnostics, and maintenance contracts

This is a vocabulary, not a requirement to manufacture six articles for every small subject. A topic landing page must expose available depths and may link directly to a later level when an intermediate article would be redundant.

Selected topics also expose an `internals` document kind at L4 or L5. These pages form a cross-topic “实现原理” reading track rather than a new top-level bucket. The initial track covers:

- source text, preprocessing, parser/AST, compiler, bytecode, and VM/context execution;
- language-feature lowering or generation paths, including defaults, delegates/events, mixins, f-strings, and FName literals where applicable;
- AngelScript object/type lifetime, garbage collection, and Unreal object/reflection interaction;
- UClass/UStruct generation, binding discovery, UHT emission, calling conventions, marshalling, and reflective fallback;
- hot-reload change detection, dependency decisions, compilation, class replacement, CDO/default-component handling, reinstancing, and Blueprint impact.

An internals page must answer a concrete mechanism question. Its standard evidence shape is: observable behavior and boundary, pipeline or state model, important data structures, stable source entry points, a minimal trace/experiment where practical, failure modes, and regression evidence. It may use code, tables, static diagrams, or a future interactive experiment, but those presentation forms are not themselves the authoritative content. This keeps internals documentation distinct from Showcase: the document explains the system; Showcase only demonstrates a reusable rendering pattern or an experiment surface.

Audience-first top-level portals were rejected because many subjects, especially hot reload and binding, need a continuous path from use to internals. A flat prefix mirror of `Documents/Knowledges/ZH` was rejected because its `Arch_`, `AS_`, `Type_`, and `RT_` prefixes encode maintainer viewpoints rather than reader tasks.

### 2. Give language features and hot reload independent first-level ownership

`unreal-language` covers the fork/Unreal-facing language surface: `UPROPERTY`, `UFUNCTION`, default statements and default components, delegate/event declarations, access specifications, mixins, formatted strings, FName literals, RPC specifiers, Unreal containers and wrapper types, editor/cooked conditions, and removed or divergent language behavior. Basic language syntax remains in `language`; reflection and object generation remain in `type-object-reflection`.

`hot-reload` covers both daily author behavior and the full implementation chain: file watching, change coalescing, preprocessing and dependencies, soft/full reload classification, PIE and restart requirements, compilation events, ClassGenerator, ClassReloadHelper, CDO/default-component behavior, instance migration, Blueprint descendants, BlueprintImpact, failure recovery, diagnostics, global-state cleanup, and regression coverage.

Keeping these as independent topics reflects the product's distinguishing value and prevents their user-facing behavior from being buried in runtime implementation articles.

### 3. Separate the core spine from special topics without misrepresenting implementation

The `topics-integrations` branch initially contains:

- GameplayTags — optional `AngelscriptGameplayTags` plugin
- GAS — optional `AngelscriptGAS` plugin, dependent on GameplayTags
- Enhanced Input — engine-domain integration, not an optional AngelScript plugin
- Networking/RPC — advanced domain topic implemented partly in the core plugin
- UI/UMG — engine-domain integration
- AI/BehaviorTree — engine-domain integration

The taxonomy records an `as-integration-kind` value of `optional-plugin` or `engine-domain` on the topic landing page. Placement in the topic branch means “not part of the core learning path”; it does not claim that every implementation is separately packaged.

Subsystems, Actor/Component behavior, Blueprint interoperability, function libraries, and core editor workflows remain in the main spine because they are general Unreal scripting surfaces.

### 4. Give UHT and Hazelight comparison explicit subchapter ownership

`AngelscriptUHTTool` remains under the core `bindings-uht-extensions` topic because it is part of how the standalone plugin exposes Unreal APIs. Its planned Chinese sequence is:

- `bindings-uht-extensions/uht-plugin-overview` — L1 role, prerequisites, configuration, and when it runs;
- `bindings-uht-extensions/uht-generation-workflow` — L2 inputs, eligibility/policy, shards, aggregators, statistics, cleanup, and fallback;
- `bindings-uht-extensions/uht-plugin-internals` — L4 C# models, policy, emitters, generator orchestration, and Runtime bridge;
- `bindings-uht-extensions/uht-plugin-maintenance` — L5 layout-version bump rules, cross-module invariants, diagnostics, generated artifacts, and tests.

The pages must distinguish the independent C# UBT/UHT plugin from the Runtime UE module, and must distinguish `NativeRuntimeLinked`, `NativeModuleFunctionAddress`, and `BlueprintCallableReflectiveFallback`. RPCs and unsupported marshalling cases remain reflective fallback unless the actual contract changes.

Hazelight comparison is a dedicated nested topic, `ASWiki/Docs/reference-differences-version/hazelight`, under `reference-differences-version`; it is not a single overview page, beginner workflow, or integration plugin. Its initial Chinese pages are:

- `reference-differences-version/hazelight-comparison-overview` — L0 comparison purpose, baselines, and how to read status labels;
- `reference-differences-version/hazelight-capability-matrix` — L2 index across language/runtime/editor/hot-reload/binding/UHT/testing/tooling;
- `reference-differences-version/hazelight-function-binding` — L4 manual/generated/reflective binding architecture and calling-path comparison;
- `reference-differences-version/hazelight-class-generation` — L4 script-class analysis, UClass generation, defaults/CDO, dispatch, and reload comparison;
- `reference-differences-version/hazelight-struct-generation` — L4 UASStruct/ICppStructOps, value lifetime, serialization, engine-patch, and stock-engine compatibility comparison;
- `reference-differences-version/hazelight-architecture-differences` — L4 standalone-plugin versus Hazelight engine-fork architecture and implementation consequences;
- `reference-differences-version/hazelight-audit-maintenance` — L5 revision pinning, source priority, update audit, and change-history maintenance.

The comparison catalog additionally reserves language extensions; preprocessor/parser/compiler/kernel; Actor/component/subsystem surfaces; hot reload/reinstancing/Blueprint impact; UHT/code generation; debugger/VS Code protocol; testing/coverage/diagnostics; examples; GameplayTags/GAS/domain integrations; removed Haze-specific behavior; and local-only capabilities. Individual pages are created only when their evidence and reader outcome are ready.

Every comparison row uses one of: `same`, `diverged`, `selective-backport`, `reimplemented`, `removed`, `local-only`, or `future-candidate`. It cites both sides when source evidence is available, records the compared revisions/date, distinguishes public docs, the dated local folder report, configured engine source, private remote source, and local plugin source, and separates verified facts from inference. Hazelight public docs describe the exposed product but cannot prove source-level parity; `References.HazelightAngelscriptEngineRoot` is a source-level reference when configured, while a pinned private-repository revision may be used for an authorized read-only audit. Private Hazelight source is never copied into the public Wiki/source corpus. Comparison content is rewritten and attributed, never copied wholesale.

The capability matrix is backed by one machine-readable JSON tiddler, `AS/Docs/Data/HazelightComparisonCatalog`, rather than hand-maintaining unrelated prose tables. Each row contains:

```text
id
family
title
relationship
confidence: verified | supported | provisional
hazelight-revision
local-revision
compared-on
unreal-version
hazelight-evidence
local-evidence
user-consequence
maintenance-consequence
disposition
benchmark-evidence
detail-doc-key
```

`benchmark-evidence` may be empty only when the row makes no comparative performance claim. Restricted Hazelight source keys resolve to metadata/purpose only and cannot emit a private excerpt. The overview and detailed pages read the same catalog rows so a revision or relationship cannot silently differ between views.

The initial evidence record pins Hazelight `f459e6322f63deef8d345f1c1624734cc22747e3` and local plugin `4e2e23ca16ae9f1786258fb96b09b268259b1aad`. It treats `Documents/Hazelight/HazelightAngelscriptEngineChangeReport.txt` as a dated, non-exhaustive path inventory: the report visibly lists thirteen changed `Engine/Source` leaf files but has no compared Git revisions and omits current verified private/editor/UHT changes. Detailed findings, limitations, stale claims, and repeatable audit rules live in `research/hazelight-comparison-audit.md` and `research/hazelight-engine-change-inventory.md`.

### 5. Use paired locale tiddlers with one stable logical identity

Long Chinese and English bodies will be separate tiddlers:

```text
Source path: Wiki/wiki/tiddlers/docs/<locale>/<topic>/<slug>.tid
Title:       AS/Docs/<locale>/<topic>/<slug>
Logical key: <topic>/<slug>
```

Both pages share `as-doc-key`. Chinese is required first. English may be absent until Chinese is reviewed. This keeps bodies independently reviewable and avoids placing two large articles in one conditional WikiText file.

An author-facing procedure will resolve logical links:

```text
<<as-doc-link "unreal-language/default-statement" "default 语句">>
```

Resolution order is current supported locale, then `zh-Hans`, then an explicit missing-document presentation. An English reader who reaches Chinese fallback sees a quiet translation-pending notice without losing the content. Ordinary canonical links remain supported during migration through compatibility aliases or retained entry tiddlers; existing titles are not renamed before the resolver is available.

Reviewed Chinese content uses `as-content-revision`, a positive integer maintained when reviewed content changes. An English page records the Chinese title in `as-translation-of` and the translated revision in `as-translation-revision`. A reviewed English page whose revision no longer matches the Chinese page is `stale`; the Wiki may still render it, but it must identify the mismatch and offer the current Chinese page.

Placeholder pages use `as-content-revision: 0`; drafts may use `0` or a positive working revision. Reviewed and published Chinese pages use positive revisions. English has its own content revision and separately records the Chinese revision it translated.

The active `refactor-wiki-toolchain-reliability` change currently describes en-GB fallback for product language values. This design treats that rule as UI/lingo compatibility. Article resolution is separately Chinese-first. Before both changes are archived, their wording must be reconciled so UI string fallback and article-body fallback cannot be read as contradictory.

### 6. Keep navigation tags narrow and metadata fields explicit

The root content tag is `ASWiki/Docs`. A topic landing tag is `ASWiki/Docs/<topic-key>`, tagged with `ASWiki/Docs`. Documents carry one primary topic tag and may carry a small number of secondary topic tags. Topic order is stored in `as-order` rather than encoded only in captions.

The legacy classification tags are retired:

| Legacy tag | Disposition |
|---|---|
| `ASWiki/Home` | No replacement tag. `AngelscriptWikiHome` remains a compatibility/default route during migration and uses `as-page-role: home`. |
| `ASWiki/Navigation` | No replacement content tag. Navigation shells use `as-page-role: navigation`. |
| `ASWiki/Status` | Reader status content maps to `ASWiki/Docs/reference-differences-version`; product-state shells may additionally use `as-page-role: project-status`. |
| `ASWiki/Workflow` | Each page maps to its actual primary topic, such as `start`, `hot-reload`, `editor-ide-debugging`, or `testing-diagnostics-release`. |
| `ASWiki/Maintainer` | Each page maps to `bindings-uht-extensions`, `testing-diagnostics-release`, or `architecture-maintenance` according to content. |
| `ASWiki/Theme` | Theme/product planning is not a reader topic; use `as-page-role: project-meta` or map a genuine authoring page into Showcase. |

The allowed reader-facing classification roots after migration are `ASWiki/Docs` and `ASWiki/Showcase`. Core TiddlyWiki system tags such as `$:/tags/Global`, `$:/tags/ViewTemplate`, and `$:/tags/Image` remain unaffected. The legacy `AngelscriptWikiHome` title is not renamed in the foundation because it is referenced by the default-tiddler configuration, theme selectors, and product tests; tag retirement and route renaming are separate compatibility decisions.

An inventoried pre-foundation title that still contains a mixed Chinese/English body may temporarily use `as-page-role: compatibility` after its legacy tag is removed. This is a narrow migration exception, not a document lifecycle state: it is excluded from completion counts, must link to its mapped topic/reviewed Chinese successor, and is accepted only for the exact existing canonical titles recorded by the content contract.

Required document fields are:

```text
caption
description
as-sdk-document: yes
as-doc-key
as-locale: zh-Hans | en-GB
as-depth: L0 | L1 | L2 | L3 | L4 | L5
as-doc-kind: tutorial | guide | reference | explanation | internals | showcase
as-content-status: placeholder | draft | reviewed | published
as-order
as-content-revision
as-sources
```

English pages additionally carry:

```text
as-translation-of
as-translation-revision
as-translation-status: draft | reviewed | stale
```

`as-sources` is a TiddlyWiki list of stable source keys recorded in the source inventory and future source registry. Locale, depth, kind, lifecycle, order, provenance, and translation status are fields rather than tags.

Only first-level topic tags may receive prominent semantic colors. Child topics and lifecycle badges remain neutral. Exact hex values are deferred to a later visual review, so the foundation implementation must not invent a palette.

### 7. Make placeholders informative and explicitly non-authoritative

A placeholder page must state:

- the question or reader outcome it will address;
- its topic, depth, and intended document kind;
- a planned section outline;
- known local sources and key source-code areas;
- dependencies and related pages;
- an explicit statement that the content has not yet been technically reviewed.

Placeholders are visible in topic directories with a “规划中” state. They must not be presented as reviewed guidance, translated merely to create symmetry, or used as evidence that a feature is complete.

The first implementation tranche creates 15 Chinese topic landings, L0–L5 skeletons for `unreal-language` and `hot-reload`, the four-page UHT sequence, the Hazelight comparison nested-topic landing/catalog and five emphasized comparison placeholders, six special-topic landings, and the three Showcase tier indexes. It records the remaining Hazelight comparison families and all 42 Showcase entries in catalog surfaces instead of creating empty pages without evidence.

The L4/L5 skeletons for `unreal-language` and `hot-reload` are explicitly marked as `internals`. The same tranche also adds a Chinese “实现原理” directory view that discovers all `internals` pages across topics. It does not create empty pages for every planned mechanism; the catalog records the later parser/compiler/VM/object/binding families until a topic-sized content change writes them.

### 8. Define three showcase stability tiers

`ASWiki/Showcase` has three child tags:

- `ASWiki/Showcase/Base`: stable syntax/rendering surfaces used for theme and responsive regression.
- `ASWiki/Showcase/Pattern`: reusable real-document compositions whose content shape is documented but whose exact DOM is not a public API.
- `ASWiki/Showcase/Lab`: experiments that may be rewritten or removed and are excluded from stable visual/DOM contracts.

Every implemented Showcase page records `as-showcase-id`, `as-showcase-tier`, and `as-showcase-purpose`; the tier field and exactly one tier tag must agree. Catalog-only entries use the same stable IDs without requiring empty page tiddlers.

The initial catalog is 15 Base surface groups, 16 Pattern groups, and 11 Lab groups, documented in the spec, `research/showcase-gap-matrix.md`, and `research/tiddlywiki-expression-showcase.md`. Existing Markdown, Markdown More, WikiText, and AngelScript presentation fixtures are mapped into the catalog rather than duplicated blindly. The expansion explicitly reserves stable cases for TiddlyWiki procedures/functions/legacy macros, trusted HTML mixed with WikiText/widgets, and local/external iframe behavior, plus reusable native-component/embed patterns and a Lab-only embed-security policy experiment.

Base receives focused Playwright coverage. Pattern receives discoverability, render, accessibility, and containment coverage. Lab receives only source-boundary, load-safety, and explicit experimental-label coverage unless a specific experiment graduates.

Raw HTML and page embedding use a stricter boundary than ordinary prose. Authored HTML is trusted repository content, not a sanitizer for untrusted input. Live scripts and inline event handlers are excluded from Showcase pages. External embeds are optional enhancements with visible fallback, minimal sandbox permissions, accessible titles, explicit network/privacy limitations, and no role in normal offline verification. Product-owned local fixtures are used for deterministic browser tests.

### 9. Preserve source provenance and rewrite rather than bulk-copy

`research/content-crosswalk.md` maps every source page or article to a primary target topic and one disposition:

- `adapt` — keep the subject, rewrite for the Wiki and current fork;
- `split` — divide a large maintainer article across depth-specific pages;
- `reference-only` — retain as evidence without migrating prose;
- `defer` — useful but outside the foundation and first content batches;
- `superseded-candidate` — potentially obsolete, requiring source verification before removal.

Hazelight text is paraphrased and attributed because the documentation repository does not include a separate content license. Images and media remain reference-only until a license/provenance review. Large code examples are taken from current project examples or newly written against the current plugin, not copied merely because a reference page contains them.

The Chinese knowledge files remain intact until a later per-topic change confirms that migrated Wiki pages cover their useful content, links have moved, and a retention/deprecation decision is reviewed.

### 10. Keep a pinned source corpus outside the initial runtime

A later source-corpus tranche may keep a complete published snapshot of `TDGameStudio/UnrealAngelscriptPlugin` under a Wiki-owned raw-source directory. It is intended for source citations, excerpt generation, offline research, and future source browsing. It is not an executable Wiki plugin, a package-manager dependency, or an input fetched during normal `dev`, `test`, `verify`, or `build:wiki`.

The snapshot source is a full 40-hex commit from the published GitHub repository, not a local worktree and not a floating `main` checkout. The update command is explicit and reviewable:

1. fetch or clone the requested GitHub revision into a temporary directory;
2. verify the commit, repository identity, allowed paths, and license inventory;
3. stage the new raw snapshot and generated path/symbol index;
4. validate every stable document source reference and mark unresolved references as stale;
5. show a revision/file/license/reference diff before any commit.

The initial captured plugin facts are:

- canonical repository: `https://github.com/TDGameStudio/UnrealAngelscriptPlugin`;
- local remote: `git@github.com:TDGameStudio/UnrealAngelscriptPlugin.git`;
- captured local committed revision: `4e2e23ca16ae9f1786258fb96b09b268259b1aad`;
- top-level plugin license: MIT, copyright Hazelight Games AB and TDGameStudio;
- `Source/AngelscriptRuntime/ThirdParty/angelscript/`: AngelScript zlib license boundary;
- local worktree: dirty and therefore prohibited as a snapshot input.

Documents cite a stable registry key rather than a machine path or unpinned GitHub URL. Each reference records repository ID, pinned revision, path, optional symbol/anchor, optional reviewed line range, excerpt hash, purpose, and license classification. Page rendering uses only generated, selected excerpts and commit-pinned GitHub links. The entire raw tree stays out of the TiddlyWiki boot payload unless a later measured source-browser change deliberately selects another packaging model.

This source-corpus tranche is independently reviewable from content taxonomy because it adds network synchronization, a large raw snapshot, license auditing, and stale-reference behavior. The present OpenSpec records its contract, but its implementation should be a separate execution batch after the content foundation works with local source keys.

### 11. Keep this change independent from current Wiki implementation work

This plan-only record may refer to completed and active Wiki changes but does not modify their artifacts. Future implementation must preserve the existing dirty Wiki worktree and must not combine line-icon, toolchain, translation-catalog, theme, publishing, or comparison-artifact changes into content commits.

Temporary ignored visual brainstorm files created during exploration were removed after visualization was deferred. No visual mockup is a source, deliverable, or implementation dependency of this OpenSpec.

## Risks / Trade-offs

- [Fifteen topics create a long first-level directory] → Use ordered groups and progressive disclosure; do not expose every article at the first sidebar level.
- [L0–L5 becomes bureaucratic] → Treat depths as a shared vocabulary and metadata, not a demand for six pages per subject.
- [Paired tiddlers duplicate metadata] → Validate shared keys, locale uniqueness, and translation relations with source-level contract tests.
- [English search results become stale] → Record content revisions, label mismatches, and link to the current Chinese article.
- [Chinese fallback surprises English readers] → Show a localized translation-pending notice and retain language selection without silently pretending the page is English.
- [Active multilingual specs use different fallback wording] → Record the conflict now and reconcile UI-string versus article-body semantics before archive.
- [Tags become a second content database] → Restrict tags to topic hierarchy and keep orthogonal state in fields.
- [Legacy audience/role tags survive beside the new taxonomy] → Deny the six old classification tags in the content contract after every current page has an explicit migration mapping.
- [Topic colors become noisy] → Color only first-level topic tags and require a later real-page contrast review before choosing hex values.
- [Placeholders make the Wiki look complete] → Render an explicit planned/unreviewed state and exclude placeholders from completion counts.
- [Domain topics are mistaken for optional plugins] → Record `optional-plugin` versus `engine-domain` explicitly and show real dependency relationships.
- [UHT is reduced to a generated-file list] → Explain configuration, policy, generation, Runtime bridge, layout contracts, failure modes, and tests as one traceable sequence.
- [Hazelight comparison becomes a stale opinion table] → Pin both baselines, label every relationship, cite both sides, separate public docs from source evidence, and maintain the audit as revisioned data.
- [The dated Hazelight engine-file report is mistaken for a complete current patch set] → Label it path-level historical evidence, preserve its missing-revision limitation, and recheck semantic claims against pinned current source.
- [Private Hazelight source leaks into the public Wiki] → Store only revision/provenance keys and paraphrased findings; never mirror or publish the private source without separate authorization and license review.
- [Reference content is copied without permission] → Treat prose as rewrite-only and media as reference-only until licensed.
- [A source snapshot silently changes underneath reviewed explanations] → Pin every snapshot to a full commit and require an explicit reviewed update.
- [The full plugin source makes the offline Wiki slow or enormous] → Keep raw source outside the boot payload and generate only selected excerpts/index data consumed by pages.
- [Uncommitted plugin work leaks into the Wiki] → Synchronize from the published GitHub commit in a temporary checkout; never copy the current plugin worktree.
- [Line-number citations break on every sync] → Use stable registry keys with path, symbol/anchor, reviewed range, and excerpt hash; validate and mark unresolved keys stale.
- [Third-party license terms are flattened into the plugin MIT license] → Maintain per-subtree license records and preserve the AngelScript zlib notice plus any additional discovered notices.
- [Current knowledge articles are deleted too early] → Make removal a later per-topic migration decision, not a foundation action.
- [Showcase pages become an unbounded component gallery] → Require every Base/Pattern entry to state a documentation purpose; keep disposable experiments in Lab.
- [Raw HTML or web embeds weaken security/offline behavior] → Keep authored HTML trusted and reviewable, forbid live inline scripts/handlers, use minimal iframe sandboxing and local deterministic fixtures, and require visible offline/failure fallbacks.
- [Implementation explanations become attractive but unverifiable diagrams] → Require behavior boundaries, source entry points, data structures, traceable experiments, and tests; treat diagrams as one presentation aid rather than proof.

## Migration Plan

1. Record and validate this plan-only OpenSpec without changing Wiki source.
2. In a later implementation session, add failing source-contract tests for fields, locale pairing, revisions, topic order, tags, and placeholder content.
3. Add taxonomy and locale-aware navigation primitives while retaining all existing titles and links.
4. Create the 15 Chinese topic landings, the language-feature and hot-reload depth skeletons, the cross-topic “实现原理” directory, the four UHT pages, the Hazelight comparison nested topic with seven initial pages/catalog, six special-topic landings, and Showcase tier indexes/catalog.
5. Map existing Wiki workflow, maintainer, status, home, navigation, syntax, and code-example pages into the new structure; remove the six legacy classification tags only after their replacements/role fields and tests are present.
6. Add focused browser coverage for navigation, Chinese fallback, stale translations, placeholder states, and Showcase tier behavior.
7. Verify the Wiki with its standard Node/pnpm commands and commit the Wiki submodule before the parent gitlink/OpenSpec update when the user requests commits.
8. In a separately reviewed source-corpus batch, add the pinned snapshot manifest, explicit synchronization command, license/path index, excerpt generator, and stale-reference validation without changing normal offline build behavior.
9. Migrate content later in topic-sized changes, beginning with Chinese entry and language-feature material; translate only reviewed Chinese pages.

Rollback for the later implementation restores the new navigation/taxonomy/content commit while keeping the OpenSpec and research record. No plugin runtime, Unreal asset, database, deployment, or external service migration is involved.

## Open Questions

None for recording the foundation. Exact topic-tag colors and the visual implementation of future experimental diagrams are explicitly deferred to separate reviewed work and are not implementation choices in this change.
