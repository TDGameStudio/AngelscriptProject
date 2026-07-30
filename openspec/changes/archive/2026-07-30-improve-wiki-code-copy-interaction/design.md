## Context

`angelscript-tools` decorates both core `$codeblock` output and `$angelscript-code` output with the same browser-only copy button. The current 32px bordered button uses a local overlapping-rectangles glyph, is always visible, and already restores the idle icon after 1.5 seconds. The new interaction must retain the existing `copy="yes|no"` contract, labels, live status, Clipboard API path, and legacy `execCommand` fallback while making the control visually quieter and safe for repeated asynchronous clicks.

## Goals / Non-Goals

**Goals:**

- Use a compact, recognizable Copy glyph based on Heroicons' outline clipboard-document without importing a runtime icon package.
- Reveal the desktop control only when the reader is interacting with its code surface, without removing keyboard access.
- Keep the action discoverable on no-hover and coarse-pointer devices.
- Ensure the most recent copy attempt exclusively controls the feedback state and 1.5-second restoration timer.

**Non-Goals:**

- Change copied source selection, clipboard permissions, fallback behavior, localization tiddlers, or the public `copy` widget attribute.
- Add text labels, toast notifications, a loading state, a shared icon framework, or broad code-card visual redesign.

## Decisions

### Use an inline Heroicons clipboard-document outline

The idle icon will use Heroicons' MIT-licensed 24px, 1.5px-stroke `clipboard-document` outline in the existing inline SVG renderer, with the source noted in a short attribution comment. It gives the small affordance a distinct clipboard silhouette and document lines, making the copy action clearer than the generic two-overlapping-documents glyph. The glyph grows to 18px inside the unchanged 32px target so the lighter outline remains legible without becoming visually dominant. Success and error continue to use simple outline feedback symbols at the same stroke weight.

The core TiddlyWiki icons are mostly authored as filled SVG paths, but the active Wiki theme presents its controls as lightweight grey pictograms. The implementation therefore follows the rendered visual language rather than copying the core paths' fill mechanics: no solid icon blocks and no persistent button chrome while idle.

### Hide only idle desktop pointer presentation

The baseline CSS leaves the button visible and low-emphasis. A `(hover: hover) and (pointer: fine)` media query changes only an idle button to transparent and non-pointer-targetable. `pre:hover`, `pre:focus-within`, and non-idle states restore visibility. `pointer-events: none` does not remove the button from keyboard navigation; focus reaches it and `:focus-within` makes it visible before activation. This avoids relying on hover for touch users.

### Give the newest click ownership of feedback

The controller will keep a monotonically increasing attempt id. Each click invalidates any prior result and clears the existing restore timer. The success or failure callback updates the presentation only when its captured id matches the newest attempt. `showResult` starts a fresh 1.5-second timer, then restores the localized idle label, glyph, and live status. This prevents a slow older failure from replacing a newer success.

## Risks / Trade-offs

- [Hidden desktop control is less discoverable] → It appears on code-surface hover, keyboard focus, and every feedback state; the native localized title remains available when shown.
- [A clipboard carries more detail than the former generic glyph] → The 18px outline treatment preserves a quiet visual weight while retaining a distinct copy affordance.
- [Touch target is visually quieter] → The existing 32px control geometry and click path remain unchanged, while no-hover devices keep the control visible.
- [Clipboard callbacks can resolve out of order] → The attempt id discards stale callbacks and tests cover a second click inside the first feedback window.

## Migration Plan

No content or configuration migration is required. The behavior is loaded through the existing `angelscript-tools` plugin source. Reverting consists of restoring the two implementation files and the matching Playwright/documentation edits; no persisted reader state exists.

## Open Questions

None.
