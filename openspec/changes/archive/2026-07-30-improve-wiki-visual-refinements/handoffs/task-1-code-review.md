# Task 1 code review: browser regression coverage

## Scope reviewed

- Requirements: `handoffs/task-1-brief.md`
- Implementer report: `handoffs/task-1-report.md`
- Submitted diff: `handoffs/task-1-review.diff`
- Current target diff: `Wiki/wiki/tiddlers/tests/playwright/angelscript-theme.spec.ts`

The submitted task diff changes only the allowed Playwright spec. The current Wiki worktree also has user-owned untracked reference artifacts/images, which are outside the submitted task and were not modified.

## Spec-compliance verdict: APPROVED

- The existing resize-rail test now asserts the required exact idle value, `expect(initial.railOpacity).toBe(0)`, while retaining its hit-target, fixed-geometry, scroll, hover, active-drag, and width-change checks.
- The added **More sidebar** test opens `/#AS/Workflow/GettingStarted`, selects main sidebar tab index `3`, uses the required secondary-category locator, verifies that the category-button collection is nonempty, confirms the selected category is visible, moves keyboard focus to a category button, and checks its visible solid `2px` focus outline. Its computed-style array assertion requires every secondary category button to have `borderRightWidth` equal to `0px`.
- The added **SDK description** test opens `/#AngelscriptWikiHome`, uniquely identifies the SDK tiddler frame, measures `.as-sdk-description`, `.tc-tags-wrapper`, and the `.tc-tiddler-body` element, and asserts the required sibling order plus `descriptionToTag <= 12` and `tagToBody > descriptionToTag`. It does not rely on a body text node.
- The supplied task report records the required red command exiting `1` due to the three intended CSS assertions (idle rail opacity, More-sidebar border, and SDK spacing), and explicitly distinguishes them from fixture/selector failures. Per review instructions, Playwright was not rerun.

## Code-quality verdict: APPROVED

- The tests derive expectations from computed styles, focus state, DOM hierarchy, and bounding-rectangle geometry rather than page-copy or brittle content assertions.
- Locators are scoped to the relevant sidebar/frame, and the SDK-frame evaluation contains clear failure messages for missing elements or elements outside the frame.
- The assertions are narrowly targeted to the requested visual regressions and preserve the existing test conventions. `git diff --check` reported no whitespace errors for the submitted spec.

## Final verdict: APPROVED

No changes required.
