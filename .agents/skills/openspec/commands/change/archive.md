# `openspec change archive`

- Purpose: Record an explicit closure and move an active change into the dated archive.
- Mutates: Writes `archived_at`, `archive_schema: closure-v1`, and `closure`, then performs a pure directory move; it never merges specs.
- Automation: Requires an intentional closure file and preflights task closure policy plus successor referential integrity. Completed tasks must all be done; early abandoned/superseded records may have no Task DAG. Target collisions fail before mutation.

```text
openspec change archive <ID> --closure-file <PATH> [--date <YYYY-MM-DD>] [--json]
```

- Output: Archive ID, path, and timestamp. Superseded closure stores the resolved successor UID and rejects missing, self, ambiguous, or cyclic links. Run `validate --archived` to audit history.
- Exit codes: 0 on success; 1 on validation or command failure; 2 for invalid CLI syntax.
- Related: [`openspec validate`](../validate.md)
