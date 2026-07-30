# Prototype review record

## 2026-07-26 — initial candidate

- Desktop view: the two samples appear side by side; the proposed More control shows a 32px square, quiet blue-gray hover surface while its neighboring controls retain their position.
- Narrow view: at 390px the samples stack in the intended order and the document has no horizontal scroll.
- Keyboard focus: the proposed controls show a visible solid outline without changing the button geometry.
- Scope check: the prototype is standalone. No file under `Wiki/src/angelscript-theme/` was changed.

## 2026-07-26 — production approval and live verification

- The user approved applying the reviewed compact candidate to the production desktop titlebar.
- The live desktop tiddler now renders four direct 32×32px controls with 20px line icons and 2px gaps; hovering More produces only a square, quiet blue-gray surface.
- Core titlebar CSS floats the control container `inline-end`; this blockifies the declared `inline-flex` group to a computed `flex` value without changing its compact layout.
- The More popup rows remain 30px grid rows with 16px line icons and vertically aligned labels.
- At 390px the desktop media rule does not apply; the existing mobile titlebar and bottom navigation remain unchanged.
