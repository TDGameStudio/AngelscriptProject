# INDEX

## Current position

Ready to archive as completed. Specs synced; knowledge promoted. Next: terminal evaluation then archive.

## Hard conclusions

- First-party SDK root is `Source/AngelscriptRuntime/angelscript/` (flattened).
- This Change retargets UBT, current specs, and live ForkStrategy guidance.
- Other active Changes replan themselves.

## Forbidden

- Do not restore `ThirdParty/angelscript` or a nested `source/` folder.
- Do not edit other Changes' `tasks.md`.
- Do not move `Core/angelscript.h`.
- Do not own `AngelscriptLSP/` CMake.

## Attachment index

- `drafts/design.md` — approved layout design — load before planning or apply
- `drafts/handoff.md` — Change identity, task boundaries, carryover — load at Ensure plan
- `drafts/glossary.md` — settled Change ID and SDK root name — load when naming
- `drafts/findings/directory-moves.md` — on-disk move evidence — load when checking the old vs new tree
- `talks/talk-20260911-194500-two-layout-changes.md` — why two Changes — load before merging with the LSP Change
- `talks/talk-20260911-194500-consumers-replan.md` — consumers replan Files themselves — load before editing sibling Changes
- `knowledges/first-party-sdk-root.md` — promoted: current SDK path — durable copy at `openspec/specs/angelscript/language/ast/core/knowledges/first-party-sdk-root.md`
- `data/planning-validation.md` — plan-acceptance self-review — load when judging coverage or placeholders
- `data/consumer-replan.md` — sibling Changes that still Files `ThirdParty/angelscript` — load before asking this Change to edit their tasks
- `data/closure.yaml` — completed closure input for archive — load at archive
- `data/workflow-evaluation.md` — terminal workflow evaluation — load before completed archive
