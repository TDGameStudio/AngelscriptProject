---
name: change-queue
description: Configure, inspect, or execute an explicit ordered Change queue in the selected Harness workspace. Continue through completed archives, handle feedback and recover an interrupted controller; ordinary chat is sufficient.
---

# Change Queue

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

## Execute

1. Read `harness.queue.status`, then `claim` with this session's identity; this also reconciles an interrupted write.
   - Keep its controller token and bind the authorized queue with `harness.execution.start` (`Scope=Queue`, exact SessionId and user SourceRef).
   - Existing occupation by another session needs explicit takeover; a token is not evidence that a chat is alive.
   - For `archive-pending`, advance the completed archive before reading active tasks.
   - `record-blocked` needs investigation, not Ensure plan.
2. Read the current Change's `tasks.md` and attachment index from the record root.
   - Use `openspec-apply-change` for Ensure plan and Ready tasks.
   - Resolve implementation paths against the execution workspace; prepare approved plugin dependencies through `workspace.prepare` when needed.
   - Checkpoint actual source identities before implementation and refresh them before closure.
3. Check queue and `harness.execution.status` before tasks/closure and after long verification.
   - Triage and acknowledge exact pending input IDs.
   - Necessary unanswered decisions pause the whole current Change; do not skip to another member.
   - On a pause request, preserve progress and release the controller.
   - Do not claim that writing a pause request terminates a running tool or UE process.
4. Repair ordinary failures inside the current task.
   - Feedback first expands affected decisions.
   - Use independent `grill` with the exact Change's talk, then `harness.replan.apply`; retain valid work and return to new Ready nodes without another start request.
   - Record unrelated ideas as follow-ups without enqueuing them.
   - Pause on a genuine unresolved blocker, without skipping to another Change.
5. After verification, commit only owned plugin paths through `git.commit` with `PluginsOnly` and `PreserveOutsideStaged`.
   - Capture actual baseline/result repository identities in `harness.queue.checkpoint` before the final closure evaluation.
   - Main-repository commits remain user-directed.
6. Complete required spec synchronization and the existing terminal/archive protocol.
   - No automatic Review.
   - Advance only after the exact Change has a `completed` archive; interrupted archive-to-advance transitions are recoverable.
7. Repeat until no pending members remain or a real blocker occurs.
   - Release on a normal stop while still owning a controller; final advance releases automatically.
   - Report archived, removed and remaining members separately, plus current task progress or `plan-needed`.

- In a replica, a previously unapproved host/control-center code modification pauses with a concrete proposal.
  - This does not restrict already authorized work in the primary workspace.
- Removing an item changes queue membership, not its Change lifecycle.
  - Started items retain their execution provenance; do not transfer work to another queue automatically.
- Integration, push, workspace creation/removal and branch deletion remain separate user-directed actions.
  - Preparing plugin worktrees already covered by the approved workspace/Change scope is authorized.
