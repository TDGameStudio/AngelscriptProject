---
name: hardness
description: Lightweight entry router for AngelscriptProject work in a selected Git workspace. Use after project instructions enable Skills to orient work, resume an unattended request, handle an evidence-gated replan or explicitly requested review, or invoke project OpenSpec, workspace, Git, and observation routes.
---

# Hardness

Hardness is a small Skill router, not an agent runtime. The repository uses one Git-derived workspace model: the primary checkout and every registered linked worktree have the same contract. Hardness derives identity from Git, keeps execution rooted in the selected workspace, and loads trusted Skill code from the derived harness root. There is no daemon, database, event store, custom loop, or repository workflow mode.

Codex `/goal` is an external continuation mechanism. It can keep an agent working, but it does not select a repository mode, prescribe a branch name, create a worktree, or become state in `AgentConfig.ini` or OpenSpec. The current workspace remains the default; create or select a linked worktree only when the user explicitly asks for it.

Workspace creation, integration, publication, and removal are separate explicit actions. Never infer permission to run `workspace.new`, `git.integrate`, `git.push`, or `workspace.remove`; push is non-force and cleanup preserves the branch.

## Load progressively

Start with `AGENTS.md`, this file, the current `tasks.md` when a Change exists, and that Change's `attachments/INDEX.md`. Then load exactly one applicable leaf Skill or focused reference. Do not bulk-load command documentation, attachments, history, or scripts.

Use [routing.md](references/routing.md) only when the route is unclear. Load a protocol only when its event occurs:

- [task-dag.md](references/task-dag.md) when planning or selecting Ready work.
- [replan.md](references/replan.md) only after evidence invalidates accepted planning truth.
- [review.md](references/review.md) only after the user or an external agent explicitly requests a Review, or when triaging an existing Review file.
- [closure.md](references/closure.md) only when closing or archiving work.

OpenSpec is opt-in: create or mutate a Change only when the user or accepted work explicitly selects it.

## Orient and pass the Explore Gate

Before creating a Change, establish the authorized objective, selected workspace, and whether the intended behavior is decision-complete:

- A new feature, architecture refactor, or major behavior change without an accepted decision-complete handoff uses deep Explore before Change creation.
- A clear defect repair, mechanical documentation change, or accepted ready-to-execute plan may skip deep Explore.
- A decision-complete exploration handoff is not an active Change. If OpenSpec owns the work, resolve or create the canonical Change and its Ready Task DAG before implementation mutation.
- After Change creation, do not restart deep Explore for that Change. Use lightweight investigation inside the Ready task to inspect code, reproduce behavior, compare bounded options, or run a focused experiment. Update the Change only when evidence invalidates a requirement, design boundary, verification contract, dependency edge, or required artifact.

```text
unclear feature or architecture -> deep Explore -> accepted handoff -> create Change
Ready task uncertainty          -> lightweight investigation -> implement or evidence-gated replan
```

## Execute the work

1. Resolve the selected workspace and, when a Change exists, call `task.status` to choose a node whose derived `ready` field is true.
2. Read only the task's linked context. Implement the smallest complete slice, run its exact verification, and preserve useful evidence.
3. Mark the task complete only after verification passes. Never uncheck completed work; add a follow-up node when new work is required.
4. After verification, Replan autonomously only when evidence invalidates accepted planning truth. Ordinary implementation uncertainty and local defects stay inside the task.
5. Otherwise proceed directly to closure or archive. Hardness never starts an Incident or Final Review on its own and completion needs no Review classification.
6. When the user or an external agent explicitly requests a Review, follow [review.md](references/review.md). Any Review file that exists must reach a valid closed or superseded state before archive.
7. Integration, push, and workspace removal remain separate user-directed operations.

Investigate technical uncertainty and choose the strongest evidence-backed in-scope implementation without interrupting the user. Stop only when progress requires new authority: a product-goal change, destructive or external action outside scope, unavailable credentials, or irreconcilable user decisions.

## Explain relationships visually

Use `visual-explain` when a compact diagram materially clarifies multiple relationships, a sequence, or state transitions—for example workspace ownership, Task DAG readiness, Replan propagation, Review lifecycle, or cross-module execution. Prefer a small text diagram during conversation and a durable artifact only when future work benefits from it. Do not generate visuals for a single fact, a trivial edit, or information already clearer as one short list.

## Handle an explicit Review

An explicitly requested Review may run inline or as an asynchronous subagent. Asynchronous execution is an optimization, not a lifecycle default. In either case, assign an immutable snapshot and one unique Review file. While an asynchronous reviewer runs, continue only disjoint work; a moving workspace never redefines the assigned snapshot.

## PowerShell entry

PowerShell 7.0 or later (`Core`) is the only supported harness host. Keep one `pwsh.exe` session and import once:

```powershell
Import-Module ./.agents/skills/hardness/scripts/Hardness.psd1
$context = New-HardnessContext -WorkspaceRoot (Get-Location).Path
Get-HardnessCommand
Invoke-Hardness -Command hardness.status -Context $context
Invoke-Hardness -Command workspace.list -Context $context
Invoke-Hardness -Command workspace.status -Context $context
Invoke-Hardness -Command task.status -Context $context -Parameters @{ Change = 'domain/change' }
Invoke-Hardness -Command ue.status -Context $context
```

Every invocation returns the same small result envelope. `task.status` returns OpenSpec TaskPlan JSON in `data`; OpenSpec validates the frontmatter graph while Hardness owns workspace selection and scheduling. Task Card detail below the machine-readable surface remains ordinary Markdown for agents and people.

Unreal execution uses the same context and lazy-loads `unreal-engine-develop` only on the first `ue.*` route. Prefer `PlanOnly` before committing resources, `NoWait` when the caller wants an asynchronous `RunId`, `ue.run.status` for one managed run, and `ue.process.list` for a bounded machine view. Same-workspace operations remain exclusive; eligible Installed Engine builds may share an Engine lane across distinct worktrees. Load the leaf's [concurrency reference](../unreal-engine-develop/references/concurrency.md) only when selecting `Auto`, `Parallel`, or `Serialize`, choosing `Auto`, `Wait`, or `Fail`, or interpreting unknown progress.

The optional project Codex hooks run only fast, read-only `hardness.status` at `SessionStart` (`startup|resume`) and `SubagentStart`. They add bounded orientation context when the repository hooks are trusted. Hook failure is never a correctness dependency; Cursor, Grok, and ordinary terminal use continue to call the same public routes directly.

Run the core gates through one public test entry:

```powershell
pwsh.exe -NoProfile -File .agents/skills/hardness/scripts/Test-Hardness.ps1 -Profile Quick
pwsh.exe -NoProfile -File .agents/skills/hardness/scripts/Test-Hardness.ps1 -Profile Performance -WarmupRuns 3 -MeasurementRuns 15
pwsh.exe -NoProfile -File .agents/skills/hardness/scripts/Test-Hardness.ps1 -Profile Integration
```

Performance runs validate every timed sample. Raw `Summary.json` and `Samples.csv` remain below ignored `Saved/Hardness/Performance/`; durable Change evidence keeps only a privacy-trimmed aggregate and its hashes. The default TaskStatus measurement uses an isolated temporary graph. Register accepted aggregates in the current Change and its attachment index before archive; ignored raw data alone is not durable evidence.
