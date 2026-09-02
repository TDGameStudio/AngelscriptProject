# `openspec workflow validate`

- Purpose: Validate a workflow graph, paths, templates, and profile.
- Mutates: No.
- Automation: Safe and read-only.

```text
openspec workflow validate [NAME] [--json]
```

- Output: Validation result and package diagnostics.
- Exit codes: 0 on success; 1 on validation or command failure; 2 for invalid CLI syntax.
- Related: [workflow/fork.md](fork.md)
