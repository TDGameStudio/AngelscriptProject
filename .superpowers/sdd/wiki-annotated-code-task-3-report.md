# Wiki annotated-code Task 3 — OpenSpec production record

## Status

`DONE_WITH_CONCERNS`

The production decision, delta requirements, component catalog entries, and task
record are updated. The three production widgets are recorded as `built`, not
`tested`, and task `2.13` remains unchecked because the required Task 1 and Task
2 final GREEN reports were not both available at the time of this record update.

## Files changed

- `openspec/changes/docs-wiki-content-and-expression-overhaul/design.md`
  - Added D10 selecting experiment 19 as an interaction direction rather than a
    standalone-page implementation.
  - Recorded the production widget contract, source/DOM boundary, interaction
    model, native capability/fallback ownership, no-dependency decision,
    responsive/print/reduced-motion behavior, lifecycle teardown, P02–P04
    evidence pages, and immutable experiment history.
  - Added mitigations for stale anchors, instance/Popover collisions, long-code
    lane competition, browser capability differences, and TiddlyWiki teardown.
- `openspec/changes/docs-wiki-content-and-expression-overhaul/specs/wiki-document-expression-components/spec.md`
  - Added normative requirements and WHEN/THEN scenarios for the exact author
    contract, backward compatibility, generic C++, pure source DOM/copy,
    unresolved anchors, progressive disclosure and keyboard access,
    native/manual equivalence, instance teardown, visual hierarchy, and
    source-revisioned P02–P04 evidence.
- `openspec/changes/docs-wiki-content-and-expression-overhaul/components-catalog.md`
  - Expanded the existing component table with example pages.
  - Replaced the `<$angelscript-code>` entry with its compatible annotated
    behavior.
  - Added `<$annotated-code>` and `<$code-note>`, their implementation form,
    purpose, boundary, state, and P02–P04 examples.
  - Recorded that the production implementation adds no external runtime
    dependency.
- `openspec/changes/docs-wiki-content-and-expression-overhaul/tasks.md`
  - Appended clean task `2.13`; left it unchecked pending complete report
    evidence.
- `.superpowers/sdd/wiki-annotated-code-task-3-report.md`
  - Added this execution and evidence report.

No numbered experiment HTML was edited.

## Validation

Command:

```powershell
openspec validate docs-wiki-content-and-expression-overhaul
```

Exact result:

```text
Change 'docs-wiki-content-and-expression-overhaul' is valid
```

Exit code: `0`.

Additional checks:

- `git diff --check` for the four OpenSpec record files exited `0` with no
  whitespace errors.
- `git diff --name-only` for the change listed only
  `components-catalog.md`, `design.md`,
  `specs/wiki-document-expression-components/spec.md`, and `tasks.md`.
- `git diff --name-only` for
  `comparison-artifacts/code-explanation/*.html` was empty.
- Fresh SHA-256 output for experiments `01`–`19` matched the pre-edit baseline
  captured at task start, including experiment 19
  `0275CA3007C7423BA6EA975ABD5F0C22DE38A4D6BA9571C57DCF73515C79CDC7`.
- Tasks `2.6`, `5.1`, `5.2`, `5.3`, and `5.4` remain unchecked.

## Evidence used for component and task state

- `.superpowers/sdd/wiki-annotated-code-task-1-report.md` still stated
  `Working status: IN_PROGRESS`. It recorded the expected RED result
  `0 passed / 1 failed`, while its files inventory, GREEN verification, and
  self-review remained `Pending`.
- `.superpowers/sdd/wiki-annotated-code-task-2-report.md` did not yet exist.
- Read-only inspection of `Wiki/src/angelscript-tools/index.ts` found the
  `AnnotatedCodeWidget` and `CodeNoteWidget` implementations and the
  `annotated-code` / `code-note` exports. Corresponding production styles were
  present in `Wiki/src/angelscript-tools/index.css`.

This evidence proves that the widget forms exist, so the catalog uses `built`.
It does not prove the required code-domain and document/content GREEN suites, so
the catalog does not use `tested` and task `2.13` is not marked complete.

## Self-review

- D10 captures every requested production choice and explicitly preserves
  experiments `01`–`19` as research history.
- The delta spec uses SHALL/MUST language and four-hash scenario headings with
  concrete WHEN/THEN assertions.
- The author contract keeps source exclusively in `code`, restricts the body to
  note definitions, preserves fixed AngelScript compatibility, and specifies
  generic C++ through `<$annotated-code language="cpp">`.
- The source boundary requires the official Highlight pipeline and sibling
  annotation layers, pure-source copy, geometry stability, and visibly
  unresolved invalid anchors.
- Interaction requirements keep short notes visible on desktop, make full
  WikiText detail click-disclosed and keyboard accessible, and prevent the lane
  from becoming a second dominant content column.
- Native capability and manual fallback behavior, multiple-instance isolation,
  refresh/destroy cleanup, narrow/print/reduced-motion behavior, and the
  no-external-dependency decision are all normative.
- P02–P04 are recorded as mapped, source-path/revisioned reader evidence.
- Unrelated planned component states and broad validation/integration tasks were
  not changed.
- No commit, push, reset, worktree creation, archive, or history rewrite was
  performed.

## Concern

Task 1 and Task 2 final reports must be re-read after their parallel work
finishes. Only if both contain the required successful code and
document/content verification evidence should the three catalog rows be raised
to `tested` and task `2.13` be checked.
