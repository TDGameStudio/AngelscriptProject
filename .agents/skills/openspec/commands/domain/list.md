# `openspec domain list`

- Purpose: List registered domains in canonical order.
- Mutates: No.
- Automation: Safe and read-only.

```text
openspec domain list [--json]
```

- Output: Domain IDs, titles, and optional structured records.
- Exit codes: 0 on success; 1 on validation or command failure; 2 for invalid CLI syntax.
- Related: [domain/show.md](show.md)
