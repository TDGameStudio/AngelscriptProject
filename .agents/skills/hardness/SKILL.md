---
name: hardness
description: Lightweight entry router for AngelscriptProject work in native Goal mode or the current workspace. Use after project instructions enable skills, when choosing the project workflow, resuming an unattended goal, handling a replan or review gate, or invoking project OpenSpec and workspace routes.
---

# Hardness

Hardness is a skill router, not a loop runtime. Native Goal mode owns persistence and continuation; leaf skills own domain behavior. There is no daemon, database, event store, or generic async process layer.

## Choose the workspace mode

- **Goal**: default for an autonomous goal. Create `.worktrees/<goal>` on `goal/<goal>` through `workspace.new`, then stay there. Finish committed, verified, reviewed, and ready to integrate.
- **Current**: use the current checkout when the user asks for direct work. Do not create or switch worktrees implicitly.

Neither mode merges, pushes, or removes a worktree automatically.

## Load only what is needed

Start with `AGENTS.md`, this file, the current `tasks.md` when a change exists, and that change's `attachments/INDEX.md`. Then load exactly one applicable leaf skill or reference. Do not bulk-load command docs, attachments, history, or scripts.

Use [routing.md](references/routing.md) only when the route is unclear. Load the focused protocol only when its event occurs:

- [task-dag.md](references/task-dag.md) for planning or selecting ready work.
- [replan.md](references/replan.md) after evidence invalidates the current plan.
- [review.md](references/review.md) at a planned review gate or explicit review request.
- [closure.md](references/closure.md) only when closing or archiving a goal.

OpenSpec is opt-in: create or mutate an OpenSpec change only when the user or active goal explicitly selects it.

## Native Goal iteration

1. Call `task.status` for the selected change, choose a node whose derived `ready` field is true, and read only its linked context.
2. Implement the smallest complete slice, verify with the task's exact command, and preserve evidence.
3. At planned high-risk slice gates and the final gate, run review and close its findings before completing the gate.
4. If evidence invalidates a requirement, design boundary, verification contract, dependency edge, or artifact, apply the Replan protocol and continue autonomously.
5. Mark a task done only after its verification passes. Never uncheck it; create a new follow-up task.

Investigate technical uncertainty, compare in-scope options, and choose the strongest evidence-backed implementation without interrupting the goal. Stop only when progress requires new authority: a product-goal change, destructive or external action outside scope, unavailable credentials, or irreconcilable user decisions.

## PowerShell entry

Keep one PowerShell session and import once:

```powershell
Import-Module ./.agents/skills/hardness/scripts/Hardness.psd1
$context = New-HardnessContext -Mode Current
Get-HardnessCommand
Invoke-Hardness -Command workspace.status -Context $context
Invoke-Hardness -Command task.status -Context $context -Parameters @{ Change = 'domain/change' }
```

Every invocation returns the same small result envelope. `task.status` returns the OpenSpec TaskPlan JSON in `data`; OpenSpec parses and validates the frontmatter Graph while Hardness owns workspace selection and scheduling. Unreal command routing is deliberately absent from this core snapshot and will be added only by a separately planned and verified `unreal-engine-develop` change.

Run the core gates through one public test entry:

```powershell
pwsh.exe -NoProfile -File .agents/skills/hardness/scripts/Test-Hardness.ps1 -Profile Quick -PowerShellHosts Both
pwsh.exe -NoProfile -File .agents/skills/hardness/scripts/Test-Hardness.ps1 -Profile Performance -PowerShellHosts Both -WarmupRuns 3 -MeasurementRuns 15
pwsh.exe -NoProfile -File .agents/skills/hardness/scripts/Test-Hardness.ps1 -Profile Integration -PowerShellHosts Both
```

Performance measures each PowerShell host independently and validates every timed sample. Raw `Summary.json`/`Samples.csv` runs remain below ignored `Saved/Harness/Hardness/Performance/`; change evidence keeps only a privacy-trimmed aggregate with hashes. Use `-TaskChange domain/change` when measuring a different active Task Graph, and never rank PS5 against PS7.
