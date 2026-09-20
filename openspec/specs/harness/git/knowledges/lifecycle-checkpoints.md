# Planning, implementation and final closure

## Three different things become durable

| Point | What the local Git history preserves | What it does not imply |
| --- | --- | --- |
| Accepted Create | Complete proposal, design, Task DAG, applicable delta specs, exports and decision provenance in the canonical OpenSpec repository | Implementation has begun; the subsequent arrangement still owns execution. |
| Accepted Replan | The exact revised formal plan and its provenance | Unfinished implementation has been checkpointed or may resume before arrangement. |
| Approved final close | Selected implementation, truthful outcome, verified archive and selected canonical records | Integration, remote push or workspace removal is authorized. |

The current `harness.change.create` and `harness.replan.apply` compose planning validation with exact Git candidates. New Create validates a complete candidate before materializing it. A failed planning commit leaves a visible pending operation and blocks implementation; exact retry retains identity and the original decision. Historical accepted records retain their compatibility contract.

The agent explains the actual selected content, proof and remaining work before the user decides. A preview is read-only. A materially changed candidate needs a fresh actual decision; cancelled, pending and preselected choices are not approval. The final close decision covers the shown local commits and archive together. Normal hooks remain active.

## Follow one partial close

Consider a plugin change whose parent repository stores OpenSpec. A plugin Git commit saves the selected plugin code. The parent stores a **gitlink**, the exact plugin commit it refers to, as well as planning and archive files. The two repositories have separate histories.

```text
harness.change.close
  -> verify the accepted selection and execution ownership
  -> save selected implementation in its owning repositories
  -> prepare terminal evidence and the truthful closure receipt
  -> move the Change into its archive and validate that exact item
  -> commit selected canonical records and selected resulting gitlinks
  -> mark the close complete; queue may register and advance it
```

If the plugin commit succeeds, the Change directory is archived, and the parent's pre-commit hook rejects the final records, **code is saved and records have moved, but full closure is pending**. `Stage=archived` with `Complete=false` describes this partial result. The queue reports `close-pending` and execution is `closing`; implementation and advancement are blocked. Directory existence alone cannot establish that the records entered Git history.

Retry the same accepted `harness.change.close` request after correcting the actual failure. The operation verifies saved outputs and finishes the remaining step without duplicating the earlier implementation commit or archive. Changed selected bytes must not be silently absorbed. Completion requires Git-persisted canonical archive content, not merely a machine-local success label. Recovery without local state can recognize an already committed closure receipt and its matching records; missing evidence remains blocking.

## Selection and incomplete outcomes

- Select exact owned paths or explicit patches. Shared-file patches can retain unrelated live and staged edits; do not infer ownership from all current modifications. The preview binds content, baseline, branch and commit intent. Normal hooks may reject a candidate; they cannot rewrite accepted selected content unnoticed.
- For completed closure, applicable specs and verification must be ready. Commit only explicitly selected plugin pointers and canonical paths. A primary workspace can close parent-owned implementation with its records; a replica commits implementation in its workspace and canonical records in `OpenSpecRoot`.
- Abandoned or superseded closure never means “implemented successfully”. Disposition every unfinished task, identify the existing replacement when superseded, and checkpoint selected code with a visibly incomplete intent before any accepted withdrawal. Show exact withdrawal and retained carryover patches; verify the result against the named baseline plus retained work. No blanket reset/restore is implied. No owned implementation requires an explicit rationale.
- The queue can register completed, abandoned or superseded outcomes only after their approved closure is fully persisted. It does not add the replacement or any work outside the originally authorized range.

These are local lifecycle operations. [Separate Git Delivery Authorities](delivery-authorities.md) continues to own the independent integration, push and removal boundaries.

## Source and proof boundary

Change `harness/feature-lifecycle-git-closure` (UID `change_9f1c9245-1e3e-49a7-9d23-7754908153bb`) owns the implementation and evidence in tasks 1.1–1.6 and 2.3–2.4. The owning sources are `ChangeGate.psm1`, `PlanningGit.psm1`, `ChangeClosure.psm1`, `closure_status.py`, `change_queue.py` and `GitOperations.psm1`; current harness/core and harness/git specifications own durable behavior.

Real temporary-repository fixtures prove exact selection, normal-hook failures, incomplete withdrawal/carryover, canonical recovery and queue boundaries. The indexed consumer audit tests explanations separately in a simulated host; it cannot prove popup rendering, user comprehension or statistical prompt reliability. The article generalizes those mechanisms, not one machine's transient closure state.
