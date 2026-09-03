# Work Closure

Closure is explicit and has exactly one of three kinds:

- `completed`: all required tasks and verification are complete.
- `abandoned`: work stops without fulfilling the accepted objective; record the reason.
- `superseded`: another named request or Change replaces this one; record its reference.

Completed closure requires all required tasks and proportionate verification to pass. If verification exposes a local defect, fix and verify it; if evidence invalidates accepted planning truth, Replan before closure. Otherwise proceed directly to closure without creating a Review or recording a Review impact/not-required classification. Durable OpenSpec behavior is synced before archive or marked not applicable with rationale.

Before any archive closure kind, run the exact evolution terminal gate:

```powershell
$result = Invoke-Hardness -Command hardness.evolution.status -Context $context -Parameters @{
    Change          = 'hardness/exact-change-id'
    RequireTerminal = $true
}
```

The gate reads only versioned material-issue and canonical workflow-evaluation frontmatter. Every admitted `openspec-material-issue-v2` record must be `resolved`, evidence-backed `rejected`, or `superseded` by an exact existing v2 issue. `open` is valid while implementation continues but blocks closure. A valid indexed `hardness-workflow-evaluation-v1` record with exact Change identity, ISO-8601 `captured_at`, and `result: passed` is also required. Ignored observations remain non-blocking until explicitly admitted as a material issue.

When an explicitly requested Review file exists, it must be `closed | superseded` before archive, no Critical/Required finding may remain open or deferred, and the resolution/evidence summary must be current. Review absence is a valid completed state.

Reusable gates cited as closure evidence must use hermetic fixtures or stable repository inputs. They must not require the current change to remain under `openspec/changes/`; before archive, confirm that the closing canonical change ID is not configured as a reusable gate's default fixture. Register every accepted performance aggregate and its raw-artifact hashes under `attachments/data/` and `attachments/INDEX.md` before archive; ignored `Saved/` output alone is not durable closure evidence.

Abandoned and superseded closure must not pretend incomplete tasks passed. Record each remaining task as `cancelled | superseded | needs_followup`, with a reason and follow-up reference where applicable. Preserve implementation, review, Replan, and verification history.

Archiving is a separate deterministic operation after policy checks. Closure never chooses or deletes a workspace or worktree. It does not merge specs, merge Git branches, push, remove a worktree, or manufacture completion evidence.

After the move, run strict archived validation and the smallest applicable non-destructive lifecycle gate that can expose active-path coupling. If that gate finds a new defect, keep the archive immutable and open a follow-up change with its own evidence.

Neither observation admission nor the terminal gate starts Review or Replan. Review remains explicit-only; Replan remains evidence-gated by invalidated planning truth. A material finding discovered after archive enters an immediate exact successor Change and v2 issue before final handoff rather than mutating the archive.
