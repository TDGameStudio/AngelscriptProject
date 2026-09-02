# `openspec change list`

- Purpose: List active changes.
- Mutates: No.
- Automation: Safe and read-only.

```text
openspec change list [--json]
```

- Output: Canonical IDs, titles, and optional structured records.
- Exit codes: 0 on success; 1 on validation or command failure; 2 for invalid CLI syntax.
- Related: [change/show.md](show.md)
