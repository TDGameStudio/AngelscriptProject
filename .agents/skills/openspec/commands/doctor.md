# `openspec doctor`

- Purpose: Inspect repository structure, manifests, identities, paths, and archive placement.
- Mutates: No.
- Automation: Safe and read-only.

```text
openspec doctor [--json]
```

- Output: A diagnostic report; exits nonzero when structural errors exist.
- Exit codes: 0 on success; 1 on validation or command failure; 2 for invalid CLI syntax.
- Related: [validate.md](validate.md)
