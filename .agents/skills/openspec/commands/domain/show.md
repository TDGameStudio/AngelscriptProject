# `openspec domain show`

- Purpose: Show one domain manifest by canonical ID or alias.
- Mutates: No.
- Automation: Safe and read-only.

```text
openspec domain show <ID> [--json]
```

- Output: The resolved canonical ID, path, and manifest.
- Exit codes: 0 on success; 1 on validation or command failure; 2 for invalid CLI syntax.
- Related: [domain/list.md](list.md)
