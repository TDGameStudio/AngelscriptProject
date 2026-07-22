## Context

The current Wiki combines the official TiddlyWiki Highlight plugin for generic fenced code with a TDGameStudio `as-code` widget backed by a hand-written tokenizer. The official Highlight bundle is Highlight.js 11.11.1 and supports additional language modules through `module-type: highlight`, but its bundled language set omits AngelScript and the upstream AngelScript grammar does not understand this repository's Unreal extensions. The reviewed RefWiki overrides Highlight with the classic Tomorrow light palette. The current migrated theme is otherwise the accepted baseline and must only receive a conservative desktop refinement.

## Goals / Non-Goals

**Goals:**

- Route generic and UE AngelScript syntax through one official Highlight.js pipeline and one `hljs-*` semantic class contract.
- Maintain UE AngelScript grammar extensions as reviewable Wiki source, aligned with the project-owned VS Code TextMate grammar.
- Provide a TW5-native author interface for line numbers, highlighted lines, and inclusive source slicing.
- Preserve a single highlighted `<pre><code>` result, exact visible source copying, and offline/browser-only operation.
- Reproduce the RefWiki Tomorrow token mapping and harmonize code chrome, focus, muted UI text, search, and desktop controls with the accepted theme.

**Non-Goals:**

- Importing the Kookma HSL plugin, splitting source into one code block per line, or fading non-highlighted lines.
- Patching Markdown fence metadata, integrating LSP semantic tokens, generating grammar from the parent repository, or adding runtime-configurable keyword tiddlers.
- Rebuilding navigation, moving the sidebar, adding a dark theme, changing the story view, or redesigning mobile.

## Decisions

### Extend the official Highlight pipeline instead of retaining a specialized renderer

A `module-type: highlight` JavaScript tiddler will register `angelscript` with the bundled `hljs` instance and expose `as` as an alias. The grammar will use the upstream AngelScript definition as its structural baseline and explicitly add Unreal macros, specifiers, fork keywords, f-strings, asset syntax, and UE type conventions. It will retain upstream attribution and group project extensions in named source constants. The VS Code TextMate grammar is a maintenance reference, not a runtime dependency.

The alternative of keeping `as-code` would preserve two renderers and duplicate escaping, token semantics, and styling. Importing upstream AngelScript unchanged would unify rendering but leave common Unreal syntax unclassified.

### Use one AngelScript code widget and native TW5 attribute values

`$angelscript-code` will accept the core-compatible `code` attribute plus `lineNumbers`, `highlightLines`, `fromLine`, `toLine`, and `startLine`; it always selects the project's `angelscript` grammar. TiddlyWiki resolves literal, triple-quoted, transcluded, variable, and filtered attribute values before the widget receives them. Widget body content remains unsupported, matching core `$codeblock`. AngelScript authoring will use explicit `$codeblock language="angelscript">` or `$angelscript-code` WikiText; this change does not extend the Markdown parser.

`fromLine` and `toLine` select a 1-based inclusive range from the supplied source. `startLine` overrides the first displayed label; otherwise the first label equals the effective `fromLine`. `highlightLines` uses displayed labels and accepts comma-separated `N` or `N-M` entries. Invalid range entries are ignored; invalid or reversed source bounds fall back to the full source; legal out-of-bounds values are clamped.

The widget will create a core CodeBlockWidget child so Highlight continues to own escaping and tokenization. A separate gutter and absolutely positioned highlight rows will align to a fixed code line-height while the code stays one non-wrapping `<pre><code>` block. Copying uses the visible sliced code text and excludes gutter and controls.

### Chain core code-block post-render for a shared copy control

A browser startup module will preserve and invoke the existing CodeBlockWidget `postRender`, then append one copy button outside the `<code>` element but inside the `<pre>`. This avoids an observer, preserves widget cleanup, applies to ordinary core and enhanced code, and cannot bypass official highlighting. The action uses Clipboard API with the existing textarea fallback and exposes localized copied/error feedback through an `aria-live` status.

### Keep the accepted theme and spend the visual change on code and interaction clarity

The classic Tomorrow foreground/token mapping from RefWiki will be theme-owned and applied to all `.hljs-*` roles. Code containers use `#f8f8f8`, a restrained hairline border, 6px radius, local Fira Code, and a low-saturation Tomorrow-blue line emphasis. The general theme retains the original LinOnetwo palette hierarchy, dimensions, typography, and document layout while restoring `:focus-visible`, widening the sidebar search within its existing column, and normalizing 32px desktop control targets. A visual review rejected the intermediate change that flattened six muted/control palette roles to `#666666`; those roles retain their original lighter values.

## Risks / Trade-offs

- [Lexically slicing source can remove context for a multiline string or comment] → Highlight the selected text as shown and document that authored source ranges should be syntactically meaningful; do not reintroduce per-line parsing.
- [UE syntax vocabulary can drift from the VS Code extension] → Keep grouped constants, a source-reference comment, and a representative Playwright fixture covering every extension family.
- [Chaining CodeBlockWidget post-render can conflict with future plugin changes] → Always call the captured implementation first, mark decorated nodes idempotently, and cover ordinary fenced code plus enhanced code in integration tests.
- [Exact Tomorrow colors include deliberately low-contrast accent hues] → Preserve the user-selected code palette while enforcing readable foreground and accessible contrast for general UI text and focus indicators.
- [Removing `as-code` is breaking] → Repository search found no production usage; remove tests/docs in the same change and document `$angelscript-code` as the replacement.

## Migration Plan

1. Replace the old widget tests with failing official-highlight and `angelscript-code` behavior tests.
2. Register the UE AngelScript grammar and activate Tomorrow styles.
3. Replace `as-code` with `angelscript-code`, line presentation, and shared copy behavior.
4. Apply the conservative theme pass and update author/agent documentation.
5. Run the complete Wiki build, offline publish, and browser suite. Rollback is a normal Wiki submodule commit revert plus parent gitlink/OpenSpec revert; no user tiddler data is migrated.

## Open Questions

None. The copy action defaults to all core code blocks, and mobile remains regression-only.
