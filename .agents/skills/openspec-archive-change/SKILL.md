---
name: openspec-archive-change
description: Close and archive an OpenSpec change with explicit completed, abandoned, or superseded closure. Use after verification; the CLI primitive only records closure and performs a deterministic directory move.
---

# Close and Archive a Change

Read the [closure schema](../openspec/references/record-schema.md), [attachment gates](../openspec/references/attachments.md), and Harness [impact-scoped verification policy](../harness/references/verification.md). Use the smallest applicable post-move check and expand only when its evidence requires it.

## Completed gate

- `doctor` and strict change validation pass.
- Every real Task DAG node is complete and its evidence remains valid.
- Verification found no unresolved local defect or planning-invalidating evidence. Repair local defects and verify them; Replan only when accepted planning truth is invalid. Otherwise close and archive directly without creating or classifying a Review.
- If an explicitly requested Review file exists, it is `closed` or `superseded`; no Critical/Required finding is open or deferred, and resolutions include evidence and any required re-review. Review absence is valid.
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
