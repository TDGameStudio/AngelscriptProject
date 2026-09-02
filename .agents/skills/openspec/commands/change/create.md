# `openspec change create`

- Purpose: Create an active change in a registered domain.
- Mutates: Writes `change.yaml` and its leaf directory.
- Automation: Safe when the ID, workflow, goal, and affected areas are intended.

```text
openspec change create <ID> [--title <TITLE>] [--description <TEXT>] [--workflow <NAME>] [--goal <TEXT>] [--affected-area <AREA>]... [--json]
```

- Output: The created active change manifest.
- Exit codes: 0 on success; 1 on validation or command failure; 2 for invalid CLI syntax.
- Related: [change/show.md](show.md)
