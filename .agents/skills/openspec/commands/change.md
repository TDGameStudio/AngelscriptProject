# `openspec change`

- Purpose: Manage active changes and deterministic archive moves.
- Mutates: Subcommands may create, move, or archive changes.
- Automation: Dispatch only an explicitly selected subcommand.

```text
openspec change <create|list|show|move|archive> ...
```

- Output: Subcommand-specific manifest, move, or archive output.
- Exit codes: 0 on success; 1 on validation or command failure; 2 for invalid CLI syntax.
- Related: [`openspec change create`](change/create.md)
