# Read-only queries

- Resolve the selected Context, invoke the matching route, and explain its returned facts. Never answer live status from conversational memory alone.
- “Current tasks / what remains”: `harness.queue.status`; if no queue is configured, say so, then use `openspec.change` with `-ArgumentList @('list', '--json')` to list active Changes or `task.status` for an exact Change. Direct work outside a Change has no fabricated Task DAG.
- “This Change's tasks / why blocked”: `task.status -Parameters @{Change='domain/change'}`. Report complete, remaining, Ready tasks and returned dependency/issues; missing plans are `plan-needed`, never 0 tasks completed.
- “All workspace queues”: `workspace.list`, then from primary call `harness.queue.status` with each explicit `TargetWorkspaceRoot`. Report legacy parent worktrees as parked; do not attach queues or create chats. Independent read calls may be batched.
- “Workspace / Git state”: `workspace.status`; opt into `Detailed=$true` for dirty files, snapshots and plugin baselines, or use `git.status` for exact repository heads and staged paths.
- “Workflow feedback inbox”: `harness.evolution.status` with `InboxOnly=$true` and optional `Limit`; report grouping, pending scope, issues and truncation. Querying does not select or resolve items.
- “Harness capabilities / health”: `Get-HarnessCommand` lists available routes; `harness.status` checks current identity, configuration readiness and packaged CLI availability, plus the current update revision/summary and any nonfatal UpdatesIssue.
- “Build/test progress”: `ue.run.status` with exact `RunId`; use `ue.process.list` to investigate active processes. A queue controller token or last task update does not prove that a chat/process is alive.
- “Discussion / Replan”: `harness.talk.status` and `harness.replan.status` for an exact Change; report unanswered questions, settled-but-unapplied decisions and recovery state.
- “This session / why stopped”: `harness.execution.status` with exact SessionId; distinguish waiting-input, user pause, blockers and derived completion.
- “Closure state”: `harness.queue.status` and exact `harness.execution.status` report partial Git closure; `harness.evolution.status` with exact Change adds terminal evidence/discussion/TaskPlan issues. An existing exact close request may use `PlanOnly` to read its saved stage, never to infer approval or repair.

```powershell
$context = New-HarnessContext -WorkspaceRoot $PWD
Invoke-Harness harness.queue.status -Context $context
Invoke-Harness openspec.change -Context $context -ArgumentList @('list', '--json')
Invoke-Harness task.status -Context $context -Parameters @{Change='domain/change'}
Invoke-Harness workspace.list -Context $context
Get-HarnessCommand
```

- Present workspace, queue state, current Change, completed/total tasks, Ready/remaining counts and blocker where known. Distinguish an unconfigured queue, an exhausted queue and unknown task/activity state.
- Report `recovery-needed` before interpreting unpublished membership. `close-pending` (execution `closing`) means approved closure still needs Git/withdrawal recovery and cannot advance. `archive-pending` means fully persisted completed/abandoned/superseded work awaits queue registration; report its actual kind. `record-blocked` means missing or invalid records. Planning commit-pending separately blocks implementation. Queries never repair these states or create a replacement plan.
- Query errors are evidence to investigate; never repair, reorder, claim, resume or take over a queue merely because the user asked to inspect it.
