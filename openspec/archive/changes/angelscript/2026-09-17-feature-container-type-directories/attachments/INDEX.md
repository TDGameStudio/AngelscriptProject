# INDEX

## Current position

All 11 tasks complete. Directory rewrite, identity repair, generate/check, and HostApiFixtureCorpus 4/4 are green. Durable delta is already in current spec `angelscript/testing/host-api-fixtures`. Ready to close. TArray type-axis and UFUNCTION direction coverage stay out of this Change and belong in a follow-up.

## Hard conclusions

- One directory per type; FileTag `Containers/<Type>/<Observation>`.
- Leaves are lengthened Pascal observations without a type prefix.
- One Change; nine type tasks have no inter-type edges; spec/corpus may join.
- Trees follow each bind surface. Fail follows Bind Throw only.

## Forbidden

- Do not keep flat `Containers/<Type>.as` or short leaves such as `add.as`.
- Do not dump Pending or generate authors from scripts.
- Do not depend on `openspec/drafts/` paths.
- Do not treat admission as AngelScript compile or execute.

## Attachment index

- [design](drafts/design.md) — accepted scoped design
- [handoff](drafts/handoff.md) — accepted handoff and Change identity
- [glossary](drafts/glossary.md) — FileTag and Change names
- [quality-debt](drafts/findings/quality-debt.md) — why flat pockets are dirty
- [coverage-gaps](drafts/findings/coverage-gaps.md) — how to thicken
- [authoring-standard](drafts/findings/authoring-standard.md) — hand-write rules
- [extended-names](drafts/findings/extended-names.md) — observation Pascal mapping
- [target-layout](drafts/findings/target-layout.md) — TArray destination tree
- [per-type-trees](drafts/findings/per-type-trees.md) — other eight trees
- [per-type-index](drafts/findings/per-type-index.md) — quality order
- [fail-siblings](drafts/findings/fail-siblings.md) — Bind Throw polarity
- [coverage-wave](drafts/findings/coverage-wave.md) — named coverage begins
- [talk-type-directories](talks/talk-20260917-174000-type-directories.md) — R4 directories and parallel Change
- [talk-observation-names](talks/talk-20260917-174200-observation-names.md) — R5 leaf names
- [talk-type-shaped-trees](talks/talk-20260917-174400-type-shaped-trees.md) — R6 bind-surface trees
- [container-observation-filetags](knowledges/container-observation-filetags.md) — disposition `candidate`; FileTag grain; remains change-local
- [Origin marker](data/harness-origin.json) — frozen export list — when checking seed identity
- [planning-validation](data/planning-validation.md) — Ensure plan self-review
- `data/workflow-evaluation.md` — Terminal completed-closure evaluation bound to the current Change digest; write last. Knowledge candidates remain change-local.
- [Completed closure input](data/closure.yaml) — recorded completed disposition, proof scope and deferred coverage; read when auditing archive provenance.
