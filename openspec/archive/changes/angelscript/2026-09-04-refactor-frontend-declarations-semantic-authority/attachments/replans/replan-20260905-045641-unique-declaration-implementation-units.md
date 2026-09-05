---
replan_id: replan-20260905-045641-unique-declaration-implementation-units
status: applied
source: verification
source_ref: run-121ae5f9c0014d3ebac67a6ba05f649e
scope: declaration frontend implementation-unit paths
base_commit: d4f69984b0611ca44956577c242266edad24002b
base_tasks_sha256: f27a56d055233f300e1d093d1c03bed099b13966feaca9cff1ca1fd8ceff89af
result_tasks_sha256: c3f804002d7bb183ce84d4bcfa2d0a17608e48d06c3f3f5c023b82d44afae5ce
created_at: 2026-09-05T04:56:41.7992054+08:00
resume_task: 1.1
---

# Replan: use UBT-safe declaration implementation-unit paths

## Trigger and Evidence

The expected Task `1.1` RED was followed by exact module enumeration and the already verified UBT basename rule. The accepted Parser/Sema `.cpp` paths would conflict, while Task `2.1` named two obsolete prerequisite paths.

## Decision

Prefix only colliding Parser/Sema implementation basenames with `as_frontend_`, and update downstream file lists to the actual typed-AST implementation paths. Keep all public final-name headers/classes and semantic contracts unchanged.

## Impact

Only implementation file paths in Tasks `1.1` through `2.2` change. No Task edge, behavior, public API, verification command, or production-isolation boundary changes.

## Old Task Disposition

Task `1.1` remains incomplete and resumes after its valid missing-header RED. No completed node is invalidated.

## Diff Snapshot

- Task paths: Parser/Sema use unique implementation basenames; AST prerequisite paths match verified output.
- Edge changes: none.
- Product semantics: none.
- Verification scope: unchanged exact Editor build and Declarations Fast prefix.

## Preserved Work

The RED test, completed prerequisite capabilities, planning artifacts, and all non-conflicting file names remain applicable.

## References and Result

- Issue: `implementation/issue-20260905-045641-ubt-declaration-basenames.md`.
- Result: resume Task `1.1` with UBT-safe paths.

