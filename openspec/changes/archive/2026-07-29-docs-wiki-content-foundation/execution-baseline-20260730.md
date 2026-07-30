# Implementation Baseline — 2026-07-30

This record captures the dirty workspace before implementing
`docs-wiki-content-foundation`. The implementation must preserve every listed
pre-existing path that is outside this change.

## Repository identities

| Repository | Branch | HEAD |
|---|---|---|
| Parent `AngelscriptProject` | `main` | `639e66889e0afc0d2392ca8eb842c0e2bbab347c` |
| `Wiki` submodule | `main` | `509ef987f12301fcca07d52dabdf6defdbb162ae` |
| `Plugins/Angelscript` submodule | `main` | `bc6c4f344c47689c2095fb8600f1c2de69838c03` |

## Pre-existing parent worktree state

The parent was already dirty across host configuration, documentation,
reference/tooling files, the Wiki and plugin gitlinks, unrelated OpenSpec
changes, generated/editor directories, screenshots, and local planning files.
The exact pre-existing tracked paths were:

```text
AGENTS.md
AGENTS_ZH.md
AngelscriptProject.uproject
Config/DefaultEngine.ini
Documents/AS_FullCoverageMatrix.md (deleted)
Documents/Plans/Plan_ScriptExamplesExpansion/Coverage/Example_Coverage_Actor.as (deleted)
Documents/Plans/Plan_ScriptExamplesExpansion/Coverage/Example_Coverage_Component.as (deleted)
Documents/Plans/Plan_ScriptExamplesExpansion/Coverage/Example_Coverage_PropertySpecifiers.as (deleted)
Documents/Plans/Plan_ScriptExamplesExpansion/Coverage/Example_Coverage_UObject.as (deleted)
Plugins/Angelscript (dirty submodule)
Reference/README.md
Source/AngelscriptProject.Target.cs
Tools/PullReference/PullReference.bat
Wiki (advanced submodule)
openspec/changes/refactor-uht-plugin-hardening/*
openspec/changes/test-coverage/*
```

The parent also contained unrelated untracked `.superpowers/`,
`AngelscriptProjectEditor/`, `Config/DefaultEditorPerProjectUserSettings.ini`,
`Docs/Screenshots/`, historical `Docs/superpowers/plans/`, Hazelight notes,
standalone-compiler OpenSpecs, other Wiki OpenSpecs, visual comparison
artifacts, and `vs2026error.png`. None are inputs to this implementation.

## Pre-existing Wiki worktree state

The Wiki branch was 26 commits ahead of its local `origin/main` tracking
reference. Its only pre-existing untracked files were:

```text
剪贴板图片.jpg
正文工具栏鼠标悬浮布局问题.jpg
```

All content-foundation source changes begin after this baseline. The two images
must remain unmodified and untracked.

## Pre-existing plugin worktree state

```text
M Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_compiler.h
M Source/AngelscriptTest/Coverage/AngelscriptCoverageInputTests.cpp
M Source/AngelscriptTest/Coverage/AngelscriptCoverageUStructTests.cpp
M Source/AngelscriptTest/Shared/AngelscriptTestMacros.h
?? Source/AngelscriptTest/AngelScriptSDK/Engine/AngelscriptNativeEngineVersionTests.cpp
```

The source-corpus implementation must never copy this worktree. It may import
only an explicitly pinned published repository commit into the Wiki-owned raw
corpus.

## Merge-sensitive Wiki surfaces

The current versions of these paths must be re-read immediately before edits:

```text
package.json
scripts/source-boundaries.test.mjs
wiki/tiddlers/as/navigation.tid
tests/playwright/product/
src/angelscript-tools/
src/angelscript-theme/
```

The active `refactor-wiki-toolchain-reliability` owns package-command layering,
toolchain enforcement, multilingual UI compatibility, isolated Playwright
artifacts, and product-test domains. `refactor-wiki-architecture-hardening`
owns product-source/runtime boundaries and remaining theme modularity.
Completed line-icon and visual changes own their existing source and tests.
This content change extends those current surfaces without reverting or
duplicating them.

## Supported toolchain evidence

The global shell remains Node `25.5.0` without a global `pnpm`. The supported
toolchain was invoked without modifying dependencies or global state:

```text
npm exec --yes --package=node@24 --package=pnpm@11.8.0 --call "node --version && pnpm --version && pnpm run toolchain:check"
```

Observed:

```text
v24.18.0
11.8.0
toolchain:check exit 0
```

All pnpm verification for this change must use the same supported temporary
toolchain wrapper unless the shell is switched to an equivalent Node 24 /
pnpm 11.8.0 environment.
