# `openspec completion`

- Purpose: Generate, install, or uninstall shell completion.
- Mutates: Install and uninstall modify user shell configuration.
- Automation: Generate is safe; install/uninstall require explicit user intent.

```text
openspec completion <generate|install|uninstall> ...
```

- Output: Shell-specific completion output or installation status.
- Exit codes: 0 on success; 1 on validation or command failure; 2 for invalid CLI syntax.
- Related: [`openspec completion generate`](completion/generate.md)
