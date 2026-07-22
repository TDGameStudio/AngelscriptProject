# Original LinOnetwo Palette Rollback Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use `superpowers:executing-plans` to implement this plan inline. Do not create a worktree, dispatch a subagent, or commit unless the user separately requests it.

**Goal:** Restore the original light LinOnetwo muted/control hierarchy without changing the accepted layout, visible focus treatment, or Tomorrow code palette.

**Architecture:** Lock all six palette roles in the existing desktop Playwright contract, then restore only those values in the theme palette. Validate the focused theme test first, followed by the full product browser suite and a 1440×1000 screenshot from the running product Wiki.

**Tech Stack:** TiddlyWiki 5 palette tiddlers, Playwright, Modern.TiddlyDev.

## Global Constraints

- Modify the current checkout only; do not create or use a worktree.
- Preserve the right sidebar, zoomin story view, fixed-light behavior, Tomorrow code tokens, and `:focus-visible` outline.
- Do not combine the Notion system-icon compatibility fix or sidebar-search removal with this palette rollback.
- Do not commit without an explicit user request.

---

### Task 1: Restore the original muted/control palette hierarchy

**Files:**

- Modify: `Wiki/wiki/tiddlers/tests/playwright/angelscript-theme.spec.ts`
- Modify: `Wiki/src/angelscript-theme/palette.tid`
- Verify: `Wiki/.generated/palette-rollback-desktop-review.png`

**Interfaces:**

- Consumes: `$tw.wiki.getTiddlerData('$:/palettes/Notion', {})` from the running Wiki.
- Produces: the original palette values `#bbb`, `#aaaaaa`, `#c0c0c0`, `#999999`, `#cccccc`, and `#c0c0c0` for their corresponding semantic roles.

- [x] **Step 1: Write the failing browser contract**

Extend the existing palette object and assertion in `angelscript-theme.spec.ts` to require:

```ts
expect(palette).toEqual({
  muted: '#bbb',
  sidebarControls: '#aaaaaa',
  sidebarMuted: '#c0c0c0',
  sidebarLink: '#999999',
  tiddlerControls: '#cccccc',
  tiddlerSubtitle: '#c0c0c0',
});
```

- [x] **Step 2: Verify RED**

Run:

```powershell
npx playwright test wiki/tiddlers/tests/playwright/angelscript-theme.spec.ts --grep "accepted desktop layout"
```

Expected: FAIL because the current six values are `#666666`.

- [x] **Step 3: Apply the minimal palette rollback**

Restore only these entries in `src/angelscript-theme/palette.tid`:

```text
muted-foreground: #bbb
sidebar-controls-foreground: #aaaaaa
sidebar-muted-foreground: #c0c0c0
sidebar-tiddler-link-foreground: #999999
tiddler-controls-foreground: #cccccc
tiddler-subtitle-foreground: #c0c0c0
```

- [x] **Step 4: Verify GREEN and regression coverage**

Run:

```powershell
npx playwright test wiki/tiddlers/tests/playwright/angelscript-theme.spec.ts
npm run test:playwright
```

Expected: the theme file passes 3/3 and the complete product suite passes 16/16 or its current higher total.

- [x] **Step 5: Inspect the running desktop result**

Capture `http://127.0.0.1:8080/#%24%3A%2FControlPanel` at 1440×1000 into `.generated/palette-rollback-desktop-review.png`. Confirm that muted controls regain the original light hierarchy while focus and code styles remain unchanged.

- [x] **Step 6: Close the record**

Mark OpenSpec task 5.1 complete, append the new command results to `verification.md`, and run `openspec validate improve-wiki-theme-and-code-experience --strict` from the parent repository.
