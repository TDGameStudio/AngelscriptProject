# Legacy ASWiki Tag Migration

Captured: 2026-07-25

## Decision

The following flat classification tags are deprecated and removed by the foundation implementation:

```text
ASWiki/Home
ASWiki/Navigation
ASWiki/Status
ASWiki/Theme
ASWiki/Workflow
ASWiki/Maintainer
```

They mix page role, audience, workflow, and project metadata in one namespace. They are replaced by two reader-facing hierarchies:

```text
ASWiki/Docs
└── ASWiki/Docs/<topic-key>

ASWiki/Showcase
├── ASWiki/Showcase/Base
├── ASWiki/Showcase/Pattern
└── ASWiki/Showcase/Lab
```

Home/navigation/project state is expressed by `as-page-role`, not by content tags.

## Current tiddler migration table

| Source file | Title | Old tag | New primary classification | Page role | Body/title treatment |
|---|---|---|---|---|---|
| `wiki/tiddlers/AngelscriptWikiHome.tid` | `AngelscriptWikiHome` | `ASWiki/Home` | none | `home` | Keep title/default route; redesign links around new directories |
| `wiki/tiddlers/as/navigation.tid` | `AS/Navigation` | `ASWiki/Navigation` | none | `navigation` | Keep sidebar transclusion title; replace hard-coded primary groups |
| `wiki/tiddlers/as/status.tid` | `AS/Status` | `ASWiki/Status` | `ASWiki/Docs/reference-differences-version` | `compatibility` initially | Preserve body/title and link to new topic |
| `wiki/tiddlers/as/theme-roadmap.tid` | `AS/ThemeRoadmap` | `ASWiki/Theme` | none | `project-meta` | Preserve as project meta; later split genuine authoring guidance into Showcase |
| `wiki/tiddlers/as/workflow/getting-started.tid` | `AS/Workflow/GettingStarted` | `ASWiki/Workflow` | `ASWiki/Docs/start` | `compatibility` initially | Preserve body/title and link to new topic |
| `wiki/tiddlers/as/workflow/authoring-and-hot-reload.tid` | `AS/Workflow/AuthoringAndHotReload` | `ASWiki/Workflow` | `ASWiki/Docs/hot-reload` | `compatibility` initially | Preserve body/title and link to new topic |
| `wiki/tiddlers/as/workflow/debugging.tid` | `AS/Workflow/Debugging` | `ASWiki/Workflow` | `ASWiki/Docs/editor-ide-debugging` | `compatibility` initially | Preserve body/title and link to new topic |
| `wiki/tiddlers/as/workflow/testing-and-release.tid` | `AS/Workflow/TestingAndRelease` | `ASWiki/Workflow` | `ASWiki/Docs/testing-diagnostics-release` | `compatibility` initially | Preserve body/title and link to new topic |
| `wiki/tiddlers/as/maintainer/bindings.tid` | `AS/Maintainer/Bindings` | `ASWiki/Maintainer` | `ASWiki/Docs/bindings-uht-extensions` | `compatibility` initially | Preserve body/title and link to new topic |
| `wiki/tiddlers/as/maintainer/build-and-diagnostics.tid` | `AS/Maintainer/BuildAndDiagnostics` | `ASWiki/Maintainer` | `ASWiki/Docs/testing-diagnostics-release` | `compatibility` initially | Preserve body/title and link to new topic; architecture may be a secondary link |

The compatibility role is limited to the seven current `AS/*` content titles above. It is not assigned to Home, Navigation, or ThemeRoadmap and cannot be used by new pages.

## Known direct consumers

The tag values and/or Home route currently appear in:

- `src/angelscript-wiki-config/config/default-tiddlers.tid`;
- `src/angelscript-theme/compact-control-rail.tid`;
- `tests/playwright/product/angelscript-defaults.spec.ts`;
- `tests/playwright/product/angelscript-theme.spec.ts`;
- `tests/playwright/product/document-experience.spec.ts`;
- `tests/playwright/product/sidebar-expanded-panels.spec.ts`;
- `tests/playwright/product/visual-contract.spec.ts`.

`ASWiki/Workflow` is used as a representative colored tag and high-volume test tag in current browser tests. Replace those uses with a real first-level topic tag, normally `ASWiki/Docs/hot-reload`, when the test intends to exercise ordinary tag behavior. Tests that intentionally assert legacy-tag retirement should keep the old value only inside isolated test data or negative assertions.

`ASWiki/Home` is used in current tag-popup/tag-list scenarios. Those expectations must change: Home remains reachable but should no longer appear in the ordinary tag directory.

## Migration sequence

1. Add the new tag roots and topic/tier tag tiddlers without removing old tags.
2. Add metadata-driven `AS/Docs` and `AS/Showcase` directories.
3. Add content-contract tests with the retired-tag denylist, initially failing.
4. Add page roles and topic mappings to every current tiddler in the table.
5. Update navigation and browser tests that relied on `ASWiki/Workflow` or `ASWiki/Home`.
6. Remove the six old tag values from content.
7. Verify that no generated tag tiddler, color record, popup, sidebar result, or ordinary content reference recreates them.
8. Retain old tiddler titles until later content migration confirms link coverage.

## Acceptance queries

Source scan:

```powershell
rg -n "ASWiki/(Home|Navigation|Status|Theme|Workflow|Maintainer)" `
  Wiki/wiki/tiddlers Wiki/src Wiki/tests Wiki/scripts
```

Expected after implementation:

- no positive use in shipped content;
- negative validator fixtures and explicit retirement assertions are allowed;
- migration research/OpenSpec text is allowed;
- no color assignment or test-created durable tiddler survives under a retired title.

Runtime checks:

- `[tag[ASWiki/Docs]sortan[as-order]]` yields exactly fifteen first-level topic tags;
- `[tag[ASWiki/Showcase]]` yields exactly Base, Pattern, and Lab tier tags;
- `[tag[ASWiki/Home]]`, `[tag[ASWiki/Workflow]]`, and the other four retired-tag queries yield no shipped content;
- `AngelscriptWikiHome` remains the configured default tiddler;
- the Home page links to `AS/Docs`, `AS/Docs/Internals`, and `AS/Showcase`;
- a current compatibility title remains directly openable.

## Removal criteria for compatibility entries

A later topic migration may remove a compatibility role or old title only after it records:

- which new Chinese pages cover the useful body;
- all inbound links and default/navigation references;
- whether an alias, short redirect, or retained historical page is appropriate;
- browser coverage for the chosen behavior;
- confirmation that the old page is not the sole owner of a source note or warning.
