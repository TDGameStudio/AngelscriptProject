# INDEX

## Current position

Feature recorded at proposal stage with the workflow-required tasks.md. The user authorized Change creation only. No design or delta specs has been authored, and no implementation or UE verification is claimed. The user-approved language-surface alignment removes all Lambda/closure goals and revises 2.2 to explicit receiver/payload state; public callable metadata is supplied by the language-surface Change. Task 1.1 is the design/specification prerequisite; all product tasks depend on it. tasks.md is the sole execution-state authority. Record validation is not a claim of implementation-ready planning.

## Hard conclusions

- Use one typed callable model for raw declarations and built-in UE DECLARE forms; parse declarations in Parser/Sema after conditional preprocessing.
- Initial functional scope is six families / 60 spellings. The other inspected 31 spellings require explicit unsupported diagnostics rather than semantic degradation.
- Separate ordinary native callables from reflected dynamic delegates; C++ templates need compiled adapters, and Blueprint needs explicit host reflection materialization.
- No Lambda/anonymous functions or lexical capture environments. Bind named functions/members with explicit payloads; preserve weak UObject receiver semantics.
- Consume `angelscript/refactor-language-surface-ue-focused` task 2.1 before product work; task 1.1 checks the external interface evidence.
- Keep feature implementation inside the plugin and consume the replacement VM/host lifecycle. Preserved legacy sources are evidence only.

## Forbidden

- No wrapper-source regeneration, AST-time UObject creation, copied native-event listener lists masquerading as live views, or reinterpretation of script callable storage as a UE delegate.
- Do not equate signature/AST inspection or successful OpenSpec validation with executable delegate, Blueprint or payload lifetime support.

## Attachment index

- [UE delegate inventory and integration evidence](data/ue-delegate-evidence.md) — historical source inspection and 91-macro inventory; Lambda observations are superseded by the indexed replan; read when authoring design/deltas or refreshing engine-version assumptions.

- [Named-callable scope replan](replans/replan-20260907-220002-named-callables-no-lambda.md) — applied user scope change; preserves task IDs and DAG while removing Lambda acceptance; read before resuming task 1.1.
- [Recoverable prior planning text](data/replans/replan-20260907-220002-named-callables-no-lambda-before.patch) — small reverse patch for previously untracked proposal/tasks/INDEX; provenance only, not current requirements.
- [Alignment verification](data/language-surface-alignment-verification.md) — strict record and candidate/scope checks; no implementation or UE execution.
