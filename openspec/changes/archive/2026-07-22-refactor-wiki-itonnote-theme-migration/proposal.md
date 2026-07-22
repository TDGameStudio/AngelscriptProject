## Why

The current Wiki ships a project-local dark `angelscript-theme`, while the established reference Wiki uses the itonnote document experience and a Notion light palette. Its visual configuration and runtime plugins are scattered, which makes the desired experience difficult to reproduce, audit, or update safely.

## What Changes

- **BREAKING** Rebase the project-local `$:/themes/angelscript` theme on migrated itonnote source and make `$:/palettes/Notion` the fixed default palette, including for dark operating-system preferences. The upstream `$:/themes/linonetwo/itonnote` plugin is not enabled at runtime.
- Import the selected upstream document-experience plugin sources into the Wiki repository and add a validated generated-source bridge for sidebar resizing, command palette dependencies, and link preview. Fira Code is bundled into the local Angelscript theme rather than retained as an itonnote-theme plugin dependency.
- Retain `$:/plugins/TDGameStudio/angelscript-tools` as the AngelScript-specific extension, but restyle `as-code` to use Highlight.js-compatible semantic colors while preserving its tokenizer, line numbers, and copy behavior.
- Enable the bundled official TiddlyWiki Markdown and Highlight plugins for standard Markdown tiddlers and generic fenced code blocks, and retain the reviewed reference-Wiki Markdown More preference values without enabling that extension.
- Consolidate stable defaults in `angelscript-wiki-config`; port only the selected itonnote-plugin mobile behavior into TDGameStudio-owned plugins, without enabling `itonnote-plugin` or its personal knowledge-management surface.

## Capabilities

### New Capabilities

- `wiki-document-experience-integration`: Auditable, editable integration of the selected upstream TiddlyWiki document-experience plugins and their build-source bridge.

### Modified Capabilities

- `angelscript-wiki-theme`: Replace the Angelscript theme and adaptive palette startup behavior with itonnote and a fixed Notion light configuration.
- `tw-angelscript-tools`: Make AngelScript code cards visually compatible with Highlight.js while retaining their existing rendering and copy contract.

## Impact

Affected areas are the `Wiki` submodule's theme/config/plugins, TiddlyWiki build and publish scripts, Playwright and Node tests, documentation, imported `src/` sources tracked by the Wiki repository, and the root reference-repository index/pull helper. The former Angelscript theme styling and adaptive browser startup action are replaced, while the `angelscript-theme` package remains the local theme identity.
