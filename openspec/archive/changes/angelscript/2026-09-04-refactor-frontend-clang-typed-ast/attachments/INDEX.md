# INDEX

## Current position

Tasks `1.1` through `2.2` are GREEN. The concrete node/type/attribute families, context ownership, checked casts, deterministic traversal, structural verifier, immutable projection, and new versioned codec pass 30 focused AST tests. Continue with final build and exact-prefix acceptance.

Task `1.1`: expected missing-header RED `1ce695a0bcff42caaf64703608f90cf7`; after the UBT basename Replan, GREEN build `a66f428a0e7a400a9145db28b78512a3` and run `fe5503aaa0b4489597b11be39809eded` passed 6/6.

Task `1.2`: expected missing Attr/Type RED `5a60623d95684f52919ded42b90ff3db`; GREEN build `d7327f2e3e9547f780974904b3508dac` and run `855be341865244d1b6347d47a78972d2` passed 12/12.

Task `2.1`: expected missing context RED `4a68434c547645b59c2097952033848d`; GREEN build `213a0e5bad614f6e9267baba3a7ab087` and run `932cb00c4014428cbd8e4afee16b18ad` passed 18/18.

Task `2.2`: expected missing codec/visitor/verifier RED `8c9de0442587494dbcff9a811e602fd2`; after one local missing-include repair, GREEN build `e888d5ff97df4b378bc7b32137dc2ae7` and run `3fb0ab496ce14dd081ea322f7ae2241e` passed 30/30 with zero warnings, errors, or skips.

Final focused acceptance: incremental Editor build `485f1c8a199b42d49db165a1295c6d11` succeeded. Exact AST Fast run `0c144438537f41f3be1bff63b5bbc99f` passed 30/30 in 19.6 seconds with zero warnings, errors, or skips; its report is `Saved/Harness/Unreal/Runs/0c144438537f41f3be1bff63b5bbc99f/AutomationReport/index.json`.

Durable synchronization: the existing `angelscript/language/ast/core` placeholder now contains the complete verified typed-AST contract without delta headings, and its knowledge index owns the promoted Clang shape/lifetime guidance. Strict validation passed for the Change (`1/1`) and current specs (`11/11`).

## Hard conclusions

- The reconstructed AST uses genuine concrete `Decl`, `DeclContext`, `Stmt -> ValueStmt -> Expr`, `Type`, and `Attr` structures.
- Canonical `Type` and compact non-node `QualType` are separate from authored `TypeLoc`/`TypeSourceInfo`; the preceding stable-identity Change supplies cross-snapshot type witnesses.
- All final implementation lives in `BEGIN_AS_NAMESPACE` plus lowercase `frontend`, under `source/frontend/`, with no `V2` leaf names.
- One context owns arena lifetime and seal state; visitors, casts, and verification derive from family taxonomies.
- Common flags and variable payloads use measured bitfield, inline, or trailing storage where focused layout tests justify it.
- A new versioned pointer-free flat projection/codec is deterministic and deliberately incompatible with the current wide Canonical AST sidecar/public-view wire shape.
- Root-level wide records remain dormant reference material, not a synchronized or fallback AST authority.
- UE core types are allowed inside ThirdParty; live engine/UObject state and persistent pointer identity are not AST facts.

## Forbidden

- Do not relabel a wide tagged record or typed facade as the new hierarchy.
- Do not create a permanent `asCScriptNode`, generic sidecar, or legacy/new shadow graph.
- Do not copy Clang's entire taxonomy, raw source encoding, serialization format, pointer identity, or runtime state into AngelScript nodes.

## Attachment index

- `talks/talk-20260905-010302-clang-typed-ast-boundary.md` — settled genuine-hierarchy decision and explicitly rejected flat/shadow/Clang-copy boundaries — read before changing node storage or ownership.
- `knowledges/clang-typed-ast-shape-and-lifetime.md` — candidate reusable local Clang and project evidence for subclasses, taxonomy, casts, context ownership, and projections — read when adding node kinds or consumers.
- `implementation/issue-20260905-043101-ubt-duplicate-ast-basenames.md` — resolved UBT input-planning issue proving that five new implementation units need unique basenames while preserved root-level sources remain.
- `replans/replan-20260905-043101-unique-ast-implementation-units.md` — applied path-only Replan preserving all public typed-AST names and semantics — resume Task `1.1`.
- `data/typed-ast-verification.md` — focused RED/GREEN sequence, final managed build and 30-test evidence, representative content hashes, durable synchronization, and impact exclusions.
- `data/completed-closure.yaml` — explicit completed disposition for deterministic archive.
- `data/workflow-evaluation.md` — completed-closure workflow evaluation written last against the final active Change digest.
