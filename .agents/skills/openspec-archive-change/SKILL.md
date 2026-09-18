---
name: openspec-archive-change
description: Close and archive an OpenSpec change with explicit completed, abandoned, or superseded closure. Use after verification; the CLI primitive only records closure and performs a deterministic directory move.
---

# Close and Archive a Change

- Read the [closure schema](../openspec/references/record-schema.md), [attachment gates](../openspec/references/attachments.md), and Harness [impact-scoped verification policy](../harness/references/verification.md).
- Use the smallest applicable post-move check and expand only when its evidence requires it.

## Completed gate

- `doctor` and strict change validation pass.
- Every real Task DAG node is complete and its evidence remains valid.
- Verification found no unresolved local defect or planning-invalidating evidence.
  - Repair local defects and verify them; Replan only when accepted planning truth is invalid.
  - Otherwise close and archive directly without creating or classifying a Review.
- If an explicitly requested Review file exists, it is `closed` or `superseded`; no Critical/Required finding is open or deferred, and resolutions include evidence and any required re-review.
- Review absence is valid.
- Implementation issues are resolved/superseded, data is trimmed, INDEX is current, and knowledge promotion is decided.
- The closing canonical change ID is not configured as a reusable gate's default fixture.
  - A gate that needs an active Task DAG uses a hermetic default or an explicit override; archived tasks never become schedulable input.
- Accepted performance aggregates and raw-artifact hashes are indexed before archive.
- Durable deltas were synced, or the record explicitly states N/A.

## Incomplete closure

- `abandoned` and `superseded` are explicit outcomes, not bypasses.
- Supply a reason and a disposition for every incomplete task; `superseded` also identifies its replacement.
- Do not mark incomplete tasks done.
- An early Change without `tasks.md` may close as abandoned or superseded with fresh terminal evidence; do not invent tasks. A present task plan must still be valid.

## Procedure

```text
close checks
  -> prepare closure YAML
  -> openspec.change archive <id> --closure-file <path>
  -> openspec.validate --archived --strict --json
  -> smallest applicable non-destructive lifecycle gate
```

- The primitive never merges specs, validates implementation, edits attachments, or decides closure kind.
- The public Harness archive route enforces the current terminal evaluation immediately before invoking that primitive. A separate successful status check cannot substitute for this mutation-time check.
- Supply one closure file with an explicit root `kind: completed`, `kind: abandoned`, or `kind: superseded` (plain or quoted YAML, or a JSON object). The checked file bytes are the bytes consumed by archive.
- Never hand-move the directory.
- If a post-move check exposes a new defect, preserve the archive and capture its source evidence in the feedback inbox or a linked draft.
  - Continue an already authorized bounded direct repair within its existing scope; do not manufacture another Change or repeat approval.
  - For a new repair scope, let the user select it. A formal successor requires user-led convergence and its exact handoff Gate; recording a finding never creates one automatically.
- Report the archived path, closure kind, evidence, historical-audit result, and post-move gate.
