# INDEX

## Current position

1.2 complete. Specs synced. Ready for terminal evaluation and completed archive.

## Knowledge disposition

- The indexed knowledge candidate stays change-local. Per-file definition sets are already the Change contract; do not promote into current capability knowledge in this archive.

## Hard conclusions

- FullReload and SoftReloadOnly both skip the dead Stage block after per-file retire/Register.
- One `asCDefinitions` per `.as`; do not retire the host graph.
- Prove reload UserData with `ClassGenReload`.
- A failed compile must keep the last-good `GetModule` name.

## Forbidden

- Do not only widen `if (Initial)`.
- Do not restore `ALWAYS_CREATE` / `Build` or a bind helper.
- Do not rewrite ClassGen or create UObject in the frontend.
- Do not use full-engine `RetireExternalDefinitions` on reload.
- Do not implement CacheV2 reuse or K replace-by-key.
- Do not depend on `openspec/drafts/` paths.

## Attachment index

- [design](drafts/design.md) — accepted scoped design
- [handoff](drafts/handoff.md) — accepted handoff
- [glossary](drafts/glossary.md) — Change id and test identity
- [reload-join](drafts/findings/reload-join.md) — name/key clash and P vs K
- [talk-width](talks/talk-20260918-123000-reload-width-and-replace.md) — W1=S and R1=P
- [talk-names](talks/talk-20260918-123100-packaging-and-names.md) — one Change and names
- [talk-approval](talks/talk-20260918-123200-approval.md) — R10 approval
- [knowledge](knowledges/per-file-definition-sets-enable-reload-retire.md) — candidate; one set cannot retire per file
- [Origin marker](data/harness-origin.json) — frozen export list
- [planning-validation](data/planning-validation.md) — plan-acceptance self-review
- [spec-sync](data/spec-sync.md) — class-generation per-file Initial plus reload rematerialize
- [closure](data/closure.yaml) — completed closure manifest
- `data/workflow-evaluation.md` — terminal harness-workflow-evaluation-v1 — load before completed archive
