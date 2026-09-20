# INDEX

## Current position

Tasks 1.1–3.1 complete. Specs synced. Ready for completed archive.

## Hard conclusions

- Target is `angelscript/feature-classgen-type-materialization`.
- Accept authored SuperClass / ImplementedInterfaces and Project-authoritative CompileOutput.
- ClassGen UserData is withdrawn. Module materialization is a later Change.
- Delegates are not verified because that path may be redesigned.

## Forbidden

- Do not create UObject in the frontend.
- Do not overwrite `Project` with a TypeInfo scan after DefinitionsBuilt.
- Do not restore `asCScriptEngine::GetModule` or forge `asCModule` shells here.
- Do not depend on `openspec/drafts/` paths.
- Do not accept delegate materialization in this Change.
- Do not use `ASTEST_CREATE_ENGINE` or `WITH_ANGELSCRIPT_UNITTESTS`.

## Attachment index

- [design](drafts/design.md) — accepted scoped design
- [handoff](drafts/handoff.md) — accepted handoff and Change identity
- [glossary](drafts/glossary.md) — confirmed public names
- [can-connect](drafts/findings/can-connect.md) — pipeline gaps
- [astype-uclass-link](drafts/findings/astype-uclass-link.md) — asType↔UClass attach
- [talk-20260917-195700-scope](talks/talk-20260917-195700-scope.md) — scope lock and delegate exclusion
- [talk-20260917-195800-names](talks/talk-20260917-195800-names.md) — Change id and test identity
- [astype-userdata-is-uclass](knowledges/astype-userdata-is-uclass.md) — candidate; not promoted; ClassGen UserData unproven here
- [planning-validation](data/planning-validation.md) — plan-acceptance self-review
- [Origin marker](data/harness-origin.json) — frozen export list — when checking seed identity
- [closure](data/closure.yaml) — completed closure manifest
- `data/workflow-evaluation.md` — terminal completed-closure evaluation bound to the current Change digest; write last. Knowledge remains change-local.
- talks/grill-20260917-123847-classgen-withdraw-310e38.md — closed — Withdraw ClassGen UserData; keep SuperClass and Project; close this Change
- replans/replan-20260917-203847-classgen-withdraw.md — applied — Withdraw ClassGen UserData; keep SuperClass and Project; close this Change
