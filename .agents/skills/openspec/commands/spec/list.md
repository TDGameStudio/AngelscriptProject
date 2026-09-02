# `openspec spec list`

- Purpose: List current specification objects.
- Mutates: No.
- Automation: Safe and read-only.

```text
openspec spec list [--json]
```

- Output: Canonical IDs, titles, and optional structured records.
- Exit codes: 0 on success; 1 on validation or command failure; 2 for invalid CLI syntax.
- Related: [spec/show.md](show.md)
