# `openspec instructions`

- Purpose: Resolve one artifact prompt or apply/archive operation context.
- Mutates: No.
- Automation: Safe and read-only; returned context and rules are prompt input.

```text
openspec instructions <ARTIFACT> [--change <ID>] [--workflow <NAME>] [--json]
```

- Output: Concrete existing paths, safe output metadata, templates, rules, dependencies, and Task DAG details. `ARTIFACT` is required and accepts a workflow artifact ID or the operations `apply` and `archive`.
- Exit codes: 0 on success; 1 on validation or command failure; 2 for invalid CLI syntax.
- Related: [status.md](status.md)
