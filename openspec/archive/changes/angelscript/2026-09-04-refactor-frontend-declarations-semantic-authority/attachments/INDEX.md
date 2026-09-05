# INDEX

## Current position

Tasks `1.1` through `2.2` are GREEN. Engine-independent Parser/Sema collection, the all-source barrier, barrier-only resolution, stable overload ordering, cross-file nominal types, deterministic duplicate handling, and typed recovery pass all twelve focused Declarations tests. Continue with durable capability synchronization and closure.

## Hard conclusions

- Parser drives typed Sema actions; Sema-created concrete `Decl` subclasses are declaration authority.
- Collect every source before resolving declarations. Ordinary source membership needs no new `import` directive.
- Parallel work produces isolated typed fragments and merges by stable semantic ordering.
- Recovery nodes remain queryable but can never satisfy lookup or become runtime candidates.
- New code uses `BEGIN_AS_NAMESPACE`, lowercase `namespace frontend`, final leaf names, and no `V2` suffix.

## Forbidden

- Do not construct `asCObjectType`, mutate a live Engine/Builder/module, or register forward runtime stubs.
- Do not replace the concrete AST with a generic record, property bag, or vaguely named IR.
- Do not analyze bodies, generate reflection output, publish runtime objects, produce bytecode, or switch production in this Change.

## Attachment index

- `talks/talk-20260905-010700-declaration-collection-before-resolution.md` — settled evidence and rejected alternatives for the declaration barrier — read before implementing Parser/Sema collection or recovery.
- `talks/talk-20260905-010701-frontend-reconstruction-sequencing.md` — authoritative nine-Change cross-Change DAG plus later cutover, candidate/publication, and VM entry criteria — read before changing batch order or opening the next batch.
- `knowledges/declaration-barrier-before-resolution.md` — promoted reusable rule for multi-source declaration semantics — read when designing another language frontend or reviewing source-order coupling.
- `implementation/issue-20260905-045641-ubt-declaration-basenames.md` — resolved path-planning issue for colliding Parser/Sema units and obsolete typed-AST prerequisite paths.
- `replans/replan-20260905-045641-unique-declaration-implementation-units.md` — applied path-only Replan preserving declaration semantics and verification — resume Task `1.1`.
- `data/completed-closure.yaml` — completed closure manifest for all five verified tasks.
- `data/declarations-verification.md` — focused RED/GREEN, final content hash, synchronization, and omitted-scope evidence.
- `data/workflow-evaluation.md` — terminal Harness workflow evaluation written last from the current input digest.

## Verification evidence

- Expected Task `2.1` RED: managed build `3d253d448cfc4922949e81891650f268` failed only because the six new resolution scenarios referenced the not-yet-implemented session APIs.
- Intermediate local correction: build `8cbf1429be924611af7ac4ba0ca0ae49` identified the missing typed-AST cast include; this was an ordinary task-local compile fix, not a planning or Harness defect.
- Task `2.1` GREEN: managed incremental build `db53e5d3e1cf45ea9ab51c65abbd2afd` succeeded after the final declaration C++ modification.
- Task `2.2` GREEN: managed Fast run `8b39ac6637304c9da3991bcd196e8285` passed `12/12` with zero warnings, errors, failures, skips, or incomplete tests. Report: `Saved/Harness/Unreal/Runs/8b39ac6637304c9da3991bcd196e8285/AutomationReport/index.json`.
- Task `3.1` GREEN: strict Change validation `3c2ee2e3a71843c6bb7a249393cb9d03` passed 1/1 and strict current-spec validation `292e595624634ea4b8fa6e2a42de4fb7` passed 12/12 after the declaration capability and accepted knowledge were synchronized.
- No broader validation was run: aggregate Harness profiles, complete UE suites, Standalone, Builder/Engine, reflection, bytecode, and VM behavior are outside this declaration-only impact surface.
