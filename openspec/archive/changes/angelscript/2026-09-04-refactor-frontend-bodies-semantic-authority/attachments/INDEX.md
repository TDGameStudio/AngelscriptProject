# INDEX

## Current position

All five tasks are GREEN. Thirteen focused body tests plus thirty adjacent AST tests prove deferred-body gating, canonical calls and conversions, typed control targets, reverse cleanup obligations, construction-failure exclusion, deterministic recovery, input/worker independence, and compact shared-AST representation. The durable capability and accepted knowledge are synchronized and strictly valid; proceed to completed closure.

## Hard conclusions

- Body parsing begins only after declaration collection and resolution are frozen.
- Parser reports syntax to Sema; Sema creates concrete typed `Stmt`/`Expr` nodes and authoritative semantic facts.
- Explicit conversions, value categories, control targets, and lifetime/cleanup obligations precede lowering.
- Each body is an isolated deterministic fragment; recovery preserves progress and later diagnostics.
- New code uses `BEGIN_AS_NAMESPACE`, lowercase `namespace frontend`, final leaf names, and no `V2` suffix.

## Forbidden

- Do not mutate declaration contexts from body workers or introduce a new `import` model.
- Do not use generic enum-tagged records as the final typed AST or query live Engine/Builder state.
- Do not generate bytecode, construct runtime functions/types, publish candidates, switch production, or change the VM.

## Attachment index

- `talks/talk-20260905-010800-body-sema-after-declaration-barrier.md` — settled boundary between body semantics and executable lowering, with user/source evidence and rejected transcript suggestions — read before implementing body Parser/Sema work.
- `knowledges/deterministic-body-fragments.md` — candidate reusable guidance for frozen-input parallel body analysis — read when scheduling or reviewing body workers and recovery.
- `implementation/issue-20260905-051913-ubt-body-basenames.md` — resolved dependency issue for stale colliding implementation-unit paths.
- `replans/replan-20260905-051913-unique-body-implementation-units.md` — applied path-only Replan that preserves semantics, DAG, and verification — resume Task `1.1`.
- `data/completed-closure.yaml` — completed closure manifest for all five verified tasks.
- `data/bodies-verification.md` — focused RED/GREEN, adjacent AST regression, final content hashes, synchronization, and omitted-scope evidence.
- `data/workflow-evaluation.md` — terminal Harness workflow evaluation written last from the current input digest.

## Verification evidence

- Expected core RED build `12f4922a5989492ea25bdbf6cc09d954` failed on the missing body-fragment contract.
- Core GREEN build `aec0f388f26c48baa77c14f9d9555028` succeeded.
- Exact core Fast run `c84562db6760410abee4b8e5b2676684` passed 6/6 with zero warnings, errors, failures, skips, or incomplete tests.
- Expected finalization RED build `b5f1c6f953c34c9cb0ef047085c308da` failed only on the not-yet-implemented lifetime/exit API.
- Intermediate build `270358ec15e5450fa02bcf23657bb086` exposed the return-target base type and was repaired locally without changing the plan.
- Finalization GREEN build `11bd0780ccf14fadadba5c87ff365546` succeeded.
- Exact final Fast run `d510ad200ccd4df497c71f9aafcfaa89` passed 13/13 with zero warnings, errors, failures, skips, or incomplete tests. Report: `Saved/Harness/Unreal/Runs/d510ad200ccd4df497c71f9aafcfaa89/AutomationReport/index.json`.
- Evidence-driven adjacent AST run `35c219b766e74afdbbbaaff7ad8f3a60` failed 1/30 because the first body-semantic representation widened representative leaf nodes beyond the existing 64-byte contract. This was a local implementation defect, not a requirement, design, DAG, verification-contract, or Harness failure.
- Corrective build `1549860d7e2c416fb4d046654069125c` succeeded after compacting the shared AST header and packing expression type/value-category semantics into one pointer-sized word.
- Current exact Bodies run `c5586e74431142fc83eeb7c8b6fce687` passed 13/13, and adjacent AST run `297960d708b54c50913f6d77af8d7ed9` passed 30/30; both have zero warnings, errors, failures, skips, or incomplete tests.
- Task `3.1` GREEN: strict Change validation `4a78acbed99a4ea5b4c95a8a3e7a329b` passed 1/1 and strict current-spec validation `b204a4340e6846a0875ab98f43dbc3a5` passed 13/13 after body capability and accepted knowledge synchronization.
- Final strict Change validation `0ce4a65756eb49c09c139c8e34f029d3` passed 1/1; final strict current-spec validation `e79a28622ff7454eb20d6a51924a138a` passed 13/13; doctor `80c7512e100b4869ba6208c4e7a84b94` returned zero diagnostics; TaskPlan `94465a21d53d46718cd799b0e1195c0e` reported 5/5 complete.
- No broader validation was run: aggregate Harness profiles, complete UE suites, Standalone, retained production Parser/Builder, reflection, bytecode, JIT, and VM behavior are outside this typed-body impact surface.
