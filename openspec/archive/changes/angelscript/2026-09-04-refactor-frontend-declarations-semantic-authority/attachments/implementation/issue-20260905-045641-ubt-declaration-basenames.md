---
issue_schema: openspec-material-issue-v2
issue_id: issue-20260905-045641-ubt-declaration-basenames
status: resolved
source: verification
source_ref: run-121ae5f9c0014d3ebac67a6ba05f649e
affected_tasks: ["1.1", "1.2", "2.1", "2.2"]
created_at: 2026-09-05T04:56:41.7992054+08:00
resolved_at: 2026-09-05T05:02:17+08:00
resolution_ref: run-db747b1231844d54883bf26fcf400ac4
---

# Declaration implementation plan contains UBT-conflicting basenames

## Symptom

After the expected missing-header RED, bounded module-input inspection showed that planned `frontend/as_parser.cpp` and `frontend/as_sema.cpp` duplicate preserved root-level sources. Task `2.1` also referenced the old planned AST implementation paths instead of the UBT-safe names established by the completed typed-AST Change.

## Investigation Log

1. Run `121ae5f9c0014d3ebac67a6ba05f649e` established the intended collection-session RED.
2. Exact module enumeration found root `as_parser.cpp` and `as_sema.cpp` in the same Runtime module.
3. The completed typed-AST Replan and UBT failure `9b7e1592c792482abefa8d343b6ed6d7` already prove directory separation does not distinguish non-Unity object basenames.
4. The declarations Task file still named pre-Replan `as_ast_context.cpp` and `as_decl.cpp` paths that do not exist in the verified prerequisite output.

## Root Cause

Planning was authored before the shared UBT-safe implementation-unit convention and before the typed-AST path Replan was applied.

## Disposition

The implementation uses `as_frontend_parser.cpp` and `as_frontend_sema.cpp`, and consumes the actual prerequisite paths `as_frontend_ast_context.cpp` and `as_frontend_decl.cpp`. Public headers, classes, semantics, edges, and verification commands remain unchanged. Build `ad98acdc1f5b426e9369b8db576bae3e` and run `db747b1231844d54883bf26fcf400ac4` resolve the issue.

## Evidence

### Failure Evidence (RED)

- Expected collection RED: `121ae5f9c0014d3ebac67a6ba05f649e`.
- Proven UBT basename rule: typed-AST build `9b7e1592c792482abefa8d343b6ed6d7` and its indexed resolved issue.
- Repository input enumeration found exactly one preserved root `as_parser.cpp` and `as_sema.cpp` before new implementation files were created.

### Resolution Evidence (GREEN)

- Managed build `ad98acdc1f5b426e9369b8db576bae3e` succeeded.
- Exact Declarations Fast run `db747b1231844d54883bf26fcf400ac4` passed 6/6 with zero warnings, errors, or skips.

### What This Proves

- Declaration frontend implementation units must follow the same UBT-safe basename convention.
- Downstream Task files must name the actual synchronized prerequisite artifacts.

### What This Does Not Prove

- It does not change Parser/Sema APIs or semantics.
- It does not authorize editing preserved production Parser/Builder/Engine paths.
- It is not a Harness defect.

## Links

- `attachments/replans/replan-20260905-045641-unique-declaration-implementation-units.md`.
- `tasks.md`, Tasks `1.1` through `2.2`.
