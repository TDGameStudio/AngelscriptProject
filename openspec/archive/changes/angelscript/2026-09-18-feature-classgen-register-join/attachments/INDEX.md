# INDEX

## Current position

1.1 complete. Specs synced. Ready for terminal evaluation and completed archive.

## Knowledge disposition

- The indexed knowledge candidate stays change-local. Dead Stage1–4 skip is already the Change contract; do not promote into current capability knowledge in this archive.

## Hard conclusions

- Only `CompileModules(Initial)` runs Builder+Register and skips the whole Stage1–4 dead block.
- Preprocessor `ModuleDesc` stays the ClassGen input; `CodeSuperClass` stays preprocessor-filled.
- Prove class/struct/enum UserData with `ClassGenMaterialization`.
- Register shells must unlink definition-owned types before `RetireExternalDefinitions` deletes them.

## Forbidden

- Do not patch only Stage1.
- Do not restore `ALWAYS_CREATE` / `Build` or `BindRegisteredTypesForClassGeneration`.
- Do not rewrite ClassGen or create UObject in the frontend.
- Do not accept delegate/event UserData or CacheV2 builder reuse.
- Do not require Full/SoftReload green.
- Do not depend on `openspec/drafts/` paths.

## Attachment index

- [design](drafts/design.md) — accepted scoped design
- [handoff](drafts/handoff.md) — accepted handoff
- [glossary](drafts/glossary.md) — Change id and test identity
- [thin-host-join](drafts/findings/thin-host-join.md) — skip width, ProcessedCode, name join
- [join-gap](drafts/findings/join-gap.md) — host singleton and remaining gaps
- [talk-scope](talks/talk-20260918-100000-scope.md) — Q1=C thin host
- [talk-names](talks/talk-20260918-100100-initial-and-names.md) — Q2=I and names
- [talk-approval](talks/talk-20260918-100200-approval.md) — R4 approval
- [knowledge](knowledges/initial-skips-dead-compile-stages.md) — candidate; dead compile is wider than Stage1
- [Origin marker](data/harness-origin.json) — frozen export list
- [planning-validation](data/planning-validation.md) — plan-acceptance self-review
- [spec-sync](data/spec-sync.md) — class-generation ADDED Initial materialize
- `implementation/issue-20260918-104000-register-shell-shutdown-uaf.md` — resolved [issue-register-shell-shutdown](implementation/issue-20260918-104000-register-shell-shutdown-uaf.md)
- [closure](data/closure.yaml) — completed closure manifest
- `data/workflow-evaluation.md` — terminal harness-workflow-evaluation-v1 — load before completed archive
