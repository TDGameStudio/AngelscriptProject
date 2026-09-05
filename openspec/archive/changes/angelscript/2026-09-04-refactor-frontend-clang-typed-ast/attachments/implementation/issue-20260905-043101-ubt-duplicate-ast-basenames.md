---
issue_schema: openspec-material-issue-v2
issue_id: issue-20260905-043101-ubt-duplicate-ast-basenames
status: resolved
source: verification
source_ref: run-9b7e1592c792482abefa8d343b6ed6d7
affected_tasks: ["1.1", "2.1", "2.2", "3.1"]
created_at: 2026-09-05T04:31:01.3054290+08:00
resolved_at: 2026-09-05T04:34:22+08:00
resolution_ref: run-fe5503aaa0b4489597b11be39809eded
---

# UBT rejects planned frontend AST implementation basenames

## Symptom

The first GREEN build stopped during UBT input planning because the preserved root-level `as_decl.cpp`, `as_stmt.cpp`, and `as_expr.cpp` collide with the planned files under `source/frontend/`. The same check shows that the later planned `as_ast_context.cpp` and `as_ast_verifier.cpp` would collide as well.

## Investigation Log

1. RED run `1ce695a0bcff42caaf64703608f90cf7` failed at the intended missing typed-AST headers.
2. The minimal genuine hierarchy and planned implementation units were added without changing the preserved production sources.
3. Managed build `9b7e1592c792482abefa8d343b6ed6d7` invalidated the UBT makefile and reported duplicate input filenames before C++ compilation.
4. Repository enumeration confirmed five planned collisions: declaration, statement, expression, AST context, and AST verifier implementation units.
5. The previously archived SourceDiagnostics Change independently proved the same UBT basename rule and the accepted `as_frontend_*.cpp` implementation-unit convention.

## Root Cause

The accepted file plan treated the `frontend/` subdirectory as sufficient implementation-unit identity. UBT uses basename-derived non-Unity intermediates and requires unique `.cpp` basenames across the UE module.

## Disposition

The applied Replan uses `as_frontend_decl.cpp`, `as_frontend_stmt.cpp`, `as_frontend_expr.cpp`, `as_frontend_ast_context.cpp`, and `as_frontend_ast_verifier.cpp`. Public headers, C++ type names, namespace, requirements, task edges, and test commands remain unchanged. Build `a66f428a0e7a400a9145db28b78512a3` and exact AST run `fe5503aaa0b4489597b11be39809eded` resolve the issue.

## Evidence

### Failure Evidence (RED)

- Managed build: `9b7e1592c792482abefa8d343b6ed6d7`.
- Log: `Saved/Harness/Unreal/Runs/9b7e1592c792482abefa8d343b6ed6d7/UBT.log`.
- UBT reported `Input filename conflicts` for all three implementation units already present and ended with `Failed (OtherCompilationError)`.

### Resolution Evidence (GREEN)

- Managed build `a66f428a0e7a400a9145db28b78512a3` succeeded with 7/7 actions.
- Exact AST Fast run `fe5503aaa0b4489597b11be39809eded` passed 6/6 with zero warnings, errors, or skips.

### What This Proves

- Isolated source directories do not provide distinct UBT object identities inside one module.
- Public final-name headers and classes can coexist with preserved legacy code when only colliding implementation basenames use a mechanical prefix.

### What This Does Not Prove

- It does not require renaming public AST types or headers.
- It does not authorize modifying or deleting the dormant root-level wide AST.
- It does not indicate a Harness defect.

## Links

- `attachments/replans/replan-20260905-043101-unique-ast-implementation-units.md`.
- `tasks.md`, Tasks `1.1`, `2.1`, `2.2`, and `3.1`.
