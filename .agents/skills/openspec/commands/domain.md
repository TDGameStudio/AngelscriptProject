# `openspec domain`

- Purpose: Manage registered first-class domain paths.
- Mutates: Subcommands may create or move domains.
- Automation: Dispatch only an explicitly selected subcommand.

```text
openspec domain <create|list|show|move> ...
```

- Output: Subcommand-specific manifest or move output.
- Exit codes: 0 on success; 1 on validation or command failure; 2 for invalid CLI syntax.
- Related: [`openspec domain create`](domain/create.md)
