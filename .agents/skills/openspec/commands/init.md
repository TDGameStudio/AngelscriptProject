# `openspec init`

- Purpose: Initialize a manifest repository and editable project configuration.
- Mutates: Creates the `openspec/` repository skeleton at the selected path.
- Automation: Safe for a new or already initialized compatible repository; preflight failures do not write.

```text
openspec init [PATH] [--language <LANG>] [--project-id <ID>] [--title <TITLE>] [--workflow <NAME>]
```

- Output: A setup summary; errors identify incompatible existing content.
- Exit codes: 0 on success; 1 on validation or command failure; 2 for invalid CLI syntax.
- Related: [doctor.md](doctor.md)
