---
name: openspec-archive-change
description: Close and archive an OpenSpec change with explicit completed, abandoned, or superseded closure. Use after verification; the CLI primitive only records closure and performs a deterministic directory move.
---

# Close and Archive a Change

Read the [closure schema](../openspec/references/record-schema.md) and [attachment gates](../openspec/references/attachments.md).

## Completed gate

- `doctor` and strict change validation pass.
- Every real Task DAG node is complete and its evidence remains valid.
- Every review is `closed` or `superseded`; no Critical/Required finding is open or deferred; resolutions include evidence and re-review.
- Implementation issues are resolved/superseded, data is trimmed, INDEX is current, and knowledge promotion is decided.
- Durable deltas were synced, or the record explicitly states N/A.

## Incomplete closure

`abandoned` and `superseded` are explicit outcomes, not bypasses. Supply a reason and a disposition for every incomplete task; `superseded` also identifies its replacement. Do not mark incomplete tasks done.

## Procedure

```text
close checks
  -> prepare closure YAML
  -> openspec.change archive <id> --closure-file <path>
  -> openspec.validate --archived --strict --json
```

The primitive never merges specs, validates implementation, edits attachments, or decides closure kind. Never hand-move the directory. Report the archived path, closure kind, evidence, and historical-audit result.
