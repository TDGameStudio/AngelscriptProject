# INDEX

## Current position

All tasks complete (1.1–4.1). Containers and remaining Bindings types are admitted; projections, spec, Skill routing, and HostApiFixtureCorpus are green. Ready for verify and archive.

## Hard conclusions

- Admitted value-container root is `AngelscriptTestCode/Containers/`.
- This Change absorbs Bindings leftovers (580) plus Pending/Containers (240) plus overlapping Pending/Math (111).
- T* and SoftObjectPath go under `Containers/`; remaining Bindings types go to `Unreal/<Type>` and merge on collision.
- Unreal first-batch UClass+World stays in `feature-unreal-fixture-root`.

## Forbidden

- Do not copy `@version root` stars or Bindings mashups as-is.
- Do not revive `Bindings/` as an admitted root.
- Do not write AActor into `Containers/`.
- Do not delete TSet files marked not-TSet-API.
- Do not depend on `openspec/drafts/` paths.

## Attachment index

- [design](drafts/design.md) — accepted scoped design.
- [handoff](drafts/handoff.md) — accepted handoff and Change identity.
- [glossary](drafts/glossary.md) — Containers root, Unreal/<Type>, Change ID.
- [bindings-intake](drafts/findings/bindings-intake.md) — full Bindings and Containers census.
- [host-destinations](drafts/findings/host-destinations.md) — split-root landing.
- [two-changes](drafts/findings/two-changes.md) — sibling Change boundaries.
- [talk-20260917-164800-host-api-scope](talks/talk-20260917-164800-host-api-scope.md) — approval of this Change.
- [host-api-two-source-merge](knowledges/host-api-two-source-merge.md) — candidate knowledge; two container piles must merge.
- [Origin marker](data/harness-origin.json) — frozen export list — when checking seed identity
- [planning-validation](data/planning-validation.md) — Ensure plan self-review
- `data/closure.yaml` — Completed-closure input for the archive primitive.
- `data/workflow-evaluation.md` — Terminal completed-closure evaluation bound to the current Change digest; write last.
