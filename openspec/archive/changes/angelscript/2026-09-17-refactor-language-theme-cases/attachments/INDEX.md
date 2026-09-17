# INDEX

## Current position

Apply 1.1-5.1 complete. Current specs `angelscript/testing/code-database` and `angelscript/testing/language-fixtures` are synced. Ready for completed archive. Knowledges remain change-local candidates.

## Hard conclusions

- FileTag is a theme pocket; several parentless VersionTags are legal; `root` is not privileged.
- Compile-fail and runtime-fail are two files (`CompileFail` / `RuntimeFail`).
- Cases open with `@begin`; callables use a function header (`@function` + `@summary` + `@inputs` + `@return`).
- This Change owns the parser, all Language author files, and the angelscript-test Skill / testing specs. Generator products stay out.

## Forbidden

- Do not edit Language `.as` files before the parser accepts `@begin` and parentless versions.
- Do not teach `Get(..., "root")` as the Language representative after Skill retarget.
- Do not change the 122 generator products in this Change.
- Do not link Change files to `openspec/drafts/`.

## Attachment index

- [Accepted design](drafts/design.md) — scoped design — when planning tasks or specs
- [Handoff](drafts/handoff.md) — success criteria and exclusions — when writing proposal/tasks
- [Glossary](drafts/glossary.md) — settled public names — when naming files, directives, or Builder APIs
- [Target overview](drafts/findings/target-overview.md) — first-change shape — when checking scope
- [Organize principles](drafts/findings/organize-principles.md) — P1–P7 — when classifying a Language version
- [Current markers](drafts/findings/current-markers.md) — live versus target marker layers — when editing the parser
- [Header tree](drafts/findings/header-tree-table.md) — header tree versus body diff — when a case has `@parent`
- [Function comment fields](drafts/findings/function-comment-fields.md) — function header fields — when marking a callable
- [Mark testable function](drafts/findings/mark-testable-function.md) — why `@function` — when choosing an entry mark
- [Skill companion](drafts/findings/skill-companion.md) — Skill and spec companions — when retargeting docs
- [Filename length](drafts/findings/filename-length.md) — Casting FileTags — when renaming Casting pockets
- [Topics open](drafts/findings/topics-open.md) — topics are open — when adding `@topic` words
- [Polarity names](drafts/findings/polarity-names.md) — Fail naming evidence — when adding Fail siblings
- [Talk: theme pocket](talks/talk-20260917-152400-theme-pocket.md) — FileTag pocket decision — before changing Builder topology
- [Talk: fail files](talks/talk-20260917-152410-fail-files.md) — two Fail files — before splitting negatives
- [Talk: author markers](talks/talk-20260917-152420-author-markers.md) — `@begin` / `@function` / `@summary` — before author-format tasks
- [Talk: first Change scope](talks/talk-20260917-152430-first-change-scope.md) — Change approval and scope — before shrinking the DAG
- [Knowledge: theme pocket](knowledges/theme-pocket-no-privileged-root.md) — reusable pocket model — candidate; remain change-local
- [Knowledge: open topics](knowledges/open-topics.md) — topic is not an enum — candidate; remain change-local
- [Knowledge: function header](knowledges/function-header.md) — function header contract — candidate; remain change-local
- [Origin marker](data/harness-origin.json) — frozen export list — when checking seed identity
- [Planning validation](data/planning-validation.md) — coverage / placeholder / symbol self-review — before treating the DAG as accepted
- `data/closure.yaml` — Completed-closure input for the archive primitive.
- `data/workflow-evaluation.md` — Terminal completed-closure evaluation bound to the current Change digest; write last.
