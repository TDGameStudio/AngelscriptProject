# `openspec spec`

- Purpose: Manage current specification objects.
- Mutates: Subcommands may create or move specifications.
- Automation: Dispatch only an explicitly selected subcommand.

```text
openspec spec <create|list|show|move> ...
```

- Output: Subcommand-specific manifest or move output.
- Exit codes: 0 on success; 1 on validation or command failure; 2 for invalid CLI syntax.
- Related: [`openspec spec create`](spec/create.md)
