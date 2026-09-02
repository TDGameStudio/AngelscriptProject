# `openspec workflow init`

- Purpose: Create a new project-local workflow package.
- Mutates: Creates or, with `--force`, replaces a workflow directory and templates.
- Automation: Safe for a new name; `--force` is destructive and requires explicit intent.

```text
openspec workflow init <NAME> [--force] [--json]
```

- Output: Initialized workflow package details.
- Exit codes: 0 on success; 1 on validation or command failure; 2 for invalid CLI syntax.
- Related: [workflow/validate.md](validate.md)
