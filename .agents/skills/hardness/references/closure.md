# Goal Closure

Closure is explicit and has exactly one of three kinds:

- `completed`: all required tasks and verification are complete.
- `abandoned`: work stops without fulfilling the goal; record the reason.
- `superseded`: another named goal or change replaces this one; record its reference.

Completed closure requires a clean verified workspace and an explicit final impact disposition: broad-impact work has one closed approving Final Review bound to the current scope-frozen final snapshot; verified small low-impact work records `Final Review: not required` and the reason. Every existing Review file is `closed | superseded`, no Critical/Required finding is open or deferred, and a short resolution/evidence summary is present. Incident and External Reviews do not silently substitute for a required Final Review. Durable OpenSpec behavior is synced before archive or marked not applicable with rationale.

Reusable gates cited as closure evidence must use hermetic fixtures or stable repository inputs. They must not require the current change to remain under `openspec/changes/`; before archive, confirm that the closing canonical change ID is not configured as a reusable gate's default fixture. Register every accepted performance aggregate and its raw-artifact hashes under `attachments/data/` and `attachments/INDEX.md` before archive; ignored `Saved/` output alone is not durable closure evidence.

Abandoned and superseded closure must not pretend incomplete tasks passed. Record each remaining task as `cancelled | superseded | needs_followup`, with a reason and follow-up reference where applicable. Preserve implementation, review, Replan, and verification history.

Archiving is a separate deterministic operation after policy checks. It does not merge specs, merge Git branches, push, remove a worktree, or manufacture completion evidence.

After the move, run strict archived validation and the smallest applicable non-destructive lifecycle gate that can expose active-path coupling. If that gate finds a new defect, keep the archive immutable and open a follow-up change with its own evidence.
