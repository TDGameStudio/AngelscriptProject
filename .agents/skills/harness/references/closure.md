# Work Closure

Closure is explicit and has exactly one of three kinds:

- `completed`: all required tasks and verification are complete.
- `abandoned`: work stops without fulfilling the accepted objective; record the reason.
- `superseded`: another named request or Change replaces this one; record its reference.

Completed closure requires all required tasks and proportionate verification to pass. If verification exposes a local defect, fix and verify it; if evidence invalidates accepted planning truth, Replan before closure. Otherwise proceed directly to closure without creating a Review or recording a Review impact/not-required classification. Durable OpenSpec behavior is synced before archive or marked not applicable with rationale.

- Queue closure commits verified owned plugin changes with `PluginsOnly`; record plugin baseline/result commits and host source identity before the final evaluation. Primary-repository work may remain uncommitted under user control without blocking completed closure.
- In a replica, evaluate/archive the canonical Change at `Context.OpenSpecRoot`, while verification artifacts and implementation paths belong to `Context.WorkspaceRoot`.

Before any archive closure kind, run the exact evolution terminal gate:

```powershell
$result = Invoke-Harness -Command harness.evolution.status -Context $context -Parameters @{
    Change          = 'harness/exact-change-id'
    ClosureKind     = 'completed'
    RequireTerminal = $true
}
```

The terminal gate accepts only one exact active Change. Ordinary exact status remains available for immutable archives, while archived policy is audited with `openspec validate --archived --strict --json`; never apply new active-record rules retroactively. The gate consumes the packaged OpenSpec TaskPlan. Completed closure requires a valid, non-empty TaskPlan with every task complete. Abandoned and superseded closure may retain incomplete nodes only when their closure manifest records each disposition. An early incomplete closure may have no `tasks.md`; it still requires fresh evaluation and every other terminal check. A present empty or invalid plan remains a blocker.

- `openspec.change archive` enforces this same terminal gate at its mutation boundary for the exact requested closure kind, regardless of an earlier status result. This is an automatic integrity check, not another user confirmation.
- Pass exactly one closure file. Its root kind must be explicit plain/quoted YAML or a JSON object; the route retains the checked bytes for the native archive operation. Missing, stale, failed or wrong-kind evaluation prevents the move.

Active `attachments/implementation/**/issue-*.md` records are discovered recursively and must be `openspec-material-issue-v2`, indexed exactly once, bound to existing TaskPlan IDs, timestamp-ordered, and structurally complete. Each must be `resolved`, evidence-backed `rejected`, or validly `superseded`; `open` remains valid during implementation but blocks closure. A superseded issue points to one active, indexed, non-superseded v2 owner whose `source_ref` reciprocally identifies the source issue. Historical schema-less records remain readable only after archive.

A valid indexed `harness-workflow-evaluation-v1` record with exact Change identity, ISO-8601 `captured_at`, `result: passed`, requested `closure_kind`, and current `input_sha256` is required. The digest covers every ordinary active Change file except the evaluation itself, using ordinal forward-slash paths and length-framed path/content bytes. Write the evaluation last; its capture time cannot precede the latest terminal issue or Review event. Ignored observations remain non-blocking until explicitly admitted as a material issue.

When an explicitly requested `attachments/reviews/**/review-*.md` file exists, active policy requires `review-v2`, exact INDEX membership, valid immutable-snapshot metadata, ordered lifecycle timestamps, and `closed | superseded` before every closure kind. A closed Review requires `APPROVE`; no Critical/Required finding may remain open or deferred. Review absence is valid.

Reusable gates cited as closure evidence must use hermetic fixtures or stable repository inputs. They must not require the current change to remain under `openspec/changes/`; before archive, confirm that the closing canonical change ID is not configured as a reusable gate's default fixture. Register every accepted performance aggregate and its raw-artifact hashes under `attachments/data/` and `attachments/INDEX.md` before archive; ignored `Saved/` output alone is not durable closure evidence.

Abandoned and superseded closure must not pretend incomplete tasks passed. Record each remaining task as `cancelled | superseded | needs_followup`, with a reason and follow-up reference where applicable. Preserve implementation, review, Replan, and verification history.

Archiving is a separate deterministic operation after policy checks. Closure never chooses or deletes a workspace or worktree. It does not merge specs, merge Git branches, push, remove a worktree, or manufacture completion evidence.

After the move, run strict archived validation and only the smallest applicable non-destructive check that does not reapply active terminal policy. `RequireTerminal` deliberately rejects an archived target. If post-move evidence finds a new defect, keep the archive immutable and collect it with source evidence in the feedback inbox or a linked draft. The user selects any new repair scope and formal handoff through the normal Gates. A bounded direct repair already authorized by the user continues within that scope without another Change or repeated approval.

Neither observation admission nor the terminal gate starts Review or Replan. Review remains explicit-only; Replan remains evidence-gated by invalidated planning truth. A material finding discovered after archive does not automatically create a successor Change; batch it for the user under [evolution](evolution.md), preserving the archive.

- Before terminal evaluation, resolve current-scope discussions, finish Replan recovery, if transcript recording was explicitly enabled, synchronize and unbind its active Change sink. There is no default transcript or dual-writing requirement. Pending decisions or an active recording sink prevent archive; archived originals remain immutable.
