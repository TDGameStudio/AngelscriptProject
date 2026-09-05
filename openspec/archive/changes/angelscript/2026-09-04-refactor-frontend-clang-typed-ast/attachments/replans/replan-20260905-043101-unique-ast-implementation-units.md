---
replan_id: replan-20260905-043101-unique-ast-implementation-units
status: applied
source: verification
source_ref: run-9b7e1592c792482abefa8d343b6ed6d7
scope: UBT typed-AST implementation-unit basename identity
base_commit: d4f69984b0611ca44956577c242266edad24002b
base_tasks_sha256: 14940f606ef59ba9ccd2738204017158dc0b189a6b0660748b74027385fc3cb5
result_tasks_sha256: e62b9ab5696793045cc2d9aa7a0c6399c47290e41be1c2f718d1c793442aeca1
created_at: 2026-09-05T04:31:01.3054290+08:00
resume_task: 1.1
---

# Replan: give colliding typed-AST implementation units unique basenames

## Trigger and Evidence

Managed build `9b7e1592c792482abefa8d343b6ed6d7` proved that UBT rejects the planned `frontend/as_decl.cpp`, `as_stmt.cpp`, and `as_expr.cpp` while their preserved root-level namesakes remain in the same module. Bounded enumeration also proved that later `as_ast_context.cpp` and `as_ast_verifier.cpp` would fail for the same reason.

## Decision

Keep all public `frontend/as_*.h` files and final C++ type names unchanged. Rename only the five colliding new implementation units with the established `as_frontend_*.cpp` prefix. Non-colliding new implementation units keep their planned names.

## Impact

Task file paths and the design placement tree now state UBT-safe implementation-unit basenames. Requirements, public APIs, local Task DAG edges, verification commands, old-source preservation, and the sole-authority boundary do not change.

## Old Task Disposition

Task `1.1` remains incomplete and resumes from its GREEN implementation step. The missing-header RED remains valid; the UBT filename failure is planning-correction evidence, not task completion evidence.

## Diff Snapshot

- Task changes: path-only corrections in Tasks `1.1`, `2.1`, `2.2`, and `3.1`.
- Edge changes: none.
- Design changes: one explicit UBT basename exception for implementation units.
- Implementation changes: three present `.cpp` files renamed; two later planned files use the corrected names from creation.

## Preserved Work

All tests, public headers, hierarchy decisions, stable-identity/source prerequisites, and exact verification scope remain applicable. No root-level legacy source or public runtime API is modified.

## References and Result

- Issue: `implementation/issue-20260905-043101-ubt-duplicate-ast-basenames.md`.
- UBT log: `Saved/Harness/Unreal/Runs/9b7e1592c792482abefa8d343b6ed6d7/UBT.log`.
- Result: resume Task `1.1` with unique implementation basenames and the same Editor build plus AST Fast prefix.

