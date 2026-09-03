---
name: hardness
description: Lightweight entry router for AngelscriptProject work in native Goal mode or the current workspace. Use after project instructions enable skills, when choosing the project workflow, resuming an unattended goal, handling a replan or review gate, or invoking project OpenSpec and workspace routes.
---

# Hardness

Hardness is a skill router, not a loop runtime. Native Goal mode owns persistence and continuation; leaf skills own domain behavior. There is no daemon, database, event store, or generic async process layer.

## Choose the workspace mode

- **Goal**: default for an autonomous goal. Create `.worktrees/<goal>` on `goal/<goal>` through `workspace.new`, activate that workspace for the PowerShell session, then stay there. Finish committed, verified, reviewed, and ready to integrate.
- **Current**: use the current checkout when the user asks for direct work. Do not create or switch worktrees implicitly.

Neither mode integrates, pushes, or removes a worktree automatically. `git.integrate`, `git.push`, and `workspace.remove` run only for explicit user intent; `git.push` is non-force and `workspace.remove` preserves the Goal branch.

## Load only what is needed

Start with `AGENTS.md`, this file, the current `tasks.md` when a change exists, and that change's `attachments/INDEX.md`. Then load exactly one applicable leaf skill or reference. Do not bulk-load command docs, attachments, history, or scripts.

Use [routing.md](references/routing.md) only when the route is unclear. Load the focused protocol only when its event occurs:

- [task-dag.md](references/task-dag.md) for planning or selecting ready work.
- [replan.md](references/replan.md) after evidence invalidates the current plan.
- [review.md](references/review.md) only for a demonstrated major Incident Review, an impact-gated scope-frozen Final Review, or External Review intake.
- [closure.md](references/closure.md) only when closing or archiving a goal.

OpenSpec is opt-in: create or mutate an OpenSpec change only when the user or active goal explicitly selects it.

## Orient and pass the Explore Gate

Before creating a new change, identify the workspace mode, authorized objective, and whether the intended work is decision-complete:

- A new feature, architecture refactor, or major behavior change without an accepted decision-complete handoff routes to `openspec-explore` before `change create`.
- A clear defect repair, mechanical documentation change, or already approved ready-to-execute plan may skip deep exploration.
- A decision-complete handoff is not an active Change. When OpenSpec owns the work, resolve the canonical active Change and Ready Task DAG before implementation mutation; Current mode does not waive this checkpoint.
- Once the target Change exists, never invoke deep Explore for it. Revise existing planning truth through `openspec-update-change`; technical uncertainty inside a Ready task remains in the implementation leaf. Inspect, experiment, and choose autonomously; use replan only when evidence invalidates a requirement, design boundary, verification contract, dependency edge, or artifact.

```text
pre-change ambiguity -> deep Explore -> accepted handoff -> create Change -> planning
Ready task uncertainty -> local investigation -> repair, or evidence-gated replan
```

## Native Goal iteration

1. After orientation and the Explore Gate, call `task.status` for the selected change, choose a node whose derived `ready` field is true, and read only its linked context.
2. Implement the smallest complete slice, verify with the task's exact command, and preserve evidence.
3. Start an Incident Review only for a demonstrated major incident. At scope freeze, run one Final Review for broad-impact work; record `Final Review: not required` for a verified small low-impact change. Register user- or agent-started External Reviews without turning ordinary tasks into Review Gates.
4. If evidence invalidates a requirement, design boundary, verification contract, dependency edge, or artifact, apply the Replan protocol and continue autonomously.
5. Mark a task done only after its verification passes. Never uncheck it; create a new follow-up task.

When a reviewer subagent is available, assign it an immutable snapshot and unique Review file asynchronously. Continue disjoint work while it runs, but do not let a moving live workspace redefine its scope. A Final Review result cannot close the current gate after task-owned reviewed content changes; batch those changes and request one incremental Final Review after the next scope freeze.

Investigate technical uncertainty, compare in-scope options, and choose the strongest evidence-backed implementation without interrupting the goal. Stop only when progress requires new authority: a product-goal change, destructive or external action outside scope, unavailable credentials, or irreconcilable user decisions.

## PowerShell entry

PowerShell 7.0 or later (`Core`) is the only supported harness host. Keep one `pwsh.exe` session and import once:

```powershell
Import-Module ./.agents/skills/hardness/scripts/Hardness.psd1
$context = New-HardnessContext -Mode Current
Get-HardnessCommand
Invoke-Hardness -Command workspace.status -Context $context
Invoke-Hardness -Command workspace.config.status -Context $context
Invoke-Hardness -Command task.status -Context $context -Parameters @{ Change = 'domain/change' }
```

Every invocation returns the same small result envelope. `task.status` returns the OpenSpec TaskPlan JSON in `data`; OpenSpec parses and validates the frontmatter Graph while Hardness owns workspace selection and scheduling. Unreal command routing is deliberately absent from this core snapshot and will be added only by a separately planned and verified `unreal-engine-develop` change.

Run the core gates through one public test entry:

```powershell
pwsh.exe -NoProfile -File .agents/skills/hardness/scripts/Test-Hardness.ps1 -Profile Quick
pwsh.exe -NoProfile -File .agents/skills/hardness/scripts/Test-Hardness.ps1 -Profile Performance -WarmupRuns 3 -MeasurementRuns 15
pwsh.exe -NoProfile -File .agents/skills/hardness/scripts/Test-Hardness.ps1 -Profile Integration
```

Performance measures PowerShell 7 and validates every timed sample. Raw `Summary.json`/`Samples.csv` runs remain below ignored `Saved/Harness/Hardness/Performance/`; change evidence keeps only a privacy-trimmed aggregate with hashes. The default TaskStatus measurement uses an isolated temporary Task Graph; pass `-TaskChange domain/change` only when intentionally measuring an active project change. Register an accepted aggregate in the current change and its attachment index before archive; ignored raw data alone is not durable change evidence.
