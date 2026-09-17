# Read-only queries

- Resolve the selected Context, invoke the matching route, and explain its returned facts. Never answer live status from conversational memory alone.
- “Current tasks / what remains”: `harness.queue.status`; if no queue is configured, say so, then use `openspec.status` to list active Changes or `task.status` for an exact Change. Direct work outside a Change has no fabricated Task DAG.
- “This Change's tasks / why blocked”: `task.status -Parameters @{Change='domain/change'}`. Report complete, remaining, Ready tasks and returned dependency/issues; missing plans are `plan-needed`, never 0 tasks completed.
- “All workspace queues”: `workspace.list`, then from primary call `harness.queue.status` with each explicit `TargetWorkspaceRoot`. Report legacy parent worktrees as parked; do not attach queues or create chats. Independent read calls may be batched.
- “Workspace / Git state”: `workspace.status`; opt into `Detailed=$true` for dirty files, snapshots and plugin baselines, or use `git.status` for exact repository heads and staged paths.
- “Harness capabilities / health”: `Get-HarnessCommand` lists available routes; `harness.status` checks current identity, configuration readiness and packaged CLI availability.
- “Build/test progress”: `ue.run.status` with exact `RunId`; use `ue.process.list` to investigate active processes. A queue controller token or last task update does not prove that a chat/process is alive.
- “Discussion / Replan”: `harness.talk.status` and `harness.replan.status` for an exact Change; report unanswered questions, settled-but-unapplied decisions and recovery state.
- “This session / why stopped”: `harness.execution.status` with exact SessionId; distinguish waiting-input, user pause, blockers and derived completion.
- “Closure state”: `harness.evolution.status` with exact Change; include pending discussions and TaskPlan issues.

```powershell
$context = New-HarnessContext -WorkspaceRoot $PWD
Invoke-Harness harness.queue.status -Context $context
Invoke-Harness task.status -Context $context -Parameters @{Change='domain/change'}
Invoke-Harness workspace.list -Context $context
Get-HarnessCommand
```

- Present workspace, queue state, current Change, completed/total tasks, Ready/remaining counts and blocker where known. Distinguish an unconfigured queue, an exhausted queue and unknown task/activity state.
- Report `recovery-needed` before interpreting unpublished membership; `archive-pending` means completed work awaits queue advance, while `record-blocked` means missing or invalid records. Querying these states never repairs them or creates a replacement plan.
- Query errors are evidence to investigate; never repair, reorder, claim, resume or take over a queue merely because the user asked to inspect it.
