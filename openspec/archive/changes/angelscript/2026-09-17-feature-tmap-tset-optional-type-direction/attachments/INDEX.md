# INDEX

## Current position

All 5 tasks complete. Authors, generate/check, spec sync, and HostApiFixtureCorpus Fast 6/6 are green. External Review closed APPROVE. Durable delta is already in current spec `angelscript/testing/host-api-fixtures`. Ready to close.

## Hard conclusions

- This wave is TMap remaining holes + TSet + TOptional, one Change.
- Keep admitted TMap `*In`. New directions are `Read` / `FillBy` / `Mutate`.
- Type tables are per tree (FName yes, float keys/elements no).
- SoftObjectPath and pointer wrappers stay out.

## Forbidden

- Do not rename TMap `*In` during apply.
- Do not dump Advance / Negative / Reject or TSet misplaced Function files.
- Do not generate author `.as` from scripts.
- Do not depend on `openspec/drafts/` paths.
- Do not treat admission as AngelScript compile or execute.

## Attachment index

- [Origin marker](data/harness-origin.json) — Draft origin, frozen export list
- [design](drafts/design.md) — accepted scoped design
- [handoff](drafts/handoff.md) — accepted handoff and Change identity
- [glossary](drafts/glossary.md) — Change id, TMap `*In`, per-tree types
- [old-function-gap](drafts/findings/old-function-gap.md) — old Function versus current leaves
- [talk-wave](talks/talk-20260917-191700-wave.md) — R1 containers
- [talk-packaging](talks/talk-20260917-191800-packaging.md) — R2 one Change
- [talk-names](talks/talk-20260917-191900-names-and-approval.md) — R3 names and approval
- [param-container-type-direction](knowledges/param-container-type-direction.md) — disposition `candidate`; remain change-local; durable contract is the published spec
- [planning-validation](data/planning-validation.md) — Ensure plan self-review
- `reviews/review-20260917-195848-tmap-tset-optional-impl.md` — External Review closed APPROVE; no findings
- [closure](data/closure.yaml) — completed closure manifest
- `data/workflow-evaluation.md` — Terminal completed-closure evaluation bound to the current Change digest; write last. Knowledge remains change-local.
