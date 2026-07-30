## Context

The live desktop titlebar renders four direct actions (More, Edit, Close, New Diagram). Its buttons are 32px wide but inherit the 32.9px title font and 39.48px line-height, producing a 32×39.48px hover surface. The visual symptom is especially obvious at high browser scale because the target becomes a tall highlighted block. The user selected a standalone before/after review artifact and explicitly deferred production application.

## Goals / Non-Goals

**Goals:**

- Make the inherited-height problem and its compact replacement visible in one self-contained HTML file.
- Lock the approved candidate to 32×32px targets, 20px line icons, 2px gaps, 5px radius, quiet blue-grey hover, and the existing 140ms color-only transition.
- Apply the approved candidate only to the desktop titlebar's direct tiddler actions.
- Keep the artifact keyboard reachable, inspectable at desktop width, and free of narrow-viewport overflow.
- Preserve More popup rows, real action behavior, and the mobile runtime path with live browser regression coverage.

**Non-Goals:**

- Do not modify core TiddlyWiki, vendor sources, generated line-icon assets, or the tiddler action definitions.
- Do not replace More, Edit, Close, or New Diagram behavior; the production change is presentation-only.
- Do not alter mobile runtime navigation or introduce a new toolbar component.

## Decisions

### 1. Store the prototype with its OpenSpec record

The comparison artifact SHALL live at `openspec/changes/improve-wiki-tiddler-toolbar-hover-layout/comparison-artifacts/tiddler-toolbar-hover-layout.html`, rather than under `Wiki/` or a published plugin. It is a review gate, must open without a server, and must not be serialized into the Wiki.

Alternative: place the HTML beneath `Wiki/comparison-artifacts/`. Rejected because the repository has previously removed such runtime-adjacent artifacts and the current request is prototype-only.

### 2. Render two measured toolbar samples

The left sample SHALL reproduce the observed current geometry: four contiguous 32×39.48px buttons with 24px line icons. The right sample SHALL render the approved compact geometry: four 32×32px controls, 20px icons, and 2px gaps. Both samples SHALL use the same title-bar context, icon order, colour family, and 24×24 / 1.5-stroke / no-fill visual language so geometry is the only material comparison.

Alternative: show only the approved design. Rejected because the tall inherited hover surface is subtle without a direct baseline.

### 3. Keep the interaction local, semantic, and motion-safe

Each visible control SHALL be a native `button` with an `aria-label`, tooltip text, hover, `:active`, and `:focus-visible` states. CSS SHALL change only foreground and background colour during the 140ms transition; it SHALL not animate position, size, margin, or transform. The page SHALL stack the two samples at 390px width without horizontal overflow.

Alternative: simulate menus or implement TiddlyWiki message actions. Rejected because that would test behavior outside the layout decision.

### 4. Apply the approved production boundary

The approved production task is limited to the desktop titlebar direct-control container: an inline-flex group, fixed 32px square controls, 20px icons, and a selector narrowed to `.tc-tiddler-controls > button`. It preserves real action tiddlers, current line-icon semantics, popup/menu markup, and the existing mobile path. Core titlebar CSS floats the container `inline-end`, so the browser reports a computed `flex` display even though the refinement declares `inline-flex`.

## Risks / Trade-offs

- [A stylized artifact could diverge from the live page] → Encode the live measured dimensions and test those values directly; use the existing action order and line-icon language.
- [The standalone page could accidentally become a runtime asset] → Store it only under the OpenSpec change and avoid wiki/plugin metadata, build configuration, or external imports.
- [The production selector could affect popup rows] → Scope the change to direct children of `.tc-tiddler-controls` and assert the tiddler More-menu rows retain their grid, 30px height, 16px icons, and text alignment.
