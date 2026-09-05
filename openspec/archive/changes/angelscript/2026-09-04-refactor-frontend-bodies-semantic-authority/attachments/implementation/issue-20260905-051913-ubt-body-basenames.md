---
issue_schema: openspec-material-issue-v2
issue_id: issue-20260905-051913-ubt-body-basenames
status: resolved
source: dependency
source_ref: angelscript/refactor-frontend-clang-typed-ast#issue-20260905-043101-ubt-duplicate-ast-basenames
affected_tasks: ["1.1", "1.2", "2.1", "2.2"]
created_at: 2026-09-05T05:19:13.7508845+08:00
resolved_at: 2026-09-05T05:19:14+08:00
resolution_ref: tasks-sha256-1d2be9294a03c6c3f7b3636c81458c28c8fdd6d5ddf2784deae9da8d1aab6046
---

# Body implementation plan reuses UBT-conflicting basenames

## Symptom

The body Task cards name frontend implementation units as as_parser.cpp, as_sema.cpp, as_stmt.cpp, as_expr.cpp, and as_ast_context.cpp even though root sources already own those basenames and completed prerequisite Changes established UBT-safe as_frontend-prefixed units.

## Investigation Log

1. The archived typed-AST issue records UBT failure 9b7e1592c792482abefa8d343b6ed6d7 for duplicate non-Unity object basenames.
2. The declarations Change records the same constraint for Parser and Sema and completed on as_frontend_parser.cpp and as_frontend_sema.cpp.
3. Current filesystem inspection confirms the prerequisite outputs are as_frontend_ast_context.cpp, as_frontend_stmt.cpp, and as_frontend_expr.cpp.
4. The body task semantics and DAG remain valid; only required artifact paths are stale.

## Root Cause

The body plan was authored before the prerequisite path-only Replans established the module-wide UBT basename convention.

## Disposition

All affected Task file lists now reference the verified as_frontend-prefixed implementation units. New body_fragment and body_lifetime units retain their planned unique names. Requirements, public classes, task edges, and verification commands are unchanged.

## Evidence

### Failure Evidence (RED)

- Typed-AST UBT run 9b7e1592c792482abefa8d343b6ed6d7 demonstrated that directory separation does not avoid duplicate source basenames.
- The completed declarations implementation and its exact build db53e5d3e1cf45ea9ab51c65abbd2afd prove the as_frontend_parser.cpp and as_frontend_sema.cpp paths.

### Resolution Evidence (GREEN)

- The updated tasks.md has SHA-256 1d2be9294a03c6c3f7b3636c81458c28c8fdd6d5ddf2784deae9da8d1aab6046 and names only the actual prerequisite implementation units.

### What This Proves

- Body work must extend the UBT-safe prerequisite implementation units rather than create colliding copies.

### What This Does Not Prove

- It does not change body semantics, public APIs, or verification scope.
- It does not authorize edits to retained root Parser, Sema, AST, Compiler, Builder, or Engine sources.
- It is not a Harness defect.

## Links

- attachments/replans/replan-20260905-051913-unique-body-implementation-units.md
- Tasks 1.1 through 2.2.
