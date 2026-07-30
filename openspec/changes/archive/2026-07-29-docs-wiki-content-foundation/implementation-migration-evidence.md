# Implemented Content Migration Evidence

Recorded: 2026-07-30

This ledger closes the implementation-side migration accounting for the documentation foundation. The exhaustive candidate-source crosswalk remains `research/content-crosswalk.md`: it records all 29 Hazelight Markdown inputs, all 73 `Documents/Knowledges/ZH` inputs, and all 36 host `.as` examples/tests. This file records what the foundation actually promoted, retained, or redirected; a crosswalk row is not by itself permission to copy source prose.

## Existing Wiki pages

| Existing title | New logical owner | Implemented disposition |
|---|---|---|
| `AngelscriptWikiHome` | `AS/Docs`, `AS/Docs/Internals`, `AS/Showcase` | Retained as the stable Home title with `as-page-role: home`; navigation now enters the three metadata-driven directories. |
| `AS/Navigation` | documentation and Showcase directories | Retained as `as-page-role: navigation`; primary navigation is metadata-driven and the compatibility section is collapsed. |
| `AS/Status` | `reference-differences-version/index` | Retained as one of the seven allowlisted compatibility titles and linked to the new Chinese landing. |
| `AS/ThemeRoadmap` | project metadata / `showcase-lab` | Retained as `as-page-role: project-meta`; it is not presented as a formal SDK document. |
| `AS/Workflow/GettingStarted` | `start/index` | Retained compatibility title; useful body remains reachable while the new topic is the canonical destination. |
| `AS/Workflow/AuthoringAndHotReload` | `hot-reload/index` | Retained compatibility title and redirected by an explicit reader link. |
| `AS/Workflow/Debugging` | `editor-ide-debugging/index` | Retained compatibility title and redirected by an explicit reader link. |
| `AS/Workflow/TestingAndRelease` | `testing-diagnostics-release/index` | Retained compatibility title and redirected by an explicit reader link. |
| `AS/Maintainer/Bindings` | `bindings-uht-extensions/index` | Retained compatibility title and redirected by an explicit reader link. |
| `AS/Maintainer/BuildAndDiagnostics` | `testing-diagnostics-release/index` | Retained compatibility title and redirected by an explicit reader link. |
| `语法展示范式` | `AS/Showcase` | Retained as an explicit Showcase compatibility entry, not a second catalog. |
| `Markdown 基础示例` | Showcase `B01` | Promoted in place as a mapped Base page with catalog-matching ID/tier/purpose. |
| `Markdown 扩展语法示例` | Showcase `B02` | Promoted in place as a mapped Base page with catalog-matching ID/tier/purpose. |
| `Markdown More 示例` | Showcase `B03` | Promoted in place as a mapped Base page with catalog-matching ID/tier/purpose. |
| `TiddlyWiki 语法示例` | Showcase `B04` | Promoted in place as a mapped Base page with catalog-matching ID/tier/purpose. |
| `TiddlyWiki 语法示例/转置片段` | Showcase `B04` support content | Retained as the single transclusion fragment consumed by the mapped B04 page; not cataloged as another showcase entry. |
| `AngelscriptCodeExamples` | Showcase `B07` | Moved from the Playwright fixture source directory to `wiki/tiddlers/examples/AngelscriptCodeShowcase.tid`; the reader title stayed stable and hidden `$:/tests/...` fixtures stayed private. |

No existing reader page was deleted. The six retired audience/page-role tags were removed and replaced by topic tags or `as-page-role`. Only the exact seven compatibility titles above remain eligible for `as-page-role: compatibility`.

## Promoted host knowledge

The foundation used selected host knowledge to establish chapter ownership and evidence-shaped placeholders; it did not copy those Markdown bodies into Wiki pages. Their implemented destinations are:

| Source input | Logical keys | Disposition |
|---|---|---|
| `Documents/Knowledges/ZH/AS_LanguageSyntax.md` | `language/index`, `language/quick-start`, `language/core-syntax`, `language/reference`, `language/internals`, `language/source-tests-maintenance` | Structure adapted into the exact L0–L5 sequence; current pages remain explicit placeholders until each claim is rewritten and reviewed. |
| `Documents/Knowledges/ZH/Guide_SyntaxFeatures.md` and the `Syntax_*` family | `unreal-language/index`, `feature-catalog`, `first-feature-path`, `boundaries-and-differences`, `feature-implementation-principles`, `source-tests-maintenance` | Feature families and maintenance questions adapted into the exact L0–L5 sequence; no bulk prose copy. |
| `Documents/Knowledges/ZH/RT_HotReload.md` | `hot-reload/index`, `daily-workflow`, `change-classification`, `reload-pipeline-internals`, `failures-and-recovery`, `source-tests-maintenance` | Split into the exact L0–L5 sequence; the L4 page additionally consumes the pinned public source key `as-source.runtime-class-reload-planner`. |
| `Documents/Knowledges/ZH/Arch_UHTToolchain.md` and `Guide_UHTToolchain.md` | `bindings-uht-extensions/uht-plugin-overview`, `uht-generation-workflow`, `uht-plugin-internals`, `uht-plugin-maintenance` | Split into the four required UHT reader/maintainer levels; the internals page additionally consumes `as-source.uht-binding-policy`. |

All other knowledge rows retain the `adapt`, `split`, `reference-only`, `defer`, or `superseded-candidate` disposition in `research/content-crosswalk.md`; they were not promoted as copied foundation content.

## Promoted Hazelight evidence

| Source input | Logical keys | Disposition |
|---|---|---|
| Pinned public `Docs-UnrealEngine-Angelscript` index and selected behavior pages | `start/index`, `unreal-language/*`, `unreal-core/index`, selected integration pages, `reference-differences-version/hazelight-comparison-overview` | Reference/rewrite input only. The Wiki records broad provenance but copies neither full articles nor media because the documentation-content reuse license is not established. |
| Private `Hazelight/UnrealEngine-Angelscript` observation at `f459e6322f63deef8d345f1c1624734cc22747e3` | `hazelight-capability-matrix`, `hazelight-architecture-differences`, `hazelight-class-generation`, `hazelight-struct-generation`, `hazelight-function-binding`, `hazelight-audit-maintenance` | Promoted only as revisioned, paraphrased comparison metadata and consequences. `source-references/hazelight-restricted.json` contains metadata-only keys; there is no private corpus, excerpt, body, hash payload, or public source link. |
| `Documents/Hazelight/HazelightAngelscriptEngineChangeReport.txt` | the same seven-page Hazelight topic and `AS/Docs/Data/HazelightComparisonCatalog` | Retained as dated, revisionless, non-exhaustive supporting evidence; the limitation is reader-visible and the report is never treated as a complete diff. |

The single catalog pins local comparison revision `4e2e23ca16ae9f1786258fb96b09b268259b1aad`, Hazelight revision `f459e6322f63deef8d345f1c1624734cc22747e3`, and comparison date `2026-07-25`.

## Host examples and tests

No host `Script/**/*.as` body was copied into the foundation. All 36 files remain individually accounted for in section 3 of `research/content-crosswalk.md`, with one canonical logical destination and an `adapt` or `reference-only` disposition. Formal pages may carry the broad `script-examples` provenance key, but a later content batch must inspect and promote each example deliberately before presenting it as reader code.

The existing Wiki-owned `AngelscriptCodeExamples` page is therefore classified as an existing Wiki migration (`B07`), not as a copy of a host `Script/` source.

## Public plugin source excerpts

Three new source-backed evidence objects were promoted from the isolated public corpus:

| Registered key | Logical consumer | Disposition |
|---|---|---|
| `as-source.runtime-class-reload-planner` | `hot-reload/reload-pipeline-internals` | Generated bounded excerpt with pinned commit, range, license, and SHA-256. |
| `as-source.uht-binding-policy` | `bindings-uht-extensions/uht-plugin-internals` | Generated bounded excerpt with pinned commit, range, license, and SHA-256. |
| `as-source.runtime-preprocessor` | `unreal-language/feature-implementation-principles` | Generated bounded excerpt with pinned commit, range, license, and SHA-256. |

The 17,692,585-byte raw snapshot stays under `source-corpus/angelscript/`, outside TiddlyWiki boot. Only the three generated tiddlers under `wiki/tiddlers/generated/source/` enter the offline product.
