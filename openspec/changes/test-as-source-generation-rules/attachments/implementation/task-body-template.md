# Task Body Template

Every future checkbox generated or manually added to `tasks.md` uses these fields:

```markdown
- [ ] X.Y Outcome-focused task title
  - Files: Exact future test/implementation/release files.
  - Reference: Existing source file/class/method, inventory IDs, or governing design section.
  - AS Scope: Exact declarations/functions/source units and behavior covered.
  - Axes: Exhaustive dimensions and constraints.
  - Oracle: Exact typed values, diagnostics, metadata, side effects, lifecycle, cleanup, isolation, or recovery.
  - Random/Frozen: Legal seed-controlled slots and semantics that never vary.
  - Impact: Additive/release effect and explicit no-adoption statement.
  - Tests: Test files and what they prove.
  - Verify: Exact command(s).
  - Requirement: Governing delta-spec requirement.
  - Dependencies: Prior task IDs and source/catalog prerequisites.
```

Tasks that implement behavior follow a failing-test task. `[P]` is used only when files and shared state are genuinely independent; the generated initial task list does not assume such independence.
