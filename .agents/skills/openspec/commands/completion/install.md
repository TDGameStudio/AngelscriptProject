# `openspec completion install`

- Purpose: Install completion for a supported shell.
- Mutates: Writes user shell completion configuration.
- Automation: Run only on explicit user request because it changes user-level files.

```text
openspec completion install [bash|zsh|fish] [--verbose]
```

- Output: Installation path and status. Elvish is supported by `generate`, but user-level Elvish installation is not supported.
- Exit codes: 0 on success; 1 on validation or command failure; 2 for invalid CLI syntax.
- Related: [completion/uninstall.md](uninstall.md)
