# INDEX

## Current position

1.1 and 2.1 complete. Specs synced. Ready for terminal evaluation and completed archive.

## Hard conclusions

- Compile on `asCDefinitions`. Register creates one `asCModule` per `.as`.
- Restore lookup `GetModule(name)` / Count / ByIndex. Do not restore the compile factory.
- Host `FAngelscriptEngine::GetModule` stays `ModuleDesc`.

## Forbidden

- Do not restore `AddScriptSection` / `Build` / `ALWAYS_CREATE`.
- Do not expose `Type.GetModule()`.
- Do not forge compiler shells in a bind helper.
- Do not depend on `openspec/drafts/` paths.
- Do not accept ClassGen UserData in this Change.

## Attachment index

- [design](drafts/design.md) — accepted scoped design
- [handoff](drafts/handoff.md) — accepted handoff
- [glossary](drafts/glossary.md) — Change id and GetModule signature
- [register-module-flow](drafts/findings/register-module-flow.md) — two-phase Register split
- [why-module-not-generated](drafts/findings/why-module-not-generated.md) — descriptors already per file
- [getmodule-why-removed](drafts/findings/getmodule-why-removed.md) — 09-08 factory cut
- [engine-module-coupling](drafts/findings/engine-module-coupling.md) — ctor still needs Engine
- [talk-restore-lookup](talks/talk-20260917-234800-restore-lookup.md) — lookup and per-file generate
- [talk-handoff](talks/talk-20260917-234900-handoff.md) — R10 handoff
- [knowledge](knowledges/getmodule-lookup-is-not-compile.md) — change-local candidate; lookup ≠ compile factory is already the Change contract; do not promote into current capability knowledge in this archive
- [Origin marker](data/harness-origin.json) — frozen export list
- [planning-validation](data/planning-validation.md) — plan-acceptance self-review
- [spec-sync](data/spec-sync.md) — type-registry ADDED and builder ScriptModule MODIFIED
- [closure](data/closure.yaml) — completed closure manifest
- `data/workflow-evaluation.md` — terminal harness-workflow-evaluation-v1 — load before completed archive
