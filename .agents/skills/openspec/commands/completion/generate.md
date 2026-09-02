# `openspec completion generate`

- Purpose: Generate a completion script for a supported shell.
- Mutates: No; writes the script to standard output.
- Automation: Safe and read-only.

```text
openspec completion generate [bash|zsh|fish|elvish]
```

- Output: Completion script text.
- Exit codes: 0 on success; 1 on validation or command failure; 2 for invalid CLI syntax.
- Related: [completion/install.md](install.md)
