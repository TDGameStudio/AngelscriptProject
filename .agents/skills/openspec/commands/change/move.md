# `openspec change move`

- Purpose: Move an active change and retain its previous ID as an alias.
- Mutates: Moves the leaf directory and rewrites its manifest.
- Automation: Use only for an intended canonical rename; conflicts fail before mutation.

```text
openspec change move <ID> --to <NEW_ID> [--json]
```

- Output: Move summary.
- Exit codes: 0 on success; 1 on validation or command failure; 2 for invalid CLI syntax.
- Related: [change/show.md](show.md)
