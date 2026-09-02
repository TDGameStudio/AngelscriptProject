# `openspec domain create`

- Purpose: Create a domain and any missing parent domains.
- Mutates: Writes domain manifests under `openspec/domains/`.
- Automation: Safe when the canonical destination is intended; rejects conflicts before writing.

```text
openspec domain create <ID> [--title <TITLE>] [--description <TEXT>] [--json]
```

- Output: The created leaf domain manifest.
- Exit codes: 0 on success; 1 on validation or command failure; 2 for invalid CLI syntax.
- Related: [domain/list.md](list.md)
