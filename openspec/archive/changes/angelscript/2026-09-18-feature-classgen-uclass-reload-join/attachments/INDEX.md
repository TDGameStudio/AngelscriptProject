# INDEX

## Current position

All four tasks GREEN. Specs synced. Ready for terminal evaluation and completed archive.

## Knowledge disposition

- `old-reload-uses-compile-modules` stays change-local. Verification confirmed `CompileModules` is the proving entry; it does not add a new cross-capability invariant.

## Hard conclusions

- One Change, two phases, split proving commands.
- Phase 1: SoftReload body + transient Blueprint ProcessEvent.
- Phase 2: FullReload add-property + failed reload keeps old ProcessEvent.
- Embed `UCLASS` source. Do not read the Language database.
- Entry is `CompileModules`, not `PerformHotReload`.

## Forbidden

- Do not compile `AngelscriptTestCode/Language/**` in this Change.
- Do not restore `Legacy/HotReload/*.cpp` or `WITH_ANGELSCRIPT_UNITTESTS`.
- Do not treat UserData-only `ClassGenReload` as this proof.
- Do not depend on `openspec/drafts/` paths.

## Attachment index

- [design](drafts/design.md) — accepted scoped design
- [handoff](drafts/handoff.md) — accepted handoff
- [glossary](drafts/glossary.md) — Change id and test identity
- [legacy-reload-slice](drafts/findings/legacy-reload-slice.md) — old gold cases
- [change-phases](drafts/findings/change-phases.md) — phase split
- [inline-as-not-corpus](drafts/findings/inline-as-not-corpus.md) — no Language database
- [talk-first](talks/talk-20260918-144000-uclass-blueprint-first.md) — UCLASS+Blueprint first
- [talk-phases](talks/talk-20260918-144100-phase-order.md) — finish UCLASS seam
- [talk-inline](talks/talk-20260918-144200-inline-not-corpus.md) — inline .as
- [talk-names](talks/talk-20260918-144300-names.md) — N1/N2
- [talk-approval](talks/talk-20260918-144400-approval.md) — R15 approval
- [knowledge](knowledges/old-reload-uses-compile-modules.md) — candidate; old entry is CompileModules
- [Origin marker](data/harness-origin.json) — frozen export list
- [planning-validation](data/planning-validation.md) — plan-acceptance self-review
- [spec-sync](data/spec-sync.md) — class-generation SoftReload/FullReload ProcessEvent
- [closure](data/closure.yaml) — completed closure manifest
- `data/workflow-evaluation.md` — terminal harness-workflow-evaluation-v1 — load before completed archive
