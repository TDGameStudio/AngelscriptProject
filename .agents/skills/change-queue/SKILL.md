---
name: change-queue
description: Configure, inspect, or execute an explicit ordered Change queue in the selected Harness workspace. Continue through completed archives, handle feedback and recover an interrupted controller; ordinary chat is sufficient.
---

# Change Queue

## Select the workspace and scope

- Use the selected Harness Context.
  - The primary workspace is both control center and a full execution workspace, including major host and framework changes.
- Read [queue operations](references/operations.md) when configuring, taking over, or inspecting route parameters.
  - Queue state is local; canonical Changes and specs are in `Context.OpenSpecRoot`.
- “Execute/continue this workspace's queue until finished” authorizes sequential execution in ordinary chat.
  - Unattended continuation is optional; see Harness.
  - If neither a queue nor pending recovery exists, obtain an explicit ordered Change list; never select all active Changes automatically.
- A new workspace starts with no queue.
- The control center may inspect or adjust another registered queue using an explicit target.
  - Execution and requirements feedback stay in that workspace's chat.

## Bind the authorized execution

- Read `harness.queue.status`, then bind the exact authorized scope with `harness.execution.start` (Scope=Queue or the Scope=Change single-item adapter, exact SessionId and actual user SourceRef).
- All Change execution uses the same queue core. Never overwrite/reorder a configured queue or execute preceding members to reach a requested non-head target.
- The controller captures ordered AuthorizedUids and SourceRef; explicit claim/recovery retains that bound. A tail append does not expand it; changes to its remaining ordered prefix are rejected.
- Existing occupation by another session needs explicit takeover; a token is not evidence that a chat is alive.
- For `archive-pending`, advance the completed archive before reading active tasks. `record-blocked` needs investigation, not Ensure plan.

## Execute the current Change and process feedback

- Read the current Change's `tasks.md` and attachment index from the record root. Use `openspec-apply-change` for Ensure plan and Ready tasks.
- Resolve implementation paths against the execution workspace; prepare approved plugin dependencies through `workspace.prepare` when needed. Checkpoint actual source identities before implementation and refresh them before closure.
- Check queue and `harness.execution.status` before tasks/closure and after long verification.
  - Capture actual new input through `harness.execution.input` (InputId/SourceRef/Summary/Kind), then triage and acknowledge exact IDs. Acknowledgement grants no approval or resume authority.
  - Necessary unanswered decisions pause the whole current Change; do not skip to another member.
  - On a pause request, preserve progress and release the controller. Do not claim that writing a pause request terminates a running tool or UE process.
- Triage feedback against the accepted scope and plan before choosing the next action.
  - Repair an ordinary in-scope implementation failure inside the current task. A failed assertion or review finding alone does not require Update.
  - Use Update only when evidence invalidates a requirement, design/task boundary or edge, verification contract or required artifact, or exposes a user-owned decision. Open/reuse its linked draft and Change talk; explain/Grill until user-led convergence, apply the exact approved Replan, then ask and apply its draft/execution arrangement Gate. Retain valid work and return only under the current arrangement; “later” cannot revive an old execution request.
  - Record unrelated ideas as follow-ups without enqueuing them. Pause on a genuine unresolved blocker, without skipping to another Change.

## Close and continue the authorized range

- After verification, commit only owned plugin paths through `git.commit` with `PluginsOnly` and `PreserveOutsideStaged`. Main-repository commits remain user-directed.
- Capture actual baseline/result repository identities in `harness.queue.checkpoint` before the final closure evaluation.
- Complete required spec synchronization and the existing terminal/archive protocol. No automatic Review.
- Advance only after the exact Change has a `completed` archive; interrupted archive-to-advance transitions are recoverable.
- Repeat until the authorized UID range is exhausted or a real blocker occurs.
  - A single-item request stops/releases after its completed archive without marking the following queue item started. Appended unapproved work remains pending outside this execution request.
  - Release on a normal stop while still owning a controller; final advance releases automatically.
  - Report archived, removed and remaining members separately, plus current task progress or `plan-needed`.

## Preserve workspace and lifecycle boundaries

- In a replica, a previously unapproved host/control-center code modification pauses with a concrete proposal.
  - This does not restrict already authorized work in the primary workspace.
- Removing an item changes queue membership, not its Change lifecycle.
  - Started items retain their execution provenance; do not transfer work to another queue automatically.
- Integration, push, workspace creation/removal and branch deletion remain separate user-directed actions.
  - Preparing plugin worktrees already covered by the approved workspace/Change scope is authorized.
