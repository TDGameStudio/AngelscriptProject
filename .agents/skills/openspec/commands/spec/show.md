# `openspec spec show`

- Purpose: Show one current specification manifest.
- Mutates: No.
- Automation: Safe and read-only.

```text
openspec spec show <ID> [--json]
```

- Output: The resolved canonical ID, path, and manifest.
- Exit codes: 0 on success; 1 on validation or command failure; 2 for invalid CLI syntax.
- Related: [spec/list.md](list.md)
