## 1. Record and prototype contract

- [x] 1.1 Create the `improve-wiki-tiddler-toolbar-hover-layout` OpenSpec change and record the prototype-only scope, measured current geometry, selected compact candidate, and deferred production boundary.
- [x] 1.2 <!-- TDD --> Add a Playwright contract for the absent standalone artifact: it SHALL expect the current and proposed samples, exact measured button geometry, local interaction states, and narrow-screen stacking; run it and confirm the failure is the missing artifact.

## 2. Standalone visual review artifact

- [x] 2.1 <!-- Non-TDD --> Create `comparison-artifacts/tiddler-toolbar-hover-layout.html` as a zero-dependency, independently openable before/after comparison using native controls and inline no-fill line SVGs.
- [x] 2.2 <!-- TDD --> Rerun the focused Playwright contract; confirm current/proposed geometry, hover/focus layout stability, and 390px no-overflow behavior pass.
- [x] 2.3 <!-- Non-TDD --> Inspect the artifact at desktop and narrow widths, including More hover and keyboard focus, and record the review result in this change if later feedback changes the candidate.

## 3. Deferred production adaptation — requires visual approval

- [x] 3.1 <!-- TDD --> After the user approves the prototype, extend the live Angelscript theme browser coverage to assert direct tiddler-toolbar controls are square, spaced, and do not alter popup-menu rows.
- [x] 3.2 <!-- Non-TDD --> After approval, modify only the desktop `.tc-tiddler-controls > button` presentation in `Wiki/src/angelscript-theme/desktop-refinement.tid`: inline-flex group, 32×32px targets, 20px icons, 2px gaps, 5px radius, and 140ms colour-only feedback.
- [x] 3.3 <!-- TDD --> Run the affected live-toolbar browser suite, the full relevant Wiki visual suite, and `openspec validate improve-wiki-tiddler-toolbar-hover-layout --strict`; retain mobile and More-menu behavior unchanged.
