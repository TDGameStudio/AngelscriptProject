# Wiki annotated source component — Task 1 report

Working status: DONE_WITH_CONCERNS

## RED checkpoints

### RED 1 — public generic surface and direct child notes

Files added before production code:

- `Wiki/wiki/tiddlers/tests/playwright/AnnotatedCodeExample.tid`
- `Wiki/tests/playwright/product/code/annotated-code.spec.ts`

Command:

```powershell
npm exec --yes --package=node@24 --package=pnpm@11.8.0 -- pnpm run test:feature -- code --grep "renders generic and AngelScript child notes"
```

Result: expected feature failure, `0 passed / 1 failed`. Playwright found only the
pre-existing `<$angelscript-code>` surface (`Expected: 2`, `Received: 1`), proving
that `<$annotated-code>` was not registered before implementation.

The task brief's equivalent `npm exec ... --call "..."` spelling was attempted
first, but the locally installed npm rejected that invocation with `EUSAGE`
before Playwright ran. The supported `--` separator above preserves the pinned
Node 24 and pnpm 11.8.0 toolchain and produced the valid RED result.

GREEN 1 command:

```powershell
npm exec --yes --package=node@24 --package=pnpm@11.8.0 -- pnpm run test:feature -- code --grep "renders generic and AngelScript child notes"
```

Result: `1 passed / 0 failed`. Both generic `cpp` and fixed-language AngelScript
surfaces render direct child notes through standard Highlight tokens, ignore a
non-note body child, and keep annotation-owned DOM outside the highlighted
source.

### RED 2 — range resolution, ordering, and invalid-note fallback

Command:

```powershell
npm exec --yes --package=node@24 --package=pnpm@11.8.0 -- pnpm run test:feature -- code --grep "resolves exact occurrences"
```

Result: expected feature failure, `0 passed / 1 failed`. The minimal first-pass
renderer kept all seven notes in the embedded note lane instead of the three
resolved notes only; invalid line/range/match/occurrence cases had not yet moved
to the required after-code author section.

GREEN 2 command:

```powershell
npm exec --yes --package=node@24 --package=pnpm@11.8.0 -- pnpm run test:feature -- code --grep "resolves exact occurrences"
```

Result: `1 passed / 0 failed`. Exact second-occurrence geometry matches a native
Range over Highlight-produced text nodes; whole two-line selection produces two
non-zero marks; resolved notes sort by displayed source line; four invalid cases
remain visible, in author order, without marks or ports. A rerun attempt between
RED and GREEN was discarded as infrastructure-only because a stale prior test
server briefly held port 4173.

### RED 3 — interaction, disclosure, geometry, and copy continuity

Command:

```powershell
npm exec --yes --package=node@24 --package=pnpm@11.8.0 -- pnpm run test:feature -- code --grep "activates one exact relation"
```

Result: expected feature failure, `0 passed / 1 failed`. Hovering the first note
left its note/range relation without `is-active`; connectors, disclosure state,
and the interaction lifecycle had not yet been implemented.

GREEN 3 command:

```powershell
npm exec --yes --package=node@24 --package=pnpm@11.8.0 -- pnpm run test:feature -- code --grep "activates one exact relation"
```

Result: `1 passed / 0 failed`. Hover and keyboard focus activate only the owning
note, exact range marks, source/note micro-ports, and SVG connector. Native
Popover discloses one WikiText detail per block with synchronized ARIA and closes
on re-click, outside click, and Escape. Every interaction preserves source text,
line rectangles, card geometry, and scroll extents; copy still returns only the
selected source. Chromium's Popover focus restoration exposed a 1px programmatic
vertical scroll in an otherwise unbounded horizontal scroller, so unbounded
surfaces now keep `scrollTop` at zero while bounded surfaces retain vertical
scrolling.

### RED 4 — capability fallbacks, isolation, and teardown

Command:

```powershell
npm exec --yes --package=node@24 --package=pnpm@11.8.0 -- pnpm run test:feature -- code --grep "capabilities exist"
```

Result: expected feature failure, `0 passed / 1 failed`. The native browser path
rendered but exposed no `data-popover-mode`/`data-anchor-mode` capability
contract; forced no-anchor/no-Popover paths and their lifecycle cleanup were not
yet implemented.

GREEN 4 commands:

```powershell
npm exec --yes --package=node@24 --package=pnpm@11.8.0 -- pnpm run test:feature -- code --grep "capabilities exist"
npm exec --yes --package=node@24 --package=pnpm@11.8.0 -- pnpm run test:feature -- code --grep "Anchor Positioning is unavailable"
npm exec --yes --package=node@24 --package=pnpm@11.8.0 -- pnpm run test:feature -- code --grep "fixed non-Popover"
npm exec --yes --package=node@24 --package=pnpm@11.8.0 -- pnpm run test:feature -- code --grep "disconnects observers"
```

Result: four focused runs, each `1 passed / 0 failed` (`4 passed / 0 failed`
combined). Native Popover + CSS Anchor Positioning is preferred; forced
no-anchor keeps native Popover with manual viewport-clamped positioning; forced
no-Popover uses an equivalent fixed disclosure with outside/Escape dismissal.
Instance IDs and ARIA targets are unique, active/open state remains
instance-local, an orphan note warns while preserving its body, and refresh
disconnects every observed old surface, closes old disclosure DOM, and removes
owned document listeners before replacements register.

### RED 5 — narrow presentation fallback

Command:

```powershell
npm exec --yes --package=node@24 --package=pnpm@11.8.0 -- pnpm run test:feature -- code --grep "after-code narrow fallback"
```

Result: expected feature failure, `0 passed / 1 failed`. At the narrow viewport
the annotation connector remained visible, proving that the production
stylesheet had not yet switched the relationship into the required after-code
fallback.

GREEN 5 commands:

```powershell
npm exec --yes --package=node@24 --package=pnpm@11.8.0 -- pnpm run test:feature -- code --grep "after-code narrow fallback"
npm exec --yes --package=node@24 --package=pnpm@11.8.0 -- pnpm run test:feature -- code --grep "bounded source|prints details|Wiki-aligned"
```

Result: `1 passed / 0 failed`, then `3 passed / 0 failed` (`4 passed / 0
failed` combined). The bounded surface retains coherent mark/note motion while
scrolling and avoids note/ink and note/note collisions. At 390 px, relationship
chrome is removed and all notes follow the source without document overflow.
Print exposes detail bodies statically while removing copy and interaction
chrome. Reduced-motion removes transitions, and computed production colors and
font roles match the Wiki-owned code/note/detail tokens.

### Full-group fixture expectation correction

The first complete `test:feature -- code` run produced `21 passed / 2 failed`.
Both failures were test-only stale cardinalities after the final fixture grew:
the public-surface test still expected one summary although its generic block
now intentionally defines two, and the lifecycle test still expected three
annotated instances although the bounded fixture is the fourth. Their assertions
were updated to verify all intended fixture instances before rerunning the full
group.

### RED 6 — long-source desktop note rail

Command:

```powershell
npm exec --yes --package=node@24 --package=pnpm@11.8.0 -- pnpm run test:feature -- code --grep "desktop note rail"
```

Result: expected regression failure, `0 passed / 1 failed`. The real P03
Showcase page loaded all seven notes and independently proved
`scrollWidth > clientWidth`, but `allSummariesVisible` was `false`: the note
rail was positioned at the right edge of the `max-content` source column rather
than the right edge of the current scroll viewport.

GREEN 6 command:

```powershell
npm exec --yes --package=node@24 --package=pnpm@11.8.0 -- pnpm run test:feature -- code --grep "desktop note rail"
```

Result: `1 passed / 0 failed`. P03 retains horizontal source overflow while all
seven summaries remain inside the scroll viewport before and after scrolling
to the far right. The rail keeps the same viewport x-position, source text and
scroll extent stay unchanged, and connector paths change after horizontal
scroll, proving their geometry was recomputed.

### RED/GREEN 7 — surface-width-aware after-code layout

RED command:

```powershell
npm exec --yes --package=node@24 --package=pnpm@11.8.0 -- pnpm run test:feature -- code --grep "narrow annotated container"
```

Initial result: expected failure, `0 passed / 1 failed`; the wide P03 surface
had no `data-annotation-layout="rail"` state because annotation layout was
controlled only by viewport media queries. After the first minimal
ResizeObserver implementation, the mode changed correctly but rectangle
evidence exposed a second root cause: a 500px surface was `[349,849]`, while
each summary was `[409,883]`. The after-code column used `width:100%` after the
roughly 60px gutter instead of consuming the remaining flex width.

GREEN command: the same focused command.

Final result: `1 passed / 0 failed`. Wide P03 remains in `rail` mode; constraining
its own tiddler body to 500px on a 1280px desktop viewport switches the surface
to `after-code`, hides overlays, and contains all seven summaries. The existing
ResizeObserver now observes both source and surface; the after-code flex column
uses only the width remaining after the gutter.

### RED/GREEN 8 — short-source collision stack height

RED command:

```powershell
npm exec --yes --package=node@24 --package=pnpm@11.8.0 -- pnpm run test:feature -- code --grep "colliding short note"
```

Result: expected failure, `0 passed / 1 failed`. Five valid notes on the same
line were collision-free, but both `lastInsideColumn` and
`lastInsideSurface` were `false`, proving absolute note placement did not
contribute to ancestor height.

GREEN command: the same focused command.

Result: `1 passed / 0 failed`. The final collision-stack bottom now contributes
to rail-mode column `min-height` together with the natural source height.
Unbounded short source expands to contain all five notes. A
`maxVisibleLines="3"` surface instead gains real vertical overflow; after
scrolling to the end its fifth note remains inside the scroll viewport and can
receive keyboard focus.

### RED/GREEN 9 — fallback disclosure scroll tracking and teardown

RED commands:

```powershell
npm exec --yes --package=node@24 --package=pnpm@11.8.0 -- pnpm run test:feature -- code --grep "Anchor Positioning is unavailable|fixed non-Popover|disconnects observers"
npm exec --yes --package=node@24 --package=pnpm@11.8.0 -- pnpm run test:feature -- code --grep "disconnects observers"
```

The first run produced `2 passed / 1 failed`: after a 120px page scroll, the
no-anchor summary moved by 120px while its manually positioned native Popover
moved by 0px. The tightened lifecycle-only run produced `0 passed / 1 failed`;
capture-scroll listener count stayed at the homepage baseline `1 → 1` after
loading the annotated fixture, proving the component owned no such handler.

GREEN command: the first three-test command above.

Result: `3 passed / 0 failed`. Surfaces that have expandable resolved notes and
need manual positioning now own a capture-phase window scroll handler. It
coalesces page and descendant scrolling into the existing RAF geometry pass.
Native no-anchor Popovers follow page movement; fixed no-Popover details follow
bounded internal scrolling and page scrolling, including legal top/bottom
placement flips, and remain viewport-clamped. Listener options are retained for
matching removal; the homepage-baselined audit proves refresh replacement does
not leak capture handlers.

### RED/GREEN 10 — direct-child dynamic attribute refresh

Command:

```powershell
npm exec --yes --package=node@24 --package=pnpm@11.8.0 -- pnpm run test:feature -- code --grep "direct child note fields"
```

RED result: `0 passed / 1 failed`. Updating field-backed `label`, `line`, and
`match` values left the parent surface ID at `as-code-1`, demonstrating that
the parent checked only its own attributes and delegated a change that affects
parent-owned summary/range/connector DOM to the child.

GREEN result: `1 passed / 0 failed`. Parent refresh now computes the attributes
of its direct `CodeNoteWidget` children and rebuilds itself if any change.
The regression proves a new instance ID, updated label and displayed line, and
native-Range-aligned geometry over the newly selected `Beta` match. Body-only
changes still use normal child refresh.

### RED/GREEN 11 — explicit empty match and whole empty-line anchor

Command:

```powershell
npm exec --yes --package=node@24 --package=pnpm@11.8.0 -- pnpm run test:feature -- code --grep "explicit empty match"
```

RED result: `0 passed / 1 failed`. The unresolved section contained no notes,
proving an explicitly supplied empty `match` was accepted as a zero-length
resolved match.

GREEN result: `1 passed / 0 failed`. `hasMatch` with an empty string is now
invalid and remains visible only in the unresolved section. A match-less
whole-line note targeting a genuinely empty line stays resolved: when native
Range returns no non-zero rectangle, the renderer derives a small non-zero
anchor from Highlight code padding, computed line height/font size, and the
source line index. The normal source-port and connector pipeline then produces
one mark, one port, and one connector.

### RED/GREEN 12 — unresolved distinct title ordering

Command:

```powershell
npm exec --yes --package=node@24 --package=pnpm@11.8.0 -- pnpm run test:feature -- code --grep "unresolved distinct title"
```

RED result: `0 passed / 1 failed`. The unresolved note retained its label and
WikiText body, but no `.angelscript-code-note-detail-title` existed when
`title` differed from `label`.

GREEN result: `1 passed / 0 failed`. An unresolved note with detail now inserts
the distinct title as a static `strong` heading at the start of its unresolved
body before rendering the author-provided WikiText. The regression verifies
the exact `label -> title -> body` DOM order.

### RED/GREEN 13 — stable visible empty-line geometry precondition

The parent fresh full-code run supplied the RED: the empty-line mark count was
one, but `boundingBox()` returned `null`. Inspection showed the surface had
selected container-aware `after-code` layout, where the range layer is
intentionally hidden. The test had asserted visible rail geometry without first
declaring a rail-layout precondition. A local baseline repeat happened to pass
`5/5`, confirming the setup was environment/layout-dependent rather than a
failure to create the synthetic mark.

The test-only fix sets the viewport to `1280x900` before navigation and waits
for `data-annotation-layout="rail"` before asserting the unresolved contract
and the visible non-zero mark, source port, and connector. No production code
or functional assertion was weakened.

Focused stability command:

```powershell
npm exec --yes --package=node@24 --package=pnpm@11.8.0 -- pnpm run test:feature -- code --grep "explicit empty match" --repeat-each 5
```

GREEN result: `5 passed / 0 failed`. Since all five repetitions reached the
explicit rail condition and returned a non-null, non-zero mark rectangle, no
additional RAF or font-readiness wait was indicated.

## Files changed

- `Wiki/src/angelscript-tools/index.ts`
  - Adds the generic `annotated-code` and direct-child `code-note` exports.
  - Refactors the existing AngelScript surface onto shared rendering without
    changing its fixed language, line controls, Highlight path, or copy source.
  - Implements note resolution, range/port/connector layout, collision
    avoidance, disclosure capability fallbacks, ARIA state, and teardown.
- `Wiki/src/angelscript-tools/index.css`
  - Adds the embedded annotation lane, quiet comment treatment, exact-range
    chrome, details, active/focus state, narrow fallback, print presentation,
    and reduced-motion rules using the approved Wiki tokens.
  - Adds an independent opaque rail background so source tokens remain
    visually separated from the viewport-fixed desktop notes.
- `Wiki/wiki/tiddlers/tests/playwright/AnnotatedCodeExample.tid`
  - Adds hidden generic, AngelScript, resolution/invalid, orphan, and bounded
    fixtures.
- `Wiki/wiki/tiddlers/tests/playwright/AnnotatedCodeStackExample.tid`
  - Adds colliding short-note fixtures for unbounded and bounded source cards.
- `Wiki/wiki/tiddlers/tests/playwright/AnnotatedCodeDynamicExample.tid`
  - Adds field-backed child-note attributes for parent refresh coverage.
- `Wiki/wiki/tiddlers/tests/playwright/AnnotatedCodeEdgeExample.tid`
  - Adds explicit-empty-match, whole-empty-line, and unresolved-title fixtures.
- `Wiki/tests/playwright/product/code/annotated-code.spec.ts`
  - Adds production-domain Playwright cases spanning the complete public,
    geometry, interaction, capability, lifecycle, responsive, print, and visual
    contract.
- `Wiki/src/angelscript-tools/readme.tid`
  - Documents ordinary core code, line-controlled AngelScript, annotated
    AngelScript, generic C++, complete surface/note attributes, and invalid-note
    fallback in Chinese and English.
- `Wiki/src/angelscript-tools/plugin.info`
  - Bumps the internal plugin version from `0.3.1` to `0.4.0`.
- `.superpowers/sdd/wiki-annotated-code-task-1-report.md`
  - Records TDD and verification evidence.

## GREEN verification

Final fresh verification is recorded below:

```powershell
npm exec --yes --package=node@24 --package=pnpm@11.8.0 -- pnpm run test:feature -- code
```

Final fresh result: `29 passed / 0 failed` in `25.4s` (exit `0`). This includes
all seventeen annotated-source cases and all twelve pre-existing code domain
cases.

```powershell
npm exec --yes --package=node@24 --package=pnpm@11.8.0 -- pnpm run check
```

Final post-cleanup result: exit `0`, no TypeScript errors.

```powershell
.\node_modules\.bin\eslint.cmd src/angelscript-tools/index.ts tests/playwright/product/code/annotated-code.spec.ts
```

Final post-cleanup result: exit `0`, `0 errors / 0 warnings` for the
implementation and new tests.

```powershell
git diff --check
git diff --check -- .superpowers/sdd/wiki-annotated-code-task-1-report.md
```

Result: both exit `0`. The Wiki command reports only existing line-ending
conversion warnings for unrelated dirty files; it reports no whitespace error.

```powershell
npm exec --yes --package=node@24 --package=pnpm@11.8.0 -- pnpm run lint
```

Result: exit `1`, `9 errors / 1456 warnings`. None is in a Task 1 file. All nine
errors are pre-existing/concurrent assertions in
`tests/playwright/product/tools/tiddler-toolbar-hover-prototype.spec.ts`; the
warnings are likewise emitted from unrelated dirty files. Those files were
left untouched as required.

## Public-contract and source-continuity self-review

- Exports: one existing widget module now exports `annotated-code`,
  `angelscript-code`, and `code-note`; generated IDs, anchor names, controls,
  and state are instance-local.
- Source input: both surfaces read source only from `code`. Direct `code-note`
  children are definitions; non-note children remain ignored. A standalone
  note renders a warning and preserves its WikiText body.
- Language: generic blank language resolves to `text` and is forwarded directly
  to TiddlyWiki Highlight; AngelScript ignores any supplied language and stays
  `angelscript`.
- Existing attributes: `title`, `lineNumbers`, `highlightLines`, `fromLine`,
  `toLine`, `startLine`, `maxVisibleLines`, and `copy` retain their prior
  parsing, numbering, clamping, viewport, and copy semantics.
- Highlight continuity: the widget creates a standard `codeblock` parse-tree
  child. No new tokenizer or `as-code-token--*` class exists; tests require
  standard `hljs-*` output for both C++ and AngelScript.
- Note contract: positive displayed `line`, inclusive defaulted `toLine`, exact
  `match`, positive 1-based `occurrence`, required `label`, defaulted `title`,
  optional WikiText detail, whole-line ranges, line sorting, and stable author
  ordering for ties are implemented and exercised.
- Invalid notes: malformed/out-of-range/reversed/unmatched notes cannot create
  marks or ports. An explicitly present empty `match` is invalid rather than a
  zero-length resolution. Labels and bodies remain visible in author order
  under `未定位注解`; a distinct title is retained before the body.
- DOM continuity: Highlight-owned `<pre>/<code>` contains source tokens only.
  Marks, ports, connector SVG, notes, and details are sibling layers.
- Geometry: selected-source offsets map into Highlight-produced text nodes and
  native `Range.getClientRects()`. Browser tests compare an exact match to an
  independent native Range and prove full-line multi-rect behavior.
- Interaction: hover and focus activate only the owning note, range rectangles,
  micro-port, and connector. Click/re-click, a second note, outside click, and
  Escape maintain one disclosure per surface with synchronized
  `aria-controls`/`aria-expanded`.
- Capability handling: native Popover + CSS Anchor is preferred; pre-load
  overrides prove native Popover/manual positioning and non-Popover fixed
  disclosure without any production test-only switch.
- Copy and layout invariants: after all interaction, copied text remains the
  selected source only. Code text, source rectangles, card rectangles, scroll
  extents, and unbounded scroll position remain unchanged.
- Multiple instances and lifecycle: IDs and control targets are unique, state
  does not leak between blocks, and a refresh proves old observers and document
  listeners are removed. `onDestroy` cancels RAF, disconnects the observer,
  closes disclosure state, and removes every owned listener.
- Bounded layout: source marks and note lane move coherently during vertical
  scrolling. Stable source-order placement prevents note/note collision and
  keeps notes clear of source ink. A five-note stack over a one-line/two-line
  source contributes its final bottom edge to unbounded surface height and
  remains keyboard/scroll reachable in a bounded card.
- Empty-line geometry: a match-less whole-line note on a genuinely empty source
  line synthesizes one non-zero mark using the Highlight surface's computed
  font and line metrics, then uses the ordinary port/connector path.
- Dynamic child inputs: changes to field-backed direct-child `label`, `line`,
  and `match` attributes rebuild the parent-owned summaries and geometry;
  detail-body-only refresh remains delegated to the child.
- Long-source desktop layout: the rail is positioned in source-column
  coordinates from `scrollLeft + clientWidth - gutterWidth - laneWidth`, with an
  independent background layer. It therefore remains fixed at the visible
  code-card edge while source continues to scroll underneath its own viewport.
  Scroll events are RAF-coalesced and rerun connector geometry; no source DOM,
  text, width, or copy input is modified.
- Container responsiveness: every geometry pass selects rail or after-code
  layout from the annotated surface's own width. A roughly 500px embedded card
  therefore stacks its notes even inside a desktop viewport, while the normal
  wide P03 card retains its visible rail.
- Manual-detail tracking: capability fallback surfaces own one capture-phase
  window scroll listener. Page scroll and bounded-ancestor scroll both schedule
  the same RAF-clamped position pass, and refresh/destroy removes the listener
  with matching options.
- Visual contract: only annotated blocks reserve the approximately `14rem`
  embedded lane. Short notes use Fira Code, secondary ink, no shadow, no pill
  fill, and quiet 4px/1px relationship chrome; expanded details alone use the
  sans-serif card treatment and restrained shadow.
- Alternate media: a 390px viewport has no document overflow or lost notes and
  switches to after-code source order with overlays hidden. Print hides
  interactive chrome and exposes detail bodies statically. Reduced motion
  yields zero-duration feedback. Computed paper, rule, secondary ink,
  scrollbar/detail border, and type roles match the requested tokens.
- Author boundary: the bilingual plugin readme distinguishes ordinary
  `$codeblock`, enhanced AS, annotated AS, and generic annotated source; its
  tables state that source remains the `code` attribute and document every
  invalid-note fallback.

## Concerns and deferred items

- The full repository lint gate remains red only because unrelated concurrent
  dirty files contain nine ESLint errors and 1456 formatting warnings. Task 1's
  implementation and test files pass a scoped ESLint run with zero findings.
- No formatter, `lint:fix`, worktree, commit, push, reset, OpenSpec edit, or
  numbered experiment HTML edit was performed.

## Root final verification: bounded-scroll geometry synchronization

The root-agent rerun exposed one additional intermittent test-read race in
`keeps bounded source marks and annotations coherent while avoiding
collisions`. This did not require a production-code change.

- RED: a first repeated run failed `1/10`; a diagnostic `20`-repeat run failed
  once. At `scrollTop=80`, the note had moved from `1162.890625` to
  `1082.890625`, while the Range mark was temporarily present in the DOM at
  `y=0`.
- Root cause: the component intentionally coalesces Range geometry redraws
  through `requestAnimationFrame`. The test waited only for the synchronous
  scroll position, then sometimes sampled the newly recreated mark before its
  scheduled position pass completed. Playwright `boundingBox()` also returns
  `null` when the mark is almost fully clipped by the bounded viewport, even
  though `getBoundingClientRect()` still exposes the geometry the assertion is
  meant to compare.
- Fix: the test now reads DOM rectangles and condition-polls the actual
  contract — convergence of note displacement and mark displacement — without
  a fixed delay or weakened geometry threshold.
- GREEN: focused `--repeat-each=30` passed `30/30`; a fresh full code-domain
  rerun passed `29/29`. TypeScript check and the relevant content contract also
  remained green.
