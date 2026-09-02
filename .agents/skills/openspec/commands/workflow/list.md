# `openspec workflow list`

- Purpose: List resolved workflow definitions and sources.
- Mutates: No.
- Automation: Safe and read-only.

```text
openspec workflow list [--json]
```

- Output: Workflow names, sources, paths, and artifact order.
- Exit codes: 0 on success; 1 on validation or command failure; 2 for invalid CLI syntax.
- Related: [workflow/which.md](which.md)
