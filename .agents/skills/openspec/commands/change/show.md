# `openspec change show`

- Purpose: Show one active change manifest.
- Mutates: No.
- Automation: Safe and read-only.

```text
openspec change show <ID> [--json]
```

- Output: The resolved canonical ID, path, and manifest.
- Exit codes: 0 on success; 1 on validation or command failure; 2 for invalid CLI syntax.
- Related: [change/list.md](list.md)
