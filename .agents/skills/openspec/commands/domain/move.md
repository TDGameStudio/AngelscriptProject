# `openspec domain move`

- Purpose: Move a domain and cascade descendant domains, specs, and changes.
- Mutates: Moves directories and updates manifests while retaining aliases.
- Automation: Use only for an intended repository-wide namespace change; conflicts fail before mutation.

```text
openspec domain move <ID> --to <NEW_ID> [--json]
```

- Output: Move summary with affected object counts.
- Exit codes: 0 on success; 1 on validation or command failure; 2 for invalid CLI syntax.
- Related: [domain/show.md](show.md)
