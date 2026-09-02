# `openspec validate`

- Purpose: Validate active record content or audit every archived closure and its task history, including completed, abandoned, and superseded dispositions.
- Mutates: No.
- Automation: Safe and read-only; validation findings exit with code 1 after the full report is emitted.

Archived audit requires explicit provenance: current records use `archive_schema: closure-v1`; only imported records marked `legacy-completed-v0` use legacy completed-checklist semantics. Completed closures require a non-empty, fully done canonical Task DAG. Abandoned and superseded closures may have no task plan, but any existing Task DAG must be valid with dispositions matching exactly its incomplete nodes.

```text
openspec validate [<ID> [--type change|spec] | --all | --changes [--specs] | --specs | --archived] [--strict] [--json] [--concurrency <N>]
```

- Output: Stable per-item results, totals, and effective concurrency; requirements-v1 owns spec.md, specs/**/spec.md, and tasks.md. `--concurrency` is host-limited and has a hard maximum of 32 workers; `OPENSPEC_CONCURRENCY` follows the same bound.
- Exit codes: 0 on success; 1 on validation or command failure; 2 for invalid CLI syntax.
- Related: [doctor.md](doctor.md)
