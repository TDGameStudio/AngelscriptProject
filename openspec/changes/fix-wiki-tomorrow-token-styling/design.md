## Context

The authoritative reference is `Experiment/RefWiki/wiki/tiddlers/$__plugins_tiddlywiki_highlight_styles.tid` together with `Wiki/wiki/原来配色字体配置.jpg`. The reference stylesheet explicitly resets common Highlight.js semantic scopes to normal weight. It also keeps preprocessors brown, built-ins cyan, class titles yellow, function titles blue, keywords/types purple, numbers/attributes/symbols orange, strings green, and operators/substitutions at the base foreground.

The current grammar assigned every callable-looking identifier to `title.function`, so a control statement such as `if (` became a blue bold function title. It also wrapped UE reflection macros and `#if` directives in the same `meta` scope, preventing the reference cyan/brown distinction.

## Decisions

### Keep standard Highlight.js scopes as the styling contract

Use `built_in` for UE reflection macro names and the small project-owned built-in function vocabulary, `meta` for preprocessor directives, `title.class` for declaration names, `title.function` for ordinary calls, `keyword` for call-shaped control flow, and `type` for UE/AngelScript types. This preserves extension space in the grammar without introducing private token classes or a second tokenizer.

### Reproduce the reference role mapping, including weight

Move the theme stylesheet back to the full classic Tomorrow grouping rather than assigning several unrelated roles to orange or green. Explicitly set semantic title/keyword/type/built-in scopes to weight 400; retain weight 700 only for Highlight.js `strong` content. The code font remains the bundled Fira Code variable font.

### Verify computed browser styles

Playwright asserts rendered colors and weights rather than only checking stylesheet text. It also verifies that `if` is a keyword and no longer appears as a function title, ensuring the grammar and cascade work together.

## Risks / Trade-offs

- [Existing screenshots change slightly] → This is intentional restoration of the user's accepted reference styling.
- [A built-in vocabulary can never enumerate all Unreal methods] → Keep only stable project-level helpers as `built_in`; ordinary UE methods remain blue function titles and can be extended later without changing CSS.
- [Class declaration parsing could affect base types] → End the declaration-name mode before `:`, `{`, or `;`, leaving base classes to the existing type rule and covering the result in Playwright.
