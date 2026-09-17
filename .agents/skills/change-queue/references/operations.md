# Queue operations

- Import Harness from the control center; construct Context with the actual execution WorkspaceRoot.
- `harness.queue.status`: no mutation; returns revision, ordered items, current Change, dispositions, controller record, pause state and live TaskPlan progress. Unknown activity remains `unknown`; missing planning is `plan-needed`, with unknown task counts.
- Recovery: `recoveryPending` / `planState=recovery-needed` reports an unpublished transaction without replaying it. Authorized execution resumes with `claim`. `archive-pending` identifies an exact completed archive awaiting `advance`; `record-blocked` carries missing/invalid record issues. Neither goes through Ensure plan. Editing an exhausted queue returns it to idle when pending work exists, preserving any requested pause.
- `harness.queue.set`: `Changes = @('domain/change-a','domain/change-b')`, `ExpectedRevision = <status revision>`. Deduplicates in order and binds each active Change to this workspace.
- `harness.queue.remove`: `Change`, `ExpectedRevision`; removes a pending member. `reorder`: `Changes`, `ExpectedRevision`; supplies exactly the pending IDs in their new order. Pause/release before removing or moving the active head.
- `harness.queue.pause`: `Reason`; the owner acknowledges by releasing at a checkpoint. With no owner it becomes paused immediately.
- `status/set/remove/reorder/pause` accept `TargetWorkspaceRoot` only from the primary Context and only within that control center.
- `harness.queue.claim`: `SessionId`; returns `controller.token`. Use the actual session ID where available; on other hosts generate one stable ID for the current chat invocation and retain it.
- `harness.queue.release`: `Token`; normal completion or a bounded stop releases ownership.
- `harness.queue.takeover`: `SessionId`, `PreviousControllerStopped = $true`; only after an explicit takeover request and confirming the former controller stopped. Harness inspects Unreal activity; unresolved activity blocks takeover. Never steal by elapsed time.
- `harness.queue.checkpoint`: `Token`; automatically captures actual host and plugin identities in indexed `attachments/data/harness-execution.json`. The first checkpoint retains `sourceBaseline`; later checkpoints refresh `source` and repository result HEADs. Primary host evidence includes HEAD, dirty paths and a content fingerprint including untracked files; replica host evidence includes copied/current file hashes. No fake root HEAD is created.
- Optional `Repositories = @(@{path='Plugins/Foo'; baseCommit='<sha>'; resultCommit='<sha>'})` narrows explicit commit evidence; every supplied result must match the actual selected plugin HEAD. Capture before implementation and before final evaluation; paths/runtime bindings remain local, while this attachment stores relative identities.
- The primary source fingerprint excludes canonical `openspec/` records to avoid hashing the checkpoint into itself; those records have their own Change input digest at closure.
- `harness.queue.advance`: `Token`; validates exact manifest UID, Change ID and completed closure in the archive before advancing. It does not perform verification, archive, merge, push or run an agent.
- Queue mutations use short OS locks, revision checks and a recoverable file transaction. Local state does not duplicate Task DAGs or test evidence.
