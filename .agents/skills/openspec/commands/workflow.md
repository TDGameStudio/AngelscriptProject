# `openspec workflow`

- Purpose: Inspect, validate, fork, or initialize workflow packages.
- Mutates: Fork and init subcommands write project-local packages.
- Automation: Read subcommands are safe; write subcommands require an intended destination.

```text
openspec workflow <list|which|validate|fork|init> ...
```

- Output: Workflow resolution, validation, or package details.
- Exit codes: 0 on success; 1 on validation or command failure; 2 for invalid CLI syntax.
- Related: [`openspec workflow list`](workflow/list.md)
