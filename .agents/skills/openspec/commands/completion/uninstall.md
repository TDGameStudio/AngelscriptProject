# `openspec completion uninstall`

- Purpose: Remove installed completion for a supported shell.
- Mutates: Deletes OpenSpec-managed user completion configuration.
- Automation: Run only on explicit user request. An existing managed file is never deleted unless `--yes` is present.

```text
openspec completion uninstall [bash|zsh|fish] [--yes]
```

- Output: Removal status, or the exact retained path when confirmation is missing. Elvish is supported by `generate`, but user-level Elvish removal is not supported.
- Exit codes: 0 on success; 1 on validation or command failure; 2 for invalid CLI syntax.
- Related: [completion/install.md](install.md)
