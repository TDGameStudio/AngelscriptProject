# Task 3 — Record the production annotated-code selection in OpenSpec

## Context

Tasks 1 and 2 will have implemented and tested a Wiki-native source annotation component plus P02–P04 Pattern Showcase pages. Update the existing long-lived OpenSpec change:

`openspec/changes/docs-wiki-content-and-expression-overhaul`

Read and obey root `AGENTS.md`, the `openspec-work` skill, and the current change context returned by:

```powershell
openspec status --change docs-wiki-content-and-expression-overhaul --json
openspec instructions apply --change docs-wiki-content-and-expression-overhaul --json
```

This is a dirty shared parent checkout. Preserve all existing edits, numbered experiments `01`–`19`, research files, and unrelated changes. Do not create a worktree, commit, push, reset, archive the change, or rewrite history.

## Required record updates

### Design

Append a new production decision after D9. Capture:

- Experiment 19 is selected as the interaction direction, not copied as a standalone page.
- Production form is a language-generic `<$annotated-code>` base, a fixed-AngelScript-compatible `<$angelscript-code>`, and direct child `<$code-note>`.
- Source stays in `code`; body contains only note definitions.
- Note relationships use displayed line/range plus optional exact substring/occurrence.
- Highlight remains the official TiddlyWiki pipeline; annotation nodes remain siblings outside `<pre>/<code>`.
- Desktop uses a restrained in-code annotation lane; short notes remain visible, hover/focus activates only the relationship, click opens WikiText details.
- DOM Range + native SVG own source measurement/connectors. Native Popover/CSS Anchor is preferred with manual fallbacks.
- No external runtime dependency is added.
- Narrow/print/reduced-motion behavior and widget teardown are required even though mobile visual polish is not a priority.
- P02, P03, and P04 are the production evidence pages.
- Existing experiments remain immutable research history.

Add risks/mitigations for:

- stale line/match anchors after source snapshot changes
- multiple widget anchor/Popover collisions
- note lane competition with long code
- browser capability differences
- TiddlyWiki refresh teardown

### Delta spec

Extend `specs/wiki-document-expression-components/spec.md` with production requirements and scenarios:

1. A reusable annotated-source component exposes the exact author contract above.
2. Existing `<$angelscript-code>` calls remain compatible and fixed to AngelScript.
3. Generic C++ uses `<$annotated-code language="cpp">`.
4. Notes do not contaminate or reflow source DOM and copy remains pure source.
5. Invalid anchors remain visibly unresolved and never point at the wrong code.
6. Short notes are always visible on desktop; full WikiText detail is click-disclosed and keyboard accessible.
7. Native capability and manual fallback behavior remain equivalent.
8. Multiple instances and TiddlyWiki refresh/destroy clean up state/listeners/observers.
9. Visual treatment inherits the Wiki Notion/Tomorrow/Fira code system and does not become a second dominant content column.
10. P02–P04 are mapped reader pages with source path/revision evidence.

Use normative SHALL/MUST language and concrete WHEN/THEN scenarios consistent with the existing spec style.

### Components catalog

Update `components-catalog.md`:

- Replace the existing `<$angelscript-code>` row with wording that includes direct child annotations while preserving line-control purpose.
- Add `<$annotated-code>` and `<$code-note>` with implementation form, purpose, boundary justification, test state, and P02–P04 examples.
- Mark them `tested` only if Task 1 and Task 2 reports show the relevant code/document feature tests passed.
- Record that there is no external production dependency.
- Do not change unrelated planned component states.

### Tasks

Append one clean task `2.13` for the production landing and mark it complete only if reports prove:

- core widgets implemented
- code tests passed
- P02–P04 and catalog/navigation implemented
- document/content tests passed

Do not mark broad `2.6`, `5.1`, or `5.4` complete unless their full stated scope has actually been verified. Leave commit/push/gitlink tasks unchecked.

### Validation

Run:

```powershell
openspec validate docs-wiki-content-and-expression-overhaul
```

Also inspect `git diff` and verify no numbered experiment HTML changed.

## Deliverable and report

Write:

`D:/Workspace/AngelscriptProject/.superpowers/sdd/wiki-annotated-code-task-3-report.md`

Include status, files changed, the exact validation result, report evidence used for tested/completed states, and self-review. Do not commit or push. Return only a short status summary.
