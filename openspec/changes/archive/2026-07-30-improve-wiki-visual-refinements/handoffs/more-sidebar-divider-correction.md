# More-sidebar divider geometry correction — 2026-07-23

## Clarified user intent

The defect was not that the More sidebar should have no divider. The divider was laid out on top of the `全部 / 最近 / 标签` category column. The desired result is one readable separator placed between the category controls and content.

## Root cause

At a 1440px viewport, browser measurements showed:

- category-buttons container: `x = 1021.61`, `width = 35.81`;
- first category button right edge: `x = 1059.42`;
- inherited vertical content-panel divider: `x = 1056.42`.

The divider therefore began before the category controls ended. Removing all borders hid the symptom but removed the intended visual separation.

## Final scoped rule

The local theme keeps category-button right borders disabled, then applies only to the More content panel:

```css
margin-left: 0.5rem;
border-left: 1px solid #ccc;
```

The resulting panel divider begins at `x = 1064.42`, leaving approximately 5px after the rightmost category button. No templates, generated files, content, or reference images were changed.

## Verification

The focused Angelscript theme Playwright suite passed **9/9 (9.2s)** after the revised test asserted the one-pixel panel divider plus a minimum 4px gap. `comparison-artifacts/more-sidebar.png` was refreshed from the running local preview.
