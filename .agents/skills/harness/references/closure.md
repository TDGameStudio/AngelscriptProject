# Work Closure

Closure is explicit and has exactly one of three kinds:

- `completed`: all required tasks and verification are complete.
- `abandoned`: work stops without fulfilling the accepted objective; record the reason.
- `superseded`: another named request or Change replaces this one; record its reference.

Completed closure requires all required tasks and proportionate verification to pass. If verification exposes a local defect, fix and verify it; if evidence invalidates accepted planning truth, Replan before closure. Otherwise proceed directly to closure without creating a Review or recording a Review impact/not-required classification. Durable OpenSpec behavior is synced before archive or marked not applicable with rationale.

- A complete close persists all approved owned results: editable plugin commits where needed, canonical planning/archive records and selected primary implementation/specification paths. An archive move with a pending canonical commit remains unfinished closure. Unrelated dirty or staged work stays outside the selection.
- In a replica, evaluate/archive the canonical Change at `Context.OpenSpecRoot`, while verification artifacts and implementation paths belong to `Context.WorkspaceRoot`.

## Explain the whole result before its selectable Gate

Present the original problem, accepted design and actual implemented behavior together. Carry a concrete example through the before/after architecture, identifying changed responsibilities and meaningful additions/removals. Explain remaining differences from the accepted design, compatibility, proof actually run, deliberately omitted heavier checks and unresolved limits. A task count, test total, revision hash or file list does not replace this account.

Then show the current workspace: each repository/branch/baseline; selected paths and meaningful hunks; code, formal records and current-spec changes; unrelated live/staged work; and exactly what will remain after closure. Explain mixed-file patches, selected parent gitlinks and partial recovery. For incomplete closure additionally show unfinished task dispositions, the visibly labelled incomplete checkpoint, exact withdrawal and verification, and any replacement's accepted carryover. Dissatisfaction with an explanation is not abandonment authority.

Prepare `harness.change.close` with `PlanOnly=$true` and the concrete inputs below. Explain that exact `HandoffRevision`, then **actually submit** an approval-capable selectable popup under [host interaction](../../grill/references/hosts.md), normally:

- **Commit and archive this result** — performs the explained scoped local commits and archive stages.
- **Explain or adjust further** — returns to the current explanation/design and its improvement loop.
- **Leave this close pending** — preserves the work and its explicit return state.

Use already-existing explicit authority when it covers this exact content and operation; do not ask it twice. Generic queue execution or approval of earlier planning does not cover unseen final Git content. Approval for this single close covers its shown local commits and native archive; do not add a redundant second commit question. A material change to content, ownership, baseline or dispositions needs a fresh preview and actual decision. Push, integration and workspace removal remain separate.

## Execute the exact close plan

`harness.change.close` accepts `ChangeId`, `ClosureKind`, `SessionId`, `GitPlan`, `Dispositions`, optional `PlanOnly`, and the actual `Gate` (`DecisionSource`, `Decision='close'`, `TargetChange`, `HandoffRevision`). Prepare actual values, not placeholders:

```text
GitPlan.Implementation: exact git.commit argument map, or an empty map
GitPlan.Records: canonical parent scopes including openspec/changes/<id>
GitPlan.Withdrawal: explicit scoped patches for an incomplete implementation
Dispositions.Closure: native kind/reason/task_dispositions/superseded_by
Dispositions.SpecSync: actual synchronization result or concrete N/A reason
Dispositions.Verification: actual proof reference and relevant limits
```

- Completed implementation steps select editable plugins; selected parent implementation belongs in `Records` with the canonical records. Include a plugin's parent gitlink only when explicitly part of the shown selection. Replica commits do not integrate into primary plugin branches.
- Each Git map supplies explicit `RepositoryScopes` and `CommitMessage`, with `RepositoryPatches`, per-plugin messages or target branches when needed. Preview binds concrete candidates and excluded content; normal hooks stay enabled. Never use blanket add/reset/restore to make the workspace appear clean.
- Incomplete checkpoints must be visibly labelled `Incomplete`. `WithdrawalVerification` records `Kind='baseline'`, per-repository exact `RepositoryReferences` and evidence. A superseded `Carryover` records replacement `Target`, acceptance `Evidence` and explicit retained `RepositoryPatches`; baseline plus retained patch proves the intended remaining implementation. Changed or inseparable hunks stop before withdrawal. No owned implementation requires an explicit `NoImplementation` rationale, not an invented checkpoint.
- The operation journals implementation checkpoints, optional withdrawal commits, source/evaluation refresh, native archive, strict per-item archived validation and final canonical commit. Generated metadata is declared in the preview; these writes do not claim new implementation tests.
- Exact retry retains the original Gate, UID, earlier commits and archive bytes. `Stage=archived, Complete=false` means the canonical record commit still needs recovery. Query/PlanOnly never repairs. Do not append the final parent SHA into its own immutable archive.
- Only fully persisted closure becomes queue `archive-pending`; `close-pending` and execution `closing` retain the item without more implementation or advancement. Advancement records completed/abandoned/superseded truth separately from exhaustion of the authorized range.

Before any archive closure kind, run the exact evolution terminal gate:

```powershell
$result = Invoke-Harness -Command harness.evolution.status -Context $context -Parameters @{
    Change          = 'harness/exact-change-id'
    ClosureKind     = 'completed'
    RequireTerminal = $true
}
```

The terminal gate accepts only one exact active Change. Ordinary exact status remains available for immutable archives, while archived policy is audited with `openspec validate --archived --strict --json`; never apply new active-record rules retroactively. The gate consumes the packaged OpenSpec TaskPlan. Completed closure requires a valid, non-empty TaskPlan with every task complete. Abandoned and superseded closure may retain incomplete nodes only when their closure manifest records each disposition. An early incomplete closure may have no `tasks.md`; it still requires fresh evaluation and every other terminal check. A present empty or invalid plan remains a blocker.

- `openspec.change archive` enforces this same terminal gate and the exact saved `harness.change.close` decision at its mutation boundary. Its private `ClosureOperation` belongs to the close route; a raw archive call cannot bypass the explained Gate. These are automatic integrity checks, not additional user confirmations.
- The terminal gate checks every file beneath the exact active Change's `attachments/`, except INDEX itself: each needs one exact relative-path entry in `attachments/INDEX.md`, which must stay within 120 lines. This includes ordinary data, knowledge and any closure file stored there. Inline-code, bare-path and Markdown-link bullets, and inline-code paths in the first table column, are supported; prose mentions and empty directories are not entries. Ordinary status does not add this directory scan.
- Pass exactly one closure file. Its root kind must be explicit plain/quoted YAML or a JSON object; the route retains the checked bytes for the native archive operation. Missing, stale, failed or wrong-kind evaluation prevents the move.

Active `attachments/implementation/**/issue-*.md` records are discovered recursively and must be `openspec-material-issue-v2`, indexed exactly once, bound to existing TaskPlan IDs, timestamp-ordered, and structurally complete. Each must be `resolved`, evidence-backed `rejected`, or validly `superseded`; `open` remains valid during implementation but blocks closure. A superseded issue points to one active, indexed, non-superseded v2 owner whose `source_ref` reciprocally identifies the source issue. Historical schema-less records remain readable only after archive.

A valid indexed `harness-workflow-evaluation-v1` record with exact Change identity, ISO-8601 `captured_at`, `result: passed`, requested `closure_kind`, and current `input_sha256` is required. The digest covers every ordinary active Change file except the evaluation itself, using ordinal forward-slash paths and length-framed path/content bytes. Write the evaluation last; its capture time cannot precede the latest terminal issue or Review event. Ignored observations remain non-blocking until explicitly admitted as a material issue.

When an explicitly requested `attachments/reviews/**/review-*.md` file exists, active policy requires `review-v2`, exact INDEX membership, valid immutable-snapshot metadata, ordered lifecycle timestamps, and `closed | superseded` before every closure kind. A closed Review requires `APPROVE`; no Critical/Required finding may remain open or deferred. Review absence is valid.

Reusable gates cited as closure evidence must use hermetic fixtures or stable repository inputs. They must not require the current change to remain under `openspec/changes/`; before archive, confirm that the closing canonical change ID is not configured as a reusable gate's default fixture. Register every accepted performance aggregate and its raw-artifact hashes under `attachments/data/` and `attachments/INDEX.md` before archive; ignored `Saved/` output alone is not durable closure evidence.

Abandoned and superseded closure must not pretend incomplete tasks passed. Record each remaining task as `cancelled | superseded | needs_followup`, with a reason and follow-up reference where applicable. Preserve implementation, review, Replan, and verification history. Save the approved incomplete implementation before any withdrawal; rejected normal hooks leave unsaved code in place. Do not sync unfinished deltas as completed current specifications. Superseded closure follows the named replacement's exact accepted subset, rather than deleting every implementation change.

Archiving is a separate deterministic operation after policy checks. Closure never chooses or deletes a workspace or worktree. It does not merge specs, merge Git branches, push, remove a worktree, or manufacture completion evidence.

After the move, run strict archived validation and only the smallest applicable non-destructive check that does not reapply active terminal policy. The portable CLI's archived selector is aggregate-only; inspect the exact item's result and disclose unrelated historical failures without rewriting those archives or claiming an aggregate pass. `RequireTerminal` deliberately rejects an archived target. New discoveries retain the immutable archive and a sourced topic-draft question; only selected repair scope proceeds. A bounded direct repair already authorized by the user continues within its scope without another Change or repeated approval.

Neither observation admission nor the terminal gate starts Review or Replan. Review remains explicit-only; Replan remains evidence-gated by invalidated planning truth. A material finding discovered after archive does not automatically create a successor Change; batch it for the user under [evolution](evolution.md), preserving the archive.

- Before terminal evaluation, resolve current-scope discussions, finish Replan recovery, if transcript recording was explicitly enabled, synchronize and unbind its active Change sink. There is no default transcript or dual-writing requirement. Pending decisions or an active recording sink prevent archive; archived originals remain immutable.
