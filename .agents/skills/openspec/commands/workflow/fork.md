# `openspec workflow fork`

- Purpose: Copy a resolved workflow into the project for customization.
- Mutates: Creates or, with `--force`, replaces `openspec/workflows/<NAME>/`.
- Automation: Safe for a new destination; `--force` is destructive and requires explicit intent.

```text
openspec workflow fork <SOURCE> [NAME] [--force] [--json]
```

- Output: Destination package and source information.
- Exit codes: 0 on success; 1 on validation or command failure; 2 for invalid CLI syntax.
- Related: [workflow/init.md](init.md)
