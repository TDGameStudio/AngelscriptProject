# `openspec status`

- Purpose: Report artifact and operation readiness for one active change.
- Mutates: No.
- Automation: Safe and read-only.

```text
openspec status [--change <ID>] [--workflow <NAME>] [--json]
```

- Output: Resolved workflow, artifact states, required flags, and operation Task DAG progress.
- Exit codes: 0 on success; 1 on validation or command failure; 2 for invalid CLI syntax.
- Related: [instructions.md](instructions.md)
