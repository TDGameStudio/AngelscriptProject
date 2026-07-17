## Why

AngelscriptWiki currently displays AngelScript examples as ordinary text. Readers cannot distinguish syntax roles, copy examples reliably, or compare the long-form teaching pages with the language structure they describe. The project-owned VS Code extension already establishes the semantic vocabulary, so the Wiki needs a browser-safe first layer that turns those examples into reusable documentation components.

## What Changes

- Add a project-owned TiddlyWiki plugin at `Wiki/src/angelscript-tools/`.
- Add a browser-safe AngelScript tokenizer for keywords, types, macros, strings, numbers, comments, functions, and operators.
- Add an `as-code` widget with a light documentation-card presentation, optional title, line numbers, and copy action.
- Add a dedicated Wiki example tiddler and Playwright coverage for rendering, semantic tokens, line numbers, and copy feedback.
- Keep full Unreal-aware LSP features out of this first browser-only version; later versions may connect to an explicit local bridge.

## Capabilities

### New Capabilities

- `tw-angelscript-tools`: Browser-side AngelScript code presentation and reusable TiddlyWiki widget behavior.

### Modified Capabilities

None.

## Impact

- Wiki submodule source under `Wiki/src/angelscript-tools/`.
- Wiki example and Playwright test tiddlers under `Wiki/wiki/tiddlers/tests/playwright/`.
- Parent repository OpenSpec records and implementation plan.
- No Unreal runtime dependency, Node-side LSP dependency, or network request in the first version.
