## Context

The Wiki is built with Modern.TiddlyDev and loads plugin entry points from `src/<plugin>/`. A widget receives a TiddlyWiki parse tree, creates DOM during `render`, and must follow the TiddlyWiki widget lifecycle rather than React/Vue conventions. The browser cannot launch the Node/VS Code LSP or access Unreal's DebugServer directly, so the first version needs an offline lexical layer.

## Goals / Non-Goals

**Goals:**

- Provide readable AngelScript examples on light documentation pages.
- Use stable semantic token classes that can later consume VS Code/LSP token data.
- Make the component usable from WikiText with a compact `as-code` widget.
- Keep copy behavior keyboard-accessible and avoid depending on clipboard access for rendering.

**Non-Goals:**

- No Unreal type database, compiler diagnostics, completion, symbol navigation, or live LSP connection in this version.
- No replacement of the existing TiddlyWiki core code-block renderer.
- No editor-like multi-line editing surface.

## Decisions

### 1. Browser-safe tokenizer instead of bundling the full LSP

Implement a focused tokenizer in `Wiki/src/angelscript-tools/highlighter.ts`. It scans the source once, preserves all source text, and emits escaped HTML spans with semantic classes. This avoids Node `fs`/`net` dependencies and keeps the initial page path small. The token class names deliberately map to the vocabulary already used by the project concept pages and VS Code semantic categories.

### 2. Widget as the primary authoring API

Expose `<$as-code>` from the plugin entry point. The widget accepts `language`, `title`, `lineNumbers`, and `copy` attributes and uses its text children as source. A `text` attribute is supported as a fallback for content containing WikiText syntax. The widget owns the card DOM, line-number rail, copy button, and accessible status text.

### 3. Documentation-card visual language

Use a quiet paper surface with a graphite code panel, thin rule borders, copper keyword accents, teal type accents, and amber macro accents. Avoid excessive gradients and large dashboard cards so the component reads as a technical document artifact. Responsive layout keeps the code panel horizontally scrollable only inside the code surface while the surrounding tiddler remains fluid.

### 4. Test through the existing Playwright setup

Add a test tiddler and focused Playwright spec. The test proves the plugin is loaded, the code is tokenized, line numbers match the source, and the copy control exposes a state change. TypeScript check, lint, build, and focused Playwright remain the required gates.

## Risks / Trade-offs

- [Lexical highlighting is not full parsing] Complex macros or malformed code may receive approximate colors → preserve source text and use conservative token rules; defer semantic resolution to a later bridge.
- [TiddlyWiki parses widget children] WikiText-like sequences inside code could be interpreted before the widget sees them → support the `text` attribute and use plain-text demo bodies in the first examples.
- [Clipboard permissions vary] Browser clipboard APIs may reject writes → keep the source in a data attribute, catch failures, and show a clear copy state without breaking rendering.
- [Large code blocks increase DOM size] One span per token can become expensive → only tokenize `as-code` instances and keep the first version synchronous and bounded.

## Migration Plan

1. Add the plugin source, widget test tiddler, and failing Playwright spec.
2. Implement the tokenizer and widget until the focused test is green.
3. Add the plugin readme/example documentation and run the complete Wiki checks.
4. Build the plugin artifact through the existing Modern.TiddlyDev commands.

The plugin is additive. Removing the plugin source and its test tiddler restores the previous Wiki behavior without changing existing tiddler syntax.

## Open Questions

The later LSP bridge transport is intentionally deferred until the offline widget and token contract are stable.
