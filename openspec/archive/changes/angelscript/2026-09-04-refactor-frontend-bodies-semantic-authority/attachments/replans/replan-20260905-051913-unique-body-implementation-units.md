---
replan_id: replan-20260905-051913-unique-body-implementation-units
status: applied
source: dependency
source_ref: issue-20260905-051913-ubt-body-basenames
scope: Align body task implementation paths with verified UBT-safe prerequisite filenames.
base_commit: d4f69984b0611ca44956577c242266edad24002b
base_tasks_sha256: 375d3e3d3d28fc4c274ae74a58a572f34c9da806dc5eee73a8ad7ad34a9036d2
result_tasks_sha256: 1d2be9294a03c6c3f7b3636c81458c28c8fdd6d5ddf2784deae9da8d1aab6046
created_at: 2026-09-05T05:19:14+08:00
resume_task: 1.1
---

# Unique body implementation units

## Trigger and Evidence

The accepted body tasks named five C++ units whose basenames already exist in the same Unreal module. Completed typed-AST and declarations Changes provide direct UBT failure and GREEN replacement-path evidence, so the artifact plan no longer represented buildable truth.

## Decision

Use as_frontend_parser.cpp, as_frontend_sema.cpp, as_frontend_stmt.cpp, as_frontend_expr.cpp, and as_frontend_ast_context.cpp. Preserve the unique planned body_fragment and body_lifetime filenames.

## Impact

Only Task file lists change. There is no requirement, design, command, task-node, or dependency-edge change.

## Old Task Disposition

Tasks 1.1 through 2.2 remain pending and Ready in their original order. Task 3.1 remains unchanged.

## Diff Snapshot

- Affected path status: the Angelscript submodule already contains the verified prerequisite files; this active Change is untracked planning input in the parent worktree.
- Diff stat: no tracked parent diff exists because the active Change is not yet tracked.
- Tasks: 0 added, 0 removed, 4 path lists modified.
- DAG edges: 0 added, 0 removed.
- Artifacts: one issue and one applied Replan added; INDEX updated.

## Preserved Work

All proposal, design, delta requirements, exact build/test commands, and body capability boundaries remain valid.

## References and Result

- Indexed issue: attachments/implementation/issue-20260905-051913-ubt-body-basenames.md.
- Result tasks SHA-256: 1d2be9294a03c6c3f7b3636c81458c28c8fdd6d5ddf2784deae9da8d1aab6046.
- Resume Task 1.1.
