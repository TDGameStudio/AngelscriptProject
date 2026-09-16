# INDEX

## Current position

All four tasks complete. Directory and CMake retargets landed; host binary remains uncertified. No durable spec delta. Ready for completed archive. Knowledge remains a change-local candidate.

## Hard conclusions

- Directory is `AngelscriptLSP/`; product remains dormant Standalone.
- JSON-RPC and `Extensions/AngelscriptVSCode/` stay out of this Change.
- Other active Changes replan `Standalone/` Files themselves.

## Forbidden

- Do not implement a language-server protocol here.
- Do not rename `as-standalone` or the CMake project in this Change.
- Do not search `Standalone/` and `AngelscriptLSP/` as dual live roots.
- Do not edit other Changes' `tasks.md`.

## Attachment index

- drafts/design.md — approved directory retarget design — load before planning or apply
- drafts/handoff.md — Change identity and task boundaries — load at Ensure plan
- drafts/glossary.md — settled names — load when naming
- drafts/findings/directory-moves.md — on-disk move evidence — load when checking Standalone vs AngelscriptLSP
- talks/talk-20260911-194500-directory-not-lsp-product.md — directory vs product vs TypeScript LSP — load before treating this tree as a server
- talks/talk-20260911-194500-consumers-replan.md — sibling Files stay on those Changes — load before editing drop-native-gc
- knowledges/angelscript-lsp-directory-identity.md — candidate: three-way identity — writing path docs
- data/planning-validation.md — plan-acceptance self-review — load when judging coverage or placeholders
- data/consumer-replan.md — sibling Changes that still Files `Standalone/` — load before asking this Change to edit their tasks
- `data/closure.yaml` — Completed-closure input for the archive primitive.
- `data/workflow-evaluation.md` — Terminal completed-closure evaluation bound to the current Change digest; write last.
