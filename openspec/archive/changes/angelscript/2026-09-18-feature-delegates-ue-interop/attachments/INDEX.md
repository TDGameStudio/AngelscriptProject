# INDEX

## Maintenance baseline — 2026-09-12

Read [Current-baseline maintenance](data/maintenance-20260912.md) before historical attachments. It records current source ownership, preserved task state, exact format checks and remaining planning boundaries. Historical talks, research snapshots and applied replans are provenance rather than current API authority.

## Current position

1.1–4.1 are GREEN. Durable deltas are synced. Knowledge stays change-local (no capability promotion). Ready for terminal evaluation and archive.

## Hard conclusions

- Script callable declarations are one table plus a 60-row matrix for the six UE `DECLARE_*` families. `delegate` and `event` are a transitional reject this Change; token deletion is later.
- The 31 Event/TS/Sparse/Derived spellings stay unsupported diagnostics.
- Parser/Sema own the declaration-form table. Preprocessor `ProcessDelegates` must not synthesize wrapper structs.
- Tests use `Angelscript.UnitTest.NativeEngine.<Layer>.<Class>`. `NewVersion/` is not a source root.
- Bind/Execute/Broadcast on `CompileModules` is required for the macro system (2.1). Payload, native adapters, `UDelegateFunction`, Blueprint, and cook stay later in this Change (2.2–4.1).
- No Lambda/anonymous functions. Legacy sources are evidence only.

## Forbidden

- No wrapper-source regeneration, AST-time UObject creation, copied native-event listener lists masquerading as live views, or reinterpretation of script callable storage as a UE delegate.
- Do not equate signature/AST inspection or successful OpenSpec validation with executable delegate, Blueprint or payload lifetime support.

## Attachment index

- [Current-baseline maintenance](data/maintenance-20260912.md) — historical record maintenance, preserved task/evidence boundaries and executed format checks; read before interpreting older planning records.
- [Completed closure input](data/closure.yaml) — recorded completed disposition and omitted full-cook boundary; read when auditing archive provenance.
- [UE delegate inventory and integration evidence](data/ue-delegate-evidence.md) — historical source inspection and 91-macro inventory; Lambda observations are superseded by the indexed replan; read when authoring design/deltas or refreshing engine-version assumptions.

- [Named-callable scope replan](replans/replan-20260907-220002-named-callables-no-lambda.md) — applied user scope change; preserves task IDs and DAG while removing Lambda acceptance; read before resuming task 1.1.
- [Recoverable prior planning text](data/replans/replan-20260907-220002-named-callables-no-lambda-before.patch) — small reverse patch for previously untracked proposal/tasks/INDEX; provenance only, not current requirements.
- [Alignment verification](data/language-surface-alignment-verification.md) — strict record and candidate/scope checks; no implementation or UE execution.

- [Planning contracts](data/planning-contracts.md) — inspected APIs, assumed names, Bind/Execute spellings, cook route; read before 1.2+.
- [Planning validation](data/planning-validation.md) — 1.1 self-review coverage, placeholders, symbols.
- [Integration evidence](data/integration-evidence.md) — 4.1 editor prefix, cook PlanOnly `9264c927fa014ed3935bf11984312fff`, and omitted full Windows cook.
- `data/workflow-evaluation.md` — terminal harness-workflow-evaluation-v1 — load before completed archive.
- [Applied current-baseline replan](replans/replan-20260912-073639-current-baseline.md) — accepted record maintenance; current paths, ownership and proof boundaries; read before resuming the pending plan.
- talks/grill-20260918-082041-stale-host-join-86f515.md — closed — Keep Change. Drop delegate/event keywords. Full 60 DECLARE_* macros + Bind/Execute. Later payload/native/BP/cook nodes retained. NativeEngine identities.
- replans/replan-20260918-083200-full-macro-system.md — applied — Keep Change. Drop delegate/event keywords. Full 60 DECLARE_* macros + Bind/Execute. Later payload/native/BP/cook nodes retained. NativeEngine identities.
- talks/grill-20260918-083234-retval-call-prerequisite-ca4146.md — closed — Q7=P add task 1.4 CallPtr-return prerequisite; 2.1 depends on 1.3 and 1.4.
- replans/replan-20260918-083500-retval-callptr.md — applied — Q7=P add task 1.4 CallPtr-return prerequisite; 2.1 depends on 1.3 and 1.4.
- talks/grill-20260918-090740-keyword-deprecation-then-delete-736e7d.md — closed — Q11 folded into verification-stages replan: reject keywords this Change; delete lexer tokens later.
- talks/grill-20260918-083859-verification-stages-bee9f2.md — closed — Q8=S Q9=R Q10=T Q11 reject-now delete-later. Split 1.5/1.6/1.7; one DECLARE table plus 60-row matrix; keywords transitional reject only.
- replans/replan-20260918-091500-verification-stages.md — applied — Q8=S Q9=R Q10=T Q11 reject-now delete-later. Split 1.5/1.6/1.7; one DECLARE table plus 60-row matrix; keywords transitional reject only.
