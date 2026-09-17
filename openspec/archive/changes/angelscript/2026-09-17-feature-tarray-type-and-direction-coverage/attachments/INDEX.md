# INDEX

## Current position

All 8 tasks complete. Authors, generate/check, spec sync, and HostApiFixtureCorpus Fast 5/5 are green. Durable delta is already in current spec `angelscript/testing/host-api-fixtures`. Ready to close.

## Hard conclusions

- Compare `TestSource-old/Containers/TArray/Function`, not Pending.
- Keep one observation per file. Add typed and direction siblings beside existing int32 observes.
- AddAndOrder is the cited hole: 23 new leaves for type-axis plus `ReadAddOrder` / `FillByAdd` / `AppendWithAdd`.
- Other containers stay out.

## Forbidden

- Do not fold types back into `AddAndOrder.as`.
- Do not dump Advance compose, Negative, or Reject piles.
- Do not generate author `.as` from scripts.
- Do not depend on `openspec/drafts/` paths.
- Do not treat admission as AngelScript compile or execute.

## Attachment index

- [Origin marker](data/harness-origin.json) — Direct reason and skipped-draft assumption
- [glossary](glossary.md) — FileTag and direction names
- [testsource-old-gap](findings/testsource-old-gap.md) — AddAndOrder 24 UFUNCTIONs versus current int32 leaf
- [planning-validation](data/planning-validation.md) — Ensure plan self-review
- [closure](data/closure.yaml) — completed closure manifest
- `data/workflow-evaluation.md` — Terminal completed-closure evaluation bound to the current Change digest; write last. Knowledge remains change-local.
