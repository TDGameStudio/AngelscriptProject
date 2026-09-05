# INDEX

## Current position

All Task DAG nodes are complete. Specs synced. Reviews closed APPROVE. Material issues resolved. Ready for completed archive. `tasks.md` is the sole execution state.

## Hard conclusions

- No AS Engine is required for frontend/definition tests; only explicit registration tests create a local Engine.
- One typed frontend AST, one fixed stable identity value, real same-pointer detached definitions and single-engine image registration.
- Final C++ declarations live directly in BEGIN_AS_NAMESPACE without a nested frontend layer or aliases; 6.1 clears old conflicts before 6.2 consolidates names. The source/frontend directory may remain.
- delegate/event are declarations; asset/import syntax is removed; UDELEGATE is not adopted.
- Only the coordinator schedules UE build/test leases. Preserve old runtime/test dormancy and generated artifacts.

## Forbidden

- Reparse generated AS strings, restore either obsolete AST as a fallback, or silently publish partially registered images.
- Treat metadata registration as executable VM support, or use old test counts as fresh evidence.
- Modify unrelated user changes, create worktrees, push, integrate or delete workspaces.

## Attachment index

- `data/workflow-evaluation.md` — terminal harness-workflow-evaluation-v1 for completed archive; write last.

- `replans/replan-20260905-204839-review-required-followups.md` — applied: add 8.1/8.2/8.3 for seven Required Review findings; 6.2 waits on those repairs; completed 3.2/4.1/4.3/5.1 keep evidence and gain needs_followup.

- `reviews/review-20260905-194335-builder-coordinator.md` — closed APPROVE: seven Required findings resolved by 8.1–8.3 on NativeEngine `59f6cb38656845afb018ed7291108382`.
- `reviews/review-20260905-194335-builder-metadata.md` — closed APPROVE: M1/M2 resolved by 8.1.
- `reviews/review-20260905-194335-builder-semantics.md` — closed APPROVE: SEM-1–3 resolved by 8.3.
- `reviews/review-20260905-194335-builder-ast.md` — closed APPROVE: AST-01/02 resolved by 8.2.

- `replans/replan-20260905-181024-canonical-as-namespace.md` — applied user-directed canonical AS namespace replan; 6.2 follows old implementation isolation, preserving existing completion and current Ready work.
- `data/namespace-replan-validation-20260905.md` — planning validation, exact DAG changes and preserved source/evidence boundaries; not C++ or UE verification.

- `replans/replan-20260905-163854-feature-group-tasks.md` — applied: preserve eight completed nodes, extract pending 4.2–4.5 feature groups and keep 4.1 as integrated acceptance; current policy supersedes delayed-first-run defaults without rewriting history.

- `implementation/issue-20260905-144517-conversion-target-identity.md` — resolved: destination-distinct conversion identity/selection proven on NativeEngine `84f867a143f44031a1ca2aeefefd5b3f`.

- `replans/replan-20260905-152247-conversion-target-identity.md` — applied: conversion destination participates in Function identity; preserves all completed tasks and resumes 4.1 without a new key family or VM support.

- `data/builder-batch-20260905.md` — partial 4.1 evidence: latest complete green is 481/481 after the fixture-crash and 476/1 retries; includes preceding 401/339 evidence, exact hashes, corrections and uncompleted grammar/cutover boundaries.

- `implementation/issue-20260905-121302-stale-openspec-engine-context.md` — resolved: `openspec/config.yaml` now names UE 5.8.

- `data/language-coverage.md` — current 4.1 frontend/definition coverage inventory, Clang source entry points and explicit remaining grammar/integration gaps; read before claiming staged Builder completeness.

- `replans/replan-20260905-095630-batched-implementation-verification.md` — applied: user-directed larger code/test batches, one NativeEngine launch per batch and parallel metadata development against the agreed key ABI — read when selecting verification or resuming metadata work.
- `replans/replan-20260905-094822-identity-handoffs-and-condition-proof.md` — applied: separate stable-key ABI from shared consumer migration and add the missing conditional-grammar proof — read when resuming identity or Builder handoffs.

- `diagrams/frontend-stack.html` — current engine-independent frontend, definition image, optional Engine attach, and quarantined VM.
- `diagrams/frontend-stack.architecture.json` — existing source companion for the frontend diagram; read only when updating its presentation, not as test evidence.
- `diagrams/builder-stages.html` — Builder RunStage products from snapshot to freeze, including the host-callable lookup gap.
- `diagrams/builder-stages.dataflow.json` — existing source companion for the Builder diagram; no additional compiler or verification contract.
- `diagrams/metadata-image.html` — MetadataImage Building / Frozen / Attaching / Attached / Retired states.
- `diagrams/metadata-image.lifecycle.json` — existing source companion for the metadata lifecycle diagram; not a second execution-state record.
