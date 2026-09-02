# `openspec workflow which`

- Purpose: Show precedence and the active source for one workflow name.
- Mutates: No.
- Automation: Safe and read-only.

```text
openspec workflow which <NAME> [--json]
```

- Output: Resolved and shadowed project, user, and embedded sources.
- Exit codes: 0 on success; 1 on validation or command failure; 2 for invalid CLI syntax.
- Related: [workflow/validate.md](validate.md)
