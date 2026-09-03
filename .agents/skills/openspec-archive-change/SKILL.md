---
name: openspec-archive-change
description: Close and archive an OpenSpec change with explicit completed, abandoned, or superseded closure. Use after verification; the CLI primitive only records closure and performs a deterministic directory move.
---

# Close and Archive a Change

Read the [closure schema](../openspec/references/record-schema.md) and [attachment gates](../openspec/references/attachments.md).

## Completed gate

- `doctor` and strict change validation pass.
- Every real Task DAG node is complete and its evidence remains valid.
- Broad-impact work has one approving Final Review `closed` against the current scope-frozen final snapshot; verified small low-impact work instead records `Final Review: not required` with impact rationale. Every existing Review is `closed` or `superseded`; no Critical/Required finding is open or deferred; resolutions include evidence and re-review.
- Implementation issues are resolved/superseded, data is trimmed, INDEX is current, and knowledge promotion is decided.
- The closing canonical change ID is not configured as a reusable gate's default fixture. A gate that needs an active Task DAG uses a hermetic default or an explicit override; archived tasks never become schedulable input.
- Accepted performance aggregates and raw-artifact hashes are indexed before archive.
- Durable deltas were synced, or the record explicitly states N/A.

## Incomplete closure

`abandoned` and `superseded` are explicit outcomes, not bypasses. Supply a reason and a disposition for every incomplete task; `superseded` also identifies its replacement. Do not mark incomplete tasks done.

## Procedure

```text
close checks
  -> prepare closure YAML
  -> openspec.change archive <id> --closure-file <path>
  -> openspec.validate --archived --strict --json
  -> smallest applicable non-destructive lifecycle gate
```

The primitive never merges specs, validates implementation, edits attachments, or decides closure kind. Never hand-move the directory. If a post-move gate exposes a new defect, do not edit the archive; open a follow-up change with independent evidence. Report the archived path, closure kind, evidence, historical-audit result, and post-move gate.
