---
name: openspec-archive-change
description: Close and archive an OpenSpec change with explicit completed, abandoned, or superseded closure. Use after verification; the CLI primitive only records closure and performs a deterministic directory move.
---

# Close and Archive a Change

- Read the [closure schema](../openspec/references/record-schema.md), [attachment gates](../openspec/references/attachments.md), and Harness [impact-scoped verification policy](../harness/references/verification.md).
- Harness [closure](../harness/references/closure.md) owns the complete result explanation, actual selectable close Gate, exact Git plan and recovery. Show accepted design versus implemented behavior, actual proof/limits, selected/excluded workspace content and the post-close state before asking commit-and-archive, explain/adjust, or leave pending.
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
- Preserve the shown owned implementation in an explicitly incomplete Git checkpoint before an exact withdrawal. Abandoned work withdraws only its approved owned portion; superseded work follows the named replacement's accepted carryover. Prove and commit the withdrawal while preserving unrelated hunks/staging and normal hooks. Replan or dissatisfaction alone is not abandonment authority; do not promote unfinished deltas into current specs.
- An early Change without `tasks.md` may close as abandoned or superseded with fresh terminal evidence; do not invent tasks. A present task plan must still be valid.

## Procedure

```text
close checks + full explanation of result/Git disposition
  -> harness.change.close PlanOnly -> actual version-bound selectable Gate
  -> same exact close operation: implementation/save/withdrawal stages
  -> terminal checkpoint -> native archive -> exact archived-item validation
  -> canonical result/record commit -> full close complete -> queue advance
```

- The primitive never merges specs, validates implementation, edits attachments, or decides closure kind.
- The public Harness archive route requires the approved close operation and current terminal evaluation before invoking that primitive. Calling raw archive with a valid evaluation cannot bypass the actual close Gate. `harness.change.close` supplies its private operation and exact closure bytes.
- The close operation generates one closure file from the approved Dispositions.Closure, with explicit completed/abandoned/superseded kind. The checked bytes are the bytes consumed by native archive; callers do not bypass close by supplying another file.
- Never hand-move the directory.
- A moved archive with a failed final canonical commit is still `close-pending`; retry the saved exact close request. Preserve successful earlier commits and immutable archive bytes. The same shown close approval covers its local commits; do not add another generic Git question. Generic queue authorization alone never approves unseen close content.
- If a post-move check exposes a new defect, preserve the archive and capture its source evidence in the owning topic draft, visible through the feedback query.
  - Continue an already authorized bounded direct repair within its existing scope; do not manufacture another Change or repeat approval.
  - For a new repair scope, let the user select it. A formal successor requires user-led convergence and its exact handoff Gate; recording a finding never creates one automatically.
- Report the archived path, closure kind, evidence, historical-audit result, and post-move gate.
