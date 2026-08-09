# Task 1 — TDD implementation of the Wiki annotated source component

## Context

Implement the approved production adaptation of experiment 19 inside the `Wiki/` submodule. Work in the current checkout as required by the repository `AGENTS.md` files. Do not create a worktree, commit, push, reset, or overwrite unrelated dirty changes.

Read these first:

- `AGENTS.md`
- `Wiki/Agents.md`
- `Wiki/src/angelscript-tools/index.ts`
- `Wiki/src/angelscript-tools/index.css`
- `Wiki/src/angelscript-tools/readme.tid`
- `Wiki/tests/playwright/product/code/presentation.spec.ts`
- `Wiki/tests/playwright/product/code/narrow-reading.spec.ts`

Use `superpowers:test-driven-development`: add the smallest real Playwright fixture/test for each behavior, run it and observe the expected missing-feature failure, then implement the minimum production behavior and rerun it green. Record the RED and GREEN commands/results in the report.

## Public author contract

Add three widget exports in the existing `module-type: widget` entry:

1. `<$annotated-code>` — language-generic enhanced code surface.
2. Existing `<$angelscript-code>` — remains fixed to `angelscript`, keeps every existing attribute and DOM/copy behavior, and gains direct child notes.
3. `<$code-note>` — valid as a direct child of either code surface.

Example:

```tid
<$annotated-code
  language="cpp"
  title="Lifecycle bridge"
  code={{{ [[$:/tests/TDGameStudio/AngelscriptWiki/Code/AnnotatedCpp]get[text]] }}}
  lineNumbers="yes"
  startLine="120"
>
  <$code-note
    line="123"
    match="CanCallScriptFunctions()"
    occurrence="1"
    label="先验证脚本上下文"
    title="生命周期保护"
  >
''完整解释''可以包含 WikiText、`inline code`、内部链接和列表。
  </$code-note>
</$annotated-code>
```

Shared code-surface attributes and semantics stay exactly compatible with the existing widget:

- `code`, `title`, `lineNumbers`, `highlightLines`, `fromLine`, `toLine`, `startLine`, `maxVisibleLines`, `copy`.
- `code` remains the only source input. The widget body is never source.
- `<$annotated-code language="">` defaults to `text` and forwards the language through the existing core Highlight pipeline.
- `<$angelscript-code>` always uses `angelscript`; a supplied `language` does not change it.
- Non-note body children remain ignored for backward compatibility.

`<$code-note>`:

- `line`: required positive displayed line number, using the same displayed-number coordinate system as `highlightLines`.
- `toLine`: optional inclusive displayed end, default `line`.
- `match`: optional exact substring inside that displayed line range; absent means the whole declared line range.
- `occurrence`: optional positive 1-based match occurrence, default `1`.
- `label`: required, always-visible short note.
- `title`: optional expanded-detail heading, default `label`.
- Body: optional WikiText detail. If absent, render a non-expanding short note.
- Sort notes by displayed source line, stable for ties.
- Generate instance-local unique IDs/anchor names; authors do not provide IDs.
- Invalid/out-of-range lines, reversed ranges, invalid occurrence, or a supplied match that is absent must not create a false connector. Keep their content visible in an after-code “未定位注解” author section.
- An orphan `<$code-note>` outside a supported parent renders a lightweight author warning rather than throwing or silently losing its body.

## Source and interaction invariants

- Keep `tiddlywiki/highlight` as the sole highlighter. Never add a tokenizer or `as-code-token--*` classes.
- `<pre>/<code>` must contain only highlighted source. Notes, range marks, ports, SVG, and details are sibling layers.
- Resolve note ranges after highlighting by mapping selected-source offsets to Highlight-produced text nodes and native `Range.getClientRects()`.
- Hover/focus only activates the exact source range, micro-port, connector, and short note.
- Click opens the full detail. One detail per code block at a time. Re-click, outside click, and `Escape` close it. Keep `aria-expanded` and `aria-controls` synchronized.
- Prefer native `popover="auto"` plus unique CSS Anchor Positioning. Provide manual fixed positioning when anchor positioning is unavailable, and a non-Popover fixed disclosure when Popover is unavailable.
- Existing code copy must copy only the selected source, never annotations.
- Opening/closing/activating notes must not change code-line text, order, wrapping, position, or size.
- Multiple blocks on one page must not share state or IDs.
- `onDestroy` must disconnect `ResizeObserver`, cancel RAF, close disclosures, and remove owned listeners.

## Visual design

Subject: source-level AngelScript/C++ documentation for technical readers. The code remains the hero.

Tokens:

- code paper `#f8f8f8`
- card/page `#ffffff`
- rule `#e1e1e1`
- note/secondary ink `#667383`
- focus/accent `var(--as-control-focus, #4271ae)`
- scrollbar/border `#d6dbe1`

Type:

- source and short note: existing `Fira Code VF`
- detail body: existing `ui-sans-serif, system-ui`

Layout:

- Preserve the existing code card and header.
- Only annotated blocks reserve an approximately `14rem` annotation lane inside the code surface, to the right of source ink. This is not a page-level second column.
- The source stays `white-space: pre`; long surfaces scroll internally.
- Use stable source-order collision avoidance. Notes must not cover source ink or each other.

Signature:

- A 4–5px micro-port and a 1px low-opacity, no-arrow SVG relationship line from the exact source range to the short note.
- Default connectors stay quieter than syntax highlighting; focus/active may strengthen to the Wiki focus blue.

Self-critique constraint:

- Short notes must read like subtle code comments, not cards or pills. No shadow on short notes, no saturated fill, no decorative numbering unless the order is genuinely needed for disambiguation. A restrained shadow is allowed only on expanded detail.

Narrow/print/reduced motion:

- Mobile polish is not a goal, but no document-level overflow or lost content is allowed. When the surface cannot host the embedded lane, hide SVG/range overlays and show notes in source order after the code.
- Print hides interactive chrome/SVG and expands detail text statically.
- `prefers-reduced-motion` disables transitions. Normal motion is limited to short color/border feedback.

## Required tests

Extend the existing code product domain and add hidden fixture tiddlers as needed. At minimum prove:

1. Every pre-existing `<$angelscript-code>` assertion remains green.
2. AngelScript child notes and generic `cpp` notes render through standard `hljs-*` tokens.
3. Exact displayed-line/match/occurrence resolution, full-line range behavior, and source-order sorting.
4. `<pre>/<code>` has no note/connector/detail contamination.
5. Pure-source copy after interaction.
6. Geometry is unchanged before/after hover, focus, open, close.
7. Keyboard focus, click, outside click, and Escape behavior with ARIA state.
8. Invalid note fallback without a false connector.
9. Multiple component isolation and refresh/destroy cleanup.
10. Native capability mode plus forced no-anchor and no-Popover fallbacks, using pre-load browser capability overrides rather than a production test-only API.
11. Bounded vertical scrolling keeps source and annotations coherent.
12. Narrow containment, print static details, and reduced-motion styles.
13. Computed Wiki-aligned paper/border/font/note colors.

Use the project-owned Node/pnpm versions:

```powershell
npm exec --yes --package=node@24 --package=pnpm@11.8.0 --call "pnpm run test:feature -- code --grep <focused-pattern>"
```

Do not run `lint:fix` or any formatter that rewrites unrelated files.

## Deliverable and report

Write your implementation report to:

`D:/Workspace/AngelscriptProject/.superpowers/sdd/wiki-annotated-code-task-1-report.md`

The report must include:

- `DONE`, `DONE_WITH_CONCERNS`, `NEEDS_CONTEXT`, or `BLOCKED`
- files changed
- RED commands and expected failure summaries
- GREEN commands and exact pass/fail counts
- self-review against every public-contract and source-continuity requirement
- any concern or deferred item

Do not commit or push. Return only the status, one-line test summary, and concerns in your final response.
