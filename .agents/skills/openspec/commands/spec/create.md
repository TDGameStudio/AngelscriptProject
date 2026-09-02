# `openspec spec create`

- Purpose: Create a current specification in a registered domain.
- Mutates: Writes `spec.yaml`; document content remains project-owned.
- Automation: Safe when the canonical destination is intended; rejects unregistered domains and conflicts.

```text
openspec spec create <ID> [--title <TITLE>] [--description <TEXT>] [--json]
```

- Output: The created specification manifest.
- Exit codes: 0 on success; 1 on validation or command failure; 2 for invalid CLI syntax.
- Related: [spec/list.md](list.md)
