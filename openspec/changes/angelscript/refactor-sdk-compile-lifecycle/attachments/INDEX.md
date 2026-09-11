# INDEX

## Current position

Ensure plan written. Nodes stay unchecked until apply is authorized. Next: apply 1.1 when authorized.

## Hard conclusions

- No public `asCMetadataImage` on the script-compile path.
- Per-unit `asCModuleDefinitionSet` is the takeable TypeInfo/Function owner until one batch Registration.
- `asCCompileOutput` is diagnostics plus `FAngelscript*Desc`; it does not own TypeInfo or bytecode.
- Runtime bytecode is written only at Registration.Link onto `asCScriptFunction`.
- Image remains BindInfo-only. `HostImages` leftover feeds Frozen-host native graphs.
- Public ByteCodeImage/snapshot types leave in task 5.2, not 5.1.

## Forbidden

- Do not put types into Engine between compile units of a full compile.
- Do not hang `asCModuleDefinitionSet` on `asCModule`.
- Do not implement BindInfo Draft/Apply or ClassGen UClass in this Change.
- Do not add a module-wave thread pool.
- Do not delete `as_metadata_image.*` while BindInfo still constructs Image.
- Do not apply tasks until the user authorizes apply.

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
- knowledges/script-typeinfo-without-engine.md — candidate: TypeInfo before Engine — writing compile tests
- knowledges/sdk-compile-parallelism.md — candidate: body workers only — writing Builder options
- data/planning-validation.md — Ensure-plan self-review — load before apply
