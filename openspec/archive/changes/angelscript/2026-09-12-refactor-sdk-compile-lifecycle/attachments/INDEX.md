# INDEX

## Current position

1.1–6.2 GREEN. Durable deltas synced. Knowledge candidates stay change-local (not promoted). Next: terminal evaluation then completed archive.

## Hard conclusions

- No `asCMetadataImage` after 6.2. DefinitionSet is the unique TypeInfo owner until Registration.
- `asCCompileOutput` is diagnostics plus `FAngelscript*Desc`; it does not own TypeInfo or bytecode.
- Runtime bytecode is written only at Registration.Link onto `asCScriptFunction`.
- BindInfo owner-swaps onto DefinitionSet. Binding tests that fail because Image is gone are commented. Binding GREEN is a later Binding Change.
- Public ByteCodeImage/snapshot types leave in task 5.2.

## Forbidden

- Do not put types into Engine between compile units of a full compile.
- Do not hang `asCModuleDefinitionSet` on `asCModule`.
- Do not keep Image as a BindInfo leftover.
- Do not treat Binding GREEN as a gate or rewrite the Binding two-stage pipeline.
- Do not implement ClassGen UClass or a module-wave thread pool.
- Apply is authorized; do not reopen design-mode brainstorming for this Change.

## Attachment index

- drafts/design.md — approved SDK compile lifecycle — load before planning or apply
- drafts/handoff.md — Change identity, task boundaries, carryover — load at Ensure plan
- drafts/glossary.md — settled names — load when naming
- drafts/findings/compile-flow-before-after.md — current vs shrink pipeline — load when rewriting Builder
- drafts/findings/compile-then-batch-register.md — TypeInfo vs Engine — load before Registration tasks
- drafts/findings/cross-module-definition-holder.md — why DefinitionSet exists — load before Dependencies API
- drafts/findings/metadata-image-removed.md — Image deletion — load before deleting the type
- drafts/findings/parallel-and-module-deps.md — workers vs DAG — load before adding threads
- drafts/findings/runtime-bytecode-timing.md — Link is the only runtime writer — load before VM Prepare
- talks/talk-20260911-215400-module-definition-set.md — DefinitionSet vs Image/CompileOutput/Engine — load before product API
- talks/talk-20260911-215400-compile-then-batch-register.md — compile DAG then one Registration — load before Engine coupling
- talks/talk-20260911-215400-bytecodes-on-function.md — two layers on Function — load before linker/VM
- talks/talk-20260911-215400-two-builder-products.md — CompileOutput vs Set — load before ClassGen payload
- talks/talk-20260912-003900-retire-metadata-image-in-change.md — user flip: delete Image here, comment Binding — load before 6.1
- replans/replan-20260912-004040-retire-metadata-image.md — applied DAG: +6.1 +6.2 — load before resume
- knowledges/script-typeinfo-without-engine.md — candidate (not promoted): TypeInfo before Engine — writing compile tests
- knowledges/sdk-compile-parallelism.md — candidate (not promoted): body workers only — writing Builder options
- data/planning-validation.md — Ensure-plan self-review — load before apply
- `data/spec-sync.md` — synced capability IDs and strict validation results — load at archive
- `data/closure.yaml` — completed closure input for archive — load at archive
- `data/workflow-evaluation.md` — terminal harness-workflow-evaluation-v1 — load before completed archive
