## Why

AngelscriptWiki now has a validated documentation taxonomy, locale lifecycle, source corpus, and placeholder contract, but its reader-facing directory exposes only fifteen abstract topic landings. All forty-two formal Chinese pages remain placeholders, concrete language capabilities are compressed into a short planning list, and the repository's seventy-three Chinese knowledge articles are not discoverable as Wiki documentation.

The Wiki needs a content expansion that adopts the useful reader-facing granularity of Hazelight's public documentation while preserving the existing fifteen-topic ownership model, L0-L5 depth tracks, Chinese-first review lifecycle, source evidence, fork-specific differences, Showcase system, and compatibility routes.

## What Changes

- Add a dual-axis documentation directory:
  - a primary task/capability view with direct links to concrete documentation;
  - a secondary knowledge-system view retaining the existing fifteen topics and L0-L5 depths.
- Add reader-navigation metadata and validation without removing existing document identity, topic, lifecycle, provenance, or translation fields.
- Replace the handwritten Unreal language feature placeholder list with a metadata-driven capability catalog.
- Create concrete Chinese entry pages for ordinary AngelScript fundamentals and Unreal-specific script features, including the seventeen existing `Syntax_*` knowledge families and the fifteen public Hazelight Script Features mappings.
- Add a task-oriented C++ Usage and Bindings path covering automatic reflection exposure, script-specific metadata, C++ `ScriptMixin` libraries, manual `Bind_*.cpp`, call-backend limits, and binding diagnostics.
- Migrate useful content from `Documents/Knowledges/ZH` through an explicit one-to-one, merged, retained, or deferred decision ledger; no source article is silently ignored or deleted.
- Upgrade an initial high-value reading path from placeholders to reviewed Chinese documentation with runnable examples, current-fork boundaries, local source/test evidence, and related-page navigation.
- Preserve all existing foundation tiddlers, logical document keys, topic tags, L0-L5 tracks, compatibility pages, source-corpus rules, Hazelight comparison records, and Showcase catalogs.
- Add repository and browser tests for capability discoverability, orphan prevention, directory semantics, lifecycle counts, responsive layout, keyboard access, and artifact inclusion.

## Capabilities

### New Capabilities

- `wiki-reader-capability-navigation`: Defines the dual-axis reader directory, navigation groups, concrete capability links, status presentation, deep linking, accessibility, and responsive behavior.
- `wiki-language-feature-content`: Defines the required ordinary AngelScript and Unreal-specific feature surface, knowledge-source migration ledger, reviewed article minimums, Hazelight mapping, and completion accounting.

### Modified Capabilities

- `wiki-content-architecture`: Extends the fifteen-topic and L0-L5 architecture with a preserved secondary taxonomy view and a primary task/capability reading path.
- `wiki-document-taxonomy`: Adds validated reader-navigation and feature-identity metadata while retaining the existing formal-document contract.

## Impact

- Primary implementation area: `Wiki/wiki/tiddlers/docs/`, with focused supporting procedures/styles under `Wiki/src/angelscript-tools/documentation/`.
- Contract and regression coverage: `Wiki/scripts/document-content-contract*.mjs` and `Wiki/tests/playwright/product/document/`.
- Author guidance: `Wiki/Agents_ZH.md` first, then `Wiki/Agents.md`.
- Change records and migration evidence: `openspec/changes/docs-wiki-content-expansion/`.
- No plugin runtime API, Unreal module dependency, vendor package, normal build-network behavior, or existing document key is removed.
